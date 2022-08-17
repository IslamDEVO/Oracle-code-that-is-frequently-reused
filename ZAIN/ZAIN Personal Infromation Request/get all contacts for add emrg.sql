SELECT
    papf.person_id                 session_user_id,
    papf2.person_id                contact_person_id,
    papf2.object_version_number    contact_person_ovn,
    pcr.contact_relationship_id,
    pcr.object_version_number      contact_relationship_ovn,
    (
        SELECT
            meaning
        FROM
            hr_lookups
        WHERE
                lookup_type = 'TITLE'
            AND ( enabled_flag = 'Y'
                  OR end_date_active IS NOT NULL )
            AND lookup_code = papf2.title
    )                              title,
    papf2.title                           title_code,
    papf2.first_name,
    papf2.last_name                family_name,
    papf2.per_information1         father_name,
    papf2.per_information2         grandfather_name,
    papf2.per_information3         arabic_first_name,
    papf2.per_information4         arabic_father_name,
    papf2.per_information5         arabic_grandfather_name,
    papf2.per_information6         arabic_family_name,
    papf2.email_address,
    (
        SELECT
            meaning
        FROM
            hr_lookups
        WHERE
                lookup_type = 'CONTACT'
            AND ( enabled_flag = 'Y'
                  OR end_date_active IS NOT NULL )
            AND lookup_code = pcr.contact_type
    )                              relationship,
    pcr.contact_type        contact_type_code,
    pcr.date_start		START_DATE,
    (
        SELECT
            meaning
        FROM
            fnd_lookups
        WHERE
                lookup_type = 'YES_NO'
            AND ( enabled_flag = 'Y'
                  OR end_date_active IS NOT NULL )
            AND lookup_code = pcr.primary_contact_flag
    )                              primary_contact_flag,
    pcr.primary_contact_flag    primary_contact_flag_code,
    (
        SELECT
            meaning
        FROM
            hr_lookups
        WHERE
                lookup_type = 'PQH_GENDER'
            AND ( enabled_flag = 'Y'
                  OR end_date_active IS NOT NULL )
            AND lookup_code = papf2.sex
    )                              gender,
    papf2.sex                             gender_code,
    papf2.national_identifier      civil_identity_number,
    papf2.date_of_birth,
    papf2.full_name,
    (
        SELECT
            phone_number
        FROM
            per_phones
        WHERE
                phone_type = (
                    SELECT
                        lookup_code
                    FROM
                        hr_lookups
                    WHERE
                            lookup_type = 'PHONE_TYPE'
                        AND lookup_code = 'H1'
                        AND ( enabled_flag = 'Y'
                              OR end_date_active IS NOT NULL )
                )
            AND parent_id = papf2.person_id
            AND SYSDATE BETWEEN date_from AND NVL(date_to, '01-JAN-47')
            AND ROWNUM = 1
    )                              home_number,
    'H1'                              home_number_code,
    (
        SELECT
            phone_number
        FROM
            per_phones
        WHERE
                phone_type = (
                    SELECT
                        lookup_code
                    FROM
                        hr_lookups
                    WHERE
                            lookup_type = 'PHONE_TYPE'
                        AND lookup_code = 'M1'
                        AND ( enabled_flag = 'Y'
                              OR end_date_active IS NOT NULL )
                )
            AND parent_id = papf2.person_id
            AND SYSDATE BETWEEN date_from AND NVL(date_to, '01-JAN-47')
            AND ROWNUM = 1
    )                              working_number,
    'M1'                              working_number_code,
    (
        SELECT
            phone_number
        FROM
            per_phones
        WHERE
                phone_type = (
                    SELECT
                        lookup_code
                    FROM
                        hr_lookups
                    WHERE
                            lookup_type = 'PHONE_TYPE'
                        AND lookup_code = 'M'
                        AND ( enabled_flag = 'Y'
                              OR end_date_active IS NOT NULL )
                )
            AND parent_id = papf2.person_id
            AND SYSDATE BETWEEN date_from AND NVL(date_to, '01-JAN-47')
            AND ROWNUM = 1
    )                              mobile_number,
    'M'                               mobile_number_code,
    (
        SELECT
            phone_number
        FROM
            per_phones
        WHERE
                phone_type = (
                    SELECT
                        lookup_code
                    FROM
                        hr_lookups
                    WHERE
                            lookup_type = 'PHONE_TYPE'
                        AND lookup_code = 'P'
                        AND ( enabled_flag = 'Y'
                              OR end_date_active IS NOT NULL )
                )
            AND parent_id = papf2.person_id
            AND SYSDATE BETWEEN date_from AND NVL(date_to, '01-JAN-47')
            AND ROWNUM = 1
    )                              pager_number,
    'P'                               pager_number_code,
    (
        SELECT
            phone_number
        FROM
            per_phones
        WHERE
                phone_type = (
                    SELECT
                        lookup_code
                    FROM
                        hr_lookups
                    WHERE
                            lookup_type = 'PHONE_TYPE'
                        AND lookup_code = 'WF'
                        AND ( enabled_flag = 'Y'
                              OR end_date_active IS NOT NULL )
                )
            AND parent_id = papf2.person_id
            AND SYSDATE BETWEEN date_from AND NVL(date_to, '01-JAN-47')
            AND ROWNUM = 1
    )                              work_fax,
    'WF'                              work_fax_code,
    (
        SELECT
            meaning
        FROM
            hr_lookups h
        WHERE
                lookup_type = 'SA_CITY'
            AND enabled_flag = 'Y'
            AND application_id = 800
            AND lookup_code = pd.town_or_city
            AND ( enabled_flag = 'Y'
                  OR end_date_active IS NULL )
    )                  "city",
    pd.town_or_city            city_code,
    pd.postal_code        "unit_no",
    pd.region_1           "street_name",
    pd.region_2           "district_name",
    pd.region_3           "zip_code",
    pd.add_information13  "addtional_number",
    pd.add_information14  "building_number",
    (
        SELECT
            meaning
        FROM
            hr_lookups h
        WHERE
                lookup_type = 'ADDRESS_TYPE'
            AND enabled_flag = 'Y'
            AND application_id = 800
            AND lookup_code = pd.address_type
            AND ( enabled_flag = 'Y'
                  OR end_date_active IS NULL )
    )                  "address_type",
    pd.address_type     address_type_code,
    (
        SELECT
            territory_short_name
        FROM
            fnd_territories_vl
        WHERE
                obsolete_flag <> 'Y'
            AND territory_code = pd.country
    )                  country,
    pd.country          country_code
