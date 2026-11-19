require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const db = require('./db');
const { router: authRouter } = require('./auth');

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());

app.use('/api/auth', rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));
app.get('/health', async (req, res) => {
  try {
    
    if (req.query.tipo === 'invalido') {
      return res.status(400).json({
        success: false,
        error: { code: 'INVALID_REQUEST', message: 'Parámetro de consulta no válido' }
      });
    }

    
    if (req.query.simular === '500') {
      throw new Error('Falla simulada de base de datos para pruebas');
    }

    await db.testConnection();
    res.status(200).json({ success: true, message: 'Mercalli API funcionando', db: 'conectada' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ 
      success: false, 
      error: { code: 'DB_ERROR', message: 'Sin conexión a la base de datos' } 
    });
  }
});

app.use('/api/auth', authRouter);

// Manejador de errores (500)
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ success: false, error: { code: 'INTERNAL_ERROR', message: 'Error interno del servidor' } });
});

const PORT = process.env.PORT || 3000;

db.testConnection()
  .then(() => {
    console.log('MySQL conectado');
    app.listen(PORT, '0.0.0.0', () => console.log(`Servidor en http://localhost:${PORT}`));
  })
  .catch((err) => {
    console.error('No se pudo conectar a MySQL:', err.message);
    process.exit(1);
  });