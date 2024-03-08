/* Q1:
Write an Oracle PL/SQL function named �is_student� that takes a �user_id� as parameter (assume IN
parameter) and checks whether the given �user_id� is a student or an instructor user (i.e., whether it
appears in instructor table vs student table). It returns the string �student� if it is a student user and
returns string �instructor� otherwise.
o You can assume that a user is either student or instructor and not both.
o Hints: (a) You can define the return type of the function as �VARCHAR2� (don�t use a size for
VARCHAR2 for the return type) (b) You can make use of cursors to check whether the given
�user_id� appears in student or instructor table. */
CREATE OR REPLACE FUNCTION is_student(
    user_id IN INTEGER) RETURN VARCHAR2
IS
    result VARCHAR2(20);
    v_student_id Users.user_id%TYPE;

BEGIN
    SELECT student_id INTO v_student_id
    FROM Student
    WHERE student_id = user_id;

    IF v_student_id IS NOT NULL THEN
        result := 'student';
    ELSE
        result := 'instructor';
    END IF;

    RETURN result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle exception when user_id does not exist in either table
        RETURN 'instructor';

END;
/

-- b. Write a SELECT statement that uses the �is_student� function either in the SELECT part or the WHERE condition. 
SELECT
    users.user_id,
    is_student(users.user_id) AS user_type
FROM
    users
WHERE
    users.user_id = 5; -- replace this integer with waht you want to search.
    
    
/* Q2:
Write an Oracle PL/SQL stores procedure named �insert_instructor� that inserts an instructor�s
data to the database. The procedure will have the following �IN� parameters: instructor_id, email,
firstname, lastname, and title.
o You can use type VARCHAR2 for the string parameters and NUMBER for the numeric parameters.
o Since �instructor_id� is a foreign key referring to the �Users.user_id�, the procedure first should
insert a tuple to the �Users� table then to the �Instructor� table */
CREATE OR REPLACE PROCEDURE insert_instructor(
    new_instructor_id IN NUMBER,
    new_email IN VARCHAR2,
    new_firstname IN VARCHAR2,
    new_lastname IN VARCHAR2,
    new_title IN VARCHAR2
)
IS
BEGIN
    INSERT INTO Users (user_id, email, firstname, lastname)
    VALUES (new_instructor_id, new_email, new_firstname, new_lastname);

    INSERT INTO Instructor (instructor_id, title)
    VALUES (new_instructor_id, new_title);
    
END;
/

--Write a test statement calling the stored procedure.
BEGIN
    insert_instructor(
        new_instructor_id => 45,
        new_email => 'email@doaei.tld',
        new_firstname => 'name',
        new_lastname => 'lastname',
        new_title => 'Prof'
    );
END;
/

select *
from users
join instructor on users.user_id = instructor.instructor_id
where users.user_id = 45;

/* Q3:
Write an Oracle PL/SQL trigger named �check_passcode� that enforces the following constraint:
�If a meeting is associated with a course (i.e., course_id is not NULL for the meeting), it should use a
passcode (i.e., its passcode can�t be NULL.)�
o The trigger should raise an application error with an appropriate message if the constraint is
violated when a new meeting is inserted or a meeting is updated.
*/

CREATE OR REPLACE TRIGGER check_passcode
AFTER INSERT OR UPDATE OF passcode ON Meeting
FOR EACH ROW
BEGIN
    IF :NEW.course_id IS NOT NULL AND :NEW.passcode IS NULL THEN
        RAISE_APPLICATION_ERROR(-20004, 'A meeting associated with a course must have a passcode.');
    END IF;
END;
/

--Insert statement that will raise an error
BEGIN
    INSERT INTO Meeting (meeting_id, title, passcode, meeting_time, duration, course_id, instructor_id)
    VALUES (1001, 'Test Meeting', NULL, SYSDATE, 60, 'CS215', 1);
END;

--update statement that will raise an error
BEGIN
    UPDATE Meeting
    SET passcode = NULL
    WHERE meeting_id = 1;
END;


/* Q4
Write an Oracle PL/SQL trigger named �set_description� that enforces the following constraint:
�The description of a course can�t be NULL. When a new course is added or an existing course is
updated, if no description is provided (i.e., description is NULL), the course title should be set as the
default description. �*/
CREATE OR REPLACE TRIGGER set_description
AFTER INSERT OR UPDATE OF description ON course
DECLARE
    CURSOR course_cursor IS
        SELECT course_id, title
        FROM Course
        WHERE description IS NULL OR description = '';

BEGIN
    FOR c IN course_cursor LOOP
        UPDATE Course
        SET description = c.course_id
        WHERE course_id = c.course_id;
    END LOOP;
END;
/

--Insert statement that will raise an error
BEGIN
    INSERT INTO course (course_id, title, description)
    VALUES ('CS999', 'Course', NULL);
END;

SELECT * 
FROM course
where course.course_id = 'CS999';


--update statement that will raise an error
BEGIN
    UPDATE course
    SET description = NULL
    WHERE course_id = 'CS437';
END;

SELECT *
FROM Course
where course.course_id = 'CS437';

/* Q5:
Write an Oracle PL/SQL trigger named �message_length� that enforces the following constraint:
�The messages posted by students can�t be longer than 40 characters. Only the instructors can post
messages longer than 40 characters. �
o When a new message is posted, the trigger should check the message length and user who
posted the message.
o If the message length is more than 40 and if the posting user is a student, it should raise an
application error with appropriate error message and the new message should not be inserted.
o If the posting use is an instructor, the insertion should succeed (even if the message is longer
than 40).
Hints: You can use the �is_student� function you defined in �question 1� to check if the user is a
student user. (b) You can use the Oracle �length� function to check the length of a �message_text�. */
CREATE OR REPLACE TRIGGER message_length
BEFORE INSERT ON Message
FOR EACH ROW
DECLARE
    user_type VARCHAR2(20);
BEGIN
    user_type := is_student(:NEW.user_id);
    
    IF LENGTH(:NEW.message_text) > 40 AND user_type = 'student' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Messages posted by students cannot exceed 40 characters.');
    END IF;
END;
/

--STUDENT MESSAGE
INSERT INTO Message (Message_id, meeting_id, message_time, message_text, user_id)
        VALUES (100, 1, SYSDATE, 'This message is over fourty characters long', 5);

--INSTRUCTOR MESSAGE
INSERT INTO Message (Message_id, meeting_id, message_time, message_text, user_id)
        VALUES (100, 1, SYSDATE, 'This message is over fourty characters long', 1);

DELETE FROM MESSAGE
WHERE message_text = 'This message is over fourty characters long';

