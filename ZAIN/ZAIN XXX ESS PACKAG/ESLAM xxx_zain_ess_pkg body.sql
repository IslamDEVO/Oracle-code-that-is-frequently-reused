
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
        p_object_version_number     IN NUMBER
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        l_object_version_number     NUMBER DEFAULT 1; 
        -------------
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
        l_object_version_number := p_object_version_number;
        ---
        hr_contact_rel_api.update_contact_relationship(p_validate => L_VALIDATE,
                                                      p_effective_date => p_effective_date,
                                                      p_contact_relationship_id => p_contact_relationship_id,
                                                      p_contact_type => p_contact_type,
                                                      p_primary_contact_flag => p_primary_contact_flag,
                                                      P_PERSONAL_FLAG => P_PERSONAL_FLAG,
                                                      p_object_version_number => l_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('OBJECT_VERSION_NUMBER', l_object_version_number);
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
                IF l_object_version_number IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_object_version_number is not null then
                    APEX_JSON.write('OBJECT_VERSION_NUMBER', l_object_version_number);
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
   
  FUNCTION delete_contact_relationship (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_contact_relationship_id   NUMBER DEFAULT NULL,
        p_delete_other              VARCHAR2 DEFAULT 'N',
        p_object_version_number     NUMBER DEFAULT 1
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
    CURSOR contacts_cursor IS
    SELECT
        contact_relationship_id
    FROM
        per_contact_relationships
    WHERE
        contact_person_id IN (
            SELECT
                contact_person_id
            FROM
                per_contact_relationships
            WHERE
                contact_relationship_id = p_contact_relationship_id
        );
        
        l_object_version_number   NUMBER;
        l_address_id              NUMBER;
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
--        SELECT object_version_number, address_id
--        INTO l_object_version_number, l_address_id
--        FROM per_addresses
--        WHERE person_id = (
--            SELECT contact_person_id 
--            FROM per_contact_relationships
--            WHERE contact_relationship_id = p_contact_relationship_id
--        );
--        hr_person_address_api.update_person_address(p_validate => L_VALIDATE, 
--                                               p_effective_date => SYSDATE,
--                                               p_date_from => SYSDATE - 5,
--                                               p_date_to => SYSDATE - 1,
--                                               p_address_id => l_address_id,
--                                               p_object_version_number => l_object_version_number);
        ---
        IF UPPER(p_delete_other) = 'Y' THEN
            FOR contact_rel_id IN contacts_cursor
                LOOP
                    SELECT object_version_number
                    INTO l_object_version_number
                    FROM per_contact_relationships
                    WHERE contact_relationship_id = contact_rel_id.contact_relationship_id;
                    hr_contact_rel_api.update_contact_relationship(p_validate => L_VALIDATE,
                                                                  p_effective_date => SYSDATE,
                                                                  p_date_start=> SYSDATE-5,
                                                                  p_date_end=> SYSDATE-1,
                                                                  p_contact_relationship_id => contact_rel_id.contact_relationship_id,
                                                                  p_object_version_number => l_object_version_number);
                END LOOP;
        ELSE
            SELECT object_version_number
            INTO l_object_version_number
            FROM per_contact_relationships
            WHERE contact_relationship_id = p_contact_relationship_id;
            hr_contact_rel_api.update_contact_relationship(p_validate => L_VALIDATE,
                                                                  p_effective_date => SYSDATE,
                                                                  p_date_start=> SYSDATE-5,
                                                                  p_date_end=> SYSDATE-1,
                                                                  p_contact_relationship_id => p_contact_relationship_id,
                                                                  p_object_version_number => l_object_version_number);
        END IF;
        ---
--        hr_contact_rel_api.delete_contact_relationship(
--                    p_validate                  => L_VALIDATE,
--                    p_contact_relationship_id   => p_contact_relationship_id,
--                    p_object_version_number     => l_object_version_number
--                );
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('DELETED_CONTACT_ID', l_object_version_number);
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
                APEX_JSON.write('DELETED_CONTACT_ID', l_object_version_number);
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
        p_validity               IN  VARCHAR2 DEFAULT NULL
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        l_object_version_number   NUMBER;
        l_phone_id                NUMBER;
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
            p_object_version_number  => l_object_version_number,
            p_phone_id               => l_phone_id
        );
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('PHONE_ID', l_phone_id);
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
                IF l_phone_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_phone_id is not null then
                    APEX_JSON.write('PHONE_ID', l_phone_id);
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
        p_object_version_number  IN  NUMBER
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        l_object_version_number     NUMBER DEFAULT 1;
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
        l_object_version_number := p_object_version_number;
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
            p_object_version_number  => l_object_version_number
        );
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('PHONE_VERSION_NUMBER', l_object_version_number);
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
                IF l_object_version_number IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_object_version_number is not null then
                    APEX_JSON.write('PHONE_VERSION_NUMBER', l_object_version_number);
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

   
  FUNCTION delete_phone (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_phone_id               IN  NUMBER,
        p_object_version_number  IN  NUMBER
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        l_object_version_number     NUMBER DEFAULT 1;
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
        l_object_version_number := p_object_version_number;
        ---
        hr_phone_api.delete_phone(
            P_VALIDATE               => L_VALIDATE,
            p_phone_id               => p_phone_id,
            p_object_version_number  => l_object_version_number
        );
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('DELETED_PHONE_VERSION', l_object_version_number);
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
                APEX_JSON.write('DELETED_PHONE_VERSION', l_object_version_number);
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
    p_party_id                 IN  NUMBER DEFAULT NULL

        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        l_address_id                NUMBER;
        l_object_version_number     NUMBER;
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
                                               p_address_id => l_address_id,
                                               p_object_version_number => l_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('ADRESS_ID', l_address_id);
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
                IF l_address_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_address_id is not null then
                    APEX_JSON.write('ADRESS_ID', l_address_id);
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
     
  FUNCTION delete_person_address (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_address_id               IN  NUMBER
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        l_object_version_number NUMBER DEFAULT 1;
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
        SELECT object_version_number
        INTO l_object_version_number
        FROM per_addresses
        WHERE address_id = p_address_id;

        hr_person_address_api.update_person_address(p_validate => L_VALIDATE, 
                                               p_effective_date => SYSDATE,
                                               p_date_from => SYSDATE - 5,
                                               p_date_to => SYSDATE - 1,
                                               p_address_id => p_address_id,
                                               p_object_version_number => l_object_version_number);
        
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('OBJECT_VERSION_NUMBER', l_object_version_number);
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
                IF l_object_version_number IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_object_version_number is not null then
                    APEX_JSON.write('OBJECT_VERSION_NUMBER', l_object_version_number);
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

     
  FUNCTION update_person_address (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_effective_date           IN  DATE DEFAULT SYSDATE,
    p_validate_county          IN  BOOLEAN DEFAULT true,
    p_address_id               IN  NUMBER,
    p_date_from                IN  DATE DEFAULT NULL,
    p_date_to                  IN  DATE DEFAULT NULL,
    p_primary_flag             IN  VARCHAR2,
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
    p_party_id                 IN  NUMBER DEFAULT NULL
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------
        l_object_version_number NUMBER DEFAULT 1;
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
        SELECT object_version_number
        INTO l_object_version_number
        FROM per_addresses
        WHERE address_id = p_address_id;
        hr_person_address_api.update_person_address(p_validate => L_VALIDATE, p_effective_date => p_effective_date,
                                               p_validate_county => p_validate_county,
--                                               p_primary_flag => p_primary_flag,
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
                                               p_object_version_number => l_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('OBJECT_VERSION_NUMBER', l_object_version_number);
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
                IF l_object_version_number IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_object_version_number is not null then
                    APEX_JSON.write('OBJECT_VERSION_NUMBER', l_object_version_number);
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
   
  FUNCTION create_sa_contact_person (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_start_date                    IN  DATE DEFAULT SYSDATE,
        p_business_group_id             IN  NUMBER DEFAULT NULL,
        p_person_type_id                IN  NUMBER DEFAULT NULL,
        p_family_name                   IN  VARCHAR2,
        p_sex                           IN  VARCHAR2,
        p_comments                      IN  VARCHAR2 DEFAULT NULL,
        p_date_employee_data_verified   IN  DATE DEFAULT NULL,
        p_date_of_birth                 IN  DATE DEFAULT NULL,
        p_email_address                 IN  VARCHAR2 DEFAULT NULL,
        p_expense_check_send_to_addres  IN  VARCHAR2 DEFAULT NULL,
        p_first_name                    IN  VARCHAR2 DEFAULT NULL,
        p_known_as                      IN  VARCHAR2 DEFAULT NULL,
        p_marital_status                IN  VARCHAR2 DEFAULT NULL,
        p_nationality                   IN  VARCHAR2 DEFAULT NULL,
        p_national_identifier           IN  VARCHAR2 DEFAULT NULL,
        p_previous_last_name            IN  VARCHAR2 DEFAULT NULL,
        p_registered_disabled_flag      IN  VARCHAR2 DEFAULT NULL,
        p_title                         IN  VARCHAR2 DEFAULT NULL,
        p_vendor_id                     IN  NUMBER DEFAULT NULL,
        p_work_telephone                IN  VARCHAR2 DEFAULT NULL,
        p_attribute_category            IN  VARCHAR2 DEFAULT NULL,
        p_father_name                   IN  VARCHAR2 DEFAULT NULL,
        p_grandfather_name              IN  VARCHAR2 DEFAULT NULL,
        p_alt_first_name                IN  VARCHAR2 DEFAULT NULL,
        p_alt_father_name               IN  VARCHAR2 DEFAULT NULL,
        p_alt_grandfather_name          IN  VARCHAR2 DEFAULT NULL,
        p_alt_family_name               IN  VARCHAR2 DEFAULT NULL,
        p_religion                      IN  VARCHAR2 DEFAULT NULL,
        p_hijrah_birth_date             IN  VARCHAR2 DEFAULT NULL,
        p_education_level               IN  VARCHAR2 DEFAULT NULL,
        p_correspondence_language       IN  VARCHAR2 DEFAULT NULL,
        p_honors                        IN  VARCHAR2 DEFAULT NULL,
        p_benefit_group_id              IN  NUMBER DEFAULT NULL,
        p_on_military_service           IN  VARCHAR2 DEFAULT NULL,
        p_student_status                IN  VARCHAR2 DEFAULT NULL,
        p_uses_tobacco_flag             IN  VARCHAR2 DEFAULT NULL,
        p_coord_ben_no_cvg_flag         IN  VARCHAR2 DEFAULT NULL,
        p_town_of_birth                 IN  VARCHAR2 DEFAULT NULL,
        p_region_of_birth               IN  VARCHAR2 DEFAULT NULL,
        p_country_of_birth              IN  VARCHAR2 DEFAULT NULL,
        p_global_person_id              IN  VARCHAR2 DEFAULT NULL,
        p_contact_type                  IN VARCHAR2 DEFAULT NULL,
        p_primary_contact_flag          IN VARCHAR2 DEFAULT 'N',
        P_PERSONAL_FLAG                 IN VARCHAR2 DEFAULT 'N',
        p_use_primary_address           IN VARCHAR2 DEFAULT 'Y',
        p_effective_date                IN  DATE DEFAULT SYSDATE,
        p_primary_flag                  IN  VARCHAR2 DEFAULT 'N',
        p_address_type                  IN  VARCHAR2 DEFAULT NULL,
        p_town_or_city                  IN  VARCHAR2 DEFAULT NULL,
        p_region_1                      IN  VARCHAR2 DEFAULT NULL,
        p_region_2                      IN  VARCHAR2 DEFAULT NULL,
        p_region_3                      IN  VARCHAR2 DEFAULT NULL,
        p_postal_code                   IN  VARCHAR2 DEFAULT NULL,
        p_country                       IN  VARCHAR2 DEFAULT NULL,
        p_add_information13             IN  VARCHAR2 DEFAULT NULL,
        p_add_information14             IN  VARCHAR2 DEFAULT NULL

        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------        
        l_person_id                  NUMBER;
        l_object_version_number      NUMBER;
        l_effective_start_date       DATE;
        l_effective_end_date         DATE;
        l_full_name                  VARCHAR2(250);
        l_comment_id                 NUMBER;
        l_name_combination_warning   BOOLEAN;
        l_orig_hire_warning          BOOLEAN;
        ---
        l_per_start_date            DATE;
        l_per_end_date              DATE;
        l_per_comment_id            NUMBER;
        l_name_comb_warning         BOOLEAN;
        l_contact_full_name         VARCHAR2(240);
        l_contact_relationship_id   NUMBER;
        l_contact_rel_ovn           NUMBER;
        l_contact_person_id         NUMBER;
        l_contact_person_ovn        NUMBER;
        --------------
        l_address_id                NUMBER;
        --
        l_country                   VARCHAR2(50);
        l_address_type              VARCHAR2(200);
        l_town_or_city              VARCHAR2(50);
        l_region_1                  VARCHAR2(50);
        l_region_2                  VARCHAR2(50);
        l_region_3                  NUMBER;
        l_postal_code               VARCHAR2(50);
        l_add_information13         VARCHAR2(50);
        l_add_information14         VARCHAR2(50);

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
        hr_sa_contact_api.create_sa_person (
                              p_validate                       => L_VALIDATE,
                              p_start_date                     => p_start_date,
                              p_business_group_id              => FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'),
                              p_family_name                    => p_family_name,
                              p_sex                            => p_sex,
                              p_person_type_id                 => 1125,
                              p_comments                       => p_comments,
                              p_date_employee_data_verified    => p_date_employee_data_verified,
                              p_date_of_birth                  => p_date_of_birth,
                              p_email_address                  => p_email_address,
                              p_expense_check_send_to_addres   => p_expense_check_send_to_addres,
                              p_first_name                     => p_first_name,
                              p_known_as                       => p_known_as,
                              p_marital_status                 => p_marital_status,
                              p_nationality                    => p_nationality,
                              p_national_identifier            => p_national_identifier,
                              p_previous_last_name             => p_previous_last_name,
                              p_registered_disabled_flag       => p_registered_disabled_flag,
                              p_title                          => p_title,
                              p_vendor_id                      => p_vendor_id,
                              p_work_telephone                 => p_work_telephone,
                              p_attribute_category             => 'SA',
                              p_father_name                    => p_father_name,
                              p_grandfather_name               => p_grandfather_name,
                              p_alt_first_name                 => p_alt_first_name,
                              p_alt_father_name                => p_alt_father_name,
                              p_alt_grandfather_name           => p_alt_grandfather_name,
                              p_alt_family_name                => p_alt_family_name,
                              p_religion                       => p_religion,
                              p_hijrah_birth_date              => p_hijrah_birth_date,
                              p_education_level                => p_education_level,
                              p_correspondence_language        => p_correspondence_language,
                              p_honors                         => p_honors,
                              p_benefit_group_id               => p_benefit_group_id,
                              p_on_military_service            => p_on_military_service,
                              p_student_status                 => p_student_status,
                              p_uses_tobacco_flag              => p_uses_tobacco_flag,
                              p_coord_ben_no_cvg_flag          => p_coord_ben_no_cvg_flag,
                              p_town_of_birth                  => p_town_of_birth,
                              p_region_of_birth                => p_region_of_birth,
                              p_country_of_birth               => p_country_of_birth,
                              p_global_person_id               => p_global_person_id,
                              p_person_id                      => l_person_id,
                              p_object_version_number          => l_object_version_number,
                              p_effective_start_date           => l_effective_start_date,
                              p_effective_end_date             => l_effective_end_date,
                              p_full_name                      => l_full_name,
                              p_comment_id                     => l_comment_id,
                              p_name_combination_warning       => l_name_combination_warning,
                              p_orig_hire_warning              => l_orig_hire_warning);
                              
            IF l_person_id IS NOT NULL THEN
               
               HR_CONTACT_REL_API.CREATE_CONTACT (
                                      -- IN
                                      P_VALIDATE                    => L_VALIDATE,
                                      P_DATE_START                  => p_start_date,
                                      P_START_DATE                  => p_start_date,
                                      P_BUSINESS_GROUP_ID           => FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'),
                                      P_PERSON_ID                   => P_PERSON_ID, 
                                      P_CONTACT_PERSON_ID           => l_person_id, --
                                      P_CONTACT_TYPE                => P_CONTACT_TYPE, --'F', --'BROTHER',
                                      P_PRIMARY_CONTACT_FLAG        => P_PRIMARY_CONTACT_FLAG, --'N',
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

            END IF;
            /* create address */
            IF l_contact_relationship_id IS NOT NULL THEN
                    IF p_use_primary_address = 'N' THEN
                        hr_person_address_api.create_person_address(p_validate => L_VALIDATE, 
                                               p_effective_date => SYSDATE, 
                                               p_person_id => L_person_id,
                                               p_primary_flag => p_primary_flag,
                                               p_style => 'SA',
                                               p_date_from => SYSDATE,
                                               p_address_type => p_address_type,
                                               p_town_or_city => p_town_or_city,
                                               p_region_1 => p_region_1,
                                               p_region_2 => p_region_2,
                                               p_region_3 => p_region_3,
                                               p_postal_code => p_postal_code,
                                               p_country => p_country,
                                               p_add_information13 => p_add_information13,
                                               p_add_information14 => p_add_information14,
                                               p_address_id => l_address_id,
                                               p_object_version_number => l_object_version_number);
--                    ELSE
--                        SELECT town_or_city, postal_code, region_1, region_2, region_3, add_information13, add_information14, address_type, country
--                        INTO l_town_or_city, l_postal_code, l_region_1, l_region_2, l_region_3, l_add_information13, l_add_information14, l_address_type, l_country
--                        FROM per_addresses WHERE primary_flag = 'Y' AND person_id = P_PERSON_ID;
--                        
--                        hr_person_address_api.create_person_address(p_validate => L_VALIDATE, 
--                                               p_effective_date => SYSDATE, 
--                                               p_person_id => L_person_id,
--                                               p_primary_flag => p_primary_flag,
--                                               p_style => 'SA',
--                                               p_date_from => SYSDATE,
--                                               p_address_type => l_address_type,
--                                               p_town_or_city => l_town_or_city,
--                                               p_region_1 => l_region_1,
--                                               p_region_2 => l_region_2,
--                                               p_region_3 => l_region_3,
--                                               p_postal_code => l_postal_code,
--                                               p_country => l_country,
--                                               p_add_information13 => l_add_information13,
--                                               p_add_information14 => l_add_information14,
--                                               p_address_id => l_address_id,
--                                               p_object_version_number => l_object_version_number);
                    END IF;
            END IF;

            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('PERSON_ID', l_person_id);
            APEX_JSON.write('CONTACT_RELATIONSHIP_ID', l_contact_relationship_id);
            APEX_JSON.write('CONTACT_ADDRESS_ID', l_address_id);
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
                IF l_person_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_person_id is not null then
                    APEX_JSON.write('PERSON_ID', l_person_id);
                else
                    APEX_JSON.write('PERSON_ID', 'null');
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

   
  FUNCTION update_sa_contact_person (
        P_PERSON_ID NUMBER default null,
        -------
        P_VALIDATE                   VARCHAR2 DEFAULT 'TRUE',
        p_addEmergency_flag             IN  VARCHAR2 DEFAULT 'N',
        p_contact_person_id             IN NUMBER,
        p_start_date                    IN  DATE DEFAULT SYSDATE,
        p_family_name                   IN  VARCHAR2,
        p_sex                           IN  VARCHAR2,
        p_person_type_id                IN  NUMBER DEFAULT NULL,
        p_comments                      IN  VARCHAR2 DEFAULT NULL,
        p_date_employee_data_verified   IN  DATE DEFAULT NULL,
        p_date_of_birth                 IN  DATE DEFAULT NULL,
        p_email_address                 IN  VARCHAR2 DEFAULT NULL,
        p_expense_check_send_to_addres  IN  VARCHAR2 DEFAULT NULL,
        p_first_name                    IN  VARCHAR2 DEFAULT NULL,
        p_known_as                      IN  VARCHAR2 DEFAULT NULL,
        p_marital_status                IN  VARCHAR2 DEFAULT NULL,
        p_nationality                   IN  VARCHAR2 DEFAULT NULL,
        p_national_identifier           IN  VARCHAR2 DEFAULT NULL,
        p_previous_last_name            IN  VARCHAR2 DEFAULT NULL,
        p_registered_disabled_flag      IN  VARCHAR2 DEFAULT NULL,
        p_title                         IN  VARCHAR2 DEFAULT NULL,
        p_vendor_id                     IN  NUMBER DEFAULT NULL,
        p_work_telephone                IN  VARCHAR2 DEFAULT NULL,
        p_attribute_category            IN  VARCHAR2 DEFAULT NULL,
        p_father_name                   IN  VARCHAR2 DEFAULT NULL,
        p_grandfather_name              IN  VARCHAR2 DEFAULT NULL,
        p_alt_first_name                IN  VARCHAR2 DEFAULT NULL,
        p_alt_father_name               IN  VARCHAR2 DEFAULT NULL,
        p_alt_grandfather_name          IN  VARCHAR2 DEFAULT NULL,
        p_alt_family_name               IN  VARCHAR2 DEFAULT NULL,
        p_religion                      IN  VARCHAR2 DEFAULT NULL,
        p_hijrah_birth_date             IN  VARCHAR2 DEFAULT NULL,
        p_education_level               IN  VARCHAR2 DEFAULT NULL,
        p_correspondence_language       IN  VARCHAR2 DEFAULT NULL,
        p_honors                        IN  VARCHAR2 DEFAULT NULL,
        p_benefit_group_id              IN  NUMBER DEFAULT NULL,
        p_on_military_service           IN  VARCHAR2 DEFAULT NULL,
        p_student_status                IN  VARCHAR2 DEFAULT NULL,
        p_uses_tobacco_flag             IN  VARCHAR2 DEFAULT NULL,
        p_coord_ben_no_cvg_flag         IN  VARCHAR2 DEFAULT NULL,
        p_town_of_birth                 IN  VARCHAR2 DEFAULT NULL,
        p_region_of_birth               IN  VARCHAR2 DEFAULT NULL,
        p_country_of_birth              IN  VARCHAR2 DEFAULT NULL,
        p_global_person_id              IN  VARCHAR2 DEFAULT NULL,
        p_contact_type                  IN VARCHAR2 DEFAULT NULL,
        p_contact_relationship_id       IN NUMBER DEFAULT 1,
        p_primary_contact_flag          IN VARCHAR2 DEFAULT 'N',
        P_PERSONAL_FLAG                 IN VARCHAR2 DEFAULT 'N',
        p_use_primary_address           IN VARCHAR2 DEFAULT 'Y',
        p_address_id                    IN  NUMBER,
        p_effective_date                IN  DATE DEFAULT SYSDATE,
        p_primary_flag                  IN  VARCHAR2 DEFAULT 'N',
        p_address_type                  IN  VARCHAR2 DEFAULT NULL,
        p_town_or_city                  IN  VARCHAR2 DEFAULT NULL,
        p_region_1                      IN  VARCHAR2 DEFAULT NULL,
        p_region_2                      IN  VARCHAR2 DEFAULT NULL,
        p_region_3                      IN  VARCHAR2 DEFAULT NULL,
        p_postal_code                   IN  VARCHAR2 DEFAULT NULL,
        p_country                       IN  VARCHAR2 DEFAULT NULL,
        p_add_information13             IN  VARCHAR2 DEFAULT NULL,
        p_add_information14             IN  VARCHAR2 DEFAULT NULL
        ) RETURN CLOB
    IS
        L_VALIDATE                  BOOLEAN DEFAULT TRUE;
        --------------   
        l_ESD                        DATE;
        l_OVN                        NUMBER;
        l_dt_ud_mode                 VARCHAR2(20);
        l_employee_number            NUMBER DEFAULT NULL;
        l_object_version_number      NUMBER DEFAULT NULL;
        l_effective_start_date       DATE;
        l_effective_end_date         DATE;
        l_full_name                  VARCHAR2(250);
        l_comment_id                 NUMBER;
        l_name_combination_warning   BOOLEAN;
        l_orig_hire_warning          BOOLEAN;
        l_assign_payroll_warning     BOOLEAN;
        ---
        l_contact_rel_ovn           NUMBER;
        l_contact_type              VARCHAR2(50);
        l_per_start_date            DATE;
        l_per_end_date              DATE;
        l_per_comment_id            NUMBER;
        l_name_comb_warning         BOOLEAN;
        l_contact_full_name         VARCHAR2(240);
        l_contact_relationship_id   NUMBER;
        l_contact_person_id         NUMBER;
        l_contact_person_ovn        NUMBER;
        l_emrg_rel_id               NUMBER;
        --------------
        l_address_id                NUMBER DEFAULT NULL;
        l_address_start_date        DATE;
        l_address_OVN               NUMBER DEFAULT 0;
        --
        l_country                   VARCHAR2(50);
        l_address_type              VARCHAR2(200);
        l_town_or_city              VARCHAR2(50);
        l_region_1                  VARCHAR2(50);
        l_region_2                  VARCHAR2(50);
        l_region_3                  NUMBER;
        l_postal_code               VARCHAR2(50);
        l_add_information13         VARCHAR2(50);
        l_add_information14         VARCHAR2(50);

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
        SELECT effective_start_date, object_version_number, employee_number
        INTO l_ESD, l_OVN, l_employee_number
        FROM per_all_people_f
        WHERE     person_id = p_contact_person_id
        AND SYSDATE BETWEEN effective_start_date AND effective_end_date;
              
        l_dt_ud_mode := dt_ud_mode(p_effective_date => l_ESD, p_base_table_name => 'PER_ALL_PEOPLE_F',
                                  p_base_key_column => 'PERSON_ID',
                                  p_base_key_value => p_contact_person_id);
                                  
            /*Update Contact relationship*/
--            IF l_OVN IS NOT NULL THEN
                SELECT object_version_number
                INTO l_contact_rel_ovn
                FROM per_contact_relationships
                WHERE CONTACT_RELATIONSHIP_ID = p_contact_relationship_id;
                ---
                IF p_addEmergency_flag = 'Y' THEN
                    SELECT COALESCE(SUM(contact_relationship_id), 0)
                    INTO l_emrg_rel_id
                    FROM per_contact_relationships
                    WHERE person_id =  P_PERSON_ID
                        AND contact_person_id = p_contact_person_id
                        And contact_type = 'EMRG';
                    
                    l_contact_type := 'EMRG';
                    IF l_emrg_rel_id = 0 THEN
                        HR_CONTACT_REL_API.CREATE_CONTACT (
                                          -- IN
                                          P_VALIDATE                    => L_VALIDATE,
                                          P_DATE_START                  => p_start_date,
                                          P_START_DATE                  => p_start_date,
                                          P_BUSINESS_GROUP_ID           => FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'),
                                          P_PERSON_ID                   => P_PERSON_ID, 
                                          P_CONTACT_PERSON_ID           => p_contact_person_id, --
                                          P_CONTACT_TYPE                => l_contact_type, --'F', --'BROTHER',
                                          P_PRIMARY_CONTACT_FLAG        => P_PRIMARY_CONTACT_FLAG, --'N',
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
                    ELSE
                        SELECT object_version_number
                        INTO l_contact_rel_ovn
                        FROM per_contact_relationships
                        WHERE person_id =  P_PERSON_ID
                            AND contact_person_id = p_contact_person_id
                            And contact_type = 'EMRG';
                        hr_contact_rel_api.update_contact_relationship(p_validate   => L_VALIDATE,
                                                          p_effective_date           => p_start_date,
                                                          P_DATE_START              => p_start_date,
                                                          p_DATE_END                => NULL,
                                                          p_contact_relationship_id => l_emrg_rel_id,
                                                          p_contact_type            => l_contact_type,
--                                                          p_primary_contact_flag    => p_primary_contact_flag,
--                                                          P_PERSONAL_FLAG           => P_PERSONAL_FLAG,
                                                          p_object_version_number   => l_contact_rel_ovn);
                    END IF;
                
                END IF;
--                ELSE
                    SELECT object_version_number
                    INTO l_contact_rel_ovn
                    FROM per_contact_relationships
                    WHERE contact_relationship_id = p_contact_relationship_id;
                    
                    IF p_contact_relationship_id != 0 THEN
                        l_contact_type := p_contact_type;
                        hr_contact_rel_api.update_contact_relationship(p_validate   => L_VALIDATE,
                                                          p_effective_date           => p_start_date,
                                                          P_DATE_START              => p_start_date,
                                                          p_DATE_END                => NULL,
                                                          p_contact_relationship_id => p_contact_relationship_id,
                                                          p_contact_type            => l_contact_type,
                                                          p_primary_contact_flag    => p_primary_contact_flag,
                                                          P_PERSONAL_FLAG           => P_PERSONAL_FLAG,
                                                          p_object_version_number   => l_contact_rel_ovn);
                    ELSE
                        l_contact_type := p_contact_type;
                        HR_CONTACT_REL_API.CREATE_CONTACT (
                                      -- IN
                                      P_VALIDATE                    => L_VALIDATE,
                                      P_DATE_START                  => p_start_date,
                                      P_START_DATE                  => p_start_date,
                                      P_BUSINESS_GROUP_ID           => FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'),
                                      P_PERSON_ID                   => P_PERSON_ID, 
                                      P_CONTACT_PERSON_ID           => p_contact_person_id, --
                                      P_CONTACT_TYPE                => l_contact_type, --'F', --'BROTHER',
                                      P_PRIMARY_CONTACT_FLAG        => P_PRIMARY_CONTACT_FLAG, --'N',
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
                    END IF;
--                END IF;
               
--            END IF;
            
                hr_sa_person_api.update_sa_person(
                                     p_validate => L_VALIDATE, 
                                     p_effective_date => l_ESD,
                                     p_datetrack_update_mode => l_dt_ud_mode,
                                     p_person_id => p_contact_person_id,
                                     p_object_version_number => l_OVN,
                                     p_family_name => p_family_name,
                                     p_date_of_birth => p_date_of_birth,
                                     p_hijrah_birth_date => NULL,
                                     p_email_address => p_email_address,
                                     p_employee_number => l_employee_number,
                                     p_first_name => p_first_name,
                                     p_national_identifier => p_national_identifier,
                                     p_sex => p_sex,
                                     p_title => p_title,
                                     p_father_name => p_father_name,
                                     p_grandfather_name => p_grandfather_name,
                                     p_alt_first_name => p_alt_first_name,
                                     p_alt_father_name => p_alt_father_name,
                                     p_alt_grandfather_name => p_alt_grandfather_name,
                                     p_alt_family_name => p_alt_family_name,
                                     p_effective_start_date => l_effective_start_date,
                                     p_effective_end_date => l_effective_end_date,
                                     p_full_name => l_full_name,
                                     p_comment_id => l_comment_id,
                                     p_name_combination_warning => l_name_combination_warning,
                                     p_assign_payroll_warning => l_assign_payroll_warning,
                                     p_orig_hire_warning => l_orig_hire_warning);
            
            /* update address if exist*/
            IF l_contact_rel_ovn IS NOT NULL THEN
                    IF p_use_primary_address = 'N' THEN
                        IF p_address_id != 0 THEN
                                SELECT date_from, object_version_number
                                INTO   l_address_start_date, l_address_OVN
                                FROM per_addresses
                                WHERE address_id = p_address_id;
                    
                                hr_person_address_api.update_person_address(p_validate => L_VALIDATE, 
                                               p_effective_date => SYSDATE,
--                                               p_primary_flag => p_primary_flag,
                                               p_date_from => l_address_start_date,
                                               p_date_to => NULL,
                                               p_address_type => p_address_type,
                                               p_town_or_city => p_town_or_city,
                                               p_region_1 => p_region_1,
                                               p_region_2 => p_region_2,
                                               p_region_3 => p_region_3,
                                               p_postal_code => p_postal_code,
                                               p_country => p_country,
                                               p_add_information13 => p_add_information13,
                                               p_add_information14 => p_add_information14,
                                               p_address_id => p_address_id,
                                               p_object_version_number => l_address_OVN);
                                    
                        ELSE
                                hr_person_address_api.create_person_address(p_validate => L_VALIDATE, 
                                               p_effective_date => SYSDATE, 
--                                               p_pradd_ovlapval_override => p_pradd_ovlapval_override,
--                                               p_validate_county => p_validate_county,
                                               p_person_id => p_contact_person_id,
                                               p_primary_flag => 'Y',
                                               p_style => 'SA',
                                               p_date_from => SYSDATE,
                                               p_date_to => NULL,
                                               p_address_type => p_address_type,
--                                               p_comments => p_comments,
--                                               p_address_line1 => p_address_line1,
--                                               p_address_line2 => p_address_line2,
--                                               p_address_line3 => p_address_line3,
                                               p_town_or_city => p_town_or_city,
                                               p_region_1 => p_region_1,
                                               p_region_2 => p_region_2,
                                               p_region_3 => p_region_3,
                                               p_postal_code => p_postal_code,
                                               p_country => p_country,
--                                               p_telephone_number_1 => p_telephone_number_1,
--                                               p_telephone_number_2 => p_telephone_number_2,
--                                               p_telephone_number_3 => p_telephone_number_3,
--                                               p_addr_attribute_category => p_addr_attribute_category,
                                               p_add_information13 => p_add_information13,
                                               p_add_information14 => p_add_information14,
--                                               p_party_id => p_party_id,
                                               p_address_id => l_address_id,
                                               p_object_version_number => l_address_OVN);
                        END IF;
                    ELSE
                        /*update contact person address with a main user addres*/
                        IF p_address_id != 0 THEN
                            SELECT town_or_city, postal_code, region_1, region_2, region_3, add_information13, add_information14, address_type, country
                            INTO l_town_or_city, l_postal_code, l_region_1, l_region_2, l_region_3, l_add_information13, l_add_information14, l_address_type, l_country
                            FROM per_addresses WHERE primary_flag = 'Y' AND person_id = P_PERSON_ID;
                            
                            SELECT object_version_number
                            INTO l_address_OVN
                            FROM per_addresses
                            WHERE address_id = p_address_id;
                            
                            hr_person_address_api.update_person_address(p_validate => L_VALIDATE, 
                                               p_effective_date => SYSDATE,
--                                               p_primary_flag => p_primary_flag,
                                               p_date_from => SYSDATE,
                                               p_date_to => NULL,
                                               p_address_type => l_address_type,
                                               p_town_or_city => l_town_or_city,
                                               p_region_1 => l_region_1,
                                               p_region_2 => l_region_2,
                                               p_region_3 => l_region_3,
                                               p_postal_code => l_postal_code,
                                               p_country => l_country,
                                               p_add_information13 => l_add_information13,
                                               p_add_information14 => l_add_information14,
                                               p_address_id => p_address_id,
                                               p_object_version_number => l_address_OVN);
                        END IF;
                    END IF;
            END IF;
            
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('PERSON_OBJECT_VESION_NUMBER', l_OVN);
            APEX_JSON.write('CONTACT_OBJECT_VESION_NUMBER', l_contact_rel_ovn);
            APEX_JSON.write('ADDRESS_ID', p_address_id);
            APEX_JSON.write('ADDRESS_OBJECT_VESION_NUMBER', l_address_OVN);
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
                IF l_OVN IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_OVN is not null then
                    APEX_JSON.write('PERSON_OBJECT_VESION_NUMBER', l_OVN);
                else
                    APEX_JSON.write('PERSON_OBJECT_VESION_NUMBER', 'null');
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


END;