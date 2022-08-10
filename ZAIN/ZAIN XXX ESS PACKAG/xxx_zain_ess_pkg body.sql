create or replace PACKAGE BODY xxx_zain_ess_pkg
AS

        cursor cur_use_resp(P_PERSON_ID NUMBER) is
            select fnd.user_id , 
                   fresp.responsibility_id, 
                   fresp.application_id 
            from   fnd_user fnd 
            ,      fnd_responsibility_tl fresp 
            where  
    --        fnd.user_name = 'SYSADMIN'
            fnd.employee_id = P_PERSON_ID
            and    fresp.responsibility_name = 'ZAIN HRMS Manager';
        -------------
        cursor cur_sysadmin_resp(P_PERSON_ID NUMBER) is
            select fnd.user_id , 
                   fresp.responsibility_id, 
                   fresp.application_id 
            from   fnd_user fnd 
            ,      fnd_responsibility_tl fresp 
            where  
    --        fnd.user_name = 'SYSADMIN'
            fnd.user_name = 'ESSHRUSER'
            --fnd.employee_id = P_PERSON_ID
--            fnd.user_id = 0
            and    fresp.responsibility_name = 'ZAIN HRMS Manager';
            
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
        
    procedure base64encode
        ( i_blob                        in blob
        , io_clob                       in out nocopy clob )
    is
        l_step                          pls_integer := 12000; -- make sure you set a multiple of 3 not higher than 24573
        l_converted                     clob; --varchar2(32767);
    
        l_buffer_size_approx            pls_integer := 1048576;
        l_buffer                        clob;
    begin
        dbms_lob.createtemporary(l_buffer, true, dbms_lob.call);
    
        for i in 0 .. trunc((dbms_lob.getlength(i_blob) - 1 )/l_step) loop
            l_converted := l_converted || utl_raw.cast_to_varchar2(utl_encode.base64_encode(dbms_lob.substr(i_blob, l_step, i * l_step + 1)));
--            dbms_lob.writeappend(l_buffer, length(l_converted), l_converted);
    
--            if dbms_lob.getlength(l_buffer) >= l_buffer_size_approx then
--                dbms_lob.append(io_clob, l_buffer);
--                dbms_lob.trim(l_buffer, 0);
--            end if;
        end loop;
        
        io_clob := l_converted;
    
--        dbms_lob.append(io_clob, l_buffer);
    
--        dbms_lob.freetemporary(l_buffer);
    end;
    --------------------------
    --------------------------
    
    PROCEDURE      ZAIN_CONCURRENT_PRGM_EXECUTION (
               p_CONC_PRGM_NAME   IN     VARCHAR2,
               p_PERSON_ID        IN     NUMBER,
               p_argument1        IN     VARCHAR2 DEFAULT CHR (0),
               p_argument2        IN     VARCHAR2 DEFAULT CHR (0),
               p_argument3        IN     VARCHAR2 DEFAULT CHR (0),
               p_argument4        IN     VARCHAR2 DEFAULT CHR (0),
               p_argument5        IN     VARCHAR2 DEFAULT CHR (0),
               p_argument6        IN     VARCHAR2 DEFAULT CHR (0),
               p_argument7        IN     VARCHAR2 DEFAULT CHR (0),
               p_argument8        IN     VARCHAR2 DEFAULT CHR (0),
               p_argument9        IN     VARCHAR2 DEFAULT CHR (0),
               p_argument10       IN     VARCHAR2 DEFAULT CHR (0),
               P_URL                 OUT VARCHAR2)
            --  p_file_id             OUT apps.fnd_lobs.file_id%TYPE)
            IS
               lr_row_id              ROWID;
               ln_document_id         NUMBER;
               ln_media_id            NUMBER;
               lb_blob_data           BLOB;
               ln_category_id         NUMBER;
               lb_blob                BLOB;
               lb_bfile               BFILE;
               L_TEMPLATE_NANME       VARCHAR2 (200);
               --  L_URL                  VARCHAR2 (2000);
               L_lifespan             NUMBER := NULL;
               L_authenticate         BOOLEAN := FALSE;
               L_purge_on_view        BOOLEAN := TRUE;
               lc_actual_file_name    VARCHAR2 (200);
               lc_display_file_name   VARCHAR2 (200);
               lc_description         VARCHAR2 (400);
               lb_go                  BOOLEAN := TRUE;
               l_modplsql             BOOLEAN := TRUE;
               ln_count               NUMBER;
               L_PROGRAM_NAME         VARCHAR2 (200);
               lv_request_id          NUMBER;
               lc_phase               VARCHAR2 (50);
               lc_status              VARCHAR2 (50);
               lc_dev_phase           VARCHAR2 (50);
               lc_dev_status          VARCHAR2 (50);
               lc_message             VARCHAR2 (50);
               L_APPL_NAME            VARCHAR2 (10);
               L_GWYUID               VARCHAR2 (256);
               L_TWO_TASK             VARCHAR2 (256);
               L_REP_OUT             VARCHAR2 (256);
               l_req_return_status    BOOLEAN;
               l_boolean              BOOLEAN;
               lc_cp_short_name       apps.fnd_concurrent_programs.concurrent_program_name%TYPE;
               p_file_id              apps.fnd_lobs.file_id%TYPE;
            
                    -------------
                    cursor cur_sysadmin_resp(CP_PERSON_ID NUMBER) is
                        select fnd.user_id , 
                               fresp.responsibility_id, 
                               fresp.application_id 
                        from   fnd_user fnd 
                        ,      fnd_responsibility_tl fresp 
                        where  
                --        fnd.user_name = 'SYSADMIN'
                        --fnd.employee_id = P_PERSON_ID
                        fnd.user_id = 0
                        and    fresp.responsibility_name = 'ZAIN HRMS Manager';
                        ---
                        l_sysadmin_resp cur_sysadmin_resp%rowtype;
            BEGIN
            
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
            
            
               --Setting Context
            
            --   fnd_global.apps_initialize (0, 53182, 800);
            
               --
               --   fnd_global.apps_initialize (
               --      user_id             => fnd_profile.VALUE ('USER_ID'),
               --      resp_id             => fnd_profile.VALUE ('RESP_ID'),
               --      resp_appl_id        => fnd_profile.VALUE ('RESP_APPL_ID'),
               --      security_group_id   => 0);
            
               --
               -- Submitting XX_PROGRAM_1;
            
               --
            
            
               SELECT APPLICATION_SHORT_NAME
                 INTO L_APPL_NAME
                 FROM FND_CONCURRENT_PROGRAMS conc, FND_APPLICATION_VL app
                WHERE     conc.CONCURRENT_PROGRAM_NAME = P_CONC_PRGM_NAME
                      AND app.application_id = conc.APPLICATION_ID
                      AND conc.ENABLED_FLAG = 'Y';
            
            if P_CONC_PRGM_NAME <> 'PAYSAPSL' THEN
               BEGIN
               begin 
                   SELECT TemplatesVlEO.TEMPLATE_CODE, TemplatesVlEO.DEFAULT_OUTPUT_TYPE
                     INTO L_TEMPLATE_NANME, L_REP_OUT
                     FROM XDO_TEMPLATES_VL TemplatesVlEO
                    WHERE     TemplatesVlEO.APPLICATION_SHORT_NAME = L_APPL_NAME
                          AND TemplatesVlEO.DATA_SOURCE_CODE = p_CONC_PRGM_NAME
                          AND TemplatesVlEO.END_DATE IS NULL
                          AND TemplatesVlEO.TEMPLATE_ID =
                                 (SELECT MAX (TEMPLATE_ID)
                                    FROM XDO_TEMPLATES_VL TemplatesVlEO
                                   WHERE     APPLICATION_SHORT_NAME = L_APPL_NAME
                                         AND TemplatesVlEO.DATA_SOURCE_CODE =
                                                p_CONC_PRGM_NAME
                                         AND TemplatesVlEO.END_DATE IS NULL);
                                         exception when others then null;
                                         end;
            
                
                   DBMS_OUTPUT.put_line ('TEMPLATE NAME =====>' || L_TEMPLATE_NANME);
               
               
                  l_boolean :=
                     fnd_request.add_layout (template_appl_name   => L_APPL_NAME,
                                             template_code        => L_TEMPLATE_NANME,
                                             template_language    => 'EN'       -- English
                                                                         ,
                                             template_territory   => NULL,
                                             output_format        => L_REP_OUT);
            
                
            
                  DBMS_OUTPUT.put_line (SQLERRM);
               END;
            
            END If;
            
               lv_request_id :=
                  fnd_request.submit_request (application   => L_APPL_NAME,
                                              program       => P_CONC_PRGM_NAME,
                                              description   => P_CONC_PRGM_NAME,
                                              argument1     => p_argument1,
                                              argument2     => p_argument2,
                                              argument3     => p_argument3,
                                              argument4     => p_argument4,
                                              argument5     => p_argument5,
                                              argument6     => p_argument6,
                                              argument7     => p_argument7,
                                              argument8     => p_argument8,
                                              argument9     => p_argument9,
                                              argument10    => p_argument10,
                                              start_time    => SYSDATE,
                                              sub_request   => FALSE);
               COMMIT;
            
               IF lv_request_id = 0
               THEN
                  DBMS_OUTPUT.put_line (
                     'Request Not Submitted due to "' || fnd_message.get || '".');
               ELSE
                  DBMS_OUTPUT.put_line (
                        'The Program PROGRAM_1 submitted successfully – Request id :'
                     || lv_request_id);
               END IF;
            
               IF lv_request_id > 0
               THEN
                  LOOP
                     --
                     --To make process execution to wait for 1st program to complete
                     --
                     l_req_return_status :=
                        fnd_concurrent.wait_for_request (request_id   => lv_request_id,
                                                         INTERVAL     => 5 --interval Number of seconds to wait between checks
                                                                          ,
                                                         max_wait     => 60 --Maximum number of seconds to wait for the request completion
                                                                           -- out arguments
                                                         ,
                                                         phase        => lc_phase,
                                                         STATUS       => lc_status,
                                                         dev_phase    => lc_dev_phase,
                                                         dev_status   => lc_dev_status,
                                                         MESSAGE      => lc_message);
                     EXIT WHEN    UPPER (lc_phase) = 'COMPLETED'
                               OR UPPER (lc_status) IN ('CANCELLED',
                                                        'ERROR',
                                                        'TERMINATED');
                  END LOOP;
            
                  --
                  --
                  IF UPPER (lc_phase) = 'COMPLETED' AND UPPER (lc_status) = 'ERROR'
                  THEN
                     DBMS_OUTPUT.put_line (
                           'The XX_PROGRAM_1 completed in error. Oracle request id: '
                        || lv_request_id
                        || ' '
                        || SQLERRM);
                  END IF;
               END IF;
            
            
            
               DBMS_OUTPUT.put_line ('AFTER RUNNING REQUEST====>' || lv_request_id);
            
               --
               --Finding CP Short name based on request ID
               --
               SELECT program_short_name, PROGRAM_SHORT_NAME
                 INTO lc_cp_short_name, L_PROGRAM_NAME
                 FROM apps.fnd_conc_req_summary_v
                WHERE 1 = 1 AND request_id = lv_request_id;
            
               lc_actual_file_name := lc_cp_short_name || '_' || lv_request_id || '_1.pdf';
               lc_display_file_name :=
                  lc_cp_short_name || '_' || lv_request_id || '_1.pdf';
            
               --
               DBMS_OUTPUT.put_line ('lc_actual_file_name: ' || lc_actual_file_name);
               DBMS_OUTPUT.put_line ('lc_display_file_name: ' || lc_display_file_name);
            
               --
--               BEGIN
--                  SELECT CATEGORY_ID
--                    INTO ln_category_id
--                    FROM apps.fnd_document_categories_tl
--                   WHERE user_name = L_PROGRAM_NAME AND LANGUAGE = USERENV ('lang');
--               EXCEPTION
--                  WHEN OTHERS
--                  THEN
--                     --
--                     lb_go := FALSE;
--                     p_file_id := -1;
--                     DBMS_OUTPUT.put_line (
--                        'Error While Deriving Document Category ' || SQLERRM);
--               --
--               END;
            
               --
               --Create a FND DOCUMENT
               --
               BEGIN
                  DBMS_OUTPUT.put_line ('FND_DOCUMENTS_PKG.INSERT_ROW Call');
                  apps.fnd_documents_pkg.insert_row (
                     x_rowid                    => lr_row_id,
                     x_document_id              => ln_document_id,
                     x_creation_date            => SYSDATE,
                     x_created_by               => fnd_global.user_id,
                     x_last_update_date         => SYSDATE,
                     x_last_updated_by          => fnd_global.user_id,
                     x_last_update_login        => fnd_global.user_id,
                     x_datatype_id              => 6,
                     --Indicates BLOB type of data
                     x_category_id              => 1000504, --ln_category_id,
                     x_security_type            => 1,
                     x_publish_flag             => 'Y',
                     x_usage_type               => 'S',
                     x_start_date_active        => SYSDATE,
                     x_request_id               => fnd_global.conc_request_id,
                     x_program_application_id   => fnd_global.prog_appl_id,
                     x_program_update_date      => SYSDATE,
                     x_language                 => fnd_global.current_language,
                     x_description              => lc_description,
                     x_file_name                => lc_display_file_name,
                     x_media_id                 => ln_media_id);
                  DBMS_OUTPUT.put_line ('file_id: ' || ln_media_id);
                  --Setting out parameter p_file_id
                  p_file_id := ln_media_id;
                  COMMIT;
               --
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     lb_go := FALSE;
                     p_file_id := -1;
                     DBMS_OUTPUT.put_line (
                        'Error during FND_DOCUMENTS_PKG.INSERT_ROW Call ' || SQLERRM);
               END;
            
            
            
               --
               --Creating Empty BLOB with reference to the above ceated document
               --
               BEGIN
                  lb_blob_data := EMPTY_BLOB ();
                  DBMS_OUTPUT.put_line ('Inserting to FND LOBS');
            
                  INSERT INTO apps.fnd_lobs (file_id,
                                             file_name,
                                             file_content_type,
                                             upload_date,
                                             expiration_date,
                                             program_name,
                                             program_tag,
                                             file_data,
                                             LANGUAGE,
                                             oracle_charset,
                                             file_format)
                       VALUES (ln_media_id,
                               lc_display_file_name,
                               'application/octet-stream',
                               SYSDATE,
                               NULL,
                               'FNDATTCH',
                               NULL,
                               lb_blob_data,
                               fnd_global.current_language,
                               NULL,
                               'binary')
                    RETURNING file_data
                         INTO lb_blob;
            
                  COMMIT;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     lb_go := FALSE;
                     p_file_id := -1;
                     DBMS_OUTPUT.put_line (
                        'Error during Insert into FND_LOBS ' || SQLERRM);
               END;
            
            
               SELECT profile_option_value
                 INTO L_GWYUID
                 FROM FND_PROFILe_OPTIONS o, FND_PROFILE_OPTION_VALUES ov
                WHERE     PROFILE_OPTION_NAME = 'GWYUID'
                      AND o.application_id = ov.application_id
                      AND o.profile_option_id = ov.profile_option_id;
            
               SELECT profile_option_value
                 INTO L_TWO_TASK
                 FROM FND_PROFILe_OPTIONS o, FND_PROFILE_OPTION_VALUES ov
                WHERE     PROFILE_OPTION_NAME = 'TWO_TASK'
                      AND o.application_id = ov.application_id
                      AND o.profile_option_id = ov.profile_option_id;
            
            
               SELECT fnd_webfile.get_url (file_type     => 4,             -- for out file
                                           ID            => lv_request_id,
                                           gwyuid        => L_GWYUID,
                                           two_task      => L_TWO_TASK,
                                           expire_time   => 500     -- minutes, security!.
                                                               )
                 INTO P_URL
                 FROM DUAL;
            
            
               --  p_file_id := P_URL;
               --   --
               --   BEGIN
               --      --
               --      --Loading physical file to LOBS table as a BLOB
               --      --
               --      DBMS_OUTPUT.put_line ('Loading File to Lobs');
               --      --
               --      --Getting a pointer for Physical file
               --      --
               --      lb_bfile := BFILENAME ('ZAIN_CONC', lc_actual_file_name);
               --      --
               --      --Open the file with the pointer returned above
               --
               --      DBMS_OUTPUT.put_line (
               --         'Reading file from directory ' || lc_actual_file_name);
               --      --
               --      DBMS_LOB.fileopen (lb_bfile);
               --      --
               --      --load the file from disk to the table directly using lb_blob created in previous insert statement
               --      --
               --      DBMS_LOB.loadfromfile (lb_blob,
               --                             lb_bfile,
               --                             DBMS_LOB.getlength (lb_bfile));
               --      --
               --      --close the file after storing it in the table
               --      --
               --      DBMS_LOB.fileclose (lb_bfile);
               --
               --      DBMS_OUTPUT.put_line (DBMS_LOB.getlength (lb_bfile));
               --   --
               --   EXCEPTION
               --      WHEN OTHERS
               --      THEN
               --         DBMS_OUTPUT.put_line (
               --               'There is no such File or Directory..File Name : '
               --            || lc_actual_file_name
               --            || ' Error : '
               --            || SQLERRM);
               --         --
               --         ROLLBACK;
               --   END;
            
               --
               COMMIT;
            --
        END;
    
   ---------------------------
   ---------------------------
    PROCEDURE GENERATE_VALUSET_VALS(
            ---- IN ----
            P_VALUESET_NAME IN VARCHAR2, 
            P_PERSON_ID NUMBER default null,
            P_REQUEST_MODE VARCHAR2 default null,
            P_Q_STRING VARCHAR2 default null,
            P_OFFSET NUMBER default null,
            P_LIMIT NUMBER default null,
            P_ORDER_BY VARCHAR2 default null,
            ---- OUT ----
            P_VALUESET_VALS OUT CLOB
        )
    IS
            L_SELECT_Q xxx_zain_ess_valuesets.select_query%type;
            ------
            MY_STRING VARCHAR2(2000) := P_Q_STRING;
            l_var varchar2(50);
            l_value varchar2(100);
            my_cur sys_refcursor;
            type v_vs_type is RECORD (code varchar2(100),meaning varchar2(150), description varchar2(200));
            v_rec_dtl v_vs_type;
            -----
            l_json_resp clob;
    BEGIN
            select distinct(select_query) into L_SELECT_Q from xxx_zain_ess_valuesets
            where APINAME = P_VALUESET_NAME;

            L_SELECT_Q := replace(L_SELECT_Q, '#PER_PERSON_ID#', to_char(P_PERSON_ID));

            if MY_STRING is not null then
              FOR CURRENT_ROW IN (
                with test as    
                  (select MY_STRING from dual)
                  select regexp_substr(MY_STRING, '[^;]+', 1, rownum) SPLIT
                  from test
                  connect by level <= length (regexp_replace(MY_STRING, '[^;]+'))  + 1)
              LOOP
                l_var := SUBSTR(CURRENT_ROW.SPLIT,1,instr(CURRENT_ROW.SPLIT, '=')-1);
                l_value := SUBSTR(CURRENT_ROW.SPLIT, 
                                instr(CURRENT_ROW.SPLIT, '=')+1, 
                                LENGTH(CURRENT_ROW.SPLIT)-instr(CURRENT_ROW.SPLIT, '=')
                              );
                L_SELECT_Q := replace(L_SELECT_Q, '#'||l_var||'#', l_value);
              END LOOP;
            end if;

            APEX_JSON.initialize_clob_output;
            APEX_JSON.open_object;
            APEX_JSON.open_array('items');

            open my_cur for L_SELECT_Q;
            loop
                fetch my_cur into v_rec_dtl;
                exit when my_cur%NOTFOUND;
                --DBMS_OUTPUT.PUT_LINE(v_rec_dtl.code);
                APEX_JSON.open_object;
