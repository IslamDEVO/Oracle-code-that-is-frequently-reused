-- display all people
SELECT * FROM per_all_people_f  WHERE first_name = 'AAISHH';
SELECT * FROM per_all_people_f WHERE last_name = 'LastName';
SELECT * FROM per_all_people_f WHERE person_id = 521;
select * from per_all_people_f where employee_number = '2811'; -- syed.salman  person_id=56193
select person_id from per_all_people_f
where full_name = 'Loluwah Saad Alnowaiser'
and sysdate between effective_start_date and effective_end_date
;

select * from per_people_x where person_id = 521;     -- Adam person_id=1123 business_group_id=101 person_id=521 employee_number= 225
select * from per_people_x where person_id = 121151;  -- AAISHH MUHAMMED ALSHEHRI person_id=121151 employee_number=3501

-- display address
SELECT * FROM per_addresses WHERE person_id = 124101;

-- display person contact relationship
select * from per_contact_relationships;
SELECT * FROM per_contact_relationships WHERE person_id = 124101;
SELECT * FROM per_contact_relationships WHERE CONTACT_RELATIONSHIP_ID = 1135663; --1135663 678945;
DESC per_contact_relationships;
SELECT * FROM per_contact_relationships WHERE CONTACT_PERSON_ID = 121151;

-- display person type
select * from PER_PERSON_TYPES  ;

-- display the end of date time
SELECT hr_general.end_of_time FROM DUAL;

-- display the phone numbers
SELECT * FROM per_phones WHERE parent_id = 124101;

-- display a user password
SELECT usr.user_name,
    get_pwd.decrypt
        ((SELECT (SELECT get_pwd.decrypt
                            (fnd_web_sec.get_guest_username_pwd,
                            usertable.encrypted_foundation_password
                            )
                    FROM DUAL) AS apps_password
            FROM fnd_user usertable
            WHERE usertable.user_name =
                    (SELECT SUBSTR
                                (fnd_web_sec.get_guest_username_pwd,
                                1,
                                    INSTR
                                        (fnd_web_sec.get_guest_username_pwd,
                                        '/'
                                        )
                                - 1
                                )
                        FROM DUAL)),
        usr.encrypted_user_password
        ) PASSWORD
FROM fnd_user usr
WHERE usr.user_name = ':USER_NAME'; -- ESSHRUSER zain@12345678 for ISG 

-- display lookups
SELECT * FROM fnd_lookups WHERE lookup_type = 'BUSINESS_ENTITY'
    and LOOKUP_CODE like 'AR%';

SELECT TERRITORY_SHORT_NAME
    FROM FND_TERRITORIES_VL
    WHERE OBSOLETE_FLAG <> 'Y' AND TERRITORY_CODE = country;

SELECT
    lookup_code   code,
    meaning       meaning,
    NULL description
FROM
    hr_lookups     h
WHERE
    lookup_type = 'TITLE'
    AND ( enabled_flag = 'Y'
          OR end_date_active IS NOT NULL )
ORDER BY
    meaning;

SELECT
    lookup_code   code,
    meaning       meaning,
    NULL description
FROM
    fnd_common_lookups
WHERE
    lookup_type = 'TITLE'
    AND ( enabled_flag = 'Y'
          OR end_date_active IS NOT NULL )
ORDER BY
    meaning;

-- Convert date to Hijrah
select to_date(to_char(sysdate,'dd/mm/yyyy','nls_calendar=''arabic hijrah''') ,'dd/mm/yyyy') from dual ;

-- display all hr position
select name from hr_all_positions_f where lower(name) like '%hr%';
select per.person_id, pos.name pos_name, g.name grade_name, per.full_name, g.attribute1
from
    per_all_people_f per
    join per_all_assignments_f assign
    on (per.person_id = assign.person_id
        and sysdate between assign.effective_start_date and assign.effective_end_date)
    join hr_all_positions_f pos
    on (assign.position_id = pos.position_id
        and sysdate between pos.effective_start_date and pos.effective_end_date)
    join per_grades g
    on (assign.grade_id = g.grade_id and g.name not like '%.H')
where
    sysdate between per.effective_start_date and per.effective_end_date
    and pos.name = 'HR Operations Manager.HR Operations - Central'
    and to_number(replace(g.name, '.H', '')) <= 16;
    
select name, attribute1 from per_grades;
