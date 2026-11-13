-- HOTEL ROOM BOOKING SYSTEM
-- DBMS Mini Project | MySQL 8.0+

CREATE DATABASE IF NOT EXISTS hotel_booking_db;
USE hotel_booking_db;

DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Rooms;
DROP TABLE IF EXISTS Guests;

CREATE TABLE Guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(120) UNIQUE,
    city VARCHAR(60)
);

CREATE TABLE Rooms (
    room_id INT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type VARCHAR(30) NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL CHECK (price_per_night > 0),
    room_status ENUM('Available','Occupied','Maintenance') DEFAULT 'Available'
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    booking_status ENUM('Confirmed','Checked-In','Checked-Out','Cancelled') DEFAULT 'Confirmed',
    CONSTRAINT fk_booking_guest FOREIGN KEY (guest_id) REFERENCES Guests(guest_id),
    CONSTRAINT fk_booking_room FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    CONSTRAINT chk_dates CHECK (check_out > check_in)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    payment_date DATE NOT NULL,
    payment_method ENUM('Cash','Card','UPI','Net Banking') NOT NULL,
    payment_status ENUM('Paid','Pending','Refunded') DEFAULT 'Pending',
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

INSERT INTO Guests (full_name, phone, email, city) VALUES
('Aarav Sharma','9876500001','aarav@example.com','Chandigarh'),
('Meera Kapoor','9876500002','meera@example.com','Delhi'),
('Kabir Singh','9876500003','kabir@example.com','Amritsar'),
('Ananya Verma','9876500004','ananya@example.com','Jaipur');

INSERT INTO Rooms (room_id, room_number, room_type, price_per_night, room_status) VALUES
(101,'101','Single',1800.00,'Available'),
(102,'102','Double',2800.00,'Occupied'),
(103,'103','Deluxe',4200.00,'Available'),
(104,'104','Suite',6500.00,'Maintenance'),
(105,'105','Double',2800.00,'Available');

INSERT INTO Bookings (guest_id, room_id, check_in, check_out, booking_status) VALUES
(1,102,'2026-11-01','2026-11-04','Confirmed'),
(2,103,'2026-11-02','2026-11-05','Confirmed'),
(3,105,'2026-11-10','2026-11-12','Cancelled');

INSERT INTO Payments (booking_id, amount, payment_date, payment_method, payment_status) VALUES
(1,8400.00,'2026-10-28','UPI','Paid'),
(2,12600.00,'2026-10-28','Card','Pending'),
(3,5600.00,'2026-10-28','Cash','Refunded');

-- Q1: View all available rooms
SELECT room_number, room_type, price_per_night
FROM Rooms
WHERE room_status = 'Available'
ORDER BY price_per_night;

-- Q2: Booking details with guest and room information
SELECT b.booking_id, g.full_name, r.room_number, r.room_type,
       b.check_in, b.check_out, b.booking_status
FROM Bookings b
JOIN Guests g ON b.guest_id = g.guest_id
JOIN Rooms r ON b.room_id = r.room_id
ORDER BY b.booking_id;

-- Q3: Total revenue collected from successful payments
SELECT SUM(amount) AS total_revenue
FROM Payments
WHERE payment_status = 'Paid';

-- Q4: Count bookings by status
SELECT booking_status, COUNT(*) AS total_bookings
FROM Bookings
GROUP BY booking_status;

-- Q5: Find rooms costing more than the average room rate
SELECT room_number, room_type, price_per_night
FROM Rooms
WHERE price_per_night > (SELECT AVG(price_per_night) FROM Rooms);

-- Q6: Pending payments with guest names
SELECT g.full_name, b.booking_id, p.amount, p.payment_method, p.payment_status
FROM Payments p
JOIN Bookings b ON p.booking_id = b.booking_id
JOIN Guests g ON b.guest_id = g.guest_id
WHERE p.payment_status = 'Pending';

-- Q7: Demonstrate a transaction (example: mark a payment as paid)
START TRANSACTION;
UPDATE Payments SET payment_status = 'Paid' WHERE payment_id = 2;
COMMIT;

-- Q8: Example view for reception staff
CREATE OR REPLACE VIEW BookingRegister AS
SELECT b.booking_id, g.full_name, r.room_number, b.check_in, b.check_out,
       b.booking_status
FROM Bookings b
JOIN Guests g ON b.guest_id = g.guest_id
JOIN Rooms r ON b.room_id = r.room_id;
SELECT * FROM BookingRegister;
