create or replace PACKAGE BODY      xxx_zain_ess_isg_R2_pkg
AS
	G_RESPONSIBILITY_NAME CONSTANT VARCHAR2(300):='ZAIN HRMS Manager';
	G_USER_NAME CONSTANT VARCHAR2(100):='ESSHRUSER';
	----------
	cursor cur_use_resp(P_PERSON_ID NUMBER) is
		select fnd.user_id , 
			   fresp.responsibility_id, 
			   fresp.application_id 
		from   fnd_user fnd 
		,      fnd_responsibility_tl fresp 
		where  
		--        fnd.user_name = 'SYSADMIN'
		fnd.employee_id = P_PERSON_ID
		-- and    fresp.responsibility_name = G_RESPONSIBILITY_NAME;
		and    fresp.responsibility_name = G_RESPONSIBILITY_NAME;
	-------------
	cursor cur_sysadmin_resp(P_PERSON_ID NUMBER) is
		select fnd.user_id , 
			   fresp.responsibility_id, 
			   fresp.application_id 
		from   fnd_user fnd 
		,      fnd_responsibility_tl fresp 
		where  
	   fnd.user_name = G_USER_NAME --'SYSADMIN'
		--fnd.employee_id = P_PERSON_ID
		-- fnd.user_id = 0
		and    fresp.responsibility_name = G_RESPONSIBILITY_NAME;
		--            and    fresp.responsibility_name = 'Saudi HRMS Manager';
		-- and    fresp.responsibility_name = 'System Administrator';
    -------------------------------------------------------------------        
    PROCEDURE init_session(p_person_id number)is
                l_user_resp cur_use_resp%rowtype;
            l_sysadmin_resp cur_sysadmin_resp%rowtype;
    begin
    
--           open cur_use_resp(P_REQUESTER_PERSON_ID);
--           fetch cur_use_resp into l_user_resp;
--           close cur_use_resp;

            open cur_sysadmin_resp(p_person_id);
           fetch cur_sysadmin_resp into l_sysadmin_resp;
           close cur_sysadmin_resp;
           --
           fnd_global.apps_initialize (--l_user_resp.user_id, 
                                        0,
                                    l_sysadmin_resp.responsibility_id, 
                                    l_sysadmin_resp.application_id);
           ---- requester person profile ----
           fnd_profile.put('PER_PERSON_ID', P_PERSON_ID);
--           hr_api.customer_hooks ('DISABLE');
            -----
            declare
            l_session_id number;
            begin
            select 1 into l_session_id from fnd_sessions where session_id = userenv('sessionid');
            exception
            when no_data_found then
            insert into fnd_sessions (SESSION_ID, EFFECTIVE_DATE) values(userenv('sessionid'), trunc(SYSDATE));
            end;
            
            -----
            
--            fnd_global.set_nls.set_parameter('NLS_LANGUAGE','ARABIC');
            ---
            
            exception 
            when others then
                null;
        end;
   ---------------------------
   ---------------------------
   FUNCTION get_lookup(
        ---- IN ----
            P_VALUESET_NAME IN VARCHAR2, 
            P_PERSON_ID NUMBER default null,
            P_REQUEST_MODE VARCHAR2 default null,
            P_Q_STRING VARCHAR2 default null,
            P_OFFSET NUMBER default null,
            P_LIMIT NUMBER default null,
            P_ORDER_BY VARCHAR2 default null
    ) return xxx_zain_ess_LookUp_tb
   IS
      L_SELECT_Q    xxx_zain_ess_valuesets.select_query%TYPE;
      ------
      MY_STRING     VARCHAR2 (2000) := P_Q_STRING;
      l_var         VARCHAR2 (50);
      l_value       VARCHAR2 (100);
      my_cur        SYS_REFCURSOR;
--      L_rec xxx_zain_ess_LookUp := xxx_zain_ess_LookUp(null,null,null);
      L_TB xxx_zain_ess_LookUp_tb := xxx_zain_ess_LookUp_tb();
      TYPE v_vs_type IS RECORD
      (
         code          VARCHAR2 (100),
         meaning       VARCHAR2 (150),
         description   VARCHAR2 (200)
      );
