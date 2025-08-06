-- View: Attendance Summary (hide contact)
CREATE VIEW view_attendance_summary AS
SELECT a.attendance_id, m.member_name, s.session_name, a.attended_on
FROM attendance a
JOIN members m ON a.member_id = m.member_id
JOIN sessions s ON a.session_id = s.session_id;

-- Procedure: Log Attendance
DELIMITER $$
CREATE PROCEDURE log_attendance(IN m_id INT, IN s_id INT)
BEGIN
  INSERT INTO attendance(member_id, session_id, attended_on)
  VALUES (m_id, s_id, CURDATE());
END$$
DELIMITER ;

-- Function: Monthly Visits
DELIMITER $$
CREATE FUNCTION get_monthly_visits(m_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE visits INT;
  SELECT COUNT(*) INTO visits
  FROM attendance
  WHERE member_id = m_id AND MONTH(attended_on) = MONTH(CURDATE());
  RETURN visits;
END$$
DELIMITER ;

-- Trigger: After Attendance gives points
DELIMITER $$
CREATE TRIGGER after_attendance
AFTER INSERT ON attendance
FOR EACH ROW
BEGIN
  UPDATE members SET points = points + 1 WHERE member_id = NEW.member_id;
END$$
DELIMITER ;

-- Public View: Active Members
CREATE VIEW view_active_members AS
SELECT member_name FROM members WHERE status = 'Active';
