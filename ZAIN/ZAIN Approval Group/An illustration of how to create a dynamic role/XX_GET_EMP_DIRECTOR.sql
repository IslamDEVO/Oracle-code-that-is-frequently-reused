create or replace FUNCTION      XX_GET_EMP_DIRECTOR (
   V_TRANSACTIONS_ID    NUMBER)
   RETURN VARCHAR2
AS
   v_Sup_Parent_Position_Id   NUMBER;
   --v_Parent_Position_Id number;
   v_PERSON_ID                NUMBER;
   v_Sup_ParPosId_Loop        NUMBER;
   v_NEXT_SUP_POS             NUMBER;
   v_POS_NAME                 VARCHAR2 (180);
   v_TRANS_ID                 NUMBER;
   v_process_name             VARCHAR2 (1000);
   l_assignment_id            NUMBER;
   l_job_level                VARCHAR (50) DEFAULT 'none';
   EMP_PERSON_ID              NUMBER;
   ORG_EXIST                  VARCHAR2 (10);
/* ASHRAF ABU SAAD */
BEGIN
   BEGIN
      SELECT RTRIM (LTRIM (hr_ameutil_ss.isLOAChange (V_TRANSACTIONS_ID)))
        INTO v_process_name
        FROM DUAL;

      --  updated Abdullah.albedah    30Mar2015  Added condition to return true for over time process

      v_process_name :=
         CASE
            WHEN APPS.XX_ZAIN_AME_PKG.XX_EIT_STRUCTURE_CODE (
                    V_TRANSACTIONS_ID) = 'SA_OVERTIME_REQUEST'
            THEN
               'true'
         END;
   EXCEPTION
      WHEN OTHERS
      THEN
         v_process_name := 'N';
   END;



   v_TRANS_ID := V_TRANSACTIONS_ID;

   SELECT DISTINCT PAF.POSITION_ID, HAT.CREATOR_PERSON_ID
     INTO v_Sup_Parent_Position_Id, EMP_PERSON_ID
     FROM HR_API_TRANSACTIONS HAT, PER_ALL_ASSIGNMENTS_F PAF
    WHERE     HAT.TRANSACTION_ID = v_TRANS_ID
          AND HAT.selected_PERSON_ID = PAF.PERSON_ID
          AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE
                          AND PAF.EFFECTIVE_END_DATE
          AND PAF.PRIMARY_FLAG = 'Y';


   LOOP
      /*                     SELECT NVL(PPSE.Parent_Position_Id,0)into v_Sup_ParPosId_Loop
                           FROM   PER_POS_STRUCTURE_ELEMENTS PPSE
                           WHERE  PPSE.SUBORDINATE_POSITION_ID= v_Sup_Parent_Position_Id
                           AND    PPSE.LAST_UPDATE_DATE=(
                                                      SELECT MAX(PPSE.LAST_UPDATE_DATE)
                                                      FROM   PER_POS_STRUCTURE_ELEMENTS PPSE
                                                      WHERE  PPSE.SUBORDINATE_POSITION_ID= v_Sup_Parent_Position_Id
                                                     );   */

      SELECT NVL (PPSE.Parent_Position_Id, 0)
        INTO v_Sup_ParPosId_Loop
        FROM PER_POS_STRUCTURE_ELEMENTS PPSE, PER_POSITION_STRUCTURES_V PPSV
       WHERE     PPSE.SUBORDINATE_POSITION_ID = v_Sup_Parent_Position_Id
             AND PPSE.POS_STRUCTURE_VERSION_ID = PPSV.POSITION_STRUCTURE_ID
             AND primary_position_flag = 'Y';


      --Getting person_id of supervisor
      SELECT NVL (MAX (PPF.PERSON_ID), 0)
        INTO v_PERSON_ID
        FROM PER_ALL_PEOPLE_F PPF, PER_ASSIGNMENTS_X PAX
       WHERE     PPF.PERSON_ID = PAX.PERSON_ID
             AND PAX.ASSIGNMENT_STATUS_TYPE_ID <> 3
             AND PAX.POSITION_ID = v_Sup_ParPosId_Loop;

      -- this condition is added by salman on 29-Nov-2017 to resolve the case of Abdullah AlDamer as per order or CEO.
      -- Please remove this condition when there is a person on Abdullah AlDamer Position.
      IF v_PERSON_ID = 40722
      THEN
         RETURN 40722;
      END IF;

      -- Check if the position is of director level
      SELECT NVL (PP.NAME, '0')
        INTO v_POS_NAME
        FROM PER_POSITIONS PP
       WHERE PP.POSITION_ID = v_Sup_ParPosId_Loop;


      v_Sup_Parent_Position_Id := v_Sup_ParPosId_Loop;

      -- Below added and updated by AJaloud 28 Jul 2017  // get job level from grade definition
      BEGIN
         --  SELECT XX_GET_EMP_ORG_name(EMP_PERSON_ID) INTO ORG_EXIST FROM DUAL;

         --    IF ORG_EXIST = 'N'
         --    THEN
         SELECT asg.assignment_id
           INTO l_assignment_id
           FROM per_all_assignments_f asg
          WHERE     SYSDATE BETWEEN asg.effective_start_date
                                AND asg.effective_end_date
                AND asg.primary_flag = 'Y'
                AND person_id = v_person_id;

         --
         l_job_level :=
            XXZIN_HR_PACKAGE1.ZAIN_GET_JOB_LEVEL_BY_ASG (l_assignment_id,
                                                         SYSDATE);

         EXIT WHEN (    v_PERSON_ID > 0
                    AND (   UPPER (l_job_level) LIKE '%GENERAL%MANAGER%'
                         OR (   UPPER (l_job_level) LIKE '%CHIEF%'
                             OR UPPER (l_job_level) LIKE '%CHEIF%'
                             OR UPPER (l_job_level) LIKE '%VICE%PRESIDENT%'
                             OR UPPER (l_job_level) LIKE '%CEO%') -- OR UPPER(v_POS_NAME) LIKE '%HEAD%'
                                                                 ));
      --                     end if;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_assignment_id := -1;
      END;
   END LOOP;

   --     return employee 304 instead of CEO when CEO is generated as approver
   IF v_person_id = X_ZAIN_KSA_GET_GLOBALV (SYSDATE, 'CEO_POSITION')
   THEN
      RETURN X_ZAIN_KSA_GET_GLOBALV (SYSDATE, 'PAYROLL_MGR_POSITION');   --672
   END IF;


   RETURN v_PERSON_ID;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN '-2';
   WHEN OTHERS
   THEN
      RETURN '-1';
END;