--
      L_rec     v_vs_type;
      -----
      l_json_resp   CLOB;
   BEGIN
      SELECT DISTINCT (select_query)
        INTO L_SELECT_Q
        FROM xxx_zain_ess_valuesets
       WHERE APINAME = P_VALUESET_NAME;

      L_SELECT_Q :=
         REPLACE (L_SELECT_Q, '#PER_PERSON_ID#', TO_CHAR (P_PERSON_ID));

      IF MY_STRING IS NOT NULL
      THEN
         FOR CURRENT_ROW
            IN (WITH test AS (SELECT MY_STRING FROM DUAL)
                    SELECT REGEXP_SUBSTR (MY_STRING,
                                          '[^;]+',
                                          1,
                                          ROWNUM)
                              SPLIT
                      FROM test
                CONNECT BY LEVEL <=
                                LENGTH (REGEXP_REPLACE (MY_STRING, '[^;]+'))
                              + 1)
         LOOP
            l_var :=
               SUBSTR (CURRENT_ROW.SPLIT,
                       1,
                       INSTR (CURRENT_ROW.SPLIT, '=') - 1);
            l_value :=
               SUBSTR (
                  CURRENT_ROW.SPLIT,
                  INSTR (CURRENT_ROW.SPLIT, '=') + 1,
                  LENGTH (CURRENT_ROW.SPLIT) - INSTR (CURRENT_ROW.SPLIT, '='));
            L_SELECT_Q := REPLACE (L_SELECT_Q, '#' || l_var || '#', l_value);
         END LOOP;
      END IF;
            dbms_output.put_line(L_SELECT_Q);
            open my_cur for L_SELECT_Q;
            loop
                fetch my_cur into L_rec;
                exit when my_cur%NOTFOUND;
                L_TB.extend;
                L_TB(L_TB.count) := xxx_zain_ess_LookUp(L_rec.code, L_rec.meaning, L_rec.description);
            end loop;

      RETURN L_TB;
    END get_lookup;

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
      RETURN xxx_zain_ess_abs_data
    is
          l_person_id number := P_PERSON_ID;
          l_absence_type varchar2(100) := P_ABSENCE_TYPE;
          l_effective_date date := P_EFFECTIVE_DATE;
          l_date_start date := P_DATE_START;
          l_date_end date := P_DATE_END;
          --
          cursor cur_assmt_info is
            select assignment_id from per_all_assignments_f
            where person_id = l_person_id
            and sysdate between effective_start_date and effective_end_date;
          --
          assmt_rec_dtl cur_assmt_info%rowtype;
          --
          l_validate boolean := FALSE; -- case when p_validate = 'TRUE' then True else False end;
          ----
--          cursor cur_deleg_users is
--            select rownum, personId, delegationType from P_BODY_DATA.delegatedUsers;
          --------------------
          v_business_group_id            NUMBER := 101;
          v_absence_attendance_type_id   NUMBER; -- Personal Time
          io_absence_days                NUMBER; -- := to_date(l_date_end) - to_date(l_date_start);
          io_absence_hours               NUMBER := NULL;
          o_absence_attendance_id        NUMBER;
          o_object_version_number        NUMBER;
          o_occurrence                   NUMBER;
          o_dur_dys_less_warning         BOOLEAN;
          o_dur_hrs_less_warning         BOOLEAN;
          o_exceeds_pto_entit_warning    BOOLEAN;
          o_exceeds_run_total_warning    BOOLEAN;
          o_abs_overlap_warning          BOOLEAN;
          o_abs_day_after_warning        BOOLEAN;
          o_dur_overwritten_warning      BOOLEAN;
          v_error_msg                    VARCHAR2 (3000);
          ---------------------------------
--          L_RET_CLOB      CLOB;
          ---------
          ---------
            l_clob         CLOB;
            l_dest_offset  PLS_INTEGER := 1;
            l_src_offset   PLS_INTEGER := 1;
            l_lang_context PLS_INTEGER := DBMS_LOB.default_lang_ctx;
            l_warning      PLS_INTEGER;
            ----
            l_resp         clob;
            ---
            odd_ctr        number := 0;
            personDelegAttr varchar2(250);
            -------
