const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const { authenticate } = require('../middleware/auth_middleware');

const prisma = new PrismaClient();

// GET /api/updates
router.get('/', authenticate, async (req, res) => {
  try {
    const updates = await prisma.notification.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });

    res.json({
      success: true,
      updates: updates.map((u) => ({
        id: u.id,
        type: u.type,
        title: u.title,
        body: u.body,
        read: u.isRead,
        data: u.data,
        createdAt: u.createdAt,
      })),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch updates' });
  }
});

// PUT /api/updates/read-all
router.put('/read-all', authenticate, async (req, res) => {
  try {
    await prisma.notification.updateMany({
      where: { userId: req.user.id, isRead: false },
      data: { isRead: true },
    });
    res.json({ success: true, message: 'All marked as read' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update' });
  }
});

module.exports = router;