--1.
SELECT business_id, name, street_address, num_tips
from (
    (select business.business_id, business.name, business.street_address, business.num_tips
       from Business
                join businesscategories on business.business_id = businesscategories.business_id
       where business.state = 'AZ'
         and business.city = 'Scottsdale'
         and businesscategories.category_name = 'Restaurants')
      INTERSECT
      (select business.business_id, business.name, business.street_address, business.num_tips
       from Business
                join businesscategories on business.business_id = businesscategories.business_id
       where business.state = 'AZ'
         and business.city = 'Scottsdale'
         and businesscategories.category_name = 'Breakfast & Brunch')
      INTERSECT
      (select business.business_id, business.name, business.street_address, business.num_tips
       from Business
                join businesscategories on business.business_id = businesscategories.business_id
       where business.state = 'AZ'
         and business.city = 'Scottsdale'
         and businesscategories.category_name = 'Bakeries')
      ) as b
 order by name;

--2.
SELECT *
from ( ((SELECT Businessattributes.business_id, name, street_address,state, city, num_tips
    FROM Business
    JOIN businessattributes on Businessattributes.business_id = Business.business_id
    AND(
        (city = 'Scottsdale' AND state = 'AZ')
        AND
        (attribute_name = 'WiFi' AND value = 'free' ))
    ORDER BY Business.name)
    intersect
        (SELECT Businessattributes.business_id, name, street_address,state, city, num_tips
        FROM Business
        JOIN businessattributes on Businessattributes.business_id = Business.business_id
        AND(
            (city = 'Scottsdale' AND state = 'AZ')
            AND
            (attribute_name = 'BusinessAcceptsCreditCards' AND value = 'True' ))
        ORDER BY Business.name)
    intersect
        (SELECT Businessattributes.business_id, name, street_address,state, city, num_tips
        FROM Business
        JOIN businessattributes on Businessattributes.business_id = Business.business_id
        AND(
            (city = 'Scottsdale' AND state = 'AZ')
            AND
            (attribute_name = 'ByAppointmentOnly' AND value = 'True' ))
       )
    )
) as Filter
order by name;

--3.
SELECT businesscategories.category_name, COUNT(businesscategories.category_name)
FROM Business
JOIN Businesscategories on Business.business_id = Businesscategories.business_id
WHERE Business.zipcode = '85251' AND is_open = true
GROUP BY businesscategories.category_name
ORDER BY COUNT(businesscategories.category_name) DESC;

--4.
CREATE VIEW q4Temp AS
    SELECT *
    FROM (Select business.business_id, business.name, street_address, num_tips
    from businesscategories
    JOIN Business on Businesscategories.business_id = Business.business_id
    WHERE zipcode = '85251' AND category_name = 'Restaurants') as t;

SELECT *
    FROM q4Temp
WHERE (SELECT MAX(num_tips)
    FROM q4Temp) = num_tips
;

--5.
SELECT Business.name, street_address, zipcode, Business.num_tips, Users.name, Tips.tip_text, Tips.tip_timestamp
FROM Business
JOIN Tips ON Business.business_id = Tips.business_id
JOIN Users ON Tips.user_id = Users.user_id
JOIN Friends ON Users.user_id = Friends.friend_id
WHERE Business.city = 'Phoenix'
AND Business.state = 'AZ'
AND Friends.user_id = 'TiWF94rl8Q6jqQf2YZSFPA'
ORDER BY Business.name
;

--6.
CREATE OR REPLACE VIEW q6Temp AS
SELECT Users.name, tip_timestamp, tip_text
FROM( SELECT friend_id
    FROM USERS
    JOIN FRIENDS on USERS.user_id = FRIENDS.user_id
    WHERE Users.user_id = 'TiWF94rl8Q6jqQf2YZSFPA') as t
JOIN Users on friend_id = Users.user_id
JOIN Tips on Users.user_id = Tips.user_id;

SELECT *
FROM q6Temp
WHERE (SELECT MAX(tip_timestamp)
       FROM q6Temp) = tip_timestamp;



SELECT name, tip_timestamp, likes, tip_text
FROM tips
    join users on tips.user_id = users.user_id
where business_id = 'yMBCem_MQYWdK1Hdratz4w';
