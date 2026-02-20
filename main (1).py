import sys
import re
import subprocess
import tempfile
import os
import fnmatch
import random

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
        
        self.zoom_level = 0
        self.base_font_size = 11

    def wheelEvent(self, event):
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
        if self.zoom_level < 10:
            self.zoom_level += 1
            self.update_font_size()
    
    def zoom_out(self):
        if self.zoom_level > -5:
            self.zoom_level -= 1
            self.update_font_size()
    
    def reset_zoom(self):
        self.zoom_level = 0
        self.update_font_size()
    
    def update_font_size(self):
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

        keyword_format = QTextCharFormat()
        keyword_format.setForeground(QColor("#0000CC"))
        keyword_format.setFontWeight(700)

        keywords = [
            "and", "break", "do", "else", "elseif", "end", "false",
            "for", "function", "if", "in", "local", "nil", "not",
            "or", "repeat", "return", "then", "true", "until", "while",
        ]
        for kw in keywords:
            self.highlighting_rules.append(
                (re.compile(r'\b' + kw + r'\b'), keyword_format)
            )

        builtin_format = QTextCharFormat()
        builtin_format.setForeground(QColor("#7C00D4"))

        builtins = [
            "print", "tostring", "tonumber", "type", "pairs", "ipairs",
            "unpack", "select", "next", "error", "assert", "pcall",
            "xpcall", "rawget", "rawset", "rawequal", "setmetatable",
            "getmetatable", "require", "loadstring", "load", "dofile",
            "collectgarbage",
            "table", "string", "math", "os", "io", "coroutine",
            "game", "workspace", "script", "task", "warn", "tick",
            "wait", "spawn", "delay",
        ]
        for b in builtins:
            self.highlighting_rules.append(
                (re.compile(r'\b' + b + r'\b'), builtin_format)
            )

        roblox_format = QTextCharFormat()
        roblox_format.setForeground(QColor("#007070"))

        roblox_names = [
            "Instance", "Vector3", "Vector2", "CFrame", "Color3",
            "UDim2", "UDim", "TweenInfo", "Enum", "Drawing",
            "Players", "RunService", "UserInputService", "TweenService",
            "ReplicatedStorage", "ServerStorage", "Workspace",
            "HttpService", "CoreGui", "Lighting",
        ]
        for r in roblox_names:
            self.highlighting_rules.append(
                (re.compile(r'\b' + r + r'\b'), roblox_format)
            )

        number_format = QTextCharFormat()
        number_format.setForeground(QColor("#098658"))
        self.highlighting_rules.append(
            (re.compile(r'\b\d+(\.\d+)?\b'), number_format)
        )

        self.string_format = QTextCharFormat()
        self.string_format.setForeground(QColor("#A31515"))

        self.comment_format = QTextCharFormat()
        self.comment_format.setForeground(QColor("#228B22"))
        self.comment_format.setFontItalic(True)

        self.single_comment_re = re.compile(r'--(?!\[\[).*')
        self.ml_start_re = re.compile(r'--\[\[')
        self.ml_end_str = ']]'

    def highlightBlock(self, text):
        for pattern, fmt in self.highlighting_rules:
            for m in pattern.finditer(text):
                self.setFormat(m.start(), m.end() - m.start(), fmt)

        self._highlight_strings(text)

        self.setCurrentBlockState(0)

        if self.previousBlockState() == 1:
            end = text.find(self.ml_end_str)
            if end == -1:
                self.setCurrentBlockState(1)
                self.setFormat(0, len(text), self.comment_format)
                return
            else:
                self.setFormat(0, end + 2, self.comment_format)
                scan_from = end + 2
        else:
            scan_from = 0

        while True:
            m = self.ml_start_re.search(text, scan_from)
            if not m:
                break
            start = m.start()
            end_idx = text.find(self.ml_end_str, start + 4)
            if end_idx == -1:
                self.setCurrentBlockState(1)
                self.setFormat(start, len(text) - start, self.comment_format)
                return
            else:
                self.setFormat(start, end_idx + 2 - start, self.comment_format)
                scan_from = end_idx + 2

        for m in self.single_comment_re.finditer(text):
            self.setFormat(m.start(), len(text) - m.start(), self.comment_format)

    def _highlight_strings(self, text):
        i = 0
        n = len(text)
        while i < n:
            ch = text[i]
            if ch in ('"', "'"):
                quote = ch
                j = i + 1
                while j < n:
                    if text[j] == '\\':
                        j += 2
                        continue
                    if text[j] == quote:
                        j += 1
                        break
                    j += 1
                self.setFormat(i, j - i, self.string_format)
                i = j
            else:
                i += 1


