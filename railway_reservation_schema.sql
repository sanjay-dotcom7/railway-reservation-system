-- Railway Reservation System Database Schema
-- Create Database
CREATE DATABASE IF NOT EXISTS railway_reservation_system;
USE railway_reservation_system;

-- Drop tables if they exist (for fresh installation)
DROP TABLE IF EXISTS PAYMENT;
DROP TABLE IF EXISTS TICKET;
DROP TABLE IF EXISTS SEAT_AVAILABILITY;
DROP TABLE IF EXISTS PASSENGER;
DROP TABLE IF EXISTS TRAIN;
DROP TABLE IF EXISTS ROUTE;

-- 1. ROUTE Table
CREATE TABLE ROUTE (
    route_id INT PRIMARY KEY AUTO_INCREMENT,
    source VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    distance_km DECIMAL(10, 2) NOT NULL,
    duration_hours DECIMAL(5, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. TRAIN Table
CREATE TABLE TRAIN (
    train_id INT PRIMARY KEY AUTO_INCREMENT,
    train_name VARCHAR(100) NOT NULL,
    train_number VARCHAR(20) UNIQUE NOT NULL,
    train_type ENUM('Express', 'Superfast', 'Passenger', 'Shatabdi', 'Rajdhani') NOT NULL,
    total_seats INT NOT NULL,
    route_id INT NOT NULL,
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    days_of_operation VARCHAR(50) DEFAULT 'All Days',
    status ENUM('Active', 'Inactive', 'Maintenance') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (route_id) REFERENCES ROUTE(route_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. PASSENGER Table
CREATE TABLE PASSENGER (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    address TEXT,
    id_proof_type ENUM('Aadhar', 'PAN', 'Passport', 'Driving License') NOT NULL,
    id_proof_number VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. SEAT_AVAILABILITY Table
CREATE TABLE SEAT_AVAILABILITY (
    availability_id INT PRIMARY KEY AUTO_INCREMENT,
    train_id INT NOT NULL,
    journey_date DATE NOT NULL,
    total_seats INT NOT NULL,
    available_seats INT NOT NULL,
    sleeper_available INT DEFAULT 0,
    ac_3tier_available INT DEFAULT 0,
    ac_2tier_available INT DEFAULT 0,
    ac_1tier_available INT DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (train_id) REFERENCES TRAIN(train_id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY unique_train_date (train_id, journey_date)
);

-- 5. TICKET Table
CREATE TABLE TICKET (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    pnr_number VARCHAR(10) UNIQUE NOT NULL,
    passenger_id INT NOT NULL,
    train_id INT NOT NULL,
    journey_date DATE NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_class ENUM('Sleeper', '3AC', '2AC', '1AC') NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ticket_status ENUM('Confirmed', 'Waiting', 'Cancelled', 'RAC') DEFAULT 'Confirmed',
    fare DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (passenger_id) REFERENCES PASSENGER(passenger_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (train_id) REFERENCES TRAIN(train_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6. PAYMENT Table
CREATE TABLE PAYMENT (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Wallet') NOT NULL,
    payment_status ENUM('Success', 'Pending', 'Failed', 'Refunded') DEFAULT 'Pending',
    transaction_id VARCHAR(100) UNIQUE NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES TICKET(ticket_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create Indexes for Better Performance
CREATE INDEX idx_train_route ON TRAIN(route_id);
CREATE INDEX idx_ticket_passenger ON TICKET(passenger_id);
CREATE INDEX idx_ticket_train ON TICKET(train_id);
CREATE INDEX idx_ticket_pnr ON TICKET(pnr_number);
CREATE INDEX idx_payment_ticket ON PAYMENT(ticket_id);
CREATE INDEX idx_seat_train_date ON SEAT_AVAILABILITY(train_id, journey_date);

-- Insert Sample Data for ROUTE
INSERT INTO ROUTE (source, destination, distance_km, duration_hours) VALUES
('Chennai Central', 'Mumbai Central', 1338.50, 24.00),
('Delhi Junction', 'Kolkata Howrah', 1441.00, 17.30),
('Bangalore City', 'Chennai Central', 362.00, 6.00),
('Mumbai Central', 'Delhi Junction', 1384.00, 16.00),
('Hyderabad Deccan', 'Bangalore City', 574.00, 10.00),
('Chennai Central', 'Coimbatore Junction', 497.00, 7.30),
('Delhi Junction', 'Jaipur Junction', 308.00, 5.00),
('Mumbai Central', 'Pune Junction', 192.00, 3.30);

-- Insert Sample Data for TRAIN
INSERT INTO TRAIN (train_name, train_number, train_type, total_seats, route_id, departure_time, arrival_time, days_of_operation, status) VALUES
('Chennai Mumbai Express', '12164', 'Express', 1200, 1, '06:00:00', '06:00:00', 'All Days', 'Active'),
('Rajdhani Express', '12301', 'Rajdhani', 800, 2, '16:55:00', '10:25:00', 'All Days', 'Active'),
('Shatabdi Express', '12028', 'Shatabdi', 600, 3, '06:00:00', '12:00:00', 'All Days', 'Active'),
('Duronto Express', '12263', 'Superfast', 1000, 4, '21:15:00', '13:15:00', 'All Days', 'Active'),
('Intercity Express', '12785', 'Express', 700, 5, '05:30:00', '15:30:00', 'All Days', 'Active'),
('Nilgiri Express', '12671', 'Express', 900, 6, '20:30:00', '04:00:00', 'All Days', 'Active'),
('Jaipur Express', '12413', 'Express', 850, 7, '07:00:00', '12:00:00', 'All Days', 'Active'),
('Deccan Queen', '12123', 'Express', 750, 8, '07:10:00', '10:40:00', 'All Days', 'Active');

-- Insert Sample Data for PASSENGER
INSERT INTO PASSENGER (first_name, last_name, email, phone, date_of_birth, gender, address, id_proof_type, id_proof_number) VALUES
('Rajesh', 'Kumar', 'rajesh.kumar@email.com', '9876543210', '1985-03-15', 'Male', '123 MG Road, Chennai', 'Aadhar', '1234-5678-9012'),
('Priya', 'Sharma', 'priya.sharma@email.com', '9876543211', '1990-07-22', 'Female', '456 Park Street, Mumbai', 'PAN', 'ABCDE1234F'),
('Amit', 'Patel', 'amit.patel@email.com', '9876543212', '1988-11-10', 'Male', '789 Brigade Road, Bangalore', 'Passport', 'M1234567'),
('Sneha', 'Reddy', 'sneha.reddy@email.com', '9876543213', '1992-05-18', 'Female', '321 Connaught Place, Delhi', 'Driving License', 'DL-1234567890'),
('Vijay', 'Mehta', 'vijay.mehta@email.com', '9876543214', '1987-09-25', 'Male', '654 MG Road, Pune', 'Aadhar', '9876-5432-1098');

-- Insert Sample Data for SEAT_AVAILABILITY (for next 7 days)
INSERT INTO SEAT_AVAILABILITY (train_id, journey_date, total_seats, available_seats, sleeper_available, ac_3tier_available, ac_2tier_available, ac_1tier_available) VALUES
(1, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 1200, 845, 450, 250, 100, 45),
(1, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1200, 920, 500, 280, 100, 40),
(2, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 800, 567, 300, 180, 60, 27),
(2, DATE_ADD(CURDATE(), INTERVAL 3 DAY), 800, 650, 350, 200, 70, 30),
(3, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 600, 425, 250, 120, 40, 15),
(4, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1000, 780, 400, 250, 90, 40),
(5, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 700, 530, 300, 150, 60, 20),
(6, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 900, 680, 380, 200, 70, 30);

-- Insert Sample Data for TICKET
INSERT INTO TICKET (pnr_number, passenger_id, train_id, journey_date, seat_number, seat_class, ticket_status, fare) VALUES
('PNR1234567', 1, 1, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'S5-42', 'Sleeper', 'Confirmed', 850.00),
('PNR2345678', 2, 2, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'A1-15', '2AC', 'Confirmed', 2500.00),
('PNR3456789', 3, 3, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'B3-28', '3AC', 'Confirmed', 1200.00),
('PNR4567890', 4, 4, DATE_ADD(CURDATE(), INTERVAL 2 DAY), 'S7-56', 'Sleeper', 'Confirmed', 920.00),
('PNR5678901', 5, 5, DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'A2-12', '1AC', 'Confirmed', 3500.00);

-- Insert Sample Data for PAYMENT
INSERT INTO PAYMENT (ticket_id, amount, payment_method, payment_status, transaction_id) VALUES
(1, 850.00, 'UPI', 'Success', 'TXN1001234567890'),
(2, 2500.00, 'Credit Card', 'Success', 'TXN1001234567891'),
(3, 1200.00, 'Debit Card', 'Success', 'TXN1001234567892'),
(4, 920.00, 'Net Banking', 'Success', 'TXN1001234567893'),
(5, 3500.00, 'UPI', 'Success', 'TXN1001234567894');

-- Create Views for Common Queries
CREATE OR REPLACE VIEW ticket_details AS
SELECT 
    t.ticket_id,
    t.pnr_number,
    CONCAT(p.first_name, ' ', p.last_name) AS passenger_name,
    p.email,
    p.phone,
    tr.train_name,
    tr.train_number,
    r.source,
    r.destination,
    t.journey_date,
    t.seat_number,
    t.seat_class,
    t.ticket_status,
    t.fare,
    pay.payment_status
FROM TICKET t
JOIN PASSENGER p ON t.passenger_id = p.passenger_id
JOIN TRAIN tr ON t.train_id = tr.train_id
JOIN ROUTE r ON tr.route_id = r.route_id
LEFT JOIN PAYMENT pay ON t.ticket_id = pay.ticket_id;

-- Create View for Train Availability
CREATE OR REPLACE VIEW train_availability AS
SELECT 
    t.train_id,
    t.train_name,
    t.train_number,
    t.train_type,
    r.source,
    r.destination,
    t.departure_time,
    t.arrival_time,
    r.distance_km,
    r.duration_hours,
    sa.journey_date,
    sa.available_seats,
    sa.sleeper_available,
    sa.ac_3tier_available,
    sa.ac_2tier_available,
    sa.ac_1tier_available
FROM TRAIN t
JOIN ROUTE r ON t.route_id = r.route_id
LEFT JOIN SEAT_AVAILABILITY sa ON t.train_id = sa.train_id
WHERE t.status = 'Active';

-- Create Stored Procedure for Booking Ticket
DELIMITER //

CREATE PROCEDURE book_ticket(
    IN p_passenger_id INT,
    IN p_train_id INT,
    IN p_journey_date DATE,
    IN p_seat_class VARCHAR(10),
    IN p_fare DECIMAL(10,2),
    OUT p_pnr VARCHAR(10),
    OUT p_ticket_id INT
)
BEGIN
    DECLARE available_count INT;
    DECLARE seat_num VARCHAR(10);
    
    -- Check seat availability
    SELECT available_seats INTO available_count
    FROM SEAT_AVAILABILITY
    WHERE train_id = p_train_id AND journey_date = p_journey_date;
    
    IF available_count > 0 THEN
        -- Generate PNR
        SET p_pnr = CONCAT('PNR', LPAD(FLOOR(RAND() * 10000000), 7, '0'));
        
        -- Generate seat number
        SET seat_num = CONCAT(
            CASE p_seat_class
                WHEN 'Sleeper' THEN 'S'
                WHEN '3AC' THEN 'B'
                WHEN '2AC' THEN 'A'
                WHEN '1AC' THEN 'F'
            END,
            FLOOR(RAND() * 10) + 1,
            '-',
            FLOOR(RAND() * 72) + 1
        );
        
        -- Insert ticket
        INSERT INTO TICKET (pnr_number, passenger_id, train_id, journey_date, seat_number, seat_class, fare)
        VALUES (p_pnr, p_passenger_id, p_train_id, p_journey_date, seat_num, p_seat_class, p_fare);
        
        SET p_ticket_id = LAST_INSERT_ID();
        
        -- Update seat availability
        UPDATE SEAT_AVAILABILITY
        SET available_seats = available_seats - 1,
            sleeper_available = CASE WHEN p_seat_class = 'Sleeper' THEN sleeper_available - 1 ELSE sleeper_available END,
            ac_3tier_available = CASE WHEN p_seat_class = '3AC' THEN ac_3tier_available - 1 ELSE ac_3tier_available END,
            ac_2tier_available = CASE WHEN p_seat_class = '2AC' THEN ac_2tier_available - 1 ELSE ac_2tier_available END,
            ac_1tier_available = CASE WHEN p_seat_class = '1AC' THEN ac_1tier_available - 1 ELSE ac_1tier_available END
        WHERE train_id = p_train_id AND journey_date = p_journey_date;
    ELSE
        SET p_pnr = NULL;
        SET p_ticket_id = NULL;
    END IF;
END //

DELIMITER ;

-- Create Trigger to Update Seat Availability on Ticket Cancellation
DELIMITER //

CREATE TRIGGER after_ticket_cancel
AFTER UPDATE ON TICKET
FOR EACH ROW
BEGIN
    IF NEW.ticket_status = 'Cancelled' AND OLD.ticket_status != 'Cancelled' THEN
        UPDATE SEAT_AVAILABILITY
        SET available_seats = available_seats + 1,
            sleeper_available = CASE WHEN NEW.seat_class = 'Sleeper' THEN sleeper_available + 1 ELSE sleeper_available END,
            ac_3tier_available = CASE WHEN NEW.seat_class = '3AC' THEN ac_3tier_available + 1 ELSE ac_3tier_available END,
            ac_2tier_available = CASE WHEN NEW.seat_class = '2AC' THEN ac_2tier_available + 1 ELSE ac_2tier_available END,
            ac_1tier_available = CASE WHEN NEW.seat_class = '1AC' THEN ac_1tier_available + 1 ELSE ac_1tier_available END
        WHERE train_id = NEW.train_id AND journey_date = NEW.journey_date;
    END IF;
END //

DELIMITER ;

-- Grant Privileges (adjust username and password as needed)
-- GRANT ALL PRIVILEGES ON railway_reservation_system.* TO 'railway_user'@'localhost' IDENTIFIED BY 'railway_pass';
-- FLUSH PRIVILEGES;

SELECT 'Database schema created successfully!' AS status;