--                l_json_resp := l_json_resp || '{"code": "'||v_rec_dtl.code||'", "meaning": "'||v_rec_dtl.meaning||'", "description": "'||v_rec_dtl.description||'"}, ';
                APEX_JSON.write('code', v_rec_dtl.code);
                APEX_JSON.write('meaning', v_rec_dtl.meaning);
                APEX_JSON.write('description', v_rec_dtl.description);
                APEX_JSON.close_object;
            end loop;

--            l_json_resp := '{"items": [' || substr(l_json_resp, 1, length(l_json_resp)-2) || ']}';

            APEX_JSON.close_array;
            APEX_JSON.close_object;
            DBMS_OUTPUT.put_line(APEX_JSON.get_clob_output);
            l_json_resp := APEX_JSON.get_clob_output;
            APEX_JSON.free_output;

            P_VALUESET_VALS := l_json_resp;
    END;

    FUNCTION GET_CNTXT_DATA_SAMPLE (
            P_REQUEST_TYPE IN VARCHAR2 default null,
            P_REQUESTER_ID NUMBER default null,
            P_PERSON_ID IN NUMBER default null,
            P_REQUEST_MODE VARCHAR2 default null,
            P_Q_STRING VARCHAR2 default null,
            P_OFFSET NUMBER default null,
            P_LIMIT NUMBER default null,
            P_ORDER_BY VARCHAR2 default null
        ) return clob
    IS
        v_query_string CLOB;
        l_cursor_id integer;
        L_DescTab   DBMS_SQL.desc_tab;
        L_COL_Count   NUMBER;
        L_VARCHAR_COL VARCHAR2(2000);
        L_NUMBER_COL    NUMBER;
        L_DATE_COL      DATE;
        L_CLOB_COL      CLOB;
        L_RET           NUMBER;
        L_RET_CLOB      CLOB;
        ---
        ------ Select Query Initialization ------
        cursor cur_ent_queries is
            select rt.request_type, eq.entity_key, eq.entity_query, eq.COLS_FILTER
            from xxx_zain_ess_entity_queries eq
            join xxx_zain_ess_req_types rt
            on (eq.entity_key = rt.entity_key)
            where rt.request_type = P_REQUEST_TYPE;
        -------------        
        L_COLS_FILTER VARCHAR2(1000);
        L_Q_STR VARCHAR2(1000) := P_Q_STRING;
        L_Q_FILTER VARCHAR2(1000) := '';
        ---
        l_var varchar2(50);
        l_value varchar2(100);
    begin
        if P_REQUEST_TYPE is null then
            return 'Please provide the Request Type!';
        end if;
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        for ent_q in cur_ent_queries loop
            -----------------------------------------------------
            -----------------------------------------------------
              IF L_Q_STR IS NOT NULL THEN
                  L_COLS_FILTER := ent_q.COLS_FILTER;
                  FOR C_ROW IN (
                    with test as    
                      (select L_Q_STR from dual)
                      select regexp_substr(L_Q_STR, '[^;]+', 1, rownum) SPLIT
                      from test
                      connect by level <= length (regexp_replace(L_Q_STR, '[^;]+'))  + 1)
                  LOOP
                        l_var := SUBSTR(C_ROW.SPLIT,1,instr(C_ROW.SPLIT, '=')-1);
                        l_value := SUBSTR(C_ROW.SPLIT, 
                                        instr(C_ROW.SPLIT, '=')+1, 
                                        LENGTH(C_ROW.SPLIT)-instr(C_ROW.SPLIT, '=')
                                      );
                          -------------
                          IF LOWER(L_COLS_FILTER) LIKE '%'||LOWER(l_var)||'%' THEN
                              FOR CURRENT_ROW IN (
                                with test as    
                                  (select L_COLS_FILTER from dual)
                                  select regexp_substr(L_COLS_FILTER, '[^|]+', 1, rownum) SPLIT
                                  from test
                                  connect by level <= length (regexp_replace(L_COLS_FILTER, '[^|]+'))  + 1)
                              LOOP
                                IF LOWER(CURRENT_ROW.SPLIT) LIKE '%'||LOWER(l_var)||'%' THEN
                                    L_Q_FILTER := L_Q_FILTER || ' AND ' || CURRENT_ROW.SPLIT || ' = ' || l_value;
                                END IF;
                              END LOOP;
                          END IF;
                          -------------
                  END LOOP;
                  DBMS_OUTPUT.PUT_LINE(L_Q_FILTER);
              END IF;
            -----------------------------------------------------
            -----------------------------------------------------
            ------ Select Query Manipulation ------
            v_query_string := ent_q.entity_query ||
--                                case when P_PERSON_ID is not null then ' and person_id = #PER_PERSON_ID#' else '' end ||
                                case when L_Q_FILTER is not null then L_Q_FILTER else '' end ||
                                case when P_LIMIT is not null then ' and rownum < '||to_char(P_LIMIT) else ' and rownum < 25' end
                                ;
            v_query_string := replace(v_query_string, '#PER_PERSON_ID#', to_char(P_PERSON_ID));
            ---
            l_cursor_id := DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(l_cursor_id, v_query_string,DBMS_SQL.NATIVE);
            DBMS_SQL.DESCRIBE_COLUMNS (l_cursor_id, L_COL_Count, L_DescTab);
            ---
            FOR I IN 1 .. L_COL_Count LOOP
                IF (L_DescTab (I).col_type = 2) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_NUMBER_COL);
                ELSIF (L_DescTab (I).col_type = 12) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_DATE_COL);
                ELSIF (L_DescTab (I).col_type = 112) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_CLOB_COL);
                ELSE
                    DBMS_SQL.define_column (l_cursor_id,I,L_VARCHAR_COL,2000);
                END IF;
            END LOOP;
            ---
            L_RET:=DBMS_SQL.execute (l_cursor_id);
            ---
            APEX_JSON.open_array(ent_q.entity_key);
            ---
            loop
                --FITCH ROW
                L_RET:=DBMS_SQL.fetch_rows (l_cursor_id);
                exit when L_RET = 0;
                APEX_JSON.open_object;
                ---
                FOR i IN 1..l_col_count LOOP 
                    IF (L_DescTab (I).col_type = 2) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I, L_NUMBER_COL);
                        --dbms_output.put_line(L_NUMBER_COL); --L_DescTab (I).col_NAME,
                        if L_NUMBER_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_NUMBER_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
                    ELSIF (L_DescTab (I).col_type = 12) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_DATE_COL);
        --                dbms_output.put_line(L_DATE_COL);
                        if L_DATE_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_DATE_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
                    ELSIF (L_DescTab (I).col_type = 112) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_CLOB_COL);
        --                dbms_output.put_line(L_CLOB_COL);
                        if L_DATE_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_CLOB_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
                    ELSE
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_VARCHAR_COL);
        --                dbms_output.put_line(L_VARCHAR_COL);
                        if L_VARCHAR_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_VARCHAR_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
                    END IF;
                END LOOP;
                ---
                APEX_JSON.close_object;
            end loop;
            ---
            APEX_JSON.close_array;
            --
            DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
        end loop;
        ---
        APEX_JSON.close_object;