--            l_msg_rec xxx_zain_ess_msg_rec;
            l_msgs_tb xxx_zain_ess_msgs_tb := xxx_zain_ess_msgs_tb();
            l_abs_data_resp xxx_zain_ess_abs_data; -- := xxx_zain_ess_abs_data(null, null, xxx_zain_ess_msgs_tb());
            l_resp_status varchar2(20);
    begin
           init_session(p_person_id);
           ---------
           open cur_assmt_info;
           fetch cur_assmt_info into assmt_rec_dtl;
           close cur_assmt_info;
           ---------
           select ABSENCE_ATTENDANCE_TYPE_ID into v_absence_attendance_type_id
            FROM per_absence_attendance_types
            where name = l_absence_type;
           ---------
           io_absence_days := XX_ZAIN_OCI_PKG.LEAVE_DURATION(assmt_rec_dtl.assignment_id,l_date_start, l_date_end, v_absence_attendance_type_id);
         --------
         --------
          FOR i IN nvl(P_DELEGATED_USERS.FIRST, 0) .. nvl(P_DELEGATED_USERS.LAST * 2, -1) LOOP
            if mod(i, 2) = 0 and i>0 and P_DELEGATED_USERS(odd_ctr+1).personId is not null then
                ---
                select employee_number||'-'||full_name into personDelegAttr from per_all_people_f
                where person_id = P_DELEGATED_USERS(odd_ctr+1).personId
                and sysdate between effective_start_date and effective_end_date;
                ---
                dbms_output.put_line(P_DELEGATED_USERS(odd_ctr+1).personId);
                l_resp := l_resp || '"Attribute' || to_char(i) || '": "' || personDelegAttr || '"' ||
                                ', "Attribute' || to_char(i+1) || '": "' || P_DELEGATED_USERS(odd_ctr+1).DELEGATIONTYPE || '",';
                odd_ctr := odd_ctr + 1;
            end if;
          END LOOP;
            ---
            l_resp := '{' || substr(l_resp, 0, length(l_resp)-1) || '}';
            dbms_output.put_line(l_resp);
            ---    
            APEX_JSON.parse(l_resp);
          --------
          --------
          hr_person_absence_api.create_person_absence (p_validate                     => l_validate
                                                      ,p_effective_date               => l_effective_date
                                                      ,p_person_id                    => l_person_id
                                                      ,p_business_group_id            => v_business_group_id
                                                      ,p_absence_attendance_type_id   => v_absence_attendance_type_id
                                                      ,p_date_start                   => l_date_start
                                                      ,p_date_end                     => l_date_end
                                                      ,p_absence_days                 => io_absence_days
                                                      ,p_absence_hours                => io_absence_hours
--                                                      ,p_attribute1                   => APEX_JSON.get_varchar2(p_path => 'Attribute1')
                                                      ,p_attribute2                   => APEX_JSON.get_varchar2(p_path => 'Attribute2')
                                                      ,p_attribute3                   => APEX_JSON.get_varchar2(p_path => 'Attribute3')
                                                      ,p_attribute4                   => APEX_JSON.get_varchar2(p_path => 'Attribute4')
                                                      ,p_attribute5                   => APEX_JSON.get_varchar2(p_path => 'Attribute5')
                                                      ,p_attribute6                   => APEX_JSON.get_varchar2(p_path => 'Attribute6')
                                                      ,p_attribute7                   => APEX_JSON.get_varchar2(p_path => 'Attribute7')
                                                      ,p_attribute8                   => APEX_JSON.get_varchar2(p_path => 'Attribute8')
                                                      ,p_attribute9                   => APEX_JSON.get_varchar2(p_path => 'Attribute9')
                                                      ,p_attribute10                  => APEX_JSON.get_varchar2(p_path => 'Attribute10')
                                                      ,p_attribute11                  => APEX_JSON.get_varchar2(p_path => 'Attribute11')
                                                      ,p_absence_attendance_id        => o_absence_attendance_id
                                                      ,p_object_version_number        => o_object_version_number
                                                      ,p_occurrence                   => o_occurrence
                                                      ,p_dur_dys_less_warning         => o_dur_dys_less_warning
                                                      ,p_dur_hrs_less_warning         => o_dur_hrs_less_warning
                                                      ,p_exceeds_pto_entit_warning    => o_exceeds_pto_entit_warning
                                                      ,p_exceeds_run_total_warning    => o_exceeds_run_total_warning
                                                      ,p_abs_overlap_warning          => o_abs_overlap_warning
                                                      ,p_abs_day_after_warning        => o_abs_day_after_warning
                                                      ,p_dur_overwritten_warning      => o_dur_overwritten_warning);

            DBMS_LOB.freetemporary(lob_loc => l_resp);                                                                                                  
            --------    
            COMMIT;                                                                                                                                                                                                                                                                                                                                                                                                              
            --
            l_resp_status := 'success';
            l_abs_data_resp := xxx_zain_ess_abs_data(l_resp_status, o_absence_attendance_id, l_msgs_tb);
            dbms_output.put_line(l_resp_status);
            ---------------------------------------------
            RETURN l_abs_data_resp;
              
         EXCEPTION
          WHEN OTHERS THEN
            v_error_msg := sqlerrm;
        --------
              IF o_absence_attendance_id IS NOT NULL THEN
                l_resp_status := 'warning';
              ELSE
                l_resp_status := 'error';
              END IF;
        --------
            if v_error_msg is not null and o_absence_attendance_id is null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('error', null, v_error_msg);
            end if;
            dbms_output.put_line(v_error_msg);
            ----
            if o_dur_dys_less_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'dur_dys_less_warning', v_error_msg);
            end if;

            if o_dur_hrs_less_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'dur_hrs_less_warning', v_error_msg);
            end if;

            if o_exceeds_pto_entit_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'exceeds_pto_entit_warning', v_error_msg);
            end if;

            if o_exceeds_run_total_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'exceeds_run_total_warning', v_error_msg);
            end if;

            if o_abs_overlap_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'abs_overlap_warning', v_error_msg);
            end if;

            if o_abs_day_after_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'abs_day_after_warning', v_error_msg);
            end if;

            if o_dur_overwritten_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'dur_overwritten_warning', v_error_msg);
            end if;
            -------------------
            l_abs_data_resp := xxx_zain_ess_abs_data(l_resp_status, o_absence_attendance_id, l_msgs_tb);
            dbms_output.put_line(l_resp_status);
            ---------------------------------------------
            RETURN l_abs_data_resp;
    end;
    
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
      RETURN xxx_zain_ess_abs_data
    is
          l_person_id number := P_PERSON_ID;
          l_absence_type varchar2(100) := P_ABSENCE_TYPE;
          l_effective_date date := P_EFFECTIVE_DATE;
          l_date_start date := P_DATE_START;
          l_date_end date := P_DATE_END;
          --
          cursor cur_assmt_info is
            select assignment_id from per_all_assignments_f
            where person_id = l_person_id
            and sysdate between effective_start_date and effective_end_date;
          --
          assmt_rec_dtl cur_assmt_info%rowtype;
          --
          l_validate boolean := TRUE; -- case when p_validate = 'TRUE' then True else False end;
          ----
