CREATE TYPE example AS (
  title varchar(255),
  description text
);

-- custom json conversion function
CREATE OR REPLACE FUNCTION example_type_to_json(example) RETURNS json IMMUTABLE STRICT LANGUAGE sql AS $$
  SELECT json_build_object('title', $1.title, 'description', $1.description);
$$;

-- associate the type with the custom json conversion function
SELECT zdb.define_type_conversion('example'::regtype, 'example_type_to_json'::regproc);

-- define a type mapping for 'example'
SELECT zdb.define_type_mapping('example'::regtype, '{"type":"nested"}'::json);

CREATE TABLE test (
  id serial8 NOT NULL PRIMARY KEY,
  data example
);

CREATE INDEX idxtest ON test USING zombodb ((test.*));

INSERT INTO test (data) VALUES (('this is the title', 'this is the description'));

SELECT * FROM test WHERE test ==> dsl.nested('data', dsl.term('data.title', 'this is the title'));

DROP TABLE test CASCADE;
DROP FUNCTION example_type_to_json(example);
DROP TYPE example;