const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { authenticate } = require('../middleware/auth_middleware');

router.get('/sessions', authenticate, async (req, res) => {
  try {
    const sessions = await prisma.chatSession.findMany({
      where: { ownerId: req.user.id },
      orderBy: { updatedAt: 'desc' },
      include: { messages: { orderBy: { createdAt: 'desc' }, take: 1 }, qrCode: { select: { purpose: true, customPurpose: true } } },
    });
    res.json({
      success: true,
      sessions: sessions.map((s) => ({
        id: s.id, qrPurpose: s.qrCode?.customPurpose || s.qrCode?.purpose || 'Unknown',
        isActive: s.isActive, lastMessage: s.messages[0]?.content || null,
        lastMessageAt: s.messages[0]?.createdAt || s.updatedAt, createdAt: s.createdAt,
      })),
    });
  } catch (error) {
    console.error('Get chat sessions error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch sessions' });
  }
});

router.get('/messages/:sessionId', authenticate, async (req, res) => {
  try {
    const { sessionId } = req.params;
    const session = await prisma.chatSession.findFirst({ where: { id: sessionId, ownerId: req.user.id } });
    if (!session) return res.status(404).json({ success: false, message: 'Session not found' });

    const messages = await prisma.chatMessage.findMany({ where: { sessionId }, orderBy: { createdAt: 'asc' } });
    res.json({
      success: true,
      messages: messages.map((m) => ({
        id: m.id, senderType: m.senderType, messageType: m.messageType, content: m.content,
        mediaUrl: m.mediaUrl, latitude: m.latitude, longitude: m.longitude, isRead: m.isRead, createdAt: m.createdAt,
      })),
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch messages' });
  }
});

module.exports = router;