3. University Result Management

-- View for subject-wise marks only
CREATE VIEW view_student_grades AS
SELECT student_id, subject_code, marks
FROM grades;

-- Procedure to update grade and audit
DELIMITER //
CREATE PROCEDURE update_grade(
  IN sid INT,
  IN sub_code VARCHAR(10),
  IN new_marks INT
)
BEGIN
  INSERT INTO grade_audit (student_id, subject_code, old_marks, new_marks, updated_at)
  SELECT student_id, subject_code, marks, new_marks, NOW()
  FROM grades
  WHERE student_id = sid AND subject_code = sub_code;
  
  UPDATE grades
  SET marks = new_marks
  WHERE student_id = sid AND subject_code = sub_code;
END;
//
DELIMITER ;

-- Function to calculate GPA
DELIMITER //
CREATE FUNCTION calculate_gpa(sid INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
BEGIN
  DECLARE gpa DECIMAL(4,2);
  SELECT AVG(marks) / 10.0 INTO gpa
  FROM grades
  WHERE student_id = sid;
  RETURN gpa;
END;
//
DELIMITER ;

-- Trigger to prevent update if locked
DELIMITER //
CREATE TRIGGER before_update_grades
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
  DECLARE is_locked BOOLEAN;
  SELECT locked INTO is_locked FROM students WHERE student_id = NEW.student_id;
  IF is_locked THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot update grades: Record is locked';
  END IF;
END;
//
DELIMITER ;

-- Abstracted final results view
CREATE VIEW view_final_results AS
SELECT student_id, subject_code, marks
FROM grades
WHERE finalized = TRUE;