--        DBMS_OUTPUT.put_line(APEX_JSON.get_clob_output);
        L_RET_CLOB := APEX_JSON.get_clob_output;
        APEX_JSON.free_output;
        ---
        L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
        ---
        RETURN L_RET_CLOB;
    end;

    FUNCTION GET_PERSON_IMAGE (P_PERSON_ID IN NUMBER) RETURN CLOB
    IS
        l_response clob;
        l_img clob;
    begin
        select replace(replace(apex_web_service.blob2clobbase64(image), chr(13), ''), chr(10), '') image into l_img
            from 
                per_images img
            where
                parent_id = P_PERSON_ID
            ;
        l_response := '{"personId": '||to_char(P_PERSON_ID)||', "imageData": "'||l_img||'"}';
        return l_response ;
    end;

    FUNCTION GET_USER_INFO (P_USER_NAME IN VARCHAR2 default null, 
                            P_EMAIL IN VARCHAR2 default null, 
                            P_EMP_NUMBER IN VARCHAR2 default null,
                            P_Q_STR IN VARCHAR2 default null) RETURN CLOB
    IS
        v_query_string CLOB;
        l_cursor_id integer;
        L_DescTab   DBMS_SQL.desc_tab;
        L_COL_Count   NUMBER;
        L_VARCHAR_COL VARCHAR2(2000);
        L_NUMBER_COL    NUMBER;
        L_DATE_COL      DATE;
        L_CLOB_COL      CLOB;
        L_RET           NUMBER;
        L_RET_CLOB      CLOB;
        ---
        L_Q_STR varchar2(1000) := P_Q_STR;
        L_Q_FILTER VARCHAR2(1000) := '';
        L_COLS_FILTER VARCHAR2(1000);
        ---
        l_operator varchar2(20);
        l_op_val varchar2(200);
        l_var varchar2(50);
        l_value varchar2(100);
        ---
        ------ Select Query Initialization ------
        cursor cur_ent_queries is
            select rt.request_type, eq.entity_key, eq.entity_query, eq.COLS_FILTER
            from xxx_zain_ess_entity_queries eq
            join xxx_zain_ess_req_types rt
            on (eq.entity_key = rt.entity_key)
            where rt.request_type = 'getUserInfo';
        -------------   
    BEGIN
        if P_USER_NAME is null and P_EMAIL is null and P_EMP_NUMBER is null and L_Q_STR is null then
            return 'Please provide Username or Email or Person Number!';
        end if;
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
--        L_RET_CLOB := '{';
        for ent_q in cur_ent_queries loop
            ------ Select Query Manipulation ------
            v_query_string := ent_q.entity_query;
            if P_USER_NAME is not null then
                v_query_string := replace(v_query_string, '#USER_NAME#', ''''||P_USER_NAME||'''');
            else
                v_query_string := replace(v_query_string, '#USER_NAME#', 'NULL');
            end if;
            if P_EMAIL is not null then
                v_query_string := replace(v_query_string, '#EMAIL_ADDRESS#', ''''||P_EMAIL||'''');
            else
                v_query_string := replace(v_query_string, '#EMAIL_ADDRESS#', 'NULL');
            end if;
            if P_EMP_NUMBER is not null then
                v_query_string := replace(v_query_string, '#EMPLOYEE_NUMBER#', ''''||P_EMP_NUMBER||'''');
            else
                v_query_string := replace(v_query_string, '#EMPLOYEE_NUMBER#', 'NULL');
            end if;
            ---
            
            IF L_Q_STR IS NOT NULL THEN
                  L_COLS_FILTER := ent_q.COLS_FILTER;
                  FOR C_ROW IN (
                    with test as    
                      (select L_Q_STR from dual)
                      select regexp_substr(L_Q_STR, '[^;]+', 1, rownum) SPLIT
                      from test
                      connect by level <= length (regexp_replace(L_Q_STR, '[^;]+'))  + 1)
                  LOOP
                        if C_ROW.SPLIT like '%=%' then
                            l_operator := '=';
                        end if;
                        if C_ROW.SPLIT like '%!=%' then
                            l_operator := '!=';
                        end if;
                        if C_ROW.SPLIT like '%>%' then
                            l_operator := '>';
                        end if;
                        if C_ROW.SPLIT like '%<%' then
                            l_operator := '<';
                        end if;
                        if C_ROW.SPLIT like '%>=%' then
                            l_operator := '>=';
                        end if;
                        if C_ROW.SPLIT like '%<=%' then
                            l_operator := '<=';
                        end if;
                        if C_ROW.SPLIT like '% sw %' then
                            l_operator := ' sw ';
                        end if;
                        if C_ROW.SPLIT like '% ew %' then
                            l_operator := ' ew ';
                        end if;
                        if C_ROW.SPLIT like '% co %' then
                            l_operator := ' co ';
                        end if;
                        ---
                        l_var := SUBSTR(C_ROW.SPLIT,1,instr(C_ROW.SPLIT, l_operator)-1);
                        l_value := SUBSTR(C_ROW.SPLIT, 
                                        instr(C_ROW.SPLIT, l_operator)+length(l_operator), 
                                        LENGTH(C_ROW.SPLIT)-(instr(C_ROW.SPLIT, l_operator)+(length(l_operator)-1))
                                      );
                        ---
                        if C_ROW.SPLIT like '%=%' then
                            l_op_val := '= ' || l_value;
                        end if;
                        if C_ROW.SPLIT like '%!=%' then
                            l_op_val := '!= ' || l_value;
                        end if;
                        if C_ROW.SPLIT like '%>%' then
                            l_op_val := '> ' || l_value;
                        end if;
                        if C_ROW.SPLIT like '%<%' then
                            l_op_val := '< ' || l_value;
                        end if;
                        if C_ROW.SPLIT like '%>=%' then
                            l_op_val := '>= ' || l_value;
                        end if;
                        if C_ROW.SPLIT like '%<=%' then
                            l_op_val := '<= ' || l_value;
                        end if;
                        if C_ROW.SPLIT like '% sw %' then
                            l_op_val := 'like lower('''||substr(l_value, 2, length(l_value)-2)||'%'')';
                        end if;
                        if C_ROW.SPLIT like '% ew %' then
                            l_op_val := 'like lower(''%'||substr(l_value, 2, length(l_value)-2)||''')';
                        end if;
                        if C_ROW.SPLIT like '% co %' then
                            l_op_val := 'like lower(''%'||substr(l_value, 2, length(l_value)-2)||'%'')';
                        end if;
                        -------------
                          IF LOWER(L_COLS_FILTER) LIKE '%'||LOWER(l_var)||'%' THEN
                              FOR CURRENT_ROW IN (
                                with test as    
                                  (select L_COLS_FILTER from dual)
                                  select regexp_substr(L_COLS_FILTER, '[^|]+', 1, rownum) SPLIT
                                  from test
                                  connect by level <= length (regexp_replace(L_COLS_FILTER, '[^|]+'))  + 1)
                              LOOP
                                IF LOWER(CURRENT_ROW.SPLIT) LIKE '%'||LOWER(l_var)||'%' THEN
                                    if l_operator like '% sw %' or l_operator like '% ew %' or l_operator like '% co %' THEN
--                                        L_Q_FILTER := L_Q_FILTER || ' AND lower(' || CURRENT_ROW.SPLIT || ') '||l_op_val;
                                        L_Q_FILTER := L_Q_FILTER || ' lower(' || CURRENT_ROW.SPLIT || ') '||l_op_val || ' OR';
                                    else
--                                        L_Q_FILTER := L_Q_FILTER || ' AND ' || CURRENT_ROW.SPLIT || ' '||l_op_val;
                                        L_Q_FILTER := L_Q_FILTER || ' ' || CURRENT_ROW.SPLIT || ' '||l_op_val || ' OR';
                                    end if;
                                END IF;
                              END LOOP;
                          END IF;
                          -------------
                  END LOOP;
                  DBMS_OUTPUT.PUT_LINE(L_Q_FILTER);
                  L_Q_FILTER := ' AND (' || substr(L_Q_FILTER, 0, length(L_Q_FILTER)-2) || ')'; --  AND ROWNUM <= 22
                  DBMS_OUTPUT.PUT_LINE(L_Q_FILTER);
              END IF;
            -------
            v_query_string := v_query_string || case when L_Q_FILTER is not null then L_Q_FILTER else '' end;
            -------
            l_cursor_id := DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(l_cursor_id, v_query_string,DBMS_SQL.NATIVE);
            DBMS_SQL.DESCRIBE_COLUMNS (l_cursor_id, L_COL_Count, L_DescTab);
            ---
            FOR I IN 1 .. L_COL_Count LOOP
                IF (L_DescTab (I).col_type = 2) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_NUMBER_COL);
                ELSIF (L_DescTab (I).col_type = 12) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_DATE_COL);
                ELSIF (L_DescTab (I).col_type = 112) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_CLOB_COL);
                ELSE
                    DBMS_SQL.define_column (l_cursor_id,I,L_VARCHAR_COL,2000);
                END IF;
            END LOOP;
            ---
            L_RET:=DBMS_SQL.execute (l_cursor_id);
            ---
            APEX_JSON.open_array(ent_q.entity_key);
--            L_RET_CLOB := L_RET_CLOB || '"'||ent_q.entity_key||'": [';
            ---
            loop
                --FITCH ROW
                L_RET:=DBMS_SQL.fetch_rows (l_cursor_id);
                exit when L_RET = 0;
                APEX_JSON.open_object;
--                L_RET_CLOB := L_RET_CLOB || '{';
                ---
                FOR I IN 1 .. L_COL_Count LOOP
                    IF (L_DescTab (I).col_type = 2) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I, L_NUMBER_COL);
                        --dbms_output.put_line(L_NUMBER_COL); --L_DescTab (I).col_NAME,
                        if L_NUMBER_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_NUMBER_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
--                        L_RET_CLOB := L_RET_CLOB || '"'||L_DescTab (I).col_NAME||'": ' || nvl(to_char(L_NUMBER_COL), 'null') || ',';
                    ELSIF (L_DescTab (I).col_type = 12) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_DATE_COL);
        --                dbms_output.put_line(L_DATE_COL);
                        if L_DATE_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_DATE_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
--                        L_RET_CLOB := L_RET_CLOB || '"'||L_DescTab (I).col_NAME||'": ' || case when L_DATE_COL is not null then '"'|| L_DATE_COL || '",' else 'null,' end;
                    ELSIF (L_DescTab (I).col_type = 112) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_CLOB_COL);
        --                dbms_output.put_line(L_CLOB_COL);
                        if L_CLOB_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_CLOB_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
--                        L_RET_CLOB := L_RET_CLOB || '"'||L_DescTab (I).col_NAME||'": ' || case when L_CLOB_COL is not null then '"'|| convert(L_CLOB_COL, 'AL32UTF8', 'WE8ISO8859P15') || '",' else 'null,' end;
                    ELSE
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_VARCHAR_COL);
        --                dbms_output.put_line(L_VARCHAR_COL);
                        if L_VARCHAR_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_VARCHAR_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
--                        L_RET_CLOB := L_RET_CLOB || '"'||L_DescTab (I).col_NAME||'": ' || case when L_VARCHAR_COL is not null then '"'|| convert(L_VARCHAR_COL, 'AL32UTF8', 'WE8ISO8859P15') || '",' else 'null,' end;
                    END IF;
                END LOOP;
                ---
                APEX_JSON.close_object;
--                L_RET_CLOB := substr(L_RET_CLOB, 0, length(L_RET_CLOB)-1) || '}';
            end loop;
            ---
            APEX_JSON.close_array;
--            L_RET_CLOB := L_RET_CLOB || ']';
            --
            DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
        end loop;
        ---
        APEX_JSON.close_object;
--        L_RET_CLOB := L_RET_CLOB || '}';
--        DBMS_OUTPUT.put_line(APEX_JSON.get_clob_output);
        L_RET_CLOB := APEX_JSON.get_clob_output;
        APEX_JSON.free_output;
        ---
        L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
        ---
        RETURN L_RET_CLOB;
    END;

    FUNCTION GET_EMPLOYEE_INFO (
            P_REQUESTER_PERSON_ID NUMBER default null,
            P_PERSON_ID IN NUMBER default null,
            P_OFFSET NUMBER default null,
            P_LIMIT NUMBER default null,
            P_ORDER_BY VARCHAR2 default null) RETURN CLOB
    IS
        v_query_string CLOB;
        l_cursor_id integer;
        L_DescTab   DBMS_SQL.desc_tab;
        L_COL_Count   NUMBER;
        L_VARCHAR_COL VARCHAR2(2000);
        L_NUMBER_COL    NUMBER;
        L_DATE_COL      DATE;
        L_CLOB_COL      CLOB;
        L_RET           NUMBER;
        L_RET_CLOB      CLOB;
        ---
        ------ Select Query Initialization ------
        cursor cur_ent_queries is
            select rt.request_type, eq.entity_key, eq.entity_query, eq.COLS_FILTER
            from xxx_zain_ess_entity_queries eq
            join xxx_zain_ess_req_types rt
            on (eq.entity_key = rt.entity_key)
            where rt.request_type = 'getEmployeeInfo';
        -------------   
    BEGIN
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        for ent_q in cur_ent_queries loop
            ------ Select Query Manipulation ------
            v_query_string := ent_q.entity_query;
            if P_PERSON_ID is not null then
                v_query_string := replace(v_query_string, '#PERSON_ID#', P_PERSON_ID);
                v_query_string := replace(v_query_string, '#REQUESTER_ID#', 'NULL');
            else
                v_query_string := replace(v_query_string, '#PERSON_ID#', 'NULL');
                v_query_string := replace(v_query_string, '#REQUESTER_ID#', P_REQUESTER_PERSON_ID);
            end if;
            if P_LIMIT is not null then
                v_query_string := replace(v_query_string, '#LIMIT#', P_LIMIT);
            else
                v_query_string := replace(v_query_string, '#LIMIT#', 'NULL');
            end if;
            dbms_output.put_line(v_query_string);
            ---
            l_cursor_id := DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(l_cursor_id, v_query_string,DBMS_SQL.NATIVE);
            DBMS_SQL.DESCRIBE_COLUMNS (l_cursor_id, L_COL_Count, L_DescTab);
            ---
            FOR I IN 1 .. L_COL_Count LOOP
                IF (L_DescTab (I).col_type = 2) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_NUMBER_COL);
                ELSIF (L_DescTab (I).col_type = 12) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_DATE_COL);
                ELSIF (L_DescTab (I).col_type = 112) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_CLOB_COL);
                ELSE
                    DBMS_SQL.define_column (l_cursor_id,I,L_VARCHAR_COL,2000);
                END IF;
            END LOOP;
            ---
            L_RET:=DBMS_SQL.execute (l_cursor_id);
            ---
            APEX_JSON.open_array(ent_q.entity_key);
            ---
            loop
                --FITCH ROW
                L_RET:=DBMS_SQL.fetch_rows (l_cursor_id);
                exit when L_RET = 0;
                APEX_JSON.open_object;
                ---
                FOR I IN 1 .. L_COL_Count LOOP
                    IF (L_DescTab (I).col_type = 2) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I, L_NUMBER_COL);
                        --dbms_output.put_line(L_NUMBER_COL); --L_DescTab (I).col_NAME,
                        APEX_JSON.write(L_DescTab (I).col_NAME, L_NUMBER_COL);
                    ELSIF (L_DescTab (I).col_type = 12) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_DATE_COL);
        --                dbms_output.put_line(L_DATE_COL);
                        APEX_JSON.write(L_DescTab (I).col_NAME, L_DATE_COL);
                    ELSIF (L_DescTab (I).col_type = 112) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_CLOB_COL);
        --                dbms_output.put_line(L_DATE_COL);
                        APEX_JSON.write(L_DescTab (I).col_NAME, L_CLOB_COL);
                    ELSE
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_VARCHAR_COL);
        --                dbms_output.put_line(L_VARCHAR_COL);
                        APEX_JSON.write(L_DescTab (I).col_NAME, L_VARCHAR_COL);
                    END IF;
                END LOOP;
                ---
                APEX_JSON.close_object;
            end loop;
            ---
            APEX_JSON.close_array;
            --
            DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
        end loop;
        ---
        APEX_JSON.close_object;
--        DBMS_OUTPUT.put_line(APEX_JSON.get_clob_output);
        L_RET_CLOB := APEX_JSON.get_clob_output;
        APEX_JSON.free_output;
        ---
        RETURN L_RET_CLOB;
    END;

    FUNCTION GET_LEAVE_DURATION (P_PERSON_ID IN NUMBER default null, P_LEAVE_TYPE IN VARCHAR2 default null, P_START_DATE IN DATE default null, P_END_DATE IN DATE default null)
    RETURN VARCHAR2
    IS
          l_person_id number := P_PERSON_ID;
          l_absence_type varchar2(100) := P_LEAVE_TYPE;
          l_date_start date := P_START_DATE;
          l_date_end date := P_END_DATE;
          v_absence_attendance_type_id   NUMBER;
          io_absence_days                NUMBER;
          --
          cursor cur_assmt_info is
            select assignment_id from per_all_assignments_f
            where person_id = l_person_id
            and sysdate between effective_start_date and effective_end_date;
          --
          assmt_rec_dtl cur_assmt_info%rowtype;
    BEGIN
       open cur_assmt_info;
       fetch cur_assmt_info into assmt_rec_dtl;
       close cur_assmt_info;
       ---------
       select ABSENCE_ATTENDANCE_TYPE_ID into v_absence_attendance_type_id
        FROM per_absence_attendance_types
        where name = l_absence_type;
       ---------
       io_absence_days := XX_ZAIN_OCI_PKG.LEAVE_DURATION(assmt_rec_dtl.assignment_id,l_date_start, l_date_end, v_absence_attendance_type_id);
        ----------
        if io_absence_days = 0.5 then
            RETURN '{"numberOfDays": '|| to_char(io_absence_days, '0D9') ||'}';
        end if;
        ----------
        RETURN '{"numberOfDays": '|| io_absence_days ||'}';
    END;

    FUNCTION GET_EMPLOYEE_ABS_HIST (
            P_PERSON_ID IN NUMBER default null,
            P_ABSENCE_TYPE IN VARCHAR2 default null,
            P_DATE_START IN DATE default null,
            P_DATE_END IN DATE default null,
            P_OFFSET NUMBER default null,
            P_LIMIT NUMBER default null,
            P_ORDER_BY VARCHAR2 default null) RETURN CLOB
    is
        v_query_string CLOB;
        l_cursor_id integer;
        L_DescTab   DBMS_SQL.desc_tab;
        L_COL_Count   NUMBER;
        L_VARCHAR_COL VARCHAR2(2000);
        L_NUMBER_COL    NUMBER;
        L_DATE_COL      DATE;
        L_CLOB_COL      CLOB;
        L_RET           NUMBER;
        L_RET_CLOB      CLOB;
        ---
        ------ Select Query Initialization ------
        cursor cur_ent_queries is
            select rt.request_type, eq.entity_key, eq.entity_query, eq.COLS_FILTER
            from xxx_zain_ess_entity_queries eq
            join xxx_zain_ess_req_types rt
            on (eq.entity_key = rt.entity_key)
            where rt.request_type = 'ZainEmpAbsHistory';
        -------------   
    BEGIN
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        for ent_q in cur_ent_queries loop
            ------ Select Query Manipulation ------
            v_query_string := ent_q.entity_query;
            if P_PERSON_ID is not null then
                v_query_string := replace(v_query_string, '#PERSON_ID#', P_PERSON_ID);
            else
                v_query_string := replace(v_query_string, '#PERSON_ID#', 'NULL');
            end if;
            if P_ABSENCE_TYPE is not null then
                v_query_string := replace(v_query_string, '#ABSENCE_TYPE#', ''''||P_ABSENCE_TYPE||'''');
            else
                v_query_string := replace(v_query_string, '#ABSENCE_TYPE#', 'NULL');
            end if;
            if P_DATE_START is not null then
                v_query_string := replace(v_query_string, '#DATE_START#', ''''||P_DATE_START||'''');
            else
                v_query_string := replace(v_query_string, '#DATE_START#', 'NULL');
            end if;
            if P_DATE_END is not null then
                v_query_string := replace(v_query_string, '#DATE_END#', ''''||P_DATE_END||'''');
            else
                v_query_string := replace(v_query_string, '#DATE_END#', 'NULL');
            end if;
            if P_LIMIT is not null then
                v_query_string := replace(v_query_string, '#LIMIT#', P_LIMIT);
            else
                v_query_string := replace(v_query_string, '#LIMIT#', 'NULL');
            end if;
            dbms_output.put_line(v_query_string);
            ---
            l_cursor_id := DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(l_cursor_id, v_query_string,DBMS_SQL.NATIVE);
            DBMS_SQL.DESCRIBE_COLUMNS (l_cursor_id, L_COL_Count, L_DescTab);
            ---
            FOR I IN 1 .. L_COL_Count LOOP
                IF (L_DescTab (I).col_type = 2) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_NUMBER_COL);
                ELSIF (L_DescTab (I).col_type = 12) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_DATE_COL);
                ELSIF (L_DescTab (I).col_type = 112) THEN
                    DBMS_SQL.define_column (l_cursor_id,I,L_CLOB_COL);
                ELSE
                    DBMS_SQL.define_column (l_cursor_id,I,L_VARCHAR_COL,2000);
                END IF;
            END LOOP;
            ---
            L_RET:=DBMS_SQL.execute (l_cursor_id);
            ---
            APEX_JSON.open_array(ent_q.entity_key);
            ---
            loop
                --FITCH ROW
                L_RET:=DBMS_SQL.fetch_rows (l_cursor_id);
                exit when L_RET = 0;
                APEX_JSON.open_object;
                ---
                FOR I IN 1 .. L_COL_Count LOOP
                    IF (L_DescTab (I).col_type = 2) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I, L_NUMBER_COL);
                        --dbms_output.put_line(L_NUMBER_COL); --L_DescTab (I).col_NAME,
                        APEX_JSON.write(L_DescTab (I).col_NAME, L_NUMBER_COL);
                    ELSIF (L_DescTab (I).col_type = 12) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_DATE_COL);
        --                dbms_output.put_line(L_DATE_COL);
                        APEX_JSON.write(L_DescTab (I).col_NAME, L_DATE_COL);
                    ELSIF (L_DescTab (I).col_type = 112) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_CLOB_COL);
        --                dbms_output.put_line(L_DATE_COL);
                        APEX_JSON.write(L_DescTab (I).col_NAME, L_CLOB_COL);
                    ELSE
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_VARCHAR_COL);
        --                dbms_output.put_line(L_VARCHAR_COL);
                        APEX_JSON.write(L_DescTab (I).col_NAME, L_VARCHAR_COL);
                    END IF;
                END LOOP;
                ---
                APEX_JSON.close_object;
            end loop;
            ---
            APEX_JSON.close_array;
            --
            DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
        end loop;
        ---
        APEX_JSON.close_object;
--        DBMS_OUTPUT.put_line(APEX_JSON.get_clob_output);
        L_RET_CLOB := APEX_JSON.get_clob_output;
        APEX_JSON.free_output;
        ---
        RETURN L_RET_CLOB;
    END;

    FUNCTION CREATE_PERSON_ABSENCE (
            P_validate IN BOOLEAN default FALSE,
            P_BODY_DATA BLOB) RETURN CLOB
    IS
          l_person_id number;
          l_absence_type varchar2(100);
          l_effective_date date;
          l_date_start date;
          l_date_end date;
          --------------------
          v_business_group_id            NUMBER := 101;
          v_absence_attendance_type_id   NUMBER; -- Personal Time
          io_absence_days                NUMBER;
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
          L_RET_CLOB      CLOB;
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
    BEGIN
          --------
          --------

            -- Convert the BLOB to a CLOB.
              DBMS_LOB.createtemporary(
                lob_loc => l_clob,
                cache   => FALSE,
                dur     => DBMS_LOB.call);

              DBMS_LOB.converttoclob(
               dest_lob      => l_clob,
               src_blob      => P_BODY_DATA,
               amount        => DBMS_LOB.lobmaxsize,
               dest_offset   => l_dest_offset,
               src_offset    => l_src_offset, 
               blob_csid     => DBMS_LOB.default_csid,
               lang_context  => l_lang_context,
               warning       => l_warning);

               APEX_JSON.parse(l_clob);

               l_person_id := APEX_JSON.get_number(p_path => 'person_id');
               l_absence_type := APEX_JSON.get_varchar2(p_path => 'absence_type');
               l_effective_date := APEX_JSON.get_varchar2(p_path => 'effective_date');
               l_date_start := APEX_JSON.get_varchar2(p_path => 'date_start');
               l_date_end := APEX_JSON.get_varchar2(p_path => 'date_end');
               ----
               io_absence_days                 := to_date(l_date_end) - to_date(l_date_start);
               ----
               select ABSENCE_ATTENDANCE_TYPE_ID into v_absence_attendance_type_id
                FROM per_absence_attendance_types
                where name = l_absence_type;

              FOR i IN 0 .. APEX_JSON.get_count(p_path => 'delegatedUsers')*2 LOOP
                if mod(i, 2) != 0 and APEX_JSON.get_number(p_path => 'delegatedUsers[%d].personId', p0 => odd_ctr+1) is not null then
                    l_resp := l_resp || '"Attribute' || to_char(i) || '": ' || to_char(APEX_JSON.get_number(p_path => 'delegatedUsers[%d].personId', p0 => odd_ctr+1)) ||
                                    ', "Attribute' || to_char(i+1) || '": "' || APEX_JSON.get_varchar2(p_path => 'delegatedUsers[%d].delegationType', p0 => odd_ctr+1) || '",';
                    odd_ctr := odd_ctr + 1;
                end if;
              END LOOP;
                ---
                l_resp := '{' || substr(l_resp, 0, length(l_resp)-1) || '}';
                ---
                DBMS_LOB.freetemporary(lob_loc => l_clob);
                ---    
                APEX_JSON.parse(l_resp);

          --------
          --------
          hr_person_absence_api.create_person_absence (p_validate                     => P_validate
                                                      ,p_effective_date               => l_effective_date
                                                      ,p_person_id                    => l_person_id
                                                      ,p_business_group_id            => v_business_group_id
                                                      ,p_absence_attendance_type_id   => v_absence_attendance_type_id
                                                      ,p_date_start                   => l_date_start
                                                      ,p_date_end                     => l_date_end
                                                      ,p_absence_days                 => io_absence_days
                                                      ,p_absence_hours                => io_absence_hours
                                                      ,p_attribute1                   => APEX_JSON.get_number(p_path => 'Attribute1')
                                                      ,p_attribute2                   => APEX_JSON.get_varchar2(p_path => 'Attribute2')
                                                      ,p_attribute3                   => APEX_JSON.get_number(p_path => 'Attribute3')
                                                      ,p_attribute4                   => APEX_JSON.get_varchar2(p_path => 'Attribute4')
                                                      ,p_attribute5                   => APEX_JSON.get_number(p_path => 'Attribute5')
                                                      ,p_attribute6                   => APEX_JSON.get_varchar2(p_path => 'Attribute6')
                                                      ,p_attribute7                   => APEX_JSON.get_number(p_path => 'Attribute7')
                                                      ,p_attribute8                   => APEX_JSON.get_varchar2(p_path => 'Attribute8')
                                                      ,p_attribute9                   => APEX_JSON.get_number(p_path => 'Attribute9')
                                                      ,p_attribute10                  => APEX_JSON.get_varchar2(p_path => 'Attribute10')
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

          IF (o_absence_attendance_id IS NOT NULL) THEN
            COMMIT;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            v_error_msg   := sqlerrm;

            APEX_JSON.initialize_clob_output;
            APEX_JSON.open_object;
            ---------------------
            if o_absence_attendance_id is not null then
                APEX_JSON.write('abs_id', o_absence_attendance_id);
                --
                APEX_JSON.write('person_id', l_person_id);
                APEX_JSON.write('absence_type', l_absence_type);
                APEX_JSON.write('effective_date', l_effective_date);
                APEX_JSON.write('date_start', l_DATE_START);
                APEX_JSON.write('date_end', l_DATE_END);
            end if;
            --
            APEX_JSON.open_array('messages');

            if v_error_msg is not null and o_absence_attendance_id is null then
                APEX_JSON.open_object;
                APEX_JSON.write('type', 'error');
                APEX_JSON.write('msg_txt', v_error_msg);
                APEX_JSON.close_object;
            end if;
            ----
            if o_dur_dys_less_warning is not null then
                APEX_JSON.open_object;
                APEX_JSON.write('type', 'warning');
                APEX_JSON.write('code', 'dur_dys_less_warning');
                APEX_JSON.write('msg_txt', v_error_msg);
                APEX_JSON.close_object;
            end if;

            if o_dur_hrs_less_warning is not null then
                APEX_JSON.open_object;
                APEX_JSON.write('type', 'warning');
                APEX_JSON.write('code', 'dur_hrs_less_warning');
                APEX_JSON.write('msg_txt', v_error_msg);
                APEX_JSON.close_object;
            end if;

            if o_exceeds_pto_entit_warning is not null then
                APEX_JSON.open_object;
                APEX_JSON.write('type', 'warning');
                APEX_JSON.write('code', 'exceeds_pto_entit_warning');
                APEX_JSON.write('msg_txt', v_error_msg);
                APEX_JSON.close_object;
            end if;

            if o_exceeds_run_total_warning is not null then
                APEX_JSON.open_object;
                APEX_JSON.write('type', 'warning');
                APEX_JSON.write('code', 'exceeds_run_total_warning');
                APEX_JSON.write('msg_txt', v_error_msg);
                APEX_JSON.close_object;
            end if;

            if o_abs_overlap_warning is not null then
                APEX_JSON.open_object;
                APEX_JSON.write('type', 'warning');
                APEX_JSON.write('code', 'abs_overlap_warning');
                APEX_JSON.write('msg_txt', v_error_msg);
                APEX_JSON.close_object;
            end if;

            if o_abs_day_after_warning is not null then
                APEX_JSON.open_object;
                APEX_JSON.write('type', 'warning');
                APEX_JSON.write('code', 'abs_day_after_warning');
                APEX_JSON.write('msg_txt', v_error_msg);
                APEX_JSON.close_object;
            end if;

            if o_dur_overwritten_warning is not null then
                APEX_JSON.open_object;
                APEX_JSON.write('type', 'warning');
                APEX_JSON.write('code', 'dur_overwritten_warning');
                APEX_JSON.write('msg_txt', v_error_msg);
                APEX_JSON.close_object;
            end if;

            APEX_JSON.close_array;
            ---------------------
            APEX_JSON.close_object;
            L_RET_CLOB := APEX_JSON.get_clob_output;
            APEX_JSON.free_output;
            ---------------------------------------------
            RETURN L_RET_CLOB;
    END;

    FUNCTION CREATE_PERSON_EXTRA_INFO (
            P_validate IN BOOLEAN default FALSE,
            P_PERSON_ID NUMBER default null,
            p_information_type VARCHAR2 default null,
--            p_pei_attribute_category VARCHAR2 default null,
--            p_pei_information_category VARCHAR2 default null,
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
            p_pei_information30 VARCHAR2 default null) RETURN CLOB
    IS
            l_person_extra_info_id    number;
            l_object_version_number   number;
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
            hr_person_extra_info_api.create_person_extra_info (
                 p_validate                   => P_validate
                ,p_person_id                  => P_PERSON_ID
                ,p_information_type           => p_information_type
                ,p_pei_attribute_category     => NULL
                ,p_pei_information_category   => p_information_type
                ,p_pei_information1           => p_pei_information1
                ,p_pei_information2           => p_pei_information2
                ,p_pei_information3           => p_pei_information3
                ,p_pei_information4           => p_pei_information4
                ,p_pei_information5           => p_pei_information5
                ,p_pei_information6           => p_pei_information6
                ,p_pei_information7           => p_pei_information7
                ,p_pei_information8           => p_pei_information8
                ,p_pei_information9           => p_pei_information9
                ,p_pei_information10           => p_pei_information10
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

--              IF l_person_extra_info_id IS NOT NULL THEN
                    commit;
--              END IF;
                l_resp_status := 'success';
                APEX_JSON.write('STATUS', l_resp_status);
                APEX_JSON.write('EIT_ID', l_person_extra_info_id);
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
                    IF l_person_extra_info_id IS NOT NULL THEN
                        l_resp_status := 'warning';
                    ELSE
                        l_resp_status := 'error';
                    END IF;
                    ---------------------
                    APEX_JSON.write('STATUS', l_resp_status);
                    if l_person_extra_info_id is not null then
                        APEX_JSON.write('EIT_ID', l_person_extra_info_id);
                    else
                        APEX_JSON.write('EIT_ID', 'null');
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
    
    FUNCTION GET_EMP_LEAVE_BALANCE(
            P_PERSON_NUMBER IN VARCHAR2 default null,
            P_DATE_START IN DATE default null,
            P_DATE_END IN DATE default null
    ) RETURN CLOB
    is 
        cursor xx_test is
            SELECT DISTINCT pf.employee_number,
                pf.full_name,
                pf.business_group_id,
                paf.assignment_id,
                pv.ACCRUAL_PLAN_ID,
                paf.payroll_id
            FROM pay_view_accrual_plans_v pv,
                   per_all_people_f pf,
                   per_all_assignments_f paf
            WHERE  pv.person_id = pf.person_id
               AND pf.person_id = paf.person_id
--               AND pv.accrual_plan_id IN (61, 1061)
               AND TRUNC (SYSDATE) BETWEEN pf.effective_start_date
                                       AND pf.effective_end_date
               AND TRUNC (SYSDATE) BETWEEN paf.effective_start_date
                                       AND paf.effective_end_date
                                       AND pf.employee_number=P_PERSON_NUMBER;
            ---
            xxx_rec xx_test%rowtype;
            -------------------
            cursor leave_b_cur(assmt_id number, plan_id number) is
                select (select distinct
                    nvl(sum(pev1.screen_entry_value), '0')
                    from    per_all_people_f P1,
                            per_all_assignments_f a1,
                            per_grades g1,
                            pay_element_types_f et1,
                            pay_element_links_f pel1,
                            pay_element_entries_f pee1,
                            pay_element_entry_values_f pev1,
                            pay_input_values_f piv1
                    where   p1.employee_number = P_PERSON_NUMBER
                        and p1.person_id = a1.person_id
                        and a1.grade_id = g1.grade_id (+)
                        and a1.assignment_id = pee1.assignment_id
                        and (P_DATE_END) BETWEEN p1.effective_start_date and p1.effective_end_date
                        and (P_DATE_END) BETWEEN a1.effective_start_date and a1.effective_end_date
                        and to_char(P_DATE_END, 'YYYY') = to_char(pee1.effective_start_date, 'YYYY')
                        and to_char(P_DATE_END, 'YYYY') = to_char(pev1.effective_start_date, 'YYYY')
                        and pee1.element_entry_id = pev1.element_entry_id
                        and et1.element_type_id = pel1.element_type_id
                        and pel1.element_link_id = pee1.element_link_id
                        and pev1.input_value_id = piv1.input_value_id
                        and piv1.name = 'Adjustment Days'
                        and element_name in ('Annual Leave Adjustment')) adjustment_days,
                    round(APPS.ZAIN_CALC_ACCRUALS_AFTER_UP(
                    P_PERSON_NUMBER, TO_DATE('31-Dec-'||extract (year from P_DATE_END)), trunc(P_DATE_END, 'YEAR'), P_DATE_END
                    ), 2) current_accrual,
                    round(APPS.ZAIN_CALC_ACCRUALS_AFTER_UP(
                    P_PERSON_NUMBER, TO_DATE('31-Dec-'||extract (year from P_DATE_END)), trunc(P_DATE_END, 'YEAR'), TO_DATE('31-Dec-'||extract (year from P_DATE_END))
                    ), 2) accrual_year_end,
                    APPS.X_ZAIN_ANNUAL_LEAVE_TAKEN(
                    P_PERSON_NUMBER, trunc(P_DATE_END, 'YEAR'), P_DATE_END
                    ) annual_leave_taken,
                    X_ZAIN_KSA_LEAVE_PKG.get_carry_over(
                    assmt_id, plan_id, P_DATE_END, trunc(P_DATE_END, 'YEAR')
                    ) carryover_days
            from dual;
            ---
            leave_b_rec leave_b_cur%rowtype;
            -------------------
            l_char varchar2(100);
            ---
           L_START_DATE         DATE;
           L_END_DATE           DATE;
           L_ACC_END_DATE       DATE;
           L_VALUE              NUMBER := 0;
           L_NET_VALUE          NUMBER;
           P_PLAN_ID            NUMBER;
           ---
           l_resp clob;
           ---
           l_person_id number;
    begin 
        select person_id into l_person_id from per_all_people_f
            where employee_number = P_PERSON_NUMBER
            AND TRUNC (SYSDATE) BETWEEN effective_start_date
                                    AND effective_end_date;
    
        init_session(l_person_id);
                                    
        open xx_test;
       fetch xx_test into xxx_rec;
       close xx_test;
        
        PER_ACCRUAL_CALC_FUNCTIONS.GET_NET_ACCRUAL
                           (P_ASSIGNMENT_ID               => xxx_rec.assignment_id,
                            P_PLAN_ID                     => xxx_rec.ACCRUAL_PLAN_ID,
                            P_PAYROLL_ID                  => xxx_rec.payroll_id,
                            P_BUSINESS_GROUP_ID           => xxx_rec.business_group_id,   -- Kindly change your business group id accordingly
                            P_ASSIGNMENT_ACTION_ID        => -1,
                            P_CALCULATION_DATE            => P_DATE_END, -- END Date,  will not use start date
                            P_ACCRUAL_START_DATE          => NULL,
                            P_ACCRUAL_LATEST_BALANCE      => NULL,
                            P_CALLING_POINT               => 'FRM',
                            P_START_DATE                  => L_START_DATE,
                            P_END_DATE                    => L_END_DATE,
                            P_ACCRUAL_END_DATE            => L_ACC_END_DATE,
                            P_ACCRUAL                     => L_VALUE,
                            P_NET_ENTITLEMENT             => L_NET_VALUE
                           );
                           
        -----
        open leave_b_cur(xxx_rec.assignment_id, xxx_rec.ACCRUAL_PLAN_ID);
       fetch leave_b_cur into leave_b_rec;
       close leave_b_cur;
        -----
        if (nvl(L_NET_VALUE, 0) > 0 and nvl(L_NET_VALUE, 0) < 1) or (nvl(L_NET_VALUE, 0) > -1 and nvl(L_NET_VALUE, 0) < 0) then
            l_resp := '{"totalLeaveDays": "'||to_char(L_VALUE-L_NET_VALUE)||'", "currentAccrualBalance": "0'||to_char(nvl(round(L_NET_VALUE,2), 0))||'",'
                ||'"currentAccrual": "'||leave_b_rec.current_accrual||'", "accrualYearEnd": "'||leave_b_rec.accrual_year_end||
                '", "annualLeaveTaken": "'||leave_b_rec.annual_leave_taken||'", "carryOverDays": "'||leave_b_rec.carryover_days||
                '", "adjustmentDays": "'||leave_b_rec.adjustment_days||'", "leaveBalance": "'||
                to_char(leave_b_rec.current_accrual+leave_b_rec.carryover_days+leave_b_rec.adjustment_days-leave_b_rec.annual_leave_taken)||
                '", "OverallEntitlement": "'||to_char(leave_b_rec.accrual_year_end+leave_b_rec.carryover_days+leave_b_rec.adjustment_days-leave_b_rec.annual_leave_taken)||
                '", "effectiveDate": "'||to_date(P_DATE_END)||'", "yearStartDate": "'||trunc(to_date(P_DATE_END), 'YEAR')||'", "yearEndDate": "'||TO_DATE('31-Dec-'||extract (year from to_date(P_DATE_END)))||'"}';
        else
            l_resp := '{"totalLeaveDays": '||to_char(L_VALUE-L_NET_VALUE)||', "currentAccrualBalance": "'||to_char(nvl(round(L_NET_VALUE,2), 0))||'",'
                ||'"currentAccrual": "'||leave_b_rec.current_accrual||'", "accrualYearEnd": "'||leave_b_rec.accrual_year_end||
                '", "annualLeaveTaken": "'||leave_b_rec.annual_leave_taken||'", "carryOverDays": "'||leave_b_rec.carryover_days||
                '", "adjustmentDays": "'||leave_b_rec.adjustment_days||'", "leaveBalance": "'||
                to_char(leave_b_rec.current_accrual+leave_b_rec.carryover_days+leave_b_rec.adjustment_days-leave_b_rec.annual_leave_taken)||
                '", "OverallEntitlement": "'||to_char(leave_b_rec.accrual_year_end+leave_b_rec.carryover_days+leave_b_rec.adjustment_days-leave_b_rec.annual_leave_taken)||
                '", "effectiveDate": "'||to_date(P_DATE_END)||'", "yearStartDate": "'||trunc(to_date(P_DATE_END), 'YEAR')||'", "yearEndDate": "'||TO_DATE('31-Dec-'||extract (year from to_date(P_DATE_END)))||'"}';
        end if;
--        l_resp := '{"totalLeaveDays": '||rec_abs_days||', "leaveBalance": "0'||to_char(nvl(rec_leave_balance, 0))||'"}';
        ---
        return l_resp;
    end;
    ---------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------
       FUNCTION get_person_extra_info (
        p_requester_person_id   IN   NUMBER default null,
        p_person_id             IN   NUMBER,
        p_REQUEST_CODE          IN   VARCHAR2,
        p_q_str   IN   VARCHAR2 default null
    ) RETURN CLOB IS

        v_query_string   CLOB;
        l_cursor_id      INTEGER;
        l_desctab        dbms_sql.desc_tab;
        l_col_count      NUMBER;
        l_varchar_col    VARCHAR2(2000);
        l_number_col     NUMBER;
        l_date_col       DATE;
        l_clob_col       CLOB;
        l_ret            NUMBER;
        l_ret_clob       CLOB;
        ---
        ------ Select Query Initialization ------
        CURSOR cur_ent_queries IS
        SELECT
            'getRequestHistory' entity_key,
            'select '
            ||
                LISTAGG(columnquery, ', ') WITHIN GROUP(
                    ORDER BY
                        seqnum
                )
            || q'[ from PER_PEOPLE_EXTRA_INFO where
 person_id=#PERSON_ID#]'
            || q'[ and INFORMATION_TYPE='#REQUEST_CODE#']' "ENTITY_QUERY"
            ,'Nameenglish:pei_information8' COLS_FILTER
        FROM
            (
                SELECT
                    column_seq_num            seqnum,
                    replace(initcap(end_user_column_name), ' ', '') "apiName",
                    application_column_name   "columnName",
                    form_left_prompt          "label",
                    flex_value_set_id         "flexValuesetId",
                    application_column_name
                    || ' "'
                    || replace(initcap(end_user_column_name), ' ', '')
                    || '"' columnquery
                FROM
                    fnd_descr_flex_col_usage_vl d
                WHERE
                    ( application_id = 800 )
                    AND ( descriptive_flexfield_name = 'Extra Person Info DDF' )
                    AND ( descriptive_flex_context_code = p_REQUEST_CODE ) -- #REQUEST_CODE# var  -- reference fields -->> information type
                    AND enabled_flag = 'Y'
--ORDER BY
--    column_seq_num
            );     -------------   
        -------------        
        L_COLS_FILTER VARCHAR2(1000);
        L_Q_STR VARCHAR2(1000) := p_q_str; -- := 'Location=''ZAIN KSA - Jeddah''';
        L_Q_FILTER VARCHAR2(1000) := '';
        ---
        l_var varchar2(50);
        l_value varchar2(100);
        l_appColName varchar2(100);
        l_operator varchar2(20);

    BEGIN

        ---
        apex_json.initialize_clob_output;
        apex_json.open_object;
        FOR ent_q IN cur_ent_queries LOOP
            -----------------------------------------------------
            -----------------------------------------------------
              IF L_Q_STR IS NOT NULL THEN
                  L_COLS_FILTER := ent_q.COLS_FILTER;
                  FOR C_ROW IN (
                    with test as    
                      (select L_Q_STR from dual)
                      select regexp_substr(L_Q_STR, '[^;]+', 1, rownum) SPLIT
                      from test
                      connect by level <= length (regexp_replace(L_Q_STR, '[^;]+'))  + 1)
                  LOOP
                        if C_ROW.SPLIT like '%=%' then
                            l_operator := '=';
                        end if;
                        if C_ROW.SPLIT like '%!=%' then
                            l_operator := '!=';
                        end if;
                        if C_ROW.SPLIT like '%>%' then
                            l_operator := '>';
                        end if;
                        if C_ROW.SPLIT like '%<%' then
                            l_operator := '<';
                        end if;
                        if C_ROW.SPLIT like '%>=%' then
                            l_operator := '>=';
                        end if;
                        if C_ROW.SPLIT like '%<=%' then
                            l_operator := '<=';
                        end if;
                        ---
                        l_var := SUBSTR(C_ROW.SPLIT,1,instr(C_ROW.SPLIT, l_operator)-1);
                        l_value := SUBSTR(C_ROW.SPLIT, 
                                        instr(C_ROW.SPLIT, l_operator)+length(l_operator), 
                                        LENGTH(C_ROW.SPLIT)-(instr(C_ROW.SPLIT, l_operator)+(length(l_operator)-1))
                                      );
                        --------------
                        begin
                            select 
                                application_column_name into l_appColName
                            FROM
                                fnd_descr_flex_col_usage_vl d
                            WHERE
                                ( application_id = 800 )
                                AND ( descriptive_flexfield_name = 'Extra Person Info DDF' )
                                AND ( descriptive_flex_context_code = p_REQUEST_CODE ) 
                                and replace(initcap(end_user_column_name), ' ', '') = l_var
                                and ENABLED_FLAG = 'Y';
                            ---
                            l_value := to_date(l_value);
                            ---
                            exception
                                when no_data_found then
                                    return 'Something wrong with attributes in q header!';
                                ---
                                when others then
                                    null;
                        end;
                        --------------
                        L_Q_FILTER := L_Q_FILTER || ' AND ' || l_appColName || ' '||l_operator||' ' || l_value;
                          -------------
                  END LOOP;
                  DBMS_OUTPUT.PUT_LINE(L_Q_FILTER);
              END IF;
            -----------------------------------------------------
            -----------------------------------------------------
            ------ Select Query Manipulation ------
            v_query_string := ent_q.entity_query;
            IF p_person_id IS NOT NULL THEN
                v_query_string := replace(v_query_string, '#PERSON_ID#', p_person_id);
            END IF;

            IF p_REQUEST_CODE IS NOT NULL THEN
                v_query_string := replace(v_query_string, '#REQUEST_CODE#', p_REQUEST_CODE);
            ELSE
                v_query_string := replace(v_query_string, '#REQUEST_CODE#', 'ZAIN_BUSINESS_CARD');
            END IF;
            
            v_query_string := v_query_string || case when L_Q_FILTER is not null then L_Q_FILTER else '' end;

            dbms_output.put_line(v_query_string);
            ---
            l_cursor_id := dbms_sql.open_cursor;
            dbms_sql.parse(l_cursor_id, v_query_string, dbms_sql.native);
            dbms_sql.describe_columns(l_cursor_id, l_col_count, l_desctab);
            ---
            FOR i IN 1..l_col_count LOOP IF ( l_desctab(i).col_type = 2 ) THEN
                dbms_sql.define_column(l_cursor_id, i, l_number_col);
            ELSIF ( l_desctab(i).col_type = 12 ) THEN
                dbms_sql.define_column(l_cursor_id, i, l_date_col);
            ELSIF ( l_desctab(i).col_type = 112 ) THEN
                dbms_sql.define_column(l_cursor_id, i, l_clob_col);
            ELSE
                dbms_sql.define_column(l_cursor_id, i, l_varchar_col, 2000);
            END IF;
            END LOOP;
            ---

            l_ret := dbms_sql.execute(l_cursor_id);
            ---
            apex_json.write('RequestName',ent_q.entity_key);
            apex_json.write('RequestCode',p_REQUEST_CODE);
            apex_json.write('RequestDate',to_char(sysdate,'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'HH24:MI:SS')||'Z');
            ---
            apex_json.open_array('RequestHistory'/*ent_q.entity_key*/ );
            ---
            LOOP
                --FITCH ROW
                l_ret := dbms_sql.fetch_rows(l_cursor_id);
                EXIT WHEN l_ret = 0;
                apex_json.open_object;
                ---
                FOR i IN 1..l_col_count LOOP
                    IF ( l_desctab(i).col_type = 2 ) THEN
                        dbms_sql.column_value(l_cursor_id, i, l_number_col);
                            --dbms_output.put_line(L_NUMBER_COL); --L_DescTab (I).col_NAME,
                        apex_json.write(l_desctab(i).col_name, l_number_col);
                    ELSIF ( l_desctab(i).col_type = 12 ) THEN
                        dbms_sql.column_value(l_cursor_id, i, l_date_col);
            --                dbms_output.put_line(L_DATE_COL);
                        apex_json.write(l_desctab(i).col_name, l_date_col);
                    ELSIF ( l_desctab(i).col_type = 112 ) THEN
                        dbms_sql.column_value(l_cursor_id, i, l_clob_col);
            --                dbms_output.put_line(L_DATE_COL);
                        apex_json.write(l_desctab(i).col_name, l_clob_col);
                    ELSE
                        dbms_sql.column_value(l_cursor_id, i, l_varchar_col);
            --                dbms_output.put_line(L_VARCHAR_COL);
                        apex_json.write(l_desctab(i).col_name, l_varchar_col);
                    END IF;
                END LOOP;
                ---

                apex_json.close_object;
            END LOOP;
            ---

            apex_json.close_array;
            --
            dbms_sql.close_cursor(l_cursor_id);
        END LOOP;
        ---

        apex_json.close_object;
--        DBMS_OUTPUT.put_line(APEX_JSON.get_clob_output);
        l_ret_clob := apex_json.get_clob_output;
        apex_json.free_output;
        ---
        RETURN l_ret_clob;
    END;
    ---------------------------------------------------------------------------------------
    ---------------------------------------------------------------------------------------
        FUNCTION get_extra_info_meta (
         p_REQUEST_CODE        IN   VARCHAR2
    ) RETURN CLOB IS



        v_query_string   CLOB;
        l_cursor_id      INTEGER;
        l_desctab        dbms_sql.desc_tab;
        l_col_count      NUMBER;
        l_varchar_col    VARCHAR2(2000);
        l_number_col     NUMBER;
        l_date_col       DATE;
        l_clob_col       CLOB;
        l_ret            NUMBER;
        l_ret_clob       CLOB;
        ---
        ------ Select Query Initialization ------
        cursor cur_ent_queries is
            select rt.request_type, eq.entity_key, eq.entity_query, eq.COLS_FILTER
            from xxx_zain_ess_entity_queries eq
            join xxx_zain_ess_req_types rt
            on (eq.entity_key = rt.entity_key)
            where rt.request_type = 'getRequestMetaData';


    BEGIN

        ---

        apex_json.initialize_clob_output;
        apex_json.open_object;
       FOR ent_q IN cur_ent_queries LOOP
            ------ Select Query Manipulation ------
            v_query_string := ent_q.entity_query;

            IF p_REQUEST_CODE IS NOT NULL THEN
                v_query_string := replace(v_query_string, '#REQUEST_CODE#', p_REQUEST_CODE);
            ELSE
                v_query_string := replace(v_query_string, '#REQUEST_CODE#', 'ZAIN_BUSINESS_CARD');
            END IF;

            dbms_output.put_line(v_query_string);
            ---
            l_cursor_id := dbms_sql.open_cursor;
            dbms_sql.parse(l_cursor_id, v_query_string, dbms_sql.native);
            dbms_sql.describe_columns(l_cursor_id, l_col_count, l_desctab);
            ---
            FOR i IN 1..l_col_count LOOP IF ( l_desctab(i).col_type = 2 ) THEN
                dbms_sql.define_column(l_cursor_id, i, l_number_col);
            ELSIF ( l_desctab(i).col_type = 12 ) THEN
                dbms_sql.define_column(l_cursor_id, i, l_date_col);
            ELSIF ( l_desctab(i).col_type = 112 ) THEN
                dbms_sql.define_column(l_cursor_id, i, l_clob_col);
            ELSE
                dbms_sql.define_column(l_cursor_id, i, l_varchar_col, 2000);
            END IF;
            END LOOP;
            ---

            l_ret := dbms_sql.execute(l_cursor_id);
            ---
            apex_json.write('RequestName',ent_q.entity_key);
            apex_json.write('RequestCode',p_REQUEST_CODE);
            apex_json.write('RequestDate',to_char(sysdate,'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'HH24:MI:SS')||'Z');
            ---
            apex_json.open_array('Attributes'/*ent_q.entity_key*/ );
            ---
            LOOP
                --FITCH ROW
                l_ret := dbms_sql.fetch_rows(l_cursor_id);
                EXIT WHEN l_ret = 0;
                apex_json.open_object;
                ---
                FOR i IN 1..l_col_count LOOP 
                    IF (L_DescTab (I).col_type = 2) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I, L_NUMBER_COL);
                        --dbms_output.put_line(L_NUMBER_COL); --L_DescTab (I).col_NAME,
                        if L_NUMBER_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_NUMBER_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
                    ELSIF (L_DescTab (I).col_type = 12) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_DATE_COL);
        --                dbms_output.put_line(L_DATE_COL);
                        if L_DATE_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_DATE_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
                    ELSIF (L_DescTab (I).col_type = 112) THEN
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_CLOB_COL);
        --                dbms_output.put_line(L_CLOB_COL);
                        if L_DATE_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_CLOB_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
                    ELSE
                        DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_VARCHAR_COL);
        --                dbms_output.put_line(L_VARCHAR_COL);
                        if L_VARCHAR_COL is not null then
                            APEX_JSON.write(L_DescTab (I).col_NAME, L_VARCHAR_COL);
                        else
                            APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                        end if;
                    END IF;
                END LOOP;
                ---

                apex_json.close_object;
            END LOOP;
            ---

            apex_json.close_array;
            --
            dbms_sql.close_cursor(l_cursor_id);

        ---
  END LOOP;
        apex_json.close_object;
--        DBMS_OUTPUT.put_line(APEX_JSON.get_clob_output);
        l_ret_clob := apex_json.get_clob_output;
        apex_json.free_output;
        ---
        L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
        ---
       -- dbms_output.put_line(l_ret_clob);
        RETURN l_ret_clob;
    END;

    FUNCTION GET_PERSON_BY_ROLE (
            P_REQUESTER_PERSON_ID NUMBER default null,
            P_PERSON_ID IN NUMBER default null,
            P_ROLE_NAME VARCHAR2 default null,
            P_TRANSACTION_TYPE VARCHAR2 default null,
            p_transaction_date  in varchar2,
            p_region  in varchar2 default null,
            p_resp  in varchar2 default null,
            P_OFFSET NUMBER default null,
            P_LIMIT NUMBER default null,
            P_ORDER_BY VARCHAR2 default null) RETURN CLOB
    IS
        v_query_string CLOB;
        l_cursor_id integer;
        L_DescTab   DBMS_SQL.desc_tab;
        L_COL_Count   NUMBER;
        L_VARCHAR_COL VARCHAR2(2000);
        L_NUMBER_COL    NUMBER;
        L_DATE_COL      DATE;
        L_CLOB_COL      CLOB;
        L_RET           NUMBER;
        L_RET_CLOB      CLOB;
        L_PERSON_IDS varchar2(2000);
        ---
        ------ Select Query Initialization ------
        cursor cur_ent_queries is
            select *
            from XXX_ZAIN_ESS_RULES_ACTIONS 
            where 
                ROLE_NAME=p_role_name 
            AND (TRANSACTION_TYPE=p_transaction_type or p_transaction_type is null or transaction_type is null)
            AND p_transaction_date>=EFFECTIVE_START_DATE AND p_transaction_date<=EFFECTIVE_END_DATE
            order by case when TRANSACTION_TYPE=p_transaction_type then 1 else 2 end;
        -------------   
        rec cur_ent_queries%rowtype;
    BEGIN
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
--        APEX_JSON.open_array('RolePeople');
--        for rec in cur_ent_queries loop
        open cur_ent_queries;
        fetch cur_ent_queries into rec;
        close cur_ent_queries;
            ------ Select Query Manipulation ------
            v_query_string := rec.sql_query;
            if P_PERSON_ID is not null then
                v_query_string := replace(v_query_string, '#PERSON_ID#', P_PERSON_ID);
            else
                v_query_string := replace(v_query_string, '#PERSON_ID#', 'NULL');
            end if;
            if P_PERSON_ID is not null then
                v_query_string := replace(v_query_string, '#ROLE_NAME#', ''''||P_ROLE_NAME||'''');
            else
                v_query_string := replace(v_query_string, '#ROLE_NAME#', 'NULL');
            end if;
            if P_LIMIT is not null then
                v_query_string := replace(v_query_string, '#LIMIT#', P_LIMIT);
            else
                v_query_string := replace(v_query_string, '#LIMIT#', 'NULL');
            end if;
            if p_region is not null then
                v_query_string := replace(v_query_string, '#v_region#', p_region);
            else
                v_query_string := replace(v_query_string, '''#v_region#''', 'NULL');
            end if;
            if p_resp is not null then
                v_query_string := replace(v_query_string, '#v_resp#', p_resp);
            else
                v_query_string := replace(v_query_string, '''#v_resp#''', 'NULL');
            end if;
            dbms_output.put_line(v_query_string);
            ----------------------------------------
            ----------------------------------------
            
            l_cursor_id := DBMS_SQL.OPEN_CURSOR;
            DBMS_SQL.PARSE(l_cursor_id, v_query_string,DBMS_SQL.NATIVE);
            DBMS_SQL.DESCRIBE_COLUMNS (l_cursor_id, L_COL_Count, L_DescTab);
            ---
            DBMS_SQL.define_column (l_cursor_id,1,L_NUMBER_COL);
            ---
            L_RET:=DBMS_SQL.execute (l_cursor_id);
            ---
            loop
                --FITCH ROW
                L_RET:=DBMS_SQL.fetch_rows (l_cursor_id);
                exit when L_RET = 0;
                ---
                DBMS_SQL.COLUMN_VALUE (l_cursor_id,1, L_NUMBER_COL);
                --dbms_output.put_line(L_NUMBER_COL); --L_DescTab (I).col_NAME,
                if L_NUMBER_COL is not null then
                    L_PERSON_IDS := L_PERSON_IDS || to_char(L_NUMBER_COL) || ',';
                end if;
            end loop;
            DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
            
            v_query_string := 'select p.person_id "personId", p.employee_number "personNumber", p.FIRST_NAME "firstName", p.last_name "lastName", p.full_name "fullName", p.start_date "hireDate",
                                        u.EMAIL_ADDRESS "email", u.user_id "ebsUserId", u.user_name "ebsUserName",
                                        assmt.position_id "PositionId", assmt.job_id "jobId", assmt.grade_id "gradeId", assmt.organization_id "departmentId",
                                        mgr.person_id "managerId", mgr.full_name "managerName", mgr.email_address "managerEmail",
                                        pos.name "PositionName", j.name "jobName", g.name "gradeName", o.name "departmentName"
                                ,
                                        (select max(group_name) from pay_people_groups where PEOPLE_GROUP_ID = assmt.PEOPLE_GROUP_ID) "peopleGroup"
                                ,
                                    ''ACTIVE'' "active"
                                from per_all_people_f p
                                    left join fnd_user u
                                    on (p.person_id = u.employee_id)
                                    left join PER_ALL_ASSIGNMENTS_F assmt
                                    on (p.person_id = assmt.person_id and sysdate between nvl(assmt.effective_start_date, sysdate) and nvl(assmt.effective_end_date, sysdate+1000))
                                    left join per_all_people_f mgr
                                    on (assmt.supervisor_id = mgr.person_id and sysdate between nvl(mgr.effective_start_date, sysdate) and nvl(mgr.effective_end_date, sysdate+1000))
                                    left join hr_all_positions_f pos
                                    on (assmt.position_id = pos.position_id and sysdate between nvl(pos.effective_start_date, sysdate) and nvl(pos.effective_end_date, sysdate+1000))
                                    left join per_jobs j
                                    on (assmt.job_id = j.job_id and sysdate between nvl(j.date_from, sysdate) and nvl(j.date_to, sysdate+1000))
                                    left join per_grades g
                                    on (assmt.grade_id = g.grade_id and sysdate between nvl(g.date_from, sysdate) and nvl(g.date_to, sysdate+1000))
                                    left join hr_all_organization_units o
                                    on (assmt.organization_id = o.organization_id and sysdate between nvl(o.date_from, sysdate) and nvl(o.date_to, sysdate+1000))
                                where sysdate between p.effective_start_date and p.effective_end_date
                                    ----------------------------------------------
                                    and p.person_id in (' || substr(L_PERSON_IDS,0,length(L_PERSON_IDS)-1) || ')
                                    and rownum < nvl('||case when P_LIMIT is not null then to_char(P_LIMIT) else 'NULL' end ||', 25)';
            dbms_output.put_line(v_query_string);
            
            ----------------------------------------
            ----------------------------------------
            APEX_JSON.open_array('RolePeople');
            ---
            if L_PERSON_IDS is not null then
                l_cursor_id := DBMS_SQL.OPEN_CURSOR;
                DBMS_SQL.PARSE(l_cursor_id, v_query_string,DBMS_SQL.NATIVE);
                DBMS_SQL.DESCRIBE_COLUMNS (l_cursor_id, L_COL_Count, L_DescTab);
                ---
                FOR I IN 1 .. L_COL_Count LOOP
                    IF (L_DescTab (I).col_type = 2) THEN
                        DBMS_SQL.define_column (l_cursor_id,I,L_NUMBER_COL);
                    ELSIF (L_DescTab (I).col_type = 12) THEN
                        DBMS_SQL.define_column (l_cursor_id,I,L_DATE_COL);
                    ELSIF (L_DescTab (I).col_type = 112) THEN
                        DBMS_SQL.define_column (l_cursor_id,I,L_CLOB_COL);
                    ELSE
                        DBMS_SQL.define_column (l_cursor_id,I,L_VARCHAR_COL,2000);
                    END IF;
                END LOOP;
                ---
                L_RET:=DBMS_SQL.execute (l_cursor_id);
                ---
                loop
                    --FITCH ROW
                    L_RET:=DBMS_SQL.fetch_rows (l_cursor_id);
                    exit when L_RET = 0;
                    APEX_JSON.open_object;
                    ---
                    FOR I IN 1 .. L_COL_Count LOOP
                        IF (L_DescTab (I).col_type = 2) THEN
                            DBMS_SQL.COLUMN_VALUE (l_cursor_id,I, L_NUMBER_COL);
                            --dbms_output.put_line(L_NUMBER_COL); --L_DescTab (I).col_NAME,
                            if L_NUMBER_COL is not null then
                                APEX_JSON.write(L_DescTab (I).col_NAME, L_NUMBER_COL);
                            else
                                APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                            end if;
                        ELSIF (L_DescTab (I).col_type = 12) THEN
                            DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_DATE_COL);
            --                dbms_output.put_line(L_DATE_COL);
                            if L_DATE_COL is not null then
                                APEX_JSON.write(L_DescTab (I).col_NAME, L_DATE_COL);
                            else
                                APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                            end if;
                        ELSIF (L_DescTab (I).col_type = 112) THEN
                            DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_CLOB_COL);
            --                dbms_output.put_line(L_CLOB_COL);
                            if L_DATE_COL is not null then
                                APEX_JSON.write(L_DescTab (I).col_NAME, L_CLOB_COL);
                            else
                                APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                            end if;
                        ELSE
                            DBMS_SQL.COLUMN_VALUE (l_cursor_id,I,L_VARCHAR_COL);
            --                dbms_output.put_line(L_VARCHAR_COL);
                            if L_VARCHAR_COL is not null then
                                APEX_JSON.write(L_DescTab (I).col_NAME, L_VARCHAR_COL);
                            else
                                APEX_JSON.write(L_DescTab (I).col_NAME, 'null');
                            end if;
                        END IF;
                    END LOOP;
                    APEX_JSON.write('delegatedFlag', FALSE);
                    --- delegatedRoles ---
                    APEX_JSON.open_array('delegatedRoles');
--                        APEX_JSON.open_object;
--                        APEX_JSON.write('delegatedPersonId', 481);
--                        APEX_JSON.write('delegatedPersonNumber', 188);
--                        APEX_JSON.write('delegatedPersonName', 'Fadi Ali');
--                        APEX_JSON.write('startDate', '2021-10-25T00:00:00Z');
--                        APEX_JSON.write('endDate', '2021-10-29T00:00:00Z');
--                        APEX_JSON.close_object;
                    APEX_JSON.close_array;
                    ---
                    APEX_JSON.close_object;
                end loop;
                DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
            elsif rec.EXCEPTION_ROLE is not null then
                return GET_PERSON_BY_ROLE (
                        P_REQUESTER_PERSON_ID,
                        P_PERSON_ID,
                        rec.EXCEPTION_ROLE,--'Approvale Cycle Exception',--P_ROLE_NAME,
                        P_TRANSACTION_TYPE,
                        p_transaction_date,
                        p_region,
                        P_OFFSET,
                        P_LIMIT,
                        P_ORDER_BY);
            else
                return '{"RolePeople": []}';
            end if;
            ---
            APEX_JSON.close_array;
            --
--            DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
--        end loop;
        ---
--        APEX_JSON.close_array;
        APEX_JSON.close_object;
--        DBMS_OUTPUT.put_line(APEX_JSON.get_clob_output);
        L_RET_CLOB := APEX_JSON.get_clob_output;
        APEX_JSON.free_output;
        ---
        L_RET_CLOB := replace(L_RET_CLOB, '"null"', 'null');
        ---
        RETURN L_RET_CLOB;
    END;

    FUNCTION EXEC_ZAIN_CONCURRENT_PROG (
           p_CONC_PRGM_NAME   IN     VARCHAR2,
           p_PERSON_ID        IN     NUMBER DEFAULT NULL,
           p_argument1        IN     VARCHAR2 DEFAULT NULL,
           p_argument2        IN     VARCHAR2 DEFAULT NULL,
           p_argument3        IN     VARCHAR2 DEFAULT NULL,
           p_argument4        IN     VARCHAR2 DEFAULT NULL,
           p_argument5        IN     VARCHAR2 DEFAULT NULL,
           p_argument6        IN     VARCHAR2 DEFAULT NULL,
           p_argument7        IN     VARCHAR2 DEFAULT NULL,
           p_argument8        IN     VARCHAR2 DEFAULT NULL,
           p_argument9        IN     VARCHAR2 DEFAULT NULL,
           p_argument10       IN     VARCHAR2 DEFAULT NULL) RETURN CLOB
    is
       BFILEDATA   varchar2(2000);
       pdfB64 clob;
       l_blob blob;
       l_raw RAW(32767);
        l_amt NUMBER := 7700;
        l_offset NUMBER := 1;
        l_temp VARCHAR2(32767);
    begin
        ZAIN_CONCURRENT_PRGM_EXECUTION (
          P_CONC_PRGM_NAME   => p_CONC_PRGM_NAME,
          p_PERSON_ID        => p_PERSON_ID,
          p_argument1        => p_argument1,
          p_argument2        => p_argument2,
          p_argument3        => p_argument3,
          p_argument4        => p_argument4,
          p_argument5        => p_argument5,
          p_argument6        => p_argument6,
          p_argument7        => p_argument7,
          p_argument8        => p_argument8,
          p_argument9        => p_argument9,
          p_argument10       => p_argument10,
          p_URL          => BFILEDATA);
        ---
        
--        pdfB64 := HTTPURITYPE.createuri(BFILEDATA).getclob();
        
--        BEGIN
--            DBMS_LOB.createtemporary (l_blob, FALSE, DBMS_LOB.CALL);
--            LOOP
--                DBMS_LOB.read(cur_rec.Photo, l_amt, l_offset, l_temp);
--                l_offset := l_offset + l_amt;
--                l_raw := UTL_ENCODE.base64_decode(UTL_RAW.cast_to_raw(l_temp));
--                DBMS_LOB.append (l_blob, TO_BLOB(l_raw));
--            END LOOP;
--            EXCEPTION
--                WHEN NO_DATA_FOUND THEN
--                NULL;
--        END;
        
        
        if BFILEDATA is not null then
            pdfB64 := replace(replace(apex_web_service.blob2clobbase64(HTTPURITYPE.createuri(BFILEDATA).getblob()), chr(10), ''), chr(13), '');
        end if;
--        pdfB64 := substr(pdfB64, 0, 100);
        
--        return HTTPURITYPE.createuri(BFILEDATA).getxml().getClobVal();
--        delete from xxx_zain_pdf_b64;
--        insert into xxx_zain_pdf_b64 (b64_value) values (pdfB64);
--        commit;
--        base64encode (HTTPURITYPE.createuri(BFILEDATA).getblob(), pdfB64);
--        return '{"pdfUrl": "'||BFILEDATA||'"}';
--        return '{"pdfUrl": "'|| substr(BFILEDATA, length('http://erp-itr-02.sa.zain.com:8021/OA_CGI/FNDWRR.exe?temp_id=')+1, length(BFILEDATA)) ||'"}';
--        return pdfB64;

--        insert into xxx_zain_pdf_b64 (blob_val) values (HTTPURITYPE.createuri(BFILEDATA).getblob());
--        commit;
        
        if BFILEDATA is null then
            return '{"pdfUrl": null, "pdfBase64": null}';
        end if;
        return '{"pdfUrl": "'||BFILEDATA||'", "pdfBase64": "'||pdfB64||'"}';
--        return '{"pdfUrl": "'||BFILEDATA||'", "pdfBase64": null}';
--        return BFILEDATA;
    end;

    FUNCTION load_binary_from_url (p_url  IN  VARCHAR2) return blob
    is
      l_blob           BLOB;
    BEGIN
      l_blob := HTTPURITYPE.createuri(p_url).getblob();
    
      return l_blob;
    end;
    
    PROCEDURE USER_CHANGES_LOG(P_PERSON_ID        IN     NUMBER default null)
    is
            cursor cur_get_user is
                select p.person_id,
                    u.EMAIL_ADDRESS, u.user_name, 
                    p.effective_start_date, p.effective_end_date, p.creation_date, p.last_update_date
                from per_all_people_f p
                join fnd_user u
                on (p.person_id = u.EMPLOYEE_ID
                    and p.person_id = P_PERSON_ID
                    and sysdate between p.effective_start_date and p.effective_end_date);
            ------
            l_user_rec cur_get_user%rowtype;
    begin
            -----
            init_session(p_person_id);
            --
--            FND_GLOBAL.APPS_INITIALIZE (USER_ID        => FND_GLOBAL.USER_ID,
--                                   RESP_ID        => FND_GLOBAL.RESP_ID,
--                                   RESP_APPL_ID   => FND_GLOBAL.RESP_APPL_ID);
--    
--            MO_GLOBAL.INIT ('SQLAP');
--            MO_GLOBAL.SET_POLICY_CONTEXT ('S', FND_PROFILE.VALUE('ORG_ID'));
           ---------
           open cur_get_user;
           fetch cur_get_user into l_user_rec;
           close cur_get_user;
           ---------
           insert into xxx_zain_ess_people_updates
            (person_id,
            EMAIL, ebs_username, 
            effective_start_date, effective_end_date, creation_date, last_update_date)
            values
            (l_user_rec.person_id,
            l_user_rec.EMAIL_ADDRESS, l_user_rec.user_name, 
            l_user_rec.effective_start_date, l_user_rec.effective_end_date, l_user_rec.creation_date, l_user_rec.last_update_date);
            ---
            commit;
    end;
    
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
    ) return clob
    IS
       L_VALIDATE BOOLEAN;
       l_qualification_id              NUMBER;
       l_object_version_number         NUMBER;
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
            PER_QUALIFICATIONS_API.CREATE_QUALIFICATION (
                  p_validate                => L_VALIDATE,
                  p_effective_date          => p_effective_date,
                  p_qualification_type_id   => p_qualification_type_id,
                  p_business_group_id       => fnd_profile.VALUE ('PER_BUSINESS_GROUP_ID'),
                  p_person_id               => p_person_id,
                  p_title                   => p_title,
                  p_attendance_id           => p_attendance_id,
                  p_start_date              => p_start_date,
                  p_end_date                => p_end_date,
                  p_qualification_id        => l_qualification_id,
                  p_object_version_number   => l_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('QUALIFICATION_ID', l_qualification_id);
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
                IF l_qualification_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_qualification_id is not null then
                    APEX_JSON.write('QUALIFICATION_ID', l_qualification_id);
                else
                    APEX_JSON.write('QUALIFICATION_ID', 'null');
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
    ) return clob
    IS
       L_VALIDATE BOOLEAN;
       l_qualification_id              NUMBER;
       l_object_version_number         NUMBER;
        --------------
        cursor cur_qualification_ovn is
            SELECT object_version_number
               FROM PER_QUALIFICATIONS
               WHERE QUALIFICATION_ID=P_QUALIFICATION_ID
               ;
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
            open cur_qualification_ovn;
            fetch cur_qualification_ovn into l_object_version_number;
            close cur_qualification_ovn;
            ---
            PER_QUALIFICATIONS_API.UPDATE_QUALIFICATION (
                  p_validate                => L_VALIDATE,
                  p_effective_date          => p_effective_date,
                  p_qualification_type_id   => p_qualification_type_id,
--                  p_business_group_id       => fnd_profile.VALUE ('PER_BUSINESS_GROUP_ID'),
--                  p_person_id               => p_person_id,
                  p_title                   => p_title,
                  p_attendance_id           => p_attendance_id,
                  p_start_date              => p_start_date,
                  p_end_date                => p_end_date,
                  p_qualification_id        => P_QUALIFICATION_ID
                  ,p_object_version_number   => l_object_version_number
                  );
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('QUALIFICATION_ID', P_QUALIFICATION_ID);
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
                IF P_QUALIFICATION_ID IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if P_QUALIFICATION_ID is not null then
                    APEX_JSON.write('QUALIFICATION_ID', P_QUALIFICATION_ID);
                else
                    APEX_JSON.write('QUALIFICATION_ID', 'null');
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
    
    FUNCTION DELETE_QUALIFICATION (
        p_validate      VARCHAR2 DEFAULT 'TRUE',
        P_PERSON_ID NUMBER default null,
        P_QUALIFICATION_ID NUMBER default null
    ) return clob
    IS
       L_VALIDATE BOOLEAN;
       l_qualification_id              NUMBER;
       l_object_version_number         NUMBER;
        --------------
        cursor cur_qualification_ovn is
            SELECT object_version_number
               FROM PER_QUALIFICATIONS
               WHERE QUALIFICATION_ID=P_QUALIFICATION_ID
               ;
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
            open cur_qualification_ovn;
            fetch cur_qualification_ovn into l_object_version_number;
            close cur_qualification_ovn;
            ---
            PER_QUALIFICATIONS_API.DELETE_QUALIFICATION (
                  p_validate                => L_VALIDATE,
                  p_qualification_id        => P_QUALIFICATION_ID
                  ,p_object_version_number   => l_object_version_number
                  );
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
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
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
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
    ) return clob
    IS
       L_VALIDATE BOOLEAN;
       l_attendance_id              NUMBER;
       l_object_version_number         NUMBER;
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
            per_estab_attendances_api.CREATE_ATTENDED_ESTAB (
                  p_validate                => L_VALIDATE,
                  p_effective_date          => p_effective_date,
                  p_establishment_id        => p_establishment_id,
                  p_establishment           => p_establishment,
                  p_business_group_id       => fnd_profile.VALUE ('PER_BUSINESS_GROUP_ID'),
                  p_person_id               => p_person_id,
                  p_fulltime                => p_fulltime,
                  p_address                 => p_address,
                  p_attended_start_date     => p_attended_start_date,
                  p_attended_end_date       => p_attended_end_date,
                  p_attendance_id           => l_attendance_id,
                  p_object_version_number   => l_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('ATTENDANCE_ID', l_attendance_id);
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
                IF l_attendance_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_attendance_id is not null then
                    APEX_JSON.write('ATTENDANCE_ID', l_attendance_id);
                else
                    APEX_JSON.write('ATTENDANCE_ID', 'null');
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
    end;
    
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
    ) return clob
    IS
       L_VALIDATE BOOLEAN;
       l_object_version_number         NUMBER;
        --------------
        cursor cur_attended_estab_ovn is
            SELECT object_version_number
               FROM PER_ESTABLISHMENT_ATTENDANCES
               WHERE ATTENDANCE_ID=p_attendance_id
               ;
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
            open cur_attended_estab_ovn;
            fetch cur_attended_estab_ovn into l_object_version_number;
            close cur_attended_estab_ovn;
            ---
            per_estab_attendances_api.UPDATE_ATTENDED_ESTAB (
                  p_validate                => L_VALIDATE,
                  p_effective_date          => p_effective_date,
                  p_establishment_id        => p_establishment_id,
                  p_establishment           => p_establishment,
--                  p_person_id               => p_person_id,
                  p_fulltime                => p_fulltime,
                  p_address                 => p_address,
                  p_attended_start_date     => p_attended_start_date,
                  p_attended_end_date       => p_attended_end_date,
                  p_attendance_id           => p_attendance_id,
                  p_object_version_number   => l_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('ATTENDANCE_ID', p_attendance_id);
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
                IF p_attendance_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if p_attendance_id is not null then
                    APEX_JSON.write('ATTENDANCE_ID', p_attendance_id);
                else
                    APEX_JSON.write('ATTENDANCE_ID', 'null');
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
    end;
    
    FUNCTION DELETE_ATTENDED_ESTAB (
        p_validate      VARCHAR2 DEFAULT 'TRUE',
        P_PERSON_ID NUMBER default null,
        -------
        p_attendance_id                 NUMBER DEFAULT null
    ) return clob
    IS
       L_VALIDATE BOOLEAN;
       l_object_version_number         NUMBER;
        --------------
        cursor cur_attended_estab_ovn is
            SELECT object_version_number
               FROM PER_ESTABLISHMENT_ATTENDANCES
               WHERE ATTENDANCE_ID=p_attendance_id
               ;
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
            open cur_attended_estab_ovn;
            fetch cur_attended_estab_ovn into l_object_version_number;
            close cur_attended_estab_ovn;
            ---
            per_estab_attendances_api.DELETE_ATTENDED_ESTAB (
                  p_validate                => L_VALIDATE,
                  p_attendance_id           => p_attendance_id,
                  p_object_version_number   => l_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
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
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
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
    end;
    
    FUNCTION CREATE_OBJECTIVE (
        P_validate IN VARCHAR2 default 'TRUE',
        P_PERSON_ID NUMBER default null,
        -- p_information_type VARCHAR2 default null,
        -- p_pei_attribute_category VARCHAR2 default null,
        -------
        P_NAME              VARCHAR2 default null,
        P_START_DATE        DATE default null,
        P_OWNING_PERSON_ID  NUMBER default null,
        P_TARGET_DATE       DATE default null,
        P_ACHIEVEMENT_DATE  DATE default null,
        P_DETAIL            VARCHAR2 default null,
        P_COMMENTS          VARCHAR2 default null,
        P_SUCCESS_CRITERIA  VARCHAR2 default null,
        P_APPRAISAL_ID      NUMBER default null,
        -------
        P_SCORECARD_ID              NUMBER default null,
        P_COPIED_FROM_LIBRARY_ID    NUMBER default null,
        P_COPIED_FROM_OBJECTIVE_ID  NUMBER default null,
        P_ALIGNED_WITH_OBJECTIVE_ID NUMBER default null,
        P_NEXT_REVIEW_DATE          DATE default null,
        P_GROUP_CODE                VARCHAR2 default null,
        P_PRIORITY_CODE             VARCHAR2 default null,
        P_APPRAISE_FLAG             VARCHAR2 default null,
        P_VERIFIED_FLAG             VARCHAR2 default null,
        P_TARGET_VALUE              VARCHAR2 default null,
        P_ACTUAL_VALUE              VARCHAR2 default null,
        P_WEIGHTING_PERCENT         VARCHAR2 default null,
        P_COMPLETE_PERCENT          VARCHAR2 default null,
        P_UOM_CODE                  VARCHAR2 default null,
        P_MEASUREMENT_STYLE_CODE    VARCHAR2 default null,
        P_MEASURE_NAME              VARCHAR2 default null,
        P_MEASURE_TYPE_CODE         VARCHAR2 default null,
        P_MEASURE_COMMENTS          VARCHAR2 default null,
        P_SHARING_ACCESS_CODE       VARCHAR2 default null,
        -------
        P_EFFECTIVE_DATE date default SYSDATE,
        P_ATTRIBUTE_CATEGORY VARCHAR2 default null,
        P_ATTRIBUTE1 VARCHAR2 default null,
        P_ATTRIBUTE2 VARCHAR2 default null,
        P_ATTRIBUTE3 VARCHAR2 default null,
        P_ATTRIBUTE4 VARCHAR2 default null,
        P_ATTRIBUTE5 VARCHAR2 default null,
        P_ATTRIBUTE6 VARCHAR2 default null,
        P_ATTRIBUTE7 VARCHAR2 default null,
        P_ATTRIBUTE8 VARCHAR2 default null,
        P_ATTRIBUTE9 VARCHAR2 default null,
        P_ATTRIBUTE10 VARCHAR2 default null,
        P_ATTRIBUTE11 VARCHAR2 default null,
        P_ATTRIBUTE12 VARCHAR2 default null,
        P_ATTRIBUTE13 VARCHAR2 default null,
        P_ATTRIBUTE14 VARCHAR2 default null,
        P_ATTRIBUTE15 VARCHAR2 default null,
        P_ATTRIBUTE16 VARCHAR2 default null,
        P_ATTRIBUTE17 VARCHAR2 default null,
        P_ATTRIBUTE18 VARCHAR2 default null,
        P_ATTRIBUTE19 VARCHAR2 default null,
        P_ATTRIBUTE20 VARCHAR2 default null,
        P_ATTRIBUTE21 VARCHAR2 default null,
        P_ATTRIBUTE22 VARCHAR2 default null,
        P_ATTRIBUTE23 VARCHAR2 default null,
        P_ATTRIBUTE24 VARCHAR2 default null,
        P_ATTRIBUTE25 VARCHAR2 default null,
        P_ATTRIBUTE26 VARCHAR2 default null,
        P_ATTRIBUTE27 VARCHAR2 default null,
        P_ATTRIBUTE28 VARCHAR2 default null,
        P_ATTRIBUTE29 VARCHAR2 default null,
        P_ATTRIBUTE30 VARCHAR2 default null) RETURN CLOB
    IS
       L_VALIDATE                      BOOLEAN;
       V_EFFECTIVE_DATE                DATE := TRUNC (SYSDATE);
    --    V_OWNING_PERSON_ID              NUMBER := 54682;
       -- Output Variables
       V_WEIGHTING_OVER_100_WARNING    BOOLEAN;
       V_WEIGHTING_APPRAISAL_WARNING   BOOLEAN;
       V_OBJECTIVE_ID                  NUMBER;
       V_OBJECT_VERSION_NUMBER         NUMBER;
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
        HR_OBJECTIVES_API.CREATE_OBJECTIVE (
             P_VALIDATE                      => l_validate,
             P_EFFECTIVE_DATE                => TRUNC(P_EFFECTIVE_DATE),
             P_BUSINESS_GROUP_ID             => FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'),
             P_NAME                          => P_NAME,
             P_START_DATE                    => P_START_DATE,
             P_OWNING_PERSON_ID              => P_OWNING_PERSON_ID,
             P_TARGET_DATE                   => P_TARGET_DATE,
             P_ACHIEVEMENT_DATE              => P_ACHIEVEMENT_DATE,
             P_DETAIL                        => P_DETAIL,
             P_COMMENTS                      => P_COMMENTS,
             P_SUCCESS_CRITERIA              => P_SUCCESS_CRITERIA,
             P_APPRAISAL_ID                  => NULL,            --P_APPRAISAL_ID,
             P_ATTRIBUTE_CATEGORY            => P_ATTRIBUTE_CATEGORY,
             P_ATTRIBUTE1                    => P_ATTRIBUTE1,
             P_ATTRIBUTE2                    => P_ATTRIBUTE2,
             P_ATTRIBUTE3                    => P_ATTRIBUTE3,
             P_ATTRIBUTE4                    => P_ATTRIBUTE4,
             P_ATTRIBUTE5                    => P_ATTRIBUTE5,
             P_ATTRIBUTE6                    => P_ATTRIBUTE6,
             P_ATTRIBUTE7                    => P_ATTRIBUTE7,
             P_ATTRIBUTE8                    => P_ATTRIBUTE8,
             P_ATTRIBUTE9                    => P_ATTRIBUTE9,
             P_ATTRIBUTE10                   => P_ATTRIBUTE10,
             P_ATTRIBUTE11                   => P_ATTRIBUTE11,
             P_ATTRIBUTE12                   => P_ATTRIBUTE12,
             P_ATTRIBUTE13                   => P_ATTRIBUTE13,
             P_ATTRIBUTE14                   => P_ATTRIBUTE14,
             P_ATTRIBUTE15                   => P_ATTRIBUTE15,
             P_ATTRIBUTE16                   => P_ATTRIBUTE16,
             P_ATTRIBUTE17                   => P_ATTRIBUTE17,
             P_ATTRIBUTE18                   => P_ATTRIBUTE18,
             P_ATTRIBUTE19                   => P_ATTRIBUTE19,
             P_ATTRIBUTE20                   => P_ATTRIBUTE20,
             P_ATTRIBUTE21                   => P_ATTRIBUTE21,
             P_ATTRIBUTE22                   => P_ATTRIBUTE22,
             P_ATTRIBUTE23                   => P_ATTRIBUTE23,
             P_ATTRIBUTE24                   => P_ATTRIBUTE24,
             P_ATTRIBUTE25                   => P_ATTRIBUTE25,
             P_ATTRIBUTE26                   => P_ATTRIBUTE26,
             P_ATTRIBUTE27                   => P_ATTRIBUTE27,
             P_ATTRIBUTE28                   => P_ATTRIBUTE28,
             P_ATTRIBUTE29                   => P_ATTRIBUTE29,
             P_ATTRIBUTE30                   => P_ATTRIBUTE30,
             P_SCORECARD_ID                  => P_SCORECARD_ID,
             P_COPIED_FROM_LIBRARY_ID        => P_COPIED_FROM_LIBRARY_ID,
             P_COPIED_FROM_OBJECTIVE_ID      => NULL, --P_COPIED_FROM_OBJECTIVE_ID,
             P_ALIGNED_WITH_OBJECTIVE_ID     => P_ALIGNED_WITH_OBJECTIVE_ID,
             P_NEXT_REVIEW_DATE              => P_NEXT_REVIEW_DATE,
             P_GROUP_CODE                    => P_GROUP_CODE,
             P_PRIORITY_CODE                 => P_PRIORITY_CODE,
             P_APPRAISE_FLAG                 => P_APPRAISE_FLAG,
             P_VERIFIED_FLAG                 => P_VERIFIED_FLAG,
             P_TARGET_VALUE                  => P_TARGET_VALUE,
             P_ACTUAL_VALUE                  => P_ACTUAL_VALUE,
             P_WEIGHTING_PERCENT             => P_WEIGHTING_PERCENT,
             P_COMPLETE_PERCENT              => P_COMPLETE_PERCENT,
             P_UOM_CODE                      => P_UOM_CODE,
             P_MEASUREMENT_STYLE_CODE        => P_MEASUREMENT_STYLE_CODE,
             P_MEASURE_NAME                  => P_MEASURE_NAME,
             P_MEASURE_TYPE_CODE             => P_MEASURE_TYPE_CODE,
             P_MEASURE_COMMENTS              => P_MEASURE_COMMENTS,
             P_SHARING_ACCESS_CODE           => P_SHARING_ACCESS_CODE,
             P_WEIGHTING_OVER_100_WARNING    => V_WEIGHTING_OVER_100_WARNING,
             P_WEIGHTING_APPRAISAL_WARNING   => V_WEIGHTING_APPRAISAL_WARNING,
             P_OBJECTIVE_ID                  => V_OBJECTIVE_ID,
             P_OBJECT_VERSION_NUMBER         => V_OBJECT_VERSION_NUMBER);
    
    --              IF V_OBJECTIVE_ID IS NOT NULL THEN
                commit;
    --              END IF;
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('OBJECTIVE_ID', V_OBJECTIVE_ID);
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
                IF V_OBJECTIVE_ID IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if V_OBJECTIVE_ID is not null then
                    APEX_JSON.write('OBJECTIVE_ID', V_OBJECTIVE_ID);
                else
                    APEX_JSON.write('OBJECTIVE_ID', 'null');
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
    
    FUNCTION UPDATE_OBJECTIVE (
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
        P_EFFECTIVE_DATE date default SYSDATE) RETURN CLOB
    IS
       L_VALIDATE                      BOOLEAN;
       V_EFFECTIVE_DATE                DATE := TRUNC (SYSDATE);
    --    V_OWNING_PERSON_ID              NUMBER := 54682;
       -- Output Variables
       V_WEIGHTING_OVER_100_WARNING    BOOLEAN;
       V_WEIGHTING_APPRAISAL_WARNING   BOOLEAN;
       V_OBJECTIVE_ID                  NUMBER := P_OBJECTIVE_ID;
       V_OBJECT_VERSION_NUMBER         NUMBER;
       ----
       cursor cur_objective_obj_v_n is
            SELECT object_version_number
               FROM PER_OBJECTIVES
              WHERE OBJECTIVE_ID = P_OBJECTIVE_ID
            ;
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
        open cur_objective_obj_v_n;
        fetch cur_objective_obj_v_n into V_OBJECT_VERSION_NUMBER;
        close cur_objective_obj_v_n;
        ---
        HR_OBJECTIVES_API.UPDATE_OBJECTIVE (
             p_validate                      => L_VALIDATE,
             P_EFFECTIVE_DATE                => P_EFFECTIVE_DATE,
             -------
             p_objective_id                  => P_OBJECTIVE_ID,
             p_scorecard_id                  => P_scorecard_id,
             p_verified_flag                 => p_verified_flag,
             p_complete_percent              => p_complete_percent,
             ---
             P_COPIED_FROM_LIBRARY_ID        => P_COPIED_FROM_LIBRARY_ID,
             P_COPIED_FROM_OBJECTIVE_ID      => NULL, --P_COPIED_FROM_OBJECTIVE_ID,
             P_ALIGNED_WITH_OBJECTIVE_ID     => P_ALIGNED_WITH_OBJECTIVE_ID,
             P_NEXT_REVIEW_DATE              => P_NEXT_REVIEW_DATE,
             P_WEIGHTING_PERCENT             => P_WEIGHTING_PERCENT,
             P_NAME                          => P_NAME,
             P_START_DATE                    => P_START_DATE,
             P_TARGET_DATE                   => P_TARGET_DATE,
             P_ACHIEVEMENT_DATE              => P_ACHIEVEMENT_DATE,
             P_DETAIL                        => P_DETAIL,
             P_COMMENTS                      => P_COMMENTS,
             P_SUCCESS_CRITERIA              => P_SUCCESS_CRITERIA,
             P_GROUP_CODE                    => P_GROUP_CODE,
             P_PRIORITY_CODE                 => P_PRIORITY_CODE,
             P_APPRAISE_FLAG                 => P_APPRAISE_FLAG,
             P_TARGET_VALUE                  => P_TARGET_VALUE,
             P_ACTUAL_VALUE                  => P_ACTUAL_VALUE,
             P_UOM_CODE                      => P_UOM_CODE,
             P_MEASUREMENT_STYLE_CODE        => P_MEASUREMENT_STYLE_CODE,
             P_MEASURE_NAME                  => P_MEASURE_NAME,
             P_MEASURE_TYPE_CODE             => P_MEASURE_TYPE_CODE,
             P_MEASURE_COMMENTS              => P_MEASURE_COMMENTS,
             P_SHARING_ACCESS_CODE           => P_SHARING_ACCESS_CODE,
             -------
             p_object_version_number         => V_OBJECT_VERSION_NUMBER,
             p_weighting_over_100_warning    => V_WEIGHTING_OVER_100_WARNING,
             p_weighting_appraisal_warning   => V_WEIGHTING_APPRAISAL_WARNING);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('OBJECTIVE_ID', V_OBJECTIVE_ID);
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
                IF V_OBJECTIVE_ID IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if V_OBJECTIVE_ID is not null then
                    APEX_JSON.write('OBJECTIVE_ID', V_OBJECTIVE_ID);
                else
                    APEX_JSON.write('OBJECTIVE_ID', 'null');
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
    
    FUNCTION DELETE_OBJECTIVE (
        P_PERSON_ID NUMBER default null,
        -------
        P_OBJECTIVE_ID NUMBER,
        P_VALIDATE VARCHAR2 DEFAULT 'TRUE') RETURN CLOB
    IS
       L_VALIDATE                      BOOLEAN;
       V_EFFECTIVE_DATE                DATE := TRUNC (SYSDATE);
    --    V_OWNING_PERSON_ID              NUMBER := 54682;
       -- Output Variables
       V_WEIGHTING_OVER_100_WARNING    BOOLEAN;
       V_WEIGHTING_APPRAISAL_WARNING   BOOLEAN;
       V_OBJECTIVE_ID                  NUMBER;
       V_OBJECT_VERSION_NUMBER         NUMBER;
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
            hr_objectives_api.delete_objective(
                p_validate => L_VALIDATE,
                p_objective_id => P_OBJECTIVE_ID,
                p_object_version_number=> V_OBJECT_VERSION_NUMBER
            );
    
            commit;
    
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
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
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
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
    
    FUNCTION submit_objectives (
        P_PERSON_ID NUMBER default null,
        P_VALIDATE VARCHAR2 DEFAULT 'TRUE',
        -------
        P_SCORECARD_ID NUMBER,
        P_STATUS_CODE VARCHAR2 DEFAULT NULL) RETURN CLOB
    IS
        v_error_msg               VARCHAR2 (3000);
        l_resp_status varchar2(20);
        -----
        L_SCORECARD_ID NUMBER;
        ---
        CURSOR CUR_SCORECARD IS
            select SCORECARD_ID from PER_PERSONAL_SCORECARDS
            where SCORECARD_ID = P_SCORECARD_ID
            ;
        -----
        L_RET_CLOB                CLOB;
    BEGIN
        init_session(P_PERSON_ID);
        ---
        OPEN CUR_SCORECARD;
        FETCH CUR_SCORECARD INTO L_SCORECARD_ID;
        CLOSE CUR_SCORECARD;
        ---
        APEX_JSON.initialize_clob_output;
        APEX_JSON.open_object;
        ---
        IF L_SCORECARD_ID IS NOT NULL THEN
            if P_VALIDATE = 'FALSE' then
                update PER_PERSONAL_SCORECARDS
                set status_code = P_STATUS_CODE
                where scorecard_id = L_SCORECARD_ID;
                ---
                commit;
            end if;
            ---
            l_resp_status := 'success';
            ---
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('SCORECARD_ID', L_SCORECARD_ID);
            APEX_JSON.open_array('MESSAGES');
            APEX_JSON.close_array;
        ELSE
            l_resp_status := 'error';
            v_error_msg := 'no data found: scorecard is not exist!';
            ---
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('SCORECARD_ID', L_SCORECARD_ID);
            APEX_JSON.open_array('MESSAGES');
                APEX_JSON.open_object;
                    APEX_JSON.write('TYPE', l_resp_status);
                    APEX_JSON.write('CODE', 'NULL');
                    APEX_JSON.write('MSG_TXT', v_error_msg);
                APEX_JSON.close_object;
            APEX_JSON.close_array;
        END IF;
        ---------------------
        APEX_JSON.close_object;
        L_RET_CLOB := APEX_JSON.get_clob_output;
        APEX_JSON.free_output;
        ---------------------------------------------
        RETURN L_RET_CLOB;
    END;
    
    FUNCTION CREATE_APPRAISAL (
        p_validate      VARCHAR2 DEFAULT 'TRUE',
        P_PERSON_ID NUMBER default null,
        -------
        P_template_id                   NUMBER DEFAULT null,
        P_MAIN_APPRAISER_id             NUMBER DEFAULT null,
        P_appraisal_period_start_date   DATE DEFAULT null,
        P_appraisal_period_end_date     DATE DEFAULT null,
        P_appraisal_system_status       VARCHAR2 DEFAULT null,
        P_p_system_type                 VARCHAR2 DEFAULT null,
        P_system_params                 VARCHAR2 DEFAULT null,
        P_assessment_type_id            NUMBER DEFAULT null,
        -------
        P_EFFECTIVE_DATE date default SYSDATE) RETURN CLOB
    IS
       L_VALIDATE BOOLEAN;
       l_appraisal_id                  NUMBER;
       l_object_version_number         NUMBER;
    --    l_rating_level_id               NUMBER := 6015;
       l_assessment_type_id            NUMBER :=4002;
       l_assessment_comp_id            NUMBER;
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
        hr_appraisals_api.create_appraisal (
            p_validate                       => l_validate,
            p_effective_date                 => P_EFFECTIVE_DATE,
            p_business_group_id              => FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'),
            p_appraisal_template_id          => P_template_id,
            p_appraisee_person_id            => P_person_id,             -- Employee
            p_appraiser_person_id            => P_MAIN_APPRAISER_id,      -- Manager
            p_appraisal_date                 => P_EFFECTIVE_DATE,
            p_appraisal_period_start_date    => P_appraisal_period_start_date,
            p_appraisal_period_end_date      => P_appraisal_period_end_date,
            p_overall_performance_level_id   => NULL,--6015,
            p_appraisal_system_status        => P_appraisal_system_status,
            p_main_appraiser_id              => P_MAIN_APPRAISER_id,      -- Manager
            p_open                           => '',
            p_system_type                    => P_p_system_type,
            p_system_params                  => P_system_params,
            --changes based on the setup
            --p_attribute1                   => x,
            --p_attribute2                   => y,
            -- OUT
            p_appraisal_id                   => l_appraisal_id,
            p_object_version_number          => l_object_version_number);
            ---
            commit;
            ---
            IF (    l_appraisal_id IS NOT NULL)
                -- AND l_apprl_templ_info.assessment_type_id IS NOT NULL)
            THEN
                hr_assessments_api.create_assessment (
                    p_assessment_id                  => l_assessment_comp_id,
                    p_assessment_type_id             => p_assessment_type_id,
                    p_business_group_id              => FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'),
                    p_person_id                      => P_person_id,
                    --p_assessment_group_id,
                    p_assessment_period_start_date   => P_appraisal_period_start_date,
                    p_assessment_period_end_date     => P_appraisal_period_end_date,
                    p_assessment_date                => SYSDATE,
                    p_assessor_person_id             => P_MAIN_APPRAISER_id,
                    --to be changed for position
                    p_appraisal_id                   => l_appraisal_id,
                    --p_comments,
                    p_object_version_number          => l_object_version_number,
                    p_validate                       => FALSE,
                    p_effective_date                 => SYSDATE);
            END IF;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('APPRAISAL_ID', l_appraisal_id);
            APEX_JSON.write('ASSESSMENT_COMP_ID', l_assessment_comp_id);
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
                IF l_appraisal_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_appraisal_id is not null then
                    APEX_JSON.write('APPRAISAL_ID', l_appraisal_id);
                    APEX_JSON.write('ASSESSMENT_COMP_ID', l_assessment_comp_id);
                else
                    APEX_JSON.write('APPRAISAL_ID', 'null');
                    APEX_JSON.write('ASSESSMENT_COMP_ID', 'null');
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
    ) RETURN CLOB
    IS
       L_VALIDATE BOOLEAN;
       l_object_version_number         NUMBER;
       ---
       cursor cur_appraisal_ovn is
            SELECT object_version_number
               FROM PER_APPRAISALS
               WHERE APPRAISAL_ID=p_appraisal_id
               ;
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
        open cur_appraisal_ovn;
        fetch cur_appraisal_ovn into l_object_version_number;
        close cur_appraisal_ovn;
        ---
        hr_appraisals_api.update_appraisal (
            p_validate                       => l_validate,
            p_appraisal_id                   => p_appraisal_id,
            p_effective_date                 => P_EFFECTIVE_DATE,
            p_main_appraiser_id              => p_main_appraiser_id,
            p_appraiser_person_id            => p_appraiser_person_id,      -- Manager
            p_appraisal_date                 => P_EFFECTIVE_DATE,
            p_update_appraisal               => p_update_appraisal,
            p_appraisal_period_start_date    => P_appraisal_period_start_date,
            p_appraisal_period_end_date      => P_appraisal_period_end_date,
            p_overall_performance_level_id   => NULL,--6015,
            p_appraisal_system_status        => P_appraisal_system_status,
            p_open                           => '',
            p_status                         => p_status,
            p_comments                       => p_comments,
            p_system_type                    => P_p_system_type,
            p_system_params                  => P_system_params,
            --changes based on the setup
            --p_attribute1                   => x,
            --p_attribute2                   => y,
            -- OUT
            p_object_version_number          => l_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('APPRAISAL_ID', p_appraisal_id);
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
                IF p_appraisal_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if p_appraisal_id is not null then
                    APEX_JSON.write('APPRAISAL_ID', p_appraisal_id);
                else
                    APEX_JSON.write('APPRAISAL_ID', 'null');
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
  
  FUNCTION insert_performance_rating (
        p_person_id     NUMBER DEFAULT NULL,
        p_validate      VARCHAR2 DEFAULT NULL,
        p_objective_id  NUMBER DEFAULT NULL,
        p_appraisal_id  NUMBER DEFAULT NULL,
        p_performance_level_id NUMBER DEFAULT NULL,
        p_effective_date DATE DEFAULT SYSDATE
    ) return clob
    is
        l_performance_rating_id number;
        L_OBJECT_VERSION_NUMBER number;
        L_VALIDATE BOOLEAN;
        --------------
        v_error_msg               VARCHAR2 (3000);
        l_resp_status varchar2(20);
        -----
        L_RET_CLOB                CLOB;
    begin
            init_session(P_PERSON_ID);
            ---
            APEX_JSON.initialize_clob_output;
            APEX_JSON.open_object;
            ---
            IF P_VALIDATE = 'TRUE' THEN L_VALIDATE := TRUE; ELSE L_VALIDATE := FALSE; END IF;
            ---
            per_prt_ins.ins (
                    -- IN
                    p_person_id               => p_person_id,
                    p_objective_id            => p_objective_id,
                    p_appraisal_id            => p_appraisal_id,
                    p_performance_level_id    => p_performance_level_id,
                    p_effective_date          => p_effective_date,
                    p_validate                => L_VALIDATE,
                    -- OUT
                    p_performance_rating_id   => l_performance_rating_id,
                    p_object_version_number   => l_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('PERFORMANCE_RATING_ID', l_performance_rating_id);
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
                IF l_performance_rating_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if l_performance_rating_id is not null then
                    APEX_JSON.write('PERFORMANCE_RATING_ID', l_performance_rating_id);
                else
                    APEX_JSON.write('PERFORMANCE_RATING_ID', 'null');
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
    end;
  
  FUNCTION update_performance_rating (
        p_person_id     NUMBER DEFAULT NULL,
        p_validate      VARCHAR2 DEFAULT NULL,
        p_performance_rating_id  NUMBER DEFAULT NULL,
        p_performance_level_id NUMBER DEFAULT NULL,
        p_effective_date DATE DEFAULT SYSDATE
    ) return clob
    is
        ---
        cursor cur_pefr_obj_v_n is
            SELECT object_version_number
               FROM PER_PERFORMANCE_RATINGS
              WHERE PERFORMANCE_RATING_ID = p_performance_rating_id
            ;
        ---
        --l_performance_rating_id number;
        L_OBJECT_VERSION_NUMBER number;
        L_VALIDATE BOOLEAN;
        --------------
        v_error_msg               VARCHAR2 (3000);
        l_resp_status varchar2(20);
        -----
        L_RET_CLOB                CLOB;
    begin
            init_session(P_PERSON_ID);
            ---
            APEX_JSON.initialize_clob_output;
            APEX_JSON.open_object;
            ---
            IF P_VALIDATE = 'TRUE' THEN L_VALIDATE := TRUE; ELSE L_VALIDATE := FALSE; END IF;
            ---
            open cur_pefr_obj_v_n;
            fetch cur_pefr_obj_v_n into l_object_version_number;
            close cur_pefr_obj_v_n;
            ---
            per_prt_upd.upd (
                    -- IN
                    p_performance_rating_id   => p_performance_rating_id,
                    p_person_id               => p_person_id,
                    p_performance_level_id    => p_performance_level_id,
                    p_effective_date          => p_effective_date,
                    p_validate                => L_VALIDATE,
                    -- OUT
                    p_object_version_number   => l_object_version_number);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('PERFORMANCE_RATING_ID', p_performance_rating_id);
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
                IF p_performance_rating_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if p_performance_rating_id is not null then
                    APEX_JSON.write('PERFORMANCE_RATING_ID', p_performance_rating_id);
                else
                    APEX_JSON.write('PERFORMANCE_RATING_ID', 'null');
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
    end;
  
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
  ) return clob
  IS
        CURSOR c_emp_cur IS
          ------------------------------------------------
          SELECT ppos.period_of_service_id,
                 ppos.object_version_number,
                 papf.person_type_id,
                 ADD_MONTHS (SYSDATE, 1) END_DATE,
                 TO_DATE (
                    TO_CHAR (ADD_MONTHS (SYSDATE, 1),
                             'dd/mm/yyyy',
                             'nls_calendar=''arabic hijrah'''),
                    'dd/mm/yyyy')
                    HIJRA_DATE
            FROM per_all_people_f papf, per_periods_of_service ppos
           WHERE     papf.person_id = ppos.person_id
                 AND SYSDATE BETWEEN papf.effective_start_date
                                 AND papf.effective_end_date
                 AND SYSDATE BETWEEN ppos.date_start
                                 AND COALESCE (ppos.projected_termination_date,
                                               actual_termination_date,
                                               SYSDATE)
                 AND papf.person_id = P_PERSON_ID;
        -------------
        c_emp_rec c_emp_cur%rowtype;
        -------------
        l_validate                       BOOLEAN := FALSE;
       l_supervisor_warning             BOOLEAN;
       l_event_warning                  BOOLEAN;
       l_interview_warning              BOOLEAN;
       l_review_warning                 BOOLEAN;
       l_recruiter_warning              BOOLEAN;
       l_asg_future_changes_warning     BOOLEAN;
       l_f_asg_future_changes_warning   BOOLEAN;
       l_pay_proposal_warning           BOOLEAN;
       l_dod_warning                    BOOLEAN;
       l_org_now_no_manager_warning     BOOLEAN;
       l_entries_changed_warning        VARCHAR2 (255);
       l_f_entries_changed_warning      VARCHAR2 (255);
       l_alu_change_warning             VARCHAR2 (255);
       -------
       -------
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
            open c_emp_cur;
            fetch c_emp_cur into c_emp_rec;
            close c_emp_cur;
            ---
            hr_periods_of_service_api.update_pds_details (
                    p_validate                      => l_validate,
                    p_effective_date                => p_effective_date,
                    p_period_of_service_id          => c_emp_rec.period_of_service_id,
                    p_termination_accepted_person   => NULL,
                    p_accepted_termination_date     => NULL,
                    p_object_version_number         => c_emp_rec.object_version_number,
                    p_comments                      => p_comments,
                    p_leaving_reason                => p_leaving_reason, -- 'RESIGNATION',
                    p_notified_termination_date     => p_resignation_date,
                    p_projected_termination_date    => NULL,
                    p_actual_termination_date       => p_last_working_date,
                    p_last_standard_process_date    => p_resignation_date,
                    p_final_process_date            => NULL,
                    p_attribute_category            => NULL,
                    p_attribute1                    => NULL,
                    p_attribute2                    => NULL,
                    p_attribute3                    => NULL,
                    p_attribute4                    => NULL,
                    p_attribute5                    => NULL,
                    p_attribute6                    => NULL,
                    p_attribute7                    => NULL,
                    p_attribute8                    => NULL,
                    p_attribute9                    => p_resignation_reason,
                    p_attribute10                   => NULL,
                    p_attribute11                   => p_sim_card,
                    p_attribute12                   => NULL,
                    p_attribute13                   => NULL,
                    p_attribute14                   => NULL,
                    p_attribute15                   => NULL,
                    p_attribute16                   => NULL,
                    p_attribute17                   => NULL,
                    p_attribute18                   => NULL,
                    p_attribute19                   => NULL,
                    p_attribute20                   => NULL,
                    p_pds_information_category      => NULL, -- 'SA'
                    p_pds_information1              => NULL, -- TO_CHAR (c_emp_rec.HIJRA_DATE,'YYYY/MM/DD'),
                    p_pds_information2              => NULL,
                    p_pds_information3              => NULL,
                    p_pds_information4              => NULL,
                    p_pds_information5              => NULL,
                    p_pds_information6              => NULL,
                    p_pds_information7              => NULL,
                    p_pds_information8              => NULL,
                    p_pds_information9              => NULL,
                    p_pds_information10             => NULL,
                    p_pds_information11             => NULL,
                    p_pds_information12             => NULL,
                    p_pds_information13             => NULL,
                    p_pds_information14             => NULL,
                    p_pds_information15             => NULL,
                    p_pds_information16             => NULL,
                    p_pds_information17             => NULL,
                    p_pds_information18             => NULL,
                    p_pds_information19             => NULL,
                    p_pds_information20             => NULL,
                    p_pds_information21             => NULL,
                    p_pds_information22             => NULL,
                    p_pds_information23             => NULL,
                    p_pds_information24             => NULL,
                    p_pds_information25             => NULL,
                    p_pds_information26             => NULL,
                    p_pds_information27             => NULL,
                    p_pds_information28             => NULL,
                    p_pds_information29             => NULL,
                    p_pds_information30             => NULL,
                    p_org_now_no_manager_warning    => l_org_now_no_manager_warning,
                    p_asg_future_changes_warning    => l_f_asg_future_changes_warning,
                    p_entries_changed_warning       => l_entries_changed_warning);
            ---
            commit;
            ---
            l_resp_status := 'success';
            APEX_JSON.write('STATUS', l_resp_status);
            APEX_JSON.write('PERIOD_OF_SERVICE_ID', c_emp_rec.period_of_service_id);
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
                IF c_emp_rec.period_of_service_id IS NOT NULL THEN
                    l_resp_status := 'warning';
                ELSE
                    l_resp_status := 'error';
                END IF;
                ---------------------
                APEX_JSON.write('STATUS', l_resp_status);
                if c_emp_rec.period_of_service_id is not null then
                    APEX_JSON.write('PERIOD_OF_SERVICE_ID', c_emp_rec.period_of_service_id);
                else
                    APEX_JSON.write('PERIOD_OF_SERVICE_ID', 'null');
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
            
            IF l_OVN IS NOT NULL THEN
                SELECT object_version_number
                INTO l_contact_rel_ovn
                FROM per_contact_relationships
                WHERE CONTACT_RELATIONSHIP_ID = p_contact_relationship_id;
                ---
                IF p_addEmergency_flag = 'Y' THEN
                    l_contact_type := 'EMRG';
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
                    l_contact_type := p_contact_type;
                    hr_contact_rel_api.update_contact_relationship(p_validate => L_VALIDATE,
                                                      p_effective_date => SYSDATE,
                                                      p_contact_relationship_id => p_contact_relationship_id,
                                                      p_contact_type => l_contact_type,
                                                      p_primary_contact_flag => p_primary_contact_flag,
                                                      P_PERSONAL_FLAG => P_PERSONAL_FLAG,
                                                      p_object_version_number => l_contact_rel_ovn);
                END IF;
               
            END IF;
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