# --- Smart Comment Remover ---
class LuaCommentRemover:
    @staticmethod
    def remove_comments(code):
        lines = code.split('\n')
        result_lines = []
        in_multiline_comment = False
        
        for line in lines:
            if in_multiline_comment:
                if ']]' in line:
                    after_comment = line.split(']]', 1)[1]
                    in_multiline_comment = False
                    if after_comment.strip():
                        result_lines.append(after_comment)
                continue
            
            if '--[[' in line:
                before_comment = line.split('--[[', 1)[0]
                remaining = line.split('--[[', 1)[1]
                
                if ']]' in remaining:
                    after_comment = remaining.split(']]', 1)[1]
                    cleaned = before_comment + after_comment
                    if cleaned.strip():
                        result_lines.append(cleaned)
                else:
                    in_multiline_comment = True
                    if before_comment.strip():
                        result_lines.append(before_comment)
                continue
            
            cleaned_line = LuaCommentRemover._remove_single_line_comment(line)
            if cleaned_line.strip():
                result_lines.append(cleaned_line)
        
        return '\n'.join(result_lines)
    
    @staticmethod
    def _remove_single_line_comment(line):
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
            if char in ['"', "'"] and not in_string:
                in_string = True
                string_char = char
            elif char == string_char and in_string:
                in_string = False
                string_char = None
            elif not in_string and char == '-' and i + 1 < len(line) and line[i + 1] == '-':
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
        
        self.font_size = QSpinBox()
        self.font_size.setRange(8, 24)
        self.font_size.setValue(11)
        layout.addRow("Font Size:", self.font_size)
        
        self.theme = QComboBox()
        self.theme.addItems(["Light", "Dark (Coming Soon)"])
        layout.addRow("Theme:", self.theme)
        
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
        
        find_layout = QHBoxLayout()
        find_label = QLabel("Find:")
        find_label.setMinimumWidth(60)
        self.find_input = QTextEdit()
        self.find_input.setMaximumHeight(30)
        find_layout.addWidget(find_label)
        find_layout.addWidget(self.find_input)
        layout.addLayout(find_layout)
        
        replace_layout = QHBoxLayout()
        replace_label = QLabel("Replace:")
        replace_label.setMinimumWidth(60)
        self.replace_input = QTextEdit()
        self.replace_input.setMaximumHeight(30)
        replace_layout.addWidget(replace_label)
        replace_layout.addWidget(self.replace_input)
        layout.addLayout(replace_layout)
        
        options_layout = QHBoxLayout()
        self.case_sensitive = QCheckBox("Case Sensitive")
        self.whole_word = QCheckBox("Whole Words")
        options_layout.addWidget(self.case_sensitive)
        options_layout.addWidget(self.whole_word)
        options_layout.addStretch()
        layout.addLayout(options_layout)
        
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
        
        title = QLabel("Obfuscate")
        title.setStyleSheet("font-size: 14pt; font-weight: bold; color: #E81123;")
        layout.addWidget(title)
        
        desc = QLabel("Select obfuscation options below:")
        desc.setStyleSheet("color: #666666; margin-bottom: 10px;")
        desc.setWordWrap(True)
        layout.addWidget(desc)
        
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
        
        options_group = QWidget()
        options_layout = QVBoxLayout(options_group)
        options_layout.setContentsMargins(10, 10, 10, 10)
        options_group.setStyleSheet("QWidget { background-color: #F5F5F5; border-radius: 5px; }")
        
        self.rename_vars = QCheckBox("Rename Variables")
        self.rename_vars.setChecked(True)
        self.rename_vars.setToolTip("Rename local variables to random meaningless names")
        options_layout.addWidget(self.rename_vars)
        
        self.encode_strings = QCheckBox("Encode Strings")
        self.encode_strings.setChecked(True)
        self.encode_strings.setToolTip("Convert strings to string.char() calls")
        options_layout.addWidget(self.encode_strings)
        
        self.encode_numbers = QCheckBox("Encode Numbers")
        self.encode_numbers.setChecked(False)
        self.encode_numbers.setToolTip("Obfuscate numeric literals")
        options_layout.addWidget(self.encode_numbers)
        
        self.control_flow = QCheckBox("Control Flow Obfuscation")
        self.control_flow.setChecked(True)
        self.control_flow.setToolTip("Add fake conditional branches and complex control flow")
        options_layout.addWidget(self.control_flow)
        
        self.add_junk = QCheckBox("Insert Junk Code")
        self.add_junk.setChecked(False)
        self.add_junk.setToolTip("Add random non-functional code")
        options_layout.addWidget(self.add_junk)
        
        self.minify = QCheckBox("Minify (Remove Whitespace)")
        self.minify.setChecked(True)
        self.minify.setToolTip("Remove all unnecessary whitespace and comments")
        options_layout.addWidget(self.minify)
        
        self.anti_debug = QCheckBox("Anti-Debug Protection")
        self.anti_debug.setChecked(False)
        self.anti_debug.setToolTip("Add anti-debugging and anti-tampering checks")
        options_layout.addWidget(self.anti_debug)
        
        self.wrap_function = QCheckBox("Wrap in Anonymous Function")
        self.wrap_function.setChecked(True)
        self.wrap_function.setToolTip("Wrap entire code in a self-executing function")
        options_layout.addWidget(self.wrap_function)

        self.add_vararg = QCheckBox("Add Vararg  [Prometheus]")
        self.add_vararg.setChecked(False)
        self.add_vararg.setToolTip(
            "Append '...' vararg to every function signature that doesn't already have one. "
            "Matches Prometheus AddVararg step — makes static analysis harder."
        )
        self.add_vararg.setStyleSheet("color: #6600CC; font-weight: bold;")
        options_layout.addWidget(self.add_vararg)

        self.watermark = QCheckBox("Watermark  [Prometheus]")
        self.watermark.setChecked(False)
        self.watermark.setToolTip(
            "Set a hidden global variable to a watermark string at the top of the script. "
            "Matches Prometheus Watermark step."
        )
        self.watermark.setStyleSheet("color: #6600CC; font-weight: bold;")
        options_layout.addWidget(self.watermark)

        self.watermark_check = QCheckBox("Watermark Check  [Prometheus]")
        self.watermark_check.setChecked(False)
        self.watermark_check.setToolTip(
            "Add a guard that returns immediately if the watermark global doesn't match. "
            "Requires Watermark to be enabled. Matches Prometheus WatermarkCheck step."
        )
        self.watermark_check.setStyleSheet("color: #6600CC; font-weight: bold;")
        options_layout.addWidget(self.watermark_check)

        self.proxify_locals = QCheckBox("Proxify Locals  [Prometheus]")
        self.proxify_locals.setChecked(False)
        self.proxify_locals.setToolTip(
            "Wrap local variables in metatable proxy objects so reads/writes go through "
            "__index/__newindex metamethods (inspired by Prometheus ProxifyLocals)"
        )
        self.proxify_locals.setStyleSheet("color: #6600CC; font-weight: bold;")
        options_layout.addWidget(self.proxify_locals)

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
        
        warning = QLabel("Heavily obfuscated code may run slower. "
                         "Vmify is the strongest option — it XOR-encodes the entire script.")
        warning.setStyleSheet("color: #FF8800; font-size: 9pt;")
        warning.setWordWrap(True)
        layout.addWidget(warning)
        
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
        
        btn_cancel.clicked.connect(self.reject)
        self.btn_obfuscate.clicked.connect(self.accept)
        
        self.apply_preset("Medium")
    
    def apply_preset(self, preset):
        # Reset all Prometheus steps first
        self.add_vararg.setChecked(False)
        self.watermark.setChecked(False)
        self.watermark_check.setChecked(False)
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
            self.add_vararg.setChecked(True)
        elif preset == "Medium":
            self.rename_vars.setChecked(True)
            self.encode_strings.setChecked(True)
            self.encode_numbers.setChecked(False)
            self.control_flow.setChecked(True)
            self.add_junk.setChecked(False)
            self.minify.setChecked(True)
            self.anti_debug.setChecked(False)
            self.wrap_function.setChecked(True)
            self.add_vararg.setChecked(True)
            self.watermark.setChecked(True)
        elif preset == "Heavy":
            self.rename_vars.setChecked(True)
            self.encode_strings.setChecked(True)
            self.encode_numbers.setChecked(True)
            self.control_flow.setChecked(True)
            self.add_junk.setChecked(True)
            self.minify.setChecked(True)
            self.anti_debug.setChecked(True)
            self.wrap_function.setChecked(True)
            self.add_vararg.setChecked(True)
            self.watermark.setChecked(True)
            self.watermark_check.setChecked(True)
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
            self.add_vararg.setChecked(True)
            self.watermark.setChecked(True)
            self.watermark_check.setChecked(True)
            self.proxify_locals.setChecked(True)
            self.vmify.setChecked(True)
    
    def get_options(self):
        return {
            'rename_vars': self.rename_vars.isChecked(),
            'encode_strings': self.encode_strings.isChecked(),
            'encode_numbers': self.encode_numbers.isChecked(),
            'control_flow': self.control_flow.isChecked(),
            'add_junk': self.add_junk.isChecked(),
            'minify': self.minify.isChecked(),
            'anti_debug': self.anti_debug.isChecked(),
            'wrap_function': self.wrap_function.isChecked(),
            'add_vararg': self.add_vararg.isChecked(),
            'watermark': self.watermark.isChecked(),
            'watermark_check': self.watermark_check.isChecked(),
            'proxify_locals': self.proxify_locals.isChecked(),
            'vmify': self.vmify.isChecked(),
        }


# ---------------------------------------------------------------------------
# Utility: tokenise Lua source into safe segments.
# Returns a list of dicts: {'type': ..., 'value': ..., 'is_string': bool}
# ---------------------------------------------------------------------------
def _lua_segments(code):
    """
    Walk through Lua source and yield segments tagged as string/comment/code.
    Used by rename_variables and encode_strings to avoid touching literal content.
    """
    segments = []
    i = 0
    n = len(code)
    while i < n:
        # Multi-line comment  --[[ ... ]]
        if code[i:i+4] == '--[[':
            end = code.find(']]', i + 4)
            if end == -1:
                segments.append({'type': 'comment', 'value': code[i:]})
                break
            segments.append({'type': 'comment', 'value': code[i:end+2]})
            i = end + 2
            continue

        # Single-line comment  -- ...
        if code[i:i+2] == '--':
            end = code.find('\n', i)
            if end == -1:
                segments.append({'type': 'comment', 'value': code[i:]})
                break
            segments.append({'type': 'comment', 'value': code[i:end]})
            i = end
            continue

        # Multi-line string  [[ ... ]]
        if code[i:i+2] == '[[':
            end = code.find(']]', i + 2)
            if end == -1:
                segments.append({'type': 'string', 'value': code[i:], 'raw': code[i:]})
                break
            segments.append({'type': 'string', 'value': code[i:end+2], 'raw': code[i+2:end]})
            i = end + 2
            continue

        # Quoted string  "..." or '...'
        if code[i] in ('"', "'"):
            quote = code[i]
            j = i + 1
            chars = []
            while j < n:
                if code[j] == '\\' and j + 1 < n:
                    chars.append(code[j+1])
                    j += 2
                    continue
                if code[j] == quote:
                    j += 1
                    break
                chars.append(code[j])
                j += 1
            segments.append({'type': 'string', 'value': code[i:j], 'raw': ''.join(chars)})
            i = j
            continue

        # Everything else: accumulate as code
        if segments and segments[-1]['type'] == 'code':
            segments[-1]['value'] += code[i]
        else:
            segments.append({'type': 'code', 'value': code[i]})
        i += 1

    return segments


