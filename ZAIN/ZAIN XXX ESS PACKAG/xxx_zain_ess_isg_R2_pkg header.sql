create or replace PACKAGE      xxx_zain_ess_isg_R2_pkg
AS
   /* $Header: $ */
   /*#
   * This interface returns the Lookup Data.
   * @rep:scope public
   * @rep:product PER
   * @rep:displayname xxx_zain_ess_isg_pkg
   * @rep:lifecycle active
   * @rep:compatibility S
   * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
   */
   /*#
   * Returns Lookup Data
   * @param P_VALUESET_NAME VARCHAR2 Valueset Name
   * @param P_PERSON_ID NUMBER Person Id

   * @param P_REQUEST_MODE VARCHAR2 Request Mode
   * @param P_Q_STRING VARCHAR2 Query String
   * @param P_OFFSET NUMBER Offset
   * @param P_LIMIT NUMBER Limit
   * @param P_ORDER_BY VARCHAR2 Order By
   * @return Lookup_Data
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname Return Lookup Data
   */
   FUNCTION get_lookup (---- IN ----
                        P_VALUESET_NAME   IN VARCHAR2,
                        P_PERSON_ID          NUMBER DEFAULT NULL,
                        P_REQUEST_MODE       VARCHAR2 DEFAULT NULL,
                        P_Q_STRING           VARCHAR2 DEFAULT NULL,
                        P_OFFSET             NUMBER DEFAULT NULL,
                        P_LIMIT              NUMBER DEFAULT NULL,
                        P_ORDER_BY           VARCHAR2 DEFAULT NULL)
      RETURN xxx_zain_ess_LookUp_tb;

   /*#
   * Returns Absence Data
   * @param P_PERSON_ID NUMBER Person Id
   * @param P_REQUESTER_PERSON_ID NUMBER Requester Person Id
   * @param P_ABSENCE_TYPE VARCHAR2 Absence Type
   * @param P_EFFECTIVE_DATE VARCHAR2 Effective Date
   * @param P_DATE_START VARCHAR2 Date Start
   * @param P_DATE_END VARCHAR2 Date End
   * @param P_DELEGATED_USERS xxx_zain_ess_Deleg_tb Delegated Users

   * @return Absence_Data
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname Return Absence Data
   */
   FUNCTION CREATE_PERSON_ABSENCE (---- IN ----
                        --P_validate           VARCHAR2 default 'FALSE',
                        P_PERSON_ID          NUMBER DEFAULT NULL,
                        P_REQUESTER_PERSON_ID NUMBER DEFAULT NULL,
                        P_ABSENCE_TYPE       VARCHAR2 DEFAULT NULL,
                        P_EFFECTIVE_DATE     VARCHAR2 DEFAULT NULL,
                        P_DATE_START         VARCHAR2 DEFAULT NULL,
                        P_DATE_END           VARCHAR2 DEFAULT NULL
                        ,
                        P_DELEGATED_USERS    xxx_zain_ess_Deleg_tb DEFAULT NULL
                        )
      RETURN xxx_zain_ess_abs_data;

   /*#
   * Returns Absence Data
   * @param P_PERSON_ID NUMBER Person Id
   * @param P_REQUESTER_PERSON_ID NUMBER Requester Person Id
   * @param P_ABSENCE_TYPE VARCHAR2 Absence Type
   * @param P_EFFECTIVE_DATE VARCHAR2 Effective Date
   * @param P_DATE_START VARCHAR2 Date Start
   * @param P_DATE_END VARCHAR2 Date End
   * @param P_DELEGATED_USERS xxx_zain_ess_Deleg_tb Delegated Users

   * @return Absence_Data
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname Return Absence Data
   */
   FUNCTION VALIDATE_PERSON_ABSENCE (---- IN ----
                        --P_validate           VARCHAR2 default 'FALSE',
                        P_PERSON_ID          NUMBER DEFAULT NULL,
                        P_REQUESTER_PERSON_ID NUMBER DEFAULT NULL,
                        P_ABSENCE_TYPE       VARCHAR2 DEFAULT NULL,
                        P_EFFECTIVE_DATE     VARCHAR2 DEFAULT NULL,
                        P_DATE_START         VARCHAR2 DEFAULT NULL,
                        P_DATE_END           VARCHAR2 DEFAULT NULL
                        ,
                        P_DELEGATED_USERS    xxx_zain_ess_Deleg_tb DEFAULT NULL
                        )
      RETURN xxx_zain_ess_abs_data;

    /*#
   * Returns Extra Info Data
   * @param P_PERSON_ID NUMBER Person Id
   * @param P_REQUESTER_PERSON_ID NUMBER Requester Person Id
   * @param p_information_type VARCHAR2 Information Type Type
   * @param p_pei_information1 VARCHAR2 PEI Info1
   * @param p_pei_information2 VARCHAR2 PEI Info2
   * @param p_pei_information3 VARCHAR2 PEI Info3
   * @param p_pei_information4 VARCHAR2 PEI Info4
   * @param p_pei_information5 VARCHAR2 PEI Info5
   * @param p_pei_information6 VARCHAR2 PEI Info6
   * @param p_pei_information7 VARCHAR2 PEI Info7
   * @param p_pei_information8 VARCHAR2 PEI Info8
   * @param p_pei_information9 VARCHAR2 PEI Info9
   * @param p_pei_information10 VARCHAR2 PEI Info10
   * @param p_pei_information11 VARCHAR2 PEI Info11
   * @param p_pei_information12 VARCHAR2 PEI Info12
   * @param p_pei_information13 VARCHAR2 PEI Info13
   * @param p_pei_information14 VARCHAR2 PEI Info14
   * @param p_pei_information15 VARCHAR2 PEI Info15
   * @param p_pei_information16 VARCHAR2 PEI Info16
   * @param p_pei_information17 VARCHAR2 PEI Info17
   * @param p_pei_information18 VARCHAR2 PEI Info18
   * @param p_pei_information19 VARCHAR2 PEI Info19
   * @param p_pei_information20 VARCHAR2 PEI Info20
   * @param p_pei_information21 VARCHAR2 PEI Info21
   * @param p_pei_information22 VARCHAR2 PEI Info22
   * @param p_pei_information23 VARCHAR2 PEI Info23
   * @param p_pei_information24 VARCHAR2 PEI Info24
   * @param p_pei_information25 VARCHAR2 PEI Info25
   * @param p_pei_information26 VARCHAR2 PEI Info26
   * @param p_pei_information27 VARCHAR2 PEI Info27
   * @param p_pei_information28 VARCHAR2 PEI Info28
   * @param p_pei_information29 VARCHAR2 PEI Info29
   * @param p_pei_information30 VARCHAR2 PEI Info30

   * @return EIT_Data
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname Return EIT Data
   */
    FUNCTION CREATE_PERSON_EXTRA_INFO (
            -- P_validate IN BOOLEAN default FALSE,
            P_PERSON_ID NUMBER default null,
            P_REQUESTER_PERSON_ID NUMBER default null,
            p_information_type VARCHAR2 default null,
            -- p_pei_attribute_category VARCHAR2 default null,
            -- p_pei_information_category VARCHAR2 default null,
            p_pei_information1 VARCHAR2 default null,
            p_pei_information2 VARCHAR2 default null,
            p_pei_information3 VARCHAR2 default null,
            p_pei_information4 VARCHAR2 default null,
            p_pei_information5 VARCHAR2 default null,
            p_pei_information6 VARCHAR2 default null,
            p_pei_information7 VARCHAR2 default null,
            p_pei_information8 VARCHAR2 default null,
            p_pei_information9 VARCHAR2 default null,
            p_pei_information10 VARCHAR2 default null,
            p_pei_information11 VARCHAR2 default null,
            p_pei_information12 VARCHAR2 default null,
            p_pei_information13 VARCHAR2 default null,
            p_pei_information14 VARCHAR2 default null,
            p_pei_information15 VARCHAR2 default null,
            p_pei_information16 VARCHAR2 default null,
            p_pei_information17 VARCHAR2 default null,
            p_pei_information18 VARCHAR2 default null,
            p_pei_information19 VARCHAR2 default null,
            p_pei_information20 VARCHAR2 default null,
            p_pei_information21 VARCHAR2 default null,
            p_pei_information22 VARCHAR2 default null,
            p_pei_information23 VARCHAR2 default null,
            p_pei_information24 VARCHAR2 default null,
            p_pei_information25 VARCHAR2 default null,
            p_pei_information26 VARCHAR2 default null,
            p_pei_information27 VARCHAR2 default null,
            p_pei_information28 VARCHAR2 default null,
            p_pei_information29 VARCHAR2 default null,
            p_pei_information30 VARCHAR2 default null
            ) RETURN xxx_zain_ess_eit_data;

    /*#
   * Returns Extra Info Data
   * @param P_PERSON_ID NUMBER Person Id
   * @param P_REQUESTER_PERSON_ID NUMBER Requester Person Id
   * @param p_information_type VARCHAR2 Information Type Type
   * @param p_pei_information1 VARCHAR2 PEI Info1
   * @param p_pei_information2 VARCHAR2 PEI Info2
   * @param p_pei_information3 VARCHAR2 PEI Info3
   * @param p_pei_information4 VARCHAR2 PEI Info4
   * @param p_pei_information5 VARCHAR2 PEI Info5
   * @param p_pei_information6 VARCHAR2 PEI Info6
   * @param p_pei_information7 VARCHAR2 PEI Info7
   * @param p_pei_information8 VARCHAR2 PEI Info8
   * @param p_pei_information9 VARCHAR2 PEI Info9
   * @param p_pei_information10 VARCHAR2 PEI Info10
   * @param p_pei_information11 VARCHAR2 PEI Info11
   * @param p_pei_information12 VARCHAR2 PEI Info12
   * @param p_pei_information13 VARCHAR2 PEI Info13
   * @param p_pei_information14 VARCHAR2 PEI Info14
   * @param p_pei_information15 VARCHAR2 PEI Info15
   * @param p_pei_information16 VARCHAR2 PEI Info16
   * @param p_pei_information17 VARCHAR2 PEI Info17
   * @param p_pei_information18 VARCHAR2 PEI Info18
   * @param p_pei_information19 VARCHAR2 PEI Info19
   * @param p_pei_information20 VARCHAR2 PEI Info20
   * @param p_pei_information21 VARCHAR2 PEI Info21
   * @param p_pei_information22 VARCHAR2 PEI Info22
   * @param p_pei_information23 VARCHAR2 PEI Info23
   * @param p_pei_information24 VARCHAR2 PEI Info24
   * @param p_pei_information25 VARCHAR2 PEI Info25
   * @param p_pei_information26 VARCHAR2 PEI Info26
   * @param p_pei_information27 VARCHAR2 PEI Info27
   * @param p_pei_information28 VARCHAR2 PEI Info28
   * @param p_pei_information29 VARCHAR2 PEI Info29
   * @param p_pei_information30 VARCHAR2 PEI Info30

   * @return EIT_Data
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname Return EIT Data
   */
    FUNCTION VALIDATE_PERSON_EXTRA_INFO (
            -- P_validate IN BOOLEAN default FALSE,
            P_PERSON_ID NUMBER default null,
            P_REQUESTER_PERSON_ID NUMBER default null,
            p_information_type VARCHAR2 default null,
            -- p_pei_attribute_category VARCHAR2 default null,
            -- p_pei_information_category VARCHAR2 default null,
            p_pei_information1 VARCHAR2 default null,
            p_pei_information2 VARCHAR2 default null,
            p_pei_information3 VARCHAR2 default null,
            p_pei_information4 VARCHAR2 default null,
            p_pei_information5 VARCHAR2 default null,
            p_pei_information6 VARCHAR2 default null,
            p_pei_information7 VARCHAR2 default null,
            p_pei_information8 VARCHAR2 default null,
            p_pei_information9 VARCHAR2 default null,
            p_pei_information10 VARCHAR2 default null,
            p_pei_information11 VARCHAR2 default null,
            p_pei_information12 VARCHAR2 default null,
            p_pei_information13 VARCHAR2 default null,
            p_pei_information14 VARCHAR2 default null,
            p_pei_information15 VARCHAR2 default null,
            p_pei_information16 VARCHAR2 default null,
            p_pei_information17 VARCHAR2 default null,
            p_pei_information18 VARCHAR2 default null,
            p_pei_information19 VARCHAR2 default null,
            p_pei_information20 VARCHAR2 default null,
            p_pei_information21 VARCHAR2 default null,
            p_pei_information22 VARCHAR2 default null,
            p_pei_information23 VARCHAR2 default null,
            p_pei_information24 VARCHAR2 default null,
            p_pei_information25 VARCHAR2 default null,
            p_pei_information26 VARCHAR2 default null,
            p_pei_information27 VARCHAR2 default null,
            p_pei_information28 VARCHAR2 default null,
            p_pei_information29 VARCHAR2 default null,
            p_pei_information30 VARCHAR2 default null
            ) RETURN xxx_zain_ess_eit_data;
            
    /*#
   * Returns Hello Test
   
   * @return Hello_Test
   * @rep:scope public
   * @rep:lifecycle active
   * @rep:displayname Return Hello Test
   */
   FUNCTION Hello_Test
      RETURN xxx_zain_ess_LookUp_tb;
END;