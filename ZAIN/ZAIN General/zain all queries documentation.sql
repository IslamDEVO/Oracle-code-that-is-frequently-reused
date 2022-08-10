-- ----
-- START general SELECT query for zain company
/* #region general SELECT query for zain company */
    -- display all people
    SELECT * FROM per_all_people_f  WHERE first_name = 'AAISHH';
    SELECT * FROM per_all_people_f WHERE last_name = 'LastName';
    SELECT * FROM per_all_people_f WHERE person_id = 521;
    select * from per_all_people_f where employee_number = '2811'; -- syed.salman  person_id=56193

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
select to_date(to_char(sysdate,'dd/mm/yyyy','nls_calendar=''arabic hijrah''') ,'dd/mm/yyyy')
    from dual ;

/* #endregion */
-- END general SELECT query for zain company


-- ----
-- START General Query for APIs
      /* #region display all APIs Name */

SELECT
    A.OWNER             API_OWNER,
    A.NAME                API_NAME,
    A.TYPE                  API_TYPE,
    U.STATUS             API_STATUS,
    U.LAST_DDL_TIME     LAST_DDL,
    SUBSTR(TEXT,1,80)   SHORT_DESCRIPTION,
    U.*
FROM
    DBA_SOURCE              A,
    DBA_OBJECTS             U
WHERE                      
    U.OBJECT_NAME    =       A.NAME
AND A.TEXT                LIKE    '%Header%'      
AND A.TYPE                =        U.OBJECT_TYPE
AND A.NAME              LIKE    '%PERSON%ADDRESS%'         -- API NAME
ORDER BY
    A.OWNER,
    A.NAME;

      /* #endregion */
-- END  General Query for APIs




