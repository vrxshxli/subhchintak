const express = require('express');
const router = express.Router();
const QRCode = require('qrcode');
const { PrismaClient } = require('@prisma/client');
const { authenticate } = require('../middleware/auth_middleware');

const prisma = new PrismaClient();

const PURPOSE_MAP = {
  'Four-Wheeler': 'FOUR_WHEELER',
  'Two-Wheeler': 'TWO_WHEELER',
  'Bag': 'BAG',
  'Key': 'KEY',
  'Child Safety': 'CHILD',
  'Elderly Care': 'ELDERLY',
  'Pet Tag': 'PET',
  'Custom': 'CUSTOM',
};

// POST /api/qr/create
router.post('/create', authenticate, async (req, res) => {
  try {
    const { purpose, templateType, customization } = req.body;

    const qr = await prisma.qRCode.create({
      data: {
        userId: req.user.id,
        purpose: PURPOSE_MAP[templateType] || 'CUSTOM',
        customPurpose: purpose,
        templateType,
        customization: customization || {},
      },
    });

    // Generate QR code image data URL
    const scanUrl = `${process.env.APP_URL || 'http://localhost:3000'}/scan/${qr.uniqueCode}`;
    const qrDataUrl = await QRCode.toDataURL(scanUrl, {
      width: 400,
      margin: 2,
      color: { dark: '#1B2838', light: '#FFFFFF' },
    });

    // Update with QR image
    await prisma.qRCode.update({
      where: { id: qr.id },
      data: { qrImageUrl: qrDataUrl },
    });

    res.status(201).json({
      success: true,
      qr: { ...qr, qrImageUrl: qrDataUrl, scanUrl },
    });
  } catch (error) {
    console.error('QR create error:', error);
    res.status(500).json({ success: false, message: 'Failed to create QR' });
  }
});

// GET /api/qr/my-qrs
router.get('/my-qrs', authenticate, async (req, res) => {
  try {
    const qrCodes = await prisma.qRCode.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' },
      include: { _count: { select: { scanLogs: true, callLogs: true } } },
    });

    res.json({ success: true, qrCodes });
  } catch (error) {
    console.error('Get QRs error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch QR codes' });
  }
});

// POST /api/qr/activate
router.post('/activate', authenticate, async (req, res) => {
  try {
    const { qrId, paymentId } = req.body;

    const qr = await prisma.qRCode.findFirst({
      where: { id: qrId, userId: req.user.id },
    });

    if (!qr) {
      return res.status(404).json({ success: false, message: 'QR not found' });
    }

    const updated = await prisma.qRCode.update({
      where: { id: qrId },
      data: {
        status: 'ACTIVE',
        activatedAt: new Date(),
        expiresAt: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
      },
    });

    res.json({ success: true, qr: updated });
  } catch (error) {
    console.error('Activate error:', error);
    res.status(500).json({ success: false, message: 'Failed to activate QR' });
  }
});

// GET /api/qr/scan/:code (Public - Stranger scans QR)
router.get('/scan/:code', async (req, res) => {
  try {
    const qr = await prisma.qRCode.findUnique({
      where: { uniqueCode: req.params.code },
      include: { user: { select: { id: true, name: true } } },
    });

    if (!qr || qr.status !== 'ACTIVE') {
      return res.status(404).json({ success: false, message: 'QR code not found or inactive' });
    }

    // Log scan
    await prisma.scanLog.create({
      data: {
        qrCodeId: qr.id,
        scannerIp: req.ip,
        userAgent: req.headers['user-agent'],
      },
    });

    // Increment scan count
    await prisma.qRCode.update({
      where: { id: qr.id },
      data: { scansCount: { increment: 1 } },
    });

    // Create chat session
    const session = await prisma.chatSession.create({
      data: { qrCodeId: qr.id, ownerId: qr.userId },
    });

    // Notify owner via socket
    const io = req.app.get('io');
    io.emit(`qr_scanned_${qr.userId}`, {
      qrId: qr.id,
      sessionId: session.id,
      purpose: qr.customPurpose || qr.purpose,
    });

    res.json({
      success: true,
      sessionId: session.id,
      strangerToken: session.strangerToken,
      purpose: qr.customPurpose || qr.purpose,
    });
  } catch (error) {
    console.error('Scan error:', error);
    res.status(500).json({ success: false, message: 'Scan processing failed' });
  }
});

module.exports = router;