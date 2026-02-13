const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { authenticate } = require('../middleware/auth_middleware');
const { v4: uuidv4 } = require('uuid');

// ─── GENERATE THE USER'S QR (one-time, after payment) ──────────
router.post('/generate', authenticate, async (req, res) => {
  try {
    // Check if user already has a QR
    const existing = await prisma.qRCode.findFirst({
      where: { userId: req.user.id },
    });

    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'You already have a QR code',
        qr: {
          id: existing.id, uniqueCode: existing.uniqueCode,
          qrDataUrl: existing.qrImageUrl, status: existing.status,
          activatedAt: existing.activatedAt, expiresAt: existing.expiresAt,
        },
      });
    }

    const uniqueCode = uuidv4().split('-')[0].toUpperCase();
    const redirectUrl = `${process.env.STRANGER_WEB_URL || 'https://shubhchintak.app'}/scan/${uniqueCode}`;

    // Create the one QR linked to this user
    const qrCode = await prisma.qRCode.create({
      data: {
        userId: req.user.id,
        uniqueCode,
        purpose: 'CUSTOM',
        templateType: 'default',
        qrImageUrl: redirectUrl,
        status: 'ACTIVE',
        activatedAt: new Date(),
        expiresAt: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
      },
    });

    res.status(201).json({
      success: true,
      qr: {
        id: qrCode.id, uniqueCode: qrCode.uniqueCode,
        qrDataUrl: redirectUrl, status: qrCode.status,
        activatedAt: qrCode.activatedAt, expiresAt: qrCode.expiresAt,
      },
    });
  } catch (error) {
    console.error('Generate QR error:', error);
    res.status(500).json({ success: false, message: 'Failed to generate QR code' });
  }
});

// ─── GET USER'S QR CODE ─────────────────────────────────────────
router.get('/my-qr', authenticate, async (req, res) => {
  try {
    const qrCode = await prisma.qRCode.findFirst({
      where: { userId: req.user.id },
    });

    if (!qrCode) {
      return res.json({ success: true, qr: null, hasSubscription: false });
    }

    const isExpired = qrCode.expiresAt && new Date() > new Date(qrCode.expiresAt);

    res.json({
      success: true,
      hasSubscription: qrCode.status === 'ACTIVE' && !isExpired,
      qr: {
        id: qrCode.id, uniqueCode: qrCode.uniqueCode,
        qrDataUrl: qrCode.qrImageUrl, status: isExpired ? 'EXPIRED' : qrCode.status,
        activatedAt: qrCode.activatedAt, expiresAt: qrCode.expiresAt,
        scansCount: qrCode.scansCount,
      },
    });
  } catch (error) {
    console.error('Get QR error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch QR' });
  }
});

// ─── SAVE A TAG DESIGN (multiple designs for the same QR) ───────
router.post('/tags', authenticate, async (req, res) => {
  try {
    const { purpose, customPurpose, templateType, customization } = req.body;

    // User must have an active QR
    const qrCode = await prisma.qRCode.findFirst({
      where: { userId: req.user.id, status: 'ACTIVE' },
    });

    if (!qrCode) {
      return res.status(403).json({ success: false, message: 'No active subscription. Please subscribe first.' });
    }

    if (!purpose) {
      return res.status(400).json({ success: false, message: 'Purpose is required' });
    }

    const purposeMap = {
      'Four-Wheeler': 'FOUR_WHEELER', 'Two-Wheeler': 'TWO_WHEELER',
      'Bag': 'BAG', 'Key': 'KEY', 'Child Safety': 'CHILD',
      'Elderly Care': 'ELDERLY', 'Pet Tag': 'PET', 'Custom': 'CUSTOM',
    };

    const tag = await prisma.tagDesign.create({
      data: {
        userId: req.user.id,
        qrCodeId: qrCode.id,
        purpose: purposeMap[purpose] || 'CUSTOM',
        customPurpose: customPurpose || (purposeMap[purpose] ? null : purpose),
        templateType: templateType || 'blank',
        customization: customization || {},
      },
    });

    res.status(201).json({
      success: true,
      tag: {
        id: tag.id, purpose: tag.purpose, customPurpose: tag.customPurpose,
        templateType: tag.templateType, customization: tag.customization,
        qrDataUrl: qrCode.qrImageUrl, createdAt: tag.createdAt,
      },
    });
  } catch (error) {
    console.error('Save tag design error:', error);
    res.status(500).json({ success: false, message: 'Failed to save tag design' });
  }
});