class LuaObfuscator:
    def __init__(self, options):
        self.options = options
        self.var_map = {}
        self.var_counter = 0
        self.keywords = {
            'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for',
            'function', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat',
            'return', 'then', 'true', 'until', 'while', 'goto'
        }
        self.roblox_globals = {
            'game', 'workspace', 'script', 'Instance', 'Vector3', 'CFrame',
            'task', 'wait', 'spawn', 'print', 'warn', 'error', 'shared',
            '_G', 'getgenv', 'getrenv', 'Enum', 'Color3', 'UDim2', 'math',
            'string', 'table', 'pcall', 'xpcall', 'delay', 'tick', 'os',
            # executor globals — never rename these
            'getrawmetatable', 'setreadonly', 'hookmetamethod', 'hookfunction',
            'newcclosure', 'getnamecallmethod', 'checkcaller', 'getconnections',
            'firesignal', 'Drawing', 'WebSocket', 'request', 'http_request',
            'readfile', 'writefile', 'isfile', 'isfolder', 'makefolder',
            'identifyexecutor', 'getgenv', 'getrenv', 'loadstring', 'load',
        }

    # ------------------------------------------------------------------
    # Main pipeline
    # ------------------------------------------------------------------
    def obfuscate(self, code):
        result = code

        # Step 1: Add vararg to all functions (before rename so arg names survive)
        if self.options.get('add_vararg'):
            result = LuaAddVararg().add_vararg(result)

        # Step 2: Rename local variables
        if self.options['rename_vars']:
            result = self.rename_variables(result)

        # Step 3: ProxifyLocals (wraps locals in metatable proxies)
        if self.options.get('proxify_locals'):
            result = LuaProxifyLocals().proxify(result)

        # Step 4: Encode strings → string.char(...)
        if self.options['encode_strings']:
            result = self.encode_strings(result)

        # Step 5: Encode numbers
        if self.options['encode_numbers']:
            result = self.encode_numbers(result)

        # Step 6: Control flow junk
        if self.options['control_flow']:
            result = self.add_control_flow(result)

        # Step 7: Junk locals
        if self.options['add_junk']:
            result = self.add_junk_code(result)

        # Step 8: Anti-debug header
        if self.options['anti_debug']:
            result = self.add_anti_debug(result)

        # Step 9: Watermark — mirrors Prometheus ordering:
        #   WatermarkCheck is applied first (inserts guard into body),
        #   then Watermark prepends the setter so it executes before the guard.
        # We track the var_name so both steps share the same global.
        wm_var = None
        wm_content = None
        if self.options.get('watermark') or self.options.get('watermark_check'):
            wm_content = self.options.get('watermark_content',
                                          'Protected by LuaBox Obfuscator')
            wm_var = LuaWatermark._random_global_name()

        if self.options.get('watermark_check') and wm_var:
            # Insert the guard first (it will sit below the setter after step below)
            result = LuaWatermarkCheck.apply(result, wm_var, wm_content)

        if self.options.get('watermark') and wm_var:
            # Prepend the setter so it runs before the guard
            result, wm_var, wm_content = LuaWatermark.apply(result, wm_content, wm_var)

        # Step 10: Wrap in anonymous function (skipped if vmify takes over)
        if self.options['wrap_function'] and not self.options.get('vmify'):
            result = self.wrap_in_function(result)

        # Step 11: Minify
        if self.options['minify']:
            result = self.minify_code(result)

        # Step 12: Vmify — XOR-encrypt everything into a VM loader (always last)
        if self.options.get('vmify'):
            result = LuaVmify().vmify(result)

        return result

    # ------------------------------------------------------------------
    # Variable name generator
    # ------------------------------------------------------------------
    def _generate_var_name(self):
        """
        Generate names that look like Lua identifiers but are hard to read:
        mix of l, I, 1, O, 0 characters.
        """
        # Use a mix of visually similar chars for confusion
        chars = 'lIiOo'
        n = self.var_counter
        self.var_counter += 1
        # Ensure starts with a letter
        name = chars[n % len(chars)]
        n //= len(chars)
        suffix_chars = 'lIiOo01'
        length = 6 + (self.var_counter % 4)  # 6-9 chars total
        while len(name) < length:
            name += suffix_chars[n % len(suffix_chars)]
            n = n // len(suffix_chars) + self.var_counter
        return name

    # ------------------------------------------------------------------
    # FIX: rename_variables — skip string/comment segments
    # ------------------------------------------------------------------
    def rename_variables(self, code):
        """
        Collect all 'local <name>' declarations, map them to mangled names,
        then replace only in code segments (not inside strings or comments).
        """
        # Pass 1: collect local variable names from code segments only
        segments = _lua_segments(code)
        for seg in segments:
            if seg['type'] != 'code':
                continue
            for match in re.finditer(r'\blocal\s+([a-zA-Z_][a-zA-Z0-9_]*)', seg['value']):
                old_name = match.group(1)
                if (old_name not in self.var_map
                        and old_name not in self.keywords
                        and old_name not in self.roblox_globals):
                    self.var_map[old_name] = self._generate_var_name()

        if not self.var_map:
            return code

        # Pass 2: rebuild code, replacing identifiers only in 'code' segments
        result_parts = []
        for seg in segments:
            if seg['type'] == 'code':
                chunk = seg['value']
                for old_name, new_name in self.var_map.items():
                    chunk = re.sub(r'(?<![a-zA-Z0-9_])' + re.escape(old_name) + r'(?![a-zA-Z0-9_])',
                                   new_name, chunk)
                result_parts.append(chunk)
            else:
                # Preserve strings and comments completely unchanged
                result_parts.append(seg['value'])

        return ''.join(result_parts)

    # ------------------------------------------------------------------
    # FIX: encode_strings — use string.char() instead of \NNN escapes
    # ------------------------------------------------------------------
    def encode_strings(self, code):
        """
        Replace string literals with string.char(...) calls.
        - Executor-friendly: string.char is universally supported
        - Skips comments and multi-line [[ ]] strings
        - Empty strings become ""
        """
        segments = _lua_segments(code)
        result_parts = []

        for seg in segments:
            if seg['type'] == 'string' and seg['value'].startswith(('[[', '"', "'")):
                raw = seg.get('raw', '')
                if seg['value'].startswith('[['):
                    # Multi-line string: encode as string.char sequence
                    if raw:
                        char_vals = ','.join(str(ord(c)) for c in raw)
                        result_parts.append(f'string.char({char_vals})')
                    else:
                        result_parts.append('""')
                else:
                    # Quoted string
                    if raw:
                        char_vals = ','.join(str(ord(c)) for c in raw)
                        result_parts.append(f'string.char({char_vals})')
                    else:
                        result_parts.append('""')
            else:
                result_parts.append(seg['value'])

        return ''.join(result_parts)

    # ------------------------------------------------------------------
    # encode_numbers — safe integer obfuscation
    # ------------------------------------------------------------------
    def encode_numbers(self, code):
        """Only encode standalone integer literals outside strings/comments."""
        segments = _lua_segments(code)
        result_parts = []

        def replace_num(match):
            num_str = match.group(0)
            num = int(num_str)
            if num > 10:
                a = random.randint(1, num - 1)
                b = num - a
                return f'({a}+{b})'
            return num_str

        for seg in segments:
            if seg['type'] == 'code':
                chunk = re.sub(r'(?<![.\w])\b([1-9][0-9]+)\b(?!\s*\.)', replace_num, seg['value'])
                result_parts.append(chunk)
            else:
                result_parts.append(seg['value'])

        return ''.join(result_parts)

    # ------------------------------------------------------------------
    # control flow
    # ------------------------------------------------------------------
    def add_control_flow(self, code):
        junk = [
            'do local _=nil end',
            'if false then end',
            'repeat until true',
        ]
        lines = code.split('\n')
        result = []
        for i, line in enumerate(lines):
            result.append(line)
            stripped = line.strip()
            if (i % 8 == 0 and stripped
                    and not stripped.startswith('--')
                    and not stripped.endswith(',')
                    and not stripped.endswith('(')
                    and not stripped.endswith('{')
                    and not stripped.endswith('and')
                    and not stripped.endswith('or')
                    and not stripped.endswith('=')
                    and not stripped.endswith('..')
                    and stripped not in ('', 'do', 'then', 'else', 'repeat')):
                result.append(random.choice(junk))
        return '\n'.join(result)

    # ------------------------------------------------------------------
    # junk code
    # ------------------------------------------------------------------
    def add_junk_code(self, code):
        junk = [
            'local _j0=nil',
            'local _j1=0',
            'local _j2=false',
        ]
        lines = code.split('\n')
        result = []
        for i, line in enumerate(lines):
            result.append(line)
            stripped = line.strip()
            if (i % 12 == 0 and stripped
                    and not stripped.startswith('--')
                    and not stripped.endswith(',')
                    and not stripped.endswith('(')
                    and not stripped.endswith('{')
                    and not stripped.endswith('and')
                    and not stripped.endswith('or')
                    and not stripped.endswith('=')
                    and not stripped.endswith('..')
                    and stripped not in ('', 'do', 'then', 'else', 'repeat')):
                result.append(random.choice(junk))
        return '\n'.join(result)

    # ------------------------------------------------------------------
    # anti-debug (executor-aware)
    # ------------------------------------------------------------------
    def add_anti_debug(self, code):
        # Only check things that actually differ inside an executor vs normal
        anti_debug = (
            'if not game then return end\n'
            'if not game:IsLoaded() then game.Loaded:Wait() end\n'
        )
        return anti_debug + code

    # ------------------------------------------------------------------
    # FIX: wrap_in_function — drop leading 'return', use semicolon prefix
    # ------------------------------------------------------------------
    def wrap_in_function(self, code):
        """
        Wrap code in a self-invoking anonymous function.
        Executor scripts are run as a function body so 'return' at top level
        works, but the semicolon prefix avoids edge cases with minified code
        where the first token could be ambiguous.
        """
        return f';(function(...)\n{code}\nend)(...)'

    # ------------------------------------------------------------------
    # minify
    # ------------------------------------------------------------------
    def minify_code(self, code):
        # Remove single-line comments (safe — not inside strings here since
        # encode_strings already ran and converted them to string.char calls)
        code = re.sub(r'--(?!\[\[)[^\n]*', '', code)
        code = re.sub(r'--\[\[.*?\]\]', '', code, flags=re.DOTALL)
        lines = [line.strip() for line in code.split('\n') if line.strip()]
        return '\n'.join(lines)


