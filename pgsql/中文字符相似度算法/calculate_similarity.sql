CREATE OR REPLACE FUNCTION "public"."calculate_similarity"("str1" text, "str2" text)
  RETURNS "pg_catalog"."float8" AS $BODY$ DECLARE
	cleaned_str1 TEXT;
str1_array TEXT [] := '{}';
str2_array TEXT [] := '{}';
cleaned_str2 TEXT;
intersect_str TEXT;
a_l INT;
b_l INT;
c_l INT;
similarity FLOAT;
BEGIN-- 基本类型判断
	IF
		str1 IS NULL 
		OR str2 IS NULL 
		OR NOT ( str1 IS NOT NULL ) 
		OR NOT ( str2 IS NOT NULL ) THEN
			RETURN 0;
		
	END IF;
-- 数据清洗和转换
	cleaned_str1 := UPPER ( regexp_replace( str1, '[^a-zA-Z0-9\u4e00-\u9fa5]+', ' ', 'g' ) );
	cleaned_str2 := UPPER ( regexp_replace( str2, '[^a-zA-Z0-9\u4e00-\u9fa5]+', ' ', 'g' ) );
	RAISE NOTICE'str1: %',
	cleaned_str1;
	RAISE NOTICE'str2: %',
	cleaned_str2;
-- 排除极端情况
	IF
		cleaned_str1 = cleaned_str2 THEN
			RETURN 1;
		
	END IF;
-- 分割字符串并编号
	str1_array := split_and_number_string ( cleaned_str1 );
	RAISE NOTICE'str1: %',
	str1_array;
	str2_array := split_and_number_string ( cleaned_str2 );
	RAISE NOTICE'str1: %',
	str2_array;
-- 获取交集字符串
	intersect_str := array_to_string(
		ARRAY (
			SELECT
				split_part( elem, '-', 1 ) 
			FROM
				UNNEST ( str1_array ) AS elem 
			WHERE
				elem IN ( SELECT UNNEST ( str2_array ) ) 
			),
			'' 
		);
	RAISE NOTICE'intersect_str: %',
	intersect_str;
-- 计算相似度
	a_l:= LENGTH ( intersect_str );
	b_l:= LENGTH ( cleaned_str1 );
	c_l:= LENGTH ( cleaned_str2 );
	similarity := a_l*2::FLOAT/(b_l+c_l);
	RAISE NOTICE'a_l: %',a_l;
	RAISE NOTICE'b_l: %',b_l;
	RAISE NOTICE'c_l: %',c_l;
	RAISE NOTICE'similarity: %',similarity;
-- 特定条件判断
	IF
		LENGTH ( intersect_str ) > 2 
		AND (
			intersect_str LIKE ( substr( cleaned_str1, 1, 2 ) || '%' ) 
			OR intersect_str LIKE ( '%' || substr( cleaned_str1, - 2 ) ) 
			) THEN
			RETURN 1;
		
	END IF;
	RETURN similarity;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100