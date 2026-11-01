/* ==========================================================================
   club_db_starter.sql
   CIS 4720 Database Management and SQL
   Project 9

   WHAT THIS FILE IS
   Your starter for Project 9. It builds a schema called club_db with one
   table in it, member, already filled in. Everything else is yours to write
   under the headings further down.

   WHY MEMBER IS GIVEN TO YOU
   Read its CREATE TABLE statement before you start. It is a worked example
   of the two things this project is about: a surrogate key, and a starting
   value for that key. You build payment and payment_log the same way.

   BEFORE YOU RUN IT
   Connect SQLTools to information_schema first, the same as Lab 5d and
   Lab 5e. The first two statements in this file create club_db and switch
   you into it. Step 1 walks through it.

   HOW TO RUN IT
   One statement at a time. Put the cursor on it and press Ctrl + E twice.
   The function and the triggers you write later are each a single statement
   from CREATE down to END, so select the whole block and run the selection.

   LABELING AND COMMENTING IS REQUIRED
   Above every statement you write, put a short comment in your own words
   saying what it does. The comments are graded.
   ========================================================================== */


-- =================================================================
-- SETUP. Run these three first, one at a time, while you are still
-- connected to information_schema.
-- =================================================================

-- every schema on this server. club_db will not be in the list yet.
show databases;

-- make yours. IF NOT EXISTS means it is safe to run twice.
create database if not exists club_db;

-- switch into it, so everything below lands in the right place.
use club_db;


-- ======================================================================
-- GIVEN TO YOU. The member table.
--
-- member_id is a surrogate key: a number the database invents so that
-- every row can be told apart. Nobody is born with one.
--
-- AUTO_INCREMENT = 100 after the closing bracket is what makes the first
-- member 100 instead of 1. Club membership numbers start at 100 because
-- that is how the club has always done it, which is the usual reason.
-- ======================================================================

CREATE TABLE member (
    member_id  INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name  VARCHAR(30) NOT NULL,
    joined_on  DATE,
    total_paid DECIMAL(7,2) DEFAULT 0.00
) AUTO_INCREMENT = 100;

INSERT INTO member (first_name, last_name, joined_on) VALUES ('Noor',   'Haddad',   '2026-01-15');
INSERT INTO member (first_name, last_name, joined_on) VALUES ('Caleb',  'Ortiz',    '2026-02-03');
INSERT INTO member (first_name, last_name, joined_on) VALUES ('Sofia',  'Marchetti','2026-02-28');
INSERT INTO member (first_name, last_name, joined_on) VALUES ('Desmond','Blake',    '2026-03-11');


-- ======================================================================
-- CHECK. Four members, numbered 100 to 103, every total_paid at 0.00.
-- ======================================================================

SELECT * FROM member;


-- ######################################################################
-- YOUR PROJECT 9 WORK STARTS BELOW THIS LINE
--
-- LABELING AND COMMENTING IS REQUIRED. It is worth a full point.
--
-- You write the SQL for Steps 2, 3, 4 and 9 yourself.
--
-- Steps 5, 6, 7 and 8 are in the handout with the skeleton complete and
-- ONE statement removed from each. Copy the skeleton in, then write the
-- missing statement yourself. The handout walks you through each one a
-- line at a time.
-- ######################################################################


-- =================================================================
-- STEP 2. Create the payment table, key starting at 5000
-- =================================================================
-- Create payment table with auto-increment starting at 5000
CREATE TABLE payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    amount DECIMAL(7,2) NOT NULL,
    paid_on DATE,
    method VARCHAR(10),
    FOREIGN KEY (member_id) REFERENCES member(member_id)
) AUTO_INCREMENT = 5000;


-- =================================================================
-- STEP 3. Create the payment_log table
-- =================================================================
-- Make 'payment_log' table 
CREATE TABLE payment_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    amount DECIMAL(7,2),
    action VARCHAR(20),
    logged_on DATETIME);


-- =================================================================
-- STEP 4. Check your two counters before anything is inserted
-- =================================================================

-- check all the tables auto incremnt values 
SHOW TABLE STATUS;


-- =================================================================
-- STEP 5. Create the member_total function
--
-- Copy the skeleton from the handout, then write the SELECT that goes in
-- the gap. One statement from CREATE FUNCTION down to END, so select the
-- whole block and run the selection.
-- =================================================================

-- sum of payments for the memebers 
CREATE FUNCTION member_total(p_member_id INT)
RETURNS DECIMAL(7,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(7,2);
    
    -- Sum payments for the member into the variable
    SELECT SUM(amount)
    INTO v_total
    FROM payment
    WHERE member_id = p_member_id;
    
    RETURN IFNULL(v_total, 0.00);
END;

-- =================================================================
-- STEP 6. A BEFORE INSERT trigger that fills in what was left out
-- =================================================================

-- Create a BEFORE INSERT trigger
CREATE TRIGGER trg_payment_before_insert
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    IF NEW.paid_on IS NULL THEN
        SET NEW.paid_on = CURDATE();
    END IF;
    
    SET NEW.method = UPPER(NEW.method);
END;

-- =================================================================
-- STEP 7. An AFTER INSERT trigger that updates and logs
-- =================================================================

-- Create an AFTER INSERT trigger to update the member's running total
CREATE TRIGGER trg_payment_after_insert
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
    UPDATE member
    SET total_paid = member_total(NEW.member_id)
    WHERE member_id = NEW.member_id;
    
    INSERT INTO payment_log (member_id, amount, action, logged_on)
    VALUES (NEW.member_id, NEW.amount, 'ADDED', NOW());
END;


-- =================================================================
-- STEP 8. An AFTER DELETE trigger that does the same in reverse
-- =================================================================
-- Create an AFTER DELETE trigger 
CREATE TRIGGER trg_payment_after_delete
AFTER DELETE ON payment
FOR EACH ROW
BEGIN
    UPDATE member
    SET total_paid = member_total(OLD.member_id)
    WHERE member_id = OLD.member_id;
    
    INSERT INTO payment_log (member_id, amount, action, logged_on)
    VALUES (OLD.member_id, OLD.amount, 'REMOVED', NOW());
END;

-- =================================================================
-- STEP 9. Add four payments, then remove one, and watch it all happen
-- =================================================================
-- check to verify trigger automation, date defaults, and method works
INSERT INTO payment (member_id, amount, paid_on, method) VALUES
(100, 45.00, NULL, 'cash'),
(100, 30.00, '2026-04-02', 'card'),
(101, 45.00, NULL, 'check'),
(102, 60.00, '2026-03-15', 'card');

-- Delete payment_id 5001 to test the AFTER DELETE trigger and log recording
DELETE FROM payment WHERE payment_id = 5001;


-- =================================================================
-- STEP 10 and 11. Push to GitHub and submit the URL
-- Nothing to write here. Follow the handout.
-- =================================================================
