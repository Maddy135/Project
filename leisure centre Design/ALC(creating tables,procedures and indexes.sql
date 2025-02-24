
--  code to create tables
--   membership table.
CREATE TABLE membership_type (
  membership_type_id serial PRIMARY KEY,
  membership_type_name VARCHAR(50),
  price DECIMAL(10,2) NOT NULL
  );
  

--   code to create enum value 'status' with values "active" and "inactive" and "terminated"
  CREATE type status as enum('active', 'inactive', 'terminated');


--   member table
  CREATE TABLE member(
    member_id serial UNIQUE PRIMARY KEY,
    name varchar(50) NOT NULL,
    address varchar(50),
    telephone_no varchar(50) NOT NULL,
    date_joined  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
	  );
	  
	  
	--   instructor table
	  CREATE TABLE instructor(
	  instructor_id SERIAL PRIMARY KEY,
	  instructor_name VARCHAR(255) NOT NULL
	  );
	  
	  CREATE TABLE class (
	  class_id SERIAL PRIMARY KEY,
	  class_name VARCHAR(255) NOT NULL
	    );

     CREATE TABLE booked_class_information(
	    class_id integer REFERENCES class(class_id),
	    instructor_id integer REFERENCES instructor(instructor_id),
      start_date DATE,
      end_date DATE,
      start_time TIME,
      end_time TIME,
        PRIMARY key(class_id, instructor_id)
	  );
	  

	--   rooms table
	  CREATE TABLE room (
	  room_id SERIAL PRIMARY KEY,
	  room_name VARCHAR(255) NOT NULL
	  );
	  
	  
	    CREATE TABLE membership(
	    member_id integer REFERENCES member(member_id),
	    membership_type_id integer REFERENCES membership_type(membership_type_id),
      date_of_last_renewal DATE,
	    membership_status status,
        PRIMARY key(member_id)
	  );
	  
     CREATE TABLE class_status_table(
	    class_id integer REFERENCES class(class_id),
	    number_of_members integer NOT NULL,
	    class_status status,
        PRIMARY key(class_id)
	  );

     CREATE TABLE class_room_allocated(
      allocation_id SERIAL UNIQUE,
	    class_id integer REFERENCES class(class_id),
	    room_id  integer REFERENCES room(room_id),
	     PRIMARY key(allocation_id)
	  );

     CREATE TABLE member_class(
      member_id integer REFERENCES member(member_id),
	    class_id integer REFERENCES class(class_id),
	    PRIMARY key(member_id,class_id)
	  );
-- table have constraints ie, NOT NULL, DEFAULT AND UNIQUE

--   end of create tables code



--audit triggers
-- first create table to store audit data
-- Create the audit table
DROP TABLE IF EXISTS membership_audit_table;
CREATE TABLE  membership_audit_table (
operation varchar(10),
operation_timestamp timestamp,
userid  text,
member_id integer,
membership_type_id integer,
date_of_last_renewal date,
membership_status status
);


-- Create the function
CREATE OR REPLACE FUNCTION membership_audit() RETURNS TRIGGER AS $$
BEGIN
-- Insert audit record for insert operation
IF TG_OP = 'INSERT' THEN
INSERT INTO membership_audit_table SELECT 'INSERT', now(), user, NEW.*;
-- Insert audit record for update operation
ELSIF TG_OP = 'UPDATE' THEN
INSERT INTO membership_audit_table SELECT 'UPDATE', now(), user, NEW.*;
-- Insert audit record for delete operation
ELSIF TG_OP = 'DELETE' THEN
INSERT INTO membership_audit_table SELECT 'DELETE', now(), user, OLD.*;

END IF;
RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- Create the trigger
CREATE TRIGGER membership_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON membership
FOR EACH ROW
EXECUTE FUNCTION membership_audit();

-- end of trigger in membership table


--  stored procedures to insert data into tables
-- (1) insert values to member_table
CREATE OR REPLACE PROCEDURE insert_record_into_member(name varchar, address varchar , telephone_no varchar)
AS $$
BEGIN
-- Start the transaction


INSERT INTO member (name, address , telephone_no)
VALUES (name, address, telephone_no);

-- Check if the insert was successful
IF FOUND THEN
    -- Commit the transaction
    COMMIT;
ELSE
    -- Rollback the transaction
    ROLLBACK;
END IF;
END;
$$ LANGUAGE plpgsql;



-- (2) stored procedure to insert into membership table
CREATE OR REPLACE PROCEDURE insert_record_into_membership_table(
      member_id integer,
	    membership_type_id integer,
      date_of_last_renewal DATE,
	    membership_status status)
AS $$
BEGIN
-- Start the transaction


INSERT INTO membership (member_id,  membership_type_id ,date_of_last_renewal,membership_status)
VALUES (member_id,  membership_type_id ,date_of_last_renewal,membership_status);

-- Check if the insert was successful
IF FOUND THEN
    -- Commit the transaction
    COMMIT;
ELSE
    -- Rollback the transaction
    ROLLBACK;
END IF;
END;
$$ LANGUAGE plpgsql;


-- (3)stored procedure to insert into memebership_type_table
CREATE OR REPLACE PROCEDURE insert_record_into_membership_type_table(
      membership_type_name VARCHAR, 
      price DECIMAL
	    )
AS $$
BEGIN
-- Start the transaction


INSERT INTO membership_type (membership_type_name, price)
VALUES (membership_type_name, price);

-- Check if the insert was successful
IF FOUND THEN
    -- Commit the transaction
    COMMIT;
ELSE
    -- Rollback the transaction
    ROLLBACK;
END IF;
END;
$$ LANGUAGE plpgsql;


-- (4) stored procedure to insert value into instructor table
CREATE OR REPLACE PROCEDURE insert_record_into_instructor_table(
      instructor_name VARCHAR
    	    )
AS $$
BEGIN
-- Start the transaction


INSERT INTO instructor (instructor_name)
VALUES (instructor_name);

-- Check if the insert was successful
IF FOUND THEN
    -- Commit the transaction
    COMMIT;
ELSE
    -- Rollback the transaction
    ROLLBACK;
END IF;
END;
$$ LANGUAGE plpgsql;

-- (5)stored procedure to insert value into room table
CREATE OR REPLACE PROCEDURE insert_record_into_room_table(
      room_name VARCHAR
    	    )
AS $$
BEGIN
-- Start the transaction


INSERT INTO room (room_name)
VALUES (room_name);

-- Check if the insert was successful
IF FOUND THEN
    -- Commit the transaction
    COMMIT;
ELSE
    -- Rollback the transaction
    ROLLBACK;
END IF;
END;
$$ LANGUAGE plpgsql;

-- (6) stored procedure to insert value into class table
CREATE OR REPLACE PROCEDURE insert_record_into_class_table(
      class_name VARCHAR 
    	    )
AS $$
BEGIN
-- Start the transaction


INSERT INTO class (class_name)
VALUES (class_name);

-- Check if the insert was successful
IF FOUND THEN
    -- Commit the transaction
    COMMIT;
ELSE
    -- Rollback the transaction
    ROLLBACK;
END IF;
END;
$$ LANGUAGE plpgsql;

-- (7) stored procedure to insert value into member_class table
CREATE OR REPLACE PROCEDURE insert_record_into_member_class_table(
      member_id int, 
      class_id int
    	    )
AS $$
BEGIN
-- Start the transaction


INSERT INTO member_class (member_id,class_id)
VALUES (member_id,class_id);

-- Check if the insert was successful
IF FOUND THEN
    -- Commit the transaction
    COMMIT;
ELSE
    -- Rollback the transaction
    ROLLBACK;
END IF;
END;
$$ LANGUAGE plpgsql;


-- (8) stored procedure to insert value into class_status_table
CREATE OR REPLACE PROCEDURE insert_record_into_class_status_table(
       class_id integer,
	    number_of_members integer,
	    class_status status
    	    )
AS $$
BEGIN
-- Start the transaction


INSERT INTO class_status_table (class_id,number_of_members,class_status)
VALUES (class_id,number_of_members,class_status);

-- Check if the insert was successful
IF FOUND THEN
    -- Commit the transaction
    COMMIT;
ELSE
    -- Rollback the transaction
    ROLLBACK;
END IF;
END;
$$ LANGUAGE plpgsql;


-- (9) stored procedure to insert value into class_room_allocated
CREATE OR REPLACE PROCEDURE insert_record_into_class_room_allocated(
      class_id integer,
	    room_id  integer
	  )
AS $$
BEGIN
-- Start the transaction


INSERT INTO class_room_allocated (class_id,room_id)
VALUES (class_id,room_id);

-- Check if the insert was successful
IF FOUND THEN
    -- Commit the transaction
    COMMIT;
ELSE
    -- Rollback the transaction
    ROLLBACK;
END IF;
END;
$$ LANGUAGE plpgsql;



-- (10) stored procedure to insert value into class_room_allocated
CREATE OR REPLACE PROCEDURE insert_record_into_booked_class_information(
	    class_id integer,
	    instructor_id integer,
      start_date DATE,
      end_date DATE,
      start_time TIME,
      end_time TIME
	  )
AS $$
BEGIN
-- Start the transaction


INSERT INTO booked_class_information (class_id,instructor_id,start_date,end_date,start_time,end_time)
VALUES (class_id,instructor_id,start_date,end_date,start_time,end_time);

-- Check if the insert was successful
IF FOUND THEN
    -- Commit the transaction
    COMMIT;
ELSE
    -- Rollback the transaction
    ROLLBACK;
END IF;
END;
$$ LANGUAGE plpgsql;


-- proceedure for all update transaction
-- example --- CALL update_table('member', 'name', 'Tyson Wilson', 'member_id', 1);
-- the above procedure call example will update the name of member  with id 1 to 'Tyson Wilson'

CREATE OR REPLACE PROCEDURE update_table(table_name text, column_name text, new_value anyelement, key_column_name text, key_value anyelement)
AS $$
BEGIN
-- start transaction block


-- update the table with the new value
UPDATE table_name
SET column_name = new_value
WHERE key_column_name = key_value;

-- check if the update was successful
IF NOT FOUND THEN
-- rollback the transaction if the update was not successful
ROLLBACK;
RAISE EXCEPTION 'Update failed';
ELSE
-- commit the transaction if the update was successful
COMMIT;
END IF;
END;
$$ LANGUAGE plpgsql;


-- stored procedure for any delete transaction
CREATE OR REPLACE PROCEDURE delete_row(table_name text, key_column_name text, key_value anyelement)
AS $$
BEGIN
-- start transaction block

-- delete the row from the table
DELETE FROM table_name
WHERE key_column_name = key_value;

-- check if the delete was successful
IF NOT FOUND THEN
-- rollback the transaction if the delete was not successful
ROLLBACK;
RAISE EXCEPTION 'Delete failed';
ELSE
-- commit the transaction if the delete was successful
COMMIT;
END IF;
END;
$$ LANGUAGE plpgsql;



-- indexing in member table, member_id, membership_status
CREATE INDEX all_members
ON member (member_id);
  
  -- member and class they belong
CREATE INDEX member_class_index
ON member_class (member_id);

-- used in WHERE clause
CREATE INDEX member_status
ON membership (membership_status);
 
--  status of classes
CREATE INDEX class_status
ON class_status_table (class_status);