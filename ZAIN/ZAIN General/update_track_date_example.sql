SET SERVEROUTPUT ON;

DECLARE
    l_effective_start_date      DATE;
    l_effective_end_date        DATE;
    l_full_name                 VARCHAR2(200);
    l_comment_id                NUMBER;
    l_name_combination_warning  BOOLEAN;
    l_assign_payroll_warning    BOOLEAN;
    l_orig_hire_warning         BOOLEAN;
    ---
    l_ESD       DATE;
    l_OVN                   NUMBER;
    l_dt_ud_mode                VARCHAR2(20);
    l_employee_number       NUMBER;
    l_hijrah_birth_date DATE;
BEGIN
    SELECT effective_start_date, object_version_number, employee_number, to_date(to_char(date_of_birth,'YYYY/MM/DD','nls_calendar=''arabic hijrah''') ,'YYYY/MM/DD')
     INTO l_ESD, l_OVN, l_employee_number, l_hijrah_birth_date
     FROM per_all_people_f
    WHERE     person_id = 126854
          AND SYSDATE BETWEEN effective_start_date AND effective_end_date;
              
    l_dt_ud_mode := dt_ud_mode(p_effective_date => l_ESD, p_base_table_name => 'PER_ALL_PEOPLE_F',
                              p_base_key_column => 'PERSON_ID',
                              p_base_key_value => 126854);

    hr_sa_person_api.update_sa_person(p_validate => true, p_effective_date => l_ESD,
                                     p_datetrack_update_mode => l_dt_ud_mode,
                                     p_person_id => 126854,
                                     p_object_version_number => l_OVN,
                                     p_family_name => 'test_family_name',
                                     p_date_of_birth => '05-JUL-01',
                                     p_hijrah_birth_date => NULL,
                                     p_email_address => 'test@test.com',
                                     p_employee_number => l_employee_number,
                                     p_first_name => 'test_first_name',
                                     p_national_identifier => '1234456',
                                     p_sex => 'M',
                                     p_title => 'MR.',
                                     p_father_name => 'test_father_name',
                                     p_grandfather_name => 'test_grandfather_name',
                                     p_alt_first_name => 'test_alt_first_name',
                                     p_alt_father_name => 'test_alt_father_name',
                                     p_alt_grandfather_name => 'test_alt_grandfather_name',
                                     p_alt_family_name => 'test_alt_family_name',
                                     p_effective_start_date => l_effective_start_date,
                                     p_effective_end_date => l_effective_end_date,
                                     p_full_name => l_full_name,
                                     p_comment_id => l_comment_id,
                                     p_name_combination_warning => l_name_combination_warning,
                                     p_assign_payroll_warning => l_assign_payroll_warning,
                                     p_orig_hire_warning => l_orig_hire_warning);

    COMMIT;
    dbms_output.put_line('Success : ');
--   DBMS_OUTPUT.put_line ('l_address_id : ' ||l_address_id);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error raised : ' || sqlerrm);
END;