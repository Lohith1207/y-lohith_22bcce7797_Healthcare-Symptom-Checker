-- Healthcare Symptom Checker Database Schema
-- This script initializes the database schema for the symptom checker

-- Create the queries table to store anonymized symptom check data
CREATE TABLE IF NOT EXISTS queries (
    id UUID PRIMARY KEY,
    user_id VARCHAR(255),
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    symptoms_hash VARCHAR(64) NOT NULL,
    response_json JSONB NOT NULL,
    triage_level VARCHAR(20) NOT NULL
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_queries_user_id ON queries(user_id);
CREATE INDEX IF NOT EXISTS idx_queries_timestamp ON queries(timestamp);
CREATE INDEX IF NOT EXISTS idx_queries_triage_level ON queries(triage_level);

-- Create a view for analytics (without exposing sensitive data)
CREATE OR REPLACE VIEW query_analytics AS
SELECT 
    DATE_TRUNC('day', timestamp) as date,
    triage_level,
    COUNT(*) as count
FROM queries
GROUP BY DATE_TRUNC('day', timestamp), triage_level
ORDER BY date DESC;

-- Add comments for documentation
COMMENT ON TABLE queries IS 'Stores anonymized symptom check queries and responses';
COMMENT ON COLUMN queries.id IS 'Unique identifier for each query';
COMMENT ON COLUMN queries.user_id IS 'Optional user identifier (can be null for anonymous queries)';
COMMENT ON COLUMN queries.symptoms_hash IS 'SHA-256 hash of symptoms for privacy protection';
COMMENT ON COLUMN queries.response_json IS 'Full JSON response from the symptom analysis';
COMMENT ON COLUMN queries.triage_level IS 'Emergency level classification (emergency, urgent, non-urgent, self-care)';
