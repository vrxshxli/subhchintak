require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { createServer } = require('http');
const { Server } = require('socket.io');

const authRoutes = require('./routes/auth.routes');
const qrRoutes = require('./routes/qr.routes');
const emergencyRoutes = require('./routes/emergency.routes');
const chatRoutes = require('./routes/chat.routes');
const paymentRoutes = require('./routes/payment.routes');
const updateRoutes = require('./routes/update.routes');
const adminRoutes = require('./routes/admin.routes');

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Make io accessible in routes
app.set('io', io);

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/qr', qrRoutes);
app.use('/api/emergency', emergencyRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api/updates', updateRoutes);
app.use('/api/admin', adminRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Socket.IO for real-time chat & calls
io.on('connection', (socket) => {
  console.log(`Socket connected: ${socket.id}`);

  socket.on('join_session', (sessionId) => {
    socket.join(sessionId);
    console.log(`Socket ${socket.id} joined session ${sessionId}`);
  });

  socket.on('send_message', (data) => {
    io.to(data.sessionId).emit('new_message', data);
  });

  socket.on('call_initiate', (data) => {
    io.to(data.ownerId).emit('incoming_call', data);
  });

  socket.on('call_answer', (data) => {
    io.to(data.sessionId).emit('call_answered', data);
  });

  socket.on('call_end', (data) => {
    io.to(data.sessionId).emit('call_ended', data);
  });

  socket.on('webrtc_offer', (data) => {
    socket.to(data.sessionId).emit('webrtc_offer', data);
  });

  socket.on('webrtc_answer', (data) => {
    socket.to(data.sessionId).emit('webrtc_answer', data);
  });

  socket.on('webrtc_ice_candidate', (data) => {
    socket.to(data.sessionId).emit('webrtc_ice_candidate', data);
  });

  socket.on('disconnect', () => {
    console.log(`Socket disconnected: ${socket.id}`);
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

const PORT = process.env.PORT || 3000;
httpServer.listen(PORT, () => {
  console.log(`SHUBHCHINTAK server running on port ${PORT}`);
});