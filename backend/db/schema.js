// db/schema.js
// Run this once to create all tables: node db/schema.js

const pool = require('./pool');

const createTables = async () => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // ─── USERS ──────────────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id            SERIAL PRIMARY KEY,
        name          VARCHAR(100) NOT NULL,
        email         VARCHAR(255) UNIQUE NOT NULL,
        password      VARCHAR(255),
        phone         VARCHAR(20),
        avatar_url    TEXT,
        google_id     VARCHAR(255),
        is_verified   BOOLEAN DEFAULT FALSE,
        created_at    TIMESTAMP DEFAULT NOW(),
        updated_at    TIMESTAMP DEFAULT NOW()
      );
    `);

    // ─── EMERGENCY CONTACTS ─────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS emergency_contacts (
        id            SERIAL PRIMARY KEY,
        user_id       INTEGER REFERENCES users(id) ON DELETE CASCADE,
        name          VARCHAR(100) NOT NULL,
        phone         VARCHAR(20) NOT NULL,
        relation      VARCHAR(50),
        priority      INTEGER DEFAULT 0,
        created_at    TIMESTAMP DEFAULT NOW()
      );
    `);

    // ─── QR CODES ───────────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS qr_codes (
        id              SERIAL PRIMARY KEY,
        owner_id        INTEGER REFERENCES users(id) ON DELETE CASCADE,
        purpose         VARCHAR(50) NOT NULL,
        custom_purpose  VARCHAR(255),
        template        VARCHAR(100) DEFAULT 'blank',
        qr_color        VARCHAR(10) DEFAULT '#000000',
        bg_color        VARCHAR(10) DEFAULT '#FFFFFF',
        qr_data_url     TEXT,
        unique_code     VARCHAR(20) UNIQUE NOT NULL,
        redirect_url    TEXT,
        order_type      VARCHAR(10) DEFAULT 'pdf' CHECK (order_type IN ('pdf', 'sticker')),
        is_active       BOOLEAN DEFAULT FALSE,
        total_scans     INTEGER DEFAULT 0,
        last_scanned_at TIMESTAMP,
        payment_id      INTEGER,
        created_at      TIMESTAMP DEFAULT NOW(),
        updated_at      TIMESTAMP DEFAULT NOW()
      );
    `);

    // ─── MESSAGES ───────────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id                SERIAL PRIMARY KEY,
        room_id           VARCHAR(100) NOT NULL,
        sender_id         VARCHAR(100) NOT NULL,
        sender_type       VARCHAR(10) NOT NULL CHECK (sender_type IN ('owner', 'stranger')),
        content           TEXT NOT NULL,
        type              VARCHAR(10) DEFAULT 'text' CHECK (type IN ('text', 'voice', 'location', 'system')),
        latitude          DOUBLE PRECISION,
        longitude         DOUBLE PRECISION,
        voice_duration_sec INTEGER,
        voice_url         TEXT,
        created_at        TIMESTAMP DEFAULT NOW()
      );
    `);

    // ─── CALL LOGS ──────────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS call_logs (
        id                  SERIAL PRIMARY KEY,
        qr_code_id          INTEGER REFERENCES qr_codes(id) ON DELETE SET NULL,
        owner_id            INTEGER REFERENCES users(id) ON DELETE CASCADE,
        stranger_session_id VARCHAR(255) NOT NULL,
        status              VARCHAR(20) DEFAULT 'missed' CHECK (status IN ('answered', 'missed', 'escalated', 'declined')),
        duration            INTEGER DEFAULT 0,
        escalated_to        VARCHAR(20),
        escalation_result   VARCHAR(20) DEFAULT 'not_attempted' CHECK (escalation_result IN ('answered', 'missed', 'not_attempted')),
        started_at          TIMESTAMP DEFAULT NOW(),
        ended_at            TIMESTAMP,
        created_at          TIMESTAMP DEFAULT NOW()
      );
    `);

    // ─── PAYMENTS ───────────────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS payments (
        id                    SERIAL PRIMARY KEY,
        user_id               INTEGER REFERENCES users(id) ON DELETE CASCADE,
        qr_code_id            INTEGER REFERENCES qr_codes(id) ON DELETE SET NULL,
        amount                NUMERIC(10,2) NOT NULL,
        currency              VARCHAR(5) DEFAULT 'INR',
        method                VARCHAR(20) DEFAULT 'upi' CHECK (method IN ('upi', 'card', 'netbanking', 'wallet')),
        status                VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'failed', 'refunded')),
        razorpay_order_id     VARCHAR(255),
        razorpay_payment_id   VARCHAR(255),
        razorpay_signature    VARCHAR(255),
        order_type            VARCHAR(10) NOT NULL CHECK (order_type IN ('pdf', 'sticker')),
        created_at            TIMESTAMP DEFAULT NOW()
      );
    `);

    // ─── INDEXES ────────────────────────────────────────────────────
    await client.query(`CREATE INDEX IF NOT EXISTS idx_qr_unique_code ON qr_codes(unique_code);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_qr_owner ON qr_codes(owner_id);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_messages_room ON messages(room_id, created_at);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_call_logs_owner ON call_logs(owner_id, created_at DESC);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_payments_user ON payments(user_id, created_at DESC);`);
    await client.query(`CREATE INDEX IF NOT EXISTS idx_emergency_user ON emergency_contacts(user_id, priority);`);

    await client.query('COMMIT');
    console.log('✅ All tables and indexes created successfully!');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Schema creation failed:', err.message);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
};

createTables();