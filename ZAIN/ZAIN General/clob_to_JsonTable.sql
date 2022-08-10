        SELECT  ErrorCode
        FROM JSON_TABLE ('{
"STATUS":"error"
,"CONTACT_RELATIONSHIP_ID":null
,"MESSAGES":[
{
"TYPE":"error"
,"CODE":"NULL"
,"MSG_TXT":"ORA-20001: A relationship of this type already exists between these two people at this time."
}
]
}','$'
        COLUMNS ( ErrorCode VARCHAR2 ( 200 ) PATH '$.STATUS'
            )
        );

--{
--"STATUS":"error"
--,"CONTACT_RELATIONSHIP_ID":null
--,"MESSAGES":[
--{
--"TYPE":"error"
--,"CODE":"NULL"
--,"MSG_TXT":"ORA-20001: A relationship of this type already exists between these two people at this time."
--}
--]
--}