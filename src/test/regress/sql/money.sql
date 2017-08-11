--
-- MONEY
--

CREATE TABLE money_data (m money);

INSERT INTO money_data VALUES ('123');
SELECT * FROM money_data;
SELECT m + '123' FROM money_data;
SELECT m + '123.45' FROM money_data;
SELECT m - '123.45' FROM money_data;
SELECT m * 2 FROM money_data;
SELECT m / 2 FROM money_data;

-- All true
SELECT m = '$123.00' FROM money_data;
SELECT m != '$124.00' FROM money_data;
SELECT m <= '$123.00' FROM money_data;
SELECT m >= '$123.00' FROM money_data;
SELECT m < '$124.00' FROM money_data;
SELECT m > '$122.00' FROM money_data;

-- All false
SELECT m = '$123.01' FROM money_data;
SELECT m != '$123.00' FROM money_data;
SELECT m <= '$122.99' FROM money_data;
SELECT m >= '$123.01' FROM money_data;
SELECT m > '$124.00' FROM money_data;
SELECT m < '$122.00' FROM money_data;

SELECT cashlarger(m, '$124.00') FROM money_data;
SELECT cashsmaller(m, '$124.00') FROM money_data;
SELECT cash_words(m) FROM money_data;
SELECT cash_words(m + '1.23') FROM money_data;

DELETE FROM money_data;
INSERT INTO money_data VALUES ('$123.45');
SELECT * FROM money_data;

DELETE FROM money_data;
INSERT INTO money_data VALUES ('$123.451');
SELECT * FROM money_data;

DELETE FROM money_data;
INSERT INTO money_data VALUES ('$123.454');
SELECT * FROM money_data;

DELETE FROM money_data;
INSERT INTO money_data VALUES ('$123.455');
SELECT * FROM money_data;

DELETE FROM money_data;
INSERT INTO money_data VALUES ('$123.456');
SELECT * FROM money_data;

DELETE FROM money_data;
INSERT INTO money_data VALUES ('$123.459');
SELECT * FROM money_data;

-- rounding vs. truncation in division
SELECT '878.08'::money / 11::float8;
SELECT '878.08'::money / 11::float4;
SELECT '878.08'::money / 11::int;
SELECT '878.08'::money / 11::smallint;

-- check for precision loss in division
SELECT '90000000000000099.00'::money / 10::int;
SELECT '90000000000000099.00'::money / 10::smallint;

-- Cast int4/int8 to money
SELECT 1234567890::money;
SELECT 12345678901234567::money;
SELECT 123456789012345678::money;
SELECT 9223372036854775807::money;
SELECT (-12345)::money;
SELECT (-1234567890)::money;
SELECT (-12345678901234567)::money;
SELECT (-123456789012345678)::money;
SELECT (-9223372036854775808)::money;
SELECT 1234567890::int4::money;
SELECT 12345678901234567::int8::money;
SELECT (-1234567890)::int4::money;
SELECT (-12345678901234567)::int8::money;

INSERT INTO money_data VALUES ('$223.459');
INSERT INTO money_data VALUES ('$323.459');
INSERT INTO money_data VALUES ('$423.459');
INSERT INTO money_data VALUES ('$523.459');
SELECT sum(m) FROM money_data;

CREATE TABLE money_data2 (a int, m money);
INSERT INTO money_data2 VALUES (1, '$123.459');
INSERT INTO money_data2 VALUES (2, '$223.459');
INSERT INTO money_data2 VALUES (3, '$323.459');
INSERT INTO money_data2 VALUES (4, '$423.459');
INSERT INTO money_data2 VALUES (5, '$523.459');
SELECT sum(m) FROM money_data2;
DROP TABLE money_data2;
