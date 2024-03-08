CREATE TABLE Usr (
    userID INT,
    firstName VARCHAR2(20),
    lastName VARCHAR2(20),
    email VARCHAR2(50) UNIQUE,
    password VARCHAR2(100),
    pronouns VARCHAR2(50),
    PRIMARY KEY (userID)
);

CREATE TABLE Student (
    studentID INT PRIMARY KEY,
        FOREIGN KEY (studentID) REFERENCES Usr(userID)
);

CREATE TABLE Instructor ( -- Cannot enforce the 1...* constraint
    instructorID INT,
    title VARCHAR2(20),
    PRIMARY KEY (instructorID),
        FOREIGN KEY (instructorID) REFERENCES Usr(userID)
);

CREATE TABLE AcademicFields (
    instructorID INT,
    fieldNames VARCHAR2(50),
    PRIMARY KEY (instructorID),
        FOREIGN KEY (instructorID) REFERENCES Instructor(instructorID)
);

CREATE TABLE Course (
    courseID INT,
    title VARCHAR2(50),
    courseDescription VARCHAR2(100),
    PRIMARY KEY (courseID)
);

CREATE TABLE EnrolledIn (
    studentID INT,
    courseID INT,
    enrollment_date DATE,
    PRIMARY KEY (studentID, courseID),
        FOREIGN KEY (studentID) REFERENCES Student(studentID),
        FOREIGN KEY (courseID) REFERENCES Course(courseID)
);

CREATE TABLE Teaches (
    instructorID INT,
    courseID INT,
    PRIMARY KEY (instructorID, courseID),
        FOREIGN KEY (instructorID) REFERENCES Instructor(instructorID),
        FOREIGN KEY (courseID) REFERENCES Course(courseID)
);
CREATE TABLE Meeting ( -- Cannot enforce at most one constraint with course association
    meetingID INT,
    title VARCHAR2(50),
    password VARCHAR2(100),
    duration INT,
    startTime TIMESTAMP,
    courseID INT,
        FOREIGN KEY (courseID) REFERENCES Course(courseID),
    instructorID INT NOT NULL,
        FOREIGN KEY (instructorID) REFERENCES Instructor(instructorID),
    PRIMARY KEY (meetingID)
);

CREATE TABLE Attended (
    studentID INT,
    meetingID INT,
    joinTime TIMESTAMP,
    leaveTime TIMESTAMP,
    PRIMARY KEY (studentID, meetingID),
        FOREIGN KEY (studentID) REFERENCES Student(studentID),
        FOREIGN KEY (meetingID) REFERENCES Meeting(meetingID)
);

CREATE TABLE MeetingRecording (
    recordingNumber INT,
    startTime TIMESTAMP,
    endTime TIMESTAMP,
    meetingID INT,
    PRIMARY KEY (meetingID, recordingNumber),
        FOREIGN KEY (meetingID) REFERENCES Meeting(meetingID)
);


CREATE TABLE Watched (
    studentID INT,
    meetingID INT,
    recordingNumber INT,
    PRIMARY KEY (studentID, meetingID, recordingNumber),
        FOREIGN KEY (studentID) REFERENCES Student(studentID),
        FOREIGN KEY (meetingID, recordingNumber) REFERENCES MeetingRecording(meetingID, recordingNumber)
);

CREATE TABLE Tags (
    meetingID INT,
    recordingNumber INT,
    tags VARCHAR2(50),
    PRIMARY KEY (meetingID, recordingNumber),
        FOREIGN KEY (meetingID, recordingNumber) REFERENCES MeetingRecording(meetingID, recordingNumber)
);

CREATE TABLE Message (
    messageID INT,
    text VARCHAR2(500),
    time TIMESTAMP,
    meetingID INT,
    userID INT NOT NULL,
        FOREIGN KEY (userID) REFERENCES Usr(userID),
    PRIMARY KEY (messageID, meetingID),
        FOREIGN KEY (meetingID) REFERENCES Meeting(meetingID)
);

CREATE TABLE Mentions (
    messageID INT,
    meetingID INT,
    studentID INT,
    PRIMARY KEY (messageID, meetingID, studentID),
        FOREIGN KEY (messageID, meetingID) REFERENCES Message(messageID, meetingID),
        FOREIGN KEY (studentID) REFERENCES Student(studentID)
);