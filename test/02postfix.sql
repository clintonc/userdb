-- -*- mode: sql; sql-product: postgres -*-

-- Query used by Postfix
CREATE FUNCTION unit_tests.postfix()
RETURNS test_result AS $$
DECLARE message test_result;
DECLARE result boolean;
DECLARE passwd_host text;
BEGIN
    SELECT host FROM passwd WHERE name = 'testuser' INTO passwd_host;

    SELECT * FROM assert.is_equal(passwd_host, 'testbox.hashbang.sh') INTO message, result;
    IF result = false THEN RETURN message; END IF;

    SELECT host FROM passwd WHERE name = 'testadmin' INTO passwd_host;
    SELECT * FROM assert.is_equal(passwd_host, 'fo0.hashbang.sh') INTO message, result;
    IF result = false THEN RETURN message; END IF;

    RETURN assert.ok('End of test.');
END $$ LANGUAGE plpgsql;
