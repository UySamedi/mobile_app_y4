#!/usr/bin/env python3
"""Simple mock backend server for testing Flutter auth"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import time
from urllib.parse import urlparse, parse_qs

PORT = 6001

class AuthHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_POST(self):
        # CORS headers
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        
        # Parse request
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')
        
        try:
            data = json.loads(body)
        except:
            self.send_error(400, "Invalid JSON")
            return

        # Route handling
        path = self.path
        
        # POST /api/v1/auth/login
        if path == '/api/v1/auth/login':
            print(f"[LOGIN] Email: {data.get('email')}, Password: {data.get('password')}")
            
            if data.get('email') and data.get('password'):
                self.send_response(201)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                
                response = {
                    'success': True,
                    'message': 'Login successful',
                    'data': {
                        'access_token': f'mock_jwt_token_{int(time.time())}',
                        'user': {
                            'id': '123',
                            'fullName': 'Test User',
                            'email': data.get('email'),
                            'phone': '+1234567890',
                            'role': 'user'
                        }
                    }
                }
                self.wfile.write(json.dumps(response).encode())
            else:
                self.send_response(400)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                response = {
                    'success': False,
                    'message': 'Email and password are required'
                }
                self.wfile.write(json.dumps(response).encode())
            return

        # POST /api/v1/auth/register
        elif path == '/api/v1/auth/register':
            print(f"[REGISTER] Email: {data.get('email')}, Name: {data.get('fullName')}")
            
            if all([data.get('email'), data.get('password'), data.get('fullName'), data.get('phoneNumber')]):
                self.send_response(201)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                
                response = {
                    'success': True,
                    'message': 'Registration successful',
                    'data': {
                        'user': {
                            'id': '124',
                            'fullName': data.get('fullName'),
                            'email': data.get('email'),
                            'phone': data.get('phoneNumber'),
                            'role': 'user'
                        }
                    }
                }
                self.wfile.write(json.dumps(response).encode())
            else:
                self.send_response(400)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                response = {
                    'success': False,
                    'message': 'All fields are required'
                }
                self.wfile.write(json.dumps(response).encode())
            return

        # 404
        else:
            self.send_response(404)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {
                'success': False,
                'message': 'Route not found'
            }
            self.wfile.write(json.dumps(response).encode())

    def log_message(self, format, *args):
        print(f"[{self.client_address[0]}] {format % args}")

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', PORT), AuthHandler)
    print(f'🚀 Mock server running on http://localhost:{PORT}')
    print(f'   Available endpoints:')
    print(f'   - POST /api/v1/auth/login')
    print(f'   - POST /api/v1/auth/register')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\n✋ Server stopped')
