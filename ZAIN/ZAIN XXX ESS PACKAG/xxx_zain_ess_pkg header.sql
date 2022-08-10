create or replace PACKAGE xxx_zain_ess_pkg AS
    PROCEDURE generate_valuset_vals (
            ---- IN ----
                    p_valueset_name  IN   VARCHAR2,
        p_person_id      NUMBER DEFAULT NULL,
        p_request_mode   VARCHAR2 DEFAULT NULL,
        p_q_string       VARCHAR2 DEFAULT NULL,
        p_offset         NUMBER DEFAULT NULL,
        p_limit          NUMBER DEFAULT NULL,
        p_order_by       VARCHAR2 DEFAULT NULL,
            ---- OUT ----
                    p_valueset_vals  OUT  CLOB
    );

    FUNCTION get_cntxt_data_sample (
        p_request_type  IN  VARCHAR2 DEFAULT NULL,
        p_requester_id  NUMBER DEFAULT NULL,
        p_person_id     IN  NUMBER DEFAULT NULL,
        p_request_mode  VARCHAR2 DEFAULT NULL,
        p_q_string      VARCHAR2 DEFAULT NULL,
        p_offset        NUMBER DEFAULT NULL,
        p_limit         NUMBER DEFAULT NULL,
        p_order_by      VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION get_person_image (
        p_person_id IN NUMBER
    ) RETURN CLOB;

    FUNCTION get_user_info (
        p_user_name   IN  VARCHAR2 DEFAULT NULL,
        p_email       IN  VARCHAR2 DEFAULT NULL,
        p_emp_number  IN  VARCHAR2 DEFAULT NULL,
        p_q_str       IN  VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION get_employee_info (
        p_requester_person_id  NUMBER DEFAULT NULL,
        p_person_id            IN NUMBER DEFAULT NULL,
        p_offset               NUMBER DEFAULT NULL,
        p_limit                NUMBER DEFAULT NULL,
        p_order_by             VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION get_leave_duration (
        p_person_id   IN  NUMBER DEFAULT NULL,
        p_leave_type  IN  VARCHAR2 DEFAULT NULL,
        p_start_date  IN  DATE DEFAULT NULL,
        p_end_date    IN  DATE DEFAULT NULL
    ) RETURN VARCHAR2;

    FUNCTION get_employee_abs_hist (
        p_person_id     IN  NUMBER DEFAULT NULL,
        p_absence_type  IN  VARCHAR2 DEFAULT NULL,
        p_date_start    IN  DATE DEFAULT NULL,
        p_date_end      IN  DATE DEFAULT NULL,
        p_offset        NUMBER DEFAULT NULL,
        p_limit         NUMBER DEFAULT NULL,
        p_order_by      VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION create_person_absence (
        p_validate   IN BOOLEAN DEFAULT false,
        p_body_data  BLOB
    ) RETURN CLOB;

    FUNCTION create_person_extra_info (
        p_validate           IN BOOLEAN DEFAULT false,
        p_person_id          NUMBER DEFAULT NULL,
        p_information_type   VARCHAR2 DEFAULT NULL,
--            p_pei_attribute_category VARCHAR2 default null,
--            p_pei_information_category VARCHAR2 default null,
                    p_pei_information1   VARCHAR2 DEFAULT NULL,
        p_pei_information2   VARCHAR2 DEFAULT NULL,
        p_pei_information3   VARCHAR2 DEFAULT NULL,
        p_pei_information4   VARCHAR2 DEFAULT NULL,
        p_pei_information5   VARCHAR2 DEFAULT NULL,
        p_pei_information6   VARCHAR2 DEFAULT NULL,
        p_pei_information7   VARCHAR2 DEFAULT NULL,
        p_pei_information8   VARCHAR2 DEFAULT NULL,
        p_pei_information9   VARCHAR2 DEFAULT NULL,
        p_pei_information10  VARCHAR2 DEFAULT NULL,
        p_pei_information11  VARCHAR2 DEFAULT NULL,
        p_pei_information12  VARCHAR2 DEFAULT NULL,
        p_pei_information13  VARCHAR2 DEFAULT NULL,
        p_pei_information14  VARCHAR2 DEFAULT NULL,
        p_pei_information15  VARCHAR2 DEFAULT NULL,
        p_pei_information16  VARCHAR2 DEFAULT NULL,
        p_pei_information17  VARCHAR2 DEFAULT NULL,
        p_pei_information18  VARCHAR2 DEFAULT NULL,
        p_pei_information19  VARCHAR2 DEFAULT NULL,
        p_pei_information20  VARCHAR2 DEFAULT NULL,
        p_pei_information21  VARCHAR2 DEFAULT NULL,
        p_pei_information22  VARCHAR2 DEFAULT NULL,
        p_pei_information23  VARCHAR2 DEFAULT NULL,
        p_pei_information24  VARCHAR2 DEFAULT NULL,
        p_pei_information25  VARCHAR2 DEFAULT NULL,
        p_pei_information26  VARCHAR2 DEFAULT NULL,
        p_pei_information27  VARCHAR2 DEFAULT NULL,
        p_pei_information28  VARCHAR2 DEFAULT NULL,
        p_pei_information29  VARCHAR2 DEFAULT NULL,
        p_pei_information30  VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION get_emp_leave_balance (
        p_person_number  IN  VARCHAR2 DEFAULT NULL,
        p_date_start     IN  DATE DEFAULT NULL,
        p_date_end       IN  DATE DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION get_person_extra_info (
        p_requester_person_id  IN  NUMBER DEFAULT NULL,
        p_person_id            IN  NUMBER,
        p_request_code         IN  VARCHAR2,
        p_q_str                IN  VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION get_extra_info_meta (
        p_request_code IN VARCHAR2
    ) RETURN CLOB;

    FUNCTION get_person_by_role (
        p_requester_person_id  NUMBER DEFAULT NULL,
        p_person_id            IN  NUMBER DEFAULT NULL,
        p_role_name            VARCHAR2 DEFAULT NULL,
        p_transaction_type     VARCHAR2 DEFAULT NULL,
        p_transaction_date     IN  VARCHAR2,
        p_region               IN  VARCHAR2 DEFAULT NULL,
        p_resp                 in varchar2 default null,
        p_offset               NUMBER DEFAULT NULL,
        p_limit                NUMBER DEFAULT NULL,
        p_order_by             VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION exec_zain_concurrent_prog (
        p_conc_prgm_name  IN  VARCHAR2,
        p_person_id       IN  NUMBER DEFAULT NULL,
        p_argument1       IN  VARCHAR2 DEFAULT NULL,
        p_argument2       IN  VARCHAR2 DEFAULT NULL,
        p_argument3       IN  VARCHAR2 DEFAULT NULL,
        p_argument4       IN  VARCHAR2 DEFAULT NULL,
        p_argument5       IN  VARCHAR2 DEFAULT NULL,
        p_argument6       IN  VARCHAR2 DEFAULT NULL,
        p_argument7       IN  VARCHAR2 DEFAULT NULL,
        p_argument8       IN  VARCHAR2 DEFAULT NULL,
        p_argument9       IN  VARCHAR2 DEFAULT NULL,
        p_argument10      IN  VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION load_binary_from_url (
        p_url IN VARCHAR2
    ) RETURN BLOB;

    FUNCTION CREATE_QUALIFICATION (
        p_validate      VARCHAR2 DEFAULT 'TRUE',
        P_PERSON_ID NUMBER default null,
        -------
        p_qualification_type_id         NUMBER DEFAULT null,
        p_title                         VARCHAR2 DEFAULT null,
        p_attendance_id                 NUMBER DEFAULT null,
        p_start_date                    VARCHAR2 DEFAULT null,
        p_end_date                      VARCHAR2 DEFAULT null,
        -------
        P_EFFECTIVE_DATE date default SYSDATE
    ) return clob;

    FUNCTION UPDATE_QUALIFICATION (
        p_validate      VARCHAR2 DEFAULT 'TRUE',
        P_PERSON_ID NUMBER default null,
        P_QUALIFICATION_ID NUMBER default null,
        -------
        p_qualification_type_id         NUMBER DEFAULT null,
        p_title                         VARCHAR2 DEFAULT null,
        p_attendance_id                 NUMBER DEFAULT null,
        p_start_date                    VARCHAR2 DEFAULT null,
        p_end_date                      VARCHAR2 DEFAULT null,
        -------
        P_EFFECTIVE_DATE date default SYSDATE
    ) return clob;

    FUNCTION DELETE_QUALIFICATION (
        p_validate      VARCHAR2 DEFAULT 'TRUE',
        P_PERSON_ID NUMBER default null,
        P_QUALIFICATION_ID NUMBER default null
    ) return clob;

    FUNCTION CREATE_ATTENDED_ESTAB (
        p_validate      VARCHAR2 DEFAULT 'TRUE',
        P_PERSON_ID NUMBER default null,
        -------
        p_establishment_id              NUMBER DEFAULT null,
        p_establishment                 VARCHAR2 DEFAULT null,
        p_address                       VARCHAR2 DEFAULT null,
        p_fulltime                      VARCHAR2 DEFAULT null,
        p_attended_start_date                    VARCHAR2 DEFAULT null,
        p_attended_end_date                      VARCHAR2 DEFAULT null,
        -------
        P_EFFECTIVE_DATE date default SYSDATE
    ) return clob;

    FUNCTION UPDATE_ATTENDED_ESTAB (
        p_validate      VARCHAR2 DEFAULT 'TRUE',
        P_PERSON_ID NUMBER default null,
        -------
        p_attendance_id                 NUMBER DEFAULT null,
        p_establishment_id              NUMBER DEFAULT null,
        p_establishment                 VARCHAR2 DEFAULT null,
        p_address                       VARCHAR2 DEFAULT null,
        p_fulltime                      VARCHAR2 DEFAULT null,
        p_attended_start_date                    VARCHAR2 DEFAULT null,
        p_attended_end_date                      VARCHAR2 DEFAULT null,
        -------
        P_EFFECTIVE_DATE date default SYSDATE
    ) return clob;

    FUNCTION DELETE_ATTENDED_ESTAB (
        p_validate      VARCHAR2 DEFAULT 'TRUE',
        P_PERSON_ID NUMBER default null,
        -------
        p_attendance_id                 NUMBER DEFAULT null
    ) return clob;

    FUNCTION create_objective (
        p_validate                   IN VARCHAR2 default 'TRUE',
        p_person_id                  NUMBER DEFAULT NULL,
        -- p_information_type VARCHAR2 default null,
        -- p_pei_attribute_category VARCHAR2 default null,
        -------
                p_name                       VARCHAR2 DEFAULT NULL,
        p_start_date                 DATE DEFAULT NULL,
        p_owning_person_id           NUMBER DEFAULT NULL,
        p_target_date                DATE DEFAULT NULL,
        p_achievement_date           DATE DEFAULT NULL,
        p_detail                     VARCHAR2 DEFAULT NULL,
        p_comments                   VARCHAR2 DEFAULT NULL,
        p_success_criteria           VARCHAR2 DEFAULT NULL,
        p_appraisal_id               NUMBER DEFAULT NULL,
        -------
                p_scorecard_id               NUMBER DEFAULT NULL,
        p_copied_from_library_id     NUMBER DEFAULT NULL,
        p_copied_from_objective_id   NUMBER DEFAULT NULL,
        p_aligned_with_objective_id  NUMBER DEFAULT NULL,
        p_next_review_date           DATE DEFAULT NULL,
        p_group_code                 VARCHAR2 DEFAULT NULL,
        p_priority_code              VARCHAR2 DEFAULT NULL,
        p_appraise_flag              VARCHAR2 DEFAULT NULL,
        p_verified_flag              VARCHAR2 DEFAULT NULL,
        p_target_value               VARCHAR2 DEFAULT NULL,
        p_actual_value               VARCHAR2 DEFAULT NULL,
        p_weighting_percent          VARCHAR2 DEFAULT NULL,
        p_complete_percent           VARCHAR2 DEFAULT NULL,
        p_uom_code                   VARCHAR2 DEFAULT NULL,
        p_measurement_style_code     VARCHAR2 DEFAULT NULL,
        p_measure_name               VARCHAR2 DEFAULT NULL,
        p_measure_type_code          VARCHAR2 DEFAULT NULL,
        p_measure_comments           VARCHAR2 DEFAULT NULL,
        p_sharing_access_code        VARCHAR2 DEFAULT NULL,
        -------
                p_effective_date             DATE DEFAULT sysdate,
        p_attribute_category         VARCHAR2 DEFAULT NULL,
        p_attribute1                 VARCHAR2 DEFAULT NULL,
        p_attribute2                 VARCHAR2 DEFAULT NULL,
        p_attribute3                 VARCHAR2 DEFAULT NULL,
        p_attribute4                 VARCHAR2 DEFAULT NULL,
        p_attribute5                 VARCHAR2 DEFAULT NULL,
        p_attribute6                 VARCHAR2 DEFAULT NULL,
        p_attribute7                 VARCHAR2 DEFAULT NULL,
        p_attribute8                 VARCHAR2 DEFAULT NULL,
        p_attribute9                 VARCHAR2 DEFAULT NULL,
        p_attribute10                VARCHAR2 DEFAULT NULL,
        p_attribute11                VARCHAR2 DEFAULT NULL,
        p_attribute12                VARCHAR2 DEFAULT NULL,
        p_attribute13                VARCHAR2 DEFAULT NULL,
        p_attribute14                VARCHAR2 DEFAULT NULL,
        p_attribute15                VARCHAR2 DEFAULT NULL,
        p_attribute16                VARCHAR2 DEFAULT NULL,
        p_attribute17                VARCHAR2 DEFAULT NULL,
        p_attribute18                VARCHAR2 DEFAULT NULL,
        p_attribute19                VARCHAR2 DEFAULT NULL,
        p_attribute20                VARCHAR2 DEFAULT NULL,
        p_attribute21                VARCHAR2 DEFAULT NULL,
        p_attribute22                VARCHAR2 DEFAULT NULL,
        p_attribute23                VARCHAR2 DEFAULT NULL,
        p_attribute24                VARCHAR2 DEFAULT NULL,
        p_attribute25                VARCHAR2 DEFAULT NULL,
        p_attribute26                VARCHAR2 DEFAULT NULL,
        p_attribute27                VARCHAR2 DEFAULT NULL,
        p_attribute28                VARCHAR2 DEFAULT NULL,
        p_attribute29                VARCHAR2 DEFAULT NULL,
        p_attribute30                VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION update_objective (
        P_validate VARCHAR2 DEFAULT 'TRUE',
        P_PERSON_ID NUMBER default null,
        -------
        P_OBJECTIVE_ID              NUMBER DEFAULT NULL,
        P_SCORECARD_ID              NUMBER default null,
        P_VERIFIED_FLAG             VARCHAR2 default null,
        P_COMPLETE_PERCENT          NUMBER default null,
        ---
        P_NAME              VARCHAR2 default null,
        P_START_DATE        DATE default null,
        P_TARGET_DATE       DATE default null,
        P_ACHIEVEMENT_DATE  DATE default null,
        P_DETAIL            VARCHAR2 default null,
        P_COMMENTS          VARCHAR2 default null,
        P_SUCCESS_CRITERIA  VARCHAR2 default null,
        P_APPRAISAL_ID      NUMBER default null,
        P_COPIED_FROM_LIBRARY_ID    NUMBER default null,
        P_COPIED_FROM_OBJECTIVE_ID  NUMBER default null,
        P_ALIGNED_WITH_OBJECTIVE_ID NUMBER default null,
        P_NEXT_REVIEW_DATE          DATE default null,
        P_GROUP_CODE                VARCHAR2 default null,
        P_PRIORITY_CODE             VARCHAR2 default null,
        P_APPRAISE_FLAG             VARCHAR2 default null,
        P_TARGET_VALUE              VARCHAR2 default null,
        P_ACTUAL_VALUE              VARCHAR2 default null,
        P_WEIGHTING_PERCENT         VARCHAR2 default null,
        P_UOM_CODE                  VARCHAR2 default null,
        P_MEASUREMENT_STYLE_CODE    VARCHAR2 default null,
        P_MEASURE_NAME              VARCHAR2 default null,
        P_MEASURE_TYPE_CODE         VARCHAR2 default null,
        P_MEASURE_COMMENTS          VARCHAR2 default null,
        P_SHARING_ACCESS_CODE       VARCHAR2 default null,
        -------
        P_EFFECTIVE_DATE date default SYSDATE
    ) RETURN CLOB;

    FUNCTION delete_objective (
        P_PERSON_ID NUMBER default null,
        -------
        P_OBJECTIVE_ID NUMBER,
        P_VALIDATE VARCHAR2 DEFAULT 'TRUE') RETURN CLOB;

    FUNCTION submit_objectives (
        P_PERSON_ID NUMBER default null,
        P_VALIDATE VARCHAR2 DEFAULT 'TRUE',
        -------
        P_SCORECARD_ID NUMBER,
        P_STATUS_CODE VARCHAR2 DEFAULT NULL) RETURN CLOB;

    FUNCTION create_appraisal (
        p_validate      VARCHAR2 DEFAULT 'TRUE',
        p_person_id                    NUMBER DEFAULT NULL,
        -------
                p_template_id                  NUMBER DEFAULT NULL,
        p_main_appraiser_id            NUMBER DEFAULT NULL,
        p_appraisal_period_start_date  DATE DEFAULT NULL,
        p_appraisal_period_end_date    DATE DEFAULT NULL,
        p_appraisal_system_status      VARCHAR2 DEFAULT NULL,
        p_p_system_type                VARCHAR2 DEFAULT NULL,
        p_system_params                VARCHAR2 DEFAULT NULL,
        p_assessment_type_id           NUMBER DEFAULT NULL,
        -------
                p_effective_date               DATE DEFAULT sysdate
    ) RETURN CLOB;

    FUNCTION update_appraisal (
        p_validate      VARCHAR2 DEFAULT 'TRUE',
        p_person_id                    NUMBER DEFAULT NULL,
        -------
        p_appraisal_id                 NUMBER DEFAULT NULL,
        P_MAIN_APPRAISER_id             NUMBER DEFAULT null,
        p_appraiser_person_id          NUMBER DEFAULT NULL,
        p_appraisal_period_start_date  DATE DEFAULT NULL,
        p_appraisal_period_end_date    DATE DEFAULT NULL,
        p_update_appraisal             VARCHAR2 DEFAULT NULL,
        p_appraisal_system_status      VARCHAR2 DEFAULT NULL,
        p_p_system_type                VARCHAR2 DEFAULT NULL,
        p_system_params                VARCHAR2 DEFAULT NULL,
        p_status                       VARCHAR2 DEFAULT NULL,
        p_comments                     VARCHAR2 DEFAULT NULL,
        -------
        p_effective_date               DATE DEFAULT sysdate
    ) RETURN CLOB;

    FUNCTION insert_performance_rating (
        p_person_id     NUMBER DEFAULT NULL,
        p_validate      VARCHAR2 DEFAULT NULL,
        p_objective_id  NUMBER DEFAULT NULL,
        p_appraisal_id  NUMBER DEFAULT NULL,
        p_performance_level_id NUMBER DEFAULT NULL,
        p_effective_date DATE DEFAULT SYSDATE
    ) return clob;

    FUNCTION update_performance_rating (
        p_person_id     NUMBER DEFAULT NULL,
        p_validate      VARCHAR2 DEFAULT NULL,
        p_performance_rating_id  NUMBER DEFAULT NULL,
        p_performance_level_id NUMBER DEFAULT NULL,
        p_effective_date DATE DEFAULT SYSDATE
    ) return clob;

    FUNCTION create_resignation (
        P_VALIDATE  VARCHAR2 DEFAULT 'TRUE',
        P_PERSON_ID NUMBER default null,
        -------
        p_comments VARCHAR2 DEFAULT NULL,
        p_resignation_reason VARCHAR2 DEFAULT NULL,
        p_leaving_reason     VARCHAR2 DEFAULT NULL,
        p_sim_card VARCHAR2 DEFAULT NULL,
        p_last_working_date  date default null,
        p_resignation_date date default null,
        -------
        p_effective_date DATE DEFAULT SYSDATE
  ) return clob;

    FUNCTION create_contact_relationship (
        p_person_id             NUMBER DEFAULT NULL,
            -------
                        p_validate              VARCHAR2 DEFAULT 'TRUE',
        p_date_start            DATE DEFAULT SYSDATE,
        p_start_date            DATE DEFAULT SYSDATE,
        p_c_person_id           NUMBER DEFAULT NULL,
        p_contact_person_id     NUMBER DEFAULT NULL,
        p_title                 VARCHAR2 DEFAULT NULL,
        p_contact_type          VARCHAR2 DEFAULT NULL,
        p_primary_contact_flag  VARCHAR2 DEFAULT 'N',
        p_cont_attribute16      VARCHAR2 DEFAULT NULL,
        p_last_name             VARCHAR2 DEFAULT NULL,
        p_sex                   VARCHAR2 DEFAULT NULL,
        p_person_type_id        NUMBER DEFAULT 1125,
        p_date_of_birth         DATE DEFAULT NULL,
        p_first_name            VARCHAR2 DEFAULT NULL,
        p_personal_flag         VARCHAR2 DEFAULT 'N'
    ) RETURN CLOB;

    FUNCTION update_contact_relationship(
        p_person_id                 NUMBER DEFAULT NULL,
        p_validate                  VARCHAR2 DEFAULT 'TRUE',
        p_effective_date            DATE DEFAULT SYSDATE,
        p_contact_relationship_id   NUMBER DEFAULT NULL,
        p_contact_type              VARCHAR2 DEFAULT NULL,
        p_primary_contact_flag      VARCHAR2 DEFAULT 'N',
        P_PERSONAL_FLAG             VARCHAR2 DEFAULT 'N',
        p_object_version_number     IN NUMBER
    )RETURN CLOB;

    FUNCTION delete_contact_relationship(
        p_person_id                 NUMBER DEFAULT NULL,
        p_validate                          IN VARCHAR2 DEFAULT 'TRUE',
        p_contact_relationship_id           IN NUMBER DEFAULT NULL,
        p_delete_other                      IN VARCHAR2 DEFAULT 'N',  
        p_object_version_number             IN NUMBER DEFAULT 1
    )RETURN CLOB;

FUNCTION create_phone (
    p_person_id              NUMBER DEFAULT NULL,
    p_validate               IN  VARCHAR2 DEFAULT 'TRUE',
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
) RETURN CLOB;    

FUNCTION update_phone (
    p_person_id              NUMBER DEFAULT NULL,
    p_validate               IN  VARCHAR2 DEFAULT 'TRUE',
    p_phone_id               IN  NUMBER,
    p_date_from              IN  DATE DEFAULT SYSDATE,
    p_phone_type             IN  VARCHAR2,
    p_phone_number           IN  VARCHAR2,
    p_attribute_category     IN  VARCHAR2 DEFAULT NULL,
    p_effective_date         IN  DATE DEFAULT SYSDATE,
    p_party_id               IN  NUMBER DEFAULT NULL,
    p_validity               IN  VARCHAR2 DEFAULT NULL,
    p_object_version_number  IN  NUMBER
) RETURN CLOB;

FUNCTION delete_phone (
    p_person_id              NUMBER DEFAULT NULL,
    p_validate               IN  VARCHAR2 DEFAULT 'TRUE',
    p_phone_id               IN  NUMBER,
    p_object_version_number  IN  NUMBER
) RETURN CLOB;

FUNCTION create_person_address (
    p_person_id                NUMBER DEFAULT NULL,
    p_validate                 IN  VARCHAR2 DEFAULT 'TRUE',
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
) RETURN CLOB;

FUNCTION delete_person_address (
    p_person_id                NUMBER DEFAULT NULL,
    p_validate                 IN  VARCHAR2 DEFAULT 'TRUE',
    p_address_id               IN  NUMBER

) RETURN CLOB;

FUNCTION update_person_address (
    p_person_id                NUMBER DEFAULT NULL,
    p_validate                 IN  VARCHAR2 DEFAULT 'TRUE',
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
) RETURN CLOB;


FUNCTION create_sa_contact_person (
    p_person_id                     NUMBER DEFAULT NULL,
    p_validate                      IN  VARCHAR2 DEFAULT 'TRUE',
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
) RETURN CLOB;

FUNCTION update_sa_contact_person (
    p_person_id                     NUMBER DEFAULT NULL,
    p_validate                      IN  VARCHAR2 DEFAULT 'TRUE',
    p_addEmergency_flag             IN  VARCHAR2 DEFAULT 'N',
    p_contact_person_id             IN  NUMBER,
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
) RETURN CLOB;

END;