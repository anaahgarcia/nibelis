create or replace procedure pr_impo_excel_salaries_cong (
  -- Modi EN 2022 12 07 T178193: ajout des compteurs supplémentaires 04 à 07 (COSU_04_xx, COSU_05_xx, COSU_06_xx, COSU_07_xx)
  -- Modi AB 2021 02 17 T118184: ajout périodes N-1 et N-2 pour les 3 compteurs supplémentaires:
  --                             COSU_01_ACQU_ANNE_N1,COSU_01_PRIS_ANNE_N1,COSU_01_REST_N1,  COSU_01_ACQU_ANNE_N2,COSU_01_PRIS_ANNE_N2,COSU_01_REST_N2,
  --                             COSU_02_ACQU_ANNE_N1,COSU_02_PRIS_ANNE_N1,COSU_02_REST_N1,  COSU_02_ACQU_ANNE_N2,COSU_02_PRIS_ANNE_N2,COSU_02_REST_N2,
  --                             COSU_03_ACQU_ANNE_N1,COSU_03_PRIS_ANNE_N1,COSU_03_REST_N1,  COSU_03_ACQU_ANNE_N2,COSU_03_PRIS_ANNE_N2,COSU_03_REST_N2
  -- Modi EN 2019 05 14 T80556 : ajout des RCR et RCN (RCRACQUIANN, RCRPRISAN, RCRCUM, RCNACQUIANN, RCNPRISAN, RCNCUM)
  -- Modi EN 2019 05 10 T80556 : ajout des RTT supplémentaires et des 3 compteurs supplémentaires (RTTANSUP, RTTPRIANNSUP, RTTAPRESUP, COSU_01_ACQU_ANNE, COSU_01_PRIS_ANNE, COSU_01_REST, COSU_02_ACQU_ANNE, COSU_02_PRIS_ANNE, COSU_02_REST, COSU_03_ACQU_ANNE, COSU_03_PRIS_ANNE, COSU_03_REST)
  -- Modi ML 2018 04 12 T69964 : Ajout d import de RTTREPRIS, RTT_SALA_REST_CLOT, RTTAPREPAT, RTTREPRISPAT et RTT_PATR_REST_CLOT
  -- Modi ML 2018 04 06 T69798 : modification de la valeur mini envoyée à pr_cvs (0 remplacé par -9999999999)
  pID_IMPO in varchar2,
  pID_SOCI in varchar2,
  pID_LOGI in varchar2,
  pMAJ_DONN in varchar2,
  pTYPE_RECH_SALA in varchar2,
  Err          out int     ,
  ErrInfo      out varchar2,
  pID_New      out varchar2)

is
  --- @\pr_impo_excel_salaries_cong.sql
   -- exec  pr_impo_excel_salaries_cong(216,983,1);

--      Err           varchar2(500);
--      ErrInfo       varchar2(500);
--      pID_New       varchar2(500);

-----   CP_INDE_MONT_N0_PREC Récupération indemnités N   - Précédent
-----   CP_INDE_MONT_N1_PREC Récupération indemnités N-1 - Précédent
-----   CP_INDE_MONT_N2_PREC Récupération indemnités N-2 - Précédent
-----   CP_INDE_MONT_N3_PREC Récupération indemnités N-3 - Précédent
-----   CP_INDE_MONT_N4_PREC Récupération indemnités N-4 - Précédent

---    Sur une période d'acquisition, si la somme des congés acquis est différente de la somme des congés restants, il faut que le montant perçu soit renseigné :
---    si  CONGACn_LEGA  + CONGACn_ANCI_1  + CONGACn_ANCI_2  + CONGACn_ANCI_3  + CONGACn_FRAC
---    !=  CONGAPRn_LEGA + CONGAPRn_ANCI_1 + CONGAPRn_ANCI_2 + CONGAPRn_ANCI_3 + CONGAPRn_FRAC
---    alors CP_INDE_MONT_Nn_PREC doit être renseigné
---
---    Une approche plus simple - bien qu'elle "corrompe" les données pourrait être :
---    si CONGAPRn_LEGA + CONGAPRn_ANCI_1 + CONGAPRn_ANCI_2 + CONGAPRn_ANCI_3 + CONGAPRn_FRAC = ZERO
---    alors BRUTCONGn = ZERO

  rSala_Impo_Cong         SALARIE_IMPO_CONG%rowtype;
  rSala_Impo_Cong_Cree    SALARIE_IMPO_CONG%rowtype;
  rSala_Impo_Cong_Colo    SALARIE_IMPO_CONG_COLO%rowtype;

  --definition des variables
-- pID_ETAB                    number;
  pID_SALA                    number;
  pID_GROU                    number;
  nID_MODBULL                 number;
  iid_sala_pres               number;
  inomb_sala_pres             number;

  iNUME_LIGN                  int;
  iID_LOT                     int;

  dPERI_COUR                  date;
  dDATE_NAIS                  date;
  dDATE_IMPO                  date;

  Err_Log    int;


  iID_SALA    number;
  NbID_SALA   int;
  id          number;
  pPERI_IMPO     varchar2(50);
  pPERI_COUR    varchar2(50);

  n        int;
  iCount      int;

  pNOM_SOCI   varchar2(200);
  pPERI       varchar2(200);

  iSALA_ID_SOCI           number;
  vSALA_ID_SOCI           varchar2(200);
  vSALA_RAIS_SOCI         varchar2(200);
  pMATR                   varchar2(200);
  pNOM                    varchar2(200);
  pPREN                   varchar2(200);

  pBRUTPREC4                 varchar2(100) ;
  pCONGAC4_LEGA              varchar2(100) ;
  pCONGAPRE4_LEGA            varchar2(100) ;
  pCONGAC4_ANCI_1            varchar2(100) ;
  pCONGAPRE4_ANCI_1          varchar2(100) ;
  pCONGAC4_ANCI_2            varchar2(100) ;
  pCONGAPRE4_ANCI_2          varchar2(100) ;
  pCONGAC4_ANCI_3            varchar2(100) ;
  pCONGAPRE4_ANCI_3          varchar2(100) ;
  pCONGAC4_FRAC              varchar2(100) ;
  pCONGAPRE4_FRAC            varchar2(100) ;
  pBRUTPREC3                 varchar2(100) ;
  pCONGAC3_LEGA              varchar2(100) ;
  pCONGAPRE3_LEGA            varchar2(100) ;
  pCONGAC3_ANCI_1            varchar2(100) ;
  pCONGAPRE3_ANCI_1          varchar2(100) ;
  pCONGAC3_ANCI_2            varchar2(100) ;
  pCONGAPRE3_ANCI_2          varchar2(100) ;
  pCONGAC3_ANCI_3            varchar2(100) ;
  pCONGAPRE3_ANCI_3          varchar2(100) ;
  pCONGAC3_FRAC              varchar2(100) ;
  pCONGAPRE3_FRAC            varchar2(100) ;
  pBRUTPREC2                 varchar2(100) ;
  pCONGAC2_LEGA              varchar2(100) ;
  pCONGAPRE2_LEGA            varchar2(100) ;
  pCONGAC2_ANCI_1            varchar2(100) ;
  pCONGAPRE2_ANCI_1          varchar2(100) ;
  pCONGAC2_ANCI_2            varchar2(100) ;
  pCONGAPRE2_ANCI_2          varchar2(100) ;
  pCONGAC2_ANCI_3            varchar2(100) ;
  pCONGAPRE2_ANCI_3          varchar2(100) ;
  pCONGAC2_FRAC              varchar2(100) ;
  pCONGAPRE2_FRAC            varchar2(100) ;
  pBRUTPREC1                 varchar2(100) ;
  pCONGAC1_LEGA              varchar2(100) ;
  pCONGAPRE1_LEGA            varchar2(100) ;
  pCONGAC1_ANCI_1            varchar2(100) ;
  pCONGAPRE1_ANCI_1          varchar2(100) ;
  pCONGAC1_ANCI_2            varchar2(100) ;
  pCONGAPRE1_ANCI_2          varchar2(100) ;
  pCONGAC1_ANCI_3            varchar2(100) ;
  pCONGAPRE1_ANCI_3          varchar2(100) ;
  pCONGAC1_FRAC              varchar2(100) ;
  pCONGAPRE1_FRAC            varchar2(100) ;
  pBRUTPREC0                 varchar2(100) ;
  pCOACOURS_LEGA             varchar2(100) ;
  pCONGAPRE0_LEGA            varchar2(100) ;
  pCOACOURS_ANCI_1           varchar2(100) ;
  pCONGAPRE0_ANCI_1          varchar2(100) ;
  pCOACOURS_ANCI_2           varchar2(100) ;
  pCONGAPRE0_ANCI_2          varchar2(100) ;
  pCOACOURS_ANCI_3           varchar2(100) ;
  pCONGAPRE0_ANCI_3          varchar2(100) ;
  pCOACOURS_FRAC             varchar2(100) ;
  pCONGAPRE0_FRAC            varchar2(100) ;
  pBRUTPRECM1                varchar2(100) ;

  pCP_INDE_MONT_N0_PREC VARCHAR2(100);
  pCP_INDE_MONT_N1_PREC VARCHAR2(100);
  pCP_INDE_MONT_N2_PREC VARCHAR2(100);
  pCP_INDE_MONT_N3_PREC VARCHAR2(100);
  pCP_INDE_MONT_N4_PREC VARCHAR2(100);

  pRTTAN                  varchar2(200);
  pRTTPRIANN              varchar2(200);
  pRTTAPRE                varchar2(200);
  pRTTREPRIS              varchar2(200);
  pRTT_SALA_REST_CLOT     varchar2(200);
  pRTTANPAT               varchar2(200);
  pRTTPRIANNPAT           varchar2(200);
  pRTTAPREPAT             varchar2(200);
  pRTTREPRISPAT           varchar2(200);
  pRTT_PATR_REST_CLOT     varchar2(200);
  pCETACQRTTPATANN        varchar2(200);
  pCETPRIRTTPATANN        varchar2(200);
  pCETACQRTTSALANN        varchar2(200);
  pCETPRIRTTSALANN        varchar2(200);
  pCETACQCPANN            varchar2(200);
  pCETPRICPANN            varchar2(200);
  pCETRESCP               varchar2(200);
  pCETRESRTTPAT           varchar2(200);
  pCETRESRTTSAL           varchar2(200);
  pCETACQCPNOMOANN        varchar2(200);
  pCETPRICPNOMOANN        varchar2(200);
  pCETRESCPNOMO           varchar2(200);
  pREPACQUI               varchar2(200);
  pREPOPRISAN             varchar2(200);
  pREPOSCUM               varchar2(200);


  pBRUTPREC4_COLO                 varchar2(100) ;
  pCONGAC4_LEGA_COLO              varchar2(100) ;
  pCONGAPRE4_LEGA_COLO            varchar2(100) ;
  pCONGAC4_ANCI_1_COLO            varchar2(100) ;
  pCONGAPRE4_ANCI_1_COLO          varchar2(100) ;
  pCONGAC4_ANCI_2_COLO            varchar2(100) ;
  pCONGAPRE4_ANCI_2_COLO          varchar2(100) ;
  pCONGAC4_ANCI_3_COLO            varchar2(100) ;
  pCONGAPRE4_ANCI_3_COLO          varchar2(100) ;
  pCONGAC4_FRAC_COLO              varchar2(100) ;
  pCONGAPRE4_FRAC_COLO            varchar2(100) ;
  pBRUTPREC3_COLO                 varchar2(100) ;
  pCONGAC3_LEGA_COLO              varchar2(100) ;
  pCONGAPRE3_LEGA_COLO            varchar2(100) ;
  pCONGAC3_ANCI_1_COLO            varchar2(100) ;
  pCONGAPRE3_ANCI_1_COLO          varchar2(100) ;
  pCONGAC3_ANCI_2_COLO            varchar2(100) ;
  pCONGAPRE3_ANCI_2_COLO          varchar2(100) ;
  pCONGAC3_ANCI_3_COLO            varchar2(100) ;
  pCONGAPRE3_ANCI_3_COLO          varchar2(100) ;
  pCONGAC3_FRAC_COLO              varchar2(100) ;
  pCONGAPRE3_FRAC_COLO            varchar2(100) ;
  pBRUTPREC2_COLO                 varchar2(100) ;
  pCONGAC2_LEGA_COLO              varchar2(100) ;
  pCONGAPRE2_LEGA_COLO            varchar2(100) ;
  pCONGAC2_ANCI_1_COLO            varchar2(100) ;
  pCONGAPRE2_ANCI_1_COLO          varchar2(100) ;
  pCONGAC2_ANCI_2_COLO            varchar2(100) ;
  pCONGAPRE2_ANCI_2_COLO          varchar2(100) ;
  pCONGAC2_ANCI_3_COLO            varchar2(100) ;
  pCONGAPRE2_ANCI_3_COLO          varchar2(100) ;
  pCONGAC2_FRAC_COLO              varchar2(100) ;
  pCONGAPRE2_FRAC_COLO            varchar2(100) ;
  pBRUTPREC1_COLO                 varchar2(100) ;
  pCONGAC1_LEGA_COLO              varchar2(100) ;
  pCONGAPRE1_LEGA_COLO            varchar2(100) ;
  pCONGAC1_ANCI_1_COLO            varchar2(100) ;
  pCONGAPRE1_ANCI_1_COLO          varchar2(100) ;
  pCONGAC1_ANCI_2_COLO            varchar2(100) ;
  pCONGAPRE1_ANCI_2_COLO          varchar2(100) ;
  pCONGAC1_ANCI_3_COLO            varchar2(100) ;
  pCONGAPRE1_ANCI_3_COLO          varchar2(100) ;
  pCONGAC1_FRAC_COLO              varchar2(100) ;
  pCONGAPRE1_FRAC_COLO            varchar2(100) ;
  pBRUTPREC0_COLO                 varchar2(100) ;
  pCOACOURS_LEGA_COLO             varchar2(100) ;
  pCONGAPRE0_LEGA_COLO            varchar2(100) ;
  pCOACOURS_ANCI_1_COLO           varchar2(100) ;
  pCONGAPRE0_ANCI_1_COLO          varchar2(100) ;
  pCOACOURS_ANCI_2_COLO           varchar2(100) ;
  pCONGAPRE0_ANCI_2_COLO          varchar2(100) ;
  pCOACOURS_ANCI_3_COLO           varchar2(100) ;
  pCONGAPRE0_ANCI_3_COLO          varchar2(100) ;
  pCOACOURS_FRAC_COLO             varchar2(100) ;
  pCONGAPRE0_FRAC_COLO            varchar2(100) ;
  pBRUTPRECM1_COLO                varchar2(100) ;

  pCP_INDE_MONT_N0_PREC_COLO VARCHAR2(100);
  pCP_INDE_MONT_N1_PREC_COLO VARCHAR2(100);
  pCP_INDE_MONT_N2_PREC_COLO VARCHAR2(100);
  pCP_INDE_MONT_N3_PREC_COLO VARCHAR2(100);
  pCP_INDE_MONT_N4_PREC_COLO VARCHAR2(100);

  pRTTAN_COLO                  varchar2(200);
  pRTTPRIANN_COLO              varchar2(200);
  pRTTAPRE_COLO                varchar2(200);
  pRTTREPRIS_COLO              varchar2(200);
  pRTT_SALA_REST_CLOT_COLO     varchar2(200);
  pRTTANPAT_COLO               varchar2(200);
  pRTTPRIANNPAT_COLO           varchar2(200);
  pRTTAPREPAT_COLO             varchar2(200);
  pRTTREPRISPAT_COLO           varchar2(200);
  pRTT_PATR_REST_CLOT_COLO     varchar2(200);
  pCETACQRTTPATANN_COLO        varchar2(200);
  pCETPRIRTTPATANN_COLO        varchar2(200);
  pCETACQRTTSALANN_COLO        varchar2(200);
  pCETPRIRTTSALANN_COLO        varchar2(200);
  pCETACQCPANN_COLO            varchar2(200);
  pCETPRICPANN_COLO            varchar2(200);
  pCETRESCP_COLO               varchar2(200);
  pCETRESRTTPAT_COLO           varchar2(200);
  pCETRESRTTSAL_COLO           varchar2(200);
  pCETACQCPNOMOANN_COLO        varchar2(200);
  pCETPRICPNOMOANN_COLO        varchar2(200);
  pCETRESCPNOMO_COLO           varchar2(200);
  pREPACQUI_COLO               varchar2(200);
  pREPOPRISAN_COLO             varchar2(200);
  pREPOSCUM_COLO               varchar2(200);


  NewBRUTPREC4                 float;
  NewCONGAC4_LEGA              float;
  NewCONGAPRE4_LEGA            float;
  NewCONGAC4_ANCI_1            float;
  NewCONGAPRE4_ANCI_1          float;
  NewCONGAC4_ANCI_2            float;
  NewCONGAPRE4_ANCI_2          float;
  NewCONGAC4_ANCI_3            float;
  NewCONGAPRE4_ANCI_3          float;
  NewCONGAC4_FRAC              float;
  NewCONGAPRE4_FRAC            float;
  NewBRUTPREC3                 float;
  NewCONGAC3_LEGA              float;
  NewCONGAPRE3_LEGA            float;
  NewCONGAC3_ANCI_1            float;
  NewCONGAPRE3_ANCI_1          float;
  NewCONGAC3_ANCI_2            float;
  NewCONGAPRE3_ANCI_2          float;
  NewCONGAC3_ANCI_3            float;
  NewCONGAPRE3_ANCI_3          float;
  NewCONGAC3_FRAC              float;
  NewCONGAPRE3_FRAC            float;
  NewBRUTPREC2                 float;
  NewCONGAC2_LEGA              float;
  NewCONGAPRE2_LEGA            float;
  NewCONGAC2_ANCI_1            float;
  NewCONGAPRE2_ANCI_1          float;
  NewCONGAC2_ANCI_2            float;
  NewCONGAPRE2_ANCI_2          float;
  NewCONGAC2_ANCI_3            float;
  NewCONGAPRE2_ANCI_3          float;
  NewCONGAC2_FRAC              float;
  NewCONGAPRE2_FRAC            float;
  NewBRUTPREC1                 float;
  NewCONGAC1_LEGA              float;
  NewCONGAPRE1_LEGA            float;
  NewCONGAC1_ANCI_1            float;
  NewCONGAPRE1_ANCI_1          float;
  NewCONGAC1_ANCI_2            float;
  NewCONGAPRE1_ANCI_2          float;
  NewCONGAC1_ANCI_3            float;
  NewCONGAPRE1_ANCI_3          float;
  NewCONGAC1_FRAC              float;
  NewCONGAPRE1_FRAC            float;
  NewBRUTPREC0                 float;
  NewCOACOURS_LEGA             float;
  NewCONGAPRE0_LEGA            float;
  NewCOACOURS_ANCI_1           float;
  NewCONGAPRE0_ANCI_1          float;
  NewCOACOURS_ANCI_2           float;
  NewCONGAPRE0_ANCI_2          float;
  NewCOACOURS_ANCI_3           float;
  NewCONGAPRE0_ANCI_3          float;
  NewCOACOURS_FRAC             float;
  NewCONGAPRE0_FRAC            float;
  NewBRUTPRECM1                float;

  NewCP_INDE_MONT_N0_PREC      float;
  NewCP_INDE_MONT_N1_PREC      float;
  NewCP_INDE_MONT_N2_PREC      float;
  NewCP_INDE_MONT_N3_PREC      float;
  NewCP_INDE_MONT_N4_PREC      float;

  NewRTTAN              float;
  NewRTTPRIANN          float;
  NewRTTAPRE            float;
  NewRTTREPRIS          float;
  NewRTT_SALA_REST_CLOT float;
  NewRTTANPAT           float;
  NewRTTPRIANNPAT       float;
  NewRTTAPREPAT         float;
  NewRTTREPRISPAT       float;
  NewRTT_PATR_REST_CLOT float;
  NewCETACQRTTPATANN    float;
  NewCETACQRTTSALANN    float;
  NewCETACQCPANN        float;
  NewCETPRIRTTPATANN    float;
  NewCETPRIRTTSALANN    float;
  NewCETPRICPANN        float;
  NewCETRESCP           float;
  NewCETRESRTTPAT       float;
  NewCETRESRTTSAL       float;
  NewCETACQCPNOMOANN    float;
  NewCETPRICPNOMOANN    float;
  NewCETRESCPNOMO       float;
  NewREPACQUI           float;
  NewREPOPRISAN        float;
  NewREPOSCUM           float;
  pRTTACQMOIS           float;

  pSTAT_IMPO  varchar2(200);
  pERR_IMPO   varchar2(200);
  pERR        varchar2(200);
  pDATE_IMPO  varchar2(200);
  pTEMP_IMPO  varchar2(200);

  iPos int;
  vLIGN varchar2(4000);
  NewVALE         varchar2(1000);
  pRECH varchar2(100);
  pMAJ varchar2(10);

  TYPE tableau is table of varchar2(1000) index by binary_integer;
  pTABL_ZONE_IMPO tableau;
  pTABL_VALE_IMPO tableau;

  pZONE int;
  pTYPE_ENRE  VARCHAR2(100);
  pVALE     VARCHAR2(100);
  pCODE_ZONE  VARCHAR2(2000);
  pZONE_TROU  number;
  pID_SOCI_FICH varchar2(100);
  INB_SOCI int;
  pERRE  int;

  pNOMB_ERRE_SALA  number;
  pID_ERRE         number;
  pNOM_ETAB        varchar2(500);
  Inb_Sala int;
  iNB_Nom_Pren           int;
  iNB_Nom_Pren_Matr      int;
  iNB_Nom_Matr           int;
  bError boolean;

  pDERN_CARA varchar2(1);
  pMAJ_SALA varchar2(1);
  pID_LOG  number;

  vREST_ENCO_LEGA         varchar2(1);
  vREST_ENCO_ANCI_1       varchar2(1);
  vREST_ENCO_ANCI_2       varchar2(1);
  vREST_ENCO_ANCI_3       varchar2(1);
  vREST_ENCO_FRAC         varchar2(1);
  fCONG_LEGA_REST_N0      float;
  fCONG_ANCI_1_REST_N0    float;
  fCONG_ANCI_2_REST_N0    float;
  fCONG_ANCI_3_REST_N0    float;
  fCONG_FRAC_REST_N0      float;
  fCONG_LEGA_REST         float;
  fCONG_ANCI_1_REST       float;
  fCONG_ANCI_2_REST       float;
  fCONG_ANCI_3_REST       float;
  fCONG_FRAC_REST         float;

  -- compteurs supplémentaires, RCR, RCN (T80556)
  pRTTANSUP               varchar2(200);
  pRTTPRIANNSUP           varchar2(200);
  pRTTAPRESUP             varchar2(200);
  pCOSU_01_ACQU_ANNE      varchar2(200);
  pCOSU_01_PRIS_ANNE      varchar2(200);
  pCOSU_01_REST           varchar2(200);
  pCOSU_02_ACQU_ANNE      varchar2(200);
  pCOSU_02_PRIS_ANNE      varchar2(200);
  pCOSU_02_REST           varchar2(200);
  pCOSU_03_ACQU_ANNE      varchar2(200);
  pCOSU_03_PRIS_ANNE      varchar2(200);
  pCOSU_03_REST           varchar2(200);

  pCOSU_01_ACQU_ANNE_N1   varchar2(200);
  pCOSU_01_PRIS_ANNE_N1   varchar2(200);
  pCOSU_01_REST_N1        varchar2(200);
  pCOSU_01_ACQU_ANNE_N2   varchar2(200);
  pCOSU_01_PRIS_ANNE_N2   varchar2(200);
  pCOSU_01_REST_N2        varchar2(200);
  pCOSU_02_ACQU_ANNE_N1   varchar2(200);
  pCOSU_02_PRIS_ANNE_N1   varchar2(200);
  pCOSU_02_REST_N1        varchar2(200);
  pCOSU_02_ACQU_ANNE_N2   varchar2(200);
  pCOSU_02_PRIS_ANNE_N2   varchar2(200);
  pCOSU_02_REST_N2        varchar2(200);
  pCOSU_03_ACQU_ANNE_N1   varchar2(200);
  pCOSU_03_PRIS_ANNE_N1   varchar2(200);
  pCOSU_03_REST_N1        varchar2(200);
  pCOSU_03_ACQU_ANNE_N2   varchar2(200);
  pCOSU_03_PRIS_ANNE_N2   varchar2(200);
  pCOSU_03_REST_N2        varchar2(200);

  pCOSU_04_ACQU_ANNE      varchar2(200);
  pCOSU_04_PRIS_ANNE      varchar2(200);
  pCOSU_04_REST           varchar2(200);
  pCOSU_04_ACQU_ANNE_N1   varchar2(200);
  pCOSU_04_PRIS_ANNE_N1   varchar2(200);
  pCOSU_04_REST_N1        varchar2(200);
  pCOSU_04_ACQU_ANNE_N2   varchar2(200);
  pCOSU_04_PRIS_ANNE_N2   varchar2(200);
  pCOSU_04_REST_N2        varchar2(200);

  pCOSU_05_ACQU_ANNE      varchar2(200);
  pCOSU_05_PRIS_ANNE      varchar2(200);
  pCOSU_05_REST           varchar2(200);
  pCOSU_05_ACQU_ANNE_N1   varchar2(200);
  pCOSU_05_PRIS_ANNE_N1   varchar2(200);
  pCOSU_05_REST_N1        varchar2(200);
  pCOSU_05_ACQU_ANNE_N2   varchar2(200);
  pCOSU_05_PRIS_ANNE_N2   varchar2(200);
  pCOSU_05_REST_N2        varchar2(200);

  pCOSU_06_ACQU_ANNE      varchar2(200);
  pCOSU_06_PRIS_ANNE      varchar2(200);
  pCOSU_06_REST           varchar2(200);
  pCOSU_06_ACQU_ANNE_N1   varchar2(200);
  pCOSU_06_PRIS_ANNE_N1   varchar2(200);
  pCOSU_06_REST_N1        varchar2(200);
  pCOSU_06_ACQU_ANNE_N2   varchar2(200);
  pCOSU_06_PRIS_ANNE_N2   varchar2(200);
  pCOSU_06_REST_N2        varchar2(200);

  pCOSU_07_ACQU_ANNE      varchar2(200);
  pCOSU_07_PRIS_ANNE      varchar2(200);
  pCOSU_07_REST           varchar2(200);
  pCOSU_07_ACQU_ANNE_N1   varchar2(200);
  pCOSU_07_PRIS_ANNE_N1   varchar2(200);
  pCOSU_07_REST_N1        varchar2(200);
  pCOSU_07_ACQU_ANNE_N2   varchar2(200);
  pCOSU_07_PRIS_ANNE_N2   varchar2(200);
  pCOSU_07_REST_N2        varchar2(200);

  pRCRACQUIANN            varchar2(200);
  pRCRPRISAN              varchar2(200);
  pRCRCUM                 varchar2(200);
  pRCNACQUIANN            varchar2(200);
  pRCNPRISAN              varchar2(200);
  pRCNCUM                 varchar2(200);

  pCOACOURS_LEGA_THEO     varchar2(200);
  pCONGAC1_LEGA_THEO      varchar2(200);
  pCONGAC2_LEGA_THEO      varchar2(200);
  pCONGAC3_LEGA_THEO      varchar2(200);
  pCONGAC4_LEGA_THEO      varchar2(200);

  NewRTTANSUP             float;
  NewRTTPRIANNSUP         float;
  NewRTTAPRESUP           float;
  NewCOSU_01_ACQU_ANNE    float;
  NewCOSU_01_PRIS_ANNE    float;
  NewCOSU_01_REST         float;
  NewCOSU_02_ACQU_ANNE    float;
  NewCOSU_02_PRIS_ANNE    float;
  NewCOSU_02_REST         float;
  NewCOSU_03_ACQU_ANNE    float;
  NewCOSU_03_PRIS_ANNE    float;
  NewCOSU_03_REST         float;

  NewCOSU_01_ACQU_ANNE_N1 float;
  NewCOSU_01_PRIS_ANNE_N1 float;
  NewCOSU_01_REST_N1      float;
  NewCOSU_02_ACQU_ANNE_N1 float;
  NewCOSU_02_PRIS_ANNE_N1 float;
  NewCOSU_02_REST_N1      float;
  NewCOSU_03_ACQU_ANNE_N1 float;
  NewCOSU_03_PRIS_ANNE_N1 float;
  NewCOSU_03_REST_N1      float;
  NewCOSU_01_ACQU_ANNE_N2 float;
  NewCOSU_01_PRIS_ANNE_N2 float;
  NewCOSU_01_REST_N2      float;
  NewCOSU_02_ACQU_ANNE_N2 float;
  NewCOSU_02_PRIS_ANNE_N2 float;
  NewCOSU_02_REST_N2      float;
  NewCOSU_03_ACQU_ANNE_N2 float;
  NewCOSU_03_PRIS_ANNE_N2 float;
  NewCOSU_03_REST_N2      float;

  NewCOSU_04_ACQU_ANNE    float;
  NewCOSU_04_PRIS_ANNE    float;
  NewCOSU_04_REST         float;
  NewCOSU_04_ACQU_ANNE_N1 float;
  NewCOSU_04_PRIS_ANNE_N1 float;
  NewCOSU_04_REST_N1      float;
  NewCOSU_04_ACQU_ANNE_N2 float;
  NewCOSU_04_PRIS_ANNE_N2 float;
  NewCOSU_04_REST_N2      float;

  NewCOSU_05_ACQU_ANNE    float;
  NewCOSU_05_PRIS_ANNE    float;
  NewCOSU_05_REST         float;
  NewCOSU_05_ACQU_ANNE_N1 float;
  NewCOSU_05_PRIS_ANNE_N1 float;
  NewCOSU_05_REST_N1      float;
  NewCOSU_05_ACQU_ANNE_N2 float;
  NewCOSU_05_PRIS_ANNE_N2 float;
  NewCOSU_05_REST_N2      float;

  NewCOSU_06_ACQU_ANNE    float;
  NewCOSU_06_PRIS_ANNE    float;
  NewCOSU_06_REST         float;
  NewCOSU_06_ACQU_ANNE_N1 float;
  NewCOSU_06_PRIS_ANNE_N1 float;
  NewCOSU_06_REST_N1      float;
  NewCOSU_06_ACQU_ANNE_N2 float;
  NewCOSU_06_PRIS_ANNE_N2 float;
  NewCOSU_06_REST_N2      float;

  NewCOSU_07_ACQU_ANNE    float;
  NewCOSU_07_PRIS_ANNE    float;
  NewCOSU_07_REST         float;
  NewCOSU_07_ACQU_ANNE_N1 float;
  NewCOSU_07_PRIS_ANNE_N1 float;
  NewCOSU_07_REST_N1      float;
  NewCOSU_07_ACQU_ANNE_N2 float;
  NewCOSU_07_PRIS_ANNE_N2 float;
  NewCOSU_07_REST_N2      float;

  NewRCRACQUIANN          float;
  NewRCRPRISAN            float;
  NewRCRCUM               float;
  NewRCNACQUIANN          float;
  NewRCNPRISAN            float;
  NewRCNCUM               float;

  NewCOACOURS_LEGA_THEO   float;
  NewCONGAC1_LEGA_THEO    float;
  NewCONGAC2_LEGA_THEO    float;
  NewCONGAC3_LEGA_THEO    float;
  NewCONGAC4_LEGA_THEO    float;

  iPOS_VIDE  int;

  type rSOCIETE is record (
    id_soci        number        ,
    rais_soci      varchar2(255) ,
    rais_soci_pont varchar2(255) ,
    peri           date
  );
  rSOCI rSOCIETE;

  type ti_SOCIETES is table of rSOCIETE index by pls_integer;
  ri_SOCIETES      ti_SOCIETES;


  -- nettoyage d'une ligne venant du fichier en retirant des caractères perturbateurs : point-virgule, saut de ligne, guillemets (T204460)
  function fct__nettoyer_ligne_csv(plign in varchar2) return varchar2 as
    icour int;  -- position courante (généralement sur un séparateur point-virgule)
    idebu int;  -- position d'un délimiteur ouvrant (un guillemet)
    ifin  int;  -- position d'un délimiteur fermant (un guillemet)
    vresu varchar2(4000);  -- ligne résultat après nettoyage
    vvale varchar2(4000);

    -- comptage du nombre de guillemets qui se suivent ; s'il y en a un nombre impair alors c'est un délimiteur
    -- paramètre psens : 1 = parcours de la chaine en avant ; -1 = parcours de la chaine en arrière
    function fct___est_delimiteur(pvale in varchar2, pdebu in int, psens in int) return boolean as
      iposi int;
    begin
      if nvl(psens, 0) not in (1, -1) then return false; end if;  -- erreur de paramètre : on ne peut rien faire
      iposi := pdebu;
      while substr(pvale, iposi, 1) = '"' loop iposi := iposi + psens; end loop;
      if mod(iposi - pdebu, 2) = 0 then return false; else return true; end if;
    end fct___est_delimiteur;

  begin
    icour := 1;
    vresu := '';

    loop
      -- recherche d'un délimiteur ouvrant
      if icour = 1 and plign like '"%' then
        idebu := 1;
      else
        idebu := icour;

        -- recherche jusqu'à trouver un nombre impair de guillemets juste après le point-virgule
        loop
          idebu := instr(plign, ';"', idebu);
          if idebu = 0 or fct___est_delimiteur(plign, idebu + 1, 1) then exit; end if;
          idebu := idebu + 1;  -- ce n'est pas un délimiteur : on cherche plus loin
        end loop;

        if idebu = 0 then vresu := vresu || substr(plign, icour); exit; end if;  -- délimiteur ouvrant non trouvé : nettoyage terminé
        idebu := idebu + 1;
      end if;

      -- recherche d'un délimiteur fermant
      ifin := idebu + 1;

      -- recherche jusqu'à trouver un nombre impair de guillemets juste avant le point-virgule
      loop
        ifin := instr(plign, '";', ifin);
        if ifin = 0 or fct___est_delimiteur(plign, ifin, -1) then exit; end if;
        ifin := ifin + 1;  -- ce n'est pas un délimiteur : on cherche plus loin
      end loop;

      if ifin = 0 and plign like '%"' then ifin := length(plign); end if;
      if ifin = 0 then vresu := vresu || substr(plign, icour); exit; end if;  -- délimiteur fermant non trouvé : nettoyage terminé

      -- traitement de la valeur et suppression des délimiteurs
      vvale := substr(plign, idebu + 1, ifin - idebu - 1);
      vvale := replace(replace(replace(replace(vvale, ';', ' '), chr(10), ''), chr(13), ''), '""', '"');
      vresu := vresu || substr(plign, icour, idebu - icour) || vvale;

      icour := ifin + 1;
      if icour > length(plign) then exit; end if;  -- fin de ligne atteinte
    end loop;

    return vresu;
  end fct__nettoyer_ligne_csv;


  procedure PR_MAJ_LOG(pVALE in varchar2,pNATU_ERRE in varchar2,pLIBE in varchar2) is
  begin