--          cursor cur_deleg_users is
--            select rownum, personId, delegationType from P_BODY_DATA.delegatedUsers;
          --------------------
          v_business_group_id            NUMBER := 101;
          v_absence_attendance_type_id   NUMBER; -- Personal Time
          io_absence_days                NUMBER; -- := to_date(l_date_end) - to_date(l_date_start);
          io_absence_hours               NUMBER := NULL;
          o_absence_attendance_id        NUMBER;
          o_object_version_number        NUMBER;
          o_occurrence                   NUMBER;
          o_dur_dys_less_warning         BOOLEAN;
          o_dur_hrs_less_warning         BOOLEAN;
          o_exceeds_pto_entit_warning    BOOLEAN;
          o_exceeds_run_total_warning    BOOLEAN;
          o_abs_overlap_warning          BOOLEAN;
          o_abs_day_after_warning        BOOLEAN;
          o_dur_overwritten_warning      BOOLEAN;
          v_error_msg                    VARCHAR2 (3000);
          ---------------------------------
--          L_RET_CLOB      CLOB;
          ---------
          ---------
            l_clob         CLOB;
            l_dest_offset  PLS_INTEGER := 1;
            l_src_offset   PLS_INTEGER := 1;
            l_lang_context PLS_INTEGER := DBMS_LOB.default_lang_ctx;
            l_warning      PLS_INTEGER;
            ----
            l_resp         clob;
            ---
            odd_ctr        number := 0;
            personDelegAttr varchar2(250);
            -------
