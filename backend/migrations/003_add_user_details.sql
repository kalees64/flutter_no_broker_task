-- Migration: 003_add_user_details.sql
-- Description: Add flat_number, society_name, and kyc_status to users table

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS flat_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS society_name VARCHAR(150),
ADD COLUMN IF NOT EXISTS kyc_status VARCHAR(20) DEFAULT 'verified';

CREATE INDEX IF NOT EXISTS idx_users_kyc_status ON users(kyc_status);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_society ON users(society_name);
