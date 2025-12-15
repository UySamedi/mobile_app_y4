// Simple mock backend server for testing
const http = require('http');
const url = require('url');

const PORT = 6001;

const server = http.createServer((req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Content-Type', 'application/json');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  // POST /api/v1/auth/login
  if (pathname === '/api/v1/auth/login' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        console.log(`[LOGIN] Email: ${data.email}, Password: ${data.password}`);

        // Mock authentication - accept any non-empty email/password
        if (data.email && data.password) {
          res.writeHead(201);
          res.end(JSON.stringify({
            success: true,
            message: 'Login successful',
            data: {
              access_token: 'mock_jwt_token_' + Date.now(),
              user: {
                id: '123',
                fullName: 'Test User',
                email: data.email,
                phone: '+1234567890',
                role: 'user'
              }
            }
          }));
        } else {
          res.writeHead(400);
          res.end(JSON.stringify({
            success: false,
            message: 'Email and password are required'
          }));
        }
      } catch (err) {
        res.writeHead(400);
        res.end(JSON.stringify({
          success: false,
          message: 'Invalid request'
        }));
      }
    });
    return;
  }

  // POST /api/v1/auth/register
  if (pathname === '/api/v1/auth/register' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on('end', () => {
      try {
        const data = JSON.parse(body);
        console.log(`[REGISTER] Email: ${data.email}, Name: ${data.fullName}`);

        if (data.email && data.password && data.fullName && data.phoneNumber) {
          res.writeHead(201);
          res.end(JSON.stringify({
            success: true,
            message: 'Registration successful',
            data: {
              user: {
                id: '124',
                fullName: data.fullName,
                email: data.email,
                phone: data.phoneNumber,
                role: 'user'
              }
            }
          }));
        } else {
          res.writeHead(400);
          res.end(JSON.stringify({
            success: false,
            message: 'All fields are required'
          }));
        }
      } catch (err) {
        res.writeHead(400);
        res.end(JSON.stringify({
          success: false,
          message: 'Invalid request'
        }));
      }
    });
    return;
  }

  // 404 for unknown routes
  res.writeHead(404);
  res.end(JSON.stringify({
    success: false,
    message: 'Route not found'
  }));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Mock server running on http://localhost:${PORT}`);
  console.log(`   Available endpoints:`);
  console.log(`   - POST /api/v1/auth/login`);
  console.log(`   - POST /api/v1/auth/register`);
});
