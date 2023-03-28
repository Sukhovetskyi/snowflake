show stages;
put file://Users/vladsukhovetskyi/Downloads/LU_SOIL_TYPE.tsv @DEMO_DB.PUBLIC.MY_INTERNAL_NAMED_STAGE;
put file://Users/vladsukhovetskyi/Downloads/my_file.txt @DEMO_DB.PUBLIC.MY_INTERNAL_NAMED_STAGE;
put file://Users/vladsukhovetskyi/Downloads/my_second_file.txt @DEMO_DB.PUBLIC.MY_INTERNAL_NAMED_STAGE;
put file://Users/vladsukhovetskyi/Downloads/my_third_file.txt @DEMO_DB.PUBLIC.MY_INTERNAL_NAMED_STAGE;
select $1 from @DEMO_DB.PUBLIC.MY_INTERNAL_NAMED_STAGE/LU_SOIL_TYPE.tsv.gz




use role pc_rivery_role;
use warehouse pc_rivery_wh;

create or replace TABLE PC_RIVERY_DB.PUBLIC.FRUIT_LOAD_LIST (
	FRUIT_NAME VARCHAR(25)
);


insert into PC_RIVERY_DB.PUBLIC.FRUIT_LOAD_LIST
values ('banana')
, ('cherry')
, ('strawberry')
, ('pineapple')
, ('apple')
, ('mango')
, ('coconut')
, ('plum')
, ('avocado')
, ('starfruit');

select * from PC_RIVERY_DB.PUBLIC.FRUIT_LOAD_LIST;