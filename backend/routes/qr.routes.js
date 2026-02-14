const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { authenticate } = require('../middleware/auth_middleware');
const { v4: uuidv4 } = require('uuid');

const STICKER_PRICE = 99;
const SHIPPING_CHARGE = 49;

const PURPOSE_MAP = {
  'Four-Wheeler': 'FOUR_WHEELER', 'Two-Wheeler': 'TWO_WHEELER',
  'Bag': 'BAG', 'Key': 'KEY', 'Child Safety': 'CHILD',
  'Elderly Care': 'ELDERLY', 'Pet Tag': 'PET', 'Custom': 'CUSTOM',
};

// ─── GENERATE QR (one-time after subscription) ──────────────────
router.post('/generate', authenticate, async (req, res) => {
  try {
    const existing = await prisma.qRCode.findFirst({ where: { userId: req.user.id } });
    if (existing) {
      return res.status(409).json({ success: false, message: 'You already have a QR code',
        qr: { id: existing.id, uniqueCode: existing.uniqueCode, qrDataUrl: existing.qrImageUrl, status: existing.status, activatedAt: existing.activatedAt, expiresAt: existing.expiresAt } });
    }
    const uniqueCode = uuidv4().split('-')[0].toUpperCase();
    const redirectUrl = `${process.env.STRANGER_WEB_URL || 'https://shubhchintak.app'}/scan/${uniqueCode}`;
    const qrCode = await prisma.qRCode.create({
      data: { userId: req.user.id, uniqueCode, purpose: 'CUSTOM', templateType: 'default', qrImageUrl: redirectUrl, status: 'ACTIVE',
        activatedAt: new Date(), expiresAt: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000) },
    });
    res.status(201).json({ success: true, qr: { id: qrCode.id, uniqueCode: qrCode.uniqueCode, qrDataUrl: redirectUrl, status: qrCode.status, activatedAt: qrCode.activatedAt, expiresAt: qrCode.expiresAt, scansCount: 0 } });
  } catch (error) { console.error('Generate QR error:', error); res.status(500).json({ success: false, message: 'Failed to generate QR' }); }
});

// ─── GET USER'S QR ──────────────────────────────────────────────
router.get('/my-qr', authenticate, async (req, res) => {
  try {
    const qr = await prisma.qRCode.findFirst({ where: { userId: req.user.id } });
    if (!qr) return res.json({ success: true, qr: null, hasSubscription: false });
    const isExpired = qr.expiresAt && new Date() > new Date(qr.expiresAt);
    res.json({ success: true, hasSubscription: qr.status === 'ACTIVE' && !isExpired,
      qr: { id: qr.id, uniqueCode: qr.uniqueCode, qrDataUrl: qr.qrImageUrl, status: isExpired ? 'EXPIRED' : qr.status, activatedAt: qr.activatedAt, expiresAt: qr.expiresAt, scansCount: qr.scansCount } });
  } catch (error) { res.status(500).json({ success: false, message: 'Failed to fetch QR' }); }
});

// ─── SAVE TAG DESIGN ────────────────────────────────────────────
router.post('/tags', authenticate, async (req, res) => {
  try {
    const { purpose, customPurpose, templateType, customization } = req.body;
    const qr = await prisma.qRCode.findFirst({ where: { userId: req.user.id, status: 'ACTIVE' } });
    if (!qr) return res.status(403).json({ success: false, message: 'No active subscription' });
    if (!purpose) return res.status(400).json({ success: false, message: 'Purpose is required' });
    const tag = await prisma.tagDesign.create({
      data: { userId: req.user.id, qrCodeId: qr.id, purpose: PURPOSE_MAP[purpose] || 'CUSTOM',
        customPurpose: customPurpose || (PURPOSE_MAP[purpose] ? null : purpose), templateType: templateType || 'blank', customization: customization || {} },
    });
    res.status(201).json({ success: true, tag: { id: tag.id, purpose: tag.purpose, customPurpose: tag.customPurpose,
      templateType: tag.templateType, customization: tag.customization, qrDataUrl: qr.qrImageUrl, createdAt: tag.createdAt } });
  } catch (error) { console.error('Save tag error:', error); res.status(500).json({ success: false, message: 'Failed to save tag' }); }
});

