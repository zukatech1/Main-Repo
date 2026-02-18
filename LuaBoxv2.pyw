import sys
import re
import subprocess
import tempfile
import os
import fnmatch

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QTextEdit, QVBoxLayout,
    QHBoxLayout, QWidget, QPushButton, QLabel, QSplitter,
    QPlainTextEdit, QStatusBar, QFileDialog, QTreeWidget,
    QTreeWidgetItem, QTabWidget, QMessageBox, QDialog,
    QFormLayout, QComboBox, QSpinBox, QCheckBox, QMenu
)
from PyQt6.QtGui import (
    QFont, QColor, QTextCharFormat, QSyntaxHighlighter,
    QPainter, QTextFormat, QAction, QIcon, QTextDocument
)
from PyQt6.QtCore import Qt, QRect, QSize, QDir

from PyQt6.QtCore import QFileSystemWatcher, QTimer


# --- Line Number Area Widget ---
class LineNumberArea(QWidget):
    def __init__(self, editor):
        super().__init__(editor)
        self.editor = editor

    def sizeHint(self):
        return QSize(self.editor.line_number_area_width(), 0)

    def paintEvent(self, event):
        self.editor.line_number_area_paint_event(event)


# --- Code Editor with Line Numbers ---
class CodeEditor(QPlainTextEdit):
    def __init__(self):
        super().__init__()
        self.line_number_area = LineNumberArea(self)
        
        self.blockCountChanged.connect(self.update_line_number_area_width)
        self.updateRequest.connect(self.update_line_number_area)
        self.cursorPositionChanged.connect(self.highlight_current_line)
        
        self.update_line_number_area_width(0)
        self.highlight_current_line()
        
        # Zoom level tracking
        self.zoom_level = 0
        self.base_font_size = 11

    def wheelEvent(self, event):
        """Handle zoom with Ctrl + scroll wheel."""
        if event.modifiers() == Qt.KeyboardModifier.ControlModifier:
            delta = event.angleDelta().y()
            if delta > 0:
                self.zoom_in()
            elif delta < 0:
                self.zoom_out()
            event.accept()
        else:
            super().wheelEvent(event)
    
    def zoom_in(self):
        """Increase font size."""
        if self.zoom_level < 10:
            self.zoom_level += 1
            self.update_font_size()
    
    def zoom_out(self):
        """Decrease font size."""
        if self.zoom_level > -5:
            self.zoom_level -= 1
            self.update_font_size()
    
    def reset_zoom(self):
        """Reset zoom to default."""
        self.zoom_level = 0
        self.update_font_size()
    
    def update_font_size(self):
        """Update the font size based on zoom level."""
        new_size = self.base_font_size + self.zoom_level
        font = self.font()
        font.setPointSize(new_size)
        self.setFont(font)
        self.update_line_number_area_width(0)

    def line_number_area_width(self):
        digits = len(str(max(1, self.blockCount())))
        space = 10 + self.fontMetrics().horizontalAdvance('9') * digits
        return space

    def update_line_number_area_width(self, _):
        self.setViewportMargins(self.line_number_area_width(), 0, 0, 0)

    def update_line_number_area(self, rect, dy):
        if dy:
            self.line_number_area.scroll(0, dy)
        else:
            self.line_number_area.update(0, rect.y(), self.line_number_area.width(), rect.height())

        if rect.contains(self.viewport().rect()):
            self.update_line_number_area_width(0)

    def resizeEvent(self, event):
        super().resizeEvent(event)
        cr = self.contentsRect()
        self.line_number_area.setGeometry(QRect(cr.left(), cr.top(), self.line_number_area_width(), cr.height()))

    def line_number_area_paint_event(self, event):
        painter = QPainter(self.line_number_area)
        painter.fillRect(event.rect(), QColor("#E8E8E8"))

        block = self.firstVisibleBlock()
        block_number = block.blockNumber()
        top = self.blockBoundingGeometry(block).translated(self.contentOffset()).top()
        bottom = top + self.blockBoundingRect(block).height()

        while block.isValid() and top <= event.rect().bottom():
            if block.isVisible() and bottom >= event.rect().top():
                number = str(block_number + 1)
                painter.setPen(QColor("#666666"))
                painter.drawText(0, int(top), self.line_number_area.width() - 5, 
                               self.fontMetrics().height(), Qt.AlignmentFlag.AlignRight, number)

            block = block.next()
            top = bottom
            bottom = top + self.blockBoundingRect(block).height()
            block_number += 1

    def highlight_current_line(self):
        extra_selections = []

        if not self.isReadOnly():
            selection = QTextEdit.ExtraSelection()
            line_color = QColor("#E8F4FF")
            selection.format.setBackground(line_color)
            selection.format.setProperty(QTextFormat.Property.FullWidthSelection, True)
            selection.cursor = self.textCursor()
            selection.cursor.clearSelection()
            extra_selections.append(selection)

        self.setExtraSelections(extra_selections)


# --- Syntax Highlighting ---
class LuaSyntaxHighlighter(QSyntaxHighlighter):
    def __init__(self, parent):
        super().__init__(parent)
        self.highlighting_rules = []

        # Keywords (Blue)
        keyword_format = QTextCharFormat()
        keyword_format.setForeground(QColor("#0000FF"))
        keyword_format.setFontWeight(QFont.Weight.Bold)
        keywords = [
            "\\band\\b", "\\bbreak\\b", "\\bdo\\b", "\\belse\\b", "\\belseif\\b",
            "\\bend\\b", "\\bfalse\\b", "\\bfor\\b", "\\bfunction\\b", "\\bif\\b",
            "\\bin\\b", "\\blocal\\b", "\\bnil\\b", "\\bnot\\b", "\\bor\\b",
            "\\brepeat\\b", "\\breturn\\b", "\\bthen\\b", "\\btrue\\b", "\\buntil\\b", "\\bwhile\\b"
        ]
        self.highlighting_rules.extend([(re.compile(pattern), keyword_format) for pattern in keywords])

        # Built-in functions (Purple)
        builtin_format = QTextCharFormat()
        builtin_format.setForeground(QColor("#8000FF"))
        builtins = [
            "\\bprint\\b", "\\btostring\\b", "\\btonumber\\b", "\\btype\\b",
            "\\bpairs\\b", "\\bipairs\\b", "\\btable\\b", "\\bstring\\b",
            "\\bmath\\b", "\\bos\\b", "\\bio\\b", "\\brequire\\b"
        ]
        self.highlighting_rules.extend([(re.compile(pattern), builtin_format) for pattern in builtins])

        # Strings (Brown/Dark orange)
        string_format = QTextCharFormat()
        string_format.setForeground(QColor("#A31515"))
        self.highlighting_rules.append((re.compile("\".*?\""), string_format))
        self.highlighting_rules.append((re.compile("'.*?'"), string_format))

        # Numbers (Dark cyan)
        number_format = QTextCharFormat()
        number_format.setForeground(QColor("#098658"))
        self.highlighting_rules.append((re.compile("\\b[0-9]+\\.?[0-9]*\\b"), number_format))

        # Comments (Green)
        comment_format = QTextCharFormat()
        comment_format.setForeground(QColor("#008000"))
        self.highlighting_rules.append((re.compile("--[^\\[].*"), comment_format))

    def highlightBlock(self, text):
        for pattern, format in self.highlighting_rules:
            for match in pattern.finditer(text):
                start, end = match.span()
                self.setFormat(start, end - start, format)

        # Multi-line comment highlighting
        self.setCurrentBlockState(0)
        comment_format = QTextCharFormat()
        comment_format.setForeground(QColor("#008000"))
        
        start_index = 0
        if self.previousBlockState() != 1:
            start_index = text.find('--[[')
        
        while start_index >= 0:
            end_index = text.find(']]', start_index)
            if end_index == -1:
                self.setCurrentBlockState(1)
                comment_len = len(text) - start_index
            else:
                comment_len = end_index - start_index + 2
            
            self.setFormat(start_index, comment_len, comment_format)
            start_index = text.find('--[[', start_index + comment_len)


# --- Smart Comment Remover ---
class LuaCommentRemover:
    """Intelligently removes comments while preserving code structure."""
    
    @staticmethod
    def remove_comments(code):
        """
        Remove Lua comments intelligently:
        - Preserves strings (doesn't touch -- inside strings)
        - Keeps code on lines with trailing comments
        - Only removes lines that are purely comments
        - Handles multi-line comments properly
        """
        lines = code.split('\n')
        result_lines = []
        in_multiline_comment = False
        
        for line in lines:
            # Check if we're in a multi-line comment
            if in_multiline_comment:
                if ']]' in line:
                    # End of multi-line comment
                    after_comment = line.split(']]', 1)[1]
                    in_multiline_comment = False
                    if after_comment.strip():
                        result_lines.append(after_comment)
                continue
            
            # Check for start of multi-line comment
            if '--[[' in line:
                before_comment = line.split('--[[', 1)[0]
                remaining = line.split('--[[', 1)[1]
                
                # Check if it closes on the same line
                if ']]' in remaining:
                    after_comment = remaining.split(']]', 1)[1]
                    cleaned = before_comment + after_comment
                    if cleaned.strip():
                        result_lines.append(cleaned)
                else:
                    # Multi-line comment starts
                    in_multiline_comment = True
                    if before_comment.strip():
                        result_lines.append(before_comment)
                continue
            
            # Handle single-line comments
            cleaned_line = LuaCommentRemover._remove_single_line_comment(line)
            
            # Only add non-empty lines
            if cleaned_line.strip():
                result_lines.append(cleaned_line)
        
        return '\n'.join(result_lines)
    
    @staticmethod
    def _remove_single_line_comment(line):
        """Remove single-line comment while respecting strings."""
        # We need to find -- that's not inside a string
        in_string = False
        string_char = None
        escaped = False
        
        for i, char in enumerate(line):
            if escaped:
                escaped = False
                continue
            
            if char == '\\':
                escaped = True
                continue
            
            # Track string state
            if char in ['"', "'"] and not in_string:
                in_string = True
                string_char = char
            elif char == string_char and in_string:
                in_string = False
                string_char = None
            
            # Look for -- outside of strings
            elif not in_string and char == '-' and i + 1 < len(line) and line[i + 1] == '-':
                # Found a comment marker outside a string
                return line[:i].rstrip()
        
        return line


# --- Settings Dialog ---
class SettingsDialog(QDialog):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Settings")
        self.setModal(True)
        self.setMinimumWidth(400)
        
        layout = QFormLayout()
        
        # Font size
        self.font_size = QSpinBox()
        self.font_size.setRange(8, 24)
        self.font_size.setValue(11)
        layout.addRow("Font Size:", self.font_size)
        
        # Theme (for future expansion)
        self.theme = QComboBox()
        self.theme.addItems(["Light", "Dark (Coming Soon)"])
        layout.addRow("Theme:", self.theme)
        
        # Buttons
        btn_layout = QHBoxLayout()
        btn_ok = QPushButton("OK")
        btn_cancel = QPushButton("Cancel")
        btn_ok.clicked.connect(self.accept)
        btn_cancel.clicked.connect(self.reject)
        btn_layout.addWidget(btn_ok)
        btn_layout.addWidget(btn_cancel)
        
        layout.addRow(btn_layout)
        self.setLayout(layout)


# --- Find & Replace Dialog ---
class FindReplaceDialog(QDialog):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Find & Replace")
        self.setModal(False)
        self.setMinimumWidth(450)
        
        layout = QVBoxLayout()
        
        # Find section
        find_layout = QHBoxLayout()
        find_label = QLabel("Find:")
        find_label.setMinimumWidth(60)
        self.find_input = QTextEdit()
        self.find_input.setMaximumHeight(30)
        find_layout.addWidget(find_label)
        find_layout.addWidget(self.find_input)
        layout.addLayout(find_layout)
        
        # Replace section
        replace_layout = QHBoxLayout()
        replace_label = QLabel("Replace:")
        replace_label.setMinimumWidth(60)
        self.replace_input = QTextEdit()
        self.replace_input.setMaximumHeight(30)
        replace_layout.addWidget(replace_label)
        replace_layout.addWidget(self.replace_input)
        layout.addLayout(replace_layout)
        
        # Options
        options_layout = QHBoxLayout()
        self.case_sensitive = QCheckBox("Case Sensitive")
        self.whole_word = QCheckBox("Whole Words")
        options_layout.addWidget(self.case_sensitive)
        options_layout.addWidget(self.whole_word)
        options_layout.addStretch()
        layout.addLayout(options_layout)
        
        # Buttons
        btn_layout = QHBoxLayout()
        
        self.btn_find_next = QPushButton("Find Next")
        self.btn_find_prev = QPushButton("Find Previous")
        self.btn_replace = QPushButton("Replace")
        self.btn_replace_all = QPushButton("Replace All")
        btn_close = QPushButton("Close")
        
        btn_close.clicked.connect(self.close)
        
        btn_layout.addWidget(self.btn_find_next)
        btn_layout.addWidget(self.btn_find_prev)
        btn_layout.addWidget(self.btn_replace)
        btn_layout.addWidget(self.btn_replace_all)
        btn_layout.addStretch()
        btn_layout.addWidget(btn_close)
        
        layout.addLayout(btn_layout)
        
        # Status label
        self.status_label = QLabel("")
        self.status_label.setStyleSheet("color: #666666; font-size: 9pt;")
        layout.addWidget(self.status_label)
        
        self.setLayout(layout)


