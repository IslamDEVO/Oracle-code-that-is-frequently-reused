--------------------------------------
begin
    owa_util.mime_header('application/json', true);
    htp.p(xxx_zain_ess_pkg.create_contact_relationship (
                        p_person_id	                => :person_id,
                        p_validate                  => :validate, 
                        P_DATE_START                => :date_start,
                        P_START_DATE                => :start_date,
                        P_C_PERSON_ID               => :c_person_id,
                        P_CONTACT_PERSON_ID         => :contact_person_id,
                        P_TITLE                     => :title,
                        P_CONTACT_TYPE              => :contact_type,
                        P_PRIMARY_CONTACT_FLAG      => :primary_contact_flag,
                        P_CONT_ATTRIBUTE16          => :con_attribute16,
                        P_LAST_NAME                 => :last_name,
                        P_SEX                       => :sex,
                        P_PERSON_TYPE_ID            => :person_type_id,
                        P_DATE_OF_BIRTH             => :date_of_birth,
                        P_FIRST_NAME                => :first_name,
                        P_PERSONAL_FLAG             => :personal_flag

                ));
end;
--------------------------------------
begin
    owa_util.mime_header('application/json', true);
    htp.p(xxx_zain_ess_pkg.create_person_address (
                        p_person_id	=> :person_id,
                        p_validate => :validate, 
                        p_effective_date => :effective_date, 
--                        p_pradd_ovlapval_override => :pradd_ovlapval_override,
--                                               p_validate_county => :validate_county,
                                               p_primary_flag => :primary_flag,
                                               p_style => 'SA',
                                               p_date_from => :date_from,
                                               p_date_to => :date_to,
                                               p_address_type => :address_type,
                                               p_comments => :comments,
--                                               p_address_line1 => :address_line1,
--                                               p_address_line2 => :address_line2,
--                                               p_address_line3 => :address_line3,
                                               p_town_or_city => :City,
                                               p_region_1 => :Street_Name,
                                               p_region_2 => :District_Name,
                                               p_region_3 => :Zip_Code,
                                               p_postal_code => :Unit_No,
                                               p_country => :Country,
                                               p_telephone_number_1 => :telephone_number_1,
                                               p_telephone_number_2 => :telephone_number_2,
                                               p_telephone_number_3 => :telephone_number_3,
                                               p_addr_attribute_category => :addr_attribute_category,
                                               p_add_information13 => :Addtional_Number,
                                               p_add_information14 => :Building_Number,
                                               p_party_id => :party_id

                ));
end;
--------------------------------------
begin
    owa_util.mime_header('application/json', true);
    htp.p(xxx_zain_ess_pkg.create_phone (
                        p_person_id	                => :person_id,
                        p_validate                  => :validate, 
                        p_validity                  => NULL,
                        p_date_from                 => :date_from,
                        p_date_to                   => :date_to,
                        p_phone_type                => :phone_type,
                        p_phone_number              => :phone_number,
                        p_parent_id                 => :parent_id,
                        p_parent_table              => 'PER_ALL_PEOPLE_F',
                        p_attribute_category        => :attribute_category,
                        p_effective_date            => :effective_date,
                        p_party_id                  => :party_id

                ));