# ---------------------------------------------------------------------------
# ProxifyLocals — FIXED to use __index / __newindex correctly
# ---------------------------------------------------------------------------
class LuaProxifyLocals:
    """
    Wraps local variable declarations in __index/__newindex metatable proxies.
    Every read goes through __index, every write through __newindex.
    This is the correct Lua metamethod pair for table-key access.
    """

    def __init__(self):
        self._counter = 0

    def _uid(self):
        self._counter += 1
        # Visually confusing name
        chars = 'lIiOo01'
        n = self._counter
        name = 'l'
        for _ in range(7):
            name += chars[n % len(chars)]
            n = n // len(chars) + self._counter
        return '_' + name

    def _random_key(self):
        letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
        length = random.randint(6, 12)
        return ''.join(random.choice(letters) for _ in range(length))

    def _make_proxy(self, val_expr: str, key: str) -> str:
        """
        Build a Lua expression:
            setmetatable({}, {
                __index    = function(t, k) return rawget(t, "_v") end,
                __newindex = function(t, k, v) rawset(t, "_v", v) end,
                _v = <val_expr>
            })
        We store the real value inside the metatable (not the table itself)
        so rawget/rawset on the proxy table can't trivially find it.
        """
        mt_key = self._random_key()  # key inside metatable to hide the value
        return (
            f'setmetatable({{}},{{_v={val_expr},'
            f'__index=function(_t,_k)return rawget(getmetatable(_t),"_v")end,'
            f'__newindex=function(_t,_k,_v)rawset(getmetatable(_t),"_v",_v)end}})'
        )

    def proxify(self, code: str) -> str:
        lines = code.split('\n')
        var_proxies = {}  # varname -> proxy_varname

        result_lines = []
        for line in lines:
            stripped = line.lstrip()

            if stripped.startswith('--'):
                result_lines.append(line)
                continue

            if re.match(r'local\s+function\s+', stripped):
                result_lines.append(line)
                continue

            # Match: local <name> = <expr>
            m = re.match(r'^(\s*)local\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*(.+)$', line)
            if m:
                indent, varname, expr = m.group(1), m.group(2), m.group(3)
                proxy_name = self._uid()
                var_proxies[varname] = proxy_name
                proxy_expr = self._make_proxy(expr.rstrip(), self._random_key())
                result_lines.append(f'{indent}local {proxy_name} = {proxy_expr}')
                continue

            # Replace usages of proxied vars in other lines
            new_line = line
            for varname, proxy_name in var_proxies.items():
                # proxy[k] read triggers __index which returns the hidden value
                new_line = re.sub(
                    r'(?<!\w)' + re.escape(varname) + r'(?!\w)',
                    f'{proxy_name}[0]',
                    new_line
                )
            result_lines.append(new_line)

        return '\n'.join(result_lines)


# ---------------------------------------------------------------------------
# Vmify — FIXED with robust Lua 5.1/Luau compatible XOR loader
# ---------------------------------------------------------------------------
class LuaVmify:
    def vmify(self, code: str) -> str:
        # Generate a pseudorandom key stream using a simple LCG
        seed = random.randint(1, 0x7FFFFFFF)
        key_len = random.randint(16, 64)

        rng_state = seed
        key_stream = []
        for _ in range(key_len):
            rng_state = (rng_state * 48271) % 0x7FFFFFFF
            key_stream.append((rng_state % 255) + 1)  # 1-255, never 0

        src_bytes = code.encode('utf-8')
        cipher = []
        for i, b in enumerate(src_bytes):
            cipher.append(b ^ key_stream[i % key_len])

        # Encode cipher as Lua-safe decimal escape sequences (\NNN)
        # These are valid in both Lua 5.1 and Luau
        escaped = ''.join('\\' + str(b) for b in cipher)

        # The loader uses bit32.bxor for Lua 5.1 compatibility,
        # with a fallback to Luau's ~ operator.
        # bit32 is available in Roblox's Luau runtime.
        loader = (
            ';(function(...)\n'
            f'local _seed,_klen={seed},{key_len}\n'
            'local _K={}\n'
            'local _rng=_seed\n'
            'for _i=1,_klen do\n'
            '_rng=(_rng*48271)%0x7FFFFFFF\n'
            '_K[_i]=(_rng%255)+1\n'
            'end\n'
            f'local _B="{escaped}"\n'
            'local _n=#_B\n'
            'local _S=table.create and table.create(_n) or {}\n'
            'local _bxor=bit32 and bit32.bxor or function(a,b)return a~b end\n'
            'for _i=1,_n do\n'
            '_S[_i]=string.char(_bxor(string.byte(_B,_i),_K[((_i-1)%_klen)+1]))\n'
            'end\n'
            'local _src=table.concat(_S)\n'
            'local _fn,_err=(loadstring or load)(_src)\n'
            'if not _fn then error("[VM] "..tostring(_err),2) end\n'
            '_fn(...)\n'
            'end)(...)'
        )

        return loader


# ---------------------------------------------------------------------------
# AddVararg — Prometheus AddVararg step (text-level)
# Appends '...' vararg to every function that doesn't already have one.
# Matches the behaviour of Prometheus's AddVararg.lua exactly:
#   "if #node.args < 1 or node.args[last].kind ~= VarargExpression then append"
# ---------------------------------------------------------------------------
class LuaAddVararg:
    # Matches:
    #   function foo(a, b)          local function bar(x)
    #   function(a, b)              function foo:method(x)
    # Does NOT touch functions that already end with '...'
    _FUNC_RE = re.compile(
        r'((?:local\s+)?function\s*(?:[a-zA-Z_][a-zA-Z0-9_.]*(?:[:][a-zA-Z_][a-zA-Z0-9_]*)?)?\s*)'
        r'\(([^)]*)\)'
    )

    @staticmethod
    def _patch_args(args_str: str) -> str:
        """Return args string with '...' appended if not already present."""
        stripped = args_str.strip()
        if stripped == '...':
            return args_str
        if stripped.endswith('...'):
            return args_str
        if stripped == '':
            return '...'
        return args_str.rstrip() + ', ...'

    def add_vararg(self, code: str) -> str:
        """
        Walk through only code segments (not strings/comments) and patch
        every function signature to include '...' as its last argument.
        """
        segments = _lua_segments(code)
        result_parts = []

        for seg in segments:
            if seg['type'] != 'code':
                result_parts.append(seg['value'])
                continue

            chunk = seg['value']

            def replacer(m):
                prefix = m.group(1)
                args = m.group(2)
                new_args = LuaAddVararg._patch_args(args)
                return f'{prefix}({new_args})'

            chunk = self._FUNC_RE.sub(replacer, chunk)
            result_parts.append(chunk)

        return ''.join(result_parts)