--            l_msg_rec xxx_zain_ess_msg_rec;
            l_msgs_tb xxx_zain_ess_msgs_tb := xxx_zain_ess_msgs_tb();
            l_abs_data_resp xxx_zain_ess_abs_data; -- := xxx_zain_ess_abs_data(null, null, xxx_zain_ess_msgs_tb());
            l_resp_status varchar2(20);
    begin
            -----
            init_session(p_person_id);
           ---------
           open cur_assmt_info;
           fetch cur_assmt_info into assmt_rec_dtl;
           close cur_assmt_info;
           ---------
           select ABSENCE_ATTENDANCE_TYPE_ID into v_absence_attendance_type_id
            FROM per_absence_attendance_types
            where name = l_absence_type;
           ---------
           io_absence_days := XX_ZAIN_OCI_PKG.LEAVE_DURATION(assmt_rec_dtl.assignment_id,l_date_start, l_date_end, v_absence_attendance_type_id);
         --------
         --------
          FOR i IN nvl(P_DELEGATED_USERS.FIRST, 0) .. nvl(P_DELEGATED_USERS.LAST * 2, -1) LOOP
            if mod(i, 2) = 0 and i>0 and P_DELEGATED_USERS(odd_ctr+1).personId is not null then
                ---
                select employee_number||'-'||full_name into personDelegAttr from per_all_people_f
                where person_id = P_DELEGATED_USERS(odd_ctr+1).personId
                and sysdate between effective_start_date and effective_end_date;
                ---
                dbms_output.put_line(P_DELEGATED_USERS(odd_ctr+1).personId);
                l_resp := l_resp || '"Attribute' || to_char(i) || '": "' || personDelegAttr || '"' ||
                                ', "Attribute' || to_char(i+1) || '": "' || P_DELEGATED_USERS(odd_ctr+1).DELEGATIONTYPE || '",';
                odd_ctr := odd_ctr + 1;
            end if;
          END LOOP;
            ---
            l_resp := '{' || substr(l_resp, 0, length(l_resp)-1) || '}';
            dbms_output.put_line(l_resp);
            ---    
            APEX_JSON.parse(l_resp);
          --------
          --------
          hr_person_absence_api.create_person_absence (p_validate                     => l_validate
                                                      ,p_effective_date               => l_effective_date
                                                      ,p_person_id                    => l_person_id
                                                      ,p_business_group_id            => v_business_group_id
                                                      ,p_absence_attendance_type_id   => v_absence_attendance_type_id
                                                      ,p_date_start                   => l_date_start
                                                      ,p_date_end                     => l_date_end
                                                      ,p_absence_days                 => io_absence_days
                                                      ,p_absence_hours                => io_absence_hours
--                                                      ,p_attribute1                   => APEX_JSON.get_varchar2(p_path => 'Attribute1')
                                                      ,p_attribute2                   => APEX_JSON.get_varchar2(p_path => 'Attribute2')
                                                      ,p_attribute3                   => APEX_JSON.get_varchar2(p_path => 'Attribute3')
                                                      ,p_attribute4                   => APEX_JSON.get_varchar2(p_path => 'Attribute4')
                                                      ,p_attribute5                   => APEX_JSON.get_varchar2(p_path => 'Attribute5')
                                                      ,p_attribute6                   => APEX_JSON.get_varchar2(p_path => 'Attribute6')
                                                      ,p_attribute7                   => APEX_JSON.get_varchar2(p_path => 'Attribute7')
                                                      ,p_attribute8                   => APEX_JSON.get_varchar2(p_path => 'Attribute8')
                                                      ,p_attribute9                   => APEX_JSON.get_varchar2(p_path => 'Attribute9')
                                                      ,p_attribute10                  => APEX_JSON.get_varchar2(p_path => 'Attribute10')
                                                      ,p_attribute11                  => APEX_JSON.get_varchar2(p_path => 'Attribute11')
                                                      ,p_absence_attendance_id        => o_absence_attendance_id
                                                      ,p_object_version_number        => o_object_version_number
                                                      ,p_occurrence                   => o_occurrence
                                                      ,p_dur_dys_less_warning         => o_dur_dys_less_warning
                                                      ,p_dur_hrs_less_warning         => o_dur_hrs_less_warning
                                                      ,p_exceeds_pto_entit_warning    => o_exceeds_pto_entit_warning
                                                      ,p_exceeds_run_total_warning    => o_exceeds_run_total_warning
                                                      ,p_abs_overlap_warning          => o_abs_overlap_warning
                                                      ,p_abs_day_after_warning        => o_abs_day_after_warning
                                                      ,p_dur_overwritten_warning      => o_dur_overwritten_warning);

            DBMS_LOB.freetemporary(lob_loc => l_resp);                                                                                                  
            --------    
            rollback;                                                                                                                                                                                                                                                                                                                                                                                                              
            --
            l_resp_status := 'success';
            l_abs_data_resp := xxx_zain_ess_abs_data(l_resp_status, o_absence_attendance_id, l_msgs_tb);
            dbms_output.put_line(l_resp_status);
            ---------------------------------------------
            RETURN l_abs_data_resp;
              
         EXCEPTION
          WHEN OTHERS THEN
            v_error_msg := sqlerrm;
        --------
              IF o_absence_attendance_id IS NOT NULL THEN
                l_resp_status := 'warning';
              ELSE
                l_resp_status := 'error';
              END IF;
        --------
            if v_error_msg is not null and o_absence_attendance_id is null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('error', null, v_error_msg);
            end if;
            dbms_output.put_line(v_error_msg);
            ----
            if o_dur_dys_less_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'dur_dys_less_warning', v_error_msg);
            end if;

            if o_dur_hrs_less_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'dur_hrs_less_warning', v_error_msg);
            end if;

            if o_exceeds_pto_entit_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'exceeds_pto_entit_warning', v_error_msg);
            end if;

            if o_exceeds_run_total_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'exceeds_run_total_warning', v_error_msg);
            end if;

            if o_abs_overlap_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'abs_overlap_warning', v_error_msg);
            end if;

            if o_abs_day_after_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'abs_day_after_warning', v_error_msg);
            end if;

            if o_dur_overwritten_warning is not null then
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec('warning', 'dur_overwritten_warning', v_error_msg);
            end if;
            -------------------
            l_abs_data_resp := xxx_zain_ess_abs_data(l_resp_status, o_absence_attendance_id, l_msgs_tb);
            dbms_output.put_line(l_resp_status);
            ---------------------------------------------
            rollback;
            ----
            RETURN l_abs_data_resp;
    end;

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
            ) RETURN xxx_zain_ess_eit_data
    IS
            l_person_extra_info_id    number;
            l_object_version_number   number;
            v_error_msg               VARCHAR2 (3000);
            -----
            L_RET_CLOB                CLOB;
            -----
            l_msgs_tb xxx_zain_ess_msgs_tb := xxx_zain_ess_msgs_tb();
            l_eit_data_resp xxx_zain_ess_eit_data; -- := xxx_zain_ess_abs_data(null, null, xxx_zain_ess_msgs_tb());
            l_resp_status varchar2(20);
            ---
            l_pei_information7 per_people_extra_info.pei_information7%type := p_pei_information7;
            l_pei_information6 per_people_extra_info.pei_information6%type := p_pei_information6;
            l_pei_information10 per_people_extra_info.pei_information10%type := p_pei_information10;
    BEGIN
            init_session(p_person_id);
            ------------
            if p_information_type = 'ZAIN_ATT_SHORTAGE' then
                Select floor(dbms_random.value(1, 20000000)) into l_pei_information7 from dual;
            end if;
            ---
            if p_information_type = 'ZAIN_HOUSING_ADVANCE_REQ' then
                select round(abs(dbms_random.random)) into l_pei_information7 from dual;
            end if;
            ---
            if p_information_type = 'SA_OVERTIME_REQUEST' then
                select round(abs(dbms_random.random)) into l_pei_information6 from dual;
            end if;
            ---
            if p_information_type = 'ZAIN_NURSERY_REQ' then
                select round(abs(dbms_random.random)) into l_pei_information10 from dual;
            end if;
            ------------
            hr_person_extra_info_api.create_person_extra_info (
                 p_validate                   => FALSE
                ,p_person_id                  => P_PERSON_ID
                ,p_information_type           => p_information_type
                ,p_pei_attribute_category     => NULL
                ,p_pei_information_category   => p_information_type
                ,p_pei_information1           => p_pei_information1
                ,p_pei_information2           => p_pei_information2
                ,p_pei_information3           => p_pei_information3
                ,p_pei_information4           => p_pei_information4
                ,p_pei_information5           => p_pei_information5
                ,p_pei_information6           => l_pei_information6 -- p_pei_information6
                ,p_pei_information7           => l_pei_information7 -- p_pei_information7
                ,p_pei_information8           => p_pei_information8
                ,p_pei_information9           => p_pei_information9
                ,p_pei_information10           => l_pei_information10 -- p_pei_information10
                ,p_pei_information11           => p_pei_information11
                ,p_pei_information12           => p_pei_information12
                ,p_pei_information13           => p_pei_information13
                ,p_pei_information14           => p_pei_information14
                ,p_pei_information15           => p_pei_information15
                ,p_pei_information16           => p_pei_information16
                ,p_pei_information17           => p_pei_information17
                ,p_pei_information18           => p_pei_information18
                ,p_pei_information19           => p_pei_information19
                ,p_pei_information20           => p_pei_information20
                ,p_pei_information21           => p_pei_information21
                ,p_pei_information22           => p_pei_information22
                ,p_pei_information23           => p_pei_information23
                ,p_pei_information24           => p_pei_information24
                ,p_pei_information25           => p_pei_information25
                ,p_pei_information26           => p_pei_information26
                ,p_pei_information27           => p_pei_information27
                ,p_pei_information28           => p_pei_information28
                ,p_pei_information29           => p_pei_information29
                ,p_pei_information30           => p_pei_information30
                ,p_person_extra_info_id       => l_person_extra_info_id
                ,p_object_version_number      => l_object_version_number);
            ----------    
            COMMIT;                                                                                                                                                                                                                                                                                                                                                                                                              
            --
            l_resp_status := 'success';
            l_eit_data_resp := xxx_zain_ess_eit_data(l_resp_status, l_person_extra_info_id, l_msgs_tb);
            dbms_output.put_line(l_resp_status);
            ---------------------------------------------
            RETURN l_eit_data_resp;
            ----
            EXCEPTION
                WHEN OTHERS THEN
                v_error_msg   := sqlerrm;
                ---------
                IF l_person_extra_info_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                -------
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec(l_resp_status, 'dur_overwritten_warning', v_error_msg);
                l_eit_data_resp := xxx_zain_ess_eit_data(l_resp_status, l_person_extra_info_id, l_msgs_tb);
                ---------------------------------------------
                RETURN l_eit_data_resp;
    END;

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
            ) RETURN xxx_zain_ess_eit_data
    IS
            l_person_extra_info_id    number;
            l_object_version_number   number;
            v_error_msg               VARCHAR2 (3000);
            -----
            l_dummy number;
            -----
            cursor cur_exit_iv is
                select PERSON_EXTRA_INFO_ID from per_people_extra_info
                where information_type = 'ZAIN_EXIT_INTERVIEW' and person_id = P_PERSON_ID;
            -----
            L_RET_CLOB                CLOB;
            -----
            l_msgs_tb xxx_zain_ess_msgs_tb := xxx_zain_ess_msgs_tb();
            l_eit_data_resp xxx_zain_ess_eit_data; -- := xxx_zain_ess_abs_data(null, null, xxx_zain_ess_msgs_tb());
            l_resp_status varchar2(20);
            ---
            l_pei_information7 per_people_extra_info.pei_information7%type := p_pei_information7;
            l_pei_information6 per_people_extra_info.pei_information6%type := p_pei_information6;
            l_pei_information10 per_people_extra_info.pei_information10%type := p_pei_information10;
    BEGIN
            init_session(p_person_id);
            ------------
            if p_information_type = 'ZAIN_ATT_SHORTAGE' then
                Select floor(dbms_random.value(1, 20000000)) into l_pei_information7 from dual;
            end if;
            ---
            if p_information_type = 'ZAIN_HOUSING_ADVANCE_REQ' then
                select round(abs(dbms_random.random)) into l_pei_information7 from dual;
            end if;
            ---
            if p_information_type = 'SA_OVERTIME_REQUEST' then
                select round(abs(dbms_random.random)) into l_pei_information6 from dual;
            end if;
            ---
            if p_information_type = 'ZAIN_NURSERY_REQ' then
                select round(abs(dbms_random.random)) into l_pei_information10 from dual;
            end if;
            ---
            if p_information_type = 'ZAIN_EXIT_INTERVIEW' then
