const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const { authenticate } = require('../middleware/auth_middleware');

const prisma = new PrismaClient();

// GET /api/emergency/contacts
router.get('/contacts', authenticate, async (req, res) => {
  try {
    const contacts = await prisma.emergencyContact.findMany({
      where: { userId: req.user.id },
      orderBy: { priority: 'asc' },
    });
    res.json({ success: true, contacts });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch contacts' });
  }
});

// POST /api/emergency/contacts
router.post('/contacts', authenticate, async (req, res) => {
  try {
    const { name, phone, relation, priority } = req.body;

    const contact = await prisma.emergencyContact.create({
      data: {
        userId: req.user.id,
        name,
        phone,
        relation,
        priority: priority || 1,
      },
    });

    res.status(201).json({ success: true, contact });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to add contact' });
  }
});

// PUT /api/emergency/contacts/:id
router.put('/contacts/:id', authenticate, async (req, res) => {
  try {
    const { name, phone, relation, priority } = req.body;

    const contact = await prisma.emergencyContact.updateMany({
      where: { id: req.params.id, userId: req.user.id },
      data: { name, phone, relation, priority },
    });

    res.json({ success: true, contact });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to update contact' });
  }
});

// DELETE /api/emergency/contacts/:id
router.delete('/contacts/:id', authenticate, async (req, res) => {
  try {
    await prisma.emergencyContact.deleteMany({
      where: { id: req.params.id, userId: req.user.id },
    });
    res.json({ success: true, message: 'Contact removed' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to delete contact' });
  }
});

// POST /api/emergency/reorder
router.post('/reorder', authenticate, async (req, res) => {
  try {
    const { orderedIds } = req.body; // Array of contact IDs in new order
    const updates = orderedIds.map((id, index) =>
      prisma.emergencyContact.updateMany({
        where: { id, userId: req.user.id },
        data: { priority: index + 1 },
      })
    );
    await prisma.$transaction(updates);
    res.json({ success: true, message: 'Order updated' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to reorder' });
  }
});

module.exports = router;