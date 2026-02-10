const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const { authenticate } = require('../middleware/auth_middleware');

const prisma = new PrismaClient();

// GET /api/chat/sessions
router.get('/sessions', authenticate, async (req, res) => {
  try {
    const sessions = await prisma.chatSession.findMany({
      where: { ownerId: req.user.id },
      include: {
        qrCode: { select: { purpose: true, customPurpose: true } },
        messages: { take: 1, orderBy: { createdAt: 'desc' } },
        _count: { select: { messages: true } },
      },
      orderBy: { updatedAt: 'desc' },
    });
    res.json({ success: true, sessions });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch sessions' });
  }
});

// GET /api/chat/messages/:sessionId
router.get('/messages/:sessionId', authenticate, async (req, res) => {
  try {
    const session = await prisma.chatSession.findFirst({
      where: { id: req.params.sessionId, ownerId: req.user.id },
    });

    if (!session) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }

    const messages = await prisma.chatMessage.findMany({
      where: { sessionId: req.params.sessionId },
      orderBy: { createdAt: 'asc' },
    });

    res.json({ success: true, messages });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch messages' });
  }
});

// POST /api/chat/send (owner sending)
router.post('/send', authenticate, async (req, res) => {
  try {
    const { sessionId, content, messageType } = req.body;

    const session = await prisma.chatSession.findFirst({
      where: { id: sessionId, ownerId: req.user.id },
    });

    if (!session) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }

    const message = await prisma.chatMessage.create({
      data: {
        sessionId,
        senderType: 'owner',
        messageType: messageType || 'TEXT',
        content,
      },
    });

    // Emit to stranger via socket
    const io = req.app.get('io');
    io.to(sessionId).emit('new_message', message);

    res.status(201).json({ success: true, message });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to send message' });
  }
});

// POST /api/chat/stranger/send (stranger sending - uses token)
router.post('/stranger/send', async (req, res) => {
  try {
    const { strangerToken, content, messageType, latitude, longitude } = req.body;

    const session = await prisma.chatSession.findUnique({
      where: { strangerToken },
    });

    if (!session || !session.isActive) {
      return res.status(404).json({ success: false, message: 'Invalid or expired session' });
    }

    const message = await prisma.chatMessage.create({
      data: {
        sessionId: session.id,
        senderType: 'stranger',
        messageType: messageType || 'TEXT',
        content,
        latitude,
        longitude,
      },
    });

    const io = req.app.get('io');
    io.to(session.id).emit('new_message', message);

    res.status(201).json({ success: true, message });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to send message' });
  }
});

module.exports = router;