end;
--------------------------------------
begin
    owa_util.mime_header('application/json', true);
    htp.p(xxx_zain_ess_pkg.create_sa_contact_person (
                            p_person_id                     => :person_id,
                            p_validate                      => :validate,
                            p_start_date                    => :start_date,
                            p_business_group_id             => :business_group_id,
                            p_family_name                   => :family_name,
                            p_sex                           => :sex,
                            p_person_type_id                => :person_type_id,
                            p_comments                      => :comments,
                            p_date_employee_data_verified   => :date_employee_data_verified,
                            p_date_of_birth                 => :date_of_birth,
                            p_email_address                 => :email_address,
                            p_expense_check_send_to_addres  => :expense_check_send_to_addres,
                            p_first_name                    => :first_name,
                            p_known_as                      => :known_as,
                            p_marital_status                => :marital_status,
                            p_nationality                   => :nationality,
                            p_national_identifier           => :national_identifier,
                            p_previous_last_name            => :previous_last_name,
                            p_registered_disabled_flag      => :registered_disabled_flag,
                            p_title                         => :title,
                            p_vendor_id                     => :vendor_id,
                            p_work_telephone                => :work_telephone,
                            p_attribute_category            => :attribute_category,
                            p_father_name                   => :father_name,
                            p_grandfather_name              => :grandfather_name,
                            p_alt_first_name                => :alt_first_name,
                            p_alt_father_name               => :alt_father_name,
                            p_alt_grandfather_name          => :alt_grandfather_name,
                            p_alt_family_name               => :alt_family_name,
                            p_religion                      => :religion,
                            p_hijrah_birth_date             => :hijrah_birth_date,
                            p_education_level               => :education_level,
                            p_correspondence_language       => :correspondence_language,
                            p_honors                        => :honors,
                            p_benefit_group_id              => :benefit_group_id,
                            p_on_military_service           => :on_military_service,
                            p_student_status                => :student_status,
                            p_uses_tobacco_flag             => :uses_tobacco_flag,
                            p_coord_ben_no_cvg_flag         => :coord_ben_no_cvg_flag,
                            p_town_of_birth                 => :town_of_birth,
                            p_region_of_birth               => :region_of_birth,
                            p_country_of_birth              => :country_of_birth,
                            p_global_person_id              => :global_person_id,
                            --
                            p_contact_type                  => :contact_type,
                            p_primary_contact_flag          => :primary_contact_flag,
                            P_PERSONAL_FLAG                 => :PERSONAL_FLAG,
                            --
                            p_use_primary_address           => :use_primary_address,
                            p_effective_date                => SYSDATE,
                            p_primary_flag                  => 'Y',
                            p_address_type                  => :address_type,
                            p_town_or_city                  => :City,
                            p_region_1                      => :Street_Name,
                            p_region_2                      => :District_Name,
                            p_region_3                      => :Zip_Code,
                            p_postal_code                   => :Unit_No,
                            p_country                       => :Country,
                            p_add_information13             => :Addtional_Number,
                            p_add_information14             => :Building_Number

                ));
end;
--------------------------------------
begin
    owa_util.mime_header('application/json', true);
    htp.p(xxx_zain_ess_pkg.delete_contact_relationship (
                        p_person_id	                => :person_id,
                        p_validate                  => :validate, 
                        p_contact_relationship_id   => :contact_relationship_id,
                        p_delete_other              => :delete_other,
                        p_object_version_number     => :object_version_number

                ));
end;
--------------------------------------
begin
    owa_util.mime_header('application/json', true);
    htp.p(xxx_zain_ess_pkg.delete_person_address (
                        p_person_id	                => :person_id,
                        p_validate                  => :validate, 
                        p_address_id               => :address_id

                ));
end;
--------------------------------------
begin
    owa_util.mime_header('application/json', true);
    htp.p(xxx_zain_ess_pkg.delete_phone (
                        p_person_id	                => :person_id,
                        p_validate                  => :validate, 
                        p_phone_id                  => :phone_id,
                        p_object_version_number     => :object_version_number

                ));
end;
--------------------------------------
begin
    owa_util.mime_header('application/json', true);
    htp.p(xxx_zain_ess_pkg.update_contact_relationship (
                        p_person_id	                => :person_id,
                        p_validate                  => :validate, 
                        p_effective_date            => :effective_date,
                        p_contact_relationship_id   => :contact_relationship_id,
                        p_contact_type              => :contact_type,
                        p_primary_contact_flag      => :primary_contact_flag,
                        P_PERSONAL_FLAG             => :PERSONAL_FLAG,
                        p_object_version_number     => :object_version_number

                ));
