#Tracking each student’s progress at a community college

CREATE SCHEMA `Prompt1_Database`;

CREATE TABLE `Prompt1_Database`.`Class` (
    `class_id` INT NOT NULL,
    `class_name` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`class_id`)
);
  
INSERT INTO `Prompt1_Database`.`Class`(`class_id`, `class_name`)
VALUES 
(101, "Geometry"),
(102, "English"),
(103, "Physics");

CREATE TABLE `Prompt1_Database`.`Student` (
    `student_id` INT NOT NULL,
    `first_name` VARCHAR(45) NOT NULL,
    `last_name` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`student_id`)
);
  
INSERT INTO `Prompt1_Database`.`Student` (`student_id`, `first_name`, `last_name`) 
VALUES 
(500, 'Robert', 'Smith'),
(762, 'Frank', 'Carter'),
(881, 'Joseph', 'Evans'),
(933, 'Anne', 'Baker');

CREATE TABLE `Prompt1_Database`.`Enrollment` (
    `class_id` INT NOT NULL,
    `student_id` INT NOT NULL,
    `semester` VARCHAR(45) NOT NULL,
    `grade` VARCHAR(20),
    FOREIGN KEY (class_id)
        REFERENCES Prompt1_Database.Class (class_id)
        ON UPDATE NO ACTION ON DELETE CASCADE,
    FOREIGN KEY (student_id)
        REFERENCES Prompt1_Database.Student (student_id)
        ON UPDATE NO ACTION ON DELETE CASCADE,
    PRIMARY KEY (`class_id` , `student_id` , `semester`)
);
  
INSERT INTO `Prompt1_Database`.`Enrollment` (`class_id`, `student_id`, `semester`, `grade`)
VALUES 
(101, 500, 'Fall 2019', 'A'),
(102, 500, 'Fall 2019', 'B'),
(103, 762, 'Fall 2019', 'F'),
(101, 881, 'Spring 2020', 'B'),
(102, 881, 'Fall 2020', 'B'),
(103, 762, 'Spring 2021', null);

-- Retrieving all columns from the Enrollment table where the grade of A or B was assigned
SELECT 
    *
FROM
    Prompt1_Database.Enrollment
WHERE
    grade = 'A' OR grade = 'B'
;

-- Returning the first and last names of each student who has taken Geometry
SELECT 
    first_name, last_name
FROM
    Prompt1_Database.Student s
        JOIN
    Prompt1_Database.Enrollment e ON s.student_id = e.student_id
        JOIN
    Class c ON e.class_id = c.class_id
WHERE
    class_name = 'Geometry';

-- Returning all rows from the Enrollment table where the student has not been given a failing grade (F)
SELECT 
    *
FROM
    Prompt1_Database.Enrollment
WHERE
    grade != 'F' OR grade IS NULL;

-- Returning the first and last names of every student in the Student table
SELECT 
    s.first_name, s.last_name, e.grade
FROM
    Prompt1_Database.Student s
        LEFT OUTER JOIN
    Prompt1_Database.Enrollment e ON s.student_id = e.student_id
        AND class_id = 102;

-- Returning the total number of students who have ever been enrolled in each of the classes
SELECT 
    class_id, COUNT(class_id) total_students_enrolled
FROM
    Prompt1_Database.Enrollment
GROUP BY (class_id);

-- Modifying Robert Smith’s grade for the English class from a B to a B+
UPDATE Prompt1_Database.Enrollment e 
SET 
    e.grade = 'B+'
WHERE
    student_id = 500 AND class_id = 102;
    
-- Creating an alternate statement to modify Robert Smith’s grade in English, but specifying the student by first/last name, not by student ID
UPDATE Prompt1_Database.Enrollment e 
SET 
    e.grade = 'B+'
WHERE
    e.student_id IN (SELECT 
            student_id
        FROM
            Student s
        WHERE
            first_name = 'Robert'
                AND last_name = 'Smith')
        AND e.class_id = 102;

-- Constructing a statement to add a new student (i.e. Michael Cronin enrolls in the Geometry class) to the Student table 
INSERT INTO Prompt1_Database.Student (student_id, first_name, last_name)
VALUES (900, 'Michael','Cronin');

-- Adding Michael Cronin’s enrollment in the Geometry class to the Enrollment table
INSERT INTO Prompt1_Database.Enrollment(class_id, student_id, semester,grade)
VALUES
(101, 900, "Spring 2020", null);

-- Returning the first and last names of all students who have not enrolled in any class
SELECT 
    first_name, last_name
FROM
    Prompt1_Database.Student s
WHERE
    student_id NOT IN (SELECT 
            student_id
        FROM
            Prompt1_Database.Enrollment e
        WHERE
            s.student_id = e.student_id);

-- Returning the same results as the previous question (first and last name of all students who have not enrolled in any class), but using a non-correlated subquery against the Enrollment table
SELECT 
    first_name, last_name
FROM
    Prompt1_Database.Student s
WHERE
    student_id NOT IN (SELECT 
            student_id
        FROM
            Prompt1_Database.Enrollment e);

-- Removing any rows from the Student table where the person has not enrolled in any classes
DELETE FROM Prompt1_Database.Student s 
WHERE student_id NOT IN 
(SELECT student_id FROM Prompt1_Database.Enrollment e);


