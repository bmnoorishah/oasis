const express = require('express');
const axios = require('axios');
const swaggerUi = require('swagger-ui-express');

const app = express();
app.use(express.json());

// List of microservices and their OpenAPI JSON endpoints
const services = [
  { name: 'User Service', url: 'http://localhost:4101/swagger.json' },
  { name: 'Timesheet Service', url: 'http://localhost:4002/swagger.json' },
  { name: 'Expense Service', url: 'http://localhost:4003/swagger.json' },
  { name: 'Approval Service', url: 'http://localhost:4103/swagger.json' },
  { name: 'Device Service', url: 'http://localhost:4104/swagger.json' },
  { name: 'Location Service', url: 'http://localhost:4105/swagger.json' },
  { name: 'Notification Service', url: 'http://localhost:4106/swagger.json' },
  { name: 'Audit Service', url: 'http://localhost:4107/swagger.json' },
  { name: 'Auth Service', url: 'http://localhost:4001/swagger.json' }
];

// Landing page: list all Swagger docs
app.get('/', (req, res) => {
  res.send(`
    <h1>Swagger Aggregator</h1>
    <ul>
      ${services.map(s => `<li><a href="/docs/${s.name.replace(/\s+/g, '-').toLowerCase()}">${s.name}</a></li>`).join('')}
    </ul>
  `);
});


// Proxy each Swagger UI (fetch OpenAPI JSON)
services.forEach(service => {
  app.use(`/docs/${service.name.replace(/\s+/g, '-').toLowerCase()}`, swaggerUi.serve, async (req, res) => {
    try {
      const { data } = await axios.get(service.url);
      res.send(swaggerUi.generateHTML(data));
    } catch (err) {
      res.status(502).send(`Failed to load Swagger docs for ${service.name}`);
    }
  });
});

const PORT = process.env.PORT || 4300;
app.listen(PORT, () => console.log(`Swagger Aggregator running on port ${PORT}`));
