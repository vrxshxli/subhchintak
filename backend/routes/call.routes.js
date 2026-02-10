const express = require('express');
const Call = require('../models/Call');

const router = express.Router();

// ─── Initiate Call ─────────────────────────────────────────────────────────
router.post('/initiate', async (req, res) => {
  try {
    const { qrId, callerId, calleeId } = req.body;

    const call = new Call({
      qrId,
      callerId,
      calleeId,
      status: 'ringing',
    });

    await call.save();

    // Emit to socket room
    const io = req.app.get('io');
    io.to(qrId).emit('incoming_call', {
      callId: call._id,
      callerId,
      qrId,
    });

    res.json({ message: 'Call initiated', callId: call._id });
  } catch (error) {
    console.error('[Call] Initiate error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// ─── Accept Call ───────────────────────────────────────────────────────────
router.put('/:callId/accept', async (req, res) => {
  try {
    const { callId } = req.params;
    const call = await Call.findByIdAndUpdate(callId, { status: 'connected' }, { new: true });

    if (!call) {
      return res.status(404).json({ error: 'Call not found' });
    }

    // Emit to socket room
    const io = req.app.get('io');
    io.to(call.qrId).emit('call_connected', { callId, qrId: call.qrId });

    res.json({ message: 'Call accepted' });
  } catch (error) {
    console.error('[Call] Accept error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// ─── Decline Call ──────────────────────────────────────────────────────────
router.put('/:callId/decline', async (req, res) => {
  try {
    const { callId } = req.params;
    const call = await Call.findByIdAndUpdate(callId, { status: 'declined' }, { new: true });

    if (!call) {
      return res.status(404).json({ error: 'Call not found' });
    }

    // Emit to socket room
    const io = req.app.get('io');
    io.to(call.qrId).emit('call_declined', { callId, qrId: call.qrId });

    res.json({ message: 'Call declined' });
  } catch (error) {
    console.error('[Call] Decline error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// ─── End Call ──────────────────────────────────────────────────────────────
router.put('/:callId/end', async (req, res) => {
  try {
    const { callId } = req.params;
    const call = await Call.findByIdAndUpdate(callId, { status: 'ended', endTime: new Date() }, { new: true });

    if (!call) {
      return res.status(404).json({ error: 'Call not found' });
    }

    // Emit to socket room
    const io = req.app.get('io');
    io.to(call.qrId).emit('call_ended', { callId, qrId: call.qrId });

    res.json({ message: 'Call ended' });
  } catch (error) {
    console.error('[Call] End error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// ─── Get Call History ──────────────────────────────────────────────────────
router.get('/history/:qrId', async (req, res) => {
  try {
    const { qrId } = req.params;
    const calls = await Call.find({ qrId }).sort({ startTime: -1 });

    res.json({ calls });
  } catch (error) {
    console.error('[Call] History error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
