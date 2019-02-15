DROP TYPE AUDIT_RESULT_LIST
/

DROP TYPE AUDIT_RESULT_TYPE
/

CREATE OR REPLACE
TYPE AUDIT_RESULT_TYPE AS OBJECT(
 IC                 NUMBER(10)
);
/

CREATE OR REPLACE
TYPE AUDIT_RESULT_LIST AS TABLE OF AUDIT_RESULT_TYPE;
/


DECLARE
  v_audit_list        AUDIT_RESULT_LIST;
  v_audit_list2       AUDIT_RESULT_LIST;
BEGIN
     SELECT AUDIT_RESULT_TYPE(IC)
        BULK COLLECT INTO v_audit_list
    FROM tb_audit_rank_result
      WHERE ic = 1
      AND id IN (SELECT MAX(id) FROM tb_audit_rank_result)
    ORDER BY end_date ASC;

    dbms_output.put_line('Total lista v_audit_list : '||v_audit_list.count);

  --Remove-se as categorias que n?o pertencem ao perfil
  SELECT AUDIT_RESULT_TYPE(ltable.ic
                          )
    BULK COLLECT INTO v_audit_list2
    FROM TABLE(CAST(v_audit_list AS AUDIT_RESULT_LIST)) ltable
   WHERE rownum < 5;

  dbms_output.put_line('Total lista v_audit_list2 : '||v_audit_list2.count);

     
END;
/



SET SERVEROUTPUT ON
DECLARE
  vdados varchar2(32767);
  v_ic NUMBER;
  v_ics AUDIT_RESULT_LISTS_TYPE;
  --Types locais
  type type_data_list is varray(800) of varchar2(32767);
  v_data_list  type_data_list := type_data_list(' ');

  --Cursor
  cursor c_cursor is
    --select 'IC: '|| ic || ' DATA:'|| to_char(trunc(end_date), 'yyyy-mm-dd') || ' Resul:'|| result
    select ic
    FROM tb_audit_rank_result
    where ic = 1
    and id in (select max(id) from tb_audit_rank_result)
    order by end_date asc;

  BEGIN
      OPEN c_cursor;
      FETCH c_cursor BULK COLLECT INTO v_data_list;

   select ic  BULK COLLECT INTO v_ics
   FROM TABLE(CAST(v_data_list AS AUDIT_RESULT_LISTS_TYPE ));

     /*select * from 
         FOR r IN 1..v_data_list.COUNT()
          LOOP
            dbms_output.put_line(v_data_list(r) );
          END LOOP;
          */
END;
/


DROP TYPE AUDIT_RESULT_LIST_TYPE;
DROP TYPE AUDIT_RESULT_LISTS_TYPE;

CREATE OR REPLACE
TYPE AUDIT_RESULT_TYPE AS OBJECT(
 IC                 NUMBER(10)
);
/

CREATE OR REPLACE
TYPE AUDIT_RESULT_LIST AS TABLE OF AUDIT_RESULT_TYPE;
/

select * 
 from (
select  IC, RESULT, end_date FROM tb_audit_rank_result
where ic = 369
and id in (select max(id) from tb_audit_rank_result)
)
PIVOT (
 COUNT(end_date)
      for end_date in
       (
        to_date('2018-12-03', 'yyyy-mm-dd'),
        to_date('2018-12-04', 'yyyy-mm-dd'),
        to_date('2018-12-05', 'yyyy-mm-dd'),
        to_date('2018-12-06', 'yyyy-mm-dd')
        )
);
