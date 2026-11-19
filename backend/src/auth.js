const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { z } = require('zod');
const db = require('../db');
const { fail, validate } = require('../util');

const router = express.Router();

const registerSchema = z.object({
  nombre: z.string().min(2).max(100),
  correo: z.string().email().max(150),
  password: z.string().min(8).max(72)
});

const loginSchema = z.object({
  correo: z.string().email(),
  password: z.string().min(1)
});

// Middleware: verifica el token JWT
function auth(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return fail(res, 401, 'NO_TOKEN', 'Token requerido');
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    fail(res, 401, 'INVALID_TOKEN', 'Token inválido o expirado');
  }
}

// POST /api/auth/register
router.post('/register', validate(registerSchema), async (req, res, next) => {
  try {
    const { nombre, correo, password } = req.body;

    const [existe] = await db.execute('SELECT id_usuario FROM usuarios WHERE correo = ?', [correo]);
    if (existe.length > 0) return fail(res, 409, 'EMAIL_IN_USE', 'El correo ya está registrado');

    const hash = await bcrypt.hash(password, 10);
    const [r] = await db.execute(
      'INSERT INTO usuarios (nombre, correo, password_hash) VALUES (?, ?, ?)',
      [nombre, correo, hash]
    );
    res.status(201).json({ success: true, data: { id: r.insertId, nombre, correo } });
  } catch (e) { next(e); }
});

// POST /api/auth/login
router.post('/login', validate(loginSchema), async (req, res, next) => {
  try {
    const { correo, password } = req.body;

    const [rows] = await db.execute(
      'SELECT id_usuario, nombre, correo, password_hash FROM usuarios WHERE correo = ?', [correo]);
    const u = rows[0];
    const ok = u && (await bcrypt.compare(password, u.password_hash));
    if (!ok) return fail(res, 401, 'INVALID_CREDENTIALS', 'Correo o contraseña incorrectos');

    const token = jwt.sign({ id: u.id_usuario, correo: u.correo }, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES || '15m'
    });
    res.status(200).json({
      success: true,
      data: { accessToken: token, usuario: { id: u.id_usuario, nombre: u.nombre, correo: u.correo } }
    });
  } catch (e) { next(e); }
});

// GET /api/auth/me
router.get('/me', auth, async (req, res, next) => {
  try {
    const [rows] = await db.execute(
      'SELECT id_usuario, nombre, correo FROM usuarios WHERE id_usuario = ?', [req.user.id]);
    if (!rows[0]) return fail(res, 404, 'NOT_FOUND', 'Usuario no encontrado');
    res.status(200).json({ success: true, data: rows[0] });
  } catch (e) { next(e); }
});

module.exports = { router, auth };