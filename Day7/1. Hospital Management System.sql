-- View to show name, age, and latest appointment (hide billing)
CREATE VIEW view_patient_summary AS
SELECT 
    p.patient_id,
    p.name,
    p.age,
    (SELECT MAX(appointment_date) FROM appointments a WHERE a.patient_id = p.patient_id) AS latest_appointment
FROM patients p;

-- Stored Procedure to add a visit and log it
DELIMITER //
CREATE PROCEDURE add_patient_visit(IN p_id INT, IN d_id INT, IN visit_date DATE)
BEGIN
    INSERT INTO visits (patient_id, doctor_id, visit_date) VALUES (p_id, d_id, visit_date);
    INSERT INTO visit_logs (patient_id, action, timestamp)
    VALUES (p_id, 'Visit Logged', NOW());
END;
//
DELIMITER ;

-- Function to get doctor's schedule
DELIMITER //
CREATE FUNCTION get_doctor_schedule(d_id INT)
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE schedule TEXT;
    SELECT GROUP_CONCAT(appointment_date ORDER BY appointment_date)
    INTO schedule
    FROM appointments
    WHERE doctor_id = d_id;
    RETURN schedule;
END;
//
DELIMITER ;

-- Trigger to update doctor availability after new appointment
DELIMITER //
CREATE TRIGGER after_insert_appointment
AFTER INSERT ON appointments
FOR EACH ROW
BEGIN
    UPDATE doctors
    SET availability = 'Booked'
    WHERE doctor_id = NEW.doctor_id;
END;
//
DELIMITER ;

-- Restrict non-admins to views (example abstraction)
GRANT SELECT ON view_patient_summary TO 'nurse_user'@'%';
REVOKE SELECT, INSERT, UPDATE, DELETE ON patients FROM 'nurse_user'@'%';