--       Err:=1;
--       pNOMB_ERRE_SALA:=pNOMB_ERRE_SALA+1;
--       select nvl(MAX(ID_IMPO),0)+1 into pID_ERRE from SALARIE_IMPO_DONN_LOG;
--       insert into SALARIE_IMPO_DONN_LOG (ID_IMPO,NATU_ERRE,VALE,libe,DATE_IMPO,id_soci,id_sala,NOM_ETAB,MATR,PREN,NOM,erreur)
--       values (pID_ERRE,pNATU_ERRE,pVALE,'SALA',trunc(sysdate),pID_SOCI,pID_SALA,pNOM_ETAB,pMATR,pPREN,pNOM,pLIBE);
--      commit;

    Err:=Err+1;
    pMAJ_SALA:='N';
    pNOMB_ERRE_SALA:=pNOMB_ERRE_SALA+1;
    select nvl(MAX(ID_LOG),0)+1 into pID_LOG from SALARIE_IMPO_CONG_LOG;
    insert into SALARIE_IMPO_CONG_LOG (NUME_LIGN,ID_IMPO,ID_LOG,CHAM_CODE,TYPE_LOG,id_soci,SALA_MATR,SALA_PREN,SALA_NOM,MESS,ID_LOGI,ID_LOT)
    values (iNUME_LIGN,pID_IMPO,pID_LOG,pNATU_ERRE,'SALA',pID_SOCI,pMATR,pPREN,pNOM,pLIBE,pID_LOGI,iID_LOT);
    commit;
  END PR_MAJ_LOG;


  procedure  PR_SAISIEVAH_MAJ(
    pID_SALA   in varchar2,
    pCODE_CONS in varchar2,
    pPERI      in varchar2,
    pVALE      in varchar2
  ) is
  begin
    if pMAJ_DONN='O' then
      n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,NUME,ETAP,Z1,Z2,Z3,Z4,Z5,Z6,Z7) values(pID_SOCI,n,' PR_SAISIEVAH avec pID_SALA=',pID_SALA,' pCODE_CONS=',pCODE_CONS,' pPERI=',pPERI,' pVALE=',pVALE);commit;
      PR_SAISIEVAH(pID_SALA,pCODE_CONS,pPERI,pVALE);
    end if;
  END PR_SAISIEVAH_MAJ;


  FUNCTION FCT_DETE_CHAM (tCHAM in varchar2)  RETURN VARCHAR2 IS
    pVALE     varchar2(100) ;
    pCHAM     varchar2(100);
  BEGIN
    pCHAM:=TRIM(tCHAM);
    NewVALE   :='';
    pZONE_TROU:='';

    For pZONE in 1..300 Loop
      if pTABL_ZONE_IMPO(pZONE)=pCHAM then
        pZONE_TROU:=TRIM(pZONE);
        NewVALE:=pTABL_VALE_IMPO(pZONE) ;
      end if;

      if pZONE<10 then
            n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,NUME,ETAP,Z1,Z2,Z3,Z4,Z5,Z6,Z7,Z8,Z9) values(pID_SOCI,n,' FCT_DETE_CHAM Recherche pZone=',pZONE,' cham=',pCHAM,' tabl pzone=',pTABL_ZONE_IMPO(pZONE),' trou=',pZONE_TROU,'donc vale=',NewVALE);commit;
      end if;

    end loop;

    RETURN NewVALE ;
  END FCT_DETE_CHAM;


  procedure PR_DETE_SALA is
  begin
    vSALA_ID_SOCI      := trim(rSala_Impo_Cong.SALA_ID_SOCI   );
    vSALA_RAIS_SOCI    := trim(rSala_Impo_Cong.SALA_RAIS_SOCI );
    pMATR              := trim(rSala_Impo_Cong.MATR           );
    pNOM               := trim(rSala_Impo_Cong.NOM            );
    pPREN              := trim(rSala_Impo_Cong.PRENOM         );

    pBRUTPREC4         := trim(rSala_Impo_Cong.BRUTPREC4           );
    pCONGAC4_LEGA      := trim(rSala_Impo_Cong.CONGAC4_LEGA        );
    pCONGAPRE4_LEGA    := trim(rSala_Impo_Cong.CONGAPRE4_LEGA      );
    pCONGAC4_ANCI_1    := trim(rSala_Impo_Cong.CONGAC4_ANCI_1      );
    pCONGAPRE4_ANCI_1  := trim(rSala_Impo_Cong.CONGAPRE4_ANCI_1    );
    pCONGAC4_ANCI_2    := trim(rSala_Impo_Cong.CONGAC4_ANCI_2      );
    pCONGAPRE4_ANCI_2  := trim(rSala_Impo_Cong.CONGAPRE4_ANCI_2    );
    pCONGAC4_ANCI_3    := trim(rSala_Impo_Cong.CONGAC4_ANCI_3      );
    pCONGAPRE4_ANCI_3  := trim(rSala_Impo_Cong.CONGAPRE4_ANCI_3    );
    pCONGAC4_FRAC      := trim(rSala_Impo_Cong.CONGAC4_FRAC        );
    pCONGAPRE4_FRAC    := trim(rSala_Impo_Cong.CONGAPRE4_FRAC      );
    pBRUTPREC3         := trim(rSala_Impo_Cong.BRUTPREC3           );
    pCONGAC3_LEGA      := trim(rSala_Impo_Cong.CONGAC3_LEGA        );
    pCONGAPRE3_LEGA    := trim(rSala_Impo_Cong.CONGAPRE3_LEGA      );
    pCONGAC3_ANCI_1    := trim(rSala_Impo_Cong.CONGAC3_ANCI_1      );
    pCONGAPRE3_ANCI_1  := trim(rSala_Impo_Cong.CONGAPRE3_ANCI_1    );
    pCONGAC3_ANCI_2    := trim(rSala_Impo_Cong.CONGAC3_ANCI_2      );
    pCONGAPRE3_ANCI_2  := trim(rSala_Impo_Cong.CONGAPRE3_ANCI_2    );
    pCONGAC3_ANCI_3    := trim(rSala_Impo_Cong.CONGAC3_ANCI_3      );
    pCONGAPRE3_ANCI_3  := trim(rSala_Impo_Cong.CONGAPRE3_ANCI_3    );
    pCONGAC3_FRAC      := trim(rSala_Impo_Cong.CONGAC3_FRAC        );
    pCONGAPRE3_FRAC    := trim(rSala_Impo_Cong.CONGAPRE3_FRAC      );
    pBRUTPREC2         := trim(rSala_Impo_Cong.BRUTPREC2           );
    pCONGAC2_LEGA      := trim(rSala_Impo_Cong.CONGAC2_LEGA        );
    pCONGAPRE2_LEGA    := trim(rSala_Impo_Cong.CONGAPRE2_LEGA      );
    pCONGAC2_ANCI_1    := trim(rSala_Impo_Cong.CONGAC2_ANCI_1      );
    pCONGAPRE2_ANCI_1  := trim(rSala_Impo_Cong.CONGAPRE2_ANCI_1    );
    pCONGAC2_ANCI_2    := trim(rSala_Impo_Cong.CONGAC2_ANCI_2      );
    pCONGAPRE2_ANCI_2  := trim(rSala_Impo_Cong.CONGAPRE2_ANCI_2    );
    pCONGAC2_ANCI_3    := trim(rSala_Impo_Cong.CONGAC2_ANCI_3      );
    pCONGAPRE2_ANCI_3  := trim(rSala_Impo_Cong.CONGAPRE2_ANCI_3    );
    pCONGAC2_FRAC      := trim(rSala_Impo_Cong.CONGAC2_FRAC        );
    pCONGAPRE2_FRAC    := trim(rSala_Impo_Cong.CONGAPRE2_FRAC      );
    pBRUTPREC1         := trim(rSala_Impo_Cong.BRUTPREC1           );
    pCONGAC1_LEGA      := trim(rSala_Impo_Cong.CONGAC1_LEGA        );
    pCONGAPRE1_LEGA    := trim(rSala_Impo_Cong.CONGAPRE1_LEGA      );
    pCONGAC1_ANCI_1    := trim(rSala_Impo_Cong.CONGAC1_ANCI_1      );
    pCONGAPRE1_ANCI_1  := trim(rSala_Impo_Cong.CONGAPRE1_ANCI_1    );
    pCONGAC1_ANCI_2    := trim(rSala_Impo_Cong.CONGAC1_ANCI_2      );
    pCONGAPRE1_ANCI_2  := trim(rSala_Impo_Cong.CONGAPRE1_ANCI_2    );
    pCONGAC1_ANCI_3    := trim(rSala_Impo_Cong.CONGAC1_ANCI_3      );
    pCONGAPRE1_ANCI_3  := trim(rSala_Impo_Cong.CONGAPRE1_ANCI_3    );
    pCONGAC1_FRAC      := trim(rSala_Impo_Cong.CONGAC1_FRAC        );
    pCONGAPRE1_FRAC    := trim(rSala_Impo_Cong.CONGAPRE1_FRAC      );
    pBRUTPREC0         := trim(rSala_Impo_Cong.BRUTPREC0           );
    pCOACOURS_LEGA     := trim(rSala_Impo_Cong.COACOURS_LEGA       );
    pCONGAPRE0_LEGA    := trim(rSala_Impo_Cong.CONGAPRE0_LEGA      );
    pCOACOURS_ANCI_1   := trim(rSala_Impo_Cong.COACOURS_ANCI_1     );
    pCONGAPRE0_ANCI_1  := trim(rSala_Impo_Cong.CONGAPRE0_ANCI_1    );
    pCOACOURS_ANCI_2   := trim(rSala_Impo_Cong.COACOURS_ANCI_2     );
    pCONGAPRE0_ANCI_2  := trim(rSala_Impo_Cong.CONGAPRE0_ANCI_2    );
    pCOACOURS_ANCI_3   := trim(rSala_Impo_Cong.COACOURS_ANCI_3     );
    pCONGAPRE0_ANCI_3  := trim(rSala_Impo_Cong.CONGAPRE0_ANCI_3    );
    pCOACOURS_FRAC     := trim(rSala_Impo_Cong.COACOURS_FRAC       );
    pCONGAPRE0_FRAC    := trim(rSala_Impo_Cong.CONGAPRE0_FRAC      );
    pBRUTPRECM1        := trim(rSala_Impo_Cong.BRUTPRECM1          );

    pCP_INDE_MONT_N0_PREC := trim(rSala_Impo_Cong.CP_INDE_MONT_N0_PREC   );
    pCP_INDE_MONT_N1_PREC := trim(rSala_Impo_Cong.CP_INDE_MONT_N1_PREC   );
    pCP_INDE_MONT_N2_PREC := trim(rSala_Impo_Cong.CP_INDE_MONT_N2_PREC   );
    pCP_INDE_MONT_N3_PREC := trim(rSala_Impo_Cong.CP_INDE_MONT_N3_PREC   );
    pCP_INDE_MONT_N4_PREC := trim(rSala_Impo_Cong.CP_INDE_MONT_N4_PREC   );

    pRTTAN              := trim(rSala_Impo_Cong.RTTAN             );
    pRTTPRIANN          := trim(rSala_Impo_Cong.RTTPRIANN         );
    pRTTAPRE            := trim(rSala_Impo_Cong.RTTAPRE           );
    pRTTREPRIS          := trim(rSala_Impo_Cong.RTTREPRIS         );
    pRTT_SALA_REST_CLOT := trim(rSala_Impo_Cong.RTT_SALA_REST_CLOT);
    pRTTANPAT           := trim(rSala_Impo_Cong.RTTANPAT          );
    pRTTPRIANNPAT       := trim(rSala_Impo_Cong.RTTPRIANNPAT      );
    pRTTAPREPAT         := trim(rSala_Impo_Cong.RTTAPREPAT        );
    pRTTREPRISPAT       := trim(rSala_Impo_Cong.RTTREPRISPAT      );
    pRTT_PATR_REST_CLOT := trim(rSala_Impo_Cong.RTT_PATR_REST_CLOT);


    pCETACQRTTPATANN    := trim(rSala_Impo_Cong.CETACQRTTPATANN);
    pCETPRIRTTPATANN    := trim(rSala_Impo_Cong.CETPRIRTTPATANN);
    pCETACQRTTSALANN    := trim(rSala_Impo_Cong.CETACQRTTSALANN);
    pCETPRIRTTSALANN    := trim(rSala_Impo_Cong.CETPRIRTTSALANN);
    pCETACQCPANN        := trim(rSala_Impo_Cong.CETACQCPANN    );
    pCETPRICPANN        := trim(rSala_Impo_Cong.CETPRICPANN    );
    pCETRESCP           := trim(rSala_Impo_Cong.CETRESCP       );
    pCETRESRTTPAT       := trim(rSala_Impo_Cong.CETRESRTTPAT   );
    pCETRESRTTSAL       := trim(rSala_Impo_Cong.CETRESRTTSAL   );
    pCETACQCPNOMOANN    := trim(rSala_Impo_Cong.CETACQCPNOMOANN);
    pCETPRICPNOMOANN    := trim(rSala_Impo_Cong.CETPRICPNOMOANN);
    pCETRESCPNOMO       := trim(rSala_Impo_Cong.CETRESCPNOMO   );

    pREPACQUI           := trim(rSala_Impo_Cong.REPACQUI       );
    pREPOPRISAN         := trim(rSala_Impo_Cong.REPOPRISAN     );
    pREPOSCUM           := trim(rSala_Impo_Cong.REPOSCUM       );

    -- compteurs supplémentaires, RCR, RCN (T80556)
    pRTTANSUP             := trim(rSala_Impo_Cong.RTTANSUP            );
    pRTTPRIANNSUP         := trim(rSala_Impo_Cong.RTTPRIANNSUP        );
    pRTTAPRESUP           := trim(rSala_Impo_Cong.RTTAPRESUP          );

    pCOSU_01_ACQU_ANNE    := trim(rSala_Impo_Cong.COSU_01_ACQU_ANNE   );
    pCOSU_01_ACQU_ANNE_N1 := trim(rSala_Impo_Cong.COSU_01_ACQU_ANNE_N1);
    pCOSU_01_ACQU_ANNE_N2 := trim(rSala_Impo_Cong.COSU_01_ACQU_ANNE_N2);
    pCOSU_01_PRIS_ANNE    := trim(rSala_Impo_Cong.COSU_01_PRIS_ANNE   );
    pCOSU_01_PRIS_ANNE_N1 := trim(rSala_Impo_Cong.COSU_01_PRIS_ANNE_N1);
    pCOSU_01_PRIS_ANNE_N2 := trim(rSala_Impo_Cong.COSU_01_PRIS_ANNE_N2);
    pCOSU_01_REST         := trim(rSala_Impo_Cong.COSU_01_REST        );
    pCOSU_01_REST_N1      := trim(rSala_Impo_Cong.COSU_01_REST_N1     );
    pCOSU_01_REST_N2      := trim(rSala_Impo_Cong.COSU_01_REST_N2     );

    pCOSU_02_ACQU_ANNE    := trim(rSala_Impo_Cong.COSU_02_ACQU_ANNE   );
    pCOSU_02_ACQU_ANNE_N1 := trim(rSala_Impo_Cong.COSU_02_ACQU_ANNE_N1);
    pCOSU_02_ACQU_ANNE_N2 := trim(rSala_Impo_Cong.COSU_02_ACQU_ANNE_N2);
    pCOSU_02_PRIS_ANNE    := trim(rSala_Impo_Cong.COSU_02_PRIS_ANNE   );
    pCOSU_02_PRIS_ANNE_N1 := trim(rSala_Impo_Cong.COSU_02_PRIS_ANNE_N1);
    pCOSU_02_PRIS_ANNE_N2 := trim(rSala_Impo_Cong.COSU_02_PRIS_ANNE_N2);
    pCOSU_02_REST         := trim(rSala_Impo_Cong.COSU_02_REST        );
    pCOSU_02_REST_N1      := trim(rSala_Impo_Cong.COSU_02_REST_N1     );
    pCOSU_02_REST_N2      := trim(rSala_Impo_Cong.COSU_02_REST_N2     );

    pCOSU_03_ACQU_ANNE    := trim(rSala_Impo_Cong.COSU_03_ACQU_ANNE   );
    pCOSU_03_ACQU_ANNE_N1 := trim(rSala_Impo_Cong.COSU_03_ACQU_ANNE_N1);
    pCOSU_03_ACQU_ANNE_N2 := trim(rSala_Impo_Cong.COSU_03_ACQU_ANNE_N2);
    pCOSU_03_PRIS_ANNE    := trim(rSala_Impo_Cong.COSU_03_PRIS_ANNE   );
    pCOSU_03_PRIS_ANNE_N1 := trim(rSala_Impo_Cong.COSU_03_PRIS_ANNE_N1);
    pCOSU_03_PRIS_ANNE_N2 := trim(rSala_Impo_Cong.COSU_03_PRIS_ANNE_N2);
    pCOSU_03_REST         := trim(rSala_Impo_Cong.COSU_03_REST        );
    pCOSU_03_REST_N1      := trim(rSala_Impo_Cong.COSU_03_REST_N1     );
    pCOSU_03_REST_N2      := trim(rSala_Impo_Cong.COSU_03_REST_N2     );

    pCOSU_04_ACQU_ANNE    := trim(rSala_Impo_Cong.COSU_04_ACQU_ANNE   );
    pCOSU_04_ACQU_ANNE_N1 := trim(rSala_Impo_Cong.COSU_04_ACQU_ANNE_N1);
    pCOSU_04_ACQU_ANNE_N2 := trim(rSala_Impo_Cong.COSU_04_ACQU_ANNE_N2);
    pCOSU_04_PRIS_ANNE    := trim(rSala_Impo_Cong.COSU_04_PRIS_ANNE   );
    pCOSU_04_PRIS_ANNE_N1 := trim(rSala_Impo_Cong.COSU_04_PRIS_ANNE_N1);
    pCOSU_04_PRIS_ANNE_N2 := trim(rSala_Impo_Cong.COSU_04_PRIS_ANNE_N2);
    pCOSU_04_REST         := trim(rSala_Impo_Cong.COSU_04_REST        );
    pCOSU_04_REST_N1      := trim(rSala_Impo_Cong.COSU_04_REST_N1     );
    pCOSU_04_REST_N2      := trim(rSala_Impo_Cong.COSU_04_REST_N2     );

    pCOSU_05_ACQU_ANNE    := trim(rSala_Impo_Cong.COSU_05_ACQU_ANNE   );
    pCOSU_05_ACQU_ANNE_N1 := trim(rSala_Impo_Cong.COSU_05_ACQU_ANNE_N1);
    pCOSU_05_ACQU_ANNE_N2 := trim(rSala_Impo_Cong.COSU_05_ACQU_ANNE_N2);
    pCOSU_05_PRIS_ANNE    := trim(rSala_Impo_Cong.COSU_05_PRIS_ANNE   );
    pCOSU_05_PRIS_ANNE_N1 := trim(rSala_Impo_Cong.COSU_05_PRIS_ANNE_N1);
    pCOSU_05_PRIS_ANNE_N2 := trim(rSala_Impo_Cong.COSU_05_PRIS_ANNE_N2);
    pCOSU_05_REST         := trim(rSala_Impo_Cong.COSU_05_REST        );
    pCOSU_05_REST_N1      := trim(rSala_Impo_Cong.COSU_05_REST_N1     );
    pCOSU_05_REST_N2      := trim(rSala_Impo_Cong.COSU_05_REST_N2     );

    pCOSU_06_ACQU_ANNE    := trim(rSala_Impo_Cong.COSU_06_ACQU_ANNE   );
    pCOSU_06_ACQU_ANNE_N1 := trim(rSala_Impo_Cong.COSU_06_ACQU_ANNE_N1);
    pCOSU_06_ACQU_ANNE_N2 := trim(rSala_Impo_Cong.COSU_06_ACQU_ANNE_N2);
    pCOSU_06_PRIS_ANNE    := trim(rSala_Impo_Cong.COSU_06_PRIS_ANNE   );
    pCOSU_06_PRIS_ANNE_N1 := trim(rSala_Impo_Cong.COSU_06_PRIS_ANNE_N1);
    pCOSU_06_PRIS_ANNE_N2 := trim(rSala_Impo_Cong.COSU_06_PRIS_ANNE_N2);
    pCOSU_06_REST         := trim(rSala_Impo_Cong.COSU_06_REST        );
    pCOSU_06_REST_N1      := trim(rSala_Impo_Cong.COSU_06_REST_N1     );
    pCOSU_06_REST_N2      := trim(rSala_Impo_Cong.COSU_06_REST_N2     );

    pCOSU_07_ACQU_ANNE    := trim(rSala_Impo_Cong.COSU_07_ACQU_ANNE   );
    pCOSU_07_ACQU_ANNE_N1 := trim(rSala_Impo_Cong.COSU_07_ACQU_ANNE_N1);
    pCOSU_07_ACQU_ANNE_N2 := trim(rSala_Impo_Cong.COSU_07_ACQU_ANNE_N2);
    pCOSU_07_PRIS_ANNE    := trim(rSala_Impo_Cong.COSU_07_PRIS_ANNE   );
    pCOSU_07_PRIS_ANNE_N1 := trim(rSala_Impo_Cong.COSU_07_PRIS_ANNE_N1);
    pCOSU_07_PRIS_ANNE_N2 := trim(rSala_Impo_Cong.COSU_07_PRIS_ANNE_N2);
    pCOSU_07_REST         := trim(rSala_Impo_Cong.COSU_07_REST        );
    pCOSU_07_REST_N1      := trim(rSala_Impo_Cong.COSU_07_REST_N1     );
    pCOSU_07_REST_N2      := trim(rSala_Impo_Cong.COSU_07_REST_N2     );

    pRCRACQUIANN        := trim(rSala_Impo_Cong.RCRACQUIANN      );
    pRCRPRISAN          := trim(rSala_Impo_Cong.RCRPRISAN        );
    pRCRCUM             := trim(rSala_Impo_Cong.RCRCUM           );
    pRCNACQUIANN        := trim(rSala_Impo_Cong.RCNACQUIANN      );
    pRCNPRISAN          := trim(rSala_Impo_Cong.RCNPRISAN        );
    pRCNCUM             := trim(rSala_Impo_Cong.RCNCUM           );

    pCOACOURS_LEGA_THEO := trim(rSala_Impo_Cong.COACOURS_LEGA_THEO    );
    pCONGAC1_LEGA_THEO  := trim(rSala_Impo_Cong.CONGAC1_LEGA_THEO     );
    pCONGAC2_LEGA_THEO  := trim(rSala_Impo_Cong.CONGAC2_LEGA_THEO     );
    pCONGAC3_LEGA_THEO  := trim(rSala_Impo_Cong.CONGAC3_LEGA_THEO     );
    pCONGAC4_LEGA_THEO  := trim(rSala_Impo_Cong.CONGAC4_LEGA_THEO     );
  end ;


  procedure PR_IMPORT is
  begin
    n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,NUME,ETAP) VALUES(pID_SOCI,n,' ***Début import le 31 08 2010  21 h** ');commit;

    for cLign in (select * from IMPORT_GENERIQUE_DETAIL where id_impo=pID_IMPO order by nume_lign) loop
      iNUME_LIGN := cLign.NUME_LIGN;
      rSala_Impo_Cong.NUME_LIGN := iNUME_LIGN;
      vLIGN := fct__nettoyer_ligne_csv(cLign.LIGN);
      rSala_Impo_Cong.ID_LOT:= iID_LOT;
      pDERN_CARA:=substr(vLIGN,length(vLIGN),1);
      if pDERN_CARA<>';' then vLIGN:=vLIGN || ';';end if;

      n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,NUME,ETAP,Z1,Z2,Z3)values(pID_SOCI,n,'  Boucle n ligne=',iNUME_LIGN,'  plign=',substr(vLIGN,1,100));


      if iNUME_LIGN=2 then

        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);pID_SOCI_FICH:=SUBSTR(vLIGN,1,iPOS-1);

        n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,NUME,ETAP,Z1,Z2,Z3) values(pID_SOCI,n,' recherche id soci =',pID_SOCI_FICH,' vLign=',SUBSTR(vLIGN,1,20));commit;

      end if;

      if iNUME_LIGN=3 then

        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);pNOM_SOCI:=SUBSTR(vLIGN,1,iPOS-1);

        n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,NUME,ETAP,Z1,Z2,Z3) values(pID_SOCI,n,' recherche nom =',pNOM_SOCI,' vLign=',SUBSTR(vLIGN,1,20));commit;

      end if;

      if iNUME_LIGN=4 then

        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
        iPOS:=INSTR(vLIGN,';',1);pPERI_IMPO:=SUBSTR(vLIGN,1,iPOS-1);

        n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,NUME,ETAP,Z1,Z2,Z3) values(pID_SOCI,n,' recherche période =',pPERI_IMPO,' vLign=',SUBSTR(vLIGN,1,20));commit;

      end if;


      if iNUME_LIGN=5 then

        For pZONE in 1..300 Loop pTABL_ZONE_IMPO(pZONE):='';end loop;
        pZONE:=0;iPOS:=INSTR(vLIGN,';',1);
        pCODE_ZONE:='DEBU';
        n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,DETA,NUME,ETAP,Z1) values(pID_SOCI,pCODE_ZONE,n,'Début boucle recherche colonnes iPos=',iPOS);commit;

        while iPOS>0 and pCODE_ZONE is not null loop
            pZONE:=pZONE+1;
            pCODE_ZONE:=SUBSTR(vLIGN,1,iPOS-1);pTABL_ZONE_IMPO(pZONE):=pCODE_ZONE;vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);iPOS:=INSTR(vLIGN,';',1);
            if iPOS=0 and length(vLIGN)>0 then
              pCODE_ZONE:=vLIGN;pTABL_ZONE_IMPO(pZONE):=pCODE_ZONE;
            end if;
             if pZONE<30 then
                n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,DETA,NUME,ETAP,Z1,Z2,Z3,Z4,Z5,Z6,Z7,Z8,Z9) values(pID_SOCI,'RECH_COLO',n,' En tete des colonnes pZone=',pZONE,' PCode=',pCODE_ZONE,' tabl=',pTABL_ZONE_IMPO(pZONE),' iPos=',iPOS,' vLign=',SUBSTR(vLIGN,1,20));commit;
            end if;
        end loop;

      end if;

      if iNUME_LIGN>=7 then

        iPOS_VIDE:=instr(VLIGN,';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;',1); -- 93 colonnes

        n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,DETA,NUME,ETAP,Z1,Z2,Z3) values(pID_SOCI,'LIGN_VIDE',n,'Début boucle recherche vide iPos vide=',iPOS_VIDE,' vlign=',vLIGN);commit;

        if iPOS_VIDE = 0 then
          For pZONE in 1..300 Loop pTABL_VALE_IMPO(pZONE):='';end loop;
          pZONE:=0;iPOS:=INSTR(vLIGN,';',1);
          n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,DETA,NUME,ETAP,Z1,Z2,Z3) values(pID_SOCI,'LIGN',n,'Début boucle recherche colonnes iPos=',iPOS,' vlign=',vLIGN);commit;

          while iPOS>0 loop
            pZONE:=pZONE+1;
            pCODE_ZONE:=SUBSTR(vLIGN,1,iPOS-1);
            n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,DETA,NUME,ETAP,Z1) values(pID_SOCI,'CODE_ZONE',n,' pCODE_ZONE=',pCODE_ZONE);commit;
            pTABL_VALE_IMPO(pZONE):=pCODE_ZONE;
            vLIGN:=SUBSTR(vLIGN,iPOS+1,Length(VLIGN)-iPOS);
            iPOS:=INSTR(vLIGN,';',1);

            if iPOS=0 and length(vLIGN)>0 then
              pCODE_ZONE:=vLIGN;pTABL_VALE_IMPO(pZONE):=pCODE_ZONE;
            end if;
            n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,DETA,NUME,ETAP,Z1,Z2,Z3,Z4,Z5,Z6,Z7) values(pID_SOCI,'RECH_VALE',n,' Lignes  pZone=',pZONE,' PCode=',pCODE_ZONE,' tabl=',pTABL_VALE_IMPO(pZONE),' iPos=',iPOS);commit;
          end loop;


          n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,DETA,NUME,ETAP,Z1)values(pID_SOCI,'MAIN_VALE',n,' le 30 04 2009 Ligne plign=',substr(vLIGN,1,100));
          commit;

          vSALA_ID_SOCI   :=FCT_DETE_CHAM('ID_SOCI');
          vSALA_RAIS_SOCI :=FCT_DETE_CHAM('RAIS_SOCI');

          if vSALA_ID_SOCI is null then
            vSALA_ID_SOCI   := pID_SOCI;
            vSALA_RAIS_SOCI := ri_SOCIETES( parse_int(vSALA_ID_SOCI) ).rais_soci;
          end if;

          rSala_Impo_Cong.SALA_ID_SOCI         :=vSALA_ID_SOCI       ;
          rSala_Impo_Cong.SALA_RAIS_SOCI       :=vSALA_RAIS_SOCI     ;

          pMATR               :=FCT_DETE_CHAM('MATR');            rSala_Impo_Cong.MATR                 :=pMATR               ;
          pNOM                :=FCT_DETE_CHAM('NOM ');            rSala_Impo_Cong.NOM                  :=pNOM                ;
          pPREN               :=FCT_DETE_CHAM('PREN');            rSala_Impo_Cong.PRENOM               :=pPREN               ;

          pBRUTPREC4                 :=FCT_DETE_CHAM('BRUTPREC4');          rSala_Impo_Cong.BRUTPREC4               :=pBRUTPREC4            ; if pBRUTPREC4        is not null then rSala_Impo_Cong_Colo.BRUTPREC4           := '50'; end if;
          pCONGAC4_LEGA              :=FCT_DETE_CHAM('CONGAC4_LEGA');       rSala_Impo_Cong.CONGAC4_LEGA            :=pCONGAC4_LEGA         ; if pCONGAC4_LEGA     is not null then rSala_Impo_Cong_Colo.CONGAC4_LEGA        := '52'; end if;
          pCONGAPRE4_LEGA            :=FCT_DETE_CHAM('CONGAPRE4_LEGA');     rSala_Impo_Cong.CONGAPRE4_LEGA          :=pCONGAPRE4_LEGA       ; if pCONGAPRE4_LEGA   is not null then rSala_Impo_Cong_Colo.CONGAPRE4_LEGA      := '53'; end if;
          pCONGAC4_ANCI_1            :=FCT_DETE_CHAM('CONGAC4_ANCI_1');     rSala_Impo_Cong.CONGAC4_ANCI_1          :=pCONGAC4_ANCI_1       ; if pCONGAC4_ANCI_1   is not null then rSala_Impo_Cong_Colo.CONGAC4_ANCI_1      := '54'; end if;
          pCONGAPRE4_ANCI_1          :=FCT_DETE_CHAM('CONGAPRE4_ANCI_1');   rSala_Impo_Cong.CONGAPRE4_ANCI_1        :=pCONGAPRE4_ANCI_1     ; if pCONGAPRE4_ANCI_1 is not null then rSala_Impo_Cong_Colo.CONGAPRE4_ANCI_1    := '55'; end if;
          pCONGAC4_ANCI_2            :=FCT_DETE_CHAM('CONGAC4_ANCI_2');     rSala_Impo_Cong.CONGAC4_ANCI_2          :=pCONGAC4_ANCI_2       ; if pCONGAC4_ANCI_2   is not null then rSala_Impo_Cong_Colo.CONGAC4_ANCI_2      := '56'; end if;
          pCONGAPRE4_ANCI_2          :=FCT_DETE_CHAM('CONGAPRE4_ANCI_2');   rSala_Impo_Cong.CONGAPRE4_ANCI_2        :=pCONGAPRE4_ANCI_2     ; if pCONGAPRE4_ANCI_2 is not null then rSala_Impo_Cong_Colo.CONGAPRE4_ANCI_2    := '57'; end if;
          pCONGAC4_ANCI_3            :=FCT_DETE_CHAM('CONGAC4_ANCI_3');     rSala_Impo_Cong.CONGAC4_ANCI_3          :=pCONGAC4_ANCI_3       ; if pCONGAC4_ANCI_3   is not null then rSala_Impo_Cong_Colo.CONGAC4_ANCI_3      := '58'; end if;
          pCONGAPRE4_ANCI_3          :=FCT_DETE_CHAM('CONGAPRE4_ANCI_3');   rSala_Impo_Cong.CONGAPRE4_ANCI_3        :=pCONGAPRE4_ANCI_3     ; if pCONGAPRE4_ANCI_3 is not null then rSala_Impo_Cong_Colo.CONGAPRE4_ANCI_3    := '59'; end if;
          pCONGAC4_FRAC              :=FCT_DETE_CHAM('CONGAC4_FRAC');       rSala_Impo_Cong.CONGAC4_FRAC            :=pCONGAC4_FRAC         ; if pCONGAC4_FRAC     is not null then rSala_Impo_Cong_Colo.CONGAC4_FRAC        := '60'; end if;
          pCONGAPRE4_FRAC            :=FCT_DETE_CHAM('CONGAPRE4_FRAC');     rSala_Impo_Cong.CONGAPRE4_FRAC          :=pCONGAPRE4_FRAC       ; if pCONGAPRE4_FRAC   is not null then rSala_Impo_Cong_Colo.CONGAPRE4_FRAC      := '61'; end if;
          pBRUTPREC3                 :=FCT_DETE_CHAM('BRUTPREC3');          rSala_Impo_Cong.BRUTPREC3               :=pBRUTPREC3            ; if pBRUTPREC3        is not null then rSala_Impo_Cong_Colo.BRUTPREC3           := '38'; end if;
          pCONGAC3_LEGA              :=FCT_DETE_CHAM('CONGAC3_LEGA');       rSala_Impo_Cong.CONGAC3_LEGA            :=pCONGAC3_LEGA         ; if pCONGAC3_LEGA     is not null then rSala_Impo_Cong_Colo.CONGAC3_LEGA        := '40'; end if;
          pCONGAPRE3_LEGA            :=FCT_DETE_CHAM('CONGAPRE3_LEGA');     rSala_Impo_Cong.CONGAPRE3_LEGA          :=pCONGAPRE3_LEGA       ; if pCONGAPRE3_LEGA   is not null then rSala_Impo_Cong_Colo.CONGAPRE3_LEGA      := '41'; end if;
          pCONGAC3_ANCI_1            :=FCT_DETE_CHAM('CONGAC3_ANCI_1');     rSala_Impo_Cong.CONGAC3_ANCI_1          :=pCONGAC3_ANCI_1       ; if pCONGAC3_ANCI_1   is not null then rSala_Impo_Cong_Colo.CONGAC3_ANCI_1      := '42'; end if;
          pCONGAPRE3_ANCI_1          :=FCT_DETE_CHAM('CONGAPRE3_ANCI_1');   rSala_Impo_Cong.CONGAPRE3_ANCI_1        :=pCONGAPRE3_ANCI_1     ; if pCONGAPRE3_ANCI_1 is not null then rSala_Impo_Cong_Colo.CONGAPRE3_ANCI_1    := '43'; end if;
          pCONGAC3_ANCI_2            :=FCT_DETE_CHAM('CONGAC3_ANCI_2');     rSala_Impo_Cong.CONGAC3_ANCI_2          :=pCONGAC3_ANCI_2       ; if pCONGAC3_ANCI_2   is not null then rSala_Impo_Cong_Colo.CONGAC3_ANCI_2      := '44'; end if;
          pCONGAPRE3_ANCI_2          :=FCT_DETE_CHAM('CONGAPRE3_ANCI_2');   rSala_Impo_Cong.CONGAPRE3_ANCI_2        :=pCONGAPRE3_ANCI_2     ; if pCONGAPRE3_ANCI_2 is not null then rSala_Impo_Cong_Colo.CONGAPRE3_ANCI_2    := '45'; end if;
          pCONGAC3_ANCI_3            :=FCT_DETE_CHAM('CONGAC3_ANCI_3');     rSala_Impo_Cong.CONGAC3_ANCI_3          :=pCONGAC3_ANCI_3       ; if pCONGAC3_ANCI_3   is not null then rSala_Impo_Cong_Colo.CONGAC3_ANCI_3      := '46'; end if;
          pCONGAPRE3_ANCI_3          :=FCT_DETE_CHAM('CONGAPRE3_ANCI_3');   rSala_Impo_Cong.CONGAPRE3_ANCI_3        :=pCONGAPRE3_ANCI_3     ; if pCONGAPRE3_ANCI_3 is not null then rSala_Impo_Cong_Colo.CONGAPRE3_ANCI_3    := '47'; end if;
          pCONGAC3_FRAC              :=FCT_DETE_CHAM('CONGAC3_FRAC');       rSala_Impo_Cong.CONGAC3_FRAC            :=pCONGAC3_FRAC         ; if pCONGAC3_FRAC     is not null then rSala_Impo_Cong_Colo.CONGAC3_FRAC        := '48'; end if;
          pCONGAPRE3_FRAC            :=FCT_DETE_CHAM('CONGAPRE3_FRAC');     rSala_Impo_Cong.CONGAPRE3_FRAC          :=pCONGAPRE3_FRAC       ; if pCONGAPRE3_FRAC   is not null then rSala_Impo_Cong_Colo.CONGAPRE3_FRAC      := '49'; end if;
          pBRUTPREC2                 :=FCT_DETE_CHAM('BRUTPREC2');          rSala_Impo_Cong.BRUTPREC2               :=pBRUTPREC2            ; if pBRUTPREC2        is not null then rSala_Impo_Cong_Colo.BRUTPREC2           := '26'; end if;
          pCONGAC2_LEGA              :=FCT_DETE_CHAM('CONGAC2_LEGA');       rSala_Impo_Cong.CONGAC2_LEGA            :=pCONGAC2_LEGA         ; if pCONGAC2_LEGA     is not null then rSala_Impo_Cong_Colo.CONGAC2_LEGA        := '28'; end if;
          pCONGAPRE2_LEGA            :=FCT_DETE_CHAM('CONGAPRE2_LEGA');     rSala_Impo_Cong.CONGAPRE2_LEGA          :=pCONGAPRE2_LEGA       ; if pCONGAPRE2_LEGA   is not null then rSala_Impo_Cong_Colo.CONGAPRE2_LEGA      := '29'; end if;
          pCONGAC2_ANCI_1            :=FCT_DETE_CHAM('CONGAC2_ANCI_1');     rSala_Impo_Cong.CONGAC2_ANCI_1          :=pCONGAC2_ANCI_1       ; if pCONGAC2_ANCI_1   is not null then rSala_Impo_Cong_Colo.CONGAC2_ANCI_1      := '30'; end if;
          pCONGAPRE2_ANCI_1          :=FCT_DETE_CHAM('CONGAPRE2_ANCI_1');   rSala_Impo_Cong.CONGAPRE2_ANCI_1        :=pCONGAPRE2_ANCI_1     ; if pCONGAPRE2_ANCI_1 is not null then rSala_Impo_Cong_Colo.CONGAPRE2_ANCI_1    := '31'; end if;
          pCONGAC2_ANCI_2            :=FCT_DETE_CHAM('CONGAC2_ANCI_2');     rSala_Impo_Cong.CONGAC2_ANCI_2          :=pCONGAC2_ANCI_2       ; if pCONGAC2_ANCI_2   is not null then rSala_Impo_Cong_Colo.CONGAC2_ANCI_2      := '32'; end if;
          pCONGAPRE2_ANCI_2          :=FCT_DETE_CHAM('CONGAPRE2_ANCI_2');   rSala_Impo_Cong.CONGAPRE2_ANCI_2        :=pCONGAPRE2_ANCI_2     ; if pCONGAPRE2_ANCI_2 is not null then rSala_Impo_Cong_Colo.CONGAPRE2_ANCI_2    := '33'; end if;
          pCONGAC2_ANCI_3            :=FCT_DETE_CHAM('CONGAC2_ANCI_3');     rSala_Impo_Cong.CONGAC2_ANCI_3          :=pCONGAC2_ANCI_3       ; if pCONGAC2_ANCI_3   is not null then rSala_Impo_Cong_Colo.CONGAC2_ANCI_3      := '34'; end if;
          pCONGAPRE2_ANCI_3          :=FCT_DETE_CHAM('CONGAPRE2_ANCI_3');   rSala_Impo_Cong.CONGAPRE2_ANCI_3        :=pCONGAPRE2_ANCI_3     ; if pCONGAPRE2_ANCI_3 is not null then rSala_Impo_Cong_Colo.CONGAPRE2_ANCI_3    := '35'; end if;
          pCONGAC2_FRAC              :=FCT_DETE_CHAM('CONGAC2_FRAC');       rSala_Impo_Cong.CONGAC2_FRAC            :=pCONGAC2_FRAC         ; if pCONGAC2_FRAC     is not null then rSala_Impo_Cong_Colo.CONGAC2_FRAC        := '36'; end if;
          pCONGAPRE2_FRAC            :=FCT_DETE_CHAM('CONGAPRE2_FRAC');     rSala_Impo_Cong.CONGAPRE2_FRAC          :=pCONGAPRE2_FRAC       ; if pCONGAPRE2_FRAC   is not null then rSala_Impo_Cong_Colo.CONGAPRE2_FRAC      := '37'; end if;
          pBRUTPREC1                 :=FCT_DETE_CHAM('BRUTPREC1');          rSala_Impo_Cong.BRUTPREC1               :=pBRUTPREC1            ; if pBRUTPREC1        is not null then rSala_Impo_Cong_Colo.BRUTPREC1           := '14'; end if;
          pCONGAC1_LEGA              :=FCT_DETE_CHAM('CONGAC1_LEGA');       rSala_Impo_Cong.CONGAC1_LEGA            :=pCONGAC1_LEGA         ; if pCONGAC1_LEGA     is not null then rSala_Impo_Cong_Colo.CONGAC1_LEGA        := '16'; end if;
          pCONGAPRE1_LEGA            :=FCT_DETE_CHAM('CONGAPRE1_LEGA');     rSala_Impo_Cong.CONGAPRE1_LEGA          :=pCONGAPRE1_LEGA       ; if pCONGAPRE1_LEGA   is not null then rSala_Impo_Cong_Colo.CONGAPRE1_LEGA      := '17'; end if;
          pCONGAC1_ANCI_1            :=FCT_DETE_CHAM('CONGAC1_ANCI_1');     rSala_Impo_Cong.CONGAC1_ANCI_1          :=pCONGAC1_ANCI_1       ; if pCONGAC1_ANCI_1   is not null then rSala_Impo_Cong_Colo.CONGAC1_ANCI_1      := '18'; end if;
          pCONGAPRE1_ANCI_1          :=FCT_DETE_CHAM('CONGAPRE1_ANCI_1');   rSala_Impo_Cong.CONGAPRE1_ANCI_1        :=pCONGAPRE1_ANCI_1     ; if pCONGAPRE1_ANCI_1 is not null then rSala_Impo_Cong_Colo.CONGAPRE1_ANCI_1    := '19'; end if;
          pCONGAC1_ANCI_2            :=FCT_DETE_CHAM('CONGAC1_ANCI_2');     rSala_Impo_Cong.CONGAC1_ANCI_2          :=pCONGAC1_ANCI_2       ; if pCONGAC1_ANCI_2   is not null then rSala_Impo_Cong_Colo.CONGAC1_ANCI_2      := '20'; end if;
          pCONGAPRE1_ANCI_2          :=FCT_DETE_CHAM('CONGAPRE1_ANCI_2');   rSala_Impo_Cong.CONGAPRE1_ANCI_2        :=pCONGAPRE1_ANCI_2     ; if pCONGAPRE1_ANCI_2 is not null then rSala_Impo_Cong_Colo.CONGAPRE1_ANCI_2    := '21'; end if;
          pCONGAC1_ANCI_3            :=FCT_DETE_CHAM('CONGAC1_ANCI_3');     rSala_Impo_Cong.CONGAC1_ANCI_3          :=pCONGAC1_ANCI_3       ; if pCONGAC1_ANCI_3   is not null then rSala_Impo_Cong_Colo.CONGAC1_ANCI_3      := '22'; end if;
          pCONGAPRE1_ANCI_3          :=FCT_DETE_CHAM('CONGAPRE1_ANCI_3');   rSala_Impo_Cong.CONGAPRE1_ANCI_3        :=pCONGAPRE1_ANCI_3     ; if pCONGAPRE1_ANCI_3 is not null then rSala_Impo_Cong_Colo.CONGAPRE1_ANCI_3    := '23'; end if;
          pCONGAC1_FRAC              :=FCT_DETE_CHAM('CONGAC1_FRAC');       rSala_Impo_Cong.CONGAC1_FRAC            :=pCONGAC1_FRAC         ; if pCONGAC1_FRAC     is not null then rSala_Impo_Cong_Colo.CONGAC1_FRAC        := '24'; end if;
          pCONGAPRE1_FRAC            :=FCT_DETE_CHAM('CONGAPRE1_FRAC');     rSala_Impo_Cong.CONGAPRE1_FRAC          :=pCONGAPRE1_FRAC       ; if pCONGAPRE1_FRAC   is not null then rSala_Impo_Cong_Colo.CONGAPRE1_FRAC      := '25'; end if;
          pBRUTPREC0                 :=FCT_DETE_CHAM('BRUTPREC0');          rSala_Impo_Cong.BRUTPREC0               :=pBRUTPREC0            ; if pBRUTPREC0        is not null then rSala_Impo_Cong_Colo.BRUTPREC0           := '2'; end if;
          pCOACOURS_LEGA             :=FCT_DETE_CHAM('COACOURS_LEGA');      rSala_Impo_Cong.COACOURS_LEGA           :=pCOACOURS_LEGA        ; if pCOACOURS_LEGA    is not null then rSala_Impo_Cong_Colo.COACOURS_LEGA       := '4'; end if;
          pCONGAPRE0_LEGA            :=FCT_DETE_CHAM('CONGAPRE0_LEGA');     rSala_Impo_Cong.CONGAPRE0_LEGA          :=pCONGAPRE0_LEGA       ; if pCONGAPRE0_LEGA   is not null then rSala_Impo_Cong_Colo.CONGAPRE0_LEGA      := '5'; end if;
          pCOACOURS_ANCI_1           :=FCT_DETE_CHAM('COACOURS_ANCI_1');    rSala_Impo_Cong.COACOURS_ANCI_1         :=pCOACOURS_ANCI_1      ; if pCOACOURS_ANCI_1  is not null then rSala_Impo_Cong_Colo.COACOURS_ANCI_1     := '6'; end if;
          pCONGAPRE0_ANCI_1          :=FCT_DETE_CHAM('CONGAPRE0_ANCI_1');   rSala_Impo_Cong.CONGAPRE0_ANCI_1        :=pCONGAPRE0_ANCI_1     ; if pCONGAPRE0_ANCI_1 is not null then rSala_Impo_Cong_Colo.CONGAPRE0_ANCI_1    := '7'; end if;
          pCOACOURS_ANCI_2           :=FCT_DETE_CHAM('COACOURS_ANCI_2');    rSala_Impo_Cong.COACOURS_ANCI_2         :=pCOACOURS_ANCI_2      ; if pCOACOURS_ANCI_2  is not null then rSala_Impo_Cong_Colo.COACOURS_ANCI_2     := '8'; end if;
          pCONGAPRE0_ANCI_2          :=FCT_DETE_CHAM('CONGAPRE0_ANCI_2');   rSala_Impo_Cong.CONGAPRE0_ANCI_2        :=pCONGAPRE0_ANCI_2     ; if pCONGAPRE0_ANCI_2 is not null then rSala_Impo_Cong_Colo.CONGAPRE0_ANCI_2    := '9'; end if;
          pCOACOURS_ANCI_3           :=FCT_DETE_CHAM('COACOURS_ANCI_3');    rSala_Impo_Cong.COACOURS_ANCI_3         :=pCOACOURS_ANCI_3      ; if pCOACOURS_ANCI_3  is not null then rSala_Impo_Cong_Colo.COACOURS_ANCI_3     := '10'; end if;
          pCONGAPRE0_ANCI_3          :=FCT_DETE_CHAM('CONGAPRE0_ANCI_3');   rSala_Impo_Cong.CONGAPRE0_ANCI_3        :=pCONGAPRE0_ANCI_3     ; if pCONGAPRE0_ANCI_3 is not null then rSala_Impo_Cong_Colo.CONGAPRE0_ANCI_3    := '11'; end if;
          pCOACOURS_FRAC             :=FCT_DETE_CHAM('COACOURS_FRAC');      rSala_Impo_Cong.COACOURS_FRAC           :=pCOACOURS_FRAC        ; if pCOACOURS_FRAC    is not null then rSala_Impo_Cong_Colo.COACOURS_FRAC       := '12'; end if;
          pCONGAPRE0_FRAC            :=FCT_DETE_CHAM('CONGAPRE0_FRAC');     rSala_Impo_Cong.CONGAPRE0_FRAC          :=pCONGAPRE0_FRAC       ; if pCONGAPRE0_FRAC   is not null then rSala_Impo_Cong_Colo.CONGAPRE0_FRAC      := '13'; end if;
          pBRUTPRECM1                :=FCT_DETE_CHAM('BRUTPRECM1');         rSala_Impo_Cong.BRUTPRECM1              :=pBRUTPRECM1           ; if pBRUTPRECM1       is not null then rSala_Impo_Cong_Colo.BRUTPRECM1          := '1'; end if;

          pCP_INDE_MONT_N0_PREC     :=FCT_DETE_CHAM('CP_INDE_MONT_N0_PREC');rSala_Impo_Cong.CP_INDE_MONT_N0_PREC              :=pCP_INDE_MONT_N0_PREC         ; if pCP_INDE_MONT_N0_PREC is not null then rSala_Impo_Cong_Colo.CP_INDE_MONT_N0_PREC := '3'; end if;
          pCP_INDE_MONT_N1_PREC     :=FCT_DETE_CHAM('CP_INDE_MONT_N1_PREC');rSala_Impo_Cong.CP_INDE_MONT_N1_PREC              :=pCP_INDE_MONT_N1_PREC         ; if pCP_INDE_MONT_N1_PREC is not null then rSala_Impo_Cong_Colo.CP_INDE_MONT_N1_PREC := '15'; end if;
          pCP_INDE_MONT_N2_PREC     :=FCT_DETE_CHAM('CP_INDE_MONT_N2_PREC');rSala_Impo_Cong.CP_INDE_MONT_N2_PREC              :=pCP_INDE_MONT_N2_PREC         ; if pCP_INDE_MONT_N2_PREC is not null then rSala_Impo_Cong_Colo.CP_INDE_MONT_N2_PREC := '27'; end if;
          pCP_INDE_MONT_N3_PREC     :=FCT_DETE_CHAM('CP_INDE_MONT_N3_PREC');rSala_Impo_Cong.CP_INDE_MONT_N3_PREC              :=pCP_INDE_MONT_N3_PREC         ; if pCP_INDE_MONT_N3_PREC is not null then rSala_Impo_Cong_Colo.CP_INDE_MONT_N3_PREC := '39'; end if;
          pCP_INDE_MONT_N4_PREC     :=FCT_DETE_CHAM('CP_INDE_MONT_N4_PREC');rSala_Impo_Cong.CP_INDE_MONT_N4_PREC              :=pCP_INDE_MONT_N4_PREC         ; if pCP_INDE_MONT_N4_PREC is not null then rSala_Impo_Cong_Colo.CP_INDE_MONT_N4_PREC := '51'; end if;

          pRTTAN                     :=FCT_DETE_CHAM('RTTAN');              rSala_Impo_Cong.RTTAN                   :=pRTTAN              ; if pRTTAN              is not null then rSala_Impo_Cong_Colo.RTTAN               := '62'; end if;
          pRTTPRIANN                 :=FCT_DETE_CHAM('RTTPRIANN');          rSala_Impo_Cong.RTTPRIANN               :=pRTTPRIANN          ; if pRTTPRIANN          is not null then rSala_Impo_Cong_Colo.RTTPRIANN           := '63'; end if;
          pRTTAPRE                   :=FCT_DETE_CHAM('RTTAPRE');            rSala_Impo_Cong.RTTAPRE                 :=pRTTAPRE            ; if pRTTAPRE            is not null then rSala_Impo_Cong_Colo.RTTAPRE             := '64'; end if;
          pRTTREPRIS                 :=FCT_DETE_CHAM('RTTREPRIS');          rSala_Impo_Cong.RTTREPRIS               :=pRTTREPRIS          ; if pRTTREPRIS          is not null then rSala_Impo_Cong_Colo.RTTREPRIS           := '65'; end if;
          pRTT_SALA_REST_CLOT        :=FCT_DETE_CHAM('RTT_SALA_REST_CLOT'); rSala_Impo_Cong.RTT_SALA_REST_CLOT      :=pRTT_SALA_REST_CLOT ; if pRTT_SALA_REST_CLOT is not null then rSala_Impo_Cong_Colo.RTT_SALA_REST_CLOT  := '66'; end if;

          pRTTANPAT                  :=FCT_DETE_CHAM('RTTANPAT');           rSala_Impo_Cong.RTTANPAT                :=pRTTANPAT           ; if pRTTANPAT           is not null then rSala_Impo_Cong_Colo.RTTANPAT            := '67'; end if;
          pRTTPRIANNPAT              :=FCT_DETE_CHAM('RTTPRIANNPAT');       rSala_Impo_Cong.RTTPRIANNPAT            :=pRTTPRIANNPAT       ; if pRTTPRIANNPAT       is not null then rSala_Impo_Cong_Colo.RTTPRIANNPAT        := '68'; end if;
          pRTTAPREPAT                :=FCT_DETE_CHAM('RTTAPREPAT');         rSala_Impo_Cong.RTTAPREPAT              :=pRTTAPREPAT         ; if pRTTAPREPAT         is not null then rSala_Impo_Cong_Colo.RTTAPREPAT          := '69'; end if;
          pRTTREPRISPAT              :=FCT_DETE_CHAM('RTTREPRISPAT');       rSala_Impo_Cong.RTTREPRISPAT            :=pRTTREPRISPAT       ; if pRTTREPRISPAT       is not null then rSala_Impo_Cong_Colo.RTTREPRISPAT        := '70'; end if;
          pRTT_PATR_REST_CLOT        :=FCT_DETE_CHAM('RTT_PATR_REST_CLOT'); rSala_Impo_Cong.RTT_PATR_REST_CLOT      :=pRTT_PATR_REST_CLOT ; if pRTT_PATR_REST_CLOT is not null then rSala_Impo_Cong_Colo.RTT_PATR_REST_CLOT  := '71'; end if;


          pCETACQRTTPATANN           :=FCT_DETE_CHAM('CETACQRTTPATANN');    rSala_Impo_Cong.CETACQRTTPATANN         :=pCETACQRTTPATANN    ; if pCETACQRTTPATANN is not null then rSala_Impo_Cong_Colo.CETACQRTTPATANN := '90'; end if;
          pCETPRIRTTPATANN           :=FCT_DETE_CHAM('CETPRIRTTPATANN');    rSala_Impo_Cong.CETPRIRTTPATANN         :=pCETPRIRTTPATANN    ; if pCETPRIRTTPATANN is not null then rSala_Impo_Cong_Colo.CETPRIRTTPATANN := '91'; end if;
          pCETACQRTTSALANN           :=FCT_DETE_CHAM('CETACQRTTSALANN');    rSala_Impo_Cong.CETACQRTTSALANN         :=pCETACQRTTSALANN    ; if pCETACQRTTSALANN is not null then rSala_Impo_Cong_Colo.CETACQRTTSALANN := '87'; end if;
          pCETPRIRTTSALANN           :=FCT_DETE_CHAM('CETPRIRTTSALANN');    rSala_Impo_Cong.CETPRIRTTSALANN         :=pCETPRIRTTSALANN    ; if pCETPRIRTTSALANN is not null then rSala_Impo_Cong_Colo.CETPRIRTTSALANN := '88'; end if;
          pCETACQCPANN               :=FCT_DETE_CHAM('CETACQCPANN');        rSala_Impo_Cong.CETACQCPANN             :=pCETACQCPANN        ; if pCETACQCPANN     is not null then rSala_Impo_Cong_Colo.CETACQCPANN     := '84'; end if;
          pCETPRICPANN               :=FCT_DETE_CHAM('CETPRICPANN');        rSala_Impo_Cong.CETPRICPANN             :=pCETPRICPANN        ; if pCETPRICPANN     is not null then rSala_Impo_Cong_Colo.CETPRICPANN     := '85'; end if;
          pCETRESCP                  :=FCT_DETE_CHAM('CETRESCP');           rSala_Impo_Cong.CETRESCP                :=pCETRESCP           ; if pCETRESCP        is not null then rSala_Impo_Cong_Colo.CETRESCP        := '86'; end if;
          pCETRESRTTPAT              :=FCT_DETE_CHAM('CETRESRTTPAT');       rSala_Impo_Cong.CETRESRTTPAT            :=pCETRESRTTPAT       ; if pCETRESRTTPAT    is not null then rSala_Impo_Cong_Colo.CETRESRTTPAT    := '92'; end if;
          pCETRESRTTSAL              :=FCT_DETE_CHAM('CETRESRTTSAL');       rSala_Impo_Cong.CETRESRTTSAL            :=pCETRESRTTSAL       ; if pCETRESRTTSAL    is not null then rSala_Impo_Cong_Colo.CETRESRTTSAL    := '89'; end if;
          pCETACQCPNOMOANN           :=FCT_DETE_CHAM('CETACQCPNOMOANN');    rSala_Impo_Cong.CETACQCPNOMOANN         :=pCETACQCPNOMOANN    ; if pCETACQCPNOMOANN is not null then rSala_Impo_Cong_Colo.CETACQCPNOMOANN := '156'; end if;
          pCETPRICPNOMOANN           :=FCT_DETE_CHAM('CETPRICPNOMOANN');    rSala_Impo_Cong.CETPRICPNOMOANN         :=pCETPRICPNOMOANN    ; if pCETPRICPNOMOANN is not null then rSala_Impo_Cong_Colo.CETPRICPNOMOANN := '157'; end if;
          pCETRESCPNOMO              :=FCT_DETE_CHAM('CETRESCPNOMO');       rSala_Impo_Cong.CETRESCPNOMO            :=pCETRESCPNOMO       ; if pCETRESCPNOMO    is not null then rSala_Impo_Cong_Colo.CETRESCPNOMO    := '158'; end if;
          pREPACQUI                  :=FCT_DETE_CHAM('REPACQUI');           rSala_Impo_Cong.REPACQUI                :=pREPACQUI           ; if pREPACQUI        is not null then rSala_Impo_Cong_Colo.REPACQUI        := '75'; end if;
          pREPOPRISAN                :=FCT_DETE_CHAM('REPOPRISAN');         rSala_Impo_Cong.REPOPRISAN              :=pREPOPRISAN         ; if pREPOPRISAN      is not null then rSala_Impo_Cong_Colo.REPOPRISAN      := '76'; end if;
          pREPOSCUM                  :=FCT_DETE_CHAM('REPOSCUM');           rSala_Impo_Cong.REPOSCUM                :=pREPOSCUM           ; if pREPOSCUM        is not null then rSala_Impo_Cong_Colo.REPOSCUM        := '77'; end if;

          -- compteurs supplémentaires, RCR, RCN (T80556)
          pRTTANSUP                  :=FCT_DETE_CHAM('RTTANSUP');           rSala_Impo_Cong.RTTANSUP                :=pRTTANSUP           ; if pRTTANSUP          is not null then rSala_Impo_Cong_Colo.RTTANSUP           := '72'; end if;
          pRTTPRIANNSUP              :=FCT_DETE_CHAM('RTTPRIANNSUP');       rSala_Impo_Cong.RTTPRIANNSUP            :=pRTTPRIANNSUP       ; if pRTTPRIANNSUP      is not null then rSala_Impo_Cong_Colo.RTTPRIANNSUP       := '73'; end if;
          pRTTAPRESUP                :=FCT_DETE_CHAM('RTTAPRESUP');         rSala_Impo_Cong.RTTAPRESUP              :=pRTTAPRESUP         ; if pRTTAPRESUP        is not null then rSala_Impo_Cong_Colo.RTTAPRESUP         := '74'; end if;
          pCOSU_01_ACQU_ANNE         :=FCT_DETE_CHAM('COSU_01_ACQU_ANNE');  rSala_Impo_Cong.COSU_01_ACQU_ANNE       :=pCOSU_01_ACQU_ANNE  ; if pCOSU_01_ACQU_ANNE is not null then rSala_Impo_Cong_Colo.COSU_01_ACQU_ANNE  := '93'; end if;
          pCOSU_01_PRIS_ANNE         :=FCT_DETE_CHAM('COSU_01_PRIS_ANNE');  rSala_Impo_Cong.COSU_01_PRIS_ANNE       :=pCOSU_01_PRIS_ANNE  ; if pCOSU_01_PRIS_ANNE is not null then rSala_Impo_Cong_Colo.COSU_01_PRIS_ANNE  := '94'; end if;
          pCOSU_01_REST              :=FCT_DETE_CHAM('COSU_01_REST');       rSala_Impo_Cong.COSU_01_REST            :=pCOSU_01_REST       ; if pCOSU_01_REST      is not null then rSala_Impo_Cong_Colo.COSU_01_REST       := '95'; end if;
          pCOSU_02_ACQU_ANNE         :=FCT_DETE_CHAM('COSU_02_ACQU_ANNE');  rSala_Impo_Cong.COSU_02_ACQU_ANNE       :=pCOSU_02_ACQU_ANNE  ; if pCOSU_02_ACQU_ANNE is not null then rSala_Impo_Cong_Colo.COSU_02_ACQU_ANNE  := '102'; end if;
          pCOSU_02_PRIS_ANNE         :=FCT_DETE_CHAM('COSU_02_PRIS_ANNE');  rSala_Impo_Cong.COSU_02_PRIS_ANNE       :=pCOSU_02_PRIS_ANNE  ; if pCOSU_02_PRIS_ANNE is not null then rSala_Impo_Cong_Colo.COSU_02_PRIS_ANNE  := '103'; end if;
          pCOSU_02_REST              :=FCT_DETE_CHAM('COSU_02_REST');       rSala_Impo_Cong.COSU_02_REST            :=pCOSU_02_REST       ; if pCOSU_02_REST      is not null then rSala_Impo_Cong_Colo.COSU_02_REST       := '104'; end if;
          pCOSU_03_ACQU_ANNE         :=FCT_DETE_CHAM('COSU_03_ACQU_ANNE');  rSala_Impo_Cong.COSU_03_ACQU_ANNE       :=pCOSU_03_ACQU_ANNE  ; if pCOSU_03_ACQU_ANNE is not null then rSala_Impo_Cong_Colo.COSU_03_ACQU_ANNE  := '111'; end if;
          pCOSU_03_PRIS_ANNE         :=FCT_DETE_CHAM('COSU_03_PRIS_ANNE');  rSala_Impo_Cong.COSU_03_PRIS_ANNE       :=pCOSU_03_PRIS_ANNE  ; if pCOSU_03_PRIS_ANNE is not null then rSala_Impo_Cong_Colo.COSU_03_PRIS_ANNE  := '112'; end if;
          pCOSU_03_REST              :=FCT_DETE_CHAM('COSU_03_REST');       rSala_Impo_Cong.COSU_03_REST            :=pCOSU_03_REST       ; if pCOSU_03_REST      is not null then rSala_Impo_Cong_Colo.COSU_03_REST       := '113'; end if;
          pRCRACQUIANN               :=FCT_DETE_CHAM('RCRACQUIANN');        rSala_Impo_Cong.RCRACQUIANN             :=pRCRACQUIANN        ; if pRCRACQUIANN       is not null then rSala_Impo_Cong_Colo.RCRACQUIANN        := '78'; end if;
          pRCRPRISAN                 :=FCT_DETE_CHAM('RCRPRISAN');          rSala_Impo_Cong.RCRPRISAN               :=pRCRPRISAN          ; if pRCRPRISAN         is not null then rSala_Impo_Cong_Colo.RCRPRISAN          := '79'; end if;
          pRCRCUM                    :=FCT_DETE_CHAM('RCRCUM');             rSala_Impo_Cong.RCRCUM                  :=pRCRCUM             ; if pRCRCUM            is not null then rSala_Impo_Cong_Colo.RCRCUM             := '80'; end if;
          pRCNACQUIANN               :=FCT_DETE_CHAM('RCNACQUIANN');        rSala_Impo_Cong.RCNACQUIANN             :=pRCNACQUIANN        ; if pRCNACQUIANN       is not null then rSala_Impo_Cong_Colo.RCNACQUIANN        := '81'; end if;
          pRCNPRISAN                 :=FCT_DETE_CHAM('RCNPRISAN');          rSala_Impo_Cong.RCNPRISAN               :=pRCNPRISAN          ; if pRCNPRISAN         is not null then rSala_Impo_Cong_Colo.RCNPRISAN          := '82'; end if;
          pRCNCUM                    :=FCT_DETE_CHAM('RCNCUM');             rSala_Impo_Cong.RCNCUM                  :=pRCNCUM             ; if pRCNCUM            is not null then rSala_Impo_Cong_Colo.RCNCUM             := '83'; end if;

          pCOSU_01_ACQU_ANNE_N1      :=FCT_DETE_CHAM('COSU_01_ACQU_ANNE_N1'); rSala_Impo_Cong.COSU_01_ACQU_ANNE_N1 :=pCOSU_01_ACQU_ANNE_N1; if pCOSU_01_ACQU_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_01_ACQU_ANNE_N1 := '96'; end if;
          pCOSU_01_PRIS_ANNE_N1      :=FCT_DETE_CHAM('COSU_01_PRIS_ANNE_N1'); rSala_Impo_Cong.COSU_01_PRIS_ANNE_N1 :=pCOSU_01_PRIS_ANNE_N1; if pCOSU_01_PRIS_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_01_PRIS_ANNE_N1 := '97'; end if;
          pCOSU_01_REST_N1           :=FCT_DETE_CHAM('COSU_01_REST_N1');      rSala_Impo_Cong.COSU_01_REST_N1      :=pCOSU_01_REST_N1     ; if pCOSU_01_REST_N1      is not null then rSala_Impo_Cong_Colo.COSU_01_REST_N1      := '98'; end if;
          pCOSU_02_ACQU_ANNE_N1      :=FCT_DETE_CHAM('COSU_02_ACQU_ANNE_N1'); rSala_Impo_Cong.COSU_02_ACQU_ANNE_N1 :=pCOSU_02_ACQU_ANNE_N1; if pCOSU_02_ACQU_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_02_ACQU_ANNE_N1 := '105'; end if;
          pCOSU_02_PRIS_ANNE_N1      :=FCT_DETE_CHAM('COSU_02_PRIS_ANNE_N1'); rSala_Impo_Cong.COSU_02_PRIS_ANNE_N1 :=pCOSU_02_PRIS_ANNE_N1; if pCOSU_02_PRIS_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_02_PRIS_ANNE_N1 := '106'; end if;
          pCOSU_02_REST_N1           :=FCT_DETE_CHAM('COSU_02_REST_N1');      rSala_Impo_Cong.COSU_02_REST_N1      :=pCOSU_02_REST_N1     ; if pCOSU_02_REST_N1      is not null then rSala_Impo_Cong_Colo.COSU_02_REST_N1      := '107'; end if;
          pCOSU_03_ACQU_ANNE_N1      :=FCT_DETE_CHAM('COSU_03_ACQU_ANNE_N1'); rSala_Impo_Cong.COSU_03_ACQU_ANNE_N1 :=pCOSU_03_ACQU_ANNE_N1; if pCOSU_03_ACQU_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_03_ACQU_ANNE_N1 := '114'; end if;
          pCOSU_03_PRIS_ANNE_N1      :=FCT_DETE_CHAM('COSU_03_PRIS_ANNE_N1'); rSala_Impo_Cong.COSU_03_PRIS_ANNE_N1 :=pCOSU_03_PRIS_ANNE_N1; if pCOSU_03_PRIS_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_03_PRIS_ANNE_N1 := '115'; end if;
          pCOSU_03_REST_N1           :=FCT_DETE_CHAM('COSU_03_REST_N1');      rSala_Impo_Cong.COSU_03_REST_N1      :=pCOSU_03_REST_N1     ; if pCOSU_03_REST_N1      is not null then rSala_Impo_Cong_Colo.COSU_03_REST_N1      := '116'; end if;
          pCOSU_01_ACQU_ANNE_N2      :=FCT_DETE_CHAM('COSU_01_ACQU_ANNE_N2'); rSala_Impo_Cong.COSU_01_ACQU_ANNE_N2 :=pCOSU_01_ACQU_ANNE_N2; if pCOSU_01_ACQU_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_01_ACQU_ANNE_N2 := '99'; end if;
          pCOSU_01_PRIS_ANNE_N2      :=FCT_DETE_CHAM('COSU_01_PRIS_ANNE_N2'); rSala_Impo_Cong.COSU_01_PRIS_ANNE_N2 :=pCOSU_01_PRIS_ANNE_N2; if pCOSU_01_PRIS_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_01_PRIS_ANNE_N2 := '100'; end if;
          pCOSU_01_REST_N2           :=FCT_DETE_CHAM('COSU_01_REST_N2');      rSala_Impo_Cong.COSU_01_REST_N2      :=pCOSU_01_REST_N2     ; if pCOSU_01_REST_N2      is not null then rSala_Impo_Cong_Colo.COSU_01_REST_N2      := '101'; end if;
          pCOSU_02_ACQU_ANNE_N2      :=FCT_DETE_CHAM('COSU_02_ACQU_ANNE_N2'); rSala_Impo_Cong.COSU_02_ACQU_ANNE_N2 :=pCOSU_02_ACQU_ANNE_N2; if pCOSU_02_ACQU_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_02_ACQU_ANNE_N2 := '108'; end if;
          pCOSU_02_PRIS_ANNE_N2      :=FCT_DETE_CHAM('COSU_02_PRIS_ANNE_N2'); rSala_Impo_Cong.COSU_02_PRIS_ANNE_N2 :=pCOSU_02_PRIS_ANNE_N2; if pCOSU_02_PRIS_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_02_PRIS_ANNE_N2 := '109'; end if;
          pCOSU_02_REST_N2           :=FCT_DETE_CHAM('COSU_02_REST_N2');      rSala_Impo_Cong.COSU_02_REST_N2      :=pCOSU_02_REST_N2     ; if pCOSU_02_REST_N2      is not null then rSala_Impo_Cong_Colo.COSU_02_REST_N2      := '110'; end if;
          pCOSU_03_ACQU_ANNE_N2      :=FCT_DETE_CHAM('COSU_03_ACQU_ANNE_N2'); rSala_Impo_Cong.COSU_03_ACQU_ANNE_N2 :=pCOSU_03_ACQU_ANNE_N2; if pCOSU_03_ACQU_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_03_ACQU_ANNE_N2 := '117'; end if;
          pCOSU_03_PRIS_ANNE_N2      :=FCT_DETE_CHAM('COSU_03_PRIS_ANNE_N2'); rSala_Impo_Cong.COSU_03_PRIS_ANNE_N2 :=pCOSU_03_PRIS_ANNE_N2; if pCOSU_03_PRIS_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_03_PRIS_ANNE_N2 := '118'; end if;
          pCOSU_03_REST_N2           :=FCT_DETE_CHAM('COSU_03_REST_N2');      rSala_Impo_Cong.COSU_03_REST_N2      :=pCOSU_03_REST_N2     ; if pCOSU_03_REST_N2      is not null then rSala_Impo_Cong_Colo.COSU_03_REST_N2      := '119'; end if;

          pCOSU_04_ACQU_ANNE         :=FCT_DETE_CHAM('COSU_04_ACQU_ANNE');    rSala_Impo_Cong.COSU_04_ACQU_ANNE    :=pCOSU_04_ACQU_ANNE   ; if pCOSU_04_ACQU_ANNE    is not null then rSala_Impo_Cong_Colo.COSU_04_ACQU_ANNE    := '120'; end if;
          pCOSU_04_PRIS_ANNE         :=FCT_DETE_CHAM('COSU_04_PRIS_ANNE');    rSala_Impo_Cong.COSU_04_PRIS_ANNE    :=pCOSU_04_PRIS_ANNE   ; if pCOSU_04_PRIS_ANNE    is not null then rSala_Impo_Cong_Colo.COSU_04_PRIS_ANNE    := '121'; end if;
          pCOSU_04_REST              :=FCT_DETE_CHAM('COSU_04_REST');         rSala_Impo_Cong.COSU_04_REST         :=pCOSU_04_REST        ; if pCOSU_04_REST         is not null then rSala_Impo_Cong_Colo.COSU_04_REST         := '122'; end if;
          pCOSU_04_ACQU_ANNE_N1      :=FCT_DETE_CHAM('COSU_04_ACQU_ANNE_N1'); rSala_Impo_Cong.COSU_04_ACQU_ANNE_N1 :=pCOSU_04_ACQU_ANNE_N1; if pCOSU_04_ACQU_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_04_ACQU_ANNE_N1 := '123'; end if;
          pCOSU_04_PRIS_ANNE_N1      :=FCT_DETE_CHAM('COSU_04_PRIS_ANNE_N1'); rSala_Impo_Cong.COSU_04_PRIS_ANNE_N1 :=pCOSU_04_PRIS_ANNE_N1; if pCOSU_04_PRIS_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_04_PRIS_ANNE_N1 := '124'; end if;
          pCOSU_04_REST_N1           :=FCT_DETE_CHAM('COSU_04_REST_N1');      rSala_Impo_Cong.COSU_04_REST_N1      :=pCOSU_04_REST_N1     ; if pCOSU_04_REST_N1      is not null then rSala_Impo_Cong_Colo.COSU_04_REST_N1      := '125'; end if;
          pCOSU_04_ACQU_ANNE_N2      :=FCT_DETE_CHAM('COSU_04_ACQU_ANNE_N2'); rSala_Impo_Cong.COSU_04_ACQU_ANNE_N2 :=pCOSU_04_ACQU_ANNE_N2; if pCOSU_04_ACQU_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_04_ACQU_ANNE_N2 := '126'; end if;
          pCOSU_04_PRIS_ANNE_N2      :=FCT_DETE_CHAM('COSU_04_PRIS_ANNE_N2'); rSala_Impo_Cong.COSU_04_PRIS_ANNE_N2 :=pCOSU_04_PRIS_ANNE_N2; if pCOSU_04_PRIS_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_04_PRIS_ANNE_N2 := '127'; end if;
          pCOSU_04_REST_N2           :=FCT_DETE_CHAM('COSU_04_REST_N2');      rSala_Impo_Cong.COSU_04_REST_N2      :=pCOSU_04_REST_N2     ; if pCOSU_04_REST_N2      is not null then rSala_Impo_Cong_Colo.COSU_04_REST_N2      := '128'; end if;

          pCOSU_05_ACQU_ANNE         :=FCT_DETE_CHAM('COSU_05_ACQU_ANNE');    rSala_Impo_Cong.COSU_05_ACQU_ANNE    :=pCOSU_05_ACQU_ANNE   ; if pCOSU_05_ACQU_ANNE    is not null then rSala_Impo_Cong_Colo.COSU_05_ACQU_ANNE    := '129'; end if;
          pCOSU_05_PRIS_ANNE         :=FCT_DETE_CHAM('COSU_05_PRIS_ANNE');    rSala_Impo_Cong.COSU_05_PRIS_ANNE    :=pCOSU_05_PRIS_ANNE   ; if pCOSU_05_PRIS_ANNE    is not null then rSala_Impo_Cong_Colo.COSU_05_PRIS_ANNE    := '130'; end if;
          pCOSU_05_REST              :=FCT_DETE_CHAM('COSU_05_REST');         rSala_Impo_Cong.COSU_05_REST         :=pCOSU_05_REST        ; if pCOSU_05_REST         is not null then rSala_Impo_Cong_Colo.COSU_05_REST         := '131'; end if;
          pCOSU_05_ACQU_ANNE_N1      :=FCT_DETE_CHAM('COSU_05_ACQU_ANNE_N1'); rSala_Impo_Cong.COSU_05_ACQU_ANNE_N1 :=pCOSU_05_ACQU_ANNE_N1; if pCOSU_05_ACQU_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_05_ACQU_ANNE_N1 := '132'; end if;
          pCOSU_05_PRIS_ANNE_N1      :=FCT_DETE_CHAM('COSU_05_PRIS_ANNE_N1'); rSala_Impo_Cong.COSU_05_PRIS_ANNE_N1 :=pCOSU_05_PRIS_ANNE_N1; if pCOSU_05_PRIS_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_05_PRIS_ANNE_N1 := '133'; end if;
          pCOSU_05_REST_N1           :=FCT_DETE_CHAM('COSU_05_REST_N1');      rSala_Impo_Cong.COSU_05_REST_N1      :=pCOSU_05_REST_N1     ; if pCOSU_05_REST_N1      is not null then rSala_Impo_Cong_Colo.COSU_05_REST_N1      := '134'; end if;
          pCOSU_05_ACQU_ANNE_N2      :=FCT_DETE_CHAM('COSU_05_ACQU_ANNE_N2'); rSala_Impo_Cong.COSU_05_ACQU_ANNE_N2 :=pCOSU_05_ACQU_ANNE_N2; if pCOSU_05_ACQU_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_05_ACQU_ANNE_N2 := '135'; end if;
          pCOSU_05_PRIS_ANNE_N2      :=FCT_DETE_CHAM('COSU_05_PRIS_ANNE_N2'); rSala_Impo_Cong.COSU_05_PRIS_ANNE_N2 :=pCOSU_05_PRIS_ANNE_N2; if pCOSU_05_PRIS_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_05_PRIS_ANNE_N2 := '136'; end if;
          pCOSU_05_REST_N2           :=FCT_DETE_CHAM('COSU_05_REST_N2');      rSala_Impo_Cong.COSU_05_REST_N2      :=pCOSU_05_REST_N2     ; if pCOSU_05_REST_N2      is not null then rSala_Impo_Cong_Colo.COSU_05_REST_N2      := '137'; end if;

          pCOSU_06_ACQU_ANNE         :=FCT_DETE_CHAM('COSU_06_ACQU_ANNE');    rSala_Impo_Cong.COSU_06_ACQU_ANNE    :=pCOSU_06_ACQU_ANNE   ; if pCOSU_06_ACQU_ANNE    is not null then rSala_Impo_Cong_Colo.COSU_06_ACQU_ANNE    := '138'; end if;
          pCOSU_06_PRIS_ANNE         :=FCT_DETE_CHAM('COSU_06_PRIS_ANNE');    rSala_Impo_Cong.COSU_06_PRIS_ANNE    :=pCOSU_06_PRIS_ANNE   ; if pCOSU_06_PRIS_ANNE    is not null then rSala_Impo_Cong_Colo.COSU_06_PRIS_ANNE    := '139'; end if;
          pCOSU_06_REST              :=FCT_DETE_CHAM('COSU_06_REST');         rSala_Impo_Cong.COSU_06_REST         :=pCOSU_06_REST        ; if pCOSU_06_REST         is not null then rSala_Impo_Cong_Colo.COSU_06_REST         := '140'; end if;
          pCOSU_06_ACQU_ANNE_N1      :=FCT_DETE_CHAM('COSU_06_ACQU_ANNE_N1'); rSala_Impo_Cong.COSU_06_ACQU_ANNE_N1 :=pCOSU_06_ACQU_ANNE_N1; if pCOSU_06_ACQU_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_06_ACQU_ANNE_N1 := '141'; end if;
          pCOSU_06_PRIS_ANNE_N1      :=FCT_DETE_CHAM('COSU_06_PRIS_ANNE_N1'); rSala_Impo_Cong.COSU_06_PRIS_ANNE_N1 :=pCOSU_06_PRIS_ANNE_N1; if pCOSU_06_PRIS_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_06_PRIS_ANNE_N1 := '142'; end if;
          pCOSU_06_REST_N1           :=FCT_DETE_CHAM('COSU_06_REST_N1');      rSala_Impo_Cong.COSU_06_REST_N1      :=pCOSU_06_REST_N1     ; if pCOSU_06_REST_N1      is not null then rSala_Impo_Cong_Colo.COSU_06_REST_N1      := '143'; end if;
          pCOSU_06_ACQU_ANNE_N2      :=FCT_DETE_CHAM('COSU_06_ACQU_ANNE_N2'); rSala_Impo_Cong.COSU_06_ACQU_ANNE_N2 :=pCOSU_06_ACQU_ANNE_N2; if pCOSU_06_ACQU_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_06_ACQU_ANNE_N2 := '144'; end if;
          pCOSU_06_PRIS_ANNE_N2      :=FCT_DETE_CHAM('COSU_06_PRIS_ANNE_N2'); rSala_Impo_Cong.COSU_06_PRIS_ANNE_N2 :=pCOSU_06_PRIS_ANNE_N2; if pCOSU_06_PRIS_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_06_PRIS_ANNE_N2 := '145'; end if;
          pCOSU_06_REST_N2           :=FCT_DETE_CHAM('COSU_06_REST_N2');      rSala_Impo_Cong.COSU_06_REST_N2      :=pCOSU_06_REST_N2     ; if pCOSU_06_REST_N2      is not null then rSala_Impo_Cong_Colo.COSU_06_REST_N2      := '146'; end if;

          pCOSU_07_ACQU_ANNE         :=FCT_DETE_CHAM('COSU_07_ACQU_ANNE');    rSala_Impo_Cong.COSU_07_ACQU_ANNE    :=pCOSU_07_ACQU_ANNE   ; if pCOSU_07_ACQU_ANNE    is not null then rSala_Impo_Cong_Colo.COSU_07_ACQU_ANNE    := '147'; end if;
          pCOSU_07_PRIS_ANNE         :=FCT_DETE_CHAM('COSU_07_PRIS_ANNE');    rSala_Impo_Cong.COSU_07_PRIS_ANNE    :=pCOSU_07_PRIS_ANNE   ; if pCOSU_07_PRIS_ANNE    is not null then rSala_Impo_Cong_Colo.COSU_07_PRIS_ANNE    := '148'; end if;
          pCOSU_07_REST              :=FCT_DETE_CHAM('COSU_07_REST');         rSala_Impo_Cong.COSU_07_REST         :=pCOSU_07_REST        ; if pCOSU_07_REST         is not null then rSala_Impo_Cong_Colo.COSU_07_REST         := '149'; end if;
          pCOSU_07_ACQU_ANNE_N1      :=FCT_DETE_CHAM('COSU_07_ACQU_ANNE_N1'); rSala_Impo_Cong.COSU_07_ACQU_ANNE_N1 :=pCOSU_07_ACQU_ANNE_N1; if pCOSU_07_ACQU_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_07_ACQU_ANNE_N1 := '150'; end if;
          pCOSU_07_PRIS_ANNE_N1      :=FCT_DETE_CHAM('COSU_07_PRIS_ANNE_N1'); rSala_Impo_Cong.COSU_07_PRIS_ANNE_N1 :=pCOSU_07_PRIS_ANNE_N1; if pCOSU_07_PRIS_ANNE_N1 is not null then rSala_Impo_Cong_Colo.COSU_07_PRIS_ANNE_N1 := '151'; end if;
          pCOSU_07_REST_N1           :=FCT_DETE_CHAM('COSU_07_REST_N1');      rSala_Impo_Cong.COSU_07_REST_N1      :=pCOSU_07_REST_N1     ; if pCOSU_07_REST_N1      is not null then rSala_Impo_Cong_Colo.COSU_07_REST_N1      := '152'; end if;
          pCOSU_07_ACQU_ANNE_N2      :=FCT_DETE_CHAM('COSU_07_ACQU_ANNE_N2'); rSala_Impo_Cong.COSU_07_ACQU_ANNE_N2 :=pCOSU_07_ACQU_ANNE_N2; if pCOSU_07_ACQU_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_07_ACQU_ANNE_N2 := '153'; end if;
          pCOSU_07_PRIS_ANNE_N2      :=FCT_DETE_CHAM('COSU_07_PRIS_ANNE_N2'); rSala_Impo_Cong.COSU_07_PRIS_ANNE_N2 :=pCOSU_07_PRIS_ANNE_N2; if pCOSU_07_PRIS_ANNE_N2 is not null then rSala_Impo_Cong_Colo.COSU_07_PRIS_ANNE_N2 := '154'; end if;
          pCOSU_07_REST_N2           :=FCT_DETE_CHAM('COSU_07_REST_N2');      rSala_Impo_Cong.COSU_07_REST_N2      :=pCOSU_07_REST_N2     ; if pCOSU_07_REST_N2      is not null then rSala_Impo_Cong_Colo.COSU_07_REST_N2      := '155'; end if;

          pCOACOURS_LEGA_THEO        :=FCT_DETE_CHAM('COACOURS_LEGA_THEO');   rSala_Impo_Cong.COACOURS_LEGA_THEO   :=pCOACOURS_LEGA_THEO  ; if pCOACOURS_LEGA_THEO   is not null then rSala_Impo_Cong_Colo.COACOURS_LEGA_THEO   := '159'; end if;
          pCONGAC1_LEGA_THEO         :=FCT_DETE_CHAM('CONGAC1_LEGA_THEO');    rSala_Impo_Cong.CONGAC1_LEGA_THEO    :=pCONGAC1_LEGA_THEO   ; if pCONGAC1_LEGA_THEO    is not null then rSala_Impo_Cong_Colo.CONGAC1_LEGA_THEO    := '160'; end if;
          pCONGAC2_LEGA_THEO         :=FCT_DETE_CHAM('CONGAC2_LEGA_THEO');    rSala_Impo_Cong.CONGAC2_LEGA_THEO    :=pCONGAC2_LEGA_THEO   ; if pCONGAC2_LEGA_THEO    is not null then rSala_Impo_Cong_Colo.CONGAC2_LEGA_THEO    := '161'; end if;
          pCONGAC3_LEGA_THEO         :=FCT_DETE_CHAM('CONGAC3_LEGA_THEO');    rSala_Impo_Cong.CONGAC3_LEGA_THEO    :=pCONGAC3_LEGA_THEO   ; if pCONGAC3_LEGA_THEO    is not null then rSala_Impo_Cong_Colo.CONGAC3_LEGA_THEO    := '161'; end if;
          pCONGAC4_LEGA_THEO         :=FCT_DETE_CHAM('CONGAC4_LEGA_THEO');    rSala_Impo_Cong.CONGAC4_LEGA_THEO    :=pCONGAC4_LEGA_THEO   ; if pCONGAC4_LEGA_THEO    is not null then rSala_Impo_Cong_Colo.CONGAC4_LEGA_THEO    := '163'; end if;

          INSERT INTO SALARIE_IMPO_CONG values rSala_Impo_Cong;commit;
        end if; -- ipos vide
      end if;

      n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,PREN,NOM,DETA,NUME,ETAP,Z1,Z2,Z3,Z4,Z5)values(pID_SOCI,pPREN,pNOM,'MAIN_VALE',n,'  brut prec0=',pBRUTPREC0,' brutprec1=',pBRUTPREC1,' congac=',pCONGAC1_LEGA);commit;
    END LOOP;
  end PR_IMPORT;

  function fct__saisie_lot(pDATE_CREATION in date) return number
  is
    iID_LOT number;
  begin

    insert into SALARIE_IMPO_CONG_LOT ("ID_LOT","ID_SOCI","ID_LOGI","ID_IMPO","LIBE","DATE_CREA","TYPE_RECH_SALA")
    values ( ( select nvl(max(id_lot),0) + 1 from SALARIE_IMPO_CONG_LOT ),
            pID_SOCI,
            pID_LOGI,
            pID_IMPO,
            'Import des compteurs du '||to_char(pDATE_CREATION,'DD/MM/YYYY HH24:MI:SS'),
            pDATE_CREATION,
            'MATR_NOM'
    ) returning id_lot into iID_LOT
    ; commit;

    return iID_LOT;
  end fct__saisie_lot;