// ─── GET ALL TAGS ───────────────────────────────────────────────
router.get('/tags', authenticate, async (req, res) => {
  try {
    const qr = await prisma.qRCode.findFirst({ where: { userId: req.user.id } });
    if (!qr) return res.json({ success: true, tags: [], qr: null });
    const tags = await prisma.tagDesign.findMany({ where: { userId: req.user.id }, orderBy: { createdAt: 'desc' } });
    res.json({ success: true,
      qr: { id: qr.id, uniqueCode: qr.uniqueCode, qrDataUrl: qr.qrImageUrl, status: qr.status, scansCount: qr.scansCount },
      tags: tags.map(t => ({ id: t.id, purpose: t.purpose, customPurpose: t.customPurpose, templateType: t.templateType, customization: t.customization, thumbnailUrl: t.thumbnailUrl, qrDataUrl: qr.qrImageUrl, createdAt: t.createdAt })) });
  } catch (error) { res.status(500).json({ success: false, message: 'Failed to fetch tags' }); }
});

// ─── DELETE TAG ──────────────────────────────────────────────────
router.delete('/tags/:id', authenticate, async (req, res) => {
  try {
    const tag = await prisma.tagDesign.findFirst({ where: { id: req.params.id, userId: req.user.id } });
    if (!tag) return res.status(404).json({ success: false, message: 'Tag not found' });
    await prisma.tagDesign.delete({ where: { id: req.params.id } });
    res.json({ success: true });
  } catch (error) { res.status(500).json({ success: false, message: 'Failed to delete tag' }); }
});

// ─── ADDRESSES ──────────────────────────────────────────────────
router.get('/addresses', authenticate, async (req, res) => {
  try {
    const addresses = await prisma.address.findMany({ where: { userId: req.user.id }, orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }] });
    res.json({ success: true, addresses });
  } catch (error) { res.status(500).json({ success: false, message: 'Failed to fetch addresses' }); }
});

router.post('/addresses', authenticate, async (req, res) => {
  try {
    const { fullName, phone, pincode, city, state, addressLine1, addressLine2, landmark, isDefault, latitude, longitude } = req.body;
    if (!fullName || !phone || !pincode || !city || !state || !addressLine1) return res.status(400).json({ success: false, message: 'Required fields missing' });
    if (isDefault) await prisma.address.updateMany({ where: { userId: req.user.id }, data: { isDefault: false } });
    const address = await prisma.address.create({ data: { userId: req.user.id, fullName, phone, pincode, city, state, addressLine1, addressLine2, landmark, isDefault: isDefault || false, latitude, longitude } });
    res.status(201).json({ success: true, address });
  } catch (error) { console.error('Save address error:', error); res.status(500).json({ success: false, message: 'Failed to save address' }); }
});

router.put('/addresses/:id', authenticate, async (req, res) => {
  try {
    const addr = await prisma.address.findFirst({ where: { id: req.params.id, userId: req.user.id } });
    if (!addr) return res.status(404).json({ success: false, message: 'Address not found' });
    if (req.body.isDefault) await prisma.address.updateMany({ where: { userId: req.user.id }, data: { isDefault: false } });
    const updated = await prisma.address.update({ where: { id: req.params.id }, data: req.body });
    res.json({ success: true, address: updated });
  } catch (error) { res.status(500).json({ success: false, message: 'Failed to update address' }); }
});

router.delete('/addresses/:id', authenticate, async (req, res) => {
  try {
    await prisma.address.delete({ where: { id: req.params.id } });
    res.json({ success: true });
  } catch (error) { res.status(500).json({ success: false, message: 'Failed to delete address' }); }
});

