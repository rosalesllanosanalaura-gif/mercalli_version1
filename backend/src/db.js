const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',          // <--- Forzamos 'root' si el env falla
  password: process.env.DB_PASSWORD || '',      // <--- Contraseña vacía por defecto
  database: process.env.DB_NAME || 'mercalli',  // <--- Base de datos 'mercalli'
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log('¡Conectado exitosamente a la base de datos MySQL!');
    connection.release();
  } catch (error) {
    throw new Error(error.message);
  }
}

module.exports = { pool, testConnection };