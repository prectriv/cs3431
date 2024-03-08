/* Q1:
Find the meeting recordings of meetings which took place before '2023/01/17' (i.e.,
meeting�s meeting_time is before this date). Return the user_id and first name of the hosting
instructor as well as the id, title, and start time of the meeting, and the recording number. (Sort by
user_id, meeting_id, recording_number.) */

select distinct *
from (
    select distinct users.user_id, users.firstname, meeting.meeting_id, meeting.title, meetingrecording.start_time, meetingrecording.recording_number
    from meeting, meetingrecording, users
    where meeting.meeting_id = meetingrecording.meeting_id
    AND meeting.instructor_id = users.user_id
    ) temp
where to_char(temp.start_time,'YYYY-MM-DD') < '2023-01-17';
 
 
/* Q2:
Find the instructors who are teaching courses with 4 or more students enrolled in them. Return
the first name and last name of the instructor (user), the course_id and title of the course, and the
number of students enrolled. (Sort by course_id) */
select users.firstname, users.lastname, enrolledin.course_id, course.title, count(enrolledin.student_id)
from enrolledin
    join teaches on teaches.course_id = enrolledin.course_id
    join users on users.user_id = teaches.instructor_id
    join course on course.course_id = enrolledin.course_id
group by enrolledin.course_id, course.title, users.firstname, users.lastname
having count(enrolledin.student_id) >= 4
order by enrolledin.course_id;


/* Q3:
Find the pair of messages that are posted at the same meeting and at the same time but by
different users. Return the common meeting_id and message_time of the two messages as well as the
message_text and user_id of each message. */
select distinct message.meeting_id, message.message_time, message.message_text, m2.message_text, message.user_id, m2.user_id
from message m2
join message on message.user_id != m2.user_id 
    and to_char(message.message_time) = to_char(m2.message_time)
    and message.meeting_id = m2.meeting_id
where message.user_id < m2.user_id;


/* Q4
Find the distinct instructors whose academic fields include both �Machine Learning� and
�Artificial Intelligence� and who are teaching more than two courses (each). Return the first and last
name of those instructors. */
(select distinct users.firstname, users.lastname
from instructor
    join academicfields on instructor.instructor_id = academicfields.instructor_id
    join users on instructor.instructor_id = users.user_id
where academicfields.academicfield = 'Machine Learning')
intersect
(select distinct users.firstname, users.lastname
from instructor
    join academicfields on instructor.instructor_id = academicfields.instructor_id
    join users on instructor.instructor_id = users.user_id
where academicfields.academicfield = 'Artificial Intelligence')
order by firstname;


/* Q5a
Find the meetings whose durations are longer than the average duration of all meetings.
Return the meeting_id, title, passcode, meeting_time, duration, course_id, and hosting instructor�s id
for those meetings. (Sort by meeting_id) */
select m2.meeting_id, m2.title, m2.passcode, m2.meeting_time, m2.duration, m2.course_id, m2.instructor_id
from meeting m1, meeting m2
group by m2.meeting_id, m2.title, m2.passcode, m2.meeting_time, m2.duration, m2.course_id, m2.instructor_id
having avg(m1.duration) < m2.duration
order by m2.meeting_id;


/* Q5b
Find the meetings whose durations are longer than the average duration of the meetings for
the course they belong to. Return the meeting_id, title, passcode, meeting_time, duration, course_id,
and hosting instructor�s id for those meetings. (Sort by meeting_id) */
select m2.meeting_id, m2.title, m2.passcode, m2.meeting_time, m2.duration, m2.course_id, m2.instructor_id
from meeting m1, meeting m2
where m1.course_id = m2.course_id
group by m2.meeting_id, m2.title, m2.passcode, m2.meeting_time, m2.duration, m2.course_id, m2.instructor_id
having avg(m1.duration) < m2.duration
order by m2.meeting_id;


/* Q6 
Find the students who didn�t attend any meetings of a course that they are enrolled in. Return
the student_ids of those students and the courses which they are enrolled in but didn�t attend the
meetings of. You should only include the courses that have meetings in the query results (i.e., the
courses that appear in the Meeting table). Sort results by student_id. */
select student.student_id, meeting.course_id
from student
    join enrolledin on enrolledin.student_id = student.student_id
    join course on course.course_id = enrolledin.course_id
    join meeting on meeting.course_id = course.course_id
where not exists (
    select distinct *
    from attended
    where attended.student_id = student.student_id and attended.meeting_id = meeting.meeting_id
)   
group by student.student_id, meeting.course_id
order by student.student_id;


/* Q7
Find the �CS451� students (i.e., the student enrolled in CS451) who didn�t attend a
meeting of the �CS451� course, but they watched that meeting�s recording. Return the
student_id, meeting�s id and title, and recording_number of the recording student watched.
(Sort results by student_id) */
select student_id, meeting_id, title, recording_number 
    from (
    select distinct student.student_id, meeting.meeting_id, meeting.title, watched.recording_number 
        from student
            join watched on watched.student_id = student.student_id
            join meetingrecording on meetingrecording.recording_number = watched.recording_number
            join meeting on meeting.meeting_id  = meetingrecording.meeting_id
        where meeting.title like '%451%'
        )
    where not exists ( --unsure as to why this one specifically does not work. Wasn't able to get this to filter properly.
        select *
        from attended 
        where attended.student_id = student_id
    );


/* Q8
Find the user who posted the most recent message (message with the max date) for a
'CS' course (i.e, course_id starts with 'CS'). Return the id , firstname, and lastname of the user
as well as the message text and the meeting message is posted in. */

select user_id, firstname, lastname, message_text, meeting_id 
from (
    select users.user_id, users.firstname, users.lastname, m2.message_text, m2.message_time, meeting.meeting_id
    from message m1, message m2
        join users on users.user_id = m2.user_id
        join meeting on meeting.meeting_id = m2.meeting_id
        join course on course.course_id = meeting.course_id
    where exists (
        select * 
        from course
        where course.course_id like 'CS%'
        )
    group by users.user_id, users.firstname, users.lastname, m2.message_text, m2.message_time, meeting.meeting_id
    having max(m1.message_time) = m2.message_time
);


/* Q9:
For each meeting return the following (sort by meeting_id):
a. meeting_id;
b. meeting title;
c. number of students attended that meeting; and
d. number of recordings for that meeting. */

select meeting.meeting_id, meeting.title, count(distinct attended.student_id) as user_count, count(distinct meetingrecording.recording_number) as record_count
from meeting
    join attended on meeting.meeting_id = attended.meeting_id
    join meetingrecording on meeting.meeting_id = meetingrecording.meeting_id
group by meeting.meeting_id, meeting.title
order by meeting.meeting_id;