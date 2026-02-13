const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

router.get('/dashboard', async (req, res) => {
  try {
    const [userCount, qrCount, scanCount, callCount] = await Promise.all([
      prisma.user.count(), prisma.qRCode.count(), prisma.scanLog.count(), prisma.callLog.count(),
    ]);
    res.json({ success: true, stats: { users: userCount, qrCodes: qrCount, totalScans: scanCount, totalCalls: callCount } });
  } catch (error) {
    console.error('Admin dashboard error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch stats' });
  }
});

router.get('/users', async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
      select: { id: true, name: true, email: true, phone: true, isVerified: true, createdAt: true, _count: { select: { qrCodes: true } } },
    });
    res.json({ success: true, users });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Failed to fetch users' });
  }
});

module.exports = router;