/* Q1: 
Find the meetings which are hosted by the instructor of `CS321’ (i.e., 
hosted by the instructor who teaches ‘CS321’). Return the meeting title and
the course_id for the meeting, and instructor’s first and last names. Order
the results by meeting course_id and meeting title.
*/
R1 = Meeting ⨝ (Meeting.instructor_id = Teaches.instructor_id) (σ course_id = 'CS321'(Teaches))
R2 = R1 ⨝ (User.user_id = Teaches.instructor_id) πuser_id,firstName, lastName (User)

τMeeting.course_id(πMeeting.title,Meeting.course_id,User.firstName,User.lastName(R2))

/* Q2:
Find the courses offered by instructors having ' Regents Professor' title. Return the course_id, title,
and description of those courses.
*/
R1 = (σ title='Regents Professor' Instructor) ⨝ Teaches
π Course.course_id,Course.title,Course.description (Course ⨝ (course_id=Teaches.course_id) (R1))

/* Q3:
Find the student users who did not post any messages. Return the student_id, email, first and last
name of those students.
*/
R1 = (σ Message.message_id = null (User ⟕ Message))
Student ⨝ (Student.student_id = User.user_id) R1

/* Q4:
Find the instructors who work in the “Machine Learning” field but are not teaching any courses.
Return the instructor_ids, firstNames, lastNames, and emails of them.
*/
R1 = (σ academicfield='Machine Learning' AcademicFields) ⟕ Teaches
R2 = Instructor ⨝ (σ Teaches.course_id = null R1)

πInstructor.instructor_id,User.firstName,User.lastName,User.email (R2 ⨝(Instructor.instructor_id = User.user_id) User)

/* Q5:
Find the students who watched a recording of a meeting of the 'CS451' course, but they didn’tattend that meeting.
Return the student_id, meeting’s title, meeting’s course_id, and recording_number of the recording student watched.
*/
R1 = (σAttended.from_timestamp = null ((Watched ⨝ Student) ⟕ Attended) ⨝ Meeting)

πWatched.student_id,Meeting.title,Meeting.course_id,MeetingRecording.recording_number (MeetingRecording ⨝ R1)

/* Q6:
Find the instructors who hosted 3 or more meetings that are associated with the same course.
Return the course_id, number of meetings, and the first and last name of the instructor.
*/
R1 = Instructor ⨝(Instructor.instructor_id = Meeting.instructor_id) Meeting
R2 = User ⨝(User.user_id = Instructor.instructor_id) R1
R3 = γ Meeting.course_id,firstName,lastName; COUNT(Meeting.course_id) → num_courses R2
R4 = πMeeting.course_id,num_courses,User.firstName,User.lastName(σ num_courses >= 3(R3))
τ num_courses desc(R4)

/* Q7:
Find the users who are mentioned 2 or more times in the messages of a CS451 meeting (‘CS451’ is
the id of the course associated with the meeting.) Return the user_id, email, firstName and lastName of
the user mentioned and the number of times they are mentioned.
*/ 
R1 = (σ Course.course_id = 'CS451' (Course)) ⨝(Course.course_id = Meeting.course_id) Meeting 
R2 = R1 ⨝(Meeting.meeting_id = Mentions.meeting_id) Mentions
R3 = γ Mentions.user_id ; COUNT(Mentions.user_id)→num_mentions R2

σ num_mentions ≥ 2 (R3) ⨝ User


/* Q8:
Find the meetings for which the number of messages posted by instructors is greater than the
number of messages posted by students. Return the meeting_id, number of messages by
instructors, and the number of messages by students for those meetings
*/
I1 = Instructor ⨝(instructor_id = user_id) Message
I2 = γ Message.meeting_id; COUNT(Message.user_id) → num_of_instructors (σ user_id = Instructor.instructor_id (I1))

S1 = Student ⨝(student_id = user_id) Message
S2 = γ Message.meeting_id; COUNT(Message.user_id) → num_of_students (σ user_id = Student.student_id (S1))

σ num_of_instructors > num_of_students (I2⨝S2)


/* Q9:
Find the longest meeting(s) (i.e., the meetings with max duration). Return the meeting_id, title and duration of those meeting(s).
*/
R1 = γ MAX(duration)→maxNum (Meeting)
R2 = Meeting ⨝(duration=maxNum) R1
π Meeting.meeting_id,Meeting.title,Meeting.duration R2

/* Q10
Find the meeting(s) with the most number of attendees. Return the meeting title and the number
of attendees for those meeting(s).
*/
R1 = γ meeting_id; COUNT(meeting_id) -> count (Attended)
R2 = γ MAX(count)→max_attended (R1)

πMeeting.title, max_attended (Meeting ⟖ (R1 ⨝(count = max_attended) R2))