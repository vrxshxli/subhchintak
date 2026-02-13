const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { authenticate } = require('../middleware/auth');

// ─── GET ALL EMERGENCY CONTACTS ─────────────────────────────────
router.get('/contacts', authenticate, async (req, res) => {
  try {
    const contacts = await prisma.emergencyContact.findMany({
      where: { userId: req.user.id },
      orderBy: { priority: 'asc' },
    });

    res.json({
      success: true,
      contacts: contacts.map((c) => ({
        id: c.id,
        name: c.name,
        phone: c.phone,
        relation: c.relation || '',
        priority: c.priority,
        createdAt: c.createdAt,
      })),
    });
  } catch (error) {
    console.error('Get emergency contacts error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch contacts' });
  }
});

// ─── ADD SINGLE EMERGENCY CONTACT ───────────────────────────────
router.post('/contacts', authenticate, async (req, res) => {
  try {
    const { name, phone, relation, priority } = req.body;

    if (!name || !phone) {
      return res.status(400).json({ success: false, message: 'Name and phone are required' });
    }

    // Check for duplicate phone
    const existing = await prisma.emergencyContact.findFirst({
      where: { userId: req.user.id, phone },
    });

    if (existing) {
      return res.status(409).json({ success: false, message: 'Contact with this phone already exists' });
    }

    // Get the next priority if not provided
    let contactPriority = priority;
    if (contactPriority === undefined || contactPriority === null) {
      const maxPriority = await prisma.emergencyContact.aggregate({
        where: { userId: req.user.id },
        _max: { priority: true },
      });
      contactPriority = (maxPriority._max.priority || 0) + 1;
    }

    const contact = await prisma.emergencyContact.create({
      data: {
        userId: req.user.id,
        name,
        phone,
        relation: relation || '',
        priority: contactPriority,
      },
    });

    res.status(201).json({
      success: true,
      contact: {
        id: contact.id,
        name: contact.name,
        phone: contact.phone,
        relation: contact.relation,
        priority: contact.priority,
        createdAt: contact.createdAt,
      },
    });
  } catch (error) {
    console.error('Add emergency contact error:', error);
    res.status(500).json({ success: false, message: 'Failed to add contact' });
  }
});

// ─── BULK ADD (SYNC FROM DEVICE) ────────────────────────────────
router.post('/contacts/bulk', authenticate, async (req, res) => {
  try {
    const { contacts } = req.body;

    if (!contacts || !Array.isArray(contacts) || contacts.length === 0) {
      return res.status(400).json({ success: false, message: 'Contacts array is required' });
    }

    // Get existing contacts to skip duplicates
    const existingContacts = await prisma.emergencyContact.findMany({
      where: { userId: req.user.id },
      select: { phone: true },
    });
    const existingPhones = new Set(existingContacts.map((c) => c.phone));

    // Get current max priority
    const maxPriority = await prisma.emergencyContact.aggregate({
      where: { userId: req.user.id },
      _max: { priority: true },
    });
    let nextPriority = (maxPriority._max.priority || 0) + 1;

    // Filter out duplicates and prepare new contacts
    const newContacts = [];
    for (const contact of contacts) {
      if (!contact.name || !contact.phone) continue;
      if (existingPhones.has(contact.phone)) continue;

      newContacts.push({
        userId: req.user.id,
        name: contact.name,
        phone: contact.phone,
        relation: contact.relation || '',
        priority: nextPriority++,
      });

      existingPhones.add(contact.phone); // prevent duplicates within batch
    }

    if (newContacts.length === 0) {
      return res.json({
        success: true,
        message: 'All contacts already exist',
        addedCount: 0,
        contacts: [],
      });
    }

    // Bulk insert
    await prisma.emergencyContact.createMany({ data: newContacts });

    // Fetch all contacts after insert to return full list
    const allContacts = await prisma.emergencyContact.findMany({
      where: { userId: req.user.id },
      orderBy: { priority: 'asc' },
    });

    res.status(201).json({
      success: true,
      message: `${newContacts.length} contact(s) added`,
      addedCount: newContacts.length,
      contacts: allContacts.map((c) => ({
        id: c.id,
        name: c.name,
        phone: c.phone,
        relation: c.relation || '',
        priority: c.priority,
        createdAt: c.createdAt,
      })),
    });
  } catch (error) {
    console.error('Bulk add emergency contacts error:', error);
    res.status(500).json({ success: false, message: 'Failed to sync contacts' });
  }
});

// ─── UPDATE CONTACT (relation, priority, name) ──────────────────
router.put('/contacts/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, phone, relation, priority } = req.body;

    // Verify ownership
    const contact = await prisma.emergencyContact.findFirst({
      where: { id, userId: req.user.id },
    });

    if (!contact) {
      return res.status(404).json({ success: false, message: 'Contact not found' });
    }

    const updated = await prisma.emergencyContact.update({
      where: { id },
      data: {
        ...(name && { name }),
        ...(phone && { phone }),
        ...(relation !== undefined && { relation }),
        ...(priority !== undefined && { priority }),
      },
    });

    res.json({
      success: true,
      contact: {
        id: updated.id,
        name: updated.name,
        phone: updated.phone,
        relation: updated.relation,
        priority: updated.priority,
        createdAt: updated.createdAt,
      },
    });
  } catch (error) {
    console.error('Update emergency contact error:', error);
    res.status(500).json({ success: false, message: 'Failed to update contact' });
  }
});

// ─── REORDER CONTACTS ───────────────────────────────────────────
router.put('/contacts/reorder', authenticate, async (req, res) => {
  try {
    const { orderedIds } = req.body;

    if (!orderedIds || !Array.isArray(orderedIds)) {
      return res.status(400).json({ success: false, message: 'orderedIds array is required' });
    }

    // Update priority for each contact
    const updates = orderedIds.map((id, index) =>
      prisma.emergencyContact.updateMany({
        where: { id, userId: req.user.id },
        data: { priority: index + 1 },
      })
    );

    await prisma.$transaction(updates);

    res.json({ success: true, message: 'Contacts reordered' });
  } catch (error) {
    console.error('Reorder emergency contacts error:', error);
    res.status(500).json({ success: false, message: 'Failed to reorder contacts' });
  }
});

// ─── DELETE CONTACT ─────────────────────────────────────────────
router.delete('/contacts/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;

    // Verify ownership
    const contact = await prisma.emergencyContact.findFirst({
      where: { id, userId: req.user.id },
    });

    if (!contact) {
      return res.status(404).json({ success: false, message: 'Contact not found' });
    }

    await prisma.emergencyContact.delete({ where: { id } });

    // Re-sequence priorities
    const remaining = await prisma.emergencyContact.findMany({
      where: { userId: req.user.id },
      orderBy: { priority: 'asc' },
    });

    const reorder = remaining.map((c, i) =>
      prisma.emergencyContact.update({
        where: { id: c.id },
        data: { priority: i + 1 },
      })
    );

    if (reorder.length > 0) {
      await prisma.$transaction(reorder);
    }

    res.json({ success: true, message: 'Contact deleted' });
  } catch (error) {
    console.error('Delete emergency contact error:', error);
    res.status(500).json({ success: false, message: 'Failed to delete contact' });
  }
});

module.exports = router;