# --- Obfuscator Dialog ---
class ObfuscatorDialog(QDialog):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Obfuscator")
        self.setModal(True)
        self.setMinimumWidth(500)
        
        layout = QVBoxLayout()
        
        # Title
        title = QLabel("Obfuscate")
        title.setStyleSheet("font-size: 14pt; font-weight: bold; color: #E81123;")
        layout.addWidget(title)
        
        desc = QLabel("Select obfuscation options below:")
        desc.setStyleSheet("color: #666666; margin-bottom: 10px;")
        desc.setWordWrap(True)
        layout.addWidget(desc)
        
        # Preset selection
        preset_layout = QHBoxLayout()
        preset_label = QLabel("Preset:")
        preset_label.setMinimumWidth(120)
        self.preset_combo = QComboBox()
        self.preset_combo.addItems(["Light", "Medium", "Heavy", "Maximum", "Custom"])
        self.preset_combo.currentTextChanged.connect(self.apply_preset)
        preset_layout.addWidget(preset_label)
        preset_layout.addWidget(self.preset_combo)
        preset_layout.addStretch()
        layout.addLayout(preset_layout)
        
        layout.addSpacing(10)
        
        # Options group
        options_group = QWidget()
        options_layout = QVBoxLayout(options_group)
        options_layout.setContentsMargins(10, 10, 10, 10)
        options_group.setStyleSheet("QWidget { background-color: #F5F5F5; border-radius: 5px; }")
        
        # Variable renaming
        self.rename_vars = QCheckBox("Rename Variables")
        self.rename_vars.setChecked(True)
        self.rename_vars.setToolTip("Rename local variables to random meaningless names")
        options_layout.addWidget(self.rename_vars)
        
        # String encoding
        self.encode_strings = QCheckBox("Encode Strings")
        self.encode_strings.setChecked(True)
        self.encode_strings.setToolTip("Convert strings to byte arrays or encoded format")
        options_layout.addWidget(self.encode_strings)
        
        # Number encoding
        self.encode_numbers = QCheckBox("Encode Numbers")
        self.encode_numbers.setChecked(False)
        self.encode_numbers.setToolTip("Obfuscate numeric literals")
        options_layout.addWidget(self.encode_numbers)
        
        # Control flow
        self.control_flow = QCheckBox("Control Flow Obfuscation")
        self.control_flow.setChecked(True)
        self.control_flow.setToolTip("Add fake conditional branches and complex control flow")
        options_layout.addWidget(self.control_flow)
        
        # Dead code
        self.add_junk = QCheckBox("Insert Junk Code")
        self.add_junk.setChecked(False)
        self.add_junk.setToolTip("Add random non-functional code")
        options_layout.addWidget(self.add_junk)
        
        # Minify
        self.minify = QCheckBox("Minify (Remove Whitespace)")
        self.minify.setChecked(True)
        self.minify.setToolTip("Remove all unnecessary whitespace and comments")
        options_layout.addWidget(self.minify)
        
        # Anti-debug
        self.anti_debug = QCheckBox("Anti-Debug Protection")
        self.anti_debug.setChecked(False)
        self.anti_debug.setToolTip("Add anti-debugging and anti-tampering checks")
        options_layout.addWidget(self.anti_debug)
        
        # Wrap in function
        self.wrap_function = QCheckBox("Wrap in Anonymous Function")
        self.wrap_function.setChecked(True)
        self.wrap_function.setToolTip("Wrap entire code in a self-executing function")
        options_layout.addWidget(self.wrap_function)

        # ProxifyLocals
        self.proxify_locals = QCheckBox("Proxify Locals  [Prometheus]")
        self.proxify_locals.setChecked(False)
        self.proxify_locals.setToolTip(
            "Wrap local variables in metatable proxy objects so reads/writes go through "
            "__index/__newindex metamethods (inspired by Prometheus ProxifyLocals)"
        )
        self.proxify_locals.setStyleSheet("color: #6600CC; font-weight: bold;")
        options_layout.addWidget(self.proxify_locals)

        # Vmify
        self.vmify = QCheckBox("Vmify — Bytecode VM Encoding  [Prometheus]")
        self.vmify.setChecked(False)
        self.vmify.setToolTip(
            "XOR-encrypt the entire script and wrap it in a custom Luau VM loader that "
            "decodes and executes it at runtime (inspired by Prometheus Vmify). "
            "Applied last — overrides wrap_function."
        )
        self.vmify.setStyleSheet("color: #CC0000; font-weight: bold;")
        options_layout.addWidget(self.vmify)
        
        layout.addWidget(options_group)
        
        layout.addSpacing(10)
        
        # Warning
        warning = QLabel("Heavily obfuscated code may run slower and be harder to debug. "
                         "Vmify is the strongest option — it encodes the entire script.")
        warning.setStyleSheet("color: #FF8800; font-size: 9pt;")
        warning.setWordWrap(True)
        layout.addWidget(warning)
        
        # Buttons
        btn_layout = QHBoxLayout()
        
        self.btn_obfuscate = QPushButton("Obfuscate")
        self.btn_obfuscate.setStyleSheet("""
            QPushButton {
                background-color: #E81123;
                color: white;
                font-weight: bold;
                padding: 8px 20px;
                border-radius: 4px;
            }
            QPushButton:hover {
                background-color: #C50F1F;
            }
        """)
        
        btn_cancel = QPushButton("Cancel")
        
        btn_layout.addStretch()
        btn_layout.addWidget(btn_cancel)
        btn_layout.addWidget(self.btn_obfuscate)
        
        layout.addLayout(btn_layout)
        
        self.setLayout(layout)
        
        # Connect buttons
        btn_cancel.clicked.connect(self.reject)
        self.btn_obfuscate.clicked.connect(self.accept)
        
        # Apply default preset
        self.apply_preset("Medium")
    
    def apply_preset(self, preset):
        """Apply a preset configuration."""
        # Reset new options first
        self.proxify_locals.setChecked(False)
        self.vmify.setChecked(False)

        if preset == "Light":
            self.rename_vars.setChecked(True)
            self.encode_strings.setChecked(False)
            self.encode_numbers.setChecked(False)
            self.control_flow.setChecked(False)
            self.add_junk.setChecked(False)
            self.minify.setChecked(True)
            self.anti_debug.setChecked(False)
            self.wrap_function.setChecked(True)
        elif preset == "Medium":
            self.rename_vars.setChecked(True)
            self.encode_strings.setChecked(True)
            self.encode_numbers.setChecked(False)
            self.control_flow.setChecked(True)
            self.add_junk.setChecked(False)
            self.minify.setChecked(True)
            self.anti_debug.setChecked(False)
            self.wrap_function.setChecked(True)
        elif preset == "Heavy":
            self.rename_vars.setChecked(True)
            self.encode_strings.setChecked(True)
            self.encode_numbers.setChecked(True)
            self.control_flow.setChecked(True)
            self.add_junk.setChecked(True)
            self.minify.setChecked(True)
            self.anti_debug.setChecked(True)
            self.wrap_function.setChecked(True)
            self.proxify_locals.setChecked(True)
        elif preset == "Maximum":
            self.rename_vars.setChecked(True)
            self.encode_strings.setChecked(True)
            self.encode_numbers.setChecked(True)
            self.control_flow.setChecked(True)
            self.add_junk.setChecked(True)
            self.minify.setChecked(True)
            self.anti_debug.setChecked(True)
            self.wrap_function.setChecked(True)
            self.proxify_locals.setChecked(True)
            self.vmify.setChecked(True)
        # Custom doesn't change anything
    
    def get_options(self):
        """Return the selected options as a dictionary."""
        return {
            'rename_vars': self.rename_vars.isChecked(),
            'encode_strings': self.encode_strings.isChecked(),
            'encode_numbers': self.encode_numbers.isChecked(),
            'control_flow': self.control_flow.isChecked(),
            'add_junk': self.add_junk.isChecked(),
            'minify': self.minify.isChecked(),
            'anti_debug': self.anti_debug.isChecked(),
            'wrap_function': self.wrap_function.isChecked(),
            'proxify_locals': self.proxify_locals.isChecked(),
            'vmify': self.vmify.isChecked(),
        }


# --- Lua Obfuscator ---
class LuaObfuscator:
    """Obfuscate Lua code with various techniques."""
    
    def __init__(self, options):
        self.options = options
        self.var_map = {}
        self.var_counter = 0
        
    def obfuscate(self, code):
        """Main obfuscation function."""
        result = code
        
        # Add watermark at the top
        watermark = """--[[Obfuscated with LuaBox v3 by Zuka]]"""
        result = watermark + result
        
        # Step 1: Rename variables
        
        
        # Step 1: Rename variables (before other transformations)
        if self.options['rename_vars']:
            result = self.rename_variables(result)
        
        # Step 2: ProxifyLocals — wrap locals in metatable proxies
        if self.options.get('proxify_locals'):
            result = LuaProxifyLocals().proxify(result)

        # Step 3: Encode strings
        if self.options['encode_strings']:
            result = self.encode_strings(result)
        
        # Step 4: Encode numbers
        if self.options['encode_numbers']:
            result = self.encode_numbers(result)
        
        # Step 5: Control flow obfuscation
        if self.options['control_flow']:
            result = self.add_control_flow(result)
        
        # Step 6: Add junk code
        if self.options['add_junk']:
            result = self.add_junk_code(result)
        
        # Step 7: Anti-debug
        if self.options['anti_debug']:
            result = self.add_anti_debug(result)
        
        # Step 8: Wrap in function (skipped if vmify is on — vmify wraps it)
        if self.options['wrap_function'] and not self.options.get('vmify'):
            result = self.wrap_in_function(result)
        
        # Step 9: Minify (before vmify so payload is smaller)
        if self.options['minify']:
            result = self.minify_code(result)

        # Step 10: Vmify — XOR-encode entire payload in a custom VM loader (applied last)
        if self.options.get('vmify'):
            result = LuaVmify().vmify(result)
        
        return result
        
        # Add footer watermark if not vmified
        if not self.options.get('vmify'):
            footer = "\n--[[Obfuscated with LuaBox v2.7 by Zuka]]"
            result = result + footer
    
    def generate_var_name(self):
        """Generate a random variable name."""
        # Use confusing character combinations
        chars = 'Il1O0_'
        name = ''
        for _ in range(8):
            name += chars[self.var_counter % len(chars)]
            self.var_counter += 1
        return '_' + name
    
    def rename_variables(self, code):
        """Rename local variables to random names."""
        # This is a simplified version - a full implementation would need proper parsing
        lines = code.split('\n')
        result_lines = []
        
        for line in lines:
            # Find local variable declarations
            if 'local ' in line and not line.strip().startswith('--'):
                # Extract variable names after 'local'
                match = re.search(r'local\s+([a-zA-Z_][a-zA-Z0-9_]*)', line)
                if match:
                    old_name = match.group(1)
                    if old_name not in self.var_map:
                        self.var_map[old_name] = self.generate_var_name()
            
            result_lines.append(line)
        
        # Replace all occurrences
        result = '\n'.join(result_lines)
        for old_name, new_name in self.var_map.items():
            # Use word boundaries to avoid partial replacements
            result = re.sub(r'\b' + old_name + r'\b', new_name, result)
        
        return result
    
    def encode_strings(self, code):
        """Encode string literals."""
        def replace_string(match):
            string_content = match.group(1)
            # Convert to byte array
            bytes_arr = [str(ord(c)) for c in string_content]
            return f'string.char({",".join(bytes_arr)})'
        
        # Replace double-quoted strings
        code = re.sub(r'"([^"]*)"', replace_string, code)
        
        # Replace single-quoted strings
        code = re.sub(r"'([^']*)'", replace_string, code)
        
        return code
    
    def encode_numbers(self, code):
        """Obfuscate numeric literals."""
        def replace_number(match):
            num = int(match.group(0))
            # Convert to mathematical expression
            if num > 10:
                # Split into sum
                a = num // 2
                b = num - a
                return f'({a}+{b})'
            return match.group(0)
        
        # Replace standalone numbers
        code = re.sub(r'\b\d+\b', replace_number, code)
        
        return code
    
    def add_control_flow(self, code):
        """Add fake control flow."""
        # Add dummy conditionals that always evaluate to false
        junk_conditions = [
            'if false then return end\n',
            'if 1 > 2 then error("x") end\n',
            'while false do end\n'
        ]
        
        lines = code.split('\n')
        result_lines = []
        
        for i, line in enumerate(lines):
            result_lines.append(line)
            # Randomly insert junk conditions
            if i % 10 == 0 and not line.strip().startswith('--'):
                import random
                result_lines.append(random.choice(junk_conditions).rstrip())
        
        return '\n'.join(result_lines)
    
    def add_junk_code(self, code):
        """Add non-functional junk code."""
        junk_snippets = [
            'local _ = function() return nil end',
            'local __ = {}',
            'local ___ = 0',
            'if nil then end',
        ]
        
        lines = code.split('\n')
        result_lines = []
        
        import random
        for i, line in enumerate(lines):
            result_lines.append(line)
            if i % 15 == 0:
                result_lines.append(random.choice(junk_snippets))
        
        return '\n'.join(result_lines)
    
    def add_anti_debug(self, code):
        """Add anti-debugging checks."""
        anti_debug_code = '''
-- Anti-debug checks
local function _check()
    if getfenv then
        local env = getfenv(2)
        if env.script then return end
    end
end
_check()
'''
        return anti_debug_code + '\n' + code
    
    def wrap_in_function(self, code):
        """Wrap code in a self-executing anonymous function."""
        return f'(function()\n{code}\nend)()'
    
    def minify_code(self, code):
        """Remove whitespace and minimize code size."""
        # Remove comments
        code = re.sub(r'--[^\n]*', '', code)
        
        # Remove multi-line comments
        code = re.sub(r'--\[\[.*?\]\]', '', code, flags=re.DOTALL)
        
        # Remove extra whitespace
        lines = code.split('\n')
        lines = [line.strip() for line in lines if line.strip()]
        
        # Join with minimal spacing
        result = ' '.join(lines)
        
        # Clean up spacing around operators
        result = re.sub(r'\s+', ' ', result)
        result = re.sub(r'\s*([=+\-*/<>~,;:])\s*', r'\1', result)
        
        return result


