# A file majorly based off of the sample code provided by Prof. Sakire Arslan Ay

# Make sure to check the "TODO" comments in the code and make the required edits before you run the code. 

import json
import psycopg2

"""cleanStr4SQL function removes the "single quote" or "back quote" characters from strings. """
def cleanStr4SQL(s):
    return s.replace("'","`").replace("\n"," ")

def insert2BusinessTable():
    #reading the JSON file
    with open('.//yelp_business.JSON','r') as f:    #TODO: update path for the input file
        line = f.readline()
        count_business = 0
        count_cats = 0
        conut_attr = 0

        #connect to yelpdb database on postgres server using psycopg2
        try:
            #TODO: update the database name, username, and password
            conn = psycopg2.connect("dbname='yelpdb' user='xavier' host='localhost' password='0509'")
        except:
            print('Unable to connect to the database!')
        cur = conn.cursor()

        while line:
            data = json.loads(line)
            # Generate the INSERT statement for the current business
            # TODO: The below INSERT statement is based on a simple (and incomplete) businesstable schema. Update the statement based on your own table schema and
            # include values for all businessTable attributes
            try:
                cur.execute("INSERT INTO Business (business_id, name, star_rating, street_address, city, zipcode, state, num_tips, is_open, latitude, longitude)"
                    + " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) ", 
                    (data['business_id'],cleanStr4SQL(data["name"]), data["stars"], cleanStr4SQL(data["address"]), data["city"], data["postal_code"], data["state"], 0, data["is_open"] == 1, data["latitude"], data["longitude"]))  \
            
                count_business += 1
                
            except Exception as e:
                print("Insert to business failed!",e)

            # categories
            try:   
                for category in data["categories"].split(', '):
                    cur.execute("INSERT INTO BusinessCategories (business_id, category_name) VALUES (%s, %s)", (data['business_id'], cleanStr4SQL(category)))    
                    count_cats += 1

            except Exception as e:
                print("Insert to business category failed!",e)

            # Attributes
            try:
                attributes = data["attributes"]
                for key in attributes:
                    val = attributes[key]
                    if(isinstance(val, dict)): ## 2-layer dictionaries
                        for key2 in val:
                            conut_attr += 1
                            val2 = val[key2]
                            cur.execute(
                                    "INSERT INTO BusinessAttributes (business_id, attribute_name, value) VALUES (%s, %s, %s)",
                                    (data["business_id"], key2, val2))
                            
                    else:
                        conut_attr += 1
                        cur.execute(
                            "INSERT INTO BusinessAttributes (business_id, attribute_name, value) VALUES (%s, %s, %s)",
                            (data["business_id"], key, val))
                        

            except Exception as e:
                print("Insert to business attributes failed!",e)

            conn.commit()
            line = f.readline()

        cur.close()
        conn.close()

    print("Business:", count_business)
    print("Categories:", count_cats)
    print("Attributes:", conut_attr)
    #outfile.close()  #uncomment this line if you are writing the INSERT statements to an output file.
    f.close()


def insert2UserTable():
    #reading the JSON file
    with open('.//yelp_user.JSON','r') as f:    #TODO: update path for the input file
        line = f.readline()
        count_users = 0
        count_friend = 0;

        #connect to yelpdb database on postgres server using psycopg2
        try:
            #TODO: update the database name, username, and password
            conn = psycopg2.connect("dbname='yelpdb' user='xavier' host='localhost' password='0509'")
        except:
            print('Unable to connect to the database!')
        cur = conn.cursor()

        while line:
            data = json.loads(line)
            # Generate the INSERT statement for the current business
            # TODO: The below INSERT statement is based on a simple (and incomplete) businesstable schema. Update the statement based on your own table schema and
            # include values for all businessTable attributes
            try:
                cur.execute("INSERT INTO Users (user_id, name, average_stars, funny_score, useful_score, cool_score, num_fans, tip_count, yelping_since)"
                       + " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s) ", 
                         (cleanStr4SQL(data["user_id"]), cleanStr4SQL(data["name"]), data["average_stars"], data["funny"], data["useful"], data["cool"], data["fans"], 0, data["yelping_since"] ) )              
            except Exception as e:
                print("Insert to Users failed!",e)

            try:
                for friend in data["friends"]:
                    count_friend += 1
                    cur.execute("INSERT INTO Friends (user_id, friend_id) VALUES (%s, %s)", (cleanStr4SQL(data["user_id"]), cleanStr4SQL(friend)))

            except Exception as e:
                print("Insert to Friends failed!",e)

            conn.commit()
            line = f.readline()
            count_users +=1

        cur.close()
        conn.close()

    print("Users:", count_users)
    print("Friends:", count_friend)
    #outfile.close()  #uncomment this line if you are writing the INSERT statements to an output file.
    f.close()


def insert2TipTable():
    #reading the JSON file
    with open('.//yelp_tip.JSON','r') as f:  #TODO: update path for the input file
        line = f.readline()
        count_line = 0

        #connect to yelpdb database on postgres server using psycopg2
        try:
            #TODO: update the database name, username, and password
            conn = psycopg2.connect("dbname='yelpdb' user='xavier' host='localhost' password='0509'")
        except:
            print('Unable to connect to the database!')
        cur = conn.cursor()

        while line:
            data = json.loads(line)
            # Generate the INSERT statement for the current business
            # TODO: The below INSERT statement is based on a simple (and incomplete) businesstable schema. Update the statement based on your own table schema and
            # include values for all businessTable attributes
            try:
                cur.execute("INSERT INTO Tips (business_id, user_id, tip_timestamp, tip_text, likes)"
                       + " VALUES (%s, %s, %s, %s, %s) ", 
                         (cleanStr4SQL(data["business_id"]), cleanStr4SQL(data["user_id"]), data["date"], cleanStr4SQL(data["text"]), data["likes"] ) )              
            except Exception as e:
                print("Insert to Tip failed!",e)
            conn.commit()
            line = f.readline()
            count_line +=1

        cur.close()
        conn.close()

    print("Tips", count_line)
    #outfile.close()  #uncomment this line if you are writing the INSERT statements to an output file.
    f.close()


# insert2BusinessTable()
# insert2UserTable()
insert2TipTable()