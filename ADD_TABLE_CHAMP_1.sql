set serveroutput on;
set define off;
declare
  iNOMB           int;
  iNOMB_INSE      int;
begin

  ------------------------------------
  -- LISTE_ETAT_COLONNES_DEFA       --
  ------------------------------------
  select count(*) into iNOMB from MGUSER.conversation_defa where conv = 'GestionListeGestionAvancee0' and cham='DATE_ANCI_CADR_FORF';
  if iNOMB = 0 then
    begin
      insert into MGUSER.conversation_defa
              (CONV,CHAM,AFFI,LIBE,ORDR, OBLI, PARA_SAIS, PARA_AFFI, PARA_OBLI, PARA_CACH, LANG) 
       values
              ('GestionListeGestionAvancee0','DATE_ANCI_CADR_FORF','N','Date d''ancienneté en tant que cadre forfait jour',215, 0, 1, 0, 0, 1, 'FR');
      iNOMB_INSE := sql%rowcount;
      if iNOMB_INSE = 1 then 
        dbms_output.put_line('MGUSER.LISTE_ETAT_COLONNES_DEFA : ETAT = ''EditionSalarie'' and id_carachamp = ''GEAV_DATE_ANCI_CADR_FORF'' insertion OK');
      else
        dbms_output.put_line('MGUSER.LISTE_ETAT_COLONNES_DEFA : ETAT = ''EditionSalarie'' and id_carachamp = ''GEAV_DATE_ANCI_CADR_FORF'' pas insertion ');
      end if;
      exception
        when others then
          dbms_output.put_line('MGUSER.LISTE_ETAT_COLONNES_DEFA : ETAT = ''EditionSalarie'' and id_carachamp = ''GEAV_DATE_ANCI_CADR_FORF'' insertion KO : '||SQLCODE||' - '||SQLERRM);
    end;
  else
    dbms_output.put_line('MGUSER.LISTE_ETAT_COLONNES_DEFA : ETAT = ''EditionSalarie'' and id_carachamp = ''GEAV_DATE_ANCI_CADR_FORF'' existant');
  end if;
 
 
end;
/