# --- ProxifyLocals Obfuscation ---
class LuaProxifyLocals:
    """
    Inspired by Prometheus's ProxifyLocals step.
    Wraps local variable declarations in metatable proxy objects so that
    every read/write goes through __index / __newindex metamethods,
    hiding the real value from static analysis.
    """

    # Metatable metamethod pairs we can use for set/get
    META_OPS = [
        ("__add",    "__sub"),
        ("__sub",    "__add"),
        ("__mul",    "__div"),
        ("__div",    "__mul"),
        ("__mod",    "__pow"),
        ("__pow",    "__mod"),
        ("__concat", "__len"),
    ]

    def __init__(self):
        import random
        self._rng = random
        self._counter = 0

    def _uid(self):
        self._counter += 1
        chars = 'lI1O0_'
        out = ''
        n = self._counter
        for _ in range(8):
            out += chars[n % len(chars)]
            n //= len(chars)
        return '_' + out

    def _random_key(self):
        """Generate a random string key for the hidden value slot."""
        import random
        letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
        return ''.join(random.choice(letters) for _ in range(self._rng.randint(6, 12)))

    def _make_proxy(self, val_expr: str, set_meta: str, get_meta: str, key: str) -> str:
        """
        Emit Lua code for:
            setmetatable({[key]=val_expr}, {
                [set_meta] = function(t,v) t[key]=v end,
                [get_meta] = function(t,x) return rawget(t,key) end,
            })
        Returns a Lua expression string.
        """
        return (
            f'setmetatable({{{key}={val_expr}}},{{'
            f'{set_meta}=function(_t,_v) _t["{key}"]=_v end,'
            f'{get_meta}=function(_t,_x) return rawget(_t,"{key}") end'
            f'}})'
        )

    def proxify(self, code: str) -> str:
        """
        Scan for   local <name> = <expr>   patterns and replace each one with
        a proxy-wrapped version.  Then replace all subsequent bare uses of
        <name> with the appropriate getter expression.

        Limitations (text-based, no real AST):
        - Only handles simple single-assignment   local x = ...   forms.
        - Skips function declarations (local function ...) and for-loop vars.
        - Won't proxy function arguments or loop variables.
        """
        import random

        lines = code.split('\n')
        # Map: varname -> (proxy_varname, get_meta, key)
        var_info: dict = {}

        result_lines = []
        for line in lines:
            stripped = line.lstrip()

            # Skip comments
            if stripped.startswith('--'):
                result_lines.append(line)
                continue

            # Skip local function declarations
            if re.match(r'local\s+function\s+', stripped):
                result_lines.append(line)
                continue

            # Match:  local <name> = <expr>   (single var, simple assignment)
            m = re.match(r'^(\s*)local\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*(.+)$', line)
            if m:
                indent, varname, expr = m.group(1), m.group(2), m.group(3)

                # Pick random metamethod pair
                set_meta, get_meta = random.choice(self.META_OPS)
                key = self._random_key()
                proxy_name = self._uid()

                var_info[varname] = (proxy_name, get_meta, key)

                proxy_expr = self._make_proxy(expr.rstrip(), set_meta, get_meta, key)
                result_lines.append(f'{indent}local {proxy_name} = {proxy_expr}')
                continue

            # For all other lines: replace known variable names with getter calls
            new_line = line
            for varname, (proxy_name, get_meta, key) in var_info.items():
                # Replace bare usage: varname  ->  proxy_name[key]
                # Use word-boundary to avoid partial matches
                # Avoid replacing if it appears after 'local ' (re-declaration)
                new_line = re.sub(
                    r'(?<!\w)' + re.escape(varname) + r'(?!\w)',
                    f'{proxy_name}["{key}"]',
                    new_line
                )
            result_lines.append(new_line)

        return '\n'.join(result_lines)


# --- Vmify (Bytecode-style VM Encoding) ---
class LuaVmify:
    """
    Inspired by Prometheus's Vmify step.
    Since we're text-based (no real Lua AST/compiler), we implement the
    practical equivalent: encode the entire script payload as a compressed
    byte-string and emit a tiny Luau-compatible loader/VM that decodes and
    executes it at runtime via loadstring / load.

    Pipeline:
      1. XOR-encrypt the source bytes with a random key stream.
      2. Encode the ciphertext as decimal byte values embedded in a Lua table.
      3. Emit a self-contained Lua 'VM' preamble that:
           a. Reconstructs the key stream using the same seed.
           b. XOR-decrypts back to the original source.
           c. Calls loadstring / load on the recovered source.
    """

    def vmify(self, code: str) -> str:
        import random

        # --- 1. Build a random XOR key stream ---
        seed = random.randint(1, 0x7FFFFFFF)
        key_len = random.randint(16, 64)
        rng_state = seed
        key_stream = []
        for _ in range(key_len):
            rng_state = (rng_state * 48271) % 0x7FFFFFFF
            key_stream.append((rng_state % 255) + 1)

        # --- 2. XOR-encrypt the source ---
        src_bytes = code.encode('utf-8')
        cipher = []
        for i, b in enumerate(src_bytes):
            cipher.append(b ^ key_stream[i % key_len])

        # --- 3. Build the Lua byte-table literal ---
        # Chunk into rows of 20 for readability (it'll be minified anyway)
        chunk_size = 20
        rows = []
        for i in range(0, len(cipher), chunk_size):
            rows.append(','.join(str(x) for x in cipher[i:i + chunk_size]))
        byte_table = '{' + ','.join(rows) + '}'

        # --- 4. Emit the VM loader ---
        # We use variable names that look like VM registers to add authenticity.
        # The loader reconstructs the key stream from the same seed, XORs back,
        # assembles the string, then executes it.
        loader = f'''(function()
local _R={{{seed},{key_len}}}
local _K={{}}
local _rng=_R[1]
for _i=1,_R[2]do
_rng=(_rng*48271)%0x7FFFFFFF
_K[_i]=(_rng%255)+1
end
local _B={byte_table}
local _S={{}}
for _i=1,#_B do
_S[_i]=string.char(_B[_i]~_K[((_i-1)%_R[2])+1])
end
local _src=table.concat(_S)
local _fn,_err=(loadstring or load)(_src)
if not _fn then error("[VM] Decode error: "..tostring(_err))end
return _fn()
end)()'''
        return loader
        return loader