begin
  -- DELETE SALARIE_IMPO_DONN where id_soci=pID_SOCI;commit;
  rSala_Impo_Cong.ID_SOCI:=pID_SOCI;
  rSala_Impo_Cong.PERI   :=pPERI_IMPO;
  rSala_Impo_Cong.STAT_IMPO:='N';
  rSala_Impo_Cong.ID_IMPO:=parse_int(pID_IMPO);
  dDATE_IMPO := sysdate;

  delete DEBUG_IMPO_EXCEL_CONG where id_soci = pID_SOCI;
  delete SALARIE_IMPO_CONG     where id_soci = pID_SOCI and id_lot = -1;
  delete SALARIE_IMPO_CONG_LOG where id_soci = pID_SOCI and id_lot = -1;
  commit;

  pERRE:=0;

  n:=0;
  --n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,NUME,ETAP) values (pID_SOCI,n,'Début de la procédure  ');commit;
  ErrInfo:='';
  Err:=0;

  for oSOCIETE in (select s.id_soci, s.rais_soci, s.rais_soci_pont, (select max(p.peri_paie) as peri from periode p where p.id_soci=s.id_soci) as peri
                   from MV_SOCIETE_GROUPE m, SOCIETE s
                   where m.mere_id  = pID_SOCI
                     and m.fille_id = s.id_soci
  ) loop
    rSOCI.id_soci        := oSOCIETE.id_soci        ;
    rSOCI.rais_soci      := oSOCIETE.rais_soci      ;
    rSOCI.rais_soci_pont := oSOCIETE.rais_soci_pont ;
    rSOCI.peri           := oSOCIETE.peri           ;

    ri_SOCIETES(rSOCI.id_soci) := rSOCI;
  end loop;

  -- Création d'un lot d'import
 if pMAJ_DONN = 'O' then
   iID_LOT := fct__saisie_lot(dDATE_IMPO);
 else
   iID_LOT := -1;
 end if;

  PR_IMPORT;

  rSala_Impo_Cong_Colo.ID_IMPO := parse_int(pID_IMPO);
  rSala_Impo_Cong_Colo.ID_SOCI := pID_SOCI;
  INSERT INTO SALARIE_IMPO_CONG_COLO values rSala_Impo_Cong_Colo;commit;

  select count(0)into iNB_SOCI from societe where id_soci = pID_SOCI and upper(trim(replace(rais_soci,' ',''))) = upper(trim(replace(pNOM_SOCI,' ','')));

  if pID_SOCI is null then
           ErrTools.alert(ErrInfo,'Vous devez saisir une société');
           PR_MAJ_LOG(pID_SOCI        ,'ID_SOCI'    ,'Vous devez saisir une société') ;
           pERRE:=pERRE+1;
           pMAJ:='N';
  end if;

  if pPERI_IMPO is null then
           ErrTools.alert(ErrInfo,'Vous devez indiquer une période dans le fichier excel');
           PR_MAJ_LOG(pPERI_IMPO        ,'PERI_IMPO'    ,'Vous devez indiquer une période dans le fichier excel (Cellule E4)') ;
           pERRE:=pERRE+1;
           pMAJ:='N';
  end if;

  if iNB_SOCI=0 then
            ErrTools.alert(ErrInfo,'La société avec Id=' || pID_SOCI || ' et la raison sociale :' || pNOM_SOCI || ' n''a pas pu être identifiée ');
            PR_MAJ_LOG(pNOM_SOCI        ,'NOM_SOCI'    ,'La société avec Id=' || pID_SOCI || ' et la raison sociale  (Cellule E3) :' || pNOM_SOCI || ' n''a pas pu être identifiée ') ;
            pERRE:=pERRE+1;
            pMAJ:='N';
  end if;

  if pID_SOCI_FICH is null or pID_SOCI <>parse_float(pID_SOCI_FICH) then
           ErrTools.alert(ErrInfo,'Vous devez saisir une société correspondant au numéro dans le tableau EXCEL(' || pID_SOCI_FICH || ') (Cellule E3)');
           PR_MAJ_LOG(pID_SOCI_FICH        ,'ID_SOCI'    ,'Vous devez saisir une société (Cellule E3) correspondant au numéro dans le tableau EXCEL(' || pID_SOCI_FICH || ') (Cellule E2)') ;
           pERRE:=pERRE+1;
           pMAJ:='N';
  end if;

  if pTYPE_RECH_SALA is null then
           ErrTools.alert(ErrInfo, 'Veuillez choisir un mode d''identifiation des salariés');
           PR_MAJ_LOG(pID_SOCI, 'TYPE_RECH_SALA', 'Veuillez choisir un mode d''identifiation des salariés') ;
           pERRE := pERRE + 1;
           pMAJ := 'N';
  end if;

  if pID_SOCI_FICH is not null and pID_SOCI=pID_SOCI_FICH then
         select to_char(MAX(PERI_PAIE),'DD/MM/YYYY') into pPERI_COUR  from periode  where id_soci = pID_SOCI;

       n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_HIST (ID_SOCI,DETA,NUME,ETAP,Z1,Z2,Z3)values(pID_SOCI,'PERI',n,' Périodes en cours =',pPERI_COUR,' importé=',pPERI_IMPO);

