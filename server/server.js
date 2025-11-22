const express = require('express');
const fetch = require('node-fetch');
const app = express();

app.get('/image-proxy', async (req, res) => {
  const url = req.query.url;
  if (!url) return res.status(400).send('missing url');
  try {
    const upstream = await fetch(url);
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET,OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Authorization,Content-Type,Accept');
    const contentType = upstream.headers.get('content-type') || 'application/octet-stream';
    res.set('Content-Type', contentType);
    upstream.body.pipe(res);
  } catch (e) {
    res.status(500).send('fetch error');
  }
});

app.options('/image-proxy', (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Authorization,Content-Type,Accept');
  res.sendStatus(204);
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log('proxy listening on', port));