-- START Person Information API
/* #region Person Information API */


    -- START create/update Employee Address
    /* #region API to create Employee Address */

        -- START create Employee Address
        /* #region API to create Employee Address */
 
   
  FUNCTION create_person_address (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_effective_date           IN  DATE,
    p_pradd_ovlapval_override  IN  BOOLEAN DEFAULT false,
    p_validate_county          IN  BOOLEAN DEFAULT true,
    p_primary_flag             IN  VARCHAR2,
    p_style                    IN  VARCHAR2,
    p_date_from                IN  DATE,
    p_date_to                  IN  DATE DEFAULT NULL,
    p_address_type             IN  VARCHAR2 DEFAULT NULL,
    p_comments                 IN  CLOB DEFAULT NULL,
    p_address_line1            IN  VARCHAR2 DEFAULT NULL,
    p_address_line2            IN  VARCHAR2 DEFAULT NULL,
    p_address_line3            IN  VARCHAR2 DEFAULT NULL,
    p_town_or_city             IN  VARCHAR2 DEFAULT NULL,
    p_region_1                 IN  VARCHAR2 DEFAULT NULL,
    p_region_2                 IN  VARCHAR2 DEFAULT NULL,
    p_region_3                 IN  VARCHAR2 DEFAULT NULL,
    p_postal_code              IN  VARCHAR2 DEFAULT NULL,
    p_country                  IN  VARCHAR2 DEFAULT NULL,
    p_telephone_number_1       IN  VARCHAR2 DEFAULT NULL,
    p_telephone_number_2       IN  VARCHAR2 DEFAULT NULL,
    p_telephone_number_3       IN  VARCHAR2 DEFAULT NULL,
    p_addr_attribute_category  IN  VARCHAR2 DEFAULT NULL,
    p_add_information13        IN  VARCHAR2 DEFAULT NULL,
    p_add_information14        IN  VARCHAR2 DEFAULT NULL,
    p_party_id                 IN  NUMBER DEFAULT NULL,
    p_address_id               OUT NOCOPY NUMBER,
    p_object_version_number    OUT NOCOPY NUMBER
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        v_error_msg               VARCHAR2 (3000);
        l_resp_status varchar2(20);
        -----
        L_RET_CLOB                CLOB;
    BEGIN
        init_session(P_PERSON_ID);
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        ---
        IF P_VALIDATE = 'TRUE' THEN L_VALIDATE := TRUE; ELSE L_VALIDATE := FALSE; END IF;
        ---
        hr_person_address_api.create_person_address(p_validate => L_VALIDATE, 
                                               p_effective_date => p_effective_date, 
                                               p_pradd_ovlapval_override => p_pradd_ovlapval_override,
                                               p_validate_county => p_validate_county,
                                               p_person_id => p_person_id,
                                               p_primary_flag => p_primary_flag,
                                               p_style => p_style,
                                               p_date_from => p_date_from,
                                               p_date_to => p_date_to,
                                               p_address_type => p_address_type,
                                               p_comments => p_comments,
                                               p_address_line1 => p_address_line1,
                                               p_address_line2 => p_address_line2,
                                               p_address_line3 => p_address_line3,
                                               p_town_or_city => p_town_or_city,
                                               p_region_1 => p_region_1,
                                               p_region_2 => p_region_2,
                                               p_region_3 => p_region_3,
                                               p_postal_code => p_postal_code,
                                               p_country => p_country,
                                               p_telephone_number_1 => p_telephone_number_1,
                                               p_telephone_number_2 => p_telephone_number_2,
                                               p_telephone_number_3 => p_telephone_number_3,
                                               p_addr_attribute_category => p_addr_attribute_category,
                                               p_add_information13 => p_add_information13,
                                               p_add_information14 => p_add_information14,
                                               p_party_id => p_party_id,
                                               p_address_id => p_address_id,
                                               p_object_version_number => p_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('ADRESS_ID', p_address_id);
            APEX_JSON.open_array('MESSAGES');
            APEX_JSON.close_array;
            ---------------------
            APEX_JSON.close_object;
            L_RET_CLOB := APEX_JSON.get_clob_output;
            APEX_JSON.free_output;
            ---------------------------------------------
            RETURN L_RET_CLOB;
            
            EXCEPTION
                WHEN OTHERS THEN
                v_error_msg   := sqlerrm;
                IF p_address_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if p_address_id is not null then
                    APEX_JSON.write('ADRESS_ID', p_address_id);
                else
                    APEX_JSON.write('ADRESS_ID', 'null');
                end if;
                APEX_JSON.open_array('MESSAGES');
                APEX_JSON.open_object;
                    APEX_JSON.write('TYPE', l_resp_status);
                    APEX_JSON.write('CODE', 'NULL');
                    APEX_JSON.write('MSG_TXT', v_error_msg);
                APEX_JSON.close_object;
                APEX_JSON.close_array;
                ---------------------
                APEX_JSON.close_object;
                L_RET_CLOB := APEX_JSON.get_clob_output;
                APEX_JSON.free_output;
                --
                L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
                ---------------------------------------------
                RETURN L_RET_CLOB;
    END;


        /* #endregion */
        -- END API to create Employee Address

        -- START update Employee Address
        /* #region API to update Employee Address */

     
  FUNCTION update_person_address (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_effective_date           IN  DATE,
    p_validate_county          IN  BOOLEAN DEFAULT true,
    p_address_id               IN  NUMBER,
    p_object_version_number    IN OUT NOCOPY NUMBER,
    p_date_from                IN  DATE DEFAULT NULL,
    p_date_to                  IN  DATE DEFAULT NULL,
    p_primary_flag             IN  VARCHAR2,
    p_address_type             IN  VARCHAR2,
    p_comments                 IN  CLOB DEFAULT NULL,
    p_address_line1            IN  VARCHAR2 DEFAULT NULL,
    p_address_line2            IN  VARCHAR2 DEFAULT NULL,
    p_address_line3            IN  VARCHAR2 DEFAULT NULL,
    p_town_or_city             IN  VARCHAR2 DEFAULT NULL,
    p_region_1                 IN  VARCHAR2 DEFAULT NULL,
    p_region_2                 IN  VARCHAR2 DEFAULT NULL,
    p_region_3                 IN  VARCHAR2 DEFAULT NULL,
    p_postal_code              IN  VARCHAR2 DEFAULT NULL,
    p_country                  IN  VARCHAR2 DEFAULT NULL,
    p_telephone_number_1       IN  VARCHAR2 DEFAULT NULL,
    p_telephone_number_2       IN  VARCHAR2 DEFAULT NULL,
    p_telephone_number_3       IN  VARCHAR2 DEFAULT NULL,
    p_addr_attribute_category  IN  VARCHAR2 DEFAULT NULL,
    p_add_information13        IN  VARCHAR2 DEFAULT NULL,
    p_add_information14        IN  VARCHAR2 DEFAULT NULL,
    p_party_id                 IN  NUMBER DEFAULT NULL
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        v_error_msg               VARCHAR2 (3000);
        l_resp_status varchar2(20);
        -----
        L_RET_CLOB                CLOB;
    BEGIN
        init_session(P_PERSON_ID);
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        ---
        IF P_VALIDATE = 'TRUE' THEN L_VALIDATE := TRUE; ELSE L_VALIDATE := FALSE; END IF;
        ---
        hr_person_address_api.update_person_address(p_validate => L_VALIDATE, p_effective_date => p_effective_date,
                                               p_validate_county => p_validate_county,
                                               p_primary_flag => p_primary_flag,
                                               p_date_from => p_date_from,
                                               p_date_to => p_date_to,
                                               p_address_type => p_address_type,
                                               p_comments => p_comments,
                                               p_address_line1 => p_address_line1,
                                               p_address_line2 => p_address_line2,
                                               p_address_line3 => p_address_line3,
                                               p_town_or_city => p_town_or_city,
                                               p_region_1 => p_region_1,
                                               p_region_2 => p_region_2,
                                               p_region_3 => p_region_3,
                                               p_postal_code => p_postal_code,
                                               p_country => p_country,
                                               p_telephone_number_1 => p_telephone_number_1,
                                               p_telephone_number_2 => p_telephone_number_2,
                                               p_telephone_number_3 => p_telephone_number_3,
                                               p_addr_attribute_category => p_addr_attribute_category,
                                               p_add_information13 => p_add_information13,
                                               p_add_information14 => p_add_information14,
                                               p_party_id => p_party_id,
                                               p_address_id => p_address_id,
                                               p_object_version_number => p_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('OBJECT_VERSION_NUMBER', p_object_version_number);
            APEX_JSON.open_array('MESSAGES');
            APEX_JSON.close_array;
            ---------------------
            APEX_JSON.close_object;
            L_RET_CLOB := APEX_JSON.get_clob_output;
            APEX_JSON.free_output;
            ---------------------------------------------
            RETURN L_RET_CLOB;
            
            EXCEPTION
                WHEN OTHERS THEN
                v_error_msg   := sqlerrm;
                IF p_object_version_number IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if p_object_version_number is not null then
                    APEX_JSON.write('OBJECT_VERSION_NUMBER', p_object_version_number);
                else
                    APEX_JSON.write('OBJECT_VERSION_NUMBER', 'null');
                end if;
                APEX_JSON.open_array('MESSAGES');
                APEX_JSON.open_object;
                    APEX_JSON.write('TYPE', l_resp_status);
                    APEX_JSON.write('CODE', 'NULL');
                    APEX_JSON.write('MSG_TXT', v_error_msg);
                APEX_JSON.close_object;
                APEX_JSON.close_array;
                ---------------------
                APEX_JSON.close_object;
                L_RET_CLOB := APEX_JSON.get_clob_output;
                APEX_JSON.free_output;
                --
                L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
                ---------------------------------------------
                RETURN L_RET_CLOB;
    END;


        /* #endregion */
        -- END API to update Employee Address

        -- START test create Employee Address
        /* #region test API to create Employee Address */

SET SERVEROUTPUT ON;

DECLARE
    ln_address_id             per_addresses.address_id%TYPE;
    ln_object_version_number  per_addresses.object_version_number%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE(xxx_zain_ess_pkg.create_person_address(p_validate => 'FALSE', p_effective_date => sysdate, p_pradd_ovlapval_override => false,
                                               p_validate_county => FALSE,
                                               p_person_id => '124101',
                                               p_primary_flag => 'N',
                                               p_style => 'SA',
                                               p_date_from => sysdate,
                                               p_date_to => NULL,
                                               p_address_type => NULL,
                                               p_comments => NULL,
                                               p_address_line1 => NULL,
                                               p_address_line2 => NULL,
                                               p_address_line3 => NULL,
                                               p_town_or_city => 'RUH',
                                               p_region_1 => 'qwe',
                                               p_region_2 => 'qwe',
                                               p_region_3 => '123',
                                               p_postal_code => '123',
                                               p_country => 'SA',
                                               p_telephone_number_1 => NULL,
                                               p_telephone_number_2 => NULL,
                                               p_telephone_number_3 => NULL,
                                               p_addr_attribute_category => NULL,
                                               p_add_information13 => '84888',
                                               p_add_information14 => '89767',
                                               p_party_id => NULL));
        

    dbms_output.put_line('Success : ');
--    dbms_output.put_line('ln_address_id : ' || ln_address_id);
    

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error raised : ' || sqlerrm);
END;
        /* #endregion */
        -- END test API to create Employee Address

        -- START test update Employee Address
        /* #region test API to update Employee Address */

SET SERVEROUTPUT ON;

DECLARE
    ln_address_id             per_addresses.address_id%TYPE DEFAULT 10965;
    ln_object_version_number  per_addresses.object_version_number%TYPE DEFAULT 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE(xxx_zain_ess_pkg.update_person_address(p_validate => 'FALSE', p_effective_date => sysdate,
                                               p_validate_county => FALSE,
                                               p_primary_flag => 'N',
                                               p_date_from => sysdate,
                                               p_date_to => NULL,
                                               p_address_type => NULL,
                                               p_comments => NULL,
                                               p_address_line1 => NULL,
                                               p_address_line2 => NULL,
                                               p_address_line3 => NULL,
                                               p_town_or_city => 'RUH',
                                               p_region_1 => 'qwetest',
                                               p_region_2 => 'qwetest',
                                               p_region_3 => '123',
                                               p_postal_code => '123',
                                               p_country => 'SA',
                                               p_telephone_number_1 => NULL,
                                               p_telephone_number_2 => NULL,
                                               p_telephone_number_3 => NULL,
                                               p_addr_attribute_category => NULL,
                                               p_add_information13 => '123',
                                               p_add_information14 => '123',
                                               p_party_id => NULL,
                                               p_address_id => ln_address_id,
                                               p_object_version_number => ln_object_version_number));
        

    dbms_output.put_line('Success : ');
    dbms_output.put_line('ln_object_version_number : ' || ln_object_version_number);
    

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error raised : ' || sqlerrm);
END;

        /* #endregion */
        -- END test API to update Employee Address

    /* #endregion */
    -- END API to create/updat Employee Address



    -- START Create/Update/Delete Phone - HRMS APIs
    /* #region Create/Update/Delete Phone - HRMS APIs*/


          -- START Create Phone - HRMS APIs
          /* #region Create Phone - HRMS APIs*/
   
  FUNCTION create_phone (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_date_from              IN  DATE DEFAULT SYSDATE,
        p_date_to                IN  DATE DEFAULT NULL,
        p_phone_type             IN  VARCHAR2,
        p_phone_number           IN  VARCHAR2,
        p_parent_id              IN  NUMBER DEFAULT NULL,
        p_parent_table           IN  VARCHAR2 DEFAULT NULL,
        p_attribute_category     IN  VARCHAR2 DEFAULT NULL,
        p_effective_date         IN  DATE DEFAULT SYSDATE,
        p_party_id               IN  NUMBER DEFAULT NULL,
        p_validity               IN  VARCHAR2 DEFAULT NULL,
        p_object_version_number  OUT NOCOPY NUMBER,
        p_phone_id               OUT NOCOPY NUMBER
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        v_error_msg               VARCHAR2 (3000);
        l_resp_status varchar2(20);
        -----
        L_RET_CLOB                CLOB;
    BEGIN
        init_session(P_PERSON_ID);
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        ---
        IF P_VALIDATE = 'TRUE' THEN L_VALIDATE := TRUE; ELSE L_VALIDATE := FALSE; END IF;
        ---
        hr_phone_api.create_phone(
            P_VALIDATE               => L_VALIDATE,
            p_date_from              => p_date_from,
            p_date_to                => p_date_to,
            p_phone_type             => p_phone_type,
            p_phone_number           => p_phone_number,
            p_parent_id              => p_parent_id,
            p_parent_table           => p_parent_table,
            p_attribute_category     => p_attribute_category,
            p_effective_date         => p_effective_date,
            p_party_id               => p_party_id,
            p_validity               => p_validity,
            p_object_version_number  => p_object_version_number,
            p_phone_id               => p_phone_id
        );
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('PHONE_ID', p_phone_id);
            APEX_JSON.open_array('MESSAGES');
            APEX_JSON.close_array;
            ---------------------
            APEX_JSON.close_object;
            L_RET_CLOB := APEX_JSON.get_clob_output;
            APEX_JSON.free_output;
            ---------------------------------------------
            RETURN L_RET_CLOB;
            
            EXCEPTION
                WHEN OTHERS THEN
                v_error_msg   := sqlerrm;
                IF p_phone_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if p_phone_id is not null then
                    APEX_JSON.write('PHONE_ID', p_phone_id);
                else
                    APEX_JSON.write('PHONE_ID', 'null');
                end if;
                APEX_JSON.open_array('MESSAGES');
                APEX_JSON.open_object;
                    APEX_JSON.write('TYPE', l_resp_status);
                    APEX_JSON.write('CODE', 'NULL');
                    APEX_JSON.write('MSG_TXT', v_error_msg);
                APEX_JSON.close_object;
                APEX_JSON.close_array;
                ---------------------
                APEX_JSON.close_object;
                L_RET_CLOB := APEX_JSON.get_clob_output;
                APEX_JSON.free_output;
                --
                L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
                ---------------------------------------------
                RETURN L_RET_CLOB;
    END;

          /* #endregion */
          -- END Create Phone - HRMS APIs

          -- START Update Phone - HRMS APIs
          /* #region Create Phone - HRMS APIs*/
   
  FUNCTION update_phone (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_phone_id               IN  NUMBER,
        p_date_from              IN  DATE DEFAULT SYSDATE,
        p_phone_type             IN  VARCHAR2,
        p_phone_number           IN  VARCHAR2,
        p_attribute_category     IN  VARCHAR2 DEFAULT NULL,
        p_effective_date         IN  DATE DEFAULT SYSDATE,
        p_party_id               IN  NUMBER DEFAULT NULL,
        p_validity               IN  VARCHAR2 DEFAULT NULL,
        p_object_version_number  IN OUT NUMBER
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        v_error_msg               VARCHAR2 (3000);
        l_resp_status varchar2(20);
        -----
        L_RET_CLOB                CLOB;
    BEGIN
        init_session(P_PERSON_ID);
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        ---
        IF P_VALIDATE = 'TRUE' THEN L_VALIDATE := TRUE; ELSE L_VALIDATE := FALSE; END IF;
        ---
        hr_phone_api.update_phone(
            P_VALIDATE               => L_VALIDATE,
            p_phone_id               => p_phone_id,
            p_date_from              => p_date_from,
            p_phone_type             => p_phone_type,
            p_phone_number           => p_phone_number,
            p_attribute_category     => p_attribute_category,
            p_effective_date         => p_effective_date,
            p_party_id               => p_party_id,
            p_validity               => p_validity,
            p_object_version_number  => p_object_version_number
        );
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('PHONE_VERSION_NUMBER', p_object_version_number);
            APEX_JSON.open_array('MESSAGES');
            APEX_JSON.close_array;
            ---------------------
            APEX_JSON.close_object;
            L_RET_CLOB := APEX_JSON.get_clob_output;
            APEX_JSON.free_output;
            ---------------------------------------------
            RETURN L_RET_CLOB;
            
            EXCEPTION
                WHEN OTHERS THEN
                v_error_msg   := sqlerrm;
                IF p_object_version_number IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if p_object_version_number is not null then
                    APEX_JSON.write('PHONE_VERSION_NUMBER', p_object_version_number);
                else
                    APEX_JSON.write('PHONE_VERSION_NUMBER', 'null');
                end if;
                APEX_JSON.open_array('MESSAGES');
                APEX_JSON.open_object;
                    APEX_JSON.write('TYPE', l_resp_status);
                    APEX_JSON.write('CODE', 'NULL');
                    APEX_JSON.write('MSG_TXT', v_error_msg);
                APEX_JSON.close_object;
                APEX_JSON.close_array;
                ---------------------
                APEX_JSON.close_object;
                L_RET_CLOB := APEX_JSON.get_clob_output;
                APEX_JSON.free_output;
                --
                L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
                ---------------------------------------------
                RETURN L_RET_CLOB;
    END;

          /* #endregion */
          -- END Update Phone - HRMS APIs

          -- START Delete Phone - HRMS APIs
          /* #region Delete Phone - HRMS APIs*/
   
  FUNCTION delete_phone (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_phone_id               IN  NUMBER,
        p_object_version_number  IN OUT NUMBER
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        v_error_msg               VARCHAR2 (3000);
        l_resp_status varchar2(20);
        -----
        L_RET_CLOB                CLOB;
    BEGIN
        init_session(P_PERSON_ID);
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        ---
        IF P_VALIDATE = 'TRUE' THEN L_VALIDATE := TRUE; ELSE L_VALIDATE := FALSE; END IF;
        ---
        hr_phone_api.delete_phone(
            P_VALIDATE               => L_VALIDATE,
            p_phone_id               => p_phone_id,
            p_object_version_number  => p_object_version_number
        );
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('DELETED_PHONE_ID', p_phone_id);
            APEX_JSON.open_array('MESSAGES');
            APEX_JSON.close_array;
            ---------------------
            APEX_JSON.close_object;
            L_RET_CLOB := APEX_JSON.get_clob_output;
            APEX_JSON.free_output;
            ---------------------------------------------
            RETURN L_RET_CLOB;
            
            EXCEPTION
                WHEN OTHERS THEN
                v_error_msg   := sqlerrm;
                l_resp_status := 'error';
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                APEX_JSON.write('DELETED_PHONE_ID', p_phone_id);
                APEX_JSON.open_array('MESSAGES');
                APEX_JSON.open_object;
                    APEX_JSON.write('TYPE', l_resp_status);
                    APEX_JSON.write('CODE', 'NULL');
                    APEX_JSON.write('MSG_TXT', v_error_msg);
                APEX_JSON.close_object;
                APEX_JSON.close_array;
                ---------------------
                APEX_JSON.close_object;
                L_RET_CLOB := APEX_JSON.get_clob_output;
                APEX_JSON.free_output;
                --
                L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
                ---------------------------------------------
                RETURN L_RET_CLOB;
    END;

          /* #endregion */
          -- END Delete Phone - HRMS APIs

          -- START Test Create Phone - HRMS APIs
          /* #region Test Create Phone - HRMS APIs*/
SET SERVEROUTPUT ON;

DECLARE
    p_object_version_number   NUMBER DEFAULT 1;
    p_phone_id                NUMBER DEFAULT 98927;
BEGIN
    DBMS_OUTPUT.PUT_LINE(xxx_zain_ess_pkg.create_phone(p_validate => 'TRUE',
                            p_date_from => SYSDATE, 
                            p_date_to => SYSDATE,
                            p_phone_type => 'M',
                            p_phone_number => 0123456789,
                            p_parent_id => 124101,
                            p_parent_table => 'PER_ALL_PEOPLE_F',
                            p_effective_date => SYSDATE,
                            p_phone_id => p_phone_id,
                            p_object_version_number => p_object_version_number));
        

    dbms_output.put_line('Success : ');

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error raised : ' || sqlerrm);
END;
          /* #endregion */
          -- END Test Create Phone - HRMS APIs

          -- START Test Update Phone - HRMS APIs
          /* #region Test Create Phone - HRMS APIs*/

SET SERVEROUTPUT ON;

DECLARE
    p_object_version_number   NUMBER DEFAULT 2;
    p_phone_id                NUMBER DEFAULT 98933;
BEGIN
    DBMS_OUTPUT.PUT_LINE(xxx_zain_ess_pkg.update_phone(p_validate => 'FALSE',
                             p_phone_type => 'M',
                             p_phone_number => 01234567891000,
                             p_phone_id => p_phone_id,
                             p_object_version_number => p_object_version_number));
        

    dbms_output.put_line('Success : ');

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error raised : ' || sqlerrm);
END;

          /* #endregion */
          -- END Test Update Phone - HRMS APIs

          -- START Test Delete Phone - HRMS APIs
          /* #region Test Delete Phone - HRMS APIs*/
SET SERVEROUTPUT ON;

DECLARE
    p_object_version_number   NUMBER DEFAULT 2;
    p_phone_id                NUMBER DEFAULT 98933;
BEGIN
    DBMS_OUTPUT.PUT_LINE(xxx_zain_ess_pkg.delete_phone(p_validate => 'FALSE',
                             p_phone_id => p_phone_id,
                             p_object_version_number => p_object_version_number));
        

    dbms_output.put_line('Success : ');

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error raised : ' || sqlerrm);
END;
          /* #endregion */
          -- END Test Delete Phone - HRMS APIs


    /* #endregion */
    -- END Create/Update/Delete Phone - HRMS APIs


    -- START Create/Update/Delete Contact Relationships - HRMS APIs
    /* #region Create/Update/Delete Contact Relationships - HRMS APIs */
        /* #region Create Contact Relationship - HRMS APIs*/
  
  FUNCTION create_contact_relationship (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        P_DATE_START                 DATE DEFAULT SYSDATE,
        P_START_DATE                 DATE DEFAULT SYSDATE,
        P_C_PERSON_ID               NUMBER default null,
        P_CONTACT_PERSON_ID          NUMBER default null,
        P_TITLE                      VARCHAR2 DEFAULT NULL,
        P_CONTACT_TYPE                VARCHAR2 DEFAULT NULL,
        P_PRIMARY_CONTACT_FLAG        VARCHAR2 DEFAULT 'N',
        P_CONT_ATTRIBUTE16            VARCHAR2 DEFAULT NULL,
        P_LAST_NAME                   VARCHAR2 DEFAULT NULL,
        P_SEX                         VARCHAR2 DEFAULT NULL,
        P_PERSON_TYPE_ID              NUMBER default 1125,
        P_DATE_OF_BIRTH               DATE DEFAULT NULL,
        P_FIRST_NAME                  VARCHAR2 DEFAULT NULL,
        P_PERSONAL_FLAG               VARCHAR2 DEFAULT 'N'
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN;
        l_per_start_date            DATE;
        l_per_end_date              DATE;
        l_per_comment_id            NUMBER;
        l_name_comb_warning         BOOLEAN;
        l_contact_full_name         VARCHAR2(240);
        l_contact_relationship_id   NUMBER;
        l_contact_rel_ovn           NUMBER;
        l_contact_person_id         NUMBER;
        l_contact_person_ovn        NUMBER;
        l_errors                    VARCHAR2 (100);
        L_ORIG_HIRE_WARNING         BOOLEAN;

        --------------
        v_error_msg               VARCHAR2 (3000);
        l_resp_status varchar2(20);
        -----
        L_RET_CLOB                CLOB;
    BEGIN
        init_session(P_PERSON_ID);
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        ---
        IF P_VALIDATE = 'TRUE' THEN L_VALIDATE := TRUE; ELSE L_VALIDATE := FALSE; END IF;
        ---
        HR_CONTACT_REL_API.CREATE_CONTACT (
                                      -- IN
                                      P_VALIDATE                    => L_VALIDATE,
                                      P_DATE_START                  => P_DATE_START,
                                      P_START_DATE                  => P_START_DATE,
                                      P_BUSINESS_GROUP_ID           => FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'), --101,
                                      P_PERSON_ID                   => P_C_PERSON_ID, --521,
                                      P_CONTACT_PERSON_ID           => P_CONTACT_PERSON_ID, --124101
--                                      P_TITLE                       => P_TITLE,
                                      P_CONTACT_TYPE                => P_CONTACT_TYPE, --'F', --'BROTHER',
                                      P_PRIMARY_CONTACT_FLAG        => P_PRIMARY_CONTACT_FLAG, --'N',
                                      P_CONT_ATTRIBUTE16            => P_CONT_ATTRIBUTE16, --NULL,
                                      P_LAST_NAME                   => P_LAST_NAME, --'LastName_test',
                                      P_SEX                         => P_SEX, --'M',
                                      P_PERSON_TYPE_ID              => P_PERSON_TYPE_ID, --1125,
                                      P_DATE_OF_BIRTH               => P_DATE_OF_BIRTH,
                                      P_FIRST_NAME                  => P_FIRST_NAME, --'FirstName_test',
                                      P_PERSONAL_FLAG               => P_PERSONAL_FLAG, --'N',
                                      -- OUT
                                      P_CONTACT_RELATIONSHIP_ID     => l_contact_relationship_id,
                                      P_CTR_OBJECT_VERSION_NUMBER   => l_contact_rel_ovn,
                                      P_PER_PERSON_ID               => l_contact_person_id,
                                      P_PER_OBJECT_VERSION_NUMBER   => l_contact_person_ovn,
                                      P_PER_EFFECTIVE_START_DATE    => l_per_start_date,
                                      P_PER_EFFECTIVE_END_DATE      => l_per_end_date,
                                      P_FULL_NAME                   => l_contact_full_name,
                                      P_PER_COMMENT_ID              => l_per_comment_id,
                                      P_NAME_COMBINATION_WARNING    => l_name_comb_warning,
                                      P_ORIG_HIRE_WARNING           => L_ORIG_HIRE_WARNING);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('CONTACT_RELATIONSHIP_ID', l_contact_relationship_id);
            APEX_JSON.open_array('MESSAGES');
            APEX_JSON.close_array;
            ---------------------
            APEX_JSON.close_object;
            L_RET_CLOB := APEX_JSON.get_clob_output;
            APEX_JSON.free_output;
            ---------------------------------------------
            RETURN L_RET_CLOB;
            
            EXCEPTION
                WHEN OTHERS THEN
                v_error_msg   := sqlerrm;
                IF l_contact_relationship_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_contact_relationship_id is not null then
                    APEX_JSON.write('CONTACT_RELATIONSHIP_ID', l_contact_relationship_id);
                else
                    APEX_JSON.write('CONTACT_RELATIONSHIP_ID', 'null');
                end if;
                APEX_JSON.open_array('MESSAGES');
                APEX_JSON.open_object;
                    APEX_JSON.write('TYPE', l_resp_status);
                    APEX_JSON.write('CODE', 'NULL');
                    APEX_JSON.write('MSG_TXT', v_error_msg);
                APEX_JSON.close_object;
                APEX_JSON.close_array;
                ---------------------
                APEX_JSON.close_object;
                L_RET_CLOB := APEX_JSON.get_clob_output;
                APEX_JSON.free_output;
                --
                L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
                ---------------------------------------------
                RETURN L_RET_CLOB;
    END;
    
    /* #endregion */
    -- END Create Contact Relationship - HRMS APIs
    -- ----
    /* #region Update Contact Relationship - HRMS APIs*/
   
  FUNCTION update_contact_relationship (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_effective_date            DATE DEFAULT SYSDATE,
        p_contact_relationship_id   NUMBER DEFAULT NULL,
        P_CONTACT_TYPE                VARCHAR2 DEFAULT NULL,
        P_PRIMARY_CONTACT_FLAG        VARCHAR2 DEFAULT 'N',
        P_PERSONAL_FLAG               VARCHAR2 DEFAULT 'N',
        -- IN OUT
        p_object_version_number     IN OUT NUMBER
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        v_error_msg               VARCHAR2 (3000);
        l_resp_status varchar2(20);
        -----
        L_RET_CLOB                CLOB;
    BEGIN
        init_session(P_PERSON_ID);
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        ---
        IF P_VALIDATE = 'TRUE' THEN L_VALIDATE := TRUE; ELSE L_VALIDATE := FALSE; END IF;
        ---
        hr_contact_rel_api.update_contact_relationship(p_validate => L_VALIDATE,
                                                      p_effective_date => p_effective_date,
                                                      p_contact_relationship_id => p_contact_relationship_id,
                                                      p_contact_type => p_contact_type,
                                                      p_primary_contact_flag => p_primary_contact_flag,
                                                      P_PERSONAL_FLAG => P_PERSONAL_FLAG,
                                                      p_object_version_number => p_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('OBJECT_VERSION_NUMBER', p_object_version_number);
            APEX_JSON.open_array('MESSAGES');
            APEX_JSON.close_array;
            ---------------------
            APEX_JSON.close_object;
            L_RET_CLOB := APEX_JSON.get_clob_output;
            APEX_JSON.free_output;
            ---------------------------------------------
            RETURN L_RET_CLOB;
            
            EXCEPTION
                WHEN OTHERS THEN
                v_error_msg   := sqlerrm;
                IF p_object_version_number IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if p_object_version_number is not null then
                    APEX_JSON.write('OBJECT_VERSION_NUMBER', p_object_version_number);
                else
                    APEX_JSON.write('OBJECT_VERSION_NUMBER', 'null');
                end if;
                APEX_JSON.open_array('MESSAGES');
                APEX_JSON.open_object;
                    APEX_JSON.write('TYPE', l_resp_status);
                    APEX_JSON.write('CODE', 'NULL');
                    APEX_JSON.write('MSG_TXT', v_error_msg);
                APEX_JSON.close_object;
                APEX_JSON.close_array;
                ---------------------
                APEX_JSON.close_object;
                L_RET_CLOB := APEX_JSON.get_clob_output;
                APEX_JSON.free_output;
                --
                L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
                ---------------------------------------------
                RETURN L_RET_CLOB;
    END;

    /* #endregion */
    -- END Update Contact Relationship - HRMS APIs
    -- ----
    /* #region Delete Contact Relationship - HRMS APIs*/
   
  FUNCTION delete_contact_relationship (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_contact_relationship_id   NUMBER DEFAULT NULL,
        p_object_version_number     NUMBER DEFAULT 1
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        v_error_msg               VARCHAR2 (3000);
        l_resp_status varchar2(20);
        -----
        L_RET_CLOB                CLOB;
    BEGIN
        init_session(P_PERSON_ID);
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        ---
        IF P_VALIDATE = 'TRUE' THEN L_VALIDATE := TRUE; ELSE L_VALIDATE := FALSE; END IF;
        ---
        hr_contact_rel_api.delete_contact_relationship(
                    p_validate                  => L_VALIDATE,
                    p_contact_relationship_id   => p_contact_relationship_id,
                    p_object_version_number     => p_object_version_number
                );
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('DELETED_CONTACT_ID', p_object_version_number);
            APEX_JSON.open_array('MESSAGES');
            APEX_JSON.close_array;
            ---------------------
            APEX_JSON.close_object;
            L_RET_CLOB := APEX_JSON.get_clob_output;
            APEX_JSON.free_output;
            ---------------------------------------------
            RETURN L_RET_CLOB;
            
            EXCEPTION
                WHEN OTHERS THEN
                v_error_msg   := sqlerrm;
                l_resp_status := 'error';
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                APEX_JSON.write('DELETED_CONTACT_ID', p_object_version_number);
                APEX_JSON.open_array('MESSAGES');
                APEX_JSON.open_object;
                    APEX_JSON.write('TYPE', l_resp_status);
                    APEX_JSON.write('CODE', 'NULL');
                    APEX_JSON.write('MSG_TXT', v_error_msg);
                APEX_JSON.close_object;
                APEX_JSON.close_array;
                ---------------------
                APEX_JSON.close_object;
                L_RET_CLOB := APEX_JSON.get_clob_output;
                APEX_JSON.free_output;
                --
                L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
                ---------------------------------------------
                RETURN L_RET_CLOB;
    END;
   

    /* #endregion */
    -- END Delete Contact Relationship - HRMS APIs


    -- ----
    /* #region Test create contact rel packeg API */
SET SERVEROUTPUT ON;

DECLARE
    l_clob CLOB;
BEGIN
    DBMS_OUTPUT.PUT_LINE(xxx_zain_ess_pkg.create_contact_relationship(p_person_id => 124101, p_validate => 'FALSE',
                                                    p_c_person_id => 126822,
                                                    p_contact_person_id => 121151,
                                                    p_contact_type => 'BROTHER',
                                                    p_primary_contact_flag => 'N',
                                                    p_cont_attribute16 => NULL,
                                                    p_last_name => 'test_last_name',
                                                    p_sex => 'F',
                                                    p_first_name => 'test_first_name',
                                                    p_personal_flag => 'N'));
        

    dbms_output.put_line('Success : ');
--    dbms_output.put_line('the API result is: '|| l_clob);

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error raised : ' || sqlerrm);
END;
    /* #endregion */
    -- END Test create contact rel packeg API
    -- ----

    /* #region Test update contact rel packeg API */
SET SERVEROUTPUT ON;

DECLARE
    l_contact_rel_ovn NUMBER DEFAULT 5;
BEGIN
    DBMS_OUTPUT.PUT_LINE(xxx_zain_ess_pkg.update_contact_relationship(p_validate => 'TRURE',
                                                    p_effective_date => SYSDATE,
                                                    p_contact_relationship_id => 1135690,
                                                    p_contact_type => 'F',
                                                    p_primary_contact_flag => 'N',
                                                    P_PERSONAL_FLAG => 'N',
                                                    p_object_version_number => l_contact_rel_ovn));
        

    dbms_output.put_line('Success : ');
    dbms_output.put_line('p_object_version_number : '|| l_contact_rel_ovn);

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error raised : ' || sqlerrm);
END;
    /* #endregion */
    -- END Test update contact rel packeg API
    -- ----

    /* #region Test delete contact rel packeg API */
SET SERVEROUTPUT ON;

DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE(xxx_zain_ess_pkg.delete_contact_relationship(p_validate => 'TRURE',
                                                    p_contact_relationship_id => 1135690,
                                                    p_object_version_number => 6));
        

    dbms_output.put_line('Success : ');

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error raised : ' || sqlerrm);
END;
    /* #endregion */
    -- END Test delete contact rel packeg API
    -- ----
    
    /* #endregion */
    -- END Create/Update/Delete Contact Relationships - HRMS APIs

    

/* #endregion */
-- END Person Information API
-- ----



-- ----
/* #region test */
    
/* #endregion */