// ─── GET ALL TAG DESIGNS ────────────────────────────────────────
router.get('/tags', authenticate, async (req, res) => {
  try {
    const qrCode = await prisma.qRCode.findFirst({
      where: { userId: req.user.id },
    });

    if (!qrCode) {
      return res.json({ success: true, tags: [], qr: null });
    }

    const tags = await prisma.tagDesign.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' },
    });

    res.json({
      success: true,
      qr: {
        id: qrCode.id, uniqueCode: qrCode.uniqueCode,
        qrDataUrl: qrCode.qrImageUrl, status: qrCode.status,
        scansCount: qrCode.scansCount,
      },
      tags: tags.map((t) => ({
        id: t.id, purpose: t.purpose, customPurpose: t.customPurpose,
        templateType: t.templateType, customization: t.customization,
        qrDataUrl: qrCode.qrImageUrl, createdAt: t.createdAt,
      })),
    });
  } catch (error) {
    console.error('Get tags error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch tags' });
  }
});

// ─── DELETE A TAG DESIGN ────────────────────────────────────────
router.delete('/tags/:id', authenticate, async (req, res) => {
  try {
    const tag = await prisma.tagDesign.findFirst({
      where: { id: req.params.id, userId: req.user.id },
    });
    if (!tag) return res.status(404).json({ success: false, message: 'Tag not found' });

    await prisma.tagDesign.delete({ where: { id: req.params.id } });
    res.json({ success: true, message: 'Tag deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to delete tag' });
  }
});

// ─── SCAN QR (stranger side — public) ───────────────────────────
router.get('/scan/:code', async (req, res) => {
  try {
    const { code } = req.params;
    const qrCode = await prisma.qRCode.findUnique({
      where: { uniqueCode: code },
      include: { user: { select: { id: true, name: true } } },
    });

    if (!qrCode) return res.status(404).json({ success: false, message: 'QR code not found' });

    if (qrCode.status !== 'ACTIVE') {
      return res.json({ success: false, message: 'This QR code is currently inactive', status: qrCode.status });
    }

    const isExpired = qrCode.expiresAt && new Date() > new Date(qrCode.expiresAt);
    if (isExpired) {
      return res.json({ success: false, message: 'This QR subscription has expired' });
    }

    await prisma.qRCode.update({ where: { uniqueCode: code }, data: { scansCount: { increment: 1 } } });
    await prisma.scanLog.create({ data: { qrCodeId: qrCode.id, scannerIp: req.ip, userAgent: req.headers['user-agent'] } });

    res.json({
      success: true,
      qr: { id: qrCode.id, ownerId: qrCode.userId, ownerName: qrCode.user.name.split(' ')[0] },
    });
  } catch (error) {
    console.error('Scan QR error:', error);
    res.status(500).json({ success: false, message: 'Failed to process scan' });
  }
});

// ─── LEGACY: keep /my-qrs for backward compat ──────────────────
router.get('/my-qrs', authenticate, async (req, res) => {
  try {
    const qrCode = await prisma.qRCode.findFirst({ where: { userId: req.user.id } });
    const tags = await prisma.tagDesign.findMany({ where: { userId: req.user.id }, orderBy: { createdAt: 'desc' } });

    res.json({
      success: true,
      qrCodes: qrCode ? [{
        id: qrCode.id, uniqueCode: qrCode.uniqueCode, purpose: 'MASTER', status: qrCode.status,
        qrDataUrl: qrCode.qrImageUrl, scansCount: qrCode.scansCount, activatedAt: qrCode.activatedAt,
        expiresAt: qrCode.expiresAt, createdAt: qrCode.createdAt,
      }] : [],
      tags: tags.map((t) => ({
        id: t.id, purpose: t.purpose, customPurpose: t.customPurpose, templateType: t.templateType,
        customization: t.customization, qrDataUrl: qrCode?.qrImageUrl, createdAt: t.createdAt,
      })),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch QR data' });
  }
});

module.exports = router;