end;
--------------------------------------
begin
    owa_util.mime_header('application/json', true);
    htp.p(xxx_zain_ess_pkg.update_person_address (
                        p_person_id	                => :person_id,
                        p_validate                  => :validate, 
                        p_effective_date            => SYSDATE, 
                        p_address_id               => :address_id,
                        p_date_from                => :date_from,
                        p_date_to                  => :date_to,
                        p_primary_flag             => :primary_flag,
                        p_address_type             => :address_type,
                        p_comments                 => :comments,
                        p_town_or_city             => :City,
                        p_region_1                 => :Street_Name,
                        p_region_2                 => :District_Name,
                        p_region_3                 => :Zip_Code,
                        p_postal_code              => :Unit_No,
                        p_country                  => :Country,
                        p_telephone_number_1       => :telephone_number_1,
                        p_telephone_number_2       => :telephone_number_2,
                        p_telephone_number_3       => :telephone_number_3,
                        p_addr_attribute_category  => :addr_attribute_category,
                        p_add_information13        => :Addtional_Number,
                        p_add_information14        => :Building_Number,
                        p_party_id                 => :party_id


                ));
end;
--------------------------------------
begin
    owa_util.mime_header('application/json', true);
    htp.p(xxx_zain_ess_pkg.update_person_address (
                        p_person_id	                => :person_id,
                        p_validate                  => :validate, 
                        p_effective_date            => SYSDATE, 
                        p_address_id               => :address_id,
                        p_date_from                => :date_from,
                        p_date_to                  => :date_to,
                        p_primary_flag             => :primary_flag,
                        p_address_type             => :address_type,
                        p_comments                 => :comments,
                        p_town_or_city             => :City,
                        p_region_1                 => :Street_Name,
                        p_region_2                 => :District_Name,
                        p_region_3                 => :Zip_Code,
                        p_postal_code              => :Unit_No,
                        p_country                  => :Country,
                        p_telephone_number_1       => :telephone_number_1,
                        p_telephone_number_2       => :telephone_number_2,
                        p_telephone_number_3       => :telephone_number_3,
                        p_addr_attribute_category  => :addr_attribute_category,
                        p_add_information13        => :Addtional_Number,
                        p_add_information14        => :Building_Number,
                        p_party_id                 => :party_id


                ));
end;
--------------------------------------
begin
    owa_util.mime_header('application/json', true);
    htp.p(xxx_zain_ess_pkg.update_sa_contact_person (
                                    p_person_id                     => :person_id,
                                    p_validate                      => :validate,
                                    p_start_date                    => :start_date,
                                    p_addEmergency_flag             => :addEmergency_flag,
                                    p_contact_person_id             => :contact_person_id,
                                    p_family_name                   => :family_name,
                                    p_date_of_birth                 => :date_of_birth,
                                    p_email_address                 => :email_address,
                                    p_first_name                    => :first_name,
                                    p_national_identifier           => :national_identifier,
                                    p_sex                           => :sex,
                                    p_title                         => :title,
                                    p_father_name                   => :father_name,
                                    p_grandfather_name              => :grandfather_name,
                                    p_alt_first_name                => :alt_first_name,
                                    p_alt_father_name               => :alt_father_name,
                                    p_alt_grandfather_name          => :alt_grandfather_name,
                                    p_alt_family_name               => :alt_family_name,
                                    p_contact_relationship_id       => :contact_relationship_id,
                                    p_contact_type                  => :contact_type,
                                    p_primary_contact_flag          => :primary_contact_flag,
                                    P_PERSONAL_FLAG                 => :PERSONAL_FLAG,
                                    p_use_primary_address           => :use_primary_address,
                                    p_address_id                    => :address_id,
                                    p_address_type                  => :address_type,
                                    p_town_or_city                  => :City,
                                    p_region_1                      => :Street_Name,
                                    p_region_2                      => :District_Name,
                                    p_region_3                      => :Zip_Code,
                                    p_postal_code                   => :Unit_No,
                                    p_country                       => :Country,
                                    p_add_information13             => :Addtional_Number,
                                    p_add_information14             => :Building_Number

                ));
end;