--      if pPERI_IMPO<>pPERI_IMPO then
--        pERRE:=pERRE+1;
--        PR_MAJ_LOG(pPERI_IMPO,'ERRE_EXCE','La période n''est pas égale à la période en cours:'|| pPERI_IMPO || ')');
--      end if;
  end if;

  n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,DETA,NUME,ETAP,Z1,Z2,Z3) values (pID_SOCI,'MAIN',n,'après validation perre=',pERRE,' errinfo=',SUBSTR(Errinfo,1,40));commit;

  Err:=0;

  if pERRE=0 then
    For cSala_Impo_Cong in (select * from  SALARIE_IMPO_CONG WHERE ID_SOCI=pID_SOCI and id_lot = iID_LOT and id_impo = pID_IMPO ORDER BY NOM) loop
      iNUME_LIGN          := cSala_Impo_Cong.nume_lign;  -- utile pour PR_MAJ_LOG
      rSala_Impo_Cong     :=cSala_Impo_Cong;
      rSala_Impo_Cong_Cree:=cSala_Impo_Cong;
      PR_DETE_SALA;

      n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,DETA,PREN,NOM,NUME,ETAP)values(pID_SOCI,'MAIN',pPREN,pNOM,n,' dans boucle ');commit;

      Err:=0;

      if vSALA_ID_SOCI is not null and parse_int(vSALA_ID_SOCI) is null then
        iSALA_ID_SOCI := null;
        PR_MAJ_LOG('','IDEN_SOCI','La société de rattachement n''est pas valide ('||vSALA_ID_SOCI||').');
      elsif not ri_SOCIETES.exists( parse_int(vSALA_ID_SOCI) ) then
        iSALA_ID_SOCI := null;
        PR_MAJ_LOG('','IDEN_SOCI','La société de rattachement ('||vSALA_ID_SOCI||') n''est pas présente dans le groupe.');
      elsif ri_SOCIETES.exists( parse_int(vSALA_ID_SOCI) ) and fct_to_simple(vSALA_RAIS_SOCI) != fct_to_simple(ri_SOCIETES( parse_int(vSALA_ID_SOCI) ).rais_soci) then
        iSALA_ID_SOCI := null;
        PR_MAJ_LOG('','IDEN_SOCI','La société de rattachement ('||vSALA_ID_SOCI||') ne correspond pas à la raison sociale ('||vSALA_RAIS_SOCI||').');
      else
        if vSALA_ID_SOCI is not null then
          iSALA_ID_SOCI := parse_int(vSALA_ID_SOCI);
        else
          iSALA_ID_SOCI := pID_SOCI;
        end if;
      end if;

      pID_SALA:=null;
      Inb_Sala:=0;

      if iSALA_ID_SOCI is not null then
        -- identification du salarié en fonction du mode choisi (T204460)
        select max(id_sala), count(1), max(case when stat_sala = 'Présent' then id_sala end), sum(case when stat_sala = 'Présent' then 1 end)
        into pID_SALA, inb_sala, iid_sala_pres, inomb_sala_pres
        from salarie
        where id_soci = iSALA_ID_SOCI
          and (pTYPE_RECH_SALA not like 'MATR%' or ltrim(matr, '0') = ltrim(pMATR, '0'))
          and (pTYPE_RECH_SALA not like 'MATR_NOM%' or nvl(fct_to_simple(nom ), ' ') = nvl(fct_to_simple(pNOM ), ' '))
          and (pTYPE_RECH_SALA not like 'ID_SALA' or id_sala = parse_int(pMATR))  -- rmq : la colonne matricule dans le fichier doit contenir l'id_sala, en cas d'identification par id_sala
        ;

        -- si plusieurs salariés trouvés mais un seul présent alors on garde le présent (T204460)
        if inb_sala >= 2 then
          if inomb_sala_pres = 1 then  pID_SALA := iid_sala_pres;  else  pID_SALA := null;  end if;
        end if;
      end if;

      if pID_SALA is null then
        PR_MAJ_LOG(pNOM, 'SALA_EXIS', inb_sala || ' salarié(s) trouvé(s) (identification par ' || pTYPE_RECH_SALA || ')');
      end if;

      pr_cvs(pBRUTPREC4                   ,          0,9999999999,'N',bError,NewBRUTPREC4            );rSala_Impo_Cong_Cree.BRUTPREC4              :=NewBRUTPREC4           ;if bError then PR_MAJ_LOG(pBRUTPREC4                ,'BRUTPREC4'            ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC4_LEGA                ,-9999999999,9999999999,'N',bError,NewCONGAC4_LEGA         );rSala_Impo_Cong_Cree.CONGAC4_LEGA           :=NewCONGAC4_LEGA        ;if bError then PR_MAJ_LOG(pCONGAC4_LEGA             ,'CONGAC4_LEGA'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE4_LEGA              ,-9999999999,9999999999,'N',bError,NewCONGAPRE4_LEGA       );rSala_Impo_Cong_Cree.CONGAPRE4_LEGA         :=NewCONGAPRE4_LEGA      ;if bError then PR_MAJ_LOG(pCONGAPRE4_LEGA           ,'CONGAPRE4_LEGA'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC4_ANCI_1              ,-9999999999,9999999999,'N',bError,NewCONGAC4_ANCI_1       );rSala_Impo_Cong_Cree.CONGAC4_ANCI_1         :=NewCONGAC4_ANCI_1      ;if bError then PR_MAJ_LOG(pCONGAC4_ANCI_1           ,'CONGAC4_ANCI_1'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE4_ANCI_1            ,-9999999999,9999999999,'N',bError,NewCONGAPRE4_ANCI_1     );rSala_Impo_Cong_Cree.CONGAPRE4_ANCI_1       :=NewCONGAPRE4_ANCI_1    ;if bError then PR_MAJ_LOG(pCONGAPRE4_ANCI_1         ,'CONGAPRE4_ANCI_1'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC4_ANCI_2              ,-9999999999,9999999999,'N',bError,NewCONGAC4_ANCI_2       );rSala_Impo_Cong_Cree.CONGAC4_ANCI_2         :=NewCONGAC4_ANCI_2      ;if bError then PR_MAJ_LOG(pCONGAC4_ANCI_2           ,'CONGAC4_ANCI_2'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE4_ANCI_2            ,-9999999999,9999999999,'N',bError,NewCONGAPRE4_ANCI_2     );rSala_Impo_Cong_Cree.CONGAPRE4_ANCI_2       :=NewCONGAPRE4_ANCI_2    ;if bError then PR_MAJ_LOG(pCONGAPRE4_ANCI_2         ,'CONGAPRE4_ANCI_2'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC4_ANCI_3              ,-9999999999,9999999999,'N',bError,NewCONGAC4_ANCI_3       );rSala_Impo_Cong_Cree.CONGAC4_ANCI_3         :=NewCONGAC4_ANCI_3      ;if bError then PR_MAJ_LOG(pCONGAC4_ANCI_3           ,'CONGAC4_ANCI_3'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE4_ANCI_3            ,-9999999999,9999999999,'N',bError,NewCONGAPRE4_ANCI_3     );rSala_Impo_Cong_Cree.CONGAPRE4_ANCI_3       :=NewCONGAPRE4_ANCI_3    ;if bError then PR_MAJ_LOG(pCONGAPRE4_ANCI_3         ,'CONGAPRE4_ANCI_3'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC4_FRAC                ,-9999999999,9999999999,'N',bError,NewCONGAC4_FRAC         );rSala_Impo_Cong_Cree.CONGAC4_FRAC           :=NewCONGAC4_FRAC        ;if bError then PR_MAJ_LOG(pCONGAC4_FRAC             ,'CONGAC4_FRAC'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE4_FRAC              ,-9999999999,9999999999,'N',bError,NewCONGAPRE4_FRAC       );rSala_Impo_Cong_Cree.CONGAPRE4_FRAC         :=NewCONGAPRE4_FRAC      ;if bError then PR_MAJ_LOG(pCONGAPRE4_FRAC           ,'CONGAPRE4_FRAC'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pBRUTPREC3                   ,          0,9999999999,'N',bError,NewBRUTPREC3            );rSala_Impo_Cong_Cree.BRUTPREC3              :=NewBRUTPREC3           ;if bError then PR_MAJ_LOG(pBRUTPREC3                ,'BRUTPREC3'            ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC3_LEGA                ,-9999999999,9999999999,'N',bError,NewCONGAC3_LEGA         );rSala_Impo_Cong_Cree.CONGAC3_LEGA           :=NewCONGAC3_LEGA        ;if bError then PR_MAJ_LOG(pCONGAC3_LEGA             ,'CONGAC3_LEGA'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE3_LEGA              ,-9999999999,9999999999,'N',bError,NewCONGAPRE3_LEGA       );rSala_Impo_Cong_Cree.CONGAPRE3_LEGA         :=NewCONGAPRE3_LEGA      ;if bError then PR_MAJ_LOG(pCONGAPRE3_LEGA           ,'CONGAPRE3_LEGA'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC3_ANCI_1              ,-9999999999,9999999999,'N',bError,NewCONGAC3_ANCI_1       );rSala_Impo_Cong_Cree.CONGAC3_ANCI_1         :=NewCONGAC3_ANCI_1      ;if bError then PR_MAJ_LOG(pCONGAC3_ANCI_1           ,'CONGAC3_ANCI_1'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE3_ANCI_1            ,-9999999999,9999999999,'N',bError,NewCONGAPRE3_ANCI_1     );rSala_Impo_Cong_Cree.CONGAPRE3_ANCI_1       :=NewCONGAPRE3_ANCI_1    ;if bError then PR_MAJ_LOG(pCONGAPRE3_ANCI_1         ,'CONGAPRE3_ANCI_1'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC3_ANCI_2              ,-9999999999,9999999999,'N',bError,NewCONGAC3_ANCI_2       );rSala_Impo_Cong_Cree.CONGAC3_ANCI_2         :=NewCONGAC3_ANCI_2      ;if bError then PR_MAJ_LOG(pCONGAC3_ANCI_2           ,'CONGAC3_ANCI_2'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE3_ANCI_2            ,-9999999999,9999999999,'N',bError,NewCONGAPRE3_ANCI_2     );rSala_Impo_Cong_Cree.CONGAPRE3_ANCI_2       :=NewCONGAPRE3_ANCI_2    ;if bError then PR_MAJ_LOG(pCONGAPRE3_ANCI_2         ,'CONGAPRE3_ANCI_2'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC3_ANCI_3              ,-9999999999,9999999999,'N',bError,NewCONGAC3_ANCI_3       );rSala_Impo_Cong_Cree.CONGAC3_ANCI_3         :=NewCONGAC3_ANCI_3      ;if bError then PR_MAJ_LOG(pCONGAC3_ANCI_3           ,'CONGAC3_ANCI_3'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE3_ANCI_3            ,-9999999999,9999999999,'N',bError,NewCONGAPRE3_ANCI_3     );rSala_Impo_Cong_Cree.CONGAPRE3_ANCI_3       :=NewCONGAPRE3_ANCI_3    ;if bError then PR_MAJ_LOG(pCONGAPRE3_ANCI_3         ,'CONGAPRE3_ANCI_3'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC3_FRAC                ,-9999999999,9999999999,'N',bError,NewCONGAC3_FRAC         );rSala_Impo_Cong_Cree.CONGAC3_FRAC           :=NewCONGAC3_FRAC        ;if bError then PR_MAJ_LOG(pCONGAC3_FRAC             ,'CONGAC3_FRAC'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE3_FRAC              ,-9999999999,9999999999,'N',bError,NewCONGAPRE3_FRAC       );rSala_Impo_Cong_Cree.CONGAPRE3_FRAC         :=NewCONGAPRE3_FRAC      ;if bError then PR_MAJ_LOG(pCONGAPRE3_FRAC           ,'CONGAPRE3_FRAC'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pBRUTPREC2                   ,          0,9999999999,'N',bError,NewBRUTPREC2            );rSala_Impo_Cong_Cree.BRUTPREC2              :=NewBRUTPREC2           ;if bError then PR_MAJ_LOG(pBRUTPREC2                ,'BRUTPREC2'            ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC2_LEGA                ,-9999999999,9999999999,'N',bError,NewCONGAC2_LEGA         );rSala_Impo_Cong_Cree.CONGAC2_LEGA           :=NewCONGAC2_LEGA        ;if bError then PR_MAJ_LOG(pCONGAC2_LEGA             ,'CONGAC2_LEGA'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE2_LEGA              ,-9999999999,9999999999,'N',bError,NewCONGAPRE2_LEGA       );rSala_Impo_Cong_Cree.CONGAPRE2_LEGA         :=NewCONGAPRE2_LEGA      ;if bError then PR_MAJ_LOG(pCONGAPRE2_LEGA           ,'CONGAPRE2_LEGA'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC2_ANCI_1              ,-9999999999,9999999999,'N',bError,NewCONGAC2_ANCI_1       );rSala_Impo_Cong_Cree.CONGAC2_ANCI_1         :=NewCONGAC2_ANCI_1      ;if bError then PR_MAJ_LOG(pCONGAC2_ANCI_1           ,'CONGAC2_ANCI_1'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE2_ANCI_1            ,-9999999999,9999999999,'N',bError,NewCONGAPRE2_ANCI_1     );rSala_Impo_Cong_Cree.CONGAPRE2_ANCI_1       :=NewCONGAPRE2_ANCI_1    ;if bError then PR_MAJ_LOG(pCONGAPRE2_ANCI_1         ,'CONGAPRE2_ANCI_1'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC2_ANCI_2              ,-9999999999,9999999999,'N',bError,NewCONGAC2_ANCI_2       );rSala_Impo_Cong_Cree.CONGAC2_ANCI_2         :=NewCONGAC2_ANCI_2      ;if bError then PR_MAJ_LOG(pCONGAC2_ANCI_2           ,'CONGAC2_ANCI_2'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE2_ANCI_2            ,-9999999999,9999999999,'N',bError,NewCONGAPRE2_ANCI_2     );rSala_Impo_Cong_Cree.CONGAPRE2_ANCI_2       :=NewCONGAPRE2_ANCI_2    ;if bError then PR_MAJ_LOG(pCONGAPRE2_ANCI_2         ,'CONGAPRE2_ANCI_2'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC2_ANCI_3              ,-9999999999,9999999999,'N',bError,NewCONGAC2_ANCI_3       );rSala_Impo_Cong_Cree.CONGAC2_ANCI_3         :=NewCONGAC2_ANCI_3      ;if bError then PR_MAJ_LOG(pCONGAC2_ANCI_3           ,'CONGAC2_ANCI_3'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE2_ANCI_3            ,-9999999999,9999999999,'N',bError,NewCONGAPRE2_ANCI_3     );rSala_Impo_Cong_Cree.CONGAPRE2_ANCI_3       :=NewCONGAPRE2_ANCI_3    ;if bError then PR_MAJ_LOG(pCONGAPRE2_ANCI_3         ,'CONGAPRE2_ANCI_3'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC2_FRAC                ,-9999999999,9999999999,'N',bError,NewCONGAC2_FRAC         );rSala_Impo_Cong_Cree.CONGAC2_FRAC           :=NewCONGAC2_FRAC        ;if bError then PR_MAJ_LOG(pCONGAC2_FRAC             ,'CONGAC2_FRAC'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE2_FRAC              ,-9999999999,9999999999,'N',bError,NewCONGAPRE2_FRAC       );rSala_Impo_Cong_Cree.CONGAPRE2_FRAC         :=NewCONGAPRE2_FRAC      ;if bError then PR_MAJ_LOG(pCONGAPRE2_FRAC           ,'CONGAPRE2_FRAC'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pBRUTPREC1                   ,          0,9999999999,'N',bError,NewBRUTPREC1            );rSala_Impo_Cong_Cree.BRUTPREC1              :=NewBRUTPREC1           ;if bError then PR_MAJ_LOG(pBRUTPREC1                ,'BRUTPREC1'            ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC1_LEGA                ,-9999999999,9999999999,'N',bError,NewCONGAC1_LEGA         );rSala_Impo_Cong_Cree.CONGAC1_LEGA           :=NewCONGAC1_LEGA        ;if bError then PR_MAJ_LOG(pCONGAC1_LEGA             ,'CONGAC1_LEGA'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE1_LEGA              ,-9999999999,9999999999,'N',bError,NewCONGAPRE1_LEGA       );rSala_Impo_Cong_Cree.CONGAPRE1_LEGA         :=NewCONGAPRE1_LEGA      ;if bError then PR_MAJ_LOG(pCONGAPRE1_LEGA           ,'CONGAPRE1_LEGA'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC1_ANCI_1              ,-9999999999,9999999999,'N',bError,NewCONGAC1_ANCI_1       );rSala_Impo_Cong_Cree.CONGAC1_ANCI_1         :=NewCONGAC1_ANCI_1      ;if bError then PR_MAJ_LOG(pCONGAC1_ANCI_1           ,'CONGAC1_ANCI_1'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE1_ANCI_1            ,-9999999999,9999999999,'N',bError,NewCONGAPRE1_ANCI_1     );rSala_Impo_Cong_Cree.CONGAPRE1_ANCI_1       :=NewCONGAPRE1_ANCI_1    ;if bError then PR_MAJ_LOG(pCONGAPRE1_ANCI_1         ,'CONGAPRE1_ANCI_1'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC1_ANCI_2              ,-9999999999,9999999999,'N',bError,NewCONGAC1_ANCI_2       );rSala_Impo_Cong_Cree.CONGAC1_ANCI_2         :=NewCONGAC1_ANCI_2      ;if bError then PR_MAJ_LOG(pCONGAC1_ANCI_2           ,'CONGAC1_ANCI_2'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE1_ANCI_2            ,-9999999999,9999999999,'N',bError,NewCONGAPRE1_ANCI_2     );rSala_Impo_Cong_Cree.CONGAPRE1_ANCI_2       :=NewCONGAPRE1_ANCI_2    ;if bError then PR_MAJ_LOG(pCONGAPRE1_ANCI_2         ,'CONGAPRE1_ANCI_2'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC1_ANCI_3              ,-9999999999,9999999999,'N',bError,NewCONGAC1_ANCI_3       );rSala_Impo_Cong_Cree.CONGAC1_ANCI_3         :=NewCONGAC1_ANCI_3      ;if bError then PR_MAJ_LOG(pCONGAC1_ANCI_3           ,'CONGAC1_ANCI_3'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE1_ANCI_3            ,-9999999999,9999999999,'N',bError,NewCONGAPRE1_ANCI_3     );rSala_Impo_Cong_Cree.CONGAPRE1_ANCI_3       :=NewCONGAPRE1_ANCI_3    ;if bError then PR_MAJ_LOG(pCONGAPRE1_ANCI_3         ,'CONGAPRE1_ANCI_3'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC1_FRAC                ,-9999999999,9999999999,'N',bError,NewCONGAC1_FRAC         );rSala_Impo_Cong_Cree.CONGAC1_FRAC           :=NewCONGAC1_FRAC        ;if bError then PR_MAJ_LOG(pCONGAC1_FRAC             ,'CONGAC1_FRAC'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE1_FRAC              ,-9999999999,9999999999,'N',bError,NewCONGAPRE1_FRAC       );rSala_Impo_Cong_Cree.CONGAPRE1_FRAC         :=NewCONGAPRE1_FRAC      ;if bError then PR_MAJ_LOG(pCONGAPRE1_FRAC           ,'CONGAPRE1_FRAC'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pBRUTPREC0                   ,          0,9999999999,'N',bError,NewBRUTPREC0            );rSala_Impo_Cong_Cree.BRUTPREC0              :=NewBRUTPREC0           ;if bError then PR_MAJ_LOG(pBRUTPREC0                ,'BRUTPREC0'            ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOACOURS_LEGA               ,-9999999999,9999999999,'N',bError,NewCOACOURS_LEGA        );rSala_Impo_Cong_Cree.COACOURS_LEGA          :=NewCOACOURS_LEGA       ;if bError then PR_MAJ_LOG(pCOACOURS_LEGA            ,'COACOURS_LEGA'        ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE0_LEGA              ,-9999999999,9999999999,'N',bError,NewCONGAPRE0_LEGA       );rSala_Impo_Cong_Cree.CONGAPRE0_LEGA         :=NewCONGAPRE0_LEGA      ;if bError then PR_MAJ_LOG(pCONGAPRE0_LEGA           ,'CONGAPRE0_LEGA'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOACOURS_ANCI_1             ,-9999999999,9999999999,'N',bError,NewCOACOURS_ANCI_1      );rSala_Impo_Cong_Cree.COACOURS_ANCI_1        :=NewCOACOURS_ANCI_1     ;if bError then PR_MAJ_LOG(pCOACOURS_ANCI_1          ,'COACOURS_ANCI_1'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE0_ANCI_1            ,-9999999999,9999999999,'N',bError,NewCONGAPRE0_ANCI_1     );rSala_Impo_Cong_Cree.CONGAPRE0_ANCI_1       :=NewCONGAPRE0_ANCI_1    ;if bError then PR_MAJ_LOG(pCONGAPRE0_ANCI_1         ,'CONGAPRE0_ANCI_1'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOACOURS_ANCI_2             ,-9999999999,9999999999,'N',bError,NewCOACOURS_ANCI_2      );rSala_Impo_Cong_Cree.COACOURS_ANCI_2        :=NewCOACOURS_ANCI_2     ;if bError then PR_MAJ_LOG(pCOACOURS_ANCI_2          ,'COACOURS_ANCI_2'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE0_ANCI_2            ,-9999999999,9999999999,'N',bError,NewCONGAPRE0_ANCI_2     );rSala_Impo_Cong_Cree.CONGAPRE0_ANCI_2       :=NewCONGAPRE0_ANCI_2    ;if bError then PR_MAJ_LOG(pCONGAPRE0_ANCI_2         ,'CONGAPRE0_ANCI_2'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOACOURS_ANCI_3             ,-9999999999,9999999999,'N',bError,NewCOACOURS_ANCI_3      );rSala_Impo_Cong_Cree.COACOURS_ANCI_3        :=NewCOACOURS_ANCI_3     ;if bError then PR_MAJ_LOG(pCOACOURS_ANCI_3          ,'COACOURS_ANCI_3'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE0_ANCI_3            ,-9999999999,9999999999,'N',bError,NewCONGAPRE0_ANCI_3     );rSala_Impo_Cong_Cree.CONGAPRE0_ANCI_3       :=NewCONGAPRE0_ANCI_3    ;if bError then PR_MAJ_LOG(pCONGAPRE0_ANCI_3         ,'CONGAPRE0_ANCI_3'     ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOACOURS_FRAC               ,-9999999999,9999999999,'N',bError,NewCOACOURS_FRAC        );rSala_Impo_Cong_Cree.COACOURS_FRAC          :=NewCOACOURS_FRAC       ;if bError then PR_MAJ_LOG(pCOACOURS_FRAC            ,'COACOURS_FRAC'        ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAPRE0_FRAC              ,-9999999999,9999999999,'N',bError,NewCONGAPRE0_FRAC       );rSala_Impo_Cong_Cree.CONGAPRE0_FRAC         :=NewCONGAPRE0_FRAC      ;if bError then PR_MAJ_LOG(pCONGAPRE0_FRAC           ,'CONGAPRE0_FRAC'       ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pBRUTPRECM1                  ,          0,9999999999,'N',bError,NewBRUTPRECM1           );rSala_Impo_Cong_Cree.BRUTPRECM1             :=NewBRUTPRECM1          ;if bError then PR_MAJ_LOG(pBRUTPRECM1               ,'BRUTPRECM1'           ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCP_INDE_MONT_N0_PREC        ,-9999999999,9999999999,'N',bError,NewCP_INDE_MONT_N0_PREC );rSala_Impo_Cong_Cree.CP_INDE_MONT_N0_PREC   :=NewCP_INDE_MONT_N0_PREC;if bError then PR_MAJ_LOG(pCP_INDE_MONT_N0_PREC     ,'CP_INDE_MONT_N0_PREC' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCP_INDE_MONT_N1_PREC        ,-9999999999,9999999999,'N',bError,NewCP_INDE_MONT_N1_PREC );rSala_Impo_Cong_Cree.CP_INDE_MONT_N1_PREC   :=NewCP_INDE_MONT_N1_PREC;if bError then PR_MAJ_LOG(pCP_INDE_MONT_N1_PREC     ,'CP_INDE_MONT_N1_PREC' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCP_INDE_MONT_N2_PREC        ,-9999999999,9999999999,'N',bError,NewCP_INDE_MONT_N2_PREC );rSala_Impo_Cong_Cree.CP_INDE_MONT_N2_PREC   :=NewCP_INDE_MONT_N2_PREC;if bError then PR_MAJ_LOG(pCP_INDE_MONT_N2_PREC     ,'CP_INDE_MONT_N2_PREC' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCP_INDE_MONT_N3_PREC        ,-9999999999,9999999999,'N',bError,NewCP_INDE_MONT_N3_PREC );rSala_Impo_Cong_Cree.CP_INDE_MONT_N3_PREC   :=NewCP_INDE_MONT_N3_PREC;if bError then PR_MAJ_LOG(pCP_INDE_MONT_N3_PREC     ,'CP_INDE_MONT_N3_PREC' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCP_INDE_MONT_N4_PREC        ,-9999999999,9999999999,'N',bError,NewCP_INDE_MONT_N4_PREC );rSala_Impo_Cong_Cree.CP_INDE_MONT_N4_PREC   :=NewCP_INDE_MONT_N4_PREC;if bError then PR_MAJ_LOG(pCP_INDE_MONT_N4_PREC     ,'CP_INDE_MONT_N4_PREC' ,'La donnée saisie est de format incorrect') ;end if;

      pr_cvs(pRTTAN                       ,-9999999999,9999999999,'N',bError,NewRTTAN                );rSala_Impo_Cong_Cree.RTTAN                  :=NewRTTAN               ;if bError then PR_MAJ_LOG(pRTTAN                    ,'RTTAN'                ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRTTPRIANN                   ,-9999999999,9999999999,'N',bError,NewRTTPRIANN            );rSala_Impo_Cong_Cree.RTTPRIANN              :=NewRTTPRIANN           ;if bError then PR_MAJ_LOG(pRTTPRIANN                ,'RTTPRIANN'            ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRTTAPRE                     ,-9999999999,9999999999,'N',bError,NewRTTAPRE              );rSala_Impo_Cong_Cree.RTTAPRE                :=NewRTTAPRE             ;if bError then PR_MAJ_LOG(pRTTAPRE                  ,'RTTAPRE'              ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRTTREPRIS                   ,-9999999999,9999999999,'N',bError,NewRTTREPRIS            );rSala_Impo_Cong_Cree.RTTREPRIS              :=NewRTTREPRIS           ;if bError then PR_MAJ_LOG(pRTTREPRIS                ,'RTTREPRIS'            ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRTT_SALA_REST_CLOT          ,-9999999999,9999999999,'N',bError,NewRTT_SALA_REST_CLOT   );rSala_Impo_Cong_Cree.RTT_SALA_REST_CLOT     :=NewRTT_SALA_REST_CLOT  ;if bError then PR_MAJ_LOG(pRTT_SALA_REST_CLOT       ,'RTT_SALA_REST_CLOT'   ,'La donnée saisie est de format incorrect') ;end if;

      pr_cvs(pRTTANPAT                    ,-9999999999,9999999999,'N',bError,NewRTTANPAT             );rSala_Impo_Cong_Cree.RTTANPAT               :=NewRTTANPAT            ;if bError then PR_MAJ_LOG(pRTTANPAT                 ,'RTTANPAT'             ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRTTPRIANNPAT                ,-9999999999,9999999999,'N',bError,NewRTTPRIANNPAT         );rSala_Impo_Cong_Cree.RTTPRIANNPAT           :=NewRTTPRIANNPAT        ;if bError then PR_MAJ_LOG(pRTTPRIANNPAT             ,'RTTPRIANNPAT'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRTTAPREPAT                  ,-9999999999,9999999999,'N',bError,NewRTTAPREPAT           );rSala_Impo_Cong_Cree.RTTAPREPAT             :=NewRTTAPREPAT          ;if bError then PR_MAJ_LOG(pRTTAPREPAT               ,'RTTAPREPAT'           ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRTTREPRISPAT                ,-9999999999,9999999999,'N',bError,NewRTTREPRISPAT         );rSala_Impo_Cong_Cree.RTTREPRISPAT           :=NewRTTREPRISPAT        ;if bError then PR_MAJ_LOG(pRTTREPRISPAT             ,'RTTREPRISPAT'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRTT_PATR_REST_CLOT          ,-9999999999,9999999999,'N',bError,NewRTT_PATR_REST_CLOT   );rSala_Impo_Cong_Cree.RTT_PATR_REST_CLOT     :=NewRTT_PATR_REST_CLOT  ;if bError then PR_MAJ_LOG(pRTT_PATR_REST_CLOT       ,'RTT_PATR_REST_CLOT'   ,'La donnée saisie est de format incorrect') ;end if;


      pr_cvs(pCETACQRTTPATANN             ,-9999999999,9999999999,'N',bError,NewCETACQRTTPATANN      );rSala_Impo_Cong_Cree.CETACQRTTPATANN        :=NewCETACQRTTPATANN     ;if bError then PR_MAJ_LOG(pCETACQRTTPATANN          ,'CETACQRTTPATANN'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCETPRIRTTPATANN             ,-9999999999,9999999999,'N',bError,NewCETPRIRTTPATANN      );rSala_Impo_Cong_Cree.CETPRIRTTPATANN        :=NewCETPRIRTTPATANN     ;if bError then PR_MAJ_LOG(pCETPRIRTTPATANN          ,'CETPRIRTTPATANN'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCETACQRTTSALANN             ,-9999999999,9999999999,'N',bError,NewCETACQRTTSALANN      );rSala_Impo_Cong_Cree.CETACQRTTSALANN        :=NewCETACQRTTSALANN     ;if bError then PR_MAJ_LOG(pCETACQRTTSALANN          ,'CETACQRTTSALANN'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCETPRIRTTSALANN             ,-9999999999,9999999999,'N',bError,NewCETPRIRTTSALANN      );rSala_Impo_Cong_Cree.CETPRIRTTSALANN        :=NewCETPRIRTTSALANN     ;if bError then PR_MAJ_LOG(pCETPRIRTTSALANN          ,'CETPRIRTTSALANN'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCETACQCPANN                 ,-9999999999,9999999999,'N',bError,NewCETACQCPANN          );rSala_Impo_Cong_Cree.CETACQCPANN            :=NewCETACQCPANN         ;if bError then PR_MAJ_LOG(pCETACQCPANN              ,'CETACQCPANN'          ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCETPRICPANN                 ,-9999999999,9999999999,'N',bError,NewCETPRICPANN          );rSala_Impo_Cong_Cree.CETPRICPANN            :=NewCETPRICPANN         ;if bError then PR_MAJ_LOG(pCETPRICPANN              ,'CETPRICPANN'          ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCETRESCP                    ,-9999999999,9999999999,'N',bError,NewCETRESCP             );rSala_Impo_Cong_Cree.CETRESCP               :=NewCETRESCP            ;if bError then PR_MAJ_LOG(pCETRESCP                 ,'CETRESCP'             ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCETRESRTTPAT                ,-9999999999,9999999999,'N',bError,NewCETRESRTTPAT         );rSala_Impo_Cong_Cree.CETRESRTTPAT           :=NewCETRESRTTPAT        ;if bError then PR_MAJ_LOG(pCETRESRTTPAT             ,'CETRESRTTPAT'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCETRESRTTSAL                ,-9999999999,9999999999,'N',bError,NewCETRESRTTSAL         );rSala_Impo_Cong_Cree.CETRESRTTSAL           :=NewCETRESRTTSAL        ;if bError then PR_MAJ_LOG(pCETRESRTTSAL             ,'CETRESRTTSAL'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCETACQCPNOMOANN             ,-9999999999,9999999999,'N',bError,NewCETACQCPNOMOANN      );rSala_Impo_Cong_Cree.CETACQCPNOMOANN        :=NewCETACQCPNOMOANN     ;if bError then PR_MAJ_LOG(pCETACQCPNOMOANN          ,'CETACQCPNOMOANN'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCETPRICPNOMOANN             ,-9999999999,9999999999,'N',bError,NewCETPRICPNOMOANN      );rSala_Impo_Cong_Cree.CETPRICPNOMOANN        :=NewCETPRICPNOMOANN     ;if bError then PR_MAJ_LOG(pCETPRICPNOMOANN          ,'CETPRICPNOMOANN'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCETRESCPNOMO                ,-9999999999,9999999999,'N',bError,NewCETRESCPNOMO         );rSala_Impo_Cong_Cree.CETRESCPNOMO           :=NewCETRESCPNOMO        ;if bError then PR_MAJ_LOG(pCETRESCPNOMO             ,'CETRESCPNOMO'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pREPACQUI                    ,-9999999999,9999999999,'N',bError,NewREPACQUI             );rSala_Impo_Cong_Cree.REPACQUI               :=NewREPACQUI            ;if bError then PR_MAJ_LOG(pREPACQUI                 ,'REPACQUI'             ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pREPOPRISAN                  ,-9999999999,9999999999,'N',bError,NewREPOPRISAN           );rSala_Impo_Cong_Cree.REPOPRISAN             :=NewREPOPRISAN          ;if bError then PR_MAJ_LOG(pREPOPRISAN               ,'REPOPRISAN'           ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pREPOSCUM                    ,-9999999999,9999999999,'N',bError,NewREPOSCUM             );rSala_Impo_Cong_Cree.REPOSCUM               :=NewREPOSCUM            ;if bError then PR_MAJ_LOG(pREPOSCUM                 ,'REPOSCUM'             ,'La donnée saisie est de format incorrect') ;end if;

      -- compteurs supplémentaires, RCR, RCN (T80556)
      pr_cvs(pRTTANSUP                    ,-9999999999,9999999999,'N',bError,NewRTTANSUP             );rSala_Impo_Cong_Cree.RTTANSUP               :=NewRTTANSUP            ;if bError then PR_MAJ_LOG(pRTTANSUP                 ,'RTTANSUP'             ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRTTPRIANNSUP                ,-9999999999,9999999999,'N',bError,NewRTTPRIANNSUP         );rSala_Impo_Cong_Cree.RTTPRIANNSUP           :=NewRTTPRIANNSUP        ;if bError then PR_MAJ_LOG(pRTTPRIANNSUP             ,'RTTPRIANNSUP'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRTTAPRESUP                  ,-9999999999,9999999999,'N',bError,NewRTTAPRESUP           );rSala_Impo_Cong_Cree.RTTAPRESUP             :=NewRTTAPRESUP          ;if bError then PR_MAJ_LOG(pRTTAPRESUP               ,'RTTAPRESUP'           ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_01_ACQU_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_01_ACQU_ANNE    );rSala_Impo_Cong_Cree.COSU_01_ACQU_ANNE      :=NewCOSU_01_ACQU_ANNE   ;if bError then PR_MAJ_LOG(pCOSU_01_ACQU_ANNE        ,'COSU_01_ACQU_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_01_PRIS_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_01_PRIS_ANNE    );rSala_Impo_Cong_Cree.COSU_01_PRIS_ANNE      :=NewCOSU_01_PRIS_ANNE   ;if bError then PR_MAJ_LOG(pCOSU_01_PRIS_ANNE        ,'COSU_01_PRIS_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_01_REST                ,-9999999999,9999999999,'N',bError,NewCOSU_01_REST         );rSala_Impo_Cong_Cree.COSU_01_REST           :=NewCOSU_01_REST        ;if bError then PR_MAJ_LOG(pCOSU_01_REST             ,'COSU_01_REST'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_02_ACQU_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_02_ACQU_ANNE    );rSala_Impo_Cong_Cree.COSU_02_ACQU_ANNE      :=NewCOSU_02_ACQU_ANNE   ;if bError then PR_MAJ_LOG(pCOSU_02_ACQU_ANNE        ,'COSU_02_ACQU_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_02_PRIS_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_02_PRIS_ANNE    );rSala_Impo_Cong_Cree.COSU_02_PRIS_ANNE      :=NewCOSU_02_PRIS_ANNE   ;if bError then PR_MAJ_LOG(pCOSU_02_PRIS_ANNE        ,'COSU_02_PRIS_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_02_REST                ,-9999999999,9999999999,'N',bError,NewCOSU_02_REST         );rSala_Impo_Cong_Cree.COSU_02_REST           :=NewCOSU_02_REST        ;if bError then PR_MAJ_LOG(pCOSU_02_REST             ,'COSU_02_REST'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_03_ACQU_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_03_ACQU_ANNE    );rSala_Impo_Cong_Cree.COSU_03_ACQU_ANNE      :=NewCOSU_03_ACQU_ANNE   ;if bError then PR_MAJ_LOG(pCOSU_03_ACQU_ANNE        ,'COSU_03_ACQU_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_03_PRIS_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_03_PRIS_ANNE    );rSala_Impo_Cong_Cree.COSU_03_PRIS_ANNE      :=NewCOSU_03_PRIS_ANNE   ;if bError then PR_MAJ_LOG(pCOSU_03_PRIS_ANNE        ,'COSU_03_PRIS_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_03_REST                ,-9999999999,9999999999,'N',bError,NewCOSU_03_REST         );rSala_Impo_Cong_Cree.COSU_03_REST           :=NewCOSU_03_REST        ;if bError then PR_MAJ_LOG(pCOSU_03_REST             ,'COSU_03_REST'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRCRACQUIANN                 ,-9999999999,9999999999,'N',bError,NewRCRACQUIANN          );rSala_Impo_Cong_Cree.RCRACQUIANN            :=NewRCRACQUIANN         ;if bError then PR_MAJ_LOG(pRCRACQUIANN              ,'RCRACQUIANN'          ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRCRPRISAN                   ,-9999999999,9999999999,'N',bError,NewRCRPRISAN            );rSala_Impo_Cong_Cree.RCRPRISAN              :=NewRCRPRISAN           ;if bError then PR_MAJ_LOG(pRCRPRISAN                ,'RCRPRISAN'            ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRCRCUM                      ,-9999999999,9999999999,'N',bError,NewRCRCUM               );rSala_Impo_Cong_Cree.RCRCUM                 :=NewRCRCUM              ;if bError then PR_MAJ_LOG(pRCRCUM                   ,'RCRCUM'               ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRCNACQUIANN                 ,-9999999999,9999999999,'N',bError,NewRCNACQUIANN          );rSala_Impo_Cong_Cree.RCNACQUIANN            :=NewRCNACQUIANN         ;if bError then PR_MAJ_LOG(pRCNACQUIANN              ,'RCNACQUIANN'          ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRCNPRISAN                   ,-9999999999,9999999999,'N',bError,NewRCNPRISAN            );rSala_Impo_Cong_Cree.RCNPRISAN              :=NewRCNPRISAN           ;if bError then PR_MAJ_LOG(pRCNPRISAN                ,'RCNPRISAN'            ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pRCNCUM                      ,-9999999999,9999999999,'N',bError,NewRCNCUM               );rSala_Impo_Cong_Cree.RCNCUM                 :=NewRCNCUM              ;if bError then PR_MAJ_LOG(pRCNCUM                   ,'RCNCUM'               ,'La donnée saisie est de format incorrect') ;end if;

      pr_cvs(pCOSU_01_ACQU_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_01_ACQU_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_01_ACQU_ANNE_N1   :=NewCOSU_01_ACQU_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_01_ACQU_ANNE_N1     ,'COSU_01_ACQU_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_01_PRIS_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_01_PRIS_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_01_PRIS_ANNE_N1   :=NewCOSU_01_PRIS_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_01_PRIS_ANNE_N1     ,'COSU_01_PRIS_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_01_REST_N1             ,-9999999999,9999999999,'N',bError,NewCOSU_01_REST_N1      );rSala_Impo_Cong_Cree.COSU_01_REST_N1        :=NewCOSU_01_REST_N1      ;if bError then PR_MAJ_LOG(pCOSU_01_REST_N1          ,'COSU_01_REST_N1'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_02_ACQU_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_02_ACQU_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_02_ACQU_ANNE_N1   :=NewCOSU_02_ACQU_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_02_ACQU_ANNE_N1     ,'COSU_02_ACQU_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_02_PRIS_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_02_PRIS_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_02_PRIS_ANNE_N1   :=NewCOSU_02_PRIS_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_02_PRIS_ANNE_N1     ,'COSU_02_PRIS_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_02_REST_N1             ,-9999999999,9999999999,'N',bError,NewCOSU_02_REST_N1      );rSala_Impo_Cong_Cree.COSU_02_REST_N1        :=NewCOSU_02_REST_N1      ;if bError then PR_MAJ_LOG(pCOSU_02_REST_N1          ,'COSU_02_REST_N1'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_03_ACQU_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_03_ACQU_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_03_ACQU_ANNE_N1   :=NewCOSU_03_ACQU_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_03_ACQU_ANNE_N1     ,'COSU_03_ACQU_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_03_PRIS_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_03_PRIS_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_03_PRIS_ANNE_N1   :=NewCOSU_03_PRIS_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_03_PRIS_ANNE_N1     ,'COSU_03_PRIS_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_03_REST_N1             ,-9999999999,9999999999,'N',bError,NewCOSU_03_REST_N1      );rSala_Impo_Cong_Cree.COSU_03_REST_N1        :=NewCOSU_03_REST_N1      ;if bError then PR_MAJ_LOG(pCOSU_03_REST_N1          ,'COSU_03_REST_N1'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_01_ACQU_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_01_ACQU_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_01_ACQU_ANNE_N2   :=NewCOSU_01_ACQU_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_01_ACQU_ANNE_N2     ,'COSU_01_ACQU_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_01_PRIS_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_01_PRIS_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_01_PRIS_ANNE_N2   :=NewCOSU_01_PRIS_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_01_PRIS_ANNE_N2     ,'COSU_01_PRIS_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_01_REST_N2             ,-9999999999,9999999999,'N',bError,NewCOSU_01_REST_N2      );rSala_Impo_Cong_Cree.COSU_01_REST_N2        :=NewCOSU_01_REST_N2      ;if bError then PR_MAJ_LOG(pCOSU_01_REST_N2          ,'COSU_01_REST_N2'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_02_ACQU_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_02_ACQU_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_02_ACQU_ANNE_N2   :=NewCOSU_02_ACQU_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_02_ACQU_ANNE_N2     ,'COSU_02_ACQU_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_02_PRIS_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_02_PRIS_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_02_PRIS_ANNE_N2   :=NewCOSU_02_PRIS_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_02_PRIS_ANNE_N2     ,'COSU_02_PRIS_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_02_REST_N2             ,-9999999999,9999999999,'N',bError,NewCOSU_02_REST_N2      );rSala_Impo_Cong_Cree.COSU_02_REST_N2        :=NewCOSU_02_REST_N2      ;if bError then PR_MAJ_LOG(pCOSU_02_REST_N2          ,'COSU_02_REST_N2'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_03_ACQU_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_03_ACQU_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_03_ACQU_ANNE_N2   :=NewCOSU_03_ACQU_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_03_ACQU_ANNE_N2     ,'COSU_03_ACQU_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_03_PRIS_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_03_PRIS_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_03_PRIS_ANNE_N2   :=NewCOSU_03_PRIS_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_03_PRIS_ANNE_N2     ,'COSU_03_PRIS_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_03_REST_N2             ,-9999999999,9999999999,'N',bError,NewCOSU_03_REST_N2      );rSala_Impo_Cong_Cree.COSU_03_REST_N2        :=NewCOSU_03_REST_N2      ;if bError then PR_MAJ_LOG(pCOSU_03_REST_N2          ,'COSU_03_REST_N2'      ,'La donnée saisie est de format incorrect') ;end if;

      pr_cvs(pCOSU_04_ACQU_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_04_ACQU_ANNE    );rSala_Impo_Cong_Cree.COSU_04_ACQU_ANNE      :=NewCOSU_04_ACQU_ANNE    ;if bError then PR_MAJ_LOG(pCOSU_04_ACQU_ANNE        ,'COSU_04_ACQU_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_04_PRIS_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_04_PRIS_ANNE    );rSala_Impo_Cong_Cree.COSU_04_PRIS_ANNE      :=NewCOSU_04_PRIS_ANNE    ;if bError then PR_MAJ_LOG(pCOSU_04_PRIS_ANNE        ,'COSU_04_PRIS_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_04_REST                ,-9999999999,9999999999,'N',bError,NewCOSU_04_REST         );rSala_Impo_Cong_Cree.COSU_04_REST           :=NewCOSU_04_REST         ;if bError then PR_MAJ_LOG(pCOSU_04_REST             ,'COSU_04_REST'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_04_ACQU_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_04_ACQU_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_04_ACQU_ANNE_N1   :=NewCOSU_04_ACQU_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_04_ACQU_ANNE_N1     ,'COSU_04_ACQU_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_04_PRIS_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_04_PRIS_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_04_PRIS_ANNE_N1   :=NewCOSU_04_PRIS_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_04_PRIS_ANNE_N1     ,'COSU_04_PRIS_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_04_REST_N1             ,-9999999999,9999999999,'N',bError,NewCOSU_04_REST_N1      );rSala_Impo_Cong_Cree.COSU_04_REST_N1        :=NewCOSU_04_REST_N1      ;if bError then PR_MAJ_LOG(pCOSU_04_REST_N1          ,'COSU_04_REST_N1'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_04_ACQU_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_04_ACQU_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_04_ACQU_ANNE_N2   :=NewCOSU_04_ACQU_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_04_ACQU_ANNE_N2     ,'COSU_04_ACQU_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_04_PRIS_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_04_PRIS_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_04_PRIS_ANNE_N2   :=NewCOSU_04_PRIS_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_04_PRIS_ANNE_N2     ,'COSU_04_PRIS_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_04_REST_N2             ,-9999999999,9999999999,'N',bError,NewCOSU_04_REST_N2      );rSala_Impo_Cong_Cree.COSU_04_REST_N2        :=NewCOSU_04_REST_N2      ;if bError then PR_MAJ_LOG(pCOSU_04_REST_N2          ,'COSU_04_REST_N2'      ,'La donnée saisie est de format incorrect') ;end if;

      pr_cvs(pCOSU_05_ACQU_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_05_ACQU_ANNE    );rSala_Impo_Cong_Cree.COSU_05_ACQU_ANNE      :=NewCOSU_05_ACQU_ANNE    ;if bError then PR_MAJ_LOG(pCOSU_05_ACQU_ANNE        ,'COSU_05_ACQU_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_05_PRIS_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_05_PRIS_ANNE    );rSala_Impo_Cong_Cree.COSU_05_PRIS_ANNE      :=NewCOSU_05_PRIS_ANNE    ;if bError then PR_MAJ_LOG(pCOSU_05_PRIS_ANNE        ,'COSU_05_PRIS_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_05_REST                ,-9999999999,9999999999,'N',bError,NewCOSU_05_REST         );rSala_Impo_Cong_Cree.COSU_05_REST           :=NewCOSU_05_REST         ;if bError then PR_MAJ_LOG(pCOSU_05_REST             ,'COSU_05_REST'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_05_ACQU_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_05_ACQU_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_05_ACQU_ANNE_N1   :=NewCOSU_05_ACQU_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_05_ACQU_ANNE_N1     ,'COSU_05_ACQU_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_05_PRIS_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_05_PRIS_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_05_PRIS_ANNE_N1   :=NewCOSU_05_PRIS_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_05_PRIS_ANNE_N1     ,'COSU_05_PRIS_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_05_REST_N1             ,-9999999999,9999999999,'N',bError,NewCOSU_05_REST_N1      );rSala_Impo_Cong_Cree.COSU_05_REST_N1        :=NewCOSU_05_REST_N1      ;if bError then PR_MAJ_LOG(pCOSU_05_REST_N1          ,'COSU_05_REST_N1'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_05_ACQU_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_05_ACQU_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_05_ACQU_ANNE_N2   :=NewCOSU_05_ACQU_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_05_ACQU_ANNE_N2     ,'COSU_05_ACQU_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_05_PRIS_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_05_PRIS_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_05_PRIS_ANNE_N2   :=NewCOSU_05_PRIS_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_05_PRIS_ANNE_N2     ,'COSU_05_PRIS_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_05_REST_N2             ,-9999999999,9999999999,'N',bError,NewCOSU_05_REST_N2      );rSala_Impo_Cong_Cree.COSU_05_REST_N2        :=NewCOSU_05_REST_N2      ;if bError then PR_MAJ_LOG(pCOSU_05_REST_N2          ,'COSU_05_REST_N2'      ,'La donnée saisie est de format incorrect') ;end if;

      pr_cvs(pCOSU_06_ACQU_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_06_ACQU_ANNE    );rSala_Impo_Cong_Cree.COSU_06_ACQU_ANNE      :=NewCOSU_06_ACQU_ANNE    ;if bError then PR_MAJ_LOG(pCOSU_06_ACQU_ANNE        ,'COSU_06_ACQU_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_06_PRIS_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_06_PRIS_ANNE    );rSala_Impo_Cong_Cree.COSU_06_PRIS_ANNE      :=NewCOSU_06_PRIS_ANNE    ;if bError then PR_MAJ_LOG(pCOSU_06_PRIS_ANNE        ,'COSU_06_PRIS_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_06_REST                ,-9999999999,9999999999,'N',bError,NewCOSU_06_REST         );rSala_Impo_Cong_Cree.COSU_06_REST           :=NewCOSU_06_REST         ;if bError then PR_MAJ_LOG(pCOSU_06_REST             ,'COSU_06_REST'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_06_ACQU_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_06_ACQU_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_06_ACQU_ANNE_N1   :=NewCOSU_06_ACQU_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_06_ACQU_ANNE_N1     ,'COSU_06_ACQU_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_06_PRIS_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_06_PRIS_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_06_PRIS_ANNE_N1   :=NewCOSU_06_PRIS_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_06_PRIS_ANNE_N1     ,'COSU_06_PRIS_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_06_REST_N1             ,-9999999999,9999999999,'N',bError,NewCOSU_06_REST_N1      );rSala_Impo_Cong_Cree.COSU_06_REST_N1        :=NewCOSU_06_REST_N1      ;if bError then PR_MAJ_LOG(pCOSU_06_REST_N1          ,'COSU_06_REST_N1'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_06_ACQU_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_06_ACQU_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_06_ACQU_ANNE_N2   :=NewCOSU_06_ACQU_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_06_ACQU_ANNE_N2     ,'COSU_06_ACQU_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_06_PRIS_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_06_PRIS_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_06_PRIS_ANNE_N2   :=NewCOSU_06_PRIS_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_06_PRIS_ANNE_N2     ,'COSU_06_PRIS_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_06_REST_N2             ,-9999999999,9999999999,'N',bError,NewCOSU_06_REST_N2      );rSala_Impo_Cong_Cree.COSU_06_REST_N2        :=NewCOSU_06_REST_N2      ;if bError then PR_MAJ_LOG(pCOSU_06_REST_N2          ,'COSU_06_REST_N2'      ,'La donnée saisie est de format incorrect') ;end if;

      pr_cvs(pCOSU_07_ACQU_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_07_ACQU_ANNE    );rSala_Impo_Cong_Cree.COSU_07_ACQU_ANNE      :=NewCOSU_07_ACQU_ANNE    ;if bError then PR_MAJ_LOG(pCOSU_07_ACQU_ANNE        ,'COSU_07_ACQU_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_07_PRIS_ANNE           ,-9999999999,9999999999,'N',bError,NewCOSU_07_PRIS_ANNE    );rSala_Impo_Cong_Cree.COSU_07_PRIS_ANNE      :=NewCOSU_07_PRIS_ANNE    ;if bError then PR_MAJ_LOG(pCOSU_07_PRIS_ANNE        ,'COSU_07_PRIS_ANNE'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_07_REST                ,-9999999999,9999999999,'N',bError,NewCOSU_07_REST         );rSala_Impo_Cong_Cree.COSU_07_REST           :=NewCOSU_07_REST         ;if bError then PR_MAJ_LOG(pCOSU_07_REST             ,'COSU_07_REST'         ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_07_ACQU_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_07_ACQU_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_07_ACQU_ANNE_N1   :=NewCOSU_07_ACQU_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_07_ACQU_ANNE_N1     ,'COSU_07_ACQU_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_07_PRIS_ANNE_N1        ,-9999999999,9999999999,'N',bError,NewCOSU_07_PRIS_ANNE_N1 );rSala_Impo_Cong_Cree.COSU_07_PRIS_ANNE_N1   :=NewCOSU_07_PRIS_ANNE_N1 ;if bError then PR_MAJ_LOG(pCOSU_07_PRIS_ANNE_N1     ,'COSU_07_PRIS_ANNE_N1' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_07_REST_N1             ,-9999999999,9999999999,'N',bError,NewCOSU_07_REST_N1      );rSala_Impo_Cong_Cree.COSU_07_REST_N1        :=NewCOSU_07_REST_N1      ;if bError then PR_MAJ_LOG(pCOSU_07_REST_N1          ,'COSU_07_REST_N1'      ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_07_ACQU_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_07_ACQU_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_07_ACQU_ANNE_N2   :=NewCOSU_07_ACQU_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_07_ACQU_ANNE_N2     ,'COSU_07_ACQU_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_07_PRIS_ANNE_N2        ,-9999999999,9999999999,'N',bError,NewCOSU_07_PRIS_ANNE_N2 );rSala_Impo_Cong_Cree.COSU_07_PRIS_ANNE_N2   :=NewCOSU_07_PRIS_ANNE_N2 ;if bError then PR_MAJ_LOG(pCOSU_07_PRIS_ANNE_N2     ,'COSU_07_PRIS_ANNE_N2' ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCOSU_07_REST_N2             ,-9999999999,9999999999,'N',bError,NewCOSU_07_REST_N2      );rSala_Impo_Cong_Cree.COSU_07_REST_N2        :=NewCOSU_07_REST_N2      ;if bError then PR_MAJ_LOG(pCOSU_07_REST_N2          ,'COSU_07_REST_N2'      ,'La donnée saisie est de format incorrect') ;end if;

      pr_cvs(pCOACOURS_LEGA_THEO          ,-9999999999,9999999999,'N',bError,NewCOACOURS_LEGA_THEO   );rSala_Impo_Cong_Cree.COACOURS_LEGA_THEO     :=NewCOACOURS_LEGA_THEO   ;if bError then PR_MAJ_LOG(pCOACOURS_LEGA_THEO       ,'COACOURS_LEGA_THEO'   ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC1_LEGA_THEO           ,-9999999999,9999999999,'N',bError,NewCONGAC1_LEGA_THEO    );rSala_Impo_Cong_Cree.CONGAC1_LEGA_THEO      :=NewCONGAC1_LEGA_THEO    ;if bError then PR_MAJ_LOG(pCONGAC1_LEGA_THEO        ,'CONGAC1_LEGA_THEO'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC2_LEGA_THEO           ,-9999999999,9999999999,'N',bError,NewCONGAC2_LEGA_THEO    );rSala_Impo_Cong_Cree.CONGAC2_LEGA_THEO      :=NewCONGAC2_LEGA_THEO    ;if bError then PR_MAJ_LOG(pCONGAC2_LEGA_THEO        ,'CONGAC2_LEGA_THEO'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC3_LEGA_THEO           ,-9999999999,9999999999,'N',bError,NewCONGAC3_LEGA_THEO    );rSala_Impo_Cong_Cree.CONGAC3_LEGA_THEO      :=NewCONGAC3_LEGA_THEO    ;if bError then PR_MAJ_LOG(pCONGAC3_LEGA_THEO        ,'CONGAC3_LEGA_THEO'    ,'La donnée saisie est de format incorrect') ;end if;
      pr_cvs(pCONGAC4_LEGA_THEO           ,-9999999999,9999999999,'N',bError,NewCONGAC4_LEGA_THEO    );rSala_Impo_Cong_Cree.CONGAC4_LEGA_THEO      :=NewCONGAC4_LEGA_THEO    ;if bError then PR_MAJ_LOG(pCONGAC4_LEGA_THEO        ,'CONGAC4_LEGA_THEO'    ,'La donnée saisie est de format incorrect') ;end if;

      n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,ID_SALA,DETA,PREN,NOM,NUME,ETAP,Z1)values(pID_SOCI,pID_SALA,'MAIN',pPREN,pNOM,n,' Aprés les validations err=',ERR);commit;


      If Err = 0 then
        rSala_Impo_Cong_Cree.ID_SALA:=pID_SALA;
        rSala_Impo_Cong_Cree.TYPE:='INTE';

        INSERT INTO SALARIE_IMPO_CONG values rSala_Impo_Cong_Cree;commit;

        n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,ID_SALA,DETA,PREN,NOM,NUME,ETAP)values(pID_SOCI,pID_SALA,'MAIN',pPREN,pNOM,n,' on importe ');commit;

        if pBRUTPREC4         is not null then PR_SAISIEVAH_MAJ(pID_SALA,'BRUTPREC4'        , pPERI_IMPO,NewBRUTPREC4           );    end if;
        if pCONGAC4_LEGA      is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC4_LEGA'   , pPERI_IMPO,NewCONGAC4_LEGA        );      end if;
        if pCONGAPRE4_LEGA    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE4_LEGA' , pPERI_IMPO,NewCONGAPRE4_LEGA      );      end if;
        if pCONGAC4_ANCI_1    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC4_ANCI_1' , pPERI_IMPO,NewCONGAC4_ANCI_1      );      end if;
        if pCONGAPRE4_ANCI_1  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE4_ANCI_1', pPERI_IMPO,NewCONGAPRE4_ANCI_1    );     end if;
        if pCONGAC4_ANCI_2    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC4_ANCI_2' , pPERI_IMPO,NewCONGAC4_ANCI_2      );      end if;
        if pCONGAPRE4_ANCI_2  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE4_ANCI_2', pPERI_IMPO,NewCONGAPRE4_ANCI_2    );     end if;
        if pCONGAC4_ANCI_3    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC4_ANCI_3' , pPERI_IMPO,NewCONGAC4_ANCI_3      );      end if;
        if pCONGAPRE4_ANCI_3  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE4_ANCI_3', pPERI_IMPO,NewCONGAPRE4_ANCI_3    );     end if;
        if pCONGAC4_FRAC      is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC4_FRAC'   , pPERI_IMPO,NewCONGAC4_FRAC        );      end if;
        if pCONGAPRE4_FRAC    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE4_FRAC' , pPERI_IMPO,NewCONGAPRE4_FRAC      );      end if;
        if pBRUTPREC3         is not null then PR_SAISIEVAH_MAJ(pID_SALA,'BRUTPREC3'        , pPERI_IMPO,NewBRUTPREC3           );    end if;
        if pCONGAC3_LEGA      is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC3_LEGA'   , pPERI_IMPO,NewCONGAC3_LEGA        );      end if;
        if pCONGAPRE3_LEGA    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE3_LEGA' , pPERI_IMPO,NewCONGAPRE3_LEGA      );      end if;
        if pCONGAC3_ANCI_1    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC3_ANCI_1' , pPERI_IMPO,NewCONGAC3_ANCI_1      );      end if;
        if pCONGAPRE3_ANCI_1  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE3_ANCI_1', pPERI_IMPO,NewCONGAPRE3_ANCI_1    );     end if;
        if pCONGAC3_ANCI_2    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC3_ANCI_2' , pPERI_IMPO,NewCONGAC3_ANCI_2      );      end if;
        if pCONGAPRE3_ANCI_2  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE3_ANCI_2', pPERI_IMPO,NewCONGAPRE3_ANCI_2    );     end if;
        if pCONGAC3_ANCI_3    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC3_ANCI_3' , pPERI_IMPO,NewCONGAC3_ANCI_3      );      end if;
        if pCONGAPRE3_ANCI_3  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE3_ANCI_3', pPERI_IMPO,NewCONGAPRE3_ANCI_3    );     end if;
        if pCONGAC3_FRAC      is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC3_FRAC'   , pPERI_IMPO,NewCONGAC3_FRAC        );      end if;
        if pCONGAPRE3_FRAC    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE3_FRAC' , pPERI_IMPO,NewCONGAPRE3_FRAC      );      end if;
        if pBRUTPREC2         is not null then PR_SAISIEVAH_MAJ(pID_SALA,'BRUTPREC2'        , pPERI_IMPO,NewBRUTPREC2           );    end if;
        if pCONGAC2_LEGA      is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC2_LEGA'   , pPERI_IMPO,NewCONGAC2_LEGA        );      end if;
        if pCONGAPRE2_LEGA    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE2_LEGA' , pPERI_IMPO,NewCONGAPRE2_LEGA      );      end if;
        if pCONGAC2_ANCI_1    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC2_ANCI_1' , pPERI_IMPO,NewCONGAC2_ANCI_1      );      end if;
        if pCONGAPRE2_ANCI_1  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE2_ANCI_1', pPERI_IMPO,NewCONGAPRE2_ANCI_1    );     end if;
        if pCONGAC2_ANCI_2    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC2_ANCI_2' , pPERI_IMPO,NewCONGAC2_ANCI_2      );      end if;
        if pCONGAPRE2_ANCI_2  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE2_ANCI_2', pPERI_IMPO,NewCONGAPRE2_ANCI_2    );     end if;
        if pCONGAC2_ANCI_3    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC2_ANCI_3' , pPERI_IMPO,NewCONGAC2_ANCI_3      );      end if;
        if pCONGAPRE2_ANCI_3  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE2_ANCI_3', pPERI_IMPO,NewCONGAPRE2_ANCI_3    );     end if;
        if pCONGAC2_FRAC      is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC2_FRAC'   , pPERI_IMPO,NewCONGAC2_FRAC        );      end if;
        if pCONGAPRE2_FRAC    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE2_FRAC' , pPERI_IMPO,NewCONGAPRE2_FRAC      );      end if;
        if pBRUTPREC1         is not null then PR_SAISIEVAH_MAJ(pID_SALA,'BRUTPREC1'        , pPERI_IMPO,NewBRUTPREC1           );    end if;
        if pCONGAC1_LEGA      is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC1_LEGA'   , pPERI_IMPO,NewCONGAC1_LEGA        );      end if;
        if pCONGAPRE1_LEGA    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE1_LEGA' , pPERI_IMPO,NewCONGAPRE1_LEGA      );      end if;
        if pCONGAC1_ANCI_1    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC1_ANCI_1' , pPERI_IMPO,NewCONGAC1_ANCI_1      );      end if;
        if pCONGAPRE1_ANCI_1  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE1_ANCI_1', pPERI_IMPO,NewCONGAPRE1_ANCI_1    );     end if;
        if pCONGAC1_ANCI_2    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC1_ANCI_2' , pPERI_IMPO,NewCONGAC1_ANCI_2      );      end if;
        if pCONGAPRE1_ANCI_2  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE1_ANCI_2', pPERI_IMPO,NewCONGAPRE1_ANCI_2    );     end if;
        if pCONGAC1_ANCI_3    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC1_ANCI_3' , pPERI_IMPO,NewCONGAC1_ANCI_3      );      end if;
        if pCONGAPRE1_ANCI_3  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE1_ANCI_3', pPERI_IMPO,NewCONGAPRE1_ANCI_3    );     end if;
        if pCONGAC1_FRAC      is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC1_FRAC'   , pPERI_IMPO,NewCONGAC1_FRAC        );      end if;
        if pCONGAPRE1_FRAC    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE1_FRAC'   , pPERI_IMPO,NewCONGAPRE1_FRAC      );      end if;
        if pBRUTPREC0         is not null then PR_SAISIEVAH_MAJ(pID_SALA,'BRUTPREC0'        , pPERI_IMPO,NewBRUTPREC0           );    end if;
        if pCOACOURS_LEGA     is not null then PR_SAISIEVAH_MAJ(pID_SALA,'COACOURS_LEGA'    , pPERI_IMPO,NewCOACOURS_LEGA       );    end if;
        if pCONGAPRE0_LEGA    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE0_LEGA'   , pPERI_IMPO,NewCONGAPRE0_LEGA      );      end if;
        if pCOACOURS_ANCI_1   is not null then PR_SAISIEVAH_MAJ(pID_SALA,'COACOURS_ANCI_1'  , pPERI_IMPO,NewCOACOURS_ANCI_1     );    end if;
        if pCONGAPRE0_ANCI_1  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE0_ANCI_1', pPERI_IMPO,NewCONGAPRE0_ANCI_1    );     end if;
        if pCOACOURS_ANCI_2   is not null then PR_SAISIEVAH_MAJ(pID_SALA,'COACOURS_ANCI_2'  , pPERI_IMPO,NewCOACOURS_ANCI_2     );    end if;
        if pCONGAPRE0_ANCI_2  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE0_ANCI_2', pPERI_IMPO,NewCONGAPRE0_ANCI_2    );     end if;
        if pCOACOURS_ANCI_3   is not null then PR_SAISIEVAH_MAJ(pID_SALA,'COACOURS_ANCI_3'  , pPERI_IMPO,NewCOACOURS_ANCI_3     );    end if;
        if pCONGAPRE0_ANCI_3  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE0_ANCI_3', pPERI_IMPO,NewCONGAPRE0_ANCI_3    );     end if;
        if pCOACOURS_FRAC     is not null then PR_SAISIEVAH_MAJ(pID_SALA,'COACOURS_FRAC'    , pPERI_IMPO,NewCOACOURS_FRAC       );    end if;
        if pCONGAPRE0_FRAC    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE0_FRAC' , pPERI_IMPO,NewCONGAPRE0_FRAC      );      end if;
        if pBRUTPRECM1        is not null then PR_SAISIEVAH_MAJ(pID_SALA,'BRUTPRECM1'     , pPERI_IMPO,NewBRUTPRECM1          );      end if;

        if pCP_INDE_MONT_N0_PREC  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CP_INDE_MONT_N0_PREC'     , pPERI_IMPO,NewCP_INDE_MONT_N0_PREC       );      end if;
        if pCP_INDE_MONT_N1_PREC  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CP_INDE_MONT_N1_PREC'     , pPERI_IMPO,NewCP_INDE_MONT_N1_PREC       );      end if;
        if pCP_INDE_MONT_N2_PREC  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CP_INDE_MONT_N2_PREC'     , pPERI_IMPO,NewCP_INDE_MONT_N2_PREC       );      end if;
        if pCP_INDE_MONT_N3_PREC  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CP_INDE_MONT_N3_PREC'     , pPERI_IMPO,NewCP_INDE_MONT_N3_PREC       );      end if;
        if pCP_INDE_MONT_N4_PREC  is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CP_INDE_MONT_N4_PREC'     , pPERI_IMPO,NewCP_INDE_MONT_N4_PREC       );      end if;


        n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,ID_SALA,PREN,NOM,DETA,NUME,ETAP,Z1,Z2,Z3,Z4,Z5)values(pID_SOCI,pID_SALA,pPREN,pNOM,'MAJ',n,' Mise à jour de la valeur avec Peri=',pPERI_IMPO,' coac cours',NewCOACOURS_LEGA,' Brut prec=',NewBRUTPREC1);commit;

        -- mise à jour des constantes de RESTANT TOTAL par type

        -- Récupération paramétrage société pour les congés
        begin
           select
             rest_enco_lega,
             rest_enco_anci_1,
             rest_enco_anci_2,
             rest_enco_anci_3,
             rest_enco_frac
           into
             vREST_ENCO_LEGA,
             vREST_ENCO_ANCI_1,
             vREST_ENCO_ANCI_2,
             vREST_ENCO_ANCI_3,
             vREST_ENCO_FRAC
           from societe_para_sais_cong
           where id_soci=iSALA_ID_SOCI;
        exception
          when no_data_found then
          vREST_ENCO_LEGA   :='N';
          vREST_ENCO_ANCI_1 :='N';
          vREST_ENCO_ANCI_2 :='N';
          vREST_ENCO_ANCI_3 :='N';
          vREST_ENCO_FRAC   :='N';
        end;

        -- permet de déterminer si l acquisition sur l année en cours doit être intégrée dans les restants
        -- ainsi que le calcul des restants négatif en cas de prise par anticipation
        if vREST_ENCO_LEGA   ='O' then fCONG_LEGA_REST_N0   := nvl(NewCONGAPRE0_LEGA  ,0); else if parse_float(nvl(NewCOACOURS_LEGA  ,0)) > parse_float(nvl(NewCONGAPRE0_LEGA  ,0)) then fCONG_LEGA_REST_N0   := - (parse_float(nvl(NewCOACOURS_LEGA  ,0)) - parse_float(nvl(NewCONGAPRE0_LEGA  ,0))); else fCONG_LEGA_REST_N0   := 0; end if; end if;
        if vREST_ENCO_ANCI_1 ='O' then fCONG_ANCI_1_REST_N0 := nvl(NewCONGAPRE0_ANCI_1,0); else if parse_float(nvl(NewCOACOURS_ANCI_1,0)) > parse_float(nvl(NewCONGAPRE0_ANCI_1,0)) then fCONG_ANCI_1_REST_N0 := - (parse_float(nvl(NewCOACOURS_ANCI_1,0)) - parse_float(nvl(NewCONGAPRE0_ANCI_1,0))); else fCONG_ANCI_1_REST_N0 := 0; end if; end if;
        if vREST_ENCO_ANCI_2 ='O' then fCONG_ANCI_2_REST_N0 := nvl(NewCONGAPRE0_ANCI_2,0); else if parse_float(nvl(NewCOACOURS_ANCI_2,0)) > parse_float(nvl(NewCONGAPRE0_ANCI_2,0)) then fCONG_ANCI_2_REST_N0 := - (parse_float(nvl(NewCOACOURS_ANCI_2,0)) - parse_float(nvl(NewCONGAPRE0_ANCI_2,0))); else fCONG_ANCI_2_REST_N0 := 0; end if; end if;
        if vREST_ENCO_ANCI_3 ='O' then fCONG_ANCI_3_REST_N0 := nvl(NewCONGAPRE0_ANCI_3,0); else if parse_float(nvl(NewCOACOURS_ANCI_3,0)) > parse_float(nvl(NewCONGAPRE0_ANCI_3,0)) then fCONG_ANCI_3_REST_N0 := - (parse_float(nvl(NewCOACOURS_ANCI_3,0)) - parse_float(nvl(NewCONGAPRE0_ANCI_3,0))); else fCONG_ANCI_3_REST_N0 := 0; end if; end if;
        if vREST_ENCO_FRAC   ='O' then fCONG_FRAC_REST_N0   := nvl(NewCONGAPRE0_FRAC  ,0); else if parse_float(nvl(NewCOACOURS_FRAC  ,0)) > parse_float(nvl(NewCONGAPRE0_FRAC  ,0)) then fCONG_FRAC_REST_N0   := - (parse_float(nvl(NewCOACOURS_FRAC  ,0)) - parse_float(nvl(NewCONGAPRE0_FRAC  ,0))); else fCONG_FRAC_REST_N0   := 0; end if; end if;

        -- MAJ restants total en fonction des restants par période de référence
        fCONG_LEGA_REST   := parse_float(nvl(NewCONGAPRE4_LEGA  ,0) + nvl(NewCONGAPRE3_LEGA  ,0) + nvl(NewCONGAPRE2_LEGA  ,0) + nvl(NewCONGAPRE1_LEGA  ,0) + nvl(fCONG_LEGA_REST_N0  ,0));
        fCONG_ANCI_1_REST := parse_float(nvl(NewCONGAPRE4_ANCI_1,0) + nvl(NewCONGAPRE3_ANCI_1,0) + nvl(NewCONGAPRE2_ANCI_1,0) + nvl(NewCONGAPRE1_ANCI_1,0) + nvl(fCONG_ANCI_1_REST_N0,0));
        fCONG_ANCI_2_REST := parse_float(nvl(NewCONGAPRE4_ANCI_2,0) + nvl(NewCONGAPRE3_ANCI_2,0) + nvl(NewCONGAPRE2_ANCI_2,0) + nvl(NewCONGAPRE1_ANCI_2,0) + nvl(fCONG_ANCI_2_REST_N0,0));
        fCONG_ANCI_3_REST := parse_float(nvl(NewCONGAPRE4_ANCI_3,0) + nvl(NewCONGAPRE3_ANCI_3,0) + nvl(NewCONGAPRE2_ANCI_3,0) + nvl(NewCONGAPRE1_ANCI_3,0) + nvl(fCONG_ANCI_3_REST_N0,0));
        fCONG_FRAC_REST   := parse_float(nvl(NewCONGAPRE4_FRAC  ,0) + nvl(NewCONGAPRE3_FRAC  ,0) + nvl(NewCONGAPRE2_FRAC  ,0) + nvl(NewCONGAPRE1_FRAC  ,0) + nvl(fCONG_FRAC_REST_N0  ,0));


        N:=N+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,ID_SALA,NUME,ETAP,Z1,Z2,Z3,Z4,Z5) values (pID_SOCI,pID_SALA,n,'* id_sala=',pID_SALA,' peri_cour=',pPERI_IMPO,' fCONG_LEGA_REST=',fCONG_LEGA_REST);commit;

        PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE_LEGA'  ,pPERI_IMPO,fCONG_LEGA_REST  );
        PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE_ANCI_1',pPERI_IMPO,fCONG_ANCI_1_REST);
        PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE_ANCI_2',pPERI_IMPO,fCONG_ANCI_2_REST);
        PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE_ANCI_3',pPERI_IMPO,fCONG_ANCI_3_REST);
        PR_SAISIEVAH_MAJ(pID_SALA,'CONGAPRE_FRAC'  ,pPERI_IMPO,fCONG_FRAC_REST  );

        -- ML 2018 04 12 T69964 : màj de RTTAN et RTTPRIANN insuffisant en cas d import sur la période en cours et de présence d'autres données particpant au calcul de RTTAPRE (voir pr_sabu_insert_comp_rtt)
        if (NewRTTAN    ='0' or NewRTTAN     is null)                          and NewRTTAPRE is not null then NewRTTAN    :=NewRTTAPRE; end if;
        if (NewRTTPRIANN='0' or NewRTTPRIANN is null) and NewRTTAN is not null and NewRTTAPRE is not null then NewRTTPRIANN:=NewRTTAN-NewRTTAPRE; end if;

        if pRTTAN              is not null then PR_SAISIEVAH_MAJ(pID_SALA,'RTTAN'              ,pPERI_IMPO,NewRTTAN);              end if;
        if pRTTPRIANN          is not null then PR_SAISIEVAH_MAJ(pID_SALA,'RTTPRIANN'          ,pPERI_IMPO,NewRTTPRIANN);          end if;
        if pRTTAPRE            is not null then PR_SAISIEVAH_MAJ(pID_SALA,'RTTAPRE'            ,pPERI_IMPO,NewRTTAPRE);            end if;
        if pRTTREPRIS          is not null then PR_SAISIEVAH_MAJ(pID_SALA,'RTTREPRIS'          ,pPERI_IMPO,NewRTTREPRIS);          end if;
        if pRTT_SALA_REST_CLOT is not null then PR_SAISIEVAH_MAJ(pID_SALA,'RTT_SALA_REST_CLOT' ,pPERI_IMPO,NewRTT_SALA_REST_CLOT); end if;


        -- ML 2018 04 12 T69964 : màj de RTTANPAT et RTTPRIANNPAT insuffisant en cas d import sur la période en cours et de présence d'autres données particpant au calcul de RTTAPREPAT (voir pr_sabu_insert_comp_rtt)
        if (NewRTTANPAT    ='0' or NewRTTANPAT     is null)                             and NewRTTAPREPAT is not null then NewRTTANPAT    :=NewRTTAPREPAT; end if;
        if (NewRTTPRIANNPAT='0' or NewRTTPRIANNPAT is null) and NewRTTANPAT is not null and NewRTTAPREPAT is not null then NewRTTPRIANNPAT:=NewRTTANPAT-NewRTTAPREPAT; end if;

        if pRTTANPAT           is not null then PR_SAISIEVAH_MAJ(pID_SALA,'RTTANPAT'           ,pPERI_IMPO,NewRTTANPAT);           end if;
        if pRTTPRIANNPAT       is not null then PR_SAISIEVAH_MAJ(pID_SALA,'RTTPRIANNPAT'       ,pPERI_IMPO,NewRTTPRIANNPAT);       end if;
        if pRTTAPREPAT         is not null then PR_SAISIEVAH_MAJ(pID_SALA,'RTTAPREPAT'         ,pPERI_IMPO,NewRTTAPREPAT);         end if;
        if pRTTREPRISPAT       is not null then PR_SAISIEVAH_MAJ(pID_SALA,'RTTREPRISPAT'       ,pPERI_IMPO,NewRTTREPRISPAT);       end if;
        if pRTT_PATR_REST_CLOT is not null then PR_SAISIEVAH_MAJ(pID_SALA,'RTT_PATR_REST_CLOT' ,pPERI_IMPO,NewRTT_PATR_REST_CLOT); end if;

        --select NOMB_RTT_ACQU into pRTTACQMOIS from SOCIETE where ID_SOCI = iSALA_ID_SOCI;
        --PR_SAISIEVAH_MAJ(pID_SALA,'RTTACQMOIS',pPERI_IMPO,pRTTACQMOIS); --RTTACQMOIS

        if pCETACQCPANN       is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETACQCPANN'    ,pPERI_IMPO,NewCETACQCPANN);        end if;
        if pCETACQRTTSALANN   is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETACQRTTSALANN',pPERI_IMPO,NewCETACQRTTSALANN);    end if;
        if pCETACQRTTPATANN   is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETACQRTTPATANN',pPERI_IMPO,NewCETACQRTTPATANN);    end if;
        if pCETPRICPANN       is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETPRICPANN'    ,pPERI_IMPO,NewCETPRICPANN);        end if;
        if pCETPRIRTTSALANN   is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETPRIRTTSALANN',pPERI_IMPO,NewCETPRIRTTSALANN);    end if;
        if pCETPRIRTTPATANN   is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETPRIRTTPATANN',pPERI_IMPO,NewCETPRIRTTPATANN);    end if;
        if pCETRESCP          is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETRESCP'       ,pPERI_IMPO,NewCETRESCP);           end if;
        if pCETRESRTTPAT      is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETRESRTTPAT'   ,pPERI_IMPO,NewCETRESRTTPAT);       end if;
        if pCETRESRTTSAL      is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETRESRTTSAL'   ,pPERI_IMPO,NewCETRESRTTSAL);       end if;
        if pCETACQCPNOMOANN   is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETACQCPNOMOANN',pPERI_IMPO,NewCETACQCPNOMOANN);    end if;
        if pCETPRICPNOMOANN   is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETPRICPNOMOANN',pPERI_IMPO,NewCETPRICPNOMOANN);    end if;
        if pCETRESCPNOMO      is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CETRESCPNOMO'   ,pPERI_IMPO,NewCETRESCPNOMO);       end if;



        -- Repos compensateur
        -- ML le 21/04/2009 constante HREPACQUI plus utilisée
        --PR_SAISIEVAH_MAJ(pID_SALA,'REPACQUI' ,pPERI_IMPO,NewREPACQUI); -- ML le 21/04/2009 constante REPACQUI désormais calculée dans PR_CALC_BULL_FIN_REPO_COMP égale à REPACQUIANN+REPACQUIMOI
        if pREPACQUI is not null then PR_SAISIEVAH_MAJ(pID_SALA,'REPACQUIANN' ,pPERI_IMPO,NewREPACQUI);end if;

        if pREPOPRISAN is not null then PR_SAISIEVAH_MAJ(pID_SALA,'REPOPRISAN' ,pPERI_IMPO,NewREPOPRISAN);end if;

        --PR_SAISIEVAH_MAJ(pID_SALA,'REPOSCUM' ,pPERI_IMPO,NewREPOSCUM); -- ML le 21/04/2009 constante REPOSCUM désormais calculée dans PR_CALC_BULL_FIN_REPO_COMP égale à REPACQUI - REPOPRISAN - REPOPRISMOI
        if pREPOSCUM is not null then PR_SAISIEVAH_MAJ(pID_SALA,'REPOPRISAN' ,pPERI_IMPO,NewREPACQUI-NewREPOSCUM);end if;

        -- compteurs supplémentaires, RCR, RCN (T80556)
        if (NewRTTANSUP          ='0' or NewRTTANSUP          is null) and NewRTTAPRESUP   is not null then NewRTTANSUP          := NewRTTAPRESUP  ; end if;
        if (NewCOSU_01_ACQU_ANNE ='0' or NewCOSU_01_ACQU_ANNE is null) and NewCOSU_01_REST is not null then NewCOSU_01_ACQU_ANNE := NewCOSU_01_REST; end if;
        if (NewCOSU_02_ACQU_ANNE ='0' or NewCOSU_02_ACQU_ANNE is null) and NewCOSU_02_REST is not null then NewCOSU_02_ACQU_ANNE := NewCOSU_02_REST; end if;
        if (NewCOSU_03_ACQU_ANNE ='0' or NewCOSU_03_ACQU_ANNE is null) and NewCOSU_03_REST is not null then NewCOSU_03_ACQU_ANNE := NewCOSU_03_REST; end if;
        if (NewCOSU_01_ACQU_ANNE_N1 ='0' or NewCOSU_01_ACQU_ANNE_N1 is null) and NewCOSU_01_REST_N1 is not null then NewCOSU_01_ACQU_ANNE_N1 := NewCOSU_01_REST_N1; end if;
        if (NewCOSU_02_ACQU_ANNE_N1 ='0' or NewCOSU_02_ACQU_ANNE_N1 is null) and NewCOSU_02_REST_N1 is not null then NewCOSU_02_ACQU_ANNE_N1 := NewCOSU_02_REST_N1; end if;
        if (NewCOSU_03_ACQU_ANNE_N1 ='0' or NewCOSU_03_ACQU_ANNE_N1 is null) and NewCOSU_03_REST_N1 is not null then NewCOSU_03_ACQU_ANNE_N1 := NewCOSU_03_REST_N1; end if;
        if (NewCOSU_01_ACQU_ANNE_N2 ='0' or NewCOSU_01_ACQU_ANNE_N2 is null) and NewCOSU_01_REST_N2 is not null then NewCOSU_01_ACQU_ANNE_N2 := NewCOSU_01_REST_N2; end if;
        if (NewCOSU_02_ACQU_ANNE_N2 ='0' or NewCOSU_02_ACQU_ANNE_N2 is null) and NewCOSU_02_REST_N2 is not null then NewCOSU_02_ACQU_ANNE_N2 := NewCOSU_02_REST_N2; end if;
        if (NewCOSU_03_ACQU_ANNE_N2 ='0' or NewCOSU_03_ACQU_ANNE_N2 is null) and NewCOSU_03_REST_N2 is not null then NewCOSU_03_ACQU_ANNE_N2 := NewCOSU_03_REST_N2; end if;

        if (NewRCRACQUIANN       ='0' or NewRCRACQUIANN       is null) and NewRCRCUM       is not null then NewRCRACQUIANN       := NewRCRCUM      ; end if;
        if (NewRCNACQUIANN       ='0' or NewRCNACQUIANN       is null) and NewRCNCUM       is not null then NewRCNACQUIANN       := NewRCNCUM      ; end if;
        if pRTTANSUP          is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'RTTANSUP'         , pPERI_IMPO, NewRTTANSUP);          end if;
        if pRTTPRIANNSUP      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'RTTPRIANNSUP'     , pPERI_IMPO, NewRTTPRIANNSUP);      end if;
        if pRTTAPRESUP        is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'RTTAPRESUP'       , pPERI_IMPO, NewRTTAPRESUP);        end if;
        if pCOSU_01_ACQU_ANNE is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_01_ACQU_ANNE', pPERI_IMPO, NewCOSU_01_ACQU_ANNE); end if;
        if pCOSU_01_PRIS_ANNE is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_01_PRIS_ANNE', pPERI_IMPO, NewCOSU_01_PRIS_ANNE); end if;
        if pCOSU_01_REST      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_01_REST'     , pPERI_IMPO, NewCOSU_01_REST);      end if;
        if pCOSU_02_ACQU_ANNE is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_02_ACQU_ANNE', pPERI_IMPO, NewCOSU_02_ACQU_ANNE); end if;
        if pCOSU_02_PRIS_ANNE is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_02_PRIS_ANNE', pPERI_IMPO, NewCOSU_02_PRIS_ANNE); end if;
        if pCOSU_02_REST      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_02_REST'     , pPERI_IMPO, NewCOSU_02_REST);      end if;
        if pCOSU_03_ACQU_ANNE is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_03_ACQU_ANNE', pPERI_IMPO, NewCOSU_03_ACQU_ANNE); end if;
        if pCOSU_03_PRIS_ANNE is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_03_PRIS_ANNE', pPERI_IMPO, NewCOSU_03_PRIS_ANNE); end if;
        if pCOSU_03_REST      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_03_REST'     , pPERI_IMPO, NewCOSU_03_REST);      end if;
        if pRCRACQUIANN       is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'RCRACQUIANN'      , pPERI_IMPO, NewRCRACQUIANN);       end if;
        if pRCRPRISAN         is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'RCRPRISAN'        , pPERI_IMPO, NewRCRPRISAN);         end if;
        if pRCRCUM            is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'RCRCUM'           , pPERI_IMPO, NewRCRCUM);            end if;
        if pRCNACQUIANN       is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'RCNACQUIANN'      , pPERI_IMPO, NewRCNACQUIANN);       end if;
        if pRCNPRISAN         is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'RCNPRISAN'        , pPERI_IMPO, NewRCNPRISAN);         end if;
        if pRCNCUM            is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'RCNCUM'           , pPERI_IMPO, NewRCNCUM);            end if;

        if pCOSU_01_ACQU_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_01_ACQU_ANNE_N1', pPERI_IMPO, NewCOSU_01_ACQU_ANNE_N1); end if;
        if pCOSU_01_PRIS_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_01_PRIS_ANNE_N1', pPERI_IMPO, NewCOSU_01_PRIS_ANNE_N1); end if;
        if pCOSU_01_REST_N1      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_01_REST_N1'     , pPERI_IMPO, NewCOSU_01_REST_N1);      end if;
        if pCOSU_02_ACQU_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_02_ACQU_ANNE_N1', pPERI_IMPO, NewCOSU_02_ACQU_ANNE_N1); end if;
        if pCOSU_02_PRIS_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_02_PRIS_ANNE_N1', pPERI_IMPO, NewCOSU_02_PRIS_ANNE_N1); end if;
        if pCOSU_02_REST_N1      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_02_REST_N1'     , pPERI_IMPO, NewCOSU_02_REST_N1);      end if;
        if pCOSU_03_ACQU_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_03_ACQU_ANNE_N1', pPERI_IMPO, NewCOSU_03_ACQU_ANNE_N1); end if;
        if pCOSU_03_PRIS_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_03_PRIS_ANNE_N1', pPERI_IMPO, NewCOSU_03_PRIS_ANNE_N1); end if;
        if pCOSU_03_REST_N1      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_03_REST_N1'     , pPERI_IMPO, NewCOSU_03_REST_N1);      end if;
        if pCOSU_01_ACQU_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_01_ACQU_ANNE_N2', pPERI_IMPO, NewCOSU_01_ACQU_ANNE_N2); end if;
        if pCOSU_01_PRIS_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_01_PRIS_ANNE_N2', pPERI_IMPO, NewCOSU_01_PRIS_ANNE_N2); end if;
        if pCOSU_01_REST_N2      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_01_REST_N2'     , pPERI_IMPO, NewCOSU_01_REST_N2);      end if;
        if pCOSU_02_ACQU_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_02_ACQU_ANNE_N2', pPERI_IMPO, NewCOSU_02_ACQU_ANNE_N2); end if;
        if pCOSU_02_PRIS_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_02_PRIS_ANNE_N2', pPERI_IMPO, NewCOSU_02_PRIS_ANNE_N2); end if;
        if pCOSU_02_REST_N2      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_02_REST_N2'     , pPERI_IMPO, NewCOSU_02_REST_N2);      end if;
        if pCOSU_03_ACQU_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_03_ACQU_ANNE_N2', pPERI_IMPO, NewCOSU_03_ACQU_ANNE_N2); end if;
        if pCOSU_03_PRIS_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_03_PRIS_ANNE_N2', pPERI_IMPO, NewCOSU_03_PRIS_ANNE_N2); end if;
        if pCOSU_03_REST_N2      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_03_REST_N2'     , pPERI_IMPO, NewCOSU_03_REST_N2);      end if;

        if (NewCOSU_04_ACQU_ANNE    ='0' or NewCOSU_04_ACQU_ANNE    is null) and NewCOSU_04_REST    is not null then NewCOSU_04_ACQU_ANNE    := NewCOSU_04_REST   ; end if;
        if (NewCOSU_04_ACQU_ANNE_N1 ='0' or NewCOSU_04_ACQU_ANNE_N1 is null) and NewCOSU_04_REST_N1 is not null then NewCOSU_04_ACQU_ANNE_N1 := NewCOSU_04_REST_N1; end if;
        if (NewCOSU_04_ACQU_ANNE_N2 ='0' or NewCOSU_04_ACQU_ANNE_N2 is null) and NewCOSU_04_REST_N2 is not null then NewCOSU_04_ACQU_ANNE_N2 := NewCOSU_04_REST_N2; end if;
        if pCOSU_04_ACQU_ANNE    is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_04_ACQU_ANNE'   , pPERI_IMPO, NewCOSU_04_ACQU_ANNE   ); end if;
        if pCOSU_04_PRIS_ANNE    is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_04_PRIS_ANNE'   , pPERI_IMPO, NewCOSU_04_PRIS_ANNE   ); end if;
        if pCOSU_04_REST         is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_04_REST'        , pPERI_IMPO, NewCOSU_04_REST);         end if;
        if pCOSU_04_ACQU_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_04_ACQU_ANNE_N1', pPERI_IMPO, NewCOSU_04_ACQU_ANNE_N1); end if;
        if pCOSU_04_PRIS_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_04_PRIS_ANNE_N1', pPERI_IMPO, NewCOSU_04_PRIS_ANNE_N1); end if;
        if pCOSU_04_REST_N1      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_04_REST_N1'     , pPERI_IMPO, NewCOSU_04_REST_N1);      end if;
        if pCOSU_04_ACQU_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_04_ACQU_ANNE_N2', pPERI_IMPO, NewCOSU_04_ACQU_ANNE_N2); end if;
        if pCOSU_04_PRIS_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_04_PRIS_ANNE_N2', pPERI_IMPO, NewCOSU_04_PRIS_ANNE_N2); end if;
        if pCOSU_04_REST_N2      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_04_REST_N2'     , pPERI_IMPO, NewCOSU_04_REST_N2);      end if;

        if (NewCOSU_05_ACQU_ANNE    ='0' or NewCOSU_05_ACQU_ANNE    is null) and NewCOSU_05_REST    is not null then NewCOSU_05_ACQU_ANNE    := NewCOSU_05_REST   ; end if;
        if (NewCOSU_05_ACQU_ANNE_N1 ='0' or NewCOSU_05_ACQU_ANNE_N1 is null) and NewCOSU_05_REST_N1 is not null then NewCOSU_05_ACQU_ANNE_N1 := NewCOSU_05_REST_N1; end if;
        if (NewCOSU_05_ACQU_ANNE_N2 ='0' or NewCOSU_05_ACQU_ANNE_N2 is null) and NewCOSU_05_REST_N2 is not null then NewCOSU_05_ACQU_ANNE_N2 := NewCOSU_05_REST_N2; end if;
        if pCOSU_05_ACQU_ANNE    is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_05_ACQU_ANNE'   , pPERI_IMPO, NewCOSU_05_ACQU_ANNE   ); end if;
        if pCOSU_05_PRIS_ANNE    is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_05_PRIS_ANNE'   , pPERI_IMPO, NewCOSU_05_PRIS_ANNE   ); end if;
        if pCOSU_05_REST         is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_05_REST'        , pPERI_IMPO, NewCOSU_05_REST);         end if;
        if pCOSU_05_ACQU_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_05_ACQU_ANNE_N1', pPERI_IMPO, NewCOSU_05_ACQU_ANNE_N1); end if;
        if pCOSU_05_PRIS_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_05_PRIS_ANNE_N1', pPERI_IMPO, NewCOSU_05_PRIS_ANNE_N1); end if;
        if pCOSU_05_REST_N1      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_05_REST_N1'     , pPERI_IMPO, NewCOSU_05_REST_N1);      end if;
        if pCOSU_05_ACQU_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_05_ACQU_ANNE_N2', pPERI_IMPO, NewCOSU_05_ACQU_ANNE_N2); end if;
        if pCOSU_05_PRIS_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_05_PRIS_ANNE_N2', pPERI_IMPO, NewCOSU_05_PRIS_ANNE_N2); end if;
        if pCOSU_05_REST_N2      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_05_REST_N2'     , pPERI_IMPO, NewCOSU_05_REST_N2);      end if;

        if (NewCOSU_06_ACQU_ANNE    ='0' or NewCOSU_06_ACQU_ANNE    is null) and NewCOSU_06_REST    is not null then NewCOSU_06_ACQU_ANNE    := NewCOSU_06_REST   ; end if;
        if (NewCOSU_06_ACQU_ANNE_N1 ='0' or NewCOSU_06_ACQU_ANNE_N1 is null) and NewCOSU_06_REST_N1 is not null then NewCOSU_06_ACQU_ANNE_N1 := NewCOSU_06_REST_N1; end if;
        if (NewCOSU_06_ACQU_ANNE_N2 ='0' or NewCOSU_06_ACQU_ANNE_N2 is null) and NewCOSU_06_REST_N2 is not null then NewCOSU_06_ACQU_ANNE_N2 := NewCOSU_06_REST_N2; end if;
        if pCOSU_06_ACQU_ANNE    is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_06_ACQU_ANNE'   , pPERI_IMPO, NewCOSU_06_ACQU_ANNE   ); end if;
        if pCOSU_06_PRIS_ANNE    is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_06_PRIS_ANNE'   , pPERI_IMPO, NewCOSU_06_PRIS_ANNE   ); end if;
        if pCOSU_06_REST         is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_06_REST'        , pPERI_IMPO, NewCOSU_06_REST);         end if;
        if pCOSU_06_ACQU_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_06_ACQU_ANNE_N1', pPERI_IMPO, NewCOSU_06_ACQU_ANNE_N1); end if;
        if pCOSU_06_PRIS_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_06_PRIS_ANNE_N1', pPERI_IMPO, NewCOSU_06_PRIS_ANNE_N1); end if;
        if pCOSU_06_REST_N1      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_06_REST_N1'     , pPERI_IMPO, NewCOSU_06_REST_N1);      end if;
        if pCOSU_06_ACQU_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_06_ACQU_ANNE_N2', pPERI_IMPO, NewCOSU_06_ACQU_ANNE_N2); end if;
        if pCOSU_06_PRIS_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_06_PRIS_ANNE_N2', pPERI_IMPO, NewCOSU_06_PRIS_ANNE_N2); end if;
        if pCOSU_06_REST_N2      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_06_REST_N2'     , pPERI_IMPO, NewCOSU_06_REST_N2);      end if;

        if (NewCOSU_07_ACQU_ANNE    ='0' or NewCOSU_07_ACQU_ANNE    is null) and NewCOSU_07_REST    is not null then NewCOSU_07_ACQU_ANNE    := NewCOSU_07_REST   ; end if;
        if (NewCOSU_07_ACQU_ANNE_N1 ='0' or NewCOSU_07_ACQU_ANNE_N1 is null) and NewCOSU_07_REST_N1 is not null then NewCOSU_07_ACQU_ANNE_N1 := NewCOSU_07_REST_N1; end if;
        if (NewCOSU_07_ACQU_ANNE_N2 ='0' or NewCOSU_07_ACQU_ANNE_N2 is null) and NewCOSU_07_REST_N2 is not null then NewCOSU_07_ACQU_ANNE_N2 := NewCOSU_07_REST_N2; end if;
        if pCOSU_07_ACQU_ANNE    is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_07_ACQU_ANNE'   , pPERI_IMPO, NewCOSU_07_ACQU_ANNE   ); end if;
        if pCOSU_07_PRIS_ANNE    is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_07_PRIS_ANNE'   , pPERI_IMPO, NewCOSU_07_PRIS_ANNE   ); end if;
        if pCOSU_07_REST         is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_07_REST'        , pPERI_IMPO, NewCOSU_07_REST);         end if;
        if pCOSU_07_ACQU_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_07_ACQU_ANNE_N1', pPERI_IMPO, NewCOSU_07_ACQU_ANNE_N1); end if;
        if pCOSU_07_PRIS_ANNE_N1 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_07_PRIS_ANNE_N1', pPERI_IMPO, NewCOSU_07_PRIS_ANNE_N1); end if;
        if pCOSU_07_REST_N1      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_07_REST_N1'     , pPERI_IMPO, NewCOSU_07_REST_N1);      end if;
        if pCOSU_07_ACQU_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_07_ACQU_ANNE_N2', pPERI_IMPO, NewCOSU_07_ACQU_ANNE_N2); end if;
        if pCOSU_07_PRIS_ANNE_N2 is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_07_PRIS_ANNE_N2', pPERI_IMPO, NewCOSU_07_PRIS_ANNE_N2); end if;
        if pCOSU_07_REST_N2      is not null then PR_SAISIEVAH_MAJ(pID_SALA, 'COSU_07_REST_N2'     , pPERI_IMPO, NewCOSU_07_REST_N2);      end if;

        if pCOACOURS_LEGA_THEO   is not null then PR_SAISIEVAH_MAJ(pID_SALA,'COACOURS_LEGA_THEO'   , pPERI_IMPO,NewCOACOURS_LEGA_THEO   ); end if;
        if pCONGAC1_LEGA_THEO    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC1_LEGA_THEO'    , pPERI_IMPO,NewCONGAC1_LEGA_THEO    ); end if;
        if pCONGAC2_LEGA_THEO    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC2_LEGA_THEO'    , pPERI_IMPO,NewCONGAC2_LEGA_THEO    ); end if;
        if pCONGAC3_LEGA_THEO    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC3_LEGA_THEO'    , pPERI_IMPO,NewCONGAC3_LEGA_THEO    ); end if;
        if pCONGAC4_LEGA_THEO    is not null then PR_SAISIEVAH_MAJ(pID_SALA,'CONGAC4_LEGA_THEO'    , pPERI_IMPO,NewCONGAC4_LEGA_THEO    ); end if;

        --n:=n+1;
        --       INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,ID_SALA,NUME,ETAP,Z1,Z2,Z3,Z4,Z5) values (pID_SOCI,pID_SALA,n,'* Validation REPACQUI=',NewREPACQUI,' REPOSCUM=',NewREPOSCUM,' REPOPRISAN=',-NewREPOSCUM);
        commit;

        --INSERT INTO CALC_BULLETIN (ID_SALA,PERI) values (pID_SALA, pPERI_IMPO);
        --PR_BESOINCALCULBULLETIN(pPERI_IMPO,pID_SALA);
        commit;

        if pMAJ_DONN='O' then
        	PR_MAJ_LOG('','OK','L''import de congés du salarié  "' || pNOM || ' ' || pPREN || '" a correctement été réalisé.'); pr_besoincalculbulletin(pPERI_IMPO,pID_SALA);
        	UPDATE SALARIE_IMPO_CONG SET STAT_IMPO = 'O', ERR_IMPO = 'N', ERR = ' ', DATE_IMPO = TO_CHAR(SYSDATE,'DD/MM/YYYY') WHERE ID_SOCI = pID_SOCI and trim(MATR) = trim(pMATR) AND trim(NOM) = trim(pNOM);
        end if;
        if pMAJ_DONN='N' then
        	PR_MAJ_LOG('','OK','Aucune erreur n''a été repérée. L''import de congés du salarié  "' || pNOM || ' ' || pPREN || '" peut être réalisé.');
        	UPDATE SALARIE_IMPO_CONG SET STAT_IMPO = 'N', ERR_IMPO = 'N', ERR = ' ', DATE_IMPO = TO_CHAR(SYSDATE,'DD/MM/YYYY') WHERE ID_SOCI = pID_SOCI and trim(MATR) = trim(pMATR) AND trim(NOM) = trim(pNOM);
        end if;
      else
        n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,DETA,ID_SALA,PREN,NOM,NUME,ETAP,Z1)values(pID_SOCI,'MAIN',pID_SALA,pPREN,pNOM,n,' on a une erreur  err=',ERR);commit;

        if pMAJ_DONN = 'O' then PR_MAJ_LOG('','ERRE','Reprise des données congés non réalisée pour ce salarié.'); end if;
        UPDATE SALARIE_IMPO_CONG SET ERR_IMPO = 'O', STAT_IMPO = 'N', ERR = ErrInfo WHERE ID_SOCI = pID_SOCI and trim(MATR) = trim(pMATR) AND trim(NOM) = trim(pNOM);
      end if;
    end loop;  ----------- Sur les salariés

  else
    n:=n+1;INSERT INTO DEBUG_IMPO_EXCEL_CONG(ID_SOCI,DETA,ID_SALA,PREN,NOM,NUME,ETAP,Z1)values(pID_SOCI,'MAIN',null,null,null,n,' on a une erreur  err=',ERR);commit;

    UPDATE SALARIE_IMPO_CONG SET ERR_IMPO = 'O', STAT_IMPO = 'N', ERR = ErrInfo WHERE ID_SOCI = pID_SOCI;

  end if; ----------- contrôle validation société -----------
  commit;

  errtools.url(ErrInfo, 'ListeEtats?TEMPLATE=ListeImportHistoriqueCongesSalaries' || chr(38) || 'ID_SOCI=' || pID_SOCI || chr(38) || 'ID_IMPO=' || pID_IMPO || chr(38) || 'MODE_IDEN_SALA=' || pTYPE_RECH_SALA);

end pr_impo_excel_salaries_cong;
