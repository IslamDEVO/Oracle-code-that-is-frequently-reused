SET SERVEROUTPUT ON;

DECLARE
    ln_address_id             per_addresses.address_id%TYPE DEFAULT 10965;
    ln_object_version_number  per_addresses.object_version_number%TYPE DEFAULT 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE(xxx_zain_ess_pkg.delete_person_address(p_validate => 'FALSE',
                                               p_address_id => 10980
                                               ));
        

    dbms_output.put_line('Success : ');    

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error raised : ' || sqlerrm);
END;