# ---------------------------------------------------------------------------
# LuaWatermark — Prometheus Watermark step (text-level)
#
# Prometheus's Watermark.lua does:
#   ("some string"):gsub(".+", function(v) _WATERMARK = v end)
# This sets a global to the watermark content via a gsub callback,
# which hides the assignment from naive static analysis.
# We replicate this exactly, inserting it at the top of the script.
# ---------------------------------------------------------------------------
class LuaWatermark:
    @staticmethod
    def _random_global_name() -> str:
        """Generate a plausible-looking Prometheus-style variable name."""
        chars = 'lIiOo01'
        n = random.randint(0, 0xFFFFFF)
        name = '_'
        for _ in range(10):
            name += chars[n % len(chars)]
            n //= len(chars)
        return name

    @staticmethod
    def apply(code: str, content: str, var_name: str = None) -> tuple:
        """
        Prepend the watermark assignment to the script.
        Returns (modified_code, var_name, content) so WatermarkCheck can use them.

        Emitted Lua (mirrors Prometheus Watermark.lua):
            ("CONTENT"):gsub(".+", function(_w) _VARNAME = _w end)
        """
        if var_name is None:
            var_name = LuaWatermark._random_global_name()

        # Use gsub callback to obscure the assignment — identical to Prometheus
        watermark_stmt = (
            f'("{content}"):gsub(".+",function(_w){var_name}=_w end)\n'
        )
        return watermark_stmt + code, var_name, content


# ---------------------------------------------------------------------------
# LuaWatermarkCheck — Prometheus WatermarkCheck step (text-level)
#
# Prometheus's WatermarkCheck.lua inserts:
#   if _VARNAME ~= "CONTENT" then return end
# at the very top of the script body (before the watermark setter).
# When used together with Watermark the order in Prometheus is:
#   1. WatermarkCheck inserts the guard
#   2. Watermark inserts the setter above the guard
# Net result:
#   ("CONTENT"):gsub(...)   -- sets _VARNAME
#   if _VARNAME ~= "CONTENT" then return end
#   ... rest of script ...
# We replicate this two-step ordering below.
# ---------------------------------------------------------------------------
class LuaWatermarkCheck:
    @staticmethod
    def apply(code: str, var_name: str, content: str) -> str:
        """
        Insert the watermark guard at the top of the script.
        Must be called AFTER LuaWatermark.apply so the setter precedes the guard.
        """
        guard = f'if {var_name}~="{content}" then return end\n'
        return guard + code


# ---------------------------------------------------------------------------
# Localizer
# ---------------------------------------------------------------------------
class LuaLocalizer:
    @staticmethod
    def localize(code):
        services = set(re.findall(r'game:GetService\(["\'](\w+)["\']\)', code))
        globals_to_fix = ["Vector3", "CFrame", "Instance", "UDim2", "Color3", "task", "wait", "spawn"]
        found_globals = [g for g in globals_to_fix if re.search(r'\b' + g + r'\b', code)]

        header = "-- [[ Auto-Localization ]]\n"
        for service in services:
            header += f'local {service} = game:GetService("{service}")\n'
        for g in found_globals:
            header += f'local {g} = {g}\n'

        for service in services:
            code = code.replace(f'game:GetService("{service}")', service)
            code = code.replace(f"game:GetService('{service}')", service)

        return header + "\n" + code


