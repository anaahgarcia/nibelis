set serveroutput on ;
set define off ;
declare
  vSQL       VARCHAR2(32000) := '';
  vUSER_NAME       VARCHAR2(30) := 'MGUSER';
  vTABLE_NAME      VARCHAR2(30) := 'pers_edit_gestion_avancee';
  vCOLUMN_NAME     VARCHAR2(30) := 'DATE_ANCI_CADR_FORF';
  vCOLUMN_TYPE     VARCHAR2(30) := 'VARCHAR2(255)';  -- NUMBER/VARCHAR2/DATE/FLOAT/CLOB
begin
  -- Si la colonne n'existe pas (compteur = 0)
  if fct_ddl_exist('COLUMN',vUSER_NAME,vCOLUMN_NAME,vTABLE_NAME) = 0 then
    -- Script de création de la colonne
    vSQL := 'alter table '||vUSER_NAME||'.'||vTABLE_NAME||' add ('||vCOLUMN_NAME||' '||vCOLUMN_TYPE ||') ' ;
    -- Debug (à décommenter si besoin)
    --dbms_output.put_line(vSQL);
    -- Exécution de la création
    execute immediate vSQL;
    dbms_output.put_line('[OK] La colonne '||vUSER_NAME||'.'||vTABLE_NAME||'.'||vCOLUMN_NAME||' est créée !');
  -- Si la colonne n'existe pas
  else
    dbms_output.put_line('[ALERT] La colonne '||vUSER_NAME||'.'||vTABLE_NAME||'.'||vCOLUMN_NAME||' existe déjà !');
  end if;
exception
  when others then
    dbms_output.put_line('[ERROR] Il y a une erreur durant la construction de la colonne '||vUSER_NAME||'.'||vTABLE_NAME||'.'||vCOLUMN_NAME);
    dbms_output.put_line(SQLERRM);
end;
/