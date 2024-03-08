CREATE OR REPLACE FUNCTION UpdateBusinessTipCount()
RETURNS trigger AS $$
BEGIN
    UPDATE business
    Set num_tips =
        (SELECT count(TIPS.business_id)
        FROM Tips
        WHERE Tips.business_id = business.business_id)+1
    WHERE business_id = NEW.business_id;
    RETURN NEW;
END

$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER BusinessTipInsertTrigger
    AFTER INSERT ON Tips
    FOR EACH ROW
    EXECUTE FUNCTION UpdateBusinessTipCount();


CREATE OR REPLACE FUNCTION UpdateUserTipCount()
RETURNS trigger AS $$
BEGIN
    UPDATE users
    Set tip_count = (SELECT count(Tips.user_id)
        FROM Tips
        WHERE Tips.user_id = users.user_id) +1
    WHERE user_id = NEW.user_id;
    RETURN NEW;
END

$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER UserTipInsertTrigger
    AFTER INSERT ON Tips
    FOR EACH ROW
    EXECUTE FUNCTION UpdateUserTipCount();


/*
********************THESE TESTS SHOULD ALL WORK*************************

--TEST TRIGGER 1
INSERT INTO Tips VALUES('5KheTjYPu1HcQzQFtm4_vw', 'jRyO2V1pA4CdVVqCIOPc1Q', '2012-12-26 01:46:17.000000', 'test tip 1', 0);
SELECT * FROM Business WHERE Business_id = '5KheTjYPu1HcQzQFtm4_vw';

--CLEAN TEST 1
DELETE FROM TIPS WHERE business_id = '5KheTjYPu1HcQzQFtm4_vw' AND user_id = '5KheTjYPu1HcQzQFtm4_vw' AND tip_timestamp = '2012-12-26 01:46:17.000000' AND tip_text = 'test tip 1' AND likes = 0;

--Test 2
SELECT *
FROM business
WHERE business_id = 'jYU4Nd71giCWpLuj5JIxgg';

SELECT *
FROM Tips  --Expect 4 tips
WHERE business_id = 'jYU4Nd71giCWpLuj5JIxgg';

--Test 3
SELECT * FROM Business WHERE business_id = 'dQj5DLZjeDK3KFysh1SYOQ';

--EXPECT 7 Tips
SELECT * FROM Tips WHERE Business_id = 'dQj5DLZjeDK3KFysh1SYOQ';

--Test 4
SELECT * FROM Users WHERE user_id = 'DYqujEDnSMgwL7sFTRSv8w';

--EXPECT 68 TIPS
SELECT * FROM Tips WHERE user_id = 'DYqujEDnSMgwL7sFTRSv8w';

 */