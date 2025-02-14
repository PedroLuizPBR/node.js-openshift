const express = require('express');
const app = express();
const port = 3000;

// Middleware for parsing JSON requests
app.use(express.json());

// In-memory data store
let items = [];

// Get all items
app.get('/api/items', (req, res) => {
  res.json(items);
});

// Get a single item by ID
app.get('/api/items/:id', (req, res) => {
  const itemId = parseInt(req.params.id);
  const item = items.find((i) => i.id === itemId);

  if (!item) {
    return res.status(404).json({ error: 'Item not found' });
  }

  res.json(item);
});

// Create a new item
app.post('/api/items', (req, res) => {
  const newItem = req.body;
  items.push(newItem);
  res.status(201).json(newItem);
});

// Hello, world! endpoint
app.get('/api/hello-world', (req, res) => {
  res.send('Hello, world!');
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

