const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { authenticate } = require('../middleware/auth_middleware');

router.post('/create-order', authenticate, async (req, res) => {
  try {
    const { qrId, orderType, amount } = req.body;
    const order = await prisma.order.create({
      data: {
        userId: req.user.id, qrCodeId: qrId || null,
        orderType: orderType === 'sticker' ? 'PHYSICAL_STICKER' : 'PDF_DOWNLOAD',
        amount: amount || 235, status: 'PENDING',
      },
    });
    res.status(201).json({ success: true, order: { id: order.id, amount: order.amount, status: order.status, orderType: order.orderType } });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ success: false, message: 'Failed to create order' });
  }
});

router.post('/verify', authenticate, async (req, res) => {
  try {
    const { orderId, paymentId, signature } = req.body;
    const order = await prisma.order.update({
      where: { id: orderId },
      data: { status: 'PAID', paymentId, paymentGateway: 'razorpay' },
    });
    if (order.qrCodeId) {
      await prisma.qRCode.update({ where: { id: order.qrCodeId }, data: { status: 'ACTIVE', activatedAt: new Date() } });
    }
    res.json({ success: true, message: 'Payment verified', order: { id: order.id, status: order.status } });
  } catch (error) {
    console.error('Verify payment error:', error);
    res.status(500).json({ success: false, message: 'Payment verification failed' });
  }
});

module.exports = router;