# --- Main Application Window ---
class LuaIDE(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("LuaBox v4")
        self.setGeometry(100, 100, 1400, 850)
        
        self.current_file = None
        self.current_directory = QDir.homePath()
        
        self.recent_files = []
        self.max_recent_files = 10
        self.load_recent_files()
        
        self.find_replace_dialog = None
        
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

        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

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
        
        def create_separator():
            sep = QWidget()
            sep.setFixedWidth(1)
            sep.setStyleSheet("background-color: #ADADAD;")
            sep.setFixedHeight(22)
            return sep
        
        btn_settings = QPushButton("Settings")
        btn_settings.setStyleSheet("background-color: #E8D6F0;")
        btn_settings.clicked.connect(self.show_settings)

        btn_format = QPushButton("Format Code")
        btn_format.setStyleSheet("background-color: #E6F3FF;")
        btn_format.clicked.connect(self.format_current_code)
        
        btn_strip = QPushButton("Remove Comments")
        btn_strip.clicked.connect(self.remove_comments)
        
        btn_find_replace = QPushButton("Find & Replace")
        btn_find_replace.clicked.connect(self.show_find_replace)
        
        btn_obfuscate = QPushButton("Obfuscate")
        btn_obfuscate.setStyleSheet("background-color: #FFE6E6;")
        btn_obfuscate.clicked.connect(self.show_obfuscator)
        
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

        content_splitter = QSplitter(Qt.Orientation.Horizontal)
        
        explorer_widget = QWidget()
        explorer_widget.setMaximumWidth(250)
        explorer_layout = QVBoxLayout(explorer_widget)
        explorer_layout.setContentsMargins(0, 0, 0, 0)
        
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

        btn_browse = QPushButton("📁")
        btn_browse.setMaximumWidth(30)
        btn_browse.setToolTip("Browse for directory")
        btn_browse.clicked.connect(self.browse_directory)
        
        btn_refresh = QPushButton("⟳")
        btn_refresh.setMaximumWidth(30)
        btn_refresh.setToolTip("Refresh explorer")
        btn_refresh.clicked.connect(self.refresh_explorer)
        
        explorer_header_layout.addWidget(explorer_label)
        explorer_header_layout.addStretch()
        explorer_header_layout.addWidget(btn_browse)
        explorer_header_layout.addWidget(btn_refresh)
        
        self.file_tree = QTreeWidget()
        self.file_tree.setHeaderLabels(["Name", "Size"])
        self.file_tree.setColumnWidth(0, 150)
        self.file_tree.itemDoubleClicked.connect(self.tree_item_double_clicked)
        self.file_tree.itemExpanded.connect(self.tree_item_expanded)
        self.file_tree.setContextMenuPolicy(Qt.ContextMenuPolicy.CustomContextMenu)
        self.file_tree.customContextMenuRequested.connect(self.show_tree_context_menu)
        
        explorer_tab_layout.addWidget(explorer_header)
        explorer_tab_layout.addWidget(self.file_tree)
        
        templates_tab = QWidget()
        templates_tab_layout = QVBoxLayout(templates_tab)
        templates_tab_layout.setContentsMargins(5, 5, 5, 5)
        
        self.templates_tree = QTreeWidget()
        self.templates_tree.setHeaderLabel("Audit Templates")
        self.templates_tree.itemDoubleClicked.connect(self.insert_template)
        self.populate_templates()
        
        templates_tab_layout.addWidget(self.templates_tree)
        
        left_panel_tabs.addTab(explorer_tab, "Files")
        left_panel_tabs.addTab(templates_tab, "Templates")
        
        explorer_layout.addWidget(left_panel_tabs)
        
        editor_widget = QWidget()
        editor_layout = QVBoxLayout(editor_widget)
        editor_layout.setContentsMargins(0, 0, 0, 0)
        editor_layout.setSpacing(0)
        
        self.tab_widget = QTabWidget()
        self.tab_widget.setTabsClosable(True)
        self.tab_widget.tabCloseRequested.connect(self.close_tab)
        
        self.create_new_tab("new")
        
        editor_layout.addWidget(self.tab_widget)
        
        content_splitter.addWidget(explorer_widget)
        content_splitter.addWidget(editor_widget)
        content_splitter.setSizes([200, 1000])
        
        main_layout.addWidget(content_splitter)
        
        self.refresh_explorer()

    def create_new_tab(self, title):
        tab_container = QWidget()
        tab_layout = QVBoxLayout(tab_container)
        tab_layout.setContentsMargins(0, 0, 0, 0)
        
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
        editor.highlighter = LuaSyntaxHighlighter(editor.document())
        tab_layout.addWidget(editor)
        
        index = self.tab_widget.addTab(tab_container, title)
        self.tab_widget.setCurrentIndex(index)
        
        return editor

    def get_current_editor(self):
        current_widget = self.tab_widget.currentWidget()
        if current_widget:
            return current_widget.findChild(CodeEditor)
        return None

    def new_file(self):
        self.create_new_tab("new")

    def open_file(self):
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
            self.add_recent_file(filename)

    def save_file(self):
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
            self.add_recent_file(filename)
            QMessageBox.information(self, "Success", "File saved successfully!")

    def close_tab(self, index):
        if self.tab_widget.count() > 1:
            self.tab_widget.removeTab(index)
        else:
            editor = self.get_current_editor()
            if editor:
                editor.clear()
                self.tab_widget.setTabText(0, "Untitled")

    def refresh_explorer(self):
        self.file_tree.clear()
        root_item = QTreeWidgetItem(self.file_tree)
        root_item.setText(0, self.current_directory)
        root_item.setText(1, "")
        root_item.setData(0, Qt.ItemDataRole.UserRole, self.current_directory)
        root_item.setExpanded(True)
        self.populate_directory_tree(root_item, self.current_directory)

    def populate_directory_tree(self, parent_item, directory_path):
        try:
            directory = QDir(directory_path)
            dirs = directory.entryInfoList(
                QDir.Filter.Dirs | QDir.Filter.NoDotAndDotDot,
                QDir.SortFlag.Name
            )
            for dir_info in dirs:
                dir_item = QTreeWidgetItem(parent_item)
                dir_item.setText(0, f"📁 {dir_info.fileName()}")
                dir_item.setText(1, "<DIR>")
                dir_item.setData(0, Qt.ItemDataRole.UserRole, dir_info.absoluteFilePath())
                placeholder = QTreeWidgetItem(dir_item)
                placeholder.setText(0, "Loading...")
            
            files = directory.entryInfoList(
                QDir.Filter.Files | QDir.Filter.NoDotAndDotDot,
                QDir.SortFlag.Name
            )
            for file_info in files:
                file_item = QTreeWidgetItem(parent_item)
                file_item.setText(0, f"📄 {file_info.fileName()}")
                size_kb = file_info.size() / 1024
                file_item.setText(1, f"{size_kb:.2f} KB")
                file_item.setData(0, Qt.ItemDataRole.UserRole, file_info.absoluteFilePath())
        except Exception as e:
            error_item = QTreeWidgetItem(parent_item)
            error_item.setText(0, f"Error: {str(e)}")
    
    def browse_directory(self):
        directory = QFileDialog.getExistingDirectory(
            self, "Select Directory", self.current_directory
        )
        if directory:
            self.current_directory = directory
            self.refresh_explorer()
    
    def show_tree_context_menu(self, position):
        item = self.file_tree.itemAt(position)
        if not item:
            return
        filepath = item.data(0, Qt.ItemDataRole.UserRole)
        if not filepath:
            return
        
        menu = QMenu(self)
        if os.path.isfile(filepath):
            open_action = menu.addAction("Open")
            open_action.triggered.connect(lambda: self.tree_item_double_clicked(item, 0))
        if os.path.isdir(filepath):
            set_as_root_action = menu.addAction("Set as Root Directory")
            set_as_root_action.triggered.connect(lambda: self.set_root_directory(filepath))
        menu.addSeparator()
        copy_path_action = menu.addAction("Copy Path")
        copy_path_action.triggered.connect(lambda: QApplication.clipboard().setText(filepath))
        copy_name_action = menu.addAction("Copy Name")
        copy_name_action.triggered.connect(lambda: QApplication.clipboard().setText(os.path.basename(filepath)))
        menu.addSeparator()
        if os.path.exists(filepath):
            show_in_folder_action = menu.addAction("Show in Folder")
            show_in_folder_action.triggered.connect(lambda: self.show_in_system_explorer(filepath))
        menu.exec(self.file_tree.viewport().mapToGlobal(position))
    
    def set_root_directory(self, directory_path):
        self.current_directory = directory_path
        self.refresh_explorer()
    
    def show_in_system_explorer(self, filepath):
        try:
            if os.path.isfile(filepath):
                filepath = os.path.dirname(filepath)
            if sys.platform == 'win32':
                os.startfile(filepath)
            elif sys.platform == 'darwin':
                subprocess.run(['open', filepath])
            else:
                subprocess.run(['xdg-open', filepath])
        except Exception as e:
            QMessageBox.warning(self, "Error", f"Could not open folder: {str(e)}")

    def tree_item_expanded(self, item):
        if item.childCount() == 1:
            child = item.child(0)
            if child.text(0) == "Loading...":
                item.removeChild(child)
                directory_path = item.data(0, Qt.ItemDataRole.UserRole)
                if directory_path and os.path.isdir(directory_path):
                    self.populate_directory_tree(item, directory_path)
    
    def tree_item_double_clicked(self, item, column):
        filepath = item.data(0, Qt.ItemDataRole.UserRole)
        if filepath:
            if os.path.isfile(filepath):
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    editor = self.create_new_tab(os.path.basename(filepath))
                    editor.setPlainText(content)
                    editor.file_path = filepath
                    self.add_recent_file(filepath)
                except Exception as e:
                    QMessageBox.warning(self, "Error", f"Could not open file: {str(e)}")
            elif os.path.isdir(filepath):
                item.setExpanded(not item.isExpanded())

    # ------------------------------------------------------------------
    # FIX: show_settings — removed the extra (font) call that crashed Python
    # ------------------------------------------------------------------
    def show_settings(self):
        dialog = SettingsDialog(self)
        if dialog.exec():
            font_size = dialog.font_size.value()
            for i in range(self.tab_widget.count()):
                widget = self.tab_widget.widget(i)
                editor = widget.findChild(CodeEditor)
                if editor:
                    font = editor.font()
                    font.setPointSize(font_size)
                    editor.setFont(font)  # FIX: was editor.setFont(font)(font) — extra (font) crashed

    def remove_comments(self):
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
            QMessageBox.information(self, "Success", "Comments removed successfully.")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error removing comments: {str(e)}")

    def populate_templates(self):
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
        print(string.format("[%s Hook] %s.%s", hookType, tostring(self), tostring(key)))
        return oldMetamethod(self, key, unpack(args))
    end)
    setreadonly(mt, true)
    
    return oldMetamethod
end
''',
                "Metatable Hook - __namecall": '''-- Advanced __namecall hook for method interception
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
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
local globalSnapshot = {}

for k, v in pairs(_G) do
    globalSnapshot[k] = v
end

task.spawn(function()
    while task.wait(1) do
        for k, v in pairs(_G) do
            if globalSnapshot[k] ~= v then
                warn(string.format("[_G CHANGE] Key '%s' changed", tostring(k)))
                globalSnapshot[k] = v
            end
        end
    end
end)
''',
                "Script Environment Detector": '''-- Detect executor environment and capabilities
local function detectEnvironment()
    local env = {
        executor = identifyexecutor and identifyexecutor() or "Unknown",
        functions = {},
        level = 0
    }
    
    local testFunctions = {
        "getgenv", "getrenv", "getrawmetatable", "setreadonly",
        "hookmetamethod", "hookfunction", "newcclosure",
        "getnamecallmethod", "checkcaller", "getconnections",
        "firesignal", "Drawing", "WebSocket", "request",
        "readfile", "writefile", "isfile", "isfolder"
    }
    
    for _, funcName in ipairs(testFunctions) do
        if getfenv()[funcName] then
            env.functions[funcName] = true
            env.level = env.level + 1
        end
    end
    
    env.rating = env.level >= 14 and "High" or env.level >= 7 and "Medium" or "Low"
    return env
end

local env = detectEnvironment()
print("Executor:", env.executor)
print("Capability Level:", env.rating, "("..env.level.." functions)")
''',
            },
            "Network Analysis": {
                "Remote Spy - All": '''-- Intercept FireServer and InvokeServer
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" or method == "InvokeServer" then
        warn("=== Remote:", self:GetFullName(), "| Method:", method, "===")
        for i, arg in ipairs(args) do
            warn(string.format("  [%d] (%s) %s", i, typeof(arg), tostring(arg)))
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
''',
                "Network Traffic Monitor": '''-- Count all network calls per second
local stats = { fireServer=0, invokeServer=0, total=0 }
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" then stats.fireServer += 1; stats.total += 1
    elseif method == "InvokeServer" then stats.invokeServer += 1; stats.total += 1 end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

task.spawn(function()
    while task.wait(5) do
        warn("FireServer:", stats.fireServer, "| InvokeServer:", stats.invokeServer, "| Total:", stats.total)
    end
end)
''',
            },
            "Entity Visualization": {
                "ESP - Box + Name + Distance": '''-- Box ESP with name and distance labels
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local espObjects = {}

