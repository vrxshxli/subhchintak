const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const { authenticate } = require('../middleware/auth_middleware');
const { v4: uuidv4 } = require('uuid');

const prisma = new PrismaClient();

// POST /api/payment/create-order
router.post('/create-order', authenticate, async (req, res) => {
  try {
    const { qrId, orderType, amount } = req.body;

    const order = await prisma.order.create({
      data: {
        userId: req.user.id,
        qrCodeId: qrId,
        orderType: orderType === 'physical' ? 'PHYSICAL_STICKER' : 'PDF_DOWNLOAD',
        amount,
        paymentGateway: 'razorpay',
      },
    });

    // In production, create a Razorpay order here
    // const razorpayOrder = await razorpay.orders.create({...});

    res.status(201).json({
      success: true,
      order: {
        id: order.id,
        amount: order.amount,
        currency: order.currency,
        // razorpayOrderId: razorpayOrder.id, // production
      },
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ success: false, message: 'Failed to create order' });
  }
});

// POST /api/payment/verify
router.post('/verify', authenticate, async (req, res) => {
  try {
    const { orderId, paymentId, signature } = req.body;

    // In production, verify Razorpay signature here
    // const isValid = verifyRazorpaySignature(orderId, paymentId, signature);

    const order = await prisma.order.update({
      where: { id: orderId },
      data: {
        status: 'PAID',
        paymentId,
      },
    });

    // Activate the QR code
    if (order.qrCodeId) {
      await prisma.qRCode.update({
        where: { id: order.qrCodeId },
        data: {
          status: 'ACTIVE',
          activatedAt: new Date(),
          expiresAt: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
        },
      });
    }

    // Create notification
    await prisma.notification.create({
      data: {
        userId: req.user.id,
        type: 'PAYMENT_SUCCESS',
        title: 'Payment Successful',
        body: `Your QR code has been activated. Order #${order.id.slice(0, 8)}`,
      },
    });

    res.json({ success: true, order });
  } catch (error) {
    console.error('Verify payment error:', error);
    res.status(500).json({ success: false, message: 'Payment verification failed' });
  }
});

module.exports = router;