CREATE OR REPLACE FUNCTION "public"."split_and_number_string"("input_string" text)
  RETURNS "pg_catalog"."_text" AS $BODY$
DECLARE
  output_array text[] := '{}';
	output_array_count text[] := '{}';
  character text;
  character_count integer := 1;
	arr_ads INTEGER :=1;
BEGIN
  -- 将字符串拆分为字符数组
  FOREACH character IN ARRAY regexp_split_to_array(input_string, '') LOOP
    -- 检查字符是否已存在于输出数组中
		RAISE NOTICE '% ',character;
    IF character = ANY(output_array) THEN
      character_count := character_count + 1;
    ELSE
      -- 将字符及其编号添加到输出数组
      output_array := array_append(output_array, character || '-' || character_count);
    END IF;
  END LOOP;

  RETURN output_array;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100