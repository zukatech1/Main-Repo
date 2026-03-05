"""
ZukaTech UI Bridge Server
---------------------------
Drop this into your ZukaTech folder and run:
    python server.py

Then open ZukaTech-ui.html in your browser.
Keep this terminal window open while using the UI.
"""

import http.server
import json
import os
import subprocess
import sys
import tempfile
import urllib.parse
from pathlib import Path

PORT = 5000
ZukaTech_DIR = Path(__file__).parent.resolve()

# Find lua executable - tries lua.exe (Windows) then lua
def find_lua():
    candidates = ['lua.exe', 'luac5.1.exe', 'lua5.1.exe', 'lua51.exe', 'lua']
    for name in candidates:
        path = ZukaTech_DIR / name
        if path.exists():
            return str(path)
    # fallback to system lua
    return 'lua'

LUA_EXE = find_lua()
CLI_LUA  = str(ZukaTech_DIR / 'cli.lua')

PRESETS = ['Minify', 'Medium', 'Strong']

print(f"""
╔══════════════════════════════════════════╗
║       ZukaTech UI Bridge v1.0          ║
╠══════════════════════════════════════════╣
║  Lua:      {LUA_EXE:<30} ║
║  CLI:      {CLI_LUA:<30} ║
║  Port:     {PORT:<30} ║
╚══════════════════════════════════════════╝

Open ZukaTech-ui.html in your browser.
Press Ctrl+C to stop.
""")


class Handler(http.server.BaseHTTPRequestHandler):

    def log_message(self, format, *args):
        # Clean up server log output
        print(f"  [{self.address_string()}] {format % args}")

    def send_cors(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_cors()
        self.end_headers()

    def do_GET(self):
        if self.path == '/ping':
            self.send_response(200)
            self.send_cors()
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({
                'status': 'ok',
                'lua': LUA_EXE,
                'cli': CLI_LUA,
                'presets': PRESETS
            }).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path != '/obfuscate':
            self.send_response(404)
            self.end_headers()
            return

        try:
            length  = int(self.headers.get('Content-Length', 0))
            body    = self.rfile.read(length)
            payload = json.loads(body.decode('utf-8'))

            lua_code = payload.get('code', '')
            preset   = payload.get('preset', 'Medium')
            extra    = payload.get('extra', '')  # any extra CLI flags

            if not lua_code.strip():
                self._json(400, {'error': 'No Lua code provided'})
                return

            if preset not in PRESETS:
                preset = 'Medium'

            # Write input to a temp file
            with tempfile.NamedTemporaryFile(
                mode='w', suffix='.lua', delete=False,
                dir=ZukaTech_DIR, encoding='utf-8'
            ) as tmp_in:
                tmp_in.write(lua_code)
                tmp_in_path = tmp_in.name

            tmp_out_path = tmp_in_path.replace('.lua', '_obf.lua')

            try:
                cmd = [LUA_EXE, CLI_LUA, '--preset', preset, '--out', tmp_out_path]
                if extra.strip():
                    cmd += extra.strip().split()
                cmd += [tmp_in_path]

                result = subprocess.run(
                    cmd,
                    capture_output=True,
                    text=True,
                    cwd=str(ZukaTech_DIR),
                    timeout=30
                )

                if result.returncode != 0:
                    error_msg = result.stderr.strip() or result.stdout.strip() or 'Unknown error'
                    self._json(200, {
                        'success': False,
                        'error': error_msg,
                        'stdout': result.stdout,
                        'stderr': result.stderr,
                    })
                    return

                # Read output file
                if os.path.exists(tmp_out_path):
                    with open(tmp_out_path, 'r', encoding='utf-8') as f:
                        obfuscated = f.read()
                    self._json(200, {
                        'success': True,
                        'output': obfuscated,
                        'stdout': result.stdout,
                        'size_in': len(lua_code),
                        'size_out': len(obfuscated),
                    })
                else:
                    # Some versions of ZukaTech write to stdout
                    if result.stdout.strip():
                        self._json(200, {
                            'success': True,
                            'output': result.stdout,
                            'size_in': len(lua_code),
                            'size_out': len(result.stdout),
                        })
                    else:
                        self._json(200, {
                            'success': False,
                            'error': 'Output file was not created. Check CLI flags.',
                            'stderr': result.stderr
                        })

            finally:
                # Clean up temp files
                for path in [tmp_in_path, tmp_out_path]:
                    try:
                        if os.path.exists(path):
                            os.remove(path)
                    except:
                        pass

        except subprocess.TimeoutExpired:
            self._json(200, {'success': False, 'error': 'Obfuscation timed out (30s limit)'})
        except Exception as e:
            self._json(500, {'error': str(e)})

    def _json(self, code, data):
        body = json.dumps(data).encode('utf-8')
        self.send_response(code)
        self.send_cors()
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == '__main__':
    server = http.server.HTTPServer(('localhost', PORT), Handler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\n\nServer stopped.')
        sys.exit(0)