local function createESP(player)
    local esp = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        dist = Drawing.new("Text"),
    }
    esp.box.Thickness = 2; esp.box.Filled = false
    esp.box.Color = Color3.new(1,0,0); esp.box.Visible = false
    esp.name.Center = true; esp.name.Outline = true
    esp.name.Color = Color3.new(1,1,1); esp.name.Size = 14; esp.name.Visible = false
    esp.dist.Center = true; esp.dist.Outline = true
    esp.dist.Color = Color3.new(1,1,1); esp.dist.Size = 12; esp.dist.Visible = false
    espObjects[player] = esp
end

local function removeESP(player)
    if espObjects[player] then
        for _, d in pairs(espObjects[player]) do d:Remove() end
        espObjects[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    for player, esp in pairs(espObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local v, on = Camera:WorldToViewportPoint(hrp.Position)
            if on then
                local h = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,2.5,0))
                local l = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                local ht = math.abs(h.Y - l.Y); local wd = ht/2
                esp.box.Size = Vector2.new(wd, ht)
                esp.box.Position = Vector2.new(v.X - wd/2, v.Y - ht/2)
                esp.box.Visible = true
                esp.name.Text = player.Name
                esp.name.Position = Vector2.new(v.X, h.Y - 20)
                esp.name.Visible = true
                local lp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if lp then
                    esp.dist.Text = string.format("%.0f", (lp.Position - hrp.Position).Magnitude)
                    esp.dist.Position = Vector2.new(v.X, l.Y + 5)
                    esp.dist.Visible = true
                end
            else
                for _, d in pairs(esp) do d.Visible = false end
            end
        else
            for _, d in pairs(esp) do d.Visible = false end
        end
    end
end)
''',
                "Tracers": '''-- Screen-to-player tracers
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local tracers = {}

local function add(p)
    local l = Drawing.new("Line")
    l.Thickness = 1; l.Color = Color3.new(1,0,0)
    l.Transparency = 0.5; l.Visible = false
    tracers[p] = l
end

local function rem(p)
    if tracers[p] then tracers[p]:Remove(); tracers[p] = nil end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then add(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then add(p) end end)
Players.PlayerRemoving:Connect(rem)

RunService.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize
    local origin = Vector2.new(vp.X/2, vp.Y)
    for player, line in pairs(tracers) do
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local v, on = Camera:WorldToViewportPoint(hrp.Position)
            if on then
                line.From = origin; line.To = Vector2.new(v.X, v.Y); line.Visible = true
            else line.Visible = false end
        else line.Visible = false end
    end
end)
''',
                "FOV Circle": '''-- FOV visualization circle
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local fov = Drawing.new("Circle")
fov.Thickness = 2; fov.NumSides = 64; fov.Radius = 120
fov.Filled = false; fov.Color = Color3.new(1,1,1)
fov.Transparency = 0.8; fov.Visible = true

RunService.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize
    fov.Position = Vector2.new(vp.X/2, vp.Y/2)
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        fov.Radius = math.clamp(fov.Radius + input.Position.Z * 10, 30, 600)
    end
end)
''',
            },
            "Character Physics": {
                "Noclip Toggle": '''-- Noclip toggle
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local enabled = false
local conn