--                begin
--                select PERSON_EXTRA_INFO_ID into l_dummy from per_people_extra_info
--                where information_type = 'ZAIN_EXIT_INTERVIEW' and person_id = P_PERSON_ID;
--                EXCEPTION WHEN no_data_found THEN
                open cur_exit_iv;
                fetch cur_exit_iv into l_dummy;
                close cur_exit_iv;
                ---
                if l_dummy is not null then
                    l_resp_status := 'error';
                    ---
                    l_msgs_tb.extend;
                    l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec(l_resp_status, null, 'Employee already submitted the Exit Interview.');
                    l_eit_data_resp := xxx_zain_ess_eit_data(l_resp_status, l_person_extra_info_id, l_msgs_tb);
                    ---
                    RETURN l_eit_data_resp;
                end if;
--                end;
            end if;
            ------------
            dbms_output.put_line(p_pei_information1);
            dbms_output.put_line(p_pei_information3);
            dbms_output.put_line(p_pei_information4);
            dbms_output.put_line(p_pei_information6);
            dbms_output.put_line(p_pei_information7);
            dbms_output.put_line(p_pei_information8);
            dbms_output.put_line(p_pei_information9);
            ------------
            hr_person_extra_info_api.create_person_extra_info (
                 p_validate                   => TRUE
                ,p_person_id                  => P_PERSON_ID
                ,p_information_type           => p_information_type
                ,p_pei_attribute_category     => NULL
                ,p_pei_information_category   => p_information_type
                ,p_pei_information1           => p_pei_information1
                ,p_pei_information2           => p_pei_information2
                ,p_pei_information3           => p_pei_information3
                ,p_pei_information4           => p_pei_information4
                ,p_pei_information5           => p_pei_information5
                ,p_pei_information6           => l_pei_information6 -- p_pei_information6
                ,p_pei_information7           => l_pei_information7 -- p_pei_information7
                ,p_pei_information8           => p_pei_information8
                ,p_pei_information9           => p_pei_information9
                ,p_pei_information10           => l_pei_information10 -- p_pei_information10
                ,p_pei_information11           => p_pei_information11
                ,p_pei_information12           => p_pei_information12
                ,p_pei_information13           => p_pei_information13
                ,p_pei_information14           => p_pei_information14
                ,p_pei_information15           => p_pei_information15
                ,p_pei_information16           => p_pei_information16
                ,p_pei_information17           => p_pei_information17
                ,p_pei_information18           => p_pei_information18
                ,p_pei_information19           => p_pei_information19
                ,p_pei_information20           => p_pei_information20
                ,p_pei_information21           => p_pei_information21
                ,p_pei_information22           => p_pei_information22
                ,p_pei_information23           => p_pei_information23
                ,p_pei_information24           => p_pei_information24
                ,p_pei_information25           => p_pei_information25
                ,p_pei_information26           => p_pei_information26
                ,p_pei_information27           => p_pei_information27
                ,p_pei_information28           => p_pei_information28
                ,p_pei_information29           => p_pei_information29
                ,p_pei_information30           => p_pei_information30
                ,p_person_extra_info_id       => l_person_extra_info_id
                ,p_object_version_number      => l_object_version_number);
            ----------    
            COMMIT;                                                                                                                                                                                                                                                                                                                                                                                                              
            --
            l_resp_status := 'success';
            l_eit_data_resp := xxx_zain_ess_eit_data(l_resp_status, l_person_extra_info_id, l_msgs_tb);
            dbms_output.put_line(l_resp_status);
            ---------------------------------------------
            RETURN l_eit_data_resp;
            ----
            EXCEPTION
                WHEN OTHERS THEN
                v_error_msg   := sqlerrm;
                ---------
                IF l_person_extra_info_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                -------
                l_msgs_tb.extend;
                l_msgs_tb(l_msgs_tb.count) := xxx_zain_ess_msg_rec(l_resp_status, null, v_error_msg);
                l_eit_data_resp := xxx_zain_ess_eit_data(l_resp_status, l_person_extra_info_id, l_msgs_tb);
                ---
                dbms_output.put_line(l_resp_status);
                dbms_output.put_line(v_error_msg);
                ---------------------------------------------
                RETURN l_eit_data_resp;
    END;
    
    FUNCTION Hello_Test return xxx_zain_ess_LookUp_tb
    is
        L_SELECT_Q    xxx_zain_ess_valuesets.select_query%TYPE;
          ------
          MY_STRING     VARCHAR2 (2000);
          l_var         VARCHAR2 (50);
          l_value       VARCHAR2 (100);
          my_cur        SYS_REFCURSOR;
    --      L_rec xxx_zain_ess_LookUp := xxx_zain_ess_LookUp(null,null,null);
          L_TB xxx_zain_ess_LookUp_tb := xxx_zain_ess_LookUp_tb();
          TYPE v_vs_type IS RECORD
          (
             code          VARCHAR2 (100),
             meaning       VARCHAR2 (150),
             description   VARCHAR2 (200)
          );
    --
          L_rec     v_vs_type;
          -----
          l_json_resp   CLOB;
       BEGIN
          SELECT DISTINCT (select_query)
            INTO L_SELECT_Q
            FROM xxx_zain_ess_valuesets
           WHERE APINAME = 'ZainYesNo';
    
          L_SELECT_Q :=
             REPLACE (L_SELECT_Q, '#PER_PERSON_ID#', '481');
    
          IF MY_STRING IS NOT NULL
          THEN
             FOR CURRENT_ROW
                IN (WITH test AS (SELECT MY_STRING FROM DUAL)
                        SELECT REGEXP_SUBSTR (MY_STRING,
                                              '[^;]+',
                                              1,
                                              ROWNUM)
                                  SPLIT
                          FROM test
                    CONNECT BY LEVEL <=
                                    LENGTH (REGEXP_REPLACE (MY_STRING, '[^;]+'))
                                  + 1)
             LOOP
                l_var :=
                   SUBSTR (CURRENT_ROW.SPLIT,
                           1,
                           INSTR (CURRENT_ROW.SPLIT, '=') - 1);
                l_value :=
                   SUBSTR (
                      CURRENT_ROW.SPLIT,
                      INSTR (CURRENT_ROW.SPLIT, '=') + 1,
                      LENGTH (CURRENT_ROW.SPLIT) - INSTR (CURRENT_ROW.SPLIT, '='));
                L_SELECT_Q := REPLACE (L_SELECT_Q, '#' || l_var || '#', l_value);
             END LOOP;
          END IF;
            
            open my_cur for L_SELECT_Q;
            loop
                fetch my_cur into L_rec;
                exit when my_cur%NOTFOUND;
                L_TB.extend;
                L_TB(L_TB.count) := xxx_zain_ess_LookUp(L_rec.code, L_rec.meaning, L_rec.description);
            end loop;

      RETURN L_TB;
    end;
END;