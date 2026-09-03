import bcrypt from 'bcrypt';
import { db } from './pool.js';

async function seedDatabase() {
  console.log('🌱 Starting NoBroker database seeding...\n');

  try {
    const defaultPassword = 'Password123!';
    const saltRounds = 10;
    const defaultHash = await bcrypt.hash(defaultPassword, saltRounds);
    const adminHash = await bcrypt.hash('AdminPass123!', saltRounds);

    const demoUsers = [
      {
        name: 'Corporate Admin',
        email: 'admin@nobroker.in',
        phone: '+91 9000000001',
        password_hash: adminHash,
        role: 'admin',
        flat_number: 'HQ-01',
        society_name: 'NoBroker HQ Whitefield',
        kyc_status: 'verified',
        avatar_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      },
      {
        name: 'Amit Sharma',
        email: 'amit.sharma@nobroker.in',
        phone: '+91 9876543210',
        password_hash: defaultHash,
        role: 'tenant',
        flat_number: 'Flat 402',
        society_name: 'Oakwood Residency',
        kyc_status: 'verified',
        avatar_url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      },
      {
        name: 'Rajesh Kumar',
        email: 'rajesh.k@nobroker.in',
        phone: '+91 9876543211',
        password_hash: defaultHash,
        role: 'owner',
        flat_number: 'Villa 14',
        society_name: 'Prestige Silver Oak',
        kyc_status: 'verified',
        avatar_url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      },
      {
        name: 'Sneha Reddy',
        email: 'sneha.reddy@nobroker.in',
        phone: '+91 9876543212',
        password_hash: defaultHash,
        role: 'tenant',
        flat_number: 'Flat 108',
        society_name: 'Palm Heights',
        kyc_status: 'pending',
        avatar_url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      },
      {
        name: 'Vikram Malhotra',
        email: 'vikram.m@nobroker.in',
        phone: '+91 9876543213',
        password_hash: defaultHash,
        role: 'vendor',
        flat_number: 'Block B Service',
        society_name: 'Whitefield Cluster Logistics',
        kyc_status: 'verified',
        avatar_url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      },
      {
        name: 'Priya Patel',
        email: 'priya.patel@nobroker.in',
        phone: '+91 9876543214',
        password_hash: defaultHash,
        role: 'owner',
        flat_number: 'Flat 901',
        society_name: 'Brigade Metropolis',
        kyc_status: 'verified',
        avatar_url: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      },
      {
        name: 'Ananya Iyer',
        email: 'ananya.iyer@nobroker.in',
        phone: '+91 9876543215',
        password_hash: defaultHash,
        role: 'tenant',
        flat_number: 'Flat 304',
        society_name: 'Sobha Dream Acres',
        kyc_status: 'verified',
        avatar_url: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      },
      {
        name: 'Rohan Gupta',
        email: 'rohan.gupta@nobroker.in',
        phone: '+91 9876543216',
        password_hash: defaultHash,
        role: 'tenant',
        flat_number: 'Flat 512',
        society_name: 'Godrej Woods',
        kyc_status: 'verified',
        avatar_url: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
      },
      {
        name: 'Kavita Joshi',
        email: 'kavita.j@nobroker.in',
        phone: '+91 9876543217',
        password_hash: defaultHash,
        role: 'owner',
        flat_number: 'Villa 22',
        society_name: 'Windmills of Your Mind',
        kyc_status: 'verified',
        avatar_url: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
      },
      {
        name: 'Arjun Nair',
        email: 'arjun.nair@nobroker.in',
        phone: '+91 9876543218',
        password_hash: defaultHash,
        role: 'tenant',
        flat_number: 'Flat 701',
        society_name: 'Assetz Marq',
        kyc_status: 'pending',
        avatar_url: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
      },
      {
        name: 'Deepa Krishnan',
        email: 'deepa.k@nobroker.in',
        phone: '+91 9876543219',
        password_hash: defaultHash,
        role: 'owner',
        flat_number: 'Flat 1104',
        society_name: 'Salarpuria Sattva',
        kyc_status: 'verified',
        avatar_url: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
      },
      {
        name: 'Manoj Bajpayee',
        email: 'manoj.b@nobroker.in',
        phone: '+91 9876543220',
        password_hash: defaultHash,
        role: 'vendor',
        flat_number: 'Electrical Suite 4',
        society_name: 'Oakwood Residency',
        kyc_status: 'verified',
        avatar_url: null,
      },
      {
        name: 'Sunita Mehra',
        email: 'sunita.m@nobroker.in',
        phone: '+91 9876543221',
        password_hash: defaultHash,
        role: 'tenant',
        flat_number: 'Flat 202',
        society_name: 'Prestige Lakeside',
        kyc_status: 'verified',
        avatar_url: null,
      },
      {
        name: 'Karthik Subbaraj',
        email: 'karthik.s@nobroker.in',
        phone: '+91 9876543222',
        password_hash: defaultHash,
        role: 'owner',
        flat_number: 'Penthouse 16A',
        society_name: 'Total Environment',
        kyc_status: 'verified',
        avatar_url: null,
      },
      {
        name: 'Meenakshi Sundaram',
        email: 'meenakshi.s@nobroker.in',
        phone: '+91 9876543223',
        password_hash: defaultHash,
        role: 'tenant',
        flat_number: 'Flat 603',
        society_name: 'Purva Fountain Square',
        kyc_status: 'pending',
        avatar_url: null,
      },
      {
        name: 'Harish Choudhary',
        email: 'harish.c@nobroker.in',
        phone: '+91 9876543224',
        password_hash: defaultHash,
        role: 'tenant',
        flat_number: 'Flat 805',
        society_name: 'Brigade Cosmopolis',
        kyc_status: 'verified',
        avatar_url: null,
      },
      {
        name: 'Pooja Hegde',
        email: 'pooja.h@nobroker.in',
        phone: '+91 9876543225',
        password_hash: defaultHash,
        role: 'owner',
        flat_number: 'Tower C 1201',
        society_name: 'Divyasree Republic of Whitefield',
        kyc_status: 'verified',
        avatar_url: null,
      },
      {
        name: 'Suresh Raina',
        email: 'suresh.r@nobroker.in',
        phone: '+91 9876543226',
        password_hash: defaultHash,
        role: 'tenant',
        flat_number: 'Flat 301',
        society_name: 'Adarsh Palm Retreat',
        kyc_status: 'rejected',
        avatar_url: null,
      },
      {
        name: 'Alok Nath',
        email: 'alok.n@nobroker.in',
        phone: '+91 9876543227',
        password_hash: defaultHash,
        role: 'vendor',
        flat_number: 'Security Office',
        society_name: 'Prestige Silver Oak',
        kyc_status: 'verified',
        avatar_url: null,
      },
      {
        name: 'Neha Kakkar',
        email: 'neha.k@nobroker.in',
        phone: '+91 9876543228',
        password_hash: defaultHash,
        role: 'tenant',
        flat_number: 'Flat 904',
        society_name: 'Assetz Marq',
        kyc_status: 'verified',
        avatar_url: null,
      },
    ];

    let insertedCount = 0;
    for (const u of demoUsers) {
      const query = `
        INSERT INTO users (
          name, email, phone, password_hash, role, 
          flat_number, society_name, kyc_status, avatar_url
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        ON CONFLICT (email) DO UPDATE SET
          name = EXCLUDED.name,
          phone = EXCLUDED.phone,
          role = EXCLUDED.role,
          flat_number = EXCLUDED.flat_number,
          society_name = EXCLUDED.society_name,
          kyc_status = EXCLUDED.kyc_status,
          avatar_url = EXCLUDED.avatar_url;
      `;
      const values = [
        u.name,
        u.email,
        u.phone,
        u.password_hash,
        u.role,
        u.flat_number,
        u.society_name,
        u.kyc_status,
        u.avatar_url,
      ];
      await db.query(query, values);
      insertedCount++;
    }

    console.log(`✅ Seeded ${insertedCount} users successfully!`);
    console.log('🔑 Credentials to test:');
    console.log('   Admin: admin@nobroker.in / AdminPass123!');
    console.log('   Users: amit.sharma@nobroker.in / Password123!');
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

seedDatabase();
