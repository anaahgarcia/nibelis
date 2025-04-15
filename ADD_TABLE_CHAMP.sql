set serveroutput on;
set define off;
declare
  iNOMB           int;
  iNOMB_INSE      int;
begin
 
  ------------------------------------
  -- CONVERSATION_DEFA              --
  ------------------------------------
  select count(*) into iNOMB from MGUSER.conversation_defa where conv = 'GestionListeGestionAvancee0' and cham='DISP_POLI_PUBL_CONV';
  if iNOMB = 0 then
    begin
      insert into MGUSER.conversation_defa
              (CONV, CHAM, AFFI, LIBE, ORDR, OBLI, PARA_SAIS, PARA_AFFI, PARA_OBLI, PARA_CACH, LANG) 
       values
              ('GestionListeGestionAvancee0', 'DISP_POLI_PUBL_CONV', 'N', 'Dispositif de politique publique et conventionnel', 214, 0, 1, 0, 0, 1, 'FR');
 
      iNOMB_INSE := sql%rowcount;
      if iNOMB_INSE = 1 then 
        dbms_output.put_line('MGUSER.conversation_defa : CONV = ''GestionListeGestionAvancee0'' and CHAM = ''POLI_PUBL_CONV'' insertion OK');
      else
        dbms_output.put_line('MGUSER.conversation_defa : CONV = ''GestionListeGestionAvancee0'' and CHAM = ''POLI_PUBL_CONV'' pas insertion ');
      end if;
      exception
        when others then
          dbms_output.put_line('MGUSER.conversation_defa : CONV = ''GestionListeGestionAvancee0'' and CHAM = ''POLI_PUBL_CONV'' insertion KO : '||SQLCODE||' - '||SQLERRM);
    end;
          
  else
    dbms_output.put_line('MGUSER.conversation_defa : CONV = ''GestionListeGestionAvancee0'' and CHAM = ''POLI_PUBL_CONV'' existant');
  end if;
 
end;
/