local function enable()
    enabled = true
    conn = RunService.Stepped:Connect(function()
        if character then
            for _, p in ipairs(character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end

local function disable()
    enabled = false
    if conn then conn:Disconnect(); conn = nil end
    if character then
        for _, p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end

local function toggle()
    if enabled then disable() else enable() end
end

-- Call toggle() to switch noclip on/off
toggle()
''',
                "Infinite Jump": '''-- Infinite jump
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local enabled = true

UserInputService.JumpRequest:Connect(function()
    if enabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
''',
                "Speed Modifier": '''-- Speed modifier
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function setSpeed(multiplier)
    humanoid.WalkSpeed = 16 * multiplier
end

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = 16 * 2
end)

setSpeed(2)
''',
            },
            "Utility Functions": {
                "Service Cache": '''-- Efficient service caching
local Services = setmetatable({}, {
    __index = function(self, name)
        local s = game:GetService(name)
        rawset(self, name, s)
        return s
    end
})
-- Usage: Services.Players, Services.RunService, etc.
''',
                "Wait for Path": '''-- Wait for instance at path (dot-separated)
local function waitForPath(path, timeout)
    timeout = timeout or 10
    local parts = string.split(path, ".")
    local current = game
    for _, part in ipairs(parts) do
        local ok, result = pcall(function()
            return current:WaitForChild(part, timeout)
        end)
        if not ok or not result then return nil end
        current = result
    end
    return current
end
-- Usage: waitForPath("ReplicatedStorage.Remotes.FireEvent")
''',
                "Deep Copy Table": '''-- Deep copy any table
local function deepCopy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in next, t, nil do
        copy[deepCopy(k)] = deepCopy(v)
    end
    return setmetatable(copy, deepCopy(getmetatable(t)))
end
''',
            },
            "Module Poisoning": {
                "Basic require() Hook": '''-- Hook require() to log all module loads
local originalRequire = require
local loaded = {}

getgenv().require = function(module)
    local name = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
    warn("[REQUIRE]", name)
    local result = originalRequire(module)
    loaded[name] = result
    return result
end
''',
                "Module Method Hijacker": '''-- Hijack specific methods in a loaded module
local originalRequire = require
local hooks = {}  -- { [modulePath] = { [methodName] = hookFn } }

local function hookMethod(modulePath, methodName, fn)
    if not hooks[modulePath] then hooks[modulePath] = {} end
    hooks[modulePath][methodName] = fn
end

getgenv().require = function(module)
    local name = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
    local result = originalRequire(module)
    if type(result) == "table" and hooks[name] then
        for mName, hook in pairs(hooks[name]) do
            if result[mName] then
                local orig = result[mName]
                result[mName] = function(...)
                    return hook(orig, ...)
                end
                warn("[HOOK] Patched", name, ".", mName)
            end
        end
    end
    return result
end

-- Example:
-- hookMethod("ReplicatedStorage.Combat", "DealDamage", function(orig, ...)
--     warn("DealDamage called:", ...)
--     return orig(...)
-- end)
''',
                "Module Blacklist": '''-- Block specific modules from loading (return empty table)
local originalRequire = require
local blacklist = {
    "ReplicatedStorage.AntiCheat",
    "ReplicatedStorage.Security",
}

getgenv().require = function(module)
    local name = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
    for _, blocked in ipairs(blacklist) do
        if name:find(blocked, 1, true) then
            warn("[BLOCKED]", name)
            return {}
        end
    end
    return originalRequire(module)
end
''',
                "Module Load Order Tracker": '''-- Track the order modules are loaded in
local originalRequire = require
local order = {}
local count = 0

getgenv().require = function(module)
    local name = typeof(module) == "Instance" and module:GetFullName() or tostring(module)
    count += 1
    table.insert(order, { n = count, name = name, t = tick() })
    warn(string.format("[LOAD %d] %s", count, name))
    return originalRequire(module)
end

-- Print full report: for _, e in ipairs(order) do print(e.n, e.name) end
''',
            },
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
        template_code = item.data(0, Qt.ItemDataRole.UserRole)
        if template_code:
            editor = self.get_current_editor()
            if editor:
                cursor = editor.textCursor()
                cursor.insertText(template_code)
                editor.setFocus()

    def show_find_replace(self):
        if not self.find_replace_dialog:
            self.find_replace_dialog = FindReplaceDialog(self)
            self.find_replace_dialog.btn_find_next.clicked.connect(self.find_next)
            self.find_replace_dialog.btn_find_prev.clicked.connect(self.find_previous)
            self.find_replace_dialog.btn_replace.clicked.connect(self.replace_current)
            self.find_replace_dialog.btn_replace_all.clicked.connect(self.replace_all)
        self.find_replace_dialog.show()
        self.find_replace_dialog.raise_()
        self.find_replace_dialog.activateWindow()

    def show_obfuscator(self):
        editor = self.get_current_editor()
        if not editor:
            return
        code = editor.toPlainText()
        if not code.strip():
            QMessageBox.warning(self, "Empty Editor", "No code to obfuscate.")
            return
        
        dialog = ObfuscatorDialog(self)
        if dialog.exec():
            options = dialog.get_options()
            try:
                QApplication.setOverrideCursor(Qt.CursorShape.WaitCursor)
                self.statusBar().showMessage("Obfuscating code...")
                
                obfuscator = LuaObfuscator(options)
                obfuscated_code = obfuscator.obfuscate(code)
                
                new_tab_name = "Obfuscated"
                if hasattr(editor, 'file_path'):
                    new_tab_name = os.path.basename(editor.file_path) + " (Obfuscated)"
                
                new_editor = self.create_new_tab(new_tab_name)
                new_editor.setPlainText(obfuscated_code)
                
                QApplication.restoreOverrideCursor()
                self.statusBar().showMessage("Code obfuscated successfully!", 3000)
                
                techniques = []
                if options.get('add_vararg'): techniques.append("Add Vararg")
                if options.get('watermark'): techniques.append("Watermark")
                if options.get('watermark_check'): techniques.append("Watermark Check")
                if options.get('proxify_locals'): techniques.append("Proxify Locals")
                if options.get('vmify'): techniques.append("Vmify (VM Encoding)")
                extra = f"\nPrometheus steps: {', '.join(techniques)}" if techniques else ""
                
                QMessageBox.information(
                    self, "Obfuscation Complete",
                    f"Code obfuscated and opened in a new tab.\n\n"
                    f"Original: {len(code)} chars\n"
                    f"Obfuscated: {len(obfuscated_code)} chars"
                    f"{extra}\n\n"
                    f"Test in executor before use."
                )
            except Exception as e:
                QApplication.restoreOverrideCursor()
                QMessageBox.critical(self, "Obfuscation Error", f"Failed to obfuscate:\n{str(e)}")

    def find_next(self):
        if not self.find_replace_dialog:
            return
        editor = self.get_current_editor()
        if not editor:
            return
        search_text = self.find_replace_dialog.find_input.toPlainText()
        if not search_text:
            self.find_replace_dialog.status_label.setText("Enter text to find")
            return
        flags = QTextDocument.FindFlag(0)
        if self.find_replace_dialog.case_sensitive.isChecked():
            flags |= QTextDocument.FindFlag.FindCaseSensitively
        if self.find_replace_dialog.whole_word.isChecked():
            flags |= QTextDocument.FindFlag.FindWholeWords
        found = editor.find(search_text, flags)
        if not found:
            cursor = editor.textCursor()
            cursor.movePosition(cursor.MoveOperation.Start)
            editor.setTextCursor(cursor)
            found = editor.find(search_text, flags)
        self.find_replace_dialog.status_label.setText(
            f"Found: {search_text}" if found else f"Not found: {search_text}"
        )

    def find_previous(self):
        if not self.find_replace_dialog:
            return
        editor = self.get_current_editor()
        if not editor:
            return
        search_text = self.find_replace_dialog.find_input.toPlainText()
        if not search_text:
            return
        flags = QTextDocument.FindFlag.FindBackward
        if self.find_replace_dialog.case_sensitive.isChecked():
            flags |= QTextDocument.FindFlag.FindCaseSensitively
        if self.find_replace_dialog.whole_word.isChecked():
            flags |= QTextDocument.FindFlag.FindWholeWords
        found = editor.find(search_text, flags)
        if not found:
            cursor = editor.textCursor()
            cursor.movePosition(cursor.MoveOperation.End)
            editor.setTextCursor(cursor)
            found = editor.find(search_text, flags)
        self.find_replace_dialog.status_label.setText(
            f"Found: {search_text}" if found else f"Not found: {search_text}"
        )

    def replace_current(self):
        if not self.find_replace_dialog:
            return
        editor = self.get_current_editor()
        if not editor:
            return
        replace_text = self.find_replace_dialog.replace_input.toPlainText()
        cursor = editor.textCursor()
        if cursor.hasSelection():
            cursor.insertText(replace_text)
        self.find_next()

    def replace_all(self):
        if not self.find_replace_dialog:
            return
        editor = self.get_current_editor()
        if not editor:
            return
        search_text = self.find_replace_dialog.find_input.toPlainText()
        replace_text = self.find_replace_dialog.replace_input.toPlainText()
        if not search_text:
            return
        cursor = editor.textCursor()
        cursor.movePosition(cursor.MoveOperation.Start)
        editor.setTextCursor(cursor)
        flags = QTextDocument.FindFlag(0)
        if self.find_replace_dialog.case_sensitive.isChecked():
            flags |= QTextDocument.FindFlag.FindCaseSensitively
        if self.find_replace_dialog.whole_word.isChecked():
            flags |= QTextDocument.FindFlag.FindWholeWords
        count = 0
        while editor.find(search_text, flags):
            editor.textCursor().insertText(replace_text)
            count += 1
        self.find_replace_dialog.status_label.setText(f"Replaced {count} occurrence(s)")

    def load_recent_files(self):
        config_file = os.path.join(os.path.expanduser("~"), ".luabox_recent")
        if os.path.exists(config_file):
            try:
                with open(config_file, 'r') as f:
                    self.recent_files = [line.strip() for line in f if line.strip()]
                    self.recent_files = self.recent_files[:self.max_recent_files]
            except:
                pass

    def save_recent_files(self):
        config_file = os.path.join(os.path.expanduser("~"), ".luabox_recent")
        try:
            with open(config_file, 'w') as f:
                for fp in self.recent_files:
                    f.write(fp + '\n')
        except:
            pass

    def add_recent_file(self, filepath):
        if filepath in self.recent_files:
            self.recent_files.remove(filepath)
        self.recent_files.insert(0, filepath)
        self.recent_files = self.recent_files[:self.max_recent_files]
        self.save_recent_files()

    def show_recent_files_menu(self):
        if not self.recent_files:
            QMessageBox.information(self, "No Recent Files", "No recent files to display.")
            return
        menu = QMenu(self)
        for filepath in self.recent_files:
            if os.path.exists(filepath):
                action = menu.addAction(os.path.basename(filepath))
                action.triggered.connect(lambda checked, path=filepath: self.open_recent_file(path))
            else:
                action = menu.addAction(os.path.basename(filepath) + " (missing)")
                action.setEnabled(False)
        menu.addSeparator()
        clear_action = menu.addAction("Clear Recent Files")
        clear_action.triggered.connect(self.clear_recent_files)
        menu.exec(self.btn_recent.mapToGlobal(self.btn_recent.rect().bottomLeft()))

    def open_recent_file(self, filepath):
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

    def format_current_code(self):
        editor = self.get_current_editor()
        if not editor:
            return
        code = editor.toPlainText()
        if not code.strip():
            QMessageBox.information(self, "Format Code", "No code to format.")
            return
        try:
            formatted_code = self.format_lua_code(code)
            cursor = editor.textCursor()
            old_position = cursor.position()
            editor.setPlainText(formatted_code)
            cursor.setPosition(min(old_position, len(formatted_code)))
            editor.setTextCursor(cursor)
            self.statusBar().showMessage("Code formatted successfully", 3000)
        except Exception as e:
            QMessageBox.warning(self, "Format Error", f"Error formatting code: {str(e)}")

    def format_lua_code(self, code):
        lines = code.split('\n')
        formatted_lines = []
        indent_level = 0
        indent_str = "    "
        in_multiline_comment = False

        for line in lines:
            stripped = line.strip()

            if not stripped:
                formatted_lines.append('')
                continue

            if in_multiline_comment:
                formatted_lines.append(indent_str * indent_level + stripped)
                if ']]' in stripped:
                    in_multiline_comment = False
                continue

            if '--[[' in stripped and ']]' not in stripped:
                in_multiline_comment = True
                formatted_lines.append(indent_str * indent_level + stripped)
                continue

            if stripped.startswith('--'):
                formatted_lines.append(indent_str * indent_level + stripped)
                continue

            if stripped.startswith('end') or stripped.startswith('until'):
                indent_level = max(0, indent_level - 1)
            elif stripped.startswith('else') or stripped.startswith('elseif'):
                formatted_lines.append(indent_str * max(0, indent_level - 1) + stripped)
                continue

            formatted_lines.append(indent_str * indent_level + stripped)

            if (stripped.startswith('function') or
                    re.match(r'^if\b', stripped) or
                    re.match(r'^for\b', stripped) or
                    re.match(r'^while\b', stripped) or
                    stripped.startswith('repeat') or
                    (stripped == 'do') or
                    stripped.startswith('local function')):
                indent_level += 1
            elif stripped.endswith('then') or stripped.endswith(' do'):
                indent_level += 1
            elif stripped.startswith('else'):
                indent_level += 1

        return '\n'.join(formatted_lines)

    def clear_recent_files(self):
        reply = QMessageBox.question(
            self, "Clear Recent Files",
            "Clear the recent files list?",
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
