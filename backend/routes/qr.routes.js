const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { authenticate } = require('../middleware/auth_middleware');
const { v4: uuidv4 } = require('uuid');

// ─── CREATE QR CODE ─────────────────────────────────────────────
router.post('/create', authenticate, async (req, res) => {
  try {
    const { purpose, templateType, customization, customPurpose } = req.body;

    if (!purpose) {
      return res.status(400).json({ success: false, message: 'Purpose is required' });
    }

    const uniqueCode = uuidv4().split('-')[0].toUpperCase();
    const redirectUrl = `${process.env.STRANGER_WEB_URL || 'https://shubhchintak.app'}/scan/${uniqueCode}`;

    const purposeMap = {
      'Four-Wheeler': 'FOUR_WHEELER', 'Two-Wheeler': 'TWO_WHEELER',
      'Bag': 'BAG', 'Key': 'KEY', 'Child Safety': 'CHILD',
      'Elderly Care': 'ELDERLY', 'Pet Tag': 'PET', 'Custom': 'CUSTOM',
    };

    const qrCode = await prisma.qRCode.create({
      data: {
        userId: req.user.id,
        uniqueCode,
        purpose: purposeMap[purpose] || 'CUSTOM',
        customPurpose: customPurpose || (purposeMap[purpose] ? null : purpose),
        templateType: templateType || 'blank',
        customization: customization || {},
        qrImageUrl: redirectUrl,
        status: 'INACTIVE',
      },
    });

    res.status(201).json({
      success: true,
      qr: {
        id: qrCode.id, uniqueCode: qrCode.uniqueCode, purpose: qrCode.purpose,
        customPurpose: qrCode.customPurpose, templateType: qrCode.templateType,
        status: qrCode.status, qrDataUrl: redirectUrl, customization: qrCode.customization,
        scansCount: qrCode.scansCount, createdAt: qrCode.createdAt,
      },
    });
  } catch (error) {
    console.error('Create QR error:', error);
    res.status(500).json({ success: false, message: 'Failed to create QR code' });
  }
});

// ─── GET USER'S QR CODES ────────────────────────────────────────
router.get('/my-qrs', authenticate, async (req, res) => {
  try {
    const qrCodes = await prisma.qRCode.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' },
    });

    res.json({
      success: true,
      qrCodes: qrCodes.map((qr) => ({
        id: qr.id, uniqueCode: qr.uniqueCode, purpose: qr.purpose,
        customPurpose: qr.customPurpose, templateType: qr.templateType,
        status: qr.status, qrDataUrl: qr.qrImageUrl, customization: qr.customization,
        scansCount: qr.scansCount, activatedAt: qr.activatedAt, createdAt: qr.createdAt,
      })),
    });
  } catch (error) {
    console.error('Get QRs error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch QR codes' });
  }
});

// ─── ACTIVATE QR (after payment) ────────────────────────────────
router.post('/activate', authenticate, async (req, res) => {
  try {
    const { qrId, paymentId } = req.body;

    if (!qrId) {
      return res.status(400).json({ success: false, message: 'QR ID is required' });
    }

    const qrCode = await prisma.qRCode.findFirst({
      where: { id: qrId, userId: req.user.id },
    });

    if (!qrCode) {
      return res.status(404).json({ success: false, message: 'QR code not found' });
    }

    const updated = await prisma.qRCode.update({
      where: { id: qrId },
      data: { status: 'ACTIVE', activatedAt: new Date() },
    });

    res.json({
      success: true, message: 'QR code activated successfully',
      qr: { id: updated.id, uniqueCode: updated.uniqueCode, status: updated.status, activatedAt: updated.activatedAt },
    });
  } catch (error) {
    console.error('Activate QR error:', error);
    res.status(500).json({ success: false, message: 'Failed to activate QR code' });
  }
});

// ─── UPDATE QR DESIGN (re-design) ───────────────────────────────
router.put('/update/:id', authenticate, async (req, res) => {
  try {
    const { id } = req.params;
    const { templateType, customization, purpose, customPurpose } = req.body;

    const qrCode = await prisma.qRCode.findFirst({ where: { id, userId: req.user.id } });
    if (!qrCode) {
      return res.status(404).json({ success: false, message: 'QR code not found' });
    }

    const purposeMap = {
      'Four-Wheeler': 'FOUR_WHEELER', 'Two-Wheeler': 'TWO_WHEELER',
      'Bag': 'BAG', 'Key': 'KEY', 'Child Safety': 'CHILD',
      'Elderly Care': 'ELDERLY', 'Pet Tag': 'PET', 'Custom': 'CUSTOM',
    };

    const updated = await prisma.qRCode.update({
      where: { id },
      data: {
        ...(templateType && { templateType }),
        ...(customization && { customization }),
        ...(purpose && { purpose: purposeMap[purpose] || qrCode.purpose }),
        ...(customPurpose !== undefined && { customPurpose }),
      },
    });

    res.json({
      success: true,
      qr: {
        id: updated.id, uniqueCode: updated.uniqueCode, purpose: updated.purpose,
        customPurpose: updated.customPurpose, templateType: updated.templateType,
        status: updated.status, qrDataUrl: updated.qrImageUrl, customization: updated.customization,
        createdAt: updated.createdAt,
      },
    });
  } catch (error) {
    console.error('Update QR error:', error);
    res.status(500).json({ success: false, message: 'Failed to update QR code' });
  }
});

// ─── SCAN QR (public, no auth) ──────────────────────────────────
router.get('/scan/:code', async (req, res) => {
  try {
    const { code } = req.params;

    const qrCode = await prisma.qRCode.findUnique({
      where: { uniqueCode: code },
      include: { user: { select: { id: true, name: true } } },
    });

    if (!qrCode) {
      return res.status(404).json({ success: false, message: 'QR code not found' });
    }

    if (qrCode.status !== 'ACTIVE') {
      return res.json({ success: false, message: 'This QR code is currently inactive', status: qrCode.status });
    }

    await prisma.qRCode.update({
      where: { uniqueCode: code },
      data: { scansCount: { increment: 1 } },
    });

    await prisma.scanLog.create({
      data: { qrCodeId: qrCode.id, scannerIp: req.ip, userAgent: req.headers['user-agent'] },
    });

    res.json({
      success: true,
      qr: { id: qrCode.id, purpose: qrCode.purpose, customPurpose: qrCode.customPurpose,
        ownerId: qrCode.userId, ownerName: qrCode.user.name.split(' ')[0] },
    });
  } catch (error) {
    console.error('Scan QR error:', error);
    res.status(500).json({ success: false, message: 'Failed to process scan' });
  }
});

module.exports = router;