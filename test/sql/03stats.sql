-- -*- mode: sql; sql-product: postgres -*-

-- Check the host statistics view

CREATE FUNCTION unit_tests.check_host_stats()
RETURNS test_result AS $$
DECLARE message test_result;
DECLARE result boolean;

DECLARE host_data     jsonb;
DECLARE host_maxusers integer;
DECLARE host_name     text;
DECLARE view_data     jsonb;
DECLARE view_maxusers integer;
DECLARE view_name     text;
DECLARE view_users    integer;
DECLARE count_users   integer;
DECLARE h             varchar;
BEGIN
    FOR h in (SELECT name FROM hosts)
    LOOP
        SELECT * FROM hosts WHERE name = h
        INTO host_name, host_maxusers, host_data;
        
        SELECT *  FROM host_statistics WHERE name = h
        INTO view_name, view_users, view_maxusers, view_data;

	SELECT COUNT(*) FROM passwd WHERE host = h
	INTO count_users;
        
	SELECT * FROM assert.is_equal(host_data, view_data) INTO message, result;
        IF result = false THEN RETURN message; END IF;

	SELECT * FROM assert.is_equal(host_maxusers, view_maxusers) INTO message, result;
        IF result = false THEN RETURN message; END IF;

	SELECT * FROM assert.is_equal(host_name, view_name) INTO message, result;
        IF result = false THEN RETURN message; END IF;

	SELECT * FROM assert.is_equal(view_users, count_users) INTO message, result;
        IF result = false THEN RETURN message; END IF;
    END LOOP;
    RETURN assert.ok('End of test.');
END $$ LANGUAGE plpgsql;
