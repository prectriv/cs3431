DROP TABLE Tips;
DROP TABLE Friends;
DROP TABLE BusinessCategories;
DROP TABLE BusinessAttributes;
DROP TABLE Business;
DROP TABLE Users;

    CREATE TABLE Users(
        user_id CHAR (22),
        name VARCHAR,
        average_stars FLOAT,
        funny_score FLOAT,
        useful_score FLOAT,
        cool_score FLOAT,
        num_fans INTEGER,
        tip_count INTEGER,
        yelping_since DATE,
        PRIMARY KEY (user_id)
    );

    CREATE TABLE Friends(
        user_id CHAR (22),
        friend_id CHAR (22),
        PRIMARY KEY (user_id, friend_id),
        FOREIGN KEY (user_id) REFERENCES Users(user_id)
    );

    CREATE TABLE Business(
        business_id CHAR(22),
        name VARCHAR,
        star_rating FLOAT,
        street_address VARCHAR,
        city VARCHAR,
        zipcode VARCHAR(10),
        state VARCHAR(20),
        num_tips INTEGER,
        is_open BOOLEAN,
        latitude DECIMAL(8,6),
        longitude DECIMAL(9,6),
        PRIMARY KEY (business_id)
    );

    CREATE TABLE BusinessCategories(
        business_id char (22),
        category_name VARCHAR(150),
        primary key (business_id, category_name),
        foreign key (business_id) references Business

    );

    CREATE TABLE BusinessAttributes(
        business_id char (22),
        attribute_name VARCHAR (150),
        value VARCHAR,
        primary key (business_id, attribute_name),
        foreign key (business_id) references Business
    );

    CREATE TABLE Tips(
        business_id CHAR (22),
        user_id CHAR (22),
        tip_timestamp TIMESTAMP,
        tip_text TEXT,
        likes INTEGER,
        primary key (business_id, user_id, tip_timestamp),
        foreign key (business_id) references Business,
        foreign key (user_id) references Users
    );