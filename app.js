const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from Syed Sofiyan this is my Node.js App! Version 1');
});

app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
