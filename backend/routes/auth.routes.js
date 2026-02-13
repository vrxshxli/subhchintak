const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { authenticate } = require('../middleware/auth_middleware');

const JWT_SECRET = process.env.JWT_SECRET || 'dev_secret_change_me';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

function generateToken(userId) {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

// ─── REGISTER ───────────────────────────────────────────────────
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, phone } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ success: false, message: 'Name, email, and password are required' });
    }

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      return res.status(409).json({ success: false, message: 'Email already registered' });
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const user = await prisma.user.create({
      data: { name, email, passwordHash, phone: phone || null },
    });

    const token = generateToken(user.id);

    res.status(201).json({
      success: true,
      token,
      user: { id: user.id, name: user.name, email: user.email, phone: user.phone, avatarUrl: user.avatarUrl },
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ success: false, message: 'Registration failed' });
  }
});

// ─── LOGIN ──────────────────────────────────────────────────────
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !user.passwordHash) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    const validPassword = await bcrypt.compare(password, user.passwordHash);
    if (!validPassword) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }

    const token = generateToken(user.id);

    res.json({
      success: true,
      token,
      user: { id: user.id, name: user.name, email: user.email, phone: user.phone, avatarUrl: user.avatarUrl },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Login failed' });
  }
});

// ─── GOOGLE SIGN-IN ─────────────────────────────────────────────
router.post('/google', async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ success: false, message: 'ID token is required' });
    }

    // Decode Firebase ID token payload
    let payload;
    try {
      const parts = idToken.split('.');
      payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());
    } catch (e) {
      return res.status(401).json({ success: false, message: 'Invalid token' });
    }

    const { sub: googleId, email, name, picture } = payload;

    if (!email) {
      return res.status(400).json({ success: false, message: 'Email not found in token' });
    }

    let user = await prisma.user.findFirst({
      where: { OR: [{ googleId }, { email }] },
    });

    if (!user) {
      user = await prisma.user.create({
        data: { name: name || email.split('@')[0], email, googleId, avatarUrl: picture, isVerified: true },
      });
    } else if (!user.googleId) {
      user = await prisma.user.update({
        where: { id: user.id },
        data: { googleId, avatarUrl: picture || user.avatarUrl, isVerified: true },
      });
    }

    const token = generateToken(user.id);

    res.json({
      success: true,
      token,
      user: { id: user.id, name: user.name, email: user.email, phone: user.phone, avatarUrl: user.avatarUrl },
    });
  } catch (error) {
    console.error('Google sign-in error:', error);
    res.status(500).json({ success: false, message: 'Google sign-in failed' });
  }
});

// ─── GET PROFILE ────────────────────────────────────────────────
router.get('/profile', authenticate, async (req, res) => {
  res.json({
    success: true,
    user: {
      id: req.user.id, name: req.user.name, email: req.user.email,
      phone: req.user.phone, avatarUrl: req.user.avatarUrl,
      isVerified: req.user.isVerified, createdAt: req.user.createdAt,
    },
  });
});

module.exports = router;