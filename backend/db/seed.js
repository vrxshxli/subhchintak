// db/seed.js
// Optional: Run to insert test data: node db/seed.js

const pool = require('./pool');
const bcrypt = require('bcryptjs');

const seed = async () => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Create a test user
    const hashedPassword = await bcrypt.hash('test123', 12);
    const userResult = await client.query(
      `INSERT INTO users (name, email, password, phone, is_verified)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (email) DO NOTHING
       RETURNING id`,
      ['Test User', 'test@shubhchintak.com', hashedPassword, '9876543210', true]
    );

    if (userResult.rows.length > 0) {
      const userId = userResult.rows[0].id;

      // Add emergency contacts
      await client.query(
        `INSERT INTO emergency_contacts (user_id, name, phone, relation, priority)
         VALUES ($1, 'Mom', '+919876543211', 'Mother', 0),
                ($1, 'Dad', '+919876543212', 'Father', 1)`,
        [userId]
      );

      console.log(`✅ Seed complete. Test user ID: ${userId}`);
      console.log('   Email: test@shubhchintak.com');
      console.log('   Password: test123');
    } else {
      console.log('⚠️  Test user already exists.');
    }

    await client.query('COMMIT');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Seed failed:', err.message);
  } finally {
    client.release();
    await pool.end();
  }
};

seed();