// ─── STICKER ORDERS ─────────────────────────────────────────────
router.post('/sticker-order', authenticate, async (req, res) => {
  try {
    const { addressId, items } = req.body; // items: [{ tagDesignId, quantity }]
    if (!addressId || !items || !items.length) return res.status(400).json({ success: false, message: 'Address and items required' });
    const subtotal = items.reduce((sum, i) => sum + (i.quantity * STICKER_PRICE), 0);
    const totalAmount = subtotal + SHIPPING_CHARGE;
    const order = await prisma.stickerOrder.create({
      data: { userId: req.user.id, addressId, subtotal, shippingCharge: SHIPPING_CHARGE, totalAmount, status: 'PENDING',
        items: { create: items.map(i => ({ tagDesignId: i.tagDesignId, quantity: i.quantity, pricePerUnit: STICKER_PRICE })) } },
      include: { items: true },
    });
    res.status(201).json({ success: true, order: { id: order.id, subtotal: order.subtotal, shippingCharge: order.shippingCharge, totalAmount: order.totalAmount, status: order.status, items: order.items } });
  } catch (error) { console.error('Sticker order error:', error); res.status(500).json({ success: false, message: 'Failed to create order' }); }
});

router.post('/sticker-order/:id/pay', authenticate, async (req, res) => {
  try {
    const { paymentId } = req.body;
    const order = await prisma.stickerOrder.update({ where: { id: req.params.id }, data: { status: 'PAID', paymentId } });
    res.json({ success: true, order: { id: order.id, status: order.status } });
  } catch (error) { res.status(500).json({ success: false, message: 'Payment failed' }); }
});

router.get('/sticker-orders', authenticate, async (req, res) => {
  try {
    const orders = await prisma.stickerOrder.findMany({ where: { userId: req.user.id }, orderBy: { createdAt: 'desc' }, include: { items: { include: { tagDesign: true } }, address: true } });
    res.json({ success: true, orders });
  } catch (error) { res.status(500).json({ success: false, message: 'Failed to fetch orders' }); }
});

// ─── SCAN (public) ──────────────────────────────────────────────
router.get('/scan/:code', async (req, res) => {
  try {
    const qr = await prisma.qRCode.findUnique({ where: { uniqueCode: req.params.code }, include: { user: { select: { id: true, name: true } } } });
    if (!qr) return res.status(404).json({ success: false, message: 'QR not found' });
    if (qr.status !== 'ACTIVE') return res.json({ success: false, message: 'QR inactive', status: qr.status });
    if (qr.expiresAt && new Date() > new Date(qr.expiresAt)) return res.json({ success: false, message: 'Subscription expired' });
    await prisma.qRCode.update({ where: { uniqueCode: req.params.code }, data: { scansCount: { increment: 1 } } });
    await prisma.scanLog.create({ data: { qrCodeId: qr.id, scannerIp: req.ip, userAgent: req.headers['user-agent'] } });
    res.json({ success: true, qr: { id: qr.id, ownerId: qr.userId, ownerName: qr.user.name.split(' ')[0] } });
  } catch (error) { res.status(500).json({ success: false, message: 'Scan failed' }); }
});

// ─── LEGACY ─────────────────────────────────────────────────────
router.get('/my-qrs', authenticate, async (req, res) => {
  try {
    const qr = await prisma.qRCode.findFirst({ where: { userId: req.user.id } });
    const tags = await prisma.tagDesign.findMany({ where: { userId: req.user.id }, orderBy: { createdAt: 'desc' } });
    res.json({ success: true, qrCodes: qr ? [{ id: qr.id, uniqueCode: qr.uniqueCode, status: qr.status, qrDataUrl: qr.qrImageUrl, scansCount: qr.scansCount, activatedAt: qr.activatedAt, expiresAt: qr.expiresAt, createdAt: qr.createdAt }] : [],
      tags: tags.map(t => ({ id: t.id, purpose: t.purpose, customPurpose: t.customPurpose, templateType: t.templateType, customization: t.customization, qrDataUrl: qr?.qrImageUrl, createdAt: t.createdAt })) });
  } catch (error) { res.status(500).json({ success: false, message: 'Failed' }); }
});

module.exports = router;