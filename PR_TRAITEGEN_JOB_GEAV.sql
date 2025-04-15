create or replace procedure        PR_TRAITEGEN_JOB_GEAV (
  -- EN  2022 08 03: T148434 Ajout du filtre "Situations" (présents, partis, bloqués, payés, ...)
  -- EN  2018 07 13: T72864 Ajout des filtres et des champs type de salarié (permanent, intermittent, ...) et nature de contrat (CDI, CDD, ...)
  -- FS  2016 08 17: T46987 : Responsable hierarchique de l'onglet affectaction dans la gestion avancée
  -- AMB 2016 03 22: Optimisation de la répartition analytique, l'initialisation n'est pas faite sur les périodes passées déjà calculées.
  -- AMB 2016 03 16: Ajout du pourcentage d'avancement. un impact sur les perf doit être analysé.
  -- AMB 2016 02 25: optimisation sur récupération des constantes échelon, niveau, date ancienneté (fct_hc au lieu d'un select avec max etc.
  -- FSA 2016 02 25: Mise en place de l'enregistrement du para_edit pour le suivi performance
  -- ML 2016 01 18 T46079 : Ajout de la spécificité vacataire / intermittent / pigiste (CALC_AUTO_INDE_CONG_PREC)
  -- ZA 2015 03 26 T39008 : Ajout de la commune, du département et du pays de naissance du salarié
  -- ZA 2015 02 06 T37403 : Ajout des codes analytiques provénant des plans analytiques
  -- ZA 2015 02 06 T36222 : Ajout du champs Date de début de contrat (DATE_DEBU_CONT)
  -- ZA 2014 07 30 T31981 : Ajout du champs Numéro de congés spectacle de la fiche salarié simple
  pID_SOCI     in  varchar2,
  pID_LOGI     in  varchar2,
  pID_PARA     in  varchar2,
  pID_LIST     in  varchar2
)
is
   vAFFI_DERN_VALE varchar2(1);
   vVALE_DERN_PERI varchar2(255);
   vDERN_PERI_AFFI varchar2(10);
   vNUME_COMP_BRUT varchar2(100);
   vLIBE_COMP_BRUT varchar2(100);
   vNUME_COMP_PAYE varchar2(100);
   vLIBE_COMP_PAYE varchar2(100);
   vDERN_VALE_RUBR FLOAT;
   iNB   int;
   NOMB_LIGN int;
   NUME_LIGN int default 0;
   POUR_AVAN int default 0;
   DATE_PREM_LIGN date;
   TEMP_REST number;
   vETAT constant varchar2(19) default 'ListeGestionAvancee';
   vLIBE_EMPL_CONV varchar2(500);

   vDIPL varchar2(255);
   vDATE_DEPA varchar2(10);

   vVALE_CONG_REST_N number;
   vVALE_CONG_ACQU_N number;
   vVALE_CONG_PRIS_N number;
   vCONG_REST_N      number;
   vEVOL_REMU_SUPP_COTI number;
   vNOMB_TR_CALC_PERI number;
   nVALE_SPEC_TR     number;
   vMODE_TR          varchar2(500);
   vVALE_SPEC_TR     varchar2(500);
   vTR_ETAB          varchar2(500);
   vTR_1             varchar2(500);
   vTR_2             varchar2(500);
   vTR_3             varchar2(500);
   vTR_4             varchar2(500);
   vTR_5             varchar2(500);
   vTR_6             varchar2(500);
   vTR_7             varchar2(500);
   vTR_8             varchar2(500);
   vTR_9             varchar2(500);
   vTR_10             varchar2(500);
   vTR_11             varchar2(500);
   vTR_12             varchar2(500);

   fCONG_PRIS_ANNE_N float;
   fHORAIRE           float;
   fHORAIRE_MENS_ETAB float;
   fHORAIRE_MENS_SOCI float;
   vETP_CCN51         varchar2(500);

   oRTT                     profil_paye_rtt%rowtype;
   iID_PROF                 NUMBER;
   type ti_PROFIL_PAYE_RTT  is table of PROFIL_PAYE_RTT%rowtype index by binary_integer;
   rPROF_RTT                profil_paye_rtt%rowtype;
   ri_S_PROFIL_PAYE_RTT     ti_PROFIL_PAYE_RTT;
   dDATE_FIN_CONT           date;



   ri_SOCIETES pack_types.ti_VARCHAR;

   type ti_SALARIE is table of salarie_table%rowtype index by binary_integer;
   ri_S_SALARIES ti_SALARIE;
   oRESPONSABLE salarie_table%rowtype;
   oDELEGUE     salarie_table%rowtype;
   oTRANSFERT   salarie_table%rowtype;

   type ti_MODBULL is table of modbull%rowtype index by binary_integer;
   ri_S_MODBULL      ti_MODBULL;
   ri_S_MODBULL_STAG ti_MODBULL;

   cursor c_FORMULE is select * from type_formule;
   type ti_FORMULE is table of c_FORMULE%rowtype index by binary_integer;
   ri_B_FORMULE    ti_FORMULE;
   ri_S_FORMULE    ti_FORMULE;

   cursor c_PAYS is select code_iso,libe_pays,gentile_f from geo_pays;
   rv_S_PAYS        pack_types.tv_varchar;
   rv_S_PAYS_GENT_F pack_types.tv_varchar;

   cursor c_GEO_DEPARTEMENT is select * from geo_departement;
   type tv_GEO_DEPARTEMENT is table of varchar2(255) index by varchar2(4);
   rv_S_GEO_DEPARTEMENT tv_GEO_DEPARTEMENT;

   cursor c_EMPLOIS_51 is select distinct id_empl_conv_51 as id_empl,libe from pa_emploi_conv_51;
   rv_S_EMPLOIS_51  pack_types.tv_varchar;

   cursor c_MOTIFDEP is select * from motifdep;
   type ti_MOTIFDEP is table of c_MOTIFDEP%rowtype index by binary_integer;
   type tv_MOTIFDEP is table of c_MOTIFDEP%rowtype index by varchar2(100);
   ri_B_MOTIFDEP    ti_MOTIFDEP;
   rv_S_MOTIFDEP    tv_MOTIFDEP;
   vCUMU varchar2(1);
   cursor c_MOTI_RECR_CDD is select * from moti_recr_cdd;
   type ti_MOTI_RECR_CDD is table of c_MOTI_RECR_CDD%rowtype index by binary_integer;
   type tv_MOTI_RECR_CDD is table of c_MOTI_RECR_CDD%rowtype index by varchar2(100);
   ri_B_MOTI_RECR_CDD    ti_MOTI_RECR_CDD;
   rv_S_MOTI_RECR_CDD    tv_MOTI_RECR_CDD;

   vLIBE_MOTI_RECR_CDD varchar2(600);

   cursor c_MOTI_RECR_CDD2 is select * from moti_recr_cdd;
   type ti_MOTI_RECR_CDD2 is table of c_MOTI_RECR_CDD2%rowtype index by binary_integer;
   type tv_MOTI_RECR_CDD2 is table of c_MOTI_RECR_CDD2%rowtype index by varchar2(100);
   ri_B_MOTI_RECR_CDD2    ti_MOTI_RECR_CDD2;
   rv_S_MOTI_RECR_CDD2    tv_MOTI_RECR_CDD2;

   vLIBE_MOTI_RECR_CDD2 varchar2(600);

   cursor c_MOTI_RECR_CDD3 is select * from moti_recr_cdd;
   type ti_MOTI_RECR_CDD3 is table of c_MOTI_RECR_CDD3%rowtype index by binary_integer;
   type tv_MOTI_RECR_CDD3 is table of c_MOTI_RECR_CDD3%rowtype index by varchar2(100);
   ri_B_MOTI_RECR_CDD3    ti_MOTI_RECR_CDD3;
   rv_S_MOTI_RECR_CDD3    tv_MOTI_RECR_CDD3;

   vLIBE_MOTI_RECR_CDD3 varchar2(600);

   type tv_SALA_PLAN_ANAL is table of SALARIE_ANALYTIQUE%rowtype index by varchar2(100);
   rv_S_SALA_PLAN_ANAL   tv_SALA_PLAN_ANAL;
   oSALA_PLAN_ANAL       SALARIE_ANALYTIQUE%rowtype;

   cursor cMUTUELLES (pSOCIETE in int,pPERIODE in date,pFILTER_ZEROFILL in varchar2, pFILTER_PREFIX_SAL in varchar2, pFILTER_PREFIX_PAT in varchar2, pFILTER_PREFIX_CODE in varchar2, pFILTER_TYPE_MUTU in varchar2, pFILTER_INDEX_MAX in varchar2) is
     select
        d.id_soci                as ID_SOCI ,
        d.peri                   as PERI    ,
        d.indexe                 as INDE    ,
        d.prefix_code||
        case d.zerofill
        when 'O' then trim(to_char(d.indexe,'09'))
        else               to_char(d.indexe)
        end                      as CODE      ,
        parse_float(d.vale_sala) as VALE_SALA ,
        parse_float(d.vale_patr) as VALE_PATR ,
        case when d.description is not null then d.description else '' end as DESCRIPTION
     from (
        select
           h.id_soci as id_soci ,
           h.peri    as peri    ,
           parse_int(replace( replace( h.code_cons , params.filter_prefix_sal   ) , params.filter_prefix_pat )) as indexe,
           max(trim(h.vale_char)) as description,
           sum(case when substr(h.code_cons,1, length( params.filter_prefix_sal))=params.filter_prefix_sal then h.vale end) as VALE_SALA,
           sum(case when substr(h.code_cons,1, length( params.filter_prefix_pat))=params.filter_prefix_pat then h.vale end) as VALE_PATR,
           case max(params.filter_type_mutu )
           when 'TAUX' then 'DEC4'
           else             'DEC2'
           end as vale_format,
           case max(params.filter_type_mutu )
           when 'TAUX' then '%'
           else             'EUR'
           end as vale_unit ,
           max(params.filter_prefix_code ) as prefix_code,
           max(params.filter_zerofill )    as zerofill
        from hist_cons_soci h, (
           select
               pFILTER_ZEROFILL    as FILTER_ZEROFILL    , -- O|N
               pFILTER_PREFIX_SAL  as FILTER_PREFIX_SAL  , -- 'TXMUSAL'
               pFILTER_PREFIX_PAT  as FILTER_PREFIX_PAT  , -- 'TXMUPAT'
               pFILTER_PREFIX_CODE as FILTER_PREFIX_CODE , -- 'TXMU'
               pFILTER_TYPE_MUTU   as FILTER_TYPE_MUTU   , -- 'TAUX'
               pFILTER_INDEX_MAX   as FILTER_INDEX_MAX     -- 20
           from dual
        ) params
        where h.id_soci = pSOCIETE
          and h.peri    = pPERIODE
          and (
                (
                     substr(h.code_cons,1, length( params.filter_prefix_sal))=params.filter_prefix_sal
                 and parse_int(substr(h.code_cons, length( params.filter_prefix_sal)+1)) <= params.filter_index_max
                )
                or
                (
                     substr(h.code_cons,1, length( params.filter_prefix_pat))=params.filter_prefix_pat
                 and parse_int(substr(h.code_cons, length( params.filter_prefix_pat)+1)) <= params.filter_index_max
                )
          )
        group by h.id_soci, h.peri, parse_int(replace( replace( h.code_cons , params.filter_prefix_sal   ) , params.filter_prefix_pat ))
     ) d
     where d.vale_sala != 0 or d.vale_patr != 0  or d.description is not null
   ;
   type ti_MUTU is table of cMUTUELLES%rowtype index by binary_integer;
   type tv_MUTU is table of cMUTUELLES%rowtype index by varchar2(100);
   ri_MUTU           ti_MUTU;
   ri_MUTU_SOUM_TAUX tv_MUTU;
   ri_MUTU_SOUM_MONT tv_MUTU;
   ri_MUTU_NOSO_TAUX tv_MUTU;
   ri_MUTU_NOSO_MONT tv_MUTU;

   vID_PARA number;
   vID_LIST number;

   type tv_BANQ is table of pack_embeded.r_banq index by varchar2(200);
   rv_BANQ       tv_BANQ;
   oBANQ_01      pack_embeded.r_BANQ;
   oBANQ_02      pack_embeded.r_BANQ;
   oBANQ_01_HIST pack_embeded.r_BANQ;
   oBANQ_02_HIST pack_embeded.r_BANQ;

   tSOCI    table_of_varchar2_255;
   tDIVI    table_of_varchar2_255;
   tPERS    table_of_varchar2_255;
   tSALA    table_of_varchar2_255;
   tETAB    table_of_varchar2_255;
   tDEPA    table_of_varchar2_255;
   tSERV    table_of_varchar2_255;
   tPERI    table_of_varchar2_255;
   tANAL    table_of_varchar2_255;
   tTYPE    table_of_varchar2_255;
   tNATU_CONT table_of_varchar2_255;
   tCAIS    table_of_varchar2_255;
   tCATE    table_of_varchar2_255;
   tEQUI    table_of_varchar2_255;
   tGROU_SAIS table_of_varchar2_255;
   tREGR    table_of_varchar2_255;
   tUNIT    table_of_varchar2_255;
   tMODE_BULL  table_of_varchar2_255;



   iSOCI    int;
   iSALA    int;
   iETAB    int;
   iDEPA    int;
   iSERV    int;
   iPERI    int;
   iANAL    int;
   iTYPE    int;
   iNATU_CONT int;
   iCAIS    int;
   iCATE    int;
   iDIVI    int;
   iEQUI    int;
   iGROU_SAIS int;
   iREGR    int;
   iUNIT    int;
   iMODE_BULL int;
   oSociOrig societe%rowtype;

   vDEPA_NAIS           varchar2(255);

   vNIVEAU              varchar2(100);
   vECHELON             varchar2(100);
   vGROU_CONV           varchar2(100);
   vPOSITION            varchar2(100);
   vCOTA                varchar2(100);
   vCLAS                varchar2(100);
   vSEUI                varchar2(100);
   vPALI                varchar2(100);
   vGRAD                varchar2(100);
   vDEGR                varchar2(100);
   vFILI                varchar2(100);
   vLIBE_FILI           varchar2(255);
   vSECT_PROF           varchar2(100);
   vLIBE_SECT_PROF      varchar2(255);
   iBULLMOD             int;
   fCOEFFIC             float;
   vCOEFFIC             varchar2(500);
   fINDICE              float;
   vINDICE              varchar2(500);
   fDATEANCI_PROF       float;
   fDATEANCI_CADR_FORF  float;
   fDATE_SIGN_CONV_STAG float;
   fDATE_REFE_01        float;
   fDATE_REFE_02        float;
   fDATE_REFE_03        float;
   fDATE_REFE_04        float;
   fDATE_REFE_05        float;
   

   oList    liste_gestion_avancee%rowtype;
   oList_2  liste_gestion_avancee_2%rowtype;
   oPara    para_edit%rowtype;
   oGeav    pers_edit_gestion_avancee%rowtype;
   oEdit    pers_edit_gestion_avancee%rowtype;

   vAUTO_GEST_LIST_PERS varchar2(1);

   vRESP_HIER_NOM  varchar2(255);
   vRAPP_HORA_ARRO float;
   vRESP_HIER_PREN varchar2(255);
   vRESP_HIER_MAIL varchar2(255);
   vFILI_CONV      varchar2(255);
   iRESP_HIER_DELE int;

   dPERI_COUR date;
   dPREM_PERI date;
   dDATE_ANCI_CADR_FORF  date;

   iLOOP_ANAL int         default 0;

   iErrInterne            int;
   sErrInfoIntere         varchar2(32000);
   iErrIdInterne          varchar2(32000);

   iID_LOGI               number;
   iID_SOCI               number;

   iID_SUIV_PROC          number;

   -- pour le filtre "Situation" (T148434)
   vSITU_STAT_PRES        char(1) := 'N'; -- Salariés présents
   vSITU_STAT_PART        char(1) := 'N'; -- Salariés partis
   vSITU_VIRE_O           char(1) := 'N'; -- Salariés bloqués
   vSITU_VIRE_N           char(1) := 'N'; -- Salariés non bloqués
   vSITU_PAYE_O           char(1) := 'N'; -- Salariés payés
   vSITU_PAYE_N           char(1) := 'N'; -- Salariés non payés
   vSITU_REGU_O           char(1) := 'N'; -- Bulletins de régularisation
   vSITU_REGU_N           char(1) := 'N'; -- Bulletins normaux
   tSITU                  table_of_varchar2_255;
   iSITU                  int;
   tPERI_SOCI             table_of_varchar2_255;

   vNOMB_JOUR_CONG_ANCI           varchar2(100);
   vMONT_ANCI_PA           varchar2(100);

   function fct__calcul(
      vCALC_XX_OPERANDE_1  varchar2,
      vCALC_XX_OPERATEUR   varchar2,
      vCALC_XX_OPERANDE_2  varchar2,
      fCALC_XX_MULT        float,
      oROW_GEAV            pers_edit_gestion_avancee%rowtype
   )return float
   is
      fCALC_XX_OPERANDE_1 float;
      fCALC_XX_OPERANDE_2 float;
      fCALC_RESULT        float;
      function fct__get_operande(
         vCALC_XX_OPERANDE_X varchar2
      )return float
      as
         fOPERANDE float;
      begin
         if    vCALC_XX_OPERANDE_X='CONS_01' then fOPERANDE:=oROW_GEAV.cons_01;
         elsif vCALC_XX_OPERANDE_X='CONS_02' then fOPERANDE:=oROW_GEAV.cons_02;
         elsif vCALC_XX_OPERANDE_X='CONS_03' then fOPERANDE:=oROW_GEAV.cons_03;
         elsif vCALC_XX_OPERANDE_X='CONS_04' then fOPERANDE:=oROW_GEAV.cons_04;
         elsif vCALC_XX_OPERANDE_X='CONS_05' then fOPERANDE:=oROW_GEAV.cons_05;
         elsif vCALC_XX_OPERANDE_X='CONS_06' then fOPERANDE:=oROW_GEAV.cons_06;
         elsif vCALC_XX_OPERANDE_X='CONS_07' then fOPERANDE:=oROW_GEAV.cons_07;
         elsif vCALC_XX_OPERANDE_X='CONS_08' then fOPERANDE:=oROW_GEAV.cons_08;
         elsif vCALC_XX_OPERANDE_X='CONS_09' then fOPERANDE:=oROW_GEAV.cons_09;
         elsif vCALC_XX_OPERANDE_X='CONS_10' then fOPERANDE:=oROW_GEAV.cons_10;
         elsif vCALC_XX_OPERANDE_X='CONS_11' then fOPERANDE:=oROW_GEAV.cons_11;
         elsif vCALC_XX_OPERANDE_X='CONS_12' then fOPERANDE:=oROW_GEAV.cons_12;
         elsif vCALC_XX_OPERANDE_X='CONS_13' then fOPERANDE:=oROW_GEAV.cons_13;
         elsif vCALC_XX_OPERANDE_X='CONS_14' then fOPERANDE:=oROW_GEAV.cons_14;
         elsif vCALC_XX_OPERANDE_X='CONS_15' then fOPERANDE:=oROW_GEAV.cons_15;
         elsif vCALC_XX_OPERANDE_X='CONS_16' then fOPERANDE:=oROW_GEAV.cons_16;
         elsif vCALC_XX_OPERANDE_X='CONS_17' then fOPERANDE:=oROW_GEAV.cons_17;
         elsif vCALC_XX_OPERANDE_X='CONS_18' then fOPERANDE:=oROW_GEAV.cons_18;
         elsif vCALC_XX_OPERANDE_X='CONS_19' then fOPERANDE:=oROW_GEAV.cons_19;
         elsif vCALC_XX_OPERANDE_X='CONS_20' then fOPERANDE:=oROW_GEAV.cons_20;

         elsif vCALC_XX_OPERANDE_X='CONS_21' then fOPERANDE:=oROW_GEAV.cons_21;
         elsif vCALC_XX_OPERANDE_X='CONS_22' then fOPERANDE:=oROW_GEAV.cons_22;
         elsif vCALC_XX_OPERANDE_X='CONS_23' then fOPERANDE:=oROW_GEAV.cons_23;
         elsif vCALC_XX_OPERANDE_X='CONS_24' then fOPERANDE:=oROW_GEAV.cons_24;
         elsif vCALC_XX_OPERANDE_X='CONS_25' then fOPERANDE:=oROW_GEAV.cons_25;
         elsif vCALC_XX_OPERANDE_X='CONS_26' then fOPERANDE:=oROW_GEAV.cons_26;
         elsif vCALC_XX_OPERANDE_X='CONS_27' then fOPERANDE:=oROW_GEAV.cons_27;
         elsif vCALC_XX_OPERANDE_X='CONS_28' then fOPERANDE:=oROW_GEAV.cons_28;
         elsif vCALC_XX_OPERANDE_X='CONS_29' then fOPERANDE:=oROW_GEAV.cons_29;
         elsif vCALC_XX_OPERANDE_X='CONS_30' then fOPERANDE:=oROW_GEAV.cons_30;
         elsif vCALC_XX_OPERANDE_X='CONS_31' then fOPERANDE:=oROW_GEAV.cons_31;
         elsif vCALC_XX_OPERANDE_X='CONS_32' then fOPERANDE:=oROW_GEAV.cons_32;
         elsif vCALC_XX_OPERANDE_X='CONS_33' then fOPERANDE:=oROW_GEAV.cons_33;
         elsif vCALC_XX_OPERANDE_X='CONS_34' then fOPERANDE:=oROW_GEAV.cons_34;
         elsif vCALC_XX_OPERANDE_X='CONS_35' then fOPERANDE:=oROW_GEAV.cons_35;
         elsif vCALC_XX_OPERANDE_X='CONS_36' then fOPERANDE:=oROW_GEAV.cons_36;
         elsif vCALC_XX_OPERANDE_X='CONS_37' then fOPERANDE:=oROW_GEAV.cons_37;
         elsif vCALC_XX_OPERANDE_X='CONS_38' then fOPERANDE:=oROW_GEAV.cons_38;
         elsif vCALC_XX_OPERANDE_X='CONS_39' then fOPERANDE:=oROW_GEAV.cons_39;
         elsif vCALC_XX_OPERANDE_X='CONS_40' then fOPERANDE:=oROW_GEAV.cons_40;
         elsif vCALC_XX_OPERANDE_X='CONS_41' then fOPERANDE:=oROW_GEAV.cons_41;
         elsif vCALC_XX_OPERANDE_X='CONS_42' then fOPERANDE:=oROW_GEAV.cons_42;
         elsif vCALC_XX_OPERANDE_X='CONS_43' then fOPERANDE:=oROW_GEAV.cons_43;
         elsif vCALC_XX_OPERANDE_X='CONS_44' then fOPERANDE:=oROW_GEAV.cons_44;
         elsif vCALC_XX_OPERANDE_X='CONS_45' then fOPERANDE:=oROW_GEAV.cons_45;
         elsif vCALC_XX_OPERANDE_X='CONS_46' then fOPERANDE:=oROW_GEAV.cons_46;
         elsif vCALC_XX_OPERANDE_X='CONS_47' then fOPERANDE:=oROW_GEAV.cons_47;
         elsif vCALC_XX_OPERANDE_X='CONS_48' then fOPERANDE:=oROW_GEAV.cons_48;
         elsif vCALC_XX_OPERANDE_X='CONS_49' then fOPERANDE:=oROW_GEAV.cons_49;
         elsif vCALC_XX_OPERANDE_X='CONS_50' then fOPERANDE:=oROW_GEAV.cons_50;

         elsif vCALC_XX_OPERANDE_X='RUBR_01' then fOPERANDE:=oROW_GEAV.rubr_01;
         elsif vCALC_XX_OPERANDE_X='RUBR_02' then fOPERANDE:=oROW_GEAV.rubr_02;
         elsif vCALC_XX_OPERANDE_X='RUBR_03' then fOPERANDE:=oROW_GEAV.rubr_03;
         elsif vCALC_XX_OPERANDE_X='RUBR_04' then fOPERANDE:=oROW_GEAV.rubr_04;
         elsif vCALC_XX_OPERANDE_X='RUBR_05' then fOPERANDE:=oROW_GEAV.rubr_05;
         elsif vCALC_XX_OPERANDE_X='RUBR_06' then fOPERANDE:=oROW_GEAV.rubr_06;
         elsif vCALC_XX_OPERANDE_X='RUBR_07' then fOPERANDE:=oROW_GEAV.rubr_07;
         elsif vCALC_XX_OPERANDE_X='RUBR_08' then fOPERANDE:=oROW_GEAV.rubr_08;
         elsif vCALC_XX_OPERANDE_X='RUBR_09' then fOPERANDE:=oROW_GEAV.rubr_09;
         elsif vCALC_XX_OPERANDE_X='RUBR_10' then fOPERANDE:=oROW_GEAV.rubr_10;
         elsif vCALC_XX_OPERANDE_X='RUBR_11' then fOPERANDE:=oROW_GEAV.rubr_11;
         elsif vCALC_XX_OPERANDE_X='RUBR_12' then fOPERANDE:=oROW_GEAV.rubr_12;
         elsif vCALC_XX_OPERANDE_X='RUBR_13' then fOPERANDE:=oROW_GEAV.rubr_13;
         elsif vCALC_XX_OPERANDE_X='RUBR_14' then fOPERANDE:=oROW_GEAV.rubr_14;
         elsif vCALC_XX_OPERANDE_X='RUBR_15' then fOPERANDE:=oROW_GEAV.rubr_15;
         elsif vCALC_XX_OPERANDE_X='RUBR_16' then fOPERANDE:=oROW_GEAV.rubr_16;
         elsif vCALC_XX_OPERANDE_X='RUBR_17' then fOPERANDE:=oROW_GEAV.rubr_17;
         elsif vCALC_XX_OPERANDE_X='RUBR_18' then fOPERANDE:=oROW_GEAV.rubr_18;
         elsif vCALC_XX_OPERANDE_X='RUBR_19' then fOPERANDE:=oROW_GEAV.rubr_19;
         elsif vCALC_XX_OPERANDE_X='RUBR_20' then fOPERANDE:=oROW_GEAV.rubr_20;
         elsif vCALC_XX_OPERANDE_X='RUBR_21' then fOPERANDE:=oROW_GEAV.rubr_21;
         elsif vCALC_XX_OPERANDE_X='RUBR_22' then fOPERANDE:=oROW_GEAV.rubr_22;
         elsif vCALC_XX_OPERANDE_X='RUBR_23' then fOPERANDE:=oROW_GEAV.rubr_23;
         elsif vCALC_XX_OPERANDE_X='RUBR_24' then fOPERANDE:=oROW_GEAV.rubr_24;
         elsif vCALC_XX_OPERANDE_X='RUBR_25' then fOPERANDE:=oROW_GEAV.rubr_25;
         elsif vCALC_XX_OPERANDE_X='RUBR_26' then fOPERANDE:=oROW_GEAV.rubr_26;
         elsif vCALC_XX_OPERANDE_X='RUBR_27' then fOPERANDE:=oROW_GEAV.rubr_27;
         elsif vCALC_XX_OPERANDE_X='RUBR_28' then fOPERANDE:=oROW_GEAV.rubr_28;
         elsif vCALC_XX_OPERANDE_X='RUBR_29' then fOPERANDE:=oROW_GEAV.rubr_29;
         elsif vCALC_XX_OPERANDE_X='RUBR_30' then fOPERANDE:=oROW_GEAV.rubr_30;
         elsif vCALC_XX_OPERANDE_X='RUBR_31' then fOPERANDE:=oROW_GEAV.rubr_31;
         elsif vCALC_XX_OPERANDE_X='RUBR_32' then fOPERANDE:=oROW_GEAV.rubr_32;
         elsif vCALC_XX_OPERANDE_X='RUBR_33' then fOPERANDE:=oROW_GEAV.rubr_33;
         elsif vCALC_XX_OPERANDE_X='RUBR_34' then fOPERANDE:=oROW_GEAV.rubr_34;
         elsif vCALC_XX_OPERANDE_X='RUBR_35' then fOPERANDE:=oROW_GEAV.rubr_35;
         elsif vCALC_XX_OPERANDE_X='RUBR_36' then fOPERANDE:=oROW_GEAV.rubr_36;
         elsif vCALC_XX_OPERANDE_X='RUBR_37' then fOPERANDE:=oROW_GEAV.rubr_37;
         elsif vCALC_XX_OPERANDE_X='RUBR_38' then fOPERANDE:=oROW_GEAV.rubr_38;
         elsif vCALC_XX_OPERANDE_X='RUBR_39' then fOPERANDE:=oROW_GEAV.rubr_39;
         elsif vCALC_XX_OPERANDE_X='RUBR_40' then fOPERANDE:=oROW_GEAV.rubr_40;
         elsif vCALC_XX_OPERANDE_X='RUBR_41' then fOPERANDE:=oROW_GEAV.rubr_41;
         elsif vCALC_XX_OPERANDE_X='RUBR_42' then fOPERANDE:=oROW_GEAV.rubr_42;
         elsif vCALC_XX_OPERANDE_X='RUBR_43' then fOPERANDE:=oROW_GEAV.rubr_43;
         elsif vCALC_XX_OPERANDE_X='RUBR_44' then fOPERANDE:=oROW_GEAV.rubr_44;
         elsif vCALC_XX_OPERANDE_X='RUBR_45' then fOPERANDE:=oROW_GEAV.rubr_45;
         elsif vCALC_XX_OPERANDE_X='RUBR_46' then fOPERANDE:=oROW_GEAV.rubr_46;
         elsif vCALC_XX_OPERANDE_X='RUBR_47' then fOPERANDE:=oROW_GEAV.rubr_47;
         elsif vCALC_XX_OPERANDE_X='RUBR_48' then fOPERANDE:=oROW_GEAV.rubr_48;
         elsif vCALC_XX_OPERANDE_X='RUBR_49' then fOPERANDE:=oROW_GEAV.rubr_49;
         elsif vCALC_XX_OPERANDE_X='RUBR_50' then fOPERANDE:=oROW_GEAV.rubr_50;

         elsif vCALC_XX_OPERANDE_X='RUBR_51' then fOPERANDE:=oROW_GEAV.rubr_51;
         elsif vCALC_XX_OPERANDE_X='RUBR_52' then fOPERANDE:=oROW_GEAV.rubr_52;
         elsif vCALC_XX_OPERANDE_X='RUBR_53' then fOPERANDE:=oROW_GEAV.rubr_53;
         elsif vCALC_XX_OPERANDE_X='RUBR_54' then fOPERANDE:=oROW_GEAV.rubr_54;
         elsif vCALC_XX_OPERANDE_X='RUBR_55' then fOPERANDE:=oROW_GEAV.rubr_55;
         elsif vCALC_XX_OPERANDE_X='RUBR_56' then fOPERANDE:=oROW_GEAV.rubr_56;
         elsif vCALC_XX_OPERANDE_X='RUBR_57' then fOPERANDE:=oROW_GEAV.rubr_57;
         elsif vCALC_XX_OPERANDE_X='RUBR_58' then fOPERANDE:=oROW_GEAV.rubr_58;
         elsif vCALC_XX_OPERANDE_X='RUBR_59' then fOPERANDE:=oROW_GEAV.rubr_59;
         elsif vCALC_XX_OPERANDE_X='RUBR_60' then fOPERANDE:=oROW_GEAV.rubr_60;
         elsif vCALC_XX_OPERANDE_X='RUBR_61' then fOPERANDE:=oROW_GEAV.rubr_61;
         elsif vCALC_XX_OPERANDE_X='RUBR_62' then fOPERANDE:=oROW_GEAV.rubr_62;
         elsif vCALC_XX_OPERANDE_X='RUBR_63' then fOPERANDE:=oROW_GEAV.rubr_63;
         elsif vCALC_XX_OPERANDE_X='RUBR_64' then fOPERANDE:=oROW_GEAV.rubr_64;
         elsif vCALC_XX_OPERANDE_X='RUBR_65' then fOPERANDE:=oROW_GEAV.rubr_65;
         elsif vCALC_XX_OPERANDE_X='RUBR_66' then fOPERANDE:=oROW_GEAV.rubr_66;
         elsif vCALC_XX_OPERANDE_X='RUBR_67' then fOPERANDE:=oROW_GEAV.rubr_67;
         elsif vCALC_XX_OPERANDE_X='RUBR_68' then fOPERANDE:=oROW_GEAV.rubr_68;
         elsif vCALC_XX_OPERANDE_X='RUBR_69' then fOPERANDE:=oROW_GEAV.rubr_69;
         elsif vCALC_XX_OPERANDE_X='RUBR_70' then fOPERANDE:=oROW_GEAV.rubr_70;
         elsif vCALC_XX_OPERANDE_X='RUBR_71' then fOPERANDE:=oROW_GEAV.rubr_71;
         elsif vCALC_XX_OPERANDE_X='RUBR_72' then fOPERANDE:=oROW_GEAV.rubr_72;
         elsif vCALC_XX_OPERANDE_X='RUBR_73' then fOPERANDE:=oROW_GEAV.rubr_73;
         elsif vCALC_XX_OPERANDE_X='RUBR_74' then fOPERANDE:=oROW_GEAV.rubr_74;
         elsif vCALC_XX_OPERANDE_X='RUBR_75' then fOPERANDE:=oROW_GEAV.rubr_75;
         elsif vCALC_XX_OPERANDE_X='RUBR_76' then fOPERANDE:=oROW_GEAV.rubr_76;
         elsif vCALC_XX_OPERANDE_X='RUBR_77' then fOPERANDE:=oROW_GEAV.rubr_77;
         elsif vCALC_XX_OPERANDE_X='RUBR_78' then fOPERANDE:=oROW_GEAV.rubr_78;
         elsif vCALC_XX_OPERANDE_X='RUBR_79' then fOPERANDE:=oROW_GEAV.rubr_79;
         elsif vCALC_XX_OPERANDE_X='RUBR_80' then fOPERANDE:=oROW_GEAV.rubr_80;
         elsif vCALC_XX_OPERANDE_X='RUBR_81' then fOPERANDE:=oROW_GEAV.rubr_81;
         elsif vCALC_XX_OPERANDE_X='RUBR_82' then fOPERANDE:=oROW_GEAV.rubr_82;
         elsif vCALC_XX_OPERANDE_X='RUBR_83' then fOPERANDE:=oROW_GEAV.rubr_83;
         elsif vCALC_XX_OPERANDE_X='RUBR_84' then fOPERANDE:=oROW_GEAV.rubr_84;
         elsif vCALC_XX_OPERANDE_X='RUBR_85' then fOPERANDE:=oROW_GEAV.rubr_85;
         elsif vCALC_XX_OPERANDE_X='RUBR_86' then fOPERANDE:=oROW_GEAV.rubr_86;
         elsif vCALC_XX_OPERANDE_X='RUBR_87' then fOPERANDE:=oROW_GEAV.rubr_87;
         elsif vCALC_XX_OPERANDE_X='RUBR_88' then fOPERANDE:=oROW_GEAV.rubr_88;
         elsif vCALC_XX_OPERANDE_X='RUBR_89' then fOPERANDE:=oROW_GEAV.rubr_89;
         elsif vCALC_XX_OPERANDE_X='RUBR_90' then fOPERANDE:=oROW_GEAV.rubr_90;
         elsif vCALC_XX_OPERANDE_X='RUBR_91' then fOPERANDE:=oROW_GEAV.rubr_91;
         elsif vCALC_XX_OPERANDE_X='RUBR_92' then fOPERANDE:=oROW_GEAV.rubr_92;
         elsif vCALC_XX_OPERANDE_X='RUBR_93' then fOPERANDE:=oROW_GEAV.rubr_93;
         elsif vCALC_XX_OPERANDE_X='RUBR_94' then fOPERANDE:=oROW_GEAV.rubr_94;
         elsif vCALC_XX_OPERANDE_X='RUBR_95' then fOPERANDE:=oROW_GEAV.rubr_95;
         elsif vCALC_XX_OPERANDE_X='RUBR_96' then fOPERANDE:=oROW_GEAV.rubr_96;
         elsif vCALC_XX_OPERANDE_X='RUBR_97' then fOPERANDE:=oROW_GEAV.rubr_97;
         elsif vCALC_XX_OPERANDE_X='RUBR_98' then fOPERANDE:=oROW_GEAV.rubr_98;
         elsif vCALC_XX_OPERANDE_X='RUBR_99' then fOPERANDE:=oROW_GEAV.rubr_99;
         elsif vCALC_XX_OPERANDE_X='RUBR_100' then fOPERANDE:=oROW_GEAV.rubr_100;
         elsif vCALC_XX_OPERANDE_X='RUBR_101' then fOPERANDE:=oROW_GEAV.rubr_101;
         elsif vCALC_XX_OPERANDE_X='RUBR_102' then fOPERANDE:=oROW_GEAV.rubr_102;
         elsif vCALC_XX_OPERANDE_X='RUBR_103' then fOPERANDE:=oROW_GEAV.rubr_103;
         elsif vCALC_XX_OPERANDE_X='RUBR_104' then fOPERANDE:=oROW_GEAV.rubr_104;
         elsif vCALC_XX_OPERANDE_X='RUBR_105' then fOPERANDE:=oROW_GEAV.rubr_105;
         elsif vCALC_XX_OPERANDE_X='RUBR_106' then fOPERANDE:=oROW_GEAV.rubr_106;
         elsif vCALC_XX_OPERANDE_X='RUBR_107' then fOPERANDE:=oROW_GEAV.rubr_107;
         elsif vCALC_XX_OPERANDE_X='RUBR_108' then fOPERANDE:=oROW_GEAV.rubr_108;
         elsif vCALC_XX_OPERANDE_X='RUBR_109' then fOPERANDE:=oROW_GEAV.rubr_109;
         elsif vCALC_XX_OPERANDE_X='RUBR_110' then fOPERANDE:=oROW_GEAV.rubr_110;
         elsif vCALC_XX_OPERANDE_X='RUBR_111' then fOPERANDE:=oROW_GEAV.rubr_111;
         elsif vCALC_XX_OPERANDE_X='RUBR_112' then fOPERANDE:=oROW_GEAV.rubr_112;
         elsif vCALC_XX_OPERANDE_X='RUBR_113' then fOPERANDE:=oROW_GEAV.rubr_113;
         elsif vCALC_XX_OPERANDE_X='RUBR_114' then fOPERANDE:=oROW_GEAV.rubr_114;
         elsif vCALC_XX_OPERANDE_X='RUBR_115' then fOPERANDE:=oROW_GEAV.rubr_115;
         elsif vCALC_XX_OPERANDE_X='RUBR_116' then fOPERANDE:=oROW_GEAV.rubr_116;
         elsif vCALC_XX_OPERANDE_X='RUBR_117' then fOPERANDE:=oROW_GEAV.rubr_117;
         elsif vCALC_XX_OPERANDE_X='RUBR_118' then fOPERANDE:=oROW_GEAV.rubr_118;
         elsif vCALC_XX_OPERANDE_X='RUBR_119' then fOPERANDE:=oROW_GEAV.rubr_119;
         elsif vCALC_XX_OPERANDE_X='RUBR_120' then fOPERANDE:=oROW_GEAV.rubr_120;
         elsif vCALC_XX_OPERANDE_X='RUBR_121' then fOPERANDE:=oROW_GEAV.rubr_121;
         elsif vCALC_XX_OPERANDE_X='RUBR_122' then fOPERANDE:=oROW_GEAV.rubr_122;
         elsif vCALC_XX_OPERANDE_X='RUBR_123' then fOPERANDE:=oROW_GEAV.rubr_123;
         elsif vCALC_XX_OPERANDE_X='RUBR_124' then fOPERANDE:=oROW_GEAV.rubr_124;
         elsif vCALC_XX_OPERANDE_X='RUBR_125' then fOPERANDE:=oROW_GEAV.rubr_125;
         elsif vCALC_XX_OPERANDE_X='RUBR_126' then fOPERANDE:=oROW_GEAV.rubr_126;
         elsif vCALC_XX_OPERANDE_X='RUBR_127' then fOPERANDE:=oROW_GEAV.rubr_127;
         elsif vCALC_XX_OPERANDE_X='RUBR_128' then fOPERANDE:=oROW_GEAV.rubr_128;
         elsif vCALC_XX_OPERANDE_X='RUBR_129' then fOPERANDE:=oROW_GEAV.rubr_129;
         elsif vCALC_XX_OPERANDE_X='RUBR_130' then fOPERANDE:=oROW_GEAV.rubr_130;
         elsif vCALC_XX_OPERANDE_X='RUBR_131' then fOPERANDE:=oROW_GEAV.rubr_131;
         elsif vCALC_XX_OPERANDE_X='RUBR_132' then fOPERANDE:=oROW_GEAV.rubr_132;
         elsif vCALC_XX_OPERANDE_X='RUBR_133' then fOPERANDE:=oROW_GEAV.rubr_133;
         elsif vCALC_XX_OPERANDE_X='RUBR_134' then fOPERANDE:=oROW_GEAV.rubr_134;
         elsif vCALC_XX_OPERANDE_X='RUBR_135' then fOPERANDE:=oROW_GEAV.rubr_135;
         elsif vCALC_XX_OPERANDE_X='RUBR_136' then fOPERANDE:=oROW_GEAV.rubr_136;
         elsif vCALC_XX_OPERANDE_X='RUBR_137' then fOPERANDE:=oROW_GEAV.rubr_137;
         elsif vCALC_XX_OPERANDE_X='RUBR_138' then fOPERANDE:=oROW_GEAV.rubr_138;
         elsif vCALC_XX_OPERANDE_X='RUBR_139' then fOPERANDE:=oROW_GEAV.rubr_139;
         elsif vCALC_XX_OPERANDE_X='RUBR_140' then fOPERANDE:=oROW_GEAV.rubr_140;
         elsif vCALC_XX_OPERANDE_X='RUBR_141' then fOPERANDE:=oROW_GEAV.rubr_141;
         elsif vCALC_XX_OPERANDE_X='RUBR_142' then fOPERANDE:=oROW_GEAV.rubr_142;
         elsif vCALC_XX_OPERANDE_X='RUBR_143' then fOPERANDE:=oROW_GEAV.rubr_143;
         elsif vCALC_XX_OPERANDE_X='RUBR_144' then fOPERANDE:=oROW_GEAV.rubr_144;
         elsif vCALC_XX_OPERANDE_X='RUBR_145' then fOPERANDE:=oROW_GEAV.rubr_145;
         elsif vCALC_XX_OPERANDE_X='RUBR_146' then fOPERANDE:=oROW_GEAV.rubr_146;
         elsif vCALC_XX_OPERANDE_X='RUBR_147' then fOPERANDE:=oROW_GEAV.rubr_147;
         elsif vCALC_XX_OPERANDE_X='RUBR_148' then fOPERANDE:=oROW_GEAV.rubr_148;
         elsif vCALC_XX_OPERANDE_X='RUBR_149' then fOPERANDE:=oROW_GEAV.rubr_149;
         elsif vCALC_XX_OPERANDE_X='RUBR_150' then fOPERANDE:=oROW_GEAV.rubr_150;
         else                                     fOPERANDE:=0;
         end if;
         return nvl(fOPERANDE,0);
      end;
   begin
      fCALC_XX_OPERANDE_1:=fct__get_operande(vCALC_XX_OPERANDE_1);
      fCALC_XX_OPERANDE_2:=fct__get_operande(vCALC_XX_OPERANDE_2);

      if vCALC_XX_OPERATEUR='+' then
         fCALC_RESULT:=fCALC_XX_OPERANDE_1+fCALC_XX_OPERANDE_2;
      elsif vCALC_XX_OPERATEUR='-' then
         fCALC_RESULT:=fCALC_XX_OPERANDE_1-fCALC_XX_OPERANDE_2;
      elsif vCALC_XX_OPERATEUR='*' then
         fCALC_RESULT:=fCALC_XX_OPERANDE_1*fCALC_XX_OPERANDE_2;
      elsif vCALC_XX_OPERATEUR='/' and fCALC_XX_OPERANDE_2!=0 then
         fCALC_RESULT:=fCALC_XX_OPERANDE_1/fCALC_XX_OPERANDE_2;
      else
         fCALC_RESULT:=0;
      end if;

      fCALC_RESULT:=fCALC_RESULT * nvl(fCALC_XX_MULT,1);

      return fCALC_RESULT;
   end;
   procedure pr__carachamp_constantes(
      iINDEX     in int,
      vCODE_CONS in varchar2,
      vLIBE      in varchar2
   )is
      iDECIMALES int;
      vLIBELLE   varchar2(100);
   begin
      if vCODE_CONS is not null then
          begin
             select
                para_deci
             into
                iDECIMALES
             from carachamp c
             where id_carachamp='CONS_'||vCODE_CONS
             ;
          exception
             when no_data_found then
                iDECIMALES:=2;
          end ;

          if vLIBE is not null then
             vLIBELLE:=vLIBE;
          else
             vLIBELLE:=fct_carachamp_soci_colo(iID_SOCI,'CONS_'||vCODE_CONS);
          end if;
      else
         iDECIMALES:=2;
         vLIBELLE:=null;
      end if;

      pr_carachamp_lien(
         iID_SOCI,
         'GEAV_CONS_'||to_char(iINDEX,'fm00'),
         vETAT,
         parse_int(vID_PARA),
         parse_int(vID_LIST),
         vLIBELLE,
         'N',
         iDECIMALES
      );
   end ;

   procedure pr__carachamp_rubrique(
      iINDEX   in int,
      vLIBE    in varchar2,-- VALE_RUBR
      vCOLONNE in varchar2 -- VALE_RUBR
   )is
      iDECIMALES    int;
   begin
      if    vCOLONNE in ('TAUX_SALA','TAUX_PATR') then
         if    oSociOrig.bull_taux_format=2 then
            iDECIMALES:=2;
         elsif oSociOrig.bull_taux_format=3 then
            iDECIMALES:=3;
         elsif oSociOrig.bull_taux_format=4 then
            iDECIMALES:=4;
         else
            iDECIMALES:=4;
         end if;

      elsif vCOLONNE ='NOMB' then
         if    oSociOrig.bull_nomb_format=2 then
            iDECIMALES:=2;
         elsif oSociOrig.bull_nomb_format=3 then
            iDECIMALES:=3;
         elsif oSociOrig.bull_nomb_format=4 then
            iDECIMALES:=4;
         else
            iDECIMALES:=2;
         end if;

      elsif vCOLONNE in ('BASE','ASSI') then
         if    oSociOrig.bull_base_format=2 then
            iDECIMALES:=2;
         elsif oSociOrig.bull_base_format=3 then
            iDECIMALES:=3;
         elsif oSociOrig.bull_base_format=4 then
            iDECIMALES:=4;
         else
            iDECIMALES:=2;
         end if;

      elsif vCOLONNE in ('MONT_SALA','MONT_PATR','PLAF') then
         if    oSociOrig.bull_mont_format=2 then
            iDECIMALES:=2;
         elsif oSociOrig.bull_mont_format=3 then
            iDECIMALES:=3;
         elsif oSociOrig.bull_mont_format=4 then
            iDECIMALES:=4;
         else
            iDECIMALES:=2;
         end if;
      else
         iDECIMALES:=2;
      end if;

      pr_carachamp_lien(
         iID_SOCI,
         'GEAV_RUBR_'||case when iINDEX >=100 then to_char(iINDEX,'fm000') else to_char(iINDEX,'fm00') end,
         vETAT,
         parse_int(vID_PARA),
         parse_int(vID_LIST),
         vLIBE,
         'N',
         iDECIMALES
      );
   end ;

   procedure pr__carachamp_calcul(
      iINDEX in int,
      iDECI  in int,
      vLIBE  in varchar2
   )is
   begin
      pr_carachamp_lien(
         iID_SOCI,
         'GEAV_CALC_'||to_char(iINDEX,'fm00'),
         vETAT,
         parse_int(vID_PARA),
         parse_int(vID_LIST),
         trim(vLIBE),
         'N',
         nvl(iDECI,2)
      );
   end ;



   procedure pr__liste_salarie_plan_anal(iID_SOCI in int, dPERI in date)
   is
   begin
     rv_S_SALA_PLAN_ANAL.delete;

     for cSALA_PLAN in (select * from SALARIE_ANALYTIQUE sa
                        where sa.id_soci = iID_SOCI
                          and sa.peri    = dPERI
                          and sa.nume_plan is not null
                          and not exists( select 1 from sala$hist sh where sh.id_sala = sa.id_sala and sh.hors_paie_type ='INTERM' and sh.acti$h ='1')
     ) loop
       oSALA_PLAN_ANAL           := null;
       oSALA_PLAN_ANAL.id_soci   := iID_SOCI;
       oSALA_PLAN_ANAL.peri      := dPERI;
       oSALA_PLAN_ANAL.id_sala   := cSALA_PLAN.id_sala;
       oSALA_PLAN_ANAL.nume_plan := cSALA_PLAN.nume_plan;

       oSALA_PLAN_ANAL.code_anal           := cSALA_PLAN.code_anal;
       oSALA_PLAN_ANAL.code_anal_axe2      := cSALA_PLAN.code_anal_axe2;
       oSALA_PLAN_ANAL.code_anal_axe3      := cSALA_PLAN.code_anal_axe3;
       oSALA_PLAN_ANAL.code_anal_axe4      := cSALA_PLAN.code_anal_axe4;
       oSALA_PLAN_ANAL.code_anal_axe5      := cSALA_PLAN.code_anal_axe5;
       oSALA_PLAN_ANAL.code_anal_axe6      := cSALA_PLAN.code_anal_axe6;
       oSALA_PLAN_ANAL.code_anal_axe7      := cSALA_PLAN.code_anal_axe7;
       oSALA_PLAN_ANAL.code_anal_axe8      := cSALA_PLAN.code_anal_axe8;
       oSALA_PLAN_ANAL.code_anal_axe9      := cSALA_PLAN.code_anal_axe9;
       oSALA_PLAN_ANAL.code_anal_ax10      := cSALA_PLAN.code_anal_ax10;
       oSALA_PLAN_ANAL.code_anal_ax11      := cSALA_PLAN.code_anal_ax11;
       oSALA_PLAN_ANAL.code_anal_ax12      := cSALA_PLAN.code_anal_ax12;
       oSALA_PLAN_ANAL.code_anal_ax13      := cSALA_PLAN.code_anal_ax13;
       oSALA_PLAN_ANAL.code_anal_ax14      := cSALA_PLAN.code_anal_ax14;
       oSALA_PLAN_ANAL.code_anal_ax15      := cSALA_PLAN.code_anal_ax15;
       oSALA_PLAN_ANAL.code_anal_ax16      := cSALA_PLAN.code_anal_ax16;
       oSALA_PLAN_ANAL.code_anal_ax17      := cSALA_PLAN.code_anal_ax17;
       oSALA_PLAN_ANAL.code_anal_ax18      := cSALA_PLAN.code_anal_ax18;
       oSALA_PLAN_ANAL.code_anal_ax19      := cSALA_PLAN.code_anal_ax19;
       oSALA_PLAN_ANAL.code_anal_ax20      := cSALA_PLAN.code_anal_ax20;
       oSALA_PLAN_ANAL.pour_affe_anal      := cSALA_PLAN.pour_affe_anal;
       oSALA_PLAN_ANAL.pour_affe_anal_axe2 := cSALA_PLAN.pour_affe_anal_axe2;
       oSALA_PLAN_ANAL.pour_affe_anal_axe3 := cSALA_PLAN.pour_affe_anal_axe3;
       oSALA_PLAN_ANAL.pour_affe_anal_axe4 := cSALA_PLAN.pour_affe_anal_axe4;
       oSALA_PLAN_ANAL.pour_affe_anal_axe5 := cSALA_PLAN.pour_affe_anal_axe5;
       oSALA_PLAN_ANAL.pour_affe_anal_axe6 := cSALA_PLAN.pour_affe_anal_axe6;
       oSALA_PLAN_ANAL.pour_affe_anal_axe7 := cSALA_PLAN.pour_affe_anal_axe7;
       oSALA_PLAN_ANAL.pour_affe_anal_axe8 := cSALA_PLAN.pour_affe_anal_axe8;
       oSALA_PLAN_ANAL.pour_affe_anal_axe9 := cSALA_PLAN.pour_affe_anal_axe9;
       oSALA_PLAN_ANAL.pour_affe_anal_ax10 := cSALA_PLAN.pour_affe_anal_ax10;
       oSALA_PLAN_ANAL.pour_affe_anal_ax11 := cSALA_PLAN.pour_affe_anal_ax11;
       oSALA_PLAN_ANAL.pour_affe_anal_ax12 := cSALA_PLAN.pour_affe_anal_ax12;
       oSALA_PLAN_ANAL.pour_affe_anal_ax13 := cSALA_PLAN.pour_affe_anal_ax13;
       oSALA_PLAN_ANAL.pour_affe_anal_ax14 := cSALA_PLAN.pour_affe_anal_ax14;
       oSALA_PLAN_ANAL.pour_affe_anal_ax15 := cSALA_PLAN.pour_affe_anal_ax15;
       oSALA_PLAN_ANAL.pour_affe_anal_ax16 := cSALA_PLAN.pour_affe_anal_ax16;
       oSALA_PLAN_ANAL.pour_affe_anal_ax17 := cSALA_PLAN.pour_affe_anal_ax17;
       oSALA_PLAN_ANAL.pour_affe_anal_ax18 := cSALA_PLAN.pour_affe_anal_ax18;
       oSALA_PLAN_ANAL.pour_affe_anal_ax19 := cSALA_PLAN.pour_affe_anal_ax19;
       oSALA_PLAN_ANAL.pour_affe_anal_ax20 := cSALA_PLAN.pour_affe_anal_ax20;

       rv_S_SALA_PLAN_ANAL(cSALA_PLAN.id_sala || '-' || cSALA_PLAN.nume_plan || '-' || to_char(cSALA_PLAN.peri,'DD/MM/YYYY')) := oSALA_PLAN_ANAL;
     end loop;
   end;

   procedure pr__raz_sala_plan_anal (oGEAV in out PERS_EDIT_GESTION_AVANCEE%rowtype)
   is
   begin
     oGEAV.plan1_code_anal_01      := null;
     oGEAV.plan1_code_anal_02      := null;
     oGEAV.plan1_code_anal_03      := null;
     oGEAV.plan1_code_anal_04      := null;
     oGEAV.plan1_code_anal_05      := null;
     oGEAV.plan1_code_anal_06      := null;
     oGEAV.plan1_code_anal_07      := null;
     oGEAV.plan1_code_anal_08      := null;
     oGEAV.plan1_code_anal_09      := null;
     oGEAV.plan1_code_anal_10      := null;
     oGEAV.plan1_code_anal_11      := null;
     oGEAV.plan1_code_anal_12      := null;
     oGEAV.plan1_code_anal_13      := null;
     oGEAV.plan1_code_anal_14      := null;
     oGEAV.plan1_code_anal_15      := null;
     oGEAV.plan1_code_anal_16      := null;
     oGEAV.plan1_code_anal_17      := null;
     oGEAV.plan1_code_anal_18      := null;
     oGEAV.plan1_code_anal_19      := null;
     oGEAV.plan1_code_anal_20      := null;
     oGEAV.plan1_pour_affe_anal_01 := null;
     oGEAV.plan1_pour_affe_anal_02 := null;
     oGEAV.plan1_pour_affe_anal_03 := null;
     oGEAV.plan1_pour_affe_anal_04 := null;
     oGEAV.plan1_pour_affe_anal_05 := null;
     oGEAV.plan1_pour_affe_anal_06 := null;
     oGEAV.plan1_pour_affe_anal_07 := null;
     oGEAV.plan1_pour_affe_anal_08 := null;
     oGEAV.plan1_pour_affe_anal_09 := null;
     oGEAV.plan1_pour_affe_anal_10 := null;
     oGEAV.plan1_pour_affe_anal_11 := null;
     oGEAV.plan1_pour_affe_anal_12 := null;
     oGEAV.plan1_pour_affe_anal_13 := null;
     oGEAV.plan1_pour_affe_anal_14 := null;
     oGEAV.plan1_pour_affe_anal_15 := null;
     oGEAV.plan1_pour_affe_anal_16 := null;
     oGEAV.plan1_pour_affe_anal_17 := null;
     oGEAV.plan1_pour_affe_anal_18 := null;
     oGEAV.plan1_pour_affe_anal_19 := null;
     oGEAV.plan1_pour_affe_anal_20 := null;

     oGEAV.plan2_code_anal_01      := null;
     oGEAV.plan2_code_anal_02      := null;
     oGEAV.plan2_code_anal_03      := null;
     oGEAV.plan2_code_anal_04      := null;
     oGEAV.plan2_code_anal_05      := null;
     oGEAV.plan2_code_anal_06      := null;
     oGEAV.plan2_code_anal_07      := null;
     oGEAV.plan2_code_anal_08      := null;
     oGEAV.plan2_code_anal_09      := null;
     oGEAV.plan2_code_anal_10      := null;
     oGEAV.plan2_code_anal_11      := null;
     oGEAV.plan2_code_anal_12      := null;
     oGEAV.plan2_code_anal_13      := null;
     oGEAV.plan2_code_anal_14      := null;
     oGEAV.plan2_code_anal_15      := null;
     oGEAV.plan2_code_anal_16      := null;
     oGEAV.plan2_code_anal_17      := null;
     oGEAV.plan2_code_anal_18      := null;
     oGEAV.plan2_code_anal_19      := null;
     oGEAV.plan2_code_anal_20      := null;
     oGEAV.plan2_pour_affe_anal_01 := null;
     oGEAV.plan2_pour_affe_anal_02 := null;
     oGEAV.plan2_pour_affe_anal_03 := null;
     oGEAV.plan2_pour_affe_anal_04 := null;
     oGEAV.plan2_pour_affe_anal_05 := null;
     oGEAV.plan2_pour_affe_anal_06 := null;
     oGEAV.plan2_pour_affe_anal_07 := null;
     oGEAV.plan2_pour_affe_anal_08 := null;
     oGEAV.plan2_pour_affe_anal_09 := null;
     oGEAV.plan2_pour_affe_anal_10 := null;
     oGEAV.plan2_pour_affe_anal_11 := null;
     oGEAV.plan2_pour_affe_anal_12 := null;
     oGEAV.plan2_pour_affe_anal_13 := null;
     oGEAV.plan2_pour_affe_anal_14 := null;
     oGEAV.plan2_pour_affe_anal_15 := null;
     oGEAV.plan2_pour_affe_anal_16 := null;
     oGEAV.plan2_pour_affe_anal_17 := null;
     oGEAV.plan2_pour_affe_anal_18 := null;
     oGEAV.plan2_pour_affe_anal_19 := null;
     oGEAV.plan2_pour_affe_anal_20 := null;

     oGEAV.plan3_code_anal_01      := null;
     oGEAV.plan3_code_anal_02      := null;
     oGEAV.plan3_code_anal_03      := null;
     oGEAV.plan3_code_anal_04      := null;
     oGEAV.plan3_code_anal_05      := null;
     oGEAV.plan3_code_anal_06      := null;
     oGEAV.plan3_code_anal_07      := null;
     oGEAV.plan3_code_anal_08      := null;
     oGEAV.plan3_code_anal_09      := null;
     oGEAV.plan3_code_anal_10      := null;
     oGEAV.plan3_code_anal_11      := null;
     oGEAV.plan3_code_anal_12      := null;
     oGEAV.plan3_code_anal_13      := null;
     oGEAV.plan3_code_anal_14      := null;
     oGEAV.plan3_code_anal_15      := null;
     oGEAV.plan3_code_anal_16      := null;
     oGEAV.plan3_code_anal_17      := null;
     oGEAV.plan3_code_anal_18      := null;
     oGEAV.plan3_code_anal_19      := null;
     oGEAV.plan3_code_anal_20      := null;
     oGEAV.plan3_pour_affe_anal_01 := null;
     oGEAV.plan3_pour_affe_anal_02 := null;
     oGEAV.plan3_pour_affe_anal_03 := null;
     oGEAV.plan3_pour_affe_anal_04 := null;
     oGEAV.plan3_pour_affe_anal_05 := null;
     oGEAV.plan3_pour_affe_anal_06 := null;
     oGEAV.plan3_pour_affe_anal_07 := null;
     oGEAV.plan3_pour_affe_anal_08 := null;
     oGEAV.plan3_pour_affe_anal_09 := null;
     oGEAV.plan3_pour_affe_anal_10 := null;
     oGEAV.plan3_pour_affe_anal_11 := null;
     oGEAV.plan3_pour_affe_anal_12 := null;
     oGEAV.plan3_pour_affe_anal_13 := null;
     oGEAV.plan3_pour_affe_anal_14 := null;
     oGEAV.plan3_pour_affe_anal_15 := null;
     oGEAV.plan3_pour_affe_anal_16 := null;
     oGEAV.plan3_pour_affe_anal_17 := null;
     oGEAV.plan3_pour_affe_anal_18 := null;
     oGEAV.plan3_pour_affe_anal_19 := null;
     oGEAV.plan3_pour_affe_anal_20 := null;

     oGEAV.plan4_code_anal_01      := null;
     oGEAV.plan4_code_anal_02      := null;
     oGEAV.plan4_code_anal_03      := null;
     oGEAV.plan4_code_anal_04      := null;
     oGEAV.plan4_code_anal_05      := null;
     oGEAV.plan4_code_anal_06      := null;
     oGEAV.plan4_code_anal_07      := null;
     oGEAV.plan4_code_anal_08      := null;
     oGEAV.plan4_code_anal_09      := null;
     oGEAV.plan4_code_anal_10      := null;
     oGEAV.plan4_code_anal_11      := null;
     oGEAV.plan4_code_anal_12      := null;
     oGEAV.plan4_code_anal_13      := null;
     oGEAV.plan4_code_anal_14      := null;
     oGEAV.plan4_code_anal_15      := null;
     oGEAV.plan4_code_anal_16      := null;
     oGEAV.plan4_code_anal_17      := null;
     oGEAV.plan4_code_anal_18      := null;
     oGEAV.plan4_code_anal_19      := null;
     oGEAV.plan4_code_anal_20      := null;
     oGEAV.plan4_pour_affe_anal_01 := null;
     oGEAV.plan4_pour_affe_anal_02 := null;
     oGEAV.plan4_pour_affe_anal_03 := null;
     oGEAV.plan4_pour_affe_anal_04 := null;
     oGEAV.plan4_pour_affe_anal_05 := null;
     oGEAV.plan4_pour_affe_anal_06 := null;
     oGEAV.plan4_pour_affe_anal_07 := null;
     oGEAV.plan4_pour_affe_anal_08 := null;
     oGEAV.plan4_pour_affe_anal_09 := null;
     oGEAV.plan4_pour_affe_anal_10 := null;
     oGEAV.plan4_pour_affe_anal_11 := null;
     oGEAV.plan4_pour_affe_anal_12 := null;
     oGEAV.plan4_pour_affe_anal_13 := null;
     oGEAV.plan4_pour_affe_anal_14 := null;
     oGEAV.plan4_pour_affe_anal_15 := null;
     oGEAV.plan4_pour_affe_anal_16 := null;
     oGEAV.plan4_pour_affe_anal_17 := null;
     oGEAV.plan4_pour_affe_anal_18 := null;
     oGEAV.plan4_pour_affe_anal_19 := null;
     oGEAV.plan4_pour_affe_anal_20 := null;

     oGEAV.plan5_code_anal_01      := null;
     oGEAV.plan5_code_anal_02      := null;
     oGEAV.plan5_code_anal_03      := null;
     oGEAV.plan5_code_anal_04      := null;
     oGEAV.plan5_code_anal_05      := null;
     oGEAV.plan5_code_anal_06      := null;
     oGEAV.plan5_code_anal_07      := null;
     oGEAV.plan5_code_anal_08      := null;
     oGEAV.plan5_code_anal_09      := null;
     oGEAV.plan5_code_anal_10      := null;
     oGEAV.plan5_code_anal_11      := null;
     oGEAV.plan5_code_anal_12      := null;
     oGEAV.plan5_code_anal_13      := null;
     oGEAV.plan5_code_anal_14      := null;
     oGEAV.plan5_code_anal_15      := null;
     oGEAV.plan5_code_anal_16      := null;
     oGEAV.plan5_code_anal_17      := null;
     oGEAV.plan5_code_anal_18      := null;
     oGEAV.plan5_code_anal_19      := null;
     oGEAV.plan5_code_anal_20      := null;
     oGEAV.plan5_pour_affe_anal_01 := null;
     oGEAV.plan5_pour_affe_anal_02 := null;
     oGEAV.plan5_pour_affe_anal_03 := null;
     oGEAV.plan5_pour_affe_anal_04 := null;
     oGEAV.plan5_pour_affe_anal_05 := null;
     oGEAV.plan5_pour_affe_anal_06 := null;
     oGEAV.plan5_pour_affe_anal_07 := null;
     oGEAV.plan5_pour_affe_anal_08 := null;
     oGEAV.plan5_pour_affe_anal_09 := null;
     oGEAV.plan5_pour_affe_anal_10 := null;
     oGEAV.plan5_pour_affe_anal_11 := null;
     oGEAV.plan5_pour_affe_anal_12 := null;
     oGEAV.plan5_pour_affe_anal_13 := null;
     oGEAV.plan5_pour_affe_anal_14 := null;
     oGEAV.plan5_pour_affe_anal_15 := null;
     oGEAV.plan5_pour_affe_anal_16 := null;
     oGEAV.plan5_pour_affe_anal_17 := null;
     oGEAV.plan5_pour_affe_anal_18 := null;
     oGEAV.plan5_pour_affe_anal_19 := null;
     oGEAV.plan5_pour_affe_anal_20 := null;
   end;

   procedure pr__maj_edit_plan_anal(
     iNUME_PLAN      in     int,
     oSALA_PLAN_ANAL in     SALARIE_ANALYTIQUE%rowtype,
     oGEAV           in out PERS_EDIT_GESTION_AVANCEE%rowtype
   ) is
   begin
     if iNUME_PLAN = 1 then
       oGEAV.PLAN1_CODE_ANAL_01      := oSALA_PLAN_ANAL.CODE_ANAL;
       oGEAV.PLAN1_CODE_ANAL_02      := oSALA_PLAN_ANAL.CODE_ANAL_AXE2;
       oGEAV.PLAN1_CODE_ANAL_03      := oSALA_PLAN_ANAL.CODE_ANAL_AXE3;
       oGEAV.PLAN1_CODE_ANAL_04      := oSALA_PLAN_ANAL.CODE_ANAL_AXE4;
       oGEAV.PLAN1_CODE_ANAL_05      := oSALA_PLAN_ANAL.CODE_ANAL_AXE5;
       oGEAV.PLAN1_CODE_ANAL_06      := oSALA_PLAN_ANAL.CODE_ANAL_AXE6;
       oGEAV.PLAN1_CODE_ANAL_07      := oSALA_PLAN_ANAL.CODE_ANAL_AXE7;
       oGEAV.PLAN1_CODE_ANAL_08      := oSALA_PLAN_ANAL.CODE_ANAL_AXE8;
       oGEAV.PLAN1_CODE_ANAL_09      := oSALA_PLAN_ANAL.CODE_ANAL_AXE9;
       oGEAV.PLAN1_CODE_ANAL_10      := oSALA_PLAN_ANAL.CODE_ANAL_AX10;
       oGEAV.PLAN1_CODE_ANAL_11      := oSALA_PLAN_ANAL.CODE_ANAL_AX11;
       oGEAV.PLAN1_CODE_ANAL_12      := oSALA_PLAN_ANAL.CODE_ANAL_AX12;
       oGEAV.PLAN1_CODE_ANAL_13      := oSALA_PLAN_ANAL.CODE_ANAL_AX13;
       oGEAV.PLAN1_CODE_ANAL_14      := oSALA_PLAN_ANAL.CODE_ANAL_AX14;
       oGEAV.PLAN1_CODE_ANAL_15      := oSALA_PLAN_ANAL.CODE_ANAL_AX15;
       oGEAV.PLAN1_CODE_ANAL_16      := oSALA_PLAN_ANAL.CODE_ANAL_AX16;
       oGEAV.PLAN1_CODE_ANAL_17      := oSALA_PLAN_ANAL.CODE_ANAL_AX17;
       oGEAV.PLAN1_CODE_ANAL_18      := oSALA_PLAN_ANAL.CODE_ANAL_AX18;
       oGEAV.PLAN1_CODE_ANAL_19      := oSALA_PLAN_ANAL.CODE_ANAL_AX19;
       oGEAV.PLAN1_CODE_ANAL_20      := oSALA_PLAN_ANAL.CODE_ANAL_AX20;
       oGEAV.PLAN1_POUR_AFFE_ANAL_01 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL);
       oGEAV.PLAN1_POUR_AFFE_ANAL_02 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE2);
       oGEAV.PLAN1_POUR_AFFE_ANAL_03 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE3);
       oGEAV.PLAN1_POUR_AFFE_ANAL_04 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE4);
       oGEAV.PLAN1_POUR_AFFE_ANAL_05 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE5);
       oGEAV.PLAN1_POUR_AFFE_ANAL_06 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE6);
       oGEAV.PLAN1_POUR_AFFE_ANAL_07 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE7);
       oGEAV.PLAN1_POUR_AFFE_ANAL_08 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE8);
       oGEAV.PLAN1_POUR_AFFE_ANAL_09 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE9);
       oGEAV.PLAN1_POUR_AFFE_ANAL_10 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX10);
       oGEAV.PLAN1_POUR_AFFE_ANAL_11 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX11);
       oGEAV.PLAN1_POUR_AFFE_ANAL_12 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX12);
       oGEAV.PLAN1_POUR_AFFE_ANAL_13 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX13);
       oGEAV.PLAN1_POUR_AFFE_ANAL_14 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX14);
       oGEAV.PLAN1_POUR_AFFE_ANAL_15 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX15);
       oGEAV.PLAN1_POUR_AFFE_ANAL_16 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX16);
       oGEAV.PLAN1_POUR_AFFE_ANAL_17 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX17);
       oGEAV.PLAN1_POUR_AFFE_ANAL_18 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX18);
       oGEAV.PLAN1_POUR_AFFE_ANAL_19 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX19);
       oGEAV.PLAN1_POUR_AFFE_ANAL_20 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX20);
     elsif iNUME_PLAN = 2 then
       oGEAV.PLAN2_CODE_ANAL_01      := oSALA_PLAN_ANAL.CODE_ANAL;
       oGEAV.PLAN2_CODE_ANAL_02      := oSALA_PLAN_ANAL.CODE_ANAL_AXE2;
       oGEAV.PLAN2_CODE_ANAL_03      := oSALA_PLAN_ANAL.CODE_ANAL_AXE3;
       oGEAV.PLAN2_CODE_ANAL_04      := oSALA_PLAN_ANAL.CODE_ANAL_AXE4;
       oGEAV.PLAN2_CODE_ANAL_05      := oSALA_PLAN_ANAL.CODE_ANAL_AXE5;
       oGEAV.PLAN2_CODE_ANAL_06      := oSALA_PLAN_ANAL.CODE_ANAL_AXE6;
       oGEAV.PLAN2_CODE_ANAL_07      := oSALA_PLAN_ANAL.CODE_ANAL_AXE7;
       oGEAV.PLAN2_CODE_ANAL_08      := oSALA_PLAN_ANAL.CODE_ANAL_AXE8;
       oGEAV.PLAN2_CODE_ANAL_09      := oSALA_PLAN_ANAL.CODE_ANAL_AXE9;
       oGEAV.PLAN2_CODE_ANAL_10      := oSALA_PLAN_ANAL.CODE_ANAL_AX10;
       oGEAV.PLAN2_CODE_ANAL_11      := oSALA_PLAN_ANAL.CODE_ANAL_AX11;
       oGEAV.PLAN2_CODE_ANAL_12      := oSALA_PLAN_ANAL.CODE_ANAL_AX12;
       oGEAV.PLAN2_CODE_ANAL_13      := oSALA_PLAN_ANAL.CODE_ANAL_AX13;
       oGEAV.PLAN2_CODE_ANAL_14      := oSALA_PLAN_ANAL.CODE_ANAL_AX14;
       oGEAV.PLAN2_CODE_ANAL_15      := oSALA_PLAN_ANAL.CODE_ANAL_AX15;
       oGEAV.PLAN2_CODE_ANAL_16      := oSALA_PLAN_ANAL.CODE_ANAL_AX16;
       oGEAV.PLAN2_CODE_ANAL_17      := oSALA_PLAN_ANAL.CODE_ANAL_AX17;
       oGEAV.PLAN2_CODE_ANAL_18      := oSALA_PLAN_ANAL.CODE_ANAL_AX18;
       oGEAV.PLAN2_CODE_ANAL_19      := oSALA_PLAN_ANAL.CODE_ANAL_AX19;
       oGEAV.PLAN2_CODE_ANAL_20      := oSALA_PLAN_ANAL.CODE_ANAL_AX20;
       oGEAV.PLAN2_POUR_AFFE_ANAL_01 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL);
       oGEAV.PLAN2_POUR_AFFE_ANAL_02 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE2);
       oGEAV.PLAN2_POUR_AFFE_ANAL_03 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE3);
       oGEAV.PLAN2_POUR_AFFE_ANAL_04 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE4);
       oGEAV.PLAN2_POUR_AFFE_ANAL_05 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE5);
       oGEAV.PLAN2_POUR_AFFE_ANAL_06 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE6);
       oGEAV.PLAN2_POUR_AFFE_ANAL_07 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE7);
       oGEAV.PLAN2_POUR_AFFE_ANAL_08 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE8);
       oGEAV.PLAN2_POUR_AFFE_ANAL_09 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE9);
       oGEAV.PLAN2_POUR_AFFE_ANAL_10 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX10);
       oGEAV.PLAN2_POUR_AFFE_ANAL_11 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX11);
       oGEAV.PLAN2_POUR_AFFE_ANAL_12 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX12);
       oGEAV.PLAN2_POUR_AFFE_ANAL_13 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX13);
       oGEAV.PLAN2_POUR_AFFE_ANAL_14 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX14);
       oGEAV.PLAN2_POUR_AFFE_ANAL_15 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX15);
       oGEAV.PLAN2_POUR_AFFE_ANAL_16 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX16);
       oGEAV.PLAN2_POUR_AFFE_ANAL_17 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX17);
       oGEAV.PLAN2_POUR_AFFE_ANAL_18 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX18);
       oGEAV.PLAN2_POUR_AFFE_ANAL_19 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX19);
       oGEAV.PLAN2_POUR_AFFE_ANAL_20 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX20);
     elsif iNUME_PLAN = 3 then
       oGEAV.PLAN3_CODE_ANAL_01      := oSALA_PLAN_ANAL.CODE_ANAL;
       oGEAV.PLAN3_CODE_ANAL_02      := oSALA_PLAN_ANAL.CODE_ANAL_AXE2;
       oGEAV.PLAN3_CODE_ANAL_03      := oSALA_PLAN_ANAL.CODE_ANAL_AXE3;
       oGEAV.PLAN3_CODE_ANAL_04      := oSALA_PLAN_ANAL.CODE_ANAL_AXE4;
       oGEAV.PLAN3_CODE_ANAL_05      := oSALA_PLAN_ANAL.CODE_ANAL_AXE5;
       oGEAV.PLAN3_CODE_ANAL_06      := oSALA_PLAN_ANAL.CODE_ANAL_AXE6;
       oGEAV.PLAN3_CODE_ANAL_07      := oSALA_PLAN_ANAL.CODE_ANAL_AXE7;
       oGEAV.PLAN3_CODE_ANAL_08      := oSALA_PLAN_ANAL.CODE_ANAL_AXE8;
       oGEAV.PLAN3_CODE_ANAL_09      := oSALA_PLAN_ANAL.CODE_ANAL_AXE9;
       oGEAV.PLAN3_CODE_ANAL_10      := oSALA_PLAN_ANAL.CODE_ANAL_AX10;
       oGEAV.PLAN3_CODE_ANAL_11      := oSALA_PLAN_ANAL.CODE_ANAL_AX11;
       oGEAV.PLAN3_CODE_ANAL_12      := oSALA_PLAN_ANAL.CODE_ANAL_AX12;
       oGEAV.PLAN3_CODE_ANAL_13      := oSALA_PLAN_ANAL.CODE_ANAL_AX13;
       oGEAV.PLAN3_CODE_ANAL_14      := oSALA_PLAN_ANAL.CODE_ANAL_AX14;
       oGEAV.PLAN3_CODE_ANAL_15      := oSALA_PLAN_ANAL.CODE_ANAL_AX15;
       oGEAV.PLAN3_CODE_ANAL_16      := oSALA_PLAN_ANAL.CODE_ANAL_AX16;
       oGEAV.PLAN3_CODE_ANAL_17      := oSALA_PLAN_ANAL.CODE_ANAL_AX17;
       oGEAV.PLAN3_CODE_ANAL_18      := oSALA_PLAN_ANAL.CODE_ANAL_AX18;
       oGEAV.PLAN3_CODE_ANAL_19      := oSALA_PLAN_ANAL.CODE_ANAL_AX19;
       oGEAV.PLAN3_CODE_ANAL_20      := oSALA_PLAN_ANAL.CODE_ANAL_AX20;
       oGEAV.PLAN3_POUR_AFFE_ANAL_01 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL);
       oGEAV.PLAN3_POUR_AFFE_ANAL_02 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE2);
       oGEAV.PLAN3_POUR_AFFE_ANAL_03 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE3);
       oGEAV.PLAN3_POUR_AFFE_ANAL_04 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE4);
       oGEAV.PLAN3_POUR_AFFE_ANAL_05 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE5);
       oGEAV.PLAN3_POUR_AFFE_ANAL_06 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE6);
       oGEAV.PLAN3_POUR_AFFE_ANAL_07 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE7);
       oGEAV.PLAN3_POUR_AFFE_ANAL_08 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE8);
       oGEAV.PLAN3_POUR_AFFE_ANAL_09 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE9);
       oGEAV.PLAN3_POUR_AFFE_ANAL_10 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX10);
       oGEAV.PLAN3_POUR_AFFE_ANAL_11 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX11);
       oGEAV.PLAN3_POUR_AFFE_ANAL_12 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX12);
       oGEAV.PLAN3_POUR_AFFE_ANAL_13 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX13);
       oGEAV.PLAN3_POUR_AFFE_ANAL_14 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX14);
       oGEAV.PLAN3_POUR_AFFE_ANAL_15 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX15);
       oGEAV.PLAN3_POUR_AFFE_ANAL_16 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX16);
       oGEAV.PLAN3_POUR_AFFE_ANAL_17 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX17);
       oGEAV.PLAN3_POUR_AFFE_ANAL_18 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX18);
       oGEAV.PLAN3_POUR_AFFE_ANAL_19 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX19);
       oGEAV.PLAN3_POUR_AFFE_ANAL_20 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX20);
     elsif iNUME_PLAN = 4 then
       oGEAV.PLAN4_CODE_ANAL_01      := oSALA_PLAN_ANAL.CODE_ANAL;
       oGEAV.PLAN4_CODE_ANAL_02      := oSALA_PLAN_ANAL.CODE_ANAL_AXE2;
       oGEAV.PLAN4_CODE_ANAL_03      := oSALA_PLAN_ANAL.CODE_ANAL_AXE3;
       oGEAV.PLAN4_CODE_ANAL_04      := oSALA_PLAN_ANAL.CODE_ANAL_AXE4;
       oGEAV.PLAN4_CODE_ANAL_05      := oSALA_PLAN_ANAL.CODE_ANAL_AXE5;
       oGEAV.PLAN4_CODE_ANAL_06      := oSALA_PLAN_ANAL.CODE_ANAL_AXE6;
       oGEAV.PLAN4_CODE_ANAL_07      := oSALA_PLAN_ANAL.CODE_ANAL_AXE7;
       oGEAV.PLAN4_CODE_ANAL_08      := oSALA_PLAN_ANAL.CODE_ANAL_AXE8;
       oGEAV.PLAN4_CODE_ANAL_09      := oSALA_PLAN_ANAL.CODE_ANAL_AXE9;
       oGEAV.PLAN4_CODE_ANAL_10      := oSALA_PLAN_ANAL.CODE_ANAL_AX10;
       oGEAV.PLAN4_CODE_ANAL_11      := oSALA_PLAN_ANAL.CODE_ANAL_AX11;
       oGEAV.PLAN4_CODE_ANAL_12      := oSALA_PLAN_ANAL.CODE_ANAL_AX12;
       oGEAV.PLAN4_CODE_ANAL_13      := oSALA_PLAN_ANAL.CODE_ANAL_AX13;
       oGEAV.PLAN4_CODE_ANAL_14      := oSALA_PLAN_ANAL.CODE_ANAL_AX14;
       oGEAV.PLAN4_CODE_ANAL_15      := oSALA_PLAN_ANAL.CODE_ANAL_AX15;
       oGEAV.PLAN4_CODE_ANAL_16      := oSALA_PLAN_ANAL.CODE_ANAL_AX16;
       oGEAV.PLAN4_CODE_ANAL_17      := oSALA_PLAN_ANAL.CODE_ANAL_AX17;
       oGEAV.PLAN4_CODE_ANAL_18      := oSALA_PLAN_ANAL.CODE_ANAL_AX18;
       oGEAV.PLAN4_CODE_ANAL_19      := oSALA_PLAN_ANAL.CODE_ANAL_AX19;
       oGEAV.PLAN4_CODE_ANAL_20      := oSALA_PLAN_ANAL.CODE_ANAL_AX20;
       oGEAV.PLAN4_POUR_AFFE_ANAL_01 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL);
       oGEAV.PLAN4_POUR_AFFE_ANAL_02 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE2);
       oGEAV.PLAN4_POUR_AFFE_ANAL_03 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE3);
       oGEAV.PLAN4_POUR_AFFE_ANAL_04 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE4);
       oGEAV.PLAN4_POUR_AFFE_ANAL_05 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE5);
       oGEAV.PLAN4_POUR_AFFE_ANAL_06 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE6);
       oGEAV.PLAN4_POUR_AFFE_ANAL_07 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE7);
       oGEAV.PLAN4_POUR_AFFE_ANAL_08 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE8);
       oGEAV.PLAN4_POUR_AFFE_ANAL_09 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE9);
       oGEAV.PLAN4_POUR_AFFE_ANAL_10 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX10);
       oGEAV.PLAN4_POUR_AFFE_ANAL_11 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX11);
       oGEAV.PLAN4_POUR_AFFE_ANAL_12 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX12);
       oGEAV.PLAN4_POUR_AFFE_ANAL_13 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX13);
       oGEAV.PLAN4_POUR_AFFE_ANAL_14 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX14);
       oGEAV.PLAN4_POUR_AFFE_ANAL_15 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX15);
       oGEAV.PLAN4_POUR_AFFE_ANAL_16 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX16);
       oGEAV.PLAN4_POUR_AFFE_ANAL_17 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX17);
       oGEAV.PLAN4_POUR_AFFE_ANAL_18 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX18);
       oGEAV.PLAN4_POUR_AFFE_ANAL_19 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX19);
       oGEAV.PLAN4_POUR_AFFE_ANAL_20 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX20);
     elsif iNUME_PLAN = 5 then
       oGEAV.PLAN5_CODE_ANAL_01      := oSALA_PLAN_ANAL.CODE_ANAL;
       oGEAV.PLAN5_CODE_ANAL_02      := oSALA_PLAN_ANAL.CODE_ANAL_AXE2;
       oGEAV.PLAN5_CODE_ANAL_03      := oSALA_PLAN_ANAL.CODE_ANAL_AXE3;
       oGEAV.PLAN5_CODE_ANAL_04      := oSALA_PLAN_ANAL.CODE_ANAL_AXE4;
       oGEAV.PLAN5_CODE_ANAL_05      := oSALA_PLAN_ANAL.CODE_ANAL_AXE5;
       oGEAV.PLAN5_CODE_ANAL_06      := oSALA_PLAN_ANAL.CODE_ANAL_AXE6;
       oGEAV.PLAN5_CODE_ANAL_07      := oSALA_PLAN_ANAL.CODE_ANAL_AXE7;
       oGEAV.PLAN5_CODE_ANAL_08      := oSALA_PLAN_ANAL.CODE_ANAL_AXE8;
       oGEAV.PLAN5_CODE_ANAL_09      := oSALA_PLAN_ANAL.CODE_ANAL_AXE9;
       oGEAV.PLAN5_CODE_ANAL_10      := oSALA_PLAN_ANAL.CODE_ANAL_AX10;
       oGEAV.PLAN5_CODE_ANAL_11      := oSALA_PLAN_ANAL.CODE_ANAL_AX11;
       oGEAV.PLAN5_CODE_ANAL_12      := oSALA_PLAN_ANAL.CODE_ANAL_AX12;
       oGEAV.PLAN5_CODE_ANAL_13      := oSALA_PLAN_ANAL.CODE_ANAL_AX13;
       oGEAV.PLAN5_CODE_ANAL_14      := oSALA_PLAN_ANAL.CODE_ANAL_AX14;
       oGEAV.PLAN5_CODE_ANAL_15      := oSALA_PLAN_ANAL.CODE_ANAL_AX15;
       oGEAV.PLAN5_CODE_ANAL_16      := oSALA_PLAN_ANAL.CODE_ANAL_AX16;
       oGEAV.PLAN5_CODE_ANAL_17      := oSALA_PLAN_ANAL.CODE_ANAL_AX17;
       oGEAV.PLAN5_CODE_ANAL_18      := oSALA_PLAN_ANAL.CODE_ANAL_AX18;
       oGEAV.PLAN5_CODE_ANAL_19      := oSALA_PLAN_ANAL.CODE_ANAL_AX19;
       oGEAV.PLAN5_CODE_ANAL_20      := oSALA_PLAN_ANAL.CODE_ANAL_AX20;
       oGEAV.PLAN5_POUR_AFFE_ANAL_01 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL);
       oGEAV.PLAN5_POUR_AFFE_ANAL_02 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE2);
       oGEAV.PLAN5_POUR_AFFE_ANAL_03 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE3);
       oGEAV.PLAN5_POUR_AFFE_ANAL_04 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE4);
       oGEAV.PLAN5_POUR_AFFE_ANAL_05 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE5);
       oGEAV.PLAN5_POUR_AFFE_ANAL_06 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE6);
       oGEAV.PLAN5_POUR_AFFE_ANAL_07 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE7);
       oGEAV.PLAN5_POUR_AFFE_ANAL_08 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE8);
       oGEAV.PLAN5_POUR_AFFE_ANAL_09 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AXE9);
       oGEAV.PLAN5_POUR_AFFE_ANAL_10 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX10);
       oGEAV.PLAN5_POUR_AFFE_ANAL_11 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX11);
       oGEAV.PLAN5_POUR_AFFE_ANAL_12 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX12);
       oGEAV.PLAN5_POUR_AFFE_ANAL_13 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX13);
       oGEAV.PLAN5_POUR_AFFE_ANAL_14 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX14);
       oGEAV.PLAN5_POUR_AFFE_ANAL_15 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX15);
       oGEAV.PLAN5_POUR_AFFE_ANAL_16 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX16);
       oGEAV.PLAN5_POUR_AFFE_ANAL_17 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX17);
       oGEAV.PLAN5_POUR_AFFE_ANAL_18 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX18);
       oGEAV.PLAN5_POUR_AFFE_ANAL_19 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX19);
       oGEAV.PLAN5_POUR_AFFE_ANAL_20 := parse_float(oSALA_PLAN_ANAL.POUR_AFFE_ANAL_AX20);
     end if;
   end;

   function fct__prof_libe(
      i__SOCI number,
      v__TYPE varchar2,
      i__SALA number,
      d__PERI date
   )
   return varchar2
   is
      i__PROF number;
      o__PROF profil_paye_gene%rowtype;
   begin
      i__PROF := fct_profil_paye_affe(i__SOCI,v__TYPE,i__SALA,null,to_char(d__PERI,'DD/MM/YYYY'));

      if i__PROF is null then
         return null;
      else
          begin
            select
                *
            into
                o__PROF
            from profil_paye_gene
            where id_prof=i__PROF;

            return o__PROF.libe;
          exception
            when no_data_found then
             return ' Le profil a été supprimé ID := '|| i__PROF;
          end;
      end if;
   end fct__prof_libe;

   function fct__get_salarie(
      iSALARIE int
   )return salarie_table%rowtype
   is
      oSALARIE salarie_table%rowtype;
   begin
      if not ri_S_SALARIES.exists( iSALARIE ) then
         select
            *
         into
            oSALARIE
         from salarie_table
         where id_sala=iSALARIE;

         ri_S_SALARIES( iSALARIE ) := oSALARIE ;
      end if;

      return ri_S_SALARIES( iSALARIE );
   exception
      when no_data_found then
         return oSALARIE;
   end;

   function fct___rubrique_decodage(
      fNOMB      float,
      fBASE      float,
      fMONT_SALA float,
      fTAUX_SALA float,
      fMONT_PATR float,
      fTAUX_PATR float,
      fASSIETTE  float,
      fPLAFOND   float,
      fPOUR_ANAL float,
      pCOLO      varchar2,
      iFORM      int
   )
   return float
   is
      oForm c_FORMULE%rowtype;
   begin

      -- Cochez cette case si vous souhaitez les rubriques  sans montant salarial ou patronal :
      if nvl(oPara.libr_1,'N') != 'O' then
         -- On n'affiche pas les valeurs si MS=ZERO ou MP=ZERO
         if fMONT_SALA=0 and fMONT_PATR=0 then
            return null;
         end if;

         -- décodage : si oPara.libr_1='N' et que pas de montant... même  infinitésimaux, on n'affiche rien

         -- récupération du type de formule
         -- si les conditions de calcul ne sont pas remplies
         if ri_S_FORMULE.exists(iFORM) then
            oForm:=ri_S_FORMULE(iFORM);

            if oForm.nomb=1 and fNOMB=0 then
               -- le nombre est requis ET il est à zero...
               -- on sort
               return null;

            elsif  oForm.base=1 and fBASE=0 then
               -- la base est requise ET elle est à zero...
               -- on sort
               return null;

            elsif (oForm.taux_sala=1 and fTAUX_SALA=0) and (oForm.taux_patr=1 and fTAUX_PATR=0) then
               -- les deux taux sont requis ET ils sont tous les deux à zero...
               -- on sort
               return null;

            elsif (oForm.taux_sala=1 and fTAUX_SALA=0) and (oForm.taux_patr=0                 ) then
               -- seul le taux salarial est requis ET il est à zero...
               -- on sort
               return null;

            elsif (oForm.taux_sala=0                 ) and (oForm.taux_patr=1 and fTAUX_PATR=0) then
               -- seul le taux patronal est requis ET il est à zero...
               -- on sort
               return null;
            else
               -- on sort pas...
               null;
            end if;
         else
            -- formule non référencée
            -- regroupement
            null;
         end if;
      else
         -- On affiche les valeurs même si MS=ZERO ou MP=ZERO
         null;
      end if;

      if    pCOLO='BASE' then
        return fBASE;

      elsif pCOLO='NOMB' then
        return fNOMB;

      elsif pCOLO='MONT_SALA' then
        return fMONT_SALA;

      elsif pCOLO='TAUX_SALA' then
        return fTAUX_SALA;

      elsif pCOLO='MONT_PATR' then
        return fMONT_PATR;

      elsif pCOLO='TAUX_PATR' then
        return fTAUX_PATR;

      elsif pCOLO='ASSI' then
        return fASSIETTE;

      elsif pCOLO='PLAF' then
        return fPLAFOND;

      elsif pCOLO='POUR_ANAL' then
        return fPOUR_ANAL;

      else
        return 0;

      end if;

   end fct___rubrique_decodage;

   function fct__rubrique(
      pAFFI varchar2,-- RUBR,REGR,N
      pID   number,
      pSALA number,
      pCOLO varchar2,
      dPERI date
   )
   return float
   is
      ri_RUBR    pack_types.ti_integer;
      fNOMB      float;
      fBASE      float;
      fMONT_SALA float;
      fTAUX_SALA float;
      fMONT_PATR float;
      fTAUX_PATR float;
      fPLAF      float;
      fASSI      float;
      iFORM      int;
      fINCR      float;
      fCUMU      float default 0;
   begin

      if pID is not null and pSALA is not null and dPERI is not null and pCOLO is not null then
         if pAFFI='RUBR' then
            ri_RUBR(1):=pID;
         elsif pAFFI='REGR' then
            ri_RUBR:=fct_pa_regroupement_rubrique(pID);
         else
             return null;
         end if;
      else
         return null;
      end if;

      for i in 1..ri_RUBR.count loop
         begin
            select
               nvl(h.nomb,     0),
               nvl(h.base,     0),
               fct_rubrique_signe( h.id_rubr , h.type_rubr ) * nvl(h.mont_sala,0),
               nvl(h.taux_sala,0),
               fct_rubrique_signe( h.id_rubr , h.type_rubr ) * nvl(h.mont_patr,0),
               nvl(h.taux_patr,0),
               case fct_base_tranche( r.base ) when 1 then  h.base_coti else 0 end ,
               case fct_base_tranche( r.base ) when 1 then  h.plaf      else 0 end
            into
               fNOMB,
               fBASE,
               fMONT_SALA,
               fTAUX_SALA,
               fMONT_PATR,
               fTAUX_PATR,
               fASSI,
               fPLAF
            from hist_rubr_sala h,
                 rubrique r
            where h.id_sala=pSALA
              and h.peri=dPERI
              and h.id_rubr=ri_RUBR(i)
              and r.id_rubr=h.id_rubr
              and r.peri=h.peri
              and not exists( select 1 from sala$hist sh where sh.id_sala = h.id_sala and sh.hors_paie_type ='INTERM' and sh.acti$h ='1')
            ;
         exception when no_data_found then
            fNOMB:=0;
            fBASE:=0;
            fMONT_SALA:=0;
            fTAUX_SALA:=0;
            fMONT_PATR:=0;
            fTAUX_PATR:=0;
            fASSI     :=0;
            fPLAF     :=0;
         end;

         if pAFFI='REGR' then
            fTAUX_SALA:=0;
            fTAUX_PATR:=0;
            fPLAF     :=0;
            iFORM     :=0;
         end if;

         fINCR:=fct___rubrique_decodage( fNOMB     ,
                                         fBASE     ,
                                         fMONT_SALA,
                                         fTAUX_SALA,
                                         fMONT_PATR,
                                         fTAUX_PATR,
                                         fASSI,
                                         fPLAF,
                                         0,
                                         pCOLO,
                                         iFORM
         );

         fCUMU:=nvl(fCUMU,0)+nvl(fINCR,0);

      end loop;

      return fCUMU;
   end fct__rubrique;

   function fct_rubrique_analytique(
      pAFFI varchar2,
      pID   number,
      pSALA number,
      pCOLO varchar2,
      dPERI date,
      pREPA_CODE varchar2,
      iAXE  int
   )
   return float
   is
      ri_RUBR    pack_types.ti_integer;
      fNOMB      float;
      fBASE      float;
      fMONT_SALA float;
      fTAUX_SALA float;
      fMONT_PATR float;
      fTAUX_PATR float;
      fPOUR_ANAL float;
      iFORM      int;
      fINCR      float;
      fCUMU      float default 0;
   begin
      if pID is not null and pSALA is not null and dPERI is not null and pCOLO is not null then
         if pAFFI='RUBR' then
            ri_RUBR(1):=pID;
         elsif pAFFI='REGR' then
            ri_RUBR:=fct_pa_regroupement_rubrique(pID);
         else
            return null;
         end if;
      else
         return null;
      end if;


      for i in 1..ri_RUBR.count loop
         begin
            select
               sum(                                                     nvl(h.nomb_non_arr , 0)) ,
               sum(                                                     nvl(h.base_non_arr , 0)) ,
               sum(fct_rubrique_signe( h.id_rubr , r.code_type_rubr ) * nvl(h.mont_sala    , 0)) ,
               max(                                                     nvl(h.taux_sala    , 0)) ,
               sum(fct_rubrique_signe( h.id_rubr , r.code_type_rubr ) * nvl(h.mont_patr    , 0)) ,
               max(                                                     nvl(h.taux_patr    , 0)) ,
               sum(                                                     nvl(h.pour_anal    , 0)) ,
               max(r.code_form_rubr)
            into
               fNOMB,
               fBASE,
               fMONT_SALA,
               fTAUX_SALA,
               fMONT_PATR,
               fTAUX_PATR,
               fPOUR_ANAL,
               iFORM
            from hist_rubr_sala_anal h,
                 rubrique r
            where
                h.id_rubr=ri_RUBR(i)
            and h.id_sala=pSALA
            and h.peri=dPERI
            and h.code_anal=pREPA_CODE
            and r.id_rubr=h.id_rubr
            and r.peri=h.peri
            and not exists( select 1 from sala$hist sh where sh.id_sala = h.id_sala and sh.hors_paie_type ='INTERM' and sh.acti$h ='1')
            ;

         exception when no_data_found then
            fNOMB:=0;
            fBASE:=0;
            fMONT_SALA:=0;
            fTAUX_SALA:=0;
            fMONT_PATR:=0;
            fTAUX_PATR:=0;
            fPOUR_ANAL:=0;
         end;

         if pAFFI='REGR' then
            fTAUX_SALA:=0;
            fTAUX_PATR:=0;
            iFORM     :=0;
         end if;

         fINCR:=fct___rubrique_decodage( fNOMB     ,
                                         fBASE     ,
                                         fMONT_SALA,
                                         fTAUX_SALA,
                                         fMONT_PATR,
                                         fTAUX_PATR,
                                         0,
                                         0,
                                         0,
                                         pCOLO,
                                         iFORM
         );

         fCUMU:=nvl(fCUMU,0)+nvl(fINCR,0);

      end loop;

      return fCUMU;

   end fct_rubrique_analytique;

   function fct__get_banque( iSALARIE int ,vCODE_TYPE varchar2 ) return pack_embeded.r_BANQ
   is
      oBANQUE pack_embeded.r_BANQ;
   begin
      if rv_BANQ.exists(iSALARIE||'~'||vCODE_TYPE) then
         return rv_BANQ(iSALARIE||'~'||vCODE_TYPE) ;

      else
         oBANQUE:=pack_embeded.get_salarie_banq(iSALARIE,vCODE_TYPE );
         rv_BANQ(iSALARIE||'~'||vCODE_TYPE):=oBANQUE;
         return oBANQUE;
      end if;
   end ;

 function fct__vale_anti_rtt(
    vVALE_COMP   in varchar2,
    vCOMP_TYPE   in varchar2,
    vACQU_REST   in varchar2,
    iAFFI_COMP   in varchar2,
    pPERI        in date,
    pID_ETAB     in NUMBER,
    pID_SALA     in NUMBER

  )return varchar2
  is
    type tPERI_CLOT is table of varchar2(1) index by binary_integer;
    type tACQU_MOIS is table of float index by binary_integer;

    fVALE_COUR        float;
    vBOUC_CLOT        varchar2(1) default 'N';
    vEXIS_CLOT        varchar2(1) default 'N';
    iMOIS_SUIV        integer;
    rPERI_CLOT        tPERI_CLOT;
    rACQU_MOIS        tACQU_MOIS;
    dPERI_SUIV        date;
    fACQU_MOIS_SUIV   float;
    vINCR_SUIV_TYPE   varchar2(10);
    vPROR_HORA        varchar2(1) default 'N';
    iPROR_IO          number default 0;
    vARRO_ACQU        varchar2(1) default 'N';
    iPROR_FORF_ACTI   number default 0;
    vPROR_FORF_FORC   varchar2(1) default 'N';
    iPROR_FORF_VALE   number default 0;
    fFORF_CONV_VALE   float;
    fFORF_SALA_VALE   float;
    fFORF_COEF        float;
    fPROR_COEF        float;
    fPROR_HORAISOC    float;
    fPROR_HORAIRE     float;
    fMINO_PROR_J_SOCI float;
    fMINO_PROR_J_IO   float;
    fMINO_PROR_P_SOCI float;
    fMINO_PROR_P_IO   float;
    iUTIL_PARA_SAL_PAT integer;
    cursor c_JOURS is
      select
        c.date_jour,
        c.anne,
        c.sema_anne,
        c.jour_sema
      from calendrier c
      where c.date_jour between dPERI_SUIV and last_day(dPERI_SUIV)
      order by c.date_jour
      ;

  begin

    fVALE_COUR := parse_float(vVALE_COMP);
    -- ML 2018 07 17 T:73411
    if iAFFI_COMP=0 then
      return null;
    else
      --------------------------------------------------------------------------------------------------------
      --------------------------------------------------------------------------------------------------------
      -- DEB : Détermination du droit à l anticipation à l affichage et détermination des périodes de clôtures
      --------------------------------------------------------------------------------------------------------
      if vCOMP_TYPE='RTTS' then
        -- Compteurs RTT sal.
        dbms_output.put_line( 'ANTICIP '||vACQU_REST||' [RTTS] INIT - Vale Acq M='||vVALE_COMP||', Acq. anticip [O/N] ? ='|| nvl(oRTT.acqu_anti_annu_sala,'N'));

        if nvl(oRTT.acqu_anti_annu_sala,'N')='O' then
          -- autorise l entrée dans la boucle pour détermination de prochaine clôture
          vBOUC_CLOT:='O';

          -- mise en tableau des périodes de clôture prévues
          for iMois in 1..12 loop
               if iMois= 1 then if nvl(oRTT.clot_01,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_01,0);
            elsif iMois= 2 then if nvl(oRTT.clot_02,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_02,0);
            elsif iMois= 3 then if nvl(oRTT.clot_03,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_03,0);
            elsif iMois= 4 then if nvl(oRTT.clot_04,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_04,0);
            elsif iMois= 5 then if nvl(oRTT.clot_05,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_05,0);
            elsif iMois= 6 then if nvl(oRTT.clot_06,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_06,0);
            elsif iMois= 7 then if nvl(oRTT.clot_07,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_07,0);
            elsif iMois= 8 then if nvl(oRTT.clot_08,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_08,0);
            elsif iMois= 9 then if nvl(oRTT.clot_09,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_09,0);
            elsif iMois=10 then if nvl(oRTT.clot_10,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_10,0);
            elsif iMois=11 then if nvl(oRTT.clot_11,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_11,0);
            elsif iMois=12 then if nvl(oRTT.clot_12,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_sala_12,0);
            end if;

            dbms_output.put_line( 'ANTICIP '||vACQU_REST||' [RTTS] BOUC : iMois='||iMois||', Peri clot [O,N] ? ='|| rPERI_CLOT(iMois) ||', Acq. prev ='||rACQU_MOIS(iMois));
          end loop;

          vPROR_HORA:=nvl(oRTT.pror_hora,'N');      -- paramètre de prorata horaire
          iPROR_IO  :=nvl(oRTT.pror_io,0);          -- paramètre de prorata entrée sortie
          vARRO_ACQU:=nvl(oRTT.arro_acqu_sala,'N'); -- paramètre arrondi acquisition
          iPROR_FORF_ACTI:=nvl(oRTT.pror_forf_jour_sala,0);   -- activation prorata forfait jour
          vPROR_FORF_FORC:=nvl(oRTT.forf_jour_conv_forc,'N'); -- forçage forfait jour conventionnel
          iPROR_FORF_VALE:=nvl(oRTT.forf_jour_conv_vale,0);   -- valeur forfait jour conventionnel forcé
        end if;

      else
        -- Compteurs RTT pat.

        -- récup d infos permettant de savoir quel param récupérer (spécifique RTT pat ou celui des RTT sal ?)
        if (oRTT.acti_para_rtt_patr is not null and oRTT.acti_para_rtt_patr='O') or oRTT.inde_rubr=2 then
          -- param spécifique RTT pat
          iUTIL_PARA_SAL_PAT:=2;
        else
          -- param RTT sal
          iUTIL_PARA_SAL_PAT:=1;
        end if;
        dbms_output.put_line( 'ANTICIP '||vACQU_REST||' [RTTP] INIT - Vale Acq M='||vVALE_COMP||', Acq. anticip (sal) [O/N] ? ='|| nvl(oRTT.acqu_anti_annu_sala,'N')||', Acqu anticip (pat) [O/N] ='|| nvl(oRTT.acqu_anti_annu_patr,'N')||', Util. Sal/Pat (1=sal+pat / 2=pat) ='|| iUTIL_PARA_SAL_PAT);

        if iUTIL_PARA_SAL_PAT=2 and nvl(oRTT.acqu_anti_annu_patr,'N')='O' then
          -- autorise l entrée dans la boucle pour détermination de prochaine clôture
          vBOUC_CLOT:='O';

          -- mise en tableau des périodes de clôture prévues
          for iMois in 1..12 loop
               if iMois= 1 then if nvl(oRTT.clot_patr_01,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_01,0);
            elsif iMois= 2 then if nvl(oRTT.clot_patr_02,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_02,0);
            elsif iMois= 3 then if nvl(oRTT.clot_patr_03,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_03,0);
            elsif iMois= 4 then if nvl(oRTT.clot_patr_04,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_04,0);
            elsif iMois= 5 then if nvl(oRTT.clot_patr_05,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_05,0);
            elsif iMois= 6 then if nvl(oRTT.clot_patr_06,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_06,0);
            elsif iMois= 7 then if nvl(oRTT.clot_patr_07,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_07,0);
            elsif iMois= 8 then if nvl(oRTT.clot_patr_08,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_08,0);
            elsif iMois= 9 then if nvl(oRTT.clot_patr_09,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_09,0);
            elsif iMois=10 then if nvl(oRTT.clot_patr_10,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_10,0);
            elsif iMois=11 then if nvl(oRTT.clot_patr_11,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_11,0);
            elsif iMois=12 then if nvl(oRTT.clot_patr_12,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_12,0);
            end if;

            dbms_output.put_line( 'ANTICIP '||vACQU_REST||' [RTTP] (pat) BOUC : iMois='||iMois||', Peri clot [O,N] ? ='|| rPERI_CLOT(iMois) ||', Acq. prev ='||rACQU_MOIS(iMois));
          end loop;

          vPROR_HORA:=nvl(oRTT.pror_hora_patr,'N'); -- paramètre de prorata horaire
          iPROR_IO  :=nvl(oRTT.pror_io_patr,0);     -- paramètre de prorata entrée sortie
          vARRO_ACQU:=nvl(oRTT.arro_acqu_patr,'N'); -- paramètre arrondi acquisition
          iPROR_FORF_ACTI:=nvl(oRTT.pror_forf_jour_patr,0);   -- activation prorata forfait jour
          vPROR_FORF_FORC:=nvl(oRTT.forf_jour_conv_forc,'N'); -- forçage forfait jour conventionnel
          iPROR_FORF_VALE:=nvl(oRTT.forf_jour_conv_vale,0);   -- valeur forfait jour conventionnel forcé

        elsif iUTIL_PARA_SAL_PAT=1 and nvl(oRTT.acqu_anti_annu_sala,'N')='O' then
          -- autorise l entrée dans la boucle pour détermination de prochaine clôture
          vBOUC_CLOT:='O';

          -- mise en tableau des périodes de clôture prévues
          for iMois in 1..12 loop
               if iMois= 1 then if nvl(oRTT.clot_01,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_01,0);
            elsif iMois= 2 then if nvl(oRTT.clot_02,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_02,0);
            elsif iMois= 3 then if nvl(oRTT.clot_03,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_03,0);
            elsif iMois= 4 then if nvl(oRTT.clot_04,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_04,0);
            elsif iMois= 5 then if nvl(oRTT.clot_05,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_05,0);
            elsif iMois= 6 then if nvl(oRTT.clot_06,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_06,0);
            elsif iMois= 7 then if nvl(oRTT.clot_07,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_07,0);
            elsif iMois= 8 then if nvl(oRTT.clot_08,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_08,0);
            elsif iMois= 9 then if nvl(oRTT.clot_09,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_09,0);
            elsif iMois=10 then if nvl(oRTT.clot_10,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_10,0);
            elsif iMois=11 then if nvl(oRTT.clot_11,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_11,0);
            elsif iMois=12 then if nvl(oRTT.clot_12,0)=1 then rPERI_CLOT(iMois):='O'; vEXIS_CLOT:='O'; else rPERI_CLOT(iMois):='N'; end if; rACQU_MOIS(iMois):=nvl(oRTT.acqu_patr_12,0);
            end if;

            dbms_output.put_line( 'ANTICIP '||vACQU_REST||' [RTTP] (sal) BOUC : iMois='||iMois||', Peri clot [O,N] ? ='|| rPERI_CLOT(iMois) ||', Acq. prev ='||rACQU_MOIS(iMois));
          end loop;

          vPROR_HORA:=nvl(oRTT.pror_hora,'N');      -- paramètre de prorata horaire
          iPROR_IO  :=nvl(oRTT.pror_io,0);          -- paramètre de prorata entrée sortie
          vARRO_ACQU:=nvl(oRTT.arro_acqu_sala,'N'); -- paramètre arrondi acquisition
          iPROR_FORF_ACTI:=nvl(oRTT.pror_forf_jour_sala,0);   -- activation prorata forfait jour
          vPROR_FORF_FORC:=nvl(oRTT.forf_jour_conv_forc,'N'); -- forçage forfait jour conventionnel
          iPROR_FORF_VALE:=nvl(oRTT.forf_jour_conv_vale,0);   -- valeur forfait jour conventionnel forcé
        end if;

      end if;
      --------------------------------------------------------------------------------------------------------
      -- FIN : Détermination du droit à l anticipation à l affichage et détermination des périodes de clôtures
      --------------------------------------------------------------------------------------------------------
      --------------------------------------------------------------------------------------------------------

      --------------------------------------------------------------------------------------------------
      --------------------------------------------------------------------------------------------------
      -- DEB : Boucle de valorisation du compteur anticipé
      --------------------------------------------------------------------------------------------------
      if vBOUC_CLOT='O' and vEXIS_CLOT='O' then

        iMOIS_SUIV := to_number(to_char(add_months(pPERI,1),'MM'));
        dPERI_SUIV := add_months(pPERI,1);

        -- boucle sur 11 mois (sortie possible avant)
        for iBouc in 1..11 loop
            if rPERI_CLOT(iMOIS_SUIV) ='N' then
              -- récupération acquis de référence
              vINCR_SUIV_TYPE := 'CONV';
              fACQU_MOIS_SUIV := rACQU_MOIS(iMOIS_SUIV);

            ------------------------------------------------------------------------------------------------------------------
            -- ML 20190918 T84617 : reproduction du code en pr_sabu_insert_profil_rtt correspondant au prorata horaire mensuel
            if vPROR_HORA='M' then

              fPROR_HORAISOC :=                   fct_horaisoc    (pID_ETAB,pID_SALA,to_char(pPERI,'DD/MM/YYYY') ) ;
              fPROR_HORAIRE  := nvl( parse_float( fct_hc_sala_nume(         pID_SALA,to_char(pPERI,'DD/MM/YYYY'),'HORAIRE' ) ) ,0 );

              if    fPROR_HORAISOC=0 then fPROR_COEF:=1;
              elsif fPROR_HORAIRE =0 then fPROR_COEF:=1;
              else
                fPROR_COEF:=fPROR_HORAIRE / fPROR_HORAISOC;

                if    fPROR_COEF > 1 then fPROR_COEF:=1;
                elsif fPROR_COEF < 0 then fPROR_COEF:=0;
                end if;
              end if;

              if fPROR_COEF != 1 then
                fACQU_MOIS_SUIV:=fACQU_MOIS_SUIV * fPROR_COEF;
              end if;

            end if;

            ------------------------------
            -- prorata au forfait jour
            if iPROR_FORF_ACTI=1 then

              -- valeur forfait jour conventionnel
              if vPROR_FORF_FORC='O' then
                -- valeur FORCÉE dans le profil
                fFORF_CONV_VALE := parse_float(iPROR_FORF_VALE);

              elsif fct_hc_sala_exists(pID_SALA,to_char(pPERI,'DD/MM/YYYY') ,'FORFAIT_JOUR_CONV_SALA')=1 then
                 -- valeur SALARIÉ présente
                 fFORF_CONV_VALE:= parse_float(fct_hc_sala_nume(pID_SALA,to_char(pPERI,'DD/MM/YYYY') ,'FORFAIT_JOUR_CONV_SALA'));

              elsif fct_hc_etab_exists(pID_ETAB,to_char(pPERI,'DD/MM/YYYY') ,'FORFAIT_JOUR_ETAB_SALA')=1 then
                 -- valeur ÉTABLISSEMENT présente
                 fFORF_CONV_VALE := parse_float(fct_hc_etab_nume(pID_ETAB,to_char(pPERI,'DD/MM/YYYY') ,'FORFAIT_JOUR_ETAB_SALA'));

              elsif fct_hc_soci_exists(pID_SOCI,to_char(pPERI,'DD/MM/YYYY') ,'FORFAIT_JOUR_CONV_SOCI')=1 then
                 -- valeur SOCIÉTÉ présente
                 fFORF_CONV_VALE := parse_float(fct_hc_soci_nume(pID_SOCI,to_char(pPERI,'DD/MM/YYYY') ,'FORFAIT_JOUR_CONV_SOCI'));
              else
                 -- sinon valeur GLOBALE
                 fFORF_CONV_VALE := parse_float(fct_hc_glob_nume(         to_char(pPERI,'DD/MM/YYYY') ,'FORFAIT_JOUR_CONV'));
              end if;

              -- valeur forfait jour salarié
              fFORF_SALA_VALE := parse_float(fct_hc_sala_nume(pID_SALA,to_char(pPERI,'DD/MM/YYYY') ,'FORFAIT_JOUR_ACQU'     ));

              if    fFORF_CONV_VALE =0 then fFORF_COEF:=1;
              elsif fFORF_SALA_VALE =0 then fFORF_COEF:=1;
              else
                fFORF_COEF := fFORF_SALA_VALE / fFORF_CONV_VALE;

                if    fFORF_COEF > 1 then fFORF_COEF:=1;
                elsif fFORF_COEF < 0 then fFORF_COEF:=0;
                end if;
              end if;

              if fFORF_COEF != 1 then
                fACQU_MOIS_SUIV:=fACQU_MOIS_SUIV * fFORF_COEF;
              end if;

            end if;

            ------------------------------------------------------------------------------------------------------------------
            -- ML 20190918 T84617  : reproduction du code en pr_sabu_insert_profil_rtt correspondant au prorata entrée sortie
            if iPROR_IO=1 and trunc(dDATE_FIN_CONT,'MM')=dPERI_SUIV and dDATE_FIN_CONT<>last_day(dPERI_SUIV) then

              fMINO_PROR_P_SOCI := 0;
              fMINO_PROR_P_IO   := 0;

              -- on lit chaque jour séquentiellement
              for j in c_JOURS loop
                -- JOUR TRAVAILLE DE REFERENCE ---------------
                ----- l absence E/S ne doit pas être décomptée
                ----- les jours feriés sont comptés comme des jours travaillés
                fMINO_PROR_J_SOCI := pack_cale.nb_jour (pID_SOCI,pID_SALA,to_char(j.date_jour,'DD/MM/YYYY'),to_char(j.date_jour,'DD/MM/YYYY'),0,0,'N','O','N','N');

                if fMINO_PROR_J_SOCI>0 then
                  -- ML 20210323 T121044 : modif de la condition
                  --  - on ne compte pas de jours d absence tant que la date de fin de contrat est supérieure ou égale au jour parcouru
                  if dDATE_FIN_CONT >= j.date_jour then fMINO_PROR_J_IO:=0;
                                                 else fMINO_PROR_J_IO:=1;
                  end if;

                else
                  -- pas jour IO
                  fMINO_PROR_J_IO:=0;
                end if;

                fMINO_PROR_P_SOCI := fMINO_PROR_P_SOCI + fMINO_PROR_J_SOCI;
                fMINO_PROR_P_IO   := fMINO_PROR_P_IO   + fMINO_PROR_J_IO;

              end loop;

              dbms_output.put_line( 'ANTICIP '||vACQU_REST||' ['||vCOMP_TYPE||'] INCR_'||vINCR_SUIV_TYPE||' : iBouc='||iBouc||', iMoisSuiv='||iMOIS_SUIV ||', PROR IO : J Soci='||fMINO_PROR_P_SOCI||', J IO='||fMINO_PROR_P_IO);

              if    fMINO_PROR_P_SOCI=0                 then fACQU_MOIS_SUIV:=0;
              elsif fMINO_PROR_P_IO > fMINO_PROR_P_SOCI then fACQU_MOIS_SUIV:=0;
              elsif fMINO_PROR_P_IO > 0                 then fACQU_MOIS_SUIV:=fACQU_MOIS_SUIV * ( (fMINO_PROR_P_SOCI-fMINO_PROR_P_IO) / fMINO_PROR_P_SOCI  ) ;
              end if;

            end if;

            -------------------------------------------------------------------------------------------------------------
            -- ML 20190918 T84617 : reproduction du code en pr_sabu_insert_profil_rtt pour arrondi après prorata --------
            if    vARRO_ACQU='O' then fACQU_MOIS_SUIV := ceil(fACQU_MOIS_SUIV);     -- à l entier supérieur
            elsif vARRO_ACQU='D' then fACQU_MOIS_SUIV := ceil(fACQU_MOIS_SUIV*2)/2; -- au demi supérieur
            end if;

            -- incrémentation de la valeur à retourner
            fVALE_COUR := fVALE_COUR + fACQU_MOIS_SUIV;

            dbms_output.put_line( 'ANTICIP '||vACQU_REST||' ['||vCOMP_TYPE||'] INCR_'||vINCR_SUIV_TYPE||' : iBouc='||iBouc||', iMoisSuiv='||iMOIS_SUIV ||', Acq ajou='||fACQU_MOIS_SUIV||', Acq tota='||fVALE_COUR);

            -- ML le 23/03/2021 T121044 modif de la condition (voir plus bas après modif dPERI_SUIV
            if iPROR_IO=1 and trunc(dDATE_FIN_CONT,'MM')=dPERI_SUIV then
              -- départ le mois suivant : OUI --> sortie de la boucle
              exit;
            end if;


            -- augmentation de l index sur le mois
            if iMOIS_SUIV = 12 then iMOIS_SUIV:=1; else iMOIS_SUIV:=iMOIS_SUIV+1; end if;

            -- passage à la période suivante
            dPERI_SUIV := add_months(dPERI_SUIV,1);

          else
            -- clôture le mois suivant : OUI --> sortie de la boucle
            exit;
          end if;
        end loop;

      end if; -- if vBOUC_CLOT='O' then
      --------------------------------------------------------------------------------------------------
      -- FIN : Boucle de valorisation du compteur anticipé
      --------------------------------------------------------------------------------------------------
      --------------------------------------------------------------------------------------------------

      -- formatage de la valeur finale en varchar avec remplacement des . par des ,
      return replace(fct_format(fVALE_COUR,'DEC3','O'),'.',',');
    end if; --if iAFFI_COMP=0 then

  end;

  function fct__affi_comp(
    vCASE      in varchar2,
    vVALEUR    in varchar2,
    iAFFI_COMP in int,
    iCOMP_ZERO in int
  )return varchar2
  is
    fVALEUR float;
  begin
    if iAFFI_COMP=0 then
      return null;

    else
      if iCOMP_ZERO=1 and vCASE in ('REST','ACQU') then
        fVALEUR:=0;
      else
        fVALEUR:=parse_float( vVALEUR );
      end if;

      return replace ( fct_format( fVALEUR, 'DEC3' , 'O' ) , '.' , ',' ) ;

    end if;
  end;
   function fct__constante(
      pAFFI varchar2,
      pCODE varchar2,
      pSALA number,
      pPERI date,
      pPOUR_ANAL float,
      pREPA_ANAL varchar,
      pLOOP_ANAL int,
      pID_ETAB  number,
      pAFFI_RTT varchar2,
      pDATE_DEPA_BULL date
   )
   return float
   is
     fVALE      float;
     fRTT_ACQU  float;
     fRTT_ACQU_P float;
     fRTT_ACQU_S float;
     dSORTIETABL_ES    date;
     dDepart           date;
     iRTT_COMP_ZERO  number;
     vRTT_COMM_AFFI  VARCHAR2(2);
     vPERI         varchar2(10);

   begin
     if   nvl(pLOOP_ANAL,0)!=1
      and nvl(pREPA_ANAL,'N')!='O'
      and oPara.rupt_dema='O' then
        return 0;
     end if;

   
     if (pAFFI='O' or (parse_int(pAFFI) is not null and parse_int(pAFFI)!=-1)) and pCODE is not null and pSALA is not null and pPERI is not null then
       begin
         select
           nvl(vale,0)
         into
           fVALE
         from hist_cons_sala
         where code_cons=pCODE
           and id_sala=pSALA
           and peri=pPERI
         ;
       exception when no_data_found then
          if pCODE = 'RTTACQANNE_SALA_REFE' THEN
            vPERI:=to_char(pPERI,'DD/MM/YYYY');
            iID_PROF :=fct_profil_paye_affe(pID_SOCI,'RTT',pSALA,'',vPERI);

              if iID_PROF is not null and not ri_S_PROFIL_PAYE_RTT.exists(iID_PROF) then

                  select *
                    into rPROF_RTT
                    from profil_paye_rtt
                    where id_prof= iID_PROF;

                  ri_S_PROFIL_PAYE_RTT(iID_PROF) := rPROF_RTT;

              end if;

              if iID_PROF is not null  then
                oRtt:=ri_S_PROFIL_PAYE_RTT(iID_PROF);

                dSORTIETABL_ES := fct_hc_sala_date(pSALA,vPERI,'SORTIETABL_ES',null,'N');
                dDepart        := nvl(pDATE_DEPA_BULL,dSORTIETABL_ES);
                iRTT_COMP_ZERO := parse_int( fct_hc_sala_nume(pSALA,vPERI,'RTT_COMP_ZERO'     ) );

                if  oRTT.acti_affi_rtt1_sala ='O' and  oRTT.clot_vola = 1   then
                  fRTT_ACQU_S   := fct_hc_sala_comp(iID_SOCI,pSALA,vPERI,'RTT1_SALA_ACQU_ANNE'            ,'','N');
                else
                  fRTT_ACQU_S  := fct_hc_sala_comp(iID_SOCI,pSALA,vPERI,'RTT_SALA_ACQU_ANNE'            ,'','N');
                end if;
              
                fRTT_ACQU_P  := fct_hc_sala_comp(iID_SOCI,pSALA,vPERI,'RTT_PATR_ACQU_ANNE'            ,'','N');


                if dDepart is null then
                  fRTT_ACQU    := replace(fct_format(
                                  fct__vale_anti_rtt(fct__affi_comp('ACQU',fRTT_ACQU_S,oRTT.comp_rttc_affi_acqu,iRTT_COMP_ZERO)  ,'RTTS', 'ACQU', oRTT.comp_rttc_affi_acqu, pPERI, pID_ETAB, pSALA)
                                + fct__vale_anti_rtt(fct__affi_comp('ACQU',fRTT_ACQU_P,oRTT.comp_rttc_affi_acqu,iRTT_COMP_ZERO)  ,'RTTP', 'ACQU', oRTT.comp_rttc_affi_acqu, pPERI, pID_ETAB, pSALA)
                                  ,'DEC3','O'),'.',',');
                else
                  fRTT_ACQU    :=fct__affi_comp('ACQU', fRTT_ACQU_S + fRTT_ACQU_P, oRTT.comp_rttc_affi_acqu, iRTT_COMP_ZERO );
                end if;

                fVALE:= fRTT_ACQU;
              else
                fVALE:=0;
              end if;
            else
                fVALE:=0;
            end if;
       end;

       if nvl(pREPA_ANAL,'N')='O' and oPara.rupt_dema='O' then
          if nvl(pPOUR_ANAL,0)=0 then
              return 0;
          else
            return fVALE * pPOUR_ANAL /100;
          end if;
       else
         return fVALE;
       end if;

     else
      return null;
     end if;
   end fct__constante;

   function fct__libe_spec_inte_vaca_pigi(
      i__SOCI number,
      i__MODB number,
      v__CODE varchar2
   )
   return varchar2
   is
      v__SPEC varchar2(200);
   begin

     if fct_modbull_vacataire(i__MODB)=1 then
        -- salarié vacataire
        begin
          select
             libe into v__SPEC
          from (
             select 'NON'      as CODE, 'Aucune'                                                        as LIBE from dual union
             select 'OUI_SALA' as CODE, 'Indemn. de précarité et CP à partir de salaires de référence'  as LIBE from dual union
             select 'OUI_BRUT' as CODE, 'Indemn. de précarité et de congés à partir du total brut'      as LIBE from dual union
             select 'OUI_BASE' as CODE, 'Indemn. de précarité et de congés à partir du salaire de base' as LIBE from dual union
             select 'SALA'     as CODE, 'Indemn. de CP à partir du salaire de base'                     as LIBE from dual union
             select 'SUIV'     as CODE, 'Salariés suiveurs'                                             as LIBE from dual union
             select 'ENQU'     as CODE, 'Enquêteurs'                                                    as LIBE from dual union
             select 'HOTE'     as CODE, 'Maître d''hôtel'                                               as LIBE from dual union
             select
               code_prof as code,
               '[*] '||libe_prof as libe
             from societe_vaca_prof_sala
             where id_soci=i__SOCI
          ) where code=v__CODE;

        exception
          when no_data_found then v__SPEC := 'Aucune';
        end;

     elsif fct_modbull_intermittent(i__MODB)=1 then
        -- salarié intermittent
        if v__CODE='O' then v__SPEC:='Précarité et congés automatiques';
                       else v__SPEC:='Précarité et congés non automatiques';
        end if;

     elsif fct_modbull_pigiste(i__MODB)=1 then
        -- salarié pigiste
        if    v__CODE='OUI_CP13' then v__SPEC:='Primes CP et 13<sup>ème</sup> mois inclues dans le montant de chaque pige';
        elsif v__CODE='OUI_BASE' then v__SPEC:='Primes et indemnités automatiques';
                                 else v__SPEC:='Primes et indemnités non automatiques';
        end if;

     else
        -- salarié permanent : non concerné
        v__SPEC:=null;
     end if;

     return v__SPEC;

   end fct__libe_spec_inte_vaca_pigi;



   --------------
   -- MUTUELLES
   --------------
   -- Récupérer le paramétrage des mutuelles de la société sur la période
   procedure pr__get_mutuelles(pSOCIETE in int, pPERIODE in date)
   is
   begin
     ri_MUTU_SOUM_TAUX.delete;
     ri_MUTU_SOUM_MONT.delete;
     ri_MUTU_NOSO_TAUX.delete;
     ri_MUTU_NOSO_MONT.delete;

     -- Mutuelles soumises
     open cMUTUELLES(pSOCIETE,pPERIODE,'N','TXMUSAL','TXMUPAT','TXMU','TAUX','20');
     loop
       fetch cMUTUELLES bulk collect into ri_MUTU limit 2000;
       for i in 1 .. ri_MUTU.count
       loop
         ri_MUTU_SOUM_TAUX(ri_MUTU(i).id_soci||'-'||to_char(ri_MUTU(i).peri,'DDMMYYYY')||'-'||ri_MUTU(i).code) := ri_MUTU(i);
       end loop;
       exit when cMUTUELLES%notfound;
     end loop;
     close cMUTUELLES;

     open cMUTUELLES(pSOCIETE,pPERIODE,'N','MOMUSAL','MOMUPAT','MOMU','MONT','20');
     loop
       fetch cMUTUELLES bulk collect into ri_MUTU limit 2000;
       for i in 1 .. ri_MUTU.count
       loop
         ri_MUTU_SOUM_MONT(ri_MUTU(i).id_soci||'-'||to_char(ri_MUTU(i).peri,'DDMMYYYY')||'-'||ri_MUTU(i).code) := ri_MUTU(i);
       end loop;
       exit when cMUTUELLES%notfound;
     end loop;
     close cMUTUELLES;

     -- Mutuelles non soumises
     open cMUTUELLES(pSOCIETE,pPERIODE,'O','TXMUSAL_NOSO_','TXMUPAT_NOSO_','TXMU_NOSO_','TAUX','20');
     loop
       fetch cMUTUELLES bulk collect into ri_MUTU limit 2000;
       for i in 1 .. ri_MUTU.count
       loop
         ri_MUTU_NOSO_TAUX(ri_MUTU(i).id_soci||'-'||to_char(ri_MUTU(i).peri,'DDMMYYYY')||'-'||ri_MUTU(i).code) := ri_MUTU(i);
       end loop;
       exit when cMUTUELLES%notfound;
     end loop;
     close cMUTUELLES;

     open cMUTUELLES(pSOCIETE,pPERIODE,'N','MUTU_MONT_SALA_NOSO_','MUTU_MONT_PATR_NOSO_','','MONT','15');
     loop
       fetch cMUTUELLES bulk collect into ri_MUTU limit 2000;
       for i in 1 .. ri_MUTU.count
       loop
         ri_MUTU_NOSO_MONT(ri_MUTU(i).id_soci||'-'||to_char(ri_MUTU(i).peri,'DDMMYYYY')||'-'||ri_MUTU(i).code) := ri_MUTU(i);
       end loop;
       exit when cMUTUELLES%notfound;
     end loop;
     close cMUTUELLES;
   end pr__get_mutuelles;

   -- Récupérer le libellé de la mutuelle
   function fct__mutuelle_desc(pSOCIETE in int, pPERIODE in date, pTYPE in varchar2, pCODE in varchar2) return varchar2
   as
     vINDE      varchar2(200);
     vDESC      varchar2(255);

   begin
     if pTYPE not in ('SOUM_TAUX', 'SOUM_MONT', 'NOSO_TAUX', 'NOSO_MONT') then return null; end if;

     vINDE := pSOCIETE||'-'||to_char(pPERIODE,'DDMMYYYY')||'-'||pCODE;

     if pTYPE = 'SOUM_TAUX' then
       if ri_MUTU_SOUM_TAUX.exists(vINDE) then vDESC := ri_MUTU_SOUM_TAUX(vINDE).description; end if;
     elsif pTYPE = 'SOUM_MONT' then
       if ri_MUTU_SOUM_MONT.exists(vINDE) then vDESC := ri_MUTU_SOUM_MONT(vINDE).description; end if;
     elsif pTYPE = 'NOSO_TAUX' then
       if ri_MUTU_NOSO_TAUX.exists(vINDE) then vDESC := ri_MUTU_NOSO_TAUX(vINDE).description; end if;
     elsif pTYPE = 'NOSO_MONT' then
       if ri_MUTU_NOSO_MONT.exists(vINDE) then vDESC := ri_MUTU_NOSO_MONT(vINDE).description; end if;
     else
       vDESC      := null;
     end if;

     return vDESC;
   end fct__mutuelle_desc;

   function fct__get_personnel_salaries(pPERS in table_of_varchar2_255) return table_of_varchar2_255
   as
     iID_PERS   number;
     iINDE_SALA int;

     ri_VALE    table_of_varchar2_255:=table_of_varchar2_255();
     ri_SALA    pack_personnel.ti_CONTRAT;
   begin

     if pPERS.count > 0 then

       iINDE_SALA := 1;
       for i in 1..pPERS.count loop
         ri_SALA := pack_personnel.get_contrats_par_id_pers(pPERS(i));

         if ri_SALA.count > 0 then
           for j in 1..ri_SALA.count loop
             ri_VALE.extend;
             ri_VALE(iINDE_SALA) := ri_SALA(j).id_sala;
             iINDE_SALA          := iINDE_SALA + 1;
           end loop;
         end if;
       end loop;

     end if;

     return ri_VALE;
   end fct__get_personnel_salaries;

begin

   -- Métrologie
   pack_syst_suiv_proc.initialiser_suivi(
     pFAMI         => 'PAYE',
     pMODU         => 'PAYE',
     pNOM_PROC     => 'PR_TRAITEGEN_JOB_GEAV',
     pID_SOCI      => pID_SOCI,
     pID_LOGI      => pID_LOGI,
     pAPPL         => 'PAYE',
     pID_SUIV_PROC => iID_SUIV_PROC
   );

   pack_syst_suiv_proc.log_argument(pID_SUIV_PROC => iID_SUIV_PROC, pNOM => 'PID_SOCI', pVALE_CHAR => pID_SOCI);
   pack_syst_suiv_proc.log_argument(pID_SUIV_PROC => iID_SUIV_PROC, pNOM => 'PID_LOGI', pVALE_CHAR => pID_LOGI);
   pack_syst_suiv_proc.log_argument(pID_SUIV_PROC => iID_SUIV_PROC, pNOM => 'PID_PARA', pVALE_CHAR => pID_PARA);
   pack_syst_suiv_proc.log_argument(pID_SUIV_PROC => iID_SUIV_PROC, pNOM => 'PID_LIST', pVALE_CHAR => pID_LIST);

   pack_syst_suiv_proc.demarrer_suivi (
     pID_SUIV_PROC => iID_SUIV_PROC,
     pID_PARA      => pID_PARA
   );

   iID_LOGI:=parse_float(pID_LOGI);
   iID_SOCI:=parse_float(pID_SOCI);

   pack_cont_para.restriction_vpd(iID_LOGI);


   select
      *
   into
      oSociOrig
   from societe
   where id_soci=iID_SOCI
   ;

   vAUTO_GEST_LIST_PERS := nvl(oSociOrig.AUTO_GEST_LIST_PERS,'N');

   pr_etat_pile_errtools_info(iID_SOCI,iID_LOGI,vETAT,'Début de la procédure ' ||to_char(  sysdate ,'HH24:MI:SS'));
   pr_etat_pile_log(iID_SOCI,iID_LOGI,vETAT,'Préparation des données');

   vID_PARA:=fct_paraedit                 (iID_SOCI,         vETAT , pID_PARA );
   vID_LIST:=fct_liste_etat_colonnes_expl (iID_SOCI,iID_LOGI,vETAT , pID_LIST , 'N');

   for p in c_PAYS loop
      rv_S_PAYS       (p.code_iso):=p.libe_pays;
      rv_S_PAYS_GENT_F(p.code_iso):=p.gentile_f;
   end loop;

   for p in c_GEO_DEPARTEMENT loop
     rv_S_GEO_DEPARTEMENT(p.code) := p.libe;
   end loop;

   for p in c_EMPLOIS_51 loop
      rv_S_EMPLOIS_51(p.id_empl):=p.libe;
   end loop;

   open c_FORMULE;
   loop
      fetch c_FORMULE bulk collect into ri_B_FORMULE limit 2000;
         for i in 1 .. ri_B_FORMULE.count
         loop
            ri_S_FORMULE( ri_B_FORMULE(i).code_type_form ):=ri_B_FORMULE(i);
         end loop;

         exit when c_FORMULE%notfound;
   end loop;
   close c_FORMULE;

   open c_MOTIFDEP;
   loop
      fetch c_MOTIFDEP bulk collect into ri_B_MOTIFDEP limit 2000;
         for i in 1 .. ri_B_MOTIFDEP.count
         loop
            rv_S_MOTIFDEP( ri_B_MOTIFDEP(i).id_moti ):=ri_B_MOTIFDEP(i);
         end loop;

         exit when c_MOTIFDEP%notfound;
   end loop;
   close c_MOTIFDEP;


   open c_MOTI_RECR_CDD;
   loop
      fetch c_MOTI_RECR_CDD bulk collect into ri_B_MOTI_RECR_CDD limit 2000;
         for i in 1 .. ri_B_MOTI_RECR_CDD.count
         loop
            rv_S_MOTI_RECR_CDD( ri_B_MOTI_RECR_CDD(i).code_moti_recr_cdd ):=ri_B_MOTI_RECR_CDD(i);
         end loop;

         exit when c_MOTI_RECR_CDD%notfound;
   end loop;
   close c_MOTI_RECR_CDD;

   open c_MOTI_RECR_CDD2;
   loop
      fetch c_MOTI_RECR_CDD2 bulk collect into ri_B_MOTI_RECR_CDD2 limit 2000;
         for i in 1 .. ri_B_MOTI_RECR_CDD2.count
         loop
            rv_S_MOTI_RECR_CDD2( ri_B_MOTI_RECR_CDD2(i).code_moti_recr_cdd ):=ri_B_MOTI_RECR_CDD2(i);
         end loop;

         exit when c_MOTI_RECR_CDD2%notfound;
   end loop;
   close c_MOTI_RECR_CDD2;

   open c_MOTI_RECR_CDD3;
   loop
      fetch c_MOTI_RECR_CDD3 bulk collect into ri_B_MOTI_RECR_CDD3 limit 2000;
         for i in 1 .. ri_B_MOTI_RECR_CDD3.count
         loop
            rv_S_MOTI_RECR_CDD3( ri_B_MOTI_RECR_CDD3(i).code_moti_recr_cdd ):=ri_B_MOTI_RECR_CDD3(i);
         end loop;

         exit when c_MOTI_RECR_CDD3%notfound;
   end loop;
   close c_MOTI_RECR_CDD3;


   delete pers_edit_gestion_avancee
   where id_soci=iID_SOCI
     and id_logi=iID_LOGI
     and id_para=vID_PARA
     and id_list=vID_LIST
   ;
   commit;

   select
      count(0)
   into
      iNB
   from liste_gestion_avancee
   where id_list=vID_LIST
   ;

   if iNB=0 then
      insert into liste_gestion_avancee(
         id_list
      )values(
         vID_LIST
      );
   end if;

   select
      count(0)
   into
      iNB
   from liste_gestion_avancee_2
   where id_list=vID_LIST
   ;

   if iNB=0 then
      insert into liste_gestion_avancee_2(
         id_list
      )values(
         vID_LIST
      );
   end if;

   select
      *
   into
      oList
   from liste_gestion_avancee
   where id_list=vID_LIST
   ;

   select
      *
   into
      oList_2
   from liste_gestion_avancee_2
   where id_list=vID_LIST
   ;

   --if accessibility.accessible(oList.id_logi,iID_LOGI)=0 then
   --    accessibility.raise;
   --end if;

   select
      *
   into
      oPara
   from
      para_edit
   where id_para=vID_PARA;

   if accessibility.accessible(oPara.id_logi,iID_LOGI)=0 then
       accessibility.raise;
   end if;
   vAFFI_DERN_VALE := nvl( oPara.libr_3, 'N');

   if vAUTO_GEST_LIST_PERS = 'O' then
     tPERS:=fct_para_edit_liste(vID_PARA,'PERSONNEL');
     tSALA := fct__get_personnel_salaries(tPERS);
   else
     tSALA:=fct_para_edit_liste(vID_PARA,'SALARIE');
   end if;

   -- ajout de la variable modif prise en compte de la notion de groupe
   tSOCI:=fct_para_edit_liste(vID_PARA,'SOCIETE');

   tDIVI:=fct_para_edit_liste(vID_PARA,'DIVISION');
   tETAB:=fct_para_edit_liste(vID_PARA,'ETABLISSEMENT');
   tDEPA:=fct_para_edit_liste(vID_PARA,'DEPARTEMENT');
   tSERV:=fct_para_edit_liste(vID_PARA,'SERVICE');
   tPERI:=fct_para_edit_liste(vID_PARA,'PERIODE');
   tANAL:=fct_para_edit_liste(vID_PARA,'CODE_ANAL');
   tTYPE:=fct_para_edit_liste(vID_PARA,'TYPE');
   tNATU_CONT := fct_para_edit_liste(vID_PARA, 'NATU_CONT');
   tCAIS:=fct_para_edit_liste(vID_PARA,'CAISSE');
   tCATE:=fct_para_edit_liste(vID_PARA,'CATEGORIE_ID');
   tEQUI:=fct_para_edit_liste(vID_PARA,'EQUIPE');
   tGROU_SAIS:=fct_para_edit_liste(vID_PARA,'CRITERE');
   tREGR:=fct_para_edit_liste(vID_PARA,'REGROUPEMENT');
   tUNIT:=fct_para_edit_liste(vID_PARA,'CATEGORIE');
   tSITU:=fct_para_edit_liste(vID_PARA,'SITUATION');
   tMODE_BULL:=fct_para_edit_liste(vID_PARA,'MODBULL');


   iSOCI:=tSOCI.count;
   iDIVI:=tDIVI.count;
   iSALA:=tSALA.count;
   iETAB:=tETAB.count;
   iDEPA:=tDEPA.count;
   iSERV:=tSERV.count;
   iPERI:=tPERI.count;
   iANAL:=tANAL.count;
   iTYPE:=tTYPE.count;
   iNATU_CONT := tNATU_CONT.count;
   iCAIS:=tCAIS.count;
   iCATE:=tCATE.count;
   iEQUI:=tEQUI.count;
   iGROU_SAIS:=tGROU_SAIS.count;
   iREGR:=tREGR.count;
   iUNIT:=tUNIT.count;
   iSITU:=tSITU.count;
   iMODE_BULL:=tMODE_BULL.count;

   -- positionnement des indicateurs en fonction des situations sélectionnées (T148434)
   for iSIT in 1..iSITU loop
     if    tSITU(iSIT) = 'STAT_PRES' then vSITU_STAT_PRES := 'O' ;  -- Salariés présents
     elsif tSITU(iSIT) = 'STAT_PART' then vSITU_STAT_PART := 'O' ;  -- Salariés partis
     elsif tSITU(iSIT) = 'VIRE_O'    then vSITU_VIRE_O    := 'O' ;  -- Salariés bloqués
     elsif tSITU(iSIT) = 'VIRE_N'    then vSITU_VIRE_N    := 'O' ;  -- Salariés non bloqués
     elsif tSITU(iSIT) = 'PAYE_O'    then vSITU_PAYE_O    := 'O' ;  -- Salariés payés
     elsif tSITU(iSIT) = 'PAYE_N'    then vSITU_PAYE_N    := 'O' ;  -- Salariés non payés
     elsif tSITU(iSIT) = 'REGU_O'    then vSITU_REGU_O    := 'O' ;  -- Bulletins de régularisation
     elsif tSITU(iSIT) = 'REGU_N'    then vSITU_REGU_N    := 'O' ;  -- Bulletins normaux
     end if;
   end loop;

   -- pour chaque paire d'indicateurs, on active les deux si aucun n'est activé (pour éviter une liste vide)
   if vSITU_STAT_PRES = 'N' and vSITU_STAT_PART = 'N' then vSITU_STAT_PRES := 'O'; vSITU_STAT_PART := 'O'; end if;
   if vSITU_VIRE_O    = 'N' and vSITU_VIRE_N    = 'N' then vSITU_VIRE_O    := 'O'; vSITU_VIRE_N    := 'O'; end if;
   if vSITU_PAYE_O    = 'N' and vSITU_PAYE_N    = 'N' then vSITU_PAYE_O    := 'O'; vSITU_PAYE_N    := 'O'; end if;
   if vSITU_REGU_O    = 'N' and vSITU_REGU_N    = 'N' then vSITU_REGU_O    := 'O'; vSITU_REGU_N    := 'O'; end if;

   -- si le filtre période est vide alors on force une recherche sur la période courante
   if iPERI = 0 then tPERI := table_of_varchar2_255('COUR'); iPERI := 1; end if;

   pr__carachamp_rubrique( 1,oList.libe_rubr_01,oList.vale_rubr_01);
   pr__carachamp_rubrique( 2,oList.libe_rubr_02,oList.vale_rubr_02);
   pr__carachamp_rubrique( 3,oList.libe_rubr_03,oList.vale_rubr_03);
   pr__carachamp_rubrique( 4,oList.libe_rubr_04,oList.vale_rubr_04);
   pr__carachamp_rubrique( 5,oList.libe_rubr_05,oList.vale_rubr_05);
   pr__carachamp_rubrique( 6,oList.libe_rubr_06,oList.vale_rubr_06);
   pr__carachamp_rubrique( 7,oList.libe_rubr_07,oList.vale_rubr_07);
   pr__carachamp_rubrique( 8,oList.libe_rubr_08,oList.vale_rubr_08);
   pr__carachamp_rubrique( 9,oList.libe_rubr_09,oList.vale_rubr_09);
   pr__carachamp_rubrique(10,oList.libe_rubr_10,oList.vale_rubr_10);
   pr__carachamp_rubrique(11,oList.libe_rubr_11,oList.vale_rubr_11);
   pr__carachamp_rubrique(12,oList.libe_rubr_12,oList.vale_rubr_12);
   pr__carachamp_rubrique(13,oList.libe_rubr_13,oList.vale_rubr_13);
   pr__carachamp_rubrique(14,oList.libe_rubr_14,oList.vale_rubr_14);
   pr__carachamp_rubrique(15,oList.libe_rubr_15,oList.vale_rubr_15);
   pr__carachamp_rubrique(16,oList.libe_rubr_16,oList.vale_rubr_16);
   pr__carachamp_rubrique(17,oList.libe_rubr_17,oList.vale_rubr_17);
   pr__carachamp_rubrique(18,oList.libe_rubr_18,oList.vale_rubr_18);
   pr__carachamp_rubrique(19,oList.libe_rubr_19,oList.vale_rubr_19);
   pr__carachamp_rubrique(20,oList.libe_rubr_20,oList.vale_rubr_20);
   pr__carachamp_rubrique(21,oList.libe_rubr_21,oList.vale_rubr_21);
   pr__carachamp_rubrique(22,oList.libe_rubr_22,oList.vale_rubr_22);
   pr__carachamp_rubrique(23,oList.libe_rubr_23,oList.vale_rubr_23);
   pr__carachamp_rubrique(24,oList.libe_rubr_24,oList.vale_rubr_24);
   pr__carachamp_rubrique(25,oList.libe_rubr_25,oList.vale_rubr_25);
   pr__carachamp_rubrique(26,oList.libe_rubr_26,oList.vale_rubr_26);
   pr__carachamp_rubrique(27,oList.libe_rubr_27,oList.vale_rubr_27);
   pr__carachamp_rubrique(28,oList.libe_rubr_28,oList.vale_rubr_28);
   pr__carachamp_rubrique(29,oList.libe_rubr_29,oList.vale_rubr_29);
   pr__carachamp_rubrique(30,oList.libe_rubr_30,oList.vale_rubr_30);
   pr__carachamp_rubrique(31,oList.libe_rubr_31,oList.vale_rubr_31);
   pr__carachamp_rubrique(32,oList.libe_rubr_32,oList.vale_rubr_32);
   pr__carachamp_rubrique(33,oList.libe_rubr_33,oList.vale_rubr_33);
   pr__carachamp_rubrique(34,oList.libe_rubr_34,oList.vale_rubr_34);
   pr__carachamp_rubrique(35,oList.libe_rubr_35,oList.vale_rubr_35);
   pr__carachamp_rubrique(36,oList.libe_rubr_36,oList.vale_rubr_36);
   pr__carachamp_rubrique(37,oList.libe_rubr_37,oList.vale_rubr_37);
   pr__carachamp_rubrique(38,oList.libe_rubr_38,oList.vale_rubr_38);
   pr__carachamp_rubrique(39,oList.libe_rubr_39,oList.vale_rubr_39);
   pr__carachamp_rubrique(40,oList.libe_rubr_40,oList.vale_rubr_40);
   pr__carachamp_rubrique(41,oList.libe_rubr_41,oList.vale_rubr_41);
   pr__carachamp_rubrique(42,oList.libe_rubr_42,oList.vale_rubr_42);
   pr__carachamp_rubrique(43,oList.libe_rubr_43,oList.vale_rubr_43);
   pr__carachamp_rubrique(44,oList.libe_rubr_44,oList.vale_rubr_44);
   pr__carachamp_rubrique(45,oList.libe_rubr_45,oList.vale_rubr_45);
   pr__carachamp_rubrique(46,oList.libe_rubr_46,oList.vale_rubr_46);
   pr__carachamp_rubrique(47,oList.libe_rubr_47,oList.vale_rubr_47);
   pr__carachamp_rubrique(48,oList.libe_rubr_48,oList.vale_rubr_48);
   pr__carachamp_rubrique(49,oList.libe_rubr_49,oList.vale_rubr_49);
   pr__carachamp_rubrique(50,oList.libe_rubr_50,oList.vale_rubr_50);

   pr__carachamp_rubrique(51,oList_2.libe_rubr_51,oList_2.vale_rubr_51);
   pr__carachamp_rubrique(52,oList_2.libe_rubr_52,oList_2.vale_rubr_52);
   pr__carachamp_rubrique(53,oList_2.libe_rubr_53,oList_2.vale_rubr_53);
   pr__carachamp_rubrique(54,oList_2.libe_rubr_54,oList_2.vale_rubr_54);
   pr__carachamp_rubrique(55,oList_2.libe_rubr_55,oList_2.vale_rubr_55);
   pr__carachamp_rubrique(56,oList_2.libe_rubr_56,oList_2.vale_rubr_56);
   pr__carachamp_rubrique(57,oList_2.libe_rubr_57,oList_2.vale_rubr_57);
   pr__carachamp_rubrique(58,oList_2.libe_rubr_58,oList_2.vale_rubr_58);
   pr__carachamp_rubrique(59,oList_2.libe_rubr_59,oList_2.vale_rubr_59);
   pr__carachamp_rubrique(60,oList_2.libe_rubr_60,oList_2.vale_rubr_60);
   pr__carachamp_rubrique(61,oList_2.libe_rubr_61,oList_2.vale_rubr_61);
   pr__carachamp_rubrique(62,oList_2.libe_rubr_62,oList_2.vale_rubr_62);
   pr__carachamp_rubrique(63,oList_2.libe_rubr_63,oList_2.vale_rubr_63);
   pr__carachamp_rubrique(64,oList_2.libe_rubr_64,oList_2.vale_rubr_64);
   pr__carachamp_rubrique(65,oList_2.libe_rubr_65,oList_2.vale_rubr_65);
   pr__carachamp_rubrique(66,oList_2.libe_rubr_66,oList_2.vale_rubr_66);
   pr__carachamp_rubrique(67,oList_2.libe_rubr_67,oList_2.vale_rubr_67);
   pr__carachamp_rubrique(68,oList_2.libe_rubr_68,oList_2.vale_rubr_68);
   pr__carachamp_rubrique(69,oList_2.libe_rubr_69,oList_2.vale_rubr_69);
   pr__carachamp_rubrique(70,oList_2.libe_rubr_70,oList_2.vale_rubr_70);
   pr__carachamp_rubrique(71,oList_2.libe_rubr_71,oList_2.vale_rubr_71);
   pr__carachamp_rubrique(72,oList_2.libe_rubr_72,oList_2.vale_rubr_72);
   pr__carachamp_rubrique(73,oList_2.libe_rubr_73,oList_2.vale_rubr_73);
   pr__carachamp_rubrique(74,oList_2.libe_rubr_74,oList_2.vale_rubr_74);
   pr__carachamp_rubrique(75,oList_2.libe_rubr_75,oList_2.vale_rubr_75);
   pr__carachamp_rubrique(76,oList_2.libe_rubr_76,oList_2.vale_rubr_76);
   pr__carachamp_rubrique(77,oList_2.libe_rubr_77,oList_2.vale_rubr_77);
   pr__carachamp_rubrique(78,oList_2.libe_rubr_78,oList_2.vale_rubr_78);
   pr__carachamp_rubrique(79,oList_2.libe_rubr_79,oList_2.vale_rubr_79);
   pr__carachamp_rubrique(80,oList_2.libe_rubr_80,oList_2.vale_rubr_80);
   pr__carachamp_rubrique(81,oList_2.libe_rubr_81,oList_2.vale_rubr_81);
   pr__carachamp_rubrique(82,oList_2.libe_rubr_82,oList_2.vale_rubr_82);
   pr__carachamp_rubrique(83,oList_2.libe_rubr_83,oList_2.vale_rubr_83);
   pr__carachamp_rubrique(84,oList_2.libe_rubr_84,oList_2.vale_rubr_84);
   pr__carachamp_rubrique(85,oList_2.libe_rubr_85,oList_2.vale_rubr_85);
   pr__carachamp_rubrique(86,oList_2.libe_rubr_86,oList_2.vale_rubr_86);
   pr__carachamp_rubrique(87,oList_2.libe_rubr_87,oList_2.vale_rubr_87);
   pr__carachamp_rubrique(88,oList_2.libe_rubr_88,oList_2.vale_rubr_88);
   pr__carachamp_rubrique(89,oList_2.libe_rubr_89,oList_2.vale_rubr_89);
   pr__carachamp_rubrique(90,oList_2.libe_rubr_90,oList_2.vale_rubr_90);
   pr__carachamp_rubrique(91,oList_2.libe_rubr_91,oList_2.vale_rubr_91);
   pr__carachamp_rubrique(92,oList_2.libe_rubr_92,oList_2.vale_rubr_92);
   pr__carachamp_rubrique(93,oList_2.libe_rubr_93,oList_2.vale_rubr_93);
   pr__carachamp_rubrique(94,oList_2.libe_rubr_94,oList_2.vale_rubr_94);
   pr__carachamp_rubrique(95,oList_2.libe_rubr_95,oList_2.vale_rubr_95);
   pr__carachamp_rubrique(96,oList_2.libe_rubr_96,oList_2.vale_rubr_96);
   pr__carachamp_rubrique(97,oList_2.libe_rubr_97,oList_2.vale_rubr_97);
   pr__carachamp_rubrique(98,oList_2.libe_rubr_98,oList_2.vale_rubr_98);
   pr__carachamp_rubrique(99,oList_2.libe_rubr_99,oList_2.vale_rubr_99);
   pr__carachamp_rubrique(100,oList_2.libe_rubr_100,oList_2.vale_rubr_100);
   pr__carachamp_rubrique(101,oList_2.libe_rubr_101,oList_2.vale_rubr_101);
   pr__carachamp_rubrique(102,oList_2.libe_rubr_102,oList_2.vale_rubr_102);
   pr__carachamp_rubrique(103,oList_2.libe_rubr_103,oList_2.vale_rubr_103);
   pr__carachamp_rubrique(104,oList_2.libe_rubr_104,oList_2.vale_rubr_104);
   pr__carachamp_rubrique(105,oList_2.libe_rubr_105,oList_2.vale_rubr_105);
   pr__carachamp_rubrique(106,oList_2.libe_rubr_106,oList_2.vale_rubr_106);
   pr__carachamp_rubrique(107,oList_2.libe_rubr_107,oList_2.vale_rubr_107);
   pr__carachamp_rubrique(108,oList_2.libe_rubr_108,oList_2.vale_rubr_108);
   pr__carachamp_rubrique(109,oList_2.libe_rubr_109,oList_2.vale_rubr_109);
   pr__carachamp_rubrique(110,oList_2.libe_rubr_110,oList_2.vale_rubr_110);
   pr__carachamp_rubrique(111,oList_2.libe_rubr_111,oList_2.vale_rubr_111);
   pr__carachamp_rubrique(112,oList_2.libe_rubr_112,oList_2.vale_rubr_112);
   pr__carachamp_rubrique(113,oList_2.libe_rubr_113,oList_2.vale_rubr_113);
   pr__carachamp_rubrique(114,oList_2.libe_rubr_114,oList_2.vale_rubr_114);
   pr__carachamp_rubrique(115,oList_2.libe_rubr_115,oList_2.vale_rubr_115);
   pr__carachamp_rubrique(116,oList_2.libe_rubr_116,oList_2.vale_rubr_116);
   pr__carachamp_rubrique(117,oList_2.libe_rubr_117,oList_2.vale_rubr_117);
   pr__carachamp_rubrique(118,oList_2.libe_rubr_118,oList_2.vale_rubr_118);
   pr__carachamp_rubrique(119,oList_2.libe_rubr_119,oList_2.vale_rubr_119);
   pr__carachamp_rubrique(120,oList_2.libe_rubr_120,oList_2.vale_rubr_120);
   pr__carachamp_rubrique(121,oList_2.libe_rubr_121,oList_2.vale_rubr_121);
   pr__carachamp_rubrique(122,oList_2.libe_rubr_122,oList_2.vale_rubr_122);
   pr__carachamp_rubrique(123,oList_2.libe_rubr_123,oList_2.vale_rubr_123);
   pr__carachamp_rubrique(124,oList_2.libe_rubr_124,oList_2.vale_rubr_124);
   pr__carachamp_rubrique(125,oList_2.libe_rubr_125,oList_2.vale_rubr_125);
   pr__carachamp_rubrique(126,oList_2.libe_rubr_126,oList_2.vale_rubr_126);
   pr__carachamp_rubrique(127,oList_2.libe_rubr_127,oList_2.vale_rubr_127);
   pr__carachamp_rubrique(128,oList_2.libe_rubr_128,oList_2.vale_rubr_128);
   pr__carachamp_rubrique(129,oList_2.libe_rubr_129,oList_2.vale_rubr_129);
   pr__carachamp_rubrique(130,oList_2.libe_rubr_130,oList_2.vale_rubr_130);
   pr__carachamp_rubrique(131,oList_2.libe_rubr_131,oList_2.vale_rubr_131);
   pr__carachamp_rubrique(132,oList_2.libe_rubr_132,oList_2.vale_rubr_132);
   pr__carachamp_rubrique(133,oList_2.libe_rubr_133,oList_2.vale_rubr_133);
   pr__carachamp_rubrique(134,oList_2.libe_rubr_134,oList_2.vale_rubr_134);
   pr__carachamp_rubrique(135,oList_2.libe_rubr_135,oList_2.vale_rubr_135);
   pr__carachamp_rubrique(136,oList_2.libe_rubr_136,oList_2.vale_rubr_136);
   pr__carachamp_rubrique(137,oList_2.libe_rubr_137,oList_2.vale_rubr_137);
   pr__carachamp_rubrique(138,oList_2.libe_rubr_138,oList_2.vale_rubr_138);
   pr__carachamp_rubrique(139,oList_2.libe_rubr_139,oList_2.vale_rubr_139);
   pr__carachamp_rubrique(140,oList_2.libe_rubr_140,oList_2.vale_rubr_140);
   pr__carachamp_rubrique(141,oList_2.libe_rubr_141,oList_2.vale_rubr_141);
   pr__carachamp_rubrique(142,oList_2.libe_rubr_142,oList_2.vale_rubr_142);
   pr__carachamp_rubrique(143,oList_2.libe_rubr_143,oList_2.vale_rubr_143);
   pr__carachamp_rubrique(144,oList_2.libe_rubr_144,oList_2.vale_rubr_144);
   pr__carachamp_rubrique(145,oList_2.libe_rubr_145,oList_2.vale_rubr_145);
   pr__carachamp_rubrique(146,oList_2.libe_rubr_146,oList_2.vale_rubr_146);
   pr__carachamp_rubrique(147,oList_2.libe_rubr_147,oList_2.vale_rubr_147);
   pr__carachamp_rubrique(148,oList_2.libe_rubr_148,oList_2.vale_rubr_148);
   pr__carachamp_rubrique(149,oList_2.libe_rubr_149,oList_2.vale_rubr_149);
   pr__carachamp_rubrique(150,oList_2.libe_rubr_150,oList_2.vale_rubr_150);

   pr__carachamp_constantes(01,oList.code_cons_01,oList.libe_cons_01);
   pr__carachamp_constantes(02,oList.code_cons_02,oList.libe_cons_02);
   pr__carachamp_constantes(03,oList.code_cons_03,oList.libe_cons_03);
   pr__carachamp_constantes(04,oList.code_cons_04,oList.libe_cons_04);
   pr__carachamp_constantes(05,oList.code_cons_05,oList.libe_cons_05);
   pr__carachamp_constantes(06,oList.code_cons_06,oList.libe_cons_06);
   pr__carachamp_constantes(07,oList.code_cons_07,oList.libe_cons_07);
   pr__carachamp_constantes(08,oList.code_cons_08,oList.libe_cons_08);
   pr__carachamp_constantes(09,oList.code_cons_09,oList.libe_cons_09);
   pr__carachamp_constantes(10,oList.code_cons_10,oList.libe_cons_10);
   pr__carachamp_constantes(11,oList.code_cons_11,oList.libe_cons_11);
   pr__carachamp_constantes(12,oList.code_cons_12,oList.libe_cons_12);
   pr__carachamp_constantes(13,oList.code_cons_13,oList.libe_cons_13);
   pr__carachamp_constantes(14,oList.code_cons_14,oList.libe_cons_14);
   pr__carachamp_constantes(15,oList.code_cons_15,oList.libe_cons_15);
   pr__carachamp_constantes(16,oList.code_cons_16,oList.libe_cons_16);
   pr__carachamp_constantes(17,oList.code_cons_17,oList.libe_cons_17);
   pr__carachamp_constantes(18,oList.code_cons_18,oList.libe_cons_18);
   pr__carachamp_constantes(19,oList.code_cons_19,oList.libe_cons_19);
   pr__carachamp_constantes(20,oList.code_cons_20,oList.libe_cons_20);

   pr__carachamp_constantes(21,oList_2.code_cons_21,oList_2.libe_cons_21);
   pr__carachamp_constantes(22,oList_2.code_cons_22,oList_2.libe_cons_22);
   pr__carachamp_constantes(23,oList_2.code_cons_23,oList_2.libe_cons_23);
   pr__carachamp_constantes(24,oList_2.code_cons_24,oList_2.libe_cons_24);
   pr__carachamp_constantes(25,oList_2.code_cons_25,oList_2.libe_cons_25);
   pr__carachamp_constantes(26,oList_2.code_cons_26,oList_2.libe_cons_26);
   pr__carachamp_constantes(27,oList_2.code_cons_27,oList_2.libe_cons_27);
   pr__carachamp_constantes(28,oList_2.code_cons_28,oList_2.libe_cons_28);
   pr__carachamp_constantes(29,oList_2.code_cons_29,oList_2.libe_cons_29);
   pr__carachamp_constantes(30,oList_2.code_cons_30,oList_2.libe_cons_30);
   pr__carachamp_constantes(31,oList_2.code_cons_31,oList_2.libe_cons_31);
   pr__carachamp_constantes(32,oList_2.code_cons_32,oList_2.libe_cons_32);
   pr__carachamp_constantes(33,oList_2.code_cons_33,oList_2.libe_cons_33);
   pr__carachamp_constantes(34,oList_2.code_cons_34,oList_2.libe_cons_34);
   pr__carachamp_constantes(35,oList_2.code_cons_35,oList_2.libe_cons_35);
   pr__carachamp_constantes(36,oList_2.code_cons_36,oList_2.libe_cons_36);
   pr__carachamp_constantes(37,oList_2.code_cons_37,oList_2.libe_cons_37);
   pr__carachamp_constantes(38,oList_2.code_cons_38,oList_2.libe_cons_38);
   pr__carachamp_constantes(39,oList_2.code_cons_39,oList_2.libe_cons_39);
   pr__carachamp_constantes(40,oList_2.code_cons_40,oList_2.libe_cons_40);
   pr__carachamp_constantes(41,oList_2.code_cons_41,oList_2.libe_cons_41);
   pr__carachamp_constantes(42,oList_2.code_cons_42,oList_2.libe_cons_42);
   pr__carachamp_constantes(43,oList_2.code_cons_43,oList_2.libe_cons_43);
   pr__carachamp_constantes(44,oList_2.code_cons_44,oList_2.libe_cons_44);
   pr__carachamp_constantes(45,oList_2.code_cons_45,oList_2.libe_cons_45);
   pr__carachamp_constantes(46,oList_2.code_cons_46,oList_2.libe_cons_46);
   pr__carachamp_constantes(47,oList_2.code_cons_47,oList_2.libe_cons_47);
   pr__carachamp_constantes(48,oList_2.code_cons_48,oList_2.libe_cons_48);
   pr__carachamp_constantes(49,oList_2.code_cons_49,oList_2.libe_cons_49);
   pr__carachamp_constantes(50,oList_2.code_cons_50,oList_2.libe_cons_50);

   pr__carachamp_calcul(01,oList.calc_01_deci,oList.calc_01_libe);
   pr__carachamp_calcul(02,oList.calc_02_deci,oList.calc_02_libe);
   pr__carachamp_calcul(03,oList.calc_03_deci,oList.calc_03_libe);
   pr__carachamp_calcul(04,oList.calc_04_deci,oList.calc_04_libe);
   pr__carachamp_calcul(05,oList.calc_05_deci,oList.calc_05_libe);
   pr__carachamp_calcul(06,oList.calc_06_deci,oList.calc_06_libe);
   pr__carachamp_calcul(07,oList.calc_07_deci,oList.calc_07_libe);
   pr__carachamp_calcul(08,oList.calc_08_deci,oList.calc_08_libe);
   pr__carachamp_calcul(09,oList.calc_09_deci,oList.calc_09_libe);
   pr__carachamp_calcul(10,oList.calc_10_deci,oList.calc_10_libe);
   pr__carachamp_calcul(11,oList.calc_11_deci,oList.calc_11_libe);
   pr__carachamp_calcul(12,oList.calc_12_deci,oList.calc_12_libe);
   pr__carachamp_calcul(13,oList.calc_13_deci,oList.calc_13_libe);
   pr__carachamp_calcul(14,oList.calc_14_deci,oList.calc_14_libe);
   pr__carachamp_calcul(15,oList.calc_15_deci,oList.calc_15_libe);
   pr__carachamp_calcul(16,oList.calc_16_deci,oList.calc_16_libe);
   pr__carachamp_calcul(17,oList.calc_17_deci,oList.calc_17_libe);
   pr__carachamp_calcul(18,oList.calc_18_deci,oList.calc_18_libe);
   pr__carachamp_calcul(19,oList.calc_19_deci,oList.calc_19_libe);
   pr__carachamp_calcul(20,oList.calc_20_deci,oList.calc_20_libe);

   for groupe in ( select
                      fille_id,
                      fille_libe
                   from mv_societe_groupe
                   where mere_id=iID_SOCI
   )loop
      ri_SOCIETES( groupe.fille_id):=groupe.fille_libe;
   end loop;



   for soci in ( select
                    rais_soci_fill as rais_soci,
                    id_soci_fill   as id_soci
                 from v_login_groupe
                 where id_soci_mere =iID_SOCI
                 and id_logi=iID_LOGI
                 and (
                     (iSOCI=0 and id_soci_fill=iID_SOCI)
                      or
                     id_soci_fill in (select * from table(cast(tSOCI as table_of_varchar2_255)))
                 )
   )loop


      pr_etat_pile_errtools_info(iID_SOCI,iID_LOGI,vETAT,'Societe '||soci.rais_soci);
      pr_etat_pile_log(iID_SOCI,iID_LOGI,vETAT,'Société '||soci.rais_soci|| ' Préparation des données');


      select
         max(peri_paie),
         min(peri_paie)
      into
         dPERI_COUR,
         dPREM_PERI
      from periode
      where id_soci=soci.id_soci;

      -- personnalisation du filtre des périodes pour la société en remplaçant "COUR" par la période courante
      tPERI_SOCI := tPERI;
      for i in 1..tPERI_SOCI.count loop if tPERI_SOCI(i) = 'COUR' then tPERI_SOCI(i) := to_char(dPERI_COUR, 'dd/mm/yyyy'); exit; end if; end loop;

      select count (0) into NOMB_LIGN from hist_rubr_sala h, categorie_prof c where
                  h.id_rubr=9999
                  and h.id_soci=soci.id_soci
                  and c.libe_cate=h.cate_prof
                  and peri in
                  (select p.peri_paie
                   from periode p
                   where p.id_soci = soci.id_soci
                     and to_char(p.peri_paie, 'DD/MM/YYYY') in (select * from table(cast(tPERI_SOCI as table_of_varchar2_255)))
                   )
                   and not exists( select 1 from sala$hist sh where sh.id_sala = h.id_sala and sh.hors_paie_type ='INTERM' and sh.acti$h ='1')
                  and (iSALA = 0 or h.id_sala                                      in (select * from table(cast(tSALA as table_of_varchar2_255))))
                  and (iETAB = 0 or h.id_etab                                      in (select * from table(cast(tETAB as table_of_varchar2_255))))
                  and (iDEPA = 0 or nvl(trim(h.depa), '@sans@')                    in (select * from table(cast(tDEPA as table_of_varchar2_255))))
                  and (iSERV = 0 or nvl(trim(h.serv), '@sans@')                    in (select * from table(cast(tSERV as table_of_varchar2_255))))
                  and (iTYPE = 0 or h.type_sala                                    in (select * from table(cast(tTYPE as table_of_varchar2_255))))
                  and (iCATE = 0 or c.id_cate                                      in (select * from table(cast(tCATE as table_of_varchar2_255))))

                  ;
      pr_etat_pile_log(iID_SOCI,iID_LOGI,vETAT, 'Société '||soci.rais_soci||'- '||NOMB_LIGN||'lignes à traiter');

      if (NOMB_LIGN = 0) then NOMB_LIGN :=1;end if;
      NUME_LIGN := 0;POUR_AVAN:=0;
      for peri in (select
                       p.peri_paie,
                       p.peri_paie                       as peri_paie_d,
                       to_char(p.peri_paie,'DD/MM/YYYY') as peri_paie_v,
                       p.repa_anal_deja_calc -- Permet de vérifier que la répartition analytique a déjà été initialisée.
                   from periode p
                   where p.id_soci = soci.id_soci
                     and to_char(p.peri_paie, 'DD/MM/YYYY') in (select * from table(cast(tPERI_SOCI as table_of_varchar2_255)))

      )loop

          ----------------------------------
          -- Lecture des plans analytiques
          ----------------------------------
          pr__liste_salarie_plan_anal(soci.id_soci, peri.peri_paie);

          if oPara.rupt_dema='O' then -- PARA_REPA_ANAL : Répartition analytique

          --   if (peri.peri_paie = dPERI_COUR or peri.REPA_ANAL_DEJA_CALC is null or peri.REPA_ANAL_DEJA_CALC != 'O') then
              pr_etat_pile_errtools_info(iID_SOCI,iID_LOGI,vETAT,'Societe '||soci.rais_soci||' Répartition analytique');
              pr_etat_pile_log(iID_SOCI,iID_LOGI,vETAT, 'Société '||soci.rais_soci||'- Première Initialisation des données analytiques pour la période '||trim(to_char(peri.peri_paie,'Month'))||' '||trim(to_char(peri.peri_paie,'YYYY')));
              pr_traitegen_hist_rubr_sala_an( soci.id_soci, to_char(peri.peri_paie,'DD/MM/YYYY'),iErrInterne,sErrInfoIntere,iErrIdInterne) ;
        --     end if;
             iErrInterne   :=0;
             sErrInfoIntere:=null;
             iErrIdInterne :=null;
          else
             pr_etat_pile_log(iID_SOCI,iID_LOGI,vETAT,'Société '||soci.rais_soci||' Récupération des données pour la période '||trim(to_char(peri.peri_paie,'Month'))||' '||trim(to_char(peri.peri_paie,'YYYY')));
          end if;-- répartition analytique

          -- Récupérer le paramétrage des mutuelles de la société sur la période
          pr__get_mutuelles(soci.id_soci, peri.peri_paie);
          --test MELB
          for data in (

               select distinct
                    e.CODE_REGR_FICH_COMP as CODE_REGR_FICH_COMP,
                    fct_hc_sala_nume(s.id_sala,dPERI_COUR,'HORAIRE_RAPP_SOCI')                       as HORA_RAPP_SOCI      ,
                    decode(fct_hc_sala_nume(s.id_sala,dPERI_COUR,'SAHO_BOO'),1,'Horaire',0,'Mensuel')as SAHO_BOO      ,
                    decode(iID_SOCI,soci.id_soci,0,1)                                                as ORDR_SOCI           ,
                    s.resp_hier                                                                      as RESP_HIER           ,
                    s.resp_hier_seco                                                                 as RESP_HIER_SECO      ,
                    s.id_sala                                                                        as ID_SALA             ,
                    s.id_tran                                                                        as ID_TRAN             ,
                    fct_format_nom(null,s.nom )                                                      as NOM                 ,
                    fct_format_nom(s.pren,null)                                                      as PREN                ,
                    fct_format_nom(null,fct_hs(s.nom_jeun_fill,hs.nom_jeun_fill,dPERI_COUR,hs.peri)) as NOM_JEUN_FILL       ,-- OK
                    --fct_hs(s.nom          ,hs.nom          ,dPERI_COUR,hs.peri)          as NOM                 ,
                    --fct_hs(s.pren         ,hs.pren         ,dPERI_COUR,hs.peri)          as PREN                ,
                    -- champs ''naturellement'' historisés
                    nvl(  cl.libe , c.libe_cate  )                                       as CATE_PROF           ,-- historisé
                    c.id_cate                                                            as ID_CATE             ,-- historisé
                    case h.reac_regu when 'O' then 'Oui' else 'Non' end                  as REAC_REGU           ,-- historisé
                    h.serv                                                               as SERV                ,-- historisé
                    h.depa                                                               as DEPA                ,-- historisé
                    h.sais                                                               as SAIS                ,-- historisé
                    h.id_modbull                                                         as ID_MODBULL          ,-- historisé
                    fct_emplois_libe(soci.id_soci,h.id_empl,h.sexe)                      as EMPL                ,-- historisé
                    et.libe                                                              as EMPL_TYPE           ,
                    me.libe                                                              as METI                ,
                    fm.libe                                                              as FAMI_METI           ,
                    fm.path_pare                                                         as FAMI_METI_HIER      ,
                    fct_emplois_code(soci.id_soci,h.id_empl)                             as CODE_EMPL           ,-- historisé
                    em.libe                                                              as EMPL_GENE           ,
                    h.regr                                                               as REGR                ,-- historisé
                    nvl(fct_hs(s.conv_coll,hs.conv_coll,dPERI_COUR,hs.peri),e.conv_coll) as CONV_COLL           ,
                    e.nom                                                                as ETAB                ,
                    nvl(trim(e.nom_etab_cour),e.nom)                                     as ETAB_COUR           ,
                    h.id_etab                                                            as ID_ETAB             ,-- historisé
                    h.sexe                                                               as SEXE                ,
                    (select libe from type_salarie where type_sala = h.type_sala)        as TYPE_SALA           ,
                    -- champs non historisés
                    s.code_iso_adre_pays                                                 as CODE_ISO_ADRE_PAYS  ,
                    sc.grou_comp                                                          as GROU_COMP           ,
                    s.mail_sala_cong                                                     as MAIL_SALA_CONG      ,
                    s.code_idcc                                                          as CODE_IDCC           ,
                    s.idcc_heur_equi                                                     as IDCC_HEUR_EQUI      ,
                    parse_float(s.comm_vent_n      )                                     as COMM_VENT_N         ,
                    parse_float(s.comm_vent_n1     )                                     as COMM_VENT_N1        ,
                    parse_float(s.prim_obje_n      )                                     as PRIM_OBJE_N         ,
                    parse_float(s.prim_obje_n1     )                                     as PRIM_OBJE_N1        ,
                    parse_float(s.prim_obje_soci_n )                                     as PRIM_OBJE_SOCI_N    ,
                    parse_float(s.prim_obje_soci_n1)                                     as PRIM_OBJE_SOCI_N1   ,
                    parse_float(s.prim_obje_glob_n )                                     as PRIM_OBJE_GLOB_N    ,
                    s.matr_grou                                                          as MATR_GROU           ,
                    fct_sala_date_prev(s.id_sala)                                        as DATE_DELA_PREV      ,
                    --case
                    --  when s.logi           is not null then s.logi
                    --  when s.nume_secu_soci is not null and length(s.nume_secu_soci) = 13 then substr(s.nume_secu_soci,1,5)
                    --  else ''
                    --end                                                                  as MATR_RESP_HIER,
                    fct_hs(s2.matr, hs2.matr, dPERI_COUR, hs2.peri)                      as MATR_RESP_HIER,
                    s.nive_form_educ_nati                                                as NIVE_FORM_EDUC_NATI,
                    s.code_iso_pays_nati                                                 as CODE_ISO_PAYS_NATI  ,
                    --s.id_prof_plan                                                       as ID_PROF_PLAN        ,
                    s.calc_auto_inde_cong_prec                                           as CALC_AUTO_INDE_CONG_PREC,
                    s.inva                                                               as INVA,
                    fct_hs(s.refe_cont_trav, hs.refe_cont_trav, dPERI_COUR, hs.peri)     as NUME_CONT,  -- T139464
                    s.moti_visi_medi                                                     as MOTI_VISI_MEDI,
                    sb.libe                                                              as STAT_BOET,
                    s.nomb_fixe_tick_rest                                                as NOMB_JOUR_TRAV_REFE_TR_2,
                    s.calc_auto_tick_rest                                                as CALC_AUTO_TR,
                    e.sire                                                               as SIRE_ETAB,
                    e.code_unit                                                          as CODE_UNIT,
                    e.code_regr_fich_comp                                                as CODE_REGR_FICH_COMP_ETAB,
                    s.type_vehi                                                          as TYPE_VEHI,
                    s.cate_vehi                                                          as CATE_VEHI,
                    s.imma_vehi                                                          as IMMA_VEHI,
                    s.tele_port                                                          as TELE_3,
                    e.code                                                               as ETAB_CODE,
                    so.code_soci                                                         as CODE_SOCI,
                    so.code                                                              as SOCI_CODE,
                    -- champs hist_salarie
                    fct_hs(s.id_resp_cong                             ,hs.id_resp_cong                             ,dPERI_COUR,hs.peri)                  as ID_RESP_CONG             ,-- OK
                    fct_hs(s.pris_char_carb                           ,hs.pris_char_carb                           ,dPERI_COUR,hs.peri)                  as PRIS_CHAR_CARB           ,-- OK
                    fct_hs(s.octr_vehi                                ,hs.octr_vehi                                ,dPERI_COUR,hs.peri)                  as OCTR_VEHI                ,-- OK
                    fct_hs(s.date_1er_mise_circ_vehi                  ,hs.date_1er_mise_circ_vehi                  ,dPERI_COUR,hs.peri)                  as DATE_1ER_MISE_CIRC_VEHI  ,-- OK
                    fct_hs(s.prix_acha_remi_vehi                      ,hs.prix_acha_remi_vehi                      ,dPERI_COUR,hs.peri)                  as PRIX_ACHA_REMI_VEHI      ,-- OK
                    fct_hs(s.cout_vehi                                ,hs.cout_vehi                                ,dPERI_COUR,hs.peri)                  as COUT_VEHI                ,-- OK
                    fct_hs(s.nati                                     ,hs.nati                                     ,dPERI_COUR,hs.peri)                  as NATI                     ,-- OK
                    fct_hs(s.nume_cart_sejo                           ,hs.nume_cart_sejo                           ,dPERI_COUR,hs.peri)                  as NUME_CART_SEJO           ,-- OK
                    to_char(fct_to_date(fct_hs(s.date_expi            ,hs.date_expi                                ,dPERI_COUR,hs.peri) ),'DD/MM/YYYY')  as DATE_EXPI                ,-- OK
                    fct_hs(s.nume_cart_trav                           ,hs.nume_cart_trav                           ,dPERI_COUR,hs.peri)                  as NUME_CART_TRAV           ,-- OK
                    to_char(fct_to_date(fct_hs(s.date_deli_trav       ,hs.date_deli_trav                           ,dPERI_COUR,hs.peri) ),'DD/MM/YYYY')  as DATE_DELI_TRAV           ,-- OK
                    to_char(fct_to_date(fct_hs(s.date_expi_trav       ,hs.date_expi_trav                           ,dPERI_COUR,hs.peri) ),'DD/MM/YYYY')  as DATE_EXPI_TRAV           ,-- OK
                    to_char(fct_to_date(s.date_dema_auto_trav), 'DD/MM/YYYY')                                                                            as DATE_DEMA_AUTO_TRAV      ,-- OK
                    sp.libe_pref                                                                                                                         as ID_PREF                  ,-- OK
                    to_char(s.date_expi_disp_mutu, 'DD/MM/YYYY')                                                                                         as DATE_EXPI_DISP_MUTU      ,-- OK
                    m.libe_moti                                                                                                                          as ID_MOTI_DISP_MUTU                ,-- OK
                    fct_emplois_inse(soci.id_soci,h.id_empl)                                                                                             as DADS_INSE_EMPL           ,-- historisé
                    fct_hs(s.cipd                                     ,hs.cipd                                     ,dPERI_COUR,hs.peri)                  as CIPDZ                    ,-- OK
                    fct_hs(fct_cate_code(soci.id_soci, s.cate_prof)   ,fct_cate_code(soci.id_soci, hs.cate_prof)   ,dPERI_COUR,hs.peri)                  as CODE_CATE                ,-- OK
                    fct_hs(sc.comp_brut                                ,hsc.comp_brut                                ,dPERI_COUR,hsc.peri)                  as COMP_BRUT                ,-- OK
                    fct_hs(sc.comp_paye                                ,hsc.comp_paye                                ,dPERI_COUR,hsc.peri)                  as COMP_PAYE                ,-- OK
                    fct_hs(sc.comp_acom                                ,hsc.comp_acom                                ,dPERI_COUR,hsc.peri)                  as COMP_ACOM                ,-- OK
                    fct_hs(s.nume_cong_spec                           ,hs.nume_cong_spec                           ,dPERI_COUR,hs.peri)                  as NUME_CONG_SPEC           ,-- OK
                    fct_hs(s.natu_cont                                ,hs.natu_cont                                ,dPERI_COUR,hs.peri)                  as NATU_CONT                ,-- OK
                    fct_hs(s.code_moti_recr_cdd                       ,hs.code_moti_recr_cdd                       ,dPERI_COUR,hs.peri)                  as CODE_MOTI_RECR_CDD       ,-- OK
                    fct_hs(s.prec_moti_recr_cdd                       ,hs.prec_moti_recr_cdd                       ,dPERI_COUR,hs.peri)                  as PREC_MOTI_RECR_CDD       ,-- OK
                    fct_hs(s.code_moti_recr_cdd                       ,hs.code_moti_recr_cdd                       ,dPERI_COUR,hs.peri)                  as CODE_MOTI_RECR_CDD2      ,-- OK
                    fct_hs(s.prec_moti_recr_cdd                       ,hs.prec_moti_recr_cdd                       ,dPERI_COUR,hs.peri)                  as PREC_MOTI_RECR_CDD2      ,-- OK
                    fct_hs(s.code_moti_recr_cdd                       ,hs.code_moti_recr_cdd                       ,dPERI_COUR,hs.peri)                  as CODE_MOTI_RECR_CDD3      ,-- OK
                    fct_hs(s.prec_moti_recr_cdd                       ,hs.prec_moti_recr_cdd                       ,dPERI_COUR,hs.peri)                  as PREC_MOTI_RECR_CDD3      ,-- OK
                    fct_hs(to_char(s.date_debu_cont,'DD/MM/YYYY')     ,to_char(hs.date_debu_cont,'DD/MM/YYYY')     ,dPERI_COUR,hs.peri)                  as DATE_DEBU_CONT           ,-- OK
                    fct_hs(s.date_fin_cont                            ,hs.date_fin_cont                            ,dPERI_COUR,hs.peri)                  as DATE_FIN_CONT            ,-- OK VC
to_char(fct_to_date(fct_hs(s.date_dern_visi_medi                      ,hs.date_dern_visi_medi                      ,dPERI_COUR,hs.peri)),'DD/MM/YYYY')   as DATE_DERN_VISI_MEDI      ,-- OK
to_char(fct_to_date(fct_hs(s.date_proc_visi_medi                      ,hs.date_proc_visi_medi                      ,dPERI_COUR,hs.peri)),'DD/MM/YYYY')   as DATE_PROC_VISI_MEDI      ,-- OK
                    fct_hs(s.equi                                     ,hs.equi                                     ,dPERI_COUR,hs.peri)                  as EQUI                     ,-- OK
                    fct_hs(s.divi                                     ,hs.divi                                     ,dPERI_COUR,hs.peri)                  as DIVI                     ,-- OK
                    fct_hs(s.cais_coti_bull                           ,hs.cais_coti_bull                           ,dPERI_COUR,hs.peri)                  as CAIS_COTI_BULL           ,-- OK
                    divi.code                                                                                                                            as CODE_DIVI                ,
                    serv.code                                                                                                                            as CODE_SERV                ,
                    depa.code                                                                                                                            as CODE_DEPA                ,
                    equi.code                                                                                                                            as CODE_EQUI                ,
                    unit.code                                                                                                                            as SALA_CODE_UNIT           ,
                    pack_champ_utilisateur.get('SALARIE',h.id_sala, 1,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_1              ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala, 2,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_2              ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala, 3,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_3              ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala, 4,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_4              ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala, 5,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_5              ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala, 6,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_6              ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala, 7,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_7              ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala, 8,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_8              ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala, 9,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_9              ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,10,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_10             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,11,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_11             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,12,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_12             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,13,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_13             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,14,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_14             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,15,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_15             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,16,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_16             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,17,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_17             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,18,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_18             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,19,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_19             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,20,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_20             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,21,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_21             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,22,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_22             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,23,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_23             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,24,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_24             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,25,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_25             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,26,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_26             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,27,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_27             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,28,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_28             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,29,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_29             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,30,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_30             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,31,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_31             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,32,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_32             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,33,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_33             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,34,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_34             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,35,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_35             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,36,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_36             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,37,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_37             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,38,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_38             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,39,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_39             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,40,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_40             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,41,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_41             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,42,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_42             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,43,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_43             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,44,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_44             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,45,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_45             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,46,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_46             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,47,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_47             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,48,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_48             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,49,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_49             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,50,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_50             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,51,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_51             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,52,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_52             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,53,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_53             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,54,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_54             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,55,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_55             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,56,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_56             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,57,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_57             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,58,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_58             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,59,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_59             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,60,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_60             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,61,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_61             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,62,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_62             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,63,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_63             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,64,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_64             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,65,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_65             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,66,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_66             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,67,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_67             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,68,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_68             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,69,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_69             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,70,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_70             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,71,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_71             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,72,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_72             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,73,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_73             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,74,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_74             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,75,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_75             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,76,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_76             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,77,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_77             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,78,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_78             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,79,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_79             ,-- OK
                    pack_champ_utilisateur.get('SALARIE',h.id_sala,80,case when h.peri<dPERI_COUR then h.peri else null end )                            as CHAM_UTIL_80             ,-- OK
                    fct_hs(s.titr                                     ,hs.titr                                     ,dPERI_COUR,hs.peri)                  as TITR                     ,-- OK
                    fct_hs(s.matr                                     ,hs.matr                                     ,dPERI_COUR,hs.peri)                  as MATR                     ,-- OK
                    fct_hs(s.nume_secu_soci||s.cle_secu_soci          ,hs.nume_secu_soci||hs.cle_secu_soci         ,dPERI_COUR,hs.peri)                  as NUME_SECU                ,-- OK
                    fct_hs(sc.code_anal                                ,hsc.code_anal                                ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_01             ,-- OK
                    fct_hs(sc.code_anal_axe2                           ,hsc.code_anal_axe2                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_02             ,-- OK
                    fct_hs(sc.code_anal_axe3                           ,hsc.code_anal_axe3                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_03             ,-- OK
                    fct_hs(sc.code_anal_axe4                           ,hsc.code_anal_axe4                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_04             ,-- OK
                    fct_hs(sc.code_anal_axe5                           ,hsc.code_anal_axe5                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_05             ,-- OK
                    fct_hs(sc.code_anal_axe6                           ,hsc.code_anal_axe6                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_06             ,-- OK
                    fct_hs(sc.code_anal_axe7                           ,hsc.code_anal_axe7                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_07             ,-- OK
                    fct_hs(sc.code_anal_axe8                           ,hsc.code_anal_axe8                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_08             ,-- OK
                    fct_hs(sc.code_anal_axe9                           ,hsc.code_anal_axe9                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_09             ,-- OK
                    fct_hs(sc.code_anal_ax10                           ,hsc.code_anal_ax10                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_10             ,-- OK
                    fct_hs(sc.code_anal_ax11                           ,hsc.code_anal_ax11                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_11             ,-- OK
                    fct_hs(sc.code_anal_ax12                           ,hsc.code_anal_ax12                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_12             ,-- OK
                    fct_hs(sc.code_anal_ax13                           ,hsc.code_anal_ax13                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_13             ,-- OK
                    fct_hs(sc.code_anal_ax14                           ,hsc.code_anal_ax14                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_14             ,-- OK
                    fct_hs(sc.code_anal_ax15                           ,hsc.code_anal_ax15                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_15             ,-- OK
                    fct_hs(sc.code_anal_ax16                           ,hsc.code_anal_ax16                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_16             ,-- OK
                    fct_hs(sc.code_anal_ax17                           ,hsc.code_anal_ax17                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_17             ,-- OK
                    fct_hs(sc.code_anal_ax18                           ,hsc.code_anal_ax18                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_18             ,-- OK
                    fct_hs(sc.code_anal_ax19                           ,hsc.code_anal_ax19                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_19             ,-- OK
                    fct_hs(sc.code_anal_ax20                           ,hsc.code_anal_ax20                           ,dPERI_COUR,hsc.peri)                  as CODE_ANAL_20             ,-- OK
                    fct_hs(s.situ_fami                                ,hs.situ_fami                                ,dPERI_COUR,hs.peri)                  as SITU_FAMI                ,-- OK
            to_date(fct_hs(s.date_emba                                ,hs.date_emba                                ,dPERI_COUR,hs.peri),'DD/MM/YYYY')    as DATE_EMBA                ,-- OK
            to_date(fct_hs(s.date_depa                                ,hs.date_depa                                ,dPERI_COUR,hs.peri),'DD/MM/YYYY')    as DATE_DEPA                ,-- OK
          -- Pour prévenir les dates ancienneté qui sont en format 6 (DD/MM/YY) - en plus des dates format 8 (DD/MM/YYYY)
          --  to_date(fct_hs(s.date_anci                                ,hs.date_anci                                ,dPERI_COUR,hs.peri),'DD/MM/YYYY')    as DATE_ANCI                ,-- OK
        fct_to_date(fct_hs(s.date_anci                                ,hs.date_anci                                ,dPERI_COUR,hs.peri),30)              as DATE_ANCI                ,-- OK
          --
            to_date(fct_hs(to_char(s.date_nais,'DD/MM/YYYY')          ,to_char(hs.date_nais,'DD/MM/YYYY')          ,dPERI_COUR,hs.peri),'DD/MM/YYYY')    as DATE_NAIS                ,-- OK
            to_date(fct_hs(s.date_acci                                ,hs.date_acci                                ,dPERI_COUR,hs.peri),'DD/MM/YYYY')    as DATE_ACCI_TRAV           ,-- OK
                    fct_hs(s.comm_nais                                ,hs.comm_nais                                ,dPERI_COUR,hs.peri)                  as COMM_NAIS                ,-- OK
                    fct_hs(s.depa_nais                                ,hs.depa_nais                                ,dPERI_COUR,hs.peri)                  as DEPA_NAIS                ,-- OK
                    fct_hs(s.pays_nais                                ,hs.pays_nais                                ,dPERI_COUR,hs.peri)                  as PAYS_NAIS                ,-- OK
                    fct_hs(s.trav_hand                                ,hs.trav_hand                                ,dPERI_COUR,hs.peri)                  as TRAV_HAND                ,-- OK
                    fct_hs(to_char(s.date_debu_coto,'DD/MM/YYYY')     ,to_char(hs.date_debu_coto,'DD/MM/YYYY')     ,dPERI_COUR,hs.peri)                  as DATE_DEBU_COTO           ,-- OK
                    fct_hs(to_char(s.date_fin_coto,'DD/MM/YYYY')      ,to_char(hs.date_fin_coto ,'DD/MM/YYYY')     ,dPERI_COUR,hs.peri)                  as DATE_FIN_COTO            ,-- OK
                    fct_hs(s.taux_inva                                ,hs.taux_inva                                ,dPERI_COUR,hs.peri)                  as TAUX_INVA                ,-- OK
                    fct_hs(s.nive_qual                                ,hs.nive_qual                                ,dPERI_COUR,hs.peri)                  as NIVE_QUAL                ,-- OK
                    fct_hs(s.adre                                     ,hs.adre                                     ,dPERI_COUR,hs.peri)                  as ADRE                     ,-- OK
                    fct_hs(s.comp_adre                                ,hs.comp_adre                                ,dPERI_COUR,hs.peri)                  as ADRE_COMP                ,-- OK
                    fct_hs(s.comu                                     ,hs.comu                                     ,dPERI_COUR,hs.peri)                  as ADRE_COMM                ,-- OK
                    fct_hs(s.code_post                                ,hs.code_post                                ,dPERI_COUR,hs.peri)                  as ADRE_CODE_POST           ,-- OK
                    fct_hs(s.mode_paie                                ,hs.mode_paie                                ,dPERI_COUR,hs.peri)                  as RIB_MODE_PAIE            ,-- OK
                    fct_hs(s.tele_1                                   ,hs.tele_1                                   ,dPERI_COUR,hs.peri)                  as TELE_1                   ,-- OK
                    fct_hs(s.tele_2                                   ,hs.tele_2                                   ,dPERI_COUR,hs.peri)                  as TELE_2                   ,-- OK
                    fct_hs(s.moti_depa                                ,hs.moti_depa                                ,dPERI_COUR,hs.peri)                  as MOTI_DEPA_CODE           ,-- OK
                    fct_hs(s.moti_depa_libe                           ,hs.moti_depa_libe                           ,dPERI_COUR,hs.peri)                  as MOTI_DEPA_LIBE           ,-- OK
                    fct_hs(s.moti_augm                                ,hs.moti_augm                                ,dPERI_COUR,hs.peri)                  as MOTI_AUGM                ,-- OK
                    fct_hs(s.moti_augm_2                              ,hs.moti_augm_2                              ,dPERI_COUR,hs.peri)                  as MOTI_AUGM_2              ,-- OK KFH 25/05/2023 T184292
                    fct_hs(s.TICK_REST_TYPE_REPA                      ,hs.TICK_REST_TYPE_REPA                      ,dPERI_COUR,hs.peri)                  as TICK_REST_TYPE_REPA      ,-- OK KFH 03/04/2024 T201908
                    s.SALA_AUTO_TITR_TRAV                                                                                                                as SALA_AUTO_TITR_TRAV      ,
                    s.LIEU_PRES_STAG                                                                                                                     as LIEU_PRES_STAG           ,
                    fct_hs(s.droi_prim_anci                           ,hs.droi_prim_anci                           ,dPERI_COUR,hs.peri)                  as DROI_PRIM_ANCI           ,-- OK
                    fct_hs(s.fin_peri_essa                            ,hs.fin_peri_essa                            ,dPERI_COUR,hs.peri)                  as FIN_PERI_ESSA            ,-- OK
                    fct_hs(s.coef_acca                                ,hs.coef_acca                                ,dPERI_COUR,hs.peri)                  as CCN51_COEF_ACCA          ,
                    fct_hs(s.coef_dipl                                ,hs.coef_dipl                                ,dPERI_COUR,hs.peri)                  as CCN51_COEF_DIPL          ,
                    fct_hs(s.coef_enca                                ,hs.coef_enca                                ,dPERI_COUR,hs.peri)                  as CCN51_COEF_ENCA          ,
                    fct_hs(s.coef_fonc                                ,hs.coef_fonc                                ,dPERI_COUR,hs.peri)                  as CCN51_COEF_FONC          ,
                    fct_hs(s.coef_meti                                ,hs.coef_meti                                ,dPERI_COUR,hs.peri)                  as CCN51_COEF_METI          ,
                    fct_hs(s.coef_recl                                ,hs.coef_recl                                ,dPERI_COUR,hs.peri)                  as CCN51_COEF_RECL          ,
                    fct_hs(s.coef_spec                                ,hs.coef_spec                                ,dPERI_COUR,hs.peri)                  as CCN51_COEF_SPEC          ,
                    fct_hs(s.id_empl_conv                             ,hs.id_empl_conv                             ,dPERI_COUR,hs.peri)                  as CCN51_ID_EMPL_CONV       ,
                    fct_hs(s.coef_refe                                ,hs.coef_refe                                ,dPERI_COUR,hs.peri)                  as CCN5166_COEF_REFE        ,
                    fct_hs(s.cate_conv                                ,hs.cate_conv                                ,dPERI_COUR,hs.peri)                  as CCN66_CATE_CONV          ,
                    fct_hs(to_char(s.date_chan_coef,'DD/MM/YYYY')     ,to_char(hs.date_chan_coef,'DD/MM/YYYY')     ,dPERI_COUR,hs.peri)                  as CCN66_DATE_CHAN_COEF     ,
                    fct_hs(s.empl_conv                                ,hs.empl_conv                                ,dPERI_COUR,hs.peri)                  as CCN66_EMPL_CONV          ,
                    fct_hs(s.fili_conv                                ,hs.fili_conv                                ,dPERI_COUR,hs.peri)                  as CCN66_FILI_CONV          ,
                    fct_hs(to_char(s.prec_date_chan_coef,'DD/MM/YYYY'),to_char(hs.prec_date_chan_coef,'DD/MM/YYYY'),dPERI_COUR,hs.peri)                  as CCN66_PREC_DATE_CHAN_COEF,
                    fct_hs(s.proc_coef_refe                           ,hs.proc_coef_refe                           ,dPERI_COUR,hs.peri)                  as CCN66_PROC_COEF_REFE     ,
                    fct_hs(s.fili_conv                                ,hs.fili_conv                                ,dPERI_COUR,hs.peri)                  as FILI_CONV                ,

                    fct_hs(s.orga                                     ,hs.orga                                     ,dPERI_COUR,hs.peri)                  as ORGA                     ,
                    fct_hs(s.unit                                     ,hs.unit                                     ,dPERI_COUR,hs.peri)                  as UNIT                     ,

                    fct_hs(s.regi                                     ,hs.regi                                     ,dPERI_COUR,hs.peri)                  as CCN66_REGI               ,

                    e.nume_fine                                                                                                                          as NUME_FINE                ,
                    e.affi_rtt                                                                                                                           as AFFI_RTT                 ,
                    s.date_depa_bull                                                                                                                     as DATE_DEPA_BULL           ,
                    sms.nume_adel                                                                                                                        as NUME_ADEL                ,
                    sms.nume_rpps                                                                                                                        as NUME_RPPS                ,
                    sms.adre_elec                                                                                                                        as ADRE_ELEC                ,
                    sms.code_titr_form                                                                                                                   as CODE_TITR_FORM           ,
                    sms.libe_titr_form                                                                                                                   as LIBE_TITR_FORM           ,
                    to_char(sms.date_titr_form, 'DD/MM/YYYY')                                                                                            as DATE_TITR_FORM           ,
                    sms.lieu_titr_form                                                                                                                   as LIEU_TITR_FORM           ,

                    e.code_regi                                                                                                                          as CODE_REGI                ,
                    rc.libe_regi                                                                                                                         as LIBE_REGI                ,

                    s.e_mail                                                                                                                             as MAIL                     ,
                    s.e_mail_2                                                                                                                           as MAIL_PERS                ,

                    fct_hs(s.code_mutu                                ,hs.code_mutu                                ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_TAUX_01 ,
                    fct_hs(s.code_mutu_02                             ,hs.code_mutu_02                             ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_TAUX_02 ,
                    fct_hs(s.code_mutu_03                             ,hs.code_mutu_03                             ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_TAUX_03 ,
                    fct_hs(s.code_mutu_04                             ,hs.code_mutu_04                             ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_TAUX_04 ,
                    fct_hs(s.code_mutu_05                             ,hs.code_mutu_05                             ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_TAUX_05 ,

                    fct_hs(s.code_mutu_mont_01                        ,hs.code_mutu_mont_01                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_MONT_01 ,
                    fct_hs(s.code_mutu_mont_02                        ,hs.code_mutu_mont_02                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_MONT_02 ,
                    fct_hs(s.code_mutu_mont_03                        ,hs.code_mutu_mont_03                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_MONT_03 ,
                    fct_hs(s.code_mutu_mont_04                        ,hs.code_mutu_mont_04                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_MONT_04 ,
                    fct_hs(s.code_mutu_mont_05                        ,hs.code_mutu_mont_05                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_MONT_05 ,
                    fct_hs(s.code_mutu_mont_06                        ,hs.code_mutu_mont_06                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_MONT_06 ,
                    fct_hs(s.code_mutu_mont_07                        ,hs.code_mutu_mont_07                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_MONT_07 ,
                    fct_hs(s.code_mutu_mont_08                        ,hs.code_mutu_mont_08                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_MONT_08 ,
                    fct_hs(s.code_mutu_mont_09                        ,hs.code_mutu_mont_09                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_MONT_09 ,
                    fct_hs(s.code_mutu_mont_10                        ,hs.code_mutu_mont_10                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_SOUM_MONT_10 ,

                    fct_hs(s.mutu_taux_noso_01                        ,hs.mutu_taux_noso_01                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_NOSO_TAUX_01 ,
                    fct_hs(s.mutu_taux_noso_02                        ,hs.mutu_taux_noso_02                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_NOSO_TAUX_02 ,
                    fct_hs(s.mutu_taux_noso_03                        ,hs.mutu_taux_noso_03                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_NOSO_TAUX_03 ,

                    fct_hs(s.mutu_mont_noso_01                        ,hs.mutu_mont_noso_01                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_NOSO_MONT_01 ,
                    fct_hs(s.mutu_mont_noso_02                        ,hs.mutu_mont_noso_02                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_NOSO_MONT_02 ,
                    fct_hs(s.mutu_mont_noso_03                        ,hs.mutu_mont_noso_03                        ,dPERI_COUR,hs.peri)                  as CODE_MUTU_NOSO_MONT_03 ,
                    fct_hs(s.code_mutu_mont_noso_04                   ,hs.code_mutu_mont_noso_04                   ,dPERI_COUR,hs.peri)                  as CODE_MUTU_NOSO_MONT_04 ,
                    fct_hs(s.code_mutu_mont_noso_05                   ,hs.code_mutu_mont_noso_05                   ,dPERI_COUR,hs.peri)                  as CODE_MUTU_NOSO_MONT_05 ,
                    fct_hs(s.code_mutu_mont_noso_06                   ,hs.code_mutu_mont_noso_06                   ,dPERI_COUR,hs.peri)                  as CODE_MUTU_NOSO_MONT_06 ,
                    fct_hs(s.code_mutu_mont_noso_07                   ,hs.code_mutu_mont_noso_07                   ,dPERI_COUR,hs.peri)                  as CODE_MUTU_NOSO_MONT_07,

                    case parse_float(fct_hc_sala_nume(s.id_sala,to_char(peri.peri_paie, 'DD/MM/YYYY'),'FORFAIT_TEMP'))
                     when 1 then 'Heures'
                     when 2 then 'Jours'
                     else   'Sans forfait'
                    end     as SALA_FORF_TEMP,
                    FCT_HC_SALA(s.id_sala,to_char(peri.peri_paie, 'DD/MM/YYYY'),'FORFAIT_JOUR_ACQU')   as NOMB_JOUR_FORF_TEMP,
                    FCT_HC_SALA(s.id_sala,to_char(peri.peri_paie, 'DD/MM/YYYY'),'FORFAIT_HEUR_ACQU')   as NOMB_HEUR_FORF_TEMP,
                    fct_hc_sala_nume(s.id_sala, to_char(peri.peri_paie, 'DD/MM/YYYY'), 'NOMB_MOIS')    as NOMB_MOIS,
                    fct_hc_sala_nume(s.id_sala, to_char(peri.peri_paie, 'DD/MM/YYYY'), 'SALA_ANNU_CONT') as SALA_ANNU_CONT,
                    fct_hc_sala_char(s.id_sala, TO_CHAR(peri.peri_paie, 'DD/MM/YYYY'), 'CODE_FINE_GEOG')                                                 as CODE_FINE_GEOG

                    ,fct_hc_sala_nume(s.id_sala,to_char(peri.peri_paie, 'DD/MM/YYYY'),'CCN_3248_CP')                                                     as NOMB_JOUR_CONG_ANCI
                    ,fct_hc_sala_nume(s.id_sala,to_char(peri.peri_paie, 'DD/MM/YYYY'),'CCN_3248_PA')                                                     as MONT_ANCI_PA
                    ,s.sala_anci_cadr                                                                                                                    as ANCI_CADR
                    ,case fct_hc_sala_nume(s.id_sala, to_char(peri.peri_paie, 'DD/MM/YYYY'), 'CCN_3248_HTRAV')
                      when 0 then fct_hc_sala_nume(s.id_sala, '01/12/2023', 'TOTALHTRAV') + fct_hc_sala_nume(s.id_sala, '01/12/2023', 'TOTALHS')
                      else fct_hc_sala_nume(s.id_sala, to_char(peri.peri_paie, 'DD/MM/YYYY'), 'CCN_3248_HTRAV')
                    end as TOTA_HEUR_TRAV
               from etablissement e,
                    categorie_prof c,
                    categorie_prof_lien cl,
                    salarie_table s,
                    salarie_compta sc,
                    hist_rubr_sala h,
                    hist_salarie hs,
                    moti_disp_mutu m,
                    societe so,
                    salarie_medico_social sms,
                    emplois em,
                    salarie_table s2,
                    hist_salarie hs2,
                    region_cpom rc,
                    salarie_prefecture sp,
                    emplois_types et,
                    metiers me,
                    familles_metiers fm,
                    salarie_medecine_travail smt,
                    statut_boeth sb,
                    division divi,
                    service serv,
                    departement depa,
                    equipe equi,
                    unite unit,
                    hist_salarie_compta hsc
                where h.id_sala=s.id_sala
                  and h.peri=peri.peri_paie
                  and s.id_sala = sc.id_sala(+)
                  and hs.id_sala(+)=s.id_sala
                  and hs.peri(+)=peri.peri_paie

                  and hsc.id_sala(+)=s.id_sala
                  and hsc.peri(+)=peri.peri_paie

                  and so.id_soci = s.id_soci
                  and h.id_rubr=9999
                  and h.id_soci=soci.id_soci
                  and e.id_etab=h.id_etab
                  and e.id_soci=soci.id_soci
                  and m.id_moti(+)=s.id_moti_disp_mutu
                  and sms.id_sala(+)=s.id_sala
                  and s2.id_sala(+)=s.resp_hier
                  and hs2.id_sala(+)=s.resp_hier
                  and hs2.peri(+)=peri.peri_paie
                  and em.id_empl(+)=s.id_empl
                  and rc.code_regi(+)=e.code_regi
                  and sp.id_pref(+)=s.id_pref
                  and et.id_empl_type(+)=em.id_empl_type
                  and me.id_meti(+)=et.id_meti
                  and fm.id_fami_meti(+)=me.id_fami_meti
                  and smt.id_sala (+)= s.id_sala
                  and sb.code (+)= smt.stat_boet
                  and divi.id_soci (+)= s.id_soci
                  and divi.libe (+)= fct_hs(s.divi, hs.divi, dPERI_COUR, hs.peri)  -- T139464
                  and serv.id_soci (+)= s.id_soci
                  and serv.libe (+)= fct_hs(s.serv, hs.serv, dPERI_COUR, hs.peri)  -- T139464
                  and depa.id_soci (+)= s.id_soci
                  and depa.libe (+)= fct_hs(s.depa, hs.depa, dPERI_COUR, hs.peri)  -- T139464
                  --and depa.id_depa = (select max(id_depa) from departement dd where dd.id_soci = s.id_soci and dd.libe = s.depa)
                  and equi.id_soci (+)= s.id_soci
                  and equi.libe (+)= fct_hs(s.equi, hs.equi, dPERI_COUR, hs.peri)  -- T139464
                  --and equi.id_equi = (select max(id_equi) from equipe ee where ee.id_soci = s.id_soci and ee.libe = s.equi)
                  and unit.id_soci (+)= s.id_soci
                  and unit.libe (+)= fct_hs(s.unit, hs.unit, dPERI_COUR, hs.peri)  -- T139464

                  and not exists( select 1 from sala$hist sh where sh.id_sala = s.id_sala and sh.hors_paie_type ='INTERM' and sh.acti$h ='1')
                  and (
                        ( vSITU_REGU_N = 'O' and nvl(h.reac_regu, 'N') = 'N')
                        or
                        ( vSITU_REGU_O = 'O' and nvl(h.reac_regu, 'N') = 'O')
                        or
                          vSITU_REGU_O = 'O' and vSITU_REGU_N = 'O'
                  )
                  and c.libe_cate=h.cate_prof
                  and cl.id_soci(+)=soci.id_soci
                  and cl.id_cate(+)=c.id_cate
                  and (iSALA = 0 or h.id_sala                                                                                   in (select * from table(cast(tSALA as table_of_varchar2_255))))
                  and (iETAB = 0 or h.id_etab                                                                                   in (select * from table(cast(tETAB as table_of_varchar2_255))))
                  and (iDEPA = 0 or nvl(trim(h.depa), '@sans@')                                                                 in (select * from table(cast(tDEPA as table_of_varchar2_255))))
                  and (iSERV = 0 or nvl(trim(h.serv), '@sans@')                                                                 in (select * from table(cast(tSERV as table_of_varchar2_255))))
                  and (iCATE = 0 or c.id_cate                                                                                   in (select * from table(cast(tCATE as table_of_varchar2_255))))
                  and (iTYPE = 0 or h.type_sala                                                                                 in (select * from table(cast(tTYPE as table_of_varchar2_255))))
                  and (iNATU_CONT = 0 or fct_hs(s.natu_cont, hs.natu_cont, dPERI_COUR, hs.peri)                                 in (select * from table(cast(tNATU_CONT as table_of_varchar2_255))))

                  -- présent/parti (T148434)
                  and (vSITU_STAT_PRES = 'O' and vSITU_STAT_PART = 'O'  -- tous les statuts
                       or vSITU_STAT_PRES = 'O' and (s.date_depa is null or '01' || substr(s.date_depa, 3) not in (select * from table(cast(tPERI_SOCI as table_of_varchar2_255))))
                       or vSITU_STAT_PART = 'O' and '01' || substr(s.date_depa, 3) in (select * from table(cast(tPERI_SOCI as table_of_varchar2_255)))
                  )

                  -- payé/non payé (T148434)
                  and (vSITU_PAYE_O = 'O' and vSITU_PAYE_N = 'O'
                       or vSITU_PAYE_O = 'O' and     exists(select 1 from virement_log_mont m, virement_log v where m.id_sala = s.id_sala and m.stat = 'ENVO' and v.id_vire = m.id_vire and to_char(v.peri, 'dd/mm/yyyy') in (select * from table(cast(tPERI_SOCI as table_of_varchar2_255)))) /*and h.mont_sala > 0*/
                       or vSITU_PAYE_N = 'O' and not exists(select 1 from virement_log_mont m, virement_log v where m.id_sala = s.id_sala and m.stat = 'ENVO' and v.id_vire = m.id_vire and to_char(v.peri, 'dd/mm/yyyy') in (select * from table(cast(tPERI_SOCI as table_of_varchar2_255)))) /*and h.mont_sala > 0*/
                  )

                  and (vSITU_VIRE_O = 'O' and vSITU_VIRE_N = 'O'  or  vSITU_VIRE_O = 'O' and s.vire_effe = 'O'  or  vSITU_VIRE_N = 'O' and nvl(s.vire_effe, 'N') = 'N')  -- bloqué/non bloqué (T148434)
                  and (iDIVI = 0 or nvl(trim(h.divi), '@sans@')                in (select * from table(cast(tDIVI as table_of_varchar2_255))))
                  and (iEQUI = 0 or nvl(trim(fct_to_simple(h.equi)), '@sans@') in (select * from table(cast(tEQUI as table_of_varchar2_255))))
                  and (iGROU_SAIS = 0 or nvl(trim(h.sais), '@sans@')           in (select * from table(cast(tGROU_SAIS as table_of_varchar2_255))))
                  and (iREGR = 0 or nvl(trim(h.regr), '@sans@')                in (select * from table(cast(tREGR as table_of_varchar2_255))))
                  and (iUNIT = 0 or nvl(trim(h.unit), '@sans@')                in (select * from table(cast(tUNIT as table_of_varchar2_255))))
                  and (iMODE_BULL = 0 or s.id_modbull                         in (select * from table(cast(tMODE_BULL as table_of_varchar2_255))))
                  and (iCAIS = 0 or (iCAIS=1 and 'REEL' in (select * from table(cast(tCAIS as table_of_varchar2_255))) and s.id_simu is null) or (iCAIS=1 and 'SIMU' in (select * from table(cast(tCAIS as table_of_varchar2_255))) and s.id_simu is not null))
           )loop

             if nvl(data.nomb_mois, 0) = 0 then data.nomb_mois := 12; end if;
             if nvl(data.sala_annu_cont, 0) = 0 then data.sala_annu_cont := data.nomb_mois * fct_hc_sala_nume(data.id_sala, to_char(peri.peri_paie, 'DD/MM/YYYY'), 'SALBAS39'); end if;
             NUME_LIGN := NUME_LIGN + 1;
             if (NUME_LIGN = 1) then
              DATE_PREM_LIGN := sysdate;
             end if;

             if (NUME_LIGN != 1 and POUR_AVAN != trunc(NUME_LIGN*100/NOMB_LIGN)) then
              POUR_AVAN := trunc(NUME_LIGN*100/NOMB_LIGN);
              TEMP_REST := 1 + trunc((NOMB_LIGN - NUME_LIGN)*(sysdate - DATE_PREM_LIGN)*24*60 / (NUME_LIGN-1));
              pr_etat_pile_log(iID_SOCI,iID_LOGI,vETAT,'('||trunc(NUME_LIGN*100/NOMB_LIGN)||'%) Il reste moins de '||TEMP_REST||'mn. <br>Société '||soci.rais_soci||' Récupération des données de '|| data.pren||' '|| upper(data.nom) ||' pour la période '||trim(to_char(peri.peri_paie,'Month'))||' '||trim(to_char(peri.peri_paie,'YYYY')));

             end if;

             begin
               select vale into vVALE_CONG_REST_N from hist_cons_sala where id_sala=data.id_sala and code_cons='CONGAPRE0_LEGA' and peri=peri.peri_paie;
             exception
             when NO_DATA_FOUND then
               vVALE_CONG_REST_N := '0';
             end;
             begin
               select vale into vVALE_CONG_ACQU_N from hist_cons_sala where id_sala=data.id_sala and code_cons='COACMOIS_LEGA' and peri=peri.peri_paie;
             exception
             when NO_DATA_FOUND then
               vVALE_CONG_ACQU_N := '0';
             end;
             begin
               select vale into vNOMB_TR_CALC_PERI from hist_cons_sala where id_sala=data.id_sala and code_cons='TICKET' and peri=peri.peri_paie;
             exception
             when NO_DATA_FOUND then
               vNOMB_TR_CALC_PERI := '0';
             end;

            begin
               SELECT DISTINCT TO_CHAR(fct_format(vale, 'DD/MM/YYYY'),'DD/MM/YYYY') into dDATE_ANCI_CADR_FORF FROM hist_cons_sala WHERE id_sala=data.id_sala AND code_cons = 'DATEANCI_CADR_FORF_J' and peri=peri.peri_paie;
             exception
             when NO_DATA_FOUND then
               dDATE_ANCI_CADR_FORF := null;
             end;


             vNUME_COMP_BRUT := '';
             vLIBE_COMP_BRUT := '';
             if data.comp_brut is not null then
             	 select nume_comp, libe_comp into vNUME_COMP_BRUT, vLIBE_COMP_BRUT from compte where id_comp = data.comp_brut;
             end if;

             vNUME_COMP_PAYE := '';
             vLIBE_COMP_PAYE := '';
             if data.comp_paye is not null then
             	 select nume_comp, libe_comp into vNUME_COMP_PAYE, vLIBE_COMP_PAYE from compte where id_comp = data.comp_paye;
             end if;

             select nvl(fct_hc_sala(data.id_sala,to_char(peri.peri_paie, 'DD/MM/YYYY'),'VALE_TICK_REST'       ,'','O'),0) into nVALE_SPEC_TR from dual;
             select nvl(fct_hc_soci(soci.id_soci,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TITR_REST_ETAB'),0) into vTR_ETAB from dual;
             if nVALE_SPEC_TR = 0 and vTR_ETAB = '0' then
               select fct_hc_soci(soci.id_soci,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TR') into vTR_1 from dual;
               select fct_hc_soci(soci.id_soci,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TRPAT') into vTR_2 from dual;
               if vTR_1 is null and vTR_2 is null then
                 vVALE_SPEC_TR := '';
               else
                 vVALE_SPEC_TR := 'Première valeur société : Sala. :' || vTR_1 || ' / Patr. : ' || vTR_2;
               end if;
             elsif nVALE_SPEC_TR = 1 and vTR_ETAB = '0' then
               select fct_hc_soci(soci.id_soci,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TR_1') into vTR_3 from dual;
               select fct_hc_soci(soci.id_soci,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TR_1PAT') into vTR_4 from dual;
               if vTR_3 is null and vTR_4 is null then
                 vVALE_SPEC_TR := '';
               else
                 vVALE_SPEC_TR := 'Deuxième valeur société : Sala. :' || vTR_3 || ' / Patr. : ' || vTR_4;
               end if;
             elsif nVALE_SPEC_TR = 2 and vTR_ETAB = '0' then
               select fct_hc_soci(soci.id_soci,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TR_2') into vTR_5 from dual;
               select fct_hc_soci(soci.id_soci,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TR_2PAT') into vTR_6 from dual;
               if vTR_5 is null and vTR_6 is null then
                 vVALE_SPEC_TR := '';
               else
                 vVALE_SPEC_TR := 'Troisième valeur société : Sala. :' || vTR_5 || ' / Patr. : ' || vTR_6;
               end if;
             elsif nVALE_SPEC_TR = 0 and vTR_ETAB = '1' then
               select fct_hc_etab(data.id_etab,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TR_ETAB_SALA_1') into vTR_7 from dual;
               select fct_hc_etab(data.id_etab,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TR_ETAB_PATR_1') into vTR_8 from dual;
               if vTR_7 is null and vTR_8 is null then
                 vVALE_SPEC_TR := '';
               else
                 vVALE_SPEC_TR := 'Première valeur établissement : Sala. :' || vTR_7 || ' / Patr. : ' || vTR_8;
               end if;
             elsif nVALE_SPEC_TR = 1 and vTR_ETAB = '1' then
               select fct_hc_etab(data.id_etab,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TR_ETAB_SALA_2') into vTR_9 from dual;
               select fct_hc_etab(data.id_etab,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TR_ETAB_PATR_2') into vTR_10 from dual;
               if vTR_9 is null and vTR_10 is null then
                 vVALE_SPEC_TR := '';
               else
                 vVALE_SPEC_TR := 'Deuxième valeur établissement : Sala. :' || vTR_9 || ' / Patr. : ' || vTR_10;
               end if;
             elsif nVALE_SPEC_TR = 2 and vTR_ETAB = '1' then
               select fct_hc_etab(data.id_etab,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TR_ETAB_SALA_3') into vTR_11 from dual;
               select fct_hc_etab(data.id_etab,to_char(peri.peri_paie, 'DD/MM/YYYY'),'TR_ETAB_PATR_3') into vTR_12 from dual;
               if vTR_11 is null and vTR_12 is null then
                 vVALE_SPEC_TR := '';
               else
                 vVALE_SPEC_TR := 'Troisième valeur établissement : Sala. :' || vTR_11 || ' / Patr. : ' || vTR_12;
               end if;
             else
               vVALE_SPEC_TR := '';
             end if;
             begin
               select vale into vVALE_CONG_PRIS_N from hist_cons_sala where id_sala=data.id_sala and code_cons='COPRIMOI_LEGA' and peri=peri.peri_paie;
             exception
             when NO_DATA_FOUND then
               vVALE_CONG_PRIS_N := '0';
             end;

             vCONG_REST_N := vVALE_CONG_REST_N + vVALE_CONG_ACQU_N - vVALE_CONG_PRIS_N;

             vEVOL_REMU_SUPP_COTI := fct_hc_sala_nume(data.id_sala, to_char(peri.peri_paie,'DD/MM/YYYY'), 'EVOL_REMU_SUPP_COTI_BULL_SIMP');

             fCONG_PRIS_ANNE_N := fct_hc_sala_comp(iID_SOCI, data.id_sala, to_char(peri.peri_paie, 'DD/MM/YYYY'), 'COPRIANN_LEGA');

             iBULLMOD:=data.id_modbull;
             oGeav.conv_coll:=data.conv_coll;
             oGeav.nomb_enfa:=fct_nomb_enfa(data.id_sala,to_char(peri.peri_paie,'DD/MM/YYYY'));

             if data.droi_prim_anci='N' then
                oEdit.droi_prim_anci    :='Non';
             else
                oEdit.droi_prim_anci    :='Oui';
             end if;
             if parse_date(data.fin_peri_essa) is not null then
                oEdit.fin_peri_essa:=to_char(to_date(parse_date(data.fin_peri_essa),'DD/MM/YYYY'),'DD/MM/YYYY');

             else
                oEdit.fin_peri_essa:=null;

             end if;

             if data.depa_nais is not null then
               if rv_S_GEO_DEPARTEMENT.exists(data.depa_nais) then
                 vDEPA_NAIS := rv_S_GEO_DEPARTEMENT(data.depa_nais);
               else
                 vDEPA_NAIS := null;
               end if;
             else
               vDEPA_NAIS := null;
             end if;


             oGeav.idcc_heur_equi := data.idcc_heur_equi;
             oGeav.moti_augm      := data.moti_augm;
             oGeav.moti_augm_2    := data.moti_augm_2; ---KFH 25/05/2023 T184292
             oGeav.TICK_REST_TYPE_REPA := data.TICK_REST_TYPE_REPA; ---KFH 03/04/2024 T201908
             oGeav.sala_auto_titr_trav := data.sala_auto_titr_trav;
             oGeav.lieu_pres_stag      := data.lieu_pres_stag;
             if    data.cipdz='1' then
                oGeav.cipdz_code :='C';
                oGeav.cipdz_libe :='Emploi à temps complet';

             elsif data.cipdz='2' then
                oGeav.cipdz_code :='I';
                oGeav.cipdz_libe :='Emploi intermittent';

             elsif data.cipdz='3' then
                oGeav.cipdz_code :='P';
                oGeav.cipdz_libe :='Emploi à temps partiel';

             elsif data.cipdz='4' then
                oGeav.cipdz_code :='D';
                oGeav.cipdz_libe :='Emploi à domicile';

             elsif data.cipdz='5' then
                oGeav.cipdz_code :='Z';
                oGeav.cipdz_libe :='Régularisation année précédente';

             else
                oGeav.cipdz_code :='';
                oGeav.cipdz_libe :='';

             end if;

             oBANQ_01:=fct__get_banque(data.id_sala,'DEFAUT_01');
             oBANQ_02:=fct__get_banque(data.id_sala,'DEFAUT_02');

             if data.code_moti_recr_cdd is null then
                vLIBE_MOTI_RECR_CDD := null;
             elsif data.code_moti_recr_cdd = 'AUTR' then
                vLIBE_MOTI_RECR_CDD := nvl(trim(data.prec_moti_recr_cdd), 'Autre');
             else
                if rv_S_MOTI_RECR_CDD.exists(data.code_moti_recr_cdd) then
                  if data.prec_moti_recr_cdd is not null then
                    vLIBE_MOTI_RECR_CDD := rv_S_MOTI_RECR_CDD( data.code_moti_recr_cdd).libe_moti_recr_cdd||' ('||data.prec_moti_recr_cdd||')';
                  else
                    vLIBE_MOTI_RECR_CDD := rv_S_MOTI_RECR_CDD( data.code_moti_recr_cdd).libe_moti_recr_cdd;
                  end if;
                end if;
             end if;

             if data.code_moti_recr_cdd2 is null then
                vLIBE_MOTI_RECR_CDD2 := null;
             elsif data.code_moti_recr_cdd2 = 'AUTR' then
                vLIBE_MOTI_RECR_CDD2 := 'Autre';
             else
                if rv_S_MOTI_RECR_CDD2.exists(data.code_moti_recr_cdd2) then
                	vLIBE_MOTI_RECR_CDD2 := rv_S_MOTI_RECR_CDD2( data.code_moti_recr_cdd2).libe_moti_recr_cdd;
                end if;
             end if;

             if data.code_moti_recr_cdd3 is null then
                vLIBE_MOTI_RECR_CDD3 := null;
             elsif data.code_moti_recr_cdd3 = 'AUTR' then
                vLIBE_MOTI_RECR_CDD3 := nvl(trim(data.prec_moti_recr_cdd3), 'Autre');
             else
                if rv_S_MOTI_RECR_CDD3.exists(data.code_moti_recr_cdd3) then
                  if data.prec_moti_recr_cdd3 is not null then
                    vLIBE_MOTI_RECR_CDD3 := data.prec_moti_recr_cdd3;
                  end if;
                end if;
             end if;

             if peri.peri_paie >= dPERI_COUR then
                oBANQ_01_HIST:=oBANQ_01;
                oBANQ_02_HIST:=oBANQ_02;

             else
                oBANQ_01_HIST:=pack_embeded.get_hist_salarie_banq(data.id_sala,'DEFAUT_01',peri.peri_paie );
                oBANQ_02_HIST:=pack_embeded.get_hist_salarie_banq(data.id_sala,'DEFAUT_02',peri.peri_paie );

                if not oBANQ_01_HIST.is_found then
                   oBANQ_01_HIST:=oBANQ_01;
                end if;
                if not oBANQ_02_HIST.is_found then
                   oBANQ_02_HIST:=oBANQ_02;
                end if;
             end if;

             oEDIT.rib_banq_1     :=oBANQ_01_HIST.banq ;
             oEDIT.rib_guic_1     :=oBANQ_01_HIST.rib_guic ;
             oEDIT.rib_comp_1     :=oBANQ_01_HIST.rib_comp ;
             oEDIT.rib_cle_1      :=oBANQ_01_HIST.rib_cle ;
             oEDIT.rib_banq_01    :=oBANQ_01_HIST.rib_banq ;
             oEDIT.rib_domi_1     :=oBANQ_01_HIST.domi ;
             oEDIT.rib_nume_1     :=fct_format_rib(oBANQ_01_HIST.rib_banq,oBANQ_01_HIST.rib_guic,oBANQ_01_HIST.rib_comp,oBANQ_01_HIST.rib_cle);
             oEDIT.rib_titu_comp_1:=oBANQ_01_HIST.titu ;

             oEDIT.rib_banq_2     :=oBANQ_02_HIST.banq ;
             oEDIT.rib_domi_2     :=oBANQ_02_HIST.domi ;
             oEDIT.rib_banq_02    :=oBANQ_02_HIST.rib_banq ;
             oEDIT.rib_nume_2     :=fct_format_rib(oBANQ_02_HIST.rib_banq,oBANQ_02_HIST.rib_guic,oBANQ_02_HIST.rib_comp,oBANQ_02_HIST.rib_cle);
             oEDIT.rib_titu_comp_2:=oBANQ_02_HIST.titu ;

             oEdit.bic_01         :=fct_format_bic(oBANQ_01_HIST.bic_banque,oBANQ_01_HIST.bic_pays,oBANQ_01_HIST.bic_emplacement,oBANQ_01_HIST.bic_branche);
             oEdit.bic_02         :=fct_format_bic(oBANQ_02_HIST.bic_banque,oBANQ_02_HIST.bic_pays,oBANQ_02_HIST.bic_emplacement,oBANQ_02_HIST.bic_branche);

             oEdit.iban_01        :=fct_iban_format(oBANQ_01_HIST.iban_nume,oBANQ_01_HIST.iban_pays);
             oEdit.iban_02        :=fct_iban_format(oBANQ_02_HIST.iban_nume,oBANQ_02_HIST.iban_pays);

             ------------------------------------------------------------
             -- Lecture de l'affectation des codes analytiques par plan
             ------------------------------------------------------------
             pr__raz_sala_plan_anal(oGeav);

             if rv_S_SALA_PLAN_ANAL.exists(data.id_sala || '-1-' || to_char(peri.peri_paie,'DD/MM/YYYY')) then
               oSALA_PLAN_ANAL := rv_S_SALA_PLAN_ANAL(data.id_sala || '-1-' || to_char(peri.peri_paie,'DD/MM/YYYY'));
               pr__maj_edit_plan_anal(1,oSALA_PLAN_ANAL,oGeav);
             end if;

             if rv_S_SALA_PLAN_ANAL.exists(data.id_sala || '-2-' || to_char(peri.peri_paie,'DD/MM/YYYY')) then
               oSALA_PLAN_ANAL := rv_S_SALA_PLAN_ANAL(data.id_sala || '-2-' || to_char(peri.peri_paie,'DD/MM/YYYY'));
               pr__maj_edit_plan_anal(2,oSALA_PLAN_ANAL,oGeav);
             end if;

             if rv_S_SALA_PLAN_ANAL.exists(data.id_sala || '-3-' || to_char(peri.peri_paie,'DD/MM/YYYY')) then
               oSALA_PLAN_ANAL := rv_S_SALA_PLAN_ANAL(data.id_sala || '-3-' || to_char(peri.peri_paie,'DD/MM/YYYY'));
               pr__maj_edit_plan_anal(3,oSALA_PLAN_ANAL,oGeav);
             end if;

             if rv_S_SALA_PLAN_ANAL.exists(data.id_sala || '-4-' || to_char(peri.peri_paie,'DD/MM/YYYY')) then
               oSALA_PLAN_ANAL := rv_S_SALA_PLAN_ANAL(data.id_sala || '-4-' || to_char(peri.peri_paie,'DD/MM/YYYY'));
               pr__maj_edit_plan_anal(4,oSALA_PLAN_ANAL,oGeav);
             end if;

             if rv_S_SALA_PLAN_ANAL.exists(data.id_sala || '-5-' || to_char(peri.peri_paie,'DD/MM/YYYY')) then
               oSALA_PLAN_ANAL := rv_S_SALA_PLAN_ANAL(data.id_sala || '-5-' || to_char(peri.peri_paie,'DD/MM/YYYY'));
               pr__maj_edit_plan_anal(5,oSALA_PLAN_ANAL,oGeav);
             end if;

             if data.moti_depa_code is not null then
                if rv_S_MOTIFDEP.exists( data.moti_depa_code ) then
                   if rv_S_MOTIFDEP( data.moti_depa_code ).deta=1 then
                      oGeav.moti_depa:=rv_S_MOTIFDEP( data.moti_depa_code ).libe||' '|| data.moti_depa_libe ;
                   else
                      oGeav.moti_depa:=rv_S_MOTIFDEP( data.moti_depa_code ).libe;
                   end if;
                else
                   oGeav.moti_depa:=null;
                end if;
             else
                oGeav.moti_depa:=null;
             end if;
             -- récupération des commentaires par salarié et période
             begin
                select comm_1, comm_2, comm_3  into  oEdit.comm_1 , oEdit.comm_2, oEdit.comm_3 from hist_bulletin where peri = peri.peri_paie and id_sala = data.id_sala;
             exception
             when no_data_found then
               null;
             end;
             oEdit.rapp_hora_arro := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'HORAIRE_RAPP_SOCI' );
             if oEdit.rapp_hora_arro  > 1 then
              oEdit.rapp_hora_arro  := 1;
             end if;
              /* FS : T46987: RESPONSABLE HIERARCHIQUE DE L'ONGLET AFFECTATION DANS LA GESTION AVANCEE  */
             oEdit.hier_resp_1_nom := '';
             oEdit.hier_resp_1_mail := '';

             if data.resp_hier is not null then
               oRESPONSABLE          := fct__get_salarie( data.resp_hier);
               oEdit.hier_resp_1_nom := substr(fct_format_nom(oRESPONSABLE.pren,oRESPONSABLE.nom,'REVE','-ANONYMOUS_OFF'), 1, 300);
               oEdit.hier_resp_1_mail:= substr(trim(oRESPONSABLE.mail_sala_cong                                         ),1,255);
             end if;

             oEdit.hier_resp_2_nom := '';
             oEdit.hier_resp_2_mail := '';

             if data.resp_hier_seco is not null then
               oRESPONSABLE          := fct__get_salarie( data.resp_hier_seco);
               oEdit.hier_resp_2_nom := substr(fct_format_nom(oRESPONSABLE.pren,oRESPONSABLE.nom,'REVE','-ANONYMOUS_OFF'), 1, 300);
               oEdit.hier_resp_2_mail:= substr(trim(oRESPONSABLE.mail_sala_cong                                         ),1,255);
             end if;

             if data.id_resp_cong is not null then

                oRESPONSABLE:=fct__get_salarie( data.id_resp_cong );

                --.. on valorise la ligne d'édition
                oEdit.resp_hier_1_nom :=substr(fct_format_nom(oRESPONSABLE.pren,oRESPONSABLE.nom,'REVE','-ANONYMOUS_OFF'), 1, 300);
                oEdit.resp_hier_1_mail:=substr(trim(oRESPONSABLE.mail_sala_cong                                         ),1,255);

                if oRESPONSABLE.id_resp_cong_dele is not null then
                   oDELEGUE:=fct__get_salarie( oRESPONSABLE.id_resp_cong_dele );

                   --.. on valorise la ligne d'édition
                   oEdit.resp_hier_2_nom :=substr(fct_format_nom(oDELEGUE.pren,oDELEGUE.nom,'REVE','-ANONYMOUS_OFF'), 1, 300);
                   oEdit.resp_hier_2_mail:=substr(trim(oDELEGUE.mail_sala_cong                                     ),1,255);

                else
                   --si pas de id_delegue... alors on n'as pas de delegué
                   --... CQFD
                   oEdit.resp_hier_2_nom :='';
                   oEdit.resp_hier_2_mail:='';
                end if;
             else
                --si pas de id_responsable... alors on n'as pas de responsable
                --... CQFD
                oEdit.resp_hier_1_nom :='';
                oEdit.resp_hier_1_mail:='';

                --si pas de responsable... alors on n'as pas de delegué du responsable
                --... CQFD
                oEdit.resp_hier_2_nom :='';
                oEdit.resp_hier_2_mail:='';
             end if;

             if data.id_tran is not null then
                oTRANSFERT:=fct__get_salarie(data.id_tran);
                if oTRANSFERT.id_soci is not null then
                   if ri_SOCIETES.exists( oTRANSFERT.id_soci  ) then
                      oEdit.soci_orig:=ri_SOCIETES( oTRANSFERT.id_soci  );
                   else
                      oEdit.soci_orig:=null;
                   end if;
                else
                   oEdit.soci_orig:=null;
                end if;
             else
                oEdit.soci_orig:=null;
             end if;

           -- select
           --    max(case when code_cons='NIVEAU'              then vale_char else null end ) as NIVEAU,
           --    max(case when code_cons='ECHELON'             then vale_char else null end ) as ECHELON,
           --    max(case when code_cons='POSITION'            then vale_char else null end ) as POSITION,
           --    sum(case when code_cons='COEFFIC'             then vale      else 0    end ) as COEFFIC,
           --    sum(case when code_cons='INDICE'              then vale      else 0    end ) as INDICE,
           --    sum(case when code_cons='DATEANCI_PROF'       then vale      else 0    end ) as DATEANCI_PROF,
           --    sum(case when code_cons='DATE_SIGN_CONV_STAG' then vale      else 0    end ) as DATE_SIGN_CONV_STAG,
           --    sum(case when code_cons='DATE_REFE_01'        then vale      else 0    end ) as DATE_REFE_01,
           --    sum(case when code_cons='DATE_REFE_02'        then vale      else 0    end ) as DATE_REFE_02,
           --    sum(case when code_cons='DATE_REFE_03'        then vale      else 0    end ) as DATE_REFE_03,
           --    sum(case when code_cons='DATE_REFE_04'        then vale      else 0    end ) as DATE_REFE_04,
           --    sum(case when code_cons='DATE_REFE_05'        then vale      else 0    end ) as DATE_REFE_05
           -- into
           --    vNIVEAU,
           --    vECHELON,
           --    vPOSITION,
           --    fCOEFFIC,
           --    fINDICE,
           --    fDATEANCI_PROF,
           --    fDATEANCI_CADR_FORF,
           --    fDATE_SIGN_CONV_STAG,
           --    fDATE_REFE_01,
           --    fDATE_REFE_02,
           --    fDATE_REFE_03,
           --    fDATE_REFE_04,
           --    fDATE_REFE_05
           -- from hist_cons_sala
           -- where peri=peri.peri_paie
           --   and id_sala=data.id_sala
           --   and code_cons in (
           --      'NIVEAU',
           --      'ECHELON',
           --      'POSITION',
           --      'COEFFIC',
           --      'INDICE',
           --      'DATEANCI_PROF',
           --      'DATE_SIGN_CONV_STAG',
           --      'DATE_REFE_01',
           --      'DATE_REFE_02',
           --      'DATE_REFE_03',
           --      'DATE_REFE_04',
           --      'DATE_REFE_05'
           -- );
            vNIVEAU                := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'NIVEAU'    );
            vECHELON               := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'ECHELON'                 );
            vGROU_CONV             := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'GROU_CONV'               );
            vPOSITION              := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'POSITION'                );
            fCOEFFIC               := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'COEFFIC'                 );
            vCOTA                  := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'COTA'                    );  -- T146548
            vCLAS                  := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'CLAS'                    );
            vSEUI                  := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'SEUI'                    );
            vPALI                  := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'PALI'                    );
            vGRAD                  := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'GRAD'                    );
            vDEGR                  := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'DEGR'                    );
            vFILI                  := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'FILI'                    );
            vSECT_PROF             := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'SECT_PROF'               );
            
            begin
              select libe_fili into vLIBE_FILI from mt.CCN_FILI where code_idcc = data.code_idcc and id_fili = vFILI;
            exception
            when no_data_found then
              vLIBE_FILI := null;
            end;

            begin
              select libe_sect_pro into vLIBE_SECT_PROF from mt.ccn_sect_pro where code_idcc = data.code_idcc and id_sect_pro = vSECT_PROF;
            exception
            when no_data_found then
              vLIBE_SECT_PROF := null;
            end;
            
            if (fCOEFFIC is null or fCOEFFIC=0) then
              vCOEFFIC := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'COEFFIC'                );
              vCOEFFIC := substr(vCOEFFIC      ,1,50);
            else
              vCOEFFIC := substr(fCOEFFIC      ,1,50);
            end if;
            fINDICE                := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'INDICE'                  );
            if (fINDICE is null or fINDICE=0) then
              vINDICE := fct_hc_sala_char(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'INDICE'                );
              vINDICE := substr(vINDICE      ,1,50);
            else
              vINDICE := substr(fINDICE      ,1,50);
            end if;

            fDATEANCI_PROF         := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'DATEANCI_PROF'           );
            fDATEANCI_CADR_FORF    := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'DATE_ANCI_CADR_FORF'           );
            fDATE_SIGN_CONV_STAG   := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'DATE_SIGN_CONV_STAG'     );
            fDATE_REFE_01          := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'DATE_REFE_01'            );
            fDATE_REFE_02          := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'DATE_REFE_02'            );
            fDATE_REFE_03          := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'DATE_REFE_03'            );
            fDATE_REFE_04          := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'DATE_REFE_04'            );
            fDATE_REFE_05          := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'DATE_REFE_05'             );

             if oList.ccn51_anci_date_chan_appl='O' or (parse_int(oList.ccn51_anci_date_chan_appl) is not null and parse_int(oList.ccn51_anci_date_chan_appl)!=-1) or oList.ccn51_anci_taux='O' or (parse_int(oList.ccn51_anci_taux) is not null and parse_int(oList.ccn51_anci_taux)!=-1) then
                begin
                   select
                      to_char(date_chan_appl,'DD/MM/YYYY'),
                      fct_format(pour_majo,'TAUX','O')
                   into
                      oEdit.ccn51_anci_date_chan_appl,
                      oEdit.ccn51_anci_taux
                   from (
                         select
                            sm.* from salarie_majoration sm
                         where id_sala=data.id_sala
                           and type_majo='ANCI'
                           and date_chan_appl<=peri.peri_paie
                        order by pour_majo desc
                   )
                   where rownum=1
                   ;
                exception
                  when no_data_found then
                      oEdit.ccn51_anci_date_chan_appl :=null;
                      oEdit.ccn51_anci_taux           :=null;
                end;
             else
                oEdit.ccn51_anci_date_chan_appl :=null;
                oEdit.ccn51_anci_taux           :=null;
             end if;

             if oList.ccn51_cadr_date_chan_appl='O' or (parse_int(oList.ccn51_cadr_date_chan_appl) is not null and parse_int(oList.ccn51_cadr_date_chan_appl)!=-1) or oList.ccn51_cadr_taux='O' or (parse_int(oList.ccn51_cadr_taux) is not null and parse_int(oList.ccn51_cadr_taux)!=-1) then
                begin
                   select
                      to_char(date_chan_appl,'DD/MM/YYYY'),
                      fct_format(pour_majo,'TAUX','O')
                   into
                      oEdit.ccn51_cadr_date_chan_appl,
                      oEdit.ccn51_cadr_taux
                   from (
                         select
                            sm.* from salarie_majoration sm
                         where id_sala=data.id_sala
                           and type_majo='SPEC_CADR'
                           and date_chan_appl<=peri.peri_paie
                        order by pour_majo desc
                   )
                   where rownum=1
                   ;
                exception
                  when no_data_found then
                      oEdit.ccn51_cadr_date_chan_appl :=null;
                      oEdit.ccn51_cadr_taux           :=null;
                end;
             else
                oEdit.ccn51_cadr_date_chan_appl :=null;
                oEdit.ccn51_cadr_taux           :=null;
             end if;

             if iBULLMOD is not null then
                if ri_S_MODBULL.exists( iBULLMOD ) then
                   -- si le modbull existe, on le relit

                   oEdit.bull_mode :=ri_S_MODBULL( iBULLMOD ).libe ;
                else
                   -- sinon, on l'extrait de la base
                   -- en valorisant la ligne d'édition
                   select
                      max(libe)
                   into
                      oEdit.bull_mode
                   from modbull
                   where id_modbull=iBULLMOD
                   ;

                   -- et on le sauvegarde pour une utilisation future potentielle
                   ri_S_MODBULL(iBULLMOD).libe :=oEdit.bull_mode;

                   if fct_modbull_stagiaire(iBULLMOD)=1 then
                      ri_S_MODBULL_STAG(iBULLMOD).libe :=oEdit.bull_mode;
                   end if;
                end if;
             else
                oEdit.bull_mode :=null;
             end if;

             if fDATE_REFE_01 between 19000000 and 99999999 then  oGeav.date_refe_01:=to_char(to_date(fDATE_REFE_01,'YYYYMMDD'),'DD/MM/YYYY'); else oGeav.date_refe_01:=null; end if;
             if fDATE_REFE_02 between 19000000 and 99999999 then  oGeav.date_refe_02:=to_char(to_date(fDATE_REFE_02,'YYYYMMDD'),'DD/MM/YYYY'); else oGeav.date_refe_02:=null; end if;
             if fDATE_REFE_03 between 19000000 and 99999999 then  oGeav.date_refe_03:=to_char(to_date(fDATE_REFE_03,'YYYYMMDD'),'DD/MM/YYYY'); else oGeav.date_refe_03:=null; end if;
             if fDATE_REFE_04 between 19000000 and 99999999 then  oGeav.date_refe_04:=to_char(to_date(fDATE_REFE_04,'YYYYMMDD'),'DD/MM/YYYY'); else oGeav.date_refe_04:=null; end if;
             if fDATE_REFE_05 between 19000000 and 99999999 then  oGeav.date_refe_05:=to_char(to_date(fDATE_REFE_05,'YYYYMMDD'),'DD/MM/YYYY'); else oGeav.date_refe_05:=null; end if;

             if fDATEANCI_PROF between 19000000 and 99999999 then
                oGeav.date_anci_prof:=to_char(to_date(fDATEANCI_PROF,'YYYYMMDD'),'DD/MM/YYYY');
             else
                oGeav.date_anci_prof:=null;
             end if;

             if fDATEANCI_CADR_FORF between 19000000 and 99999999 then
                oGeav.date_anci_cadr_forf:=to_char(to_date(fDATEANCI_CADR_FORF,'YYYYMMDD'),'DD/MM/YYYY');
             else
                oGeav.date_anci_cadr_forf:=null;
             end if;

             if fDATE_SIGN_CONV_STAG between 19000000 and 99999999 and ri_S_MODBULL_STAG.exists(iBULLMOD) then
                oGeav.date_sign_conv_stag:=to_char(to_date(fDATE_SIGN_CONV_STAG,'YYYYMMDD'),'DD/MM/YYYY');
             else
                oGeav.date_sign_conv_stag:=null;
             end if;

             iLOOP_ANAL:=0;
             for repa_anal in (
                select
                   s.nom,
                   s.id_sala,
                   ra.ca,
                   ra.pour_affe,
                   ra.axe
                from salarie_table s,(
                   select
                      max(hrsa.id_sala)              as id_sala,
                      hrsa.code_anal                 as ca,
                      max(100*nvl(hrsa.pour_anal,0)) as pour_affe,
                      max(hrsa.axe)                  as axe
                   from hist_rubr_sala_anal hrsa
                   where hrsa.id_sala=data.id_sala
                     and hrsa.peri=peri.peri_paie
                     and oPara.rupt_dema='O'
                     and (iANAL=0 or nvl(hrsa.code_anal,'@sans@') in (select * from table(cast(tANAL as table_of_varchar2_255) ) ) )
                     and nvl(hrsa.pour_anal,0)!=0
                   group by hrsa.code_anal
                   order by axe
                ) ra
                where s.id_sala=data.id_sala
                  and ra.id_sala(+)=s.id_sala
                  and (case oPara.rupt_dema when 'O' then 'O' else 'N' end ='N' or ra.id_sala=s.id_sala)
                order by ra.axe
             )loop
                iLOOP_ANAL:=iLOOP_ANAL+1;

                if oPara.rupt_dema='O' then

                   oGeav.repa_anal:=iLOOP_ANAL;
                   oGeav.repa_anal_code:=repa_anal.ca;
                   oGeav.repa_anal_pour:=repa_anal.pour_affe;

                   oGeav.rubr_01:=fct_rubrique_analytique(oList.rubr_01,oList.id_rubr_01,data.id_sala,oList.vale_rubr_01,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_02:=fct_rubrique_analytique(oList.rubr_02,oList.id_rubr_02,data.id_sala,oList.vale_rubr_02,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_03:=fct_rubrique_analytique(oList.rubr_03,oList.id_rubr_03,data.id_sala,oList.vale_rubr_03,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_04:=fct_rubrique_analytique(oList.rubr_04,oList.id_rubr_04,data.id_sala,oList.vale_rubr_04,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_05:=fct_rubrique_analytique(oList.rubr_05,oList.id_rubr_05,data.id_sala,oList.vale_rubr_05,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_06:=fct_rubrique_analytique(oList.rubr_06,oList.id_rubr_06,data.id_sala,oList.vale_rubr_06,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_07:=fct_rubrique_analytique(oList.rubr_07,oList.id_rubr_07,data.id_sala,oList.vale_rubr_07,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_08:=fct_rubrique_analytique(oList.rubr_08,oList.id_rubr_08,data.id_sala,oList.vale_rubr_08,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_09:=fct_rubrique_analytique(oList.rubr_09,oList.id_rubr_09,data.id_sala,oList.vale_rubr_09,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_10:=fct_rubrique_analytique(oList.rubr_10,oList.id_rubr_10,data.id_sala,oList.vale_rubr_10,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_11:=fct_rubrique_analytique(oList.rubr_11,oList.id_rubr_11,data.id_sala,oList.vale_rubr_11,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_12:=fct_rubrique_analytique(oList.rubr_12,oList.id_rubr_12,data.id_sala,oList.vale_rubr_12,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_13:=fct_rubrique_analytique(oList.rubr_13,oList.id_rubr_13,data.id_sala,oList.vale_rubr_13,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_14:=fct_rubrique_analytique(oList.rubr_14,oList.id_rubr_14,data.id_sala,oList.vale_rubr_14,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_15:=fct_rubrique_analytique(oList.rubr_15,oList.id_rubr_15,data.id_sala,oList.vale_rubr_15,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_16:=fct_rubrique_analytique(oList.rubr_16,oList.id_rubr_16,data.id_sala,oList.vale_rubr_16,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_17:=fct_rubrique_analytique(oList.rubr_17,oList.id_rubr_17,data.id_sala,oList.vale_rubr_17,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_18:=fct_rubrique_analytique(oList.rubr_18,oList.id_rubr_18,data.id_sala,oList.vale_rubr_18,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_19:=fct_rubrique_analytique(oList.rubr_19,oList.id_rubr_19,data.id_sala,oList.vale_rubr_19,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_20:=fct_rubrique_analytique(oList.rubr_20,oList.id_rubr_20,data.id_sala,oList.vale_rubr_20,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_21:=fct_rubrique_analytique(oList.rubr_21,oList.id_rubr_21,data.id_sala,oList.vale_rubr_21,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_22:=fct_rubrique_analytique(oList.rubr_22,oList.id_rubr_22,data.id_sala,oList.vale_rubr_22,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_23:=fct_rubrique_analytique(oList.rubr_23,oList.id_rubr_23,data.id_sala,oList.vale_rubr_23,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_24:=fct_rubrique_analytique(oList.rubr_24,oList.id_rubr_24,data.id_sala,oList.vale_rubr_24,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_25:=fct_rubrique_analytique(oList.rubr_25,oList.id_rubr_25,data.id_sala,oList.vale_rubr_25,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_26:=fct_rubrique_analytique(oList.rubr_26,oList.id_rubr_26,data.id_sala,oList.vale_rubr_26,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_27:=fct_rubrique_analytique(oList.rubr_27,oList.id_rubr_27,data.id_sala,oList.vale_rubr_27,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_28:=fct_rubrique_analytique(oList.rubr_28,oList.id_rubr_28,data.id_sala,oList.vale_rubr_28,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_29:=fct_rubrique_analytique(oList.rubr_29,oList.id_rubr_29,data.id_sala,oList.vale_rubr_29,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_30:=fct_rubrique_analytique(oList.rubr_30,oList.id_rubr_30,data.id_sala,oList.vale_rubr_30,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_31:=fct_rubrique_analytique(oList.rubr_31,oList.id_rubr_31,data.id_sala,oList.vale_rubr_31,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_32:=fct_rubrique_analytique(oList.rubr_32,oList.id_rubr_32,data.id_sala,oList.vale_rubr_32,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_33:=fct_rubrique_analytique(oList.rubr_33,oList.id_rubr_33,data.id_sala,oList.vale_rubr_33,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_34:=fct_rubrique_analytique(oList.rubr_34,oList.id_rubr_34,data.id_sala,oList.vale_rubr_34,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_35:=fct_rubrique_analytique(oList.rubr_35,oList.id_rubr_35,data.id_sala,oList.vale_rubr_35,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_36:=fct_rubrique_analytique(oList.rubr_36,oList.id_rubr_36,data.id_sala,oList.vale_rubr_36,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_37:=fct_rubrique_analytique(oList.rubr_37,oList.id_rubr_37,data.id_sala,oList.vale_rubr_37,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_38:=fct_rubrique_analytique(oList.rubr_38,oList.id_rubr_38,data.id_sala,oList.vale_rubr_38,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_39:=fct_rubrique_analytique(oList.rubr_39,oList.id_rubr_39,data.id_sala,oList.vale_rubr_39,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_40:=fct_rubrique_analytique(oList.rubr_40,oList.id_rubr_40,data.id_sala,oList.vale_rubr_40,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_41:=fct_rubrique_analytique(oList.rubr_41,oList.id_rubr_41,data.id_sala,oList.vale_rubr_41,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_42:=fct_rubrique_analytique(oList.rubr_42,oList.id_rubr_42,data.id_sala,oList.vale_rubr_42,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_43:=fct_rubrique_analytique(oList.rubr_43,oList.id_rubr_43,data.id_sala,oList.vale_rubr_43,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_44:=fct_rubrique_analytique(oList.rubr_44,oList.id_rubr_44,data.id_sala,oList.vale_rubr_44,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_45:=fct_rubrique_analytique(oList.rubr_45,oList.id_rubr_45,data.id_sala,oList.vale_rubr_45,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_46:=fct_rubrique_analytique(oList.rubr_46,oList.id_rubr_46,data.id_sala,oList.vale_rubr_46,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_47:=fct_rubrique_analytique(oList.rubr_47,oList.id_rubr_47,data.id_sala,oList.vale_rubr_47,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_48:=fct_rubrique_analytique(oList.rubr_48,oList.id_rubr_48,data.id_sala,oList.vale_rubr_48,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_49:=fct_rubrique_analytique(oList.rubr_49,oList.id_rubr_49,data.id_sala,oList.vale_rubr_49,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_50:=fct_rubrique_analytique(oList.rubr_50,oList.id_rubr_50,data.id_sala,oList.vale_rubr_50,peri.peri_paie,repa_anal.ca,repa_anal.axe);

                   oGeav.rubr_51:=fct_rubrique_analytique(oList_2.rubr_51,oList_2.id_rubr_51,data.id_sala,oList_2.vale_rubr_51,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_52:=fct_rubrique_analytique(oList_2.rubr_52,oList_2.id_rubr_52,data.id_sala,oList_2.vale_rubr_52,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_53:=fct_rubrique_analytique(oList_2.rubr_53,oList_2.id_rubr_53,data.id_sala,oList_2.vale_rubr_53,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_54:=fct_rubrique_analytique(oList_2.rubr_54,oList_2.id_rubr_54,data.id_sala,oList_2.vale_rubr_54,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_55:=fct_rubrique_analytique(oList_2.rubr_55,oList_2.id_rubr_55,data.id_sala,oList_2.vale_rubr_55,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_56:=fct_rubrique_analytique(oList_2.rubr_56,oList_2.id_rubr_56,data.id_sala,oList_2.vale_rubr_56,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_57:=fct_rubrique_analytique(oList_2.rubr_57,oList_2.id_rubr_57,data.id_sala,oList_2.vale_rubr_57,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_58:=fct_rubrique_analytique(oList_2.rubr_58,oList_2.id_rubr_58,data.id_sala,oList_2.vale_rubr_58,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_59:=fct_rubrique_analytique(oList_2.rubr_59,oList_2.id_rubr_59,data.id_sala,oList_2.vale_rubr_59,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_60:=fct_rubrique_analytique(oList_2.rubr_60,oList_2.id_rubr_60,data.id_sala,oList_2.vale_rubr_60,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_61:=fct_rubrique_analytique(oList_2.rubr_61,oList_2.id_rubr_61,data.id_sala,oList_2.vale_rubr_61,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_62:=fct_rubrique_analytique(oList_2.rubr_62,oList_2.id_rubr_62,data.id_sala,oList_2.vale_rubr_62,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_63:=fct_rubrique_analytique(oList_2.rubr_63,oList_2.id_rubr_63,data.id_sala,oList_2.vale_rubr_63,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_64:=fct_rubrique_analytique(oList_2.rubr_64,oList_2.id_rubr_64,data.id_sala,oList_2.vale_rubr_64,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_65:=fct_rubrique_analytique(oList_2.rubr_65,oList_2.id_rubr_65,data.id_sala,oList_2.vale_rubr_65,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_66:=fct_rubrique_analytique(oList_2.rubr_66,oList_2.id_rubr_66,data.id_sala,oList_2.vale_rubr_66,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_67:=fct_rubrique_analytique(oList_2.rubr_67,oList_2.id_rubr_67,data.id_sala,oList_2.vale_rubr_67,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_68:=fct_rubrique_analytique(oList_2.rubr_68,oList_2.id_rubr_68,data.id_sala,oList_2.vale_rubr_68,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_69:=fct_rubrique_analytique(oList_2.rubr_69,oList_2.id_rubr_69,data.id_sala,oList_2.vale_rubr_69,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_70:=fct_rubrique_analytique(oList_2.rubr_70,oList_2.id_rubr_70,data.id_sala,oList_2.vale_rubr_70,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_71:=fct_rubrique_analytique(oList_2.rubr_71,oList_2.id_rubr_71,data.id_sala,oList_2.vale_rubr_71,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_72:=fct_rubrique_analytique(oList_2.rubr_72,oList_2.id_rubr_72,data.id_sala,oList_2.vale_rubr_72,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_73:=fct_rubrique_analytique(oList_2.rubr_73,oList_2.id_rubr_73,data.id_sala,oList_2.vale_rubr_73,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_74:=fct_rubrique_analytique(oList_2.rubr_74,oList_2.id_rubr_74,data.id_sala,oList_2.vale_rubr_74,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_75:=fct_rubrique_analytique(oList_2.rubr_75,oList_2.id_rubr_75,data.id_sala,oList_2.vale_rubr_75,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_76:=fct_rubrique_analytique(oList_2.rubr_76,oList_2.id_rubr_76,data.id_sala,oList_2.vale_rubr_76,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_77:=fct_rubrique_analytique(oList_2.rubr_77,oList_2.id_rubr_77,data.id_sala,oList_2.vale_rubr_77,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_78:=fct_rubrique_analytique(oList_2.rubr_78,oList_2.id_rubr_78,data.id_sala,oList_2.vale_rubr_78,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_79:=fct_rubrique_analytique(oList_2.rubr_79,oList_2.id_rubr_79,data.id_sala,oList_2.vale_rubr_79,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_80:=fct_rubrique_analytique(oList_2.rubr_80,oList_2.id_rubr_80,data.id_sala,oList_2.vale_rubr_80,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_81:=fct_rubrique_analytique(oList_2.rubr_81,oList_2.id_rubr_81,data.id_sala,oList_2.vale_rubr_81,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_82:=fct_rubrique_analytique(oList_2.rubr_82,oList_2.id_rubr_82,data.id_sala,oList_2.vale_rubr_82,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_83:=fct_rubrique_analytique(oList_2.rubr_83,oList_2.id_rubr_83,data.id_sala,oList_2.vale_rubr_83,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_84:=fct_rubrique_analytique(oList_2.rubr_84,oList_2.id_rubr_84,data.id_sala,oList_2.vale_rubr_84,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_85:=fct_rubrique_analytique(oList_2.rubr_85,oList_2.id_rubr_85,data.id_sala,oList_2.vale_rubr_85,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_86:=fct_rubrique_analytique(oList_2.rubr_86,oList_2.id_rubr_86,data.id_sala,oList_2.vale_rubr_86,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_87:=fct_rubrique_analytique(oList_2.rubr_87,oList_2.id_rubr_87,data.id_sala,oList_2.vale_rubr_87,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_88:=fct_rubrique_analytique(oList_2.rubr_88,oList_2.id_rubr_88,data.id_sala,oList_2.vale_rubr_88,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_89:=fct_rubrique_analytique(oList_2.rubr_89,oList_2.id_rubr_89,data.id_sala,oList_2.vale_rubr_89,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_90:=fct_rubrique_analytique(oList_2.rubr_90,oList_2.id_rubr_90,data.id_sala,oList_2.vale_rubr_90,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_91:=fct_rubrique_analytique(oList_2.rubr_91,oList_2.id_rubr_91,data.id_sala,oList_2.vale_rubr_91,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_92:=fct_rubrique_analytique(oList_2.rubr_92,oList_2.id_rubr_92,data.id_sala,oList_2.vale_rubr_92,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_93:=fct_rubrique_analytique(oList_2.rubr_93,oList_2.id_rubr_93,data.id_sala,oList_2.vale_rubr_93,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_94:=fct_rubrique_analytique(oList_2.rubr_94,oList_2.id_rubr_94,data.id_sala,oList_2.vale_rubr_94,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_95:=fct_rubrique_analytique(oList_2.rubr_95,oList_2.id_rubr_95,data.id_sala,oList_2.vale_rubr_95,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_96:=fct_rubrique_analytique(oList_2.rubr_96,oList_2.id_rubr_96,data.id_sala,oList_2.vale_rubr_96,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_97:=fct_rubrique_analytique(oList_2.rubr_97,oList_2.id_rubr_97,data.id_sala,oList_2.vale_rubr_97,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_98:=fct_rubrique_analytique(oList_2.rubr_98,oList_2.id_rubr_98,data.id_sala,oList_2.vale_rubr_98,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_99:=fct_rubrique_analytique(oList_2.rubr_99,oList_2.id_rubr_99,data.id_sala,oList_2.vale_rubr_99,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_100:=fct_rubrique_analytique(oList_2.rubr_100,oList_2.id_rubr_100,data.id_sala,oList_2.vale_rubr_100,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_101:=fct_rubrique_analytique(oList_2.rubr_101,oList_2.id_rubr_101,data.id_sala,oList_2.vale_rubr_101,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_102:=fct_rubrique_analytique(oList_2.rubr_102,oList_2.id_rubr_102,data.id_sala,oList_2.vale_rubr_102,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_103:=fct_rubrique_analytique(oList_2.rubr_103,oList_2.id_rubr_103,data.id_sala,oList_2.vale_rubr_103,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_104:=fct_rubrique_analytique(oList_2.rubr_104,oList_2.id_rubr_104,data.id_sala,oList_2.vale_rubr_104,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_105:=fct_rubrique_analytique(oList_2.rubr_105,oList_2.id_rubr_105,data.id_sala,oList_2.vale_rubr_105,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_106:=fct_rubrique_analytique(oList_2.rubr_106,oList_2.id_rubr_106,data.id_sala,oList_2.vale_rubr_106,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_107:=fct_rubrique_analytique(oList_2.rubr_107,oList_2.id_rubr_107,data.id_sala,oList_2.vale_rubr_107,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_108:=fct_rubrique_analytique(oList_2.rubr_108,oList_2.id_rubr_108,data.id_sala,oList_2.vale_rubr_108,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_109:=fct_rubrique_analytique(oList_2.rubr_109,oList_2.id_rubr_109,data.id_sala,oList_2.vale_rubr_109,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_110:=fct_rubrique_analytique(oList_2.rubr_110,oList_2.id_rubr_110,data.id_sala,oList_2.vale_rubr_110,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_111:=fct_rubrique_analytique(oList_2.rubr_111,oList_2.id_rubr_111,data.id_sala,oList_2.vale_rubr_111,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_112:=fct_rubrique_analytique(oList_2.rubr_112,oList_2.id_rubr_112,data.id_sala,oList_2.vale_rubr_112,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_113:=fct_rubrique_analytique(oList_2.rubr_113,oList_2.id_rubr_113,data.id_sala,oList_2.vale_rubr_113,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_114:=fct_rubrique_analytique(oList_2.rubr_114,oList_2.id_rubr_114,data.id_sala,oList_2.vale_rubr_114,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_115:=fct_rubrique_analytique(oList_2.rubr_115,oList_2.id_rubr_115,data.id_sala,oList_2.vale_rubr_115,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_116:=fct_rubrique_analytique(oList_2.rubr_116,oList_2.id_rubr_116,data.id_sala,oList_2.vale_rubr_116,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_117:=fct_rubrique_analytique(oList_2.rubr_117,oList_2.id_rubr_117,data.id_sala,oList_2.vale_rubr_117,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_118:=fct_rubrique_analytique(oList_2.rubr_118,oList_2.id_rubr_118,data.id_sala,oList_2.vale_rubr_118,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_119:=fct_rubrique_analytique(oList_2.rubr_119,oList_2.id_rubr_119,data.id_sala,oList_2.vale_rubr_119,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_120:=fct_rubrique_analytique(oList_2.rubr_120,oList_2.id_rubr_120,data.id_sala,oList_2.vale_rubr_120,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_121:=fct_rubrique_analytique(oList_2.rubr_121,oList_2.id_rubr_121,data.id_sala,oList_2.vale_rubr_121,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_122:=fct_rubrique_analytique(oList_2.rubr_122,oList_2.id_rubr_122,data.id_sala,oList_2.vale_rubr_122,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_123:=fct_rubrique_analytique(oList_2.rubr_123,oList_2.id_rubr_123,data.id_sala,oList_2.vale_rubr_123,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_124:=fct_rubrique_analytique(oList_2.rubr_124,oList_2.id_rubr_124,data.id_sala,oList_2.vale_rubr_124,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_125:=fct_rubrique_analytique(oList_2.rubr_125,oList_2.id_rubr_125,data.id_sala,oList_2.vale_rubr_125,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_126:=fct_rubrique_analytique(oList_2.rubr_126,oList_2.id_rubr_126,data.id_sala,oList_2.vale_rubr_126,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_127:=fct_rubrique_analytique(oList_2.rubr_127,oList_2.id_rubr_127,data.id_sala,oList_2.vale_rubr_127,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_128:=fct_rubrique_analytique(oList_2.rubr_128,oList_2.id_rubr_128,data.id_sala,oList_2.vale_rubr_128,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_129:=fct_rubrique_analytique(oList_2.rubr_129,oList_2.id_rubr_129,data.id_sala,oList_2.vale_rubr_129,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_130:=fct_rubrique_analytique(oList_2.rubr_130,oList_2.id_rubr_130,data.id_sala,oList_2.vale_rubr_130,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_131:=fct_rubrique_analytique(oList_2.rubr_131,oList_2.id_rubr_131,data.id_sala,oList_2.vale_rubr_131,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_132:=fct_rubrique_analytique(oList_2.rubr_132,oList_2.id_rubr_132,data.id_sala,oList_2.vale_rubr_132,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_133:=fct_rubrique_analytique(oList_2.rubr_133,oList_2.id_rubr_133,data.id_sala,oList_2.vale_rubr_133,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_134:=fct_rubrique_analytique(oList_2.rubr_134,oList_2.id_rubr_134,data.id_sala,oList_2.vale_rubr_134,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_135:=fct_rubrique_analytique(oList_2.rubr_135,oList_2.id_rubr_135,data.id_sala,oList_2.vale_rubr_135,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_136:=fct_rubrique_analytique(oList_2.rubr_136,oList_2.id_rubr_136,data.id_sala,oList_2.vale_rubr_136,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_137:=fct_rubrique_analytique(oList_2.rubr_137,oList_2.id_rubr_137,data.id_sala,oList_2.vale_rubr_137,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_138:=fct_rubrique_analytique(oList_2.rubr_138,oList_2.id_rubr_138,data.id_sala,oList_2.vale_rubr_138,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_139:=fct_rubrique_analytique(oList_2.rubr_139,oList_2.id_rubr_139,data.id_sala,oList_2.vale_rubr_139,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_140:=fct_rubrique_analytique(oList_2.rubr_140,oList_2.id_rubr_140,data.id_sala,oList_2.vale_rubr_140,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_141:=fct_rubrique_analytique(oList_2.rubr_141,oList_2.id_rubr_141,data.id_sala,oList_2.vale_rubr_141,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_142:=fct_rubrique_analytique(oList_2.rubr_142,oList_2.id_rubr_142,data.id_sala,oList_2.vale_rubr_142,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_143:=fct_rubrique_analytique(oList_2.rubr_143,oList_2.id_rubr_143,data.id_sala,oList_2.vale_rubr_143,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_144:=fct_rubrique_analytique(oList_2.rubr_144,oList_2.id_rubr_144,data.id_sala,oList_2.vale_rubr_144,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_145:=fct_rubrique_analytique(oList_2.rubr_145,oList_2.id_rubr_145,data.id_sala,oList_2.vale_rubr_145,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_146:=fct_rubrique_analytique(oList_2.rubr_146,oList_2.id_rubr_146,data.id_sala,oList_2.vale_rubr_146,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_147:=fct_rubrique_analytique(oList_2.rubr_147,oList_2.id_rubr_147,data.id_sala,oList_2.vale_rubr_147,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_148:=fct_rubrique_analytique(oList_2.rubr_148,oList_2.id_rubr_148,data.id_sala,oList_2.vale_rubr_148,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_149:=fct_rubrique_analytique(oList_2.rubr_149,oList_2.id_rubr_149,data.id_sala,oList_2.vale_rubr_149,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                   oGeav.rubr_150:=fct_rubrique_analytique(oList_2.rubr_150,oList_2.id_rubr_150,data.id_sala,oList_2.vale_rubr_150,peri.peri_paie,repa_anal.ca,repa_anal.axe);
                else

                   oGeav.repa_anal:=0;
                   oGeav.repa_anal_code:='Pas de répartition analytique';
                   oGeav.repa_anal_pour:=100;

                   oGeav.rubr_01:=fct__rubrique          (oList.rubr_01,oList.id_rubr_01,data.id_sala,oList.vale_rubr_01,peri.peri_paie);
                   oGeav.rubr_02:=fct__rubrique          (oList.rubr_02,oList.id_rubr_02,data.id_sala,oList.vale_rubr_02,peri.peri_paie);
                   oGeav.rubr_03:=fct__rubrique          (oList.rubr_03,oList.id_rubr_03,data.id_sala,oList.vale_rubr_03,peri.peri_paie);
                   oGeav.rubr_04:=fct__rubrique          (oList.rubr_04,oList.id_rubr_04,data.id_sala,oList.vale_rubr_04,peri.peri_paie);
                   oGeav.rubr_05:=fct__rubrique          (oList.rubr_05,oList.id_rubr_05,data.id_sala,oList.vale_rubr_05,peri.peri_paie);
                   oGeav.rubr_06:=fct__rubrique          (oList.rubr_06,oList.id_rubr_06,data.id_sala,oList.vale_rubr_06,peri.peri_paie);
                   oGeav.rubr_07:=fct__rubrique          (oList.rubr_07,oList.id_rubr_07,data.id_sala,oList.vale_rubr_07,peri.peri_paie);
                   oGeav.rubr_08:=fct__rubrique          (oList.rubr_08,oList.id_rubr_08,data.id_sala,oList.vale_rubr_08,peri.peri_paie);
                   oGeav.rubr_09:=fct__rubrique          (oList.rubr_09,oList.id_rubr_09,data.id_sala,oList.vale_rubr_09,peri.peri_paie);
                   oGeav.rubr_10:=fct__rubrique          (oList.rubr_10,oList.id_rubr_10,data.id_sala,oList.vale_rubr_10,peri.peri_paie);
                   oGeav.rubr_11:=fct__rubrique          (oList.rubr_11,oList.id_rubr_11,data.id_sala,oList.vale_rubr_11,peri.peri_paie);
                   oGeav.rubr_12:=fct__rubrique          (oList.rubr_12,oList.id_rubr_12,data.id_sala,oList.vale_rubr_12,peri.peri_paie);
                   oGeav.rubr_13:=fct__rubrique          (oList.rubr_13,oList.id_rubr_13,data.id_sala,oList.vale_rubr_13,peri.peri_paie);
                   oGeav.rubr_14:=fct__rubrique          (oList.rubr_14,oList.id_rubr_14,data.id_sala,oList.vale_rubr_14,peri.peri_paie);
                   oGeav.rubr_15:=fct__rubrique          (oList.rubr_15,oList.id_rubr_15,data.id_sala,oList.vale_rubr_15,peri.peri_paie);
                   oGeav.rubr_16:=fct__rubrique          (oList.rubr_16,oList.id_rubr_16,data.id_sala,oList.vale_rubr_16,peri.peri_paie);
                   oGeav.rubr_17:=fct__rubrique          (oList.rubr_17,oList.id_rubr_17,data.id_sala,oList.vale_rubr_17,peri.peri_paie);
                   oGeav.rubr_18:=fct__rubrique          (oList.rubr_18,oList.id_rubr_18,data.id_sala,oList.vale_rubr_18,peri.peri_paie);
                   oGeav.rubr_19:=fct__rubrique          (oList.rubr_19,oList.id_rubr_19,data.id_sala,oList.vale_rubr_19,peri.peri_paie);
                   oGeav.rubr_20:=fct__rubrique          (oList.rubr_20,oList.id_rubr_20,data.id_sala,oList.vale_rubr_20,peri.peri_paie);
                   oGeav.rubr_21:=fct__rubrique          (oList.rubr_21,oList.id_rubr_21,data.id_sala,oList.vale_rubr_21,peri.peri_paie);
                   oGeav.rubr_22:=fct__rubrique          (oList.rubr_22,oList.id_rubr_22,data.id_sala,oList.vale_rubr_22,peri.peri_paie);
                   oGeav.rubr_23:=fct__rubrique          (oList.rubr_23,oList.id_rubr_23,data.id_sala,oList.vale_rubr_23,peri.peri_paie);
                   oGeav.rubr_24:=fct__rubrique          (oList.rubr_24,oList.id_rubr_24,data.id_sala,oList.vale_rubr_24,peri.peri_paie);
                   oGeav.rubr_25:=fct__rubrique          (oList.rubr_25,oList.id_rubr_25,data.id_sala,oList.vale_rubr_25,peri.peri_paie);
                   oGeav.rubr_26:=fct__rubrique          (oList.rubr_26,oList.id_rubr_26,data.id_sala,oList.vale_rubr_26,peri.peri_paie);
                   oGeav.rubr_27:=fct__rubrique          (oList.rubr_27,oList.id_rubr_27,data.id_sala,oList.vale_rubr_27,peri.peri_paie);
                   oGeav.rubr_28:=fct__rubrique          (oList.rubr_28,oList.id_rubr_28,data.id_sala,oList.vale_rubr_28,peri.peri_paie);
                   oGeav.rubr_29:=fct__rubrique          (oList.rubr_29,oList.id_rubr_29,data.id_sala,oList.vale_rubr_29,peri.peri_paie);
                   oGeav.rubr_30:=fct__rubrique          (oList.rubr_30,oList.id_rubr_30,data.id_sala,oList.vale_rubr_30,peri.peri_paie);
                   oGeav.rubr_31:=fct__rubrique          (oList.rubr_31,oList.id_rubr_31,data.id_sala,oList.vale_rubr_31,peri.peri_paie);
                   oGeav.rubr_32:=fct__rubrique          (oList.rubr_32,oList.id_rubr_32,data.id_sala,oList.vale_rubr_32,peri.peri_paie);
                   oGeav.rubr_33:=fct__rubrique          (oList.rubr_33,oList.id_rubr_33,data.id_sala,oList.vale_rubr_33,peri.peri_paie);
                   oGeav.rubr_34:=fct__rubrique          (oList.rubr_34,oList.id_rubr_34,data.id_sala,oList.vale_rubr_34,peri.peri_paie);
                   oGeav.rubr_35:=fct__rubrique          (oList.rubr_35,oList.id_rubr_35,data.id_sala,oList.vale_rubr_35,peri.peri_paie);
                   oGeav.rubr_36:=fct__rubrique          (oList.rubr_36,oList.id_rubr_36,data.id_sala,oList.vale_rubr_36,peri.peri_paie);
                   oGeav.rubr_37:=fct__rubrique          (oList.rubr_37,oList.id_rubr_37,data.id_sala,oList.vale_rubr_37,peri.peri_paie);
                   oGeav.rubr_38:=fct__rubrique          (oList.rubr_38,oList.id_rubr_38,data.id_sala,oList.vale_rubr_38,peri.peri_paie);
                   oGeav.rubr_39:=fct__rubrique          (oList.rubr_39,oList.id_rubr_39,data.id_sala,oList.vale_rubr_39,peri.peri_paie);
                   oGeav.rubr_40:=fct__rubrique          (oList.rubr_40,oList.id_rubr_40,data.id_sala,oList.vale_rubr_40,peri.peri_paie);
                   oGeav.rubr_41:=fct__rubrique          (oList.rubr_41,oList.id_rubr_41,data.id_sala,oList.vale_rubr_41,peri.peri_paie);
                   oGeav.rubr_42:=fct__rubrique          (oList.rubr_42,oList.id_rubr_42,data.id_sala,oList.vale_rubr_42,peri.peri_paie);
                   oGeav.rubr_43:=fct__rubrique          (oList.rubr_43,oList.id_rubr_43,data.id_sala,oList.vale_rubr_43,peri.peri_paie);
                   oGeav.rubr_44:=fct__rubrique          (oList.rubr_44,oList.id_rubr_44,data.id_sala,oList.vale_rubr_44,peri.peri_paie);
                   oGeav.rubr_45:=fct__rubrique          (oList.rubr_45,oList.id_rubr_45,data.id_sala,oList.vale_rubr_45,peri.peri_paie);
                   oGeav.rubr_46:=fct__rubrique          (oList.rubr_46,oList.id_rubr_46,data.id_sala,oList.vale_rubr_46,peri.peri_paie);
                   oGeav.rubr_47:=fct__rubrique          (oList.rubr_47,oList.id_rubr_47,data.id_sala,oList.vale_rubr_47,peri.peri_paie);
                   oGeav.rubr_48:=fct__rubrique          (oList.rubr_48,oList.id_rubr_48,data.id_sala,oList.vale_rubr_48,peri.peri_paie);
                   oGeav.rubr_49:=fct__rubrique          (oList.rubr_49,oList.id_rubr_49,data.id_sala,oList.vale_rubr_49,peri.peri_paie);
                   oGeav.rubr_50:=fct__rubrique          (oList.rubr_50,oList.id_rubr_50,data.id_sala,oList.vale_rubr_50,peri.peri_paie);

                   oGeav.rubr_51:=fct__rubrique          (oList_2.rubr_51,oList_2.id_rubr_51,data.id_sala,oList_2.vale_rubr_51,peri.peri_paie);
                   oGeav.rubr_52:=fct__rubrique          (oList_2.rubr_52,oList_2.id_rubr_52,data.id_sala,oList_2.vale_rubr_52,peri.peri_paie);
                   oGeav.rubr_53:=fct__rubrique          (oList_2.rubr_53,oList_2.id_rubr_53,data.id_sala,oList_2.vale_rubr_53,peri.peri_paie);
                   oGeav.rubr_54:=fct__rubrique          (oList_2.rubr_54,oList_2.id_rubr_54,data.id_sala,oList_2.vale_rubr_54,peri.peri_paie);
                   oGeav.rubr_55:=fct__rubrique          (oList_2.rubr_55,oList_2.id_rubr_55,data.id_sala,oList_2.vale_rubr_55,peri.peri_paie);
                   oGeav.rubr_56:=fct__rubrique          (oList_2.rubr_56,oList_2.id_rubr_56,data.id_sala,oList_2.vale_rubr_56,peri.peri_paie);
                   oGeav.rubr_57:=fct__rubrique          (oList_2.rubr_57,oList_2.id_rubr_57,data.id_sala,oList_2.vale_rubr_57,peri.peri_paie);
                   oGeav.rubr_58:=fct__rubrique          (oList_2.rubr_58,oList_2.id_rubr_58,data.id_sala,oList_2.vale_rubr_58,peri.peri_paie);
                   oGeav.rubr_59:=fct__rubrique          (oList_2.rubr_59,oList_2.id_rubr_59,data.id_sala,oList_2.vale_rubr_59,peri.peri_paie);
                   oGeav.rubr_60:=fct__rubrique          (oList_2.rubr_60,oList_2.id_rubr_60,data.id_sala,oList_2.vale_rubr_60,peri.peri_paie);
                   oGeav.rubr_61:=fct__rubrique          (oList_2.rubr_61,oList_2.id_rubr_61,data.id_sala,oList_2.vale_rubr_61,peri.peri_paie);
                   oGeav.rubr_62:=fct__rubrique          (oList_2.rubr_62,oList_2.id_rubr_62,data.id_sala,oList_2.vale_rubr_62,peri.peri_paie);
                   oGeav.rubr_63:=fct__rubrique          (oList_2.rubr_63,oList_2.id_rubr_63,data.id_sala,oList_2.vale_rubr_63,peri.peri_paie);
                   oGeav.rubr_64:=fct__rubrique          (oList_2.rubr_64,oList_2.id_rubr_64,data.id_sala,oList_2.vale_rubr_64,peri.peri_paie);
                   oGeav.rubr_65:=fct__rubrique          (oList_2.rubr_65,oList_2.id_rubr_65,data.id_sala,oList_2.vale_rubr_65,peri.peri_paie);
                   oGeav.rubr_66:=fct__rubrique          (oList_2.rubr_66,oList_2.id_rubr_66,data.id_sala,oList_2.vale_rubr_66,peri.peri_paie);
                   oGeav.rubr_67:=fct__rubrique          (oList_2.rubr_67,oList_2.id_rubr_67,data.id_sala,oList_2.vale_rubr_67,peri.peri_paie);
                   oGeav.rubr_68:=fct__rubrique          (oList_2.rubr_68,oList_2.id_rubr_68,data.id_sala,oList_2.vale_rubr_68,peri.peri_paie);
                   oGeav.rubr_69:=fct__rubrique          (oList_2.rubr_69,oList_2.id_rubr_69,data.id_sala,oList_2.vale_rubr_69,peri.peri_paie);
                   oGeav.rubr_70:=fct__rubrique          (oList_2.rubr_70,oList_2.id_rubr_70,data.id_sala,oList_2.vale_rubr_70,peri.peri_paie);
                   oGeav.rubr_71:=fct__rubrique          (oList_2.rubr_71,oList_2.id_rubr_71,data.id_sala,oList_2.vale_rubr_71,peri.peri_paie);
                   oGeav.rubr_72:=fct__rubrique          (oList_2.rubr_72,oList_2.id_rubr_72,data.id_sala,oList_2.vale_rubr_72,peri.peri_paie);
                   oGeav.rubr_73:=fct__rubrique          (oList_2.rubr_73,oList_2.id_rubr_73,data.id_sala,oList_2.vale_rubr_73,peri.peri_paie);
                   oGeav.rubr_74:=fct__rubrique          (oList_2.rubr_74,oList_2.id_rubr_74,data.id_sala,oList_2.vale_rubr_74,peri.peri_paie);
                   oGeav.rubr_75:=fct__rubrique          (oList_2.rubr_75,oList_2.id_rubr_75,data.id_sala,oList_2.vale_rubr_75,peri.peri_paie);
                   oGeav.rubr_76:=fct__rubrique          (oList_2.rubr_76,oList_2.id_rubr_76,data.id_sala,oList_2.vale_rubr_76,peri.peri_paie);
                   oGeav.rubr_77:=fct__rubrique          (oList_2.rubr_77,oList_2.id_rubr_77,data.id_sala,oList_2.vale_rubr_77,peri.peri_paie);
                   oGeav.rubr_78:=fct__rubrique          (oList_2.rubr_78,oList_2.id_rubr_78,data.id_sala,oList_2.vale_rubr_78,peri.peri_paie);
                   oGeav.rubr_79:=fct__rubrique          (oList_2.rubr_79,oList_2.id_rubr_79,data.id_sala,oList_2.vale_rubr_79,peri.peri_paie);
                   oGeav.rubr_80:=fct__rubrique          (oList_2.rubr_80,oList_2.id_rubr_80,data.id_sala,oList_2.vale_rubr_80,peri.peri_paie);
                   oGeav.rubr_81:=fct__rubrique          (oList_2.rubr_81,oList_2.id_rubr_81,data.id_sala,oList_2.vale_rubr_81,peri.peri_paie);
                   oGeav.rubr_82:=fct__rubrique          (oList_2.rubr_82,oList_2.id_rubr_82,data.id_sala,oList_2.vale_rubr_82,peri.peri_paie);
                   oGeav.rubr_83:=fct__rubrique          (oList_2.rubr_83,oList_2.id_rubr_83,data.id_sala,oList_2.vale_rubr_83,peri.peri_paie);
                   oGeav.rubr_84:=fct__rubrique          (oList_2.rubr_84,oList_2.id_rubr_84,data.id_sala,oList_2.vale_rubr_84,peri.peri_paie);
                   oGeav.rubr_85:=fct__rubrique          (oList_2.rubr_85,oList_2.id_rubr_85,data.id_sala,oList_2.vale_rubr_85,peri.peri_paie);
                   oGeav.rubr_86:=fct__rubrique          (oList_2.rubr_86,oList_2.id_rubr_86,data.id_sala,oList_2.vale_rubr_86,peri.peri_paie);
                   oGeav.rubr_87:=fct__rubrique          (oList_2.rubr_87,oList_2.id_rubr_87,data.id_sala,oList_2.vale_rubr_87,peri.peri_paie);
                   oGeav.rubr_88:=fct__rubrique          (oList_2.rubr_88,oList_2.id_rubr_88,data.id_sala,oList_2.vale_rubr_88,peri.peri_paie);
                   oGeav.rubr_89:=fct__rubrique          (oList_2.rubr_89,oList_2.id_rubr_89,data.id_sala,oList_2.vale_rubr_89,peri.peri_paie);
                   oGeav.rubr_90:=fct__rubrique          (oList_2.rubr_90,oList_2.id_rubr_90,data.id_sala,oList_2.vale_rubr_90,peri.peri_paie);
                   oGeav.rubr_91:=fct__rubrique          (oList_2.rubr_91,oList_2.id_rubr_91,data.id_sala,oList_2.vale_rubr_91,peri.peri_paie);
                   oGeav.rubr_92:=fct__rubrique          (oList_2.rubr_92,oList_2.id_rubr_92,data.id_sala,oList_2.vale_rubr_92,peri.peri_paie);
                   oGeav.rubr_93:=fct__rubrique          (oList_2.rubr_93,oList_2.id_rubr_93,data.id_sala,oList_2.vale_rubr_93,peri.peri_paie);
                   oGeav.rubr_94:=fct__rubrique          (oList_2.rubr_94,oList_2.id_rubr_94,data.id_sala,oList_2.vale_rubr_94,peri.peri_paie);
                   oGeav.rubr_95:=fct__rubrique          (oList_2.rubr_95,oList_2.id_rubr_95,data.id_sala,oList_2.vale_rubr_95,peri.peri_paie);
                   oGeav.rubr_96:=fct__rubrique          (oList_2.rubr_96,oList_2.id_rubr_96,data.id_sala,oList_2.vale_rubr_96,peri.peri_paie);
                   oGeav.rubr_97:=fct__rubrique          (oList_2.rubr_97,oList_2.id_rubr_97,data.id_sala,oList_2.vale_rubr_97,peri.peri_paie);
                   oGeav.rubr_98:=fct__rubrique          (oList_2.rubr_98,oList_2.id_rubr_98,data.id_sala,oList_2.vale_rubr_98,peri.peri_paie);
                   oGeav.rubr_99:=fct__rubrique          (oList_2.rubr_99,oList_2.id_rubr_99,data.id_sala,oList_2.vale_rubr_99,peri.peri_paie);
                   oGeav.rubr_100:=fct__rubrique          (oList_2.rubr_100,oList_2.id_rubr_100,data.id_sala,oList_2.vale_rubr_100,peri.peri_paie);
                   oGeav.rubr_101:=fct__rubrique          (oList_2.rubr_101,oList_2.id_rubr_101,data.id_sala,oList_2.vale_rubr_101,peri.peri_paie);
                   oGeav.rubr_102:=fct__rubrique          (oList_2.rubr_102,oList_2.id_rubr_102,data.id_sala,oList_2.vale_rubr_102,peri.peri_paie);
                   oGeav.rubr_103:=fct__rubrique          (oList_2.rubr_103,oList_2.id_rubr_103,data.id_sala,oList_2.vale_rubr_103,peri.peri_paie);
                   oGeav.rubr_104:=fct__rubrique          (oList_2.rubr_104,oList_2.id_rubr_104,data.id_sala,oList_2.vale_rubr_104,peri.peri_paie);
                   oGeav.rubr_105:=fct__rubrique          (oList_2.rubr_105,oList_2.id_rubr_105,data.id_sala,oList_2.vale_rubr_105,peri.peri_paie);
                   oGeav.rubr_106:=fct__rubrique          (oList_2.rubr_106,oList_2.id_rubr_106,data.id_sala,oList_2.vale_rubr_106,peri.peri_paie);
                   oGeav.rubr_107:=fct__rubrique          (oList_2.rubr_107,oList_2.id_rubr_107,data.id_sala,oList_2.vale_rubr_107,peri.peri_paie);
                   oGeav.rubr_108:=fct__rubrique          (oList_2.rubr_108,oList_2.id_rubr_108,data.id_sala,oList_2.vale_rubr_108,peri.peri_paie);
                   oGeav.rubr_109:=fct__rubrique          (oList_2.rubr_109,oList_2.id_rubr_109,data.id_sala,oList_2.vale_rubr_109,peri.peri_paie);
                   oGeav.rubr_110:=fct__rubrique          (oList_2.rubr_110,oList_2.id_rubr_110,data.id_sala,oList_2.vale_rubr_110,peri.peri_paie);
                   oGeav.rubr_111:=fct__rubrique          (oList_2.rubr_111,oList_2.id_rubr_111,data.id_sala,oList_2.vale_rubr_111,peri.peri_paie);
                   oGeav.rubr_112:=fct__rubrique          (oList_2.rubr_112,oList_2.id_rubr_112,data.id_sala,oList_2.vale_rubr_112,peri.peri_paie);
                   oGeav.rubr_113:=fct__rubrique          (oList_2.rubr_113,oList_2.id_rubr_113,data.id_sala,oList_2.vale_rubr_113,peri.peri_paie);
                   oGeav.rubr_114:=fct__rubrique          (oList_2.rubr_114,oList_2.id_rubr_114,data.id_sala,oList_2.vale_rubr_114,peri.peri_paie);
                   oGeav.rubr_115:=fct__rubrique          (oList_2.rubr_115,oList_2.id_rubr_115,data.id_sala,oList_2.vale_rubr_115,peri.peri_paie);
                   oGeav.rubr_116:=fct__rubrique          (oList_2.rubr_116,oList_2.id_rubr_116,data.id_sala,oList_2.vale_rubr_116,peri.peri_paie);
                   oGeav.rubr_117:=fct__rubrique          (oList_2.rubr_117,oList_2.id_rubr_117,data.id_sala,oList_2.vale_rubr_117,peri.peri_paie);
                   oGeav.rubr_118:=fct__rubrique          (oList_2.rubr_118,oList_2.id_rubr_118,data.id_sala,oList_2.vale_rubr_118,peri.peri_paie);
                   oGeav.rubr_119:=fct__rubrique          (oList_2.rubr_119,oList_2.id_rubr_119,data.id_sala,oList_2.vale_rubr_119,peri.peri_paie);
                   oGeav.rubr_120:=fct__rubrique          (oList_2.rubr_120,oList_2.id_rubr_120,data.id_sala,oList_2.vale_rubr_120,peri.peri_paie);
                   oGeav.rubr_121:=fct__rubrique          (oList_2.rubr_121,oList_2.id_rubr_121,data.id_sala,oList_2.vale_rubr_121,peri.peri_paie);
                   oGeav.rubr_122:=fct__rubrique          (oList_2.rubr_122,oList_2.id_rubr_122,data.id_sala,oList_2.vale_rubr_122,peri.peri_paie);
                   oGeav.rubr_123:=fct__rubrique          (oList_2.rubr_123,oList_2.id_rubr_123,data.id_sala,oList_2.vale_rubr_123,peri.peri_paie);
                   oGeav.rubr_124:=fct__rubrique          (oList_2.rubr_124,oList_2.id_rubr_124,data.id_sala,oList_2.vale_rubr_124,peri.peri_paie);
                   oGeav.rubr_125:=fct__rubrique          (oList_2.rubr_125,oList_2.id_rubr_125,data.id_sala,oList_2.vale_rubr_125,peri.peri_paie);
                   oGeav.rubr_126:=fct__rubrique          (oList_2.rubr_126,oList_2.id_rubr_126,data.id_sala,oList_2.vale_rubr_126,peri.peri_paie);
                   oGeav.rubr_127:=fct__rubrique          (oList_2.rubr_127,oList_2.id_rubr_127,data.id_sala,oList_2.vale_rubr_127,peri.peri_paie);
                   oGeav.rubr_128:=fct__rubrique          (oList_2.rubr_128,oList_2.id_rubr_128,data.id_sala,oList_2.vale_rubr_128,peri.peri_paie);
                   oGeav.rubr_129:=fct__rubrique          (oList_2.rubr_129,oList_2.id_rubr_129,data.id_sala,oList_2.vale_rubr_129,peri.peri_paie);
                   oGeav.rubr_130:=fct__rubrique          (oList_2.rubr_130,oList_2.id_rubr_130,data.id_sala,oList_2.vale_rubr_130,peri.peri_paie);
                   oGeav.rubr_131:=fct__rubrique          (oList_2.rubr_131,oList_2.id_rubr_131,data.id_sala,oList_2.vale_rubr_131,peri.peri_paie);
                   oGeav.rubr_132:=fct__rubrique          (oList_2.rubr_132,oList_2.id_rubr_132,data.id_sala,oList_2.vale_rubr_132,peri.peri_paie);
                   oGeav.rubr_133:=fct__rubrique          (oList_2.rubr_133,oList_2.id_rubr_133,data.id_sala,oList_2.vale_rubr_133,peri.peri_paie);
                   oGeav.rubr_134:=fct__rubrique          (oList_2.rubr_134,oList_2.id_rubr_134,data.id_sala,oList_2.vale_rubr_134,peri.peri_paie);
                   oGeav.rubr_135:=fct__rubrique          (oList_2.rubr_135,oList_2.id_rubr_135,data.id_sala,oList_2.vale_rubr_135,peri.peri_paie);
                   oGeav.rubr_136:=fct__rubrique          (oList_2.rubr_136,oList_2.id_rubr_136,data.id_sala,oList_2.vale_rubr_136,peri.peri_paie);
                   oGeav.rubr_137:=fct__rubrique          (oList_2.rubr_137,oList_2.id_rubr_137,data.id_sala,oList_2.vale_rubr_137,peri.peri_paie);
                   oGeav.rubr_138:=fct__rubrique          (oList_2.rubr_138,oList_2.id_rubr_138,data.id_sala,oList_2.vale_rubr_138,peri.peri_paie);
                   oGeav.rubr_139:=fct__rubrique          (oList_2.rubr_139,oList_2.id_rubr_139,data.id_sala,oList_2.vale_rubr_139,peri.peri_paie);
                   oGeav.rubr_140:=fct__rubrique          (oList_2.rubr_140,oList_2.id_rubr_140,data.id_sala,oList_2.vale_rubr_140,peri.peri_paie);
                   oGeav.rubr_141:=fct__rubrique          (oList_2.rubr_141,oList_2.id_rubr_141,data.id_sala,oList_2.vale_rubr_141,peri.peri_paie);
                   oGeav.rubr_142:=fct__rubrique          (oList_2.rubr_142,oList_2.id_rubr_142,data.id_sala,oList_2.vale_rubr_142,peri.peri_paie);
                   oGeav.rubr_143:=fct__rubrique          (oList_2.rubr_143,oList_2.id_rubr_143,data.id_sala,oList_2.vale_rubr_143,peri.peri_paie);
                   oGeav.rubr_144:=fct__rubrique          (oList_2.rubr_144,oList_2.id_rubr_144,data.id_sala,oList_2.vale_rubr_144,peri.peri_paie);
                   oGeav.rubr_145:=fct__rubrique          (oList_2.rubr_145,oList_2.id_rubr_145,data.id_sala,oList_2.vale_rubr_145,peri.peri_paie);
                   oGeav.rubr_146:=fct__rubrique          (oList_2.rubr_146,oList_2.id_rubr_146,data.id_sala,oList_2.vale_rubr_146,peri.peri_paie);
                   oGeav.rubr_147:=fct__rubrique          (oList_2.rubr_147,oList_2.id_rubr_147,data.id_sala,oList_2.vale_rubr_147,peri.peri_paie);
                   oGeav.rubr_148:=fct__rubrique          (oList_2.rubr_148,oList_2.id_rubr_148,data.id_sala,oList_2.vale_rubr_148,peri.peri_paie);
                   oGeav.rubr_149:=fct__rubrique          (oList_2.rubr_149,oList_2.id_rubr_149,data.id_sala,oList_2.vale_rubr_149,peri.peri_paie);
                   oGeav.rubr_150:=fct__rubrique          (oList_2.rubr_150,oList_2.id_rubr_150,data.id_sala,oList_2.vale_rubr_150,peri.peri_paie);
                end if;
                oEdit.adre_mail       := '1';
                if rv_S_PAYS_GENT_F.exists(data.code_iso_pays_nati) then
                  if rv_S_PAYS_GENT_F(data.code_iso_pays_nati) is not null then
                    oEDIT.nati:=rv_S_PAYS_GENT_F(data.code_iso_pays_nati);
                  else
                    oEDIT.nati:=rv_S_PAYS(data.code_iso_pays_nati);
                  end if;
                elsif data.code_iso_pays_nati is null then
                   oEDIT.nati:=rv_S_PAYS_GENT_F('FR');
                else
                  oEDIT.nati:=null;
                end if;

                if rv_S_PAYS.exists(data.code_iso_adre_pays) then
                   oGeav.adre_pays:=rv_S_PAYS(data.code_iso_adre_pays);
                else
                   oGeav.adre_pays:=null;
                end if;
                if rv_S_PAYS.exists(data.code_iso_pays_nati) then
                   oEdit.code_iso_pays_nati:=rv_S_PAYS(data.code_iso_pays_nati);
                elsif data.code_iso_pays_nati is null then
                   oEdit.code_iso_pays_nati:=rv_S_PAYS('FR');
                else
                   oEdit.code_iso_pays_nati:=null;
                end if;

                oGeav.adre_pays:=data.code_iso_adre_pays;

                oGeav.cons_01:=fct__constante( oList.cons_01 , oList.code_cons_01 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_01 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_02:=fct__constante( oList.cons_02 , oList.code_cons_02 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_02 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_03:=fct__constante( oList.cons_03 , oList.code_cons_03 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_03 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_04:=fct__constante( oList.cons_04 , oList.code_cons_04 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_04 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_05:=fct__constante( oList.cons_05 , oList.code_cons_05 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_05 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_06:=fct__constante( oList.cons_06 , oList.code_cons_06 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_06 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_07:=fct__constante( oList.cons_07 , oList.code_cons_07 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_07 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_08:=fct__constante( oList.cons_08 , oList.code_cons_08 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_08 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_09:=fct__constante( oList.cons_09 , oList.code_cons_09 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_09 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_10:=fct__constante( oList.cons_10 , oList.code_cons_10 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_10 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_11:=fct__constante( oList.cons_11 , oList.code_cons_11 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_11 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_12:=fct__constante( oList.cons_12 , oList.code_cons_12 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_12 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_13:=fct__constante( oList.cons_13 , oList.code_cons_13 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_13 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_14:=fct__constante( oList.cons_14 , oList.code_cons_14 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_14 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_15:=fct__constante( oList.cons_15 , oList.code_cons_15 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_15 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_16:=fct__constante( oList.cons_16 , oList.code_cons_16 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_16 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_17:=fct__constante( oList.cons_17 , oList.code_cons_17 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_17 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_18:=fct__constante( oList.cons_18 , oList.code_cons_18 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_18 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_19:=fct__constante( oList.cons_19 , oList.code_cons_19 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_19 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_20:=fct__constante( oList.cons_20 , oList.code_cons_20 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList.cons_repa_20 , iLOOP_ANAL, data.id_etab,data.affi_rtt,data.date_depa_bull );

                oGeav.cons_21:=fct__constante( oList_2.cons_21 , oList_2.code_cons_21 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_21 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_22:=fct__constante( oList_2.cons_22 , oList_2.code_cons_22 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_22 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_23:=fct__constante( oList_2.cons_23 , oList_2.code_cons_23 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_23 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_24:=fct__constante( oList_2.cons_24 , oList_2.code_cons_24 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_24 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_25:=fct__constante( oList_2.cons_25 , oList_2.code_cons_25 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_25 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_26:=fct__constante( oList_2.cons_26 , oList_2.code_cons_26 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_26 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_27:=fct__constante( oList_2.cons_27 , oList_2.code_cons_27 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_27 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_28:=fct__constante( oList_2.cons_28 , oList_2.code_cons_28 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_28 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_29:=fct__constante( oList_2.cons_29 , oList_2.code_cons_29 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_29 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_30:=fct__constante( oList_2.cons_30 , oList_2.code_cons_30 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_30 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_31:=fct__constante( oList_2.cons_31 , oList_2.code_cons_31 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_31 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_32:=fct__constante( oList_2.cons_32 , oList_2.code_cons_32 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_32 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_33:=fct__constante( oList_2.cons_33 , oList_2.code_cons_33 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_33 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_34:=fct__constante( oList_2.cons_34 , oList_2.code_cons_34 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_34 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_35:=fct__constante( oList_2.cons_35 , oList_2.code_cons_35 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_35 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_36:=fct__constante( oList_2.cons_36 , oList_2.code_cons_36 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_36 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_37:=fct__constante( oList_2.cons_37 , oList_2.code_cons_37 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_37 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_38:=fct__constante( oList_2.cons_38 , oList_2.code_cons_38 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_38 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_39:=fct__constante( oList_2.cons_39 , oList_2.code_cons_39 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_39 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_40:=fct__constante( oList_2.cons_40 , oList_2.code_cons_40 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_40 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_41:=fct__constante( oList_2.cons_41 , oList_2.code_cons_41 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_41 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_42:=fct__constante( oList_2.cons_42 , oList_2.code_cons_42 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_42 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_43:=fct__constante( oList_2.cons_43 , oList_2.code_cons_43 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_43 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_44:=fct__constante( oList_2.cons_44 , oList_2.code_cons_44 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_44 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_45:=fct__constante( oList_2.cons_45 , oList_2.code_cons_45 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_45 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_46:=fct__constante( oList_2.cons_46 , oList_2.code_cons_46 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_46 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_47:=fct__constante( oList_2.cons_47 , oList_2.code_cons_47 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_47 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_48:=fct__constante( oList_2.cons_48 , oList_2.code_cons_48 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_48 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_49:=fct__constante( oList_2.cons_49 , oList_2.code_cons_49 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_49 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );
                oGeav.cons_50:=fct__constante( oList_2.cons_50 , oList_2.code_cons_50 , data.id_sala , peri.peri_paie , repa_anal.pour_affe , oList_2.cons_repa_50 , iLOOP_ANAL ,data.id_etab,data.affi_rtt,data.date_depa_bull );

                oEdit.profil_paye_cp          :=fct__prof_libe(soci.id_soci,'CP'          ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_rtt         :=fct__prof_libe(soci.id_soci,'RTT'         ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_dif         :=fct__prof_libe(soci.id_soci,'DIF'         ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_prov_cet    :=fct__prof_libe(soci.id_soci,'PROV_CET'    ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_prov_inte   :=fct__prof_libe(soci.id_soci,'PROV_INTE'   ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_prov_part   :=fct__prof_libe(soci.id_soci,'PROV_PART'   ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_13mo        :=fct__prof_libe(soci.id_soci,'13MO'        ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_14mo        :=fct__prof_libe(soci.id_soci,'14MO'        ,data.id_sala,peri.peri_paie);
                oEdit.prof_15mo               :=fct__prof_libe(soci.id_soci,'15MO'        ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_prim_vaca_01:=fct__prof_libe(soci.id_soci,'PRIM_VACA_01',data.id_sala,peri.peri_paie);
                oEdit.profil_paye_prim_vaca_02:=fct__prof_libe(soci.id_soci,'PRIM_VACA_02',data.id_sala,peri.peri_paie);
                oEdit.profil_paye_hs_conv     :=fct__prof_libe(soci.id_soci,'HS_CONV'     ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_heur_equi   :=fct__prof_libe(soci.id_soci,'HEUR_EQUI'   ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_deca_fisc   :=fct__prof_libe(soci.id_soci,'DECA_FISC'   ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_tepa        :=fct__prof_libe(soci.id_soci,'TEPA'        ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_affi_bull   :=fct__prof_libe(soci.id_soci,'AFFI_BULL'   ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_forf        :=fct__prof_libe(soci.id_soci,'FORF'        ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_depa        :=fct__prof_libe(soci.id_soci,'DEPA'        ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_rein_frai   :=fct__prof_libe(soci.id_soci,'REIN_FRAI'   ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_ndf         :=fct__prof_libe(soci.id_soci,'NDF'         ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_acce_sala   :=fct__prof_libe(soci.id_soci,'ACCE_SALA'   ,data.id_sala,peri.peri_paie);
                oEdit.prof_temp_libe          :=fct__prof_libe(soci.id_soci,'POIN'        ,data.id_sala,peri.peri_paie);
                oEdit.profil_paye_tele_trav   :=fct__prof_libe(soci.id_soci,'TELE_TRAV'   ,data.id_sala,peri.peri_paie);

                select
                  substr(case
                         when count(0)=2 then min(libe)||' et '||max(libe)
                         else listagg(libe, ', ')  within group (order by libe)
                         end,1,4000)
                into
                   oEdit.profil_paye_plan
                from ps_profil_planning
                where id_prof_plan in (select * from table(fct_ps_profil_planning_sala_h(data.id_sala,peri.peri_paie_d)));

                --On récupère plus la valeurs depuis salarie.hora_mens_fich, hist_salarie.hora_mens_fich, /so.HORA_COLL_MENS
                fHORAIRE           := fct_hc_sala_nume(data.id_sala, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'HORAIRE');

                fHORAIRE_MENS_ETAB := fct_hc_etab_nume(data.id_etab, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'HORAISOC');
                if fHORAIRE_MENS_ETAB = 0 then 
                   fHORAIRE_MENS_ETAB := null;
                end if;

                fHORAIRE_MENS_SOCI := fct_hc_soci_nume(iID_SOCI, to_char (peri.peri_paie, 'DD/MM/YYYY'), 'HORAISOC');
                if fHORAIRE_MENS_SOCI = 0 then 
                   fHORAIRE_MENS_SOCI := null;
                end if;

                vETP_CCN51    := to_char(round(fHORAIRE/coalesce (fHORAIRE_MENS_ETAB, fHORAIRE_MENS_SOCI, 151.67), 2), '0.00');

                oEdit.etp_ccn51                :=parse_float(vETP_CCN51);
                oEdit.ccn51_coef_acca          :=parse_float(data.ccn51_coef_acca     );
                oEdit.ccn51_coef_dipl          :=parse_float(data.ccn51_coef_dipl     );
                oEdit.ccn51_coef_enca          :=parse_float(data.ccn51_coef_enca     );
                oEdit.ccn51_coef_fonc          :=parse_float(data.ccn51_coef_fonc     );
                oEdit.ccn51_coef_meti          :=parse_float(data.ccn51_coef_meti     );
                oEdit.ccn51_coef_recl          :=parse_float(data.ccn51_coef_recl     );
                oEdit.ccn51_coef_spec          :=parse_float(data.ccn51_coef_spec     );
                oEdit.ccn5166_coef_refe        :=parse_float(data.ccn5166_coef_refe   );
                oEdit.ccn66_proc_coef_refe     :=parse_float(data.ccn66_proc_coef_refe);

                if rv_S_EMPLOIS_51.exists(data.ccn51_id_empl_conv) then
                   oEdit.ccn51_id_empl_conv    :=rv_S_EMPLOIS_51(data.ccn51_id_empl_conv);
                else
                   oEdit.ccn51_id_empl_conv    :=null;
                end if;
                oEdit.ccn66_cate_conv          :=data.ccn66_cate_conv          ;
                oEdit.ccn66_date_chan_coef     :=data.ccn66_date_chan_coef     ;
                oEdit.ccn66_empl_conv          :=data.ccn66_empl_conv          ;
                if parse_int(data.ccn66_empl_conv) is not null then
                  begin
                    select libe into vLIBE_EMPL_CONV from EMPL_CONV_CCU_FHP where id_empl = data.ccn66_empl_conv;
                  exception
                  when no_data_found then
                    vLIBE_EMPL_CONV := '';
                  end;
                else
                  vLIBE_EMPL_CONV := '';
                end if;
                oEdit.ccn66_libe_empl_conv     :=vLIBE_EMPL_CONV               ;
                oEdit.ccn66_fili_conv          :=data.ccn66_fili_conv          ;
                oEdit.saho_boo                 :=data.saho_boo                 ;
                oEdit.ccn66_prec_date_chan_coef:=data.ccn66_prec_date_chan_coef;
                if data.ccn66_regi='I' then
                   oEdit.ccn66_regi            :='Oui';
                else
                   oEdit.ccn66_regi            :='Non';
                end if;


                oEdit.calc_auto_inde_cong_prec := fct__libe_spec_inte_vaca_pigi(iID_SOCI,iBULLMOD,data.calc_auto_inde_cong_prec);

                oGeav.mutu_soum_txde_01 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_TAUX',data.CODE_MUTU_SOUM_TAUX_01) ;
                oGeav.mutu_soum_txde_02 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_TAUX',data.CODE_MUTU_SOUM_TAUX_02) ;
                oGeav.mutu_soum_txde_03 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_TAUX',data.CODE_MUTU_SOUM_TAUX_03) ;
                oGeav.mutu_soum_txde_04 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_TAUX',data.CODE_MUTU_SOUM_TAUX_04) ;
                oGeav.mutu_soum_txde_05 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_TAUX',data.CODE_MUTU_SOUM_TAUX_05) ;

                oGeav.mutu_soum_mtde_01 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_MONT',data.CODE_MUTU_SOUM_MONT_01) ;
                oGeav.mutu_soum_mtde_02 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_MONT',data.CODE_MUTU_SOUM_MONT_02) ;
                oGeav.mutu_soum_mtde_03 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_MONT',data.CODE_MUTU_SOUM_MONT_03) ;
                oGeav.mutu_soum_mtde_04 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_MONT',data.CODE_MUTU_SOUM_MONT_04) ;
                oGeav.mutu_soum_mtde_05 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_MONT',data.CODE_MUTU_SOUM_MONT_05) ;
                oGeav.mutu_soum_mtde_06 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_MONT',data.CODE_MUTU_SOUM_MONT_06) ;
                oGeav.mutu_soum_mtde_07 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_MONT',data.CODE_MUTU_SOUM_MONT_07) ;
                oGeav.mutu_soum_mtde_08 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_MONT',data.CODE_MUTU_SOUM_MONT_08) ;
                oGeav.mutu_soum_mtde_09 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_MONT',data.CODE_MUTU_SOUM_MONT_09) ;
                oGeav.mutu_soum_mtde_10 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'SOUM_MONT',data.CODE_MUTU_SOUM_MONT_10) ;

                oGeav.mutu_noso_txde_01 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'NOSO_TAUX',data.CODE_MUTU_NOSO_TAUX_01) ;
                oGeav.mutu_noso_txde_02 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'NOSO_TAUX',data.CODE_MUTU_NOSO_TAUX_02) ;
                oGeav.mutu_noso_txde_03 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'NOSO_TAUX',data.CODE_MUTU_NOSO_TAUX_03) ;

                oGeav.mutu_noso_mtde_01 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'NOSO_MONT',data.CODE_MUTU_NOSO_MONT_01) ;
                oGeav.mutu_noso_mtde_02 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'NOSO_MONT',data.CODE_MUTU_NOSO_MONT_02) ;
                oGeav.mutu_noso_mtde_03 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'NOSO_MONT',data.CODE_MUTU_NOSO_MONT_03) ;
                oGeav.mutu_noso_mtde_04 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'NOSO_MONT',data.CODE_MUTU_NOSO_MONT_04) ;
                oGeav.mutu_noso_mtde_05 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'NOSO_MONT',data.CODE_MUTU_NOSO_MONT_05) ;
                oGeav.mutu_noso_mtde_06 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'NOSO_MONT',data.CODE_MUTU_NOSO_MONT_06) ;
                oGeav.mutu_noso_mtde_07 := fct__mutuelle_desc(soci.id_soci,peri.peri_paie,'NOSO_MONT',data.CODE_MUTU_NOSO_MONT_07) ;

                oGeav.calc_01:=fct__calcul(oList.calc_01_operande_1,oList.calc_01_operateur,oList.calc_01_operande_2,oList.calc_01_mult,oGeav);
                oGeav.calc_02:=fct__calcul(oList.calc_02_operande_1,oList.calc_02_operateur,oList.calc_02_operande_2,oList.calc_02_mult,oGeav);
                oGeav.calc_03:=fct__calcul(oList.calc_03_operande_1,oList.calc_03_operateur,oList.calc_03_operande_2,oList.calc_03_mult,oGeav);
                oGeav.calc_04:=fct__calcul(oList.calc_04_operande_1,oList.calc_04_operateur,oList.calc_04_operande_2,oList.calc_04_mult,oGeav);
                oGeav.calc_05:=fct__calcul(oList.calc_05_operande_1,oList.calc_05_operateur,oList.calc_05_operande_2,oList.calc_05_mult,oGeav);
                oGeav.calc_06:=fct__calcul(oList.calc_06_operande_1,oList.calc_06_operateur,oList.calc_06_operande_2,oList.calc_06_mult,oGeav);
                oGeav.calc_07:=fct__calcul(oList.calc_07_operande_1,oList.calc_07_operateur,oList.calc_07_operande_2,oList.calc_07_mult,oGeav);
                oGeav.calc_08:=fct__calcul(oList.calc_08_operande_1,oList.calc_08_operateur,oList.calc_08_operande_2,oList.calc_08_mult,oGeav);
                oGeav.calc_09:=fct__calcul(oList.calc_09_operande_1,oList.calc_09_operateur,oList.calc_09_operande_2,oList.calc_09_mult,oGeav);
                oGeav.calc_10:=fct__calcul(oList.calc_10_operande_1,oList.calc_10_operateur,oList.calc_10_operande_2,oList.calc_10_mult,oGeav);
                oGeav.calc_11:=fct__calcul(oList.calc_11_operande_1,oList.calc_11_operateur,oList.calc_11_operande_2,oList.calc_11_mult,oGeav);
                oGeav.calc_12:=fct__calcul(oList.calc_12_operande_1,oList.calc_12_operateur,oList.calc_12_operande_2,oList.calc_12_mult,oGeav);
                oGeav.calc_13:=fct__calcul(oList.calc_13_operande_1,oList.calc_13_operateur,oList.calc_13_operande_2,oList.calc_13_mult,oGeav);
                oGeav.calc_14:=fct__calcul(oList.calc_14_operande_1,oList.calc_14_operateur,oList.calc_14_operande_2,oList.calc_14_mult,oGeav);
                oGeav.calc_15:=fct__calcul(oList.calc_15_operande_1,oList.calc_15_operateur,oList.calc_15_operande_2,oList.calc_15_mult,oGeav);
                oGeav.calc_16:=fct__calcul(oList.calc_16_operande_1,oList.calc_16_operateur,oList.calc_16_operande_2,oList.calc_16_mult,oGeav);
                oGeav.calc_17:=fct__calcul(oList.calc_17_operande_1,oList.calc_17_operateur,oList.calc_17_operande_2,oList.calc_17_mult,oGeav);
                oGeav.calc_18:=fct__calcul(oList.calc_18_operande_1,oList.calc_18_operateur,oList.calc_18_operande_2,oList.calc_18_mult,oGeav);
                oGeav.calc_19:=fct__calcul(oList.calc_19_operande_1,oList.calc_19_operateur,oList.calc_19_operande_2,oList.calc_19_mult,oGeav);
                oGeav.calc_20:=fct__calcul(oList.calc_20_operande_1,oList.calc_20_operateur,oList.calc_20_operande_2,oList.calc_20_mult,oGeav);

                begin
                  select max(libe_sanc) into vDIPL from RH_FORM_SALA_SANC where type_sanc='DIPL' and id_sala=data.id_sala and id_soci=soci.id_soci and date_debu=(select max(date_debu) from RH_FORM_SALA_SANC where type_sanc='DIPL' and id_sala=data.id_sala and id_soci=soci.id_soci and date_debu <= last_day(peri.peri_paie));
                exception
                when NO_DATA_FOUND then
                  vDIPL := '';
                end;
                if vDIPL is null then
                  vDIPL := '';
                end if;

                -- insertion détail
                insert into pers_edit_gestion_avancee (
                   id_soci                   ,
                   id_logi                   ,
                   id_list                   ,
                   id_para                   ,
                   peri                      ,
                   lign                      ,
                   id_sala                   ,
                   repa_anal                 ,
                   repa_anal_code            ,
                   repa_anal_pour            ,
                   nom                       ,
                   pren                      ,
                   nom_jeun_fill             ,
                   titr                      ,
                   matr                      ,
                   reac_regu                 ,
                   serv                      ,
                   depa                      ,
                   id_cate                   ,
                   cate_prof                 ,
                   conv_coll                 ,
                   id_etab                   ,
                   libe_etab                 ,
                   libe_etab_cour            ,
                   empl                      ,
                   empl_type                 ,
                   meti                      ,
                   fami_meti                 ,
                   fami_meti_hier            ,
                   code_empl                 ,
                   code_cate                 ,
                   libe_empl_gene            ,
                   coef                      ,
                   sire_etab                 ,
                   dipl                      ,
                   nive_form_educ_nati       ,
                   code_unit                 ,
                   code_regr_fich_comp_etab  ,
                   nive                      ,
                   eche                      ,
                   grou_conv                 ,
                   posi                      ,
                   indi                      ,
                   cota                      ,
                   clas                      ,
                   seui                      ,
                   pali                      ,
                   grad                      ,
                   degr                      ,
                   fili                      ,
                   sect_prof                 ,
                   comp_brut                 ,
                   nume_comp_brut            ,
                   libe_comp_brut            ,
                   comp_paye                 ,
                   nume_comp_paye            ,
                   libe_comp_paye            ,
                   comp_acom                 ,
                   nume_secu                 ,
                   date_emba                 ,
                   date_depa                 ,
                   date_anci                 ,
                   date_dela_prev            ,
                   date_nais                 ,
                   date_acci_trav            ,
                   comm_nais                 ,
                   depa_nais                 ,
                   pays_nais                 ,
                   trav_hand                 ,
                   date_debu_coto            ,
                   date_fin_coto             ,
                   taux_inva                 ,
                   cong_rest_mois            ,
                   evol_remu_supp_coti       ,
                   nomb_tr_calc_peri         ,
                   vale_spec_tr              ,
                   cong_pris_anne            ,
                   mutu_soum_txde_01         ,
                   mutu_soum_txde_02         ,
                   mutu_soum_txde_03         ,
                   mutu_soum_txde_04         ,
                   mutu_soum_txde_05         ,
                   mutu_soum_mtde_01         ,
                   mutu_soum_mtde_02         ,
                   mutu_soum_mtde_03         ,
                   mutu_soum_mtde_04         ,
                   mutu_soum_mtde_05         ,
                   mutu_soum_mtde_06         ,
                   mutu_soum_mtde_07         ,
                   mutu_soum_mtde_08         ,
                   mutu_soum_mtde_09         ,
                   mutu_soum_mtde_10         ,
                   mutu_noso_txde_01         ,
                   mutu_noso_txde_02         ,
                   mutu_noso_txde_03         ,
                   mutu_noso_mtde_01         ,
                   mutu_noso_mtde_02         ,
                   mutu_noso_mtde_03         ,
                   mutu_noso_mtde_04         ,
                   mutu_noso_mtde_05         ,
                   mutu_noso_mtde_06         ,
                   mutu_noso_mtde_07         ,
                   code_anal_01              ,
                   code_anal_02              ,
                   code_anal_03              ,
                   code_anal_04              ,
                   code_anal_05              ,
                   code_anal_06              ,
                   code_anal_07              ,
                   code_anal_08              ,
                   code_anal_09              ,
                   code_anal_10              ,
                   code_anal_11              ,
                   code_anal_12              ,
                   code_anal_13              ,
                   code_anal_14              ,
                   code_anal_15              ,
                   code_anal_16              ,
                   code_anal_17              ,
                   code_anal_18              ,
                   code_anal_19              ,
                   code_anal_20              ,
                   plan1_code_anal_01        ,
                   plan1_code_anal_02        ,
                   plan1_code_anal_03        ,
                   plan1_code_anal_04        ,
                   plan1_code_anal_05        ,
                   plan1_code_anal_06        ,
                   plan1_code_anal_07        ,
                   plan1_code_anal_08        ,
                   plan1_code_anal_09        ,
                   plan1_code_anal_10        ,
                   plan1_code_anal_11        ,
                   plan1_code_anal_12        ,
                   plan1_code_anal_13        ,
                   plan1_code_anal_14        ,
                   plan1_code_anal_15        ,
                   plan1_code_anal_16        ,
                   plan1_code_anal_17        ,
                   plan1_code_anal_18        ,
                   plan1_code_anal_19        ,
                   plan1_code_anal_20        ,
                   plan1_pour_affe_anal_01   ,
                   plan1_pour_affe_anal_02   ,
                   plan1_pour_affe_anal_03   ,
                   plan1_pour_affe_anal_04   ,
                   plan1_pour_affe_anal_05   ,
                   plan1_pour_affe_anal_06   ,
                   plan1_pour_affe_anal_07   ,
                   plan1_pour_affe_anal_08   ,
                   plan1_pour_affe_anal_09   ,
                   plan1_pour_affe_anal_10   ,
                   plan1_pour_affe_anal_11   ,
                   plan1_pour_affe_anal_12   ,
                   plan1_pour_affe_anal_13   ,
                   plan1_pour_affe_anal_14   ,
                   plan1_pour_affe_anal_15   ,
                   plan1_pour_affe_anal_16   ,
                   plan1_pour_affe_anal_17   ,
                   plan1_pour_affe_anal_18   ,
                   plan1_pour_affe_anal_19   ,
                   plan1_pour_affe_anal_20   ,
                   plan2_code_anal_01        ,
                   plan2_code_anal_02        ,
                   plan2_code_anal_03        ,
                   plan2_code_anal_04        ,
                   plan2_code_anal_05        ,
                   plan2_code_anal_06        ,
                   plan2_code_anal_07        ,
                   plan2_code_anal_08        ,
                   plan2_code_anal_09        ,
                   plan2_code_anal_10        ,
                   plan2_code_anal_11        ,
                   plan2_code_anal_12        ,
                   plan2_code_anal_13        ,
                   plan2_code_anal_14        ,
                   plan2_code_anal_15        ,
                   plan2_code_anal_16        ,
                   plan2_code_anal_17        ,
                   plan2_code_anal_18        ,
                   plan2_code_anal_19        ,
                   plan2_code_anal_20        ,
                   plan2_pour_affe_anal_01   ,
                   plan2_pour_affe_anal_02   ,
                   plan2_pour_affe_anal_03   ,
                   plan2_pour_affe_anal_04   ,
                   plan2_pour_affe_anal_05   ,
                   plan2_pour_affe_anal_06   ,
                   plan2_pour_affe_anal_07   ,
                   plan2_pour_affe_anal_08   ,
                   plan2_pour_affe_anal_09   ,
                   plan2_pour_affe_anal_10   ,
                   plan2_pour_affe_anal_11   ,
                   plan2_pour_affe_anal_12   ,
                   plan2_pour_affe_anal_13   ,
                   plan2_pour_affe_anal_14   ,
                   plan2_pour_affe_anal_15   ,
                   plan2_pour_affe_anal_16   ,
                   plan2_pour_affe_anal_17   ,
                   plan2_pour_affe_anal_18   ,
                   plan2_pour_affe_anal_19   ,
                   plan2_pour_affe_anal_20   ,
                   plan3_code_anal_01        ,
                   plan3_code_anal_02        ,
                   plan3_code_anal_03        ,
                   plan3_code_anal_04        ,
                   plan3_code_anal_05        ,
                   plan3_code_anal_06        ,
                   plan3_code_anal_07        ,
                   plan3_code_anal_08        ,
                   plan3_code_anal_09        ,
                   plan3_code_anal_10        ,
                   plan3_code_anal_11        ,
                   plan3_code_anal_12        ,
                   plan3_code_anal_13        ,
                   plan3_code_anal_14        ,
                   plan3_code_anal_15        ,
                   plan3_code_anal_16        ,
                   plan3_code_anal_17        ,
                   plan3_code_anal_18        ,
                   plan3_code_anal_19        ,
                   plan3_code_anal_20        ,
                   plan3_pour_affe_anal_01   ,
                   plan3_pour_affe_anal_02   ,
                   plan3_pour_affe_anal_03   ,
                   plan3_pour_affe_anal_04   ,
                   plan3_pour_affe_anal_05   ,
                   plan3_pour_affe_anal_06   ,
                   plan3_pour_affe_anal_07   ,
                   plan3_pour_affe_anal_08   ,
                   plan3_pour_affe_anal_09   ,
                   plan3_pour_affe_anal_10   ,
                   plan3_pour_affe_anal_11   ,
                   plan3_pour_affe_anal_12   ,
                   plan3_pour_affe_anal_13   ,
                   plan3_pour_affe_anal_14   ,
                   plan3_pour_affe_anal_15   ,
                   plan3_pour_affe_anal_16   ,
                   plan3_pour_affe_anal_17   ,
                   plan3_pour_affe_anal_18   ,
                   plan3_pour_affe_anal_19   ,
                   plan3_pour_affe_anal_20   ,
                   plan4_code_anal_01        ,
                   plan4_code_anal_02        ,
                   plan4_code_anal_03        ,
                   plan4_code_anal_04        ,
                   plan4_code_anal_05        ,
                   plan4_code_anal_06        ,
                   plan4_code_anal_07        ,
                   plan4_code_anal_08        ,
                   plan4_code_anal_09        ,
                   plan4_code_anal_10        ,
                   plan4_code_anal_11        ,
                   plan4_code_anal_12        ,
                   plan4_code_anal_13        ,
                   plan4_code_anal_14        ,
                   plan4_code_anal_15        ,
                   plan4_code_anal_16        ,
                   plan4_code_anal_17        ,
                   plan4_code_anal_18        ,
                   plan4_code_anal_19        ,
                   plan4_code_anal_20        ,
                   plan4_pour_affe_anal_01   ,
                   plan4_pour_affe_anal_02   ,
                   plan4_pour_affe_anal_03   ,
                   plan4_pour_affe_anal_04   ,
                   plan4_pour_affe_anal_05   ,
                   plan4_pour_affe_anal_06   ,
                   plan4_pour_affe_anal_07   ,
                   plan4_pour_affe_anal_08   ,
                   plan4_pour_affe_anal_09   ,
                   plan4_pour_affe_anal_10   ,
                   plan4_pour_affe_anal_11   ,
                   plan4_pour_affe_anal_12   ,
                   plan4_pour_affe_anal_13   ,
                   plan4_pour_affe_anal_14   ,
                   plan4_pour_affe_anal_15   ,
                   plan4_pour_affe_anal_16   ,
                   plan4_pour_affe_anal_17   ,
                   plan4_pour_affe_anal_18   ,
                   plan4_pour_affe_anal_19   ,
                   plan4_pour_affe_anal_20   ,
                   plan5_code_anal_01        ,
                   plan5_code_anal_02        ,
                   plan5_code_anal_03        ,
                   plan5_code_anal_04        ,
                   plan5_code_anal_05        ,
                   plan5_code_anal_06        ,
                   plan5_code_anal_07        ,
                   plan5_code_anal_08        ,
                   plan5_code_anal_09        ,
                   plan5_code_anal_10        ,
                   plan5_code_anal_11        ,
                   plan5_code_anal_12        ,
                   plan5_code_anal_13        ,
                   plan5_code_anal_14        ,
                   plan5_code_anal_15        ,
                   plan5_code_anal_16        ,
                   plan5_code_anal_17        ,
                   plan5_code_anal_18        ,
                   plan5_code_anal_19        ,
                   plan5_code_anal_20        ,
                   plan5_pour_affe_anal_01   ,
                   plan5_pour_affe_anal_02   ,
                   plan5_pour_affe_anal_03   ,
                   plan5_pour_affe_anal_04   ,
                   plan5_pour_affe_anal_05   ,
                   plan5_pour_affe_anal_06   ,
                   plan5_pour_affe_anal_07   ,
                   plan5_pour_affe_anal_08   ,
                   plan5_pour_affe_anal_09   ,
                   plan5_pour_affe_anal_10   ,
                   plan5_pour_affe_anal_11   ,
                   plan5_pour_affe_anal_12   ,
                   plan5_pour_affe_anal_13   ,
                   plan5_pour_affe_anal_14   ,
                   plan5_pour_affe_anal_15   ,
                   plan5_pour_affe_anal_16   ,
                   plan5_pour_affe_anal_17   ,
                   plan5_pour_affe_anal_18   ,
                   plan5_pour_affe_anal_19   ,
                   plan5_pour_affe_anal_20   ,
                   situ_fami                 ,
                   bull_mode                 ,
                   profil_paye_cp            ,
                   profil_paye_rtt           ,
                   profil_paye_dif           ,
                   profil_paye_prov_cet      ,
                   profil_paye_prov_inte     ,
                   profil_paye_prov_part     ,
                   profil_paye_13mo          ,
                   profil_paye_14mo          ,
                   prof_15mo                 ,
                   profil_paye_prim_vaca_01  ,
                   profil_paye_prim_vaca_02  ,
                   profil_paye_hs_conv       ,
                   profil_paye_heur_equi     ,
                   profil_paye_deca_fisc     ,
                   profil_paye_tepa          ,
                   profil_paye_affi_bull     ,
                   profil_paye_forf          ,
                   profil_paye_depa          ,
                   profil_paye_rein_frai     ,
                   profil_paye_ndf           ,
                   profil_paye_acce_sala     ,
                   profil_paye_plan          ,
                   profil_paye_tele_trav     ,
                   idcc_heur_equi            ,
                   cipdz_code                ,
                   cipdz_libe                ,
                   nume_cong_spec            ,
                   grou_comp                 ,
                   nati                      ,
                   date_expi                 ,
                   nume_cart_sejo            ,
                   nume_cart_trav            ,
                   date_deli_trav            ,
                   date_expi_trav            ,
                   date_dema_auto_trav       ,
                   id_pref                   ,
                   date_expi_disp_mutu       ,
                   id_moti_disp_mutu         ,
                   nomb_enfa                 ,
                   comm_vent_n               ,
                   comm_vent_n1              ,
                   prim_obje_n               ,
                   prim_obje_n1              ,
                   prim_obje_soci_n          ,
                   prim_obje_soci_n1         ,
                   prim_obje_glob_n          ,
                   dads_inse_empl            ,
                   sais                      ,
                   moti_visi_medi            ,
                   stat_boet                 ,
                   nomb_jour_trav_refe_tr_2  ,
                   calc_auto_tr              ,
                   type_vehi                 ,
                   cate_vehi                 ,
                   pris_char_carb            ,
                   octr_vehi                 ,
                   imma_vehi                 ,
                   date_1er_mise_circ_vehi   ,
                   prix_acha_remi_vehi       ,
                   cout_vehi                 ,
                   type_sala                 ,
                   natu_cont                 ,
                   nume_cont                 ,
                   libe_moti_recr_cdd        ,
                   libe_moti_recr_cdd2       ,
                   libe_moti_recr_cdd3       ,
                   date_debu_cont            ,
                   date_fin_cont             ,
                   date_dern_visi_medi       ,
                   date_proc_visi_medi       ,
                   equi                      ,
                   code_soci                 ,
                   soci_code                 ,
                   etab_code                 ,
                   code_divi                 ,
                   code_serv                 ,
                   code_depa                 ,
                   code_equi                 ,
                   sala_code_unit            ,
                   divi                      ,
                   cais_coti_bull            ,
                   matr_grou                 ,
                   matr_resp_hier            ,
                   date_anci_prof            ,
                   date_refe_01              ,
                   date_refe_02              ,
                   date_refe_03              ,
                   date_refe_04              ,
                   date_refe_05              ,
                   date_sign_conv_stag       ,
                   nive_qual                 ,
                   moti_depa                 ,
                   moti_augm                 ,
                   moti_augm_2               , ---KFH 25/05/2023 T184292
                   TICK_REST_TYPE_REPA       ,--KFH 03/04/2024 T201908
                   sala_auto_titr_trav       ,
                   lieu_pres_stag            ,
                   sexe                      ,
                   regr                      ,
                   mail_sala_cong            ,
                   resp_hier_1_nom           ,
                   resp_hier_1_mail          ,
                   resp_hier_2_nom           ,
                   resp_hier_2_mail          ,
                   hier_resp_1_nom           ,
                   hier_resp_1_mail          ,
                   hier_resp_2_nom           ,
                   hier_resp_2_mail          ,
                   rib_mode_paie             ,
                   rib_banq_1                ,
                   rib_domi_1                ,
                   rib_nume_1                ,
                   rib_titu_comp_1           ,
                   rib_banq_2                ,
                   rib_domi_2                ,
                   rib_nume_2                ,
                   rib_titu_comp_2           ,
                   tele_1                    ,
                   tele_2                    ,
                   tele_3                    ,
                   adre                      ,
                   adre_comp                 ,
                   adre_comm                 ,
                   adre_code_post            ,
                   adre_pays                 ,
                   cham_util_1               ,
                   cham_util_2               ,
                   cham_util_3               ,
                   cham_util_4               ,
                   cham_util_5               ,
                   cham_util_6               ,
                   cham_util_7               ,
                   cham_util_8               ,
                   cham_util_9               ,
                   cham_util_10              ,
                   cham_util_11              ,
                   cham_util_12              ,
                   cham_util_13              ,
                   cham_util_14              ,
                   cham_util_15              ,
                   cham_util_16              ,
                   cham_util_17              ,
                   cham_util_18              ,
                   cham_util_19              ,
                   cham_util_20              ,
                   cham_util_21              ,
                   cham_util_22              ,
                   cham_util_23              ,
                   cham_util_24              ,
                   cham_util_25              ,
                   cham_util_26              ,
                   cham_util_27              ,
                   cham_util_28              ,
                   cham_util_29              ,
                   cham_util_30              ,
                   cham_util_31              ,
                   cham_util_32              ,
                   cham_util_33              ,
                   cham_util_34              ,
                   cham_util_35              ,
                   cham_util_36              ,
                   cham_util_37              ,
                   cham_util_38              ,
                   cham_util_39              ,
                   cham_util_40              ,
                   cham_util_41              ,
                   cham_util_42              ,
                   cham_util_43              ,
                   cham_util_44              ,
                   cham_util_45              ,
                   cham_util_46              ,
                   cham_util_47              ,
                   cham_util_48              ,
                   cham_util_49              ,
                   cham_util_50              ,
                   cham_util_51              ,
                   cham_util_52              ,
                   cham_util_53              ,
                   cham_util_54              ,
                   cham_util_55              ,
                   cham_util_56              ,
                   cham_util_57              ,
                   cham_util_58              ,
                   cham_util_59              ,
                   cham_util_60              ,
                   cham_util_61              ,
                   cham_util_62              ,
                   cham_util_63              ,
                   cham_util_64              ,
                   cham_util_65              ,
                   cham_util_66              ,
                   cham_util_67              ,
                   cham_util_68              ,
                   cham_util_69              ,
                   cham_util_70              ,
                   cham_util_71              ,
                   cham_util_72              ,
                   cham_util_73              ,
                   cham_util_74              ,
                   cham_util_75              ,
                   cham_util_76              ,
                   cham_util_77              ,
                   cham_util_78              ,
                   cham_util_79              ,
                   cham_util_80              ,
                   ordr_soci                 ,
                   soci                      ,
                   rais_soci                 ,
                   soci_orig                 ,
                   fin_peri_essa             ,
                   droi_prim_anci            ,
                   bic_01                    ,
                   bic_02                    ,
                   iban_01                   ,
                   iban_02                   ,
                   code_iso_pays_nati        ,
                   ccn51_anci_date_chan_appl ,
                   ccn51_anci_taux           ,
                   ccn51_cadr_date_chan_appl ,
                   ccn51_cadr_taux           ,
                   etp_ccn51                 ,
                   ccn51_coef_acca           ,
                   ccn51_coef_dipl           ,
                   ccn51_coef_enca           ,
                   ccn51_coef_fonc           ,
                   ccn51_coef_meti           ,
                   ccn51_coef_recl           ,
                   ccn51_coef_spec           ,
                   ccn51_id_empl_conv        ,
                   ccn5166_coef_refe         ,
                   ccn66_cate_conv           ,
                   ccn66_date_chan_coef      ,
                   ccn66_empl_conv           ,
                   ccn66_libe_empl_conv      ,
                   ccn66_fili_conv           ,
                   ccn66_prec_date_chan_coef ,
                   ccn66_proc_coef_refe      ,
                   ccn66_regi                ,
                   code_regi                 ,
                   libe_regi                 ,
                   orga                      ,
                   unit                      ,
                   nume_fine                 ,
                   nume_adel                 ,
                   nume_rpps                 ,
                   adre_elec                 ,
                   code_titr_form            ,
                   libe_titr_form            ,
                   date_titr_form            ,
                   lieu_titr_form            ,
                   calc_auto_inde_cong_prec  ,
                   rubr_01                   ,
                   rubr_02                   ,
                   rubr_03                   ,
                   rubr_04                   ,
                   rubr_05                   ,
                   rubr_06                   ,
                   rubr_07                   ,
                   rubr_08                   ,
                   rubr_09                   ,
                   rubr_10                   ,
                   rubr_11                   ,
                   rubr_12                   ,
                   rubr_13                   ,
                   rubr_14                   ,
                   rubr_15                   ,
                   rubr_16                   ,
                   rubr_17                   ,
                   rubr_18                   ,
                   rubr_19                   ,
                   rubr_20                   ,
                   rubr_21                   ,
                   rubr_22                   ,
                   rubr_23                   ,
                   rubr_24                   ,
                   rubr_25                   ,
                   rubr_26                   ,
                   rubr_27                   ,
                   rubr_28                   ,
                   rubr_29                   ,
                   rubr_30                   ,
                   rubr_31                   ,
                   rubr_32                   ,
                   rubr_33                   ,
                   rubr_34                   ,
                   rubr_35                   ,
                   rubr_36                   ,
                   rubr_37                   ,
                   rubr_38                   ,
                   rubr_39                   ,
                   rubr_40                   ,
                   rubr_41                   ,
                   rubr_42                   ,
                   rubr_43                   ,
                   rubr_44                   ,
                   rubr_45                   ,
                   rubr_46                   ,
                   rubr_47                   ,
                   rubr_48                   ,
                   rubr_49                   ,
                   rubr_50                   ,

                   rubr_51                   ,
                   rubr_52                   ,
                   rubr_53                   ,
                   rubr_54                   ,
                   rubr_55                   ,
                   rubr_56                   ,
                   rubr_57                   ,
                   rubr_58                   ,
                   rubr_59                   ,
                   rubr_60                   ,
                   rubr_61                   ,
                   rubr_62                   ,
                   rubr_63                   ,
                   rubr_64                   ,
                   rubr_65                   ,
                   rubr_66                   ,
                   rubr_67                   ,
                   rubr_68                   ,
                   rubr_69                   ,
                   rubr_70                   ,
                   rubr_71                   ,
                   rubr_72                   ,
                   rubr_73                   ,
                   rubr_74                   ,
                   rubr_75                   ,
                   rubr_76                   ,
                   rubr_77                   ,
                   rubr_78                   ,
                   rubr_79                   ,
                   rubr_80                   ,
                   rubr_81                   ,
                   rubr_82                   ,
                   rubr_83                   ,
                   rubr_84                   ,
                   rubr_85                   ,
                   rubr_86                   ,
                   rubr_87                   ,
                   rubr_88                   ,
                   rubr_89                   ,
                   rubr_90                   ,
                   rubr_91                   ,
                   rubr_92                   ,
                   rubr_93                   ,
                   rubr_94                   ,
                   rubr_95                   ,
                   rubr_96                   ,
                   rubr_97                   ,
                   rubr_98                   ,
                   rubr_99                   ,
                   rubr_100                  ,
                   rubr_101                  ,
                   rubr_102                  ,
                   rubr_103                  ,
                   rubr_104                  ,
                   rubr_105                  ,
                   rubr_106                  ,
                   rubr_107                  ,
                   rubr_108                  ,
                   rubr_109                  ,
                   rubr_110                  ,
                   rubr_111                  ,
                   rubr_112                  ,
                   rubr_113                  ,
                   rubr_114                  ,
                   rubr_115                  ,
                   rubr_116                  ,
                   rubr_117                  ,
                   rubr_118                  ,
                   rubr_119                  ,
                   rubr_120                  ,
                   rubr_121                  ,
                   rubr_122                  ,
                   rubr_123                  ,
                   rubr_124                  ,
                   rubr_125                  ,
                   rubr_126                  ,
                   rubr_127                  ,
                   rubr_128                  ,
                   rubr_129                  ,
                   rubr_130                  ,
                   rubr_131                  ,
                   rubr_132                  ,
                   rubr_133                  ,
                   rubr_134                  ,
                   rubr_135                  ,
                   rubr_136                  ,
                   rubr_137                  ,
                   rubr_138                  ,
                   rubr_139                  ,
                   rubr_140                  ,
                   rubr_141                  ,
                   rubr_142                  ,
                   rubr_143                  ,
                   rubr_144                  ,
                   rubr_145                  ,
                   rubr_146                  ,
                   rubr_147                  ,
                   rubr_148                  ,
                   rubr_149                  ,
                   rubr_150                  ,

                   cons_01                   ,
                   cons_02                   ,
                   cons_03                   ,
                   cons_04                   ,
                   cons_05                   ,
                   cons_06                   ,
                   cons_07                   ,
                   cons_08                   ,
                   cons_09                   ,
                   cons_10                   ,
                   cons_11                   ,
                   cons_12                   ,
                   cons_13                   ,
                   cons_14                   ,
                   cons_15                   ,
                   cons_16                   ,
                   cons_17                   ,
                   cons_18                   ,
                   cons_19                   ,
                   cons_20                   ,

                   cons_21                   ,
                   cons_22                   ,
                   cons_23                   ,
                   cons_24                   ,
                   cons_25                   ,
                   cons_26                   ,
                   cons_27                   ,
                   cons_28                   ,
                   cons_29                   ,
                   cons_30                   ,
                   cons_31                   ,
                   cons_32                   ,
                   cons_33                   ,
                   cons_34                   ,
                   cons_35                   ,
                   cons_36                   ,
                   cons_37                   ,
                   cons_38                   ,
                   cons_39                   ,
                   cons_40                   ,
                   cons_41                   ,
                   cons_42                   ,
                   cons_43                   ,
                   cons_44                   ,
                   cons_45                   ,
                   cons_46                   ,
                   cons_47                   ,
                   cons_48                   ,
                   cons_49                   ,
                   cons_50                   ,

                   fili_conv                 ,
                   rapp_hora_arro            ,
                   comm_1                    ,
                   comm_2                    ,
                   comm_3                    ,
                   adre_mail                 ,
                   adre_mail_pers            ,
                   inva                      ,
                   saho_boo                  ,
                   calc_01                   ,
                   calc_02                   ,
                   calc_03                   ,
                   calc_04                   ,
                   calc_05                   ,
                   calc_06                   ,
                   calc_07                   ,
                   calc_08                   ,
                   calc_09                   ,
                   calc_10                   ,
                   calc_11                   ,
                   calc_12                   ,
                   calc_13                   ,
                   calc_14                   ,
                   calc_15                   ,
                   calc_16                   ,
                   calc_17                   ,
                   calc_18                   ,
                   calc_19                   ,
                   calc_20                   ,
                   code_comp_fic             ,
                   sala_forf_temp            ,
                   nomb_jour_forf_temp       ,
                   nomb_heur_forf_temp       ,
                   nomb_mois                 ,
                   sala_annu_cont            ,
                   code_fine_geog            ,
                   rib_guic_1                ,
                   rib_comp_1                ,
                   rib_cle_1                 ,
                   rib_banq_01               ,
                   rib_banq_02               ,
                   prof_temp_libe            ,
                   nomb_jour_cong_anci       ,
                   mont_anci_pa              ,
                   anci_cadr                 ,
                   tota_heur_trav            ,
                   DPAE_ENVO                 ,
                   DISP_POLI_PUBL_CONV       ,
                   DATE_ANCI_CADR_FORF    
                )values(
                   iID_SOCI            ,
                   iID_LOGI            ,
                   vID_LIST            ,
                   vID_PARA            ,
                   to_char(peri.peri_paie,'DD/MM/YYYY'), -- POURQUOI CETTE COLONNE EST ELLE STOCKEE EN VARCHAR !!
                   1                              ,
                   data.id_sala                   ,
                   oGeav.repa_anal                ,
                   oGeav.repa_anal_code           ,
                   oGeav.repa_anal_pour           ,
                   substr(data.nom, 1, 100)       ,
                   substr(data.pren, 1, 100)      ,
                   substr(data.nom_jeun_fill, 1, 100),
                   substr(data.titr,1,20)         ,
                   data.matr                      ,
                   data.reac_regu                 ,
                   data.serv                      ,
                   data.depa                      ,
                   data.id_cate                   ,
                   data.cate_prof                 ,
                   oGeav.conv_coll                ,
                   data.id_etab                   ,
                   substr(data.etab     ,1,50)    ,
                   substr(data.etab_cour,1,50)    ,
                   substr(data.empl     ,1,80)    ,
                   data.empl_type                 ,
                   data.meti                      ,
                   data.fami_meti                 ,
                   data.fami_meti_hier            ,
                   data.code_empl                 ,
                   data.code_cate                 ,
                   data.empl_gene                 ,
                   vCOEFFIC                       ,
                   data.sire_etab                 ,
                   vDIPL                          ,
                   data.nive_form_educ_nati       ,
                   data.code_unit                 ,
                   data.code_regr_fich_comp_etab  ,
                   substr(vNIVEAU       ,1,50)    ,
                   substr(vECHELON      ,1,50)    ,
                   substr(vGROU_CONV    ,1,50)    ,
                   substr(vPOSITION     ,1,50)    ,
                   substr(vINDICE       ,1,50)    ,
                   substr(vCOTA         ,1,50)    ,
                   substr(vCLAS         ,1,50)    ,
                   substr(vSEUI         ,1,50)    ,
                   substr(vPALI         ,1,50)    ,
                   substr(vGRAD         ,1,50)    ,
                   substr(vDEGR         ,1,50)    ,
                   vLIBE_FILI                     ,
                   vLIBE_SECT_PROF                ,
                   data.comp_brut                 ,
                   vNUME_COMP_BRUT                ,
                   vLIBE_COMP_BRUT                ,
                   data.comp_paye                 ,
                   vNUME_COMP_PAYE                ,
                   vLIBE_COMP_PAYE                ,
                   data.comp_acom                 ,
                   substr(data.nume_secu,1,50)    ,
                   data.date_emba                 ,
                   data.date_depa                 ,
                   data.date_anci                 ,
                   data.date_dela_prev            ,
                   data.date_nais                 ,
                   data.date_acci_trav            ,
                   data.comm_nais                 ,
                   vDEPA_NAIS                     ,
                   data.pays_nais                 ,
                   data.trav_hand                 ,
                   data.date_debu_coto            ,
                   data.date_fin_coto             ,
                   data.taux_inva                 ,
                   vCONG_REST_N                   ,
                   vEVOL_REMU_SUPP_COTI           ,
                   vNOMB_TR_CALC_PERI             ,
                   vVALE_SPEC_TR                  ,
                   fCONG_PRIS_ANNE_N              ,
                   oGeav.mutu_soum_txde_01        ,
                   oGeav.mutu_soum_txde_02        ,
                   oGeav.mutu_soum_txde_03        ,
                   oGeav.mutu_soum_txde_04        ,
                   oGeav.mutu_soum_txde_05        ,
                   oGeav.mutu_soum_mtde_01        ,
                   oGeav.mutu_soum_mtde_02        ,
                   oGeav.mutu_soum_mtde_03        ,
                   oGeav.mutu_soum_mtde_04        ,
                   oGeav.mutu_soum_mtde_05        ,
                   oGeav.mutu_soum_mtde_06        ,
                   oGeav.mutu_soum_mtde_07        ,
                   oGeav.mutu_soum_mtde_08        ,
                   oGeav.mutu_soum_mtde_09        ,
                   oGeav.mutu_soum_mtde_10        ,
                   oGeav.mutu_noso_txde_01        ,
                   oGeav.mutu_noso_txde_02        ,
                   oGeav.mutu_noso_txde_03        ,
                   oGeav.mutu_noso_mtde_01        ,
                   oGeav.mutu_noso_mtde_02        ,
                   oGeav.mutu_noso_mtde_03        ,
                   oGeav.mutu_noso_mtde_04        ,
                   oGeav.mutu_noso_mtde_05        ,
                   oGeav.mutu_noso_mtde_06        ,
                   oGeav.mutu_noso_mtde_07        ,
                   data.code_anal_01              ,
                   data.code_anal_02              ,
                   data.code_anal_03              ,
                   data.code_anal_04              ,
                   data.code_anal_05              ,
                   data.code_anal_06              ,
                   data.code_anal_07              ,
                   data.code_anal_08              ,
                   data.code_anal_09              ,
                   data.code_anal_10              ,
                   data.code_anal_11              ,
                   data.code_anal_12              ,
                   data.code_anal_13              ,
                   data.code_anal_14              ,
                   data.code_anal_15              ,
                   data.code_anal_16              ,
                   data.code_anal_17              ,
                   data.code_anal_18              ,
                   data.code_anal_19              ,
                   data.code_anal_20              ,
                   oGeav.plan1_code_anal_01       ,
                   oGeav.plan1_code_anal_02       ,
                   oGeav.plan1_code_anal_03       ,
                   oGeav.plan1_code_anal_04       ,
                   oGeav.plan1_code_anal_05       ,
                   oGeav.plan1_code_anal_06       ,
                   oGeav.plan1_code_anal_07       ,
                   oGeav.plan1_code_anal_08       ,
                   oGeav.plan1_code_anal_09       ,
                   oGeav.plan1_code_anal_10       ,
                   oGeav.plan1_code_anal_11       ,
                   oGeav.plan1_code_anal_12       ,
                   oGeav.plan1_code_anal_13       ,
                   oGeav.plan1_code_anal_14       ,
                   oGeav.plan1_code_anal_15       ,
                   oGeav.plan1_code_anal_16       ,
                   oGeav.plan1_code_anal_17       ,
                   oGeav.plan1_code_anal_18       ,
                   oGeav.plan1_code_anal_19       ,
                   oGeav.plan1_code_anal_20       ,
                   oGeav.plan1_pour_affe_anal_01  ,
                   oGeav.plan1_pour_affe_anal_02  ,
                   oGeav.plan1_pour_affe_anal_03  ,
                   oGeav.plan1_pour_affe_anal_04  ,
                   oGeav.plan1_pour_affe_anal_05  ,
                   oGeav.plan1_pour_affe_anal_06  ,
                   oGeav.plan1_pour_affe_anal_07  ,
                   oGeav.plan1_pour_affe_anal_08  ,
                   oGeav.plan1_pour_affe_anal_09  ,
                   oGeav.plan1_pour_affe_anal_10  ,
                   oGeav.plan1_pour_affe_anal_11  ,
                   oGeav.plan1_pour_affe_anal_12  ,
                   oGeav.plan1_pour_affe_anal_13  ,
                   oGeav.plan1_pour_affe_anal_14  ,
                   oGeav.plan1_pour_affe_anal_15  ,
                   oGeav.plan1_pour_affe_anal_16  ,
                   oGeav.plan1_pour_affe_anal_17  ,
                   oGeav.plan1_pour_affe_anal_18  ,
                   oGeav.plan1_pour_affe_anal_19  ,
                   oGeav.plan1_pour_affe_anal_20  ,
                   oGeav.plan2_code_anal_01       ,
                   oGeav.plan2_code_anal_02       ,
                   oGeav.plan2_code_anal_03       ,
                   oGeav.plan2_code_anal_04       ,
                   oGeav.plan2_code_anal_05       ,
                   oGeav.plan2_code_anal_06       ,
                   oGeav.plan2_code_anal_07       ,
                   oGeav.plan2_code_anal_08       ,
                   oGeav.plan2_code_anal_09       ,
                   oGeav.plan2_code_anal_10       ,
                   oGeav.plan2_code_anal_11       ,
                   oGeav.plan2_code_anal_12       ,
                   oGeav.plan2_code_anal_13       ,
                   oGeav.plan2_code_anal_14       ,
                   oGeav.plan2_code_anal_15       ,
                   oGeav.plan2_code_anal_16       ,
                   oGeav.plan2_code_anal_17       ,
                   oGeav.plan2_code_anal_18       ,
                   oGeav.plan2_code_anal_19       ,
                   oGeav.plan2_code_anal_20       ,
                   oGeav.plan2_pour_affe_anal_01  ,
                   oGeav.plan2_pour_affe_anal_02  ,
                   oGeav.plan2_pour_affe_anal_03  ,
                   oGeav.plan2_pour_affe_anal_04  ,
                   oGeav.plan2_pour_affe_anal_05  ,
                   oGeav.plan2_pour_affe_anal_06  ,
                   oGeav.plan2_pour_affe_anal_07  ,
                   oGeav.plan2_pour_affe_anal_08  ,
                   oGeav.plan2_pour_affe_anal_09  ,
                   oGeav.plan2_pour_affe_anal_10  ,
                   oGeav.plan2_pour_affe_anal_11  ,
                   oGeav.plan2_pour_affe_anal_12  ,
                   oGeav.plan2_pour_affe_anal_13  ,
                   oGeav.plan2_pour_affe_anal_14  ,
                   oGeav.plan2_pour_affe_anal_15  ,
                   oGeav.plan2_pour_affe_anal_16  ,
                   oGeav.plan2_pour_affe_anal_17  ,
                   oGeav.plan2_pour_affe_anal_18  ,
                   oGeav.plan2_pour_affe_anal_19  ,
                   oGeav.plan2_pour_affe_anal_20  ,
                   oGeav.plan3_code_anal_01       ,
                   oGeav.plan3_code_anal_02       ,
                   oGeav.plan3_code_anal_03       ,
                   oGeav.plan3_code_anal_04       ,
                   oGeav.plan3_code_anal_05       ,
                   oGeav.plan3_code_anal_06       ,
                   oGeav.plan3_code_anal_07       ,
                   oGeav.plan3_code_anal_08       ,
                   oGeav.plan3_code_anal_09       ,
                   oGeav.plan3_code_anal_10       ,
                   oGeav.plan3_code_anal_11       ,
                   oGeav.plan3_code_anal_12       ,
                   oGeav.plan3_code_anal_13       ,
                   oGeav.plan3_code_anal_14       ,
                   oGeav.plan3_code_anal_15       ,
                   oGeav.plan3_code_anal_16       ,
                   oGeav.plan3_code_anal_17       ,
                   oGeav.plan3_code_anal_18       ,
                   oGeav.plan3_code_anal_19       ,
                   oGeav.plan3_code_anal_20       ,
                   oGeav.plan3_pour_affe_anal_01  ,
                   oGeav.plan3_pour_affe_anal_02  ,
                   oGeav.plan3_pour_affe_anal_03  ,
                   oGeav.plan3_pour_affe_anal_04  ,
                   oGeav.plan3_pour_affe_anal_05  ,
                   oGeav.plan3_pour_affe_anal_06  ,
                   oGeav.plan3_pour_affe_anal_07  ,
                   oGeav.plan3_pour_affe_anal_08  ,
                   oGeav.plan3_pour_affe_anal_09  ,
                   oGeav.plan3_pour_affe_anal_10  ,
                   oGeav.plan3_pour_affe_anal_11  ,
                   oGeav.plan3_pour_affe_anal_12  ,
                   oGeav.plan3_pour_affe_anal_13  ,
                   oGeav.plan3_pour_affe_anal_14  ,
                   oGeav.plan3_pour_affe_anal_15  ,
                   oGeav.plan3_pour_affe_anal_16  ,
                   oGeav.plan3_pour_affe_anal_17  ,
                   oGeav.plan3_pour_affe_anal_18  ,
                   oGeav.plan3_pour_affe_anal_19  ,
                   oGeav.plan3_pour_affe_anal_20  ,
                   oGeav.plan4_code_anal_01       ,
                   oGeav.plan4_code_anal_02       ,
                   oGeav.plan4_code_anal_03       ,
                   oGeav.plan4_code_anal_04       ,
                   oGeav.plan4_code_anal_05       ,
                   oGeav.plan4_code_anal_06       ,
                   oGeav.plan4_code_anal_07       ,
                   oGeav.plan4_code_anal_08       ,
                   oGeav.plan4_code_anal_09       ,
                   oGeav.plan4_code_anal_10       ,
                   oGeav.plan4_code_anal_11       ,
                   oGeav.plan4_code_anal_12       ,
                   oGeav.plan4_code_anal_13       ,
                   oGeav.plan4_code_anal_14       ,
                   oGeav.plan4_code_anal_15       ,
                   oGeav.plan4_code_anal_16       ,
                   oGeav.plan4_code_anal_17       ,
                   oGeav.plan4_code_anal_18       ,
                   oGeav.plan4_code_anal_19       ,
                   oGeav.plan4_code_anal_20       ,
                   oGeav.plan4_pour_affe_anal_01  ,
                   oGeav.plan4_pour_affe_anal_02  ,
                   oGeav.plan4_pour_affe_anal_03  ,
                   oGeav.plan4_pour_affe_anal_04  ,
                   oGeav.plan4_pour_affe_anal_05  ,
                   oGeav.plan4_pour_affe_anal_06  ,
                   oGeav.plan4_pour_affe_anal_07  ,
                   oGeav.plan4_pour_affe_anal_08  ,
                   oGeav.plan4_pour_affe_anal_09  ,
                   oGeav.plan4_pour_affe_anal_10  ,
                   oGeav.plan4_pour_affe_anal_11  ,
                   oGeav.plan4_pour_affe_anal_12  ,
                   oGeav.plan4_pour_affe_anal_13  ,
                   oGeav.plan4_pour_affe_anal_14  ,
                   oGeav.plan4_pour_affe_anal_15  ,
                   oGeav.plan4_pour_affe_anal_16  ,
                   oGeav.plan4_pour_affe_anal_17  ,
                   oGeav.plan4_pour_affe_anal_18  ,
                   oGeav.plan4_pour_affe_anal_19  ,
                   oGeav.plan4_pour_affe_anal_20  ,
                   oGeav.plan5_code_anal_01       ,
                   oGeav.plan5_code_anal_02       ,
                   oGeav.plan5_code_anal_03       ,
                   oGeav.plan5_code_anal_04       ,
                   oGeav.plan5_code_anal_05       ,
                   oGeav.plan5_code_anal_06       ,
                   oGeav.plan5_code_anal_07       ,
                   oGeav.plan5_code_anal_08       ,
                   oGeav.plan5_code_anal_09       ,
                   oGeav.plan5_code_anal_10       ,
                   oGeav.plan5_code_anal_11       ,
                   oGeav.plan5_code_anal_12       ,
                   oGeav.plan5_code_anal_13       ,
                   oGeav.plan5_code_anal_14       ,
                   oGeav.plan5_code_anal_15       ,
                   oGeav.plan5_code_anal_16       ,
                   oGeav.plan5_code_anal_17       ,
                   oGeav.plan5_code_anal_18       ,
                   oGeav.plan5_code_anal_19       ,
                   oGeav.plan5_code_anal_20       ,
                   oGeav.plan5_pour_affe_anal_01  ,
                   oGeav.plan5_pour_affe_anal_02  ,
                   oGeav.plan5_pour_affe_anal_03  ,
                   oGeav.plan5_pour_affe_anal_04  ,
                   oGeav.plan5_pour_affe_anal_05  ,
                   oGeav.plan5_pour_affe_anal_06  ,
                   oGeav.plan5_pour_affe_anal_07  ,
                   oGeav.plan5_pour_affe_anal_08  ,
                   oGeav.plan5_pour_affe_anal_09  ,
                   oGeav.plan5_pour_affe_anal_10  ,
                   oGeav.plan5_pour_affe_anal_11  ,
                   oGeav.plan5_pour_affe_anal_12  ,
                   oGeav.plan5_pour_affe_anal_13  ,
                   oGeav.plan5_pour_affe_anal_14  ,
                   oGeav.plan5_pour_affe_anal_15  ,
                   oGeav.plan5_pour_affe_anal_16  ,
                   oGeav.plan5_pour_affe_anal_17  ,
                   oGeav.plan5_pour_affe_anal_18  ,
                   oGeav.plan5_pour_affe_anal_19  ,
                   oGeav.plan5_pour_affe_anal_20  ,
                   data.situ_fami                 ,
                   oEdit.bull_mode                ,
                   oEdit.profil_paye_cp           ,
                   oEdit.profil_paye_rtt          ,
                   oEdit.profil_paye_dif          ,
                   oEdit.profil_paye_prov_cet     ,
                   oEdit.profil_paye_prov_inte    ,
                   oEdit.profil_paye_prov_part    ,
                   oEdit.profil_paye_13mo         ,
                   oEdit.profil_paye_14mo         ,
                   oEdit.prof_15mo                ,
                   oEdit.profil_paye_prim_vaca_01 ,
                   oEdit.profil_paye_prim_vaca_02 ,
                   oEdit.profil_paye_hs_conv      ,
                   oEdit.profil_paye_heur_equi    ,
                   oEdit.profil_paye_deca_fisc    ,
                   oEdit.profil_paye_tepa         ,
                   oEdit.profil_paye_affi_bull    ,
                   oEdit.profil_paye_forf         ,
                   oEdit.profil_paye_depa         ,
                   oEdit.profil_paye_rein_frai    ,
                   oEdit.profil_paye_ndf          ,
                   oEdit.profil_paye_acce_sala    ,
                   oEdit.profil_paye_plan         ,
                   oEdit.profil_paye_tele_trav    ,
                   oGeav.idcc_heur_equi           ,
                   oGeav.cipdz_code               ,
                   oGeav.cipdz_libe               ,
                   data.nume_cong_spec            ,
                   data.grou_comp                 ,
                   oEdit.nati                     ,
                   data.date_expi                 ,
                   data.nume_cart_sejo            ,
                   data.nume_cart_trav            ,
                   data.date_deli_trav            ,
                   data.date_expi_trav            ,
                   data.date_dema_auto_trav       ,
                   data.id_pref                   ,
                   data.date_expi_disp_mutu       ,
                   data.id_moti_disp_mutu         ,
                   oGeav.nomb_enfa                ,
                   data.comm_vent_n               ,
                   data.comm_vent_n1              ,
                   data.prim_obje_n               ,
                   data.prim_obje_n1              ,
                   data.prim_obje_soci_n          ,
                   data.prim_obje_soci_n1         ,
                   data.prim_obje_glob_n          ,
                   data.dads_inse_empl            ,
                   data.sais                      ,
                   data.moti_visi_medi            ,
                   data.stat_boet                 ,
                   data.nomb_jour_trav_refe_tr_2  ,
                   data.calc_auto_tr              ,
                   data.type_vehi                 ,
                   data.cate_vehi                 ,
                   data.pris_char_carb            ,
                   data.octr_vehi                 ,
                   data.imma_vehi                 ,
                   data.date_1er_mise_circ_vehi   ,
                   data.prix_acha_remi_vehi       ,
                   data.cout_vehi                 ,
                   data.type_sala                 ,
                   data.natu_cont                 ,
                   data.nume_cont                 ,
                   vLIBE_MOTI_RECR_CDD            ,
                   vLIBE_MOTI_RECR_CDD2           ,
                   vLIBE_MOTI_RECR_CDD3           ,
                   data.date_debu_cont            ,
                   data.date_fin_cont             ,
                   data.date_dern_visi_medi       ,
                   data.date_proc_visi_medi       ,
                   data.equi                      ,
                   data.code_soci                 ,
                   data.soci_code                 ,
                   data.etab_code                 ,
                   data.code_divi                 ,
                   data.code_serv                 ,
                   data.code_depa                 ,
                   data.code_equi                 ,
                   data.sala_code_unit            ,
                   data.divi                      ,
                   data.cais_coti_bull            ,
                   data.matr_grou                 ,
                   data.matr_resp_hier            ,
                   oGeav.date_anci_prof           ,
                   oGeav.date_refe_01             ,
                   oGeav.date_refe_02             ,
                   oGeav.date_refe_03             ,
                   oGeav.date_refe_04             ,
                   oGeav.date_refe_05             ,
                   oGeav.date_sign_conv_stag      ,
                   data.nive_qual                 ,
                   oGeav.moti_depa                ,
                   oGeav.moti_augm                ,
                   oGeav.moti_augm_2              , ---KFH 25/05/2023 T184292
                   oGeav.TICK_REST_TYPE_REPA      , ---KFH 03/04/2024 T201908
                   oGeav.sala_auto_titr_trav      ,
                   oGeav.lieu_pres_stag           ,
                   data.sexe                      ,
                   data.regr                      ,
                   data.mail_sala_cong            ,
                   oEdit.resp_hier_1_nom          ,
                   oEdit.resp_hier_1_mail         ,
                   oEdit.resp_hier_2_nom          ,
                   oEdit.resp_hier_2_mail         ,
                   oEdit.hier_resp_1_nom          ,
                   oEdit.hier_resp_1_mail         ,
                   oEdit.hier_resp_2_nom          ,
                   oEdit.hier_resp_2_mail         ,
                   data.rib_mode_paie             ,
                   oEDIT.rib_banq_1               ,
                   oEDIT.rib_domi_1               ,
                   oEDIT.rib_nume_1               ,
                   oEDIT.rib_titu_comp_1          ,
                   oEDIT.rib_banq_2               ,
                   oEDIT.rib_domi_2               ,
                   oEDIT.rib_nume_2               ,
                   oEDIT.rib_titu_comp_2          ,
                   data.tele_1                    ,
                   data.tele_2                    ,
                   data.tele_3                    ,
                   data.adre                      ,
                   data.adre_comp                 ,
                   data.adre_comm                 ,
                   data.adre_code_post            ,
                   oGeav.adre_pays                ,
                   data.cham_util_1               ,
                   data.cham_util_2               ,
                   data.cham_util_3               ,
                   data.cham_util_4               ,
                   data.cham_util_5               ,
                   data.cham_util_6               ,
                   data.cham_util_7               ,
                   data.cham_util_8               ,
                   data.cham_util_9               ,
                   data.cham_util_10              ,
                   data.cham_util_11              ,
                   data.cham_util_12              ,
                   data.cham_util_13              ,
                   data.cham_util_14              ,
                   data.cham_util_15              ,
                   data.cham_util_16              ,
                   data.cham_util_17              ,
                   data.cham_util_18              ,
                   data.cham_util_19              ,
                   data.cham_util_20              ,
                   data.cham_util_21              ,
                   data.cham_util_22              ,
                   data.cham_util_23              ,
                   data.cham_util_24              ,
                   data.cham_util_25              ,
                   data.cham_util_26              ,
                   data.cham_util_27              ,
                   data.cham_util_28              ,
                   data.cham_util_29              ,
                   data.cham_util_30              ,
                   data.cham_util_31              ,
                   data.cham_util_32              ,
                   data.cham_util_33              ,
                   data.cham_util_34              ,
                   data.cham_util_35              ,
                   data.cham_util_36              ,
                   data.cham_util_37              ,
                   data.cham_util_38              ,
                   data.cham_util_39              ,
                   data.cham_util_40              ,
                   data.cham_util_41              ,
                   data.cham_util_42              ,
                   data.cham_util_43              ,
                   data.cham_util_44              ,
                   data.cham_util_45              ,
                   data.cham_util_46              ,
                   data.cham_util_47              ,
                   data.cham_util_48              ,
                   data.cham_util_49              ,
                   data.cham_util_50              ,
                   data.cham_util_51              ,
                   data.cham_util_52              ,
                   data.cham_util_53              ,
                   data.cham_util_54              ,
                   data.cham_util_55              ,
                   data.cham_util_56              ,
                   data.cham_util_57              ,
                   data.cham_util_58              ,
                   data.cham_util_59              ,
                   data.cham_util_60              ,
                   data.cham_util_61              ,
                   data.cham_util_62              ,
                   data.cham_util_63              ,
                   data.cham_util_64              ,
                   data.cham_util_65              ,
                   data.cham_util_66              ,
                   data.cham_util_67              ,
                   data.cham_util_68              ,
                   data.cham_util_69              ,
                   data.cham_util_70              ,
                   data.cham_util_71              ,
                   data.cham_util_72              ,
                   data.cham_util_73              ,
                   data.cham_util_74              ,
                   data.cham_util_75              ,
                   data.cham_util_76              ,
                   data.cham_util_77              ,
                   data.cham_util_78              ,
                   data.cham_util_79              ,
                   data.cham_util_80              ,
                   data.ordr_soci                 ,
                   soci.id_soci                   ,
                   soci.rais_soci                 ,
                   oEdit.soci_orig                ,
                   oEdit.fin_peri_essa            ,
                   oEdit.droi_prim_anci           ,
                   oEdit.bic_01                   ,
                   oEdit.bic_02                   ,
                   oEdit.iban_01                  ,
                   oEdit.iban_02                  ,
                   oEdit.code_iso_pays_nati       ,
                   oEdit.ccn51_anci_date_chan_appl,
                   oEdit.ccn51_anci_taux          ,
                   oEdit.ccn51_cadr_date_chan_appl,
                   oEdit.ccn51_cadr_taux          ,
                   oEdit.etp_ccn51                ,
                   oEdit.ccn51_coef_acca          ,
                   oEdit.ccn51_coef_dipl          ,
                   oEdit.ccn51_coef_enca          ,
                   oEdit.ccn51_coef_fonc          ,
                   oEdit.ccn51_coef_meti          ,
                   oEdit.ccn51_coef_recl          ,
                   oEdit.ccn51_coef_spec          ,
                   oEdit.ccn51_id_empl_conv       ,
                   oEdit.ccn5166_coef_refe        ,
                   oEdit.ccn66_cate_conv          ,
                   oEdit.ccn66_date_chan_coef     ,
                   oEdit.ccn66_empl_conv          ,
                   oEdit.ccn66_libe_empl_conv     ,
                   oEdit.ccn66_fili_conv          ,
                   oEdit.ccn66_prec_date_chan_coef,
                   oEdit.ccn66_proc_coef_refe     ,
                   oEdit.ccn66_regi               ,
                   data.code_regi                 ,
                   data.libe_regi                 ,
                   data.orga                      ,
                   data.unit                      ,
                   data.nume_fine                 ,
                   data.nume_adel                 ,
                   data.nume_rpps                 ,
                   data.adre_elec                 ,
                   data.code_titr_form            ,
                   data.libe_titr_form            ,
                   data.date_titr_form            ,
                   data.lieu_titr_form            ,
                   oEdit.calc_auto_inde_cong_prec ,
                   oGeav.rubr_01                  ,
                   oGeav.rubr_02                  ,
                   oGeav.rubr_03                  ,
                   oGeav.rubr_04                  ,
                   oGeav.rubr_05                  ,
                   oGeav.rubr_06                  ,
                   oGeav.rubr_07                  ,
                   oGeav.rubr_08                  ,
                   oGeav.rubr_09                  ,
                   oGeav.rubr_10                  ,
                   oGeav.rubr_11                  ,
                   oGeav.rubr_12                  ,
                   oGeav.rubr_13                  ,
                   oGeav.rubr_14                  ,
                   oGeav.rubr_15                  ,
                   oGeav.rubr_16                  ,
                   oGeav.rubr_17                  ,
                   oGeav.rubr_18                  ,
                   oGeav.rubr_19                  ,
                   oGeav.rubr_20                  ,
                   oGeav.rubr_21                  ,
                   oGeav.rubr_22                  ,
                   oGeav.rubr_23                  ,
                   oGeav.rubr_24                  ,
                   oGeav.rubr_25                  ,
                   oGeav.rubr_26                  ,
                   oGeav.rubr_27                  ,
                   oGeav.rubr_28                  ,
                   oGeav.rubr_29                  ,
                   oGeav.rubr_30                  ,
                   oGeav.rubr_31                  ,
                   oGeav.rubr_32                  ,
                   oGeav.rubr_33                  ,
                   oGeav.rubr_34                  ,
                   oGeav.rubr_35                  ,
                   oGeav.rubr_36                  ,
                   oGeav.rubr_37                  ,
                   oGeav.rubr_38                  ,
                   oGeav.rubr_39                  ,
                   oGeav.rubr_40                  ,
                   oGeav.rubr_41                  ,
                   oGeav.rubr_42                  ,
                   oGeav.rubr_43                  ,
                   oGeav.rubr_44                  ,
                   oGeav.rubr_45                  ,
                   oGeav.rubr_46                  ,
                   oGeav.rubr_47                  ,
                   oGeav.rubr_48                  ,
                   oGeav.rubr_49                  ,
                   oGeav.rubr_50                  ,

                   oGeav.rubr_51                  ,
                   oGeav.rubr_52                  ,
                   oGeav.rubr_53                  ,
                   oGeav.rubr_54                  ,
                   oGeav.rubr_55                  ,
                   oGeav.rubr_56                  ,
                   oGeav.rubr_57                  ,
                   oGeav.rubr_58                  ,
                   oGeav.rubr_59                  ,
                   oGeav.rubr_60                  ,
                   oGeav.rubr_61                  ,
                   oGeav.rubr_62                  ,
                   oGeav.rubr_63                  ,
                   oGeav.rubr_64                  ,
                   oGeav.rubr_65                  ,
                   oGeav.rubr_66                  ,
                   oGeav.rubr_67                  ,
                   oGeav.rubr_68                  ,
                   oGeav.rubr_69                  ,
                   oGeav.rubr_70                  ,
                   oGeav.rubr_71                  ,
                   oGeav.rubr_72                  ,
                   oGeav.rubr_73                  ,
                   oGeav.rubr_74                  ,
                   oGeav.rubr_75                  ,
                   oGeav.rubr_76                  ,
                   oGeav.rubr_77                  ,
                   oGeav.rubr_78                  ,
                   oGeav.rubr_79                  ,
                   oGeav.rubr_80                  ,
                   oGeav.rubr_81                  ,
                   oGeav.rubr_82                  ,
                   oGeav.rubr_83                  ,
                   oGeav.rubr_84                  ,
                   oGeav.rubr_85                  ,
                   oGeav.rubr_86                  ,
                   oGeav.rubr_87                  ,
                   oGeav.rubr_88                  ,
                   oGeav.rubr_89                  ,
                   oGeav.rubr_90                  ,
                   oGeav.rubr_91                  ,
                   oGeav.rubr_92                  ,
                   oGeav.rubr_93                  ,
                   oGeav.rubr_94                  ,
                   oGeav.rubr_95                  ,
                   oGeav.rubr_96                  ,
                   oGeav.rubr_97                  ,
                   oGeav.rubr_98                  ,
                   oGeav.rubr_99                  ,
                   oGeav.rubr_100                 ,
                   oGeav.rubr_101                 ,
                   oGeav.rubr_102                 ,
                   oGeav.rubr_103                 ,
                   oGeav.rubr_104                 ,
                   oGeav.rubr_105                 ,
                   oGeav.rubr_106                 ,
                   oGeav.rubr_107                 ,
                   oGeav.rubr_108                 ,
                   oGeav.rubr_109                 ,
                   oGeav.rubr_110                 ,
                   oGeav.rubr_111                 ,
                   oGeav.rubr_112                 ,
                   oGeav.rubr_113                 ,
                   oGeav.rubr_114                 ,
                   oGeav.rubr_115                 ,
                   oGeav.rubr_116                 ,
                   oGeav.rubr_117                 ,
                   oGeav.rubr_118                 ,
                   oGeav.rubr_119                 ,
                   oGeav.rubr_120                 ,
                   oGeav.rubr_121                 ,
                   oGeav.rubr_122                 ,
                   oGeav.rubr_123                 ,
                   oGeav.rubr_124                 ,
                   oGeav.rubr_125                 ,
                   oGeav.rubr_126                 ,
                   oGeav.rubr_127                 ,
                   oGeav.rubr_128                 ,
                   oGeav.rubr_129                 ,
                   oGeav.rubr_130                 ,
                   oGeav.rubr_131                 ,
                   oGeav.rubr_132                 ,
                   oGeav.rubr_133                 ,
                   oGeav.rubr_134                 ,
                   oGeav.rubr_135                 ,
                   oGeav.rubr_136                 ,
                   oGeav.rubr_137                 ,
                   oGeav.rubr_138                 ,
                   oGeav.rubr_139                 ,
                   oGeav.rubr_140                 ,
                   oGeav.rubr_141                 ,
                   oGeav.rubr_142                 ,
                   oGeav.rubr_143                 ,
                   oGeav.rubr_144                 ,
                   oGeav.rubr_145                 ,
                   oGeav.rubr_146                 ,
                   oGeav.rubr_147                 ,
                   oGeav.rubr_148                 ,
                   oGeav.rubr_149                 ,
                   oGeav.rubr_150                 ,

                   oGeav.cons_01                  ,
                   oGeav.cons_02                  ,
                   oGeav.cons_03                  ,
                   oGeav.cons_04                  ,
                   oGeav.cons_05                  ,
                   oGeav.cons_06                  ,
                   oGeav.cons_07                  ,
                   oGeav.cons_08                  ,
                   oGeav.cons_09                  ,
                   oGeav.cons_10                  ,
                   oGeav.cons_11                  ,
                   oGeav.cons_12                  ,
                   oGeav.cons_13                  ,
                   oGeav.cons_14                  ,
                   oGeav.cons_15                  ,
                   oGeav.cons_16                  ,
                   oGeav.cons_17                  ,
                   oGeav.cons_18                  ,
                   oGeav.cons_19                  ,
                   oGeav.cons_20                  ,

                   oGeav.cons_21                  ,
                   oGeav.cons_22                  ,
                   oGeav.cons_23                  ,
                   oGeav.cons_24                  ,
                   oGeav.cons_25                  ,
                   oGeav.cons_26                  ,
                   oGeav.cons_27                  ,
                   oGeav.cons_28                  ,
                   oGeav.cons_29                  ,
                   oGeav.cons_30                  ,
                   oGeav.cons_31                  ,
                   oGeav.cons_32                  ,
                   oGeav.cons_33                  ,
                   oGeav.cons_34                  ,
                   oGeav.cons_35                  ,
                   oGeav.cons_36                  ,
                   oGeav.cons_37                  ,
                   oGeav.cons_38                  ,
                   oGeav.cons_39                  ,
                   oGeav.cons_40                  ,
                   oGeav.cons_41                  ,
                   oGeav.cons_42                  ,
                   oGeav.cons_43                  ,
                   oGeav.cons_44                  ,
                   oGeav.cons_45                  ,
                   oGeav.cons_46                  ,
                   oGeav.cons_47                  ,
                   oGeav.cons_48                  ,
                   oGeav.cons_49                  ,
                   oGeav.cons_50                  ,

                   data.fili_conv                 ,
                   oEdit.rapp_hora_arro           ,
                   oEdit.comm_1                   ,
                   oEdit.comm_2                   ,
                   oEdit.comm_3                   ,
                   data.mail                      ,
                   data.mail_pers                 ,
                   data.inva                      ,
                   data.saho_boo                  ,
                   oGeav.calc_01                  ,
                   oGeav.calc_02                  ,
                   oGeav.calc_03                  ,
                   oGeav.calc_04                  ,
                   oGeav.calc_05                  ,
                   oGeav.calc_06                  ,
                   oGeav.calc_07                  ,
                   oGeav.calc_08                  ,
                   oGeav.calc_09                  ,
                   oGeav.calc_10                  ,
                   oGeav.calc_11                  ,
                   oGeav.calc_12                  ,
                   oGeav.calc_13                  ,
                   oGeav.calc_14                  ,
                   oGeav.calc_15                  ,
                   oGeav.calc_16                  ,
                   oGeav.calc_17                  ,
                   oGeav.calc_18                  ,
                   oGeav.calc_19                  ,
                   oGeav.calc_20                  ,
                   data.CODE_REGR_FICH_COMP       ,
                   data.SALA_FORF_TEMP            ,
                   data.NOMB_JOUR_FORF_TEMP       ,
                   data.NOMB_HEUR_FORF_TEMP       ,
                   data.nomb_mois                 ,
                   replace(fct_format(data.sala_annu_cont, 'DEC2', 'O'), '.', ','),
                   data.code_fine_geog            ,
                   oEDIT.rib_guic_1               ,
                   oEDIT.rib_comp_1               ,
                   oEDIT.rib_cle_1                ,
                   oEDIT.rib_banq_01              ,
                   oEDIT.rib_banq_02              ,
                   oEdit.prof_temp_libe           ,
                   data.nomb_jour_cong_anci       ,
                   data.mont_anci_pa              ,
                   data.anci_cadr                 ,
                   data.tota_heur_trav            ,
                   oGeav.DPAE_ENVO                ,
                   oGeav.DISP_POLI_PUBL_CONV      ,
                   dDATE_ANCI_CADR_FORF 
                );
                commit;
             end loop;-- boucle analytique
          end loop;-- boucle salarie
      end loop;-- peri
   end loop;-- boucle societe

   pr_etat_pile_log(iID_SOCI,iID_LOGI,vETAT,'Regroupement des données avant affichage');

   for grp in (
      select
         max(l.code_cons_01                        ) as CODE_CONS_01                 ,
         max(l.code_cons_02                        ) as CODE_CONS_02                 ,
         max(l.code_cons_03                        ) as CODE_CONS_03                 ,
         max(l.code_cons_04                        ) as CODE_CONS_04                 ,
         max(l.code_cons_05                        ) as CODE_CONS_05                 ,
         max(l.code_cons_06                        ) as CODE_CONS_06                 ,
         max(l.code_cons_07                        ) as CODE_CONS_07                 ,
         max(l.code_cons_08                        ) as CODE_CONS_08                 ,
         max(l.code_cons_09                        ) as CODE_CONS_09                 ,
         max(l.code_cons_10                        ) as CODE_CONS_10                 ,
         max(l.code_cons_11                        ) as CODE_CONS_11                 ,
         max(l.code_cons_12                        ) as CODE_CONS_12                 ,
         max(l.code_cons_13                        ) as CODE_CONS_13                 ,
         max(l.code_cons_14                        ) as CODE_CONS_14                 ,
         max(l.code_cons_15                        ) as CODE_CONS_15                 ,
         max(l.code_cons_16                        ) as CODE_CONS_16                 ,
         max(l.code_cons_17                        ) as CODE_CONS_17                 ,
         max(l.code_cons_18                        ) as CODE_CONS_18                 ,
         max(l.code_cons_19                        ) as CODE_CONS_19                 ,
         max(l.code_cons_20                        ) as CODE_CONS_20                 ,

         max(l2.code_cons_21                        ) as CODE_CONS_21                 ,
         max(l2.code_cons_22                        ) as CODE_CONS_22                 ,
         max(l2.code_cons_23                        ) as CODE_CONS_23                 ,
         max(l2.code_cons_24                        ) as CODE_CONS_24                 ,
         max(l2.code_cons_25                        ) as CODE_CONS_25                 ,
         max(l2.code_cons_26                        ) as CODE_CONS_26                 ,
         max(l2.code_cons_27                        ) as CODE_CONS_27                 ,
         max(l2.code_cons_28                        ) as CODE_CONS_28                 ,
         max(l2.code_cons_29                        ) as CODE_CONS_29                 ,
         max(l2.code_cons_30                        ) as CODE_CONS_30                 ,
         max(l2.code_cons_31                        ) as CODE_CONS_31                 ,
         max(l2.code_cons_32                        ) as CODE_CONS_32                 ,
         max(l2.code_cons_33                        ) as CODE_CONS_33                 ,
         max(l2.code_cons_34                        ) as CODE_CONS_34                 ,
         max(l2.code_cons_35                        ) as CODE_CONS_35                 ,
         max(l2.code_cons_36                        ) as CODE_CONS_36                 ,
         max(l2.code_cons_37                        ) as CODE_CONS_37                 ,
         max(l2.code_cons_38                        ) as CODE_CONS_38                 ,
         max(l2.code_cons_39                        ) as CODE_CONS_39                 ,
         max(l2.code_cons_40                        ) as CODE_CONS_40                 ,
         max(l2.code_cons_41                        ) as CODE_CONS_41                 ,
         max(l2.code_cons_42                        ) as CODE_CONS_42                 ,
         max(l2.code_cons_43                        ) as CODE_CONS_43                 ,
         max(l2.code_cons_44                        ) as CODE_CONS_44                 ,
         max(l2.code_cons_45                        ) as CODE_CONS_45                 ,
         max(l2.code_cons_46                        ) as CODE_CONS_46                 ,
         max(l2.code_cons_47                        ) as CODE_CONS_47                 ,
         max(l2.code_cons_48                        ) as CODE_CONS_48                 ,
         max(l2.code_cons_49                        ) as CODE_CONS_49                 ,
         max(l2.code_cons_50                        ) as CODE_CONS_50                 ,

         max(to_date(e.peri, 'DD/MM/YYYY')         ) as PERI                         ,
         max(e.id_sala                             ) as ID_SALA                      ,
         max(e.nom                                 ) as NOM                          ,
         max(e.pren                                ) as PREN                         ,
         max(e.nom_jeun_fill                       ) as NOM_JEUN_FILL                ,
         max(e.titr                                ) as TITR                         ,
         max(e.id_cate                             ) as ID_CATE                      ,
         max(e.cate_prof                           ) as CATE_PROF                    ,
         max(e.conv_coll                           ) as CONV_COLL                    ,
         max(e.id_etab                             ) as ID_ETAB                      ,
         max(e.libe_etab                           ) as LIBE_ETAB                    ,
         max(e.libe_etab_cour                      ) as LIBE_ETAB_COUR               ,
         max(e.soci                                ) as SOCI                         ,
         max(e.rais_soci                           ) as RAIS_SOCI                    ,
         max(e.soci_orig                           ) as SOCI_ORIG                    ,
         max(e.fin_peri_essa                       ) as FIN_PERI_ESSA                ,
         max(e.droi_prim_anci                      ) as DROI_PRIM_ANCI               ,
         max(e.bic_01                              ) as BIC_01                       ,
         max(e.bic_02                              ) as BIC_02                       ,
         max(e.iban_01                             ) as IBAN_01                      ,
         max(e.iban_02                             ) as IBAN_02                      ,
         max(e.code_iso_pays_nati                  ) as CODE_ISO_PAYS_NATI           ,
         max(e.repa_anal_code                      ) as REPA_ANAL_CODE               ,
         max(e.regr                                ) as REGR                         ,
         max(e.mail_sala_cong                      ) as MAIL_SALA_CONG               ,
         max(e.resp_hier_1_nom                     ) as RESP_HIER_1_NOM              ,
         max(e.resp_hier_1_mail                    ) as RESP_HIER_1_MAIL             ,
         max(e.resp_hier_2_nom                     ) as RESP_HIER_2_NOM              ,
         max(e.resp_hier_2_mail                    ) as RESP_HIER_2_MAIL             ,
         max(e.hier_resp_1_nom                     ) as HIER_RESP_1_NOM              ,
         max(e.hier_resp_1_mail                    ) as HIER_RESP_1_MAIL             ,
         max(e.hier_resp_2_nom                     ) as HIER_RESP_2_NOM              ,
         max(e.hier_resp_2_mail                    ) as HIER_RESP_2_MAIL             ,
         max(e.rib_mode_paie                       ) as RIB_MODE_PAIE                ,
         max(e.rib_banq_1                          ) as RIB_BANQ_1                   ,
         max(e.rib_domi_1                          ) as RIB_DOMI_1                   ,
         max(e.rib_nume_1                          ) as RIB_NUME_1                   ,
         max(e.rib_titu_comp_1                     ) as RIB_TITU_COMP_1              ,
         max(e.rib_banq_2                          ) as RIB_BANQ_2                   ,
         max(e.rib_domi_2                          ) as RIB_DOMI_2                   ,
         max(e.rib_nume_2                          ) as RIB_NUME_2                   ,
         max(e.rib_titu_comp_2                     ) as RIB_TITU_COMP_2              ,
         max(e.tele_1                              ) as TELE_1                       ,
         max(e.tele_2                              ) as TELE_2                       ,
         max(e.tele_3                              ) as TELE_3                       ,
         max(e.adre                                ) as ADRE                         ,
         max(e.adre_comp) keep (dense_rank first order by e.peri desc, e.date_emba desc nulls first) as ADRE_COMP,
         max(e.adre_comm                           ) as ADRE_COMM                    ,
         max(e.adre_code_post                      ) as ADRE_CODE_POST               ,
         max(e.adre_pays                           ) as ADRE_PAYS                    ,
         max(e.ccn51_anci_date_chan_appl           ) as CCN51_ANCI_DATE_CHAN_APPL    ,
         max(e.ccn51_anci_taux                     ) as CCN51_ANCI_TAUX              ,
         max(e.ccn51_cadr_date_chan_appl           ) as CCN51_CADR_DATE_CHAN_APPL    ,
         max(e.ccn51_cadr_taux                     ) as CCN51_CADR_TAUX              ,
         max(e.etp_ccn51                           ) as ETP_CCN51                    ,
         max(e.ccn51_coef_acca                     ) as CCN51_COEF_ACCA              ,
         max(e.ccn51_coef_dipl                     ) as CCN51_COEF_DIPL              ,
         max(e.ccn51_coef_enca                     ) as CCN51_COEF_ENCA              ,
         max(e.ccn51_coef_fonc                     ) as CCN51_COEF_FONC              ,
         max(e.ccn51_coef_meti                     ) as CCN51_COEF_METI              ,
         max(e.ccn51_coef_recl                     ) as CCN51_COEF_RECL              ,
         max(e.ccn51_coef_spec                     ) as CCN51_COEF_SPEC              ,
         max(e.ccn51_id_empl_conv                  ) as CCN51_ID_EMPL_CONV           ,
         max(e.ccn5166_coef_refe                   ) as CCN5166_COEF_REFE            ,
         max(e.ccn66_cate_conv                     ) as CCN66_CATE_CONV              ,
         max(e.ccn66_date_chan_coef                ) as CCN66_DATE_CHAN_COEF         ,
         max(e.ccn66_empl_conv                     ) as CCN66_EMPL_CONV              ,
         max(e.ccn66_libe_empl_conv                ) as CCN66_LIBE_EMPL_CONV         ,
         max(e.ccn66_fili_conv                     ) as CCN66_FILI_CONV              ,
         max(e.ccn66_prec_date_chan_coef           ) as CCN66_PREC_DATE_CHAN_COEF    ,
         max(e.ccn66_proc_coef_refe                ) as CCN66_PROC_COEF_REFE         ,
         max(e.ccn66_regi                          ) as CCN66_REGI                   ,
         max(e.code_regi                           ) as CODE_REGI                    ,
         max(e.libe_regi                           ) as LIBE_REGI                    ,
         max(e.orga                                ) as ORGA                         ,
         max(e.unit                                ) as UNIT                         ,
         max(e.nume_fine                           ) as NUME_FINE                    ,
         max(e.nume_adel                           ) as NUME_ADEL                    ,
         max(e.nume_rpps                           ) as NUME_RPPS                    ,
         max(e.adre_elec                           ) as ADRE_ELEC                    ,
         max(e.code_titr_form                      ) as CODE_TITR_FORM               ,
         max(e.libe_titr_form                      ) as LIBE_TITR_FORM               ,
         max(e.date_titr_form                      ) as DATE_TITR_FORM               ,
         max(e.lieu_titr_form                      ) as LIEU_TITR_FORM               ,
         max(e.cham_util_1                         ) as CHAM_UTIL_1                  ,
         max(e.cham_util_2                         ) as CHAM_UTIL_2                  ,
         max(e.cham_util_3                         ) as CHAM_UTIL_3                  ,
         max(e.cham_util_4                         ) as CHAM_UTIL_4                  ,
         max(e.cham_util_5                         ) as CHAM_UTIL_5                  ,
         max(e.cham_util_6                         ) as CHAM_UTIL_6                  ,
         max(e.cham_util_7                         ) as CHAM_UTIL_7                  ,
         max(e.cham_util_8                         ) as CHAM_UTIL_8                  ,
         max(e.cham_util_9                         ) as CHAM_UTIL_9                  ,
         max(e.cham_util_10                        ) as CHAM_UTIL_10                 ,
         max(e.cham_util_11                        ) as CHAM_UTIL_11                 ,
         max(e.cham_util_12                        ) as CHAM_UTIL_12                 ,
         max(e.cham_util_13                        ) as CHAM_UTIL_13                 ,
         max(e.cham_util_14                        ) as CHAM_UTIL_14                 ,
         max(e.cham_util_15                        ) as CHAM_UTIL_15                 ,
         max(e.cham_util_16                        ) as CHAM_UTIL_16                 ,
         max(e.cham_util_17                        ) as CHAM_UTIL_17                 ,
         max(e.cham_util_18                        ) as CHAM_UTIL_18                 ,
         max(e.cham_util_19                        ) as CHAM_UTIL_19                 ,
         max(e.cham_util_20                        ) as CHAM_UTIL_20                 ,
         max(e.cham_util_21                        ) as CHAM_UTIL_21                 ,
         max(e.cham_util_22                        ) as CHAM_UTIL_22                 ,
         max(e.cham_util_23                        ) as CHAM_UTIL_23                 ,
         max(e.cham_util_24                        ) as CHAM_UTIL_24                 ,
         max(e.cham_util_25                        ) as CHAM_UTIL_25                 ,
         max(e.cham_util_26                        ) as CHAM_UTIL_26                 ,
         max(e.cham_util_27                        ) as CHAM_UTIL_27                 ,
         max(e.cham_util_28                        ) as CHAM_UTIL_28                 ,
         max(e.cham_util_29                        ) as CHAM_UTIL_29                 ,
         max(e.cham_util_30                        ) as CHAM_UTIL_30                 ,
         max(e.cham_util_31                        ) as CHAM_UTIL_31                 ,
         max(e.cham_util_32                        ) as CHAM_UTIL_32                 ,
         max(e.cham_util_33                        ) as CHAM_UTIL_33                 ,
         max(e.cham_util_34                        ) as CHAM_UTIL_34                 ,
         max(e.cham_util_35                        ) as CHAM_UTIL_35                 ,
         max(e.cham_util_36                        ) as CHAM_UTIL_36                 ,
         max(e.cham_util_37                        ) as CHAM_UTIL_37                 ,
         max(e.cham_util_38                        ) as CHAM_UTIL_38                 ,
         max(e.cham_util_39                        ) as CHAM_UTIL_39                 ,
         max(e.cham_util_40                        ) as CHAM_UTIL_40                 ,
         max(e.cham_util_41                        ) as CHAM_UTIL_41                 ,
         max(e.cham_util_42                        ) as CHAM_UTIL_42                 ,
         max(e.cham_util_43                        ) as CHAM_UTIL_43                 ,
         max(e.cham_util_44                        ) as CHAM_UTIL_44                 ,
         max(e.cham_util_45                        ) as CHAM_UTIL_45                 ,
         max(e.cham_util_46                        ) as CHAM_UTIL_46                 ,
         max(e.cham_util_47                        ) as CHAM_UTIL_47                 ,
         max(e.cham_util_48                        ) as CHAM_UTIL_48                 ,
         max(e.cham_util_49                        ) as CHAM_UTIL_49                 ,
         max(e.cham_util_50                        ) as CHAM_UTIL_50                 ,
         max(e.cham_util_51                        ) as CHAM_UTIL_51                 ,
         max(e.cham_util_52                        ) as CHAM_UTIL_52                 ,
         max(e.cham_util_53                        ) as CHAM_UTIL_53                 ,
         max(e.cham_util_54                        ) as CHAM_UTIL_54                 ,
         max(e.cham_util_55                        ) as CHAM_UTIL_55                 ,
         max(e.cham_util_56                        ) as CHAM_UTIL_56                 ,
         max(e.cham_util_57                        ) as CHAM_UTIL_57                 ,
         max(e.cham_util_58                        ) as CHAM_UTIL_58                 ,
         max(e.cham_util_59                        ) as CHAM_UTIL_59                 ,
         max(e.cham_util_60                        ) as CHAM_UTIL_60                 ,
         max(e.cham_util_61                        ) as CHAM_UTIL_61                 ,
         max(e.cham_util_62                        ) as CHAM_UTIL_62                 ,
         max(e.cham_util_63                        ) as CHAM_UTIL_63                 ,
         max(e.cham_util_64                        ) as CHAM_UTIL_64                 ,
         max(e.cham_util_65                        ) as CHAM_UTIL_65                 ,
         max(e.cham_util_66                        ) as CHAM_UTIL_66                 ,
         max(e.cham_util_67                        ) as CHAM_UTIL_67                 ,
         max(e.cham_util_68                        ) as CHAM_UTIL_68                 ,
         max(e.cham_util_69                        ) as CHAM_UTIL_69                 ,
         max(e.cham_util_70                        ) as CHAM_UTIL_70                 ,
         max(e.cham_util_71                        ) as CHAM_UTIL_71                 ,
         max(e.cham_util_72                        ) as CHAM_UTIL_72                 ,
         max(e.cham_util_73                        ) as CHAM_UTIL_73                 ,
         max(e.cham_util_74                        ) as CHAM_UTIL_74                 ,
         max(e.cham_util_75                        ) as CHAM_UTIL_75                 ,
         max(e.cham_util_76                        ) as CHAM_UTIL_76                 ,
         max(e.cham_util_77                        ) as CHAM_UTIL_77                 ,
         max(e.cham_util_78                        ) as CHAM_UTIL_78                 ,
         max(e.cham_util_79                        ) as CHAM_UTIL_79                 ,
         max(e.cham_util_80                        ) as CHAM_UTIL_80                 ,
         count(distinct e.nom                      ) as CNT_NOM                      ,
         count(distinct e.pren                     ) as CNT_PREN                     ,
         count(distinct e.nom_jeun_fill            ) as CNT_NOM_JEUN_FILL            ,
         count(distinct e.titr                     ) as CNT_TITR                     ,
         count(distinct e.id_cate                  ) as CNT_ID_CATE                  ,
         count(distinct e.cate_prof                ) as CNT_CATE_PROF                ,
         count(distinct e.conv_coll                ) as CNT_CONV_COLL                ,
         count(distinct e.id_etab                  ) as CNT_ID_ETAB                  ,
         count(distinct e.libe_etab                ) as CNT_LIBE_ETAB                ,
         count(distinct e.libe_etab_cour           ) as CNT_LIBE_ETAB_COUR           ,
         count(distinct e.soci                     ) as CNT_SOCI                     ,
         count(distinct e.peri                     ) as CNT_PERI                     ,
         count(distinct e.id_sala                  ) as CNT_ID_SALA                  ,
         count(distinct e.rais_soci                ) as CNT_RAIS_SOCI                ,
         count(distinct e.soci_orig                ) as CNT_SOCI_ORIG                ,
         count(distinct e.fin_peri_essa            ) as CNT_FIN_PERI_ESSA            ,
         count(distinct e.droi_prim_anci           ) as CNT_DROI_PRIM_ANCI           ,
         count(distinct e.bic_01                   ) as CNT_BIC_01                   ,
         count(distinct e.bic_02                   ) as CNT_BIC_02                   ,
         count(distinct e.iban_01                  ) as CNT_IBAN_01                  ,
         count(distinct e.iban_02                  ) as CNT_IBAN_02                  ,
         count(distinct e.code_iso_pays_nati       ) as CNT_CODE_ISO_PAYS_NATI       ,
         count(distinct e.repa_anal_code           ) as CNT_REPA_ANAL_CODE           ,
         count(distinct e.regr                     ) as CNT_REGR                     ,
         count(distinct e.mail_sala_cong           ) as CNT_MAIL_SALA_CONG           ,
         count(distinct e.resp_hier_1_nom          ) as CNT_RESP_HIER_1_NOM          ,
         count(distinct e.resp_hier_1_mail         ) as CNT_RESP_HIER_1_MAIL         ,
         count(distinct e.resp_hier_2_nom          ) as CNT_RESP_HIER_2_NOM          ,
         count(distinct e.resp_hier_2_mail         ) as CNT_RESP_HIER_2_MAIL         ,
         count(distinct e.hier_resp_1_nom          ) as CNT_HIER_RESP_1_NOM          ,
         count(distinct e.hier_resp_1_mail         ) as CNT_HIER_RESP_1_MAIL         ,
         count(distinct e.hier_resp_2_nom          ) as CNT_HIER_RESP_2_NOM          ,
         count(distinct e.hier_resp_2_mail         ) as CNT_HIER_RESP_2_MAIL         ,
         count(distinct e.rib_mode_paie            ) as CNT_RIB_MODE_PAIE            ,
         count(distinct e.rib_banq_1               ) as CNT_RIB_BANQ_1               ,
         count(distinct e.rib_domi_1               ) as CNT_RIB_DOMI_1               ,
         count(distinct e.rib_nume_1               ) as CNT_RIB_NUME_1               ,
         count(distinct e.rib_titu_comp_1          ) as CNT_RIB_TITU_COMP_1          ,
         count(distinct e.rib_banq_2               ) as CNT_RIB_BANQ_2               ,
         count(distinct e.rib_domi_2               ) as CNT_RIB_DOMI_2               ,
         count(distinct e.rib_nume_2               ) as CNT_RIB_NUME_2               ,
         count(distinct e.rib_titu_comp_2          ) as CNT_RIB_TITU_COMP_2          ,
         count(distinct e.tele_1                   ) as CNT_TELE_1                   ,
         count(distinct e.tele_2                   ) as CNT_TELE_2                   ,
         count(distinct e.tele_3                   ) as CNT_TELE_3                   ,
         count(distinct e.adre                     ) as CNT_ADRE                     ,
         count(distinct e.adre_comp                ) as CNT_ADRE_COMP                ,
         count(distinct e.adre_comm                ) as CNT_ADRE_COMM                ,
         count(distinct e.adre_code_post           ) as CNT_ADRE_CODE_POST           ,
         count(distinct e.adre_pays                ) as CNT_ADRE_PAYS                ,
         count(distinct e.ccn51_anci_date_chan_appl) as CNT_CCN51_ANCI_DATE_CHAN_APPL,
         count(distinct e.ccn51_anci_taux          ) as CNT_CCN51_ANCI_TAUX          ,
         count(distinct e.ccn51_cadr_date_chan_appl) as CNT_CCN51_CADR_DATE_CHAN_APPL,
         count(distinct e.ccn51_cadr_taux          ) as CNT_CCN51_CADR_TAUX          ,
         count(distinct e.etp_ccn51                ) as CNT_ETP_CCN51                ,
         count(distinct e.ccn51_coef_acca          ) as CNT_CCN51_COEF_ACCA          ,
         count(distinct e.ccn51_coef_dipl          ) as CNT_CCN51_COEF_DIPL          ,
         count(distinct e.ccn51_coef_enca          ) as CNT_CCN51_COEF_ENCA          ,
         count(distinct e.ccn51_coef_fonc          ) as CNT_CCN51_COEF_FONC          ,
         count(distinct e.ccn51_coef_meti          ) as CNT_CCN51_COEF_METI          ,
         count(distinct e.ccn51_coef_recl          ) as CNT_CCN51_COEF_RECL          ,
         count(distinct e.ccn51_coef_spec          ) as CNT_CCN51_COEF_SPEC          ,
         count(distinct e.ccn51_id_empl_conv       ) as CNT_CCN51_ID_EMPL_CONV       ,
         count(distinct e.ccn5166_coef_refe        ) as CNT_CCN5166_COEF_REFE        ,
         count(distinct e.ccn66_cate_conv          ) as CNT_CCN66_CATE_CONV          ,
         count(distinct e.ccn66_date_chan_coef     ) as CNT_CCN66_DATE_CHAN_COEF     ,
         count(distinct e.ccn66_empl_conv          ) as CNT_CCN66_EMPL_CONV          ,
         count(distinct e.ccn66_libe_empl_conv     ) as CNT_CCN66_LIBE_EMPL_CONV     ,
         count(distinct e.ccn66_fili_conv          ) as CNT_CCN66_FILI_CONV          ,
         count(distinct e.ccn66_prec_date_chan_coef) as CNT_CCN66_PREC_DATE_CHAN_COEF,
         count(distinct e.ccn66_proc_coef_refe     ) as CNT_CCN66_PROC_COEF_REFE     ,
         count(distinct e.ccn66_regi               ) as CNT_CCN66_REGI               ,
         count(distinct e.code_regi                ) as CNT_CODE_REGI                ,
         count(distinct e.libe_regi                ) as CNT_LIBE_REGI                ,
         count(distinct e.orga                     ) as CNT_ORGA                     ,
         count(distinct e.unit                     ) as CNT_UNIT                     ,
         count(distinct e.nume_fine                ) as CNT_NUME_FINE                ,
         count(distinct e.nume_adel                ) as CNT_NUME_ADEL                ,
         count(distinct e.nume_rpps                ) as CNT_NUME_RPPS                ,
         count(distinct e.adre_elec                ) as CNT_ADRE_ELEC                ,
         count(distinct e.code_titr_form           ) as CNT_CODE_TITR_FORM           ,
         count(distinct e.libe_titr_form           ) as CNT_LIBE_TITR_FORM           ,
         count(distinct e.date_titr_form           ) as CNT_DATE_TITR_FORM           ,
         count(distinct e.lieu_titr_form           ) as CNT_LIEU_TITR_FORM           ,
         count(distinct e.cham_util_1              ) as CNT_CHAM_UTIL_1              ,
         count(distinct e.cham_util_2              ) as CNT_CHAM_UTIL_2              ,
         count(distinct e.cham_util_3              ) as CNT_CHAM_UTIL_3              ,
         count(distinct e.cham_util_4              ) as CNT_CHAM_UTIL_4              ,
         count(distinct e.cham_util_5              ) as CNT_CHAM_UTIL_5              ,
         count(distinct e.cham_util_6              ) as CNT_CHAM_UTIL_6              ,
         count(distinct e.cham_util_7              ) as CNT_CHAM_UTIL_7              ,
         count(distinct e.cham_util_8              ) as CNT_CHAM_UTIL_8              ,
         count(distinct e.cham_util_9              ) as CNT_CHAM_UTIL_9              ,
         count(distinct e.cham_util_10             ) as CNT_CHAM_UTIL_10             ,
         count(distinct e.cham_util_11             ) as CNT_CHAM_UTIL_11             ,
         count(distinct e.cham_util_12             ) as CNT_CHAM_UTIL_12             ,
         count(distinct e.cham_util_13             ) as CNT_CHAM_UTIL_13             ,
         count(distinct e.cham_util_14             ) as CNT_CHAM_UTIL_14             ,
         count(distinct e.cham_util_15             ) as CNT_CHAM_UTIL_15             ,
         count(distinct e.cham_util_16             ) as CNT_CHAM_UTIL_16             ,
         count(distinct e.cham_util_17             ) as CNT_CHAM_UTIL_17             ,
         count(distinct e.cham_util_18             ) as CNT_CHAM_UTIL_18             ,
         count(distinct e.cham_util_19             ) as CNT_CHAM_UTIL_19             ,
         count(distinct e.cham_util_20             ) as CNT_CHAM_UTIL_20             ,
         count(distinct e.cham_util_21             ) as CNT_CHAM_UTIL_21             ,
         count(distinct e.cham_util_22             ) as CNT_CHAM_UTIL_22             ,
         count(distinct e.cham_util_23             ) as CNT_CHAM_UTIL_23             ,
         count(distinct e.cham_util_24             ) as CNT_CHAM_UTIL_24             ,
         count(distinct e.cham_util_25             ) as CNT_CHAM_UTIL_25             ,
         count(distinct e.cham_util_26             ) as CNT_CHAM_UTIL_26             ,
         count(distinct e.cham_util_27             ) as CNT_CHAM_UTIL_27             ,
         count(distinct e.cham_util_28             ) as CNT_CHAM_UTIL_28             ,
         count(distinct e.cham_util_29             ) as CNT_CHAM_UTIL_29             ,
         count(distinct e.cham_util_30             ) as CNT_CHAM_UTIL_30             ,
         count(distinct e.cham_util_31             ) as CNT_CHAM_UTIL_31             ,
         count(distinct e.cham_util_32             ) as CNT_CHAM_UTIL_32             ,
         count(distinct e.cham_util_33             ) as CNT_CHAM_UTIL_33             ,
         count(distinct e.cham_util_34             ) as CNT_CHAM_UTIL_34             ,
         count(distinct e.cham_util_35             ) as CNT_CHAM_UTIL_35             ,
         count(distinct e.cham_util_36             ) as CNT_CHAM_UTIL_36             ,
         count(distinct e.cham_util_37             ) as CNT_CHAM_UTIL_37             ,
         count(distinct e.cham_util_38             ) as CNT_CHAM_UTIL_38             ,
         count(distinct e.cham_util_39             ) as CNT_CHAM_UTIL_39             ,
         count(distinct e.cham_util_40             ) as CNT_CHAM_UTIL_40             ,
         count(distinct e.cham_util_41             ) as CNT_CHAM_UTIL_41             ,
         count(distinct e.cham_util_42             ) as CNT_CHAM_UTIL_42             ,
         count(distinct e.cham_util_43             ) as CNT_CHAM_UTIL_43             ,
         count(distinct e.cham_util_44             ) as CNT_CHAM_UTIL_44             ,
         count(distinct e.cham_util_45             ) as CNT_CHAM_UTIL_45             ,
         count(distinct e.cham_util_46             ) as CNT_CHAM_UTIL_46             ,
         count(distinct e.cham_util_47             ) as CNT_CHAM_UTIL_47             ,
         count(distinct e.cham_util_48             ) as CNT_CHAM_UTIL_48             ,
         count(distinct e.cham_util_49             ) as CNT_CHAM_UTIL_49             ,
         count(distinct e.cham_util_50             ) as CNT_CHAM_UTIL_50             ,
         count(distinct e.cham_util_51             ) as CNT_CHAM_UTIL_51             ,
         count(distinct e.cham_util_52             ) as CNT_CHAM_UTIL_52             ,
         count(distinct e.cham_util_53             ) as CNT_CHAM_UTIL_53             ,
         count(distinct e.cham_util_54             ) as CNT_CHAM_UTIL_54             ,
         count(distinct e.cham_util_55             ) as CNT_CHAM_UTIL_55             ,
         count(distinct e.cham_util_56             ) as CNT_CHAM_UTIL_56             ,
         count(distinct e.cham_util_57             ) as CNT_CHAM_UTIL_57             ,
         count(distinct e.cham_util_58             ) as CNT_CHAM_UTIL_58             ,
         count(distinct e.cham_util_59             ) as CNT_CHAM_UTIL_59             ,
         count(distinct e.cham_util_60             ) as CNT_CHAM_UTIL_60             ,
         count(distinct e.cham_util_61             ) as CNT_CHAM_UTIL_61             ,
         count(distinct e.cham_util_62             ) as CNT_CHAM_UTIL_62             ,
         count(distinct e.cham_util_63             ) as CNT_CHAM_UTIL_63             ,
         count(distinct e.cham_util_64             ) as CNT_CHAM_UTIL_64             ,
         count(distinct e.cham_util_65             ) as CNT_CHAM_UTIL_65             ,
         count(distinct e.cham_util_66             ) as CNT_CHAM_UTIL_66             ,
         count(distinct e.cham_util_67             ) as CNT_CHAM_UTIL_67             ,
         count(distinct e.cham_util_68             ) as CNT_CHAM_UTIL_68             ,
         count(distinct e.cham_util_69             ) as CNT_CHAM_UTIL_69             ,
         count(distinct e.cham_util_70             ) as CNT_CHAM_UTIL_70             ,
         count(distinct e.cham_util_71             ) as CNT_CHAM_UTIL_71             ,
         count(distinct e.cham_util_72             ) as CNT_CHAM_UTIL_72             ,
         count(distinct e.cham_util_73             ) as CNT_CHAM_UTIL_73             ,
         count(distinct e.cham_util_74             ) as CNT_CHAM_UTIL_74             ,
         count(distinct e.cham_util_75             ) as CNT_CHAM_UTIL_75             ,
         count(distinct e.cham_util_76             ) as CNT_CHAM_UTIL_76             ,
         count(distinct e.cham_util_77             ) as CNT_CHAM_UTIL_77             ,
         count(distinct e.cham_util_78             ) as CNT_CHAM_UTIL_78             ,
         count(distinct e.cham_util_79             ) as CNT_CHAM_UTIL_79             ,
         count(distinct e.cham_util_80             ) as CNT_CHAM_UTIL_80             ,
         sum(nvl( e.rubr_01, 0))                     as SUM_RUBR_01                  ,
         sum(nvl( e.rubr_02, 0))                     as SUM_RUBR_02                  ,
         sum(nvl( e.rubr_03, 0))                     as SUM_RUBR_03                  ,
         sum(nvl( e.rubr_04, 0))                     as SUM_RUBR_04                  ,
         sum(nvl( e.rubr_05, 0))                     as SUM_RUBR_05                  ,
         sum(nvl( e.rubr_06, 0))                     as SUM_RUBR_06                  ,
         sum(nvl( e.rubr_07, 0))                     as SUM_RUBR_07                  ,
         sum(nvl( e.rubr_08, 0))                     as SUM_RUBR_08                  ,
         sum(nvl( e.rubr_09, 0))                     as SUM_RUBR_09                  ,
         sum(nvl( e.rubr_10, 0))                     as SUM_RUBR_10                  ,
         sum(nvl( e.rubr_11, 0))                     as SUM_RUBR_11                  ,
         sum(nvl( e.rubr_12, 0))                     as SUM_RUBR_12                  ,
         sum(nvl( e.rubr_13, 0))                     as SUM_RUBR_13                  ,
         sum(nvl( e.rubr_14, 0))                     as SUM_RUBR_14                  ,
         sum(nvl( e.rubr_15, 0))                     as SUM_RUBR_15                  ,
         sum(nvl( e.rubr_16, 0))                     as SUM_RUBR_16                  ,
         sum(nvl( e.rubr_17, 0))                     as SUM_RUBR_17                  ,
         sum(nvl( e.rubr_18, 0))                     as SUM_RUBR_18                  ,
         sum(nvl( e.rubr_19, 0))                     as SUM_RUBR_19                  ,
         sum(nvl( e.rubr_20, 0))                     as SUM_RUBR_20                  ,
         sum(nvl( e.rubr_21, 0))                     as SUM_RUBR_21                  ,
         sum(nvl( e.rubr_22, 0))                     as SUM_RUBR_22                  ,
         sum(nvl( e.rubr_23, 0))                     as SUM_RUBR_23                  ,
         sum(nvl( e.rubr_24, 0))                     as SUM_RUBR_24                  ,
         sum(nvl( e.rubr_25, 0))                     as SUM_RUBR_25                  ,
         sum(nvl( e.rubr_26, 0))                     as SUM_RUBR_26                  ,
         sum(nvl( e.rubr_27, 0))                     as SUM_RUBR_27                  ,
         sum(nvl( e.rubr_28, 0))                     as SUM_RUBR_28                  ,
         sum(nvl( e.rubr_29, 0))                     as SUM_RUBR_29                  ,
         sum(nvl( e.rubr_30, 0))                     as SUM_RUBR_30                  ,
         sum(nvl( e.rubr_31, 0))                     as SUM_RUBR_31                  ,
         sum(nvl( e.rubr_32, 0))                     as SUM_RUBR_32                  ,
         sum(nvl( e.rubr_33, 0))                     as SUM_RUBR_33                  ,
         sum(nvl( e.rubr_34, 0))                     as SUM_RUBR_34                  ,
         sum(nvl( e.rubr_35, 0))                     as SUM_RUBR_35                  ,
         sum(nvl( e.rubr_36, 0))                     as SUM_RUBR_36                  ,
         sum(nvl( e.rubr_37, 0))                     as SUM_RUBR_37                  ,
         sum(nvl( e.rubr_38, 0))                     as SUM_RUBR_38                  ,
         sum(nvl( e.rubr_39, 0))                     as SUM_RUBR_39                  ,
         sum(nvl( e.rubr_40, 0))                     as SUM_RUBR_40                  ,
         sum(nvl( e.rubr_41, 0))                     as SUM_RUBR_41                  ,
         sum(nvl( e.rubr_42, 0))                     as SUM_RUBR_42                  ,
         sum(nvl( e.rubr_43, 0))                     as SUM_RUBR_43                  ,
         sum(nvl( e.rubr_44, 0))                     as SUM_RUBR_44                  ,
         sum(nvl( e.rubr_45, 0))                     as SUM_RUBR_45                  ,
         sum(nvl( e.rubr_46, 0))                     as SUM_RUBR_46                  ,
         sum(nvl( e.rubr_47, 0))                     as SUM_RUBR_47                  ,
         sum(nvl( e.rubr_48, 0))                     as SUM_RUBR_48                  ,
         sum(nvl( e.rubr_49, 0))                     as SUM_RUBR_49                  ,
         sum(nvl( e.rubr_50, 0))                     as SUM_RUBR_50                  ,

         sum(nvl( e.rubr_51, 0))                     as SUM_RUBR_51                  ,
         sum(nvl( e.rubr_52, 0))                     as SUM_RUBR_52                  ,
         sum(nvl( e.rubr_53, 0))                     as SUM_RUBR_53                  ,
         sum(nvl( e.rubr_54, 0))                     as SUM_RUBR_54                  ,
         sum(nvl( e.rubr_55, 0))                     as SUM_RUBR_55                  ,
         sum(nvl( e.rubr_56, 0))                     as SUM_RUBR_56                  ,
         sum(nvl( e.rubr_57, 0))                     as SUM_RUBR_57                  ,
         sum(nvl( e.rubr_58, 0))                     as SUM_RUBR_58                  ,
         sum(nvl( e.rubr_59, 0))                     as SUM_RUBR_59                  ,
         sum(nvl( e.rubr_60, 0))                     as SUM_RUBR_60                  ,
         sum(nvl( e.rubr_61, 0))                     as SUM_RUBR_61                  ,
         sum(nvl( e.rubr_62, 0))                     as SUM_RUBR_62                  ,
         sum(nvl( e.rubr_63, 0))                     as SUM_RUBR_63                  ,
         sum(nvl( e.rubr_64, 0))                     as SUM_RUBR_64                  ,
         sum(nvl( e.rubr_65, 0))                     as SUM_RUBR_65                  ,
         sum(nvl( e.rubr_66, 0))                     as SUM_RUBR_66                  ,
         sum(nvl( e.rubr_67, 0))                     as SUM_RUBR_67                  ,
         sum(nvl( e.rubr_68, 0))                     as SUM_RUBR_68                  ,
         sum(nvl( e.rubr_69, 0))                     as SUM_RUBR_69                  ,
         sum(nvl( e.rubr_70, 0))                     as SUM_RUBR_70                  ,
         sum(nvl( e.rubr_71, 0))                     as SUM_RUBR_71                  ,
         sum(nvl( e.rubr_72, 0))                     as SUM_RUBR_72                  ,
         sum(nvl( e.rubr_73, 0))                     as SUM_RUBR_73                  ,
         sum(nvl( e.rubr_74, 0))                     as SUM_RUBR_74                  ,
         sum(nvl( e.rubr_75, 0))                     as SUM_RUBR_75                  ,
         sum(nvl( e.rubr_76, 0))                     as SUM_RUBR_76                  ,
         sum(nvl( e.rubr_77, 0))                     as SUM_RUBR_77                  ,
         sum(nvl( e.rubr_78, 0))                     as SUM_RUBR_78                  ,
         sum(nvl( e.rubr_79, 0))                     as SUM_RUBR_79                  ,
         sum(nvl( e.rubr_80, 0))                     as SUM_RUBR_80                  ,
         sum(nvl( e.rubr_81, 0))                     as SUM_RUBR_81                  ,
         sum(nvl( e.rubr_82, 0))                     as SUM_RUBR_82                  ,
         sum(nvl( e.rubr_83, 0))                     as SUM_RUBR_83                  ,
         sum(nvl( e.rubr_84, 0))                     as SUM_RUBR_84                  ,
         sum(nvl( e.rubr_85, 0))                     as SUM_RUBR_85                  ,
         sum(nvl( e.rubr_86, 0))                     as SUM_RUBR_86                  ,
         sum(nvl( e.rubr_87, 0))                     as SUM_RUBR_87                  ,
         sum(nvl( e.rubr_88, 0))                     as SUM_RUBR_88                  ,
         sum(nvl( e.rubr_89, 0))                     as SUM_RUBR_89                  ,
         sum(nvl( e.rubr_90, 0))                     as SUM_RUBR_90                  ,
         sum(nvl( e.rubr_91, 0))                     as SUM_RUBR_91                  ,
         sum(nvl( e.rubr_92, 0))                     as SUM_RUBR_92                  ,
         sum(nvl( e.rubr_93, 0))                     as SUM_RUBR_93                  ,
         sum(nvl( e.rubr_94, 0))                     as SUM_RUBR_94                  ,
         sum(nvl( e.rubr_95, 0))                     as SUM_RUBR_95                  ,
         sum(nvl( e.rubr_96, 0))                     as SUM_RUBR_96                  ,
         sum(nvl( e.rubr_97, 0))                     as SUM_RUBR_97                  ,
         sum(nvl( e.rubr_98, 0))                     as SUM_RUBR_98                  ,
         sum(nvl( e.rubr_99, 0))                     as SUM_RUBR_99                  ,
         sum(nvl( e.rubr_100, 0))                    as SUM_RUBR_100                 ,
         sum(nvl( e.rubr_101, 0))                    as SUM_RUBR_101                 ,
         sum(nvl( e.rubr_102, 0))                    as SUM_RUBR_102                 ,
         sum(nvl( e.rubr_103, 0))                    as SUM_RUBR_103                 ,
         sum(nvl( e.rubr_104, 0))                    as SUM_RUBR_104                 ,
         sum(nvl( e.rubr_105, 0))                    as SUM_RUBR_105                 ,
         sum(nvl( e.rubr_106, 0))                    as SUM_RUBR_106                 ,
         sum(nvl( e.rubr_107, 0))                    as SUM_RUBR_107                 ,
         sum(nvl( e.rubr_108, 0))                    as SUM_RUBR_108                 ,
         sum(nvl( e.rubr_109, 0))                    as SUM_RUBR_109                 ,
         sum(nvl( e.rubr_110, 0))                    as SUM_RUBR_110                 ,
         sum(nvl( e.rubr_111, 0))                    as SUM_RUBR_111                 ,
         sum(nvl( e.rubr_112, 0))                    as SUM_RUBR_112                 ,
         sum(nvl( e.rubr_113, 0))                    as SUM_RUBR_113                 ,
         sum(nvl( e.rubr_114, 0))                    as SUM_RUBR_114                 ,
         sum(nvl( e.rubr_115, 0))                    as SUM_RUBR_115                 ,
         sum(nvl( e.rubr_116, 0))                    as SUM_RUBR_116                 ,
         sum(nvl( e.rubr_117, 0))                    as SUM_RUBR_117                 ,
         sum(nvl( e.rubr_118, 0))                    as SUM_RUBR_118                 ,
         sum(nvl( e.rubr_119, 0))                    as SUM_RUBR_119                 ,
         sum(nvl( e.rubr_120, 0))                    as SUM_RUBR_120                 ,
         sum(nvl( e.rubr_121, 0))                    as SUM_RUBR_121                 ,
         sum(nvl( e.rubr_122, 0))                    as SUM_RUBR_122                 ,
         sum(nvl( e.rubr_123, 0))                    as SUM_RUBR_123                 ,
         sum(nvl( e.rubr_124, 0))                    as SUM_RUBR_124                 ,
         sum(nvl( e.rubr_125, 0))                    as SUM_RUBR_125                 ,
         sum(nvl( e.rubr_126, 0))                    as SUM_RUBR_126                 ,
         sum(nvl( e.rubr_127, 0))                    as SUM_RUBR_127                 ,
         sum(nvl( e.rubr_128, 0))                    as SUM_RUBR_128                 ,
         sum(nvl( e.rubr_129, 0))                    as SUM_RUBR_129                 ,
         sum(nvl( e.rubr_130, 0))                    as SUM_RUBR_130                 ,
         sum(nvl( e.rubr_131, 0))                    as SUM_RUBR_131                 ,
         sum(nvl( e.rubr_132, 0))                    as SUM_RUBR_132                 ,
         sum(nvl( e.rubr_133, 0))                    as SUM_RUBR_133                 ,
         sum(nvl( e.rubr_134, 0))                    as SUM_RUBR_134                 ,
         sum(nvl( e.rubr_135, 0))                    as SUM_RUBR_135                 ,
         sum(nvl( e.rubr_136, 0))                    as SUM_RUBR_136                 ,
         sum(nvl( e.rubr_137, 0))                    as SUM_RUBR_137                 ,
         sum(nvl( e.rubr_138, 0))                    as SUM_RUBR_138                 ,
         sum(nvl( e.rubr_139, 0))                    as SUM_RUBR_139                 ,
         sum(nvl( e.rubr_140, 0))                    as SUM_RUBR_140                 ,
         sum(nvl( e.rubr_141, 0))                    as SUM_RUBR_141                 ,
         sum(nvl( e.rubr_142, 0))                    as SUM_RUBR_142                 ,
         sum(nvl( e.rubr_143, 0))                    as SUM_RUBR_143                 ,
         sum(nvl( e.rubr_144, 0))                    as SUM_RUBR_144                 ,
         sum(nvl( e.rubr_145, 0))                    as SUM_RUBR_145                 ,
         sum(nvl( e.rubr_146, 0))                    as SUM_RUBR_146                 ,
         sum(nvl( e.rubr_147, 0))                    as SUM_RUBR_147                 ,
         sum(nvl( e.rubr_148, 0))                    as SUM_RUBR_148                 ,
         sum(nvl( e.rubr_149, 0))                    as SUM_RUBR_149                 ,
         sum(nvl( e.rubr_150, 0))                    as SUM_RUBR_150                 ,

         sum(nvl( e.cons_01, 0))                     as CONS_01                      ,
         sum(nvl( e.cons_02, 0))                     as CONS_02                      ,
         sum(nvl( e.cons_03, 0))                     as CONS_03                      ,
         sum(nvl( e.cons_04, 0))                     as CONS_04                      ,
         sum(nvl( e.cons_05, 0))                     as CONS_05                      ,
         sum(nvl( e.cons_06, 0))                     as CONS_06                      ,
         sum(nvl( e.cons_07, 0))                     as CONS_07                      ,
         sum(nvl( e.cons_08, 0))                     as CONS_08                      ,
         sum(nvl( e.cons_09, 0))                     as CONS_09                      ,
         sum(nvl( e.cons_10, 0))                     as CONS_10                      ,
         sum(nvl( e.cons_11, 0))                     as CONS_11                      ,
         sum(nvl( e.cons_12, 0))                     as CONS_12                      ,
         sum(nvl( e.cons_13, 0))                     as CONS_13                      ,
         sum(nvl( e.cons_14, 0))                     as CONS_14                      ,
         sum(nvl( e.cons_15, 0))                     as CONS_15                      ,
         sum(nvl( e.cons_16, 0))                     as CONS_16                      ,
         sum(nvl( e.cons_17, 0))                     as CONS_17                      ,
         sum(nvl( e.cons_18, 0))                     as CONS_18                      ,
         sum(nvl( e.cons_19, 0))                     as CONS_19                      ,
         sum(nvl( e.cons_20, 0))                     as CONS_20                      ,

         sum(nvl( e.cons_21, 0))                     as CONS_21                      ,
         sum(nvl( e.cons_22, 0))                     as CONS_22                      ,
         sum(nvl( e.cons_23, 0))                     as CONS_23                      ,
         sum(nvl( e.cons_24, 0))                     as CONS_24                      ,
         sum(nvl( e.cons_25, 0))                     as CONS_25                      ,
         sum(nvl( e.cons_26, 0))                     as CONS_26                      ,
         sum(nvl( e.cons_27, 0))                     as CONS_27                      ,
         sum(nvl( e.cons_28, 0))                     as CONS_28                      ,
         sum(nvl( e.cons_29, 0))                     as CONS_29                      ,
         sum(nvl( e.cons_30, 0))                     as CONS_30                      ,
         sum(nvl( e.cons_31, 0))                     as CONS_31                      ,
         sum(nvl( e.cons_32, 0))                     as CONS_32                      ,
         sum(nvl( e.cons_33, 0))                     as CONS_33                      ,
         sum(nvl( e.cons_34, 0))                     as CONS_34                      ,
         sum(nvl( e.cons_35, 0))                     as CONS_35                      ,
         sum(nvl( e.cons_36, 0))                     as CONS_36                      ,
         sum(nvl( e.cons_37, 0))                     as CONS_37                      ,
         sum(nvl( e.cons_38, 0))                     as CONS_38                      ,
         sum(nvl( e.cons_39, 0))                     as CONS_39                      ,
         sum(nvl( e.cons_40, 0))                     as CONS_40                      ,
         sum(nvl( e.cons_41, 0))                     as CONS_41                      ,
         sum(nvl( e.cons_42, 0))                     as CONS_42                      ,
         sum(nvl( e.cons_43, 0))                     as CONS_43                      ,
         sum(nvl( e.cons_44, 0))                     as CONS_44                      ,
         sum(nvl( e.cons_45, 0))                     as CONS_45                      ,
         sum(nvl( e.cons_46, 0))                     as CONS_46                      ,
         sum(nvl( e.cons_47, 0))                     as CONS_47                      ,
         sum(nvl( e.cons_48, 0))                     as CONS_48                      ,
         sum(nvl( e.cons_49, 0))                     as CONS_49                      ,
         sum(nvl( e.cons_50, 0))                     as CONS_50                      ,

         sum(nvl( e.calc_01, 0))                     as CALC_01                      ,
         sum(nvl( e.calc_02, 0))                     as CALC_02                      ,
         sum(nvl( e.calc_03, 0))                     as CALC_03                      ,
         sum(nvl( e.calc_04, 0))                     as CALC_04                      ,
         sum(nvl( e.calc_05, 0))                     as CALC_05                      ,
         sum(nvl( e.calc_06, 0))                     as CALC_06                      ,
         sum(nvl( e.calc_07, 0))                     as CALC_07                      ,
         sum(nvl( e.calc_08, 0))                     as CALC_08                      ,
         sum(nvl( e.calc_09, 0))                     as CALC_09                      ,
         sum(nvl( e.calc_10, 0))                     as CALC_10                      ,
         sum(nvl( e.calc_11, 0))                     as CALC_11                      ,
         sum(nvl( e.calc_12, 0))                     as CALC_12                      ,
         sum(nvl( e.calc_13, 0))                     as CALC_13                      ,
         sum(nvl( e.calc_14, 0))                     as CALC_14                      ,
         sum(nvl( e.calc_15, 0))                     as CALC_15                      ,
         sum(nvl( e.calc_16, 0))                     as CALC_16                      ,
         sum(nvl( e.calc_17, 0))                     as CALC_17                      ,
         sum(nvl( e.calc_18, 0))                     as CALC_18                      ,
         sum(nvl( e.calc_19, 0))                     as CALC_19                      ,
         sum(nvl( e.calc_20, 0))                     as CALC_20                      ,
         count(1)                                    as CNT                          ,
         max(e.matr_grou                          )  as MATR_GROU                    ,
         max(e.matr_resp_hier                     )  as MATR_RESP_HIER               ,
         max(e.date_anci_prof                     )  as DATE_ANCI_PROF               ,
         max(e.date_refe_01                       )  as DATE_REFE_01                 ,
         max(e.date_refe_02                       )  as DATE_REFE_02                 ,
         max(e.date_refe_03                       )  as DATE_REFE_03                 ,
         max(e.date_refe_04                       )  as DATE_REFE_04                 ,
         max(e.date_refe_05                       )  as DATE_REFE_05                 ,
         max(e.date_sign_conv_stag                )  as DATE_SIGN_CONV_STAG          ,
         max(e.matr                               )  as MATR                         ,
         max(e.adre_mail                          )  as ADRE_MAIL                    ,
         max(e.adre_mail_pers                     )  as ADRE_MAIL_PERS               ,
         max(e.nive_qual                          )  as NIVE_QUAL                    ,
         max(e.moti_depa                          )  as MOTI_DEPA                    ,
         max(e.moti_augm                          )  as MOTI_AUGM                    ,
         max(e.moti_augm_2                        )  as moti_augm_2                  ,---KFH 25/05/2023 T184292
         max(e.TICK_REST_TYPE_REPA                )  as TICK_REST_TYPE_REPA          ,---KFH 03/04/2024 T201908
         max(e.sala_auto_titr_trav                )  as sala_auto_titr_trav          ,
         max(e.lieu_pres_stag                     )  as lieu_pres_stag               ,
         max(e.sexe                               )  as SEXE                         ,
         max(e.reac_regu                          )  as REAC_REGU                    ,
         max(e.serv                               )  as SERV                         ,
         max(e.depa                               )  as DEPA                         ,
         max(e.empl                               )  as EMPL                         ,
         max(e.empl_type                          )  as EMPL_TYPE                    ,
         max(e.meti                               )  as METI                         ,
         max(e.fami_meti                          )  as FAMI_METI                    ,
         max(e.fami_meti_hier                     )  as FAMI_METI_HIER               ,
         max(e.code_empl                          )  as CODE_EMPL                    ,
         max(e.code_cate                          )  as CODE_CATE                    ,
         max(e.coef                               )  as COEF                         ,
         max(e.sire_etab                               )  as SIRE_ETAB                         ,
         max(e.dipl                               )  as DIPL                         ,
         max(e.code_unit                               )  as CODE_UNIT                         ,
         max(e.code_regr_fich_comp_etab           )  as CODE_REGR_FICH_COMP_ETAB,
         max(e.nive                               )  as NIVE                         ,
         max(e.eche                               )  as ECHE                         ,
         max(e.grou_conv                          )  as GROU_CONV                    ,
         max(e.posi                               )  as POSI                         ,
         max(e.indi                               )  as INDI                         ,
         max(e.cota                               )  as COTA                         ,
         max(e.clas                               )  as CLAS                         ,
         max(e.seui                               )  as SEUI                         ,
         max(e.pali                               )  as PALI                         ,
         max(e.grad                               )  as GRAD                         ,
         max(e.degr                               )  as DEGR                         ,
         max(e.fili                               )  as FILI                         ,
         max(e.sect_prof                          )  as SECT_PROF                    ,
         max(e.comp_brut                          )  as COMP_BRUT                    ,
         max(e.comp_paye                          )  as COMP_PAYE                    ,
         max(e.comp_acom                          )  as COMP_ACOM                    ,
         max(e.nume_secu                          )  as NUME_SECU                    ,
         max(e.date_emba                          )  as DATE_EMBA                    ,
         max(e.date_depa) keep (dense_rank first order by e.peri desc, e.date_emba desc nulls first)  as DATE_DEPA,
         max(e.date_anci                          )  as DATE_ANCI                    ,
         max(e.date_dela_prev                     )  as DATE_DELA_PREV               ,
         to_char(max(e.date_nais),'DD/MM/YYYY'    )  as DATE_NAIS                    ,
         max(e.date_acci_trav                     )  as DATE_ACCI_TRAV               ,
         max(e.comm_nais                          )  as COMM_NAIS                    ,
         max(e.depa_nais                          )  as DEPA_NAIS                    ,
         max(e.pays_nais                          )  as PAYS_NAIS                    ,
         max(e.trav_hand                          )  as TRAV_HAND                    ,
         max(e.date_debu_coto                     )  as DATE_DEBU_COTO               ,
         max(e.date_fin_coto                      )  as DATE_FIN_COTO                ,
         max(e.taux_inva                          )  as TAUX_INVA                    ,
         max(e.situ_fami                          )  as SITU_FAMI                    ,
         max(e.bull_mode                          )  as BULL_MODE                    ,
         max(e.profil_paye_cp                     )  as PROFIL_PAYE_CP               ,
         max(e.profil_paye_rtt                    )  as PROFIL_PAYE_RTT              ,
         max(e.profil_paye_dif                    )  as PROFIL_PAYE_DIF              ,
         max(e.profil_paye_prov_cet               )  as PROFIL_PAYE_PROV_CET         ,
         max(e.profil_paye_prov_inte              )  as PROFIL_PAYE_PROV_INTE        ,
         max(e.profil_paye_prov_part              )  as PROFIL_PAYE_PROV_PART        ,
         max(e.profil_paye_13mo                   )  as PROFIL_PAYE_13MO             ,
         max(e.profil_paye_14mo                   )  as PROFIL_PAYE_14MO             ,
         max(e.prof_15mo                          )  as PROF_15MO                    ,
         max(e.profil_paye_prim_vaca_01           )  as PROFIL_PAYE_PRIM_VACA_01     ,
         max(e.profil_paye_prim_vaca_02           )  as PROFIL_PAYE_PRIM_VACA_02     ,
         max(e.profil_paye_hs_conv                )  as PROFIL_PAYE_HS_CONV          ,
         max(e.profil_paye_heur_equi              )  as PROFIL_PAYE_HEUR_EQUI        ,
         max(e.profil_paye_deca_fisc              )  as PROFIL_PAYE_DECA_FISC        ,
         max(e.profil_paye_tepa                   )  as PROFIL_PAYE_TEPA             ,
         max(e.profil_paye_affi_bull              )  as PROFIL_PAYE_AFFI_BULL        ,
         max(e.profil_paye_forf                   )  as PROFIL_PAYE_FORF             ,
         max(e.profil_paye_depa                   )  as PROFIL_PAYE_DEPA             ,
         max(e.profil_paye_rein_frai              )  as PROFIL_PAYE_REIN_FRAI        ,
         max(e.profil_paye_ndf                    )  as PROFIL_PAYE_NDF              ,
         max(e.profil_paye_acce_sala              )  as PROFIL_PAYE_ACCE_SALA        ,
         max(e.profil_paye_plan                   )  as PROFIL_PAYE_PLAN             ,
         max(e.profil_paye_tele_trav              )  as PROFIL_PAYE_TELE_TRAV        ,
         max(e.idcc_heur_equi                     )  as IDCC_HEUR_EQUI               ,
         max(e.cipdz_code                         )  as CIPDZ_CODE                   ,
         max(e.cipdz_libe                         )  as CIPDZ_LIBE                   ,
         max(e.nume_cong_spec                     )  as NUME_CONG_SPEC               ,
         max(e.grou_comp                          )  as GROU_COMP                    ,
         max(e.nati                               )  as NATI                         ,
         max(e.date_expi                          )  as DATE_EXPI                    ,
         max(e.nume_cart_sejo                     )  as NUME_CART_SEJO               ,
         max(e.nume_cart_trav                     )  as NUME_CART_TRAV               ,
         max(e.date_deli_trav                     )  as DATE_DELI_TRAV               ,
         max(e.date_expi_trav                     )  as DATE_EXPI_TRAV               ,
         max(e.date_dema_auto_trav                )  as DATE_DEMA_AUTO_TRAV          ,
         max(e.id_pref                            )  as ID_PREF                      ,
         max(e.date_expi_disp_mutu                )  as DATE_EXPI_DISP_MUTU          ,
         max(e.id_moti_disp_mutu                  )  as ID_MOTI_DISP_MUTU            ,
         max(e.nomb_enfa                          )  as NOMB_ENFA                    ,
         sum(e.comm_vent_n                        )  as COMM_VENT_N                  ,
         sum(e.comm_vent_n1                       )  as COMM_VENT_N1                 ,
         sum(e.prim_obje_n                        )  as PRIM_OBJE_N                  ,
         sum(e.prim_obje_n1                       )  as PRIM_OBJE_N1                 ,
         sum(e.prim_obje_soci_n                   )  as PRIM_OBJE_SOCI_N             ,
         sum(e.prim_obje_soci_n1                  )  as PRIM_OBJE_SOCI_N1            ,
         sum(e.prim_obje_glob_n                   )  as PRIM_OBJE_GLOB_N             ,
         max(e.dads_inse_empl                     )  as DADS_INSE_EMPL               ,
         max(e.sais                               )  as SAIS                         ,
         max(e.moti_visi_medi                     )  as MOTI_VISI_MEDI               ,
         max(e.stat_boet                          )  as STAT_BOET                    ,
         max(e.nomb_jour_trav_refe_tr_2           )  as NOMB_JOUR_TRAV_REFE_TR_2     ,
         max(e.calc_auto_tr                       )  as CALC_AUTO_TR                 ,
         max(e.type_vehi                          )  as TYPE_VEHI                    ,
         max(e.cate_vehi                          )  as CATE_VEHI                    ,
         max(e.pris_char_carb                     )  as PRIS_CHAR_CARB               ,
         max(e.octr_vehi                          )  as OCTR_VEHI                    ,
         max(e.imma_vehi                          )  as IMMA_VEHI                    ,
         max(e.date_1er_mise_circ_vehi            )  as DATE_1ER_MISE_CIRC_VEHI      ,
         max(e.prix_acha_remi_vehi                )  as PRIX_ACHA_REMI_VEHI          ,
         max(e.cout_vehi                          )  as COUT_VEHI                    ,
         max(e.type_sala                          )  as TYPE_SALA                    ,
         max(e.natu_cont                          )  as NATU_CONT                    ,
         max(e.nume_cont                          )  as NUME_CONT                    ,
         max(e.libe_moti_recr_cdd                 )  as LIBE_MOTI_RECR_CDD           ,
         max(e.libe_moti_recr_cdd2                )  as LIBE_MOTI_RECR_CDD2          ,
         max(e.libe_moti_recr_cdd3                )  as LIBE_MOTI_RECR_CDD3          ,
         max(e.date_debu_cont                     )  as DATE_DEBU_CONT               ,
         max(e.date_fin_cont                      )  as DATE_FIN_CONT                ,
         max(e.date_dern_visi_medi                )  as DATE_DERN_VISI_MEDI          ,
         max(e.date_proc_visi_medi                )  as DATE_PROC_VISI_MEDI          ,
         max(e.equi                               )  as EQUI                         ,
         max(e.divi                               )  as DIVI                         ,
         max(e.cais_coti_bull                     )  as CAIS_COTI_BULL               ,
         max(e.sala_forf_temp                     )  as SALA_FORF_TEMP               ,
         max(e.nomb_jour_forf_temp                )  as NOMB_JOUR_FORF_TEMP          ,
         max(e.nomb_heur_forf_temp                )  as NOMB_HEUR_FORF_TEMP          ,
         max(e.nomb_mois                          )  as nomb_mois                    ,
         max(e.sala_annu_cont                     )  as sala_annu_cont               ,
         count(distinct e.matr_grou               )  as CNT_MATR_GROU                ,
         count(distinct e.matr_resp_hier          )  as CNT_MATR_RESP_HIER           ,
         count(distinct e.date_anci_prof          )  as CNT_DATE_ANCI_PROF           ,
         count(distinct e.date_refe_01            )  as CNT_DATE_REFE_01             ,
         count(distinct e.date_refe_02            )  as CNT_DATE_REFE_02             ,
         count(distinct e.date_refe_03            )  as CNT_DATE_REFE_03             ,
         count(distinct e.date_refe_04            )  as CNT_DATE_REFE_04             ,
         count(distinct e.date_refe_05            )  as CNT_DATE_REFE_05             ,
         count(distinct e.date_sign_conv_stag     )  as CNT_DATE_SIGN_CONV_STAG      ,
         count(distinct e.matr                    )  as CNT_MATR                     ,
         count(distinct e.adre_mail               )  as CNT_ADRE_MAIL                ,
         count(distinct e.adre_mail_pers          )  as CNT_ADRE_MAIL_PERS           ,
         count(distinct e.nive_qual               )  as CNT_NIVE_QUAL                ,
         count(distinct e.moti_depa               )  as CNT_MOTI_DEPA                ,
         count(distinct e.moti_augm               )  as CNT_MOTI_AUGM                ,
         count(distinct e.moti_augm_2             )  as CNT_MOTI_AUGM_2              ,---KFH 25/05/2023 T184292
         count(distinct e.TICK_REST_TYPE_REPA     )  as CNT_TICK_REST_TYPE_REPA      ,---KFH 03/04/2024 T201908
         count(distinct e.sala_auto_titr_trav     )  as CNT_sala_auto_titr_trav      ,
         count(distinct e.lieu_pres_stag          )  as CNT_lieu_pres_stag           ,
         count(distinct e.sexe                    )  as CNT_SEXE                     ,
         count(distinct e.equi                    )  as CNT_EQUI                     ,
         count(distinct e.divi                    )  as CNT_DIVI                     ,
         count(distinct e.reac_regu               )  as CNT_REAC_REGU                ,
         count(distinct e.serv                    )  as CNT_SERV                     ,
         count(distinct e.depa                    )  as CNT_DEPA                     ,
         count(distinct e.empl                    )  as CNT_EMPL                     ,
         count(distinct e.empl_type               )  as CNT_EMPL_TYPE                ,
         count(distinct e.meti                    )  as CNT_METI                     ,
         count(distinct e.fami_meti               )  as CNT_FAMI_METI                ,
         count(distinct e.fami_meti_hier          )  as CNT_FAMI_METI_HIER           ,
         count(distinct e.code_empl               )  as CNT_CODE_EMPL                ,
         count(distinct e.code_cate               )  as CNT_CODE_CATE                ,
         count(distinct e.coef                    )  as CNT_COEF                     ,
         count(distinct e.sire_etab                    )  as CNT_SIRE_ETAB                     ,
         count(distinct e.dipl                    )  as CNT_DIPL                     ,
         count(distinct e.code_unit                    )  as CNT_CODE_UNIT                     ,
         count(distinct e.code_regr_fich_comp_etab                    )  as CNT_CODE_REGR_FICH_COMP_ETAB                     ,
         count(distinct e.nive                    )  as CNT_NIVE                     ,
         count(distinct e.eche                    )  as CNT_ECHE                     ,
         count(distinct e.grou_conv               )  as CNT_GROU_CONV                ,
         count(distinct e.posi                    )  as CNT_POSI                     ,
         count(distinct e.indi                    )  as CNT_INDI                     ,
         count(distinct e.cota                    )  as CNT_COTA                     ,
         count(distinct e.clas                    )  as CNT_CLAS                     ,
         count(distinct e.seui                    )  as CNT_SEUI                     ,
         count(distinct e.pali                    )  as CNT_PALI                     ,
         count(distinct e.grad                    )  as CNT_GRAD                     ,
         count(distinct e.degr                    )  as CNT_DEGR                     ,
         count(distinct e.fili                    )  as CNT_FILI                     ,
         count(distinct e.sect_prof               )  as CNT_SECT_PROF                ,
         count(distinct e.comp_brut               )  as CNT_COMP_BRUT                ,
         count(distinct e.comp_paye               )  as CNT_COMP_PAYE                ,
         count(distinct e.comp_acom               )  as CNT_COMP_ACOM                ,
         count(distinct e.nume_secu               )  as CNT_NUME_SECU                ,
         count(distinct e.date_emba               )  as CNT_DATE_EMBA                ,
         count(distinct e.date_depa               )  as CNT_DATE_DEPA                ,
         count(distinct e.date_anci               )  as CNT_DATE_ANCI                ,
         count(distinct e.date_dela_prev          )  as CNT_DATE_DELA_PREV           ,
         count(distinct e.date_nais               )  as CNT_DATE_NAIS                ,
         count(distinct e.date_acci_trav          )  as CNT_DATE_ACCI_TRAV           ,
         count(distinct e.comm_nais               )  as CNT_COMM_NAIS                ,
         count(distinct e.depa_nais               )  as CNT_DEPA_NAIS                ,
         count(distinct e.pays_nais               )  as CNT_PAYS_NAIS                ,
         count(distinct e.trav_hand               )  as CNT_TRAV_HAND                ,
         count(distinct e.date_debu_coto          )  as CNT_DATE_DEBU_COTO           ,
         count(distinct e.date_fin_coto           )  as CNT_DATE_FIN_COTO            ,
         count(distinct e.taux_inva               )  as CNT_TAUX_INVA                ,
         count(distinct e.situ_fami               )  as CNT_SITU_FAMI                ,
         count(distinct e.bull_mode               )  as CNT_BULL_MODE                ,
         count(distinct e.profil_paye_cp          )  as CNT_PROFIL_PAYE_CP           ,
         count(distinct e.profil_paye_rtt         )  as CNT_PROFIL_PAYE_RTT          ,
         count(distinct e.profil_paye_dif         )  as CNT_PROFIL_PAYE_DIF          ,
         count(distinct e.profil_paye_prov_cet    )  as CNT_PROFIL_PAYE_PROV_CET     ,
         count(distinct e.profil_paye_prov_inte   )  as CNT_PROFIL_PAYE_PROV_INTE    ,
         count(distinct e.profil_paye_prov_part   )  as CNT_PROFIL_PAYE_PROV_PART    ,
         count(distinct e.profil_paye_13mo        )  as CNT_PROFIL_PAYE_13MO         ,
         count(distinct e.profil_paye_14mo        )  as CNT_PROFIL_PAYE_14MO         ,
         count(distinct e.prof_15mo               )  as CNT_PROF_15MO                ,
         count(distinct e.profil_paye_prim_vaca_01)  as CNT_PROFIL_PAYE_PRIM_VACA_01 ,
         count(distinct e.profil_paye_prim_vaca_02)  as CNT_PROFIL_PAYE_PRIM_VACA_02 ,
         count(distinct e.profil_paye_hs_conv     )  as CNT_PROFIL_PAYE_HS_CONV      ,
         count(distinct e.profil_paye_heur_equi   )  as CNT_PROFIL_PAYE_HEUR_EQUI    ,
         count(distinct e.profil_paye_deca_fisc   )  as CNT_PROFIL_PAYE_DECA_FISC    ,
         count(distinct e.profil_paye_tepa        )  as CNT_PROFIL_PAYE_TEPA         ,
         count(distinct e.profil_paye_affi_bull   )  as CNT_PROFIL_PAYE_AFFI_BULL    ,
         count(distinct e.profil_paye_forf        )  as CNT_PROFIL_PAYE_FORF         ,
         count(distinct e.profil_paye_depa        )  as CNT_PROFIL_PAYE_DEPA         ,
         count(distinct e.profil_paye_rein_frai   )  as CNT_PROFIL_PAYE_REIN_FRAI    ,
         count(distinct e.profil_paye_ndf         )  as CNT_PROFIL_PAYE_NDF          ,
         count(distinct e.profil_paye_acce_sala   )  as CNT_PROFIL_PAYE_ACCE_SALA    ,
         count(distinct e.profil_paye_plan        )  as CNT_PROFIL_PAYE_PLAN         ,
         count(distinct e.profil_paye_tele_trav   )  as CNT_PROFIL_PAYE_TELE_TRAV    ,
         count(distinct e.idcc_heur_equi          )  as CNT_IDCC_HEUR_EQUI           ,
         count(distinct e.cipdz_code              )  as CNT_CIPDZ_CODE               ,
         count(distinct e.cipdz_libe              )  as CNT_CIPDZ_LIBE               ,
         count(distinct e.nume_cong_spec          )  as CNT_NUME_CONG_SPEC           ,
         count(distinct e.grou_comp               )  as CNT_GROU_COMP                ,
         count(distinct e.nati                    )  as CNT_NATI                     ,
         count(distinct e.date_expi               )  as CNT_DATE_EXPI                ,
         count(distinct e.nume_cart_sejo          )  as CNT_NUME_CART_SEJO           ,
         count(distinct e.nume_cart_trav          )  as CNT_NUME_CART_TRAV           ,
         count(distinct e.date_deli_trav          )  as CNT_DATE_DELI_TRAV           ,
         count(distinct e.date_expi_trav          )  as CNT_DATE_EXPI_TRAV           ,
         count(distinct e.date_dema_auto_trav     )  as CNT_DATE_DEMA_AUTO_TRAV      ,
         count(distinct e.id_pref                 )  as CNT_ID_PREF                  ,
         count(distinct e.date_expi_disp_mutu     )  as CNT_DATE_EXPI_DISP_MUTU      ,
         count(distinct e.id_moti_disp_mutu       )  as CNT_ID_MOTI_DISP_MUTU        ,
         count(distinct e.nomb_enfa               )  as CNT_NOMB_ENFA                ,
         count(distinct e.dads_inse_empl          )  as CNT_DADS_INSE_EMPL           ,
         count(distinct e.sais                    )  as CNT_SAIS                     ,
         count(distinct e.moti_visi_medi          )  as CNT_MOTI_VISI_MEDI           ,
         count(distinct e.stat_boet               )  as CNT_STAT_BOET                ,
         count(distinct e.nomb_jour_trav_refe_tr_2)  as CNT_NOMB_JOUR_TRAV_REFE_TR_2 ,
         count(distinct e.calc_auto_tr            )  as CNT_CALC_AUTO_TR             ,
         count(distinct e.type_vehi               )  as CNT_TYPE_VEHI                ,
         count(distinct e.cate_vehi               )  as CNT_CATE_VEHI                ,
         count(distinct e.pris_char_carb          )  as CNT_PRIS_CHAR_CARB           ,
         count(distinct e.octr_vehi               )  as CNT_OCTR_VEHI                ,
         count(distinct e.imma_vehi               )  as CNT_IMMA_VEHI                ,
         count(distinct e.date_1er_mise_circ_vehi )  as CNT_DATE_1ER_MISE_CIRC_VEHI  ,
         count(distinct e.prix_acha_remi_vehi     )  as CNT_PRIX_ACHA_REMI_VEHI      ,
         count(distinct e.cout_vehi               )  as CNT_COUT_VEHI                ,
         count(distinct e.type_sala               )  as CNT_TYPE_SALA                ,
         count(distinct e.natu_cont               )  as CNT_NATU_CONT                ,
         count(distinct e.nume_cont               )  as CNT_NUME_CONT                ,
         count(distinct e.libe_moti_recr_cdd      )  as CNT_LIBE_MOTI_RECR_CDD       ,
         count(distinct e.libe_moti_recr_cdd2     )  as CNT_LIBE_MOTI_RECR_CDD2      ,
         count(distinct e.libe_moti_recr_cdd3     )  as CNT_LIBE_MOTI_RECR_CDD3      ,
         count(distinct e.date_debu_cont          )  as CNT_DATE_DEBU_CONT           ,
         count(distinct e.date_fin_cont           )  as CNT_DATE_FIN_CONT            ,
         count(distinct e.date_dern_visi_medi     )  as CNT_DATE_DERN_VISI_MEDI      ,
         count(distinct e.date_proc_visi_medi     )  as CNT_DATE_PROC_VISI_MEDI      ,
         count(distinct e.cais_coti_bull          )  as CNT_CAIS_COTI_BULL           ,
         count(distinct e.sala_forf_temp          )  as CNT_SALA_FORF_TEMP           ,
         count(distinct e.nomb_jour_forf_temp     )  as CNT_NOMB_JOUR_FORF_TEMP      ,
         count(distinct e.nomb_heur_forf_temp     )  as CNT_NOMB_HEUR_FORF_TEMP      ,
         count(distinct e.nomb_mois               )  as cnt_nomb_mois                ,
         count(distinct e.sala_annu_cont          )  as cnt_sala_annu_cont           ,
         max(e.cong_rest_mois)                       as CONG_REST_MOIS           ,
         max(e.evol_remu_supp_coti)                  as EVOL_REMU_SUPP_COTI      ,
         max(e.nomb_tr_calc_peri)                    as NOMB_TR_CALC_PERI        ,
         max(e.vale_spec_tr)                         as VALE_SPEC_TR        ,
         max(e.cong_pris_anne)                       as CONG_PRIS_ANNE           ,
         max(e.mutu_soum_txde_01)                    as MUTU_SOUM_TXDE_01        ,
         max(e.mutu_soum_txde_02)                    as MUTU_SOUM_TXDE_02        ,
         max(e.mutu_soum_txde_03)                    as MUTU_SOUM_TXDE_03        ,
         max(e.mutu_soum_txde_04)                    as MUTU_SOUM_TXDE_04        ,
         max(e.mutu_soum_txde_05)                    as MUTU_SOUM_TXDE_05        ,
         max(e.mutu_soum_mtde_01)                    as MUTU_SOUM_MTDE_01        ,
         max(e.mutu_soum_mtde_02)                    as MUTU_SOUM_MTDE_02        ,
         max(e.mutu_soum_mtde_03)                    as MUTU_SOUM_MTDE_03        ,
         max(e.mutu_soum_mtde_04)                    as MUTU_SOUM_MTDE_04        ,
         max(e.mutu_soum_mtde_05)                    as MUTU_SOUM_MTDE_05        ,
         max(e.mutu_soum_mtde_06)                    as MUTU_SOUM_MTDE_06        ,
         max(e.mutu_soum_mtde_07)                    as MUTU_SOUM_MTDE_07        ,
         max(e.mutu_soum_mtde_08)                    as MUTU_SOUM_MTDE_08        ,
         max(e.mutu_soum_mtde_09)                    as MUTU_SOUM_MTDE_09        ,
         max(e.mutu_soum_mtde_10)                    as MUTU_SOUM_MTDE_10        ,
         max(e.mutu_noso_txde_01)                    as MUTU_NOSO_TXDE_01        ,
         max(e.mutu_noso_txde_02)                    as MUTU_NOSO_TXDE_02        ,
         max(e.mutu_noso_txde_03)                    as MUTU_NOSO_TXDE_03        ,
         max(e.mutu_noso_mtde_01)                    as MUTU_NOSO_MTDE_01        ,
         max(e.mutu_noso_mtde_02)                    as MUTU_NOSO_MTDE_02        ,
         max(e.mutu_noso_mtde_03)                    as MUTU_NOSO_MTDE_03        ,
         max(e.mutu_noso_mtde_04)                    as MUTU_NOSO_MTDE_04        ,
         max(e.mutu_noso_mtde_05)                    as MUTU_NOSO_MTDE_05        ,
         max(e.mutu_noso_mtde_06)                    as MUTU_NOSO_MTDE_06        ,
         max(e.mutu_noso_mtde_07)                    as MUTU_NOSO_MTDE_07        ,
         count(distinct e.cong_rest_mois)            as CNT_CONG_REST_MOIS       ,
         count(distinct e.evol_remu_supp_coti)       as CNT_EVOL_REMU_SUPP_COTI  ,
         count(distinct e.nomb_tr_calc_peri)         as CNT_NOMB_TR_CALC_PERI    ,
         count(distinct e.VALE_SPEC_TR)              as CNT_VALE_SPEC_TR         ,
         count(distinct e.cong_pris_anne)            as CNT_CONG_PRIS_ANNE       ,
         count(distinct e.mutu_soum_txde_01)         as CNT_MUTU_SOUM_TXDE_01    ,
         count(distinct e.mutu_soum_txde_02)         as CNT_MUTU_SOUM_TXDE_02    ,
         count(distinct e.mutu_soum_txde_03)         as CNT_MUTU_SOUM_TXDE_03    ,
         count(distinct e.mutu_soum_txde_04)         as CNT_MUTU_SOUM_TXDE_04    ,
         count(distinct e.mutu_soum_txde_05)         as CNT_MUTU_SOUM_TXDE_05    ,
         count(distinct e.mutu_soum_mtde_01)         as CNT_MUTU_SOUM_MTDE_01    ,
         count(distinct e.mutu_soum_mtde_02)         as CNT_MUTU_SOUM_MTDE_02    ,
         count(distinct e.mutu_soum_mtde_03)         as CNT_MUTU_SOUM_MTDE_03    ,
         count(distinct e.mutu_soum_mtde_04)         as CNT_MUTU_SOUM_MTDE_04    ,
         count(distinct e.mutu_soum_mtde_05)         as CNT_MUTU_SOUM_MTDE_05    ,
         count(distinct e.mutu_soum_mtde_06)         as CNT_MUTU_SOUM_MTDE_06    ,
         count(distinct e.mutu_soum_mtde_07)         as CNT_MUTU_SOUM_MTDE_07    ,
         count(distinct e.mutu_soum_mtde_08)         as CNT_MUTU_SOUM_MTDE_08    ,
         count(distinct e.mutu_soum_mtde_09)         as CNT_MUTU_SOUM_MTDE_09    ,
         count(distinct e.mutu_soum_mtde_10)         as CNT_MUTU_SOUM_MTDE_10    ,
         count(distinct e.mutu_noso_txde_01)         as CNT_MUTU_NOSO_TXDE_01    ,
         count(distinct e.mutu_noso_txde_02)         as CNT_MUTU_NOSO_TXDE_02    ,
         count(distinct e.mutu_noso_txde_03)         as CNT_MUTU_NOSO_TXDE_03    ,
         count(distinct e.mutu_noso_mtde_01)         as CNT_MUTU_NOSO_MTDE_01    ,
         count(distinct e.mutu_noso_mtde_02)         as CNT_MUTU_NOSO_MTDE_02    ,
         count(distinct e.mutu_noso_mtde_03)         as CNT_MUTU_NOSO_MTDE_03    ,
         count(distinct e.mutu_noso_mtde_04)         as CNT_MUTU_NOSO_MTDE_04    ,
         count(distinct e.mutu_noso_mtde_05)         as CNT_MUTU_NOSO_MTDE_05    ,
         count(distinct e.mutu_noso_mtde_06)         as CNT_MUTU_NOSO_MTDE_06    ,
         count(distinct e.mutu_noso_mtde_07)         as CNT_MUTU_NOSO_MTDE_07    ,
         max(e.code_anal_01)                         as CODE_ANAL_01             ,
         max(e.code_anal_02)                         as CODE_ANAL_02             ,
         max(e.code_anal_03)                         as CODE_ANAL_03             ,
         max(e.code_anal_04)                         as CODE_ANAL_04             ,
         max(e.code_anal_05)                         as CODE_ANAL_05             ,
         max(e.code_anal_06)                         as CODE_ANAL_06             ,
         max(e.code_anal_07)                         as CODE_ANAL_07             ,
         max(e.code_anal_08)                         as CODE_ANAL_08             ,
         max(e.code_anal_09)                         as CODE_ANAL_09             ,
         max(e.code_anal_10)                         as CODE_ANAL_10             ,
         max(e.code_anal_11)                         as CODE_ANAL_11             ,
         max(e.code_anal_12)                         as CODE_ANAL_12             ,
         max(e.code_anal_13)                         as CODE_ANAL_13             ,
         max(e.code_anal_14)                         as CODE_ANAL_14             ,
         max(e.code_anal_15)                         as CODE_ANAL_15             ,
         max(e.code_anal_16)                         as CODE_ANAL_16             ,
         max(e.code_anal_17)                         as CODE_ANAL_17             ,
         max(e.code_anal_18)                         as CODE_ANAL_18             ,
         max(e.code_anal_19)                         as CODE_ANAL_19             ,
         max(e.code_anal_20)                         as CODE_ANAL_20             ,
         count(distinct e.code_anal_01)              as CNT_CODE_ANAL_01         ,
         count(distinct e.code_anal_02)              as CNT_CODE_ANAL_02         ,
         count(distinct e.code_anal_03)              as CNT_CODE_ANAL_03         ,
         count(distinct e.code_anal_04)              as CNT_CODE_ANAL_04         ,
         count(distinct e.code_anal_05)              as CNT_CODE_ANAL_05         ,
         count(distinct e.code_anal_06)              as CNT_CODE_ANAL_06         ,
         count(distinct e.code_anal_07)              as CNT_CODE_ANAL_07         ,
         count(distinct e.code_anal_08)              as CNT_CODE_ANAL_08         ,
         count(distinct e.code_anal_09)              as CNT_CODE_ANAL_09         ,
         count(distinct e.code_anal_10)              as CNT_CODE_ANAL_10         ,
         count(distinct e.code_anal_11)              as CNT_CODE_ANAL_11         ,
         count(distinct e.code_anal_12)              as CNT_CODE_ANAL_12         ,
         count(distinct e.code_anal_13)              as CNT_CODE_ANAL_13         ,
         count(distinct e.code_anal_14)              as CNT_CODE_ANAL_14         ,
         count(distinct e.code_anal_15)              as CNT_CODE_ANAL_15         ,
         count(distinct e.code_anal_16)              as CNT_CODE_ANAL_16         ,
         count(distinct e.code_anal_17)              as CNT_CODE_ANAL_17         ,
         count(distinct e.code_anal_18)              as CNT_CODE_ANAL_18         ,
         count(distinct e.code_anal_19)              as CNT_CODE_ANAL_19         ,
         count(distinct e.code_anal_20)              as CNT_CODE_ANAL_20         ,
         max(e.plan1_code_anal_01)                   as PLAN1_CODE_ANAL_01       ,
         max(e.plan1_code_anal_02)                   as PLAN1_CODE_ANAL_02       ,
         max(e.plan1_code_anal_03)                   as PLAN1_CODE_ANAL_03       ,
         max(e.plan1_code_anal_04)                   as PLAN1_CODE_ANAL_04       ,
         max(e.plan1_code_anal_05)                   as PLAN1_CODE_ANAL_05       ,
         max(e.plan1_code_anal_06)                   as PLAN1_CODE_ANAL_06       ,
         max(e.plan1_code_anal_07)                   as PLAN1_CODE_ANAL_07       ,
         max(e.plan1_code_anal_08)                   as PLAN1_CODE_ANAL_08       ,
         max(e.plan1_code_anal_09)                   as PLAN1_CODE_ANAL_09       ,
         max(e.plan1_code_anal_10)                   as PLAN1_CODE_ANAL_10       ,
         max(e.plan1_code_anal_11)                   as PLAN1_CODE_ANAL_11       ,
         max(e.plan1_code_anal_12)                   as PLAN1_CODE_ANAL_12       ,
         max(e.plan1_code_anal_13)                   as PLAN1_CODE_ANAL_13       ,
         max(e.plan1_code_anal_14)                   as PLAN1_CODE_ANAL_14       ,
         max(e.plan1_code_anal_15)                   as PLAN1_CODE_ANAL_15       ,
         max(e.plan1_code_anal_16)                   as PLAN1_CODE_ANAL_16       ,
         max(e.plan1_code_anal_17)                   as PLAN1_CODE_ANAL_17       ,
         max(e.plan1_code_anal_18)                   as PLAN1_CODE_ANAL_18       ,
         max(e.plan1_code_anal_19)                   as PLAN1_CODE_ANAL_19       ,
         max(e.plan1_code_anal_20)                   as PLAN1_CODE_ANAL_20       ,
         max(e.plan1_pour_affe_anal_01)              as PLAN1_POUR_AFFE_ANAL_01  ,
         max(e.plan1_pour_affe_anal_02)              as PLAN1_POUR_AFFE_ANAL_02  ,
         max(e.plan1_pour_affe_anal_03)              as PLAN1_POUR_AFFE_ANAL_03  ,
         max(e.plan1_pour_affe_anal_04)              as PLAN1_POUR_AFFE_ANAL_04  ,
         max(e.plan1_pour_affe_anal_05)              as PLAN1_POUR_AFFE_ANAL_05  ,
         max(e.plan1_pour_affe_anal_06)              as PLAN1_POUR_AFFE_ANAL_06  ,
         max(e.plan1_pour_affe_anal_07)              as PLAN1_POUR_AFFE_ANAL_07  ,
         max(e.plan1_pour_affe_anal_08)              as PLAN1_POUR_AFFE_ANAL_08  ,
         max(e.plan1_pour_affe_anal_09)              as PLAN1_POUR_AFFE_ANAL_09  ,
         max(e.plan1_pour_affe_anal_10)              as PLAN1_POUR_AFFE_ANAL_10  ,
         max(e.plan1_pour_affe_anal_11)              as PLAN1_POUR_AFFE_ANAL_11  ,
         max(e.plan1_pour_affe_anal_12)              as PLAN1_POUR_AFFE_ANAL_12  ,
         max(e.plan1_pour_affe_anal_13)              as PLAN1_POUR_AFFE_ANAL_13  ,
         max(e.plan1_pour_affe_anal_14)              as PLAN1_POUR_AFFE_ANAL_14  ,
         max(e.plan1_pour_affe_anal_15)              as PLAN1_POUR_AFFE_ANAL_15  ,
         max(e.plan1_pour_affe_anal_16)              as PLAN1_POUR_AFFE_ANAL_16  ,
         max(e.plan1_pour_affe_anal_17)              as PLAN1_POUR_AFFE_ANAL_17  ,
         max(e.plan1_pour_affe_anal_18)              as PLAN1_POUR_AFFE_ANAL_18  ,
         max(e.plan1_pour_affe_anal_19)              as PLAN1_POUR_AFFE_ANAL_19  ,
         max(e.plan1_pour_affe_anal_20)              as PLAN1_POUR_AFFE_ANAL_20  ,
         max(e.plan2_code_anal_01)                   as PLAN2_CODE_ANAL_01       ,
         max(e.plan2_code_anal_02)                   as PLAN2_CODE_ANAL_02       ,
         max(e.plan2_code_anal_03)                   as PLAN2_CODE_ANAL_03       ,
         max(e.plan2_code_anal_04)                   as PLAN2_CODE_ANAL_04       ,
         max(e.plan2_code_anal_05)                   as PLAN2_CODE_ANAL_05       ,
         max(e.plan2_code_anal_06)                   as PLAN2_CODE_ANAL_06       ,
         max(e.plan2_code_anal_07)                   as PLAN2_CODE_ANAL_07       ,
         max(e.plan2_code_anal_08)                   as PLAN2_CODE_ANAL_08       ,
         max(e.plan2_code_anal_09)                   as PLAN2_CODE_ANAL_09       ,
         max(e.plan2_code_anal_10)                   as PLAN2_CODE_ANAL_10       ,
         max(e.plan2_code_anal_11)                   as PLAN2_CODE_ANAL_11       ,
         max(e.plan2_code_anal_12)                   as PLAN2_CODE_ANAL_12       ,
         max(e.plan2_code_anal_13)                   as PLAN2_CODE_ANAL_13       ,
         max(e.plan2_code_anal_14)                   as PLAN2_CODE_ANAL_14       ,
         max(e.plan2_code_anal_15)                   as PLAN2_CODE_ANAL_15       ,
         max(e.plan2_code_anal_16)                   as PLAN2_CODE_ANAL_16       ,
         max(e.plan2_code_anal_17)                   as PLAN2_CODE_ANAL_17       ,
         max(e.plan2_code_anal_18)                   as PLAN2_CODE_ANAL_18       ,
         max(e.plan2_code_anal_19)                   as PLAN2_CODE_ANAL_19       ,
         max(e.plan2_code_anal_20)                   as PLAN2_CODE_ANAL_20       ,
         max(e.plan2_pour_affe_anal_01)              as PLAN2_POUR_AFFE_ANAL_01  ,
         max(e.plan2_pour_affe_anal_02)              as PLAN2_POUR_AFFE_ANAL_02  ,
         max(e.plan2_pour_affe_anal_03)              as PLAN2_POUR_AFFE_ANAL_03  ,
         max(e.plan2_pour_affe_anal_04)              as PLAN2_POUR_AFFE_ANAL_04  ,
         max(e.plan2_pour_affe_anal_05)              as PLAN2_POUR_AFFE_ANAL_05  ,
         max(e.plan2_pour_affe_anal_06)              as PLAN2_POUR_AFFE_ANAL_06  ,
         max(e.plan2_pour_affe_anal_07)              as PLAN2_POUR_AFFE_ANAL_07  ,
         max(e.plan2_pour_affe_anal_08)              as PLAN2_POUR_AFFE_ANAL_08  ,
         max(e.plan2_pour_affe_anal_09)              as PLAN2_POUR_AFFE_ANAL_09  ,
         max(e.plan2_pour_affe_anal_10)              as PLAN2_POUR_AFFE_ANAL_10  ,
         max(e.plan2_pour_affe_anal_11)              as PLAN2_POUR_AFFE_ANAL_11  ,
         max(e.plan2_pour_affe_anal_12)              as PLAN2_POUR_AFFE_ANAL_12  ,
         max(e.plan2_pour_affe_anal_13)              as PLAN2_POUR_AFFE_ANAL_13  ,
         max(e.plan2_pour_affe_anal_14)              as PLAN2_POUR_AFFE_ANAL_14  ,
         max(e.plan2_pour_affe_anal_15)              as PLAN2_POUR_AFFE_ANAL_15  ,
         max(e.plan2_pour_affe_anal_16)              as PLAN2_POUR_AFFE_ANAL_16  ,
         max(e.plan2_pour_affe_anal_17)              as PLAN2_POUR_AFFE_ANAL_17  ,
         max(e.plan2_pour_affe_anal_18)              as PLAN2_POUR_AFFE_ANAL_18  ,
         max(e.plan2_pour_affe_anal_19)              as PLAN2_POUR_AFFE_ANAL_19  ,
         max(e.plan2_pour_affe_anal_20)              as PLAN2_POUR_AFFE_ANAL_20  ,
         max(e.plan3_code_anal_01)                   as PLAN3_CODE_ANAL_01       ,
         max(e.plan3_code_anal_02)                   as PLAN3_CODE_ANAL_02       ,
         max(e.plan3_code_anal_03)                   as PLAN3_CODE_ANAL_03       ,
         max(e.plan3_code_anal_04)                   as PLAN3_CODE_ANAL_04       ,
         max(e.plan3_code_anal_05)                   as PLAN3_CODE_ANAL_05       ,
         max(e.plan3_code_anal_06)                   as PLAN3_CODE_ANAL_06       ,
         max(e.plan3_code_anal_07)                   as PLAN3_CODE_ANAL_07       ,
         max(e.plan3_code_anal_08)                   as PLAN3_CODE_ANAL_08       ,
         max(e.plan3_code_anal_09)                   as PLAN3_CODE_ANAL_09       ,
         max(e.plan3_code_anal_10)                   as PLAN3_CODE_ANAL_10       ,
         max(e.plan3_code_anal_11)                   as PLAN3_CODE_ANAL_11       ,
         max(e.plan3_code_anal_12)                   as PLAN3_CODE_ANAL_12       ,
         max(e.plan3_code_anal_13)                   as PLAN3_CODE_ANAL_13       ,
         max(e.plan3_code_anal_14)                   as PLAN3_CODE_ANAL_14       ,
         max(e.plan3_code_anal_15)                   as PLAN3_CODE_ANAL_15       ,
         max(e.plan3_code_anal_16)                   as PLAN3_CODE_ANAL_16       ,
         max(e.plan3_code_anal_17)                   as PLAN3_CODE_ANAL_17       ,
         max(e.plan3_code_anal_18)                   as PLAN3_CODE_ANAL_18       ,
         max(e.plan3_code_anal_19)                   as PLAN3_CODE_ANAL_19       ,
         max(e.plan3_code_anal_20)                   as PLAN3_CODE_ANAL_20       ,
         max(e.plan3_pour_affe_anal_01)              as PLAN3_POUR_AFFE_ANAL_01  ,
         max(e.plan3_pour_affe_anal_02)              as PLAN3_POUR_AFFE_ANAL_02  ,
         max(e.plan3_pour_affe_anal_03)              as PLAN3_POUR_AFFE_ANAL_03  ,
         max(e.plan3_pour_affe_anal_04)              as PLAN3_POUR_AFFE_ANAL_04  ,
         max(e.plan3_pour_affe_anal_05)              as PLAN3_POUR_AFFE_ANAL_05  ,
         max(e.plan3_pour_affe_anal_06)              as PLAN3_POUR_AFFE_ANAL_06  ,
         max(e.plan3_pour_affe_anal_07)              as PLAN3_POUR_AFFE_ANAL_07  ,
         max(e.plan3_pour_affe_anal_08)              as PLAN3_POUR_AFFE_ANAL_08  ,
         max(e.plan3_pour_affe_anal_09)              as PLAN3_POUR_AFFE_ANAL_09  ,
         max(e.plan3_pour_affe_anal_10)              as PLAN3_POUR_AFFE_ANAL_10  ,
         max(e.plan3_pour_affe_anal_11)              as PLAN3_POUR_AFFE_ANAL_11  ,
         max(e.plan3_pour_affe_anal_12)              as PLAN3_POUR_AFFE_ANAL_12  ,
         max(e.plan3_pour_affe_anal_13)              as PLAN3_POUR_AFFE_ANAL_13  ,
         max(e.plan3_pour_affe_anal_14)              as PLAN3_POUR_AFFE_ANAL_14  ,
         max(e.plan3_pour_affe_anal_15)              as PLAN3_POUR_AFFE_ANAL_15  ,
         max(e.plan3_pour_affe_anal_16)              as PLAN3_POUR_AFFE_ANAL_16  ,
         max(e.plan3_pour_affe_anal_17)              as PLAN3_POUR_AFFE_ANAL_17  ,
         max(e.plan3_pour_affe_anal_18)              as PLAN3_POUR_AFFE_ANAL_18  ,
         max(e.plan3_pour_affe_anal_19)              as PLAN3_POUR_AFFE_ANAL_19  ,
         max(e.plan3_pour_affe_anal_20)              as PLAN3_POUR_AFFE_ANAL_20  ,
         max(e.plan4_code_anal_01)                   as PLAN4_CODE_ANAL_01       ,
         max(e.plan4_code_anal_02)                   as PLAN4_CODE_ANAL_02       ,
         max(e.plan4_code_anal_03)                   as PLAN4_CODE_ANAL_03       ,
         max(e.plan4_code_anal_04)                   as PLAN4_CODE_ANAL_04       ,
         max(e.plan4_code_anal_05)                   as PLAN4_CODE_ANAL_05       ,
         max(e.plan4_code_anal_06)                   as PLAN4_CODE_ANAL_06       ,
         max(e.plan4_code_anal_07)                   as PLAN4_CODE_ANAL_07       ,
         max(e.plan4_code_anal_08)                   as PLAN4_CODE_ANAL_08       ,
         max(e.plan4_code_anal_09)                   as PLAN4_CODE_ANAL_09       ,
         max(e.plan4_code_anal_10)                   as PLAN4_CODE_ANAL_10       ,
         max(e.plan4_code_anal_11)                   as PLAN4_CODE_ANAL_11       ,
         max(e.plan4_code_anal_12)                   as PLAN4_CODE_ANAL_12       ,
         max(e.plan4_code_anal_13)                   as PLAN4_CODE_ANAL_13       ,
         max(e.plan4_code_anal_14)                   as PLAN4_CODE_ANAL_14       ,
         max(e.plan4_code_anal_15)                   as PLAN4_CODE_ANAL_15       ,
         max(e.plan4_code_anal_16)                   as PLAN4_CODE_ANAL_16       ,
         max(e.plan4_code_anal_17)                   as PLAN4_CODE_ANAL_17       ,
         max(e.plan4_code_anal_18)                   as PLAN4_CODE_ANAL_18       ,
         max(e.plan4_code_anal_19)                   as PLAN4_CODE_ANAL_19       ,
         max(e.plan4_code_anal_20)                   as PLAN4_CODE_ANAL_20       ,
         max(e.plan4_pour_affe_anal_01)              as PLAN4_POUR_AFFE_ANAL_01  ,
         max(e.plan4_pour_affe_anal_02)              as PLAN4_POUR_AFFE_ANAL_02  ,
         max(e.plan4_pour_affe_anal_03)              as PLAN4_POUR_AFFE_ANAL_03  ,
         max(e.plan4_pour_affe_anal_04)              as PLAN4_POUR_AFFE_ANAL_04  ,
         max(e.plan4_pour_affe_anal_05)              as PLAN4_POUR_AFFE_ANAL_05  ,
         max(e.plan4_pour_affe_anal_06)              as PLAN4_POUR_AFFE_ANAL_06  ,
         max(e.plan4_pour_affe_anal_07)              as PLAN4_POUR_AFFE_ANAL_07  ,
         max(e.plan4_pour_affe_anal_08)              as PLAN4_POUR_AFFE_ANAL_08  ,
         max(e.plan4_pour_affe_anal_09)              as PLAN4_POUR_AFFE_ANAL_09  ,
         max(e.plan4_pour_affe_anal_10)              as PLAN4_POUR_AFFE_ANAL_10  ,
         max(e.plan4_pour_affe_anal_11)              as PLAN4_POUR_AFFE_ANAL_11  ,
         max(e.plan4_pour_affe_anal_12)              as PLAN4_POUR_AFFE_ANAL_12  ,
         max(e.plan4_pour_affe_anal_13)              as PLAN4_POUR_AFFE_ANAL_13  ,
         max(e.plan4_pour_affe_anal_14)              as PLAN4_POUR_AFFE_ANAL_14  ,
         max(e.plan4_pour_affe_anal_15)              as PLAN4_POUR_AFFE_ANAL_15  ,
         max(e.plan4_pour_affe_anal_16)              as PLAN4_POUR_AFFE_ANAL_16  ,
         max(e.plan4_pour_affe_anal_17)              as PLAN4_POUR_AFFE_ANAL_17  ,
         max(e.plan4_pour_affe_anal_18)              as PLAN4_POUR_AFFE_ANAL_18  ,
         max(e.plan4_pour_affe_anal_19)              as PLAN4_POUR_AFFE_ANAL_19  ,
         max(e.plan4_pour_affe_anal_20)              as PLAN4_POUR_AFFE_ANAL_20  ,
         max(e.plan5_code_anal_01)                   as PLAN5_CODE_ANAL_01       ,
         max(e.plan5_code_anal_02)                   as PLAN5_CODE_ANAL_02       ,
         max(e.plan5_code_anal_03)                   as PLAN5_CODE_ANAL_03       ,
         max(e.plan5_code_anal_04)                   as PLAN5_CODE_ANAL_04       ,
         max(e.plan5_code_anal_05)                   as PLAN5_CODE_ANAL_05       ,
         max(e.plan5_code_anal_06)                   as PLAN5_CODE_ANAL_06       ,
         max(e.plan5_code_anal_07)                   as PLAN5_CODE_ANAL_07       ,
         max(e.plan5_code_anal_08)                   as PLAN5_CODE_ANAL_08       ,
         max(e.plan5_code_anal_09)                   as PLAN5_CODE_ANAL_09       ,
         max(e.plan5_code_anal_10)                   as PLAN5_CODE_ANAL_10       ,
         max(e.plan5_code_anal_11)                   as PLAN5_CODE_ANAL_11       ,
         max(e.plan5_code_anal_12)                   as PLAN5_CODE_ANAL_12       ,
         max(e.plan5_code_anal_13)                   as PLAN5_CODE_ANAL_13       ,
         max(e.plan5_code_anal_14)                   as PLAN5_CODE_ANAL_14       ,
         max(e.plan5_code_anal_15)                   as PLAN5_CODE_ANAL_15       ,
         max(e.plan5_code_anal_16)                   as PLAN5_CODE_ANAL_16       ,
         max(e.plan5_code_anal_17)                   as PLAN5_CODE_ANAL_17       ,
         max(e.plan5_code_anal_18)                   as PLAN5_CODE_ANAL_18       ,
         max(e.plan5_code_anal_19)                   as PLAN5_CODE_ANAL_19       ,
         max(e.plan5_code_anal_20)                   as PLAN5_CODE_ANAL_20       ,
         max(e.plan5_pour_affe_anal_01)              as PLAN5_POUR_AFFE_ANAL_01  ,
         max(e.plan5_pour_affe_anal_02)              as PLAN5_POUR_AFFE_ANAL_02  ,
         max(e.plan5_pour_affe_anal_03)              as PLAN5_POUR_AFFE_ANAL_03  ,
         max(e.plan5_pour_affe_anal_04)              as PLAN5_POUR_AFFE_ANAL_04  ,
         max(e.plan5_pour_affe_anal_05)              as PLAN5_POUR_AFFE_ANAL_05  ,
         max(e.plan5_pour_affe_anal_06)              as PLAN5_POUR_AFFE_ANAL_06  ,
         max(e.plan5_pour_affe_anal_07)              as PLAN5_POUR_AFFE_ANAL_07  ,
         max(e.plan5_pour_affe_anal_08)              as PLAN5_POUR_AFFE_ANAL_08  ,
         max(e.plan5_pour_affe_anal_09)              as PLAN5_POUR_AFFE_ANAL_09  ,
         max(e.plan5_pour_affe_anal_10)              as PLAN5_POUR_AFFE_ANAL_10  ,
         max(e.plan5_pour_affe_anal_11)              as PLAN5_POUR_AFFE_ANAL_11  ,
         max(e.plan5_pour_affe_anal_12)              as PLAN5_POUR_AFFE_ANAL_12  ,
         max(e.plan5_pour_affe_anal_13)              as PLAN5_POUR_AFFE_ANAL_13  ,
         max(e.plan5_pour_affe_anal_14)              as PLAN5_POUR_AFFE_ANAL_14  ,
         max(e.plan5_pour_affe_anal_15)              as PLAN5_POUR_AFFE_ANAL_15  ,
         max(e.plan5_pour_affe_anal_16)              as PLAN5_POUR_AFFE_ANAL_16  ,
         max(e.plan5_pour_affe_anal_17)              as PLAN5_POUR_AFFE_ANAL_17  ,
         max(e.plan5_pour_affe_anal_18)              as PLAN5_POUR_AFFE_ANAL_18  ,
         max(e.plan5_pour_affe_anal_19)              as PLAN5_POUR_AFFE_ANAL_19  ,
         max(e.plan5_pour_affe_anal_20)              as PLAN5_POUR_AFFE_ANAL_20  ,
         count(distinct e.plan1_code_anal_01)        as CNT_PLAN1_CODE_ANAL_01      ,
         count(distinct e.plan1_code_anal_02)        as CNT_PLAN1_CODE_ANAL_02      ,
         count(distinct e.plan1_code_anal_03)        as CNT_PLAN1_CODE_ANAL_03      ,
         count(distinct e.plan1_code_anal_04)        as CNT_PLAN1_CODE_ANAL_04      ,
         count(distinct e.plan1_code_anal_05)        as CNT_PLAN1_CODE_ANAL_05      ,
         count(distinct e.plan1_code_anal_06)        as CNT_PLAN1_CODE_ANAL_06      ,
         count(distinct e.plan1_code_anal_07)        as CNT_PLAN1_CODE_ANAL_07      ,
         count(distinct e.plan1_code_anal_08)        as CNT_PLAN1_CODE_ANAL_08      ,
         count(distinct e.plan1_code_anal_09)        as CNT_PLAN1_CODE_ANAL_09      ,
         count(distinct e.plan1_code_anal_10)        as CNT_PLAN1_CODE_ANAL_10      ,
         count(distinct e.plan1_code_anal_11)        as CNT_PLAN1_CODE_ANAL_11      ,
         count(distinct e.plan1_code_anal_12)        as CNT_PLAN1_CODE_ANAL_12      ,
         count(distinct e.plan1_code_anal_13)        as CNT_PLAN1_CODE_ANAL_13      ,
         count(distinct e.plan1_code_anal_14)        as CNT_PLAN1_CODE_ANAL_14      ,
         count(distinct e.plan1_code_anal_15)        as CNT_PLAN1_CODE_ANAL_15      ,
         count(distinct e.plan1_code_anal_16)        as CNT_PLAN1_CODE_ANAL_16      ,
         count(distinct e.plan1_code_anal_17)        as CNT_PLAN1_CODE_ANAL_17      ,
         count(distinct e.plan1_code_anal_18)        as CNT_PLAN1_CODE_ANAL_18      ,
         count(distinct e.plan1_code_anal_19)        as CNT_PLAN1_CODE_ANAL_19      ,
         count(distinct e.plan1_code_anal_20)        as CNT_PLAN1_CODE_ANAL_20      ,
         count(distinct e.plan1_pour_affe_anal_01)   as CNT_PLAN1_POUR_AFFE_ANAL_01 ,
         count(distinct e.plan1_pour_affe_anal_02)   as CNT_PLAN1_POUR_AFFE_ANAL_02 ,
         count(distinct e.plan1_pour_affe_anal_03)   as CNT_PLAN1_POUR_AFFE_ANAL_03 ,
         count(distinct e.plan1_pour_affe_anal_04)   as CNT_PLAN1_POUR_AFFE_ANAL_04 ,
         count(distinct e.plan1_pour_affe_anal_05)   as CNT_PLAN1_POUR_AFFE_ANAL_05 ,
         count(distinct e.plan1_pour_affe_anal_06)   as CNT_PLAN1_POUR_AFFE_ANAL_06 ,
         count(distinct e.plan1_pour_affe_anal_07)   as CNT_PLAN1_POUR_AFFE_ANAL_07 ,
         count(distinct e.plan1_pour_affe_anal_08)   as CNT_PLAN1_POUR_AFFE_ANAL_08 ,
         count(distinct e.plan1_pour_affe_anal_09)   as CNT_PLAN1_POUR_AFFE_ANAL_09 ,
         count(distinct e.plan1_pour_affe_anal_10)   as CNT_PLAN1_POUR_AFFE_ANAL_10 ,
         count(distinct e.plan1_pour_affe_anal_11)   as CNT_PLAN1_POUR_AFFE_ANAL_11 ,
         count(distinct e.plan1_pour_affe_anal_12)   as CNT_PLAN1_POUR_AFFE_ANAL_12 ,
         count(distinct e.plan1_pour_affe_anal_13)   as CNT_PLAN1_POUR_AFFE_ANAL_13 ,
         count(distinct e.plan1_pour_affe_anal_14)   as CNT_PLAN1_POUR_AFFE_ANAL_14 ,
         count(distinct e.plan1_pour_affe_anal_15)   as CNT_PLAN1_POUR_AFFE_ANAL_15 ,
         count(distinct e.plan1_pour_affe_anal_16)   as CNT_PLAN1_POUR_AFFE_ANAL_16 ,
         count(distinct e.plan1_pour_affe_anal_17)   as CNT_PLAN1_POUR_AFFE_ANAL_17 ,
         count(distinct e.plan1_pour_affe_anal_18)   as CNT_PLAN1_POUR_AFFE_ANAL_18 ,
         count(distinct e.plan1_pour_affe_anal_19)   as CNT_PLAN1_POUR_AFFE_ANAL_19 ,
         count(distinct e.plan1_pour_affe_anal_20)   as CNT_PLAN1_POUR_AFFE_ANAL_20 ,
         count(distinct e.plan2_code_anal_01)        as CNT_PLAN2_CODE_ANAL_01      ,
         count(distinct e.plan2_code_anal_02)        as CNT_PLAN2_CODE_ANAL_02      ,
         count(distinct e.plan2_code_anal_03)        as CNT_PLAN2_CODE_ANAL_03      ,
         count(distinct e.plan2_code_anal_04)        as CNT_PLAN2_CODE_ANAL_04      ,
         count(distinct e.plan2_code_anal_05)        as CNT_PLAN2_CODE_ANAL_05      ,
         count(distinct e.plan2_code_anal_06)        as CNT_PLAN2_CODE_ANAL_06      ,
         count(distinct e.plan2_code_anal_07)        as CNT_PLAN2_CODE_ANAL_07      ,
         count(distinct e.plan2_code_anal_08)        as CNT_PLAN2_CODE_ANAL_08      ,
         count(distinct e.plan2_code_anal_09)        as CNT_PLAN2_CODE_ANAL_09      ,
         count(distinct e.plan2_code_anal_10)        as CNT_PLAN2_CODE_ANAL_10      ,
         count(distinct e.plan2_code_anal_11)        as CNT_PLAN2_CODE_ANAL_11      ,
         count(distinct e.plan2_code_anal_12)        as CNT_PLAN2_CODE_ANAL_12      ,
         count(distinct e.plan2_code_anal_13)        as CNT_PLAN2_CODE_ANAL_13      ,
         count(distinct e.plan2_code_anal_14)        as CNT_PLAN2_CODE_ANAL_14      ,
         count(distinct e.plan2_code_anal_15)        as CNT_PLAN2_CODE_ANAL_15      ,
         count(distinct e.plan2_code_anal_16)        as CNT_PLAN2_CODE_ANAL_16      ,
         count(distinct e.plan2_code_anal_17)        as CNT_PLAN2_CODE_ANAL_17      ,
         count(distinct e.plan2_code_anal_18)        as CNT_PLAN2_CODE_ANAL_18      ,
         count(distinct e.plan2_code_anal_19)        as CNT_PLAN2_CODE_ANAL_19      ,
         count(distinct e.plan2_code_anal_20)        as CNT_PLAN2_CODE_ANAL_20      ,
         count(distinct e.plan2_pour_affe_anal_01)   as CNT_PLAN2_POUR_AFFE_ANAL_01 ,
         count(distinct e.plan2_pour_affe_anal_02)   as CNT_PLAN2_POUR_AFFE_ANAL_02 ,
         count(distinct e.plan2_pour_affe_anal_03)   as CNT_PLAN2_POUR_AFFE_ANAL_03 ,
         count(distinct e.plan2_pour_affe_anal_04)   as CNT_PLAN2_POUR_AFFE_ANAL_04 ,
         count(distinct e.plan2_pour_affe_anal_05)   as CNT_PLAN2_POUR_AFFE_ANAL_05 ,
         count(distinct e.plan2_pour_affe_anal_06)   as CNT_PLAN2_POUR_AFFE_ANAL_06 ,
         count(distinct e.plan2_pour_affe_anal_07)   as CNT_PLAN2_POUR_AFFE_ANAL_07 ,
         count(distinct e.plan2_pour_affe_anal_08)   as CNT_PLAN2_POUR_AFFE_ANAL_08 ,
         count(distinct e.plan2_pour_affe_anal_09)   as CNT_PLAN2_POUR_AFFE_ANAL_09 ,
         count(distinct e.plan2_pour_affe_anal_10)   as CNT_PLAN2_POUR_AFFE_ANAL_10 ,
         count(distinct e.plan2_pour_affe_anal_11)   as CNT_PLAN2_POUR_AFFE_ANAL_11 ,
         count(distinct e.plan2_pour_affe_anal_12)   as CNT_PLAN2_POUR_AFFE_ANAL_12 ,
         count(distinct e.plan2_pour_affe_anal_13)   as CNT_PLAN2_POUR_AFFE_ANAL_13 ,
         count(distinct e.plan2_pour_affe_anal_14)   as CNT_PLAN2_POUR_AFFE_ANAL_14 ,
         count(distinct e.plan2_pour_affe_anal_15)   as CNT_PLAN2_POUR_AFFE_ANAL_15 ,
         count(distinct e.plan2_pour_affe_anal_16)   as CNT_PLAN2_POUR_AFFE_ANAL_16 ,
         count(distinct e.plan2_pour_affe_anal_17)   as CNT_PLAN2_POUR_AFFE_ANAL_17 ,
         count(distinct e.plan2_pour_affe_anal_18)   as CNT_PLAN2_POUR_AFFE_ANAL_18 ,
         count(distinct e.plan2_pour_affe_anal_19)   as CNT_PLAN2_POUR_AFFE_ANAL_19 ,
         count(distinct e.plan2_pour_affe_anal_20)   as CNT_PLAN2_POUR_AFFE_ANAL_20 ,
         count(distinct e.plan3_code_anal_01)        as CNT_PLAN3_CODE_ANAL_01      ,
         count(distinct e.plan3_code_anal_02)        as CNT_PLAN3_CODE_ANAL_02      ,
         count(distinct e.plan3_code_anal_03)        as CNT_PLAN3_CODE_ANAL_03      ,
         count(distinct e.plan3_code_anal_04)        as CNT_PLAN3_CODE_ANAL_04      ,
         count(distinct e.plan3_code_anal_05)        as CNT_PLAN3_CODE_ANAL_05      ,
         count(distinct e.plan3_code_anal_06)        as CNT_PLAN3_CODE_ANAL_06      ,
         count(distinct e.plan3_code_anal_07)        as CNT_PLAN3_CODE_ANAL_07      ,
         count(distinct e.plan3_code_anal_08)        as CNT_PLAN3_CODE_ANAL_08      ,
         count(distinct e.plan3_code_anal_09)        as CNT_PLAN3_CODE_ANAL_09      ,
         count(distinct e.plan3_code_anal_10)        as CNT_PLAN3_CODE_ANAL_10      ,
         count(distinct e.plan3_code_anal_11)        as CNT_PLAN3_CODE_ANAL_11      ,
         count(distinct e.plan3_code_anal_12)        as CNT_PLAN3_CODE_ANAL_12      ,
         count(distinct e.plan3_code_anal_13)        as CNT_PLAN3_CODE_ANAL_13      ,
         count(distinct e.plan3_code_anal_14)        as CNT_PLAN3_CODE_ANAL_14      ,
         count(distinct e.plan3_code_anal_15)        as CNT_PLAN3_CODE_ANAL_15      ,
         count(distinct e.plan3_code_anal_16)        as CNT_PLAN3_CODE_ANAL_16      ,
         count(distinct e.plan3_code_anal_17)        as CNT_PLAN3_CODE_ANAL_17      ,
         count(distinct e.plan3_code_anal_18)        as CNT_PLAN3_CODE_ANAL_18      ,
         count(distinct e.plan3_code_anal_19)        as CNT_PLAN3_CODE_ANAL_19      ,
         count(distinct e.plan3_code_anal_20)        as CNT_PLAN3_CODE_ANAL_20      ,
         count(distinct e.plan3_pour_affe_anal_01)   as CNT_PLAN3_POUR_AFFE_ANAL_01 ,
         count(distinct e.plan3_pour_affe_anal_02)   as CNT_PLAN3_POUR_AFFE_ANAL_02 ,
         count(distinct e.plan3_pour_affe_anal_03)   as CNT_PLAN3_POUR_AFFE_ANAL_03 ,
         count(distinct e.plan3_pour_affe_anal_04)   as CNT_PLAN3_POUR_AFFE_ANAL_04 ,
         count(distinct e.plan3_pour_affe_anal_05)   as CNT_PLAN3_POUR_AFFE_ANAL_05 ,
         count(distinct e.plan3_pour_affe_anal_06)   as CNT_PLAN3_POUR_AFFE_ANAL_06 ,
         count(distinct e.plan3_pour_affe_anal_07)   as CNT_PLAN3_POUR_AFFE_ANAL_07 ,
         count(distinct e.plan3_pour_affe_anal_08)   as CNT_PLAN3_POUR_AFFE_ANAL_08 ,
         count(distinct e.plan3_pour_affe_anal_09)   as CNT_PLAN3_POUR_AFFE_ANAL_09 ,
         count(distinct e.plan3_pour_affe_anal_10)   as CNT_PLAN3_POUR_AFFE_ANAL_10 ,
         count(distinct e.plan3_pour_affe_anal_11)   as CNT_PLAN3_POUR_AFFE_ANAL_11 ,
         count(distinct e.plan3_pour_affe_anal_12)   as CNT_PLAN3_POUR_AFFE_ANAL_12 ,
         count(distinct e.plan3_pour_affe_anal_13)   as CNT_PLAN3_POUR_AFFE_ANAL_13 ,
         count(distinct e.plan3_pour_affe_anal_14)   as CNT_PLAN3_POUR_AFFE_ANAL_14 ,
         count(distinct e.plan3_pour_affe_anal_15)   as CNT_PLAN3_POUR_AFFE_ANAL_15 ,
         count(distinct e.plan3_pour_affe_anal_16)   as CNT_PLAN3_POUR_AFFE_ANAL_16 ,
         count(distinct e.plan3_pour_affe_anal_17)   as CNT_PLAN3_POUR_AFFE_ANAL_17 ,
         count(distinct e.plan3_pour_affe_anal_18)   as CNT_PLAN3_POUR_AFFE_ANAL_18 ,
         count(distinct e.plan3_pour_affe_anal_19)   as CNT_PLAN3_POUR_AFFE_ANAL_19 ,
         count(distinct e.plan3_pour_affe_anal_20)   as CNT_PLAN3_POUR_AFFE_ANAL_20 ,
         count(distinct e.plan4_code_anal_01)        as CNT_PLAN4_CODE_ANAL_01      ,
         count(distinct e.plan4_code_anal_02)        as CNT_PLAN4_CODE_ANAL_02      ,
         count(distinct e.plan4_code_anal_03)        as CNT_PLAN4_CODE_ANAL_03      ,
         count(distinct e.plan4_code_anal_04)        as CNT_PLAN4_CODE_ANAL_04      ,
         count(distinct e.plan4_code_anal_05)        as CNT_PLAN4_CODE_ANAL_05      ,
         count(distinct e.plan4_code_anal_06)        as CNT_PLAN4_CODE_ANAL_06      ,
         count(distinct e.plan4_code_anal_07)        as CNT_PLAN4_CODE_ANAL_07      ,
         count(distinct e.plan4_code_anal_08)        as CNT_PLAN4_CODE_ANAL_08      ,
         count(distinct e.plan4_code_anal_09)        as CNT_PLAN4_CODE_ANAL_09      ,
         count(distinct e.plan4_code_anal_10)        as CNT_PLAN4_CODE_ANAL_10      ,
         count(distinct e.plan4_code_anal_11)        as CNT_PLAN4_CODE_ANAL_11      ,
         count(distinct e.plan4_code_anal_12)        as CNT_PLAN4_CODE_ANAL_12      ,
         count(distinct e.plan4_code_anal_13)        as CNT_PLAN4_CODE_ANAL_13      ,
         count(distinct e.plan4_code_anal_14)        as CNT_PLAN4_CODE_ANAL_14      ,
         count(distinct e.plan4_code_anal_15)        as CNT_PLAN4_CODE_ANAL_15      ,
         count(distinct e.plan4_code_anal_16)        as CNT_PLAN4_CODE_ANAL_16      ,
         count(distinct e.plan4_code_anal_17)        as CNT_PLAN4_CODE_ANAL_17      ,
         count(distinct e.plan4_code_anal_18)        as CNT_PLAN4_CODE_ANAL_18      ,
         count(distinct e.plan4_code_anal_19)        as CNT_PLAN4_CODE_ANAL_19      ,
         count(distinct e.plan4_code_anal_20)        as CNT_PLAN4_CODE_ANAL_20      ,
         count(distinct e.plan4_pour_affe_anal_01)   as CNT_PLAN4_POUR_AFFE_ANAL_01 ,
         count(distinct e.plan4_pour_affe_anal_02)   as CNT_PLAN4_POUR_AFFE_ANAL_02 ,
         count(distinct e.plan4_pour_affe_anal_03)   as CNT_PLAN4_POUR_AFFE_ANAL_03 ,
         count(distinct e.plan4_pour_affe_anal_04)   as CNT_PLAN4_POUR_AFFE_ANAL_04 ,
         count(distinct e.plan4_pour_affe_anal_05)   as CNT_PLAN4_POUR_AFFE_ANAL_05 ,
         count(distinct e.plan4_pour_affe_anal_06)   as CNT_PLAN4_POUR_AFFE_ANAL_06 ,
         count(distinct e.plan4_pour_affe_anal_07)   as CNT_PLAN4_POUR_AFFE_ANAL_07 ,
         count(distinct e.plan4_pour_affe_anal_08)   as CNT_PLAN4_POUR_AFFE_ANAL_08 ,
         count(distinct e.plan4_pour_affe_anal_09)   as CNT_PLAN4_POUR_AFFE_ANAL_09 ,
         count(distinct e.plan4_pour_affe_anal_10)   as CNT_PLAN4_POUR_AFFE_ANAL_10 ,
         count(distinct e.plan4_pour_affe_anal_11)   as CNT_PLAN4_POUR_AFFE_ANAL_11 ,
         count(distinct e.plan4_pour_affe_anal_12)   as CNT_PLAN4_POUR_AFFE_ANAL_12 ,
         count(distinct e.plan4_pour_affe_anal_13)   as CNT_PLAN4_POUR_AFFE_ANAL_13 ,
         count(distinct e.plan4_pour_affe_anal_14)   as CNT_PLAN4_POUR_AFFE_ANAL_14 ,
         count(distinct e.plan4_pour_affe_anal_15)   as CNT_PLAN4_POUR_AFFE_ANAL_15 ,
         count(distinct e.plan4_pour_affe_anal_16)   as CNT_PLAN4_POUR_AFFE_ANAL_16 ,
         count(distinct e.plan4_pour_affe_anal_17)   as CNT_PLAN4_POUR_AFFE_ANAL_17 ,
         count(distinct e.plan4_pour_affe_anal_18)   as CNT_PLAN4_POUR_AFFE_ANAL_18 ,
         count(distinct e.plan4_pour_affe_anal_19)   as CNT_PLAN4_POUR_AFFE_ANAL_19 ,
         count(distinct e.plan4_pour_affe_anal_20)   as CNT_PLAN4_POUR_AFFE_ANAL_20 ,
         count(distinct e.plan5_code_anal_01)        as CNT_PLAN5_CODE_ANAL_01      ,
         count(distinct e.plan5_code_anal_02)        as CNT_PLAN5_CODE_ANAL_02      ,
         count(distinct e.plan5_code_anal_03)        as CNT_PLAN5_CODE_ANAL_03      ,
         count(distinct e.plan5_code_anal_04)        as CNT_PLAN5_CODE_ANAL_04      ,
         count(distinct e.plan5_code_anal_05)        as CNT_PLAN5_CODE_ANAL_05      ,
         count(distinct e.plan5_code_anal_06)        as CNT_PLAN5_CODE_ANAL_06      ,
         count(distinct e.plan5_code_anal_07)        as CNT_PLAN5_CODE_ANAL_07      ,
         count(distinct e.plan5_code_anal_08)        as CNT_PLAN5_CODE_ANAL_08      ,
         count(distinct e.plan5_code_anal_09)        as CNT_PLAN5_CODE_ANAL_09      ,
         count(distinct e.plan5_code_anal_10)        as CNT_PLAN5_CODE_ANAL_10      ,
         count(distinct e.plan5_code_anal_11)        as CNT_PLAN5_CODE_ANAL_11      ,
         count(distinct e.plan5_code_anal_12)        as CNT_PLAN5_CODE_ANAL_12      ,
         count(distinct e.plan5_code_anal_13)        as CNT_PLAN5_CODE_ANAL_13      ,
         count(distinct e.plan5_code_anal_14)        as CNT_PLAN5_CODE_ANAL_14      ,
         count(distinct e.plan5_code_anal_15)        as CNT_PLAN5_CODE_ANAL_15      ,
         count(distinct e.plan5_code_anal_16)        as CNT_PLAN5_CODE_ANAL_16      ,
         count(distinct e.plan5_code_anal_17)        as CNT_PLAN5_CODE_ANAL_17      ,
         count(distinct e.plan5_code_anal_18)        as CNT_PLAN5_CODE_ANAL_18      ,
         count(distinct e.plan5_code_anal_19)        as CNT_PLAN5_CODE_ANAL_19      ,
         count(distinct e.plan5_code_anal_20)        as CNT_PLAN5_CODE_ANAL_20      ,
         count(distinct e.plan5_pour_affe_anal_01)   as CNT_PLAN5_POUR_AFFE_ANAL_01 ,
         count(distinct e.plan5_pour_affe_anal_02)   as CNT_PLAN5_POUR_AFFE_ANAL_02 ,
         count(distinct e.plan5_pour_affe_anal_03)   as CNT_PLAN5_POUR_AFFE_ANAL_03 ,
         count(distinct e.plan5_pour_affe_anal_04)   as CNT_PLAN5_POUR_AFFE_ANAL_04 ,
         count(distinct e.plan5_pour_affe_anal_05)   as CNT_PLAN5_POUR_AFFE_ANAL_05 ,
         count(distinct e.plan5_pour_affe_anal_06)   as CNT_PLAN5_POUR_AFFE_ANAL_06 ,
         count(distinct e.plan5_pour_affe_anal_07)   as CNT_PLAN5_POUR_AFFE_ANAL_07 ,
         count(distinct e.plan5_pour_affe_anal_08)   as CNT_PLAN5_POUR_AFFE_ANAL_08 ,
         count(distinct e.plan5_pour_affe_anal_09)   as CNT_PLAN5_POUR_AFFE_ANAL_09 ,
         count(distinct e.plan5_pour_affe_anal_10)   as CNT_PLAN5_POUR_AFFE_ANAL_10 ,
         count(distinct e.plan5_pour_affe_anal_11)   as CNT_PLAN5_POUR_AFFE_ANAL_11 ,
         count(distinct e.plan5_pour_affe_anal_12)   as CNT_PLAN5_POUR_AFFE_ANAL_12 ,
         count(distinct e.plan5_pour_affe_anal_13)   as CNT_PLAN5_POUR_AFFE_ANAL_13 ,
         count(distinct e.plan5_pour_affe_anal_14)   as CNT_PLAN5_POUR_AFFE_ANAL_14 ,
         count(distinct e.plan5_pour_affe_anal_15)   as CNT_PLAN5_POUR_AFFE_ANAL_15 ,
         count(distinct e.plan5_pour_affe_anal_16)   as CNT_PLAN5_POUR_AFFE_ANAL_16 ,
         count(distinct e.plan5_pour_affe_anal_17)   as CNT_PLAN5_POUR_AFFE_ANAL_17 ,
         count(distinct e.plan5_pour_affe_anal_18)   as CNT_PLAN5_POUR_AFFE_ANAL_18 ,
         count(distinct e.plan5_pour_affe_anal_19)   as CNT_PLAN5_POUR_AFFE_ANAL_19 ,
         count(distinct e.plan5_pour_affe_anal_20)   as CNT_PLAN5_POUR_AFFE_ANAL_20 ,
         max(l2.calc_rubr_01)                        as CALC_RUBR_01                ,
         max(l2.calc_rubr_02)                        as CALC_RUBR_02                ,
         max(l2.calc_rubr_03)                        as CALC_RUBR_03                ,
         max(l2.calc_rubr_04)                        as CALC_RUBR_04                ,
         max(l2.calc_rubr_05)                        as CALC_RUBR_05                ,
         max(l2.calc_rubr_06)                        as CALC_RUBR_06                ,
         max(l2.calc_rubr_07)                        as CALC_RUBR_07                ,
         max(l2.calc_rubr_08)                        as CALC_RUBR_08                ,
         max(l2.calc_rubr_09)                        as CALC_RUBR_09                ,
         max(l2.calc_rubr_10)                        as CALC_RUBR_10                ,
         max(l2.calc_rubr_11)                        as CALC_RUBR_11                ,
         max(l2.calc_rubr_12)                        as CALC_RUBR_12                ,
         max(l2.calc_rubr_13)                        as CALC_RUBR_13                ,
         max(l2.calc_rubr_14)                        as CALC_RUBR_14                ,
         max(l2.calc_rubr_15)                        as CALC_RUBR_15                ,
         max(l2.calc_rubr_16)                        as CALC_RUBR_16                ,
         max(l2.calc_rubr_17)                        as CALC_RUBR_17                ,
         max(l2.calc_rubr_18)                        as CALC_RUBR_18                ,
         max(l2.calc_rubr_19)                        as CALC_RUBR_19                ,
         max(l2.calc_rubr_20)                        as CALC_RUBR_20                ,
         max(l2.calc_rubr_21)                        as CALC_RUBR_21                ,
         max(l2.calc_rubr_22)                        as CALC_RUBR_22                ,
         max(l2.calc_rubr_23)                        as CALC_RUBR_23                ,
         max(l2.calc_rubr_24)                        as CALC_RUBR_24                ,
         max(l2.calc_rubr_25)                        as CALC_RUBR_25                ,
         max(l2.calc_rubr_26)                        as CALC_RUBR_26                ,
         max(l2.calc_rubr_27)                        as CALC_RUBR_27                ,
         max(l2.calc_rubr_28)                        as CALC_RUBR_28                ,
         max(l2.calc_rubr_29)                        as CALC_RUBR_29                ,
         max(l2.calc_rubr_30)                        as CALC_RUBR_30                ,
         max(l2.calc_rubr_31)                        as CALC_RUBR_31                ,
         max(l2.calc_rubr_32)                        as CALC_RUBR_32                ,
         max(l2.calc_rubr_33)                        as CALC_RUBR_33                ,
         max(l2.calc_rubr_34)                        as CALC_RUBR_34                ,
         max(l2.calc_rubr_35)                        as CALC_RUBR_35                ,
         max(l2.calc_rubr_36)                        as CALC_RUBR_36                ,
         max(l2.calc_rubr_37)                        as CALC_RUBR_37                ,
         max(l2.calc_rubr_38)                        as CALC_RUBR_38                ,
         max(l2.calc_rubr_39)                        as CALC_RUBR_39                ,
         max(l2.calc_rubr_40)                        as CALC_RUBR_40                ,
         max(l2.calc_rubr_41)                        as CALC_RUBR_41                ,
         max(l2.calc_rubr_42)                        as CALC_RUBR_42                ,
         max(l2.calc_rubr_43)                        as CALC_RUBR_43                ,
         max(l2.calc_rubr_44)                        as CALC_RUBR_44                ,
         max(l2.calc_rubr_45)                        as CALC_RUBR_45                ,
         max(l2.calc_rubr_46)                        as CALC_RUBR_46                ,
         max(l2.calc_rubr_47)                        as CALC_RUBR_47                ,
         max(l2.calc_rubr_48)                        as CALC_RUBR_48                ,
         max(l2.calc_rubr_49)                        as CALC_RUBR_49                ,
         max(l2.calc_rubr_50)                        as CALC_RUBR_50                ,
         max(l2.calc_rubr_51)                        as CALC_RUBR_51                ,
         max(l2.calc_rubr_52)                        as CALC_RUBR_52                ,
         max(l2.calc_rubr_53)                        as CALC_RUBR_53                ,
         max(l2.calc_rubr_54)                        as CALC_RUBR_54                ,
         max(l2.calc_rubr_55)                        as CALC_RUBR_55                ,
         max(l2.calc_rubr_56)                        as CALC_RUBR_56                ,
         max(l2.calc_rubr_57)                        as CALC_RUBR_57                ,
         max(l2.calc_rubr_58)                        as CALC_RUBR_58                ,
         max(l2.calc_rubr_59)                        as CALC_RUBR_59                ,
         max(l2.calc_rubr_60)                        as CALC_RUBR_60                ,
         max(l2.calc_rubr_61)                        as CALC_RUBR_61                ,
         max(l2.calc_rubr_62)                        as CALC_RUBR_62                ,
         max(l2.calc_rubr_63)                        as CALC_RUBR_63                ,
         max(l2.calc_rubr_64)                        as CALC_RUBR_64                ,
         max(l2.calc_rubr_65)                        as CALC_RUBR_65                ,
         max(l2.calc_rubr_66)                        as CALC_RUBR_66                ,
         max(l2.calc_rubr_67)                        as CALC_RUBR_67                ,
         max(l2.calc_rubr_68)                        as CALC_RUBR_68                ,
         max(l2.calc_rubr_69)                        as CALC_RUBR_69                ,
         max(l2.calc_rubr_70)                        as CALC_RUBR_70                ,
         max(l2.calc_rubr_71)                        as CALC_RUBR_71                ,
         max(l2.calc_rubr_72)                        as CALC_RUBR_72                ,
         max(l2.calc_rubr_73)                        as CALC_RUBR_73                ,
         max(l2.calc_rubr_74)                        as CALC_RUBR_74                ,
         max(l2.calc_rubr_75)                        as CALC_RUBR_75                ,
         max(l2.calc_rubr_76)                        as CALC_RUBR_76                ,
         max(l2.calc_rubr_77)                        as CALC_RUBR_77                ,
         max(l2.calc_rubr_78)                        as CALC_RUBR_78                ,
         max(l2.calc_rubr_79)                        as CALC_RUBR_79                ,
         max(l2.calc_rubr_80)                        as CALC_RUBR_80                ,
         max(l2.calc_rubr_81)                        as CALC_RUBR_81                ,
         max(l2.calc_rubr_82)                        as CALC_RUBR_82                ,
         max(l2.calc_rubr_83)                        as CALC_RUBR_83                ,
         max(l2.calc_rubr_84)                        as CALC_RUBR_84                ,
         max(l2.calc_rubr_85)                        as CALC_RUBR_85                ,
         max(l2.calc_rubr_86)                        as CALC_RUBR_86                ,
         max(l2.calc_rubr_87)                        as CALC_RUBR_87                ,
         max(l2.calc_rubr_88)                        as CALC_RUBR_88                ,
         max(l2.calc_rubr_89)                        as CALC_RUBR_89                ,
         max(l2.calc_rubr_90)                        as CALC_RUBR_90                ,
         max(l2.calc_rubr_91)                        as CALC_RUBR_91                ,
         max(l2.calc_rubr_92)                        as CALC_RUBR_92                ,
         max(l2.calc_rubr_93)                        as CALC_RUBR_93                ,
         max(l2.calc_rubr_94)                        as CALC_RUBR_94                ,
         max(l2.calc_rubr_95)                        as CALC_RUBR_95                ,
         max(l2.calc_rubr_96)                        as CALC_RUBR_96                ,
         max(l2.calc_rubr_97)                        as CALC_RUBR_97                ,
         max(l2.calc_rubr_98)                        as CALC_RUBR_98                ,
         max(l2.calc_rubr_99)                        as CALC_RUBR_99                ,
         max(l2.calc_rubr_100)                        as CALC_RUBR_100                ,
         max(l2.calc_rubr_101)                        as CALC_RUBR_101                ,
         max(l2.calc_rubr_102)                        as CALC_RUBR_102                ,
         max(l2.calc_rubr_103)                        as CALC_RUBR_103                ,
         max(l2.calc_rubr_104)                        as CALC_RUBR_104                ,
         max(l2.calc_rubr_105)                        as CALC_RUBR_105                ,
         max(l2.calc_rubr_106)                        as CALC_RUBR_106                ,
         max(l2.calc_rubr_107)                        as CALC_RUBR_107                ,
         max(l2.calc_rubr_108)                        as CALC_RUBR_108                ,
         max(l2.calc_rubr_109)                        as CALC_RUBR_109                ,
         max(l2.calc_rubr_110)                        as CALC_RUBR_110                ,
         max(l2.calc_rubr_111)                        as CALC_RUBR_111                ,
         max(l2.calc_rubr_112)                        as CALC_RUBR_112                ,
         max(l2.calc_rubr_113)                        as CALC_RUBR_113                ,
         max(l2.calc_rubr_114)                        as CALC_RUBR_114                ,
         max(l2.calc_rubr_115)                        as CALC_RUBR_115                ,
         max(l2.calc_rubr_116)                        as CALC_RUBR_116                ,
         max(l2.calc_rubr_117)                        as CALC_RUBR_117                ,
         max(l2.calc_rubr_118)                        as CALC_RUBR_118                ,
         max(l2.calc_rubr_119)                        as CALC_RUBR_119                ,
         max(l2.calc_rubr_120)                        as CALC_RUBR_120                ,
         max(l2.calc_rubr_121)                        as CALC_RUBR_121                ,
         max(l2.calc_rubr_122)                        as CALC_RUBR_122                ,
         max(l2.calc_rubr_123)                        as CALC_RUBR_123                ,
         max(l2.calc_rubr_124)                        as CALC_RUBR_124                ,
         max(l2.calc_rubr_125)                        as CALC_RUBR_125                ,
         max(l2.calc_rubr_126)                        as CALC_RUBR_126                ,
         max(l2.calc_rubr_127)                        as CALC_RUBR_127                ,
         max(l2.calc_rubr_128)                        as CALC_RUBR_128                ,
         max(l2.calc_rubr_129)                        as CALC_RUBR_129                ,
         max(l2.calc_rubr_130)                        as CALC_RUBR_130                ,
         max(l2.calc_rubr_131)                        as CALC_RUBR_131                ,
         max(l2.calc_rubr_132)                        as CALC_RUBR_132                ,
         max(l2.calc_rubr_133)                        as CALC_RUBR_133                ,
         max(l2.calc_rubr_134)                        as CALC_RUBR_134                ,
         max(l2.calc_rubr_135)                        as CALC_RUBR_135                ,
         max(l2.calc_rubr_136)                        as CALC_RUBR_136                ,
         max(l2.calc_rubr_137)                        as CALC_RUBR_137                ,
         max(l2.calc_rubr_138)                        as CALC_RUBR_138                ,
         max(l2.calc_rubr_139)                        as CALC_RUBR_139                ,
         max(l2.calc_rubr_140)                        as CALC_RUBR_140                ,
         max(l2.calc_rubr_141)                        as CALC_RUBR_141                ,
         max(l2.calc_rubr_142)                        as CALC_RUBR_142                ,
         max(l2.calc_rubr_143)                        as CALC_RUBR_143                ,
         max(l2.calc_rubr_144)                        as CALC_RUBR_144                ,
         max(l2.calc_rubr_145)                        as CALC_RUBR_145                ,
         max(l2.calc_rubr_146)                        as CALC_RUBR_146                ,
         max(l2.calc_rubr_147)                        as CALC_RUBR_147                ,
         max(l2.calc_rubr_148)                        as CALC_RUBR_148                ,
         max(l2.calc_rubr_149)                        as CALC_RUBR_149                ,
         max(l2.calc_rubr_150)                        as CALC_RUBR_150                ,

         max(e.code_fine_geog)                        as CODE_FINE_GEOG               ,
         count(distinct e.code_fine_geog)             as CNT_CODE_FINE_GEOG           ,

         max(e.rib_guic_1)                            as RIB_GUIC_1                   ,
         count(distinct e.rib_guic_1)                 as CNT_RIB_GUIC_1               ,
         max(e.rib_comp_1)                            as RIB_COMP_1                   ,
         count(distinct e.rib_comp_1)                 as CNT_RIB_COMP_1               ,
         max(e.rib_cle_1)                             as RIB_CLE_1                    ,
         count(distinct e.rib_cle_1)                  as CNT_RIB_CLE_1                ,
         max(e.rib_banq_01)                           as RIB_BANQ_01                  ,
         count(distinct e.rib_banq_01)                as CNT_RIB_BANQ_01              ,
         max(e.rib_banq_02)                           as RIB_BANQ_02                  ,
         count(distinct e.rib_banq_02)                as CNT_RIB_BANQ_02              ,

         max(e.prof_temp_libe)                        as PROF_TEMP_LIBE               ,
         count(distinct e.prof_temp_libe)             as CNT_PROF_TEMP_LIBE           ,

         max(e.nomb_jour_cong_anci)                   as NOMB_JOUR_CONG_ANCI          ,
         count(distinct e.nomb_jour_cong_anci)        as CNT_NOMB_JOUR_CONG_ANCI      ,

         max(e.mont_anci_pa)                          as MONT_ANCI_PA                ,
         count(distinct e.mont_anci_pa)               as CNT_MONT_ANCI_PA            ,

        max(e.anci_cadr)                              as ANCI_CADR                   ,
        count(distinct e.anci_cadr)                   as CNT_ANCI_CADR               ,

        max(e.tota_heur_trav)                              as TOTA_HEUR_TRAV         ,
        count(distinct e.tota_heur_trav)                   as CNT_TOTA_HEUR_TRAV     ,

        max(e.DPAE_ENVO)                              as DPAE_ENVO                   ,
        count(distinct e.DPAE_ENVO)                   as CNT_DPAE_ENVO                   ,
        
        max(e.DISP_POLI_PUBL_CONV)                    as DISP_POLI_PUBL_CONV         ,
        count(distinct e.DISP_POLI_PUBL_CONV)         as CNT_DISP_POLI_PUBL_CONV         ,
                
        max(e.DATE_ANCI_CADR_FORF)                    as DATE_ANCI_CADR_FORF         ,
        count(distinct e.DATE_ANCI_CADR_FORF)         as CNT_DATE_ANCI_CADR_FORF         

      from pers_edit_gestion_avancee e,liste_gestion_avancee l,liste_gestion_avancee_2 l2
      where
          e.id_soci=iID_SOCI
      and e.id_logi=iID_LOGI
      and e.id_para=vID_PARA
      and e.id_list=vID_LIST
      and l.id_list=e.id_list
      and l2.id_list (+)=l.id_list
      and e.lign=1
      group by case oPara.libr_4
                  when 'SALA' then
                     to_char(e.id_sala)
                  when 'ANAL' then
                     e.repa_anal_code
                  when 'DIVI' then
                     e.divi
                  when 'CATE' then
                     to_char(e.id_cate)
                  when 'SERV' then
                     e.serv
                  when 'EQUI' then
                     e.equi
                  when 'DEPA'  then
                     e.depa
                  when 'ETAB' then
                     to_char(e.id_etab)
                  when 'MATR_SOCI' then
                     to_char(nvl(e.matr,'#:'||e.id_sala||':#'))
                  when 'MATR_GROU' then
                     to_char(nvl(e.matr_grou,'#:'||e.id_sala||':#'))
                  -- js 2007 02 10 : incohérent, supprimé du template de paramétrage when 'PERI'  then
                  -- js 2007 02 10 : incohérent, supprimé du template de paramétrage    e.peri
                  else
                     to_char(e.id_sala)
               end
      order by case oPara.tri
                  when 'SALA' then
                     max(to_char(e.id_sala))
                  when 'ANAL' then
                     max(e.repa_anal_code)
                  when 'DIVI' then
                     max(e.divi)
                  when 'CATE' then
                     max(to_char(e.id_cate))
                  when 'SERV' then
                     max(e.serv)
                  when 'DEPA'  then
                     max(e.depa)
                  when 'ETAB' then
                     max(to_char(e.id_etab))
                  when 'MATR_SOCI' then
                     to_char(nvl(max(e.matr),'#:'||max(e.id_sala)||':#'))
                  when 'MATR_GROU' then
                     to_char(nvl(max(e.matr_grou),'#:'||max(e.id_sala)||':#'))
                  -- js 2007 02 10 : incohérent, supprimé du template de paramétrage when 'PERI'  then
                  -- js 2007 02 10 : incohérent, supprimé du template de paramétrage    e.peri
                  else
                     max(to_char(e.id_sala))
               end
   )loop

       vDERN_PERI_AFFI    := to_char(grp.peri, 'DD/MM/YYYY');

       if instr(oList.vale_rubr_01,'TAUX')=0 then oGeav.rubr_01:=grp.sum_rubr_01; else oGeav.rubr_01:=grp.sum_rubr_01/grp.cnt; end if;
       if instr(oList.vale_rubr_02,'TAUX')=0 then oGeav.rubr_02:=grp.sum_rubr_02; else oGeav.rubr_02:=grp.sum_rubr_02/grp.cnt; end if;
       if instr(oList.vale_rubr_03,'TAUX')=0 then oGeav.rubr_03:=grp.sum_rubr_03; else oGeav.rubr_03:=grp.sum_rubr_03/grp.cnt; end if;
       if instr(oList.vale_rubr_04,'TAUX')=0 then oGeav.rubr_04:=grp.sum_rubr_04; else oGeav.rubr_04:=grp.sum_rubr_04/grp.cnt; end if;
       if instr(oList.vale_rubr_05,'TAUX')=0 then oGeav.rubr_05:=grp.sum_rubr_05; else oGeav.rubr_05:=grp.sum_rubr_05/grp.cnt; end if;
       if instr(oList.vale_rubr_06,'TAUX')=0 then oGeav.rubr_06:=grp.sum_rubr_06; else oGeav.rubr_06:=grp.sum_rubr_06/grp.cnt; end if;
       if instr(oList.vale_rubr_07,'TAUX')=0 then oGeav.rubr_07:=grp.sum_rubr_07; else oGeav.rubr_07:=grp.sum_rubr_07/grp.cnt; end if;
       if instr(oList.vale_rubr_08,'TAUX')=0 then oGeav.rubr_08:=grp.sum_rubr_08; else oGeav.rubr_08:=grp.sum_rubr_08/grp.cnt; end if;
       if instr(oList.vale_rubr_09,'TAUX')=0 then oGeav.rubr_09:=grp.sum_rubr_09; else oGeav.rubr_09:=grp.sum_rubr_09/grp.cnt; end if;
       if instr(oList.vale_rubr_10,'TAUX')=0 then oGeav.rubr_10:=grp.sum_rubr_10; else oGeav.rubr_10:=grp.sum_rubr_10/grp.cnt; end if;
       if instr(oList.vale_rubr_11,'TAUX')=0 then oGeav.rubr_11:=grp.sum_rubr_11; else oGeav.rubr_11:=grp.sum_rubr_11/grp.cnt; end if;
       if instr(oList.vale_rubr_12,'TAUX')=0 then oGeav.rubr_12:=grp.sum_rubr_12; else oGeav.rubr_12:=grp.sum_rubr_12/grp.cnt; end if;
       if instr(oList.vale_rubr_13,'TAUX')=0 then oGeav.rubr_13:=grp.sum_rubr_13; else oGeav.rubr_13:=grp.sum_rubr_13/grp.cnt; end if;
       if instr(oList.vale_rubr_14,'TAUX')=0 then oGeav.rubr_14:=grp.sum_rubr_14; else oGeav.rubr_14:=grp.sum_rubr_14/grp.cnt; end if;
       if instr(oList.vale_rubr_15,'TAUX')=0 then oGeav.rubr_15:=grp.sum_rubr_15; else oGeav.rubr_15:=grp.sum_rubr_15/grp.cnt; end if;
       if instr(oList.vale_rubr_16,'TAUX')=0 then oGeav.rubr_16:=grp.sum_rubr_16; else oGeav.rubr_16:=grp.sum_rubr_16/grp.cnt; end if;
       if instr(oList.vale_rubr_17,'TAUX')=0 then oGeav.rubr_17:=grp.sum_rubr_17; else oGeav.rubr_17:=grp.sum_rubr_17/grp.cnt; end if;
       if instr(oList.vale_rubr_18,'TAUX')=0 then oGeav.rubr_18:=grp.sum_rubr_18; else oGeav.rubr_18:=grp.sum_rubr_18/grp.cnt; end if;
       if instr(oList.vale_rubr_19,'TAUX')=0 then oGeav.rubr_19:=grp.sum_rubr_19; else oGeav.rubr_19:=grp.sum_rubr_19/grp.cnt; end if;
       if instr(oList.vale_rubr_20,'TAUX')=0 then oGeav.rubr_20:=grp.sum_rubr_20; else oGeav.rubr_20:=grp.sum_rubr_20/grp.cnt; end if;
       if instr(oList.vale_rubr_21,'TAUX')=0 then oGeav.rubr_21:=grp.sum_rubr_21; else oGeav.rubr_21:=grp.sum_rubr_21/grp.cnt; end if;
       if instr(oList.vale_rubr_22,'TAUX')=0 then oGeav.rubr_22:=grp.sum_rubr_22; else oGeav.rubr_22:=grp.sum_rubr_22/grp.cnt; end if;
       if instr(oList.vale_rubr_23,'TAUX')=0 then oGeav.rubr_23:=grp.sum_rubr_23; else oGeav.rubr_23:=grp.sum_rubr_23/grp.cnt; end if;
       if instr(oList.vale_rubr_24,'TAUX')=0 then oGeav.rubr_24:=grp.sum_rubr_24; else oGeav.rubr_24:=grp.sum_rubr_24/grp.cnt; end if;
       if instr(oList.vale_rubr_25,'TAUX')=0 then oGeav.rubr_25:=grp.sum_rubr_25; else oGeav.rubr_25:=grp.sum_rubr_25/grp.cnt; end if;
       if instr(oList.vale_rubr_26,'TAUX')=0 then oGeav.rubr_26:=grp.sum_rubr_26; else oGeav.rubr_26:=grp.sum_rubr_26/grp.cnt; end if;
       if instr(oList.vale_rubr_27,'TAUX')=0 then oGeav.rubr_27:=grp.sum_rubr_27; else oGeav.rubr_27:=grp.sum_rubr_27/grp.cnt; end if;
       if instr(oList.vale_rubr_28,'TAUX')=0 then oGeav.rubr_28:=grp.sum_rubr_28; else oGeav.rubr_28:=grp.sum_rubr_28/grp.cnt; end if;
       if instr(oList.vale_rubr_29,'TAUX')=0 then oGeav.rubr_29:=grp.sum_rubr_29; else oGeav.rubr_29:=grp.sum_rubr_29/grp.cnt; end if;
       if instr(oList.vale_rubr_30,'TAUX')=0 then oGeav.rubr_30:=grp.sum_rubr_30; else oGeav.rubr_30:=grp.sum_rubr_30/grp.cnt; end if;
       if instr(oList.vale_rubr_31,'TAUX')=0 then oGeav.rubr_31:=grp.sum_rubr_31; else oGeav.rubr_31:=grp.sum_rubr_31/grp.cnt; end if;
       if instr(oList.vale_rubr_32,'TAUX')=0 then oGeav.rubr_32:=grp.sum_rubr_32; else oGeav.rubr_32:=grp.sum_rubr_32/grp.cnt; end if;
       if instr(oList.vale_rubr_33,'TAUX')=0 then oGeav.rubr_33:=grp.sum_rubr_33; else oGeav.rubr_33:=grp.sum_rubr_33/grp.cnt; end if;
       if instr(oList.vale_rubr_34,'TAUX')=0 then oGeav.rubr_34:=grp.sum_rubr_34; else oGeav.rubr_34:=grp.sum_rubr_34/grp.cnt; end if;
       if instr(oList.vale_rubr_35,'TAUX')=0 then oGeav.rubr_35:=grp.sum_rubr_35; else oGeav.rubr_35:=grp.sum_rubr_35/grp.cnt; end if;
       if instr(oList.vale_rubr_36,'TAUX')=0 then oGeav.rubr_36:=grp.sum_rubr_36; else oGeav.rubr_36:=grp.sum_rubr_36/grp.cnt; end if;
       if instr(oList.vale_rubr_37,'TAUX')=0 then oGeav.rubr_37:=grp.sum_rubr_37; else oGeav.rubr_37:=grp.sum_rubr_37/grp.cnt; end if;
       if instr(oList.vale_rubr_38,'TAUX')=0 then oGeav.rubr_38:=grp.sum_rubr_38; else oGeav.rubr_38:=grp.sum_rubr_38/grp.cnt; end if;
       if instr(oList.vale_rubr_39,'TAUX')=0 then oGeav.rubr_39:=grp.sum_rubr_39; else oGeav.rubr_39:=grp.sum_rubr_39/grp.cnt; end if;
       if instr(oList.vale_rubr_40,'TAUX')=0 then oGeav.rubr_40:=grp.sum_rubr_40; else oGeav.rubr_40:=grp.sum_rubr_40/grp.cnt; end if;
       if instr(oList.vale_rubr_41,'TAUX')=0 then oGeav.rubr_41:=grp.sum_rubr_41; else oGeav.rubr_41:=grp.sum_rubr_41/grp.cnt; end if;
       if instr(oList.vale_rubr_42,'TAUX')=0 then oGeav.rubr_42:=grp.sum_rubr_42; else oGeav.rubr_42:=grp.sum_rubr_42/grp.cnt; end if;
       if instr(oList.vale_rubr_43,'TAUX')=0 then oGeav.rubr_43:=grp.sum_rubr_43; else oGeav.rubr_43:=grp.sum_rubr_43/grp.cnt; end if;
       if instr(oList.vale_rubr_44,'TAUX')=0 then oGeav.rubr_44:=grp.sum_rubr_44; else oGeav.rubr_44:=grp.sum_rubr_44/grp.cnt; end if;
       if instr(oList.vale_rubr_45,'TAUX')=0 then oGeav.rubr_45:=grp.sum_rubr_45; else oGeav.rubr_45:=grp.sum_rubr_45/grp.cnt; end if;
       if instr(oList.vale_rubr_46,'TAUX')=0 then oGeav.rubr_46:=grp.sum_rubr_46; else oGeav.rubr_46:=grp.sum_rubr_46/grp.cnt; end if;
       if instr(oList.vale_rubr_47,'TAUX')=0 then oGeav.rubr_47:=grp.sum_rubr_47; else oGeav.rubr_47:=grp.sum_rubr_47/grp.cnt; end if;
       if instr(oList.vale_rubr_48,'TAUX')=0 then oGeav.rubr_48:=grp.sum_rubr_48; else oGeav.rubr_48:=grp.sum_rubr_48/grp.cnt; end if;
       if instr(oList.vale_rubr_49,'TAUX')=0 then oGeav.rubr_49:=grp.sum_rubr_49; else oGeav.rubr_49:=grp.sum_rubr_49/grp.cnt; end if;
       if instr(oList.vale_rubr_50,'TAUX')=0 then oGeav.rubr_50:=grp.sum_rubr_50; else oGeav.rubr_50:=grp.sum_rubr_50/grp.cnt; end if;

       if instr(oList_2.vale_rubr_51,'TAUX')=0 then oGeav.rubr_51:=grp.sum_rubr_51; else oGeav.rubr_51:=grp.sum_rubr_51/grp.cnt; end if;
       if instr(oList_2.vale_rubr_52,'TAUX')=0 then oGeav.rubr_52:=grp.sum_rubr_52; else oGeav.rubr_52:=grp.sum_rubr_52/grp.cnt; end if;
       if instr(oList_2.vale_rubr_53,'TAUX')=0 then oGeav.rubr_53:=grp.sum_rubr_53; else oGeav.rubr_53:=grp.sum_rubr_53/grp.cnt; end if;
       if instr(oList_2.vale_rubr_54,'TAUX')=0 then oGeav.rubr_54:=grp.sum_rubr_54; else oGeav.rubr_54:=grp.sum_rubr_54/grp.cnt; end if;
       if instr(oList_2.vale_rubr_55,'TAUX')=0 then oGeav.rubr_55:=grp.sum_rubr_55; else oGeav.rubr_55:=grp.sum_rubr_55/grp.cnt; end if;
       if instr(oList_2.vale_rubr_56,'TAUX')=0 then oGeav.rubr_56:=grp.sum_rubr_56; else oGeav.rubr_56:=grp.sum_rubr_56/grp.cnt; end if;
       if instr(oList_2.vale_rubr_57,'TAUX')=0 then oGeav.rubr_57:=grp.sum_rubr_57; else oGeav.rubr_57:=grp.sum_rubr_57/grp.cnt; end if;
       if instr(oList_2.vale_rubr_58,'TAUX')=0 then oGeav.rubr_58:=grp.sum_rubr_58; else oGeav.rubr_58:=grp.sum_rubr_58/grp.cnt; end if;
       if instr(oList_2.vale_rubr_59,'TAUX')=0 then oGeav.rubr_59:=grp.sum_rubr_59; else oGeav.rubr_59:=grp.sum_rubr_59/grp.cnt; end if;
       if instr(oList_2.vale_rubr_60,'TAUX')=0 then oGeav.rubr_60:=grp.sum_rubr_60; else oGeav.rubr_60:=grp.sum_rubr_60/grp.cnt; end if;
       if instr(oList_2.vale_rubr_61,'TAUX')=0 then oGeav.rubr_61:=grp.sum_rubr_61; else oGeav.rubr_61:=grp.sum_rubr_61/grp.cnt; end if;
       if instr(oList_2.vale_rubr_62,'TAUX')=0 then oGeav.rubr_62:=grp.sum_rubr_62; else oGeav.rubr_62:=grp.sum_rubr_62/grp.cnt; end if;
       if instr(oList_2.vale_rubr_63,'TAUX')=0 then oGeav.rubr_63:=grp.sum_rubr_63; else oGeav.rubr_63:=grp.sum_rubr_63/grp.cnt; end if;
       if instr(oList_2.vale_rubr_64,'TAUX')=0 then oGeav.rubr_64:=grp.sum_rubr_64; else oGeav.rubr_64:=grp.sum_rubr_64/grp.cnt; end if;
       if instr(oList_2.vale_rubr_65,'TAUX')=0 then oGeav.rubr_65:=grp.sum_rubr_65; else oGeav.rubr_65:=grp.sum_rubr_65/grp.cnt; end if;
       if instr(oList_2.vale_rubr_66,'TAUX')=0 then oGeav.rubr_66:=grp.sum_rubr_66; else oGeav.rubr_66:=grp.sum_rubr_66/grp.cnt; end if;
       if instr(oList_2.vale_rubr_67,'TAUX')=0 then oGeav.rubr_67:=grp.sum_rubr_67; else oGeav.rubr_67:=grp.sum_rubr_67/grp.cnt; end if;
       if instr(oList_2.vale_rubr_68,'TAUX')=0 then oGeav.rubr_68:=grp.sum_rubr_68; else oGeav.rubr_68:=grp.sum_rubr_68/grp.cnt; end if;
       if instr(oList_2.vale_rubr_69,'TAUX')=0 then oGeav.rubr_69:=grp.sum_rubr_69; else oGeav.rubr_69:=grp.sum_rubr_69/grp.cnt; end if;
       if instr(oList_2.vale_rubr_70,'TAUX')=0 then oGeav.rubr_70:=grp.sum_rubr_70; else oGeav.rubr_70:=grp.sum_rubr_70/grp.cnt; end if;
       if instr(oList_2.vale_rubr_71,'TAUX')=0 then oGeav.rubr_71:=grp.sum_rubr_71; else oGeav.rubr_71:=grp.sum_rubr_71/grp.cnt; end if;
       if instr(oList_2.vale_rubr_72,'TAUX')=0 then oGeav.rubr_72:=grp.sum_rubr_72; else oGeav.rubr_72:=grp.sum_rubr_72/grp.cnt; end if;
       if instr(oList_2.vale_rubr_73,'TAUX')=0 then oGeav.rubr_73:=grp.sum_rubr_73; else oGeav.rubr_73:=grp.sum_rubr_73/grp.cnt; end if;
       if instr(oList_2.vale_rubr_74,'TAUX')=0 then oGeav.rubr_74:=grp.sum_rubr_74; else oGeav.rubr_74:=grp.sum_rubr_74/grp.cnt; end if;
       if instr(oList_2.vale_rubr_75,'TAUX')=0 then oGeav.rubr_75:=grp.sum_rubr_75; else oGeav.rubr_75:=grp.sum_rubr_75/grp.cnt; end if;
       if instr(oList_2.vale_rubr_76,'TAUX')=0 then oGeav.rubr_76:=grp.sum_rubr_76; else oGeav.rubr_76:=grp.sum_rubr_76/grp.cnt; end if;
       if instr(oList_2.vale_rubr_77,'TAUX')=0 then oGeav.rubr_77:=grp.sum_rubr_77; else oGeav.rubr_77:=grp.sum_rubr_77/grp.cnt; end if;
       if instr(oList_2.vale_rubr_78,'TAUX')=0 then oGeav.rubr_78:=grp.sum_rubr_78; else oGeav.rubr_78:=grp.sum_rubr_78/grp.cnt; end if;
       if instr(oList_2.vale_rubr_79,'TAUX')=0 then oGeav.rubr_79:=grp.sum_rubr_79; else oGeav.rubr_79:=grp.sum_rubr_79/grp.cnt; end if;
       if instr(oList_2.vale_rubr_80,'TAUX')=0 then oGeav.rubr_80:=grp.sum_rubr_80; else oGeav.rubr_80:=grp.sum_rubr_80/grp.cnt; end if;
       if instr(oList_2.vale_rubr_81,'TAUX')=0 then oGeav.rubr_81:=grp.sum_rubr_81; else oGeav.rubr_81:=grp.sum_rubr_81/grp.cnt; end if;
       if instr(oList_2.vale_rubr_82,'TAUX')=0 then oGeav.rubr_82:=grp.sum_rubr_82; else oGeav.rubr_82:=grp.sum_rubr_82/grp.cnt; end if;
       if instr(oList_2.vale_rubr_83,'TAUX')=0 then oGeav.rubr_83:=grp.sum_rubr_83; else oGeav.rubr_83:=grp.sum_rubr_83/grp.cnt; end if;
       if instr(oList_2.vale_rubr_84,'TAUX')=0 then oGeav.rubr_84:=grp.sum_rubr_84; else oGeav.rubr_84:=grp.sum_rubr_84/grp.cnt; end if;
       if instr(oList_2.vale_rubr_85,'TAUX')=0 then oGeav.rubr_85:=grp.sum_rubr_85; else oGeav.rubr_85:=grp.sum_rubr_85/grp.cnt; end if;
       if instr(oList_2.vale_rubr_86,'TAUX')=0 then oGeav.rubr_86:=grp.sum_rubr_86; else oGeav.rubr_86:=grp.sum_rubr_86/grp.cnt; end if;
       if instr(oList_2.vale_rubr_87,'TAUX')=0 then oGeav.rubr_87:=grp.sum_rubr_87; else oGeav.rubr_87:=grp.sum_rubr_87/grp.cnt; end if;
       if instr(oList_2.vale_rubr_88,'TAUX')=0 then oGeav.rubr_88:=grp.sum_rubr_88; else oGeav.rubr_88:=grp.sum_rubr_88/grp.cnt; end if;
       if instr(oList_2.vale_rubr_89,'TAUX')=0 then oGeav.rubr_89:=grp.sum_rubr_89; else oGeav.rubr_89:=grp.sum_rubr_89/grp.cnt; end if;
       if instr(oList_2.vale_rubr_90,'TAUX')=0 then oGeav.rubr_90:=grp.sum_rubr_90; else oGeav.rubr_90:=grp.sum_rubr_90/grp.cnt; end if;
       if instr(oList_2.vale_rubr_91,'TAUX')=0 then oGeav.rubr_91:=grp.sum_rubr_91; else oGeav.rubr_91:=grp.sum_rubr_91/grp.cnt; end if;
       if instr(oList_2.vale_rubr_92,'TAUX')=0 then oGeav.rubr_92:=grp.sum_rubr_92; else oGeav.rubr_92:=grp.sum_rubr_92/grp.cnt; end if;
       if instr(oList_2.vale_rubr_93,'TAUX')=0 then oGeav.rubr_93:=grp.sum_rubr_93; else oGeav.rubr_93:=grp.sum_rubr_93/grp.cnt; end if;
       if instr(oList_2.vale_rubr_94,'TAUX')=0 then oGeav.rubr_94:=grp.sum_rubr_94; else oGeav.rubr_94:=grp.sum_rubr_94/grp.cnt; end if;
       if instr(oList_2.vale_rubr_95,'TAUX')=0 then oGeav.rubr_95:=grp.sum_rubr_95; else oGeav.rubr_95:=grp.sum_rubr_95/grp.cnt; end if;
       if instr(oList_2.vale_rubr_96,'TAUX')=0 then oGeav.rubr_96:=grp.sum_rubr_96; else oGeav.rubr_96:=grp.sum_rubr_96/grp.cnt; end if;
       if instr(oList_2.vale_rubr_97,'TAUX')=0 then oGeav.rubr_97:=grp.sum_rubr_97; else oGeav.rubr_97:=grp.sum_rubr_97/grp.cnt; end if;
       if instr(oList_2.vale_rubr_98,'TAUX')=0 then oGeav.rubr_98:=grp.sum_rubr_98; else oGeav.rubr_98:=grp.sum_rubr_98/grp.cnt; end if;
       if instr(oList_2.vale_rubr_99,'TAUX')=0 then oGeav.rubr_99:=grp.sum_rubr_99; else oGeav.rubr_99:=grp.sum_rubr_99/grp.cnt; end if;
       if instr(oList_2.vale_rubr_100,'TAUX')=0 then oGeav.rubr_100:=grp.sum_rubr_100; else oGeav.rubr_100:=grp.sum_rubr_100/grp.cnt; end if;
       if instr(oList_2.vale_rubr_101,'TAUX')=0 then oGeav.rubr_101:=grp.sum_rubr_101; else oGeav.rubr_101:=grp.sum_rubr_101/grp.cnt; end if;
       if instr(oList_2.vale_rubr_102,'TAUX')=0 then oGeav.rubr_102:=grp.sum_rubr_102; else oGeav.rubr_102:=grp.sum_rubr_102/grp.cnt; end if;
       if instr(oList_2.vale_rubr_103,'TAUX')=0 then oGeav.rubr_103:=grp.sum_rubr_103; else oGeav.rubr_103:=grp.sum_rubr_103/grp.cnt; end if;
       if instr(oList_2.vale_rubr_104,'TAUX')=0 then oGeav.rubr_104:=grp.sum_rubr_104; else oGeav.rubr_104:=grp.sum_rubr_104/grp.cnt; end if;
       if instr(oList_2.vale_rubr_105,'TAUX')=0 then oGeav.rubr_105:=grp.sum_rubr_105; else oGeav.rubr_105:=grp.sum_rubr_105/grp.cnt; end if;
       if instr(oList_2.vale_rubr_106,'TAUX')=0 then oGeav.rubr_106:=grp.sum_rubr_106; else oGeav.rubr_106:=grp.sum_rubr_106/grp.cnt; end if;
       if instr(oList_2.vale_rubr_107,'TAUX')=0 then oGeav.rubr_107:=grp.sum_rubr_107; else oGeav.rubr_107:=grp.sum_rubr_107/grp.cnt; end if;
       if instr(oList_2.vale_rubr_108,'TAUX')=0 then oGeav.rubr_108:=grp.sum_rubr_108; else oGeav.rubr_108:=grp.sum_rubr_108/grp.cnt; end if;
       if instr(oList_2.vale_rubr_109,'TAUX')=0 then oGeav.rubr_109:=grp.sum_rubr_109; else oGeav.rubr_109:=grp.sum_rubr_109/grp.cnt; end if;
       if instr(oList_2.vale_rubr_110,'TAUX')=0 then oGeav.rubr_110:=grp.sum_rubr_110; else oGeav.rubr_110:=grp.sum_rubr_110/grp.cnt; end if;
       if instr(oList_2.vale_rubr_111,'TAUX')=0 then oGeav.rubr_111:=grp.sum_rubr_111; else oGeav.rubr_111:=grp.sum_rubr_111/grp.cnt; end if;
       if instr(oList_2.vale_rubr_112,'TAUX')=0 then oGeav.rubr_112:=grp.sum_rubr_112; else oGeav.rubr_112:=grp.sum_rubr_112/grp.cnt; end if;
       if instr(oList_2.vale_rubr_113,'TAUX')=0 then oGeav.rubr_113:=grp.sum_rubr_113; else oGeav.rubr_113:=grp.sum_rubr_113/grp.cnt; end if;
       if instr(oList_2.vale_rubr_114,'TAUX')=0 then oGeav.rubr_114:=grp.sum_rubr_114; else oGeav.rubr_114:=grp.sum_rubr_114/grp.cnt; end if;
       if instr(oList_2.vale_rubr_115,'TAUX')=0 then oGeav.rubr_115:=grp.sum_rubr_115; else oGeav.rubr_115:=grp.sum_rubr_115/grp.cnt; end if;
       if instr(oList_2.vale_rubr_116,'TAUX')=0 then oGeav.rubr_116:=grp.sum_rubr_116; else oGeav.rubr_116:=grp.sum_rubr_116/grp.cnt; end if;
       if instr(oList_2.vale_rubr_117,'TAUX')=0 then oGeav.rubr_117:=grp.sum_rubr_117; else oGeav.rubr_117:=grp.sum_rubr_117/grp.cnt; end if;
       if instr(oList_2.vale_rubr_118,'TAUX')=0 then oGeav.rubr_118:=grp.sum_rubr_118; else oGeav.rubr_118:=grp.sum_rubr_118/grp.cnt; end if;
       if instr(oList_2.vale_rubr_119,'TAUX')=0 then oGeav.rubr_119:=grp.sum_rubr_119; else oGeav.rubr_119:=grp.sum_rubr_119/grp.cnt; end if;
       if instr(oList_2.vale_rubr_120,'TAUX')=0 then oGeav.rubr_120:=grp.sum_rubr_120; else oGeav.rubr_120:=grp.sum_rubr_120/grp.cnt; end if;
       if instr(oList_2.vale_rubr_121,'TAUX')=0 then oGeav.rubr_121:=grp.sum_rubr_121; else oGeav.rubr_121:=grp.sum_rubr_121/grp.cnt; end if;
       if instr(oList_2.vale_rubr_122,'TAUX')=0 then oGeav.rubr_122:=grp.sum_rubr_122; else oGeav.rubr_122:=grp.sum_rubr_122/grp.cnt; end if;
       if instr(oList_2.vale_rubr_123,'TAUX')=0 then oGeav.rubr_123:=grp.sum_rubr_123; else oGeav.rubr_123:=grp.sum_rubr_123/grp.cnt; end if;
       if instr(oList_2.vale_rubr_124,'TAUX')=0 then oGeav.rubr_124:=grp.sum_rubr_124; else oGeav.rubr_124:=grp.sum_rubr_124/grp.cnt; end if;
       if instr(oList_2.vale_rubr_125,'TAUX')=0 then oGeav.rubr_125:=grp.sum_rubr_125; else oGeav.rubr_125:=grp.sum_rubr_125/grp.cnt; end if;
       if instr(oList_2.vale_rubr_126,'TAUX')=0 then oGeav.rubr_126:=grp.sum_rubr_126; else oGeav.rubr_126:=grp.sum_rubr_126/grp.cnt; end if;
       if instr(oList_2.vale_rubr_127,'TAUX')=0 then oGeav.rubr_127:=grp.sum_rubr_127; else oGeav.rubr_127:=grp.sum_rubr_127/grp.cnt; end if;
       if instr(oList_2.vale_rubr_128,'TAUX')=0 then oGeav.rubr_128:=grp.sum_rubr_128; else oGeav.rubr_128:=grp.sum_rubr_128/grp.cnt; end if;
       if instr(oList_2.vale_rubr_129,'TAUX')=0 then oGeav.rubr_129:=grp.sum_rubr_129; else oGeav.rubr_129:=grp.sum_rubr_129/grp.cnt; end if;
       if instr(oList_2.vale_rubr_130,'TAUX')=0 then oGeav.rubr_130:=grp.sum_rubr_130; else oGeav.rubr_130:=grp.sum_rubr_130/grp.cnt; end if;
       if instr(oList_2.vale_rubr_131,'TAUX')=0 then oGeav.rubr_131:=grp.sum_rubr_131; else oGeav.rubr_131:=grp.sum_rubr_131/grp.cnt; end if;
       if instr(oList_2.vale_rubr_132,'TAUX')=0 then oGeav.rubr_132:=grp.sum_rubr_132; else oGeav.rubr_132:=grp.sum_rubr_132/grp.cnt; end if;
       if instr(oList_2.vale_rubr_133,'TAUX')=0 then oGeav.rubr_133:=grp.sum_rubr_133; else oGeav.rubr_133:=grp.sum_rubr_133/grp.cnt; end if;
       if instr(oList_2.vale_rubr_134,'TAUX')=0 then oGeav.rubr_134:=grp.sum_rubr_134; else oGeav.rubr_134:=grp.sum_rubr_134/grp.cnt; end if;
       if instr(oList_2.vale_rubr_135,'TAUX')=0 then oGeav.rubr_135:=grp.sum_rubr_135; else oGeav.rubr_135:=grp.sum_rubr_135/grp.cnt; end if;
       if instr(oList_2.vale_rubr_136,'TAUX')=0 then oGeav.rubr_136:=grp.sum_rubr_136; else oGeav.rubr_136:=grp.sum_rubr_136/grp.cnt; end if;
       if instr(oList_2.vale_rubr_137,'TAUX')=0 then oGeav.rubr_137:=grp.sum_rubr_137; else oGeav.rubr_137:=grp.sum_rubr_137/grp.cnt; end if;
       if instr(oList_2.vale_rubr_138,'TAUX')=0 then oGeav.rubr_138:=grp.sum_rubr_138; else oGeav.rubr_138:=grp.sum_rubr_138/grp.cnt; end if;
       if instr(oList_2.vale_rubr_139,'TAUX')=0 then oGeav.rubr_139:=grp.sum_rubr_139; else oGeav.rubr_139:=grp.sum_rubr_139/grp.cnt; end if;
       if instr(oList_2.vale_rubr_140,'TAUX')=0 then oGeav.rubr_140:=grp.sum_rubr_140; else oGeav.rubr_140:=grp.sum_rubr_140/grp.cnt; end if;
       if instr(oList_2.vale_rubr_141,'TAUX')=0 then oGeav.rubr_141:=grp.sum_rubr_141; else oGeav.rubr_141:=grp.sum_rubr_141/grp.cnt; end if;
       if instr(oList_2.vale_rubr_142,'TAUX')=0 then oGeav.rubr_142:=grp.sum_rubr_142; else oGeav.rubr_142:=grp.sum_rubr_142/grp.cnt; end if;
       if instr(oList_2.vale_rubr_143,'TAUX')=0 then oGeav.rubr_143:=grp.sum_rubr_143; else oGeav.rubr_143:=grp.sum_rubr_143/grp.cnt; end if;
       if instr(oList_2.vale_rubr_144,'TAUX')=0 then oGeav.rubr_144:=grp.sum_rubr_144; else oGeav.rubr_144:=grp.sum_rubr_144/grp.cnt; end if;
       if instr(oList_2.vale_rubr_145,'TAUX')=0 then oGeav.rubr_145:=grp.sum_rubr_145; else oGeav.rubr_145:=grp.sum_rubr_145/grp.cnt; end if;
       if instr(oList_2.vale_rubr_146,'TAUX')=0 then oGeav.rubr_146:=grp.sum_rubr_146; else oGeav.rubr_146:=grp.sum_rubr_146/grp.cnt; end if;
       if instr(oList_2.vale_rubr_147,'TAUX')=0 then oGeav.rubr_147:=grp.sum_rubr_147; else oGeav.rubr_147:=grp.sum_rubr_147/grp.cnt; end if;
       if instr(oList_2.vale_rubr_148,'TAUX')=0 then oGeav.rubr_148:=grp.sum_rubr_148; else oGeav.rubr_148:=grp.sum_rubr_148/grp.cnt; end if;
       if instr(oList_2.vale_rubr_149,'TAUX')=0 then oGeav.rubr_149:=grp.sum_rubr_149; else oGeav.rubr_149:=grp.sum_rubr_149/grp.cnt; end if;
       if instr(oList_2.vale_rubr_150,'TAUX')=0 then oGeav.rubr_150:=grp.sum_rubr_150; else oGeav.rubr_150:=grp.sum_rubr_150/grp.cnt; end if;

       if grp.cnt_mutu_soum_txde_01        < 2 then oGeav.mutu_soum_txde_01         :=grp.mutu_soum_txde_01         ; else oGeav.mutu_soum_txde_01         :='Plusieurs ('||grp.cnt_mutu_soum_txde_01    ||')';end if;
       if grp.cnt_mutu_soum_txde_02        < 2 then oGeav.mutu_soum_txde_02         :=grp.mutu_soum_txde_02         ; else oGeav.mutu_soum_txde_02         :='Plusieurs ('||grp.cnt_mutu_soum_txde_02    ||')';end if;
       if grp.cnt_mutu_soum_txde_03        < 2 then oGeav.mutu_soum_txde_03         :=grp.mutu_soum_txde_03         ; else oGeav.mutu_soum_txde_03         :='Plusieurs ('||grp.cnt_mutu_soum_txde_03    ||')';end if;
       if grp.cnt_mutu_soum_txde_04        < 2 then oGeav.mutu_soum_txde_04         :=grp.mutu_soum_txde_04         ; else oGeav.mutu_soum_txde_04         :='Plusieurs ('||grp.cnt_mutu_soum_txde_04    ||')';end if;
       if grp.cnt_mutu_soum_txde_05        < 2 then oGeav.mutu_soum_txde_05         :=grp.mutu_soum_txde_05         ; else oGeav.mutu_soum_txde_05         :='Plusieurs ('||grp.cnt_mutu_soum_txde_05    ||')';end if;
       if grp.cnt_mutu_soum_mtde_01        < 2 then oGeav.mutu_soum_mtde_01         :=grp.mutu_soum_mtde_01         ; else oGeav.mutu_soum_mtde_01         :='Plusieurs ('||grp.cnt_mutu_soum_mtde_01    ||')';end if;
       if grp.cnt_mutu_soum_mtde_02        < 2 then oGeav.mutu_soum_mtde_02         :=grp.mutu_soum_mtde_02         ; else oGeav.mutu_soum_mtde_02         :='Plusieurs ('||grp.cnt_mutu_soum_mtde_02    ||')';end if;
       if grp.cnt_mutu_soum_mtde_03        < 2 then oGeav.mutu_soum_mtde_03         :=grp.mutu_soum_mtde_03         ; else oGeav.mutu_soum_mtde_03         :='Plusieurs ('||grp.cnt_mutu_soum_mtde_03    ||')';end if;
       if grp.cnt_mutu_soum_mtde_04        < 2 then oGeav.mutu_soum_mtde_04         :=grp.mutu_soum_mtde_04         ; else oGeav.mutu_soum_mtde_04         :='Plusieurs ('||grp.cnt_mutu_soum_mtde_04    ||')';end if;
       if grp.cnt_mutu_soum_mtde_05        < 2 then oGeav.mutu_soum_mtde_05         :=grp.mutu_soum_mtde_05         ; else oGeav.mutu_soum_mtde_05         :='Plusieurs ('||grp.cnt_mutu_soum_mtde_05    ||')';end if;
       if grp.cnt_mutu_soum_mtde_06        < 2 then oGeav.mutu_soum_mtde_06         :=grp.mutu_soum_mtde_06         ; else oGeav.mutu_soum_mtde_06         :='Plusieurs ('||grp.cnt_mutu_soum_mtde_06    ||')';end if;
       if grp.cnt_mutu_soum_mtde_07        < 2 then oGeav.mutu_soum_mtde_07         :=grp.mutu_soum_mtde_07         ; else oGeav.mutu_soum_mtde_07         :='Plusieurs ('||grp.cnt_mutu_soum_mtde_07    ||')';end if;
       if grp.cnt_mutu_soum_mtde_08        < 2 then oGeav.mutu_soum_mtde_08         :=grp.mutu_soum_mtde_08         ; else oGeav.mutu_soum_mtde_08         :='Plusieurs ('||grp.cnt_mutu_soum_mtde_08    ||')';end if;
       if grp.cnt_mutu_soum_mtde_09        < 2 then oGeav.mutu_soum_mtde_09         :=grp.mutu_soum_mtde_09         ; else oGeav.mutu_soum_mtde_09         :='Plusieurs ('||grp.cnt_mutu_soum_mtde_09    ||')';end if;
       if grp.cnt_mutu_soum_mtde_10        < 2 then oGeav.mutu_soum_mtde_10         :=grp.mutu_soum_mtde_10         ; else oGeav.mutu_soum_mtde_10         :='Plusieurs ('||grp.cnt_mutu_soum_mtde_10    ||')';end if;
       if grp.cnt_mutu_noso_txde_01        < 2 then oGeav.mutu_noso_txde_01         :=grp.mutu_noso_txde_01         ; else oGeav.mutu_noso_txde_01         :='Plusieurs ('||grp.cnt_mutu_noso_txde_01    ||')';end if;
       if grp.cnt_mutu_noso_txde_02        < 2 then oGeav.mutu_noso_txde_02         :=grp.mutu_noso_txde_02         ; else oGeav.mutu_noso_txde_02         :='Plusieurs ('||grp.cnt_mutu_noso_txde_02    ||')';end if;
       if grp.cnt_mutu_noso_txde_03        < 2 then oGeav.mutu_noso_txde_03         :=grp.mutu_noso_txde_03         ; else oGeav.mutu_noso_txde_03         :='Plusieurs ('||grp.cnt_mutu_noso_txde_03    ||')';end if;
       if grp.cnt_mutu_noso_mtde_01        < 2 then oGeav.mutu_noso_mtde_01         :=grp.mutu_noso_mtde_01         ; else oGeav.mutu_noso_mtde_01         :='Plusieurs ('||grp.cnt_mutu_noso_mtde_01    ||')';end if;
       if grp.cnt_mutu_noso_mtde_02        < 2 then oGeav.mutu_noso_mtde_02         :=grp.mutu_noso_mtde_02         ; else oGeav.mutu_noso_mtde_02         :='Plusieurs ('||grp.cnt_mutu_noso_mtde_02    ||')';end if;
       if grp.cnt_mutu_noso_mtde_03        < 2 then oGeav.mutu_noso_mtde_03         :=grp.mutu_noso_mtde_03         ; else oGeav.mutu_noso_mtde_03         :='Plusieurs ('||grp.cnt_mutu_noso_mtde_03    ||')';end if;
       if grp.cnt_mutu_noso_mtde_04        < 2 then oGeav.mutu_noso_mtde_04         :=grp.mutu_noso_mtde_04         ; else oGeav.mutu_noso_mtde_04         :='Plusieurs ('||grp.cnt_mutu_noso_mtde_04    ||')';end if;
       if grp.cnt_mutu_noso_mtde_05        < 2 then oGeav.mutu_noso_mtde_05         :=grp.mutu_noso_mtde_05         ; else oGeav.mutu_noso_mtde_05         :='Plusieurs ('||grp.cnt_mutu_noso_mtde_05    ||')';end if;
       if grp.cnt_mutu_noso_mtde_06        < 2 then oGeav.mutu_noso_mtde_06         :=grp.mutu_noso_mtde_06         ; else oGeav.mutu_noso_mtde_06         :='Plusieurs ('||grp.cnt_mutu_noso_mtde_06    ||')';end if;
       if grp.cnt_mutu_noso_mtde_07        < 2 then oGeav.mutu_noso_mtde_07         :=grp.mutu_noso_mtde_07         ; else oGeav.mutu_noso_mtde_07         :='Plusieurs ('||grp.cnt_mutu_noso_mtde_07    ||')';end if;
       if grp.cnt_code_anal_01             < 2 then oGeav.code_anal_01              :=grp.code_anal_01              ; else oGeav.code_anal_01              :='Plusieurs ('||grp.cnt_code_anal_01         ||')';end if;
       if grp.cnt_code_anal_02             < 2 then oGeav.code_anal_02              :=grp.code_anal_02              ; else oGeav.code_anal_02              :='Plusieurs ('||grp.cnt_code_anal_02         ||')';end if;
       if grp.cnt_code_anal_03             < 2 then oGeav.code_anal_03              :=grp.code_anal_03              ; else oGeav.code_anal_03              :='Plusieurs ('||grp.cnt_code_anal_03         ||')';end if;
       if grp.cnt_code_anal_04             < 2 then oGeav.code_anal_04              :=grp.code_anal_04              ; else oGeav.code_anal_04              :='Plusieurs ('||grp.cnt_code_anal_04         ||')';end if;
       if grp.cnt_code_anal_05             < 2 then oGeav.code_anal_05              :=grp.code_anal_05              ; else oGeav.code_anal_05              :='Plusieurs ('||grp.cnt_code_anal_05         ||')';end if;
       if grp.cnt_code_anal_06             < 2 then oGeav.code_anal_06              :=grp.code_anal_06              ; else oGeav.code_anal_06              :='Plusieurs ('||grp.cnt_code_anal_06         ||')';end if;
       if grp.cnt_code_anal_07             < 2 then oGeav.code_anal_07              :=grp.code_anal_07              ; else oGeav.code_anal_07              :='Plusieurs ('||grp.cnt_code_anal_07         ||')';end if;
       if grp.cnt_code_anal_08             < 2 then oGeav.code_anal_08              :=grp.code_anal_08              ; else oGeav.code_anal_08              :='Plusieurs ('||grp.cnt_code_anal_08         ||')';end if;
       if grp.cnt_code_anal_09             < 2 then oGeav.code_anal_09              :=grp.code_anal_09              ; else oGeav.code_anal_09              :='Plusieurs ('||grp.cnt_code_anal_09         ||')';end if;
       if grp.cnt_code_anal_10             < 2 then oGeav.code_anal_10              :=grp.code_anal_10              ; else oGeav.code_anal_10              :='Plusieurs ('||grp.cnt_code_anal_10         ||')';end if;
       if grp.cnt_code_anal_11             < 2 then oGeav.code_anal_11              :=grp.code_anal_11              ; else oGeav.code_anal_11              :='Plusieurs ('||grp.cnt_code_anal_11         ||')';end if;
       if grp.cnt_code_anal_12             < 2 then oGeav.code_anal_12              :=grp.code_anal_12              ; else oGeav.code_anal_12              :='Plusieurs ('||grp.cnt_code_anal_12         ||')';end if;
       if grp.cnt_code_anal_13             < 2 then oGeav.code_anal_13              :=grp.code_anal_13              ; else oGeav.code_anal_13              :='Plusieurs ('||grp.cnt_code_anal_13         ||')';end if;
       if grp.cnt_code_anal_14             < 2 then oGeav.code_anal_14              :=grp.code_anal_14              ; else oGeav.code_anal_14              :='Plusieurs ('||grp.cnt_code_anal_14         ||')';end if;
       if grp.cnt_code_anal_15             < 2 then oGeav.code_anal_15              :=grp.code_anal_15              ; else oGeav.code_anal_15              :='Plusieurs ('||grp.cnt_code_anal_15         ||')';end if;
       if grp.cnt_code_anal_16             < 2 then oGeav.code_anal_16              :=grp.code_anal_16              ; else oGeav.code_anal_16              :='Plusieurs ('||grp.cnt_code_anal_16         ||')';end if;
       if grp.cnt_code_anal_17             < 2 then oGeav.code_anal_17              :=grp.code_anal_17              ; else oGeav.code_anal_17              :='Plusieurs ('||grp.cnt_code_anal_17         ||')';end if;
       if grp.cnt_code_anal_18             < 2 then oGeav.code_anal_18              :=grp.code_anal_18              ; else oGeav.code_anal_18              :='Plusieurs ('||grp.cnt_code_anal_18         ||')';end if;
       if grp.cnt_code_anal_19             < 2 then oGeav.code_anal_19              :=grp.code_anal_19              ; else oGeav.code_anal_19              :='Plusieurs ('||grp.cnt_code_anal_19         ||')';end if;
       if grp.cnt_code_anal_20             < 2 then oGeav.code_anal_20              :=grp.code_anal_20              ; else oGeav.code_anal_20              :='Plusieurs ('||grp.cnt_code_anal_20         ||')';end if;

       if grp.cnt_plan1_code_anal_01       < 2 then oGeav.plan1_code_anal_01         :=grp.plan1_code_anal_01       ; else oGeav.plan1_code_anal_01        :='Plusieurs ('||grp.cnt_plan1_code_anal_01      ||')';end if;
       if grp.cnt_plan1_code_anal_02       < 2 then oGeav.plan1_code_anal_02         :=grp.plan1_code_anal_02       ; else oGeav.plan1_code_anal_02        :='Plusieurs ('||grp.cnt_plan1_code_anal_02      ||')';end if;
       if grp.cnt_plan1_code_anal_03       < 2 then oGeav.plan1_code_anal_03         :=grp.plan1_code_anal_03       ; else oGeav.plan1_code_anal_03        :='Plusieurs ('||grp.cnt_plan1_code_anal_03      ||')';end if;
       if grp.cnt_plan1_code_anal_04       < 2 then oGeav.plan1_code_anal_04         :=grp.plan1_code_anal_04       ; else oGeav.plan1_code_anal_04        :='Plusieurs ('||grp.cnt_plan1_code_anal_04      ||')';end if;
       if grp.cnt_plan1_code_anal_05       < 2 then oGeav.plan1_code_anal_05         :=grp.plan1_code_anal_05       ; else oGeav.plan1_code_anal_05        :='Plusieurs ('||grp.cnt_plan1_code_anal_05      ||')';end if;
       if grp.cnt_plan1_code_anal_06       < 2 then oGeav.plan1_code_anal_06         :=grp.plan1_code_anal_06       ; else oGeav.plan1_code_anal_06        :='Plusieurs ('||grp.cnt_plan1_code_anal_06      ||')';end if;
       if grp.cnt_plan1_code_anal_07       < 2 then oGeav.plan1_code_anal_07         :=grp.plan1_code_anal_07       ; else oGeav.plan1_code_anal_07        :='Plusieurs ('||grp.cnt_plan1_code_anal_07      ||')';end if;
       if grp.cnt_plan1_code_anal_08       < 2 then oGeav.plan1_code_anal_08         :=grp.plan1_code_anal_08       ; else oGeav.plan1_code_anal_08        :='Plusieurs ('||grp.cnt_plan1_code_anal_08      ||')';end if;
       if grp.cnt_plan1_code_anal_09       < 2 then oGeav.plan1_code_anal_09         :=grp.plan1_code_anal_09       ; else oGeav.plan1_code_anal_09        :='Plusieurs ('||grp.cnt_plan1_code_anal_09      ||')';end if;
       if grp.cnt_plan1_code_anal_10       < 2 then oGeav.plan1_code_anal_10         :=grp.plan1_code_anal_10       ; else oGeav.plan1_code_anal_10        :='Plusieurs ('||grp.cnt_plan1_code_anal_10      ||')';end if;
       if grp.cnt_plan1_code_anal_11       < 2 then oGeav.plan1_code_anal_11         :=grp.plan1_code_anal_11       ; else oGeav.plan1_code_anal_11        :='Plusieurs ('||grp.cnt_plan1_code_anal_11      ||')';end if;
       if grp.cnt_plan1_code_anal_12       < 2 then oGeav.plan1_code_anal_12         :=grp.plan1_code_anal_12       ; else oGeav.plan1_code_anal_12        :='Plusieurs ('||grp.cnt_plan1_code_anal_12      ||')';end if;
       if grp.cnt_plan1_code_anal_13       < 2 then oGeav.plan1_code_anal_13         :=grp.plan1_code_anal_13       ; else oGeav.plan1_code_anal_13        :='Plusieurs ('||grp.cnt_plan1_code_anal_13      ||')';end if;
       if grp.cnt_plan1_code_anal_14       < 2 then oGeav.plan1_code_anal_14         :=grp.plan1_code_anal_14       ; else oGeav.plan1_code_anal_14        :='Plusieurs ('||grp.cnt_plan1_code_anal_14      ||')';end if;
       if grp.cnt_plan1_code_anal_15       < 2 then oGeav.plan1_code_anal_15         :=grp.plan1_code_anal_15       ; else oGeav.plan1_code_anal_15        :='Plusieurs ('||grp.cnt_plan1_code_anal_15      ||')';end if;
       if grp.cnt_plan1_code_anal_16       < 2 then oGeav.plan1_code_anal_16         :=grp.plan1_code_anal_16       ; else oGeav.plan1_code_anal_16        :='Plusieurs ('||grp.cnt_plan1_code_anal_16      ||')';end if;
       if grp.cnt_plan1_code_anal_17       < 2 then oGeav.plan1_code_anal_17         :=grp.plan1_code_anal_17       ; else oGeav.plan1_code_anal_17        :='Plusieurs ('||grp.cnt_plan1_code_anal_17      ||')';end if;
       if grp.cnt_plan1_code_anal_18       < 2 then oGeav.plan1_code_anal_18         :=grp.plan1_code_anal_18       ; else oGeav.plan1_code_anal_18        :='Plusieurs ('||grp.cnt_plan1_code_anal_18      ||')';end if;
       if grp.cnt_plan1_code_anal_19       < 2 then oGeav.plan1_code_anal_19         :=grp.plan1_code_anal_19       ; else oGeav.plan1_code_anal_19        :='Plusieurs ('||grp.cnt_plan1_code_anal_19      ||')';end if;
       if grp.cnt_plan1_code_anal_20       < 2 then oGeav.plan1_code_anal_20         :=grp.plan1_code_anal_20       ; else oGeav.plan1_code_anal_20        :='Plusieurs ('||grp.cnt_plan1_code_anal_20      ||')';end if;
       if grp.cnt_plan1_pour_affe_anal_01  < 2 then oGeav.plan1_pour_affe_anal_01    :=grp.plan1_pour_affe_anal_01  ; else oGeav.plan1_pour_affe_anal_01   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_02  < 2 then oGeav.plan1_pour_affe_anal_02    :=grp.plan1_pour_affe_anal_02  ; else oGeav.plan1_pour_affe_anal_02   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_03  < 2 then oGeav.plan1_pour_affe_anal_03    :=grp.plan1_pour_affe_anal_03  ; else oGeav.plan1_pour_affe_anal_03   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_04  < 2 then oGeav.plan1_pour_affe_anal_04    :=grp.plan1_pour_affe_anal_04  ; else oGeav.plan1_pour_affe_anal_04   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_05  < 2 then oGeav.plan1_pour_affe_anal_05    :=grp.plan1_pour_affe_anal_05  ; else oGeav.plan1_pour_affe_anal_05   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_06  < 2 then oGeav.plan1_pour_affe_anal_06    :=grp.plan1_pour_affe_anal_06  ; else oGeav.plan1_pour_affe_anal_06   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_07  < 2 then oGeav.plan1_pour_affe_anal_07    :=grp.plan1_pour_affe_anal_07  ; else oGeav.plan1_pour_affe_anal_07   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_08  < 2 then oGeav.plan1_pour_affe_anal_08    :=grp.plan1_pour_affe_anal_08  ; else oGeav.plan1_pour_affe_anal_08   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_09  < 2 then oGeav.plan1_pour_affe_anal_09    :=grp.plan1_pour_affe_anal_09  ; else oGeav.plan1_pour_affe_anal_09   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_10  < 2 then oGeav.plan1_pour_affe_anal_10    :=grp.plan1_pour_affe_anal_10  ; else oGeav.plan1_pour_affe_anal_10   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_11  < 2 then oGeav.plan1_pour_affe_anal_11    :=grp.plan1_pour_affe_anal_11  ; else oGeav.plan1_pour_affe_anal_11   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_12  < 2 then oGeav.plan1_pour_affe_anal_12    :=grp.plan1_pour_affe_anal_12  ; else oGeav.plan1_pour_affe_anal_12   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_13  < 2 then oGeav.plan1_pour_affe_anal_13    :=grp.plan1_pour_affe_anal_13  ; else oGeav.plan1_pour_affe_anal_13   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_14  < 2 then oGeav.plan1_pour_affe_anal_14    :=grp.plan1_pour_affe_anal_14  ; else oGeav.plan1_pour_affe_anal_14   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_15  < 2 then oGeav.plan1_pour_affe_anal_15    :=grp.plan1_pour_affe_anal_15  ; else oGeav.plan1_pour_affe_anal_15   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_16  < 2 then oGeav.plan1_pour_affe_anal_16    :=grp.plan1_pour_affe_anal_16  ; else oGeav.plan1_pour_affe_anal_16   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_17  < 2 then oGeav.plan1_pour_affe_anal_17    :=grp.plan1_pour_affe_anal_17  ; else oGeav.plan1_pour_affe_anal_17   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_18  < 2 then oGeav.plan1_pour_affe_anal_18    :=grp.plan1_pour_affe_anal_18  ; else oGeav.plan1_pour_affe_anal_18   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_19  < 2 then oGeav.plan1_pour_affe_anal_19    :=grp.plan1_pour_affe_anal_19  ; else oGeav.plan1_pour_affe_anal_19   :='';end if;
       if grp.cnt_plan1_pour_affe_anal_20  < 2 then oGeav.plan1_pour_affe_anal_20    :=grp.plan1_pour_affe_anal_20  ; else oGeav.plan1_pour_affe_anal_20   :='';end if;
       if grp.cnt_plan2_code_anal_01       < 2 then oGeav.plan2_code_anal_01         :=grp.plan2_code_anal_01       ; else oGeav.plan2_code_anal_01        :='Plusieurs ('||grp.cnt_plan2_code_anal_01      ||')';end if;
       if grp.cnt_plan2_code_anal_02       < 2 then oGeav.plan2_code_anal_02         :=grp.plan2_code_anal_02       ; else oGeav.plan2_code_anal_02        :='Plusieurs ('||grp.cnt_plan2_code_anal_02      ||')';end if;
       if grp.cnt_plan2_code_anal_03       < 2 then oGeav.plan2_code_anal_03         :=grp.plan2_code_anal_03       ; else oGeav.plan2_code_anal_03        :='Plusieurs ('||grp.cnt_plan2_code_anal_03      ||')';end if;
       if grp.cnt_plan2_code_anal_04       < 2 then oGeav.plan2_code_anal_04         :=grp.plan2_code_anal_04       ; else oGeav.plan2_code_anal_04        :='Plusieurs ('||grp.cnt_plan2_code_anal_04      ||')';end if;
       if grp.cnt_plan2_code_anal_05       < 2 then oGeav.plan2_code_anal_05         :=grp.plan2_code_anal_05       ; else oGeav.plan2_code_anal_05        :='Plusieurs ('||grp.cnt_plan2_code_anal_05      ||')';end if;
       if grp.cnt_plan2_code_anal_06       < 2 then oGeav.plan2_code_anal_06         :=grp.plan2_code_anal_06       ; else oGeav.plan2_code_anal_06        :='Plusieurs ('||grp.cnt_plan2_code_anal_06      ||')';end if;
       if grp.cnt_plan2_code_anal_07       < 2 then oGeav.plan2_code_anal_07         :=grp.plan2_code_anal_07       ; else oGeav.plan2_code_anal_07        :='Plusieurs ('||grp.cnt_plan2_code_anal_07      ||')';end if;
       if grp.cnt_plan2_code_anal_08       < 2 then oGeav.plan2_code_anal_08         :=grp.plan2_code_anal_08       ; else oGeav.plan2_code_anal_08        :='Plusieurs ('||grp.cnt_plan2_code_anal_08      ||')';end if;
       if grp.cnt_plan2_code_anal_09       < 2 then oGeav.plan2_code_anal_09         :=grp.plan2_code_anal_09       ; else oGeav.plan2_code_anal_09        :='Plusieurs ('||grp.cnt_plan2_code_anal_09      ||')';end if;
       if grp.cnt_plan2_code_anal_10       < 2 then oGeav.plan2_code_anal_10         :=grp.plan2_code_anal_10       ; else oGeav.plan2_code_anal_10        :='Plusieurs ('||grp.cnt_plan2_code_anal_10      ||')';end if;
       if grp.cnt_plan2_code_anal_11       < 2 then oGeav.plan2_code_anal_11         :=grp.plan2_code_anal_11       ; else oGeav.plan2_code_anal_11        :='Plusieurs ('||grp.cnt_plan2_code_anal_11      ||')';end if;
       if grp.cnt_plan2_code_anal_12       < 2 then oGeav.plan2_code_anal_12         :=grp.plan2_code_anal_12       ; else oGeav.plan2_code_anal_12        :='Plusieurs ('||grp.cnt_plan2_code_anal_12      ||')';end if;
       if grp.cnt_plan2_code_anal_13       < 2 then oGeav.plan2_code_anal_13         :=grp.plan2_code_anal_13       ; else oGeav.plan2_code_anal_13        :='Plusieurs ('||grp.cnt_plan2_code_anal_13      ||')';end if;
       if grp.cnt_plan2_code_anal_14       < 2 then oGeav.plan2_code_anal_14         :=grp.plan2_code_anal_14       ; else oGeav.plan2_code_anal_14        :='Plusieurs ('||grp.cnt_plan2_code_anal_14      ||')';end if;
       if grp.cnt_plan2_code_anal_15       < 2 then oGeav.plan2_code_anal_15         :=grp.plan2_code_anal_15       ; else oGeav.plan2_code_anal_15        :='Plusieurs ('||grp.cnt_plan2_code_anal_15      ||')';end if;
       if grp.cnt_plan2_code_anal_16       < 2 then oGeav.plan2_code_anal_16         :=grp.plan2_code_anal_16       ; else oGeav.plan2_code_anal_16        :='Plusieurs ('||grp.cnt_plan2_code_anal_16      ||')';end if;
       if grp.cnt_plan2_code_anal_17       < 2 then oGeav.plan2_code_anal_17         :=grp.plan2_code_anal_17       ; else oGeav.plan2_code_anal_17        :='Plusieurs ('||grp.cnt_plan2_code_anal_17      ||')';end if;
       if grp.cnt_plan2_code_anal_18       < 2 then oGeav.plan2_code_anal_18         :=grp.plan2_code_anal_18       ; else oGeav.plan2_code_anal_18        :='Plusieurs ('||grp.cnt_plan2_code_anal_18      ||')';end if;
       if grp.cnt_plan2_code_anal_19       < 2 then oGeav.plan2_code_anal_19         :=grp.plan2_code_anal_19       ; else oGeav.plan2_code_anal_19        :='Plusieurs ('||grp.cnt_plan2_code_anal_19      ||')';end if;
       if grp.cnt_plan2_code_anal_20       < 2 then oGeav.plan2_code_anal_20         :=grp.plan2_code_anal_20       ; else oGeav.plan2_code_anal_20        :='Plusieurs ('||grp.cnt_plan2_code_anal_20      ||')';end if;
       if grp.cnt_plan2_pour_affe_anal_01  < 2 then oGeav.plan2_pour_affe_anal_01    :=grp.plan2_pour_affe_anal_01  ; else oGeav.plan2_pour_affe_anal_01   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_02  < 2 then oGeav.plan2_pour_affe_anal_02    :=grp.plan2_pour_affe_anal_02  ; else oGeav.plan2_pour_affe_anal_02   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_03  < 2 then oGeav.plan2_pour_affe_anal_03    :=grp.plan2_pour_affe_anal_03  ; else oGeav.plan2_pour_affe_anal_03   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_04  < 2 then oGeav.plan2_pour_affe_anal_04    :=grp.plan2_pour_affe_anal_04  ; else oGeav.plan2_pour_affe_anal_04   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_05  < 2 then oGeav.plan2_pour_affe_anal_05    :=grp.plan2_pour_affe_anal_05  ; else oGeav.plan2_pour_affe_anal_05   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_06  < 2 then oGeav.plan2_pour_affe_anal_06    :=grp.plan2_pour_affe_anal_06  ; else oGeav.plan2_pour_affe_anal_06   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_07  < 2 then oGeav.plan2_pour_affe_anal_07    :=grp.plan2_pour_affe_anal_07  ; else oGeav.plan2_pour_affe_anal_07   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_08  < 2 then oGeav.plan2_pour_affe_anal_08    :=grp.plan2_pour_affe_anal_08  ; else oGeav.plan2_pour_affe_anal_08   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_09  < 2 then oGeav.plan2_pour_affe_anal_09    :=grp.plan2_pour_affe_anal_09  ; else oGeav.plan2_pour_affe_anal_09   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_10  < 2 then oGeav.plan2_pour_affe_anal_10    :=grp.plan2_pour_affe_anal_10  ; else oGeav.plan2_pour_affe_anal_10   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_11  < 2 then oGeav.plan2_pour_affe_anal_11    :=grp.plan2_pour_affe_anal_11  ; else oGeav.plan2_pour_affe_anal_11   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_12  < 2 then oGeav.plan2_pour_affe_anal_12    :=grp.plan2_pour_affe_anal_12  ; else oGeav.plan2_pour_affe_anal_12   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_13  < 2 then oGeav.plan2_pour_affe_anal_13    :=grp.plan2_pour_affe_anal_13  ; else oGeav.plan2_pour_affe_anal_13   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_14  < 2 then oGeav.plan2_pour_affe_anal_14    :=grp.plan2_pour_affe_anal_14  ; else oGeav.plan2_pour_affe_anal_14   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_15  < 2 then oGeav.plan2_pour_affe_anal_15    :=grp.plan2_pour_affe_anal_15  ; else oGeav.plan2_pour_affe_anal_15   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_16  < 2 then oGeav.plan2_pour_affe_anal_16    :=grp.plan2_pour_affe_anal_16  ; else oGeav.plan2_pour_affe_anal_16   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_17  < 2 then oGeav.plan2_pour_affe_anal_17    :=grp.plan2_pour_affe_anal_17  ; else oGeav.plan2_pour_affe_anal_17   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_18  < 2 then oGeav.plan2_pour_affe_anal_18    :=grp.plan2_pour_affe_anal_18  ; else oGeav.plan2_pour_affe_anal_18   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_19  < 2 then oGeav.plan2_pour_affe_anal_19    :=grp.plan2_pour_affe_anal_19  ; else oGeav.plan2_pour_affe_anal_19   :='';end if;
       if grp.cnt_plan2_pour_affe_anal_20  < 2 then oGeav.plan2_pour_affe_anal_20    :=grp.plan2_pour_affe_anal_20  ; else oGeav.plan2_pour_affe_anal_20   :='';end if;
       if grp.cnt_plan3_code_anal_01       < 2 then oGeav.plan3_code_anal_01         :=grp.plan3_code_anal_01       ; else oGeav.plan3_code_anal_01        :='Plusieurs ('||grp.cnt_plan3_code_anal_01      ||')';end if;
       if grp.cnt_plan3_code_anal_02       < 2 then oGeav.plan3_code_anal_02         :=grp.plan3_code_anal_02       ; else oGeav.plan3_code_anal_02        :='Plusieurs ('||grp.cnt_plan3_code_anal_02      ||')';end if;
       if grp.cnt_plan3_code_anal_03       < 2 then oGeav.plan3_code_anal_03         :=grp.plan3_code_anal_03       ; else oGeav.plan3_code_anal_03        :='Plusieurs ('||grp.cnt_plan3_code_anal_03      ||')';end if;
       if grp.cnt_plan3_code_anal_04       < 2 then oGeav.plan3_code_anal_04         :=grp.plan3_code_anal_04       ; else oGeav.plan3_code_anal_04        :='Plusieurs ('||grp.cnt_plan3_code_anal_04      ||')';end if;
       if grp.cnt_plan3_code_anal_05       < 2 then oGeav.plan3_code_anal_05         :=grp.plan3_code_anal_05       ; else oGeav.plan3_code_anal_05        :='Plusieurs ('||grp.cnt_plan3_code_anal_05      ||')';end if;
       if grp.cnt_plan3_code_anal_06       < 2 then oGeav.plan3_code_anal_06         :=grp.plan3_code_anal_06       ; else oGeav.plan3_code_anal_06        :='Plusieurs ('||grp.cnt_plan3_code_anal_06      ||')';end if;
       if grp.cnt_plan3_code_anal_07       < 2 then oGeav.plan3_code_anal_07         :=grp.plan3_code_anal_07       ; else oGeav.plan3_code_anal_07        :='Plusieurs ('||grp.cnt_plan3_code_anal_07      ||')';end if;
       if grp.cnt_plan3_code_anal_08       < 2 then oGeav.plan3_code_anal_08         :=grp.plan3_code_anal_08       ; else oGeav.plan3_code_anal_08        :='Plusieurs ('||grp.cnt_plan3_code_anal_08      ||')';end if;
       if grp.cnt_plan3_code_anal_09       < 2 then oGeav.plan3_code_anal_09         :=grp.plan3_code_anal_09       ; else oGeav.plan3_code_anal_09        :='Plusieurs ('||grp.cnt_plan3_code_anal_09      ||')';end if;
       if grp.cnt_plan3_code_anal_10       < 2 then oGeav.plan3_code_anal_10         :=grp.plan3_code_anal_10       ; else oGeav.plan3_code_anal_10        :='Plusieurs ('||grp.cnt_plan3_code_anal_10      ||')';end if;
       if grp.cnt_plan3_code_anal_11       < 2 then oGeav.plan3_code_anal_11         :=grp.plan3_code_anal_11       ; else oGeav.plan3_code_anal_11        :='Plusieurs ('||grp.cnt_plan3_code_anal_11      ||')';end if;
       if grp.cnt_plan3_code_anal_12       < 2 then oGeav.plan3_code_anal_12         :=grp.plan3_code_anal_12       ; else oGeav.plan3_code_anal_12        :='Plusieurs ('||grp.cnt_plan3_code_anal_12      ||')';end if;
       if grp.cnt_plan3_code_anal_13       < 2 then oGeav.plan3_code_anal_13         :=grp.plan3_code_anal_13       ; else oGeav.plan3_code_anal_13        :='Plusieurs ('||grp.cnt_plan3_code_anal_13      ||')';end if;
       if grp.cnt_plan3_code_anal_14       < 2 then oGeav.plan3_code_anal_14         :=grp.plan3_code_anal_14       ; else oGeav.plan3_code_anal_14        :='Plusieurs ('||grp.cnt_plan3_code_anal_14      ||')';end if;
       if grp.cnt_plan3_code_anal_15       < 2 then oGeav.plan3_code_anal_15         :=grp.plan3_code_anal_15       ; else oGeav.plan3_code_anal_15        :='Plusieurs ('||grp.cnt_plan3_code_anal_15      ||')';end if;
       if grp.cnt_plan3_code_anal_16       < 2 then oGeav.plan3_code_anal_16         :=grp.plan3_code_anal_16       ; else oGeav.plan3_code_anal_16        :='Plusieurs ('||grp.cnt_plan3_code_anal_16      ||')';end if;
       if grp.cnt_plan3_code_anal_17       < 2 then oGeav.plan3_code_anal_17         :=grp.plan3_code_anal_17       ; else oGeav.plan3_code_anal_17        :='Plusieurs ('||grp.cnt_plan3_code_anal_17      ||')';end if;
       if grp.cnt_plan3_code_anal_18       < 2 then oGeav.plan3_code_anal_18         :=grp.plan3_code_anal_18       ; else oGeav.plan3_code_anal_18        :='Plusieurs ('||grp.cnt_plan3_code_anal_18      ||')';end if;
       if grp.cnt_plan3_code_anal_19       < 2 then oGeav.plan3_code_anal_19         :=grp.plan3_code_anal_19       ; else oGeav.plan3_code_anal_19        :='Plusieurs ('||grp.cnt_plan3_code_anal_19      ||')';end if;
       if grp.cnt_plan3_code_anal_20       < 2 then oGeav.plan3_code_anal_20         :=grp.plan3_code_anal_20       ; else oGeav.plan3_code_anal_20        :='Plusieurs ('||grp.cnt_plan3_code_anal_20      ||')';end if;
       if grp.cnt_plan3_pour_affe_anal_01  < 2 then oGeav.plan3_pour_affe_anal_01    :=grp.plan3_pour_affe_anal_01  ; else oGeav.plan3_pour_affe_anal_01   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_02  < 2 then oGeav.plan3_pour_affe_anal_02    :=grp.plan3_pour_affe_anal_02  ; else oGeav.plan3_pour_affe_anal_02   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_03  < 2 then oGeav.plan3_pour_affe_anal_03    :=grp.plan3_pour_affe_anal_03  ; else oGeav.plan3_pour_affe_anal_03   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_04  < 2 then oGeav.plan3_pour_affe_anal_04    :=grp.plan3_pour_affe_anal_04  ; else oGeav.plan3_pour_affe_anal_04   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_05  < 2 then oGeav.plan3_pour_affe_anal_05    :=grp.plan3_pour_affe_anal_05  ; else oGeav.plan3_pour_affe_anal_05   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_06  < 2 then oGeav.plan3_pour_affe_anal_06    :=grp.plan3_pour_affe_anal_06  ; else oGeav.plan3_pour_affe_anal_06   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_07  < 2 then oGeav.plan3_pour_affe_anal_07    :=grp.plan3_pour_affe_anal_07  ; else oGeav.plan3_pour_affe_anal_07   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_08  < 2 then oGeav.plan3_pour_affe_anal_08    :=grp.plan3_pour_affe_anal_08  ; else oGeav.plan3_pour_affe_anal_08   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_09  < 2 then oGeav.plan3_pour_affe_anal_09    :=grp.plan3_pour_affe_anal_09  ; else oGeav.plan3_pour_affe_anal_09   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_10  < 2 then oGeav.plan3_pour_affe_anal_10    :=grp.plan3_pour_affe_anal_10  ; else oGeav.plan3_pour_affe_anal_10   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_11  < 2 then oGeav.plan3_pour_affe_anal_11    :=grp.plan3_pour_affe_anal_11  ; else oGeav.plan3_pour_affe_anal_11   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_12  < 2 then oGeav.plan3_pour_affe_anal_12    :=grp.plan3_pour_affe_anal_12  ; else oGeav.plan3_pour_affe_anal_12   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_13  < 2 then oGeav.plan3_pour_affe_anal_13    :=grp.plan3_pour_affe_anal_13  ; else oGeav.plan3_pour_affe_anal_13   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_14  < 2 then oGeav.plan3_pour_affe_anal_14    :=grp.plan3_pour_affe_anal_14  ; else oGeav.plan3_pour_affe_anal_14   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_15  < 2 then oGeav.plan3_pour_affe_anal_15    :=grp.plan3_pour_affe_anal_15  ; else oGeav.plan3_pour_affe_anal_15   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_16  < 2 then oGeav.plan3_pour_affe_anal_16    :=grp.plan3_pour_affe_anal_16  ; else oGeav.plan3_pour_affe_anal_16   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_17  < 2 then oGeav.plan3_pour_affe_anal_17    :=grp.plan3_pour_affe_anal_17  ; else oGeav.plan3_pour_affe_anal_17   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_18  < 2 then oGeav.plan3_pour_affe_anal_18    :=grp.plan3_pour_affe_anal_18  ; else oGeav.plan3_pour_affe_anal_18   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_19  < 2 then oGeav.plan3_pour_affe_anal_19    :=grp.plan3_pour_affe_anal_19  ; else oGeav.plan3_pour_affe_anal_19   :='';end if;
       if grp.cnt_plan3_pour_affe_anal_20  < 2 then oGeav.plan3_pour_affe_anal_20    :=grp.plan3_pour_affe_anal_20  ; else oGeav.plan3_pour_affe_anal_20   :='';end if;
       if grp.cnt_plan4_code_anal_01       < 2 then oGeav.plan4_code_anal_01         :=grp.plan4_code_anal_01       ; else oGeav.plan4_code_anal_01        :='Plusieurs ('||grp.cnt_plan4_code_anal_01      ||')';end if;
       if grp.cnt_plan4_code_anal_02       < 2 then oGeav.plan4_code_anal_02         :=grp.plan4_code_anal_02       ; else oGeav.plan4_code_anal_02        :='Plusieurs ('||grp.cnt_plan4_code_anal_02      ||')';end if;
       if grp.cnt_plan4_code_anal_03       < 2 then oGeav.plan4_code_anal_03         :=grp.plan4_code_anal_03       ; else oGeav.plan4_code_anal_03        :='Plusieurs ('||grp.cnt_plan4_code_anal_03      ||')';end if;
       if grp.cnt_plan4_code_anal_04       < 2 then oGeav.plan4_code_anal_04         :=grp.plan4_code_anal_04       ; else oGeav.plan4_code_anal_04        :='Plusieurs ('||grp.cnt_plan4_code_anal_04      ||')';end if;
       if grp.cnt_plan4_code_anal_05       < 2 then oGeav.plan4_code_anal_05         :=grp.plan4_code_anal_05       ; else oGeav.plan4_code_anal_05        :='Plusieurs ('||grp.cnt_plan4_code_anal_05      ||')';end if;
       if grp.cnt_plan4_code_anal_06       < 2 then oGeav.plan4_code_anal_06         :=grp.plan4_code_anal_06       ; else oGeav.plan4_code_anal_06        :='Plusieurs ('||grp.cnt_plan4_code_anal_06      ||')';end if;
       if grp.cnt_plan4_code_anal_07       < 2 then oGeav.plan4_code_anal_07         :=grp.plan4_code_anal_07       ; else oGeav.plan4_code_anal_07        :='Plusieurs ('||grp.cnt_plan4_code_anal_07      ||')';end if;
       if grp.cnt_plan4_code_anal_08       < 2 then oGeav.plan4_code_anal_08         :=grp.plan4_code_anal_08       ; else oGeav.plan4_code_anal_08        :='Plusieurs ('||grp.cnt_plan4_code_anal_08      ||')';end if;
       if grp.cnt_plan4_code_anal_09       < 2 then oGeav.plan4_code_anal_09         :=grp.plan4_code_anal_09       ; else oGeav.plan4_code_anal_09        :='Plusieurs ('||grp.cnt_plan4_code_anal_09      ||')';end if;
       if grp.cnt_plan4_code_anal_10       < 2 then oGeav.plan4_code_anal_10         :=grp.plan4_code_anal_10       ; else oGeav.plan4_code_anal_10        :='Plusieurs ('||grp.cnt_plan4_code_anal_10      ||')';end if;
       if grp.cnt_plan4_code_anal_11       < 2 then oGeav.plan4_code_anal_11         :=grp.plan4_code_anal_11       ; else oGeav.plan4_code_anal_11        :='Plusieurs ('||grp.cnt_plan4_code_anal_11      ||')';end if;
       if grp.cnt_plan4_code_anal_12       < 2 then oGeav.plan4_code_anal_12         :=grp.plan4_code_anal_12       ; else oGeav.plan4_code_anal_12        :='Plusieurs ('||grp.cnt_plan4_code_anal_12      ||')';end if;
       if grp.cnt_plan4_code_anal_13       < 2 then oGeav.plan4_code_anal_13         :=grp.plan4_code_anal_13       ; else oGeav.plan4_code_anal_13        :='Plusieurs ('||grp.cnt_plan4_code_anal_13      ||')';end if;
       if grp.cnt_plan4_code_anal_14       < 2 then oGeav.plan4_code_anal_14         :=grp.plan4_code_anal_14       ; else oGeav.plan4_code_anal_14        :='Plusieurs ('||grp.cnt_plan4_code_anal_14      ||')';end if;
       if grp.cnt_plan4_code_anal_15       < 2 then oGeav.plan4_code_anal_15         :=grp.plan4_code_anal_15       ; else oGeav.plan4_code_anal_15        :='Plusieurs ('||grp.cnt_plan4_code_anal_15      ||')';end if;
       if grp.cnt_plan4_code_anal_16       < 2 then oGeav.plan4_code_anal_16         :=grp.plan4_code_anal_16       ; else oGeav.plan4_code_anal_16        :='Plusieurs ('||grp.cnt_plan4_code_anal_16      ||')';end if;
       if grp.cnt_plan4_code_anal_17       < 2 then oGeav.plan4_code_anal_17         :=grp.plan4_code_anal_17       ; else oGeav.plan4_code_anal_17        :='Plusieurs ('||grp.cnt_plan4_code_anal_17      ||')';end if;
       if grp.cnt_plan4_code_anal_18       < 2 then oGeav.plan4_code_anal_18         :=grp.plan4_code_anal_18       ; else oGeav.plan4_code_anal_18        :='Plusieurs ('||grp.cnt_plan4_code_anal_18      ||')';end if;
       if grp.cnt_plan4_code_anal_19       < 2 then oGeav.plan4_code_anal_19         :=grp.plan4_code_anal_19       ; else oGeav.plan4_code_anal_19        :='Plusieurs ('||grp.cnt_plan4_code_anal_19      ||')';end if;
       if grp.cnt_plan4_code_anal_20       < 2 then oGeav.plan4_code_anal_20         :=grp.plan4_code_anal_20       ; else oGeav.plan4_code_anal_20        :='Plusieurs ('||grp.cnt_plan4_code_anal_20      ||')';end if;
       if grp.cnt_plan4_pour_affe_anal_01  < 2 then oGeav.plan4_pour_affe_anal_01    :=grp.plan4_pour_affe_anal_01  ; else oGeav.plan4_pour_affe_anal_01   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_02  < 2 then oGeav.plan4_pour_affe_anal_02    :=grp.plan4_pour_affe_anal_02  ; else oGeav.plan4_pour_affe_anal_02   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_03  < 2 then oGeav.plan4_pour_affe_anal_03    :=grp.plan4_pour_affe_anal_03  ; else oGeav.plan4_pour_affe_anal_03   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_04  < 2 then oGeav.plan4_pour_affe_anal_04    :=grp.plan4_pour_affe_anal_04  ; else oGeav.plan4_pour_affe_anal_04   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_05  < 2 then oGeav.plan4_pour_affe_anal_05    :=grp.plan4_pour_affe_anal_05  ; else oGeav.plan4_pour_affe_anal_05   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_06  < 2 then oGeav.plan4_pour_affe_anal_06    :=grp.plan4_pour_affe_anal_06  ; else oGeav.plan4_pour_affe_anal_06   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_07  < 2 then oGeav.plan4_pour_affe_anal_07    :=grp.plan4_pour_affe_anal_07  ; else oGeav.plan4_pour_affe_anal_07   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_08  < 2 then oGeav.plan4_pour_affe_anal_08    :=grp.plan4_pour_affe_anal_08  ; else oGeav.plan4_pour_affe_anal_08   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_09  < 2 then oGeav.plan4_pour_affe_anal_09    :=grp.plan4_pour_affe_anal_09  ; else oGeav.plan4_pour_affe_anal_09   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_10  < 2 then oGeav.plan4_pour_affe_anal_10    :=grp.plan4_pour_affe_anal_10  ; else oGeav.plan4_pour_affe_anal_10   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_11  < 2 then oGeav.plan4_pour_affe_anal_11    :=grp.plan4_pour_affe_anal_11  ; else oGeav.plan4_pour_affe_anal_11   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_12  < 2 then oGeav.plan4_pour_affe_anal_12    :=grp.plan4_pour_affe_anal_12  ; else oGeav.plan4_pour_affe_anal_12   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_13  < 2 then oGeav.plan4_pour_affe_anal_13    :=grp.plan4_pour_affe_anal_13  ; else oGeav.plan4_pour_affe_anal_13   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_14  < 2 then oGeav.plan4_pour_affe_anal_14    :=grp.plan4_pour_affe_anal_14  ; else oGeav.plan4_pour_affe_anal_14   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_15  < 2 then oGeav.plan4_pour_affe_anal_15    :=grp.plan4_pour_affe_anal_15  ; else oGeav.plan4_pour_affe_anal_15   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_16  < 2 then oGeav.plan4_pour_affe_anal_16    :=grp.plan4_pour_affe_anal_16  ; else oGeav.plan4_pour_affe_anal_16   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_17  < 2 then oGeav.plan4_pour_affe_anal_17    :=grp.plan4_pour_affe_anal_17  ; else oGeav.plan4_pour_affe_anal_17   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_18  < 2 then oGeav.plan4_pour_affe_anal_18    :=grp.plan4_pour_affe_anal_18  ; else oGeav.plan4_pour_affe_anal_18   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_19  < 2 then oGeav.plan4_pour_affe_anal_19    :=grp.plan4_pour_affe_anal_19  ; else oGeav.plan4_pour_affe_anal_19   :='';end if;
       if grp.cnt_plan4_pour_affe_anal_20  < 2 then oGeav.plan4_pour_affe_anal_20    :=grp.plan4_pour_affe_anal_20  ; else oGeav.plan4_pour_affe_anal_20   :='';end if;
       if grp.cnt_plan5_code_anal_01       < 2 then oGeav.plan5_code_anal_01         :=grp.plan5_code_anal_01       ; else oGeav.plan5_code_anal_01        :='Plusieurs ('||grp.cnt_plan5_code_anal_01      ||')';end if;
       if grp.cnt_plan5_code_anal_02       < 2 then oGeav.plan5_code_anal_02         :=grp.plan5_code_anal_02       ; else oGeav.plan5_code_anal_02        :='Plusieurs ('||grp.cnt_plan5_code_anal_02      ||')';end if;
       if grp.cnt_plan5_code_anal_03       < 2 then oGeav.plan5_code_anal_03         :=grp.plan5_code_anal_03       ; else oGeav.plan5_code_anal_03        :='Plusieurs ('||grp.cnt_plan5_code_anal_03      ||')';end if;
       if grp.cnt_plan5_code_anal_04       < 2 then oGeav.plan5_code_anal_04         :=grp.plan5_code_anal_04       ; else oGeav.plan5_code_anal_04        :='Plusieurs ('||grp.cnt_plan5_code_anal_04      ||')';end if;
       if grp.cnt_plan5_code_anal_05       < 2 then oGeav.plan5_code_anal_05         :=grp.plan5_code_anal_05       ; else oGeav.plan5_code_anal_05        :='Plusieurs ('||grp.cnt_plan5_code_anal_05      ||')';end if;
       if grp.cnt_plan5_code_anal_06       < 2 then oGeav.plan5_code_anal_06         :=grp.plan5_code_anal_06       ; else oGeav.plan5_code_anal_06        :='Plusieurs ('||grp.cnt_plan5_code_anal_06      ||')';end if;
       if grp.cnt_plan5_code_anal_07       < 2 then oGeav.plan5_code_anal_07         :=grp.plan5_code_anal_07       ; else oGeav.plan5_code_anal_07        :='Plusieurs ('||grp.cnt_plan5_code_anal_07      ||')';end if;
       if grp.cnt_plan5_code_anal_08       < 2 then oGeav.plan5_code_anal_08         :=grp.plan5_code_anal_08       ; else oGeav.plan5_code_anal_08        :='Plusieurs ('||grp.cnt_plan5_code_anal_08      ||')';end if;
       if grp.cnt_plan5_code_anal_09       < 2 then oGeav.plan5_code_anal_09         :=grp.plan5_code_anal_09       ; else oGeav.plan5_code_anal_09        :='Plusieurs ('||grp.cnt_plan5_code_anal_09      ||')';end if;
       if grp.cnt_plan5_code_anal_10       < 2 then oGeav.plan5_code_anal_10         :=grp.plan5_code_anal_10       ; else oGeav.plan5_code_anal_10        :='Plusieurs ('||grp.cnt_plan5_code_anal_10      ||')';end if;
       if grp.cnt_plan5_code_anal_11       < 2 then oGeav.plan5_code_anal_11         :=grp.plan5_code_anal_11       ; else oGeav.plan5_code_anal_11        :='Plusieurs ('||grp.cnt_plan5_code_anal_11      ||')';end if;
       if grp.cnt_plan5_code_anal_12       < 2 then oGeav.plan5_code_anal_12         :=grp.plan5_code_anal_12       ; else oGeav.plan5_code_anal_12        :='Plusieurs ('||grp.cnt_plan5_code_anal_12      ||')';end if;
       if grp.cnt_plan5_code_anal_13       < 2 then oGeav.plan5_code_anal_13         :=grp.plan5_code_anal_13       ; else oGeav.plan5_code_anal_13        :='Plusieurs ('||grp.cnt_plan5_code_anal_13      ||')';end if;
       if grp.cnt_plan5_code_anal_14       < 2 then oGeav.plan5_code_anal_14         :=grp.plan5_code_anal_14       ; else oGeav.plan5_code_anal_14        :='Plusieurs ('||grp.cnt_plan5_code_anal_14      ||')';end if;
       if grp.cnt_plan5_code_anal_15       < 2 then oGeav.plan5_code_anal_15         :=grp.plan5_code_anal_15       ; else oGeav.plan5_code_anal_15        :='Plusieurs ('||grp.cnt_plan5_code_anal_15      ||')';end if;
       if grp.cnt_plan5_code_anal_16       < 2 then oGeav.plan5_code_anal_16         :=grp.plan5_code_anal_16       ; else oGeav.plan5_code_anal_16        :='Plusieurs ('||grp.cnt_plan5_code_anal_16      ||')';end if;
       if grp.cnt_plan5_code_anal_17       < 2 then oGeav.plan5_code_anal_17         :=grp.plan5_code_anal_17       ; else oGeav.plan5_code_anal_17        :='Plusieurs ('||grp.cnt_plan5_code_anal_17      ||')';end if;
       if grp.cnt_plan5_code_anal_18       < 2 then oGeav.plan5_code_anal_18         :=grp.plan5_code_anal_18       ; else oGeav.plan5_code_anal_18        :='Plusieurs ('||grp.cnt_plan5_code_anal_18      ||')';end if;
       if grp.cnt_plan5_code_anal_19       < 2 then oGeav.plan5_code_anal_19         :=grp.plan5_code_anal_19       ; else oGeav.plan5_code_anal_19        :='Plusieurs ('||grp.cnt_plan5_code_anal_19      ||')';end if;
       if grp.cnt_plan5_code_anal_20       < 2 then oGeav.plan5_code_anal_20         :=grp.plan5_code_anal_20       ; else oGeav.plan5_code_anal_20        :='Plusieurs ('||grp.cnt_plan5_code_anal_20      ||')';end if;
       if grp.cnt_plan5_pour_affe_anal_01  < 2 then oGeav.plan5_pour_affe_anal_01    :=grp.plan5_pour_affe_anal_01  ; else oGeav.plan5_pour_affe_anal_01   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_02  < 2 then oGeav.plan5_pour_affe_anal_02    :=grp.plan5_pour_affe_anal_02  ; else oGeav.plan5_pour_affe_anal_02   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_03  < 2 then oGeav.plan5_pour_affe_anal_03    :=grp.plan5_pour_affe_anal_03  ; else oGeav.plan5_pour_affe_anal_03   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_04  < 2 then oGeav.plan5_pour_affe_anal_04    :=grp.plan5_pour_affe_anal_04  ; else oGeav.plan5_pour_affe_anal_04   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_05  < 2 then oGeav.plan5_pour_affe_anal_05    :=grp.plan5_pour_affe_anal_05  ; else oGeav.plan5_pour_affe_anal_05   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_06  < 2 then oGeav.plan5_pour_affe_anal_06    :=grp.plan5_pour_affe_anal_06  ; else oGeav.plan5_pour_affe_anal_06   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_07  < 2 then oGeav.plan5_pour_affe_anal_07    :=grp.plan5_pour_affe_anal_07  ; else oGeav.plan5_pour_affe_anal_07   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_08  < 2 then oGeav.plan5_pour_affe_anal_08    :=grp.plan5_pour_affe_anal_08  ; else oGeav.plan5_pour_affe_anal_08   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_09  < 2 then oGeav.plan5_pour_affe_anal_09    :=grp.plan5_pour_affe_anal_09  ; else oGeav.plan5_pour_affe_anal_09   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_10  < 2 then oGeav.plan5_pour_affe_anal_10    :=grp.plan5_pour_affe_anal_10  ; else oGeav.plan5_pour_affe_anal_10   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_11  < 2 then oGeav.plan5_pour_affe_anal_11    :=grp.plan5_pour_affe_anal_11  ; else oGeav.plan5_pour_affe_anal_11   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_12  < 2 then oGeav.plan5_pour_affe_anal_12    :=grp.plan5_pour_affe_anal_12  ; else oGeav.plan5_pour_affe_anal_12   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_13  < 2 then oGeav.plan5_pour_affe_anal_13    :=grp.plan5_pour_affe_anal_13  ; else oGeav.plan5_pour_affe_anal_13   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_14  < 2 then oGeav.plan5_pour_affe_anal_14    :=grp.plan5_pour_affe_anal_14  ; else oGeav.plan5_pour_affe_anal_14   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_15  < 2 then oGeav.plan5_pour_affe_anal_15    :=grp.plan5_pour_affe_anal_15  ; else oGeav.plan5_pour_affe_anal_15   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_16  < 2 then oGeav.plan5_pour_affe_anal_16    :=grp.plan5_pour_affe_anal_16  ; else oGeav.plan5_pour_affe_anal_16   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_17  < 2 then oGeav.plan5_pour_affe_anal_17    :=grp.plan5_pour_affe_anal_17  ; else oGeav.plan5_pour_affe_anal_17   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_18  < 2 then oGeav.plan5_pour_affe_anal_18    :=grp.plan5_pour_affe_anal_18  ; else oGeav.plan5_pour_affe_anal_18   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_19  < 2 then oGeav.plan5_pour_affe_anal_19    :=grp.plan5_pour_affe_anal_19  ; else oGeav.plan5_pour_affe_anal_19   :='';end if;
       if grp.cnt_plan5_pour_affe_anal_20  < 2 then oGeav.plan5_pour_affe_anal_20    :=grp.plan5_pour_affe_anal_20  ; else oGeav.plan5_pour_affe_anal_20   :='';end if;

       if grp.cnt_repa_anal_code           < 2 then oGeav.repa_anal_code            :=grp.repa_anal_code            ; else oGeav.repa_anal_code            :='Plusieurs ('||grp.cnt_repa_anal_code       ||')';if vAFFI_DERN_VALE = 'O' then begin select e.repa_anal_code into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.repa_anal_code :=oGeav.repa_anal_code || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_rais_soci                < 2 then oGeav.rais_soci                 :=grp.rais_soci                 ; else oGeav.rais_soci                 :='Plusieures ('||grp.cnt_rais_soci           ||')';end if;
       if grp.cnt_soci_orig                < 2 then oGeav.soci_orig                 :=grp.soci_orig                 ; else oGeav.soci_orig                 :='Plusieures ('||grp.cnt_soci_orig           ||')';end if;
       if grp.cnt_fin_peri_essa            < 2 then oGeav.fin_peri_essa             :=grp.fin_peri_essa             ; else oGeav.fin_peri_essa             :='Plusieurs ('||grp.cnt_fin_peri_essa        ||')';end if;
       if grp.cnt_droi_prim_anci           < 2 then oGeav.droi_prim_anci            :=grp.droi_prim_anci            ; else oGeav.droi_prim_anci            :='Plusieurs ('||grp.cnt_droi_prim_anci       ||')';end if;
       if grp.cnt_bic_01                   < 2 then oGeav.bic_01                    :=grp.bic_01                    ; else oGeav.bic_01                    :='Plusieurs ('||grp.cnt_bic_01               ||')';if vAFFI_DERN_VALE = 'O' then begin select e.bic_01 into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.bic_01 :=oGeav.bic_01 || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_bic_02                   < 2 then oGeav.bic_02                    :=grp.bic_02                    ; else oGeav.bic_02                    :='Plusieurs ('||grp.cnt_bic_02               ||')';end if;
       if grp.cnt_iban_01                  < 2 then oGeav.iban_01                   :=grp.iban_01                   ; else oGeav.iban_01                   :='Plusieurs ('||grp.cnt_iban_01              ||')';if vAFFI_DERN_VALE = 'O' then begin select e.iban_01 into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.iban_01 :=oGeav.iban_01 || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_iban_02                  < 2 then oGeav.iban_02                   :=grp.iban_02                   ; else oGeav.iban_02                   :='Plusieurs ('||grp.cnt_iban_02              ||')';end if;
       if grp.cnt_code_iso_pays_nati       < 2 then oGeav.code_iso_pays_nati        :=grp.code_iso_pays_nati        ; else oGeav.code_iso_pays_nati        :='Plusieurs ('||grp.cnt_code_iso_pays_nati   ||')';end if;
       if grp.cnt_soci                     < 2 then oGeav.soci                      :=grp.soci                      ; else oGeav.soci                      :=''                                               ;end if;

       if grp.cnt_peri                     < 2 then oGeav.peri                      :=grp.peri                      ; else oGeav.peri                      :='Plusieurs ('||grp.cnt_peri                 ||')' ; if vAFFI_DERN_VALE = 'O' then oGeav.peri :=vDERN_PERI_AFFI ;end if;end if;
       if grp.cnt_id_sala                  < 2 then oGeav.id_sala                   :=grp.id_sala                   ; else oGeav.id_sala                   :=''                                               ;end if;
       if grp.cnt_nom                      < 2 then oGeav.nom                       :=grp.nom                       ; else oGeav.nom                       :='Plusieurs ('||grp.cnt_nom                  ||')';if vAFFI_DERN_VALE = 'O' then begin select e.nom into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.nom :=oGeav.nom || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_pren                     < 2 then oGeav.pren                      :=grp.pren                      ; else oGeav.pren                      :='Plusieurs ('||grp.cnt_pren                 ||')';if vAFFI_DERN_VALE = 'O' then begin select e.pren into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.pren :=oGeav.pren || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_nom_jeun_fill            < 2 then oGeav.nom_jeun_fill             :=grp.nom_jeun_fill             ; else oGeav.nom_jeun_fill             :='Plusieurs ('||grp.cnt_nom_jeun_fill        ||')';end if;
       if grp.cnt_depa                     < 2 then oGeav.depa                      :=grp.depa                      ; else oGeav.depa                      :='Plusieurs ('||grp.cnt_depa                 ||') ';if vAFFI_DERN_VALE = 'O' then begin select e.depa into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.depa :=oGeav.depa || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_id_cate                  < 2 then oGeav.id_cate                   :=grp.id_cate                   ; else oGeav.id_cate                   :=''                                               ;end if;
       if grp.cnt_cate_prof                < 2 then oGeav.cate_prof                 :=grp.cate_prof                 ; else oGeav.cate_prof                 :='Plusieurs (' ||grp.cnt_cate_prof           ||')';if vAFFI_DERN_VALE = 'O' then begin select e.cate_prof into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.cate_prof :=oGeav.cate_prof || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_conv_coll                < 2 then oGeav.conv_coll                 :=grp.conv_coll                 ; else oGeav.conv_coll                 :='Plusieures ('||grp.cnt_conv_coll           ||')';end if;
       if grp.cnt_id_etab                  < 2 then oGeav.id_etab                   :=grp.id_etab                   ; else oGeav.id_etab                   :=''                                               ;end if;
       if grp.cnt_libe_etab                < 2 then oGeav.libe_etab                 :=grp.libe_etab                 ; else oGeav.libe_etab                 :='';if vAFFI_DERN_VALE = 'O' then begin select e.libe_etab into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.libe_etab :=oGeav.libe_etab || ' [' || vVALE_DERN_PERI || '] '; else oGeav.libe_etab := 'Plusieurs (' ||grp.cnt_libe_etab||')';end if; end if;
       if grp.cnt_libe_etab_cour           < 2 then oGeav.libe_etab_cour            :=grp.libe_etab_cour            ; else oGeav.libe_etab_cour            :='';if vAFFI_DERN_VALE = 'O' then begin select e.libe_etab_cour into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.libe_etab_cour :=oGeav.libe_etab_cour || ' [' || vVALE_DERN_PERI || '] '; else oGeav.libe_etab_cour := 'Plusieurs (' ||grp.cnt_libe_etab_cour||')';end if; end if;
       if grp.cnt_titr                     < 2 then oGeav.titr                      :=grp.titr                      ; else oGeav.titr                      :='Plusieurs (' ||grp.cnt_titr                ||')';end if;
       if grp.cnt_nive_qual                < 2 then oGeav.nive_qual                 :=grp.nive_qual                 ; else oGeav.nive_qual                 :='Plusieurs (' ||grp.cnt_nive_qual           ||')';end if;
       if grp.cnt_moti_depa                < 2 then oGeav.moti_depa                 :=grp.moti_depa                 ; else oGeav.moti_depa                 :='Plusieurs (' ||grp.cnt_moti_depa           ||')';end if;
       if grp.cnt_moti_augm                < 2 then oGeav.moti_augm                 :=grp.moti_augm                 ; else oGeav.moti_augm                 :='Plusieurs (' ||grp.cnt_moti_augm           ||')';end if;
       if grp.cnt_moti_augm_2              < 2 then oGeav.moti_augm_2               :=grp.moti_augm_2               ; else oGeav.moti_augm_2               :='Plusieurs (' ||grp.cnt_moti_augm_2         ||')';end if;---KFH 25/05/2023 T184292
       if grp.cnt_TICK_REST_TYPE_REPA      < 2 then oGeav.TICK_REST_TYPE_REPA       :=grp.TICK_REST_TYPE_REPA       ; else oGeav.TICK_REST_TYPE_REPA       :='Plusieurs (' ||grp.cnt_TICK_REST_TYPE_REPA ||')';end if;---KFH 03/04/2024 T201908
       if grp.cnt_sala_auto_titr_trav      < 2 then oGeav.sala_auto_titr_trav       :=grp.sala_auto_titr_trav       ; else oGeav.sala_auto_titr_trav       :='Plusieurs (' ||grp.cnt_sala_auto_titr_trav ||')';end if;
       if grp.cnt_lieu_pres_stag           < 2 then oGeav.lieu_pres_stag            :=grp.lieu_pres_stag            ; else oGeav.lieu_pres_stag            :='Plusieurs (' ||grp.cnt_lieu_pres_stag      ||')';end if;
       if grp.cnt_sexe                     < 2 then oGeav.sexe                      :=grp.sexe                      ; else oGeav.sexe                      :='Plusieurs (' ||grp.cnt_sexe                ||')';end if;
       if grp.cnt_matr_grou                < 2 then oGeav.matr_grou                 :=grp.matr_grou                 ; else oGeav.matr_grou                 :='Plusieurs (' ||grp.cnt_matr_grou           ||')';end if;
       if grp.cnt_matr_resp_hier           < 2 then oGeav.matr_resp_hier            :=grp.matr_resp_hier            ; else oGeav.matr_resp_hier            :='Plusieurs (' ||grp.cnt_matr_resp_hier      ||')';end if;
       if grp.cnt_date_anci_prof           < 2 then oGeav.date_anci_prof            :=grp.date_anci_prof            ; else oGeav.date_anci_prof            :='Plusieures ('||grp.cnt_date_anci_prof      ||')';end if;
       if grp.cnt_date_refe_01             < 2 then oGeav.date_refe_01              :=grp.date_refe_01              ; else oGeav.date_refe_01              :='Plusieures ('||grp.cnt_date_refe_01        ||')';end if;
       if grp.cnt_date_refe_02             < 2 then oGeav.date_refe_02              :=grp.date_refe_02              ; else oGeav.date_refe_02              :='Plusieures ('||grp.cnt_date_refe_02        ||')';end if;
       if grp.cnt_date_refe_03             < 2 then oGeav.date_refe_03              :=grp.date_refe_03              ; else oGeav.date_refe_03              :='Plusieures ('||grp.cnt_date_refe_03        ||')';end if;
       if grp.cnt_date_refe_04             < 2 then oGeav.date_refe_04              :=grp.date_refe_04              ; else oGeav.date_refe_04              :='Plusieures ('||grp.cnt_date_refe_04        ||')';end if;
       if grp.cnt_date_refe_05             < 2 then oGeav.date_refe_05              :=grp.date_refe_05              ; else oGeav.date_refe_05              :='Plusieures ('||grp.cnt_date_refe_05        ||')';end if;
       if grp.cnt_date_sign_conv_stag      < 2 then oGeav.date_sign_conv_stag       :=grp.date_sign_conv_stag       ; else oGeav.date_sign_conv_stag       :='Plusieures ('||grp.cnt_date_sign_conv_stag ||')';end if;
       if grp.cnt_matr                     < 2 then oGeav.matr                      :=grp.matr                      ; else oGeav.matr                      :='Plusieurs (' ||grp.cnt_matr                ||')';if vAFFI_DERN_VALE = 'O' then begin select e.matr into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.matr :=oGeav.matr || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_adre_mail                < 2 then oGeav.adre_mail                 :=grp.adre_mail                 ; else oGeav.adre_mail                 :='Plusieurs (' ||grp.cnt_adre_mail           ||')';if vAFFI_DERN_VALE = 'O' then begin select e.adre_mail into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.adre_mail :=oGeav.adre_mail || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_adre_mail_pers           < 2 then oGeav.adre_mail_pers            :=grp.adre_mail_pers            ; else oGeav.adre_mail_pers            :='Plusieurs (' ||grp.cnt_adre_mail_pers      ||')';if vAFFI_DERN_VALE = 'O' then begin select e.adre_mail_pers into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.adre_mail_pers :=oGeav.adre_mail_pers || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_reac_regu                < 2 then oGeav.reac_regu                 :=grp.reac_regu                 ; else oGeav.reac_regu                 :='Plusieurs (' ||grp.cnt_reac_regu           ||')';end if;
       if grp.cnt_serv                     < 2 then oGeav.serv                      :=grp.serv                      ; else  oGeav.serv                     :='Plusieurs (' ||grp.cnt_serv                ||')';if vAFFI_DERN_VALE = 'O' then select max(e.serv) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala;oGeav.serv  :=vVALE_DERN_PERI ; end if; end if;
       if grp.cnt_empl                     < 2 then oGeav.empl                      :=grp.empl                      ; else oGeav.empl                      :='Plusieurs (' ||grp.cnt_empl                ||')';if vAFFI_DERN_VALE = 'O' then select max(e.empl) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.empl :=vVALE_DERN_PERI ; end if; end if;
       if grp.cnt_empl_type                < 2 then oGeav.empl_type                 :=grp.empl_type                 ; else oGeav.empl_type                 :='Plusieurs (' ||grp.cnt_empl_type           ||')';end if;
       if grp.cnt_meti                     < 2 then oGeav.meti                      :=grp.meti                      ; else oGeav.meti                      :='Plusieurs (' ||grp.cnt_meti                ||')';end if;
       if grp.cnt_fami_meti                < 2 then oGeav.fami_meti                 :=grp.fami_meti                 ; else oGeav.fami_meti                 :='Plusieurs (' ||grp.cnt_fami_meti           ||')';end if;
       if grp.cnt_fami_meti_hier           < 2 then oGeav.fami_meti_hier            :=grp.fami_meti_hier            ; else oGeav.fami_meti_hier            :='Plusieurs (' ||grp.cnt_fami_meti_hier      ||')';end if;
       if grp.cnt_code_empl                < 2 then oGeav.code_empl                 :=grp.code_empl                 ; else oGeav.code_empl                 :='Plusieurs (' ||grp.cnt_code_empl           ||')';end if;
       if grp.cnt_code_cate                < 2 then oGeav.code_cate                 :=grp.code_cate                 ; else oGeav.code_cate                 :='Plusieurs (' ||grp.cnt_code_cate           ||')';end if;
       if grp.cnt_code_fine_geog           < 2 then oGeav.code_fine_geog            :=grp.code_fine_geog            ; else oGeav.code_fine_geog            :='Plusieurs (' ||grp.cnt_code_fine_geog      ||')';end if;
       if grp.cnt_coef                     < 2 then oGeav.coef                      :=grp.coef                      ; else oGeav.coef                      :='';if vAFFI_DERN_VALE = 'O' then begin select e.coef into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.coef :=oGeav.coef || ' [' || vVALE_DERN_PERI || '] '; else oGeav.coef := 'Plusieurs (' ||grp.cnt_coef||')';end if; end if;
       if grp.cnt_sire_etab                     < 2 then oGeav.sire_etab                      :=grp.sire_etab                      ; else oGeav.sire_etab                      :='Plusieurs (' ||grp.cnt_sire_etab                ||')';end if;
       if grp.cnt_dipl                     < 2 then oGeav.dipl                      :=grp.dipl                      ; else oGeav.dipl                      :='Plusieurs (' ||grp.cnt_dipl                ||')';end if;
       if grp.cnt_code_unit                     < 2 then oGeav.code_unit                      :=grp.code_unit                      ; else oGeav.code_unit                      :='Plusieurs (' ||grp.cnt_code_unit                ||')';end if;
       if grp.cnt_code_regr_fich_comp_etab                     < 2 then oGeav.code_regr_fich_comp_etab                      :=grp.code_regr_fich_comp_etab                      ; else oGeav.code_regr_fich_comp_etab                      :='Plusieurs (' ||grp.cnt_code_regr_fich_comp_etab                ||')';end if;
       if grp.cnt_nive                     < 2 then oGeav.nive                      :=grp.nive                      ; else oGeav.nive                      :='Plusieurs (' ||grp.cnt_nive                ||')';if vAFFI_DERN_VALE = 'O' then select max(e.nive) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.nive :=vVALE_DERN_PERI ; end if; end if;
       if grp.cnt_eche                     < 2 then oGeav.eche                      :=grp.eche                      ; else oGeav.eche                      :='Plusieurs (' ||grp.cnt_eche                ||')';if vAFFI_DERN_VALE = 'O' then select max(e.eche) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.eche :=vVALE_DERN_PERI ; end if; end if;
       if grp.cnt_grou_conv                < 2 then oGeav.grou_conv                 :=grp.grou_conv                 ; else oGeav.grou_conv                 :='Plusieures ('||grp.cnt_grou_conv           ||')';if vAFFI_DERN_VALE = 'O' then begin select e.grou_conv into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.grou_conv :=oGeav.grou_conv || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_posi                     < 2 then oGeav.posi                      :=grp.posi                      ; else oGeav.posi                      :='';if vAFFI_DERN_VALE = 'O' then begin select e.posi into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.posi :=oGeav.posi || ' [' || vVALE_DERN_PERI || '] '; else oGeav.posi := 'Plusieures ('||grp.cnt_posi||')';end if; end if;
       if grp.cnt_indi                     < 2 then oGeav.indi                      :=grp.indi                      ; else oGeav.indi                      :='Plusieurs (' ||grp.cnt_indi                ||')';end if;
       if grp.cnt_cota                     < 2 then oGeav.cota                      :=grp.cota                      ; else oGeav.cota                      :='Plusieurs (' ||grp.cnt_cota                ||')';if vAFFI_DERN_VALE = 'O' then select max(e.cota) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.cota :=vVALE_DERN_PERI ; end if; end if;
       if grp.cnt_clas                     < 2 then oGeav.clas                      :=grp.clas                      ; else oGeav.clas                      :='Plusieurs (' ||grp.cnt_clas                ||')';if vAFFI_DERN_VALE = 'O' then select max(e.clas) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.clas :=vVALE_DERN_PERI ; end if; end if;
       if grp.cnt_seui                     < 2 then oGeav.seui                      :=grp.seui                      ; else oGeav.seui                      :='Plusieurs (' ||grp.cnt_seui                ||')';if vAFFI_DERN_VALE = 'O' then select max(e.seui) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.seui :=vVALE_DERN_PERI ; end if; end if;
       if grp.cnt_pali                     < 2 then oGeav.pali                      :=grp.pali                      ; else oGeav.pali                      :='Plusieurs (' ||grp.cnt_pali                ||')';if vAFFI_DERN_VALE = 'O' then select max(e.pali) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.pali :=vVALE_DERN_PERI ; end if; end if;
       if grp.cnt_grad                     < 2 then oGeav.grad                      :=grp.grad                      ; else oGeav.grad                      :='Plusieurs (' ||grp.cnt_grad                ||')';if vAFFI_DERN_VALE = 'O' then select max(e.grad) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.grad :=vVALE_DERN_PERI ; end if; end if;
       if grp.cnt_degr                     < 2 then oGeav.degr                      :=grp.degr                      ; else oGeav.degr                      :='Plusieurs (' ||grp.cnt_degr                ||')';if vAFFI_DERN_VALE = 'O' then select max(e.degr) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.degr :=vVALE_DERN_PERI ; end if; end if;
       if grp.cnt_fili                     < 2 then oGeav.fili                      :=grp.fili                      ; else oGeav.fili                      :='Plusieurs (' ||grp.cnt_fili                ||')';end if;
       if grp.cnt_sect_prof                < 2 then oGeav.sect_prof                 :=grp.sect_prof                 ; else oGeav.sect_prof                 :='Plusieurs (' ||grp.cnt_sect_prof           ||')';end if;
       if grp.cnt_comp_brut                < 2 then oGeav.comp_brut                 :=grp.comp_brut                 ; else oGeav.comp_brut                 :='Plusieurs (' ||grp.cnt_comp_brut           ||')';end if;
       if grp.cnt_comp_paye                < 2 then oGeav.comp_paye                 :=grp.comp_paye                 ; else oGeav.comp_paye                 :='Plusieurs (' ||grp.cnt_comp_paye           ||')';end if;
       if grp.cnt_comp_acom                < 2 then oGeav.comp_acom                 :=grp.comp_acom                 ; else oGeav.comp_acom                 :='Plusieurs (' ||grp.cnt_comp_acom           ||')';end if;
       if grp.cnt_nume_secu                < 2 then oGeav.nume_secu                 :=grp.nume_secu                 ; else oGeav.nume_secu                 :='Plusieurs (' ||grp.cnt_nume_secu           ||')';end if;
       if grp.cnt_date_emba                < 2 then oGeav.date_emba                 :=grp.date_emba                 ; else oGeav.date_emba                 :='';if vAFFI_DERN_VALE = 'O' then select max(e.date_emba) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.date_emba :=vVALE_DERN_PERI ; end if; end if;--if vAFFI_DERN_VALE = 'O' then begin select e.date_emba into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.date_emba :=oGeav.date_emba || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_date_depa                < 2 then oGeav.date_depa                 :=grp.date_depa                 ; else oGeav.date_depa                 :='';if vAFFI_DERN_VALE = 'O' then select max(e.date_depa) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.date_depa :=vVALE_DERN_PERI ; end if; end if;--if vAFFI_DERN_VALE = 'O' then begin select e.date_depa into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.date_depa :=oGeav.date_depa || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_date_anci                < 2 then oGeav.date_anci                 :=grp.date_anci                 ; else oGeav.date_anci                 :='';if vAFFI_DERN_VALE = 'O' then select max(e.date_anci) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala=grp.id_sala; oGeav.date_anci :=vVALE_DERN_PERI ; end if; end if;--if vAFFI_DERN_VALE = 'O' then begin select e.date_anci into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.date_anci :=oGeav.date_anci || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_date_dela_prev           < 2 then oGeav.date_dela_prev            :=grp.date_dela_prev            ; else oGeav.date_dela_prev            :=''                                               ;end if;
       if grp.cnt_date_nais                < 2 then oGeav.date_nais                 :=grp.date_nais                 ; else oGeav.date_nais                 :=''                                               ;end if;
       if grp.cnt_date_acci_trav           < 2 then oGeav.date_acci_trav            :=grp.date_acci_trav            ; else oGeav.date_acci_trav            :=''                                               ;end if;

       if grp.cnt_comm_nais                < 2 then oGeav.comm_nais                 :=grp.comm_nais                 ; else oGeav.comm_nais                 :='Plusieurs (' ||grp.cnt_comm_nais           ||')';end if;
       if grp.cnt_depa_nais                < 2 then oGeav.depa_nais                 :=grp.depa_nais                 ; else oGeav.depa_nais                 :='Plusieurs (' ||grp.cnt_depa_nais           ||')';end if;
       if grp.cnt_pays_nais                < 2 then oGeav.pays_nais                 :=grp.pays_nais                 ; else oGeav.pays_nais                 :='Plusieurs (' ||grp.cnt_pays_nais           ||')';end if;

       if grp.cnt_trav_hand                < 2 then oGeav.trav_hand                 :=grp.trav_hand                 ; else oGeav.trav_hand                 :=''                                               ;end if;
       if grp.cnt_date_debu_coto           < 2 then oGeav.date_debu_coto            :=grp.date_debu_coto            ; else oGeav.date_debu_coto            :=''                                               ;end if;
       if grp.cnt_date_fin_coto            < 2 then oGeav.date_fin_coto             :=grp.date_fin_coto             ; else oGeav.date_fin_coto             :=''                                               ;end if;
       if grp.cnt_taux_inva                < 2 then oGeav.taux_inva                 :=grp.taux_inva                 ; else oGeav.taux_inva                 :=''                                               ;end if;
       if grp.cnt_situ_fami                < 2 then oGeav.situ_fami                 :=grp.situ_fami                 ; else oGeav.situ_fami                 :='Plusieurs ('||grp.cnt_situ_fami            ||')';end if;
       if grp.cnt_bull_mode                < 2 then oGeav.bull_mode                 :=grp.bull_mode                 ; else oGeav.bull_mode                 :='Plusieurs ('||grp.cnt_bull_mode            ||')';end if;
       if grp.cnt_profil_paye_cp           < 2 then oGeav.profil_paye_cp            :=grp.profil_paye_cp            ; else oGeav.profil_paye_cp            :='Plusieurs ('||grp.cnt_profil_paye_cp          ||')';end if;
       if grp.cnt_profil_paye_rtt          < 2 then oGeav.profil_paye_rtt           :=grp.profil_paye_rtt           ; else oGeav.profil_paye_rtt           :='Plusieurs ('||grp.cnt_profil_paye_rtt         ||')';end if;
       if grp.cnt_profil_paye_dif          < 2 then oGeav.profil_paye_dif           :=grp.profil_paye_dif           ; else oGeav.profil_paye_dif           :='Plusieurs ('||grp.cnt_profil_paye_dif         ||')';end if;
       if grp.cnt_profil_paye_prov_cet     < 2 then oGeav.profil_paye_prov_cet      :=grp.profil_paye_prov_cet      ; else oGeav.profil_paye_prov_cet      :='Plusieurs ('||grp.cnt_profil_paye_prov_cet    ||')';end if;
       if grp.cnt_profil_paye_prov_inte    < 2 then oGeav.profil_paye_prov_inte     :=grp.profil_paye_prov_inte     ; else oGeav.profil_paye_prov_inte     :='Plusieurs ('||grp.cnt_profil_paye_prov_inte   ||')';end if;
       if grp.cnt_profil_paye_prov_part    < 2 then oGeav.profil_paye_prov_part     :=grp.profil_paye_prov_part     ; else oGeav.profil_paye_prov_part     :='Plusieurs ('||grp.cnt_profil_paye_prov_part   ||')';end if;
       if grp.cnt_profil_paye_13mo         < 2 then oGeav.profil_paye_13mo          :=grp.profil_paye_13mo          ; else oGeav.profil_paye_13mo          :='Plusieurs ('||grp.cnt_profil_paye_13mo        ||')';end if;
       if grp.cnt_profil_paye_14mo         < 2 then oGeav.profil_paye_14mo          :=grp.profil_paye_14mo          ; else oGeav.profil_paye_14mo          :='Plusieurs ('||grp.cnt_profil_paye_14mo        ||')';end if;
       if grp.cnt_prof_15mo                < 2 then oGeav.prof_15mo                 :=grp.prof_15mo                 ; else oGeav.prof_15mo                 :='Plusieurs ('||grp.cnt_prof_15mo               ||')';end if;
       if grp.cnt_profil_paye_prim_vaca_01 < 2 then oGeav.profil_paye_prim_vaca_01  :=grp.profil_paye_prim_vaca_01  ; else oGeav.profil_paye_prim_vaca_01  :='Plusieurs ('||grp.cnt_profil_paye_prim_vaca_01||')';end if;
       if grp.cnt_profil_paye_prim_vaca_02 < 2 then oGeav.profil_paye_prim_vaca_02  :=grp.profil_paye_prim_vaca_02  ; else oGeav.profil_paye_prim_vaca_02  :='Plusieurs ('||grp.cnt_profil_paye_prim_vaca_02||')';end if;
       if grp.cnt_profil_paye_hs_conv      < 2 then oGeav.profil_paye_hs_conv       :=grp.profil_paye_hs_conv       ; else oGeav.profil_paye_hs_conv       :='Plusieurs ('||grp.cnt_profil_paye_hs_conv     ||')';end if;
       if grp.cnt_profil_paye_heur_equi    < 2 then oGeav.profil_paye_heur_equi     :=grp.profil_paye_heur_equi     ; else oGeav.profil_paye_heur_equi     :='Plusieurs ('||grp.cnt_profil_paye_heur_equi   ||')';end if;
       if grp.cnt_profil_paye_deca_fisc    < 2 then oGeav.profil_paye_deca_fisc     :=grp.profil_paye_deca_fisc     ; else oGeav.profil_paye_deca_fisc     :='Plusieurs ('||grp.cnt_profil_paye_deca_fisc   ||')';end if;
       if grp.cnt_profil_paye_tepa         < 2 then oGeav.profil_paye_tepa          :=grp.profil_paye_tepa          ; else oGeav.profil_paye_tepa          :='Plusieurs ('||grp.cnt_profil_paye_tepa        ||')';end if;
       if grp.cnt_profil_paye_affi_bull    < 2 then oGeav.profil_paye_affi_bull     :=grp.profil_paye_affi_bull     ; else oGeav.profil_paye_affi_bull     :='Plusieurs ('||grp.cnt_profil_paye_affi_bull   ||')';end if;
       if grp.cnt_profil_paye_forf         < 2 then oGeav.profil_paye_forf          :=grp.profil_paye_forf          ; else oGeav.profil_paye_forf          :='Plusieurs ('||grp.cnt_profil_paye_forf        ||')';end if;
       if grp.cnt_profil_paye_depa         < 2 then oGeav.profil_paye_depa          :=grp.profil_paye_depa          ; else oGeav.profil_paye_depa          :='Plusieurs ('||grp.cnt_profil_paye_depa        ||')';end if;
       if grp.cnt_profil_paye_rein_frai    < 2 then oGeav.profil_paye_rein_frai     :=grp.profil_paye_rein_frai     ; else oGeav.profil_paye_rein_frai     :='Plusieurs ('||grp.cnt_profil_paye_rein_frai   ||')';end if;
       if grp.cnt_profil_paye_ndf          < 2 then oGeav.profil_paye_ndf           :=grp.profil_paye_ndf           ; else oGeav.profil_paye_ndf           :='Plusieurs ('||grp.cnt_profil_paye_ndf         ||')';end if;
       if grp.cnt_profil_paye_acce_sala    < 2 then oGeav.profil_paye_acce_sala     :=grp.profil_paye_acce_sala     ; else oGeav.profil_paye_acce_sala     :='Plusieurs ('||grp.cnt_profil_paye_acce_sala   ||')';end if;
       if grp.cnt_profil_paye_plan         < 2 then oGeav.profil_paye_plan          :=grp.profil_paye_plan          ; else oGeav.profil_paye_plan          :='Plusieurs ('||grp.cnt_profil_paye_plan        ||')';end if;
       if grp.cnt_profil_paye_tele_trav    < 2 then oGeav.profil_paye_tele_trav     :=grp.profil_paye_tele_trav     ; else oGeav.profil_paye_tele_trav     :='Plusieurs ('||grp.cnt_profil_paye_tele_trav   ||')';end if;
       if grp.cnt_prof_temp_libe           < 2 then oGeav.prof_temp_libe            :=grp.prof_temp_libe            ; else oGeav.prof_temp_libe            :='Plusieurs (' ||grp.cnt_prof_temp_libe      ||')';end if;
       if grp.cnt_idcc_heur_equi           < 2 then oGeav.idcc_heur_equi            :=grp.idcc_heur_equi            ; else oGeav.idcc_heur_equi            :='Plusieurs ('||grp.cnt_idcc_heur_equi       ||')';end if;
       if grp.cnt_cipdz_code               < 2 then oGeav.cipdz_code                :=grp.cipdz_code                ; else oGeav.cipdz_code                :='';if vAFFI_DERN_VALE = 'O' then begin select e.cipdz_code into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.cipdz_code :=oGeav.cipdz_code || ' [' || vVALE_DERN_PERI || '] '; else oGeav.cipdz_code := 'Plusieurs ('||grp.cnt_cipdz_code||')';end if; end if;
       if grp.cnt_cipdz_libe               < 2 then oGeav.cipdz_libe                :=grp.cipdz_libe                ; else oGeav.cipdz_libe                :='';if vAFFI_DERN_VALE = 'O' then begin select e.cipdz_libe into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.cipdz_libe :=oGeav.cipdz_libe || ' [' || vVALE_DERN_PERI || '] '; else oGeav.cipdz_libe := 'Plusieurs ('||grp.cnt_cipdz_libe||')';end if; end if;
       if grp.cnt_nume_cong_spec           < 2 then oGeav.nume_cong_spec            :=grp.nume_cong_spec            ; else oGeav.nume_cong_spec            :='Plusieurs ('||grp.cnt_nume_cong_spec       ||')';end if;
       if grp.cnt_grou_comp                < 2 then oGeav.grou_comp                 :=grp.grou_comp                 ; else oGeav.grou_comp                 :='Plusieurs ('||grp.cnt_grou_comp            ||')';end if;
       if grp.cnt_nati                     < 2 then oGeav.nati                      :=grp.nati                      ; else oGeav.nati                      :='Plusieurs ('||grp.cnt_nati                 ||')';end if;
       if grp.cnt_date_expi                < 2 then oGeav.date_expi                 :=grp.date_expi                 ; else oGeav.date_expi                 :='Plusieurs ('||grp.cnt_date_expi            ||')';end if;
       if grp.cnt_nume_cart_sejo           < 2 then oGeav.nume_cart_sejo            :=grp.nume_cart_sejo            ; else oGeav.nume_cart_sejo            :='Plusieurs ('||grp.cnt_nume_cart_sejo       ||')';end if;
       if grp.cnt_nume_cart_trav           < 2 then oGeav.nume_cart_trav            :=grp.nume_cart_trav            ; else oGeav.nume_cart_trav            :='Plusieurs ('||grp.cnt_nume_cart_trav       ||')';end if;
       if grp.cnt_date_deli_trav           < 2 then oGeav.date_deli_trav            :=grp.date_deli_trav            ; else oGeav.date_deli_trav            :='Plusieurs ('||grp.cnt_date_deli_trav       ||')';end if;
       if grp.cnt_date_expi_trav           < 2 then oGeav.date_expi_trav            :=grp.date_expi_trav            ; else oGeav.date_expi_trav            :='Plusieurs ('||grp.cnt_date_expi_trav       ||')';end if;
       if grp.cnt_date_dema_auto_trav      < 2 then oGeav.date_dema_auto_trav       :=grp.date_dema_auto_trav       ; else oGeav.date_dema_auto_trav       :='Plusieurs ('||grp.cnt_date_dema_auto_trav  ||')';end if;
       if grp.cnt_id_pref                  < 2 then oGeav.id_pref                   :=grp.id_pref                   ; else oGeav.id_pref                   :='Plusieurs ('||grp.cnt_id_pref              ||')';end if;
       if grp.cnt_date_expi_disp_mutu      < 2 then oGeav.date_expi_disp_mutu       :=grp.date_expi_disp_mutu       ; else oGeav.date_expi_disp_mutu       :='Plusieurs ('||grp.cnt_date_expi_disp_mutu  ||')';end if;
       if grp.cnt_id_moti_disp_mutu        < 2 then oGeav.id_moti_disp_mutu         :=grp.id_moti_disp_mutu         ; else oGeav.id_moti_disp_mutu         :='Plusieurs ('||grp.cnt_id_moti_disp_mutu    ||')';end if;
       if grp.cnt_nomb_enfa                < 2 then oGeav.nomb_enfa                 :=grp.nomb_enfa                 ; else oGeav.nomb_enfa                 :='Plusieurs ('||grp.cnt_nomb_enfa            ||')';end if;
       if grp.cnt_dads_inse_empl           < 2 then oGeav.dads_inse_empl            :=grp.dads_inse_empl            ; else oGeav.dads_inse_empl            :='Plusieurs ('||grp.cnt_dads_inse_empl       ||')';end if;
       if grp.cnt_sais                     < 2 then oGeav.sais                      :=grp.sais                      ; else oGeav.sais                      :='Plusieurs ('||grp.cnt_sais                 ||')';end if;
       if grp.cnt_moti_visi_medi           < 2 then oGeav.moti_visi_medi            :=grp.moti_visi_medi            ; else oGeav.moti_visi_medi            :='Plusieurs ('||grp.cnt_moti_visi_medi       ||')';end if;
       if grp.cnt_stat_boet                < 2 then oGeav.stat_boet                 :=grp.stat_boet                 ; else oGeav.stat_boet                 :='Plusieurs ('||grp.cnt_stat_boet            ||')';end if;
       if grp.cnt_nomb_jour_trav_refe_tr_2 < 2 then oGeav.nomb_jour_trav_refe_tr_2  :=grp.nomb_jour_trav_refe_tr_2  ; else oGeav.nomb_jour_trav_refe_tr_2  :='Plusieurs ('||grp.cnt_nomb_jour_trav_refe_tr_2 ||')';end if;
       if grp.CNT_calc_auto_tr             < 2 then oGeav.calc_auto_tr              :=grp.calc_auto_tr              ; else oGeav.calc_auto_tr              :='Plusieurs ('||grp.cnt_calc_auto_tr         ||')';end if;
       if grp.CNT_type_vehi                < 2 then oGeav.type_vehi                 :=grp.type_vehi                 ; else oGeav.type_vehi                 :='Plusieurs ('||grp.cnt_type_vehi            ||')';end if;
       if grp.CNT_cate_vehi                < 2 then oGeav.cate_vehi                 :=grp.cate_vehi                 ; else oGeav.cate_vehi                 :='Plusieurs ('||grp.cnt_cate_vehi            ||')';end if;
       if grp.CNT_pris_char_carb           < 2 then oGeav.pris_char_carb            :=grp.pris_char_carb            ; else oGeav.pris_char_carb            :='Plusieurs ('||grp.cnt_pris_char_carb       ||')';end if;
       if grp.CNT_octr_vehi                < 2 then oGeav.octr_vehi                 :=grp.octr_vehi                 ; else oGeav.octr_vehi                 :='Plusieurs ('||grp.cnt_octr_vehi            ||')';end if;
       if grp.CNT_imma_vehi                < 2 then oGeav.imma_vehi                 :=grp.imma_vehi                 ; else oGeav.imma_vehi                 :='Plusieurs ('||grp.cnt_imma_vehi            ||')';end if;
       if grp.CNT_date_1er_mise_circ_vehi  < 2 then oGeav.date_1er_mise_circ_vehi   :=grp.date_1er_mise_circ_vehi   ; else oGeav.date_1er_mise_circ_vehi   :='Plusieurs ('||grp.cnt_date_1er_mise_circ_vehi ||')';end if;
       if grp.CNT_prix_acha_remi_vehi      < 2 then oGeav.prix_acha_remi_vehi       :=grp.prix_acha_remi_vehi       ; else oGeav.prix_acha_remi_vehi       :='Plusieurs ('||grp.cnt_prix_acha_remi_vehi  ||')';end if;
       if grp.CNT_cout_vehi                < 2 then oGeav.cout_vehi                 :=grp.cout_vehi                 ; else oGeav.cout_vehi                 :='Plusieurs ('||grp.cnt_cout_vehi            ||')';end if;
       if grp.cnt_type_sala                < 2 then oGeav.type_sala                 :=grp.type_sala                 ; else oGeav.type_sala                 :='Plusieurs ('||grp.cnt_type_sala            ||')';end if;
       if grp.cnt_natu_cont                < 2 then oGeav.natu_cont                 :=grp.natu_cont                 ; else oGeav.natu_cont                 :='';if vAFFI_DERN_VALE = 'O' then begin select e.natu_cont into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.natu_cont :=oGeav.natu_cont || ' [' || vVALE_DERN_PERI || '] '; else oGeav.natu_cont := 'Plusieurs ('||grp.cnt_natu_cont||')';end if; end if;
       if grp.cnt_nume_cont                < 2 then oGeav.nume_cont                 :=grp.nume_cont                 ; else oGeav.nume_cont                 :='Plusieurs ('||grp.cnt_nume_cont            ||')';end if;
       if grp.cnt_libe_moti_recr_cdd       < 2 then oGeav.libe_moti_recr_cdd        :=grp.libe_moti_recr_cdd        ; else oGeav.libe_moti_recr_cdd        :='Plusieurs ('||grp.cnt_libe_moti_recr_cdd   ||')';end if;
       if grp.cnt_libe_moti_recr_cdd2      < 2 then oGeav.libe_moti_recr_cdd2       :=grp.libe_moti_recr_cdd2       ; else oGeav.libe_moti_recr_cdd2       :='Plusieurs ('||grp.cnt_libe_moti_recr_cdd2  ||')';end if;
       if grp.cnt_libe_moti_recr_cdd3      < 2 then oGeav.libe_moti_recr_cdd3       :=grp.libe_moti_recr_cdd3       ; else oGeav.libe_moti_recr_cdd3       :='Plusieurs ('||grp.cnt_libe_moti_recr_cdd3  ||')';end if;
       if grp.cnt_date_debu_cont           < 2 then oGeav.date_debu_cont            :=grp.date_debu_cont            ; else oGeav.date_debu_cont            :='';                                               end if;
       if grp.cnt_date_fin_cont            < 2 then oGeav.date_fin_cont             :=grp.date_fin_cont             ; else oGeav.date_fin_cont             :='Plusieurs ('||grp.cnt_date_fin_cont        ||')';end if;
       if grp.cnt_date_dern_visi_medi      < 2 then oGeav.date_dern_visi_medi       :=grp.date_dern_visi_medi       ; else oGeav.date_dern_visi_medi       :='Plusieurs ('||grp.cnt_date_dern_visi_medi  ||')';end if;
       if grp.cnt_date_proc_visi_medi      < 2 then oGeav.date_proc_visi_medi       :=grp.date_proc_visi_medi       ; else oGeav.date_proc_visi_medi       :='Plusieurs ('||grp.cnt_date_proc_visi_medi  ||')';end if;
       if grp.cnt_equi                     < 2 then oGeav.equi                      :=grp.equi                      ; else oGeav.equi                      :='Plusieurs ('||grp.cnt_equi                 ||')';end if;
       if grp.cnt_divi                     < 2 then oGeav.divi                      :=grp.divi                      ; else oGeav.divi                      :='';if vAFFI_DERN_VALE = 'O' then begin select e.divi into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.divi :=oGeav.divi || ' [' || vVALE_DERN_PERI || '] '; else oGeav.divi := 'Plusieures ('||grp.cnt_divi||')';end if; end if;
       if grp.cnt_cais_coti_bull           < 2 then oGeav.cais_coti_bull            :=grp.cais_coti_bull            ; else oGeav.cais_coti_bull            :='Plusieurs (' ||grp.cnt_cais_coti_bull       ||')';end if;
       if grp.cnt_regr                     < 2 then oGeav.regr                      :=grp.regr                      ; else oGeav.regr                      :='Plusieurs (' ||grp.cnt_regr                 ||')';end if;
       if grp.cnt_mail_sala_cong           < 2 then oGeav.mail_sala_cong            :=grp.mail_sala_cong            ; else oGeav.mail_sala_cong            :='Plusieurs (' ||grp.cnt_mail_sala_cong       ||')';end if;
       if grp.cnt_resp_hier_1_nom          < 2 then oGeav.resp_hier_1_nom           :=grp.resp_hier_1_nom           ; else oGeav.resp_hier_1_nom           :='Plusieurs (' ||grp.cnt_resp_hier_1_nom      ||')';end if;
       if grp.cnt_resp_hier_1_mail         < 2 then oGeav.resp_hier_1_mail          :=grp.resp_hier_1_mail          ; else oGeav.resp_hier_1_mail          :='Plusieurs (' ||grp.cnt_resp_hier_1_mail     ||')';end if;
       if grp.cnt_resp_hier_2_nom          < 2 then oGeav.resp_hier_2_nom           :=grp.resp_hier_2_nom           ; else oGeav.resp_hier_2_nom           :='Plusieurs (' ||grp.cnt_resp_hier_2_nom      ||')';end if;
       if grp.cnt_resp_hier_2_mail         < 2 then oGeav.resp_hier_2_mail          :=grp.resp_hier_2_mail          ; else oGeav.resp_hier_2_mail          :='Plusieurs (' ||grp.cnt_resp_hier_2_mail     ||')';end if;
       if grp.cnt_hier_resp_1_nom          < 2 then oGeav.hier_resp_1_nom           :=grp.hier_resp_1_nom           ; else oGeav.hier_resp_1_nom           :='Plusieurs (' ||grp.cnt_hier_resp_1_nom      ||')';end if;
       if grp.cnt_hier_resp_1_mail         < 2 then oGeav.hier_resp_1_mail          :=grp.hier_resp_1_mail          ; else oGeav.hier_resp_1_mail          :='Plusieurs (' ||grp.cnt_hier_resp_1_mail     ||')';end if;
       if grp.cnt_hier_resp_2_nom          < 2 then oGeav.hier_resp_2_nom           :=grp.hier_resp_2_nom           ; else oGeav.hier_resp_2_nom           :='Plusieurs (' ||grp.cnt_hier_resp_2_nom      ||')';end if;
       if grp.cnt_hier_resp_2_mail         < 2 then oGeav.hier_resp_2_mail          :=grp.hier_resp_2_mail          ; else oGeav.hier_resp_2_mail          :='Plusieurs (' ||grp.cnt_hier_resp_2_mail     ||')';end if;
       if grp.cnt_rib_mode_paie            < 2 then oGeav.rib_mode_paie             :=grp.rib_mode_paie             ; else oGeav.rib_mode_paie             :='Plusieurs (' ||grp.cnt_rib_mode_paie        ||')';end if;
       if grp.cnt_rib_banq_1               < 2 then oGeav.rib_banq_1                :=grp.rib_banq_1                ; else oGeav.rib_banq_1                :='Plusieurs (' ||grp.cnt_rib_banq_1           ||')';if vAFFI_DERN_VALE = 'O' then begin select e.rib_banq_1      into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.rib_banq_1      :=oGeav.rib_banq_1      || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_rib_guic_1               < 2 then oGeav.rib_guic_1                :=grp.rib_guic_1                ; else oGeav.rib_guic_1                :='Plusieurs (' ||grp.cnt_rib_guic_1           ||')';if vAFFI_DERN_VALE = 'O' then begin select e.rib_guic_1      into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.rib_guic_1      :=oGeav.rib_guic_1      || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_rib_comp_1               < 2 then oGeav.rib_comp_1                :=grp.rib_comp_1                ; else oGeav.rib_comp_1                :='Plusieurs (' ||grp.cnt_rib_comp_1           ||')';if vAFFI_DERN_VALE = 'O' then begin select e.rib_comp_1      into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.rib_comp_1      :=oGeav.rib_comp_1      || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_rib_cle_1                < 2 then oGeav.rib_cle_1                 :=grp.rib_cle_1                 ; else oGeav.rib_cle_1                 :='Plusieurs (' ||grp.cnt_rib_cle_1            ||')';if vAFFI_DERN_VALE = 'O' then begin select e.rib_cle_1       into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.rib_cle_1       :=oGeav.rib_cle_1       || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_rib_banq_01              < 2 then oGeav.rib_banq_01               :=grp.rib_banq_01               ; else oGeav.rib_banq_01               :='Plusieurs (' ||grp.cnt_rib_banq_01          ||')';if vAFFI_DERN_VALE = 'O' then begin select e.rib_banq_01     into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.rib_banq_01     :=oGeav.rib_banq_01     || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_rib_banq_02              < 2 then oGeav.rib_banq_02               :=grp.rib_banq_02               ; else oGeav.rib_banq_02               :='Plusieurs (' ||grp.cnt_rib_banq_02          ||')';if vAFFI_DERN_VALE = 'O' then begin select e.rib_banq_02     into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.rib_banq_02     :=oGeav.rib_banq_02     || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_rib_domi_1               < 2 then oGeav.rib_domi_1                :=grp.rib_domi_1                ; else oGeav.rib_domi_1                :='Plusieurs (' ||grp.cnt_rib_domi_1           ||')';if vAFFI_DERN_VALE = 'O' then begin select e.rib_domi_1      into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.rib_domi_1      :=oGeav.rib_domi_1      || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_rib_nume_1               < 2 then oGeav.rib_nume_1                :=grp.rib_nume_1                ; else oGeav.rib_nume_1                :='Plusieurs (' ||grp.cnt_rib_nume_1           ||')';if vAFFI_DERN_VALE = 'O' then begin select e.rib_nume_1      into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.rib_nume_1      :=oGeav.rib_nume_1      || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_rib_titu_comp_1          < 2 then oGeav.rib_titu_comp_1           :=grp.rib_titu_comp_1           ; else oGeav.rib_titu_comp_1           :='Plusieurs (' ||grp.cnt_rib_titu_comp_1      ||')';if vAFFI_DERN_VALE = 'O' then begin select e.rib_titu_comp_1 into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.rib_titu_comp_1 :=oGeav.rib_titu_comp_1 || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_rib_banq_2               < 2 then oGeav.rib_banq_2                :=grp.rib_banq_2                ; else oGeav.rib_banq_2                :='Plusieurs (' ||grp.cnt_rib_banq_2           ||')';end if;
       if grp.cnt_rib_domi_2               < 2 then oGeav.rib_domi_2                :=grp.rib_domi_2                ; else oGeav.rib_domi_2                :='Plusieurs (' ||grp.cnt_rib_domi_2           ||')';end if;
       if grp.cnt_rib_nume_2               < 2 then oGeav.rib_nume_2                :=grp.rib_nume_2                ; else oGeav.rib_nume_2                :='Plusieurs (' ||grp.cnt_rib_nume_2           ||')';end if;
       if grp.cnt_rib_titu_comp_2          < 2 then oGeav.rib_titu_comp_2           :=grp.rib_titu_comp_2           ; else oGeav.rib_titu_comp_2           :='Plusieurs (' ||grp.cnt_rib_titu_comp_2      ||')';end if;
       if grp.cnt_tele_1                   < 2 then oGeav.tele_1                    :=grp.tele_1                    ; else oGeav.tele_1                    :='Plusieurs (' ||grp.cnt_tele_1               ||')';end if;
       if grp.cnt_tele_2                   < 2 then oGeav.tele_2                    :=grp.tele_2                    ; else oGeav.tele_2                    :='Plusieurs (' ||grp.cnt_tele_2               ||')';end if;
       if grp.cnt_tele_3                   < 2 then oGeav.tele_3                    :=grp.tele_3                    ; else oGeav.tele_3                    :='Plusieurs (' ||grp.cnt_tele_3               ||')';end if;
       if grp.cnt_adre                     < 2 then oGeav.adre                      :=grp.adre                      ; else oGeav.adre                      :='Plusieurs (' ||grp.cnt_adre                 ||')';if vAFFI_DERN_VALE = 'O' then begin select e.adre into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.adre :=oGeav.adre || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_adre_comp                < 2 then oGeav.adre_comp                 :=grp.adre_comp                 ; else oGeav.adre_comp                 :='Plusieurs (' ||grp.cnt_adre_comp            ||')';if vAFFI_DERN_VALE = 'O' then begin select e.adre_comp into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.adre_comp :=oGeav.adre_comp || ' [' || vVALE_DERN_PERI || '] ' ; end if; end if;
       if grp.cnt_adre_comm                < 2 then oGeav.adre_comm                 :=grp.adre_comm                 ; else oGeav.adre_comm                 :='Plusieurs (' ||grp.cnt_adre_comm            ||')';if vAFFI_DERN_VALE = 'O' then begin select e.adre_comm into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.adre_comm :=oGeav.adre_comm || ' [' || vVALE_DERN_PERI || '] '; end if; end if;
       if grp.cnt_adre_code_post           < 2 then oGeav.adre_code_post            :=grp.adre_code_post            ; else oGeav.adre_code_post            :='Plusieurs (' ||grp.cnt_adre_code_post       ||')';if vAFFI_DERN_VALE = 'O' then begin select e.adre_code_post into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.adre_code_post :=oGeav.adre_code_post || ' [ ' || vVALE_DERN_PERI || ' ] '; end if; end if;
       if grp.cnt_adre_pays                < 2 then oGeav.adre_pays                 :=grp.adre_pays                 ; else oGeav.adre_pays                 :='Plusieurs (' ||grp.cnt_adre_pays            ||')';if vAFFI_DERN_VALE = 'O' then begin select e.adre_pays into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; exception when NO_DATA_FOUND then vVALE_DERN_PERI:=''; end; oGeav.adre_pays :=oGeav.adre_pays || ' [' || vVALE_DERN_PERI || '] '  ; end if; end if;
       if grp.cnt_ccn51_anci_date_chan_appl< 2 then oGeav.ccn51_anci_date_chan_appl :=grp.ccn51_anci_date_chan_appl ; else oGeav.ccn51_anci_date_chan_appl :='Plusieures ('||grp.cnt_ccn51_anci_date_chan_appl||')';end if;
       if grp.cnt_ccn51_anci_taux          < 2 then oGeav.ccn51_anci_taux           :=grp.ccn51_anci_taux           ; else oGeav.ccn51_anci_taux           :='Plusieurs (' ||grp.cnt_ccn51_anci_taux          ||')';end if;
       if grp.cnt_ccn51_cadr_date_chan_appl< 2 then oGeav.ccn51_cadr_date_chan_appl :=grp.ccn51_cadr_date_chan_appl ; else oGeav.ccn51_cadr_date_chan_appl :='Plusieures ('||grp.cnt_ccn51_cadr_date_chan_appl||')';end if;
       if grp.cnt_ccn51_cadr_taux          < 2 then oGeav.ccn51_cadr_taux           :=grp.ccn51_cadr_taux           ; else oGeav.ccn51_cadr_taux           :='Plusieurs (' ||grp.cnt_ccn51_cadr_taux          ||')';end if;
       if grp.cnt_etp_ccn51                < 2 then oGeav.etp_ccn51                 :=grp.etp_ccn51                 ; else oGeav.etp_ccn51                 :='Plusieurs (' ||grp.cnt_etp_ccn51                ||')';end if;
       if grp.cnt_ccn51_coef_acca          < 2 then oGeav.ccn51_coef_acca           :=grp.ccn51_coef_acca           ; else oGeav.ccn51_coef_acca           :='Plusieurs (' ||grp.cnt_ccn51_coef_acca          ||')';end if;
       if grp.cnt_ccn51_coef_dipl          < 2 then oGeav.ccn51_coef_dipl           :=grp.ccn51_coef_dipl           ; else oGeav.ccn51_coef_dipl           :='Plusieurs (' ||grp.cnt_ccn51_coef_dipl          ||')';end if;
       if grp.cnt_ccn51_coef_enca          < 2 then oGeav.ccn51_coef_enca           :=grp.ccn51_coef_enca           ; else oGeav.ccn51_coef_enca           :='Plusieurs (' ||grp.cnt_ccn51_coef_enca          ||')';end if;
       if grp.cnt_ccn51_coef_fonc          < 2 then oGeav.ccn51_coef_fonc           :=grp.ccn51_coef_fonc           ; else oGeav.ccn51_coef_fonc           :='Plusieurs (' ||grp.cnt_ccn51_coef_fonc          ||')';end if;
       if grp.cnt_ccn51_coef_meti          < 2 then oGeav.ccn51_coef_meti           :=grp.ccn51_coef_meti           ; else oGeav.ccn51_coef_meti           :='Plusieurs (' ||grp.cnt_ccn51_coef_meti          ||')';end if;
       if grp.cnt_ccn51_coef_recl          < 2 then oGeav.ccn51_coef_recl           :=grp.ccn51_coef_recl           ; else oGeav.ccn51_coef_recl           :='Plusieurs (' ||grp.cnt_ccn51_coef_recl          ||')';end if;
       if grp.cnt_ccn51_coef_spec          < 2 then oGeav.ccn51_coef_spec           :=grp.ccn51_coef_spec           ; else oGeav.ccn51_coef_spec           :='Plusieurs (' ||grp.cnt_ccn51_coef_spec          ||')';end if;
       if grp.cnt_ccn51_id_empl_conv       < 2 then oGeav.ccn51_id_empl_conv        :=grp.ccn51_id_empl_conv        ; else oGeav.ccn51_id_empl_conv        :='Plusieurs (' ||grp.cnt_ccn51_id_empl_conv       ||')';end if;
       if grp.cnt_ccn5166_coef_refe        < 2 then oGeav.ccn5166_coef_refe         :=grp.ccn5166_coef_refe         ; else oGeav.ccn5166_coef_refe         :='Plusieurs (' ||grp.cnt_ccn5166_coef_refe        ||')';end if;
       if grp.cnt_ccn66_cate_conv          < 2 then oGeav.ccn66_cate_conv           :=grp.ccn66_cate_conv           ; else oGeav.ccn66_cate_conv           :='Plusieurs (' ||grp.cnt_ccn66_cate_conv          ||')';end if;
       if grp.cnt_ccn66_date_chan_coef     < 2 then oGeav.ccn66_date_chan_coef      :=grp.ccn66_date_chan_coef      ; else oGeav.ccn66_date_chan_coef      :='Plusieures ('||grp.cnt_ccn66_date_chan_coef     ||')';end if;
       if grp.cnt_ccn66_empl_conv          < 2 then oGeav.ccn66_empl_conv           :=grp.ccn66_empl_conv           ; else oGeav.ccn66_empl_conv           :='Plusieurs (' ||grp.cnt_ccn66_empl_conv          ||')';end if;
       if grp.cnt_ccn66_libe_empl_conv     < 2 then oGeav.ccn66_libe_empl_conv      :=grp.ccn66_libe_empl_conv      ; else oGeav.ccn66_libe_empl_conv      :='Plusieurs (' ||grp.cnt_ccn66_libe_empl_conv     ||')';end if;
       if grp.cnt_ccn66_fili_conv          < 2 then oGeav.ccn66_fili_conv           :=grp.ccn66_fili_conv           ; else oGeav.ccn66_fili_conv           :='Plusieurs (' ||grp.cnt_ccn66_fili_conv          ||')';end if;
       if grp.cnt_ccn66_prec_date_chan_coef< 2 then oGeav.ccn66_prec_date_chan_coef :=grp.ccn66_prec_date_chan_coef ; else oGeav.ccn66_prec_date_chan_coef :='Plusieures ('||grp.cnt_ccn66_prec_date_chan_coef||')';end if;
       if grp.cnt_ccn66_proc_coef_refe     < 2 then oGeav.ccn66_proc_coef_refe      :=grp.ccn66_proc_coef_refe      ; else oGeav.ccn66_proc_coef_refe      :='Plusieures ('||grp.cnt_ccn66_proc_coef_refe     ||')';end if;
       if grp.cnt_ccn66_regi               < 2 then oGeav.ccn66_regi                :=grp.ccn66_regi                ; else oGeav.ccn66_regi                :='Plusieurs (' ||grp.cnt_ccn66_regi               ||')';end if;
       if grp.cnt_code_regi                < 2 then oGeav.code_regi                 :=grp.code_regi                 ; else oGeav.code_regi                 :='Plusieurs (' ||grp.cnt_code_regi                ||')';end if;
       if grp.cnt_libe_regi                < 2 then oGeav.libe_regi                 :=grp.libe_regi                 ; else oGeav.libe_regi                 :='Plusieurs (' ||grp.cnt_libe_regi                ||')';end if;
       if grp.cnt_orga                     < 2 then oGeav.orga                      :=grp.orga                      ; else oGeav.orga                      :='Plusieurs (' ||grp.cnt_orga                     ||')';end if;
       if grp.cnt_unit                     < 2 then oGeav.unit                      :=grp.unit                      ; else oGeav.unit                      :='Plusieurs (' ||grp.cnt_unit                     ||')';end if;
       if grp.cnt_nume_fine                < 2 then oGeav.nume_fine                 :=grp.nume_fine                 ; else oGeav.nume_fine                 :='Plusieurs (' ||grp.cnt_nume_fine                ||')';end if;
       if grp.cnt_nume_adel                < 2 then oGeav.nume_adel                 :=grp.nume_adel                 ; else oGeav.nume_adel                 :='Plusieurs (' ||grp.cnt_nume_adel                ||')';end if;
       if grp.cnt_nume_rpps                < 2 then oGeav.nume_rpps                 :=grp.nume_rpps                 ; else oGeav.nume_rpps                 :='Plusieurs (' ||grp.cnt_nume_rpps                ||')';end if;
       if grp.cnt_adre_elec                < 2 then oGeav.adre_elec                 :=grp.adre_elec                 ; else oGeav.adre_elec                 :='Plusieurs (' ||grp.cnt_adre_elec                ||')';end if;
       if grp.cnt_code_titr_form           < 2 then oGeav.code_titr_form            :=grp.code_titr_form            ; else oGeav.code_titr_form            :='Plusieurs (' ||grp.cnt_code_titr_form           ||')';end if;
       if grp.cnt_libe_titr_form           < 2 then oGeav.libe_titr_form            :=grp.libe_titr_form            ; else oGeav.libe_titr_form            :='Plusieurs (' ||grp.cnt_libe_titr_form           ||')';end if;
       if grp.cnt_date_titr_form           < 2 then oGeav.date_titr_form            :=grp.date_titr_form            ; else oGeav.date_titr_form            :='Plusieurs (' ||grp.cnt_date_titr_form           ||')';end if;
       if grp.cnt_lieu_titr_form           < 2 then oGeav.lieu_titr_form            :=grp.lieu_titr_form            ; else oGeav.lieu_titr_form            :='Plusieurs (' ||grp.cnt_lieu_titr_form           ||')';end if;
       if grp.cnt_cham_util_1              < 2 then oGeav.cham_util_1               :=grp.cham_util_1               ; else oGeav.cham_util_1               :='Plusieurs (' ||grp.cnt_cham_util_1              ||')';end if;
       if grp.cnt_cham_util_2              < 2 then oGeav.cham_util_2               :=grp.cham_util_2               ; else oGeav.cham_util_2               :='Plusieurs (' ||grp.cnt_cham_util_2              ||')';end if;
       if grp.cnt_cham_util_3              < 2 then oGeav.cham_util_3               :=grp.cham_util_3               ; else oGeav.cham_util_3               :='Plusieurs (' ||grp.cnt_cham_util_3              ||')';end if;
       if grp.cnt_cham_util_4              < 2 then oGeav.cham_util_4               :=grp.cham_util_4               ; else oGeav.cham_util_4               :='Plusieurs (' ||grp.cnt_cham_util_4              ||')';end if;
       if grp.cnt_cham_util_5              < 2 then oGeav.cham_util_5               :=grp.cham_util_5               ; else oGeav.cham_util_5               :='Plusieurs (' ||grp.cnt_cham_util_5              ||')';end if;
       if grp.cnt_cham_util_6              < 2 then oGeav.cham_util_6               :=grp.cham_util_6               ; else oGeav.cham_util_6               :='Plusieurs (' ||grp.cnt_cham_util_6              ||')';end if;
       if grp.cnt_cham_util_7              < 2 then oGeav.cham_util_7               :=grp.cham_util_7               ; else oGeav.cham_util_7               :='Plusieurs (' ||grp.cnt_cham_util_7              ||')';end if;
       if grp.cnt_cham_util_8              < 2 then oGeav.cham_util_8               :=grp.cham_util_8               ; else oGeav.cham_util_8               :='Plusieurs (' ||grp.cnt_cham_util_8              ||')';end if;
       if grp.cnt_cham_util_9              < 2 then oGeav.cham_util_9               :=grp.cham_util_9               ; else oGeav.cham_util_9               :='Plusieurs (' ||grp.cnt_cham_util_9              ||')';end if;
       if grp.cnt_cham_util_10             < 2 then oGeav.cham_util_10              :=grp.cham_util_10              ; else oGeav.cham_util_10              :='Plusieurs (' ||grp.cnt_cham_util_10             ||')';end if;
       if grp.cnt_cham_util_11             < 2 then oGeav.cham_util_11              :=grp.cham_util_11              ; else oGeav.cham_util_11              :='Plusieurs (' ||grp.cnt_cham_util_11             ||')';end if;
       if grp.cnt_cham_util_12             < 2 then oGeav.cham_util_12              :=grp.cham_util_12              ; else oGeav.cham_util_12              :='Plusieurs (' ||grp.cnt_cham_util_12             ||')';end if;
       if grp.cnt_cham_util_13             < 2 then oGeav.cham_util_13              :=grp.cham_util_13              ; else oGeav.cham_util_13              :='Plusieurs (' ||grp.cnt_cham_util_13             ||')';end if;
       if grp.cnt_cham_util_14             < 2 then oGeav.cham_util_14              :=grp.cham_util_14              ; else oGeav.cham_util_14              :='Plusieurs (' ||grp.cnt_cham_util_14             ||')';end if;
       if grp.cnt_cham_util_15             < 2 then oGeav.cham_util_15              :=grp.cham_util_15              ; else oGeav.cham_util_15              :='Plusieurs (' ||grp.cnt_cham_util_15             ||')';end if;
       if grp.cnt_cham_util_16             < 2 then oGeav.cham_util_16              :=grp.cham_util_16              ; else oGeav.cham_util_16              :='Plusieurs (' ||grp.cnt_cham_util_16             ||')';end if;
       if grp.cnt_cham_util_17             < 2 then oGeav.cham_util_17              :=grp.cham_util_17              ; else oGeav.cham_util_17              :='Plusieurs (' ||grp.cnt_cham_util_17             ||')';end if;
       if grp.cnt_cham_util_18             < 2 then oGeav.cham_util_18              :=grp.cham_util_18              ; else oGeav.cham_util_18              :='Plusieurs (' ||grp.cnt_cham_util_18             ||')';end if;
       if grp.cnt_cham_util_19             < 2 then oGeav.cham_util_19              :=grp.cham_util_19              ; else oGeav.cham_util_19              :='Plusieurs (' ||grp.cnt_cham_util_19             ||')';end if;
       if grp.cnt_cham_util_20             < 2 then oGeav.cham_util_20              :=grp.cham_util_20              ; else oGeav.cham_util_20              :='Plusieurs (' ||grp.cnt_cham_util_20             ||')';end if;
       if grp.cnt_cham_util_21             < 2 then oGeav.cham_util_21              :=grp.cham_util_21              ; else oGeav.cham_util_21              :='Plusieurs (' ||grp.cnt_cham_util_21             ||')';end if;
       if grp.cnt_cham_util_22             < 2 then oGeav.cham_util_22              :=grp.cham_util_22              ; else oGeav.cham_util_22              :='Plusieurs (' ||grp.cnt_cham_util_22             ||')';end if;
       if grp.cnt_cham_util_23             < 2 then oGeav.cham_util_23              :=grp.cham_util_23              ; else oGeav.cham_util_23              :='Plusieurs (' ||grp.cnt_cham_util_23             ||')';end if;
       if grp.cnt_cham_util_24             < 2 then oGeav.cham_util_24              :=grp.cham_util_24              ; else oGeav.cham_util_24              :='Plusieurs (' ||grp.cnt_cham_util_24             ||')';end if;
       if grp.cnt_cham_util_25             < 2 then oGeav.cham_util_25              :=grp.cham_util_25              ; else oGeav.cham_util_25              :='Plusieurs (' ||grp.cnt_cham_util_25             ||')';end if;
       if grp.cnt_cham_util_26             < 2 then oGeav.cham_util_26              :=grp.cham_util_26              ; else oGeav.cham_util_26              :='Plusieurs (' ||grp.cnt_cham_util_26             ||')';end if;
       if grp.cnt_cham_util_27             < 2 then oGeav.cham_util_27              :=grp.cham_util_27              ; else oGeav.cham_util_27              :='Plusieurs (' ||grp.cnt_cham_util_27             ||')';end if;
       if grp.cnt_cham_util_28             < 2 then oGeav.cham_util_28              :=grp.cham_util_28              ; else oGeav.cham_util_28              :='Plusieurs (' ||grp.cnt_cham_util_28             ||')';end if;
       if grp.cnt_cham_util_29             < 2 then oGeav.cham_util_29              :=grp.cham_util_29              ; else oGeav.cham_util_29              :='Plusieurs (' ||grp.cnt_cham_util_29             ||')';end if;
       if grp.cnt_cham_util_30             < 2 then oGeav.cham_util_30              :=grp.cham_util_30              ; else oGeav.cham_util_30              :='Plusieurs (' ||grp.cnt_cham_util_30             ||')';end if;
       if grp.cnt_cham_util_31             < 2 then oGeav.cham_util_31              :=grp.cham_util_31              ; else oGeav.cham_util_31              :='Plusieurs (' ||grp.cnt_cham_util_31             ||')';end if;
       if grp.cnt_cham_util_32             < 2 then oGeav.cham_util_32              :=grp.cham_util_32              ; else oGeav.cham_util_32              :='Plusieurs (' ||grp.cnt_cham_util_32             ||')';end if;
       if grp.cnt_cham_util_33             < 2 then oGeav.cham_util_33              :=grp.cham_util_33              ; else oGeav.cham_util_33              :='Plusieurs (' ||grp.cnt_cham_util_33             ||')';end if;
       if grp.cnt_cham_util_34             < 2 then oGeav.cham_util_34              :=grp.cham_util_34              ; else oGeav.cham_util_34              :='Plusieurs (' ||grp.cnt_cham_util_34             ||')';end if;
       if grp.cnt_cham_util_35             < 2 then oGeav.cham_util_35              :=grp.cham_util_35              ; else oGeav.cham_util_35              :='Plusieurs (' ||grp.cnt_cham_util_35             ||')';end if;
       if grp.cnt_cham_util_36             < 2 then oGeav.cham_util_36              :=grp.cham_util_36              ; else oGeav.cham_util_36              :='Plusieurs (' ||grp.cnt_cham_util_36             ||')';end if;
       if grp.cnt_cham_util_37             < 2 then oGeav.cham_util_37              :=grp.cham_util_37              ; else oGeav.cham_util_37              :='Plusieurs (' ||grp.cnt_cham_util_37             ||')';end if;
       if grp.cnt_cham_util_38             < 2 then oGeav.cham_util_38              :=grp.cham_util_38              ; else oGeav.cham_util_38              :='Plusieurs (' ||grp.cnt_cham_util_38             ||')';end if;
       if grp.cnt_cham_util_39             < 2 then oGeav.cham_util_39              :=grp.cham_util_39              ; else oGeav.cham_util_39              :='Plusieurs (' ||grp.cnt_cham_util_39             ||')';end if;
       if grp.cnt_cham_util_40             < 2 then oGeav.cham_util_40              :=grp.cham_util_40              ; else oGeav.cham_util_40              :='Plusieurs (' ||grp.cnt_cham_util_40             ||')';end if;
       if grp.cnt_cham_util_41             < 2 then oGeav.cham_util_41              :=grp.cham_util_41              ; else oGeav.cham_util_41              :='Plusieurs (' ||grp.cnt_cham_util_41             ||')';end if;
       if grp.cnt_cham_util_42             < 2 then oGeav.cham_util_42              :=grp.cham_util_42              ; else oGeav.cham_util_42              :='Plusieurs (' ||grp.cnt_cham_util_42             ||')';end if;
       if grp.cnt_cham_util_43             < 2 then oGeav.cham_util_43              :=grp.cham_util_43              ; else oGeav.cham_util_43              :='Plusieurs (' ||grp.cnt_cham_util_43             ||')';end if;
       if grp.cnt_cham_util_44             < 2 then oGeav.cham_util_44              :=grp.cham_util_44              ; else oGeav.cham_util_44              :='Plusieurs (' ||grp.cnt_cham_util_44             ||')';end if;
       if grp.cnt_cham_util_45             < 2 then oGeav.cham_util_45              :=grp.cham_util_45              ; else oGeav.cham_util_45              :='Plusieurs (' ||grp.cnt_cham_util_45             ||')';end if;
       if grp.cnt_cham_util_46             < 2 then oGeav.cham_util_46              :=grp.cham_util_46              ; else oGeav.cham_util_46              :='Plusieurs (' ||grp.cnt_cham_util_46             ||')';end if;
       if grp.cnt_cham_util_47             < 2 then oGeav.cham_util_47              :=grp.cham_util_47              ; else oGeav.cham_util_47              :='Plusieurs (' ||grp.cnt_cham_util_47             ||')';end if;
       if grp.cnt_cham_util_48             < 2 then oGeav.cham_util_48              :=grp.cham_util_48              ; else oGeav.cham_util_48              :='Plusieurs (' ||grp.cnt_cham_util_48             ||')';end if;
       if grp.cnt_cham_util_49             < 2 then oGeav.cham_util_49              :=grp.cham_util_49              ; else oGeav.cham_util_49              :='Plusieurs (' ||grp.cnt_cham_util_49             ||')';end if;
       if grp.cnt_cham_util_50             < 2 then oGeav.cham_util_50              :=grp.cham_util_50              ; else oGeav.cham_util_50              :='Plusieurs (' ||grp.cnt_cham_util_50             ||')';end if;
       if grp.cnt_cham_util_51             < 2 then oGeav.cham_util_51              :=grp.cham_util_51              ; else oGeav.cham_util_51              :='Plusieurs (' ||grp.cnt_cham_util_51             ||')';end if;
       if grp.cnt_cham_util_52             < 2 then oGeav.cham_util_52              :=grp.cham_util_52              ; else oGeav.cham_util_52              :='Plusieurs (' ||grp.cnt_cham_util_52             ||')';end if;
       if grp.cnt_cham_util_53             < 2 then oGeav.cham_util_53              :=grp.cham_util_53              ; else oGeav.cham_util_53              :='Plusieurs (' ||grp.cnt_cham_util_53             ||')';end if;
       if grp.cnt_cham_util_54             < 2 then oGeav.cham_util_54              :=grp.cham_util_54              ; else oGeav.cham_util_54              :='Plusieurs (' ||grp.cnt_cham_util_54             ||')';end if;
       if grp.cnt_cham_util_55             < 2 then oGeav.cham_util_55              :=grp.cham_util_55              ; else oGeav.cham_util_55              :='Plusieurs (' ||grp.cnt_cham_util_55             ||')';end if;
       if grp.cnt_cham_util_56             < 2 then oGeav.cham_util_56              :=grp.cham_util_56              ; else oGeav.cham_util_56              :='Plusieurs (' ||grp.cnt_cham_util_56             ||')';end if;
       if grp.cnt_cham_util_57             < 2 then oGeav.cham_util_57              :=grp.cham_util_57              ; else oGeav.cham_util_57              :='Plusieurs (' ||grp.cnt_cham_util_57             ||')';end if;
       if grp.cnt_cham_util_58             < 2 then oGeav.cham_util_58              :=grp.cham_util_58              ; else oGeav.cham_util_58              :='Plusieurs (' ||grp.cnt_cham_util_58             ||')';end if;
       if grp.cnt_cham_util_59             < 2 then oGeav.cham_util_59              :=grp.cham_util_59              ; else oGeav.cham_util_59              :='Plusieurs (' ||grp.cnt_cham_util_59             ||')';end if;
       if grp.cnt_cham_util_60             < 2 then oGeav.cham_util_60              :=grp.cham_util_60              ; else oGeav.cham_util_60              :='Plusieurs (' ||grp.cnt_cham_util_60             ||')';end if;
       if grp.cnt_cham_util_61             < 2 then oGeav.cham_util_61              :=grp.cham_util_61              ; else oGeav.cham_util_61              :='Plusieurs (' ||grp.cnt_cham_util_61             ||')';end if;
       if grp.cnt_cham_util_62             < 2 then oGeav.cham_util_62              :=grp.cham_util_62              ; else oGeav.cham_util_62              :='Plusieurs (' ||grp.cnt_cham_util_62             ||')';end if;
       if grp.cnt_cham_util_63             < 2 then oGeav.cham_util_63              :=grp.cham_util_63              ; else oGeav.cham_util_63              :='Plusieurs (' ||grp.cnt_cham_util_63             ||')';end if;
       if grp.cnt_cham_util_64             < 2 then oGeav.cham_util_64              :=grp.cham_util_64              ; else oGeav.cham_util_64              :='Plusieurs (' ||grp.cnt_cham_util_64             ||')';end if;
       if grp.cnt_cham_util_65             < 2 then oGeav.cham_util_65              :=grp.cham_util_65              ; else oGeav.cham_util_65              :='Plusieurs (' ||grp.cnt_cham_util_65             ||')';end if;
       if grp.cnt_cham_util_66             < 2 then oGeav.cham_util_66              :=grp.cham_util_66              ; else oGeav.cham_util_66              :='Plusieurs (' ||grp.cnt_cham_util_66             ||')';end if;
       if grp.cnt_cham_util_67             < 2 then oGeav.cham_util_67              :=grp.cham_util_67              ; else oGeav.cham_util_67              :='Plusieurs (' ||grp.cnt_cham_util_67             ||')';end if;
       if grp.cnt_cham_util_68             < 2 then oGeav.cham_util_68              :=grp.cham_util_68              ; else oGeav.cham_util_68              :='Plusieurs (' ||grp.cnt_cham_util_68             ||')';end if;
       if grp.cnt_cham_util_69             < 2 then oGeav.cham_util_69              :=grp.cham_util_69              ; else oGeav.cham_util_69              :='Plusieurs (' ||grp.cnt_cham_util_69             ||')';end if;
       if grp.cnt_cham_util_70             < 2 then oGeav.cham_util_70              :=grp.cham_util_70              ; else oGeav.cham_util_70              :='Plusieurs (' ||grp.cnt_cham_util_70             ||')';end if;
       if grp.cnt_cham_util_71             < 2 then oGeav.cham_util_71              :=grp.cham_util_71              ; else oGeav.cham_util_71              :='Plusieurs (' ||grp.cnt_cham_util_71             ||')';end if;
       if grp.cnt_cham_util_72             < 2 then oGeav.cham_util_72              :=grp.cham_util_72              ; else oGeav.cham_util_72              :='Plusieurs (' ||grp.cnt_cham_util_72             ||')';end if;
       if grp.cnt_cham_util_73             < 2 then oGeav.cham_util_73              :=grp.cham_util_73              ; else oGeav.cham_util_73              :='Plusieurs (' ||grp.cnt_cham_util_73             ||')';end if;
       if grp.cnt_cham_util_74             < 2 then oGeav.cham_util_74              :=grp.cham_util_74              ; else oGeav.cham_util_74              :='Plusieurs (' ||grp.cnt_cham_util_74             ||')';end if;
       if grp.cnt_cham_util_75             < 2 then oGeav.cham_util_75              :=grp.cham_util_75              ; else oGeav.cham_util_75              :='Plusieurs (' ||grp.cnt_cham_util_75             ||')';end if;
       if grp.cnt_cham_util_76             < 2 then oGeav.cham_util_76              :=grp.cham_util_76              ; else oGeav.cham_util_76              :='Plusieurs (' ||grp.cnt_cham_util_76             ||')';end if;
       if grp.cnt_cham_util_77             < 2 then oGeav.cham_util_77              :=grp.cham_util_77              ; else oGeav.cham_util_77              :='Plusieurs (' ||grp.cnt_cham_util_77             ||')';end if;
       if grp.cnt_cham_util_78             < 2 then oGeav.cham_util_78              :=grp.cham_util_78              ; else oGeav.cham_util_78              :='Plusieurs (' ||grp.cnt_cham_util_78             ||')';end if;
       if grp.cnt_cham_util_79             < 2 then oGeav.cham_util_79              :=grp.cham_util_79              ; else oGeav.cham_util_79              :='Plusieurs (' ||grp.cnt_cham_util_79             ||')';end if;
       if grp.cnt_cham_util_80             < 2 then oGeav.cham_util_80              :=grp.cham_util_80              ; else oGeav.cham_util_80              :='Plusieurs (' ||grp.cnt_cham_util_80             ||')';end if;
       if grp.CNT_SALA_FORF_TEMP           < 2 then oGeav.sala_forf_temp            :=grp.sala_forf_temp            ; else oGeav.sala_forf_temp            :=''                                               ;end if;
       if grp.CNT_NOMB_JOUR_FORF_TEMP      < 2 then oGeav.nomb_jour_forf_temp       :=grp.nomb_jour_forf_temp       ; else oGeav.nomb_jour_forf_temp       :=''                                               ;end if;
       if grp.CNT_NOMB_HEUR_FORF_TEMP      < 2 then oGeav.nomb_heur_forf_temp       :=grp.nomb_heur_forf_temp       ; else oGeav.nomb_heur_forf_temp       :=''                                               ;end if;
       if grp.CNT_NOMB_MOIS                < 2 then oGeav.nomb_mois                 :=grp.nomb_mois                 ; else oGeav.nomb_mois                 :=''                                               ;end if;
       if grp.CNT_SALA_ANNU_CONT           < 2 then oGeav.sala_annu_cont            :=grp.sala_annu_cont            ; else oGeav.sala_annu_cont            :=''                                               ;end if;

       if grp.CNT_NOMB_JOUR_CONG_ANCI      < 2 then oGeav.nomb_jour_cong_anci       :=grp.nomb_jour_cong_anci        ; else oGeav.nomb_jour_cong_anci      :=''                                               ;end if;
       if grp.CNT_MONT_ANCI_PA             < 2 then oGeav.mont_anci_pa              :=grp.mont_anci_pa              ; else oGeav.mont_anci_pa              :=''                                               ;end if;
       if grp.CNT_ANCI_CADR                < 2 then oGeav.anci_cadr                 :=grp.anci_cadr                 ; else oGeav.anci_cadr                 :=''                                               ;end if;
       if grp.CNT_TOTA_HEUR_TRAV           < 2 then oGeav.tota_heur_trav            :=grp.tota_heur_trav            ; else oGeav.tota_heur_trav            :=''                                               ;end if;
       
      if grp.cnt_DPAE_ENVO                < 2 then oGeav.DPAE_ENVO                  :=grp.DPAE_ENVO                        ; else oGeav.DPAE_ENVO                        :=''                                 ;end if;       
      if grp.cnt_DISP_POLI_PUBL_CONV      < 2 then oGeav.DISP_POLI_PUBL_CONV        :=grp.DISP_POLI_PUBL_CONV              ; else oGeav.DISP_POLI_PUBL_CONV              :=''                                 ;end if;
      if grp.cnt_DATE_ANCI_CADR_FORF      < 2 then oGeav.DATE_ANCI_CADR_FORF        :=grp.DATE_ANCI_CADR_FORF              ; else oGeav.DATE_ANCI_CADR_FORF              :='Plusieurs (' ||grp.cnt_DATE_ANCI_CADR_FORF       ||')';end if;
   
   
	     if grp.cnt_adre < 2 then
	     	oGeav.dern_adre :=grp.adre;
	     else
	     	begin
	     	  select e.adre into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1;
	     	exception
	     	when no_data_found then
	     		vVALE_DERN_PERI := '';
	     	end;
	     	oGeav.dern_adre        :=vVALE_DERN_PERI ;
	     end if;

	     if grp.cnt_adre_comp < 2 then
	     	oGeav.dern_adre_comp :=grp.adre_comp;
	     else
	     	begin
	     	  select e.adre_comp into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1;
	     	exception
	     	when no_data_found then
	     		vVALE_DERN_PERI := '';
	     	end;
	     	oGeav.dern_adre_comp        :=vVALE_DERN_PERI ;
	     end if;

	     if grp.cnt_adre_comm < 2 then
	     	oGeav.dern_adre_comm :=grp.adre_comm;
	     else
	     	begin
	     	  select e.adre_comm into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1;
	     	exception
	     	when no_data_found then
	     		vVALE_DERN_PERI := '';
	     	end;
	     	oGeav.dern_adre_comm        :=vVALE_DERN_PERI ;
	     end if;

	     if grp.cnt_adre_code_post < 2 then
	     	oGeav.dern_adre_code_post :=grp.adre_code_post;
	     else
	     	begin
	     	  select e.adre_code_post into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1;
	     	exception
	     	when no_data_found then
	     		vVALE_DERN_PERI := '';
	     	end;
	     	oGeav.dern_adre_code_post        :=vVALE_DERN_PERI ;
	     end if;

	     if iID_SOCI = 2576 then
	       if grp.cnt_cham_util_1 < 2 then
	       	oGeav.dern_sala_base_annu :=grp.cham_util_1;
	       else
	       	select e.cham_util_1 into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1;
	       	oGeav.dern_sala_base_annu        :=vVALE_DERN_PERI ;
	       end if;
	     end if;

       oGeav.comm_vent_n      :=grp.comm_vent_n ;
       oGeav.comm_vent_n1     :=grp.comm_vent_n1;
       oGeav.prim_obje_n      :=grp.prim_obje_n ;
       oGeav.prim_obje_n1     :=grp.prim_obje_n1;
       if vAFFI_DERN_VALE = 'O' then
         begin
           select nvl(e.prim_obje_soci_n, 0) into vVALE_DERN_PERI  from pers_edit_gestion_avancee e,liste_gestion_avancee l  where e.id_soci=iID_SOCI  and e.id_logi=iID_LOGI  and e.id_para=vID_PARA and e.id_list=vID_LIST and l.id_list=e.id_list and e.lign=1 and peri = vDERN_PERI_AFFI and e.id_sala = grp.id_sala and rownum = 1; oGeav.prim_obje_soci_n := nvl(vVALE_DERN_PERI, 0);
         exception
         when NO_DATA_FOUND then
           vVALE_DERN_PERI := 0;
         end;
       else
         oGeav.prim_obje_soci_n := nvl(grp.prim_obje_soci_n, 0) ;
       end if;

       oGeav.prim_obje_soci_n1:=grp.prim_obje_soci_n1;
       oGeav.prim_obje_glob_n :=grp.prim_obje_glob_n ;
       -- vérfication si on prends le cumul ou pas
       oGeav.cons_01:=grp.cons_01;
       if grp.code_cons_01 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_01;if vCUMU = 'N' then oGeav.cons_01 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_01);end if;
       if grp.code_cons_01 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_01);end if;
       if grp.code_cons_01 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_01);end if;end if;
       oGeav.cons_02:=grp.cons_02;
       if grp.code_cons_02 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_02;if vCUMU = 'N' then oGeav.cons_02 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_02);end if;
       if grp.code_cons_02 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_02);end if;
       if grp.code_cons_02 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_02);end if;end if;
       oGeav.cons_03:=grp.cons_03;
       if grp.code_cons_03 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_03;if vCUMU = 'N' then oGeav.cons_03 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_03);end if;
       if grp.code_cons_03 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_03);end if;
       if grp.code_cons_03 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_03);end if;end if;
       oGeav.cons_04:=grp.cons_04;
       if grp.code_cons_04 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_04;if vCUMU = 'N' then oGeav.cons_04 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_04);end if;
       if grp.code_cons_04 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_04);end if;
       if grp.code_cons_04 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_04);end if;end if;
       oGeav.cons_05:=grp.cons_05;
       if grp.code_cons_05 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_05;if vCUMU = 'N' then oGeav.cons_05 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_05);end if;
       if grp.code_cons_05 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_05);end if;
       if grp.code_cons_05 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_05);end if;end if;
       oGeav.cons_06:=grp.cons_06;
       if grp.code_cons_06 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_06;if vCUMU = 'N' then oGeav.cons_06 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_06);end if;
       if grp.code_cons_06 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_06);end if;
       if grp.code_cons_06 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_06);end if;end if;
       oGeav.cons_07:=grp.cons_07;
       if grp.code_cons_07 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_07;if vCUMU = 'N' then oGeav.cons_07 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_07);end if;
       if grp.code_cons_07 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_07);end if;
       if grp.code_cons_07 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_07);end if;end if;
       oGeav.cons_08:=grp.cons_08;
       if grp.code_cons_08 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_08;if vCUMU = 'N' then oGeav.cons_08 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_08);end if;
       if grp.code_cons_08 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_08);end if;
       if grp.code_cons_08 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_08);end if;end if;
       oGeav.cons_09:=grp.cons_09;
       if grp.code_cons_09 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_09;if vCUMU = 'N' then oGeav.cons_09 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_09);end if;
       if grp.code_cons_09 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_09);end if;
       if grp.code_cons_09 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_09);end if;end if;
       oGeav.cons_10:=grp.cons_10;
       if grp.code_cons_10 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_10;if vCUMU = 'N' then oGeav.cons_10 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_10);end if;
       if grp.code_cons_10 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_10);end if;
       if grp.code_cons_10 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_10);end if;end if;
       oGeav.cons_11:=grp.cons_11;
       if grp.code_cons_11 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_11;if vCUMU = 'N' then oGeav.cons_11 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_11);end if;
       if grp.code_cons_11 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_11);end if;
       if grp.code_cons_11 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_11);end if;end if;
       oGeav.cons_12:=grp.cons_12;
       if grp.code_cons_12 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_12;if vCUMU = 'N' then oGeav.cons_12 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_12);end if;
       if grp.code_cons_12 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_12);end if;
       if grp.code_cons_12 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_12);end if;end if;
       oGeav.cons_13:=grp.cons_13;
       if grp.code_cons_13 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_13;if vCUMU = 'N' then oGeav.cons_13 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_13);end if;
       if grp.code_cons_13 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_13);end if;
       if grp.code_cons_13 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_13);end if;end if;
       oGeav.cons_14:=grp.cons_14;
       if grp.code_cons_14 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_14;if vCUMU = 'N' then oGeav.cons_14 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_14);end if;
       if grp.code_cons_14 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_14);end if;
       if grp.code_cons_14 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_14);end if;end if;
       oGeav.cons_15:=grp.cons_15;
       if grp.code_cons_15 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_15;if vCUMU = 'N' then oGeav.cons_15 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_15);end if;
       if grp.code_cons_15 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_15);end if;
       if grp.code_cons_15 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_15);end if;end if;
       oGeav.cons_16:=grp.cons_16;
       if grp.code_cons_16 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_16;if vCUMU = 'N' then oGeav.cons_16 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_16);end if;
       if grp.code_cons_16 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_16);end if;
       if grp.code_cons_16 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_16);end if;end if;
       oGeav.cons_17:=grp.cons_17;
       if grp.code_cons_17 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_17;if vCUMU = 'N' then oGeav.cons_17 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_17);end if;
       if grp.code_cons_17 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_17);end if;
       if grp.code_cons_17 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_17);end if;end if;
       oGeav.cons_18:=grp.cons_18;
       if grp.code_cons_18 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_18;if vCUMU = 'N' then oGeav.cons_18 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_18);end if;
       if grp.code_cons_18 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_18);end if;
       if grp.code_cons_18 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_18);end if;end if;
       oGeav.cons_19:=grp.cons_19;
       if grp.code_cons_19 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_19;if vCUMU = 'N' then oGeav.cons_19 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_19);end if;
       if grp.code_cons_19 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_19);end if;
       if grp.code_cons_19 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_19);end if;end if;
       oGeav.cons_20:=grp.cons_20;
       if grp.code_cons_20 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_20;if vCUMU = 'N' then oGeav.cons_20 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_20);end if;
       if grp.code_cons_20 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_20);end if;
       if grp.code_cons_20 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_20);end if;end if;

       oGeav.cons_21:=grp.cons_21;
       if grp.code_cons_21 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_21;if vCUMU = 'N' then oGeav.cons_21 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_21);end if;
       if grp.code_cons_21 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_21);end if;
       if grp.code_cons_21 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_21);end if;end if;
       oGeav.cons_22:=grp.cons_22;
       if grp.code_cons_22 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_22;if vCUMU = 'N' then oGeav.cons_22 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_22);end if;
       if grp.code_cons_22 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_22);end if;
       if grp.code_cons_22 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_22);end if;end if;
       oGeav.cons_23:=grp.cons_23;
       if grp.code_cons_23 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_23;if vCUMU = 'N' then oGeav.cons_23 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_23);end if;
       if grp.code_cons_23 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_23);end if;
       if grp.code_cons_23 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_23);end if;end if;
       oGeav.cons_24:=grp.cons_24;
       if grp.code_cons_24 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_24;if vCUMU = 'N' then oGeav.cons_24 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_24);end if;
       if grp.code_cons_24 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_24);end if;
       if grp.code_cons_24 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_24);end if;end if;
       oGeav.cons_25:=grp.cons_25;
       if grp.code_cons_25 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_25;if vCUMU = 'N' then oGeav.cons_25 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_25);end if;
       if grp.code_cons_25 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_25);end if;
       if grp.code_cons_25 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_25);end if;end if;
       oGeav.cons_26:=grp.cons_26;
       if grp.code_cons_26 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_26;if vCUMU = 'N' then oGeav.cons_26 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_26);end if;
       if grp.code_cons_26 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_26);end if;
       if grp.code_cons_26 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_26);end if;end if;
       oGeav.cons_27:=grp.cons_27;
       if grp.code_cons_27 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_27;if vCUMU = 'N' then oGeav.cons_27 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_27);end if;
       if grp.code_cons_27 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_27);end if;
       if grp.code_cons_27 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_27);end if;end if;
       oGeav.cons_28:=grp.cons_28;
       if grp.code_cons_28 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_28;if vCUMU = 'N' then oGeav.cons_28 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_28);end if;
       if grp.code_cons_28 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_28);end if;
       if grp.code_cons_28 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_28);end if;end if;
       oGeav.cons_29:=grp.cons_29;
       if grp.code_cons_29 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_29;if vCUMU = 'N' then oGeav.cons_29 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_29);end if;
       if grp.code_cons_29 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_29);end if;
       if grp.code_cons_29 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_29);end if;end if;
       oGeav.cons_30:=grp.cons_30;
       if grp.code_cons_30 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_30;if vCUMU = 'N' then oGeav.cons_30 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_30);end if;
       if grp.code_cons_30 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_30);end if;
       if grp.code_cons_30 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_30);end if;end if;
       oGeav.cons_31:=grp.cons_31;
       if grp.code_cons_31 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_31;if vCUMU = 'N' then oGeav.cons_31 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_31);end if;
       if grp.code_cons_31 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_31);end if;
       if grp.code_cons_31 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_31);end if;end if;
       oGeav.cons_32:=grp.cons_32;
       if grp.code_cons_32 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_32;if vCUMU = 'N' then oGeav.cons_32 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_32);end if;
       if grp.code_cons_32 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_32);end if;
       if grp.code_cons_32 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_32);end if;end if;
       oGeav.cons_33:=grp.cons_33;
       if grp.code_cons_33 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_33;if vCUMU = 'N' then oGeav.cons_33 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_33);end if;
       if grp.code_cons_33 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_33);end if;
       if grp.code_cons_33 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_33);end if;end if;
       oGeav.cons_34:=grp.cons_34;
       if grp.code_cons_34 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_34;if vCUMU = 'N' then oGeav.cons_34 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_34);end if;
       if grp.code_cons_34 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_34);end if;
       if grp.code_cons_34 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_34);end if;end if;
       oGeav.cons_35:=grp.cons_35;
       if grp.code_cons_35 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_35;if vCUMU = 'N' then oGeav.cons_35 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_35);end if;
       if grp.code_cons_35 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_35);end if;
       if grp.code_cons_35 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_35);end if;end if;
       oGeav.cons_36:=grp.cons_36;
       if grp.code_cons_36 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_36;if vCUMU = 'N' then oGeav.cons_36 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_36);end if;
       if grp.code_cons_36 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_36);end if;
       if grp.code_cons_36 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_36);end if;end if;
       oGeav.cons_37:=grp.cons_37;
       if grp.code_cons_37 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_37;if vCUMU = 'N' then oGeav.cons_37 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_37);end if;
       if grp.code_cons_37 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_37);end if;
       if grp.code_cons_37 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_37);end if;end if;
       oGeav.cons_38:=grp.cons_38;
       if grp.code_cons_38 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_38;if vCUMU = 'N' then oGeav.cons_38 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_38);end if;
       if grp.code_cons_38 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_38);end if;
       if grp.code_cons_38 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_38);end if;end if;
       oGeav.cons_39:=grp.cons_39;
       if grp.code_cons_39 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_39;if vCUMU = 'N' then oGeav.cons_39 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_39);end if;
       if grp.code_cons_39 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_39);end if;
       if grp.code_cons_39 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_39);end if;end if;
       oGeav.cons_40:=grp.cons_40;
       if grp.code_cons_40 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_40;if vCUMU = 'N' then oGeav.cons_40 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_40);end if;
       if grp.code_cons_40 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_40);end if;
       if grp.code_cons_40 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_40);end if;end if;
       oGeav.cons_41:=grp.cons_41;
       if grp.code_cons_41 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_41;if vCUMU = 'N' then oGeav.cons_41 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_41);end if;
       if grp.code_cons_41 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_41);end if;
       if grp.code_cons_41 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_41);end if;end if;
       oGeav.cons_42:=grp.cons_42;
       if grp.code_cons_42 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_42;if vCUMU = 'N' then oGeav.cons_42 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_42);end if;
       if grp.code_cons_42 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_42);end if;
       if grp.code_cons_42 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_42);end if;end if;
       oGeav.cons_43:=grp.cons_43;
       if grp.code_cons_43 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_43;if vCUMU = 'N' then oGeav.cons_43 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_43);end if;
       if grp.code_cons_43 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_43);end if;
       if grp.code_cons_43 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_43);end if;end if;
       oGeav.cons_44:=grp.cons_44;
       if grp.code_cons_44 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_44;if vCUMU = 'N' then oGeav.cons_44 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_44);end if;
       if grp.code_cons_44 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_44);end if;
       if grp.code_cons_44 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_44);end if;end if;
       oGeav.cons_45:=grp.cons_45;
       if grp.code_cons_45 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_45;if vCUMU = 'N' then oGeav.cons_45 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_45);end if;
       if grp.code_cons_45 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_45);end if;
       if grp.code_cons_45 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_45);end if;end if;
       oGeav.cons_46:=grp.cons_46;
       if grp.code_cons_46 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_46;if vCUMU = 'N' then oGeav.cons_46 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_46);end if;
       if grp.code_cons_46 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_46);end if;
       if grp.code_cons_46 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_46);end if;end if;
       oGeav.cons_47:=grp.cons_47;
       if grp.code_cons_47 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_47;if vCUMU = 'N' then oGeav.cons_47 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_47);end if;
       if grp.code_cons_47 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_47);end if;
       if grp.code_cons_47 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_47);end if;end if;
       oGeav.cons_48:=grp.cons_48;
       if grp.code_cons_48 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_48;if vCUMU = 'N' then oGeav.cons_48 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_48);end if;
       if grp.code_cons_48 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_48);end if;
       if grp.code_cons_48 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_48);end if;end if;
       oGeav.cons_49:=grp.cons_49;
       if grp.code_cons_49 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_49;if vCUMU = 'N' then oGeav.cons_49 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_49);end if;
       if grp.code_cons_49 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_49);end if;
       if grp.code_cons_49 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_49);end if;end if;
       oGeav.cons_50:=grp.cons_50;
       if grp.code_cons_50 is not null then select nvl(list_cons_bool_cumu,'O') into vCUMU from constantes where code_cons = grp.code_cons_50;if vCUMU = 'N' then oGeav.cons_50 := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_50);end if;
       if grp.code_cons_50 = 'SALAIRE_REFE_PARA_03' then oGeav.dern_sala_base := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_50);end if;
       if grp.code_cons_50 = 'HORAIRE' then oGeav.dern_hora := fct_hc_sala_nume(grp.id_sala,vDERN_PERI_AFFI,grp.code_cons_50);end if;end if;

       oGeav.calc_01:=grp.calc_01;
       oGeav.calc_02:=grp.calc_02;
       oGeav.calc_03:=grp.calc_03;
       oGeav.calc_04:=grp.calc_04;
       oGeav.calc_05:=grp.calc_05;
       oGeav.calc_06:=grp.calc_06;
       oGeav.calc_07:=grp.calc_07;
       oGeav.calc_08:=grp.calc_08;
       oGeav.calc_09:=grp.calc_09;
       oGeav.calc_10:=grp.calc_10;
       oGeav.calc_11:=grp.calc_11;
       oGeav.calc_12:=grp.calc_12;
       oGeav.calc_13:=grp.calc_13;
       oGeav.calc_14:=grp.calc_14;
       oGeav.calc_15:=grp.calc_15;
       oGeav.calc_16:=grp.calc_16;
       oGeav.calc_17:=grp.calc_17;
       oGeav.calc_18:=grp.calc_18;
       oGeav.calc_19:=grp.calc_19;
       oGeav.calc_20:=grp.calc_20;

       if grp.CALC_RUBR_01 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_01 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_01 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_01 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_02 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_02 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_02 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_02 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_03 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_03 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_03 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_03 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_04 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_04 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_04 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_04 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_05 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_05 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_05 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_05 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_06 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_06 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_06 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_06 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_07 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_07 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_07 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_07 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_08 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_08 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_08 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_08 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_09 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_09 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_09 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_09 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_10 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_10 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_10 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_10 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_11 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_11 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_11 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_11 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_12 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_12 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_12 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_12 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_13 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_13 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_13 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_13 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_14 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_14 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_14 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_14 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_15 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_15 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_15 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_15 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_16 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_16 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_16 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_16 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_17 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_17 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_17 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_17 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_18 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_18 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_18 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_18 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_19 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_19 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_19 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_19 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_20 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_20 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_20 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_20 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_21 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_21 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_21 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_21 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_22 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_22 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_22 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_22 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_23 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_23 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_23 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_23 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_24 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_24 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_24 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_24 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_25 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_25 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_25 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_25 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_26 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_26 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_26 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_26 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_27 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_27 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_27 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_27 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_28 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_28 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_28 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_28 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_29 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_29 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_29 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_29 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_30 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_30 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_30 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_30 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_31 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_31 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_31 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_31 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_32 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_32 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_32 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_32 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_33 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_33 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_33 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_33 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_34 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_34 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_34 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_34 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_35 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_35 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_35 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_35 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_36 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_36 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_36 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_36 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_37 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_37 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_37 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_37 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_38 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_38 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_38 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_38 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_39 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_39 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_39 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_39 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_40 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_40 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_40 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_40 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_41 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_41 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_41 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_41 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_42 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_42 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_42 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_42 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_43 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_43 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_43 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_43 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_44 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_44 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_44 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_44 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_45 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_45 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_45 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_45 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_46 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_46 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_46 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_46 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_47 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_47 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_47 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_47 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_48 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_48 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_48 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_48 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_49 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_49 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_49 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_49 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_50 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_50 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_50 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_50 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_51 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_51 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_51 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_51 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_52 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_52 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_52 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_52 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_53 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_53 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_53 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_53 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_54 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_54 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_54 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_54 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_55 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_55 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_55 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_55 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_56 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_56 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_56 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_56 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_57 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_57 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_57 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_57 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_58 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_58 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_58 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_58 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_59 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_59 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_59 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_59 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_60 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_60 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_60 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_60 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_61 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_61 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_61 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_61 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_62 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_62 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_62 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_62 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_63 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_63 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_63 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_63 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_64 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_64 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_64 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_64 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_65 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_65 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_65 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_65 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_66 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_66 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_66 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_66 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_67 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_67 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_67 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_67 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_68 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_68 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_68 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_68 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_69 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_69 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_69 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_69 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_70 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_70 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_70 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_70 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_71 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_71 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_71 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_71 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_72 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_72 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_72 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_72 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_73 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_73 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_73 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_73 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_74 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_74 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_74 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_74 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_75 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_75 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_75 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_75 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_76 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_76 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_76 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_76 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_77 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_77 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_77 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_77 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_78 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_78 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_78 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_78 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_79 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_79 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_79 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_79 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_80 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_80 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_80 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_80 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_81 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_81 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_81 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_81 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_82 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_82 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_82 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_82 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_83 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_83 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_83 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_83 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_84 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_84 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_84 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_84 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_85 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_85 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_85 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_85 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_86 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_86 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_86 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_86 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_87 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_87 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_87 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_87 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_88 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_88 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_88 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_88 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_89 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_89 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_89 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_89 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_90 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_90 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_90 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_90 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_91 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_91 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_91 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_91 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_92 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_92 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_92 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_92 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_93 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_93 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_93 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_93 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_94 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_94 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_94 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_94 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_95 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_95 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_95 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_95 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_96 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_96 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_96 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_96 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_97 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_97 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_97 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_97 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_98 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_98 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_98 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_98 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_99 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_99 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_99 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_99 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_100 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_100 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_100 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_100 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_101 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_101 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_101 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_101 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_102 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_102 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_102 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_102 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_103 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_103 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_103 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_103 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_104 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_104 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_104 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_104 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_105 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_105 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_105 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_105 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_106 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_106 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_106 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_106 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_107 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_107 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_107 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_107 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_108 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_108 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_108 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_108 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_109 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_109 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_109 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_109 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_110 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_110 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_110 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_110 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_111 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_110 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_111 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_111 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_112 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_111 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_112 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_112 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_113 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_113 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_113 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_113 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_114 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_114 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_114 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_114 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_115 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_115 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_115 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_115 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_116 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_116 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_116 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_116 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_117 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_117 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_117 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_117 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_118 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_118 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_118 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_118 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_119 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_119 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_119 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_119 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_120 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_120 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_120 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_120 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_121 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_121 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_121 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_121 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_122 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_122 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_122 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_122 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_123 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_123 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_123 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_123 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_124 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_124 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_124 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_124 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_125 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_125 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_125 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_125 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_126 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_126 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_126 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_126 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_127 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_127 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_127 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_127 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_128 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_128 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_128 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_128 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_129 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_129 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_129 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_129 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_130 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_130 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_130 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_130 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_131 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_131 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_131 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_131 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_132 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_132 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_132 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_132 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_133 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_133 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_133 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_133 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_134 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_134 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_134 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_134 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_135 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_135 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_135 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_135 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_136 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_136 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_136 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_136 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_137 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_137 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_137 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_137 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_138 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_138 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_138 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_138 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_139 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_139 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_139 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_139 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_140 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_140 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_140 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_140 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_141 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_141 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_141 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_141 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_142 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_142 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_142 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_142 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_143 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_143 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_143 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_143 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_144 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_144 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_144 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_144 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_145 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_145 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_145 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_145 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_146 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_146 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_146 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_146 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_147 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_147 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_147 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_147 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_148 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_148 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_148 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_148 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_149 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_149 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_149 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_149 := vDERN_VALE_RUBR;
       end if;

       if grp.CALC_RUBR_150 = 'DERN' then
         if oPara.rupt_dema='O' then
           begin
             select rubr_150 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and repa_anal_code=grp.repa_anal_code and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         else
           begin
             select rubr_150 into vDERN_VALE_RUBR from pers_edit_gestion_avancee where id_soci=iID_SOCI and id_logi=iID_LOGI and id_para=vID_PARA and id_list=vID_LIST and peri=vDERN_PERI_AFFI and id_sala=grp.ID_SALA and rownum = 1;
           exception
           when NO_DATA_FOUND then
             vDERN_VALE_RUBR:=0;
           end;
         end if;
         oGeav.rubr_150 := vDERN_VALE_RUBR;
       end if;




       insert into pers_edit_gestion_avancee (
          id_soci                  ,
          id_logi                  ,
          id_list                  ,
          id_para                  ,
          peri                     ,
          lign                     ,
          id_sala                  ,
          nom                      ,
          pren                     ,
          nom_jeun_fill            ,
          titr                     ,
          matr_grou                ,
          matr_resp_hier           ,
          date_anci_prof           ,
          date_refe_01             ,
          date_refe_02             ,
          date_refe_03             ,
          date_refe_04             ,
          date_refe_05             ,
          date_sign_conv_stag      ,
          matr                     ,
          adre_mail                ,
          adre_mail_pers           ,
          sexe                     ,
          nive_qual                ,
          moti_depa                ,
          moti_augm                ,
          moti_augm_2              ,--KFH 25/05/2023 T184292
          TICK_REST_TYPE_REPA      ,--KFH 03/04/2024 T201908
          sala_auto_titr_trav      ,
          lieu_pres_stag           ,
          reac_regu                ,
          serv                     ,
          depa                     ,
          id_cate                  ,
          cate_prof                ,
          conv_coll                ,
          id_etab                  ,
          libe_etab                ,
          libe_etab_cour           ,
          empl                     ,
          empl_type                ,
          meti                     ,
          fami_meti                ,
          fami_meti_hier           ,
          code_empl                ,
          code_cate                ,
          coef                     ,
          sire_etab                ,
          dipl                     ,
          code_unit                ,
          code_regr_fich_comp_etab ,
          nive                     ,
          eche                     ,
          grou_conv                ,
          posi                     ,
          indi                     ,
          cota                     ,
          clas                     ,
          seui                     ,
          pali                     ,
          grad                     ,
          degr                     ,
          fili                     ,
          sect_prof                ,
          comp_brut                ,
          comp_paye                ,
          comp_acom                ,
          nume_secu                ,
          date_emba                ,
          date_depa                ,
          date_anci                ,
          date_dela_prev           ,
          date_nais                ,
          date_acci_trav           ,
          comm_nais                ,
          depa_nais                ,
          pays_nais                ,
          trav_hand                ,
          date_debu_coto           ,
          date_fin_coto            ,
          taux_inva                ,
          cong_rest_mois           ,
          evol_remu_supp_coti      ,
          nomb_tr_calc_peri        ,
          vale_spec_tr             ,
          cong_pris_anne           ,
          mutu_soum_txde_01        ,
          mutu_soum_txde_02        ,
          mutu_soum_txde_03        ,
          mutu_soum_txde_04        ,
          mutu_soum_txde_05        ,
          mutu_soum_mtde_01        ,
          mutu_soum_mtde_02        ,
          mutu_soum_mtde_03        ,
          mutu_soum_mtde_04        ,
          mutu_soum_mtde_05        ,
          mutu_soum_mtde_06        ,
          mutu_soum_mtde_07        ,
          mutu_soum_mtde_08        ,
          mutu_soum_mtde_09        ,
          mutu_soum_mtde_10        ,
          mutu_noso_txde_01        ,
          mutu_noso_txde_02        ,
          mutu_noso_txde_03        ,
          mutu_noso_mtde_01        ,
          mutu_noso_mtde_02        ,
          mutu_noso_mtde_03        ,
          mutu_noso_mtde_04        ,
          mutu_noso_mtde_05        ,
          mutu_noso_mtde_06        ,
          mutu_noso_mtde_07        ,
          code_anal_01             ,
          code_anal_02             ,
          code_anal_03             ,
          code_anal_04             ,
          code_anal_05             ,
          code_anal_06             ,
          code_anal_07             ,
          code_anal_08             ,
          code_anal_09             ,
          code_anal_10             ,
          code_anal_11             ,
          code_anal_12             ,
          code_anal_13             ,
          code_anal_14             ,
          code_anal_15             ,
          code_anal_16             ,
          code_anal_17             ,
          code_anal_18             ,
          code_anal_19             ,
          code_anal_20             ,
          plan1_code_anal_01       ,
          plan1_code_anal_02       ,
          plan1_code_anal_03       ,
          plan1_code_anal_04       ,
          plan1_code_anal_05       ,
          plan1_code_anal_06       ,
          plan1_code_anal_07       ,
          plan1_code_anal_08       ,
          plan1_code_anal_09       ,
          plan1_code_anal_10       ,
          plan1_code_anal_11       ,
          plan1_code_anal_12       ,
          plan1_code_anal_13       ,
          plan1_code_anal_14       ,
          plan1_code_anal_15       ,
          plan1_code_anal_16       ,
          plan1_code_anal_17       ,
          plan1_code_anal_18       ,
          plan1_code_anal_19       ,
          plan1_code_anal_20       ,
          plan1_pour_affe_anal_01  ,
          plan1_pour_affe_anal_02  ,
          plan1_pour_affe_anal_03  ,
          plan1_pour_affe_anal_04  ,
          plan1_pour_affe_anal_05  ,
          plan1_pour_affe_anal_06  ,
          plan1_pour_affe_anal_07  ,
          plan1_pour_affe_anal_08  ,
          plan1_pour_affe_anal_09  ,
          plan1_pour_affe_anal_10  ,
          plan1_pour_affe_anal_11  ,
          plan1_pour_affe_anal_12  ,
          plan1_pour_affe_anal_13  ,
          plan1_pour_affe_anal_14  ,
          plan1_pour_affe_anal_15  ,
          plan1_pour_affe_anal_16  ,
          plan1_pour_affe_anal_17  ,
          plan1_pour_affe_anal_18  ,
          plan1_pour_affe_anal_19  ,
          plan1_pour_affe_anal_20  ,
          plan2_code_anal_01       ,
          plan2_code_anal_02       ,
          plan2_code_anal_03       ,
          plan2_code_anal_04       ,
          plan2_code_anal_05       ,
          plan2_code_anal_06       ,
          plan2_code_anal_07       ,
          plan2_code_anal_08       ,
          plan2_code_anal_09       ,
          plan2_code_anal_10       ,
          plan2_code_anal_11       ,
          plan2_code_anal_12       ,
          plan2_code_anal_13       ,
          plan2_code_anal_14       ,
          plan2_code_anal_15       ,
          plan2_code_anal_16       ,
          plan2_code_anal_17       ,
          plan2_code_anal_18       ,
          plan2_code_anal_19       ,
          plan2_code_anal_20       ,
          plan2_pour_affe_anal_01  ,
          plan2_pour_affe_anal_02  ,
          plan2_pour_affe_anal_03  ,
          plan2_pour_affe_anal_04  ,
          plan2_pour_affe_anal_05  ,
          plan2_pour_affe_anal_06  ,
          plan2_pour_affe_anal_07  ,
          plan2_pour_affe_anal_08  ,
          plan2_pour_affe_anal_09  ,
          plan2_pour_affe_anal_10  ,
          plan2_pour_affe_anal_11  ,
          plan2_pour_affe_anal_12  ,
          plan2_pour_affe_anal_13  ,
          plan2_pour_affe_anal_14  ,
          plan2_pour_affe_anal_15  ,
          plan2_pour_affe_anal_16  ,
          plan2_pour_affe_anal_17  ,
          plan2_pour_affe_anal_18  ,
          plan2_pour_affe_anal_19  ,
          plan2_pour_affe_anal_20  ,
          plan3_code_anal_01       ,
          plan3_code_anal_02       ,
          plan3_code_anal_03       ,
          plan3_code_anal_04       ,
          plan3_code_anal_05       ,
          plan3_code_anal_06       ,
          plan3_code_anal_07       ,
          plan3_code_anal_08       ,
          plan3_code_anal_09       ,
          plan3_code_anal_10       ,
          plan3_code_anal_11       ,
          plan3_code_anal_12       ,
          plan3_code_anal_13       ,
          plan3_code_anal_14       ,
          plan3_code_anal_15       ,
          plan3_code_anal_16       ,
          plan3_code_anal_17       ,
          plan3_code_anal_18       ,
          plan3_code_anal_19       ,
          plan3_code_anal_20       ,
          plan3_pour_affe_anal_01  ,
          plan3_pour_affe_anal_02  ,
          plan3_pour_affe_anal_03  ,
          plan3_pour_affe_anal_04  ,
          plan3_pour_affe_anal_05  ,
          plan3_pour_affe_anal_06  ,
          plan3_pour_affe_anal_07  ,
          plan3_pour_affe_anal_08  ,
          plan3_pour_affe_anal_09  ,
          plan3_pour_affe_anal_10  ,
          plan3_pour_affe_anal_11  ,
          plan3_pour_affe_anal_12  ,
          plan3_pour_affe_anal_13  ,
          plan3_pour_affe_anal_14  ,
          plan3_pour_affe_anal_15  ,
          plan3_pour_affe_anal_16  ,
          plan3_pour_affe_anal_17  ,
          plan3_pour_affe_anal_18  ,
          plan3_pour_affe_anal_19  ,
          plan3_pour_affe_anal_20  ,
          plan4_code_anal_01       ,
          plan4_code_anal_02       ,
          plan4_code_anal_03       ,
          plan4_code_anal_04       ,
          plan4_code_anal_05       ,
          plan4_code_anal_06       ,
          plan4_code_anal_07       ,
          plan4_code_anal_08       ,
          plan4_code_anal_09       ,
          plan4_code_anal_10       ,
          plan4_code_anal_11       ,
          plan4_code_anal_12       ,
          plan4_code_anal_13       ,
          plan4_code_anal_14       ,
          plan4_code_anal_15       ,
          plan4_code_anal_16       ,
          plan4_code_anal_17       ,
          plan4_code_anal_18       ,
          plan4_code_anal_19       ,
          plan4_code_anal_20       ,
          plan4_pour_affe_anal_01  ,
          plan4_pour_affe_anal_02  ,
          plan4_pour_affe_anal_03  ,
          plan4_pour_affe_anal_04  ,
          plan4_pour_affe_anal_05  ,
          plan4_pour_affe_anal_06  ,
          plan4_pour_affe_anal_07  ,
          plan4_pour_affe_anal_08  ,
          plan4_pour_affe_anal_09  ,
          plan4_pour_affe_anal_10  ,
          plan4_pour_affe_anal_11  ,
          plan4_pour_affe_anal_12  ,
          plan4_pour_affe_anal_13  ,
          plan4_pour_affe_anal_14  ,
          plan4_pour_affe_anal_15  ,
          plan4_pour_affe_anal_16  ,
          plan4_pour_affe_anal_17  ,
          plan4_pour_affe_anal_18  ,
          plan4_pour_affe_anal_19  ,
          plan4_pour_affe_anal_20  ,
          plan5_code_anal_01       ,
          plan5_code_anal_02       ,
          plan5_code_anal_03       ,
          plan5_code_anal_04       ,
          plan5_code_anal_05       ,
          plan5_code_anal_06       ,
          plan5_code_anal_07       ,
          plan5_code_anal_08       ,
          plan5_code_anal_09       ,
          plan5_code_anal_10       ,
          plan5_code_anal_11       ,
          plan5_code_anal_12       ,
          plan5_code_anal_13       ,
          plan5_code_anal_14       ,
          plan5_code_anal_15       ,
          plan5_code_anal_16       ,
          plan5_code_anal_17       ,
          plan5_code_anal_18       ,
          plan5_code_anal_19       ,
          plan5_code_anal_20       ,
          plan5_pour_affe_anal_01  ,
          plan5_pour_affe_anal_02  ,
          plan5_pour_affe_anal_03  ,
          plan5_pour_affe_anal_04  ,
          plan5_pour_affe_anal_05  ,
          plan5_pour_affe_anal_06  ,
          plan5_pour_affe_anal_07  ,
          plan5_pour_affe_anal_08  ,
          plan5_pour_affe_anal_09  ,
          plan5_pour_affe_anal_10  ,
          plan5_pour_affe_anal_11  ,
          plan5_pour_affe_anal_12  ,
          plan5_pour_affe_anal_13  ,
          plan5_pour_affe_anal_14  ,
          plan5_pour_affe_anal_15  ,
          plan5_pour_affe_anal_16  ,
          plan5_pour_affe_anal_17  ,
          plan5_pour_affe_anal_18  ,
          plan5_pour_affe_anal_19  ,
          plan5_pour_affe_anal_20  ,
          situ_fami                ,
          bull_mode                ,
          profil_paye_cp           ,
          profil_paye_rtt          ,
          profil_paye_dif          ,
          profil_paye_prov_cet     ,
          profil_paye_prov_inte    ,
          profil_paye_prov_part    ,
          profil_paye_13mo         ,
          profil_paye_14mo         ,
          prof_15mo                ,
          profil_paye_prim_vaca_01 ,
          profil_paye_prim_vaca_02 ,
          profil_paye_hs_conv      ,
          profil_paye_heur_equi    ,
          profil_paye_deca_fisc    ,
          profil_paye_tepa         ,
          profil_paye_affi_bull    ,
          profil_paye_forf         ,
          profil_paye_depa         ,
          profil_paye_rein_frai    ,
          profil_paye_ndf          ,
          profil_paye_acce_sala    ,
          profil_paye_plan         ,
          profil_paye_tele_trav    ,
          idcc_heur_equi           ,
          cipdz_code               ,
          cipdz_libe               ,
          nume_cong_spec           ,
          grou_comp                ,
          nati                     ,
          date_expi                ,
          nume_cart_sejo           ,
          nume_cart_trav           ,
          date_deli_trav           ,
          date_expi_trav           ,
          date_dema_auto_trav      ,
          id_pref                  ,
          date_expi_disp_mutu      ,
          id_moti_disp_mutu        ,
          nomb_enfa                ,
          comm_vent_n              ,
          comm_vent_n1             ,
          prim_obje_n              ,
          prim_obje_n1             ,
          prim_obje_soci_n         ,
          prim_obje_soci_n1        ,
          prim_obje_glob_n         ,
          dads_inse_empl           ,
          sais                     ,
          moti_visi_medi           ,
          stat_boet                ,
          nomb_jour_trav_refe_tr_2 ,
          calc_auto_tr             ,
          type_vehi                ,
          cate_vehi                ,
          pris_char_carb           ,
          octr_vehi                ,
          imma_vehi                ,
          date_1er_mise_circ_vehi  ,
          prix_acha_remi_vehi      ,
          cout_vehi                ,
          type_sala                ,
          natu_cont                ,
          nume_cont                ,
          libe_moti_recr_cdd       ,
          libe_moti_recr_cdd2      ,
          libe_moti_recr_cdd3      ,
          date_debu_cont           ,
          date_fin_cont            ,
          date_dern_visi_medi      ,
          date_proc_visi_medi      ,
          equi                     ,
          divi                     ,
          cais_coti_bull           ,
          regr                     ,
          mail_sala_cong           ,
          resp_hier_1_nom          ,
          resp_hier_1_mail         ,
          resp_hier_2_nom          ,
          resp_hier_2_mail         ,
          hier_resp_1_nom          ,
          hier_resp_1_mail         ,
          hier_resp_2_nom          ,
          hier_resp_2_mail         ,
          rib_mode_paie            ,
          rib_banq_1               ,
          rib_domi_1               ,
          rib_nume_1               ,
          rib_titu_comp_1          ,
          rib_banq_2               ,
          rib_domi_2               ,
          rib_nume_2               ,
          rib_titu_comp_2          ,
          tele_1                   ,
          tele_2                   ,
          tele_3                   ,
          adre                     ,
          dern_adre                ,
          adre_comp                ,
          dern_adre_comp           ,
          adre_comm                ,
          dern_adre_comm           ,
          adre_code_post           ,
          dern_adre_code_post      ,
          adre_pays                ,
          ccn51_anci_date_chan_appl,
          ccn51_anci_taux          ,
          ccn51_cadr_date_chan_appl,
          ccn51_cadr_taux          ,
          etp_ccn51                ,
          ccn51_coef_acca          ,
          ccn51_coef_dipl          ,
          ccn51_coef_enca          ,
          ccn51_coef_fonc          ,
          ccn51_coef_meti          ,
          ccn51_coef_recl          ,
          ccn51_coef_spec          ,
          ccn51_id_empl_conv       ,
          ccn5166_coef_refe        ,
          ccn66_cate_conv          ,
          ccn66_date_chan_coef     ,
          ccn66_empl_conv          ,
          ccn66_libe_empl_conv     ,
          ccn66_fili_conv          ,
          ccn66_prec_date_chan_coef,
          ccn66_proc_coef_refe     ,
          ccn66_regi               ,
          code_regi                ,
          libe_regi                ,
          orga                     ,
          unit                     ,
          nume_fine                ,
          nume_adel                ,
          nume_rpps                ,
          adre_elec                ,
          code_titr_form           ,
          libe_titr_form           ,
          date_titr_form           ,
          lieu_titr_form           ,
          cham_util_1              ,
          cham_util_2              ,
          cham_util_3              ,
          cham_util_4              ,
          cham_util_5              ,
          cham_util_6              ,
          cham_util_7              ,
          cham_util_8              ,
          cham_util_9              ,
          cham_util_10             ,
          cham_util_11             ,
          cham_util_12             ,
          cham_util_13             ,
          cham_util_14             ,
          cham_util_15             ,
          cham_util_16             ,
          cham_util_17             ,
          cham_util_18             ,
          cham_util_19             ,
          cham_util_20             ,
          cham_util_21             ,
          cham_util_22             ,
          cham_util_23             ,
          cham_util_24             ,
          cham_util_25             ,
          cham_util_26             ,
          cham_util_27             ,
          cham_util_28             ,
          cham_util_29             ,
          cham_util_30             ,
          cham_util_31             ,
          cham_util_32             ,
          cham_util_33             ,
          cham_util_34             ,
          cham_util_35             ,
          cham_util_36             ,
          cham_util_37             ,
          cham_util_38             ,
          cham_util_39             ,
          cham_util_40             ,
          cham_util_41              ,
          cham_util_42              ,
          cham_util_43              ,
          cham_util_44              ,
          cham_util_45              ,
          cham_util_46              ,
          cham_util_47              ,
          cham_util_48              ,
          cham_util_49              ,
          cham_util_50             ,
          cham_util_51             ,
          cham_util_52             ,
          cham_util_53             ,
          cham_util_54             ,
          cham_util_55             ,
          cham_util_56             ,
          cham_util_57             ,
          cham_util_58             ,
          cham_util_59             ,
          cham_util_60             ,
          cham_util_61             ,
          cham_util_62             ,
          cham_util_63             ,
          cham_util_64             ,
          cham_util_65             ,
          cham_util_66             ,
          cham_util_67             ,
          cham_util_68             ,
          cham_util_69             ,
          cham_util_70             ,
          cham_util_71             ,
          cham_util_72             ,
          cham_util_73             ,
          cham_util_74             ,
          cham_util_75             ,
          cham_util_76             ,
          cham_util_77             ,
          cham_util_78             ,
          cham_util_79             ,
          cham_util_80             ,
          soci                     ,
          rais_soci                ,
          soci_orig                ,
          fin_peri_essa            ,
          droi_prim_anci           ,
          bic_01                   ,
          bic_02                   ,
          iban_01                  ,
          iban_02                  ,
          code_iso_pays_nati       ,
          repa_anal_code           ,
          rubr_01                  ,
          rubr_02                  ,
          rubr_03                  ,
          rubr_04                  ,
          rubr_05                  ,
          rubr_06                  ,
          rubr_07                  ,
          rubr_08                  ,
          rubr_09                  ,
          rubr_10                  ,
          rubr_11                  ,
          rubr_12                  ,
          rubr_13                  ,
          rubr_14                  ,
          rubr_15                  ,
          rubr_16                  ,
          rubr_17                  ,
          rubr_18                  ,
          rubr_19                  ,
          rubr_20                  ,
          rubr_21                  ,
          rubr_22                  ,
          rubr_23                  ,
          rubr_24                  ,
          rubr_25                  ,
          rubr_26                  ,
          rubr_27                  ,
          rubr_28                  ,
          rubr_29                  ,
          rubr_30                  ,
          rubr_31                  ,
          rubr_32                  ,
          rubr_33                  ,
          rubr_34                  ,
          rubr_35                  ,
          rubr_36                  ,
          rubr_37                  ,
          rubr_38                  ,
          rubr_39                  ,
          rubr_40                  ,
          rubr_41                  ,
          rubr_42                  ,
          rubr_43                  ,
          rubr_44                  ,
          rubr_45                  ,
          rubr_46                  ,
          rubr_47                  ,
          rubr_48                  ,
          rubr_49                  ,
          rubr_50                  ,

          rubr_51                  ,
          rubr_52                  ,
          rubr_53                  ,
          rubr_54                  ,
          rubr_55                  ,
          rubr_56                  ,
          rubr_57                  ,
          rubr_58                  ,
          rubr_59                  ,
          rubr_60                  ,
          rubr_61                  ,
          rubr_62                  ,
          rubr_63                  ,
          rubr_64                  ,
          rubr_65                  ,
          rubr_66                  ,
          rubr_67                  ,
          rubr_68                  ,
          rubr_69                  ,
          rubr_70                  ,
          rubr_71                  ,
          rubr_72                  ,
          rubr_73                  ,
          rubr_74                  ,
          rubr_75                  ,
          rubr_76                  ,
          rubr_77                  ,
          rubr_78                  ,
          rubr_79                  ,
          rubr_80                  ,
          rubr_81                  ,
          rubr_82                  ,
          rubr_83                  ,
          rubr_84                  ,
          rubr_85                  ,
          rubr_86                  ,
          rubr_87                  ,
          rubr_88                  ,
          rubr_89                  ,
          rubr_90                  ,
          rubr_91                  ,
          rubr_92                  ,
          rubr_93                  ,
          rubr_94                  ,
          rubr_95                  ,
          rubr_96                  ,
          rubr_97                  ,
          rubr_98                  ,
          rubr_99                  ,
          rubr_100                 ,
          rubr_101                 ,
          rubr_102                 ,
          rubr_103                 ,
          rubr_104                 ,
          rubr_105                 ,
          rubr_106                 ,
          rubr_107                 ,
          rubr_108                 ,
          rubr_109                 ,
          rubr_110                  ,
          rubr_111                  ,
          rubr_112                  ,
          rubr_113                  ,
          rubr_114                  ,
          rubr_115                  ,
          rubr_116                  ,
          rubr_117                  ,
          rubr_118                  ,
          rubr_119                  ,
          rubr_120                  ,
          rubr_121                  ,
          rubr_122                  ,
          rubr_123                  ,
          rubr_124                  ,
          rubr_125                  ,
          rubr_126                  ,
          rubr_127                  ,
          rubr_128                  ,
          rubr_129                  ,
          rubr_130                  ,
          rubr_131                  ,
          rubr_132                  ,
          rubr_133                  ,
          rubr_134                  ,
          rubr_135                  ,
          rubr_136                  ,
          rubr_137                  ,
          rubr_138                  ,
          rubr_139                  ,
          rubr_140                  ,
          rubr_141                  ,
          rubr_142                  ,
          rubr_143                  ,
          rubr_144                  ,
          rubr_145                  ,
          rubr_146                  ,
          rubr_147                  ,
          rubr_148                  ,
          rubr_149                  ,
          rubr_150                  ,

          cons_01                  ,
          cons_02                  ,
          cons_03                  ,
          cons_04                  ,
          cons_05                  ,
          cons_06                  ,
          cons_07                  ,
          cons_08                  ,
          cons_09                  ,
          cons_10                  ,
          cons_11                  ,
          cons_12                  ,
          cons_13                  ,
          cons_14                  ,
          cons_15                  ,
          cons_16                  ,
          cons_17                  ,
          cons_18                  ,
          cons_19                  ,
          cons_20                  ,

          cons_21                  ,
          cons_22                  ,
          cons_23                  ,
          cons_24                  ,
          cons_25                  ,
          cons_26                  ,
          cons_27                  ,
          cons_28                  ,
          cons_29                  ,
          cons_30                  ,
          cons_31                  ,
          cons_32                  ,
          cons_33                  ,
          cons_34                  ,
          cons_35                  ,
          cons_36                  ,
          cons_37                  ,
          cons_38                  ,
          cons_39                  ,
          cons_40                  ,
          cons_41                  ,
          cons_42                  ,
          cons_43                  ,
          cons_44                  ,
          cons_45                  ,
          cons_46                  ,
          cons_47                  ,
          cons_48                  ,
          cons_49                  ,
          cons_50                  ,

          calc_01                  ,
          calc_02                  ,
          calc_03                  ,
          calc_04                  ,
          calc_05                  ,
          calc_06                  ,
          calc_07                  ,
          calc_08                  ,
          calc_09                  ,
          calc_10                  ,
          calc_11                  ,
          calc_12                  ,
          calc_13                  ,
          calc_14                  ,
          calc_15                  ,
          calc_16                  ,
          calc_17                  ,
          calc_18                  ,
          calc_19                  ,
          calc_20                  ,
          dern_sala_base           ,
          dern_sala_base_annu      ,
          dern_hora                ,
          sala_forf_temp           ,
          nomb_jour_forf_temp      ,
          nomb_heur_forf_temp      ,
          nomb_mois                ,
          sala_annu_cont           ,
          code_fine_geog           ,
          rib_guic_1               ,
          rib_comp_1               ,
          rib_cle_1                ,
          rib_banq_01              ,
          rib_banq_02              ,
          prof_temp_libe           ,
          nomb_jour_cong_anci      ,
          mont_anci_pa             ,
          anci_cadr                ,
          tota_heur_trav           ,
          DPAE_ENVO                ,
          DISP_POLI_PUBL_CONV      ,
          DATE_ANCI_CADR_FORF 
       )values(
          iID_SOCI                          ,
          iID_LOGI                          ,
          vID_LIST                          ,
          vID_PARA                          ,
          substr(oGeav.peri           ,1,30),
          2                                 ,
          oGeav.id_sala                     ,
          substr(oGeav.nom, 1, 150),
          substr(oGeav.pren, 1, 150),
          substr(oGeav.nom_jeun_fill, 1, 150),
          substr(oGeav.titr,1,20)           ,
          oGeav.matr_grou                   ,
          oGeav.matr_resp_hier              ,
          oGeav.date_anci_prof              ,
          oGeav.date_refe_01                ,
          oGeav.date_refe_02                ,
          oGeav.date_refe_03                ,
          oGeav.date_refe_04                ,
          oGeav.date_refe_05                ,
          oGeav.date_sign_conv_stag         ,
          oGeav.matr                        ,
          oGeav.adre_mail                   ,
          oGeav.adre_mail_pers              ,
          oGeav.sexe                        ,
          oGeav.nive_qual                   ,
          oGeav.moti_depa                   ,
          oGeav.moti_augm                   ,
          oGeav.moti_augm_2                 ,--KFH 25/05/2023 T184292
          oGeav.TICK_REST_TYPE_REPA         ,--KFH 03/04/2024 T201908
          oGeav.sala_auto_titr_trav         ,
          oGeav.lieu_pres_stag              ,
          oGeav.reac_regu                   ,
          oGeav.serv                        ,
          oGeav.depa                        ,
          oGeav.id_cate                     ,
          oGeav.cate_prof                   ,
          oGeav.conv_coll                   ,
          oGeav.id_etab                     ,
          substr(oGeav.libe_etab      ,1,50),
          substr(oGeav.libe_etab_cour ,1,50),
          substr(oGeav.empl           ,1,80),
          oGeav.empl_type                   ,
          oGeav.meti                        ,
          oGeav.fami_meti                   ,
          oGeav.fami_meti_hier              ,
          oGeav.code_empl                   ,
          oGeav.code_cate                   ,
          substr(oGeav.coef           ,1,50),
          oGeav.sire_etab                        ,
          oGeav.dipl                        ,
          oGeav.code_unit                        ,
          oGeav.code_regr_fich_comp_etab                        ,
          substr(oGeav.nive           ,1,50),
          substr(oGeav.eche           ,1,50),
          substr(oGeav.grou_conv      ,1,50),
          substr(oGeav.posi           ,1,50),
          substr(oGeav.indi           ,1,50),
          substr(oGeav.cota           ,1,50),
          substr(oGeav.clas           ,1,50),
          substr(oGeav.seui           ,1,50),
          substr(oGeav.pali           ,1,50),
          substr(oGeav.grad           ,1,50),
          substr(oGeav.degr           ,1,50),
          oGeav.fili                        ,
          oGeav.sect_prof                   ,
          oGeav.comp_brut                   ,
          oGeav.comp_paye                   ,
          oGeav.comp_acom                   ,
          substr(oGeav.nume_secu      ,1,50),
          oGeav.date_emba                   ,
          oGeav.date_depa                   ,
          oGeav.date_anci                   ,
          oGeav.date_dela_prev              ,
          oGeav.date_nais                   ,
          oGeav.date_acci_trav              ,
          oGeav.comm_nais                   ,
          oGeav.depa_nais                   ,
          oGeav.pays_nais                   ,
          oGeav.trav_hand                   ,
          oGeav.date_debu_coto              ,
          oGeav.date_fin_coto               ,
          oGeav.taux_inva                   ,
          vCONG_REST_N                      ,
          vEVOL_REMU_SUPP_COTI              ,
          vNOMB_TR_CALC_PERI                ,
          vVALE_SPEC_TR                     ,
          fCONG_PRIS_ANNE_N                 ,
          oGeav.mutu_soum_txde_01           ,
          oGeav.mutu_soum_txde_02           ,
          oGeav.mutu_soum_txde_03           ,
          oGeav.mutu_soum_txde_04           ,
          oGeav.mutu_soum_txde_05           ,
          oGeav.mutu_soum_mtde_01           ,
          oGeav.mutu_soum_mtde_02           ,
          oGeav.mutu_soum_mtde_03           ,
          oGeav.mutu_soum_mtde_04           ,
          oGeav.mutu_soum_mtde_05           ,
          oGeav.mutu_soum_mtde_06           ,
          oGeav.mutu_soum_mtde_07           ,
          oGeav.mutu_soum_mtde_08           ,
          oGeav.mutu_soum_mtde_09           ,
          oGeav.mutu_soum_mtde_10           ,
          oGeav.mutu_noso_txde_01           ,
          oGeav.mutu_noso_txde_02           ,
          oGeav.mutu_noso_txde_03           ,
          oGeav.mutu_noso_mtde_01           ,
          oGeav.mutu_noso_mtde_02           ,
          oGeav.mutu_noso_mtde_03           ,
          oGeav.mutu_noso_mtde_04           ,
          oGeav.mutu_noso_mtde_05           ,
          oGeav.mutu_noso_mtde_06           ,
          oGeav.mutu_noso_mtde_07           ,
          oGeav.code_anal_01                ,
          oGeav.code_anal_02                ,
          oGeav.code_anal_03                ,
          oGeav.code_anal_04                ,
          oGeav.code_anal_05                ,
          oGeav.code_anal_06                ,
          oGeav.code_anal_07                ,
          oGeav.code_anal_08                ,
          oGeav.code_anal_09                ,
          oGeav.code_anal_10                ,
          oGeav.code_anal_11                ,
          oGeav.code_anal_12                ,
          oGeav.code_anal_13                ,
          oGeav.code_anal_14                ,
          oGeav.code_anal_15                ,
          oGeav.code_anal_16                ,
          oGeav.code_anal_17                ,
          oGeav.code_anal_18                ,
          oGeav.code_anal_19                ,
          oGeav.code_anal_20                ,
          oGeav.plan1_code_anal_01          ,
          oGeav.plan1_code_anal_02          ,
          oGeav.plan1_code_anal_03          ,
          oGeav.plan1_code_anal_04          ,
          oGeav.plan1_code_anal_05          ,
          oGeav.plan1_code_anal_06          ,
          oGeav.plan1_code_anal_07          ,
          oGeav.plan1_code_anal_08          ,
          oGeav.plan1_code_anal_09          ,
          oGeav.plan1_code_anal_10          ,
          oGeav.plan1_code_anal_11          ,
          oGeav.plan1_code_anal_12          ,
          oGeav.plan1_code_anal_13          ,
          oGeav.plan1_code_anal_14          ,
          oGeav.plan1_code_anal_15          ,
          oGeav.plan1_code_anal_16          ,
          oGeav.plan1_code_anal_17          ,
          oGeav.plan1_code_anal_18          ,
          oGeav.plan1_code_anal_19          ,
          oGeav.plan1_code_anal_20          ,
          oGeav.plan1_pour_affe_anal_01     ,
          oGeav.plan1_pour_affe_anal_02     ,
          oGeav.plan1_pour_affe_anal_03     ,
          oGeav.plan1_pour_affe_anal_04     ,
          oGeav.plan1_pour_affe_anal_05     ,
          oGeav.plan1_pour_affe_anal_06     ,
          oGeav.plan1_pour_affe_anal_07     ,
          oGeav.plan1_pour_affe_anal_08     ,
          oGeav.plan1_pour_affe_anal_09     ,
          oGeav.plan1_pour_affe_anal_10     ,
          oGeav.plan1_pour_affe_anal_11     ,
          oGeav.plan1_pour_affe_anal_12     ,
          oGeav.plan1_pour_affe_anal_13     ,
          oGeav.plan1_pour_affe_anal_14     ,
          oGeav.plan1_pour_affe_anal_15     ,
          oGeav.plan1_pour_affe_anal_16     ,
          oGeav.plan1_pour_affe_anal_17     ,
          oGeav.plan1_pour_affe_anal_18     ,
          oGeav.plan1_pour_affe_anal_19     ,
          oGeav.plan1_pour_affe_anal_20     ,
          oGeav.plan2_code_anal_01          ,
          oGeav.plan2_code_anal_02          ,
          oGeav.plan2_code_anal_03          ,
          oGeav.plan2_code_anal_04          ,
          oGeav.plan2_code_anal_05          ,
          oGeav.plan2_code_anal_06          ,
          oGeav.plan2_code_anal_07          ,
          oGeav.plan2_code_anal_08          ,
          oGeav.plan2_code_anal_09          ,
          oGeav.plan2_code_anal_10          ,
          oGeav.plan2_code_anal_11          ,
          oGeav.plan2_code_anal_12          ,
          oGeav.plan2_code_anal_13          ,
          oGeav.plan2_code_anal_14          ,
          oGeav.plan2_code_anal_15          ,
          oGeav.plan2_code_anal_16          ,
          oGeav.plan2_code_anal_17          ,
          oGeav.plan2_code_anal_18          ,
          oGeav.plan2_code_anal_19          ,
          oGeav.plan2_code_anal_20          ,
          oGeav.plan2_pour_affe_anal_01     ,
          oGeav.plan2_pour_affe_anal_02     ,
          oGeav.plan2_pour_affe_anal_03     ,
          oGeav.plan2_pour_affe_anal_04     ,
          oGeav.plan2_pour_affe_anal_05     ,
          oGeav.plan2_pour_affe_anal_06     ,
          oGeav.plan2_pour_affe_anal_07     ,
          oGeav.plan2_pour_affe_anal_08     ,
          oGeav.plan2_pour_affe_anal_09     ,
          oGeav.plan2_pour_affe_anal_10     ,
          oGeav.plan2_pour_affe_anal_11     ,
          oGeav.plan2_pour_affe_anal_12     ,
          oGeav.plan2_pour_affe_anal_13     ,
          oGeav.plan2_pour_affe_anal_14     ,
          oGeav.plan2_pour_affe_anal_15     ,
          oGeav.plan2_pour_affe_anal_16     ,
          oGeav.plan2_pour_affe_anal_17     ,
          oGeav.plan2_pour_affe_anal_18     ,
          oGeav.plan2_pour_affe_anal_19     ,
          oGeav.plan2_pour_affe_anal_20     ,
          oGeav.plan3_code_anal_01          ,
          oGeav.plan3_code_anal_02          ,
          oGeav.plan3_code_anal_03          ,
          oGeav.plan3_code_anal_04          ,
          oGeav.plan3_code_anal_05          ,
          oGeav.plan3_code_anal_06          ,
          oGeav.plan3_code_anal_07          ,
          oGeav.plan3_code_anal_08          ,
          oGeav.plan3_code_anal_09          ,
          oGeav.plan3_code_anal_10          ,
          oGeav.plan3_code_anal_11          ,
          oGeav.plan3_code_anal_12          ,
          oGeav.plan3_code_anal_13          ,
          oGeav.plan3_code_anal_14          ,
          oGeav.plan3_code_anal_15          ,
          oGeav.plan3_code_anal_16          ,
          oGeav.plan3_code_anal_17          ,
          oGeav.plan3_code_anal_18          ,
          oGeav.plan3_code_anal_19          ,
          oGeav.plan3_code_anal_20          ,
          oGeav.plan3_pour_affe_anal_01     ,
          oGeav.plan3_pour_affe_anal_02     ,
          oGeav.plan3_pour_affe_anal_03     ,
          oGeav.plan3_pour_affe_anal_04     ,
          oGeav.plan3_pour_affe_anal_05     ,
          oGeav.plan3_pour_affe_anal_06     ,
          oGeav.plan3_pour_affe_anal_07     ,
          oGeav.plan3_pour_affe_anal_08     ,
          oGeav.plan3_pour_affe_anal_09     ,
          oGeav.plan3_pour_affe_anal_10     ,
          oGeav.plan3_pour_affe_anal_11     ,
          oGeav.plan3_pour_affe_anal_12     ,
          oGeav.plan3_pour_affe_anal_13     ,
          oGeav.plan3_pour_affe_anal_14     ,
          oGeav.plan3_pour_affe_anal_15     ,
          oGeav.plan3_pour_affe_anal_16     ,
          oGeav.plan3_pour_affe_anal_17     ,
          oGeav.plan3_pour_affe_anal_18     ,
          oGeav.plan3_pour_affe_anal_19     ,
          oGeav.plan3_pour_affe_anal_20     ,
          oGeav.plan4_code_anal_01          ,
          oGeav.plan4_code_anal_02          ,
          oGeav.plan4_code_anal_03          ,
          oGeav.plan4_code_anal_04          ,
          oGeav.plan4_code_anal_05          ,
          oGeav.plan4_code_anal_06          ,
          oGeav.plan4_code_anal_07          ,
          oGeav.plan4_code_anal_08          ,
          oGeav.plan4_code_anal_09          ,
          oGeav.plan4_code_anal_10          ,
          oGeav.plan4_code_anal_11          ,
          oGeav.plan4_code_anal_12          ,
          oGeav.plan4_code_anal_13          ,
          oGeav.plan4_code_anal_14          ,
          oGeav.plan4_code_anal_15          ,
          oGeav.plan4_code_anal_16          ,
          oGeav.plan4_code_anal_17          ,
          oGeav.plan4_code_anal_18          ,
          oGeav.plan4_code_anal_19          ,
          oGeav.plan4_code_anal_20          ,
          oGeav.plan4_pour_affe_anal_01     ,
          oGeav.plan4_pour_affe_anal_02     ,
          oGeav.plan4_pour_affe_anal_03     ,
          oGeav.plan4_pour_affe_anal_04     ,
          oGeav.plan4_pour_affe_anal_05     ,
          oGeav.plan4_pour_affe_anal_06     ,
          oGeav.plan4_pour_affe_anal_07     ,
          oGeav.plan4_pour_affe_anal_08     ,
          oGeav.plan4_pour_affe_anal_09     ,
          oGeav.plan4_pour_affe_anal_10     ,
          oGeav.plan4_pour_affe_anal_11     ,
          oGeav.plan4_pour_affe_anal_12     ,
          oGeav.plan4_pour_affe_anal_13     ,
          oGeav.plan4_pour_affe_anal_14     ,
          oGeav.plan4_pour_affe_anal_15     ,
          oGeav.plan4_pour_affe_anal_16     ,
          oGeav.plan4_pour_affe_anal_17     ,
          oGeav.plan4_pour_affe_anal_18     ,
          oGeav.plan4_pour_affe_anal_19     ,
          oGeav.plan4_pour_affe_anal_20     ,
          oGeav.plan5_code_anal_01          ,
          oGeav.plan5_code_anal_02          ,
          oGeav.plan5_code_anal_03          ,
          oGeav.plan5_code_anal_04          ,
          oGeav.plan5_code_anal_05          ,
          oGeav.plan5_code_anal_06          ,
          oGeav.plan5_code_anal_07          ,
          oGeav.plan5_code_anal_08          ,
          oGeav.plan5_code_anal_09          ,
          oGeav.plan5_code_anal_10          ,
          oGeav.plan5_code_anal_11          ,
          oGeav.plan5_code_anal_12          ,
          oGeav.plan5_code_anal_13          ,
          oGeav.plan5_code_anal_14          ,
          oGeav.plan5_code_anal_15          ,
          oGeav.plan5_code_anal_16          ,
          oGeav.plan5_code_anal_17          ,
          oGeav.plan5_code_anal_18          ,
          oGeav.plan5_code_anal_19          ,
          oGeav.plan5_code_anal_20          ,
          oGeav.plan5_pour_affe_anal_01     ,
          oGeav.plan5_pour_affe_anal_02     ,
          oGeav.plan5_pour_affe_anal_03     ,
          oGeav.plan5_pour_affe_anal_04     ,
          oGeav.plan5_pour_affe_anal_05     ,
          oGeav.plan5_pour_affe_anal_06     ,
          oGeav.plan5_pour_affe_anal_07     ,
          oGeav.plan5_pour_affe_anal_08     ,
          oGeav.plan5_pour_affe_anal_09     ,
          oGeav.plan5_pour_affe_anal_10     ,
          oGeav.plan5_pour_affe_anal_11     ,
          oGeav.plan5_pour_affe_anal_12     ,
          oGeav.plan5_pour_affe_anal_13     ,
          oGeav.plan5_pour_affe_anal_14     ,
          oGeav.plan5_pour_affe_anal_15     ,
          oGeav.plan5_pour_affe_anal_16     ,
          oGeav.plan5_pour_affe_anal_17     ,
          oGeav.plan5_pour_affe_anal_18     ,
          oGeav.plan5_pour_affe_anal_19     ,
          oGeav.plan5_pour_affe_anal_20     ,
          oGeav.situ_fami                   ,
          oGeav.bull_mode                   ,
          oGeav.profil_paye_cp              ,
          oGeav.profil_paye_rtt             ,
          oGeav.profil_paye_dif             ,
          oGeav.profil_paye_prov_cet        ,
          oGeav.profil_paye_prov_inte       ,
          oGeav.profil_paye_prov_part       ,
          oGeav.profil_paye_13mo            ,
          oGeav.profil_paye_14mo            ,
          oGeav.prof_15mo                   ,
          oGeav.profil_paye_prim_vaca_01    ,
          oGeav.profil_paye_prim_vaca_02    ,
          oGeav.profil_paye_hs_conv         ,
          oGeav.profil_paye_heur_equi       ,
          oGeav.profil_paye_deca_fisc       ,
          oGeav.profil_paye_tepa            ,
          oGeav.profil_paye_affi_bull       ,
          oGeav.profil_paye_forf            ,
          oGeav.profil_paye_depa            ,
          oGeav.profil_paye_rein_frai       ,
          oGeav.profil_paye_ndf             ,
          oGeav.profil_paye_acce_sala       ,
          oGeav.profil_paye_plan            ,
          oGeav.profil_paye_tele_trav       ,
          oGeav.idcc_heur_equi              ,
          oGeav.cipdz_code                  ,
          oGeav.cipdz_libe                  ,
          oGeav.nume_cong_spec              ,
          oGeav.grou_comp                   ,
          oGeav.nati                        ,
          oGeav.date_expi                   ,
          oGeav.nume_cart_sejo              ,
          oGeav.nume_cart_trav              ,
          oGeav.date_deli_trav              ,
          oGeav.date_expi_trav              ,
          oGeav.date_dema_auto_trav         ,
          oGeav.id_pref                     ,
          oGeav.date_expi_disp_mutu         ,
          oGeav.id_moti_disp_mutu           ,
          oGeav.nomb_enfa                   ,
          oGeav.comm_vent_n                 ,
          oGeav.comm_vent_n1                ,
          oGeav.prim_obje_n                 ,
          oGeav.prim_obje_n1                ,
          oGeav.prim_obje_soci_n            ,
          oGeav.prim_obje_soci_n1           ,
          oGeav.prim_obje_glob_n            ,
          oGeav.dads_inse_empl              ,
          oGeav.sais                        ,
          oGeav.moti_visi_medi              ,
          oGeav.stat_boet                   ,
          oGeav.nomb_jour_trav_refe_tr_2    ,
          oGeav.calc_auto_tr                ,
          oGeav.type_vehi                   ,
          oGeav.cate_vehi                   ,
          oGeav.pris_char_carb              ,
          oGeav.octr_vehi                   ,
          oGeav.imma_vehi                   ,
          oGeav.date_1er_mise_circ_vehi     ,
          oGeav.prix_acha_remi_vehi         ,
          oGeav.cout_vehi                   ,
          oGeav.type_sala                   ,
          oGeav.natu_cont                   ,
          oGeav.nume_cont                   ,
          oGeav.libe_moti_recr_cdd          ,
          oGeav.libe_moti_recr_cdd2         ,
          oGeav.libe_moti_recr_cdd3         ,
          oGeav.date_debu_cont              ,
          oGeav.date_fin_cont               ,
          oGeav.date_dern_visi_medi         ,
          oGeav.date_proc_visi_medi         ,
          oGeav.equi                        ,
          oGeav.divi                        ,
          oGeav.cais_coti_bull              ,
          oGeav.regr                        ,
          oGeav.mail_sala_cong              ,
          oGeav.resp_hier_1_nom             ,
          oGeav.resp_hier_1_mail            ,
          oGeav.resp_hier_2_nom             ,
          oGeav.resp_hier_2_mail            ,
          oGeav.hier_resp_1_nom             ,
          oGeav.hier_resp_1_mail            ,
          oGeav.hier_resp_2_nom             ,
          oGeav.hier_resp_2_mail            ,
          oGeav.rib_mode_paie               ,
          oGeav.rib_banq_1                  ,
          oGeav.rib_domi_1                  ,
          oGeav.rib_nume_1                  ,
          oGeav.rib_titu_comp_1             ,
          oGeav.rib_banq_2                  ,
          oGeav.rib_domi_2                  ,
          oGeav.rib_nume_2                  ,
          oGeav.rib_titu_comp_2             ,
          oGeav.tele_1                      ,
          oGeav.tele_2                      ,
          oGeav.tele_3                      ,
          oGeav.adre                        ,
          oGeav.dern_adre                   ,
          oGeav.adre_comp                   ,
          oGeav.dern_adre_comp              ,
          oGeav.adre_comm                   ,
          oGeav.dern_adre_comm              ,
          oGeav.adre_code_post              ,
          oGeav.dern_adre_code_post         ,
          oGeav.adre_pays                   ,
          oGeav.ccn51_anci_date_chan_appl   ,
          oGeav.ccn51_anci_taux             ,
          oGeav.ccn51_cadr_date_chan_appl   ,
          oGeav.ccn51_cadr_taux             ,
          oGeav.etp_ccn51                   ,
          oGeav.ccn51_coef_acca             ,
          oGeav.ccn51_coef_dipl             ,
          oGeav.ccn51_coef_enca             ,
          oGeav.ccn51_coef_fonc             ,
          oGeav.ccn51_coef_meti             ,
          oGeav.ccn51_coef_recl             ,
          oGeav.ccn51_coef_spec             ,
          oGeav.ccn51_id_empl_conv          ,
          oGeav.ccn5166_coef_refe           ,
          oGeav.ccn66_cate_conv             ,
          oGeav.ccn66_date_chan_coef        ,
          oGeav.ccn66_empl_conv             ,
          oGeav.ccn66_libe_empl_conv        ,
          oGeav.ccn66_fili_conv             ,
          oGeav.ccn66_prec_date_chan_coef   ,
          oGeav.ccn66_proc_coef_refe        ,
          oGeav.ccn66_regi                  ,
          oGeav.code_regi                   ,
          oGeav.libe_regi                   ,
          oGeav.orga                        ,
          oGeav.unit                        ,
          oGeav.nume_fine                   ,
          oGeav.nume_adel                   ,
          oGeav.nume_rpps                   ,
          oGeav.adre_elec                   ,
          oGeav.code_titr_form              ,
          oGeav.libe_titr_form              ,
          oGeav.date_titr_form              ,
          oGeav.lieu_titr_form              ,
          oGeav.cham_util_1                 ,
          oGeav.cham_util_2                 ,
          oGeav.cham_util_3                 ,
          oGeav.cham_util_4                 ,
          oGeav.cham_util_5                 ,
          oGeav.cham_util_6                 ,
          oGeav.cham_util_7                 ,
          oGeav.cham_util_8                 ,
          oGeav.cham_util_9                 ,
          oGeav.cham_util_10                ,
          oGeav.cham_util_11                ,
          oGeav.cham_util_12                ,
          oGeav.cham_util_13                ,
          oGeav.cham_util_14                ,
          oGeav.cham_util_15                ,
          oGeav.cham_util_16                ,
          oGeav.cham_util_17                ,
          oGeav.cham_util_18                ,
          oGeav.cham_util_19                ,
          oGeav.cham_util_20                ,
          oGeav.cham_util_21                ,
          oGeav.cham_util_22                ,
          oGeav.cham_util_23                ,
          oGeav.cham_util_24                ,
          oGeav.cham_util_25                ,
          oGeav.cham_util_26                ,
          oGeav.cham_util_27                ,
          oGeav.cham_util_28                ,
          oGeav.cham_util_29                ,
          oGeav.cham_util_30                ,
          oGeav.cham_util_31                ,
          oGeav.cham_util_32                ,
          oGeav.cham_util_33                ,
          oGeav.cham_util_34                ,
          oGeav.cham_util_35                ,
          oGeav.cham_util_36                ,
          oGeav.cham_util_37                ,
          oGeav.cham_util_38                ,
          oGeav.cham_util_39                ,
          oGeav.cham_util_40                ,
          oGeav.cham_util_41                ,
          oGeav.cham_util_42                ,
          oGeav.cham_util_43                ,
          oGeav.cham_util_44                ,
          oGeav.cham_util_45                ,
          oGeav.cham_util_46                ,
          oGeav.cham_util_47                ,
          oGeav.cham_util_48                ,
          oGeav.cham_util_49                ,
          oGeav.cham_util_50                ,
          oGeav.cham_util_51                ,
          oGeav.cham_util_52                ,
          oGeav.cham_util_53                ,
          oGeav.cham_util_54                ,
          oGeav.cham_util_55                ,
          oGeav.cham_util_56                ,
          oGeav.cham_util_57                ,
          oGeav.cham_util_58                ,
          oGeav.cham_util_59                ,
          oGeav.cham_util_60                ,
          oGeav.cham_util_61                ,
          oGeav.cham_util_62                ,
          oGeav.cham_util_63                ,
          oGeav.cham_util_64                ,
          oGeav.cham_util_65                ,
          oGeav.cham_util_66                ,
          oGeav.cham_util_67                ,
          oGeav.cham_util_68                ,
          oGeav.cham_util_69                ,
          oGeav.cham_util_70                ,
          oGeav.cham_util_71                ,
          oGeav.cham_util_72                ,
          oGeav.cham_util_73                ,
          oGeav.cham_util_74                ,
          oGeav.cham_util_75                ,
          oGeav.cham_util_76                ,
          oGeav.cham_util_77                ,
          oGeav.cham_util_78                ,
          oGeav.cham_util_79                ,
          oGeav.cham_util_80                ,
          oGeav.soci                        ,
          oGeav.rais_soci                   ,
          oGeav.soci_orig                   ,
          oGeav.fin_peri_essa               ,
          oGeav.droi_prim_anci              ,
          oGeav.bic_01                      ,
          oGeav.bic_02                      ,
          oGeav.iban_01                     ,
          oGeav.iban_02                     ,
          oGeav.code_iso_pays_nati          ,
          oGeav.repa_anal_code              ,
          oGeav.rubr_01                     ,
          oGeav.rubr_02                     ,
          oGeav.rubr_03                     ,
          oGeav.rubr_04                     ,
          oGeav.rubr_05                     ,
          oGeav.rubr_06                     ,
          oGeav.rubr_07                     ,
          oGeav.rubr_08                     ,
          oGeav.rubr_09                     ,
          oGeav.rubr_10                     ,
          oGeav.rubr_11                     ,
          oGeav.rubr_12                     ,
          oGeav.rubr_13                     ,
          oGeav.rubr_14                     ,
          oGeav.rubr_15                     ,
          oGeav.rubr_16                     ,
          oGeav.rubr_17                     ,
          oGeav.rubr_18                     ,
          oGeav.rubr_19                     ,
          oGeav.rubr_20                     ,
          oGeav.rubr_21                     ,
          oGeav.rubr_22                     ,
          oGeav.rubr_23                     ,
          oGeav.rubr_24                     ,
          oGeav.rubr_25                     ,
          oGeav.rubr_26                     ,
          oGeav.rubr_27                     ,
          oGeav.rubr_28                     ,
          oGeav.rubr_29                     ,
          oGeav.rubr_30                     ,
          oGeav.rubr_31                     ,
          oGeav.rubr_32                     ,
          oGeav.rubr_33                     ,
          oGeav.rubr_34                     ,
          oGeav.rubr_35                     ,
          oGeav.rubr_36                     ,
          oGeav.rubr_37                     ,
          oGeav.rubr_38                     ,
          oGeav.rubr_39                     ,
          oGeav.rubr_40                     ,
          oGeav.rubr_41                     ,
          oGeav.rubr_42                     ,
          oGeav.rubr_43                     ,
          oGeav.rubr_44                     ,
          oGeav.rubr_45                     ,
          oGeav.rubr_46                     ,
          oGeav.rubr_47                     ,
          oGeav.rubr_48                     ,
          oGeav.rubr_49                     ,
          oGeav.rubr_50                     ,

          oGeav.rubr_51                     ,
          oGeav.rubr_52                     ,
          oGeav.rubr_53                     ,
          oGeav.rubr_54                     ,
          oGeav.rubr_55                     ,
          oGeav.rubr_56                     ,
          oGeav.rubr_57                     ,
          oGeav.rubr_58                     ,
          oGeav.rubr_59                     ,
          oGeav.rubr_60                     ,
          oGeav.rubr_61                     ,
          oGeav.rubr_62                     ,
          oGeav.rubr_63                     ,
          oGeav.rubr_64                     ,
          oGeav.rubr_65                     ,
          oGeav.rubr_66                     ,
          oGeav.rubr_67                     ,
          oGeav.rubr_68                     ,
          oGeav.rubr_69                     ,
          oGeav.rubr_70                     ,
          oGeav.rubr_71                     ,
          oGeav.rubr_72                     ,
          oGeav.rubr_73                     ,
          oGeav.rubr_74                     ,
          oGeav.rubr_75                     ,
          oGeav.rubr_76                     ,
          oGeav.rubr_77                     ,
          oGeav.rubr_78                     ,
          oGeav.rubr_79                     ,
          oGeav.rubr_80                     ,
          oGeav.rubr_81                     ,
          oGeav.rubr_82                     ,
          oGeav.rubr_83                     ,
          oGeav.rubr_84                     ,
          oGeav.rubr_85                     ,
          oGeav.rubr_86                     ,
          oGeav.rubr_87                     ,
          oGeav.rubr_88                     ,
          oGeav.rubr_89                     ,
          oGeav.rubr_90                     ,
          oGeav.rubr_91                     ,
          oGeav.rubr_92                     ,
          oGeav.rubr_93                     ,
          oGeav.rubr_94                     ,
          oGeav.rubr_95                     ,
          oGeav.rubr_96                     ,
          oGeav.rubr_97                     ,
          oGeav.rubr_98                     ,
          oGeav.rubr_99                     ,
          oGeav.rubr_100                    ,
          oGeav.rubr_101                    ,
          oGeav.rubr_102                    ,
          oGeav.rubr_103                    ,
          oGeav.rubr_104                    ,
          oGeav.rubr_105                    ,
          oGeav.rubr_106                    ,
          oGeav.rubr_107                    ,
          oGeav.rubr_108                    ,
          oGeav.rubr_109                    ,
          oGeav.rubr_110                    ,
          oGeav.rubr_111                    ,
          oGeav.rubr_112                    ,
          oGeav.rubr_113                    ,
          oGeav.rubr_114                    ,
          oGeav.rubr_115                    ,
          oGeav.rubr_116                    ,
          oGeav.rubr_117                    ,
          oGeav.rubr_118                    ,
          oGeav.rubr_119                    ,
          oGeav.rubr_120                    ,
          oGeav.rubr_121                    ,
          oGeav.rubr_122                    ,
          oGeav.rubr_123                    ,
          oGeav.rubr_124                    ,
          oGeav.rubr_125                    ,
          oGeav.rubr_126                    ,
          oGeav.rubr_127                    ,
          oGeav.rubr_128                    ,
          oGeav.rubr_129                    ,
          oGeav.rubr_130                    ,
          oGeav.rubr_131                    ,
          oGeav.rubr_132                    ,
          oGeav.rubr_133                    ,
          oGeav.rubr_134                    ,
          oGeav.rubr_135                    ,
          oGeav.rubr_136                    ,
          oGeav.rubr_137                    ,
          oGeav.rubr_138                    ,
          oGeav.rubr_139                    ,
          oGeav.rubr_140                    ,
          oGeav.rubr_141                    ,
          oGeav.rubr_142                    ,
          oGeav.rubr_143                    ,
          oGeav.rubr_144                    ,
          oGeav.rubr_145                    ,
          oGeav.rubr_146                    ,
          oGeav.rubr_147                    ,
          oGeav.rubr_148                    ,
          oGeav.rubr_149                    ,
          oGeav.rubr_150                    ,

          oGeav.cons_01                     ,
          oGeav.cons_02                     ,
          oGeav.cons_03                     ,
          oGeav.cons_04                     ,
          oGeav.cons_05                     ,
          oGeav.cons_06                     ,
          oGeav.cons_07                     ,
          oGeav.cons_08                     ,
          oGeav.cons_09                     ,
          oGeav.cons_10                     ,
          oGeav.cons_11                     ,
          oGeav.cons_12                     ,
          oGeav.cons_13                     ,
          oGeav.cons_14                     ,
          oGeav.cons_15                     ,
          oGeav.cons_16                     ,
          oGeav.cons_17                     ,
          oGeav.cons_18                     ,
          oGeav.cons_19                     ,
          oGeav.cons_20                     ,

          oGeav.cons_21                     ,
          oGeav.cons_22                     ,
          oGeav.cons_23                     ,
          oGeav.cons_24                     ,
          oGeav.cons_25                     ,
          oGeav.cons_26                     ,
          oGeav.cons_27                     ,
          oGeav.cons_28                     ,
          oGeav.cons_29                     ,
          oGeav.cons_30                     ,
          oGeav.cons_31                     ,
          oGeav.cons_32                     ,
          oGeav.cons_33                     ,
          oGeav.cons_34                     ,
          oGeav.cons_35                     ,
          oGeav.cons_36                     ,
          oGeav.cons_37                     ,
          oGeav.cons_38                     ,
          oGeav.cons_39                     ,
          oGeav.cons_40                     ,
          oGeav.cons_41                     ,
          oGeav.cons_42                     ,
          oGeav.cons_43                     ,
          oGeav.cons_44                     ,
          oGeav.cons_45                     ,
          oGeav.cons_46                     ,
          oGeav.cons_47                     ,
          oGeav.cons_48                     ,
          oGeav.cons_49                     ,
          oGeav.cons_50                     ,

          oGeav.calc_01                     ,
          oGeav.calc_02                     ,
          oGeav.calc_03                     ,
          oGeav.calc_04                     ,
          oGeav.calc_05                     ,
          oGeav.calc_06                     ,
          oGeav.calc_07                     ,
          oGeav.calc_08                     ,
          oGeav.calc_09                     ,
          oGeav.calc_10                     ,
          oGeav.calc_11                     ,
          oGeav.calc_12                     ,
          oGeav.calc_13                     ,
          oGeav.calc_14                     ,
          oGeav.calc_15                     ,
          oGeav.calc_16                     ,
          oGeav.calc_17                     ,
          oGeav.calc_18                     ,
          oGeav.calc_19                     ,
          oGeav.calc_20                     ,
          oGeav.dern_sala_base              ,
          oGeav.dern_sala_base_annu         ,
          oGeav.dern_hora                   ,
          oGeav.sala_forf_temp              ,
          oGeav.nomb_jour_forf_temp         ,
          oGeav.nomb_heur_forf_temp         ,
          oGeav.nomb_mois                   ,
          oGeav.sala_annu_cont              ,
          oGeav.code_fine_geog              ,
          oGeav.rib_guic_1                  ,
          oGeav.rib_comp_1                  ,
          oGeav.rib_cle_1                   ,
          oGeav.rib_banq_01                 ,
          oGeav.rib_banq_02                 ,
          oGeav.prof_temp_libe              ,
          oGeav.nomb_jour_cong_anci         ,
          oGeav.mont_anci_pa                ,
          oGeav.anci_cadr                   ,
          oGeav.tota_heur_trav              ,
          oGeav.DPAE_ENVO                   ,
          oGeav.DISP_POLI_PUBL_CONV         ,
          oGeav.DATE_ANCI_CADR_FORF 

      );
   end loop;
   commit;

   pr_etat_pile_fin(iID_SOCI,iID_LOGI,vETAT);
   pack_syst_suiv_proc.terminer_suivi (
     pID_SUIV_PROC => iID_SUIV_PROC
   );

exception
   when accessibility.access_exception  then
      pr_etat_pile_errtools_info (iID_SOCI,iID_LOGI,vETAT,accessibility.message);
      pr_etat_pile_errtools_alert(iID_SOCI,iID_LOGI,vETAT,accessibility.message);
      commit;
      pr_etat_pile_fin(iID_SOCI,iID_LOGI,vETAT);

      pack_syst_suiv_proc.terminer_suivi (
        pID_SUIV_PROC => iID_SUIV_PROC
      );
   when others then

      pr_etat_pile_log           (iID_SOCI,iID_LOGI,vETAT,'Erreur dans l''execution du processus décalé : [' || sqlcode||'] '||sqlerrm||chr(10)||dbms_utility.format_error_backtrace);
      dbms_output.put_line('BUG !!! Erreur dans l''execution du processus décalé : ' || dbms_utility.format_error_backtrace );

      pack_syst_suiv_proc.terminer_suivi (
        pID_SUIV_PROC => iID_SUIV_PROC
      );

end pr_traitegen_job_geav;