# --- Main Application Window ---
class LuaIDE(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("LuaBox v3")
        self.setGeometry(100, 100, 1400, 850)
        
        self.current_file = None
        self.current_directory = QDir.homePath()
        
        # Recent files tracking
        self.recent_files = []
        self.max_recent_files = 10
        self.load_recent_files()
        
        # Find & Replace dialog
        self.find_replace_dialog = None
        
        # Set light theme
        self.setStyleSheet("""
            QMainWindow {
                background-color: #F0F0F0;
            }
            QPushButton {
                background-color: #E1E1E1;
                color: #000000;
                border: 1px solid #ADADAD;
                border-top: 1px solid #FFFFFF;
                border-left: 1px solid #FFFFFF;
                border-right: 1px solid #7A7A7A;
                border-bottom: 1px solid #7A7A7A;
                padding: 3px 10px;
                font-size: 9pt;
                min-width: 60px;
            }
            QPushButton:hover {
                background-color: #E5F1FB;
                border: 1px solid #0078D7;
            }
            QPushButton:pressed {
                background-color: #CCE8FF;
                border-top: 1px solid #7A7A7A;
                border-left: 1px solid #7A7A7A;
                border-right: 1px solid #FFFFFF;
                border-bottom: 1px solid #FFFFFF;
            }
            QTreeWidget {
                background-color: white;
                border: 1px solid #ADADAD;
                font-size: 9pt;
                alternate-background-color: #F5F5F5;
            }
            QTreeWidget::item {
                padding: 2px;
            }
            QTreeWidget::item:selected {
                background-color: #0078D7;
                color: white;
            }
            QTreeWidget::item:hover {
                background-color: #E5F1FB;
            }
            QTabWidget::pane {
                border: 1px solid #CCCCCC;
                background-color: white;
                top: -1px;
            }
            QTabBar::tab {
                background-color: #E1E1E1;
                border: 1px solid #ADADAD;
                border-bottom: none;
                padding: 4px 10px;
                margin-right: 2px;
                font-size: 9pt;
                border-top-left-radius: 4px;
                border-top-right-radius: 4px;
                min-width: 60px;
            }
            QTabBar::tab:selected {
                background-color: white;
                border-bottom: 1px solid white;
                margin-bottom: -1px;
            }
            QTabBar::tab:hover {
                background-color: #E5F1FB;
            }
            QTabBar::tab:!selected {
                margin-top: 2px;
            }
            QTabBar::close-button {
                image: none;
                subcontrol-position: right;
                subcontrol-origin: padding;
                background-color: transparent;
                border: none;
                padding: 0px;
                margin: 2px;
            }
            QTabBar::close-button:hover {
                background-color: #E81123;
                border-radius: 2px;
            }
        """)

        # --- Main Layout ---
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        # --- Menu Bar / Toolbar ---
        toolbar_widget = QWidget()
        toolbar_widget.setMaximumHeight(35)
        toolbar_widget.setStyleSheet("background-color: #F0F0F0; border-bottom: 1px solid #CCCCCC;")
        toolbar_layout = QHBoxLayout(toolbar_widget)
        toolbar_layout.setContentsMargins(3, 3, 3, 3)
        toolbar_layout.setSpacing(3)
        
        btn_new = QPushButton("New")
        btn_new.clicked.connect(self.new_file)
        
        btn_open = QPushButton("Open")
        btn_open.clicked.connect(self.open_file)
        
        btn_save = QPushButton("Save")
        btn_save.clicked.connect(self.save_file)
        
        # Separator helper
        def create_separator():
            sep = QWidget()
            sep.setFixedWidth(1)
            sep.setStyleSheet("background-color: #ADADAD;")
            sep.setFixedHeight(22)
            return sep
        
        btn_settings = QPushButton("Settings")
        btn_settings.setStyleSheet("background-color: #E8D6F0;")
        btn_settings.clicked.connect(self.show_settings)
        
        btn_strip = QPushButton("Remove Comments")
        btn_strip.clicked.connect(self.remove_comments)
        
        btn_find_replace = QPushButton("Find & Replace")
        btn_find_replace.clicked.connect(self.show_find_replace)
        
        btn_obfuscate = QPushButton("Obfuscate")
        btn_obfuscate.setStyleSheet("background-color: #FFE6E6;")
        btn_obfuscate.clicked.connect(self.show_obfuscator)
        
        # Recent files dropdown button
        self.btn_recent = QPushButton("Recent Files ▼")
        self.btn_recent.clicked.connect(self.show_recent_files_menu)

        toolbar_layout.addWidget(btn_new)
        toolbar_layout.addWidget(btn_open)
        toolbar_layout.addWidget(btn_save)
        toolbar_layout.addWidget(self.btn_recent)
        toolbar_layout.addWidget(create_separator())
        toolbar_layout.addWidget(btn_find_replace)
        toolbar_layout.addWidget(btn_obfuscate)
        toolbar_layout.addWidget(create_separator())
        toolbar_layout.addWidget(btn_settings)
        toolbar_layout.addWidget(create_separator())
        toolbar_layout.addWidget(btn_strip)
        toolbar_layout.addStretch()
        
        main_layout.addWidget(toolbar_widget)

        # --- Main Content Area ---
        content_splitter = QSplitter(Qt.Orientation.Horizontal)
        
        # --- File Explorer ---
        explorer_widget = QWidget()
        explorer_widget.setMaximumWidth(250)
        explorer_layout = QVBoxLayout(explorer_widget)
        explorer_layout.setContentsMargins(0, 0, 0, 0)
        
        # Create tab widget for Explorer and Templates
        left_panel_tabs = QTabWidget()
        left_panel_tabs.setStyleSheet("""
            QTabWidget::pane {
                border: 1px solid #ADADAD;
                background-color: white;
            }
            QTabBar::tab {
                background-color: #E1E1E1;
                border: 1px solid #ADADAD;
                padding: 4px 8px;
                font-size: 9pt;
            }
            QTabBar::tab:selected {
                background-color: white;
            }
        """)
        
        # Explorer Tab
        explorer_tab = QWidget()
        explorer_tab_layout = QVBoxLayout(explorer_tab)
        explorer_tab_layout.setContentsMargins(0, 0, 0, 0)
        
        explorer_header = QWidget()
        explorer_header.setMaximumHeight(30)
        explorer_header.setStyleSheet("background-color: #F0F0F0; border-bottom: 1px solid #CCCCCC;")
        explorer_header_layout = QHBoxLayout(explorer_header)
        explorer_header_layout.setContentsMargins(5, 2, 5, 2)
        
        explorer_label = QLabel("Explorer")
        explorer_label.setStyleSheet("font-weight: bold;")
        btn_refresh = QPushButton("⟳")
        btn_refresh.setMaximumWidth(30)
        btn_refresh.clicked.connect(self.refresh_explorer)
        
        explorer_header_layout.addWidget(explorer_label)
        explorer_header_layout.addStretch()
        explorer_header_layout.addWidget(btn_refresh)
        
        self.file_tree = QTreeWidget()
        self.file_tree.setHeaderLabels(["Name", "Size"])
        self.file_tree.setColumnWidth(0, 150)
        self.file_tree.itemDoubleClicked.connect(self.tree_item_double_clicked)
        
        explorer_tab_layout.addWidget(explorer_header)
        explorer_tab_layout.addWidget(self.file_tree)
        
        # Templates Tab
        templates_tab = QWidget()
        templates_tab_layout = QVBoxLayout(templates_tab)
        templates_tab_layout.setContentsMargins(5, 5, 5, 5)
        
        # Templates tree
        self.templates_tree = QTreeWidget()
        self.templates_tree.setHeaderLabel("Audit Templates")
        self.templates_tree.itemDoubleClicked.connect(self.insert_template)
        self.populate_templates()
        
        templates_tab_layout.addWidget(self.templates_tree)
        
        # Add tabs
        left_panel_tabs.addTab(explorer_tab, "Files")
        left_panel_tabs.addTab(templates_tab, "Templates")
        
        explorer_layout.addWidget(left_panel_tabs)
        
        # --- Editor Area ---
        editor_widget = QWidget()
        editor_layout = QVBoxLayout(editor_widget)
        editor_layout.setContentsMargins(0, 0, 0, 0)
        editor_layout.setSpacing(0)
        
        # Tab widget for multiple files
        self.tab_widget = QTabWidget()
        self.tab_widget.setTabsClosable(True)
        self.tab_widget.tabCloseRequested.connect(self.close_tab)
        
        # Create initial tab
        self.create_new_tab("new")
        
        editor_layout.addWidget(self.tab_widget)
        
        content_splitter.addWidget(explorer_widget)
        content_splitter.addWidget(editor_widget)
        content_splitter.setSizes([200, 1000])
        
        main_layout.addWidget(content_splitter)
        
        # Populate file explorer
        self.refresh_explorer()

    def create_new_tab(self, title):
        """Create a new editor tab."""
        tab_container = QWidget()
        tab_layout = QVBoxLayout(tab_container)
        tab_layout.setContentsMargins(0, 0, 0, 0)
        
        # Code editor
        editor = CodeEditor()
        editor.setFont(QFont("Consolas", 11))
        editor.setStyleSheet("""
            QPlainTextEdit {
                background-color: white;
                color: black;
                border: none;
                selection-background-color: #ADD6FF;
            }
        """)
        editor.setTabStopDistance(editor.fontMetrics().horizontalAdvance(' ') * 4)
        highlighter = LuaSyntaxHighlighter(editor.document())
        
        tab_layout.addWidget(editor)
        
        # Add tab
        index = self.tab_widget.addTab(tab_container, title)
        self.tab_widget.setCurrentIndex(index)
        
        return editor

    def get_current_editor(self):
        """Get the current active editor."""
        current_widget = self.tab_widget.currentWidget()
        if current_widget:
            return current_widget.findChild(CodeEditor)
        return None

    def new_file(self):
        """Create a new file tab."""
        self.create_new_tab("new")

    def open_file(self):
        """Open a file dialog and load a file."""
        filename, _ = QFileDialog.getOpenFileName(
            self, "Open File", self.current_directory, "Lua Files (*.lua);;All Files (*.*)"
        )
        if filename:
            self.current_directory = os.path.dirname(filename)
            with open(filename, 'r', encoding='utf-8') as f:
                content = f.read()
            
            editor = self.create_new_tab(os.path.basename(filename))
            editor.setPlainText(content)
            editor.file_path = filename
            
            # Add to recent files
            self.add_recent_file(filename)

    def save_file(self):
        """Save the current file."""
        editor = self.get_current_editor()
        if not editor:
            return
        
        if hasattr(editor, 'file_path'):
            filename = editor.file_path
        else:
            filename, _ = QFileDialog.getSaveFileName(
                self, "Save File", self.current_directory, "Lua Files (*.lua);;All Files (*.*)"
            )
        
        if filename:
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(editor.toPlainText())
            
            editor.file_path = filename
            current_index = self.tab_widget.currentIndex()
            self.tab_widget.setTabText(current_index, os.path.basename(filename))
            
            # Add to recent files
            self.add_recent_file(filename)
            
            QMessageBox.information(self, "Success", "File saved successfully!")

    def close_tab(self, index):
        """Close a tab."""
        if self.tab_widget.count() > 1:
            self.tab_widget.removeTab(index)
        else:
            # Keep at least one tab
            editor = self.get_current_editor()
            if editor:
                editor.clear()
                self.tab_widget.setTabText(0, "Untitled")

    def refresh_explorer(self):
        """Refresh the file explorer."""
        self.file_tree.clear()
        
        directory = QDir(self.current_directory)
        files = directory.entryInfoList(QDir.Filter.Files | QDir.Filter.NoDotAndDotDot)
        
        for file_info in files:
            item = QTreeWidgetItem(self.file_tree)
            item.setText(0, file_info.fileName())
            size_kb = file_info.size() / 1024
            item.setText(1, f"{size_kb:.2f} KB")
            item.setData(0, Qt.ItemDataRole.UserRole, file_info.absoluteFilePath())

    def tree_item_double_clicked(self, item, column):
        """Handle double-click on file explorer item."""
        filepath = item.data(0, Qt.ItemDataRole.UserRole)
        if filepath and os.path.isfile(filepath):
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            editor = self.create_new_tab(os.path.basename(filepath))
            editor.setPlainText(content)
            editor.file_path = filepath

    def show_settings(self):
        """Show settings dialog."""
        dialog = SettingsDialog(self)
        if dialog.exec():
            # Apply settings
            font_size = dialog.font_size.value()
            for i in range(self.tab_widget.count()):
                widget = self.tab_widget.widget(i)
                editor = widget.findChild(CodeEditor)
                if editor:
                    font = editor.font()
                    font.setPointSize(font_size)
                    editor.setFont(font)

    def remove_comments(self):
        """Smart comment removal that preserves code structure."""
        editor = self.get_current_editor()
        if not editor:
            return
        
        code = editor.toPlainText()
        if not code.strip():
            QMessageBox.warning(self, "Empty Editor", "Editor is empty. Nothing to remove.")
            return

        try:
            cleaned_code = LuaCommentRemover.remove_comments(code)
            editor.setPlainText(cleaned_code)
            QMessageBox.information(
                self, "Success", 
                "Comments removed intelligently.\n\nPreserved:\n"
                "• Code structure and line integrity\n"
                "• Strings containing '--' patterns\n"
                "• Code on lines with trailing comments"
            )
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error removing comments: {str(e)}")

    def populate_templates(self):
        """Populate the templates tree with advanced audit and research templates."""
        templates_data = {
            "Environment Auditing": {
                "Metatable Hook - __index": '''-- Metatable __index hook for auditing property access
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function hookMetatable(object, hookType)
    local mt = getrawmetatable(object)
    local oldMetamethod = mt[hookType]
    
    setreadonly(mt, false)
    mt[hookType] = newcclosure(function(self, key, ...)
        local args = {...}
        
        -- Log the access
        print(string.format("[%s Hook] %s.%s", hookType, tostring(self), tostring(key)))
        
        -- Call original
        return oldMetamethod(self, key, unpack(args))
    end)
    setreadonly(mt, true)
    
    return oldMetamethod
end

-- Usage: Hook player metatable
-- hookMetatable(player, "__index")
''',
                "Metatable Hook - __namecall": '''-- Advanced __namecall hook for method interception
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    -- Log all method calls with context
    local info = string.format(
        "[NAMECALL] %s:%s(%s)",
        tostring(self),
        method,
        table.concat(args, ", ", 1, #args - 1)
    )
    print(info)
    
    -- Filter specific methods for detailed analysis
    if method == "FireServer" or method == "InvokeServer" then
        warn("[NETWORK] Remote call detected:", self.Name)
        for i, v in ipairs(args) do
            print(string.format("  Arg[%d] = %s", i, tostring(v)))
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
''',
                "Global Environment Monitor": '''-- Detect changes to _G and shared environments
local HttpService = game:GetService("HttpService")

local globalSnapshot = {}

-- Capture initial state
for k, v in pairs(_G) do
    globalSnapshot[k] = v
end

-- Monitor for changes
task.spawn(function()
    while task.wait(1) do
        for k, v in pairs(_G) do
            if globalSnapshot[k] ~= v then
                warn(string.format(
                    "[_G CHANGE] Key '%s' changed from %s to %s",
                    tostring(k),
                    tostring(globalSnapshot[k]),
                    tostring(v)
                ))
                globalSnapshot[k] = v
            end
        end
        
        -- Detect new additions
        for k in pairs(globalSnapshot) do
            if _G[k] == nil then
                warn(string.format("[_G DELETE] Key '%s' was removed", tostring(k)))
                globalSnapshot[k] = nil
            end
        end
    end
end)
''',
                "Function Hook Template": '''-- Generic function hooking utility
local function hookFunction(target, functionName, callback)
    local original = target[functionName]
    
    target[functionName] = function(...)
        local args = {...}
        
        -- Pre-execution hook
        local shouldProceed, modifiedArgs = callback("before", args)
        if not shouldProceed then
            return
        end
        
        -- Execute original
        local results = {original(unpack(modifiedArgs or args))}
        
        -- Post-execution hook
        callback("after", results)
        
        return unpack(results)
    end
    
    return original
end

-- Usage example
-- hookFunction(game.Players, "GetPlayers", function(phase, data)
--     if phase == "before" then
--         print("Getting players...")
--         return true, data
--     else
--         print("Got", #data[1], "players")
--     end
-- end)
''',
                "Script Environment Detector": '''-- Detect executor environment and capabilities
local function detectEnvironment()
    local env = {
        executor = identifyexecutor and identifyexecutor() or "Unknown",
        functions = {},
        level = 0
    }
    
    -- Test common executor functions
    local testFunctions = {
        "getgenv", "getrenv", "getrawmetatable", "setreadonly",
        "hookmetamethod", "hookfunction", "newcclosure",
        "getnamecallmethod", "checkcaller", "getconnections",
        "firesignal", "Drawing", "WebSocket", "request",
        "http_request", "syn_request", "readfile", "writefile",
        "isfile", "isfolder", "makefolder", "delfile"
    }
    
    for _, funcName in ipairs(testFunctions) do
        local func = getfenv()[funcName]
        if func then
            env.functions[funcName] = type(func)
            env.level = env.level + 1
        end
    end
    
    -- Calculate capability level
    env.rating = env.level >= 20 and "High" or env.level >= 10 and "Medium" or "Low"
    
    return env
end

local env = detectEnvironment()
print("Executor:", env.executor)
print("Capability Level:", env.rating)
print("Available Functions:", env.level)
''',
            },
            "Entity Visualization": {
                "ESP - Box ESP": '''-- High-performance box ESP using Drawing library
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local espObjects = {}

local function createESP(player)
    local esp = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        healthBar = Drawing.new("Line"),
        healthBarBg = Drawing.new("Line")
    }
    
    -- Box settings
    esp.box.Thickness = 2
    esp.box.Filled = false
    esp.box.Color = Color3.new(1, 0, 0)
    esp.box.Transparency = 1
    esp.box.Visible = false
    
    -- Name settings
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Color = Color3.new(1, 1, 1)
    esp.name.Size = 14
    esp.name.Visible = false
    
    -- Distance settings
    esp.distance.Center = true
    esp.distance.Outline = true
    esp.distance.Color = Color3.new(1, 1, 1)
    esp.distance.Size = 12
    esp.distance.Visible = false
    
    -- Health bar settings
    esp.healthBar.Thickness = 3
    esp.healthBar.Color = Color3.new(0, 1, 0)
    esp.healthBar.Visible = false
    
    esp.healthBarBg.Thickness = 3
    esp.healthBarBg.Color = Color3.new(0.2, 0.2, 0.2)
    esp.healthBarBg.Visible = false
    
    espObjects[player] = esp
    return esp
end

local function removeESP(player)
    local esp = espObjects[player]
    if esp then
        for _, drawing in pairs(esp) do
            drawing:Remove()
        end
        espObjects[player] = nil
    end
end

local function updateESP()
    for player, esp in pairs(espObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local head = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
                local leg = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                
                local height = math.abs(head.Y - leg.Y)
                local width = height / 2
                
                -- Update box
                esp.box.Size = Vector2.new(width, height)
                esp.box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                esp.box.Visible = true
                
                -- Update name
                esp.name.Text = player.Name
                esp.name.Position = Vector2.new(vector.X, head.Y - 20)
                esp.name.Visible = true
                
                -- Update distance
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                esp.distance.Text = string.format("%.0f studs", distance)
                esp.distance.Position = Vector2.new(vector.X, leg.Y + 5)
                esp.distance.Visible = true
                
                -- Update health bar
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local barHeight = height
                local barX = vector.X - width / 2 - 8
                
                esp.healthBarBg.From = Vector2.new(barX, vector.Y - height / 2)
                esp.healthBarBg.To = Vector2.new(barX, vector.Y - height / 2 + barHeight)
                esp.healthBarBg.Visible = true
                
                esp.healthBar.From = Vector2.new(barX, vector.Y - height / 2 + barHeight)
                esp.healthBar.To = Vector2.new(barX, vector.Y - height / 2 + barHeight - (barHeight * healthPercent))
                esp.healthBar.Color = Color3.new(1 - healthPercent, healthPercent, 0)
                esp.healthBar.Visible = true
            else
                esp.box.Visible = false
                esp.name.Visible = false
                esp.distance.Visible = false
                esp.healthBar.Visible = false
                esp.healthBarBg.Visible = false
            end
        else
            esp.box.Visible = false
            esp.name.Visible = false
            esp.distance.Visible = false
            esp.healthBar.Visible = false
            esp.healthBarBg.Visible = false
        end
    end
end

-- Initialize ESP for all players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(removeESP)

-- Update loop
RunService.RenderStepped:Connect(updateESP)
''',
                "ESP - Skeleton ESP": '''-- Skeleton ESP with limb tracking
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local skeletons = {}

local limbConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function createSkeleton(player)
    local skeleton = {}
    
    for i = 1, #limbConnections do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Color = Color3.new(1, 1, 1)
        line.Transparency = 1
        line.Visible = false
        skeleton[i] = line
    end
    
    skeletons[player] = skeleton
    return skeleton
end

local function removeSkeleton(player)
    local skeleton = skeletons[player]
    if skeleton then
        for _, line in ipairs(skeleton) do
            line:Remove()
        end
        skeletons[player] = nil
    end
end

local function updateSkeleton()
    for player, skeleton in pairs(skeletons) do
        if player.Character then
            for i, connection in ipairs(limbConnections) do
                local part1 = player.Character:FindFirstChild(connection[1])
                local part2 = player.Character:FindFirstChild(connection[2])
                
                if part1 and part2 then
                    local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
                    local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)
                    
                    if onScreen1 and onScreen2 then
                        skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                        skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                        skeleton[i].Visible = true
                    else
                        skeleton[i].Visible = false
                    end
                else
                    skeleton[i].Visible = false
                end
            end
        else
            for _, line in ipairs(skeleton) do
                line.Visible = false
            end
        end
    end
end

-- Initialize skeletons
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createSkeleton(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createSkeleton(player)
    end
end)

Players.PlayerRemoving:Connect(removeSkeleton)

RunService.RenderStepped:Connect(updateSkeleton)
''',
                "Tracers": '''-- Screen-to-player tracers
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local tracers = {}

local function createTracer(player)
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Color3.new(1, 0, 0)
    line.Transparency = 0.5
    line.Visible = false
    
    tracers[player] = line
    return line
end

local function removeTracer(player)
    local line = tracers[player]
    if line then
        line:Remove()
        tracers[player] = nil
    end
end

local function updateTracers()
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y)
    
    for player, line in pairs(tracers) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                line.From = screenCenter
                line.To = Vector2.new(vector.X, vector.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

-- Initialize tracers
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createTracer(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createTracer(player)
    end
end)

Players.PlayerRemoving:Connect(removeTracer)

RunService.RenderStepped:Connect(updateTracers)
''',
                "FOV Circle": '''-- FOV circle for aimbot visualization
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Radius = 100
fovCircle.Filled = false
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Transparency = 0.8
fovCircle.Visible = true

RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    fovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
end)

-- Dynamic FOV with scroll wheel
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        local delta = input.Position.Z
        fovCircle.Radius = math.clamp(fovCircle.Radius + (delta * 10), 50, 500)
    end
end)
''',
            },
            "Network Analysis": {
                "Remote Spy - FireServer": '''-- Intercept and log all FireServer calls
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" then
        local remoteName = self:GetFullName()
        
        warn("=== Remote Fired ===")
        warn("Remote:", remoteName)
        warn("Arguments:")
        
        for i, arg in ipairs(args) do
            local argType = typeof(arg)
            local argValue = tostring(arg)
            
            if argType == "Instance" then
                argValue = arg:GetFullName()
            elseif argType == "table" then
                argValue = game:GetService("HttpService"):JSONEncode(arg)
            end
            
            warn(string.format("  [%d] (%s) %s", i, argType, argValue))
        end
        warn("==================")
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
''',
                "Remote Spy - InvokeServer": '''-- Intercept RemoteFunction calls
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "InvokeServer" then
        warn("=== RemoteFunction Invoked ===")
        warn("Function:", self:GetFullName())
        warn("Arguments:", unpack(args))
        
        local result = oldNamecall(self, ...)
        
        warn("Return Value:", result)
        warn("==============================")
        
        return result
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
''',
                "Remote Event Logger": '''-- Advanced remote event logging with filtering
local HttpService = game:GetService("HttpService")
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

local loggedRemotes = {}
local remoteFilter = {} -- Add remote names to filter

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" or method == "InvokeServer" then
        local remoteName = self.Name
        
        -- Apply filter
        if #remoteFilter > 0 then
            local shouldLog = false
            for _, filter in ipairs(remoteFilter) do
                if string.find(remoteName, filter) then
                    shouldLog = true
                    break
                end
            end
            if not shouldLog then
                return oldNamecall(self, ...)
            end
        end
        
        -- Create log entry
        local logEntry = {
            remote = self:GetFullName(),
            method = method,
            timestamp = os.time(),
            args = {}
        }
        
        for i, arg in ipairs(args) do
            local argData = {
                type = typeof(arg),
                value = arg
            }
            
            if typeof(arg) == "Instance" then
                argData.value = arg:GetFullName()
            elseif typeof(arg) == "table" then
                argData.value = HttpService:JSONEncode(arg)
            else
                argData.value = tostring(arg)
            end
            
            table.insert(logEntry.args, argData)
        end
        
        table.insert(loggedRemotes, logEntry)
        
        -- Print compact log
        print(string.format(
            "[%s] %s:%s() - %d args",
            os.date("%H:%M:%S", logEntry.timestamp),
            remoteName,
            method,
            #args
        ))
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Function to export logs
local function exportLogs()
    return HttpService:JSONEncode(loggedRemotes)
end

-- Function to clear logs
local function clearLogs()
    loggedRemotes = {}
    print("Logs cleared")
end
''',
                "Network Traffic Monitor": '''-- Monitor all network-related function calls
local stats = {
    fireServer = 0,
    invokeServer = 0,
    fireClient = 0,
    fireAllClients = 0,
    totalCalls = 0
}

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if method == "FireServer" then
        stats.fireServer = stats.fireServer + 1
        stats.totalCalls = stats.totalCalls + 1
    elseif method == "InvokeServer" then
        stats.invokeServer = stats.invokeServer + 1
        stats.totalCalls = stats.totalCalls + 1
    elseif method == "FireClient" then
        stats.fireClient = stats.fireClient + 1
        stats.totalCalls = stats.totalCalls + 1
    elseif method == "FireAllClients" then
        stats.fireAllClients = stats.fireAllClients + 1
        stats.totalCalls = stats.totalCalls + 1
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Print stats every 5 seconds
task.spawn(function()
    while task.wait(5) do
        print("=== Network Stats ===")
        print("FireServer:", stats.fireServer)
        print("InvokeServer:", stats.invokeServer)
        print("FireClient:", stats.fireClient)
        print("FireAllClients:", stats.fireAllClients)
        print("Total Calls:", stats.totalCalls)
        print("====================")
    end
end)
''',
            },
            "Character Physics": {
                "Velocity Manipulation": '''-- Velocity manipulation for physics testing
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local velocityEnabled = false
local targetVelocity = Vector3.new(0, 0, 0)

-- Create velocity object
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.Velocity = Vector3.new(0, 0, 0)
bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
bodyVelocity.Parent = hrp

local function setVelocity(velocity)
    targetVelocity = velocity
    bodyVelocity.Velocity = velocity
    velocityEnabled = true
end

local function stopVelocity()
    velocityEnabled = false
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
end

-- Example: Move forward at high speed
-- setVelocity(hrp.CFrame.LookVector * 100)

-- Example: Fly upward
-- setVelocity(Vector3.new(0, 50, 0))

-- Stop with: stopVelocity()
''',
                "CFrame Interpolation": '''-- Smooth CFrame interpolation for positioning
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local function smoothTeleport(targetCFrame, duration)
    duration = duration or 0.5
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    -- Create AlignPosition for smooth movement
    local align = Instance.new("AlignPosition")
    align.Mode = Enum.PositionAlignmentMode.OneAttachment
    align.RigidityEnabled = false
    align.Responsiveness = 200
    align.MaxForce = 100000
    
    local attachment = Instance.new("Attachment", hrp)
    align.Attachment0 = attachment
    align.Parent = hrp
    
    -- Interpolate position
    local startPos = hrp.Position
    local endPos = targetCFrame.Position
    local elapsed = 0
    
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        local alpha = math.min(elapsed / duration, 1)
        
        -- Ease function
        alpha = 1 - math.pow(1 - alpha, 2)
        
        local currentPos = startPos:Lerp(endPos, alpha)
        align.Position = currentPos
        
        if alpha >= 1 then
            connection:Disconnect()
            align:Destroy()
            attachment:Destroy()
            hrp.CFrame = targetCFrame
        end
    end)
end

-- Usage: smoothTeleport(CFrame.new(0, 100, 0), 2)
''',
                "Noclip Toggle": '''-- Toggle noclip for environment traversal
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local noclipEnabled = false
local noclipConnection

local function enableNoclip()
    if noclipEnabled then return end
    noclipEnabled = true
    
    noclipConnection = RunService.Stepped:Connect(function()
        if character and character:FindFirstChild("Humanoid") then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    print("Noclip enabled")
end

local function disableNoclip()
    if not noclipEnabled then return end
    noclipEnabled = false
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    print("Noclip disabled")
end

local function toggleNoclip()
    if noclipEnabled then
        disableNoclip()
    else
        enableNoclip()
    end
end

-- Usage: toggleNoclip()
''',
                "Infinite Jump": '''-- Infinite jump capability
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local infiniteJumpEnabled = true

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Toggle: infiniteJumpEnabled = false
''',
                "Speed Modifier": '''-- Dynamic walkspeed modifier
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local defaultSpeed = 16
local speedMultiplier = 1

local function setSpeed(multiplier)
    speedMultiplier = multiplier
    humanoid.WalkSpeed = defaultSpeed * multiplier
end

-- Maintain speed through respawn
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = defaultSpeed * speedMultiplier
end)

-- Usage: setSpeed(2) for 2x speed
''',
            },
            "Advanced Input": {
                "WorldToViewportPoint": '''-- Vector-to-screen projection for UI overlays
local Camera = workspace.CurrentCamera

local function worldToScreen(position)
    local vector, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(vector.X, vector.Y), onScreen, vector.Z
end

-- Usage example: Project 3D position to 2D screen
local targetPos = Vector3.new(0, 10, 0)
local screenPos, visible, depth = worldToScreen(targetPos)

if visible then
    print("Screen Position:", screenPos)
    print("Depth:", depth)
end
''',
                "Closest Player to Mouse": '''-- Find closest player to mouse within FOV
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function getClosestPlayerToMouse(fov)
    fov = fov or 100
    
    local mousePos = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local closestDistance = fov
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer, closestDistance
end

-- Usage
local target, distance = getClosestPlayerToMouse(150)
if target then
    print("Closest player:", target.Name, "at", distance, "pixels")
end
''',
                "Advanced Raycast": '''-- Advanced raycasting with filtering
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function performRaycast(origin, direction, filterTable, maxDistance)
    maxDistance = maxDistance or 1000
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = filterTable or {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(origin, direction * maxDistance, raycastParams)
    
    return raycastResult
end

-- Usage: Cast from camera to mouse
local mouseLocation = UserInputService:GetMouseLocation()
local unitRay = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

local result = performRaycast(unitRay.Origin, unitRay.Direction, {LocalPlayer.Character}, 500)

if result then
    print("Hit:", result.Instance:GetFullName())
    print("Position:", result.Position)
    print("Normal:", result.Normal)
end
''',
                "Prediction Calculator": '''-- Projectile path prediction for moving targets
local function predictPosition(targetPosition, targetVelocity, projectileSpeed)
    -- Calculate time for projectile to reach target
    local distance = targetPosition.Magnitude
    local time = distance / projectileSpeed
    
    -- Predict where target will be
    local predictedPosition = targetPosition + (targetVelocity * time)
    
    return predictedPosition, time
end

-- Advanced prediction with gravity
local function predictWithGravity(targetPos, targetVel, projSpeed, gravity)
    gravity = gravity or 196.2 -- Roblox gravity
    
    local horizontal = Vector3.new(targetPos.X, 0, targetPos.Z)
    local horizontalDist = horizontal.Magnitude
    
    local time = horizontalDist / projSpeed
    
    -- Calculate drop due to gravity
    local drop = 0.5 * gravity * time * time
    
    -- Predict position
    local predictedPos = targetPos + (targetVel * time)
    predictedPos = predictedPos + Vector3.new(0, drop, 0)
    
    return predictedPos, time
end

-- Usage example
local targetHRP = targetPlayer.Character.HumanoidRootPart
local targetPos = targetHRP.Position - LocalPlayer.Character.HumanoidRootPart.Position
local targetVel = targetHRP.AssemblyLinearVelocity

local predicted, time = predictPosition(targetPos, targetVel, 500)
print("Aim at:", predicted, "Lead time:", time)
''',
            },
            "Utility Functions": {
                "Service Cache": '''-- Efficient service caching
local Services = setmetatable({}, {
    __index = function(self, serviceName)
        local service = game:GetService(serviceName)
        rawset(self, serviceName, service)
        return service
    end
})

-- Usage: Services.Players, Services.Workspace, etc.
''',
                "Instance Finder": '''-- Recursive instance finder
local function findFirstDescendant(parent, name, className)
    for _, descendant in ipairs(parent:GetDescendants()) do
        if descendant.Name == name then
            if not className or descendant:IsA(className) then
                return descendant
            end
        end
    end
    return nil
end

-- Usage: findFirstDescendant(workspace, "SomeObject", "Part")
''',
                "Wait for Path": '''-- Wait for instance at path
local function waitForPath(path, timeout)
    timeout = timeout or 10
    local elapsed = 0
    
    while elapsed < timeout do
        local success, result = pcall(function()
            local current = game
            for segment in string.gmatch(path, "[^.]+") do
                current = current:WaitForChild(segment, 0.1)
            end
            return current
        end)
        
        if success then
            return result
        end
        
        elapsed = elapsed + 0.1
        task.wait(0.1)
    end
    
    return nil
end

-- Usage: waitForPath("ReplicatedStorage.Remotes.FireEvent")
''',
                "Table Deep Copy": '''-- Deep copy table utility
local function deepCopy(original)
    local copy
    if type(original) == "table" then
        copy = {}
        for k, v in next, original, nil do
            copy[deepCopy(k)] = deepCopy(v)
        end
        setmetatable(copy, deepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

-- Usage: local newTable = deepCopy(originalTable)
''',
            },
            "GUI Frameworks & Templates": {
                "Win95 Command Bar": '''--[[
  Windows 95 Style Command Bar Framework
  Features: Command registration, notifications, draggable/resizable window, DOS aesthetic
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Splash screen configuration
do
    local THEME = {
        Title = "Loading...",
        Subtitle = "Command Bar Initialized",
        IconAssetId = "rbxassetid://7243158473",
        BackgroundColor = Color3.fromRGB(15, 15, 20),
        AccentColor = Color3.fromRGB(0, 255, 255),
        TextColor = Color3.fromRGB(240, 240, 240),
        FadeInTime = 0.45,
        HoldTime = 1.2,
        FadeOutTime = 0.35
    }

    local splashGui = Instance.new("ScreenGui")
    splashGui.Name = "SplashScreen_" .. math.random(1000, 9999)
    splashGui.IgnoreGuiInset = true
    splashGui.ResetOnSpawn = false
    splashGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    splashGui.Parent = CoreGui

    local background = Instance.new("Frame")
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundColor3 = THEME.BackgroundColor
    background.BackgroundTransparency = 1
    background.Parent = splashGui

    local blur = Instance.new("BlurEffect")
    blur.Size = 1
    blur.Parent = Lighting

    local card = Instance.new("Frame")
    card.Size = UDim2.fromOffset(320, 260)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    card.BackgroundTransparency = 1
    card.Parent = background
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.fromOffset(96, 96)
    icon.Position = UDim2.fromScale(0.5, 0.32)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.ImageTransparency = 0.5
    icon.ImageColor3 = THEME.AccentColor
    icon.Image = THEME.IconAssetId
    icon.Parent = card

    local tweenIn = TweenInfo.new(THEME.FadeInTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(background, tweenIn, { BackgroundTransparency = 0.35 }):Play()
    TweenService:Create(blur, tweenIn, { Size = 16 }):Play()
    
    task.wait(THEME.FadeInTime + THEME.HoldTime)
    
    local tweenOut = TweenInfo.new(THEME.FadeOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(background, tweenOut, { BackgroundTransparency = 1 }):Play()
    TweenService:Create(blur, tweenOut, { Size = 0 }):Play()
    
    task.wait(THEME.FadeOutTime)
    blur:Destroy()
    splashGui:Destroy()
end

local Prefix = ";"
local Commands = {}
local CommandInfo = {}

-- Notification Manager
local NotificationManager = {}
do
    local queue = {}
    local isActive = false
    local textService = game:GetService("TextService")
    local notifGui = Instance.new("ScreenGui", CoreGui)
    notifGui.Name = "NotificationGui"
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    notifGui.ResetOnSpawn = false

    local function processNext()
        if isActive or #queue == 0 then return end
        isActive = true
        local data = table.remove(queue, 1)
        local text, duration = data[1], data[2]
        
        local notif = Instance.new("TextLabel")
        notif.Font = Enum.Font.GothamSemibold
        notif.TextSize = 12
        notif.Text = text
        notif.TextWrapped = true
        notif.Size = UDim2.fromOffset(300, 0)
        
        local textBounds = textService:GetTextSize(notif.Text, notif.TextSize, notif.Font, Vector2.new(300, 1000))
        notif.Size = UDim2.fromOffset(300, textBounds.Y + 20)
        notif.Position = UDim2.new(0.5, -150, 0, -60)
        notif.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        notif.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
        notif.Parent = notifGui

        local tweenIn = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(notif, tweenIn, { Position = UDim2.new(0.5, -150, 0, 10) }):Play()
        
        task.wait(0.4 + duration)
        
        local tweenOut = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        TweenService:Create(notif, tweenOut, { Position = UDim2.new(0.5, -150, 0, -60) }):Play()
        
        task.wait(0.4)
        notif:Destroy()
        isActive = false
        task.spawn(processNext)
    end
    
    function NotificationManager.Send(text, duration)
        table.insert(queue, {tostring(text), duration or 1})
        task.spawn(processNext)
    end
end

-- Command registration
function RegisterCommand(info, func)
    if not info or not info.Name or not func then
        warn("Command registration failed")
        return
    end
    
    local name = info.Name:lower()
    Commands[name] = func
    
    if info.Aliases then
        for _, alias in ipairs(info.Aliases) do
            Commands[alias:lower()] = func
        end
    end
    
    table.insert(CommandInfo, info)
end

-- Example command registration:
-- RegisterCommand({
--     Name = "teleport",
--     Aliases = {"tp"},
--     Description = "Teleport to a player"
-- }, function(args)
--     print("Teleporting to:", args[1])
-- end)

print("Command bar framework loaded. Press semicolon to open.")
''',
                "Modern UI Library": '''-- Modern UI library with smooth animations
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UI = {
    Theme = {
        Background = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(88, 101, 242),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 150)
    }
}

function UI:CreateWindow(title)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ModernUI"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.fromOffset(500, 400)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = self.Theme.Background
    main.BorderSizePixel = 0
    main.Parent = gui
    
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = main
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.fromOffset(20, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = self.Theme.Text
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    return {
        GUI = gui,
        Main = main,
        TitleBar = titleBar
    }
end

function UI:CreateButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 35)
    button.BackgroundColor3 = self.Theme.Secondary
    button.Text = text
    button.Font = Enum.Font.GothamSemibold
    button.TextColor3 = self.Theme.Text
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = parent
    
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    
    button.MouseButton1Click:Connect(function()
        -- Ripple effect
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.fromScale(0, 0)
        ripple.Position = UDim2.fromScale(0.5, 0.5)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = self.Theme.Accent
        ripple.BackgroundTransparency = 0.5
        ripple.BorderSizePixel = 0
        ripple.Parent = button
        
        Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
        
        local tween = TweenService:Create(ripple, TweenInfo.new(0.5), {
            Size = UDim2.fromScale(2, 2),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            ripple:Destroy()
        end)
        
        if callback then callback() end
    end)
    
    return button
end

-- Usage:
-- local window = UI:CreateWindow("My Script")
-- local button = UI:CreateButton(window.Main, "Click Me", function()
--     print("Button clicked!")
-- end)
''',
                "Notification System": '''-- Standalone notification system
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Notifications = {
    Queue = {},
    Active = false,
    Container = nil
}

function Notifications:Initialize()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NotificationSystem"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    self.Container = Instance.new("Frame")
    self.Container.Name = "Container"
    self.Container.Size = UDim2.new(0, 350, 1, 0)
    self.Container.Position = UDim2.new(1, -20, 0, 20)
    self.Container.AnchorPoint = Vector2.new(1, 0)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = gui
    
    Instance.new("UIListLayout", self.Container).Padding = UDim.new(0, 10)
end

function Notifications:Send(config)
    local title = config.Title or "Notification"
    local description = config.Description or ""
    local duration = config.Duration or 3
    local type = config.Type or "info" -- info, success, warning, error
    
    local colors = {
        info = Color3.fromRGB(88, 101, 242),
        success = Color3.fromRGB(67, 181, 129),
        warning = Color3.fromRGB(250, 166, 26),
        error = Color3.fromRGB(240, 71, 71)
    }
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.fromOffset(330, 80)
    notif.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    notif.BorderSizePixel = 0
    notif.Parent = self.Container
    
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = colors[type]
    accent.BorderSizePixel = 0
    accent.Parent = notif
    
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 10)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.fromOffset(15, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -20, 0, 40)
    descLabel.Position = UDim2.fromOffset(15, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.TextWrapped = true
    descLabel.Parent = notif
    
    -- Slide in
    notif.Position = UDim2.fromOffset(350, 0)
    local slideIn = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.fromOffset(0, 0)
    })
    slideIn:Play()
    
    -- Wait and slide out
    task.delay(duration, function()
        local slideOut = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = UDim2.fromOffset(350, 0)
        })
        slideOut:Play()
        slideOut.Completed:Wait()
        notif:Destroy()
    end)
end

Notifications:Initialize()

-- Usage:
-- Notifications:Send({
--     Title = "Success",
--     Description = "Operation completed successfully!",
--     Type = "success",
--     Duration = 3
-- })
''',
                "Draggable Window Framework": '''-- Reusable draggable window system
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local DraggableWindow = {}
DraggableWindow.__index = DraggableWindow

function DraggableWindow.new(config)
    local self = setmetatable({}, DraggableWindow)
    
    self.Title = config.Title or "Window"
    self.Size = config.Size or UDim2.fromOffset(400, 300)
    self.Dragging = false
    self.Resizing = false
    
    self:CreateWindow()
    self:SetupDragging()
    
    return self
end

function DraggableWindow:CreateWindow()
    self.GUI = Instance.new("ScreenGui")
    self.GUI.Name = "DraggableWindow"
    self.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.GUI.ResetOnSpawn = false
    self.GUI.Parent = game:GetService("CoreGui")
    
    self.Frame = Instance.new("Frame")
    self.Frame.Size = self.Size
    self.Frame.Position = UDim2.fromScale(0.5, 0.5)
    self.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    self.Frame.BorderSizePixel = 0
    self.Frame.Parent = self.GUI
    
    Instance.new("UICorner", self.Frame).CornerRadius = UDim.new(0, 10)
    
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Frame
    
    Instance.new("UICorner", self.TitleBar).CornerRadius = UDim.new(0, 10)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.fromOffset(10, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = self.Title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = self.TitleBar
    
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, -20, 1, -40)
    self.Content.Position = UDim2.fromOffset(10, 35)
    self.Content.BackgroundTransparency = 1
    self.Content.Parent = self.Frame
end

function DraggableWindow:SetupDragging()
    local dragStart, startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            dragStart = input.Position
            startPos = self.Frame.Position
        end
    end)
    
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function DraggableWindow:Destroy()
    self.GUI:Destroy()
end

-- Usage:
-- local window = DraggableWindow.new({
--     Title = "My Window",
--     Size = UDim2.fromOffset(500, 400)
-- })
-- -- Add content to window.Content
''',
                "Terminal/Console UI": '''-- Terminal-style console interface
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Terminal = {
    Lines = {},
    MaxLines = 500,
    Theme = {
        Background = Color3.fromRGB(0, 0, 0),
        Text = Color3.fromRGB(0, 255, 0),
        Input = Color3.fromRGB(0, 200, 0),
        Error = Color3.fromRGB(255, 0, 0),
        Warning = Color3.fromRGB(255, 255, 0),
        Info = Color3.fromRGB(0, 150, 255)
    }
}

function Terminal:Initialize()
    local gui = Instance.new("ScreenGui")
    gui.Name = "Terminal"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(800, 500)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = self.Theme.Background
    main.BorderColor3 = self.Theme.Text
    main.BorderSizePixel = 2
    main.Parent = gui
    
    local output = Instance.new("ScrollingFrame")
    output.Name = "Output"
    output.Size = UDim2.new(1, -10, 1, -40)
    output.Position = UDim2.fromOffset(5, 5)
    output.BackgroundTransparency = 1
    output.BorderSizePixel = 0
    output.ScrollBarThickness = 6
    output.CanvasSize = UDim2.fromOffset(0, 0)
    output.AutomaticCanvasSize = Enum.AutomaticSize.Y
    output.Parent = main
    
    Instance.new("UIListLayout", output).Padding = UDim.new(0, 2)
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -10, 0, 25)
    inputFrame.Position = UDim2.new(0, 5, 1, -30)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Parent = main
    
    local prompt = Instance.new("TextLabel")
    prompt.Size = UDim2.fromOffset(30, 25)
    prompt.BackgroundTransparency = 1
    prompt.Font = Enum.Font.Code
    prompt.Text = ">"
    prompt.TextColor3 = self.Theme.Input
    prompt.TextSize = 14
    prompt.TextXAlignment = Enum.TextXAlignment.Left
    prompt.Parent = inputFrame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -35, 1, 0)
    input.Position = UDim2.fromOffset(35, 0)
    input.BackgroundTransparency = 1
    input.Font = Enum.Font.Code
    input.PlaceholderText = "Type command..."
    input.Text = ""
    input.TextColor3 = self.Theme.Input
    input.TextSize = 14
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.Parent = inputFrame
    
    self.GUI = gui
    self.Output = output
    self.Input = input
    
    input.FocusLost:Connect(function(enter)
        if enter and input.Text ~= "" then
            self:ProcessCommand(input.Text)
            input.Text = ""
        end
    end)
    
    self:Print("Terminal initialized. Type 'help' for commands.", "info")
end

function Terminal:Print(text, type)
    type = type or "text"
    
    local line = Instance.new("TextLabel")
    line.Size = UDim2.new(1, -10, 0, 0)
    line.AutomaticSize = Enum.AutomaticSize.Y
    line.BackgroundTransparency = 1
    line.Font = Enum.Font.Code
    line.Text = text
    line.TextColor3 = self.Theme[type:lower()] or self.Theme.Text
    line.TextSize = 13
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.TextWrapped = true
    line.Parent = self.Output
    
    table.insert(self.Lines, line)
    
    if #self.Lines > self.MaxLines then
        self.Lines[1]:Destroy()
        table.remove(self.Lines, 1)
    end
    
    task.defer(function()
        self.Output.CanvasPosition = Vector2.new(0, self.Output.AbsoluteCanvasSize.Y)
    end)
end

function Terminal:ProcessCommand(cmd)
    self:Print("> " .. cmd, "input")
    
    -- Add your command processing here
    if cmd:lower() == "help" then
        self:Print("Available commands: help, clear, exit", "info")
    elseif cmd:lower() == "clear" then
        for _, line in ipairs(self.Lines) do
            line:Destroy()
        end
        self.Lines = {}
    else
        self:Print("Unknown command: " .. cmd, "error")
    end
end

Terminal:Initialize()
''',
                "Settings Panel Template": '''-- Settings/configuration panel UI
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Settings = {
    Config = {},
    Elements = {}
}

function Settings:CreatePanel(title)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SettingsPanel"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(400, 500)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Parent = main
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.fromOffset(10, 45)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.fromOffset(0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = main
    
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 10)
    
    self.GUI = gui
    self.Content = content
    
    return self
end

function Settings:AddToggle(name, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    container.BorderSizePixel = 0
    container.Parent = self.Content
    
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.fromOffset(10, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.fromOffset(40, 20)
    toggle.Position = UDim2.new(1, -50, 0.5, -10)
    toggle.BackgroundColor3 = default and Color3.fromRGB(67, 181, 129) or Color3.fromRGB(60, 60, 70)
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.Parent = container
    
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    self.Config[name] = default
    
    toggle.MouseButton1Click:Connect(function()
        self.Config[name] = not self.Config[name]
        
        local color = self.Config[name] and Color3.fromRGB(67, 181, 129) or Color3.fromRGB(60, 60, 70)
        local pos = self.Config[name] and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2)
        
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = pos}):Play()
        
        if callback then callback(self.Config[name]) end
    end)
end

function Settings:AddSlider(name, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    container.BorderSizePixel = 0
    container.Parent = self.Content
    
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.fromOffset(10, 5)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 4)
    sliderBg.Position = UDim2.new(0, 10, 1, -15)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
    
    self.Config[name] = default
    
    -- Slider interaction would go here
end

-- Usage:
-- local settings = Settings:CreatePanel("Settings")
-- settings:AddToggle("Enable Feature", true, function(value)
--     print("Feature toggled:", value)
-- end)
''',
            },
            "Module Poisoning": {
                "Basic require() Hook": '''-- Hook require() to intercept module loads
local originalRequire = require
local loadedModules = {}

local function hookRequire()
    getgenv().require = function(module)
        local moduleName = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
        
        warn("[REQUIRE] Loading:", moduleName)
        
        -- Call original require
        local result = originalRequire(module)
        
        -- Cache the result
        loadedModules[moduleName] = result
        
        warn("[REQUIRE] Loaded:", moduleName, "| Type:", typeof(result))
        
        return result
    end
end

hookRequire()

-- View all loaded modules
local function getLoadedModules()
    for name, module in pairs(loadedModules) do
        print(name, "->", typeof(module))
    end
end
''',
                "Module Cache Inspector": '''-- Inspect and dump module cache
local function inspectModuleCache()
    local cache = {}
    
    -- Get loaded module scripts from game
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local success, module = pcall(require, obj)
            if success then
                cache[obj:GetFullName()] = {
                    path = obj:GetFullName(),
                    type = typeof(module),
                    isTable = type(module) == "table",
                    module = module
                }
                
                -- If it's a table, get its keys
                if type(module) == "table" then
                    cache[obj:GetFullName()].keys = {}
                    for k, v in pairs(module) do
                        table.insert(cache[obj:GetFullName()].keys, {
                            key = tostring(k),
                            valueType = typeof(v)
                        })
                    end
                end
            end
        end
    end
    
    return cache
end

-- Usage
local cache = inspectModuleCache()
for path, data in pairs(cache) do
    print("Module:", path)
    print("  Type:", data.type)
    if data.keys then
        print("  Keys:")
        for _, keyData in ipairs(data.keys) do
            print(string.format("    %s: %s", keyData.key, keyData.valueType))
        end
    end
end
''',
                "Module Replacement": '''-- Replace a module's return value completely
local originalRequire = require
local moduleReplacements = {}

-- Register a replacement for a module
local function replaceModule(modulePath, replacement)
    moduleReplacements[modulePath] = replacement
    print("[MODULE POISON] Registered replacement for:", modulePath)
end

-- Hook require to serve replacements
getgenv().require = function(module)
    local moduleName = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
    
    -- Check if we have a replacement
    if moduleReplacements[moduleName] then
        warn("[MODULE POISON] Serving poisoned module:", moduleName)
        return moduleReplacements[moduleName]
    end
    
    -- Otherwise return original
    return originalRequire(module)
end

-- Example: Replace a module with custom implementation
--[[
local fakeModule = {
    someFunction = function()
        print("Poisoned function called!")
        return "fake data"
    end
}

replaceModule("ReplicatedStorage.GameModules.CombatController", fakeModule)
--]]
''',
                "Module Method Hijacker": '''-- Hijack specific methods in loaded modules
local originalRequire = require
local methodHooks = {}

local function hookModuleMethod(modulePath, methodName, hook)
    if not methodHooks[modulePath] then
        methodHooks[modulePath] = {}
    end
    methodHooks[modulePath][methodName] = hook
    print("[METHOD HOOK] Registered hook for:", modulePath, ".", methodName)
end

getgenv().require = function(module)
    local moduleName = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
    local result = originalRequire(module)
    
    -- Check if we have hooks for this module
    if methodHooks[moduleName] and type(result) == "table" then
        for methodName, hook in pairs(methodHooks[moduleName]) do
            if result[methodName] then
                local originalMethod = result[methodName]
                
                result[methodName] = function(...)
                    -- Pre-hook
                    local shouldContinue, modifiedArgs = hook("before", {...})
                    
                    if not shouldContinue then
                        return
                    end
                    
                    -- Call original
                    local returns = {originalMethod(unpack(modifiedArgs or {...}))}
                    
                    -- Post-hook
                    hook("after", returns)
                    
                    return unpack(returns)
                end
                
                warn("[METHOD HOOK] Hooked:", moduleName, ".", methodName)
            end
        end
    end
    
    return result
end

-- Example usage:
--[[
hookModuleMethod("ReplicatedStorage.CombatModule", "DealDamage", function(phase, data)
    if phase == "before" then
        print("DealDamage called with:", unpack(data))
        -- Modify damage amount (data[2] might be damage)
        data[2] = 0  -- Set damage to 0
        return true, data
    else
        print("DealDamage returned:", unpack(data))
    end
end)
--]]
''',
                "Framework Patcher - Knit": '''-- Patch Knit framework services before initialization
local originalRequire = require
local knitPatched = false

getgenv().require = function(module)
    local result = originalRequire(module)
    
    -- Detect Knit framework
    if type(result) == "table" and result.CreateService and not knitPatched then
        warn("[KNIT PATCH] Knit framework detected!")
        knitPatched = true
        
        local originalCreateService = result.CreateService
        
        -- Hook CreateService to monitor all services
        result.CreateService = function(serviceDefinition)
            warn("[KNIT] Service created:", serviceDefinition.Name)
            
            -- Log all methods in the service
            for key, value in pairs(serviceDefinition) do
                if type(value) == "function" then
                    warn("[KNIT]   Method:", key)
                end
            end
            
            -- You can patch service methods here
            -- Example: Hook a specific service
            if serviceDefinition.Name == "CombatService" then
                if serviceDefinition.DealDamage then
                    local originalDealDamage = serviceDefinition.DealDamage
                    serviceDefinition.DealDamage = function(self, ...)
                        warn("[KNIT PATCH] CombatService:DealDamage called with:", ...)
                        return originalDealDamage(self, ...)
                    end
                end
            end
            
            return originalCreateService(serviceDefinition)
        end
        
        -- Hook Start to detect when framework initializes
        if result.Start then
            local originalStart = result.Start
            result.Start = function(...)
                warn("[KNIT PATCH] Knit framework starting...")
                return originalStart(...)
            end
        end
    end
    
    return result
end
''',
                "Framework Patcher - Nevermore": '''-- Patch Nevermore (NevermoreEngine) module loader
local originalRequire = require

getgenv().require = function(module)
    local result = originalRequire(module)
    
    -- Detect Nevermore's module loader pattern
    if type(result) == "table" and result.GetResource then
        warn("[NEVERMORE PATCH] Nevermore loader detected!")
        
        local originalGetResource = result.GetResource
        
        result.GetResource = function(resourceName)
            warn("[NEVERMORE] Loading resource:", resourceName)
            local resource = originalGetResource(resourceName)
            
            -- Patch specific resources
            if resourceName == "CombatController" and type(resource) == "table" then
                warn("[NEVERMORE PATCH] Patching CombatController")
                
                -- Hook methods
                for key, value in pairs(resource) do
                    if type(value) == "function" then
                        local original = value
                        resource[key] = function(...)
                            warn("[COMBAT] Method called:", key)
                            return original(...)
                        end
                    end
                end
            end
            
            return resource
        end
    end
    
    return result
end
''',
                "Dependency Injection": '''-- Inject dependencies into modules before they load
local originalRequire = require
local injectedDependencies = {}

-- Register a dependency to inject
local function injectDependency(modulePath, dependencyName, dependencyValue)
    if not injectedDependencies[modulePath] then
        injectedDependencies[modulePath] = {}
    end
    injectedDependencies[modulePath][dependencyName] = dependencyValue
    print("[INJECT] Registered dependency:", dependencyName, "for", modulePath)
end

getgenv().require = function(module)
    local moduleName = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
    local result = originalRequire(module)
    
    -- Inject dependencies if this is a table module
    if type(result) == "table" and injectedDependencies[moduleName] then
        warn("[INJECT] Injecting dependencies into:", moduleName)
        
        for depName, depValue in pairs(injectedDependencies[moduleName]) do
            result[depName] = depValue
            warn("[INJECT]   Injected:", depName)
        end
    end
    
    return result
end

-- Example: Inject a fake RemoteEvent
--[[
local fakeRemote = {
    FireServer = function(...)
        print("Fake remote fired with:", ...)
    end
}

injectDependency("ReplicatedStorage.Controllers.NetworkController", "CombatRemote", fakeRemote)
--]]
''',
                "Module Load Order Tracker": '''-- Track module loading order and dependencies
local originalRequire = require
local loadOrder = {}
local loadCount = 0
local loadStack = {}

getgenv().require = function(module)
    local moduleName = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
    
    loadCount = loadCount + 1
    
    -- Track what's currently loading (for dependency tree)
    local parent = loadStack[#loadStack]
    
    table.insert(loadStack, moduleName)
    
    local entry = {
        order = loadCount,
        name = moduleName,
        parent = parent,
        timestamp = tick(),
        dependencies = {}
    }
    
    table.insert(loadOrder, entry)
    
    warn(string.format("[LOAD %d] %s%s", loadCount, string.rep("  ", #loadStack - 1), moduleName))
    
    -- Load the module
    local result = originalRequire(module)
    
    -- Pop from stack
    table.remove(loadStack)
    
    entry.loadTime = tick() - entry.timestamp
    entry.type = typeof(result)
    
    return result
end

-- Print load order report
local function printLoadReport()
    print("\n=== Module Load Report ===")
    print("Total modules loaded:", loadCount)
    print("\nLoad order:")
    for _, entry in ipairs(loadOrder) do
        local indent = entry.parent and "  → " or ""
        print(string.format("%s[%d] %s (%.3fs, %s)", 
            indent, entry.order, entry.name, entry.loadTime, entry.type))
    end
end

-- Call after game loads: printLoadReport()
''',
                "OOP Class Patcher": '''-- Patch OOP classes (metatables) returned by modules
local originalRequire = require

local function patchClass(class, patches)
    if type(class) ~= "table" then return class end
    
    -- Check if it's a class (has __index metatable pattern)
    local mt = getmetatable(class)
    if mt and mt.__index then
        warn("[CLASS PATCH] Patching class methods")
        
        for methodName, patchFn in pairs(patches) do
            if mt.__index[methodName] then
                local original = mt.__index[methodName]
                
                mt.__index[methodName] = function(self, ...)
                    return patchFn(self, original, ...)
                end
                
                warn("[CLASS PATCH]   Patched method:", methodName)
            end
        end
    end
    
    return class
end

getgenv().require = function(module)
    local moduleName = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
    local result = originalRequire(module)
    
    -- Example: Patch a specific class
    if moduleName:match("Weapon") or moduleName:match("Gun") then
        warn("[CLASS PATCH] Weapon class detected:", moduleName)
        
        result = patchClass(result, {
            Fire = function(self, original, ...)
                warn("[WEAPON] Fire method called on:", self)
                warn("[WEAPON] Arguments:", ...)
                return original(self, ...)
            end,
            
            Reload = function(self, original, ...)
                warn("[WEAPON] Reload called")
                return original(self, ...)
            end
        })
    end
    
    return result
end
''',
                "Module Whitelist/Blacklist": '''-- Control which modules can be loaded
local originalRequire = require

local config = {
    mode = "blacklist", -- "whitelist" or "blacklist"
    blacklist = {
        "ReplicatedStorage.AntiCheat",
        "ReplicatedStorage.Security",
    },
    whitelist = {
        -- Add allowed modules here if using whitelist mode
    }
}

local function isAllowed(moduleName)
    if config.mode == "blacklist" then
        for _, blocked in ipairs(config.blacklist) do
            if moduleName:match(blocked) then
                return false, "Module blacklisted"
            end
        end
        return true
    elseif config.mode == "whitelist" then
        for _, allowed in ipairs(config.whitelist) do
            if moduleName:match(allowed) then
                return true
            end
        end
        return false, "Module not in whitelist"
    end
    return true
end

getgenv().require = function(module)
    local moduleName = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
    
    local allowed, reason = isAllowed(moduleName)
    
    if not allowed then
        warn("[MODULE BLOCK] Blocked:", moduleName, "| Reason:", reason)
        -- Return empty table instead of loading
        return {}
    end
    
    return originalRequire(module)
end

-- Example: Block anti-cheat modules from loading
-- They'll get an empty table instead of their actual code
''',
                "Live Module Reloading": '''-- Hot-reload modules during runtime
local originalRequire = require
local moduleCache = {}
local moduleInstances = {}

local function cacheModule(module)
    local moduleName = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
    
    if typeof(module) == "Instance" then
        moduleInstances[moduleName] = module
    end
    
    local result = originalRequire(module)
    moduleCache[moduleName] = result
    
    return result
end

getgenv().require = function(module)
    return cacheModule(module)
end

-- Reload a specific module
local function reloadModule(moduleName)
    if not moduleInstances[moduleName] then
        warn("[RELOAD] Module not in cache:", moduleName)
        return nil
    end
    
    warn("[RELOAD] Reloading module:", moduleName)
    
    -- Clear from cache
    moduleCache[moduleName] = nil
    
    -- Re-require it
    local newModule = originalRequire(moduleInstances[moduleName])
    moduleCache[moduleName] = newModule
    
    warn("[RELOAD] Module reloaded successfully")
    return newModule
end

-- Reload all modules
local function reloadAll()
    for moduleName, instance in pairs(moduleInstances) do
        reloadModule(moduleName)
    end
end

-- Usage: reloadModule("ReplicatedStorage.Controllers.PlayerController")
''',
            }
        }
        
        for category, templates in templates_data.items():
            category_item = QTreeWidgetItem(self.templates_tree)
            category_item.setText(0, category)
            category_item.setExpanded(False)
            
            for name, code in templates.items():
                template_item = QTreeWidgetItem(category_item)
                template_item.setText(0, name)
                template_item.setData(0, Qt.ItemDataRole.UserRole, code)

    def insert_template(self, item, column):
        """Insert selected template into the current editor."""
        template_code = item.data(0, Qt.ItemDataRole.UserRole)
        if template_code:
            editor = self.get_current_editor()
            if editor:
                cursor = editor.textCursor()
                cursor.insertText(template_code)
                editor.setFocus()
    
    # --- Find & Replace Methods ---
    def show_find_replace(self):
        """Show the Find & Replace dialog."""
        if not self.find_replace_dialog:
            self.find_replace_dialog = FindReplaceDialog(self)
            
            # Connect buttons to methods
            self.find_replace_dialog.btn_find_next.clicked.connect(self.find_next)
            self.find_replace_dialog.btn_find_prev.clicked.connect(self.find_previous)
            self.find_replace_dialog.btn_replace.clicked.connect(self.replace_current)
            self.find_replace_dialog.btn_replace_all.clicked.connect(self.replace_all)
        
        self.find_replace_dialog.show()
        self.find_replace_dialog.raise_()
        self.find_replace_dialog.activateWindow()
    
    def show_obfuscator(self):
        """Show the obfuscator dialog and obfuscate code."""
        editor = self.get_current_editor()
        if not editor:
            return
        
        code = editor.toPlainText()
        if not code.strip():
            QMessageBox.warning(self, "Empty Editor", "No code to obfuscate.")
            return
        
        # Show obfuscator dialog
        dialog = ObfuscatorDialog(self)
        if dialog.exec():
            options = dialog.get_options()
            
            try:
                # Show progress
                QApplication.setOverrideCursor(Qt.CursorShape.WaitCursor)
                self.statusBar().showMessage("Obfuscating code...")
                
                # Perform obfuscation
                obfuscator = LuaObfuscator(options)
                obfuscated_code = obfuscator.obfuscate(code)
                
                # Create new tab with obfuscated code
                new_tab_name = "Obfuscated"
                if hasattr(editor, 'file_path'):
                    original_name = os.path.basename(editor.file_path)
                    new_tab_name = f"{original_name} (Obfuscated)"
                
                new_editor = self.create_new_tab(new_tab_name)
                new_editor.setPlainText(obfuscated_code)
                
                QApplication.restoreOverrideCursor()
                self.statusBar().showMessage("Code obfuscated successfully!", 3000)
                
                # Show info message
                techniques = []
                if options.get('proxify_locals'): techniques.append("Proxify Locals")
                if options.get('vmify'): techniques.append("Vmify (VM Encoding)")
                extra = f"\n\nPrometheus steps applied: {', '.join(techniques)}" if techniques else ""
                QMessageBox.information(
                    self, 
                    "Obfuscation Complete",
                    f"Code has been obfuscated and opened in a new tab.\n\n"
                    f"Original size: {len(code)} characters\n"
                    f"Obfuscated size: {len(obfuscated_code)} characters"
                    f"{extra}\n\n"
                    f"Test inside executor to see if it functions"
                )
                
            except Exception as e:
                QApplication.restoreOverrideCursor()
                QMessageBox.critical(self, "Obfuscation Error", f"Failed to obfuscate code:\n{str(e)}")
    
    def find_next(self):
        """Find the next occurrence of the search text."""
        if not self.find_replace_dialog:
            return
        
        editor = self.get_current_editor()
        if not editor:
            return
        
        search_text = self.find_replace_dialog.find_input.toPlainText()
        if not search_text:
            self.find_replace_dialog.status_label.setText("Please enter text to find")
            return
        
        flags = QTextDocument.FindFlag(0)
        if self.find_replace_dialog.case_sensitive.isChecked():
            flags |= QTextDocument.FindFlag.FindCaseSensitively
        if self.find_replace_dialog.whole_word.isChecked():
            flags |= QTextDocument.FindFlag.FindWholeWords
        
        found = editor.find(search_text, flags)
        if found:
            self.find_replace_dialog.status_label.setText(f"Found: {search_text}")
        else:
            # Wrap around to beginning
            cursor = editor.textCursor()
            cursor.movePosition(cursor.MoveOperation.Start)
            editor.setTextCursor(cursor)
            found = editor.find(search_text, flags)
            if found:
                self.find_replace_dialog.status_label.setText(f"Wrapped to beginning")
            else:
                self.find_replace_dialog.status_label.setText(f"Not found: {search_text}")
    
    def find_previous(self):
        """Find the previous occurrence of the search text."""
        if not self.find_replace_dialog:
            return
        
        editor = self.get_current_editor()
        if not editor:
            return
        
        search_text = self.find_replace_dialog.find_input.toPlainText()
        if not search_text:
            self.find_replace_dialog.status_label.setText("Please enter text to find")
            return
        
        flags = QTextDocument.FindFlag.FindBackward
        if self.find_replace_dialog.case_sensitive.isChecked():
            flags |= QTextDocument.FindFlag.FindCaseSensitively
        if self.find_replace_dialog.whole_word.isChecked():
            flags |= QTextDocument.FindFlag.FindWholeWords
        
        found = editor.find(search_text, flags)
        if found:
            self.find_replace_dialog.status_label.setText(f"Found: {search_text}")
        else:
            # Wrap around to end
            cursor = editor.textCursor()
            cursor.movePosition(cursor.MoveOperation.End)
            editor.setTextCursor(cursor)
            found = editor.find(search_text, flags)
            if found:
                self.find_replace_dialog.status_label.setText(f"Wrapped to end")
            else:
                self.find_replace_dialog.status_label.setText(f"Not found: {search_text}")
    
    def replace_current(self):
        """Replace the currently selected occurrence."""
        if not self.find_replace_dialog:
            return
        
        editor = self.get_current_editor()
        if not editor:
            return
        
        search_text = self.find_replace_dialog.find_input.toPlainText()
        replace_text = self.find_replace_dialog.replace_input.toPlainText()
        
        cursor = editor.textCursor()
        if cursor.hasSelection():
            cursor.insertText(replace_text)
            self.find_replace_dialog.status_label.setText("Replaced and finding next...")
            self.find_next()
        else:
            self.find_next()
    
    def replace_all(self):
        """Replace all occurrences of the search text."""
        if not self.find_replace_dialog:
            return
        
        editor = self.get_current_editor()
        if not editor:
            return
        
        search_text = self.find_replace_dialog.find_input.toPlainText()
        replace_text = self.find_replace_dialog.replace_input.toPlainText()
        
        if not search_text:
            self.find_replace_dialog.status_label.setText("Please enter text to find")
            return
        
        # Move to beginning
        cursor = editor.textCursor()
        cursor.movePosition(cursor.MoveOperation.Start)
        editor.setTextCursor(cursor)
        
        count = 0
        flags = QTextDocument.FindFlag(0)
        if self.find_replace_dialog.case_sensitive.isChecked():
            flags |= QTextDocument.FindFlag.FindCaseSensitively
        if self.find_replace_dialog.whole_word.isChecked():
            flags |= QTextDocument.FindFlag.FindWholeWords
        
        while editor.find(search_text, flags):
            cursor = editor.textCursor()
            cursor.insertText(replace_text)
            count += 1
        
        self.find_replace_dialog.status_label.setText(f"Replaced {count} occurrence(s)")
    
    # --- Recent Files Methods ---
    def load_recent_files(self):
        """Load recent files from a config file."""
        config_file = os.path.join(os.path.expanduser("~"), ".luabox_recent")
        if os.path.exists(config_file):
            try:
                with open(config_file, 'r') as f:
                    self.recent_files = [line.strip() for line in f.readlines() if line.strip()]
                    self.recent_files = self.recent_files[:self.max_recent_files]
            except:
                pass
    
    def save_recent_files(self):
        """Save recent files to a config file."""
        config_file = os.path.join(os.path.expanduser("~"), ".luabox_recent")
        try:
            with open(config_file, 'w') as f:
                for filepath in self.recent_files:
                    f.write(filepath + '\n')
        except:
            pass
    
    def add_recent_file(self, filepath):
        """Add a file to the recent files list."""
        # Remove if already exists
        if filepath in self.recent_files:
            self.recent_files.remove(filepath)
        
        # Add to beginning
        self.recent_files.insert(0, filepath)
        
        # Keep only max recent files
        self.recent_files = self.recent_files[:self.max_recent_files]
        
        # Save to disk
        self.save_recent_files()
    
    def show_recent_files_menu(self):
        """Show a dropdown menu with recent files."""
        if not self.recent_files:
            QMessageBox.information(self, "No Recent Files", "No recent files to display.")
            return
        
        menu = QMenu(self)
        
        for filepath in self.recent_files:
            if os.path.exists(filepath):
                filename = os.path.basename(filepath)
                action = menu.addAction(filename)
                action.setData(filepath)
                action.triggered.connect(lambda checked, path=filepath: self.open_recent_file(path))
            else:
                # File doesn't exist anymore, show grayed out
                filename = os.path.basename(filepath) + " (missing)"
                action = menu.addAction(filename)
                action.setEnabled(False)
        
        menu.addSeparator()
        clear_action = menu.addAction("Clear Recent Files")
        clear_action.triggered.connect(self.clear_recent_files)
        
        # Show menu at button position
        menu.exec(self.btn_recent.mapToGlobal(self.btn_recent.rect().bottomLeft()))
    
    def open_recent_file(self, filepath):
        """Open a file from the recent files list."""
        if os.path.exists(filepath):
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                editor = self.create_new_tab(os.path.basename(filepath))
                editor.setPlainText(content)
                editor.file_path = filepath
                self.add_recent_file(filepath)
            except Exception as e:
                QMessageBox.critical(self, "Error", f"Failed to open file: {str(e)}")
    
    def clear_recent_files(self):
        """Clear the recent files list."""
        reply = QMessageBox.question(
            self, "Clear Recent Files",
            "Are you sure you want to clear the recent files list?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        )
        if reply == QMessageBox.StandardButton.Yes:
            self.recent_files = []
            self.save_recent_files()


if __name__ == '__main__':
    app = QApplication(sys.argv)
    ide = LuaIDE()
    ide.show()
    sys.exit(app.exec())
