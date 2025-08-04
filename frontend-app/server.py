#!/usr/bin/env python3
"""
Simple HTTP server to serve the frontend application
This avoids CORS issues when opening index.html directly with file:// protocol
"""

import http.server
import socketserver
import os
import sys
from pathlib import Path

# Get the directory where this script is located
SCRIPT_DIR = Path(__file__).parent.absolute()

class CORSHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.send_header('Access-Control-Max-Age', '86400')
        super().end_headers()
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()
    
    def log_message(self, format, *args):
        # Custom logging to show requests
        print(f"[{self.log_date_time_string()}] {format % args}")

def main():
    # Change to the frontend directory
    os.chdir(SCRIPT_DIR)
    
    PORT = int(os.environ.get('PORT', 3000))
    HOST = os.environ.get('HOST', '0.0.0.0')
    
    with socketserver.TCPServer((HOST, PORT), CORSHTTPRequestHandler) as httpd:
        print(f"🚀 Servidor frontend iniciado en http://{HOST}:{PORT}")
        print(f"📁 Sirviendo archivos desde: {SCRIPT_DIR}")
        print(f"🌐 Abre tu navegador en: http://localhost:{PORT}")
        print("Presiona Ctrl+C para detener el servidor")
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 Servidor detenido")

if __name__ == "__main__":
    main() 