,
    (
        SELECT
            CASE
                WHEN 1 = 1
                    AND pa1.style = NVL(pa2.style, pa1.style)
                    AND NVL(pa1.address_type, '1') = NVL(pa2.address_type, NVL(pa1.address_type, '1'))
                    AND pa1.region_1 = NVL(pa2.region_1, pa1.region_1)
                    AND pa1.region_2 = NVL(pa2.region_2, pa1.region_2)
                    AND pa1.region_3 = NVL(pa2.region_3, pa1.region_3)
                    AND pa1.country = NVL(pa2.country, pa1.country)
                    AND pa1.town_or_city = NVL(pa2.town_or_city, pa1.town_or_city)
                    AND pa1.ADD_INFORMATION13 = NVL(pa2.ADD_INFORMATION13, pa1.ADD_INFORMATION13)
                    AND pa1.ADD_INFORMATION14 = NVL(pa2.ADD_INFORMATION14, pa1.ADD_INFORMATION14)
                    
                THEN
                    'Y'
                ELSE
                    'N'
            END
        FROM
            per_addresses  pa1
            LEFT OUTER JOIN per_addresses  pa2 ON ( pa1.primary_flag = pa2.primary_flag
                                                   AND pa2.person_id = papf2.person_id )
        WHERE
                1 = 1
            AND pa1.person_id = papf.person_id
            AND pa1.primary_flag = 'Y'
            AND sysdate BETWEEN pa1.date_from AND nvl(pa1.date_to, '01-JAN-47')
    )                  primary_addres_used,
    pd.address_id
FROM
    per_contact_relationships  pcr,
    per_all_people_f           papf,
    per_all_people_f           papf2,
    per_addresses              pd
WHERE
        papf.person_id = pcr.person_id
    AND pcr.contact_type <> 'EMRG'
    AND pcr.contact_person_id NOT IN (
        SELECT contact_person_id
        FROM per_contact_relationships
        WHERE contact_type = 'EMRG' AND person_id = 56193 --#PER_PERSON_ID#
        AND sysdate BETWEEN date_start AND NVL(date_end, '01-JAN-47')
    )
    AND pcr.contact_person_id = papf2.person_id
    AND pd.person_id (+) = pcr.contact_person_id
--    AND pd.person_id = papf.person_id
--    AND pd.primary_flag = 'Y'
    AND sysdate BETWEEN papf2.effective_start_date AND papf2.effective_end_date
    AND sysdate BETWEEN papf.effective_start_date AND papf.effective_end_date
    AND sysdate BETWEEN pcr.date_start AND NVL(pcr.date_end, '01-JAN-47')
    AND papf.person_id = 56193 --#PER_PERSON_ID#
