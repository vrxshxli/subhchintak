const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { authenticate } = require('../middleware/auth_middleware');

router.get('/', authenticate, async (req, res) => {
  try {
    const notifications = await prisma.notification.findMany({
      where: { userId: req.user.id }, orderBy: { createdAt: 'desc' }, take: 50,
    });
    res.json({
      success: true,
      updates: notifications.map((n) => ({
        id: n.id, type: n.type, title: n.title, body: n.body, data: n.data, read: n.isRead, createdAt: n.createdAt,
      })),
    });
  } catch (error) {
    console.error('Get updates error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch updates' });
  }
});

router.put('/read-all', authenticate, async (req, res) => {
  try {
    await prisma.notification.updateMany({ where: { userId: req.user.id, isRead: false }, data: { isRead: true } });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to mark as read' });
  }
});

module.exports = router;