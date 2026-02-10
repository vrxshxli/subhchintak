const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const { authenticate } = require('../middleware/auth_middleware');

const prisma = new PrismaClient();

// NOTE: In production, add admin role check middleware

// GET /api/admin/dashboard
router.get('/dashboard', authenticate, async (req, res) => {
  try {
    const [totalUsers, totalQRs, totalScans, totalOrders, totalRevenue, callLogs, purposeDistribution] =
      await Promise.all([
        prisma.user.count(),
        prisma.qRCode.count(),
        prisma.scanLog.count(),
        prisma.order.count({ where: { status: 'PAID' } }),
        prisma.order.aggregate({ where: { status: 'PAID' }, _sum: { amount: true } }),
        prisma.callLog.groupBy({ by: ['status'], _count: true }),
        prisma.qRCode.groupBy({ by: ['purpose'], _count: true }),
      ]);

    res.json({
      success: true,
      dashboard: {
        totalUsers,
        totalQRs,
        totalScans,
        totalOrders,
        totalRevenue: totalRevenue._sum.amount || 0,
        callStats: callLogs.reduce((acc, c) => ({ ...acc, [c.status]: c._count }), {}),
        purposeDistribution: purposeDistribution.reduce((acc, p) => ({ ...acc, [p.purpose]: p._count }), {}),
      },
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ success: false, message: 'Failed to load dashboard' });
  }
});

// GET /api/admin/users
router.get('/users', authenticate, async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      select: {
        id: true, name: true, email: true, phone: true, createdAt: true,
        _count: { select: { qrCodes: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
    res.json({ success: true, users });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch users' });
  }
});

// GET /api/admin/orders
router.get('/orders', authenticate, async (req, res) => {
  try {
    const orders = await prisma.order.findMany({
      include: { user: { select: { name: true, email: true } } },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
    res.json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch orders' });
  }
});

// GET /api/admin/call-logs
router.get('/call-logs', authenticate, async (req, res) => {
  try {
    const logs = await prisma.callLog.findMany({
      include: {
        owner: { select: { name: true } },
        qrCode: { select: { purpose: true, customPurpose: true } },
      },
      orderBy: { startedAt: 'desc' },
      take: 100,
    });
    res.json({ success: true, logs });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch call logs' });
  }
});

module.exports = router;