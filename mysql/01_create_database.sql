-- =====================================================================
-- STEP 1: create the database (MySQL 8.0 or newer)
-- In MySQL Workbench: paste, then press Ctrl+Shift+Enter (run all).
-- =====================================================================
SELECT VERSION();                      -- must start with 8 (window functions and CTEs need MySQL 8+)

CREATE DATABASE IF NOT EXISTS quickcommerce;
USE quickcommerce;
