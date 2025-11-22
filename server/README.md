Image proxy (development)
=========================

This simple Node/Express proxy fetches an image URL and returns it with permissive CORS headers.

Run locally:

1. cd server
2. npm install
3. npm start

Proxy endpoint:
GET http://localhost:3000/image-proxy?url=<encoded-image-url>

Notes:
- This is a development helper. Do NOT expose a production proxy without proper authentication and rate-limiting.
