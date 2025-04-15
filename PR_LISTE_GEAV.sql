create or replace PROCEDURE          "PR_LISTE_GEAV" (
   pSYNC_COMP                 in varchar2,             -- MP:SYNC_COMP
   pID_SOCI                   in varchar2,             -- SESS_ID_SOCI
   pID_LOGI                   in varchar2,             -- SESS_ID_LOGI
   pID_LIST                   in varchar2,             -- GEAV_ID_LIST
   pID_SALA                   in varchar2,             -- GEAV_ID_SALA
   pFIN_PERI_ESSA             in varchar2,             -- GEAV_FIN_PERI_ESSA
   pDROI_PRIM_ANCI            in varchar2,             -- GEAV_DROI_PRIM_ANCI
   pBIC_01                    in varchar2,             -- GEAV_BIC_01
   pBIC_02                    in varchar2,             -- GEAV_BIC_02
   pIBAN_01                   in varchar2,             -- GEAV_IBAN_01
   pIBAN_02                   in varchar2,             -- GEAV_IBAN_02
   pCODE_ISO_PAYS_NATI        in varchar2,             -- GEAV_CODE_ISO_PAYS_NATI
   pRAIS_SOCI                 in varchar2,             -- GEAV_RAIS_SOCI
   pSOCI_ORIG                 in varchar2,             -- GEAV_SOCI_ORIG
   pNOM                       in varchar2,             -- GEAV_NOM
   pPREN                      in varchar2,             -- GEAV_PREN
   pTITR                      in varchar2,             -- GEAV_TITR
   pMATR                      in varchar2,             -- GEAV_MATR
   pNOM_JEUN_FILL             in varchar2,             -- GEAV_NOM_JEUN_FILL
   pCONV_COLL                 in varchar2,             -- GEAV_CONV_COLL
   pREAC_REGU                 in varchar2,             -- GEAV_REAC_REGU
   pSERV                      in varchar2,             -- GEAV_SERV
   pDEPA                      in varchar2,             -- GEAV_DEPA
   pCATE_PROF                 in varchar2,             -- GEAV_CATE_PROF
   pLIBE_ETAB                 in varchar2,             -- GEAV_LIBE_ETAB
   pLIBE_ETAB_COUR            in varchar2,             -- GEAV_LIBE_ETAB_COUR
   pEMPL                      in varchar2,             -- GEAV_EMPL
   pEMPL_TYPE                 in varchar2,             -- GEAV_EMPL_TYPE
   pMETI                      in varchar2,             -- GEAV_METI
   pFAMI_METI                 in varchar2,             -- GEAV_FAMI_METI
   pFAMI_METI_HIER            in varchar2,             -- GEAV_FAMI_METI_HIER
   pEMPL_GENE                 in varchar2,             -- GEAV_EMPL_GENE
   pCOEF                      in varchar2,             -- GEAV_COEF
   pDIPL                      in varchar2,             -- GEAV_DIPL
   pNIVE_FORM_EDUC_NATI       in varchar2,             -- GEAV_NIVE_FORM_EDUC_NATI
   pSIRE_ETAB                      in varchar2,             -- GEAV_SIRE_ETAB
   pCODE_UNIT                      in varchar2,             -- GEAV_CODE_UNIT
   pCODE_REGR_FICH_COMP_ETAB                      in varchar2,             -- GEAV_REGR_FICH_COMP_ETAB
   pNIVE                      in varchar2,             -- GEAV_NIVE
   pECHE                      in varchar2,             -- GEAV_ECHE
   pGROU_CONV                 in varchar2,             -- GEAV_GROU_CONV
   pPOSI                      in varchar2,             -- GEAV_POSI
   pINDI                      in varchar2,             -- GEAV_INDI
   pCOTA                      in varchar2,             -- GEAV_COTA (T146548)
   pCLAS                      in varchar2,             -- GEAV_CLAS
   pSEUI                      in varchar2,             -- GEAV_SEUI
   pPALI                      in varchar2,             -- GEAV_PALI
   pGRAD                      in varchar2,             -- GEAV_GRAD
   pDEGR                      in varchar2,             -- GEAV_DEGR
   pFILI                      in varchar2,             -- GEAV_FILI
   pSECT_PROF                 in varchar2,             -- GEAV_SECT_PROF
   pCOMP_BRUT                 in varchar2,             -- GEAV_COMP_BRUT
   pNUME_COMP_BRUT            in varchar2,             -- GEAV_NUME_COMP_BRUT
   pLIBE_COMP_BRUT            in varchar2,             -- GEAV_LIBE_COMP_BRUT
   pCOMP_PAYE                 in varchar2,             -- GEAV_COMP_PAYE
   pNUME_COMP_PAYE            in varchar2,             -- GEAV_NUME_COMP_PAYE
   pLIBE_COMP_PAYE            in varchar2,             -- GEAV_LIBE_COMP_PAYE
   pCOMP_ACOM                 in varchar2,             -- GEAV_COMP_ACOM
   pVALE_SPEC_TR              in varchar2,             -- GEAV_VALE_SPEC_TR
   pCALC_AUTO_TR              in varchar2,             -- GEAV_CALC_AUTO_TR
   pNOMB_JOUR_TRAV_REFE_TR    in varchar2,             -- GEAV_NOMB_JOUR_TRAV_REFE_TR
   pNOMB_TR_CALC_PERI         in varchar2,             -- GEAV_NOMB_TR_CALC_PERI
   pNUME_SECU                 in varchar2,             -- GEAV_NUME_SECU
   pDATE_EMBA                 in varchar2,             -- GEAV_DATE_EMBA
   pDATE_DEPA                 in varchar2,             -- GEAV_DATE_DEPA
   pDATE_ANCI                 in varchar2,             -- GEAV_DATE_ANCI
   pDATE_DELA_PREV            in varchar2,             -- GEAV_DATE_DELA_PREV
   pDATE_NAIS                 in varchar2,             -- GEAV_DATE_NAIS
   pCOMM_NAIS                 in varchar2,             -- GEAV_COMM_NAIS
   pDEPA_NAIS                 in varchar2,             -- GEAV_DEPA_NAIS
   pPAYS_NAIS                 in varchar2,             -- GEAV_PAYS_NAIS
   pCODE_ANAL_01              in varchar2,             -- GEAV_CODE_ANAL_01
   pCODE_ANAL_02              in varchar2,             -- GEAV_CODE_ANAL_02
   pCODE_ANAL_03              in varchar2,             -- GEAV_CODE_ANAL_03
   pCODE_ANAL_04              in varchar2,             -- GEAV_CODE_ANAL_04
   pCODE_ANAL_05              in varchar2,             -- GEAV_CODE_ANAL_05
   pCODE_ANAL_06              in varchar2,             -- GEAV_CODE_ANAL_06
   pCODE_ANAL_07              in varchar2,             -- GEAV_CODE_ANAL_07
   pCODE_ANAL_08              in varchar2,             -- GEAV_CODE_ANAL_08
   pCODE_ANAL_09              in varchar2,             -- GEAV_CODE_ANAL_09
   pCODE_ANAL_10              in varchar2,             -- GEAV_CODE_ANAL_10
   pCODE_ANAL_11              in varchar2,             -- GEAV_CODE_ANAL_11
   pCODE_ANAL_12              in varchar2,             -- GEAV_CODE_ANAL_12
   pCODE_ANAL_13              in varchar2,             -- GEAV_CODE_ANAL_13
   pCODE_ANAL_14              in varchar2,             -- GEAV_CODE_ANAL_14
   pCODE_ANAL_15              in varchar2,             -- GEAV_CODE_ANAL_15
   pCODE_ANAL_16              in varchar2,             -- GEAV_CODE_ANAL_16
   pCODE_ANAL_17              in varchar2,             -- GEAV_CODE_ANAL_17
   pCODE_ANAL_18              in varchar2,             -- GEAV_CODE_ANAL_18
   pCODE_ANAL_19              in varchar2,             -- GEAV_CODE_ANAL_19
   pCODE_ANAL_20              in varchar2,             -- GEAV_CODE_ANAL_20
   pPLAN1_CODE_ANAL_01        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_01
   pPLAN1_CODE_ANAL_02        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_02
   pPLAN1_CODE_ANAL_03        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_03
   pPLAN1_CODE_ANAL_04        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_04
   pPLAN1_CODE_ANAL_05        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_05
   pPLAN1_CODE_ANAL_06        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_06
   pPLAN1_CODE_ANAL_07        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_07
   pPLAN1_CODE_ANAL_08        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_08
   pPLAN1_CODE_ANAL_09        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_09
   pPLAN1_CODE_ANAL_10        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_10
   pPLAN1_CODE_ANAL_11        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_11
   pPLAN1_CODE_ANAL_12        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_12
   pPLAN1_CODE_ANAL_13        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_13
   pPLAN1_CODE_ANAL_14        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_14
   pPLAN1_CODE_ANAL_15        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_15
   pPLAN1_CODE_ANAL_16        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_16
   pPLAN1_CODE_ANAL_17        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_17
   pPLAN1_CODE_ANAL_18        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_18
   pPLAN1_CODE_ANAL_19        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_19
   pPLAN1_CODE_ANAL_20        in varchar2,             -- GEAV_PLAN1_CODE_ANAL_20
   pPLAN1_POUR_AFFE_ANAL_01   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_01
   pPLAN1_POUR_AFFE_ANAL_02   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_02
   pPLAN1_POUR_AFFE_ANAL_03   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_03
   pPLAN1_POUR_AFFE_ANAL_04   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_04
   pPLAN1_POUR_AFFE_ANAL_05   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_05
   pPLAN1_POUR_AFFE_ANAL_06   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_06
   pPLAN1_POUR_AFFE_ANAL_07   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_07
   pPLAN1_POUR_AFFE_ANAL_08   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_08
   pPLAN1_POUR_AFFE_ANAL_09   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_09
   pPLAN1_POUR_AFFE_ANAL_10   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_10
   pPLAN1_POUR_AFFE_ANAL_11   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_11
   pPLAN1_POUR_AFFE_ANAL_12   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_12
   pPLAN1_POUR_AFFE_ANAL_13   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_13
   pPLAN1_POUR_AFFE_ANAL_14   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_14
   pPLAN1_POUR_AFFE_ANAL_15   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_15
   pPLAN1_POUR_AFFE_ANAL_16   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_16
   pPLAN1_POUR_AFFE_ANAL_17   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_17
   pPLAN1_POUR_AFFE_ANAL_18   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_18
   pPLAN1_POUR_AFFE_ANAL_19   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_19
   pPLAN1_POUR_AFFE_ANAL_20   in varchar2,             -- GEAV_PLAN1_POUR_AFFE_ANAL_20
   pPLAN2_CODE_ANAL_01        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_01
   pPLAN2_CODE_ANAL_02        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_02
   pPLAN2_CODE_ANAL_03        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_03
   pPLAN2_CODE_ANAL_04        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_04
   pPLAN2_CODE_ANAL_05        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_05
   pPLAN2_CODE_ANAL_06        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_06
   pPLAN2_CODE_ANAL_07        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_07
   pPLAN2_CODE_ANAL_08        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_08
   pPLAN2_CODE_ANAL_09        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_09
   pPLAN2_CODE_ANAL_10        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_10
   pPLAN2_CODE_ANAL_11        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_11
   pPLAN2_CODE_ANAL_12        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_12
   pPLAN2_CODE_ANAL_13        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_13
   pPLAN2_CODE_ANAL_14        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_14
   pPLAN2_CODE_ANAL_15        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_15
   pPLAN2_CODE_ANAL_16        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_16
   pPLAN2_CODE_ANAL_17        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_17
   pPLAN2_CODE_ANAL_18        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_18
   pPLAN2_CODE_ANAL_19        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_19
   pPLAN2_CODE_ANAL_20        in varchar2,             -- GEAV_PLAN2_CODE_ANAL_20
   pPLAN2_POUR_AFFE_ANAL_01   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_01
   pPLAN2_POUR_AFFE_ANAL_02   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_02
   pPLAN2_POUR_AFFE_ANAL_03   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_03
   pPLAN2_POUR_AFFE_ANAL_04   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_04
   pPLAN2_POUR_AFFE_ANAL_05   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_05
   pPLAN2_POUR_AFFE_ANAL_06   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_06
   pPLAN2_POUR_AFFE_ANAL_07   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_07
   pPLAN2_POUR_AFFE_ANAL_08   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_08
   pPLAN2_POUR_AFFE_ANAL_09   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_09
   pPLAN2_POUR_AFFE_ANAL_10   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_10
   pPLAN2_POUR_AFFE_ANAL_11   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_11
   pPLAN2_POUR_AFFE_ANAL_12   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_12
   pPLAN2_POUR_AFFE_ANAL_13   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_13
   pPLAN2_POUR_AFFE_ANAL_14   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_14
   pPLAN2_POUR_AFFE_ANAL_15   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_15
   pPLAN2_POUR_AFFE_ANAL_16   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_16
   pPLAN2_POUR_AFFE_ANAL_17   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_17
   pPLAN2_POUR_AFFE_ANAL_18   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_18
   pPLAN2_POUR_AFFE_ANAL_19   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_19
   pPLAN2_POUR_AFFE_ANAL_20   in varchar2,             -- GEAV_PLAN2_POUR_AFFE_ANAL_20
   pPLAN3_CODE_ANAL_01        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_01
   pPLAN3_CODE_ANAL_02        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_02
   pPLAN3_CODE_ANAL_03        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_03
   pPLAN3_CODE_ANAL_04        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_04
   pPLAN3_CODE_ANAL_05        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_05
   pPLAN3_CODE_ANAL_06        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_06
   pPLAN3_CODE_ANAL_07        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_07
   pPLAN3_CODE_ANAL_08        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_08
   pPLAN3_CODE_ANAL_09        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_09
   pPLAN3_CODE_ANAL_10        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_10
   pPLAN3_CODE_ANAL_11        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_11
   pPLAN3_CODE_ANAL_12        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_12
   pPLAN3_CODE_ANAL_13        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_13
   pPLAN3_CODE_ANAL_14        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_14
   pPLAN3_CODE_ANAL_15        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_15
   pPLAN3_CODE_ANAL_16        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_16
   pPLAN3_CODE_ANAL_17        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_17
   pPLAN3_CODE_ANAL_18        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_18
   pPLAN3_CODE_ANAL_19        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_19
   pPLAN3_CODE_ANAL_20        in varchar2,             -- GEAV_PLAN3_CODE_ANAL_20
   pPLAN3_POUR_AFFE_ANAL_01   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_01
   pPLAN3_POUR_AFFE_ANAL_02   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_02
   pPLAN3_POUR_AFFE_ANAL_03   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_03
   pPLAN3_POUR_AFFE_ANAL_04   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_04
   pPLAN3_POUR_AFFE_ANAL_05   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_05
   pPLAN3_POUR_AFFE_ANAL_06   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_06
   pPLAN3_POUR_AFFE_ANAL_07   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_07
   pPLAN3_POUR_AFFE_ANAL_08   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_08
   pPLAN3_POUR_AFFE_ANAL_09   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_09
   pPLAN3_POUR_AFFE_ANAL_10   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_10
   pPLAN3_POUR_AFFE_ANAL_11   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_11
   pPLAN3_POUR_AFFE_ANAL_12   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_12
   pPLAN3_POUR_AFFE_ANAL_13   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_13
   pPLAN3_POUR_AFFE_ANAL_14   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_14
   pPLAN3_POUR_AFFE_ANAL_15   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_15
   pPLAN3_POUR_AFFE_ANAL_16   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_16
   pPLAN3_POUR_AFFE_ANAL_17   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_17
   pPLAN3_POUR_AFFE_ANAL_18   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_18
   pPLAN3_POUR_AFFE_ANAL_19   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_19
   pPLAN3_POUR_AFFE_ANAL_20   in varchar2,             -- GEAV_PLAN3_POUR_AFFE_ANAL_20
   pPLAN4_CODE_ANAL_01        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_01
   pPLAN4_CODE_ANAL_02        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_02
   pPLAN4_CODE_ANAL_03        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_03
   pPLAN4_CODE_ANAL_04        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_04
   pPLAN4_CODE_ANAL_05        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_05
   pPLAN4_CODE_ANAL_06        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_06
   pPLAN4_CODE_ANAL_07        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_07
   pPLAN4_CODE_ANAL_08        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_08
   pPLAN4_CODE_ANAL_09        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_09
   pPLAN4_CODE_ANAL_10        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_10
   pPLAN4_CODE_ANAL_11        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_11
   pPLAN4_CODE_ANAL_12        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_12
   pPLAN4_CODE_ANAL_13        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_13
   pPLAN4_CODE_ANAL_14        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_14
   pPLAN4_CODE_ANAL_15        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_15
   pPLAN4_CODE_ANAL_16        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_16
   pPLAN4_CODE_ANAL_17        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_17
   pPLAN4_CODE_ANAL_18        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_18
   pPLAN4_CODE_ANAL_19        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_19
   pPLAN4_CODE_ANAL_20        in varchar2,             -- GEAV_PLAN4_CODE_ANAL_20
   pPLAN4_POUR_AFFE_ANAL_01   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_01
   pPLAN4_POUR_AFFE_ANAL_02   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_02
   pPLAN4_POUR_AFFE_ANAL_03   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_03
   pPLAN4_POUR_AFFE_ANAL_04   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_04
   pPLAN4_POUR_AFFE_ANAL_05   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_05
   pPLAN4_POUR_AFFE_ANAL_06   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_06
   pPLAN4_POUR_AFFE_ANAL_07   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_07
   pPLAN4_POUR_AFFE_ANAL_08   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_08
   pPLAN4_POUR_AFFE_ANAL_09   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_09
   pPLAN4_POUR_AFFE_ANAL_10   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_10
   pPLAN4_POUR_AFFE_ANAL_11   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_11
   pPLAN4_POUR_AFFE_ANAL_12   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_12
   pPLAN4_POUR_AFFE_ANAL_13   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_13
   pPLAN4_POUR_AFFE_ANAL_14   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_14
   pPLAN4_POUR_AFFE_ANAL_15   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_15
   pPLAN4_POUR_AFFE_ANAL_16   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_16
   pPLAN4_POUR_AFFE_ANAL_17   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_17
   pPLAN4_POUR_AFFE_ANAL_18   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_18
   pPLAN4_POUR_AFFE_ANAL_19   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_19
   pPLAN4_POUR_AFFE_ANAL_20   in varchar2,             -- GEAV_PLAN4_POUR_AFFE_ANAL_20
   pPLAN5_CODE_ANAL_01        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_01
   pPLAN5_CODE_ANAL_02        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_02
   pPLAN5_CODE_ANAL_03        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_03
   pPLAN5_CODE_ANAL_04        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_04
   pPLAN5_CODE_ANAL_05        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_05
   pPLAN5_CODE_ANAL_06        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_06
   pPLAN5_CODE_ANAL_07        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_07
   pPLAN5_CODE_ANAL_08        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_08
   pPLAN5_CODE_ANAL_09        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_09
   pPLAN5_CODE_ANAL_10        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_10
   pPLAN5_CODE_ANAL_11        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_11
   pPLAN5_CODE_ANAL_12        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_12
   pPLAN5_CODE_ANAL_13        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_13
   pPLAN5_CODE_ANAL_14        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_14
   pPLAN5_CODE_ANAL_15        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_15
   pPLAN5_CODE_ANAL_16        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_16
   pPLAN5_CODE_ANAL_17        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_17
   pPLAN5_CODE_ANAL_18        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_18
   pPLAN5_CODE_ANAL_19        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_19
   pPLAN5_CODE_ANAL_20        in varchar2,             -- GEAV_PLAN5_CODE_ANAL_20
   pPLAN5_POUR_AFFE_ANAL_01   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_01
   pPLAN5_POUR_AFFE_ANAL_02   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_02
   pPLAN5_POUR_AFFE_ANAL_03   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_03
   pPLAN5_POUR_AFFE_ANAL_04   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_04
   pPLAN5_POUR_AFFE_ANAL_05   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_05
   pPLAN5_POUR_AFFE_ANAL_06   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_06
   pPLAN5_POUR_AFFE_ANAL_07   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_07
   pPLAN5_POUR_AFFE_ANAL_08   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_08
   pPLAN5_POUR_AFFE_ANAL_09   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_09
   pPLAN5_POUR_AFFE_ANAL_10   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_10
   pPLAN5_POUR_AFFE_ANAL_11   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_11
   pPLAN5_POUR_AFFE_ANAL_12   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_12
   pPLAN5_POUR_AFFE_ANAL_13   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_13
   pPLAN5_POUR_AFFE_ANAL_14   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_14
   pPLAN5_POUR_AFFE_ANAL_15   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_15
   pPLAN5_POUR_AFFE_ANAL_16   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_16
   pPLAN5_POUR_AFFE_ANAL_17   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_17
   pPLAN5_POUR_AFFE_ANAL_18   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_18
   pPLAN5_POUR_AFFE_ANAL_19   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_19
   pPLAN5_POUR_AFFE_ANAL_20   in varchar2,             -- GEAV_PLAN5_POUR_AFFE_ANAL_20
   pSITU_FAMI                 in varchar2,             -- GEAV_SITU_FAMI
   pBULL_MODE                 in varchar2,             -- GEAV_BULL_MODE
   pPROFIL_PAYE_CP            in varchar2,             -- GEAV_PROFIL_PAYE_CP
   pPROFIL_PAYE_RTT           in varchar2,             -- GEAV_PROFIL_PAYE_RTT
   pPROFIL_PAYE_DIF           in varchar2,             -- GEAV_PROFIL_PAYE_DIF
   pPROFIL_PAYE_PROV_CET      in varchar2,             -- GEAV_PROFIL_PAYE_PROV_CET
   pPROFIL_PAYE_PROV_INTE     in varchar2,             -- GEAV_PROFIL_PAYE_PROV_INTE
   pPROFIL_PAYE_PROV_PART     in varchar2,             -- GEAV_PROFIL_PAYE_PROV_PART
   pPROFIL_PAYE_13MO          in varchar2,             -- GEAV_PROFIL_PAYE_13MO
   pPROFIL_PAYE_14MO          in varchar2,             -- GEAV_PROFIL_PAYE_14MO
   pPROF_15MO                 in varchar2,             -- GEAV_PROF_15MO
   pPROFIL_PAYE_PRIM_VACA_01  in varchar2,             -- GEAV_PROFIL_PAYE_PRIM_VACA_01
   pPROFIL_PAYE_PRIM_VACA_02  in varchar2,             -- GEAV_PROFIL_PAYE_PRIM_VACA_02
   pPROFIL_PAYE_HS_CONV       in varchar2,             -- GEAV_PROFIL_PAYE_HS_CONV
   pPROFIL_PAYE_HEUR_EQUI     in varchar2,             -- GEAV_PROFIL_PAYE_HEUR_EQUI
   pPROFIL_PAYE_DECA_FISC     in varchar2,             -- GEAV_PROFIL_PAYE_DECA_FISC
   pPROFIL_PAYE_TEPA          in varchar2,             -- GEAV_PROFIL_PAYE_TEPA
   pPROFIL_PAYE_AFFI_BULL     in varchar2,             -- GEAV_PROFIL_PAYE_AFFI_BULL
   pPROFIL_PAYE_FORF          in varchar2,             -- GEAV_PROFIL_PAYE_FORF
   pPROFIL_PAYE_DEPA          in varchar2,             -- GEAV_PROFIL_PAYE_DEPA
   pPROFIL_PAYE_REIN_FRAI     in varchar2,             -- GEAV_PROFIL_PAYE_REIN_FRAI
   pPROFIL_PAYE_NDF           in varchar2,             -- GEAV_PROFIL_PAYE_NDF
   pPROFIL_PAYE_ACCE_SALA     in varchar2,             -- GEAV_PROFIL_PAYE_ACCE_SALA
   pPROFIL_PAYE_PLAN          in varchar2,             -- GEAV_PROFIL_PAYE_PLAN
   pPROFIL_PAYE_TELE_TRAV     in varchar2,             -- GEAV_PROFIL_PAYE_TELE_TRAV
   pIDCC_HEUR_EQUI            in varchar2,             -- GEAV_IDCC_HEUR_EQUI
   pCIPDZ_CODE                in varchar2,             -- GEAV_CIPDZ_CODE
   pCIPDZ_LIBE                in varchar2,             -- GEAV_CIPDZ_LIBE
   pNUME_CONG_SPEC            in varchar2,             -- GEAV_NUME_CONG_SPEC
   pGROU_COMP                 in varchar2,             -- GEAV_GROU_COMP
   pCHAM_UTIL_1               in varchar2,             -- CHAM_UTIL_1
   pCHAM_UTIL_2               in varchar2,             -- CHAM_UTIL_2
   pCHAM_UTIL_3               in varchar2,             -- CHAM_UTIL_3
   pCHAM_UTIL_4               in varchar2,             -- CHAM_UTIL_4
   pCHAM_UTIL_5               in varchar2,             -- CHAM_UTIL_5
   pCHAM_UTIL_6               in varchar2,             -- CHAM_UTIL_6
   pCHAM_UTIL_7               in varchar2,             -- CHAM_UTIL_7
   pCHAM_UTIL_8               in varchar2,             -- CHAM_UTIL_8
   pCHAM_UTIL_9               in varchar2,             -- CHAM_UTIL_9
   pCHAM_UTIL_10              in varchar2,             -- CHAM_UTIL_10
   pCHAM_UTIL_11              in varchar2,             -- CHAM_UTIL_11
   pCHAM_UTIL_12              in varchar2,             -- CHAM_UTIL_12
   pCHAM_UTIL_13              in varchar2,             -- CHAM_UTIL_13
   pCHAM_UTIL_14              in varchar2,             -- CHAM_UTIL_14
   pCHAM_UTIL_15              in varchar2,             -- CHAM_UTIL_15
   pCHAM_UTIL_16              in varchar2,             -- CHAM_UTIL_16
   pCHAM_UTIL_17              in varchar2,             -- CHAM_UTIL_17
   pCHAM_UTIL_18              in varchar2,             -- CHAM_UTIL_18
   pCHAM_UTIL_19              in varchar2,             -- CHAM_UTIL_19
   pCHAM_UTIL_20              in varchar2,             -- CHAM_UTIL_20
   pCHAM_UTIL_21              in varchar2,             -- CHAM_UTIL_21
   pCHAM_UTIL_22              in varchar2,             -- CHAM_UTIL_22
   pCHAM_UTIL_23              in varchar2,             -- CHAM_UTIL_23
   pCHAM_UTIL_24              in varchar2,             -- CHAM_UTIL_24
   pCHAM_UTIL_25              in varchar2,             -- CHAM_UTIL_25
   pCHAM_UTIL_26              in varchar2,             -- CHAM_UTIL_26
   pCHAM_UTIL_27              in varchar2,             -- CHAM_UTIL_27
   pCHAM_UTIL_28              in varchar2,             -- CHAM_UTIL_28
   pCHAM_UTIL_29              in varchar2,             -- CHAM_UTIL_29
   pCHAM_UTIL_30              in varchar2,             -- CHAM_UTIL_30
   pCHAM_UTIL_31              in varchar2,             -- CHAM_UTIL_31
   pCHAM_UTIL_32              in varchar2,             -- CHAM_UTIL_32
   pCHAM_UTIL_33              in varchar2,             -- CHAM_UTIL_33
   pCHAM_UTIL_34              in varchar2,             -- CHAM_UTIL_34
   pCHAM_UTIL_35              in varchar2,             -- CHAM_UTIL_35
   pCHAM_UTIL_36              in varchar2,             -- CHAM_UTIL_36
   pCHAM_UTIL_37              in varchar2,             -- CHAM_UTIL_37
   pCHAM_UTIL_38              in varchar2,             -- CHAM_UTIL_38
   pCHAM_UTIL_39              in varchar2,             -- CHAM_UTIL_39
   pCHAM_UTIL_40              in varchar2,             -- CHAM_UTIL_40
   pCHAM_UTIL_41              in varchar2,             -- CHAM_UTIL_41
   pCHAM_UTIL_42              in varchar2,             -- CHAM_UTIL_42
   pCHAM_UTIL_43              in varchar2,             -- CHAM_UTIL_43
   pCHAM_UTIL_44              in varchar2,             -- CHAM_UTIL_44
   pCHAM_UTIL_45              in varchar2,             -- CHAM_UTIL_45
   pCHAM_UTIL_46              in varchar2,             -- CHAM_UTIL_46
   pCHAM_UTIL_47              in varchar2,             -- CHAM_UTIL_47
   pCHAM_UTIL_48              in varchar2,             -- CHAM_UTIL_48
   pCHAM_UTIL_49              in varchar2,             -- CHAM_UTIL_49
   pCHAM_UTIL_50              in varchar2,             -- CHAM_UTIL_50
   pCHAM_UTIL_51              in varchar2,             -- CHAM_UTIL_51
   pCHAM_UTIL_52              in varchar2,             -- CHAM_UTIL_52
   pCHAM_UTIL_53              in varchar2,             -- CHAM_UTIL_53
   pCHAM_UTIL_54              in varchar2,             -- CHAM_UTIL_54
   pCHAM_UTIL_55              in varchar2,             -- CHAM_UTIL_55
   pCHAM_UTIL_56              in varchar2,             -- CHAM_UTIL_56
   pCHAM_UTIL_57              in varchar2,             -- CHAM_UTIL_57
   pCHAM_UTIL_58              in varchar2,             -- CHAM_UTIL_58
   pCHAM_UTIL_59              in varchar2,             -- CHAM_UTIL_59
   pCHAM_UTIL_60              in varchar2,             -- CHAM_UTIL_60
   pCHAM_UTIL_61              in varchar2,             -- CHAM_UTIL_61
   pCHAM_UTIL_62              in varchar2,             -- CHAM_UTIL_62
   pCHAM_UTIL_63              in varchar2,             -- CHAM_UTIL_63
   pCHAM_UTIL_64              in varchar2,             -- CHAM_UTIL_64
   pCHAM_UTIL_65              in varchar2,             -- CHAM_UTIL_65
   pCHAM_UTIL_66              in varchar2,             -- CHAM_UTIL_66
   pCHAM_UTIL_67              in varchar2,             -- CHAM_UTIL_67
   pCHAM_UTIL_68              in varchar2,             -- CHAM_UTIL_68
   pCHAM_UTIL_69              in varchar2,             -- CHAM_UTIL_69
   pCHAM_UTIL_70              in varchar2,             -- CHAM_UTIL_70
   pCHAM_UTIL_71              in varchar2,             -- CHAM_UTIL_71
   pCHAM_UTIL_72              in varchar2,             -- CHAM_UTIL_72
   pCHAM_UTIL_73              in varchar2,             -- CHAM_UTIL_73
   pCHAM_UTIL_74              in varchar2,             -- CHAM_UTIL_74
   pCHAM_UTIL_75              in varchar2,             -- CHAM_UTIL_75
   pCHAM_UTIL_76              in varchar2,             -- CHAM_UTIL_76
   pCHAM_UTIL_77              in varchar2,             -- CHAM_UTIL_77
   pCHAM_UTIL_78              in varchar2,             -- CHAM_UTIL_78
   pCHAM_UTIL_79              in varchar2,             -- CHAM_UTIL_79
   pCHAM_UTIL_80              in varchar2,             -- CHAM_UTIL_80
   pCAIS_COTI_BULL            in varchar2,             -- GEAV_CAIS_COTI_BULL
   pDATE_DERN_VISI_MEDI       in varchar2,             -- GEAV_DATE_DERN_VISI_MEDI
   pSTAT_BOET                 in varchar2,             -- GEAV_STAT_BOET
   pDATE_EXPI                 in varchar2,             -- GEAV_DATE_EXPI
   pNUME_CART_SEJO            in varchar2,             -- GEAV_NUME_CART_SEJO
   pNUME_CART_TRAV            in varchar2,             -- GEAV_NUME_CART_TRAV
   pDATE_DELI_TRAV            in varchar2,             -- GEAV_DATE_DELI_TRAV
   pDATE_EXPI_TRAV            in varchar2,             -- GEAV_DATE_EXPI_TRAV
   pDATE_DEMA_AUTO_TRAV       in varchar2,             -- GEAV_DATE_DEMA_AUTO_TRAV
   pID_PREF                   in varchar2,             -- GEAV_ID_PREF
   pDATE_EXPI_DISP_MUTU       in varchar2,             -- GEAV_DATE_EXPI_DISP_MUTU
   pID_MOTI_DISP_MUTU         in varchar2,             -- GEAV_ID_MOTI_DISP_MUTU
   pDATE_PROC_VISI_MEDI       in varchar2,             -- GEAV_DATE_PROC_VISI_MEDI
   pEQUI                      in varchar2,             -- GEAV_EQUI
   pNATI                      in varchar2,             -- GEAV_NATI
   pMOTI_VISI_MEDI            in varchar2,             -- GEAV_MOTI_VISI_MEDI
   pTYPE_SALA                 in varchar2,             -- GEAV_TYPE_SALA
   pNATU_CONT                 in varchar2,             -- GEAV_NATU_CONT
   pNUME_CONT                 in varchar2,             -- GEAV_NUME_CONT
   pLIBE_MOTI_RECR_CDD        in varchar2,             -- GEAV_LIBE_MOTI_RECR_CDD
   pLIBE_MOTI_RECR_CDD2       in varchar2,             -- GEAV_LIBE_MOTI_RECR_CDD2
   pLIBE_MOTI_RECR_CDD3       in varchar2,             -- GEAV_LIBE_MOTI_RECR_CDD3
   pDATE_DEBU_CONT            in varchar2,             -- GEAV_DATE_DEBU_CONT
   pDATE_FIN_CONT             in varchar2,             -- GEAV_DATE_FIN_CONT
   pNOMB_ENFA                 in varchar2,             -- GEAV_NOMB_ENFA
   pCOMM_VENT_N               in varchar2,             -- GEAV_COMM_VENT_N
   pCOMM_VENT_N1              in varchar2,             -- GEAV_COMM_VENT_N1
   pPRIM_OBJE_N               in varchar2,             -- GEAV_PRIM_OBJE_N
   pPRIM_OBJE_N1              in varchar2,             -- GEAV_PRIM_OBJE_N1
   pDADS_INSE_EMPL            in varchar2,             -- GEAV_DADS_INSE_EMPL
   pSAIS                      in varchar2,             -- GEAV_SAIS
   pMATR_GROU                 in varchar2,             -- GEAV_MATR_GROU
   pMATR_RESP_HIER            in varchar2,             -- GEAV_MATR_RESP_HIER
   pDATE_ANCI_PROF            in varchar2,             -- GEAV_DATE_ANCI_PROF
   pDATE_REFE_01              in varchar2,             --
   pDATE_REFE_02              in varchar2,             --
   pDATE_REFE_03              in varchar2,             --
   pDATE_REFE_04              in varchar2,             --
   pDATE_REFE_05              in varchar2,             --
   pDATE_SIGN_CONV_STAG       in varchar2,             -- GEAV_DATE_SIGN_CONV_STAG
   pNIVE_QUAL                 in varchar2,             -- GEAV_NIVE_QUAL
   pMOTI_DEPA                 in varchar2,             -- GEAV_MOTI_DEPA
   pMOTI_AUGM                 in varchar2,             -- GEAV_MOTI_AUGM
   pSEXE                      in varchar2,             -- GEAV_SEXE
   pADRE                      in varchar2,             -- GEAV_ADRE
   pDERN_ADRE                 in varchar2,             -- GEAV_DERN_ADRE
   pADRE_COMP                 in varchar2,             -- GEAV_ADRE_COMP
   pDERN_ADRE_COMP            in varchar2,             -- GEAV_DERN_ADRE_COMP
   pADRE_COMM                 in varchar2,             -- GEAV_ADRE_COMM
   pDERN_ADRE_COMM            in varchar2,             -- GEAV_DERN_ADRE_COMM
   pADRE_CODE_POST            in varchar2,             -- GEAV_ADRE_CODE_POST
   pDERN_ADRE_CODE_POST       in varchar2,             -- GEAV_DERN_ADRE_CODE_POST
   pADRE_PAYS                 in varchar2,             -- GEAV_ADRE_PAYS
   pDIVI                      in varchar2,             -- GEAV_DIVI
   pREGR                      in varchar2,             -- GEAV_REGR
   pDATE_ACCI_TRAV            in varchar2,             -- GEAV_DATE_ACCI_TRAV
   pTRAV_HAND                 in varchar2,             -- GEAV_TRAV_HAND
   pDATE_DEBU_COTO            in varchar2,             -- GEAV_DATE_DEBU_COTO
   pDATE_FIN_COTO             in varchar2,             -- GEAV_DATE_FIN_COTO
   pINVA                      in varchar2,             -- GEAV_INVA
   pTAUX_INVA                 in varchar2,             -- GEAV_TAUX_INVA
   pADRE_MAIL                 in varchar2,             -- GEAV_ADRE_MAIL
   pADRE_MAIL_PERS            in varchar2,             -- GEAV_ADRE_MAIL_PERS
   pMAIL_SALA_CONG            in varchar2,             -- GEAV_MAIL_SALA_CONG
   pRESP_HIER_1_NOM           in varchar2,             -- GEAV_RESP_HIER_1_NOM    ATTENTION: RESPONSABLE HIERARCHIQUE ABSENCE
   pRESP_HIER_1_MAIL          in varchar2,             -- GEAV_RESP_HIER_1_MAIL   ATTENTION: RESPONSABLE HIERARCHIQUE ABSENCE
   pRESP_HIER_2_NOM           in varchar2,             -- GEAV_RESP_HIER_2_NOM    ATTENTION: RESPONSABLE HIERARCHIQUE ABSENCE DELEGUE
   pRESP_HIER_2_MAIL          in varchar2,             -- GEAV_RESP_HIER_2_MAIL   ATTENTION: RESPONSABLE HIERARCHIQUE ABSENCE DELEGUE
   pHIER_RESP_1_NOM           in varchar2,             -- GEAV_RESP_HIER_1_NOM    RESPONSABLE HIERARCHIQUE REEL
   pHIER_RESP_2_NOM           in varchar2,             -- GEAV_RESP_HIER_2_NOM    RESPONSABLE HIERARCHIQUE SECONDAIRE REEL
   pFILI_CONV                 in varchar2,             -- GEAV_FILI_CONV
   pRIB_MODE_PAIE             in varchar2,             -- GEAV_RIB_MODE_PAIE
   pRIB_BANQ_1                in varchar2,             -- GEAV_RIB_BANQ_1
   pRIB_DOMI_1                in varchar2,             -- GEAV_RIB_DOMI_1
   pRIB_NUME_1                in varchar2,             -- GEAV_RIB_NUME_1
   pRIB_TITU_COMP_1           in varchar2,             -- GEAV_RIB_TITU_COMP_1
   pRIB_BANQ_2                in varchar2,             -- GEAV_RIB_BANQ_2
   pRIB_DOMI_2                in varchar2,             -- GEAV_RIB_DOMI_2
   pRIB_NUME_2                in varchar2,             -- GEAV_RIB_NUME_2
   pRIB_TITU_COMP_2           in varchar2,             -- GEAV_RIB_TITU_COMP_2
   pTELE_1                    in varchar2,             -- GEAV_TELE_1
   pTELE_2                    in varchar2,             -- GEAV_TELE_2
   pTELE_3                    in varchar2,             -- GEAV_TELE_3
   pPRIM_OBJE_SOCI_N          in varchar2,             -- GEAV_PRIM_OBJE_SOCI_N
   pPRIM_OBJE_SOCI_N1         in varchar2,             -- GEAV_PRIM_OBJE_SOCI_N1
   pPRIM_OBJE_GLOB_N          in varchar2,             -- GEAV_PRIM_OBJE_GLOB_N
   pETP_CCN51                 in varchar2,             -- GEAV_ETP_CCN51
   pCCN51_COEF_ACCA           in varchar2,             -- GEAV_CCN51_COEF_ACCA
   pCCN51_COEF_DIPL           in varchar2,             -- GEAV_CCN51_COEF_DIPL
   pCCN51_COEF_ENCA           in varchar2,             -- GEAV_CCN51_COEF_ENCA
   pCCN51_COEF_FONC           in varchar2,             -- GEAV_CCN51_COEF_FONC
   pCCN51_COEF_METI           in varchar2,             -- GEAV_CCN51_COEF_METI
   pCCN51_COEF_RECL           in varchar2,             -- GEAV_CCN51_COEF_RECL
   pCCN5166_COEF_REFE         in varchar2,             -- GEAV_CCN5166_COEF_REFE
   pCCN51_COEF_SPEC           in varchar2,             -- GEAV_CCN51_COEF_SPEC
   pCCN51_ID_EMPL_CONV        in varchar2,             -- GEAV_CCN51_ID_EMPL_CONV
   pCCN51_ANCI_DATE_CHAN_APPL in varchar2,             -- GEAV_CCN51_ANCI_DATE_CHAN_APPL
   pCCN51_ANCI_TAUX           in varchar2,             -- GEAV_CCN51_ANCI_TAUX
   pCCN51_CADR_DATE_CHAN_APPL in varchar2,             -- GEAV_CCN51_CADR_DATE_CHAN_APPL
   pCCN51_CADR_TAUX           in varchar2,             -- GEAV_CCN51_CADR_TAUX
   pCCN66_CATE_CONV           in varchar2,             -- GEAV_CCN66_CATE_CONV
   pCCN66_DATE_CHAN_COEF      in varchar2,             -- GEAV_CCN66_DATE_CHAN_COEF
   pCCN66_EMPL_CONV           in varchar2,             -- GEAV_CCN66_EMPL_CONV
   pCCN66_LIBE_EMPL_CONV      in varchar2,             -- GEAV_CCN66_LIBE_EMPL_CONV
   pCCN66_FILI_CONV           in varchar2,             -- GEAV_CCN66_FILI_CONV
   pCCN66_PREC_DATE_CHAN_COEF in varchar2,             -- GEAV_CCN66_PREC_DATE_CHAN_COEF
   pCCN66_PROC_COEF_REFE      in varchar2,             -- GEAV_CCN66_PROC_COEF_REFE
   pCCN66_REGI                in varchar2,             -- GEAV_CCN66_REGI
   pCALC_AUTO_INDE_CONG_PREC  in varchar2,             -- GEAV_CALC_AUTO_INDE_CONG_PREC
   pLIBE_RUBR_01              in varchar2,             -- GEAV_LIBE_RUBR_01
   pLIBE_RUBR_02              in varchar2,             -- GEAV_LIBE_RUBR_02
   pLIBE_RUBR_03              in varchar2,             -- GEAV_LIBE_RUBR_03
   pLIBE_RUBR_04              in varchar2,             -- GEAV_LIBE_RUBR_04
   pLIBE_RUBR_05              in varchar2,             -- GEAV_LIBE_RUBR_05
   pLIBE_RUBR_06              in varchar2,             -- GEAV_LIBE_RUBR_06
   pLIBE_RUBR_07              in varchar2,             -- GEAV_LIBE_RUBR_07
   pLIBE_RUBR_08              in varchar2,             -- GEAV_LIBE_RUBR_08
   pLIBE_RUBR_09              in varchar2,             -- GEAV_LIBE_RUBR_09
   pLIBE_RUBR_10              in varchar2,             -- GEAV_LIBE_RUBR_10
   pLIBE_RUBR_11              in varchar2,             -- GEAV_LIBE_RUBR_11
   pLIBE_RUBR_12              in varchar2,             -- GEAV_LIBE_RUBR_12
   pLIBE_RUBR_13              in varchar2,             -- GEAV_LIBE_RUBR_13
   pLIBE_RUBR_14              in varchar2,             -- GEAV_LIBE_RUBR_14
   pLIBE_RUBR_15              in varchar2,             -- GEAV_LIBE_RUBR_15
   pLIBE_RUBR_16              in varchar2,             -- GEAV_LIBE_RUBR_16
   pLIBE_RUBR_17              in varchar2,             -- GEAV_LIBE_RUBR_17
   pLIBE_RUBR_18              in varchar2,             -- GEAV_LIBE_RUBR_18
   pLIBE_RUBR_19              in varchar2,             -- GEAV_LIBE_RUBR_19
   pLIBE_RUBR_20              in varchar2,             -- GEAV_LIBE_RUBR_20
   pLIBE_RUBR_21              in varchar2,             -- GEAV_LIBE_RUBR_21
   pLIBE_RUBR_22              in varchar2,             -- GEAV_LIBE_RUBR_22
   pLIBE_RUBR_23              in varchar2,             -- GEAV_LIBE_RUBR_23
   pLIBE_RUBR_24              in varchar2,             -- GEAV_LIBE_RUBR_24
   pLIBE_RUBR_25              in varchar2,             -- GEAV_LIBE_RUBR_25
   pLIBE_RUBR_26              in varchar2,             -- GEAV_LIBE_RUBR_26
   pLIBE_RUBR_27              in varchar2,             -- GEAV_LIBE_RUBR_27
   pLIBE_RUBR_28              in varchar2,             -- GEAV_LIBE_RUBR_28
   pLIBE_RUBR_29              in varchar2,             -- GEAV_LIBE_RUBR_29
   pLIBE_RUBR_30              in varchar2,             -- GEAV_LIBE_RUBR_30
   pLIBE_RUBR_31              in varchar2,             -- GEAV_LIBE_RUBR_31
   pLIBE_RUBR_32              in varchar2,             -- GEAV_LIBE_RUBR_32
   pLIBE_RUBR_33              in varchar2,             -- GEAV_LIBE_RUBR_33
   pLIBE_RUBR_34              in varchar2,             -- GEAV_LIBE_RUBR_34
   pLIBE_RUBR_35              in varchar2,             -- GEAV_LIBE_RUBR_35
   pLIBE_RUBR_36              in varchar2,             -- GEAV_LIBE_RUBR_36
   pLIBE_RUBR_37              in varchar2,             -- GEAV_LIBE_RUBR_37
   pLIBE_RUBR_38              in varchar2,             -- GEAV_LIBE_RUBR_38
   pLIBE_RUBR_39              in varchar2,             -- GEAV_LIBE_RUBR_39
   pLIBE_RUBR_40              in varchar2,             -- GEAV_LIBE_RUBR_40
   pLIBE_RUBR_41              in varchar2,             -- GEAV_LIBE_RUBR_41
   pLIBE_RUBR_42              in varchar2,             -- GEAV_LIBE_RUBR_42
   pLIBE_RUBR_43              in varchar2,             -- GEAV_LIBE_RUBR_43
   pLIBE_RUBR_44              in varchar2,             -- GEAV_LIBE_RUBR_44
   pLIBE_RUBR_45              in varchar2,             -- GEAV_LIBE_RUBR_45
   pLIBE_RUBR_46              in varchar2,             -- GEAV_LIBE_RUBR_46
   pLIBE_RUBR_47              in varchar2,             -- GEAV_LIBE_RUBR_47
   pLIBE_RUBR_48              in varchar2,             -- GEAV_LIBE_RUBR_48
   pLIBE_RUBR_49              in varchar2,             -- GEAV_LIBE_RUBR_49
   pLIBE_RUBR_50              in varchar2,             -- GEAV_LIBE_RUBR_50

   pLIBE_RUBR_51              in varchar2,             -- GEAV_LIBE_RUBR_51
   pLIBE_RUBR_52              in varchar2,             -- GEAV_LIBE_RUBR_52
   pLIBE_RUBR_53              in varchar2,             -- GEAV_LIBE_RUBR_53
   pLIBE_RUBR_54              in varchar2,             -- GEAV_LIBE_RUBR_54
   pLIBE_RUBR_55              in varchar2,             -- GEAV_LIBE_RUBR_55
   pLIBE_RUBR_56              in varchar2,             -- GEAV_LIBE_RUBR_56
   pLIBE_RUBR_57              in varchar2,             -- GEAV_LIBE_RUBR_57
   pLIBE_RUBR_58              in varchar2,             -- GEAV_LIBE_RUBR_58
   pLIBE_RUBR_59              in varchar2,             -- GEAV_LIBE_RUBR_59
   pLIBE_RUBR_60              in varchar2,             -- GEAV_LIBE_RUBR_60
   pLIBE_RUBR_61              in varchar2,             -- GEAV_LIBE_RUBR_61
   pLIBE_RUBR_62              in varchar2,             -- GEAV_LIBE_RUBR_62
   pLIBE_RUBR_63              in varchar2,             -- GEAV_LIBE_RUBR_63
   pLIBE_RUBR_64              in varchar2,             -- GEAV_LIBE_RUBR_64
   pLIBE_RUBR_65              in varchar2,             -- GEAV_LIBE_RUBR_65
   pLIBE_RUBR_66              in varchar2,             -- GEAV_LIBE_RUBR_66
   pLIBE_RUBR_67              in varchar2,             -- GEAV_LIBE_RUBR_67
   pLIBE_RUBR_68              in varchar2,             -- GEAV_LIBE_RUBR_68
   pLIBE_RUBR_69              in varchar2,             -- GEAV_LIBE_RUBR_69
   pLIBE_RUBR_70              in varchar2,             -- GEAV_LIBE_RUBR_70
   pLIBE_RUBR_71              in varchar2,             -- GEAV_LIBE_RUBR_71
   pLIBE_RUBR_72              in varchar2,             -- GEAV_LIBE_RUBR_72
   pLIBE_RUBR_73              in varchar2,             -- GEAV_LIBE_RUBR_73
   pLIBE_RUBR_74              in varchar2,             -- GEAV_LIBE_RUBR_74
   pLIBE_RUBR_75              in varchar2,             -- GEAV_LIBE_RUBR_75
   pLIBE_RUBR_76              in varchar2,             -- GEAV_LIBE_RUBR_76
   pLIBE_RUBR_77              in varchar2,             -- GEAV_LIBE_RUBR_77
   pLIBE_RUBR_78              in varchar2,             -- GEAV_LIBE_RUBR_78
   pLIBE_RUBR_79              in varchar2,             -- GEAV_LIBE_RUBR_79
   pLIBE_RUBR_80              in varchar2,             -- GEAV_LIBE_RUBR_80
   pLIBE_RUBR_81              in varchar2,             -- GEAV_LIBE_RUBR_81
   pLIBE_RUBR_82              in varchar2,             -- GEAV_LIBE_RUBR_82
   pLIBE_RUBR_83              in varchar2,             -- GEAV_LIBE_RUBR_83
   pLIBE_RUBR_84              in varchar2,             -- GEAV_LIBE_RUBR_84
   pLIBE_RUBR_85              in varchar2,             -- GEAV_LIBE_RUBR_85
   pLIBE_RUBR_86              in varchar2,             -- GEAV_LIBE_RUBR_86
   pLIBE_RUBR_87              in varchar2,             -- GEAV_LIBE_RUBR_87
   pLIBE_RUBR_88              in varchar2,             -- GEAV_LIBE_RUBR_88
   pLIBE_RUBR_89              in varchar2,             -- GEAV_LIBE_RUBR_89
   pLIBE_RUBR_90              in varchar2,             -- GEAV_LIBE_RUBR_90
   pLIBE_RUBR_91              in varchar2,             -- GEAV_LIBE_RUBR_91
   pLIBE_RUBR_92              in varchar2,             -- GEAV_LIBE_RUBR_92
   pLIBE_RUBR_93              in varchar2,             -- GEAV_LIBE_RUBR_93
   pLIBE_RUBR_94              in varchar2,             -- GEAV_LIBE_RUBR_94
   pLIBE_RUBR_95              in varchar2,             -- GEAV_LIBE_RUBR_95
   pLIBE_RUBR_96              in varchar2,             -- GEAV_LIBE_RUBR_96
   pLIBE_RUBR_97              in varchar2,             -- GEAV_LIBE_RUBR_97
   pLIBE_RUBR_98              in varchar2,             -- GEAV_LIBE_RUBR_98
   pLIBE_RUBR_99              in varchar2,             -- GEAV_LIBE_RUBR_99
   pLIBE_RUBR_100              in varchar2,             -- GEAV_LIBE_RUBR_100
   pLIBE_RUBR_101              in varchar2,             -- GEAV_LIBE_RUBR_101
   pLIBE_RUBR_102              in varchar2,             -- GEAV_LIBE_RUBR_102
   pLIBE_RUBR_103              in varchar2,             -- GEAV_LIBE_RUBR_103
   pLIBE_RUBR_104              in varchar2,             -- GEAV_LIBE_RUBR_104
   pLIBE_RUBR_105              in varchar2,             -- GEAV_LIBE_RUBR_105
   pLIBE_RUBR_106              in varchar2,             -- GEAV_LIBE_RUBR_106
   pLIBE_RUBR_107              in varchar2,             -- GEAV_LIBE_RUBR_107
   pLIBE_RUBR_108              in varchar2,             -- GEAV_LIBE_RUBR_108
   pLIBE_RUBR_109              in varchar2,             -- GEAV_LIBE_RUBR_109
   pLIBE_RUBR_110              in varchar2,             -- GEAV_LIBE_RUBR_110
   pLIBE_RUBR_111              in varchar2,             -- GEAV_LIBE_RUBR_111
   pLIBE_RUBR_112              in varchar2,             -- GEAV_LIBE_RUBR_112
   pLIBE_RUBR_113              in varchar2,             -- GEAV_LIBE_RUBR_113
   pLIBE_RUBR_114              in varchar2,             -- GEAV_LIBE_RUBR_114
   pLIBE_RUBR_115              in varchar2,             -- GEAV_LIBE_RUBR_115
   pLIBE_RUBR_116              in varchar2,             -- GEAV_LIBE_RUBR_116
   pLIBE_RUBR_117              in varchar2,             -- GEAV_LIBE_RUBR_117
   pLIBE_RUBR_118              in varchar2,             -- GEAV_LIBE_RUBR_118
   pLIBE_RUBR_119              in varchar2,             -- GEAV_LIBE_RUBR_119
   pLIBE_RUBR_120              in varchar2,             -- GEAV_LIBE_RUBR_120
   pLIBE_RUBR_121              in varchar2,             -- GEAV_LIBE_RUBR_121
   pLIBE_RUBR_122              in varchar2,             -- GEAV_LIBE_RUBR_122
   pLIBE_RUBR_123              in varchar2,             -- GEAV_LIBE_RUBR_123
   pLIBE_RUBR_124              in varchar2,             -- GEAV_LIBE_RUBR_124
   pLIBE_RUBR_125              in varchar2,             -- GEAV_LIBE_RUBR_125
   pLIBE_RUBR_126              in varchar2,             -- GEAV_LIBE_RUBR_126
   pLIBE_RUBR_127              in varchar2,             -- GEAV_LIBE_RUBR_127
   pLIBE_RUBR_128              in varchar2,             -- GEAV_LIBE_RUBR_128
   pLIBE_RUBR_129              in varchar2,             -- GEAV_LIBE_RUBR_129
   pLIBE_RUBR_130              in varchar2,             -- GEAV_LIBE_RUBR_130
   pLIBE_RUBR_131              in varchar2,             -- GEAV_LIBE_RUBR_131
   pLIBE_RUBR_132              in varchar2,             -- GEAV_LIBE_RUBR_132
   pLIBE_RUBR_133              in varchar2,             -- GEAV_LIBE_RUBR_133
   pLIBE_RUBR_134              in varchar2,             -- GEAV_LIBE_RUBR_134
   pLIBE_RUBR_135              in varchar2,             -- GEAV_LIBE_RUBR_135
   pLIBE_RUBR_136              in varchar2,             -- GEAV_LIBE_RUBR_136
   pLIBE_RUBR_137              in varchar2,             -- GEAV_LIBE_RUBR_137
   pLIBE_RUBR_138              in varchar2,             -- GEAV_LIBE_RUBR_138
   pLIBE_RUBR_139              in varchar2,             -- GEAV_LIBE_RUBR_139
   pLIBE_RUBR_140              in varchar2,             -- GEAV_LIBE_RUBR_140
   pLIBE_RUBR_141              in varchar2,             -- GEAV_LIBE_RUBR_141
   pLIBE_RUBR_142              in varchar2,             -- GEAV_LIBE_RUBR_142
   pLIBE_RUBR_143              in varchar2,             -- GEAV_LIBE_RUBR_143
   pLIBE_RUBR_144              in varchar2,             -- GEAV_LIBE_RUBR_144
   pLIBE_RUBR_145              in varchar2,             -- GEAV_LIBE_RUBR_145
   pLIBE_RUBR_146              in varchar2,             -- GEAV_LIBE_RUBR_146
   pLIBE_RUBR_147              in varchar2,             -- GEAV_LIBE_RUBR_147
   pLIBE_RUBR_148              in varchar2,             -- GEAV_LIBE_RUBR_148
   pLIBE_RUBR_149              in varchar2,             -- GEAV_LIBE_RUBR_149
   pLIBE_RUBR_150              in varchar2,             -- GEAV_LIBE_RUBR_150

   pLIBE_CONS_01              in varchar2,             -- GEAV_LIBE_CONS_01
   pLIBE_CONS_02              in varchar2,             -- GEAV_LIBE_CONS_02
   pLIBE_CONS_03              in varchar2,             -- GEAV_LIBE_CONS_03
   pLIBE_CONS_04              in varchar2,             -- GEAV_LIBE_CONS_04
   pLIBE_CONS_05              in varchar2,             -- GEAV_LIBE_CONS_05
   pLIBE_CONS_06              in varchar2,             -- GEAV_LIBE_CONS_06
   pLIBE_CONS_07              in varchar2,             -- GEAV_LIBE_CONS_07
   pLIBE_CONS_08              in varchar2,             -- GEAV_LIBE_CONS_08
   pLIBE_CONS_09              in varchar2,             -- GEAV_LIBE_CONS_09
   pLIBE_CONS_10              in varchar2,             -- GEAV_LIBE_CONS_10
   pLIBE_CONS_11              in varchar2,             -- GEAV_LIBE_CONS_11
   pLIBE_CONS_12              in varchar2,             -- GEAV_LIBE_CONS_12
   pLIBE_CONS_13              in varchar2,             -- GEAV_LIBE_CONS_13
   pLIBE_CONS_14              in varchar2,             -- GEAV_LIBE_CONS_14
   pLIBE_CONS_15              in varchar2,             -- GEAV_LIBE_CONS_15
   pLIBE_CONS_16              in varchar2,             -- GEAV_LIBE_CONS_16
   pLIBE_CONS_17              in varchar2,             -- GEAV_LIBE_CONS_17
   pLIBE_CONS_18              in varchar2,             -- GEAV_LIBE_CONS_18
   pLIBE_CONS_19              in varchar2,             -- GEAV_LIBE_CONS_19
   pLIBE_CONS_20              in varchar2,             -- GEAV_LIBE_CONS_20

   pLIBE_CONS_21              in varchar2,             -- GEAV_LIBE_CONS_21
   pLIBE_CONS_22              in varchar2,             -- GEAV_LIBE_CONS_22
   pLIBE_CONS_23              in varchar2,             -- GEAV_LIBE_CONS_23
   pLIBE_CONS_24              in varchar2,             -- GEAV_LIBE_CONS_24
   pLIBE_CONS_25              in varchar2,             -- GEAV_LIBE_CONS_25
   pLIBE_CONS_26              in varchar2,             -- GEAV_LIBE_CONS_26
   pLIBE_CONS_27              in varchar2,             -- GEAV_LIBE_CONS_27
   pLIBE_CONS_28              in varchar2,             -- GEAV_LIBE_CONS_28
   pLIBE_CONS_29              in varchar2,             -- GEAV_LIBE_CONS_29
   pLIBE_CONS_30              in varchar2,             -- GEAV_LIBE_CONS_30
   pLIBE_CONS_31              in varchar2,             -- GEAV_LIBE_CONS_31
   pLIBE_CONS_32              in varchar2,             -- GEAV_LIBE_CONS_32
   pLIBE_CONS_33              in varchar2,             -- GEAV_LIBE_CONS_33
   pLIBE_CONS_34              in varchar2,             -- GEAV_LIBE_CONS_34
   pLIBE_CONS_35              in varchar2,             -- GEAV_LIBE_CONS_35
   pLIBE_CONS_36              in varchar2,             -- GEAV_LIBE_CONS_36
   pLIBE_CONS_37              in varchar2,             -- GEAV_LIBE_CONS_37
   pLIBE_CONS_38              in varchar2,             -- GEAV_LIBE_CONS_38
   pLIBE_CONS_39              in varchar2,             -- GEAV_LIBE_CONS_39
   pLIBE_CONS_40              in varchar2,             -- GEAV_LIBE_CONS_40
   pLIBE_CONS_41              in varchar2,             -- GEAV_LIBE_CONS_41
   pLIBE_CONS_42              in varchar2,             -- GEAV_LIBE_CONS_42
   pLIBE_CONS_43              in varchar2,             -- GEAV_LIBE_CONS_43
   pLIBE_CONS_44              in varchar2,             -- GEAV_LIBE_CONS_44
   pLIBE_CONS_45              in varchar2,             -- GEAV_LIBE_CONS_45
   pLIBE_CONS_46              in varchar2,             -- GEAV_LIBE_CONS_46
   pLIBE_CONS_47              in varchar2,             -- GEAV_LIBE_CONS_47
   pLIBE_CONS_48              in varchar2,             -- GEAV_LIBE_CONS_48
   pLIBE_CONS_49              in varchar2,             -- GEAV_LIBE_CONS_49
   pLIBE_CONS_50              in varchar2,             -- GEAV_LIBE_CONS_50

   pCONS_REPA_01              in varchar2,             -- GEAV_CONS_REPA_01
   pCONS_REPA_02              in varchar2,             -- GEAV_CONS_REPA_02
   pCONS_REPA_03              in varchar2,             -- GEAV_CONS_REPA_03
   pCONS_REPA_04              in varchar2,             -- GEAV_CONS_REPA_04
   pCONS_REPA_05              in varchar2,             -- GEAV_CONS_REPA_05
   pCONS_REPA_06              in varchar2,             -- GEAV_CONS_REPA_06
   pCONS_REPA_07              in varchar2,             -- GEAV_CONS_REPA_07
   pCONS_REPA_08              in varchar2,             -- GEAV_CONS_REPA_08
   pCONS_REPA_09              in varchar2,             -- GEAV_CONS_REPA_09
   pCONS_REPA_10              in varchar2,             -- GEAV_CONS_REPA_10
   pCONS_REPA_11              in varchar2,             -- GEAV_CONS_REPA_11
   pCONS_REPA_12              in varchar2,             -- GEAV_CONS_REPA_12
   pCONS_REPA_13              in varchar2,             -- GEAV_CONS_REPA_13
   pCONS_REPA_14              in varchar2,             -- GEAV_CONS_REPA_14
   pCONS_REPA_15              in varchar2,             -- GEAV_CONS_REPA_15
   pCONS_REPA_16              in varchar2,             -- GEAV_CONS_REPA_16
   pCONS_REPA_17              in varchar2,             -- GEAV_CONS_REPA_17
   pCONS_REPA_18              in varchar2,             -- GEAV_CONS_REPA_18
   pCONS_REPA_19              in varchar2,             -- GEAV_CONS_REPA_19
   pCONS_REPA_20              in varchar2,             -- GEAV_CONS_REPA_20

   pCONS_REPA_21              in varchar2,             -- GEAV_CONS_REPA_21
   pCONS_REPA_22              in varchar2,             -- GEAV_CONS_REPA_22
   pCONS_REPA_23              in varchar2,             -- GEAV_CONS_REPA_23
   pCONS_REPA_24              in varchar2,             -- GEAV_CONS_REPA_24
   pCONS_REPA_25              in varchar2,             -- GEAV_CONS_REPA_25
   pCONS_REPA_26              in varchar2,             -- GEAV_CONS_REPA_26
   pCONS_REPA_27              in varchar2,             -- GEAV_CONS_REPA_27
   pCONS_REPA_28              in varchar2,             -- GEAV_CONS_REPA_28
   pCONS_REPA_29              in varchar2,             -- GEAV_CONS_REPA_29
   pCONS_REPA_30              in varchar2,             -- GEAV_CONS_REPA_30
   pCONS_REPA_31              in varchar2,             -- GEAV_CONS_REPA_31
   pCONS_REPA_32              in varchar2,             -- GEAV_CONS_REPA_32
   pCONS_REPA_33              in varchar2,             -- GEAV_CONS_REPA_33
   pCONS_REPA_34              in varchar2,             -- GEAV_CONS_REPA_34
   pCONS_REPA_35              in varchar2,             -- GEAV_CONS_REPA_35
   pCONS_REPA_36              in varchar2,             -- GEAV_CONS_REPA_36
   pCONS_REPA_37              in varchar2,             -- GEAV_CONS_REPA_37
   pCONS_REPA_38              in varchar2,             -- GEAV_CONS_REPA_38
   pCONS_REPA_39              in varchar2,             -- GEAV_CONS_REPA_39
   pCONS_REPA_40              in varchar2,             -- GEAV_CONS_REPA_40
   pCONS_REPA_41              in varchar2,             -- GEAV_CONS_REPA_41
   pCONS_REPA_42              in varchar2,             -- GEAV_CONS_REPA_42
   pCONS_REPA_43              in varchar2,             -- GEAV_CONS_REPA_43
   pCONS_REPA_44              in varchar2,             -- GEAV_CONS_REPA_44
   pCONS_REPA_45              in varchar2,             -- GEAV_CONS_REPA_45
   pCONS_REPA_46              in varchar2,             -- GEAV_CONS_REPA_46
   pCONS_REPA_47              in varchar2,             -- GEAV_CONS_REPA_47
   pCONS_REPA_48              in varchar2,             -- GEAV_CONS_REPA_48
   pCONS_REPA_49              in varchar2,             -- GEAV_CONS_REPA_49
   pCONS_REPA_50              in varchar2,             -- GEAV_CONS_REPA_50

   pID_RUBR_01                in varchar2,             -- GEAV_ID_RUBR_01
   pID_RUBR_02                in varchar2,             -- GEAV_ID_RUBR_02
   pID_RUBR_03                in varchar2,             -- GEAV_ID_RUBR_03
   pID_RUBR_04                in varchar2,             -- GEAV_ID_RUBR_04
   pID_RUBR_05                in varchar2,             -- GEAV_ID_RUBR_05
   pID_RUBR_06                in varchar2,             -- GEAV_ID_RUBR_06
   pID_RUBR_07                in varchar2,             -- GEAV_ID_RUBR_07
   pID_RUBR_08                in varchar2,             -- GEAV_ID_RUBR_08
   pID_RUBR_09                in varchar2,             -- GEAV_ID_RUBR_09
   pID_RUBR_10                in varchar2,             -- GEAV_ID_RUBR_10
   pID_RUBR_11                in varchar2,             -- GEAV_ID_RUBR_11
   pID_RUBR_12                in varchar2,             -- GEAV_ID_RUBR_12
   pID_RUBR_13                in varchar2,             -- GEAV_ID_RUBR_13
   pID_RUBR_14                in varchar2,             -- GEAV_ID_RUBR_14
   pID_RUBR_15                in varchar2,             -- GEAV_ID_RUBR_15
   pID_RUBR_16                in varchar2,             -- GEAV_ID_RUBR_16
   pID_RUBR_17                in varchar2,             -- GEAV_ID_RUBR_17
   pID_RUBR_18                in varchar2,             -- GEAV_ID_RUBR_18
   pID_RUBR_19                in varchar2,             -- GEAV_ID_RUBR_19
   pID_RUBR_20                in varchar2,             -- GEAV_ID_RUBR_20
   pID_RUBR_21                in varchar2,             -- GEAV_ID_RUBR_21
   pID_RUBR_22                in varchar2,             -- GEAV_ID_RUBR_22
   pID_RUBR_23                in varchar2,             -- GEAV_ID_RUBR_23
   pID_RUBR_24                in varchar2,             -- GEAV_ID_RUBR_24
   pID_RUBR_25                in varchar2,             -- GEAV_ID_RUBR_25
   pID_RUBR_26                in varchar2,             -- GEAV_ID_RUBR_26
   pID_RUBR_27                in varchar2,             -- GEAV_ID_RUBR_27
   pID_RUBR_28                in varchar2,             -- GEAV_ID_RUBR_28
   pID_RUBR_29                in varchar2,             -- GEAV_ID_RUBR_29
   pID_RUBR_30                in varchar2,             -- GEAV_ID_RUBR_30
   pID_RUBR_31                in varchar2,             -- GEAV_ID_RUBR_31
   pID_RUBR_32                in varchar2,             -- GEAV_ID_RUBR_32
   pID_RUBR_33                in varchar2,             -- GEAV_ID_RUBR_33
   pID_RUBR_34                in varchar2,             -- GEAV_ID_RUBR_34
   pID_RUBR_35                in varchar2,             -- GEAV_ID_RUBR_35
   pID_RUBR_36                in varchar2,             -- GEAV_ID_RUBR_36
   pID_RUBR_37                in varchar2,             -- GEAV_ID_RUBR_37
   pID_RUBR_38                in varchar2,             -- GEAV_ID_RUBR_38
   pID_RUBR_39                in varchar2,             -- GEAV_ID_RUBR_39
   pID_RUBR_40                in varchar2,             -- GEAV_ID_RUBR_40
   pID_RUBR_41                in varchar2,             -- GEAV_ID_RUBR_41
   pID_RUBR_42                in varchar2,             -- GEAV_ID_RUBR_42
   pID_RUBR_43                in varchar2,             -- GEAV_ID_RUBR_43
   pID_RUBR_44                in varchar2,             -- GEAV_ID_RUBR_44
   pID_RUBR_45                in varchar2,             -- GEAV_ID_RUBR_45
   pID_RUBR_46                in varchar2,             -- GEAV_ID_RUBR_46
   pID_RUBR_47                in varchar2,             -- GEAV_ID_RUBR_47
   pID_RUBR_48                in varchar2,             -- GEAV_ID_RUBR_48
   pID_RUBR_49                in varchar2,             -- GEAV_ID_RUBR_49
   pID_RUBR_50                in varchar2,             -- GEAV_ID_RUBR_50

   pID_RUBR_51                in varchar2,             -- GEAV_ID_RUBR_51
   pID_RUBR_52                in varchar2,             -- GEAV_ID_RUBR_52
   pID_RUBR_53                in varchar2,             -- GEAV_ID_RUBR_53
   pID_RUBR_54                in varchar2,             -- GEAV_ID_RUBR_54
   pID_RUBR_55                in varchar2,             -- GEAV_ID_RUBR_55
   pID_RUBR_56                in varchar2,             -- GEAV_ID_RUBR_56
   pID_RUBR_57                in varchar2,             -- GEAV_ID_RUBR_57
   pID_RUBR_58                in varchar2,             -- GEAV_ID_RUBR_58
   pID_RUBR_59                in varchar2,             -- GEAV_ID_RUBR_59
   pID_RUBR_60                in varchar2,             -- GEAV_ID_RUBR_60
   pID_RUBR_61                in varchar2,             -- GEAV_ID_RUBR_61
   pID_RUBR_62                in varchar2,             -- GEAV_ID_RUBR_62
   pID_RUBR_63                in varchar2,             -- GEAV_ID_RUBR_63
   pID_RUBR_64                in varchar2,             -- GEAV_ID_RUBR_64
   pID_RUBR_65                in varchar2,             -- GEAV_ID_RUBR_65
   pID_RUBR_66                in varchar2,             -- GEAV_ID_RUBR_66
   pID_RUBR_67                in varchar2,             -- GEAV_ID_RUBR_67
   pID_RUBR_68                in varchar2,             -- GEAV_ID_RUBR_68
   pID_RUBR_69                in varchar2,             -- GEAV_ID_RUBR_69
   pID_RUBR_70                in varchar2,             -- GEAV_ID_RUBR_70
   pID_RUBR_71                in varchar2,             -- GEAV_ID_RUBR_71
   pID_RUBR_72                in varchar2,             -- GEAV_ID_RUBR_72
   pID_RUBR_73                in varchar2,             -- GEAV_ID_RUBR_73
   pID_RUBR_74                in varchar2,             -- GEAV_ID_RUBR_74
   pID_RUBR_75                in varchar2,             -- GEAV_ID_RUBR_75
   pID_RUBR_76                in varchar2,             -- GEAV_ID_RUBR_76
   pID_RUBR_77                in varchar2,             -- GEAV_ID_RUBR_77
   pID_RUBR_78                in varchar2,             -- GEAV_ID_RUBR_78
   pID_RUBR_79                in varchar2,             -- GEAV_ID_RUBR_79
   pID_RUBR_80                in varchar2,             -- GEAV_ID_RUBR_80
   pID_RUBR_81                in varchar2,             -- GEAV_ID_RUBR_81
   pID_RUBR_82                in varchar2,             -- GEAV_ID_RUBR_82
   pID_RUBR_83                in varchar2,             -- GEAV_ID_RUBR_83
   pID_RUBR_84                in varchar2,             -- GEAV_ID_RUBR_84
   pID_RUBR_85                in varchar2,             -- GEAV_ID_RUBR_85
   pID_RUBR_86                in varchar2,             -- GEAV_ID_RUBR_86
   pID_RUBR_87                in varchar2,             -- GEAV_ID_RUBR_87
   pID_RUBR_88                in varchar2,             -- GEAV_ID_RUBR_88
   pID_RUBR_89                in varchar2,             -- GEAV_ID_RUBR_89
   pID_RUBR_90                in varchar2,             -- GEAV_ID_RUBR_90
   pID_RUBR_91                in varchar2,             -- GEAV_ID_RUBR_91
   pID_RUBR_92                in varchar2,             -- GEAV_ID_RUBR_92
   pID_RUBR_93                in varchar2,             -- GEAV_ID_RUBR_93
   pID_RUBR_94                in varchar2,             -- GEAV_ID_RUBR_94
   pID_RUBR_95                in varchar2,             -- GEAV_ID_RUBR_95
   pID_RUBR_96                in varchar2,             -- GEAV_ID_RUBR_96
   pID_RUBR_97                in varchar2,             -- GEAV_ID_RUBR_97
   pID_RUBR_98                in varchar2,             -- GEAV_ID_RUBR_98
   pID_RUBR_99                in varchar2,             -- GEAV_ID_RUBR_99
   pID_RUBR_100                in varchar2,             -- GEAV_ID_RUBR_100
   pID_RUBR_101                in varchar2,             -- GEAV_ID_RUBR_101
   pID_RUBR_102                in varchar2,             -- GEAV_ID_RUBR_102
   pID_RUBR_103                in varchar2,             -- GEAV_ID_RUBR_103
   pID_RUBR_104                in varchar2,             -- GEAV_ID_RUBR_104
   pID_RUBR_105                in varchar2,             -- GEAV_ID_RUBR_105
   pID_RUBR_106                in varchar2,             -- GEAV_ID_RUBR_106
   pID_RUBR_107                in varchar2,             -- GEAV_ID_RUBR_107
   pID_RUBR_108                in varchar2,             -- GEAV_ID_RUBR_108
   pID_RUBR_109                in varchar2,             -- GEAV_ID_RUBR_109
   pID_RUBR_110                in varchar2,             -- GEAV_ID_RUBR_110
   pID_RUBR_111                in varchar2,             -- GEAV_ID_RUBR_111
   pID_RUBR_112                in varchar2,             -- GEAV_ID_RUBR_112
   pID_RUBR_113                in varchar2,             -- GEAV_ID_RUBR_113
   pID_RUBR_114                in varchar2,             -- GEAV_ID_RUBR_114
   pID_RUBR_115                in varchar2,             -- GEAV_ID_RUBR_115
   pID_RUBR_116                in varchar2,             -- GEAV_ID_RUBR_116
   pID_RUBR_117                in varchar2,             -- GEAV_ID_RUBR_117
   pID_RUBR_118                in varchar2,             -- GEAV_ID_RUBR_118
   pID_RUBR_119                in varchar2,             -- GEAV_ID_RUBR_119
   pID_RUBR_120                in varchar2,             -- GEAV_ID_RUBR_120
   pID_RUBR_121                in varchar2,             -- GEAV_ID_RUBR_121
   pID_RUBR_122                in varchar2,             -- GEAV_ID_RUBR_122
   pID_RUBR_123                in varchar2,             -- GEAV_ID_RUBR_123
   pID_RUBR_124                in varchar2,             -- GEAV_ID_RUBR_124
   pID_RUBR_125                in varchar2,             -- GEAV_ID_RUBR_125
   pID_RUBR_126                in varchar2,             -- GEAV_ID_RUBR_126
   pID_RUBR_127                in varchar2,             -- GEAV_ID_RUBR_127
   pID_RUBR_128                in varchar2,             -- GEAV_ID_RUBR_128
   pID_RUBR_129                in varchar2,             -- GEAV_ID_RUBR_129
   pID_RUBR_130                in varchar2,             -- GEAV_ID_RUBR_130
   pID_RUBR_131                in varchar2,             -- GEAV_ID_RUBR_131
   pID_RUBR_132                in varchar2,             -- GEAV_ID_RUBR_132
   pID_RUBR_133                in varchar2,             -- GEAV_ID_RUBR_133
   pID_RUBR_134                in varchar2,             -- GEAV_ID_RUBR_134
   pID_RUBR_135                in varchar2,             -- GEAV_ID_RUBR_135
   pID_RUBR_136                in varchar2,             -- GEAV_ID_RUBR_136
   pID_RUBR_137                in varchar2,             -- GEAV_ID_RUBR_137
   pID_RUBR_138                in varchar2,             -- GEAV_ID_RUBR_138
   pID_RUBR_139                in varchar2,             -- GEAV_ID_RUBR_139
   pID_RUBR_140                in varchar2,             -- GEAV_ID_RUBR_140
   pID_RUBR_141                in varchar2,             -- GEAV_ID_RUBR_141
   pID_RUBR_142                in varchar2,             -- GEAV_ID_RUBR_142
   pID_RUBR_143                in varchar2,             -- GEAV_ID_RUBR_143
   pID_RUBR_144                in varchar2,             -- GEAV_ID_RUBR_144
   pID_RUBR_145                in varchar2,             -- GEAV_ID_RUBR_145
   pID_RUBR_146                in varchar2,             -- GEAV_ID_RUBR_146
   pID_RUBR_147                in varchar2,             -- GEAV_ID_RUBR_147
   pID_RUBR_148                in varchar2,             -- GEAV_ID_RUBR_148
   pID_RUBR_149                in varchar2,             -- GEAV_ID_RUBR_149
   pID_RUBR_150                in varchar2,             -- GEAV_ID_RUBR_150

   pCODE_CONS_01              in varchar2,             -- GEAV_CODE_CONS_01
   pCODE_CONS_02              in varchar2,             -- GEAV_CODE_CONS_02
   pCODE_CONS_03              in varchar2,             -- GEAV_CODE_CONS_03
   pCODE_CONS_04              in varchar2,             -- GEAV_CODE_CONS_04
   pCODE_CONS_05              in varchar2,             -- GEAV_CODE_CONS_05
   pCODE_CONS_06              in varchar2,             -- GEAV_CODE_CONS_06
   pCODE_CONS_07              in varchar2,             -- GEAV_CODE_CONS_07
   pCODE_CONS_08              in varchar2,             -- GEAV_CODE_CONS_08
   pCODE_CONS_09              in varchar2,             -- GEAV_CODE_CONS_09
   pCODE_CONS_10              in varchar2,             -- GEAV_CODE_CONS_10
   pCODE_CONS_11              in varchar2,             -- GEAV_CODE_CONS_11
   pCODE_CONS_12              in varchar2,             -- GEAV_CODE_CONS_12
   pCODE_CONS_13              in varchar2,             -- GEAV_CODE_CONS_13
   pCODE_CONS_14              in varchar2,             -- GEAV_CODE_CONS_14
   pCODE_CONS_15              in varchar2,             -- GEAV_CODE_CONS_15
   pCODE_CONS_16              in varchar2,             -- GEAV_CODE_CONS_16
   pCODE_CONS_17              in varchar2,             -- GEAV_CODE_CONS_17
   pCODE_CONS_18              in varchar2,             -- GEAV_CODE_CONS_18
   pCODE_CONS_19              in varchar2,             -- GEAV_CODE_CONS_19
   pCODE_CONS_20              in varchar2,             -- GEAV_CODE_CONS_20

   pCODE_CONS_21              in varchar2,             -- GEAV_CODE_CONS_21
   pCODE_CONS_22              in varchar2,             -- GEAV_CODE_CONS_22
   pCODE_CONS_23              in varchar2,             -- GEAV_CODE_CONS_23
   pCODE_CONS_24              in varchar2,             -- GEAV_CODE_CONS_24
   pCODE_CONS_25              in varchar2,             -- GEAV_CODE_CONS_25
   pCODE_CONS_26              in varchar2,             -- GEAV_CODE_CONS_26
   pCODE_CONS_27              in varchar2,             -- GEAV_CODE_CONS_27
   pCODE_CONS_28              in varchar2,             -- GEAV_CODE_CONS_28
   pCODE_CONS_29              in varchar2,             -- GEAV_CODE_CONS_29
   pCODE_CONS_30              in varchar2,             -- GEAV_CODE_CONS_30
   pCODE_CONS_31              in varchar2,             -- GEAV_CODE_CONS_31
   pCODE_CONS_32              in varchar2,             -- GEAV_CODE_CONS_32
   pCODE_CONS_33              in varchar2,             -- GEAV_CODE_CONS_33
   pCODE_CONS_34              in varchar2,             -- GEAV_CODE_CONS_34
   pCODE_CONS_35              in varchar2,             -- GEAV_CODE_CONS_35
   pCODE_CONS_36              in varchar2,             -- GEAV_CODE_CONS_36
   pCODE_CONS_37              in varchar2,             -- GEAV_CODE_CONS_37
   pCODE_CONS_38              in varchar2,             -- GEAV_CODE_CONS_38
   pCODE_CONS_39              in varchar2,             -- GEAV_CODE_CONS_39
   pCODE_CONS_40              in varchar2,             -- GEAV_CODE_CONS_40
   pCODE_CONS_41              in varchar2,             -- GEAV_CODE_CONS_41
   pCODE_CONS_42              in varchar2,             -- GEAV_CODE_CONS_42
   pCODE_CONS_43              in varchar2,             -- GEAV_CODE_CONS_43
   pCODE_CONS_44              in varchar2,             -- GEAV_CODE_CONS_44
   pCODE_CONS_45              in varchar2,             -- GEAV_CODE_CONS_45
   pCODE_CONS_46              in varchar2,             -- GEAV_CODE_CONS_46
   pCODE_CONS_47              in varchar2,             -- GEAV_CODE_CONS_47
   pCODE_CONS_48              in varchar2,             -- GEAV_CODE_CONS_48
   pCODE_CONS_49              in varchar2,             -- GEAV_CODE_CONS_49
   pCODE_CONS_50              in varchar2,             -- GEAV_CODE_CONS_50

   pVALE_RUBR_01              in varchar2,             -- GEAV_VALE_RUBR_01
   pVALE_RUBR_02              in varchar2,             -- GEAV_VALE_RUBR_02
   pVALE_RUBR_03              in varchar2,             -- GEAV_VALE_RUBR_03
   pVALE_RUBR_04              in varchar2,             -- GEAV_VALE_RUBR_04
   pVALE_RUBR_05              in varchar2,             -- GEAV_VALE_RUBR_05
   pVALE_RUBR_06              in varchar2,             -- GEAV_VALE_RUBR_06
   pVALE_RUBR_07              in varchar2,             -- GEAV_VALE_RUBR_07
   pVALE_RUBR_08              in varchar2,             -- GEAV_VALE_RUBR_08
   pVALE_RUBR_09              in varchar2,             -- GEAV_VALE_RUBR_09
   pVALE_RUBR_10              in varchar2,             -- GEAV_VALE_RUBR_10
   pVALE_RUBR_11              in varchar2,             -- GEAV_VALE_RUBR_11
   pVALE_RUBR_12              in varchar2,             -- GEAV_VALE_RUBR_12
   pVALE_RUBR_13              in varchar2,             -- GEAV_VALE_RUBR_13
   pVALE_RUBR_14              in varchar2,             -- GEAV_VALE_RUBR_14
   pVALE_RUBR_15              in varchar2,             -- GEAV_VALE_RUBR_15
   pVALE_RUBR_16              in varchar2,             -- GEAV_VALE_RUBR_16
   pVALE_RUBR_17              in varchar2,             -- GEAV_VALE_RUBR_17
   pVALE_RUBR_18              in varchar2,             -- GEAV_VALE_RUBR_18
   pVALE_RUBR_19              in varchar2,             -- GEAV_VALE_RUBR_19
   pVALE_RUBR_20              in varchar2,             -- GEAV_VALE_RUBR_20
   pVALE_RUBR_21              in varchar2,             -- GEAV_VALE_RUBR_21
   pVALE_RUBR_22              in varchar2,             -- GEAV_VALE_RUBR_22
   pVALE_RUBR_23              in varchar2,             -- GEAV_VALE_RUBR_23
   pVALE_RUBR_24              in varchar2,             -- GEAV_VALE_RUBR_24
   pVALE_RUBR_25              in varchar2,             -- GEAV_VALE_RUBR_25
   pVALE_RUBR_26              in varchar2,             -- GEAV_VALE_RUBR_26
   pVALE_RUBR_27              in varchar2,             -- GEAV_VALE_RUBR_27
   pVALE_RUBR_28              in varchar2,             -- GEAV_VALE_RUBR_28
   pVALE_RUBR_29              in varchar2,             -- GEAV_VALE_RUBR_29
   pVALE_RUBR_30              in varchar2,             -- GEAV_VALE_RUBR_30
   pVALE_RUBR_31              in varchar2,             -- GEAV_VALE_RUBR_31
   pVALE_RUBR_32              in varchar2,             -- GEAV_VALE_RUBR_32
   pVALE_RUBR_33              in varchar2,             -- GEAV_VALE_RUBR_33
   pVALE_RUBR_34              in varchar2,             -- GEAV_VALE_RUBR_34
   pVALE_RUBR_35              in varchar2,             -- GEAV_VALE_RUBR_35
   pVALE_RUBR_36              in varchar2,             -- GEAV_VALE_RUBR_36
   pVALE_RUBR_37              in varchar2,             -- GEAV_VALE_RUBR_37
   pVALE_RUBR_38              in varchar2,             -- GEAV_VALE_RUBR_38
   pVALE_RUBR_39              in varchar2,             -- GEAV_VALE_RUBR_39
   pVALE_RUBR_40              in varchar2,             -- GEAV_VALE_RUBR_40
   pVALE_RUBR_41              in varchar2,             -- GEAV_VALE_RUBR_41
   pVALE_RUBR_42              in varchar2,             -- GEAV_VALE_RUBR_42
   pVALE_RUBR_43              in varchar2,             -- GEAV_VALE_RUBR_43
   pVALE_RUBR_44              in varchar2,             -- GEAV_VALE_RUBR_44
   pVALE_RUBR_45              in varchar2,             -- GEAV_VALE_RUBR_45
   pVALE_RUBR_46              in varchar2,             -- GEAV_VALE_RUBR_46
   pVALE_RUBR_47              in varchar2,             -- GEAV_VALE_RUBR_47
   pVALE_RUBR_48              in varchar2,             -- GEAV_VALE_RUBR_48
   pVALE_RUBR_49              in varchar2,             -- GEAV_VALE_RUBR_49
   pVALE_RUBR_50              in varchar2,             -- GEAV_VALE_RUBR_50

   pVALE_RUBR_51              in varchar2,             -- GEAV_VALE_RUBR_51
   pVALE_RUBR_52              in varchar2,             -- GEAV_VALE_RUBR_52
   pVALE_RUBR_53              in varchar2,             -- GEAV_VALE_RUBR_53
   pVALE_RUBR_54              in varchar2,             -- GEAV_VALE_RUBR_54
   pVALE_RUBR_55              in varchar2,             -- GEAV_VALE_RUBR_55
   pVALE_RUBR_56              in varchar2,             -- GEAV_VALE_RUBR_56
   pVALE_RUBR_57              in varchar2,             -- GEAV_VALE_RUBR_57
   pVALE_RUBR_58              in varchar2,             -- GEAV_VALE_RUBR_58
   pVALE_RUBR_59              in varchar2,             -- GEAV_VALE_RUBR_59
   pVALE_RUBR_60              in varchar2,             -- GEAV_VALE_RUBR_60
   pVALE_RUBR_61              in varchar2,             -- GEAV_VALE_RUBR_61
   pVALE_RUBR_62              in varchar2,             -- GEAV_VALE_RUBR_62
   pVALE_RUBR_63              in varchar2,             -- GEAV_VALE_RUBR_63
   pVALE_RUBR_64              in varchar2,             -- GEAV_VALE_RUBR_64
   pVALE_RUBR_65              in varchar2,             -- GEAV_VALE_RUBR_65
   pVALE_RUBR_66              in varchar2,             -- GEAV_VALE_RUBR_66
   pVALE_RUBR_67              in varchar2,             -- GEAV_VALE_RUBR_67
   pVALE_RUBR_68              in varchar2,             -- GEAV_VALE_RUBR_68
   pVALE_RUBR_69              in varchar2,             -- GEAV_VALE_RUBR_69
   pVALE_RUBR_70              in varchar2,             -- GEAV_VALE_RUBR_70
   pVALE_RUBR_71              in varchar2,             -- GEAV_VALE_RUBR_71
   pVALE_RUBR_72              in varchar2,             -- GEAV_VALE_RUBR_72
   pVALE_RUBR_73              in varchar2,             -- GEAV_VALE_RUBR_73
   pVALE_RUBR_74              in varchar2,             -- GEAV_VALE_RUBR_74
   pVALE_RUBR_75              in varchar2,             -- GEAV_VALE_RUBR_75
   pVALE_RUBR_76              in varchar2,             -- GEAV_VALE_RUBR_76
   pVALE_RUBR_77              in varchar2,             -- GEAV_VALE_RUBR_77
   pVALE_RUBR_78              in varchar2,             -- GEAV_VALE_RUBR_78
   pVALE_RUBR_79              in varchar2,             -- GEAV_VALE_RUBR_79
   pVALE_RUBR_80              in varchar2,             -- GEAV_VALE_RUBR_80
   pVALE_RUBR_81              in varchar2,             -- GEAV_VALE_RUBR_81
   pVALE_RUBR_82              in varchar2,             -- GEAV_VALE_RUBR_82
   pVALE_RUBR_83              in varchar2,             -- GEAV_VALE_RUBR_83
   pVALE_RUBR_84              in varchar2,             -- GEAV_VALE_RUBR_84
   pVALE_RUBR_85              in varchar2,             -- GEAV_VALE_RUBR_85
   pVALE_RUBR_86              in varchar2,             -- GEAV_VALE_RUBR_86
   pVALE_RUBR_87              in varchar2,             -- GEAV_VALE_RUBR_87
   pVALE_RUBR_88              in varchar2,             -- GEAV_VALE_RUBR_88
   pVALE_RUBR_89              in varchar2,             -- GEAV_VALE_RUBR_89
   pVALE_RUBR_90              in varchar2,             -- GEAV_VALE_RUBR_90
   pVALE_RUBR_91              in varchar2,             -- GEAV_VALE_RUBR_91
   pVALE_RUBR_92              in varchar2,             -- GEAV_VALE_RUBR_92
   pVALE_RUBR_93              in varchar2,             -- GEAV_VALE_RUBR_93
   pVALE_RUBR_94              in varchar2,             -- GEAV_VALE_RUBR_94
   pVALE_RUBR_95              in varchar2,             -- GEAV_VALE_RUBR_95
   pVALE_RUBR_96              in varchar2,             -- GEAV_VALE_RUBR_96
   pVALE_RUBR_97              in varchar2,             -- GEAV_VALE_RUBR_97
   pVALE_RUBR_98              in varchar2,             -- GEAV_VALE_RUBR_98
   pVALE_RUBR_99              in varchar2,             -- GEAV_VALE_RUBR_99
   pVALE_RUBR_100              in varchar2,             -- GEAV_VALE_RUBR_100
   pVALE_RUBR_101              in varchar2,             -- GEAV_VALE_RUBR_101
   pVALE_RUBR_102              in varchar2,             -- GEAV_VALE_RUBR_102
   pVALE_RUBR_103              in varchar2,             -- GEAV_VALE_RUBR_103
   pVALE_RUBR_104              in varchar2,             -- GEAV_VALE_RUBR_104
   pVALE_RUBR_105              in varchar2,             -- GEAV_VALE_RUBR_105
   pVALE_RUBR_106              in varchar2,             -- GEAV_VALE_RUBR_106
   pVALE_RUBR_107              in varchar2,             -- GEAV_VALE_RUBR_107
   pVALE_RUBR_108              in varchar2,             -- GEAV_VALE_RUBR_108
   pVALE_RUBR_109              in varchar2,             -- GEAV_VALE_RUBR_109
   pVALE_RUBR_110              in varchar2,             -- GEAV_VALE_RUBR_110
   pVALE_RUBR_111              in varchar2,             -- GEAV_VALE_RUBR_111
   pVALE_RUBR_112              in varchar2,             -- GEAV_VALE_RUBR_112
   pVALE_RUBR_113              in varchar2,             -- GEAV_VALE_RUBR_113
   pVALE_RUBR_114              in varchar2,             -- GEAV_VALE_RUBR_114
   pVALE_RUBR_115              in varchar2,             -- GEAV_VALE_RUBR_115
   pVALE_RUBR_116              in varchar2,             -- GEAV_VALE_RUBR_116
   pVALE_RUBR_117              in varchar2,             -- GEAV_VALE_RUBR_117
   pVALE_RUBR_118              in varchar2,             -- GEAV_VALE_RUBR_118
   pVALE_RUBR_119              in varchar2,             -- GEAV_VALE_RUBR_119
   pVALE_RUBR_120              in varchar2,             -- GEAV_VALE_RUBR_120
   pVALE_RUBR_121              in varchar2,             -- GEAV_VALE_RUBR_121
   pVALE_RUBR_122              in varchar2,             -- GEAV_VALE_RUBR_122
   pVALE_RUBR_123              in varchar2,             -- GEAV_VALE_RUBR_123
   pVALE_RUBR_124              in varchar2,             -- GEAV_VALE_RUBR_124
   pVALE_RUBR_125              in varchar2,             -- GEAV_VALE_RUBR_125
   pVALE_RUBR_126              in varchar2,             -- GEAV_VALE_RUBR_126
   pVALE_RUBR_127              in varchar2,             -- GEAV_VALE_RUBR_127
   pVALE_RUBR_128              in varchar2,             -- GEAV_VALE_RUBR_128
   pVALE_RUBR_129              in varchar2,             -- GEAV_VALE_RUBR_129
   pVALE_RUBR_130              in varchar2,             -- GEAV_VALE_RUBR_130
   pVALE_RUBR_131              in varchar2,             -- GEAV_VALE_RUBR_131
   pVALE_RUBR_132              in varchar2,             -- GEAV_VALE_RUBR_132
   pVALE_RUBR_133              in varchar2,             -- GEAV_VALE_RUBR_133
   pVALE_RUBR_134              in varchar2,             -- GEAV_VALE_RUBR_134
   pVALE_RUBR_135              in varchar2,             -- GEAV_VALE_RUBR_135
   pVALE_RUBR_136              in varchar2,             -- GEAV_VALE_RUBR_136
   pVALE_RUBR_137              in varchar2,             -- GEAV_VALE_RUBR_137
   pVALE_RUBR_138              in varchar2,             -- GEAV_VALE_RUBR_138
   pVALE_RUBR_139              in varchar2,             -- GEAV_VALE_RUBR_139
   pVALE_RUBR_140              in varchar2,             -- GEAV_VALE_RUBR_140
   pVALE_RUBR_141              in varchar2,             -- GEAV_VALE_RUBR_141
   pVALE_RUBR_142              in varchar2,             -- GEAV_VALE_RUBR_142
   pVALE_RUBR_143              in varchar2,             -- GEAV_VALE_RUBR_143
   pVALE_RUBR_144              in varchar2,             -- GEAV_VALE_RUBR_144
   pVALE_RUBR_145              in varchar2,             -- GEAV_VALE_RUBR_145
   pVALE_RUBR_146              in varchar2,             -- GEAV_VALE_RUBR_146
   pVALE_RUBR_147              in varchar2,             -- GEAV_VALE_RUBR_147
   pVALE_RUBR_148              in varchar2,             -- GEAV_VALE_RUBR_148
   pVALE_RUBR_149              in varchar2,             -- GEAV_VALE_RUBR_149
   pVALE_RUBR_150              in varchar2,             -- GEAV_VALE_RUBR_150

   pCALC_RUBR_01              in varchar2,             -- GEAV_CALC_RUBR_01
   pCALC_RUBR_02              in varchar2,             -- GEAV_CALC_RUBR_02
   pCALC_RUBR_03              in varchar2,             -- GEAV_CALC_RUBR_03
   pCALC_RUBR_04              in varchar2,             -- GEAV_CALC_RUBR_04
   pCALC_RUBR_05              in varchar2,             -- GEAV_CALC_RUBR_05
   pCALC_RUBR_06              in varchar2,             -- GEAV_CALC_RUBR_06
   pCALC_RUBR_07              in varchar2,             -- GEAV_CALC_RUBR_07
   pCALC_RUBR_08              in varchar2,             -- GEAV_CALC_RUBR_08
   pCALC_RUBR_09              in varchar2,             -- GEAV_CALC_RUBR_09
   pCALC_RUBR_10              in varchar2,             -- GEAV_CALC_RUBR_10
   pCALC_RUBR_11              in varchar2,             -- GEAV_CALC_RUBR_11
   pCALC_RUBR_12              in varchar2,             -- GEAV_CALC_RUBR_12
   pCALC_RUBR_13              in varchar2,             -- GEAV_CALC_RUBR_13
   pCALC_RUBR_14              in varchar2,             -- GEAV_CALC_RUBR_14
   pCALC_RUBR_15              in varchar2,             -- GEAV_CALC_RUBR_15
   pCALC_RUBR_16              in varchar2,             -- GEAV_CALC_RUBR_16
   pCALC_RUBR_17              in varchar2,             -- GEAV_CALC_RUBR_17
   pCALC_RUBR_18              in varchar2,             -- GEAV_CALC_RUBR_18
   pCALC_RUBR_19              in varchar2,             -- GEAV_CALC_RUBR_19
   pCALC_RUBR_20              in varchar2,             -- GEAV_CALC_RUBR_20
   pCALC_RUBR_21              in varchar2,             -- GEAV_CALC_RUBR_21
   pCALC_RUBR_22              in varchar2,             -- GEAV_CALC_RUBR_22
   pCALC_RUBR_23              in varchar2,             -- GEAV_CALC_RUBR_23
   pCALC_RUBR_24              in varchar2,             -- GEAV_CALC_RUBR_24
   pCALC_RUBR_25              in varchar2,             -- GEAV_CALC_RUBR_25
   pCALC_RUBR_26              in varchar2,             -- GEAV_CALC_RUBR_26
   pCALC_RUBR_27              in varchar2,             -- GEAV_CALC_RUBR_27
   pCALC_RUBR_28              in varchar2,             -- GEAV_CALC_RUBR_28
   pCALC_RUBR_29              in varchar2,             -- GEAV_CALC_RUBR_29
   pCALC_RUBR_30              in varchar2,             -- GEAV_CALC_RUBR_30
   pCALC_RUBR_31              in varchar2,             -- GEAV_CALC_RUBR_31
   pCALC_RUBR_32              in varchar2,             -- GEAV_CALC_RUBR_32
   pCALC_RUBR_33              in varchar2,             -- GEAV_CALC_RUBR_33
   pCALC_RUBR_34              in varchar2,             -- GEAV_CALC_RUBR_34
   pCALC_RUBR_35              in varchar2,             -- GEAV_CALC_RUBR_35
   pCALC_RUBR_36              in varchar2,             -- GEAV_CALC_RUBR_36
   pCALC_RUBR_37              in varchar2,             -- GEAV_CALC_RUBR_37
   pCALC_RUBR_38              in varchar2,             -- GEAV_CALC_RUBR_38
   pCALC_RUBR_39              in varchar2,             -- GEAV_CALC_RUBR_39
   pCALC_RUBR_40              in varchar2,             -- GEAV_CALC_RUBR_40
   pCALC_RUBR_41              in varchar2,             -- GEAV_CALC_RUBR_41
   pCALC_RUBR_42              in varchar2,             -- GEAV_CALC_RUBR_42
   pCALC_RUBR_43              in varchar2,             -- GEAV_CALC_RUBR_43
   pCALC_RUBR_44              in varchar2,             -- GEAV_CALC_RUBR_44
   pCALC_RUBR_45              in varchar2,             -- GEAV_CALC_RUBR_45
   pCALC_RUBR_46              in varchar2,             -- GEAV_CALC_RUBR_46
   pCALC_RUBR_47              in varchar2,             -- GEAV_CALC_RUBR_47
   pCALC_RUBR_48              in varchar2,             -- GEAV_CALC_RUBR_48
   pCALC_RUBR_49              in varchar2,             -- GEAV_CALC_RUBR_49
   pCALC_RUBR_50              in varchar2,             -- GEAV_CALC_RUBR_50

   pCALC_RUBR_51              in varchar2,             -- GEAV_CALC_RUBR_51
   pCALC_RUBR_52              in varchar2,             -- GEAV_CALC_RUBR_52
   pCALC_RUBR_53              in varchar2,             -- GEAV_CALC_RUBR_53
   pCALC_RUBR_54              in varchar2,             -- GEAV_CALC_RUBR_54
   pCALC_RUBR_55              in varchar2,             -- GEAV_CALC_RUBR_55
   pCALC_RUBR_56              in varchar2,             -- GEAV_CALC_RUBR_56
   pCALC_RUBR_57              in varchar2,             -- GEAV_CALC_RUBR_57
   pCALC_RUBR_58              in varchar2,             -- GEAV_CALC_RUBR_58
   pCALC_RUBR_59              in varchar2,             -- GEAV_CALC_RUBR_59
   pCALC_RUBR_60              in varchar2,             -- GEAV_CALC_RUBR_60
   pCALC_RUBR_61              in varchar2,             -- GEAV_CALC_RUBR_61
   pCALC_RUBR_62              in varchar2,             -- GEAV_CALC_RUBR_62
   pCALC_RUBR_63              in varchar2,             -- GEAV_CALC_RUBR_63
   pCALC_RUBR_64              in varchar2,             -- GEAV_CALC_RUBR_64
   pCALC_RUBR_65              in varchar2,             -- GEAV_CALC_RUBR_65
   pCALC_RUBR_66              in varchar2,             -- GEAV_CALC_RUBR_66
   pCALC_RUBR_67              in varchar2,             -- GEAV_CALC_RUBR_67
   pCALC_RUBR_68              in varchar2,             -- GEAV_CALC_RUBR_68
   pCALC_RUBR_69              in varchar2,             -- GEAV_CALC_RUBR_69
   pCALC_RUBR_70              in varchar2,             -- GEAV_CALC_RUBR_70
   pCALC_RUBR_71              in varchar2,             -- GEAV_CALC_RUBR_71
   pCALC_RUBR_72              in varchar2,             -- GEAV_CALC_RUBR_72
   pCALC_RUBR_73              in varchar2,             -- GEAV_CALC_RUBR_73
   pCALC_RUBR_74              in varchar2,             -- GEAV_CALC_RUBR_74
   pCALC_RUBR_75              in varchar2,             -- GEAV_CALC_RUBR_75
   pCALC_RUBR_76              in varchar2,             -- GEAV_CALC_RUBR_76
   pCALC_RUBR_77              in varchar2,             -- GEAV_CALC_RUBR_77
   pCALC_RUBR_78              in varchar2,             -- GEAV_CALC_RUBR_78
   pCALC_RUBR_79              in varchar2,             -- GEAV_CALC_RUBR_79
   pCALC_RUBR_80              in varchar2,             -- GEAV_CALC_RUBR_80
   pCALC_RUBR_81              in varchar2,             -- GEAV_CALC_RUBR_81
   pCALC_RUBR_82              in varchar2,             -- GEAV_CALC_RUBR_82
   pCALC_RUBR_83              in varchar2,             -- GEAV_CALC_RUBR_83
   pCALC_RUBR_84              in varchar2,             -- GEAV_CALC_RUBR_84
   pCALC_RUBR_85              in varchar2,             -- GEAV_CALC_RUBR_85
   pCALC_RUBR_86              in varchar2,             -- GEAV_CALC_RUBR_86
   pCALC_RUBR_87              in varchar2,             -- GEAV_CALC_RUBR_87
   pCALC_RUBR_88              in varchar2,             -- GEAV_CALC_RUBR_88
   pCALC_RUBR_89              in varchar2,             -- GEAV_CALC_RUBR_89
   pCALC_RUBR_90              in varchar2,             -- GEAV_CALC_RUBR_90
   pCALC_RUBR_91              in varchar2,             -- GEAV_CALC_RUBR_91
   pCALC_RUBR_92              in varchar2,             -- GEAV_CALC_RUBR_92
   pCALC_RUBR_93              in varchar2,             -- GEAV_CALC_RUBR_93
   pCALC_RUBR_94              in varchar2,             -- GEAV_CALC_RUBR_94
   pCALC_RUBR_95              in varchar2,             -- GEAV_CALC_RUBR_95
   pCALC_RUBR_96              in varchar2,             -- GEAV_CALC_RUBR_96
   pCALC_RUBR_97              in varchar2,             -- GEAV_CALC_RUBR_97
   pCALC_RUBR_98              in varchar2,             -- GEAV_CALC_RUBR_98
   pCALC_RUBR_99              in varchar2,             -- GEAV_CALC_RUBR_99
   pCALC_RUBR_100              in varchar2,             -- GEAV_CALC_RUBR_100
   pCALC_RUBR_101              in varchar2,             -- GEAV_CALC_RUBR_101
   pCALC_RUBR_102              in varchar2,             -- GEAV_CALC_RUBR_102
   pCALC_RUBR_103              in varchar2,             -- GEAV_CALC_RUBR_103
   pCALC_RUBR_104              in varchar2,             -- GEAV_CALC_RUBR_104
   pCALC_RUBR_105              in varchar2,             -- GEAV_CALC_RUBR_105
   pCALC_RUBR_106              in varchar2,             -- GEAV_CALC_RUBR_106
   pCALC_RUBR_107              in varchar2,             -- GEAV_CALC_RUBR_107
   pCALC_RUBR_108              in varchar2,             -- GEAV_CALC_RUBR_108
   pCALC_RUBR_109              in varchar2,             -- GEAV_CALC_RUBR_109
   pCALC_RUBR_110              in varchar2,             -- GEAV_CALC_RUBR_110
   pCALC_RUBR_111              in varchar2,             -- GEAV_CALC_RUBR_111
   pCALC_RUBR_112              in varchar2,             -- GEAV_CALC_RUBR_112
   pCALC_RUBR_113              in varchar2,             -- GEAV_CALC_RUBR_113
   pCALC_RUBR_114              in varchar2,             -- GEAV_CALC_RUBR_114
   pCALC_RUBR_115              in varchar2,             -- GEAV_CALC_RUBR_115
   pCALC_RUBR_116              in varchar2,             -- GEAV_CALC_RUBR_116
   pCALC_RUBR_117              in varchar2,             -- GEAV_CALC_RUBR_117
   pCALC_RUBR_118              in varchar2,             -- GEAV_CALC_RUBR_118
   pCALC_RUBR_119              in varchar2,             -- GEAV_CALC_RUBR_119
   pCALC_RUBR_120              in varchar2,             -- GEAV_CALC_RUBR_120
   pCALC_RUBR_121              in varchar2,             -- GEAV_CALC_RUBR_121
   pCALC_RUBR_122              in varchar2,             -- GEAV_CALC_RUBR_122
   pCALC_RUBR_123              in varchar2,             -- GEAV_CALC_RUBR_123
   pCALC_RUBR_124              in varchar2,             -- GEAV_CALC_RUBR_124
   pCALC_RUBR_125              in varchar2,             -- GEAV_CALC_RUBR_125
   pCALC_RUBR_126              in varchar2,             -- GEAV_CALC_RUBR_126
   pCALC_RUBR_127              in varchar2,             -- GEAV_CALC_RUBR_127
   pCALC_RUBR_128              in varchar2,             -- GEAV_CALC_RUBR_128
   pCALC_RUBR_129              in varchar2,             -- GEAV_CALC_RUBR_129
   pCALC_RUBR_130              in varchar2,             -- GEAV_CALC_RUBR_130
   pCALC_RUBR_131              in varchar2,             -- GEAV_CALC_RUBR_131
   pCALC_RUBR_132              in varchar2,             -- GEAV_CALC_RUBR_132
   pCALC_RUBR_133              in varchar2,             -- GEAV_CALC_RUBR_133
   pCALC_RUBR_134              in varchar2,             -- GEAV_CALC_RUBR_134
   pCALC_RUBR_135              in varchar2,             -- GEAV_CALC_RUBR_135
   pCALC_RUBR_136              in varchar2,             -- GEAV_CALC_RUBR_136
   pCALC_RUBR_137              in varchar2,             -- GEAV_CALC_RUBR_137
   pCALC_RUBR_138              in varchar2,             -- GEAV_CALC_RUBR_138
   pCALC_RUBR_139              in varchar2,             -- GEAV_CALC_RUBR_139
   pCALC_RUBR_140              in varchar2,             -- GEAV_CALC_RUBR_140
   pCALC_RUBR_141              in varchar2,             -- GEAV_CALC_RUBR_141
   pCALC_RUBR_142              in varchar2,             -- GEAV_CALC_RUBR_142
   pCALC_RUBR_143              in varchar2,             -- GEAV_CALC_RUBR_143
   pCALC_RUBR_144              in varchar2,             -- GEAV_CALC_RUBR_144
   pCALC_RUBR_145              in varchar2,             -- GEAV_CALC_RUBR_145
   pCALC_RUBR_146              in varchar2,             -- GEAV_CALC_RUBR_146
   pCALC_RUBR_147              in varchar2,             -- GEAV_CALC_RUBR_147
   pCALC_RUBR_148              in varchar2,             -- GEAV_CALC_RUBR_148
   pCALC_RUBR_149              in varchar2,             -- GEAV_CALC_RUBR_149
   pCALC_RUBR_150              in varchar2,             -- GEAV_CALC_RUBR_150

   pRAPP_HORA_ARRO            in varchar2,             -- GEAV_RAPP_HORA_ARRO
   pCOMM_1                    in varchar2,             -- GEAV_COMM_1
   pCOMM_2                    in varchar2,             -- GEAV_COMM_1
   pCOMM_3                    in varchar2,              -- GEAV_COMM_1
   pSAHO_BOO                  in varchar2,
   pCALC_01_LIBE              in varchar2,
   pCALC_02_LIBE              in varchar2,
   pCALC_03_LIBE              in varchar2,
   pCALC_04_LIBE              in varchar2,
   pCALC_05_LIBE              in varchar2,
   pCALC_06_LIBE              in varchar2,
   pCALC_07_LIBE              in varchar2,
   pCALC_08_LIBE              in varchar2,
   pCALC_09_LIBE              in varchar2,
   pCALC_10_LIBE              in varchar2,
   pCALC_11_LIBE              in varchar2,
   pCALC_12_LIBE              in varchar2,
   pCALC_13_LIBE              in varchar2,
   pCALC_14_LIBE              in varchar2,
   pCALC_15_LIBE              in varchar2,
   pCALC_16_LIBE              in varchar2,
   pCALC_17_LIBE              in varchar2,
   pCALC_18_LIBE              in varchar2,
   pCALC_19_LIBE              in varchar2,
   pCALC_20_LIBE              in varchar2,
   pCALC_01_OPERANDE_1        in varchar2,
   pCALC_02_OPERANDE_1        in varchar2,
   pCALC_03_OPERANDE_1        in varchar2,
   pCALC_04_OPERANDE_1        in varchar2,
   pCALC_05_OPERANDE_1        in varchar2,
   pCALC_06_OPERANDE_1        in varchar2,
   pCALC_07_OPERANDE_1        in varchar2,
   pCALC_08_OPERANDE_1        in varchar2,
   pCALC_09_OPERANDE_1        in varchar2,
   pCALC_10_OPERANDE_1        in varchar2,
   pCALC_11_OPERANDE_1        in varchar2,
   pCALC_12_OPERANDE_1        in varchar2,
   pCALC_13_OPERANDE_1        in varchar2,
   pCALC_14_OPERANDE_1        in varchar2,
   pCALC_15_OPERANDE_1        in varchar2,
   pCALC_16_OPERANDE_1        in varchar2,
   pCALC_17_OPERANDE_1        in varchar2,
   pCALC_18_OPERANDE_1        in varchar2,
   pCALC_19_OPERANDE_1        in varchar2,
   pCALC_20_OPERANDE_1        in varchar2,
   pCALC_01_OPERATEUR         in varchar2,
   pCALC_02_OPERATEUR         in varchar2,
   pCALC_03_OPERATEUR         in varchar2,
   pCALC_04_OPERATEUR         in varchar2,
   pCALC_05_OPERATEUR         in varchar2,
   pCALC_06_OPERATEUR         in varchar2,
   pCALC_07_OPERATEUR         in varchar2,
   pCALC_08_OPERATEUR         in varchar2,
   pCALC_09_OPERATEUR         in varchar2,
   pCALC_10_OPERATEUR         in varchar2,
   pCALC_11_OPERATEUR         in varchar2,
   pCALC_12_OPERATEUR         in varchar2,
   pCALC_13_OPERATEUR         in varchar2,
   pCALC_14_OPERATEUR         in varchar2,
   pCALC_15_OPERATEUR         in varchar2,
   pCALC_16_OPERATEUR         in varchar2,
   pCALC_17_OPERATEUR         in varchar2,
   pCALC_18_OPERATEUR         in varchar2,
   pCALC_19_OPERATEUR         in varchar2,
   pCALC_20_OPERATEUR         in varchar2,
   pCALC_01_OPERANDE_2        in varchar2,
   pCALC_02_OPERANDE_2        in varchar2,
   pCALC_03_OPERANDE_2        in varchar2,
   pCALC_04_OPERANDE_2        in varchar2,
   pCALC_05_OPERANDE_2        in varchar2,
   pCALC_06_OPERANDE_2        in varchar2,
   pCALC_07_OPERANDE_2        in varchar2,
   pCALC_08_OPERANDE_2        in varchar2,
   pCALC_09_OPERANDE_2        in varchar2,
   pCALC_10_OPERANDE_2        in varchar2,
   pCALC_11_OPERANDE_2        in varchar2,
   pCALC_12_OPERANDE_2        in varchar2,
   pCALC_13_OPERANDE_2        in varchar2,
   pCALC_14_OPERANDE_2        in varchar2,
   pCALC_15_OPERANDE_2        in varchar2,
   pCALC_16_OPERANDE_2        in varchar2,
   pCALC_17_OPERANDE_2        in varchar2,
   pCALC_18_OPERANDE_2        in varchar2,
   pCALC_19_OPERANDE_2        in varchar2,
   pCALC_20_OPERANDE_2        in varchar2,
   pCALC_01_DECI              in varchar2,
   pCALC_02_DECI              in varchar2,
   pCALC_03_DECI              in varchar2,
   pCALC_04_DECI              in varchar2,
   pCALC_05_DECI              in varchar2,
   pCALC_06_DECI              in varchar2,
   pCALC_07_DECI              in varchar2,
   pCALC_08_DECI              in varchar2,
   pCALC_09_DECI              in varchar2,
   pCALC_10_DECI              in varchar2,
   pCALC_11_DECI              in varchar2,
   pCALC_12_DECI              in varchar2,
   pCALC_13_DECI              in varchar2,
   pCALC_14_DECI              in varchar2,
   pCALC_15_DECI              in varchar2,
   pCALC_16_DECI              in varchar2,
   pCALC_17_DECI              in varchar2,
   pCALC_18_DECI              in varchar2,
   pCALC_19_DECI              in varchar2,
   pCALC_20_DECI              in varchar2,
   pCALC_01_MULT              in varchar2,
   pCALC_02_MULT              in varchar2,
   pCALC_03_MULT              in varchar2,
   pCALC_04_MULT              in varchar2,
   pCALC_05_MULT              in varchar2,
   pCALC_06_MULT              in varchar2,
   pCALC_07_MULT              in varchar2,
   pCALC_08_MULT              in varchar2,
   pCALC_09_MULT              in varchar2,
   pCALC_10_MULT              in varchar2,
   pCALC_11_MULT              in varchar2,
   pCALC_12_MULT              in varchar2,
   pCALC_13_MULT              in varchar2,
   pCALC_14_MULT              in varchar2,
   pCALC_15_MULT              in varchar2,
   pCALC_16_MULT              in varchar2,
   pCALC_17_MULT              in varchar2,
   pCALC_18_MULT              in varchar2,
   pCALC_19_MULT              in varchar2,
   pCALC_20_MULT              in varchar2,
   pCODE_COMP_FICH            in varchar2,
   pCONG_REST_MOIS            in varchar2,
   pCONG_PRIS_ANNE            in varchar2,
   pMUTU_SOUM_TXDE_01         in varchar2,
   pMUTU_SOUM_TXDE_02         in varchar2,
   pMUTU_SOUM_TXDE_03         in varchar2,
   pMUTU_SOUM_TXDE_04         in varchar2,
   pMUTU_SOUM_TXDE_05         in varchar2,
   pMUTU_SOUM_MTDE_01         in varchar2,
   pMUTU_SOUM_MTDE_02         in varchar2,
   pMUTU_SOUM_MTDE_03         in varchar2,
   pMUTU_SOUM_MTDE_04         in varchar2,
   pMUTU_SOUM_MTDE_05         in varchar2,
   pMUTU_SOUM_MTDE_06         in varchar2,
   pMUTU_SOUM_MTDE_07         in varchar2,
   pMUTU_SOUM_MTDE_08         in varchar2,
   pMUTU_SOUM_MTDE_09         in varchar2,
   pMUTU_SOUM_MTDE_10         in varchar2,
   pMUTU_NOSO_TXDE_01         in varchar2,
   pMUTU_NOSO_TXDE_02         in varchar2,
   pMUTU_NOSO_TXDE_03         in varchar2,
   pMUTU_NOSO_MTDE_01         in varchar2,
   pMUTU_NOSO_MTDE_02         in varchar2,
   pMUTU_NOSO_MTDE_03         in varchar2,
   pMUTU_NOSO_MTDE_04         in varchar2,
   pMUTU_NOSO_MTDE_05         in varchar2,
   pMUTU_NOSO_MTDE_06         in varchar2,
   pMUTU_NOSO_MTDE_07         in varchar2,
   pDERN_SALA_BASE            in varchar2,
   pDERN_SALA_BASE_ANNU       in varchar2,
   pDERN_HORA                 in varchar2,

   pCODE_EMPL                 in varchar2,
   pCODE_CATE                 in varchar2,

   pEVOL_REMU_SUPP_COTI       in varchar2,

   pTYPE_VEHI                 in varchar2,
   pCATE_VEHI                 in varchar2,
   pPRIS_CHAR_CARB            in varchar2,
   pOCTR_VEHI                 in varchar2,
   pIMMA_VEHI                 in varchar2,
   pDATE_1ER_MISE_CIRC_VEHI   in varchar2,
   pPRIX_ACHA_REMI_VEHI       in varchar2,
   pCOUT_VEHI                 in varchar2,

   pNUME_FINE                 in varchar2,
   pNUME_ADEL                 in varchar2,
   pNUME_RPPS                 in varchar2,
   pADRE_ELEC                 in varchar2,
   pCODE_TITR_FORM            in varchar2,
   pLIBE_TITR_FORM            in varchar2,
   pDATE_TITR_FORM            in varchar2,
   pLIEU_TITR_FORM            in varchar2,

   pCODE_REGI                 in varchar2,
   pLIBE_REGI                 in varchar2,

   pORGA                      in varchar2,
   pUNIT                      in varchar2,

   pCODE_SOCI                 in varchar2,
   pSOCI_CODE                 in varchar2,
   pETAB_CODE                 in varchar2,
   pCODE_DIVI                 in varchar2,
   pCODE_SERV                 in varchar2,
   pCODE_DEPA                 in varchar2,
   pCODE_EQUI                 in varchar2,
   pSALA_CODE_UNIT            in varchar2,
   pSALA_FORF_TEMP            in varchar2,
   pNOMB_JOUR_FORF_TEMP       in varchar2,
   pNOMB_HEUR_FORF_TEMP       in varchar2,

   pCODE_FINE_GEOG            in varchar2,
   pGEAV_NOMB_MOIS            in varchar2,
   pGEAV_SALA_ANNU_CONT       in varchar2,
   pGEAV_PART_VARI_CONT       in varchar2,

   pRIB_GUIC_1                in varchar2,             -- GEAV_RIB_GUIC_1
   pRIB_COMP_1                in varchar2,             -- GEAV_RIB_COMP_1
   pRIB_CLE_1                 in varchar2,             -- GEAV_RIB_CLE_1
   pRIB_BANQ_01               in varchar2,             -- GEAV_RIB_BANQ_01
   pRIB_BANQ_02               in varchar2,             -- GEAV_RIB_BANQ_02
   pPROF_TEMP_LIBE            in varchar2,
   pMOTI_AUGM_2               in varchar2,             -- GEAV_MOTI_AUGM_2 KFH 27/04/2023 T184292
   pSALA_AUTO_TITR_TRAV       in varchar2,             -- GEAV_SALA_AUTO_TITR_TRAV
   pLIEU_PRES_STAG            in varchar2,             -- GEAV_LIEU_PRES_STAG
   pNOMB_JOUR_CONG_ANCI       in varchar2,             -- Nombre de jours de congés d’ancienneté au 12/2023
   pMONT_ANCI_PA              in varchar2,             -- Montant de la prime d’ancienneté au 12/2023
   pANCI_CADR                 in varchar2,             -- anciennement cadre
   pTOTA_HEUR_TRAV            in varchar2,             -- Total heures travaillées au 12/2023
   pTICK_REST_TYPE_REPA       in varchar2,             -- GEAV_TICK_REST_TYPE_REPA KFH 03/04/2024 T201908
   pDPAE_ENVO                 in varchar2,             -- GEAV_DPAE_ENVO
   pDISP_POLI_PUBL_CONV       in varchar2,             -- GEAV_DISP_POLI_PUBL_CONV
   pDATE_ANCI_CADR_FORF       in varchar2,             -- DATE_ANCI_CADR_FORF

   Err                        out int     ,
   pXML                       out varchar2,
   pID_New                    out varchar2
)
is
   iErr      int;
   iNB       int;
   iNB_LIST  int;
   strAction varchar(10) ; -- CREE ou MODI
   oOld      liste_gestion_avancee%rowtype;
   oNew      liste_gestion_avancee%rowtype;
   oOld_2    liste_gestion_avancee_2%rowtype;
   oNew_2    liste_gestion_avancee_2%rowtype;
   oList     v_liste_etat_colonnes_list%rowtype;

   dPERI     date;
   iID_SOCI  number;
   iID_LIST  number;
   iID_LOGI  number;
   vETAT     constant varchar(20) default 'ListeGestionAvancee' ;

   procedure pr__calcul(
      pINDEX              in varchar2,
      pCALC_XX_OPERANDE_1 in varchar2,
      pCALC_XX_OPERATEUR  in varchar2,
      pCALC_XX_OPERANDE_2 in varchar2,
      pCALC_XX_MULT       in varchar2,
      pCALC_XX_LIBE       in varchar2,
      pCALC_XX_DECI       in varchar2
   )is
      iINDEX int;
      vCALC_XX_OPERANDE_1 varchar2(100) default null;
      vCALC_XX_OPERATEUR  varchar2(100) default null;
      vCALC_XX_OPERANDE_2 varchar2(100) default null;
      fCALC_XX_MULT       float         default null;
      vCALC_XX_LIBE       varchar2(100) default null;
      iCALC_XX_DECI       int           default null;
   begin
      iINDEX:=to_number(pINDEX);
      if  pCALC_XX_OPERANDE_1 is not null
      and pCALC_XX_OPERANDE_2 is not null
      then
         vCALC_XX_OPERANDE_1 :=pCALC_XX_OPERANDE_1 ;
         vCALC_XX_OPERANDE_2 :=pCALC_XX_OPERANDE_2 ;
         vCALC_XX_LIBE       :=pCALC_XX_LIBE;

         if pCALC_XX_OPERATEUR in ('+','-','*','/') then
            vCALC_XX_OPERATEUR  :=pCALC_XX_OPERATEUR;
         else
            vCALC_XX_OPERATEUR  :='+';
         end if;
         if parse_float(pCALC_XX_MULT) in (-1,1,10,100,1000,1/10,1/100,1/1000) then
            fCALC_XX_MULT  :=parse_float(pCALC_XX_MULT);
         else
            fCALC_XX_MULT  :=1;
         end if;
         if parse_int(pCALC_XX_DECI) in (0,2,3,4,10) then
            iCALC_XX_DECI  :=parse_int(pCALC_XX_DECI);
         else
            iCALC_XX_DECI  :=2;
         end if;

         vCALC_XX_LIBE:=substr(trim(pCALC_XX_LIBE),1,50);
         if vCALC_XX_LIBE is null then
            errtools.pr_errlistadd(pXML,'CALC_'||pINDEX||'_LIBE','','','Vous devez saisir un libellé');
         end if;
      end if;


      if    iINDEX= 1 then oNew.calc_01_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_01_operateur:=vCALC_XX_OPERATEUR;oNew.calc_01_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_01_mult:=fCALC_XX_MULT;oNew.calc_01_libe:=vCALC_XX_LIBE;oNew.calc_01_deci:=iCALC_XX_DECI;
      elsif iINDEX= 2 then oNew.calc_02_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_02_operateur:=vCALC_XX_OPERATEUR;oNew.calc_02_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_02_mult:=fCALC_XX_MULT;oNew.calc_02_libe:=vCALC_XX_LIBE;oNew.calc_02_deci:=iCALC_XX_DECI;
      elsif iINDEX= 3 then oNew.calc_03_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_03_operateur:=vCALC_XX_OPERATEUR;oNew.calc_03_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_03_mult:=fCALC_XX_MULT;oNew.calc_03_libe:=vCALC_XX_LIBE;oNew.calc_03_deci:=iCALC_XX_DECI;
      elsif iINDEX= 4 then oNew.calc_04_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_04_operateur:=vCALC_XX_OPERATEUR;oNew.calc_04_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_04_mult:=fCALC_XX_MULT;oNew.calc_04_libe:=vCALC_XX_LIBE;oNew.calc_04_deci:=iCALC_XX_DECI;
      elsif iINDEX= 5 then oNew.calc_05_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_05_operateur:=vCALC_XX_OPERATEUR;oNew.calc_05_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_05_mult:=fCALC_XX_MULT;oNew.calc_05_libe:=vCALC_XX_LIBE;oNew.calc_05_deci:=iCALC_XX_DECI;
      elsif iINDEX= 6 then oNew.calc_06_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_06_operateur:=vCALC_XX_OPERATEUR;oNew.calc_06_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_06_mult:=fCALC_XX_MULT;oNew.calc_06_libe:=vCALC_XX_LIBE;oNew.calc_06_deci:=iCALC_XX_DECI;
      elsif iINDEX= 7 then oNew.calc_07_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_07_operateur:=vCALC_XX_OPERATEUR;oNew.calc_07_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_07_mult:=fCALC_XX_MULT;oNew.calc_07_libe:=vCALC_XX_LIBE;oNew.calc_07_deci:=iCALC_XX_DECI;
      elsif iINDEX= 8 then oNew.calc_08_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_08_operateur:=vCALC_XX_OPERATEUR;oNew.calc_08_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_08_mult:=fCALC_XX_MULT;oNew.calc_08_libe:=vCALC_XX_LIBE;oNew.calc_08_deci:=iCALC_XX_DECI;
      elsif iINDEX= 9 then oNew.calc_09_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_09_operateur:=vCALC_XX_OPERATEUR;oNew.calc_09_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_09_mult:=fCALC_XX_MULT;oNew.calc_09_libe:=vCALC_XX_LIBE;oNew.calc_09_deci:=iCALC_XX_DECI;
      elsif iINDEX=10 then oNew.calc_10_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_10_operateur:=vCALC_XX_OPERATEUR;oNew.calc_10_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_10_mult:=fCALC_XX_MULT;oNew.calc_10_libe:=vCALC_XX_LIBE;oNew.calc_10_deci:=iCALC_XX_DECI;
      elsif iINDEX=11 then oNew.calc_11_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_11_operateur:=vCALC_XX_OPERATEUR;oNew.calc_11_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_11_mult:=fCALC_XX_MULT;oNew.calc_11_libe:=vCALC_XX_LIBE;oNew.calc_11_deci:=iCALC_XX_DECI;
      elsif iINDEX=12 then oNew.calc_12_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_12_operateur:=vCALC_XX_OPERATEUR;oNew.calc_12_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_12_mult:=fCALC_XX_MULT;oNew.calc_12_libe:=vCALC_XX_LIBE;oNew.calc_12_deci:=iCALC_XX_DECI;
      elsif iINDEX=13 then oNew.calc_13_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_13_operateur:=vCALC_XX_OPERATEUR;oNew.calc_13_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_13_mult:=fCALC_XX_MULT;oNew.calc_13_libe:=vCALC_XX_LIBE;oNew.calc_13_deci:=iCALC_XX_DECI;
      elsif iINDEX=14 then oNew.calc_14_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_14_operateur:=vCALC_XX_OPERATEUR;oNew.calc_14_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_14_mult:=fCALC_XX_MULT;oNew.calc_14_libe:=vCALC_XX_LIBE;oNew.calc_14_deci:=iCALC_XX_DECI;
      elsif iINDEX=15 then oNew.calc_15_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_15_operateur:=vCALC_XX_OPERATEUR;oNew.calc_15_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_15_mult:=fCALC_XX_MULT;oNew.calc_15_libe:=vCALC_XX_LIBE;oNew.calc_15_deci:=iCALC_XX_DECI;
      elsif iINDEX=16 then oNew.calc_16_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_16_operateur:=vCALC_XX_OPERATEUR;oNew.calc_16_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_16_mult:=fCALC_XX_MULT;oNew.calc_16_libe:=vCALC_XX_LIBE;oNew.calc_16_deci:=iCALC_XX_DECI;
      elsif iINDEX=17 then oNew.calc_17_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_17_operateur:=vCALC_XX_OPERATEUR;oNew.calc_17_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_17_mult:=fCALC_XX_MULT;oNew.calc_17_libe:=vCALC_XX_LIBE;oNew.calc_17_deci:=iCALC_XX_DECI;
      elsif iINDEX=18 then oNew.calc_18_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_18_operateur:=vCALC_XX_OPERATEUR;oNew.calc_18_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_18_mult:=fCALC_XX_MULT;oNew.calc_18_libe:=vCALC_XX_LIBE;oNew.calc_18_deci:=iCALC_XX_DECI;
      elsif iINDEX=19 then oNew.calc_19_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_19_operateur:=vCALC_XX_OPERATEUR;oNew.calc_19_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_19_mult:=fCALC_XX_MULT;oNew.calc_19_libe:=vCALC_XX_LIBE;oNew.calc_19_deci:=iCALC_XX_DECI;
      elsif iINDEX=20 then oNew.calc_20_operande_1:=vCALC_XX_OPERANDE_1;oNew.calc_20_operateur:=vCALC_XX_OPERATEUR;oNew.calc_20_operande_2:=vCALC_XX_OPERANDE_2;oNew.calc_20_mult:=fCALC_XX_MULT;oNew.calc_20_libe:=vCALC_XX_LIBE;oNew.calc_20_deci:=iCALC_XX_DECI;
      end if;


   end;

   procedure pr_constante(
      pCODE_CONS varchar2,
      pLIBE      varchar2,
      pINDEX     varchar2,
      pREPA      varchar2
   )
   is
      iINDEX int;
      vLIBE  varchar2(20);
   begin
      if trim(pCODE_CONS) is not null then

         iINDEX:=to_number(pINDEX);

         if trim(pLIBE) is null then
            errtools.pr_errlistadd(pXML,'GEAV_LIBE_CONS_'||pINDEX,'','','Vous devez saisir un libellé');
            return;
         else
            vLIBE:=substr(trim(pLIBE),1,20);
         end if;

         -- on inserre le code dans un index non null
            if oNew.code_cons_01 is null and iINDEX= 1 then oNew.code_cons_01:=pCODE_CONS; oNew.libe_cons_01:=vLIBE;oNew.cons_01:='850';if nvl(pREPA,'N')='O' then oNew.cons_repa_01:='O'; else oNew.cons_repa_01:='N';end if;
         elsif oNew.code_cons_02 is null and iINDEX= 2 then oNew.code_cons_02:=pCODE_CONS; oNew.libe_cons_02:=vLIBE;oNew.cons_02:='851';if nvl(pREPA,'N')='O' then oNew.cons_repa_02:='O'; else oNew.cons_repa_02:='N';end if;
         elsif oNew.code_cons_03 is null and iINDEX= 3 then oNew.code_cons_03:=pCODE_CONS; oNew.libe_cons_03:=vLIBE;oNew.cons_03:='852';if nvl(pREPA,'N')='O' then oNew.cons_repa_03:='O'; else oNew.cons_repa_03:='N';end if;
         elsif oNew.code_cons_04 is null and iINDEX= 4 then oNew.code_cons_04:=pCODE_CONS; oNew.libe_cons_04:=vLIBE;oNew.cons_04:='853';if nvl(pREPA,'N')='O' then oNew.cons_repa_04:='O'; else oNew.cons_repa_04:='N';end if;
         elsif oNew.code_cons_05 is null and iINDEX= 5 then oNew.code_cons_05:=pCODE_CONS; oNew.libe_cons_05:=vLIBE;oNew.cons_05:='854';if nvl(pREPA,'N')='O' then oNew.cons_repa_05:='O'; else oNew.cons_repa_05:='N';end if;
         elsif oNew.code_cons_06 is null and iINDEX= 6 then oNew.code_cons_06:=pCODE_CONS; oNew.libe_cons_06:=vLIBE;oNew.cons_06:='855';if nvl(pREPA,'N')='O' then oNew.cons_repa_06:='O'; else oNew.cons_repa_06:='N';end if;
         elsif oNew.code_cons_07 is null and iINDEX= 7 then oNew.code_cons_07:=pCODE_CONS; oNew.libe_cons_07:=vLIBE;oNew.cons_07:='856';if nvl(pREPA,'N')='O' then oNew.cons_repa_07:='O'; else oNew.cons_repa_07:='N';end if;
         elsif oNew.code_cons_08 is null and iINDEX= 8 then oNew.code_cons_08:=pCODE_CONS; oNew.libe_cons_08:=vLIBE;oNew.cons_08:='857';if nvl(pREPA,'N')='O' then oNew.cons_repa_08:='O'; else oNew.cons_repa_08:='N';end if;
         elsif oNew.code_cons_09 is null and iINDEX= 9 then oNew.code_cons_09:=pCODE_CONS; oNew.libe_cons_09:=vLIBE;oNew.cons_09:='858';if nvl(pREPA,'N')='O' then oNew.cons_repa_09:='O'; else oNew.cons_repa_09:='N';end if;
         elsif oNew.code_cons_10 is null and iINDEX=10 then oNew.code_cons_10:=pCODE_CONS; oNew.libe_cons_10:=vLIBE;oNew.cons_10:='859';if nvl(pREPA,'N')='O' then oNew.cons_repa_10:='O'; else oNew.cons_repa_10:='N';end if;
         elsif oNew.code_cons_11 is null and iINDEX=11 then oNew.code_cons_11:=pCODE_CONS; oNew.libe_cons_11:=vLIBE;oNew.cons_11:='860';if nvl(pREPA,'N')='O' then oNew.cons_repa_11:='O'; else oNew.cons_repa_11:='N';end if;
         elsif oNew.code_cons_12 is null and iINDEX=12 then oNew.code_cons_12:=pCODE_CONS; oNew.libe_cons_12:=vLIBE;oNew.cons_12:='861';if nvl(pREPA,'N')='O' then oNew.cons_repa_12:='O'; else oNew.cons_repa_12:='N';end if;
         elsif oNew.code_cons_13 is null and iINDEX=13 then oNew.code_cons_13:=pCODE_CONS; oNew.libe_cons_13:=vLIBE;oNew.cons_13:='862';if nvl(pREPA,'N')='O' then oNew.cons_repa_13:='O'; else oNew.cons_repa_13:='N';end if;
         elsif oNew.code_cons_14 is null and iINDEX=14 then oNew.code_cons_14:=pCODE_CONS; oNew.libe_cons_14:=vLIBE;oNew.cons_14:='863';if nvl(pREPA,'N')='O' then oNew.cons_repa_14:='O'; else oNew.cons_repa_14:='N';end if;
         elsif oNew.code_cons_15 is null and iINDEX=15 then oNew.code_cons_15:=pCODE_CONS; oNew.libe_cons_15:=vLIBE;oNew.cons_15:='864';if nvl(pREPA,'N')='O' then oNew.cons_repa_15:='O'; else oNew.cons_repa_15:='N';end if;
         elsif oNew.code_cons_16 is null and iINDEX=16 then oNew.code_cons_16:=pCODE_CONS; oNew.libe_cons_16:=vLIBE;oNew.cons_16:='865';if nvl(pREPA,'N')='O' then oNew.cons_repa_16:='O'; else oNew.cons_repa_16:='N';end if;
         elsif oNew.code_cons_17 is null and iINDEX=17 then oNew.code_cons_17:=pCODE_CONS; oNew.libe_cons_17:=vLIBE;oNew.cons_17:='866';if nvl(pREPA,'N')='O' then oNew.cons_repa_17:='O'; else oNew.cons_repa_17:='N';end if;
         elsif oNew.code_cons_18 is null and iINDEX=18 then oNew.code_cons_18:=pCODE_CONS; oNew.libe_cons_18:=vLIBE;oNew.cons_18:='867';if nvl(pREPA,'N')='O' then oNew.cons_repa_18:='O'; else oNew.cons_repa_18:='N';end if;
         elsif oNew.code_cons_19 is null and iINDEX=19 then oNew.code_cons_19:=pCODE_CONS; oNew.libe_cons_19:=vLIBE;oNew.cons_19:='868';if nvl(pREPA,'N')='O' then oNew.cons_repa_19:='O'; else oNew.cons_repa_19:='N';end if;
         elsif oNew.code_cons_20 is null and iINDEX=20 then oNew.code_cons_20:=pCODE_CONS; oNew.libe_cons_20:=vLIBE;oNew.cons_20:='869';if nvl(pREPA,'N')='O' then oNew.cons_repa_20:='O'; else oNew.cons_repa_20:='N';end if;

         elsif oNew_2.code_cons_21 is null and iINDEX=21 then oNew_2.code_cons_21:=pCODE_CONS; oNew_2.libe_cons_21:=vLIBE;oNew_2.cons_21:='870';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_21:='O'; else oNew_2.cons_repa_21:='N';end if;
         elsif oNew_2.code_cons_22 is null and iINDEX=22 then oNew_2.code_cons_22:=pCODE_CONS; oNew_2.libe_cons_22:=vLIBE;oNew_2.cons_22:='871';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_22:='O'; else oNew_2.cons_repa_22:='N';end if;
         elsif oNew_2.code_cons_23 is null and iINDEX=23 then oNew_2.code_cons_23:=pCODE_CONS; oNew_2.libe_cons_23:=vLIBE;oNew_2.cons_23:='872';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_23:='O'; else oNew_2.cons_repa_23:='N';end if;
         elsif oNew_2.code_cons_24 is null and iINDEX=24 then oNew_2.code_cons_24:=pCODE_CONS; oNew_2.libe_cons_24:=vLIBE;oNew_2.cons_24:='873';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_24:='O'; else oNew_2.cons_repa_24:='N';end if;
         elsif oNew_2.code_cons_25 is null and iINDEX=25 then oNew_2.code_cons_25:=pCODE_CONS; oNew_2.libe_cons_25:=vLIBE;oNew_2.cons_25:='874';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_25:='O'; else oNew_2.cons_repa_25:='N';end if;
         elsif oNew_2.code_cons_26 is null and iINDEX=26 then oNew_2.code_cons_26:=pCODE_CONS; oNew_2.libe_cons_26:=vLIBE;oNew_2.cons_26:='875';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_26:='O'; else oNew_2.cons_repa_26:='N';end if;
         elsif oNew_2.code_cons_27 is null and iINDEX=27 then oNew_2.code_cons_27:=pCODE_CONS; oNew_2.libe_cons_27:=vLIBE;oNew_2.cons_27:='876';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_27:='O'; else oNew_2.cons_repa_27:='N';end if;
         elsif oNew_2.code_cons_28 is null and iINDEX=28 then oNew_2.code_cons_28:=pCODE_CONS; oNew_2.libe_cons_28:=vLIBE;oNew_2.cons_28:='877';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_28:='O'; else oNew_2.cons_repa_28:='N';end if;
         elsif oNew_2.code_cons_29 is null and iINDEX=29 then oNew_2.code_cons_29:=pCODE_CONS; oNew_2.libe_cons_29:=vLIBE;oNew_2.cons_29:='878';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_29:='O'; else oNew_2.cons_repa_29:='N';end if;
         elsif oNew_2.code_cons_30 is null and iINDEX=30 then oNew_2.code_cons_30:=pCODE_CONS; oNew_2.libe_cons_30:=vLIBE;oNew_2.cons_30:='879';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_30:='O'; else oNew_2.cons_repa_30:='N';end if;
         elsif oNew_2.code_cons_31 is null and iINDEX=31 then oNew_2.code_cons_31:=pCODE_CONS; oNew_2.libe_cons_31:=vLIBE;oNew_2.cons_31:='880';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_31:='O'; else oNew_2.cons_repa_31:='N';end if;
         elsif oNew_2.code_cons_32 is null and iINDEX=32 then oNew_2.code_cons_32:=pCODE_CONS; oNew_2.libe_cons_32:=vLIBE;oNew_2.cons_32:='881';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_32:='O'; else oNew_2.cons_repa_32:='N';end if;
         elsif oNew_2.code_cons_33 is null and iINDEX=33 then oNew_2.code_cons_33:=pCODE_CONS; oNew_2.libe_cons_33:=vLIBE;oNew_2.cons_33:='882';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_33:='O'; else oNew_2.cons_repa_33:='N';end if;
         elsif oNew_2.code_cons_34 is null and iINDEX=34 then oNew_2.code_cons_34:=pCODE_CONS; oNew_2.libe_cons_34:=vLIBE;oNew_2.cons_34:='883';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_34:='O'; else oNew_2.cons_repa_34:='N';end if;
         elsif oNew_2.code_cons_35 is null and iINDEX=35 then oNew_2.code_cons_35:=pCODE_CONS; oNew_2.libe_cons_35:=vLIBE;oNew_2.cons_35:='884';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_35:='O'; else oNew_2.cons_repa_35:='N';end if;
         elsif oNew_2.code_cons_36 is null and iINDEX=36 then oNew_2.code_cons_36:=pCODE_CONS; oNew_2.libe_cons_36:=vLIBE;oNew_2.cons_36:='885';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_36:='O'; else oNew_2.cons_repa_36:='N';end if;
         elsif oNew_2.code_cons_37 is null and iINDEX=37 then oNew_2.code_cons_37:=pCODE_CONS; oNew_2.libe_cons_37:=vLIBE;oNew_2.cons_37:='886';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_37:='O'; else oNew_2.cons_repa_37:='N';end if;
         elsif oNew_2.code_cons_38 is null and iINDEX=38 then oNew_2.code_cons_38:=pCODE_CONS; oNew_2.libe_cons_38:=vLIBE;oNew_2.cons_38:='887';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_38:='O'; else oNew_2.cons_repa_38:='N';end if;
         elsif oNew_2.code_cons_39 is null and iINDEX=39 then oNew_2.code_cons_39:=pCODE_CONS; oNew_2.libe_cons_39:=vLIBE;oNew_2.cons_39:='888';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_39:='O'; else oNew_2.cons_repa_39:='N';end if;
         elsif oNew_2.code_cons_40 is null and iINDEX=40 then oNew_2.code_cons_40:=pCODE_CONS; oNew_2.libe_cons_40:=vLIBE;oNew_2.cons_40:='889';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_40:='O'; else oNew_2.cons_repa_40:='N';end if;
         elsif oNew_2.code_cons_41 is null and iINDEX=41 then oNew_2.code_cons_41:=pCODE_CONS; oNew_2.libe_cons_41:=vLIBE;oNew_2.cons_41:='890';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_41:='O'; else oNew_2.cons_repa_41:='N';end if;
         elsif oNew_2.code_cons_42 is null and iINDEX=42 then oNew_2.code_cons_42:=pCODE_CONS; oNew_2.libe_cons_42:=vLIBE;oNew_2.cons_42:='891';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_42:='O'; else oNew_2.cons_repa_42:='N';end if;
         elsif oNew_2.code_cons_43 is null and iINDEX=43 then oNew_2.code_cons_43:=pCODE_CONS; oNew_2.libe_cons_43:=vLIBE;oNew_2.cons_43:='892';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_43:='O'; else oNew_2.cons_repa_43:='N';end if;
         elsif oNew_2.code_cons_44 is null and iINDEX=44 then oNew_2.code_cons_44:=pCODE_CONS; oNew_2.libe_cons_44:=vLIBE;oNew_2.cons_44:='893';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_44:='O'; else oNew_2.cons_repa_44:='N';end if;
         elsif oNew_2.code_cons_45 is null and iINDEX=45 then oNew_2.code_cons_45:=pCODE_CONS; oNew_2.libe_cons_45:=vLIBE;oNew_2.cons_45:='894';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_45:='O'; else oNew_2.cons_repa_45:='N';end if;
         elsif oNew_2.code_cons_46 is null and iINDEX=46 then oNew_2.code_cons_46:=pCODE_CONS; oNew_2.libe_cons_46:=vLIBE;oNew_2.cons_46:='895';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_46:='O'; else oNew_2.cons_repa_46:='N';end if;
         elsif oNew_2.code_cons_47 is null and iINDEX=47 then oNew_2.code_cons_47:=pCODE_CONS; oNew_2.libe_cons_47:=vLIBE;oNew_2.cons_47:='896';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_47:='O'; else oNew_2.cons_repa_47:='N';end if;
         elsif oNew_2.code_cons_48 is null and iINDEX=48 then oNew_2.code_cons_48:=pCODE_CONS; oNew_2.libe_cons_48:=vLIBE;oNew_2.cons_48:='897';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_48:='O'; else oNew_2.cons_repa_48:='N';end if;
         elsif oNew_2.code_cons_49 is null and iINDEX=49 then oNew_2.code_cons_49:=pCODE_CONS; oNew_2.libe_cons_49:=vLIBE;oNew_2.cons_49:='898';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_49:='O'; else oNew_2.cons_repa_49:='N';end if;
         elsif oNew_2.code_cons_50 is null and iINDEX=50 then oNew_2.code_cons_50:=pCODE_CONS; oNew_2.libe_cons_50:=vLIBE;oNew_2.cons_50:='899';if nvl(pREPA,'N')='O' then oNew_2.cons_repa_50:='O'; else oNew_2.cons_repa_50:='N';end if;

         end if;
      end if;
   end pr_constante;

   procedure pr_rubrique(
      pID      varchar,
      pLIBE    varchar,
      pVALE    varchar,
      pCALC    varchar,
      pINDEX   varchar
   )
   is
      iINDEX   int;
      iRL_EXIS int;
      vGEAV_MONT varchar2(9);
      vTYPE      char(4);
      vID        varchar2(50);
   begin
   insert into debug_fabien values ('pSYNC_COMP',pSYNC_COMP); commit;
      iINDEX:=to_number(pINDEX);

      if trim(pID) is not null and trim(pID)!='-1' /* headers */ then
         if pVALE is null then
            errtools.pr_errlistadd(pXML,'GEAV_VALE_RUBR_'||pINDEX,'','','Vous devez saisir une valeur');
            return;
         end if;
         if trim(pLIBE) is null then
            errtools.pr_errlistadd(pXML,'GEAV_LIBE_RUBR_'||pINDEX,'','','Vous devez saisir un libellé');
            return;
         elsif length(pLIBE) > 20 then
            errtools.pr_errlistadd(pXML,'GEAV_LIBE_RUBR_'||pINDEX,'','','Le libellé est limité à 20 caractères');
            return;
         end if;
      end if;



      -- le id recu est de la forme 'TYPE:ID';
      vTYPE:=substr(pID,1,4);
      vID  :=substr(pID,6);

      if vTYPE='RUBR' then
         begin
            select
               decode(geav_mont,
                 'BA','BASE',
                 'NB','NOMB',
                 'TS','TAUX_SALA',
                 'TP','TAUX_PATR',
                 'MP','MONT_PATR',
                 'PL','PLAF',
                 'AS','ASSI',
                      'MONT_SALA'
               ),
               decode(rl.id_rubr,r.id_rubr,1,0)
            into
               vGEAV_MONT,
               iRL_EXIS
            from rubrique_lien rl,rubrique r
            where rl.id_rubr(+)=r.id_rubr
            and rl.id_soci(+)=iID_SOCI
            and r.id_rubr=vID
            and r.peri=dPERI;

            /*if pVALE=vGEAV_MONT then
              -- on met à jour rubrique_lien
                pr_pa_rubrique_lien_libe_geav(iID_SOCI, to_char( dPERI , 'DD/MM/YYYY') ,vID,trim(pLIBE));
            end if;*/


         exception
            when no_data_found then -- impossible !! la rubrique existe !!!
               -- si la rubrique n'existe pas... on ne met pas à jour rubrique_lien, ni liste_gestion_avancee
               return;
         end;
      elsif vTYPE='REGR' then
         if pVALE in ('TAUX_SALA','TAUX_PATR') then
            errtools.pr_errlistadd(pXML,'GEAV_VALE_RUBR_'||pINDEX,'','','Les regroupement en taux ne sont pas supportés');
            return;
         end if;
      end if;

         if oNew.id_rubr_01 is null and pINDEX= 1 then oNew.id_rubr_01:=vID;  oNew.libe_rubr_01:=pLIBE;  oNew.vale_rubr_01:=pVALE;  oNew_2.calc_rubr_01:=pCALC;  oNew.rubr_01:=vTYPE;
      elsif oNew.id_rubr_02 is null and pINDEX= 2 then oNew.id_rubr_02:=vID;  oNew.libe_rubr_02:=pLIBE;  oNew.vale_rubr_02:=pVALE;  oNew_2.calc_rubr_02:=pCALC;  oNew.rubr_02:=vTYPE;
      elsif oNew.id_rubr_03 is null and pINDEX= 3 then oNew.id_rubr_03:=vID;  oNew.libe_rubr_03:=pLIBE;  oNew.vale_rubr_03:=pVALE;  oNew_2.calc_rubr_03:=pCALC;  oNew.rubr_03:=vTYPE;
      elsif oNew.id_rubr_04 is null and pINDEX= 4 then oNew.id_rubr_04:=vID;  oNew.libe_rubr_04:=pLIBE;  oNew.vale_rubr_04:=pVALE;  oNew_2.calc_rubr_04:=pCALC;  oNew.rubr_04:=vTYPE;
      elsif oNew.id_rubr_05 is null and pINDEX= 5 then oNew.id_rubr_05:=vID;  oNew.libe_rubr_05:=pLIBE;  oNew.vale_rubr_05:=pVALE;  oNew_2.calc_rubr_05:=pCALC;  oNew.rubr_05:=vTYPE;
      elsif oNew.id_rubr_06 is null and pINDEX= 6 then oNew.id_rubr_06:=vID;  oNew.libe_rubr_06:=pLIBE;  oNew.vale_rubr_06:=pVALE;  oNew_2.calc_rubr_06:=pCALC;  oNew.rubr_06:=vTYPE;
      elsif oNew.id_rubr_07 is null and pINDEX= 7 then oNew.id_rubr_07:=vID;  oNew.libe_rubr_07:=pLIBE;  oNew.vale_rubr_07:=pVALE;  oNew_2.calc_rubr_07:=pCALC;  oNew.rubr_07:=vTYPE;
      elsif oNew.id_rubr_08 is null and pINDEX= 8 then oNew.id_rubr_08:=vID;  oNew.libe_rubr_08:=pLIBE;  oNew.vale_rubr_08:=pVALE;  oNew_2.calc_rubr_08:=pCALC;  oNew.rubr_08:=vTYPE;
      elsif oNew.id_rubr_09 is null and pINDEX= 9 then oNew.id_rubr_09:=vID;  oNew.libe_rubr_09:=pLIBE;  oNew.vale_rubr_09:=pVALE;  oNew_2.calc_rubr_09:=pCALC;  oNew.rubr_09:=vTYPE;
      elsif oNew.id_rubr_10 is null and pINDEX=10 then oNew.id_rubr_10:=vID;  oNew.libe_rubr_10:=pLIBE;  oNew.vale_rubr_10:=pVALE;  oNew_2.calc_rubr_10:=pCALC;  oNew.rubr_10:=vTYPE;
      elsif oNew.id_rubr_11 is null and pINDEX=11 then oNew.id_rubr_11:=vID;  oNew.libe_rubr_11:=pLIBE;  oNew.vale_rubr_11:=pVALE;  oNew_2.calc_rubr_11:=pCALC;  oNew.rubr_11:=vTYPE;
      elsif oNew.id_rubr_12 is null and pINDEX=12 then oNew.id_rubr_12:=vID;  oNew.libe_rubr_12:=pLIBE;  oNew.vale_rubr_12:=pVALE;  oNew_2.calc_rubr_12:=pCALC;  oNew.rubr_12:=vTYPE;
      elsif oNew.id_rubr_13 is null and pINDEX=13 then oNew.id_rubr_13:=vID;  oNew.libe_rubr_13:=pLIBE;  oNew.vale_rubr_13:=pVALE;  oNew_2.calc_rubr_13:=pCALC;  oNew.rubr_13:=vTYPE;
      elsif oNew.id_rubr_14 is null and pINDEX=14 then oNew.id_rubr_14:=vID;  oNew.libe_rubr_14:=pLIBE;  oNew.vale_rubr_14:=pVALE;  oNew_2.calc_rubr_14:=pCALC;  oNew.rubr_14:=vTYPE;
      elsif oNew.id_rubr_15 is null and pINDEX=15 then oNew.id_rubr_15:=vID;  oNew.libe_rubr_15:=pLIBE;  oNew.vale_rubr_15:=pVALE;  oNew_2.calc_rubr_15:=pCALC;  oNew.rubr_15:=vTYPE;
      elsif oNew.id_rubr_16 is null and pINDEX=16 then oNew.id_rubr_16:=vID;  oNew.libe_rubr_16:=pLIBE;  oNew.vale_rubr_16:=pVALE;  oNew_2.calc_rubr_16:=pCALC;  oNew.rubr_16:=vTYPE;
      elsif oNew.id_rubr_17 is null and pINDEX=17 then oNew.id_rubr_17:=vID;  oNew.libe_rubr_17:=pLIBE;  oNew.vale_rubr_17:=pVALE;  oNew_2.calc_rubr_17:=pCALC;  oNew.rubr_17:=vTYPE;
      elsif oNew.id_rubr_18 is null and pINDEX=18 then oNew.id_rubr_18:=vID;  oNew.libe_rubr_18:=pLIBE;  oNew.vale_rubr_18:=pVALE;  oNew_2.calc_rubr_18:=pCALC;  oNew.rubr_18:=vTYPE;
      elsif oNew.id_rubr_19 is null and pINDEX=19 then oNew.id_rubr_19:=vID;  oNew.libe_rubr_19:=pLIBE;  oNew.vale_rubr_19:=pVALE;  oNew_2.calc_rubr_19:=pCALC;  oNew.rubr_19:=vTYPE;
      elsif oNew.id_rubr_20 is null and pINDEX=20 then oNew.id_rubr_20:=vID;  oNew.libe_rubr_20:=pLIBE;  oNew.vale_rubr_20:=pVALE;  oNew_2.calc_rubr_20:=pCALC;  oNew.rubr_20:=vTYPE;
      elsif oNew.id_rubr_21 is null and pINDEX=21 then oNew.id_rubr_21:=vID;  oNew.libe_rubr_21:=pLIBE;  oNew.vale_rubr_21:=pVALE;  oNew_2.calc_rubr_21:=pCALC;  oNew.rubr_21:=vTYPE;
      elsif oNew.id_rubr_22 is null and pINDEX=22 then oNew.id_rubr_22:=vID;  oNew.libe_rubr_22:=pLIBE;  oNew.vale_rubr_22:=pVALE;  oNew_2.calc_rubr_22:=pCALC;  oNew.rubr_22:=vTYPE;
      elsif oNew.id_rubr_23 is null and pINDEX=23 then oNew.id_rubr_23:=vID;  oNew.libe_rubr_23:=pLIBE;  oNew.vale_rubr_23:=pVALE;  oNew_2.calc_rubr_23:=pCALC;  oNew.rubr_23:=vTYPE;
      elsif oNew.id_rubr_24 is null and pINDEX=24 then oNew.id_rubr_24:=vID;  oNew.libe_rubr_24:=pLIBE;  oNew.vale_rubr_24:=pVALE;  oNew_2.calc_rubr_24:=pCALC;  oNew.rubr_24:=vTYPE;
      elsif oNew.id_rubr_25 is null and pINDEX=25 then oNew.id_rubr_25:=vID;  oNew.libe_rubr_25:=pLIBE;  oNew.vale_rubr_25:=pVALE;  oNew_2.calc_rubr_25:=pCALC;  oNew.rubr_25:=vTYPE;
      elsif oNew.id_rubr_26 is null and pINDEX=26 then oNew.id_rubr_26:=vID;  oNew.libe_rubr_26:=pLIBE;  oNew.vale_rubr_26:=pVALE;  oNew_2.calc_rubr_26:=pCALC;  oNew.rubr_26:=vTYPE;
      elsif oNew.id_rubr_27 is null and pINDEX=27 then oNew.id_rubr_27:=vID;  oNew.libe_rubr_27:=pLIBE;  oNew.vale_rubr_27:=pVALE;  oNew_2.calc_rubr_27:=pCALC;  oNew.rubr_27:=vTYPE;
      elsif oNew.id_rubr_28 is null and pINDEX=28 then oNew.id_rubr_28:=vID;  oNew.libe_rubr_28:=pLIBE;  oNew.vale_rubr_28:=pVALE;  oNew_2.calc_rubr_28:=pCALC;  oNew.rubr_28:=vTYPE;
      elsif oNew.id_rubr_29 is null and pINDEX=29 then oNew.id_rubr_29:=vID;  oNew.libe_rubr_29:=pLIBE;  oNew.vale_rubr_29:=pVALE;  oNew_2.calc_rubr_29:=pCALC;  oNew.rubr_29:=vTYPE;
      elsif oNew.id_rubr_30 is null and pINDEX=30 then oNew.id_rubr_30:=vID;  oNew.libe_rubr_30:=pLIBE;  oNew.vale_rubr_30:=pVALE;  oNew_2.calc_rubr_30:=pCALC;  oNew.rubr_30:=vTYPE;
      elsif oNew.id_rubr_31 is null and pINDEX=31 then oNew.id_rubr_31:=vID;  oNew.libe_rubr_31:=pLIBE;  oNew.vale_rubr_31:=pVALE;  oNew_2.calc_rubr_31:=pCALC;  oNew.rubr_31:=vTYPE;
      elsif oNew.id_rubr_32 is null and pINDEX=32 then oNew.id_rubr_32:=vID;  oNew.libe_rubr_32:=pLIBE;  oNew.vale_rubr_32:=pVALE;  oNew_2.calc_rubr_32:=pCALC;  oNew.rubr_32:=vTYPE;
      elsif oNew.id_rubr_33 is null and pINDEX=33 then oNew.id_rubr_33:=vID;  oNew.libe_rubr_33:=pLIBE;  oNew.vale_rubr_33:=pVALE;  oNew_2.calc_rubr_33:=pCALC;  oNew.rubr_33:=vTYPE;
      elsif oNew.id_rubr_34 is null and pINDEX=34 then oNew.id_rubr_34:=vID;  oNew.libe_rubr_34:=pLIBE;  oNew.vale_rubr_34:=pVALE;  oNew_2.calc_rubr_34:=pCALC;  oNew.rubr_34:=vTYPE;
      elsif oNew.id_rubr_35 is null and pINDEX=35 then oNew.id_rubr_35:=vID;  oNew.libe_rubr_35:=pLIBE;  oNew.vale_rubr_35:=pVALE;  oNew_2.calc_rubr_35:=pCALC;  oNew.rubr_35:=vTYPE;
      elsif oNew.id_rubr_36 is null and pINDEX=36 then oNew.id_rubr_36:=vID;  oNew.libe_rubr_36:=pLIBE;  oNew.vale_rubr_36:=pVALE;  oNew_2.calc_rubr_36:=pCALC;  oNew.rubr_36:=vTYPE;
      elsif oNew.id_rubr_37 is null and pINDEX=37 then oNew.id_rubr_37:=vID;  oNew.libe_rubr_37:=pLIBE;  oNew.vale_rubr_37:=pVALE;  oNew_2.calc_rubr_37:=pCALC;  oNew.rubr_37:=vTYPE;
      elsif oNew.id_rubr_38 is null and pINDEX=38 then oNew.id_rubr_38:=vID;  oNew.libe_rubr_38:=pLIBE;  oNew.vale_rubr_38:=pVALE;  oNew_2.calc_rubr_38:=pCALC;  oNew.rubr_38:=vTYPE;
      elsif oNew.id_rubr_39 is null and pINDEX=39 then oNew.id_rubr_39:=vID;  oNew.libe_rubr_39:=pLIBE;  oNew.vale_rubr_39:=pVALE;  oNew_2.calc_rubr_39:=pCALC;  oNew.rubr_39:=vTYPE;
      elsif oNew.id_rubr_40 is null and pINDEX=40 then oNew.id_rubr_40:=vID;  oNew.libe_rubr_40:=pLIBE;  oNew.vale_rubr_40:=pVALE;  oNew_2.calc_rubr_40:=pCALC;  oNew.rubr_40:=vTYPE;
      elsif oNew.id_rubr_41 is null and pINDEX=41 then oNew.id_rubr_41:=vID;  oNew.libe_rubr_41:=pLIBE;  oNew.vale_rubr_41:=pVALE;  oNew_2.calc_rubr_41:=pCALC;  oNew.rubr_41:=vTYPE;
      elsif oNew.id_rubr_42 is null and pINDEX=42 then oNew.id_rubr_42:=vID;  oNew.libe_rubr_42:=pLIBE;  oNew.vale_rubr_42:=pVALE;  oNew_2.calc_rubr_42:=pCALC;  oNew.rubr_42:=vTYPE;
      elsif oNew.id_rubr_43 is null and pINDEX=43 then oNew.id_rubr_43:=vID;  oNew.libe_rubr_43:=pLIBE;  oNew.vale_rubr_43:=pVALE;  oNew_2.calc_rubr_43:=pCALC;  oNew.rubr_43:=vTYPE;
      elsif oNew.id_rubr_44 is null and pINDEX=44 then oNew.id_rubr_44:=vID;  oNew.libe_rubr_44:=pLIBE;  oNew.vale_rubr_44:=pVALE;  oNew_2.calc_rubr_44:=pCALC;  oNew.rubr_44:=vTYPE;
      elsif oNew.id_rubr_45 is null and pINDEX=45 then oNew.id_rubr_45:=vID;  oNew.libe_rubr_45:=pLIBE;  oNew.vale_rubr_45:=pVALE;  oNew_2.calc_rubr_45:=pCALC;  oNew.rubr_45:=vTYPE;
      elsif oNew.id_rubr_46 is null and pINDEX=46 then oNew.id_rubr_46:=vID;  oNew.libe_rubr_46:=pLIBE;  oNew.vale_rubr_46:=pVALE;  oNew_2.calc_rubr_46:=pCALC;  oNew.rubr_46:=vTYPE;
      elsif oNew.id_rubr_47 is null and pINDEX=47 then oNew.id_rubr_47:=vID;  oNew.libe_rubr_47:=pLIBE;  oNew.vale_rubr_47:=pVALE;  oNew_2.calc_rubr_47:=pCALC;  oNew.rubr_47:=vTYPE;
      elsif oNew.id_rubr_48 is null and pINDEX=48 then oNew.id_rubr_48:=vID;  oNew.libe_rubr_48:=pLIBE;  oNew.vale_rubr_48:=pVALE;  oNew_2.calc_rubr_48:=pCALC;  oNew.rubr_48:=vTYPE;
      elsif oNew.id_rubr_49 is null and pINDEX=49 then oNew.id_rubr_49:=vID;  oNew.libe_rubr_49:=pLIBE;  oNew.vale_rubr_49:=pVALE;  oNew_2.calc_rubr_49:=pCALC;  oNew.rubr_49:=vTYPE;
      elsif oNew.id_rubr_50 is null and pINDEX=50 then oNew.id_rubr_50:=vID;  oNew.libe_rubr_50:=pLIBE;  oNew.vale_rubr_50:=pVALE;  oNew_2.calc_rubr_50:=pCALC;  oNew.rubr_50:=vTYPE;

      elsif oNew_2.id_rubr_51 is null and pINDEX=51 then oNew_2.id_rubr_51:=vID;  oNew_2.libe_rubr_51:=pLIBE;  oNew_2.vale_rubr_51:=pVALE;  oNew_2.calc_rubr_51:=pCALC;  oNew_2.rubr_51:=vTYPE;
      elsif oNew_2.id_rubr_52 is null and pINDEX=52 then oNew_2.id_rubr_52:=vID;  oNew_2.libe_rubr_52:=pLIBE;  oNew_2.vale_rubr_52:=pVALE;  oNew_2.calc_rubr_52:=pCALC;  oNew_2.rubr_52:=vTYPE;
      elsif oNew_2.id_rubr_53 is null and pINDEX=53 then oNew_2.id_rubr_53:=vID;  oNew_2.libe_rubr_53:=pLIBE;  oNew_2.vale_rubr_53:=pVALE;  oNew_2.calc_rubr_53:=pCALC;  oNew_2.rubr_53:=vTYPE;
      elsif oNew_2.id_rubr_54 is null and pINDEX=54 then oNew_2.id_rubr_54:=vID;  oNew_2.libe_rubr_54:=pLIBE;  oNew_2.vale_rubr_54:=pVALE;  oNew_2.calc_rubr_54:=pCALC;  oNew_2.rubr_54:=vTYPE;
      elsif oNew_2.id_rubr_55 is null and pINDEX=55 then oNew_2.id_rubr_55:=vID;  oNew_2.libe_rubr_55:=pLIBE;  oNew_2.vale_rubr_55:=pVALE;  oNew_2.calc_rubr_55:=pCALC;  oNew_2.rubr_55:=vTYPE;
      elsif oNew_2.id_rubr_56 is null and pINDEX=56 then oNew_2.id_rubr_56:=vID;  oNew_2.libe_rubr_56:=pLIBE;  oNew_2.vale_rubr_56:=pVALE;  oNew_2.calc_rubr_56:=pCALC;  oNew_2.rubr_56:=vTYPE;
      elsif oNew_2.id_rubr_57 is null and pINDEX=57 then oNew_2.id_rubr_57:=vID;  oNew_2.libe_rubr_57:=pLIBE;  oNew_2.vale_rubr_57:=pVALE;  oNew_2.calc_rubr_57:=pCALC;  oNew_2.rubr_57:=vTYPE;
      elsif oNew_2.id_rubr_58 is null and pINDEX=58 then oNew_2.id_rubr_58:=vID;  oNew_2.libe_rubr_58:=pLIBE;  oNew_2.vale_rubr_58:=pVALE;  oNew_2.calc_rubr_58:=pCALC;  oNew_2.rubr_58:=vTYPE;
      elsif oNew_2.id_rubr_59 is null and pINDEX=59 then oNew_2.id_rubr_59:=vID;  oNew_2.libe_rubr_59:=pLIBE;  oNew_2.vale_rubr_59:=pVALE;  oNew_2.calc_rubr_59:=pCALC;  oNew_2.rubr_59:=vTYPE;
      elsif oNew_2.id_rubr_60 is null and pINDEX=60 then oNew_2.id_rubr_60:=vID;  oNew_2.libe_rubr_60:=pLIBE;  oNew_2.vale_rubr_60:=pVALE;  oNew_2.calc_rubr_60:=pCALC;  oNew_2.rubr_60:=vTYPE;
      elsif oNew_2.id_rubr_61 is null and pINDEX=61 then oNew_2.id_rubr_61:=vID;  oNew_2.libe_rubr_61:=pLIBE;  oNew_2.vale_rubr_61:=pVALE;  oNew_2.calc_rubr_61:=pCALC;  oNew_2.rubr_61:=vTYPE;
      elsif oNew_2.id_rubr_62 is null and pINDEX=62 then oNew_2.id_rubr_62:=vID;  oNew_2.libe_rubr_62:=pLIBE;  oNew_2.vale_rubr_62:=pVALE;  oNew_2.calc_rubr_62:=pCALC;  oNew_2.rubr_62:=vTYPE;
      elsif oNew_2.id_rubr_63 is null and pINDEX=63 then oNew_2.id_rubr_63:=vID;  oNew_2.libe_rubr_63:=pLIBE;  oNew_2.vale_rubr_63:=pVALE;  oNew_2.calc_rubr_63:=pCALC;  oNew_2.rubr_63:=vTYPE;
      elsif oNew_2.id_rubr_64 is null and pINDEX=64 then oNew_2.id_rubr_64:=vID;  oNew_2.libe_rubr_64:=pLIBE;  oNew_2.vale_rubr_64:=pVALE;  oNew_2.calc_rubr_64:=pCALC;  oNew_2.rubr_64:=vTYPE;
      elsif oNew_2.id_rubr_65 is null and pINDEX=65 then oNew_2.id_rubr_65:=vID;  oNew_2.libe_rubr_65:=pLIBE;  oNew_2.vale_rubr_65:=pVALE;  oNew_2.calc_rubr_65:=pCALC;  oNew_2.rubr_65:=vTYPE;
      elsif oNew_2.id_rubr_66 is null and pINDEX=66 then oNew_2.id_rubr_66:=vID;  oNew_2.libe_rubr_66:=pLIBE;  oNew_2.vale_rubr_66:=pVALE;  oNew_2.calc_rubr_66:=pCALC;  oNew_2.rubr_66:=vTYPE;
      elsif oNew_2.id_rubr_67 is null and pINDEX=67 then oNew_2.id_rubr_67:=vID;  oNew_2.libe_rubr_67:=pLIBE;  oNew_2.vale_rubr_67:=pVALE;  oNew_2.calc_rubr_67:=pCALC;  oNew_2.rubr_67:=vTYPE;
      elsif oNew_2.id_rubr_68 is null and pINDEX=68 then oNew_2.id_rubr_68:=vID;  oNew_2.libe_rubr_68:=pLIBE;  oNew_2.vale_rubr_68:=pVALE;  oNew_2.calc_rubr_68:=pCALC;  oNew_2.rubr_68:=vTYPE;
      elsif oNew_2.id_rubr_69 is null and pINDEX=69 then oNew_2.id_rubr_69:=vID;  oNew_2.libe_rubr_69:=pLIBE;  oNew_2.vale_rubr_69:=pVALE;  oNew_2.calc_rubr_69:=pCALC;  oNew_2.rubr_69:=vTYPE;
      elsif oNew_2.id_rubr_70 is null and pINDEX=70 then oNew_2.id_rubr_70:=vID;  oNew_2.libe_rubr_70:=pLIBE;  oNew_2.vale_rubr_70:=pVALE;  oNew_2.calc_rubr_70:=pCALC;  oNew_2.rubr_70:=vTYPE;
      elsif oNew_2.id_rubr_71 is null and pINDEX=71 then oNew_2.id_rubr_71:=vID;  oNew_2.libe_rubr_71:=pLIBE;  oNew_2.vale_rubr_71:=pVALE;  oNew_2.calc_rubr_71:=pCALC;  oNew_2.rubr_71:=vTYPE;
      elsif oNew_2.id_rubr_72 is null and pINDEX=72 then oNew_2.id_rubr_72:=vID;  oNew_2.libe_rubr_72:=pLIBE;  oNew_2.vale_rubr_72:=pVALE;  oNew_2.calc_rubr_72:=pCALC;  oNew_2.rubr_72:=vTYPE;
      elsif oNew_2.id_rubr_73 is null and pINDEX=73 then oNew_2.id_rubr_73:=vID;  oNew_2.libe_rubr_73:=pLIBE;  oNew_2.vale_rubr_73:=pVALE;  oNew_2.calc_rubr_73:=pCALC;  oNew_2.rubr_73:=vTYPE;
      elsif oNew_2.id_rubr_74 is null and pINDEX=74 then oNew_2.id_rubr_74:=vID;  oNew_2.libe_rubr_74:=pLIBE;  oNew_2.vale_rubr_74:=pVALE;  oNew_2.calc_rubr_74:=pCALC;  oNew_2.rubr_74:=vTYPE;
      elsif oNew_2.id_rubr_75 is null and pINDEX=75 then oNew_2.id_rubr_75:=vID;  oNew_2.libe_rubr_75:=pLIBE;  oNew_2.vale_rubr_75:=pVALE;  oNew_2.calc_rubr_75:=pCALC;  oNew_2.rubr_75:=vTYPE;
      elsif oNew_2.id_rubr_76 is null and pINDEX=76 then oNew_2.id_rubr_76:=vID;  oNew_2.libe_rubr_76:=pLIBE;  oNew_2.vale_rubr_76:=pVALE;  oNew_2.calc_rubr_76:=pCALC;  oNew_2.rubr_76:=vTYPE;
      elsif oNew_2.id_rubr_77 is null and pINDEX=77 then oNew_2.id_rubr_77:=vID;  oNew_2.libe_rubr_77:=pLIBE;  oNew_2.vale_rubr_77:=pVALE;  oNew_2.calc_rubr_77:=pCALC;  oNew_2.rubr_77:=vTYPE;
      elsif oNew_2.id_rubr_78 is null and pINDEX=78 then oNew_2.id_rubr_78:=vID;  oNew_2.libe_rubr_78:=pLIBE;  oNew_2.vale_rubr_78:=pVALE;  oNew_2.calc_rubr_78:=pCALC;  oNew_2.rubr_78:=vTYPE;
      elsif oNew_2.id_rubr_79 is null and pINDEX=79 then oNew_2.id_rubr_79:=vID;  oNew_2.libe_rubr_79:=pLIBE;  oNew_2.vale_rubr_79:=pVALE;  oNew_2.calc_rubr_79:=pCALC;  oNew_2.rubr_79:=vTYPE;
      elsif oNew_2.id_rubr_80 is null and pINDEX=80 then oNew_2.id_rubr_80:=vID;  oNew_2.libe_rubr_80:=pLIBE;  oNew_2.vale_rubr_80:=pVALE;  oNew_2.calc_rubr_80:=pCALC;  oNew_2.rubr_80:=vTYPE;
      elsif oNew_2.id_rubr_81 is null and pINDEX=81 then oNew_2.id_rubr_81:=vID;  oNew_2.libe_rubr_81:=pLIBE;  oNew_2.vale_rubr_81:=pVALE;  oNew_2.calc_rubr_81:=pCALC;  oNew_2.rubr_81:=vTYPE;
      elsif oNew_2.id_rubr_82 is null and pINDEX=82 then oNew_2.id_rubr_82:=vID;  oNew_2.libe_rubr_82:=pLIBE;  oNew_2.vale_rubr_82:=pVALE;  oNew_2.calc_rubr_82:=pCALC;  oNew_2.rubr_82:=vTYPE;
      elsif oNew_2.id_rubr_83 is null and pINDEX=83 then oNew_2.id_rubr_83:=vID;  oNew_2.libe_rubr_83:=pLIBE;  oNew_2.vale_rubr_83:=pVALE;  oNew_2.calc_rubr_83:=pCALC;  oNew_2.rubr_83:=vTYPE;
      elsif oNew_2.id_rubr_84 is null and pINDEX=84 then oNew_2.id_rubr_84:=vID;  oNew_2.libe_rubr_84:=pLIBE;  oNew_2.vale_rubr_84:=pVALE;  oNew_2.calc_rubr_84:=pCALC;  oNew_2.rubr_84:=vTYPE;
      elsif oNew_2.id_rubr_85 is null and pINDEX=85 then oNew_2.id_rubr_85:=vID;  oNew_2.libe_rubr_85:=pLIBE;  oNew_2.vale_rubr_85:=pVALE;  oNew_2.calc_rubr_85:=pCALC;  oNew_2.rubr_85:=vTYPE;
      elsif oNew_2.id_rubr_86 is null and pINDEX=86 then oNew_2.id_rubr_86:=vID;  oNew_2.libe_rubr_86:=pLIBE;  oNew_2.vale_rubr_86:=pVALE;  oNew_2.calc_rubr_86:=pCALC;  oNew_2.rubr_86:=vTYPE;
      elsif oNew_2.id_rubr_87 is null and pINDEX=87 then oNew_2.id_rubr_87:=vID;  oNew_2.libe_rubr_87:=pLIBE;  oNew_2.vale_rubr_87:=pVALE;  oNew_2.calc_rubr_87:=pCALC;  oNew_2.rubr_87:=vTYPE;
      elsif oNew_2.id_rubr_88 is null and pINDEX=88 then oNew_2.id_rubr_88:=vID;  oNew_2.libe_rubr_88:=pLIBE;  oNew_2.vale_rubr_88:=pVALE;  oNew_2.calc_rubr_88:=pCALC;  oNew_2.rubr_88:=vTYPE;
      elsif oNew_2.id_rubr_89 is null and pINDEX=89 then oNew_2.id_rubr_89:=vID;  oNew_2.libe_rubr_89:=pLIBE;  oNew_2.vale_rubr_89:=pVALE;  oNew_2.calc_rubr_89:=pCALC;  oNew_2.rubr_89:=vTYPE;
      elsif oNew_2.id_rubr_90 is null and pINDEX=90 then oNew_2.id_rubr_90:=vID;  oNew_2.libe_rubr_90:=pLIBE;  oNew_2.vale_rubr_90:=pVALE;  oNew_2.calc_rubr_90:=pCALC;  oNew_2.rubr_90:=vTYPE;
      elsif oNew_2.id_rubr_91 is null and pINDEX=91 then oNew_2.id_rubr_91:=vID;  oNew_2.libe_rubr_91:=pLIBE;  oNew_2.vale_rubr_91:=pVALE;  oNew_2.calc_rubr_91:=pCALC;  oNew_2.rubr_91:=vTYPE;
      elsif oNew_2.id_rubr_92 is null and pINDEX=92 then oNew_2.id_rubr_92:=vID;  oNew_2.libe_rubr_92:=pLIBE;  oNew_2.vale_rubr_92:=pVALE;  oNew_2.calc_rubr_92:=pCALC;  oNew_2.rubr_92:=vTYPE;
      elsif oNew_2.id_rubr_93 is null and pINDEX=93 then oNew_2.id_rubr_93:=vID;  oNew_2.libe_rubr_93:=pLIBE;  oNew_2.vale_rubr_93:=pVALE;  oNew_2.calc_rubr_93:=pCALC;  oNew_2.rubr_93:=vTYPE;
      elsif oNew_2.id_rubr_94 is null and pINDEX=94 then oNew_2.id_rubr_94:=vID;  oNew_2.libe_rubr_94:=pLIBE;  oNew_2.vale_rubr_94:=pVALE;  oNew_2.calc_rubr_94:=pCALC;  oNew_2.rubr_94:=vTYPE;
      elsif oNew_2.id_rubr_95 is null and pINDEX=95 then oNew_2.id_rubr_95:=vID;  oNew_2.libe_rubr_95:=pLIBE;  oNew_2.vale_rubr_95:=pVALE;  oNew_2.calc_rubr_95:=pCALC;  oNew_2.rubr_95:=vTYPE;
      elsif oNew_2.id_rubr_96 is null and pINDEX=96 then oNew_2.id_rubr_96:=vID;  oNew_2.libe_rubr_96:=pLIBE;  oNew_2.vale_rubr_96:=pVALE;  oNew_2.calc_rubr_96:=pCALC;  oNew_2.rubr_96:=vTYPE;
      elsif oNew_2.id_rubr_97 is null and pINDEX=97 then oNew_2.id_rubr_97:=vID;  oNew_2.libe_rubr_97:=pLIBE;  oNew_2.vale_rubr_97:=pVALE;  oNew_2.calc_rubr_97:=pCALC;  oNew_2.rubr_97:=vTYPE;
      elsif oNew_2.id_rubr_98 is null and pINDEX=98 then oNew_2.id_rubr_98:=vID;  oNew_2.libe_rubr_98:=pLIBE;  oNew_2.vale_rubr_98:=pVALE;  oNew_2.calc_rubr_98:=pCALC;  oNew_2.rubr_98:=vTYPE;
      elsif oNew_2.id_rubr_99 is null and pINDEX=99 then oNew_2.id_rubr_99:=vID;  oNew_2.libe_rubr_99:=pLIBE;  oNew_2.vale_rubr_99:=pVALE;  oNew_2.calc_rubr_99:=pCALC;  oNew_2.rubr_99:=vTYPE;
      elsif oNew_2.id_rubr_100 is null and pINDEX=100 then oNew_2.id_rubr_100:=vID;  oNew_2.libe_rubr_100:=pLIBE;  oNew_2.vale_rubr_100:=pVALE;  oNew_2.calc_rubr_100:=pCALC;  oNew_2.rubr_100:=vTYPE;
      elsif oNew_2.id_rubr_101 is null and pINDEX=101 then oNew_2.id_rubr_101:=vID;  oNew_2.libe_rubr_101:=pLIBE;  oNew_2.vale_rubr_101:=pVALE;  oNew_2.calc_rubr_101:=pCALC;  oNew_2.rubr_101:=vTYPE;
      elsif oNew_2.id_rubr_102 is null and pINDEX=102 then oNew_2.id_rubr_102:=vID;  oNew_2.libe_rubr_102:=pLIBE;  oNew_2.vale_rubr_102:=pVALE;  oNew_2.calc_rubr_102:=pCALC;  oNew_2.rubr_102:=vTYPE;
      elsif oNew_2.id_rubr_103 is null and pINDEX=103 then oNew_2.id_rubr_103:=vID;  oNew_2.libe_rubr_103:=pLIBE;  oNew_2.vale_rubr_103:=pVALE;  oNew_2.calc_rubr_103:=pCALC;  oNew_2.rubr_103:=vTYPE;
      elsif oNew_2.id_rubr_104 is null and pINDEX=104 then oNew_2.id_rubr_104:=vID;  oNew_2.libe_rubr_104:=pLIBE;  oNew_2.vale_rubr_104:=pVALE;  oNew_2.calc_rubr_104:=pCALC;  oNew_2.rubr_104:=vTYPE;
      elsif oNew_2.id_rubr_105 is null and pINDEX=105 then oNew_2.id_rubr_105:=vID;  oNew_2.libe_rubr_105:=pLIBE;  oNew_2.vale_rubr_105:=pVALE;  oNew_2.calc_rubr_105:=pCALC;  oNew_2.rubr_105:=vTYPE;
      elsif oNew_2.id_rubr_106 is null and pINDEX=106 then oNew_2.id_rubr_106:=vID;  oNew_2.libe_rubr_106:=pLIBE;  oNew_2.vale_rubr_106:=pVALE;  oNew_2.calc_rubr_106:=pCALC;  oNew_2.rubr_106:=vTYPE;
      elsif oNew_2.id_rubr_107 is null and pINDEX=107 then oNew_2.id_rubr_107:=vID;  oNew_2.libe_rubr_107:=pLIBE;  oNew_2.vale_rubr_107:=pVALE;  oNew_2.calc_rubr_107:=pCALC;  oNew_2.rubr_107:=vTYPE;
      elsif oNew_2.id_rubr_108 is null and pINDEX=108 then oNew_2.id_rubr_108:=vID;  oNew_2.libe_rubr_108:=pLIBE;  oNew_2.vale_rubr_108:=pVALE;  oNew_2.calc_rubr_108:=pCALC;  oNew_2.rubr_108:=vTYPE;
      elsif oNew_2.id_rubr_109 is null and pINDEX=109 then oNew_2.id_rubr_109:=vID;  oNew_2.libe_rubr_109:=pLIBE;  oNew_2.vale_rubr_109:=pVALE;  oNew_2.calc_rubr_109:=pCALC;  oNew_2.rubr_109:=vTYPE;
      elsif oNew_2.id_rubr_110 is null and pINDEX=110 then oNew_2.id_rubr_110:=vID;  oNew_2.libe_rubr_110:=pLIBE;  oNew_2.vale_rubr_110:=pVALE;  oNew_2.calc_rubr_110:=pCALC;  oNew_2.rubr_110:=vTYPE;
      elsif oNew_2.id_rubr_111 is null and pINDEX=111 then oNew_2.id_rubr_111:=vID;  oNew_2.libe_rubr_111:=pLIBE;  oNew_2.vale_rubr_111:=pVALE;  oNew_2.calc_rubr_111:=pCALC;  oNew_2.rubr_111:=vTYPE;
      elsif oNew_2.id_rubr_112 is null and pINDEX=112 then oNew_2.id_rubr_112:=vID;  oNew_2.libe_rubr_112:=pLIBE;  oNew_2.vale_rubr_112:=pVALE;  oNew_2.calc_rubr_112:=pCALC;  oNew_2.rubr_112:=vTYPE;
      elsif oNew_2.id_rubr_113 is null and pINDEX=113 then oNew_2.id_rubr_113:=vID;  oNew_2.libe_rubr_113:=pLIBE;  oNew_2.vale_rubr_113:=pVALE;  oNew_2.calc_rubr_113:=pCALC;  oNew_2.rubr_113:=vTYPE;
      elsif oNew_2.id_rubr_114 is null and pINDEX=114 then oNew_2.id_rubr_114:=vID;  oNew_2.libe_rubr_114:=pLIBE;  oNew_2.vale_rubr_114:=pVALE;  oNew_2.calc_rubr_114:=pCALC;  oNew_2.rubr_114:=vTYPE;
      elsif oNew_2.id_rubr_115 is null and pINDEX=115 then oNew_2.id_rubr_115:=vID;  oNew_2.libe_rubr_115:=pLIBE;  oNew_2.vale_rubr_115:=pVALE;  oNew_2.calc_rubr_115:=pCALC;  oNew_2.rubr_115:=vTYPE;
      elsif oNew_2.id_rubr_116 is null and pINDEX=116 then oNew_2.id_rubr_116:=vID;  oNew_2.libe_rubr_116:=pLIBE;  oNew_2.vale_rubr_116:=pVALE;  oNew_2.calc_rubr_116:=pCALC;  oNew_2.rubr_116:=vTYPE;
      elsif oNew_2.id_rubr_117 is null and pINDEX=117 then oNew_2.id_rubr_117:=vID;  oNew_2.libe_rubr_117:=pLIBE;  oNew_2.vale_rubr_117:=pVALE;  oNew_2.calc_rubr_117:=pCALC;  oNew_2.rubr_117:=vTYPE;
      elsif oNew_2.id_rubr_118 is null and pINDEX=118 then oNew_2.id_rubr_118:=vID;  oNew_2.libe_rubr_118:=pLIBE;  oNew_2.vale_rubr_118:=pVALE;  oNew_2.calc_rubr_118:=pCALC;  oNew_2.rubr_118:=vTYPE;
      elsif oNew_2.id_rubr_119 is null and pINDEX=119 then oNew_2.id_rubr_119:=vID;  oNew_2.libe_rubr_119:=pLIBE;  oNew_2.vale_rubr_119:=pVALE;  oNew_2.calc_rubr_119:=pCALC;  oNew_2.rubr_119:=vTYPE;
      elsif oNew_2.id_rubr_120 is null and pINDEX=120 then oNew_2.id_rubr_120:=vID;  oNew_2.libe_rubr_120:=pLIBE;  oNew_2.vale_rubr_120:=pVALE;  oNew_2.calc_rubr_120:=pCALC;  oNew_2.rubr_120:=vTYPE;
      elsif oNew_2.id_rubr_121 is null and pINDEX=121 then oNew_2.id_rubr_121:=vID;  oNew_2.libe_rubr_121:=pLIBE;  oNew_2.vale_rubr_121:=pVALE;  oNew_2.calc_rubr_121:=pCALC;  oNew_2.rubr_121:=vTYPE;
      elsif oNew_2.id_rubr_122 is null and pINDEX=122 then oNew_2.id_rubr_122:=vID;  oNew_2.libe_rubr_122:=pLIBE;  oNew_2.vale_rubr_122:=pVALE;  oNew_2.calc_rubr_122:=pCALC;  oNew_2.rubr_122:=vTYPE;
      elsif oNew_2.id_rubr_123 is null and pINDEX=123 then oNew_2.id_rubr_123:=vID;  oNew_2.libe_rubr_123:=pLIBE;  oNew_2.vale_rubr_123:=pVALE;  oNew_2.calc_rubr_123:=pCALC;  oNew_2.rubr_123:=vTYPE;
      elsif oNew_2.id_rubr_124 is null and pINDEX=124 then oNew_2.id_rubr_124:=vID;  oNew_2.libe_rubr_124:=pLIBE;  oNew_2.vale_rubr_124:=pVALE;  oNew_2.calc_rubr_124:=pCALC;  oNew_2.rubr_124:=vTYPE;
      elsif oNew_2.id_rubr_125 is null and pINDEX=125 then oNew_2.id_rubr_125:=vID;  oNew_2.libe_rubr_125:=pLIBE;  oNew_2.vale_rubr_125:=pVALE;  oNew_2.calc_rubr_125:=pCALC;  oNew_2.rubr_125:=vTYPE;
      elsif oNew_2.id_rubr_126 is null and pINDEX=126 then oNew_2.id_rubr_126:=vID;  oNew_2.libe_rubr_126:=pLIBE;  oNew_2.vale_rubr_126:=pVALE;  oNew_2.calc_rubr_126:=pCALC;  oNew_2.rubr_126:=vTYPE;
      elsif oNew_2.id_rubr_127 is null and pINDEX=127 then oNew_2.id_rubr_127:=vID;  oNew_2.libe_rubr_127:=pLIBE;  oNew_2.vale_rubr_127:=pVALE;  oNew_2.calc_rubr_127:=pCALC;  oNew_2.rubr_127:=vTYPE;
      elsif oNew_2.id_rubr_128 is null and pINDEX=128 then oNew_2.id_rubr_128:=vID;  oNew_2.libe_rubr_128:=pLIBE;  oNew_2.vale_rubr_128:=pVALE;  oNew_2.calc_rubr_128:=pCALC;  oNew_2.rubr_128:=vTYPE;
      elsif oNew_2.id_rubr_129 is null and pINDEX=129 then oNew_2.id_rubr_129:=vID;  oNew_2.libe_rubr_129:=pLIBE;  oNew_2.vale_rubr_129:=pVALE;  oNew_2.calc_rubr_129:=pCALC;  oNew_2.rubr_129:=vTYPE;
      elsif oNew_2.id_rubr_130 is null and pINDEX=130 then oNew_2.id_rubr_130:=vID;  oNew_2.libe_rubr_130:=pLIBE;  oNew_2.vale_rubr_130:=pVALE;  oNew_2.calc_rubr_130:=pCALC;  oNew_2.rubr_130:=vTYPE;
      elsif oNew_2.id_rubr_131 is null and pINDEX=131 then oNew_2.id_rubr_131:=vID;  oNew_2.libe_rubr_131:=pLIBE;  oNew_2.vale_rubr_131:=pVALE;  oNew_2.calc_rubr_131:=pCALC;  oNew_2.rubr_131:=vTYPE;
      elsif oNew_2.id_rubr_132 is null and pINDEX=132 then oNew_2.id_rubr_132:=vID;  oNew_2.libe_rubr_132:=pLIBE;  oNew_2.vale_rubr_132:=pVALE;  oNew_2.calc_rubr_132:=pCALC;  oNew_2.rubr_132:=vTYPE;
      elsif oNew_2.id_rubr_133 is null and pINDEX=133 then oNew_2.id_rubr_133:=vID;  oNew_2.libe_rubr_133:=pLIBE;  oNew_2.vale_rubr_133:=pVALE;  oNew_2.calc_rubr_133:=pCALC;  oNew_2.rubr_133:=vTYPE;
      elsif oNew_2.id_rubr_134 is null and pINDEX=134 then oNew_2.id_rubr_134:=vID;  oNew_2.libe_rubr_134:=pLIBE;  oNew_2.vale_rubr_134:=pVALE;  oNew_2.calc_rubr_134:=pCALC;  oNew_2.rubr_134:=vTYPE;
      elsif oNew_2.id_rubr_135 is null and pINDEX=135 then oNew_2.id_rubr_135:=vID;  oNew_2.libe_rubr_135:=pLIBE;  oNew_2.vale_rubr_135:=pVALE;  oNew_2.calc_rubr_135:=pCALC;  oNew_2.rubr_135:=vTYPE;
      elsif oNew_2.id_rubr_136 is null and pINDEX=136 then oNew_2.id_rubr_136:=vID;  oNew_2.libe_rubr_136:=pLIBE;  oNew_2.vale_rubr_136:=pVALE;  oNew_2.calc_rubr_136:=pCALC;  oNew_2.rubr_136:=vTYPE;
      elsif oNew_2.id_rubr_137 is null and pINDEX=137 then oNew_2.id_rubr_137:=vID;  oNew_2.libe_rubr_137:=pLIBE;  oNew_2.vale_rubr_137:=pVALE;  oNew_2.calc_rubr_137:=pCALC;  oNew_2.rubr_137:=vTYPE;
      elsif oNew_2.id_rubr_138 is null and pINDEX=138 then oNew_2.id_rubr_138:=vID;  oNew_2.libe_rubr_138:=pLIBE;  oNew_2.vale_rubr_138:=pVALE;  oNew_2.calc_rubr_138:=pCALC;  oNew_2.rubr_138:=vTYPE;
      elsif oNew_2.id_rubr_139 is null and pINDEX=139 then oNew_2.id_rubr_139:=vID;  oNew_2.libe_rubr_139:=pLIBE;  oNew_2.vale_rubr_139:=pVALE;  oNew_2.calc_rubr_139:=pCALC;  oNew_2.rubr_139:=vTYPE;
      elsif oNew_2.id_rubr_140 is null and pINDEX=140 then oNew_2.id_rubr_140:=vID;  oNew_2.libe_rubr_140:=pLIBE;  oNew_2.vale_rubr_140:=pVALE;  oNew_2.calc_rubr_140:=pCALC;  oNew_2.rubr_140:=vTYPE;
      elsif oNew_2.id_rubr_141 is null and pINDEX=141 then oNew_2.id_rubr_141:=vID;  oNew_2.libe_rubr_141:=pLIBE;  oNew_2.vale_rubr_141:=pVALE;  oNew_2.calc_rubr_141:=pCALC;  oNew_2.rubr_141:=vTYPE;
      elsif oNew_2.id_rubr_142 is null and pINDEX=142 then oNew_2.id_rubr_142:=vID;  oNew_2.libe_rubr_142:=pLIBE;  oNew_2.vale_rubr_142:=pVALE;  oNew_2.calc_rubr_142:=pCALC;  oNew_2.rubr_142:=vTYPE;
      elsif oNew_2.id_rubr_143 is null and pINDEX=143 then oNew_2.id_rubr_143:=vID;  oNew_2.libe_rubr_143:=pLIBE;  oNew_2.vale_rubr_143:=pVALE;  oNew_2.calc_rubr_143:=pCALC;  oNew_2.rubr_143:=vTYPE;
      elsif oNew_2.id_rubr_144 is null and pINDEX=144 then oNew_2.id_rubr_144:=vID;  oNew_2.libe_rubr_144:=pLIBE;  oNew_2.vale_rubr_144:=pVALE;  oNew_2.calc_rubr_144:=pCALC;  oNew_2.rubr_144:=vTYPE;
      elsif oNew_2.id_rubr_145 is null and pINDEX=145 then oNew_2.id_rubr_145:=vID;  oNew_2.libe_rubr_145:=pLIBE;  oNew_2.vale_rubr_145:=pVALE;  oNew_2.calc_rubr_145:=pCALC;  oNew_2.rubr_145:=vTYPE;
      elsif oNew_2.id_rubr_146 is null and pINDEX=146 then oNew_2.id_rubr_146:=vID;  oNew_2.libe_rubr_146:=pLIBE;  oNew_2.vale_rubr_146:=pVALE;  oNew_2.calc_rubr_146:=pCALC;  oNew_2.rubr_146:=vTYPE;
      elsif oNew_2.id_rubr_147 is null and pINDEX=147 then oNew_2.id_rubr_147:=vID;  oNew_2.libe_rubr_147:=pLIBE;  oNew_2.vale_rubr_147:=pVALE;  oNew_2.calc_rubr_147:=pCALC;  oNew_2.rubr_147:=vTYPE;
      elsif oNew_2.id_rubr_148 is null and pINDEX=148 then oNew_2.id_rubr_148:=vID;  oNew_2.libe_rubr_148:=pLIBE;  oNew_2.vale_rubr_148:=pVALE;  oNew_2.calc_rubr_148:=pCALC;  oNew_2.rubr_148:=vTYPE;
      elsif oNew_2.id_rubr_149 is null and pINDEX=149 then oNew_2.id_rubr_149:=vID;  oNew_2.libe_rubr_149:=pLIBE;  oNew_2.vale_rubr_149:=pVALE;  oNew_2.calc_rubr_149:=pCALC;  oNew_2.rubr_149:=vTYPE;
      elsif oNew_2.id_rubr_150 is null and pINDEX=150 then oNew_2.id_rubr_150:=vID;  oNew_2.libe_rubr_150:=pLIBE;  oNew_2.vale_rubr_150:=pVALE;  oNew_2.calc_rubr_150:=pCALC;  oNew_2.rubr_150:=vTYPE;
      end if;
   end pr_rubrique;




begin
      iID_SOCI:=parse_int(pID_SOCI);
      iID_LOGI:=parse_int(pID_LOGI);
      iID_LIST:=parse_int(pID_LIST);
      pXML := null;

      pr_para_grou_test(iID_SOCI,'LIST_GEAV',pID_LIST,pXML);



      pID_New := iID_LIST;

      select
         max(peri_paie)
      into
         dPERI
      from periode
      where id_soci=iID_SOCI;


      begin
         select
            *
         into
            oList
         from v_liste_etat_colonnes_list
         where id_list=fct_liste_etat_colonnes_modi(iID_SOCI,iID_LOGI,vETAT,pID_LIST,'N')
           and acce_id_soci=iID_SOCI
           and prop_id_soci=iID_SOCI
         ;
      exception
         when no_data_found then
            -- IMPOSSIBLE !!!!!!
            errtools.session_create(pXML , 'SESS_ID_LOGI','','remove');
            errtools.pr_errlistfinal(pXML, Err);
            return;

      end
      ;

      select
         count(*)
      into
         iNB
      from  liste_gestion_avancee
      where id_list=iID_LIST
      ;

      if iNB=0 then
         strAction := 'CREE';
      else -- Modification
         strAction := 'MODI';

         select
            *
         into
            oOld
         from liste_gestion_avancee
         where id_list=iID_LIST
         ;
      end if;

      pr_constante(pCODE_CONS_01,pLIBE_CONS_01,'01',pCONS_REPA_01);
      pr_constante(pCODE_CONS_02,pLIBE_CONS_02,'02',pCONS_REPA_02);
      pr_constante(pCODE_CONS_03,pLIBE_CONS_03,'03',pCONS_REPA_03);
      pr_constante(pCODE_CONS_04,pLIBE_CONS_04,'04',pCONS_REPA_04);
      pr_constante(pCODE_CONS_05,pLIBE_CONS_05,'05',pCONS_REPA_05);
      pr_constante(pCODE_CONS_06,pLIBE_CONS_06,'06',pCONS_REPA_06);
      pr_constante(pCODE_CONS_07,pLIBE_CONS_07,'07',pCONS_REPA_07);
      pr_constante(pCODE_CONS_08,pLIBE_CONS_08,'08',pCONS_REPA_08);
      pr_constante(pCODE_CONS_09,pLIBE_CONS_09,'09',pCONS_REPA_09);
      pr_constante(pCODE_CONS_10,pLIBE_CONS_10,'10',pCONS_REPA_10);
      pr_constante(pCODE_CONS_11,pLIBE_CONS_11,'11',pCONS_REPA_11);
      pr_constante(pCODE_CONS_12,pLIBE_CONS_12,'12',pCONS_REPA_12);
      pr_constante(pCODE_CONS_13,pLIBE_CONS_13,'13',pCONS_REPA_13);
      pr_constante(pCODE_CONS_14,pLIBE_CONS_14,'14',pCONS_REPA_14);
      pr_constante(pCODE_CONS_15,pLIBE_CONS_15,'15',pCONS_REPA_15);
      pr_constante(pCODE_CONS_16,pLIBE_CONS_16,'16',pCONS_REPA_16);
      pr_constante(pCODE_CONS_17,pLIBE_CONS_17,'17',pCONS_REPA_17);
      pr_constante(pCODE_CONS_18,pLIBE_CONS_18,'18',pCONS_REPA_18);
      pr_constante(pCODE_CONS_19,pLIBE_CONS_19,'19',pCONS_REPA_19);
      pr_constante(pCODE_CONS_20,pLIBE_CONS_20,'20',pCONS_REPA_20);

      pr_constante(pCODE_CONS_21,pLIBE_CONS_21,'21',pCONS_REPA_21);
      pr_constante(pCODE_CONS_22,pLIBE_CONS_22,'22',pCONS_REPA_22);
      pr_constante(pCODE_CONS_23,pLIBE_CONS_23,'23',pCONS_REPA_23);
      pr_constante(pCODE_CONS_24,pLIBE_CONS_24,'24',pCONS_REPA_24);
      pr_constante(pCODE_CONS_25,pLIBE_CONS_25,'25',pCONS_REPA_25);
      pr_constante(pCODE_CONS_26,pLIBE_CONS_26,'26',pCONS_REPA_26);
      pr_constante(pCODE_CONS_27,pLIBE_CONS_27,'27',pCONS_REPA_27);
      pr_constante(pCODE_CONS_28,pLIBE_CONS_28,'28',pCONS_REPA_28);
      pr_constante(pCODE_CONS_29,pLIBE_CONS_29,'29',pCONS_REPA_29);
      pr_constante(pCODE_CONS_30,pLIBE_CONS_30,'30',pCONS_REPA_30);
      pr_constante(pCODE_CONS_31,pLIBE_CONS_31,'31',pCONS_REPA_31);
      pr_constante(pCODE_CONS_32,pLIBE_CONS_32,'32',pCONS_REPA_32);
      pr_constante(pCODE_CONS_33,pLIBE_CONS_33,'33',pCONS_REPA_33);
      pr_constante(pCODE_CONS_34,pLIBE_CONS_34,'34',pCONS_REPA_34);
      pr_constante(pCODE_CONS_35,pLIBE_CONS_35,'35',pCONS_REPA_35);
      pr_constante(pCODE_CONS_36,pLIBE_CONS_36,'36',pCONS_REPA_36);
      pr_constante(pCODE_CONS_37,pLIBE_CONS_37,'37',pCONS_REPA_37);
      pr_constante(pCODE_CONS_38,pLIBE_CONS_38,'38',pCONS_REPA_38);
      pr_constante(pCODE_CONS_39,pLIBE_CONS_39,'39',pCONS_REPA_39);
      pr_constante(pCODE_CONS_40,pLIBE_CONS_40,'40',pCONS_REPA_40);
      pr_constante(pCODE_CONS_41,pLIBE_CONS_41,'41',pCONS_REPA_41);
      pr_constante(pCODE_CONS_42,pLIBE_CONS_42,'42',pCONS_REPA_42);
      pr_constante(pCODE_CONS_43,pLIBE_CONS_43,'43',pCONS_REPA_43);
      pr_constante(pCODE_CONS_44,pLIBE_CONS_44,'44',pCONS_REPA_44);
      pr_constante(pCODE_CONS_45,pLIBE_CONS_45,'45',pCONS_REPA_45);
      pr_constante(pCODE_CONS_46,pLIBE_CONS_46,'46',pCONS_REPA_46);
      pr_constante(pCODE_CONS_47,pLIBE_CONS_47,'47',pCONS_REPA_47);
      pr_constante(pCODE_CONS_48,pLIBE_CONS_48,'48',pCONS_REPA_48);
      pr_constante(pCODE_CONS_49,pLIBE_CONS_49,'49',pCONS_REPA_49);
      pr_constante(pCODE_CONS_50,pLIBE_CONS_50,'50',pCONS_REPA_50);

      pr_rubrique(pID_RUBR_01  , pLIBE_RUBR_01 ,pVALE_RUBR_01 , pCALC_RUBR_01 , '1' );
      pr_rubrique(pID_RUBR_02  , pLIBE_RUBR_02 ,pVALE_RUBR_02 , pCALC_RUBR_02 , '2' );
      pr_rubrique(pID_RUBR_03  , pLIBE_RUBR_03 ,pVALE_RUBR_03 , pCALC_RUBR_03 , '3' );
      pr_rubrique(pID_RUBR_04  , pLIBE_RUBR_04 ,pVALE_RUBR_04 , pCALC_RUBR_04 , '4' );
      pr_rubrique(pID_RUBR_05  , pLIBE_RUBR_05 ,pVALE_RUBR_05 , pCALC_RUBR_05 , '5' );
      pr_rubrique(pID_RUBR_06  , pLIBE_RUBR_06 ,pVALE_RUBR_06 , pCALC_RUBR_06 , '6' );
      pr_rubrique(pID_RUBR_07  , pLIBE_RUBR_07 ,pVALE_RUBR_07 , pCALC_RUBR_07 , '7' );
      pr_rubrique(pID_RUBR_08  , pLIBE_RUBR_08 ,pVALE_RUBR_08 , pCALC_RUBR_08 , '8' );
      pr_rubrique(pID_RUBR_09  , pLIBE_RUBR_09 ,pVALE_RUBR_09 , pCALC_RUBR_09 , '9' );
      pr_rubrique(pID_RUBR_10  , pLIBE_RUBR_10 ,pVALE_RUBR_10 , pCALC_RUBR_10 , '10');
      pr_rubrique(pID_RUBR_11  , pLIBE_RUBR_11 ,pVALE_RUBR_11 , pCALC_RUBR_11 , '11');
      pr_rubrique(pID_RUBR_12  , pLIBE_RUBR_12 ,pVALE_RUBR_12 , pCALC_RUBR_12 , '12');
      pr_rubrique(pID_RUBR_13  , pLIBE_RUBR_13 ,pVALE_RUBR_13 , pCALC_RUBR_13 , '13');
      pr_rubrique(pID_RUBR_14  , pLIBE_RUBR_14 ,pVALE_RUBR_14 , pCALC_RUBR_14 , '14');
      pr_rubrique(pID_RUBR_15  , pLIBE_RUBR_15 ,pVALE_RUBR_15 , pCALC_RUBR_15 , '15');
      pr_rubrique(pID_RUBR_16  , pLIBE_RUBR_16 ,pVALE_RUBR_16 , pCALC_RUBR_16 , '16');
      pr_rubrique(pID_RUBR_17  , pLIBE_RUBR_17 ,pVALE_RUBR_17 , pCALC_RUBR_17 , '17');
      pr_rubrique(pID_RUBR_18  , pLIBE_RUBR_18 ,pVALE_RUBR_18 , pCALC_RUBR_18 , '18');
      pr_rubrique(pID_RUBR_19  , pLIBE_RUBR_19 ,pVALE_RUBR_19 , pCALC_RUBR_19 , '19');
      pr_rubrique(pID_RUBR_20  , pLIBE_RUBR_20 ,pVALE_RUBR_20 , pCALC_RUBR_20 , '20');
      pr_rubrique(pID_RUBR_21  , pLIBE_RUBR_21 ,pVALE_RUBR_21 , pCALC_RUBR_21 , '21');
      pr_rubrique(pID_RUBR_22  , pLIBE_RUBR_22 ,pVALE_RUBR_22 , pCALC_RUBR_22 , '22');
      pr_rubrique(pID_RUBR_23  , pLIBE_RUBR_23 ,pVALE_RUBR_23 , pCALC_RUBR_23 , '23');
      pr_rubrique(pID_RUBR_24  , pLIBE_RUBR_24 ,pVALE_RUBR_24 , pCALC_RUBR_24 , '24');
      pr_rubrique(pID_RUBR_25  , pLIBE_RUBR_25 ,pVALE_RUBR_25 , pCALC_RUBR_25 , '25');
      pr_rubrique(pID_RUBR_26  , pLIBE_RUBR_26 ,pVALE_RUBR_26 , pCALC_RUBR_26 , '26');
      pr_rubrique(pID_RUBR_27  , pLIBE_RUBR_27 ,pVALE_RUBR_27 , pCALC_RUBR_27 , '27');
      pr_rubrique(pID_RUBR_28  , pLIBE_RUBR_28 ,pVALE_RUBR_28 , pCALC_RUBR_28 , '28');
      pr_rubrique(pID_RUBR_29  , pLIBE_RUBR_29 ,pVALE_RUBR_29 , pCALC_RUBR_29 , '29');
      pr_rubrique(pID_RUBR_30  , pLIBE_RUBR_30 ,pVALE_RUBR_30 , pCALC_RUBR_30 , '30');
      pr_rubrique(pID_RUBR_31  , pLIBE_RUBR_31 ,pVALE_RUBR_31 , pCALC_RUBR_31 , '31');
      pr_rubrique(pID_RUBR_32  , pLIBE_RUBR_32 ,pVALE_RUBR_32 , pCALC_RUBR_32 , '32');
      pr_rubrique(pID_RUBR_33  , pLIBE_RUBR_33 ,pVALE_RUBR_33 , pCALC_RUBR_33 , '33');
      pr_rubrique(pID_RUBR_34  , pLIBE_RUBR_34 ,pVALE_RUBR_34 , pCALC_RUBR_34 , '34');
      pr_rubrique(pID_RUBR_35  , pLIBE_RUBR_35 ,pVALE_RUBR_35 , pCALC_RUBR_35 , '35');
      pr_rubrique(pID_RUBR_36  , pLIBE_RUBR_36 ,pVALE_RUBR_36 , pCALC_RUBR_36 , '36');
      pr_rubrique(pID_RUBR_37  , pLIBE_RUBR_37 ,pVALE_RUBR_37 , pCALC_RUBR_37 , '37');
      pr_rubrique(pID_RUBR_38  , pLIBE_RUBR_38 ,pVALE_RUBR_38 , pCALC_RUBR_38 , '38');
      pr_rubrique(pID_RUBR_39  , pLIBE_RUBR_39 ,pVALE_RUBR_39 , pCALC_RUBR_39 , '39');
      pr_rubrique(pID_RUBR_40  , pLIBE_RUBR_40 ,pVALE_RUBR_40 , pCALC_RUBR_40 , '40');
      pr_rubrique(pID_RUBR_41  , pLIBE_RUBR_41 ,pVALE_RUBR_41 , pCALC_RUBR_41 , '41');
      pr_rubrique(pID_RUBR_42  , pLIBE_RUBR_42 ,pVALE_RUBR_42 , pCALC_RUBR_42 , '42');
      pr_rubrique(pID_RUBR_43  , pLIBE_RUBR_43 ,pVALE_RUBR_43 , pCALC_RUBR_43 , '43');
      pr_rubrique(pID_RUBR_44  , pLIBE_RUBR_44 ,pVALE_RUBR_44 , pCALC_RUBR_44 , '44');
      pr_rubrique(pID_RUBR_45  , pLIBE_RUBR_45 ,pVALE_RUBR_45 , pCALC_RUBR_45 , '45');
      pr_rubrique(pID_RUBR_46  , pLIBE_RUBR_46 ,pVALE_RUBR_46 , pCALC_RUBR_46 , '46');
      pr_rubrique(pID_RUBR_47  , pLIBE_RUBR_47 ,pVALE_RUBR_47 , pCALC_RUBR_47 , '47');
      pr_rubrique(pID_RUBR_48  , pLIBE_RUBR_48 ,pVALE_RUBR_48 , pCALC_RUBR_48 , '48');
      pr_rubrique(pID_RUBR_49  , pLIBE_RUBR_49 ,pVALE_RUBR_49 , pCALC_RUBR_49 , '49');
      pr_rubrique(pID_RUBR_50  , pLIBE_RUBR_50 ,pVALE_RUBR_50 , pCALC_RUBR_50 , '50');

      pr_rubrique(pID_RUBR_51  , pLIBE_RUBR_51 ,pVALE_RUBR_51 , pCALC_RUBR_51 , '51' );
      pr_rubrique(pID_RUBR_52  , pLIBE_RUBR_52 ,pVALE_RUBR_52 , pCALC_RUBR_52 , '52' );
      pr_rubrique(pID_RUBR_53  , pLIBE_RUBR_53 ,pVALE_RUBR_53 , pCALC_RUBR_53 , '53' );
      pr_rubrique(pID_RUBR_54  , pLIBE_RUBR_54 ,pVALE_RUBR_54 , pCALC_RUBR_54 , '54' );
      pr_rubrique(pID_RUBR_55  , pLIBE_RUBR_55 ,pVALE_RUBR_55 , pCALC_RUBR_55 , '55' );
      pr_rubrique(pID_RUBR_56  , pLIBE_RUBR_56 ,pVALE_RUBR_56 , pCALC_RUBR_56 , '56' );
      pr_rubrique(pID_RUBR_57  , pLIBE_RUBR_57 ,pVALE_RUBR_57 , pCALC_RUBR_57 , '57' );
      pr_rubrique(pID_RUBR_58  , pLIBE_RUBR_58 ,pVALE_RUBR_58 , pCALC_RUBR_58 , '58' );
      pr_rubrique(pID_RUBR_59  , pLIBE_RUBR_59 ,pVALE_RUBR_59 , pCALC_RUBR_59 , '59' );
      pr_rubrique(pID_RUBR_60  , pLIBE_RUBR_60 ,pVALE_RUBR_60 , pCALC_RUBR_60 , '60');
      pr_rubrique(pID_RUBR_61  , pLIBE_RUBR_61 ,pVALE_RUBR_61 , pCALC_RUBR_61 , '61');
      pr_rubrique(pID_RUBR_62  , pLIBE_RUBR_62 ,pVALE_RUBR_62 , pCALC_RUBR_62 , '62');
      pr_rubrique(pID_RUBR_63  , pLIBE_RUBR_63 ,pVALE_RUBR_63 , pCALC_RUBR_63 , '63');
      pr_rubrique(pID_RUBR_64  , pLIBE_RUBR_64 ,pVALE_RUBR_64 , pCALC_RUBR_64 , '64');
      pr_rubrique(pID_RUBR_65  , pLIBE_RUBR_65 ,pVALE_RUBR_65 , pCALC_RUBR_65 , '65');
      pr_rubrique(pID_RUBR_66  , pLIBE_RUBR_66 ,pVALE_RUBR_66 , pCALC_RUBR_66 , '66');
      pr_rubrique(pID_RUBR_67  , pLIBE_RUBR_67 ,pVALE_RUBR_67 , pCALC_RUBR_67 , '67');
      pr_rubrique(pID_RUBR_68  , pLIBE_RUBR_68 ,pVALE_RUBR_68 , pCALC_RUBR_68 , '68');
      pr_rubrique(pID_RUBR_69  , pLIBE_RUBR_69 ,pVALE_RUBR_69 , pCALC_RUBR_69 , '69');
      pr_rubrique(pID_RUBR_70  , pLIBE_RUBR_70 ,pVALE_RUBR_70 , pCALC_RUBR_70 , '70');
      pr_rubrique(pID_RUBR_71  , pLIBE_RUBR_71 ,pVALE_RUBR_71 , pCALC_RUBR_71 , '71');
      pr_rubrique(pID_RUBR_72  , pLIBE_RUBR_72 ,pVALE_RUBR_72 , pCALC_RUBR_72 , '72');
      pr_rubrique(pID_RUBR_73  , pLIBE_RUBR_73 ,pVALE_RUBR_73 , pCALC_RUBR_73 , '73');
      pr_rubrique(pID_RUBR_74  , pLIBE_RUBR_74 ,pVALE_RUBR_74 , pCALC_RUBR_74 , '74');
      pr_rubrique(pID_RUBR_75  , pLIBE_RUBR_75 ,pVALE_RUBR_75 , pCALC_RUBR_75 , '75');
      pr_rubrique(pID_RUBR_76  , pLIBE_RUBR_76 ,pVALE_RUBR_76 , pCALC_RUBR_76 , '76');
      pr_rubrique(pID_RUBR_77  , pLIBE_RUBR_77 ,pVALE_RUBR_77 , pCALC_RUBR_77 , '77');
      pr_rubrique(pID_RUBR_78  , pLIBE_RUBR_78 ,pVALE_RUBR_78 , pCALC_RUBR_78 , '78');
      pr_rubrique(pID_RUBR_79  , pLIBE_RUBR_79 ,pVALE_RUBR_79 , pCALC_RUBR_79 , '79');
      pr_rubrique(pID_RUBR_80  , pLIBE_RUBR_80 ,pVALE_RUBR_80 , pCALC_RUBR_80 , '80');
      pr_rubrique(pID_RUBR_81  , pLIBE_RUBR_81 ,pVALE_RUBR_81 , pCALC_RUBR_81 , '81');
      pr_rubrique(pID_RUBR_82  , pLIBE_RUBR_82 ,pVALE_RUBR_82 , pCALC_RUBR_82 , '82');
      pr_rubrique(pID_RUBR_83  , pLIBE_RUBR_83 ,pVALE_RUBR_83 , pCALC_RUBR_83 , '83');
      pr_rubrique(pID_RUBR_84  , pLIBE_RUBR_84 ,pVALE_RUBR_84 , pCALC_RUBR_84 , '84');
      pr_rubrique(pID_RUBR_85  , pLIBE_RUBR_85 ,pVALE_RUBR_85 , pCALC_RUBR_85 , '85');
      pr_rubrique(pID_RUBR_86  , pLIBE_RUBR_86 ,pVALE_RUBR_86 , pCALC_RUBR_86 , '86');
      pr_rubrique(pID_RUBR_87  , pLIBE_RUBR_87 ,pVALE_RUBR_87 , pCALC_RUBR_87 , '87');
      pr_rubrique(pID_RUBR_88  , pLIBE_RUBR_88 ,pVALE_RUBR_88 , pCALC_RUBR_88 , '88');
      pr_rubrique(pID_RUBR_89  , pLIBE_RUBR_89 ,pVALE_RUBR_89 , pCALC_RUBR_89 , '89');
      pr_rubrique(pID_RUBR_90  , pLIBE_RUBR_90 ,pVALE_RUBR_90 , pCALC_RUBR_90 , '90');
      pr_rubrique(pID_RUBR_91  , pLIBE_RUBR_91 ,pVALE_RUBR_91 , pCALC_RUBR_91 , '91');
      pr_rubrique(pID_RUBR_92  , pLIBE_RUBR_92 ,pVALE_RUBR_92 , pCALC_RUBR_92 , '92');
      pr_rubrique(pID_RUBR_93  , pLIBE_RUBR_93 ,pVALE_RUBR_93 , pCALC_RUBR_93 , '93');
      pr_rubrique(pID_RUBR_94  , pLIBE_RUBR_94 ,pVALE_RUBR_94 , pCALC_RUBR_94 , '94');
      pr_rubrique(pID_RUBR_95  , pLIBE_RUBR_95 ,pVALE_RUBR_95 , pCALC_RUBR_95 , '95');
      pr_rubrique(pID_RUBR_96  , pLIBE_RUBR_96 ,pVALE_RUBR_96 , pCALC_RUBR_96 , '96');
      pr_rubrique(pID_RUBR_97  , pLIBE_RUBR_97 ,pVALE_RUBR_97 , pCALC_RUBR_97 , '97');
      pr_rubrique(pID_RUBR_98  , pLIBE_RUBR_98 ,pVALE_RUBR_98 , pCALC_RUBR_98 , '98');
      pr_rubrique(pID_RUBR_99  , pLIBE_RUBR_99 ,pVALE_RUBR_99 , pCALC_RUBR_99 , '99');
      pr_rubrique(pID_RUBR_100  , pLIBE_RUBR_100 ,pVALE_RUBR_100 , pCALC_RUBR_100 , '100');
      pr_rubrique(pID_RUBR_101  , pLIBE_RUBR_101 ,pVALE_RUBR_101 , pCALC_RUBR_101 , '101' );
      pr_rubrique(pID_RUBR_102  , pLIBE_RUBR_102 ,pVALE_RUBR_102 , pCALC_RUBR_102 , '102' );
      pr_rubrique(pID_RUBR_103  , pLIBE_RUBR_103 ,pVALE_RUBR_103 , pCALC_RUBR_103 , '103' );
      pr_rubrique(pID_RUBR_104  , pLIBE_RUBR_104 ,pVALE_RUBR_104 , pCALC_RUBR_104 , '104' );
      pr_rubrique(pID_RUBR_105  , pLIBE_RUBR_105 ,pVALE_RUBR_105 , pCALC_RUBR_105 , '105' );
      pr_rubrique(pID_RUBR_106  , pLIBE_RUBR_106 ,pVALE_RUBR_106 , pCALC_RUBR_106 , '106' );
      pr_rubrique(pID_RUBR_107  , pLIBE_RUBR_107 ,pVALE_RUBR_107 , pCALC_RUBR_107 , '107' );
      pr_rubrique(pID_RUBR_108  , pLIBE_RUBR_108 ,pVALE_RUBR_108 , pCALC_RUBR_108 , '108' );
      pr_rubrique(pID_RUBR_109  , pLIBE_RUBR_109 ,pVALE_RUBR_109 , pCALC_RUBR_109 , '109' );
      pr_rubrique(pID_RUBR_110  , pLIBE_RUBR_110 ,pVALE_RUBR_110 , pCALC_RUBR_110 , '110');
      pr_rubrique(pID_RUBR_111  , pLIBE_RUBR_111 ,pVALE_RUBR_111 , pCALC_RUBR_111 , '111');
      pr_rubrique(pID_RUBR_112  , pLIBE_RUBR_112 ,pVALE_RUBR_112 , pCALC_RUBR_112 , '112');
      pr_rubrique(pID_RUBR_113  , pLIBE_RUBR_113 ,pVALE_RUBR_113 , pCALC_RUBR_113 , '113');
      pr_rubrique(pID_RUBR_114  , pLIBE_RUBR_114 ,pVALE_RUBR_114 , pCALC_RUBR_114 , '114');
      pr_rubrique(pID_RUBR_115  , pLIBE_RUBR_115 ,pVALE_RUBR_115 , pCALC_RUBR_115 , '115');
      pr_rubrique(pID_RUBR_116  , pLIBE_RUBR_116 ,pVALE_RUBR_116 , pCALC_RUBR_116 , '116');
      pr_rubrique(pID_RUBR_117  , pLIBE_RUBR_117 ,pVALE_RUBR_117 , pCALC_RUBR_117 , '117');
      pr_rubrique(pID_RUBR_118  , pLIBE_RUBR_118 ,pVALE_RUBR_118 , pCALC_RUBR_118 , '118');
      pr_rubrique(pID_RUBR_119  , pLIBE_RUBR_119 ,pVALE_RUBR_119 , pCALC_RUBR_119 , '119');
      pr_rubrique(pID_RUBR_120  , pLIBE_RUBR_120 ,pVALE_RUBR_120 , pCALC_RUBR_120 , '120');
      pr_rubrique(pID_RUBR_121  , pLIBE_RUBR_121 ,pVALE_RUBR_121 , pCALC_RUBR_121 , '121');
      pr_rubrique(pID_RUBR_122  , pLIBE_RUBR_122 ,pVALE_RUBR_122 , pCALC_RUBR_122 , '122');
      pr_rubrique(pID_RUBR_123  , pLIBE_RUBR_123 ,pVALE_RUBR_123 , pCALC_RUBR_123 , '123');
      pr_rubrique(pID_RUBR_124  , pLIBE_RUBR_124 ,pVALE_RUBR_124 , pCALC_RUBR_124 , '124');
      pr_rubrique(pID_RUBR_125  , pLIBE_RUBR_125 ,pVALE_RUBR_125 , pCALC_RUBR_125 , '125');
      pr_rubrique(pID_RUBR_126  , pLIBE_RUBR_126 ,pVALE_RUBR_126 , pCALC_RUBR_126 , '126');
      pr_rubrique(pID_RUBR_127  , pLIBE_RUBR_127 ,pVALE_RUBR_127 , pCALC_RUBR_127 , '127');
      pr_rubrique(pID_RUBR_128  , pLIBE_RUBR_128 ,pVALE_RUBR_128 , pCALC_RUBR_128 , '128');
      pr_rubrique(pID_RUBR_129  , pLIBE_RUBR_129 ,pVALE_RUBR_129 , pCALC_RUBR_129 , '129');
      pr_rubrique(pID_RUBR_130  , pLIBE_RUBR_130 ,pVALE_RUBR_130 , pCALC_RUBR_130 , '130');
      pr_rubrique(pID_RUBR_131  , pLIBE_RUBR_131 ,pVALE_RUBR_131 , pCALC_RUBR_131 , '131');
      pr_rubrique(pID_RUBR_132  , pLIBE_RUBR_132 ,pVALE_RUBR_132 , pCALC_RUBR_132 , '132');
      pr_rubrique(pID_RUBR_133  , pLIBE_RUBR_133 ,pVALE_RUBR_133 , pCALC_RUBR_133 , '133');
      pr_rubrique(pID_RUBR_134  , pLIBE_RUBR_134 ,pVALE_RUBR_134 , pCALC_RUBR_134 , '134');
      pr_rubrique(pID_RUBR_135  , pLIBE_RUBR_135 ,pVALE_RUBR_135 , pCALC_RUBR_135 , '135');
      pr_rubrique(pID_RUBR_136  , pLIBE_RUBR_136 ,pVALE_RUBR_136 , pCALC_RUBR_136 , '136');
      pr_rubrique(pID_RUBR_137  , pLIBE_RUBR_137 ,pVALE_RUBR_137 , pCALC_RUBR_137 , '137');
      pr_rubrique(pID_RUBR_138  , pLIBE_RUBR_138 ,pVALE_RUBR_138 , pCALC_RUBR_138 , '138');
      pr_rubrique(pID_RUBR_139  , pLIBE_RUBR_139 ,pVALE_RUBR_139 , pCALC_RUBR_139 , '139');
      pr_rubrique(pID_RUBR_140  , pLIBE_RUBR_140 ,pVALE_RUBR_140 , pCALC_RUBR_140 , '140');
      pr_rubrique(pID_RUBR_141  , pLIBE_RUBR_141 ,pVALE_RUBR_141 , pCALC_RUBR_141 , '141');
      pr_rubrique(pID_RUBR_142  , pLIBE_RUBR_142 ,pVALE_RUBR_142 , pCALC_RUBR_142 , '142');
      pr_rubrique(pID_RUBR_143  , pLIBE_RUBR_143 ,pVALE_RUBR_143 , pCALC_RUBR_143 , '143');
      pr_rubrique(pID_RUBR_144  , pLIBE_RUBR_144 ,pVALE_RUBR_144 , pCALC_RUBR_144 , '144');
      pr_rubrique(pID_RUBR_145  , pLIBE_RUBR_145 ,pVALE_RUBR_145 , pCALC_RUBR_145 , '145');
      pr_rubrique(pID_RUBR_146  , pLIBE_RUBR_146 ,pVALE_RUBR_146 , pCALC_RUBR_146 , '146');
      pr_rubrique(pID_RUBR_147  , pLIBE_RUBR_147 ,pVALE_RUBR_147 , pCALC_RUBR_147 , '147');
      pr_rubrique(pID_RUBR_148  , pLIBE_RUBR_148 ,pVALE_RUBR_148 , pCALC_RUBR_148 , '148');
      pr_rubrique(pID_RUBR_149  , pLIBE_RUBR_149 ,pVALE_RUBR_149 , pCALC_RUBR_149 , '149');
      pr_rubrique(pID_RUBR_150  , pLIBE_RUBR_150 ,pVALE_RUBR_150 , pCALC_RUBR_150 , '150');


      pr__calcul('01',pCALC_01_OPERANDE_1,pCALC_01_OPERATEUR,pCALC_01_OPERANDE_2,pCALC_01_MULT,pCALC_01_LIBE,pCALC_01_DECI);
      pr__calcul('02',pCALC_02_OPERANDE_1,pCALC_02_OPERATEUR,pCALC_02_OPERANDE_2,pCALC_02_MULT,pCALC_02_LIBE,pCALC_02_DECI);
      pr__calcul('03',pCALC_03_OPERANDE_1,pCALC_03_OPERATEUR,pCALC_03_OPERANDE_2,pCALC_03_MULT,pCALC_03_LIBE,pCALC_03_DECI);
      pr__calcul('04',pCALC_04_OPERANDE_1,pCALC_04_OPERATEUR,pCALC_04_OPERANDE_2,pCALC_04_MULT,pCALC_04_LIBE,pCALC_04_DECI);
      pr__calcul('05',pCALC_05_OPERANDE_1,pCALC_05_OPERATEUR,pCALC_05_OPERANDE_2,pCALC_05_MULT,pCALC_05_LIBE,pCALC_05_DECI);
      pr__calcul('06',pCALC_06_OPERANDE_1,pCALC_06_OPERATEUR,pCALC_06_OPERANDE_2,pCALC_06_MULT,pCALC_06_LIBE,pCALC_06_DECI);
      pr__calcul('07',pCALC_07_OPERANDE_1,pCALC_07_OPERATEUR,pCALC_07_OPERANDE_2,pCALC_07_MULT,pCALC_07_LIBE,pCALC_07_DECI);
      pr__calcul('08',pCALC_08_OPERANDE_1,pCALC_08_OPERATEUR,pCALC_08_OPERANDE_2,pCALC_08_MULT,pCALC_08_LIBE,pCALC_08_DECI);
      pr__calcul('09',pCALC_09_OPERANDE_1,pCALC_09_OPERATEUR,pCALC_09_OPERANDE_2,pCALC_09_MULT,pCALC_09_LIBE,pCALC_09_DECI);
      pr__calcul('10',pCALC_10_OPERANDE_1,pCALC_10_OPERATEUR,pCALC_10_OPERANDE_2,pCALC_10_MULT,pCALC_10_LIBE,pCALC_10_DECI);
      pr__calcul('11',pCALC_11_OPERANDE_1,pCALC_11_OPERATEUR,pCALC_11_OPERANDE_2,pCALC_11_MULT,pCALC_11_LIBE,pCALC_11_DECI);
      pr__calcul('12',pCALC_12_OPERANDE_1,pCALC_12_OPERATEUR,pCALC_12_OPERANDE_2,pCALC_12_MULT,pCALC_12_LIBE,pCALC_12_DECI);
      pr__calcul('13',pCALC_13_OPERANDE_1,pCALC_13_OPERATEUR,pCALC_13_OPERANDE_2,pCALC_13_MULT,pCALC_13_LIBE,pCALC_13_DECI);
      pr__calcul('14',pCALC_14_OPERANDE_1,pCALC_14_OPERATEUR,pCALC_14_OPERANDE_2,pCALC_14_MULT,pCALC_14_LIBE,pCALC_14_DECI);
      pr__calcul('15',pCALC_15_OPERANDE_1,pCALC_15_OPERATEUR,pCALC_15_OPERANDE_2,pCALC_15_MULT,pCALC_15_LIBE,pCALC_15_DECI);
      pr__calcul('16',pCALC_16_OPERANDE_1,pCALC_16_OPERATEUR,pCALC_16_OPERANDE_2,pCALC_16_MULT,pCALC_16_LIBE,pCALC_16_DECI);
      pr__calcul('17',pCALC_17_OPERANDE_1,pCALC_17_OPERATEUR,pCALC_17_OPERANDE_2,pCALC_17_MULT,pCALC_17_LIBE,pCALC_17_DECI);
      pr__calcul('18',pCALC_18_OPERANDE_1,pCALC_18_OPERATEUR,pCALC_18_OPERANDE_2,pCALC_18_MULT,pCALC_18_LIBE,pCALC_18_DECI);
      pr__calcul('19',pCALC_19_OPERANDE_1,pCALC_19_OPERATEUR,pCALC_19_OPERANDE_2,pCALC_19_MULT,pCALC_19_LIBE,pCALC_19_DECI);
      pr__calcul('20',pCALC_20_OPERANDE_1,pCALC_20_OPERATEUR,pCALC_20_OPERANDE_2,pCALC_20_MULT,pCALC_20_LIBE,pCALC_20_DECI);

      if errtools.no_error(pXML) then

         pr_para_grou_stat_ctxt(iID_SOCI,'LIST_GEAV',pID_LIST);

         if strAction='CREE' then
            insert into liste_gestion_avancee(
               id_list
            )values(
               iID_LIST
            );
            commit;

            insert into liste_gestion_avancee_2(
               id_list
            )values(
               iID_LIST
            );
            commit;
         end if;

         select count(0) into iNB_LIST from liste_gestion_avancee_2 where id_list=iID_LIST;
         if iNB_LIST = 0 then

           insert into liste_gestion_avancee_2(
               id_list
            )values(
               iID_LIST
            );
            commit;

          end if;

         -- Maj des champs
         update liste_gestion_avancee set
            id_sala                  = pID_SALA                  ,
            fin_peri_essa            = pFIN_PERI_ESSA            ,
            droi_prim_anci           = pDROI_PRIM_ANCI           ,
            bic_01                   = pBIC_01                   ,
            bic_02                   = pBIC_02                   ,
            iban_01                  = pIBAN_01                  ,
            iban_02                  = pIBAN_02                  ,
            code_iso_pays_nati       = pCODE_ISO_PAYS_NATI       ,
            rais_soci                = pRAIS_SOCI                ,
            soci_orig                = pSOCI_ORIG                ,
            nom                      = pNOM                      ,
            pren                     = pPREN                     ,
            titr                     = pTITR                     ,
            matr                     = pMATR                     ,
            nom_jeun_fill            = pNOM_JEUN_FILL            ,
            conv_coll                = pCONV_COLL                ,
            reac_regu                = pREAC_REGU                ,
            serv                     = pSERV                     ,
            depa                     = pDEPA                     ,
            cate_prof                = pCATE_PROF                ,
            libe_etab                = pLIBE_ETAB                ,
            libe_etab_cour           = pLIBE_ETAB_COUR           ,
            empl                     = pEMPL                     ,
            empl_type                = pEMPL_TYPE                ,
            meti                     = pMETI                     ,
            fami_meti                = pFAMI_METI                ,
            fami_meti_hier           = pFAMI_METI_HIER           ,
            code_empl                = pCODE_EMPL                ,
            code_cate                = pCODE_CATE                ,
            libe_empl_gene           = pEMPL_GENE                ,
            coef                     = pCOEF                     ,
            dipl                     = pDIPL                     ,
            nive_form_educ_nati      = pNIVE_FORM_EDUC_NATI      ,
            sire_etab                = pSIRE_ETAB                ,
            code_unit                = pCODE_UNIT                ,
            code_regr_fich_comp_etab = pCODE_REGR_FICH_COMP_ETAB ,
            nive                     = pNIVE                     ,
            eche                     = pECHE                     ,
            grou_conv                = pGROU_CONV                ,
            posi                     = pPOSI                     ,
            indi                     = pINDI                     ,
            comp_brut                = pCOMP_BRUT                ,
            nume_comp_brut           = pNUME_COMP_BRUT           ,
            libe_comp_brut           = pLIBE_COMP_BRUT           ,
            comp_paye                = pCOMP_PAYE                ,
            nume_comp_paye           = pNUME_COMP_PAYE           ,
            libe_comp_paye           = pLIBE_COMP_PAYE           ,
            comp_acom                = pCOMP_ACOM                ,
            vale_spec_tr             = pVALE_SPEC_TR             ,
            calc_auto_tr             = pCALC_AUTO_TR             ,
            nomb_jour_trav_refe_tr   = pNOMB_JOUR_TRAV_REFE_TR   ,
            nomb_tr_calc_peri        = pNOMB_TR_CALC_PERI        ,
            nume_secu                = pNUME_SECU                ,
            date_emba                = pDATE_EMBA                ,
            date_depa                = pDATE_DEPA                ,
            date_anci                = pDATE_ANCI                ,
            date_dela_prev           = pDATE_DELA_PREV           ,
            date_nais                = pDATE_NAIS                ,
            comm_nais                = pCOMM_NAIS                ,
            depa_nais                = pDEPA_NAIS                ,
            pays_nais                = pPAYS_NAIS                ,
            cong_rest_mois           = pCONG_REST_MOIS           ,
            cong_pris_anne           = pCONG_PRIS_ANNE           ,
            evol_remu_supp_coti      = pEVOL_REMU_SUPP_COTI      ,
            type_vehi                = pTYPE_VEHI                ,
            cate_vehi                = pCATE_VEHI                ,
            pris_char_carb           = pPRIS_CHAR_CARB           ,
            octr_vehi                = pOCTR_VEHI                ,
            imma_vehi                = pIMMA_VEHI                ,
            date_1er_mise_circ_vehi  = pDATE_1ER_MISE_CIRC_VEHI  ,
            prix_acha_remi_vehi      = pPRIX_ACHA_REMI_VEHI      ,
            cout_vehi                = pCOUT_VEHI                ,
            mutu_soum_txde_01        = pMUTU_SOUM_TXDE_01        ,
            mutu_soum_txde_02        = pMUTU_SOUM_TXDE_02        ,
            mutu_soum_txde_03        = pMUTU_SOUM_TXDE_03        ,
            mutu_soum_txde_04        = pMUTU_SOUM_TXDE_04        ,
            mutu_soum_txde_05        = pMUTU_SOUM_TXDE_05        ,
            mutu_soum_mtde_01        = pMUTU_SOUM_MTDE_01        ,
            mutu_soum_mtde_02        = pMUTU_SOUM_MTDE_02        ,
            mutu_soum_mtde_03        = pMUTU_SOUM_MTDE_03        ,
            mutu_soum_mtde_04        = pMUTU_SOUM_MTDE_04        ,
            mutu_soum_mtde_05        = pMUTU_SOUM_MTDE_05        ,
            mutu_soum_mtde_06        = pMUTU_SOUM_MTDE_06        ,
            mutu_soum_mtde_07        = pMUTU_SOUM_MTDE_07        ,
            mutu_soum_mtde_08        = pMUTU_SOUM_MTDE_08        ,
            mutu_soum_mtde_09        = pMUTU_SOUM_MTDE_09        ,
            mutu_soum_mtde_10        = pMUTU_SOUM_MTDE_10        ,
            mutu_noso_txde_01        = pMUTU_NOSO_TXDE_01        ,
            mutu_noso_txde_02        = pMUTU_NOSO_TXDE_02        ,
            mutu_noso_txde_03        = pMUTU_NOSO_TXDE_03        ,
            mutu_noso_mtde_01        = pMUTU_NOSO_MTDE_01        ,
            mutu_noso_mtde_02        = pMUTU_NOSO_MTDE_02        ,
            mutu_noso_mtde_03        = pMUTU_NOSO_MTDE_03        ,
            mutu_noso_mtde_04        = pMUTU_NOSO_MTDE_04        ,
            mutu_noso_mtde_05        = pMUTU_NOSO_MTDE_05        ,
            mutu_noso_mtde_06        = pMUTU_NOSO_MTDE_06        ,
            mutu_noso_mtde_07        = pMUTU_NOSO_MTDE_07        ,
            code_anal_01             = pCODE_ANAL_01             ,
            code_anal_02             = pCODE_ANAL_02             ,
            code_anal_03             = pCODE_ANAL_03             ,
            code_anal_04             = pCODE_ANAL_04             ,
            code_anal_05             = pCODE_ANAL_05             ,
            code_anal_06             = pCODE_ANAL_06             ,
            code_anal_07             = pCODE_ANAL_07             ,
            code_anal_08             = pCODE_ANAL_08             ,
            code_anal_09             = pCODE_ANAL_09             ,
            code_anal_10             = pCODE_ANAL_10             ,
            code_anal_11             = pCODE_ANAL_11             ,
            code_anal_12             = pCODE_ANAL_12             ,
            code_anal_13             = pCODE_ANAL_13             ,
            code_anal_14             = pCODE_ANAL_14             ,
            code_anal_15             = pCODE_ANAL_15             ,
            code_anal_16             = pCODE_ANAL_16             ,
            code_anal_17             = pCODE_ANAL_17             ,
            code_anal_18             = pCODE_ANAL_18             ,
            code_anal_19             = pCODE_ANAL_19             ,
            code_anal_20             = pCODE_ANAL_20             ,
            plan1_code_anal_01       = pPLAN1_CODE_ANAL_01       ,
            plan1_code_anal_02       = pPLAN1_CODE_ANAL_02       ,
            plan1_code_anal_03       = pPLAN1_CODE_ANAL_03       ,
            plan1_code_anal_04       = pPLAN1_CODE_ANAL_04       ,
            plan1_code_anal_05       = pPLAN1_CODE_ANAL_05       ,
            plan1_code_anal_06       = pPLAN1_CODE_ANAL_06       ,
            plan1_code_anal_07       = pPLAN1_CODE_ANAL_07       ,
            plan1_code_anal_08       = pPLAN1_CODE_ANAL_08       ,
            plan1_code_anal_09       = pPLAN1_CODE_ANAL_09       ,
            plan1_code_anal_10       = pPLAN1_CODE_ANAL_10       ,
            plan1_code_anal_11       = pPLAN1_CODE_ANAL_11       ,
            plan1_code_anal_12       = pPLAN1_CODE_ANAL_12       ,
            plan1_code_anal_13       = pPLAN1_CODE_ANAL_13       ,
            plan1_code_anal_14       = pPLAN1_CODE_ANAL_14       ,
            plan1_code_anal_15       = pPLAN1_CODE_ANAL_15       ,
            plan1_code_anal_16       = pPLAN1_CODE_ANAL_16       ,
            plan1_code_anal_17       = pPLAN1_CODE_ANAL_17       ,
            plan1_code_anal_18       = pPLAN1_CODE_ANAL_18       ,
            plan1_code_anal_19       = pPLAN1_CODE_ANAL_19       ,
            plan1_code_anal_20       = pPLAN1_CODE_ANAL_20       ,
            plan1_pour_affe_anal_01  = pPLAN1_POUR_AFFE_ANAL_01  ,
            plan1_pour_affe_anal_02  = pPLAN1_POUR_AFFE_ANAL_02  ,
            plan1_pour_affe_anal_03  = pPLAN1_POUR_AFFE_ANAL_03  ,
            plan1_pour_affe_anal_04  = pPLAN1_POUR_AFFE_ANAL_04  ,
            plan1_pour_affe_anal_05  = pPLAN1_POUR_AFFE_ANAL_05  ,
            plan1_pour_affe_anal_06  = pPLAN1_POUR_AFFE_ANAL_06  ,
            plan1_pour_affe_anal_07  = pPLAN1_POUR_AFFE_ANAL_07  ,
            plan1_pour_affe_anal_08  = pPLAN1_POUR_AFFE_ANAL_08  ,
            plan1_pour_affe_anal_09  = pPLAN1_POUR_AFFE_ANAL_09  ,
            plan1_pour_affe_anal_10  = pPLAN1_POUR_AFFE_ANAL_10  ,
            plan1_pour_affe_anal_11  = pPLAN1_POUR_AFFE_ANAL_11  ,
            plan1_pour_affe_anal_12  = pPLAN1_POUR_AFFE_ANAL_12  ,
            plan1_pour_affe_anal_13  = pPLAN1_POUR_AFFE_ANAL_13  ,
            plan1_pour_affe_anal_14  = pPLAN1_POUR_AFFE_ANAL_14  ,
            plan1_pour_affe_anal_15  = pPLAN1_POUR_AFFE_ANAL_15  ,
            plan1_pour_affe_anal_16  = pPLAN1_POUR_AFFE_ANAL_16  ,
            plan1_pour_affe_anal_17  = pPLAN1_POUR_AFFE_ANAL_17  ,
            plan1_pour_affe_anal_18  = pPLAN1_POUR_AFFE_ANAL_18  ,
            plan1_pour_affe_anal_19  = pPLAN1_POUR_AFFE_ANAL_19  ,
            plan1_pour_affe_anal_20  = pPLAN1_POUR_AFFE_ANAL_20  ,
            plan2_code_anal_01       = pPLAN2_CODE_ANAL_01       ,
            plan2_code_anal_02       = pPLAN2_CODE_ANAL_02       ,
            plan2_code_anal_03       = pPLAN2_CODE_ANAL_03       ,
            plan2_code_anal_04       = pPLAN2_CODE_ANAL_04       ,
            plan2_code_anal_05       = pPLAN2_CODE_ANAL_05       ,
            plan2_code_anal_06       = pPLAN2_CODE_ANAL_06       ,
            plan2_code_anal_07       = pPLAN2_CODE_ANAL_07       ,
            plan2_code_anal_08       = pPLAN2_CODE_ANAL_08       ,
            plan2_code_anal_09       = pPLAN2_CODE_ANAL_09       ,
            plan2_code_anal_10       = pPLAN2_CODE_ANAL_10       ,
            plan2_code_anal_11       = pPLAN2_CODE_ANAL_11       ,
            plan2_code_anal_12       = pPLAN2_CODE_ANAL_12       ,
            plan2_code_anal_13       = pPLAN2_CODE_ANAL_13       ,
            plan2_code_anal_14       = pPLAN2_CODE_ANAL_14       ,
            plan2_code_anal_15       = pPLAN2_CODE_ANAL_15       ,
            plan2_code_anal_16       = pPLAN2_CODE_ANAL_16       ,
            plan2_code_anal_17       = pPLAN2_CODE_ANAL_17       ,
            plan2_code_anal_18       = pPLAN2_CODE_ANAL_18       ,
            plan2_code_anal_19       = pPLAN2_CODE_ANAL_19       ,
            plan2_code_anal_20       = pPLAN2_CODE_ANAL_20       ,
            plan2_pour_affe_anal_01  = pPLAN2_POUR_AFFE_ANAL_01  ,
            plan2_pour_affe_anal_02  = pPLAN2_POUR_AFFE_ANAL_02  ,
            plan2_pour_affe_anal_03  = pPLAN2_POUR_AFFE_ANAL_03  ,
            plan2_pour_affe_anal_04  = pPLAN2_POUR_AFFE_ANAL_04  ,
            plan2_pour_affe_anal_05  = pPLAN2_POUR_AFFE_ANAL_05  ,
            plan2_pour_affe_anal_06  = pPLAN2_POUR_AFFE_ANAL_06  ,
            plan2_pour_affe_anal_07  = pPLAN2_POUR_AFFE_ANAL_07  ,
            plan2_pour_affe_anal_08  = pPLAN2_POUR_AFFE_ANAL_08  ,
            plan2_pour_affe_anal_09  = pPLAN2_POUR_AFFE_ANAL_09  ,
            plan2_pour_affe_anal_10  = pPLAN2_POUR_AFFE_ANAL_10  ,
            plan2_pour_affe_anal_11  = pPLAN2_POUR_AFFE_ANAL_11  ,
            plan2_pour_affe_anal_12  = pPLAN2_POUR_AFFE_ANAL_12  ,
            plan2_pour_affe_anal_13  = pPLAN2_POUR_AFFE_ANAL_13  ,
            plan2_pour_affe_anal_14  = pPLAN2_POUR_AFFE_ANAL_14  ,
            plan2_pour_affe_anal_15  = pPLAN2_POUR_AFFE_ANAL_15  ,
            plan2_pour_affe_anal_16  = pPLAN2_POUR_AFFE_ANAL_16  ,
            plan2_pour_affe_anal_17  = pPLAN2_POUR_AFFE_ANAL_17  ,
            plan2_pour_affe_anal_18  = pPLAN2_POUR_AFFE_ANAL_18  ,
            plan2_pour_affe_anal_19  = pPLAN2_POUR_AFFE_ANAL_19  ,
            plan2_pour_affe_anal_20  = pPLAN2_POUR_AFFE_ANAL_20  ,
            plan3_code_anal_01       = pPLAN3_CODE_ANAL_01       ,
            plan3_code_anal_02       = pPLAN3_CODE_ANAL_02       ,
            plan3_code_anal_03       = pPLAN3_CODE_ANAL_03       ,
            plan3_code_anal_04       = pPLAN3_CODE_ANAL_04       ,
            plan3_code_anal_05       = pPLAN3_CODE_ANAL_05       ,
            plan3_code_anal_06       = pPLAN3_CODE_ANAL_06       ,
            plan3_code_anal_07       = pPLAN3_CODE_ANAL_07       ,
            plan3_code_anal_08       = pPLAN3_CODE_ANAL_08       ,
            plan3_code_anal_09       = pPLAN3_CODE_ANAL_09       ,
            plan3_code_anal_10       = pPLAN3_CODE_ANAL_10       ,
            plan3_code_anal_11       = pPLAN3_CODE_ANAL_11       ,
            plan3_code_anal_12       = pPLAN3_CODE_ANAL_12       ,
            plan3_code_anal_13       = pPLAN3_CODE_ANAL_13       ,
            plan3_code_anal_14       = pPLAN3_CODE_ANAL_14       ,
            plan3_code_anal_15       = pPLAN3_CODE_ANAL_15       ,
            plan3_code_anal_16       = pPLAN3_CODE_ANAL_16       ,
            plan3_code_anal_17       = pPLAN3_CODE_ANAL_17       ,
            plan3_code_anal_18       = pPLAN3_CODE_ANAL_18       ,
            plan3_code_anal_19       = pPLAN3_CODE_ANAL_19       ,
            plan3_code_anal_20       = pPLAN3_CODE_ANAL_20       ,
            plan3_pour_affe_anal_01  = pPLAN3_POUR_AFFE_ANAL_01  ,
            plan3_pour_affe_anal_02  = pPLAN3_POUR_AFFE_ANAL_02  ,
            plan3_pour_affe_anal_03  = pPLAN3_POUR_AFFE_ANAL_03  ,
            plan3_pour_affe_anal_04  = pPLAN3_POUR_AFFE_ANAL_04  ,
            plan3_pour_affe_anal_05  = pPLAN3_POUR_AFFE_ANAL_05  ,
            plan3_pour_affe_anal_06  = pPLAN3_POUR_AFFE_ANAL_06  ,
            plan3_pour_affe_anal_07  = pPLAN3_POUR_AFFE_ANAL_07  ,
            plan3_pour_affe_anal_08  = pPLAN3_POUR_AFFE_ANAL_08  ,
            plan3_pour_affe_anal_09  = pPLAN3_POUR_AFFE_ANAL_09  ,
            plan3_pour_affe_anal_10  = pPLAN3_POUR_AFFE_ANAL_10  ,
            plan3_pour_affe_anal_11  = pPLAN3_POUR_AFFE_ANAL_11  ,
            plan3_pour_affe_anal_12  = pPLAN3_POUR_AFFE_ANAL_12  ,
            plan3_pour_affe_anal_13  = pPLAN3_POUR_AFFE_ANAL_13  ,
            plan3_pour_affe_anal_14  = pPLAN3_POUR_AFFE_ANAL_14  ,
            plan3_pour_affe_anal_15  = pPLAN3_POUR_AFFE_ANAL_15  ,
            plan3_pour_affe_anal_16  = pPLAN3_POUR_AFFE_ANAL_16  ,
            plan3_pour_affe_anal_17  = pPLAN3_POUR_AFFE_ANAL_17  ,
            plan3_pour_affe_anal_18  = pPLAN3_POUR_AFFE_ANAL_18  ,
            plan3_pour_affe_anal_19  = pPLAN3_POUR_AFFE_ANAL_19  ,
            plan3_pour_affe_anal_20  = pPLAN3_POUR_AFFE_ANAL_20  ,
            plan4_code_anal_01       = pPLAN4_CODE_ANAL_01       ,
            plan4_code_anal_02       = pPLAN4_CODE_ANAL_02       ,
            plan4_code_anal_03       = pPLAN4_CODE_ANAL_03       ,
            plan4_code_anal_04       = pPLAN4_CODE_ANAL_04       ,
            plan4_code_anal_05       = pPLAN4_CODE_ANAL_05       ,
            plan4_code_anal_06       = pPLAN4_CODE_ANAL_06       ,
            plan4_code_anal_07       = pPLAN4_CODE_ANAL_07       ,
            plan4_code_anal_08       = pPLAN4_CODE_ANAL_08       ,
            plan4_code_anal_09       = pPLAN4_CODE_ANAL_09       ,
            plan4_code_anal_10       = pPLAN4_CODE_ANAL_10       ,
            plan4_code_anal_11       = pPLAN4_CODE_ANAL_11       ,
            plan4_code_anal_12       = pPLAN4_CODE_ANAL_12       ,
            plan4_code_anal_13       = pPLAN4_CODE_ANAL_13       ,
            plan4_code_anal_14       = pPLAN4_CODE_ANAL_14       ,
            plan4_code_anal_15       = pPLAN4_CODE_ANAL_15       ,
            plan4_code_anal_16       = pPLAN4_CODE_ANAL_16       ,
            plan4_code_anal_17       = pPLAN4_CODE_ANAL_17       ,
            plan4_code_anal_18       = pPLAN4_CODE_ANAL_18       ,
            plan4_code_anal_19       = pPLAN4_CODE_ANAL_19       ,
            plan4_code_anal_20       = pPLAN4_CODE_ANAL_20       ,
            plan4_pour_affe_anal_01  = pPLAN4_POUR_AFFE_ANAL_01  ,
            plan4_pour_affe_anal_02  = pPLAN4_POUR_AFFE_ANAL_02  ,
            plan4_pour_affe_anal_03  = pPLAN4_POUR_AFFE_ANAL_03  ,
            plan4_pour_affe_anal_04  = pPLAN4_POUR_AFFE_ANAL_04  ,
            plan4_pour_affe_anal_05  = pPLAN4_POUR_AFFE_ANAL_05  ,
            plan4_pour_affe_anal_06  = pPLAN4_POUR_AFFE_ANAL_06  ,
            plan4_pour_affe_anal_07  = pPLAN4_POUR_AFFE_ANAL_07  ,
            plan4_pour_affe_anal_08  = pPLAN4_POUR_AFFE_ANAL_08  ,
            plan4_pour_affe_anal_09  = pPLAN4_POUR_AFFE_ANAL_09  ,
            plan4_pour_affe_anal_10  = pPLAN4_POUR_AFFE_ANAL_10  ,
            plan4_pour_affe_anal_11  = pPLAN4_POUR_AFFE_ANAL_11  ,
            plan4_pour_affe_anal_12  = pPLAN4_POUR_AFFE_ANAL_12  ,
            plan4_pour_affe_anal_13  = pPLAN4_POUR_AFFE_ANAL_13  ,
            plan4_pour_affe_anal_14  = pPLAN4_POUR_AFFE_ANAL_14  ,
            plan4_pour_affe_anal_15  = pPLAN4_POUR_AFFE_ANAL_15  ,
            plan4_pour_affe_anal_16  = pPLAN4_POUR_AFFE_ANAL_16  ,
            plan4_pour_affe_anal_17  = pPLAN4_POUR_AFFE_ANAL_17  ,
            plan4_pour_affe_anal_18  = pPLAN4_POUR_AFFE_ANAL_18  ,
            plan4_pour_affe_anal_19  = pPLAN4_POUR_AFFE_ANAL_19  ,
            plan4_pour_affe_anal_20  = pPLAN4_POUR_AFFE_ANAL_20  ,
            plan5_code_anal_01       = pPLAN5_CODE_ANAL_01       ,
            plan5_code_anal_02       = pPLAN5_CODE_ANAL_02       ,
            plan5_code_anal_03       = pPLAN5_CODE_ANAL_03       ,
            plan5_code_anal_04       = pPLAN5_CODE_ANAL_04       ,
            plan5_code_anal_05       = pPLAN5_CODE_ANAL_05       ,
            plan5_code_anal_06       = pPLAN5_CODE_ANAL_06       ,
            plan5_code_anal_07       = pPLAN5_CODE_ANAL_07       ,
            plan5_code_anal_08       = pPLAN5_CODE_ANAL_08       ,
            CODE_COMP_FIC            = pCODE_COMP_FICH           ,
            plan5_code_anal_09       = pPLAN5_CODE_ANAL_09       ,
            plan5_code_anal_10       = pPLAN5_CODE_ANAL_10       ,
            plan5_code_anal_11       = pPLAN5_CODE_ANAL_11       ,
            plan5_code_anal_12       = pPLAN5_CODE_ANAL_12       ,
            plan5_code_anal_13       = pPLAN5_CODE_ANAL_13       ,
            plan5_code_anal_14       = pPLAN5_CODE_ANAL_14       ,
            plan5_code_anal_15       = pPLAN5_CODE_ANAL_15       ,
            plan5_code_anal_16       = pPLAN5_CODE_ANAL_16       ,
            plan5_code_anal_17       = pPLAN5_CODE_ANAL_17       ,
            plan5_code_anal_18       = pPLAN5_CODE_ANAL_18       ,
            plan5_code_anal_19       = pPLAN5_CODE_ANAL_19       ,
            plan5_code_anal_20       = pPLAN5_CODE_ANAL_20       ,
            plan5_pour_affe_anal_01  = pPLAN5_POUR_AFFE_ANAL_01  ,
            plan5_pour_affe_anal_02  = pPLAN5_POUR_AFFE_ANAL_02  ,
            plan5_pour_affe_anal_03  = pPLAN5_POUR_AFFE_ANAL_03  ,
            plan5_pour_affe_anal_04  = pPLAN5_POUR_AFFE_ANAL_04  ,
            plan5_pour_affe_anal_05  = pPLAN5_POUR_AFFE_ANAL_05  ,
            plan5_pour_affe_anal_06  = pPLAN5_POUR_AFFE_ANAL_06  ,
            plan5_pour_affe_anal_07  = pPLAN5_POUR_AFFE_ANAL_07  ,
            plan5_pour_affe_anal_08  = pPLAN5_POUR_AFFE_ANAL_08  ,
            plan5_pour_affe_anal_09  = pPLAN5_POUR_AFFE_ANAL_09  ,
            plan5_pour_affe_anal_10  = pPLAN5_POUR_AFFE_ANAL_10  ,
            plan5_pour_affe_anal_11  = pPLAN5_POUR_AFFE_ANAL_11  ,
            plan5_pour_affe_anal_12  = pPLAN5_POUR_AFFE_ANAL_12  ,
            plan5_pour_affe_anal_13  = pPLAN5_POUR_AFFE_ANAL_13  ,
            plan5_pour_affe_anal_14  = pPLAN5_POUR_AFFE_ANAL_14  ,
            plan5_pour_affe_anal_15  = pPLAN5_POUR_AFFE_ANAL_15  ,
            plan5_pour_affe_anal_16  = pPLAN5_POUR_AFFE_ANAL_16  ,
            plan5_pour_affe_anal_17  = pPLAN5_POUR_AFFE_ANAL_17  ,
            plan5_pour_affe_anal_18  = pPLAN5_POUR_AFFE_ANAL_18  ,
            plan5_pour_affe_anal_19  = pPLAN5_POUR_AFFE_ANAL_19  ,
            plan5_pour_affe_anal_20  = pPLAN5_POUR_AFFE_ANAL_20  ,
            situ_fami                = pSITU_FAMI                ,
            bull_mode                = pBULL_MODE                ,
            profil_paye_cp           = pPROFIL_PAYE_CP           ,
            profil_paye_rtt          = pPROFIL_PAYE_RTT          ,
            profil_paye_dif          = pPROFIL_PAYE_DIF          ,
            profil_paye_prov_cet     = pPROFIL_PAYE_PROV_CET     ,
            profil_paye_prov_inte    = pPROFIL_PAYE_PROV_INTE    ,
            profil_paye_prov_part    = pPROFIL_PAYE_PROV_PART    ,
            profil_paye_13mo         = pPROFIL_PAYE_13MO         ,
            profil_paye_14mo         = pPROFIL_PAYE_14MO         ,
            prof_15mo                = pPROF_15MO                ,
            profil_paye_prim_vaca_01 = pPROFIL_PAYE_PRIM_VACA_01 ,
            profil_paye_prim_vaca_02 = pPROFIL_PAYE_PRIM_VACA_02 ,
            profil_paye_hs_conv      = pPROFIL_PAYE_HS_CONV      ,
            profil_paye_heur_equi    = pPROFIL_PAYE_HEUR_EQUI    ,
            profil_paye_deca_fisc    = pPROFIL_PAYE_DECA_FISC    ,
            profil_paye_tepa         = pPROFIL_PAYE_TEPA         ,
            profil_paye_affi_bull    = pPROFIL_PAYE_AFFI_BULL    ,
            profil_paye_forf         = pPROFIL_PAYE_FORF         ,
            profil_paye_depa         = pPROFIL_PAYE_DEPA         ,
            profil_paye_rein_frai    = pPROFIL_PAYE_REIN_FRAI    ,
            profil_paye_ndf          = pPROFIL_PAYE_NDF          ,
            profil_paye_acce_sala    = pPROFIL_PAYE_ACCE_SALA    ,
            profil_paye_plan         = pPROFIL_PAYE_PLAN         ,
            profil_paye_tele_trav    = pPROFIL_PAYE_TELE_TRAV    ,
            idcc_heur_equi           = pIDCC_HEUR_EQUI           ,
            cipdz_code               = pCIPDZ_CODE               ,
            cipdz_libe               = pCIPDZ_LIBE               ,
            nume_cong_spec           = pNUME_CONG_SPEC           ,
            grou_comp                = pGROU_COMP                ,
            cham_util_1              = pCHAM_UTIL_1              ,
            cham_util_2              = pCHAM_UTIL_2              ,
            cham_util_3              = pCHAM_UTIL_3              ,
            cham_util_4              = pCHAM_UTIL_4              ,
            cham_util_5              = pCHAM_UTIL_5              ,
            cham_util_6              = pCHAM_UTIL_6              ,
            cham_util_7              = pCHAM_UTIL_7              ,
            cham_util_8              = pCHAM_UTIL_8              ,
            cham_util_9              = pCHAM_UTIL_9              ,
            cham_util_10             = pCHAM_UTIL_10             ,
            cham_util_11             = pCHAM_UTIL_11             ,
            cham_util_12             = pCHAM_UTIL_12             ,
            cham_util_13             = pCHAM_UTIL_13             ,
            cham_util_14             = pCHAM_UTIL_14             ,
            cham_util_15             = pCHAM_UTIL_15             ,
            cham_util_16             = pCHAM_UTIL_16             ,
            cham_util_17             = pCHAM_UTIL_17             ,
            cham_util_18             = pCHAM_UTIL_18             ,
            cham_util_19             = pCHAM_UTIL_19             ,
            cham_util_20             = pCHAM_UTIL_20             ,
            cham_util_21             = pCHAM_UTIL_21             ,
            cham_util_22             = pCHAM_UTIL_22             ,
            cham_util_23             = pCHAM_UTIL_23             ,
            cham_util_24             = pCHAM_UTIL_24             ,
            cham_util_25             = pCHAM_UTIL_25             ,
            cham_util_26             = pCHAM_UTIL_26             ,
            cham_util_27             = pCHAM_UTIL_27             ,
            cham_util_28             = pCHAM_UTIL_28             ,
            cham_util_29             = pCHAM_UTIL_29             ,
            cham_util_30             = pCHAM_UTIL_30             ,
            cham_util_31             = pCHAM_UTIL_31             ,
            cham_util_32             = pCHAM_UTIL_32             ,
            cham_util_33             = pCHAM_UTIL_33             ,
            cham_util_34             = pCHAM_UTIL_34             ,
            cham_util_35             = pCHAM_UTIL_35             ,
            cham_util_36             = pCHAM_UTIL_36             ,
            cham_util_37             = pCHAM_UTIL_37             ,
            cham_util_38             = pCHAM_UTIL_38             ,
            cham_util_39             = pCHAM_UTIL_39             ,
            cham_util_40             = pCHAM_UTIL_40             ,

            cham_util_41             = pCHAM_UTIL_41             ,
            cham_util_42             = pCHAM_UTIL_42             ,
            cham_util_43             = pCHAM_UTIL_43             ,
            cham_util_44             = pCHAM_UTIL_44             ,
            cham_util_45             = pCHAM_UTIL_45             ,
            cham_util_46             = pCHAM_UTIL_46             ,
            cham_util_47             = pCHAM_UTIL_47             ,
            cham_util_48             = pCHAM_UTIL_48             ,
            cham_util_49             = pCHAM_UTIL_49             ,
            cham_util_50             = pCHAM_UTIL_50             ,
            cham_util_51             = pCHAM_UTIL_51             ,
            cham_util_52             = pCHAM_UTIL_52             ,
            cham_util_53             = pCHAM_UTIL_53             ,
            cham_util_54             = pCHAM_UTIL_54             ,
            cham_util_55             = pCHAM_UTIL_55             ,
            cham_util_56             = pCHAM_UTIL_56             ,
            cham_util_57             = pCHAM_UTIL_57             ,
            cham_util_58             = pCHAM_UTIL_58             ,
            cham_util_59             = pCHAM_UTIL_59             ,
            cham_util_60             = pCHAM_UTIL_60             ,
            cham_util_61             = pCHAM_UTIL_61             ,
            cham_util_62             = pCHAM_UTIL_62             ,
            cham_util_63             = pCHAM_UTIL_63             ,
            cham_util_64             = pCHAM_UTIL_64             ,
            cham_util_65             = pCHAM_UTIL_65             ,
            cham_util_66             = pCHAM_UTIL_66             ,
            cham_util_67             = pCHAM_UTIL_67             ,
            cham_util_68             = pCHAM_UTIL_68             ,
            cham_util_69             = pCHAM_UTIL_69             ,
            cham_util_70             = pCHAM_UTIL_70             ,
            cham_util_71             = pCHAM_UTIL_71             ,
            cham_util_72             = pCHAM_UTIL_72             ,
            cham_util_73             = pCHAM_UTIL_73             ,
            cham_util_74             = pCHAM_UTIL_74             ,
            cham_util_75             = pCHAM_UTIL_75             ,
            cham_util_76             = pCHAM_UTIL_76             ,
            cham_util_77             = pCHAM_UTIL_77             ,
            cham_util_78             = pCHAM_UTIL_78             ,
            cham_util_79             = pCHAM_UTIL_79             ,
            cham_util_80             = pCHAM_UTIL_80             ,

            cais_coti_bull           = pCAIS_COTI_BULL           ,
            date_dern_visi_medi      = pDATE_DERN_VISI_MEDI      ,
            stat_boet                = pSTAT_BOET                ,
            date_expi                = pDATE_EXPI                ,
            nume_cart_sejo           = pNUME_CART_SEJO           ,
            nume_cart_trav           = pNUME_CART_TRAV           ,
            date_deli_trav           = pDATE_DELI_TRAV           ,
            date_expi_trav           = pDATE_EXPI_TRAV           ,
            date_dema_auto_trav      = pDATE_DEMA_AUTO_TRAV      ,
            id_pref                  = pID_PREF                  ,
            date_expi_disp_mutu      = pDATE_EXPI_DISP_MUTU      ,
            id_moti_disp_mutu        = pID_MOTI_DISP_MUTU        ,
            date_proc_visi_medi      = pDATE_PROC_VISI_MEDI      ,
            equi                     = pEQUI                     ,
            code_soci                = pCODE_SOCI                ,
            soci_code                = pSOCI_CODE                ,
            etab_code                = pETAB_CODE                ,
            code_divi                = pCODE_DIVI                ,
            code_serv                = pCODE_SERV                ,
            code_depa                = pCODE_DEPA                ,
            code_equi                = pCODE_EQUI                ,
            sala_code_unit           = pSALA_CODE_UNIT           ,
            nati                     = pNATI                     ,
            moti_visi_medi           = pMOTI_VISI_MEDI           ,
            type_sala                = pTYPE_SALA                ,
            natu_cont                = pNATU_CONT                ,
            nume_cont                = pNUME_CONT                ,
            libe_moti_recr_cdd       = pLIBE_MOTI_RECR_CDD       ,
            libe_moti_recr_cdd2      = pLIBE_MOTI_RECR_CDD2      ,
            libe_moti_recr_cdd3      = pLIBE_MOTI_RECR_CDD3      ,
            date_debu_cont           = pDATE_DEBU_CONT           ,
            date_fin_cont            = pDATE_FIN_CONT            ,
            nomb_enfa                = pNOMB_ENFA                ,
            comm_vent_n              = pCOMM_VENT_N              ,
            comm_vent_n1             = pCOMM_VENT_N1             ,
            prim_obje_n              = pPRIM_OBJE_N              ,
            prim_obje_n1             = pPRIM_OBJE_N1             ,
            prim_obje_soci_n         = pPRIM_OBJE_SOCI_N         ,
            prim_obje_soci_n1        = pPRIM_OBJE_SOCI_N1        ,
            prim_obje_glob_n         = pPRIM_OBJE_GLOB_N         ,
            etp_ccn51                = pETP_CCN51                ,
            ccn51_coef_acca          = pCCN51_COEF_ACCA          ,
            ccn51_coef_dipl          = pCCN51_COEF_DIPL          ,
            ccn51_coef_enca          = pCCN51_COEF_ENCA          ,
            ccn51_coef_fonc          = pCCN51_COEF_FONC          ,
            ccn51_coef_meti          = pCCN51_COEF_METI          ,
            ccn51_coef_recl          = pCCN51_COEF_RECL          ,
            ccn5166_coef_refe        = pCCN5166_COEF_REFE        ,
            ccn51_coef_spec          = pCCN51_COEF_SPEC          ,
            ccn51_id_empl_conv       = pCCN51_ID_EMPL_CONV       ,
            ccn51_anci_date_chan_appl= pCCN51_ANCI_DATE_CHAN_APPL,
            ccn51_anci_taux          = pCCN51_ANCI_TAUX          ,
            ccn51_cadr_date_chan_appl= pCCN51_CADR_DATE_CHAN_APPL,
            ccn51_cadr_taux          = pCCN51_CADR_TAUX          ,
            ccn66_cate_conv          = pCCN66_CATE_CONV          ,
            ccn66_date_chan_coef     = pCCN66_DATE_CHAN_COEF     ,
            ccn66_empl_conv          = pCCN66_EMPL_CONV          ,
            ccn66_libe_empl_conv     = pCCN66_LIBE_EMPL_CONV     ,
            ccn66_fili_conv          = pCCN66_FILI_CONV          ,
            ccn66_prec_date_chan_coef= pCCN66_PREC_DATE_CHAN_COEF,
            ccn66_proc_coef_refe     = pCCN66_PROC_COEF_REFE     ,
            ccn66_regi               = pCCN66_REGI               ,

            nume_fine                = pNUME_FINE                ,
            nume_adel                = pNUME_ADEL                ,
            nume_rpps                = pNUME_RPPS                ,
            adre_elec                = pADRE_ELEC                ,
            code_titr_form           = pCODE_TITR_FORM           ,
            libe_titr_form           = pLIBE_TITR_FORM           ,
            date_titr_form           = pDATE_TITR_FORM           ,
            lieu_titr_form           = pLIEU_TITR_FORM           ,

            code_regi                = pCODE_REGI                ,
            libe_regi                = pLIBE_REGI                ,

            orga                     = pORGA                     ,
            unit                     = pUNIT                     ,

            dads_inse_empl           = pDADS_INSE_EMPL           ,
            sais                     = pSAIS                     ,
            matr_grou                = pMATR_GROU                ,
            matr_resp_hier           = pMATR_RESP_HIER           ,
            date_anci_prof           = pDATE_ANCI_PROF           ,
            date_refe_01             = pDATE_REFE_01             ,
            date_refe_02             = pDATE_REFE_02             ,
            date_refe_03             = pDATE_REFE_03             ,
            date_refe_04             = pDATE_REFE_04             ,
            date_refe_05             = pDATE_REFE_05             ,
            date_sign_conv_stag      = pDATE_SIGN_CONV_STAG      ,
            nive_qual                = pNIVE_QUAL                ,
            moti_depa                = pMOTI_DEPA                ,
            moti_augm                = pMOTI_AUGM                ,
            moti_augm_2              = pMOTI_AUGM_2              ,----KFH 27/04/2023 T184292
            TICK_REST_TYPE_REPA      = pTICK_REST_TYPE_REPA      , --KFH 15/04/2024 T201908
            sala_auto_titr_trav      = pSALA_AUTO_TITR_TRAV      ,
            lieu_pres_stag           = pLIEU_PRES_STAG           ,
            sexe                     = pSEXE                     ,
            adre                     = pADRE                     ,
            dern_adre                = pDERN_ADRE                ,
            adre_comp                = pADRE_COMP                ,
            dern_adre_comp           = pDERN_ADRE_COMP           ,
            adre_comm                = pADRE_COMM                ,
            dern_adre_comm           = pDERN_ADRE_COMM           ,
            adre_code_post           = pADRE_CODE_POST           ,
            dern_adre_code_post      = pDERN_ADRE_CODE_POST      ,
            adre_pays                = pADRE_PAYS                ,
            divi                     = pDIVI                     ,
            regr                     = pREGR                     ,
            date_acci_trav           = pDATE_ACCI_TRAV           ,
            trav_hand                = pTRAV_HAND                ,
            date_debu_coto           = pDATE_DEBU_COTO           ,
            date_fin_coto            = pDATE_FIN_COTO            ,
            inva                     = pINVA                     ,
            taux_inva                = pTAUX_INVA                ,
            adre_mail                = pADRE_MAIL                ,
            adre_mail_pers           = pADRE_MAIL_PERS           ,
            mail_sala_cong           = pMAIL_SALA_CONG           ,
            resp_hier_1_nom          = pRESP_HIER_1_NOM          ,
           resp_hier_1_mail          = pRESP_HIER_1_MAIL         ,
            resp_hier_2_nom          = pRESP_HIER_2_NOM          ,
            resp_hier_2_mail         = pRESP_HIER_2_MAIL         ,
            hier_resp_1_nom          = pHIER_RESP_1_NOM          ,
            hier_resp_2_nom          = pHIER_RESP_2_NOM          ,
    --       hier_resp_1_mail        = pHIER_RESP_1_MAIL         ,
            FILI_CONV                = pFILI_CONV                ,
            rib_mode_paie            = pRIB_MODE_PAIE            ,
            rib_banq_1               = pRIB_BANQ_1               ,
            rib_domi_1               = pRIB_DOMI_1               ,
            rib_nume_1               = pRIB_NUME_1               ,
            rib_titu_comp_1          = pRIB_TITU_COMP_1          ,
            rib_banq_2               = pRIB_BANQ_2               ,
            rib_domi_2               = pRIB_DOMI_2               ,
            rib_nume_2               = pRIB_NUME_2               ,
            rib_titu_comp_2          = pRIB_TITU_COMP_2          ,
            tele_1                   = pTELE_1                   ,
            tele_2                   = pTELE_2                   ,
            tele_3                   = pTELE_3                   ,
            calc_auto_inde_cong_prec = pCALC_AUTO_INDE_CONG_PREC ,
            rapp_hora_arro           = pRAPP_HORA_ARRO           ,
            comm_1                   = pCOMM_1                   ,
            comm_2                   = pCOMM_2                   ,
            comm_3                   = pCOMM_3                   ,
            saho_boo                 = pSAHO_BOO                 ,

            rubr_01                  = oNew.rubr_01     ,
            rubr_02                  = oNew.rubr_02     ,
            rubr_03                  = oNew.rubr_03     ,
            rubr_04                  = oNew.rubr_04     ,
            rubr_05                  = oNew.rubr_05     ,
            rubr_06                  = oNew.rubr_06     ,
            rubr_07                  = oNew.rubr_07     ,
            rubr_08                  = oNew.rubr_08     ,
            rubr_09                  = oNew.rubr_09     ,
            rubr_10                  = oNew.rubr_10     ,
            rubr_11                  = oNew.rubr_11     ,
            rubr_12                  = oNew.rubr_12     ,
            rubr_13                  = oNew.rubr_13     ,
            rubr_14                  = oNew.rubr_14     ,
            rubr_15                  = oNew.rubr_15     ,
            rubr_16                  = oNew.rubr_16     ,
            rubr_17                  = oNew.rubr_17     ,
            rubr_18                  = oNew.rubr_18     ,
            rubr_19                  = oNew.rubr_19     ,
            rubr_20                  = oNew.rubr_20     ,
            rubr_21                  = oNew.rubr_21     ,
            rubr_22                  = oNew.rubr_22     ,
            rubr_23                  = oNew.rubr_23     ,
            rubr_24                  = oNew.rubr_24     ,
            rubr_25                  = oNew.rubr_25     ,
            rubr_26                  = oNew.rubr_26     ,
            rubr_27                  = oNew.rubr_27     ,
            rubr_28                  = oNew.rubr_28     ,
            rubr_29                  = oNew.rubr_29     ,
            rubr_30                  = oNew.rubr_30     ,
            rubr_31                  = oNew.rubr_31     ,
            rubr_32                  = oNew.rubr_32     ,
            rubr_33                  = oNew.rubr_33     ,
            rubr_34                  = oNew.rubr_34     ,
            rubr_35                  = oNew.rubr_35     ,
            rubr_36                  = oNew.rubr_36     ,
            rubr_37                  = oNew.rubr_37     ,
            rubr_38                  = oNew.rubr_38     ,
            rubr_39                  = oNew.rubr_39     ,
            rubr_40                  = oNew.rubr_40     ,
            rubr_41                  = oNew.rubr_41     ,
            rubr_42                  = oNew.rubr_42     ,
            rubr_43                  = oNew.rubr_43     ,
            rubr_44                  = oNew.rubr_44     ,
            rubr_45                  = oNew.rubr_45     ,
            rubr_46                  = oNew.rubr_46     ,
            rubr_47                  = oNew.rubr_47     ,
            rubr_48                  = oNew.rubr_48     ,
            rubr_49                  = oNew.rubr_49     ,
            rubr_50                  = oNew.rubr_50     ,
            cons_01                  = oNew.cons_01     ,
            cons_02                  = oNew.cons_02     ,
            cons_03                  = oNew.cons_03     ,
            cons_04                  = oNew.cons_04     ,
            cons_05                  = oNew.cons_05     ,
            cons_06                  = oNew.cons_06     ,
            cons_07                  = oNew.cons_07     ,
            cons_08                  = oNew.cons_08     ,
            cons_09                  = oNew.cons_09     ,
            cons_10                  = oNew.cons_10     ,
            cons_11                  = oNew.cons_11     ,
            cons_12                  = oNew.cons_12     ,
            cons_13                  = oNew.cons_13     ,
            cons_14                  = oNew.cons_14     ,
            cons_15                  = oNew.cons_15     ,
            cons_16                  = oNew.cons_16     ,
            cons_17                  = oNew.cons_17     ,
            cons_18                  = oNew.cons_18     ,
            cons_19                  = oNew.cons_19     ,
            cons_20                  = oNew.cons_20     ,

            libe_rubr_01             = oNew.libe_rubr_01,
            libe_rubr_02             = oNew.libe_rubr_02,
            libe_rubr_03             = oNew.libe_rubr_03,
            libe_rubr_04             = oNew.libe_rubr_04,
            libe_rubr_05             = oNew.libe_rubr_05,
            libe_rubr_06             = oNew.libe_rubr_06,
            libe_rubr_07             = oNew.libe_rubr_07,
            libe_rubr_08             = oNew.libe_rubr_08,
            libe_rubr_09             = oNew.libe_rubr_09,
            libe_rubr_10             = oNew.libe_rubr_10,
            libe_rubr_11             = oNew.libe_rubr_11,
            libe_rubr_12             = oNew.libe_rubr_12,
            libe_rubr_13             = oNew.libe_rubr_13,
            libe_rubr_14             = oNew.libe_rubr_14,
            libe_rubr_15             = oNew.libe_rubr_15,
            libe_rubr_16             = oNew.libe_rubr_16,
            libe_rubr_17             = oNew.libe_rubr_17,
            libe_rubr_18             = oNew.libe_rubr_18,
            libe_rubr_19             = oNew.libe_rubr_19,
            libe_rubr_20             = oNew.libe_rubr_20,
            libe_rubr_21             = oNew.libe_rubr_21,
            libe_rubr_22             = oNew.libe_rubr_22,
            libe_rubr_23             = oNew.libe_rubr_23,
            libe_rubr_24             = oNew.libe_rubr_24,
            libe_rubr_25             = oNew.libe_rubr_25,
            libe_rubr_26             = oNew.libe_rubr_26,
            libe_rubr_27             = oNew.libe_rubr_27,
            libe_rubr_28             = oNew.libe_rubr_28,
            libe_rubr_29             = oNew.libe_rubr_29,
            libe_rubr_30             = oNew.libe_rubr_30,
            libe_rubr_31             = oNew.libe_rubr_31,
            libe_rubr_32             = oNew.libe_rubr_32,
            libe_rubr_33             = oNew.libe_rubr_33,
            libe_rubr_34             = oNew.libe_rubr_34,
            libe_rubr_35             = oNew.libe_rubr_35,
            libe_rubr_36             = oNew.libe_rubr_36,
            libe_rubr_37             = oNew.libe_rubr_37,
            libe_rubr_38             = oNew.libe_rubr_38,
            libe_rubr_39             = oNew.libe_rubr_39,
            libe_rubr_40             = oNew.libe_rubr_40,
            libe_rubr_41             = oNew.libe_rubr_41,
            libe_rubr_42             = oNew.libe_rubr_42,
            libe_rubr_43             = oNew.libe_rubr_43,
            libe_rubr_44             = oNew.libe_rubr_44,
            libe_rubr_45             = oNew.libe_rubr_45,
            libe_rubr_46             = oNew.libe_rubr_46,
            libe_rubr_47             = oNew.libe_rubr_47,
            libe_rubr_48             = oNew.libe_rubr_48,
            libe_rubr_49             = oNew.libe_rubr_49,
            libe_rubr_50             = oNew.libe_rubr_50,

            libe_cons_01        = oNew.libe_cons_01,
            libe_cons_02        = oNew.libe_cons_02,
            libe_cons_03        = oNew.libe_cons_03,
            libe_cons_04        = oNew.libe_cons_04,
            libe_cons_05        = oNew.libe_cons_05,
            libe_cons_06        = oNew.libe_cons_06,
            libe_cons_07        = oNew.libe_cons_07,
            libe_cons_08        = oNew.libe_cons_08,
            libe_cons_09        = oNew.libe_cons_09,
            libe_cons_10        = oNew.libe_cons_10,
            libe_cons_11        = oNew.libe_cons_11,
            libe_cons_12        = oNew.libe_cons_12,
            libe_cons_13        = oNew.libe_cons_13,
            libe_cons_14        = oNew.libe_cons_14,
            libe_cons_15        = oNew.libe_cons_15,
            libe_cons_16        = oNew.libe_cons_16,
            libe_cons_17        = oNew.libe_cons_17,
            libe_cons_18        = oNew.libe_cons_18,
            libe_cons_19        = oNew.libe_cons_19,
            libe_cons_20        = oNew.libe_cons_20,

            cons_repa_01        = oNew.cons_repa_01,
            cons_repa_02        = oNew.cons_repa_02,
            cons_repa_03        = oNew.cons_repa_03,
            cons_repa_04        = oNew.cons_repa_04,
            cons_repa_05        = oNew.cons_repa_05,
            cons_repa_06        = oNew.cons_repa_06,
            cons_repa_07        = oNew.cons_repa_07,
            cons_repa_08        = oNew.cons_repa_08,
            cons_repa_09        = oNew.cons_repa_09,
            cons_repa_10        = oNew.cons_repa_10,
            cons_repa_11        = oNew.cons_repa_11,
            cons_repa_12        = oNew.cons_repa_12,
            cons_repa_13        = oNew.cons_repa_13,
            cons_repa_14        = oNew.cons_repa_14,
            cons_repa_15        = oNew.cons_repa_15,
            cons_repa_16        = oNew.cons_repa_16,
            cons_repa_17        = oNew.cons_repa_17,
            cons_repa_18        = oNew.cons_repa_18,
            cons_repa_19        = oNew.cons_repa_19,
            cons_repa_20        = oNew.cons_repa_20,

            id_rubr_01          = oNew.id_rubr_01  ,
            id_rubr_02          = oNew.id_rubr_02  ,
            id_rubr_03          = oNew.id_rubr_03  ,
            id_rubr_04          = oNew.id_rubr_04  ,
            id_rubr_05          = oNew.id_rubr_05  ,
            id_rubr_06          = oNew.id_rubr_06  ,
            id_rubr_07          = oNew.id_rubr_07  ,
            id_rubr_08          = oNew.id_rubr_08  ,
            id_rubr_09          = oNew.id_rubr_09  ,
            id_rubr_10          = oNew.id_rubr_10  ,
            id_rubr_11          = oNew.id_rubr_11  ,
            id_rubr_12          = oNew.id_rubr_12  ,
            id_rubr_13          = oNew.id_rubr_13  ,
            id_rubr_14          = oNew.id_rubr_14  ,
            id_rubr_15          = oNew.id_rubr_15  ,
            id_rubr_16          = oNew.id_rubr_16  ,
            id_rubr_17          = oNew.id_rubr_17  ,
            id_rubr_18          = oNew.id_rubr_18  ,
            id_rubr_19          = oNew.id_rubr_19  ,
            id_rubr_20          = oNew.id_rubr_20  ,
            id_rubr_21          = oNew.id_rubr_21  ,
            id_rubr_22          = oNew.id_rubr_22  ,
            id_rubr_23          = oNew.id_rubr_23  ,
            id_rubr_24          = oNew.id_rubr_24  ,
            id_rubr_25          = oNew.id_rubr_25  ,
            id_rubr_26          = oNew.id_rubr_26  ,
            id_rubr_27          = oNew.id_rubr_27  ,
            id_rubr_28          = oNew.id_rubr_28  ,
            id_rubr_29          = oNew.id_rubr_29  ,
            id_rubr_30          = oNew.id_rubr_30  ,
            id_rubr_31          = oNew.id_rubr_31  ,
            id_rubr_32          = oNew.id_rubr_32  ,
            id_rubr_33          = oNew.id_rubr_33  ,
            id_rubr_34          = oNew.id_rubr_34  ,
            id_rubr_35          = oNew.id_rubr_35  ,
            id_rubr_36          = oNew.id_rubr_36  ,
            id_rubr_37          = oNew.id_rubr_37  ,
            id_rubr_38          = oNew.id_rubr_38  ,
            id_rubr_39          = oNew.id_rubr_39  ,
            id_rubr_40          = oNew.id_rubr_40  ,
            id_rubr_41          = oNew.id_rubr_41  ,
            id_rubr_42          = oNew.id_rubr_42  ,
            id_rubr_43          = oNew.id_rubr_43  ,
            id_rubr_44          = oNew.id_rubr_44  ,
            id_rubr_45          = oNew.id_rubr_45  ,
            id_rubr_46          = oNew.id_rubr_46  ,
            id_rubr_47          = oNew.id_rubr_47  ,
            id_rubr_48          = oNew.id_rubr_48  ,
            id_rubr_49          = oNew.id_rubr_49  ,
            id_rubr_50          = oNew.id_rubr_50  ,

            code_cons_01        = oNew.code_cons_01,
            code_cons_02        = oNew.code_cons_02,
            code_cons_03        = oNew.code_cons_03,
            code_cons_04        = oNew.code_cons_04,
            code_cons_05        = oNew.code_cons_05,
            code_cons_06        = oNew.code_cons_06,
            code_cons_07        = oNew.code_cons_07,
            code_cons_08        = oNew.code_cons_08,
            code_cons_09        = oNew.code_cons_09,
            code_cons_10        = oNew.code_cons_10,
            code_cons_11        = oNew.code_cons_11,
            code_cons_12        = oNew.code_cons_12,
            code_cons_13        = oNew.code_cons_13,
            code_cons_14        = oNew.code_cons_14,
            code_cons_15        = oNew.code_cons_15,
            code_cons_16        = oNew.code_cons_16,
            code_cons_17        = oNew.code_cons_17,
            code_cons_18        = oNew.code_cons_18,
            code_cons_19        = oNew.code_cons_19,
            code_cons_20        = oNew.code_cons_20,

            vale_rubr_01        = oNew.vale_rubr_01,
            vale_rubr_02        = oNew.vale_rubr_02,
            vale_rubr_03        = oNew.vale_rubr_03,
            vale_rubr_04        = oNew.vale_rubr_04,
            vale_rubr_05        = oNew.vale_rubr_05,
            vale_rubr_06        = oNew.vale_rubr_06,
            vale_rubr_07        = oNew.vale_rubr_07,
            vale_rubr_08        = oNew.vale_rubr_08,
            vale_rubr_09        = oNew.vale_rubr_09,
            vale_rubr_10        = oNew.vale_rubr_10,
            vale_rubr_11        = oNew.vale_rubr_11,
            vale_rubr_12        = oNew.vale_rubr_12,
            vale_rubr_13        = oNew.vale_rubr_13,
            vale_rubr_14        = oNew.vale_rubr_14,
            vale_rubr_15        = oNew.vale_rubr_15,
            vale_rubr_16        = oNew.vale_rubr_16,
            vale_rubr_17        = oNew.vale_rubr_17,
            vale_rubr_18        = oNew.vale_rubr_18,
            vale_rubr_19        = oNew.vale_rubr_19,
            vale_rubr_20        = oNew.vale_rubr_20,
            vale_rubr_21        = oNew.vale_rubr_21,
            vale_rubr_22        = oNew.vale_rubr_22,
            vale_rubr_23        = oNew.vale_rubr_23,
            vale_rubr_24        = oNew.vale_rubr_24,
            vale_rubr_25        = oNew.vale_rubr_25,
            vale_rubr_26        = oNew.vale_rubr_26,
            vale_rubr_27        = oNew.vale_rubr_27,
            vale_rubr_28        = oNew.vale_rubr_28,
            vale_rubr_29        = oNew.vale_rubr_29,
            vale_rubr_30        = oNew.vale_rubr_30,
            vale_rubr_31        = oNew.vale_rubr_31,
            vale_rubr_32        = oNew.vale_rubr_32,
            vale_rubr_33        = oNew.vale_rubr_33,
            vale_rubr_34        = oNew.vale_rubr_34,
            vale_rubr_35        = oNew.vale_rubr_35,
            vale_rubr_36        = oNew.vale_rubr_36,
            vale_rubr_37        = oNew.vale_rubr_37,
            vale_rubr_38        = oNew.vale_rubr_38,
            vale_rubr_39        = oNew.vale_rubr_39,
            vale_rubr_40        = oNew.vale_rubr_40,
            vale_rubr_41        = oNew.vale_rubr_41,
            vale_rubr_42        = oNew.vale_rubr_42,
            vale_rubr_43        = oNew.vale_rubr_43,
            vale_rubr_44        = oNew.vale_rubr_44,
            vale_rubr_45        = oNew.vale_rubr_45,
            vale_rubr_46        = oNew.vale_rubr_46,
            vale_rubr_47        = oNew.vale_rubr_47,
            vale_rubr_48        = oNew.vale_rubr_48,
            vale_rubr_49        = oNew.vale_rubr_49,
            vale_rubr_50        = oNew.vale_rubr_50,
            calc_01_libe        = oNew.calc_01_libe      ,
            calc_02_libe        = oNew.calc_02_libe      ,
            calc_03_libe        = oNew.calc_03_libe      ,
            calc_04_libe        = oNew.calc_04_libe      ,
            calc_05_libe        = oNew.calc_05_libe      ,
            calc_06_libe        = oNew.calc_06_libe      ,
            calc_07_libe        = oNew.calc_07_libe      ,
            calc_08_libe        = oNew.calc_08_libe      ,
            calc_09_libe        = oNew.calc_09_libe      ,
            calc_10_libe        = oNew.calc_10_libe      ,
            calc_11_libe        = oNew.calc_11_libe      ,
            calc_12_libe        = oNew.calc_12_libe      ,
            calc_13_libe        = oNew.calc_13_libe      ,
            calc_14_libe        = oNew.calc_14_libe      ,
            calc_15_libe        = oNew.calc_15_libe      ,
            calc_16_libe        = oNew.calc_16_libe      ,
            calc_17_libe        = oNew.calc_17_libe      ,
            calc_18_libe        = oNew.calc_18_libe      ,
            calc_19_libe        = oNew.calc_19_libe      ,
            calc_20_libe        = oNew.calc_20_libe      ,
            calc_01_operande_1  = oNew.calc_01_operande_1,
            calc_02_operande_1  = oNew.calc_02_operande_1,
            calc_03_operande_1  = oNew.calc_03_operande_1,
            calc_04_operande_1  = oNew.calc_04_operande_1,
            calc_05_operande_1  = oNew.calc_05_operande_1,
            calc_06_operande_1  = oNew.calc_06_operande_1,
            calc_07_operande_1  = oNew.calc_07_operande_1,
            calc_08_operande_1  = oNew.calc_08_operande_1,
            calc_09_operande_1  = oNew.calc_09_operande_1,
            calc_10_operande_1  = oNew.calc_10_operande_1,
            calc_11_operande_1  = oNew.calc_11_operande_1,
            calc_12_operande_1  = oNew.calc_12_operande_1,
            calc_13_operande_1  = oNew.calc_13_operande_1,
            calc_14_operande_1  = oNew.calc_14_operande_1,
            calc_15_operande_1  = oNew.calc_15_operande_1,
            calc_16_operande_1  = oNew.calc_16_operande_1,
            calc_17_operande_1  = oNew.calc_17_operande_1,
            calc_18_operande_1  = oNew.calc_18_operande_1,
            calc_19_operande_1  = oNew.calc_19_operande_1,
            calc_20_operande_1  = oNew.calc_20_operande_1,
            calc_01_operateur   = oNew.calc_01_operateur ,
            calc_02_operateur   = oNew.calc_02_operateur ,
            calc_03_operateur   = oNew.calc_03_operateur ,
            calc_04_operateur   = oNew.calc_04_operateur ,
            calc_05_operateur   = oNew.calc_05_operateur ,
            calc_06_operateur   = oNew.calc_06_operateur ,
            calc_07_operateur   = oNew.calc_07_operateur ,
            calc_08_operateur   = oNew.calc_08_operateur ,
            calc_09_operateur   = oNew.calc_09_operateur ,
            calc_10_operateur   = oNew.calc_10_operateur ,
            calc_11_operateur   = oNew.calc_11_operateur ,
            calc_12_operateur   = oNew.calc_12_operateur ,
            calc_13_operateur   = oNew.calc_13_operateur ,
            calc_14_operateur   = oNew.calc_14_operateur ,
            calc_15_operateur   = oNew.calc_15_operateur ,
            calc_16_operateur   = oNew.calc_16_operateur ,
            calc_17_operateur   = oNew.calc_17_operateur ,
            calc_18_operateur   = oNew.calc_18_operateur ,
            calc_19_operateur   = oNew.calc_19_operateur ,
            calc_20_operateur   = oNew.calc_20_operateur ,
            calc_01_operande_2  = oNew.calc_01_operande_2,
            calc_02_operande_2  = oNew.calc_02_operande_2,
            calc_03_operande_2  = oNew.calc_03_operande_2,
            calc_04_operande_2  = oNew.calc_04_operande_2,
            calc_05_operande_2  = oNew.calc_05_operande_2,
            calc_06_operande_2  = oNew.calc_06_operande_2,
            calc_07_operande_2  = oNew.calc_07_operande_2,
            calc_08_operande_2  = oNew.calc_08_operande_2,
            calc_09_operande_2  = oNew.calc_09_operande_2,
            calc_10_operande_2  = oNew.calc_10_operande_2,
            calc_11_operande_2  = oNew.calc_11_operande_2,
            calc_12_operande_2  = oNew.calc_12_operande_2,
            calc_13_operande_2  = oNew.calc_13_operande_2,
            calc_14_operande_2  = oNew.calc_14_operande_2,
            calc_15_operande_2  = oNew.calc_15_operande_2,
            calc_16_operande_2  = oNew.calc_16_operande_2,
            calc_17_operande_2  = oNew.calc_17_operande_2,
            calc_18_operande_2  = oNew.calc_18_operande_2,
            calc_19_operande_2  = oNew.calc_19_operande_2,
            calc_20_operande_2  = oNew.calc_20_operande_2,
            calc_01_deci        = oNew.calc_01_deci      ,
            calc_02_deci        = oNew.calc_02_deci      ,
            calc_03_deci        = oNew.calc_03_deci      ,
            calc_04_deci        = oNew.calc_04_deci      ,
            calc_05_deci        = oNew.calc_05_deci      ,
            calc_06_deci        = oNew.calc_06_deci      ,
            calc_07_deci        = oNew.calc_07_deci      ,
            calc_08_deci        = oNew.calc_08_deci      ,
            calc_09_deci        = oNew.calc_09_deci      ,
            calc_10_deci        = oNew.calc_10_deci      ,
            calc_11_deci        = oNew.calc_11_deci      ,
            calc_12_deci        = oNew.calc_12_deci      ,
            calc_13_deci        = oNew.calc_13_deci      ,
            calc_14_deci        = oNew.calc_14_deci      ,
            calc_15_deci        = oNew.calc_15_deci      ,
            calc_16_deci        = oNew.calc_16_deci      ,
            calc_17_deci        = oNew.calc_17_deci      ,
            calc_18_deci        = oNew.calc_18_deci      ,
            calc_19_deci        = oNew.calc_19_deci      ,
            calc_20_deci        = oNew.calc_20_deci      ,
            calc_01_mult        = oNew.calc_01_mult      ,
            calc_02_mult        = oNew.calc_02_mult      ,
            calc_03_mult        = oNew.calc_03_mult      ,
            calc_04_mult        = oNew.calc_04_mult      ,
            calc_05_mult        = oNew.calc_05_mult      ,
            calc_06_mult        = oNew.calc_06_mult      ,
            calc_07_mult        = oNew.calc_07_mult      ,
            calc_08_mult        = oNew.calc_08_mult      ,
            calc_09_mult        = oNew.calc_09_mult      ,
            calc_10_mult        = oNew.calc_10_mult      ,
            calc_11_mult        = oNew.calc_11_mult      ,
            calc_12_mult        = oNew.calc_12_mult      ,
            calc_13_mult        = oNew.calc_13_mult      ,
            calc_14_mult        = oNew.calc_14_mult      ,
            calc_15_mult        = oNew.calc_15_mult      ,
            calc_16_mult        = oNew.calc_16_mult      ,
            calc_17_mult        = oNew.calc_17_mult      ,
            calc_18_mult        = oNew.calc_18_mult      ,
            calc_19_mult        = oNew.calc_19_mult      ,
            calc_20_mult        = oNew.calc_20_mult      ,
            dern_sala_base      = pDERN_SALA_BASE        ,
            dern_sala_base_annu = pDERN_SALA_BASE_ANNU   ,
            dern_hora           = pDERN_HORA,
            NOMB_MOIS           = pGEAV_NOMB_MOIS     ,
            SALA_ANNU_CONT      = pGEAV_SALA_ANNU_CONT,
            fili                = pFILI               ,
            sect_prof           = pSECT_PROF          ,
            PART_VARI_CONT      = pGEAV_PART_VARI_CONT
         where id_list = iID_LIST
         ;
         commit;

         -- Maj des champs
         update liste_gestion_avancee_2 set


            rubr_51                  = oNew_2.rubr_51     ,
            rubr_52                  = oNew_2.rubr_52     ,
            rubr_53                  = oNew_2.rubr_53     ,
            rubr_54                  = oNew_2.rubr_54     ,
            rubr_55                  = oNew_2.rubr_55     ,
            rubr_56                  = oNew_2.rubr_56     ,
            rubr_57                  = oNew_2.rubr_57     ,
            rubr_58                  = oNew_2.rubr_58     ,
            rubr_59                  = oNew_2.rubr_59     ,
            rubr_60                  = oNew_2.rubr_60     ,
            rubr_61                  = oNew_2.rubr_61     ,
            rubr_62                  = oNew_2.rubr_62     ,
            rubr_63                  = oNew_2.rubr_63     ,
            rubr_64                  = oNew_2.rubr_64     ,
            rubr_65                  = oNew_2.rubr_65     ,
            rubr_66                  = oNew_2.rubr_66     ,
            rubr_67                  = oNew_2.rubr_67     ,
            rubr_68                  = oNew_2.rubr_68     ,
            rubr_69                  = oNew_2.rubr_69     ,
            rubr_70                  = oNew_2.rubr_70     ,
            rubr_71                  = oNew_2.rubr_71     ,
            rubr_72                  = oNew_2.rubr_72     ,
            rubr_73                  = oNew_2.rubr_73     ,
            rubr_74                  = oNew_2.rubr_74     ,
            rubr_75                  = oNew_2.rubr_75     ,
            rubr_76                  = oNew_2.rubr_76     ,
            rubr_77                  = oNew_2.rubr_77     ,
            rubr_78                  = oNew_2.rubr_78     ,
            rubr_79                  = oNew_2.rubr_79     ,
            rubr_80                  = oNew_2.rubr_80     ,
            rubr_81                  = oNew_2.rubr_81     ,
            rubr_82                  = oNew_2.rubr_82     ,
            rubr_83                  = oNew_2.rubr_83     ,
            rubr_84                  = oNew_2.rubr_84     ,
            rubr_85                  = oNew_2.rubr_85     ,
            rubr_86                  = oNew_2.rubr_86     ,
            rubr_87                  = oNew_2.rubr_87     ,
            rubr_88                  = oNew_2.rubr_88     ,
            rubr_89                  = oNew_2.rubr_89     ,
            rubr_90                  = oNew_2.rubr_90     ,
            rubr_91                  = oNew_2.rubr_91     ,
            rubr_92                  = oNew_2.rubr_92     ,
            rubr_93                  = oNew_2.rubr_93     ,
            rubr_94                  = oNew_2.rubr_94     ,
            rubr_95                  = oNew_2.rubr_95     ,
            rubr_96                  = oNew_2.rubr_96     ,
            rubr_97                  = oNew_2.rubr_97     ,
            rubr_98                  = oNew_2.rubr_98     ,
            rubr_99                  = oNew_2.rubr_99     ,
            rubr_100                  = oNew_2.rubr_100     ,
            rubr_101                  = oNew_2.rubr_101     ,
            rubr_102                  = oNew_2.rubr_102     ,
            rubr_103                  = oNew_2.rubr_103     ,
            rubr_104                  = oNew_2.rubr_104     ,
            rubr_105                  = oNew_2.rubr_105     ,
            rubr_106                  = oNew_2.rubr_106     ,
            rubr_107                  = oNew_2.rubr_107     ,
            rubr_108                  = oNew_2.rubr_108     ,
            rubr_109                  = oNew_2.rubr_109     ,
            rubr_110                  = oNew_2.rubr_110     ,
            rubr_111                  = oNew_2.rubr_111     ,
            rubr_112                  = oNew_2.rubr_112     ,
            rubr_113                  = oNew_2.rubr_113     ,
            rubr_114                  = oNew_2.rubr_114     ,
            rubr_115                  = oNew_2.rubr_115     ,
            rubr_116                  = oNew_2.rubr_116     ,
            rubr_117                  = oNew_2.rubr_117     ,
            rubr_118                  = oNew_2.rubr_118     ,
            rubr_119                  = oNew_2.rubr_119     ,
            rubr_120                  = oNew_2.rubr_120     ,
            rubr_121                  = oNew_2.rubr_121     ,
            rubr_122                  = oNew_2.rubr_122     ,
            rubr_123                  = oNew_2.rubr_123     ,
            rubr_124                  = oNew_2.rubr_124     ,
            rubr_125                  = oNew_2.rubr_125     ,
            rubr_126                  = oNew_2.rubr_126     ,
            rubr_127                  = oNew_2.rubr_127     ,
            rubr_128                  = oNew_2.rubr_128     ,
            rubr_129                  = oNew_2.rubr_129     ,
            rubr_130                  = oNew_2.rubr_130     ,
            rubr_131                  = oNew_2.rubr_131     ,
            rubr_132                  = oNew_2.rubr_132     ,
            rubr_133                  = oNew_2.rubr_133     ,
            rubr_134                  = oNew_2.rubr_134     ,
            rubr_135                  = oNew_2.rubr_135     ,
            rubr_136                  = oNew_2.rubr_136     ,
            rubr_137                  = oNew_2.rubr_137     ,
            rubr_138                  = oNew_2.rubr_138     ,
            rubr_139                  = oNew_2.rubr_139     ,
            rubr_140                  = oNew_2.rubr_140     ,
            rubr_141                  = oNew_2.rubr_141     ,
            rubr_142                  = oNew_2.rubr_142     ,
            rubr_143                  = oNew_2.rubr_143     ,
            rubr_144                  = oNew_2.rubr_144     ,
            rubr_145                  = oNew_2.rubr_145     ,
            rubr_146                  = oNew_2.rubr_146     ,
            rubr_147                  = oNew_2.rubr_147     ,
            rubr_148                  = oNew_2.rubr_148     ,
            rubr_149                  = oNew_2.rubr_149     ,
            rubr_150                  = oNew_2.rubr_150     ,

            libe_rubr_51             = oNew_2.libe_rubr_51,
            libe_rubr_52             = oNew_2.libe_rubr_52,
            libe_rubr_53             = oNew_2.libe_rubr_53,
            libe_rubr_54             = oNew_2.libe_rubr_54,
            libe_rubr_55             = oNew_2.libe_rubr_55,
            libe_rubr_56             = oNew_2.libe_rubr_56,
            libe_rubr_57             = oNew_2.libe_rubr_57,
            libe_rubr_58             = oNew_2.libe_rubr_58,
            libe_rubr_59             = oNew_2.libe_rubr_59,
            libe_rubr_60             = oNew_2.libe_rubr_60,
            libe_rubr_61             = oNew_2.libe_rubr_61,
            libe_rubr_62             = oNew_2.libe_rubr_62,
            libe_rubr_63             = oNew_2.libe_rubr_63,
            libe_rubr_64             = oNew_2.libe_rubr_64,
            libe_rubr_65             = oNew_2.libe_rubr_65,
            libe_rubr_66             = oNew_2.libe_rubr_66,
            libe_rubr_67             = oNew_2.libe_rubr_67,
            libe_rubr_68             = oNew_2.libe_rubr_68,
            libe_rubr_69             = oNew_2.libe_rubr_69,
            libe_rubr_70             = oNew_2.libe_rubr_70,
            libe_rubr_71             = oNew_2.libe_rubr_71,
            libe_rubr_72             = oNew_2.libe_rubr_72,
            libe_rubr_73             = oNew_2.libe_rubr_73,
            libe_rubr_74             = oNew_2.libe_rubr_74,
            libe_rubr_75             = oNew_2.libe_rubr_75,
            libe_rubr_76             = oNew_2.libe_rubr_76,
            libe_rubr_77             = oNew_2.libe_rubr_77,
            libe_rubr_78             = oNew_2.libe_rubr_78,
            libe_rubr_79             = oNew_2.libe_rubr_79,
            libe_rubr_80             = oNew_2.libe_rubr_80,
            libe_rubr_81             = oNew_2.libe_rubr_81,
            libe_rubr_82             = oNew_2.libe_rubr_82,
            libe_rubr_83             = oNew_2.libe_rubr_83,
            libe_rubr_84             = oNew_2.libe_rubr_84,
            libe_rubr_85             = oNew_2.libe_rubr_85,
            libe_rubr_86             = oNew_2.libe_rubr_86,
            libe_rubr_87             = oNew_2.libe_rubr_87,
            libe_rubr_88             = oNew_2.libe_rubr_88,
            libe_rubr_89             = oNew_2.libe_rubr_89,
            libe_rubr_90             = oNew_2.libe_rubr_90,
            libe_rubr_91             = oNew_2.libe_rubr_91,
            libe_rubr_92             = oNew_2.libe_rubr_92,
            libe_rubr_93             = oNew_2.libe_rubr_93,
            libe_rubr_94             = oNew_2.libe_rubr_94,
            libe_rubr_95             = oNew_2.libe_rubr_95,
            libe_rubr_96             = oNew_2.libe_rubr_96,
            libe_rubr_97             = oNew_2.libe_rubr_97,
            libe_rubr_98             = oNew_2.libe_rubr_98,
            libe_rubr_99             = oNew_2.libe_rubr_99,
            libe_rubr_100             = oNew_2.libe_rubr_100,
            libe_rubr_101             = oNew_2.libe_rubr_101,
            libe_rubr_102             = oNew_2.libe_rubr_102,
            libe_rubr_103             = oNew_2.libe_rubr_103,
            libe_rubr_104             = oNew_2.libe_rubr_104,
            libe_rubr_105             = oNew_2.libe_rubr_105,
            libe_rubr_106             = oNew_2.libe_rubr_106,
            libe_rubr_107             = oNew_2.libe_rubr_107,
            libe_rubr_108             = oNew_2.libe_rubr_108,
            libe_rubr_109             = oNew_2.libe_rubr_109,
            libe_rubr_110             = oNew_2.libe_rubr_110,
            libe_rubr_111             = oNew_2.libe_rubr_111,
            libe_rubr_112             = oNew_2.libe_rubr_112,
            libe_rubr_113             = oNew_2.libe_rubr_113,
            libe_rubr_114             = oNew_2.libe_rubr_114,
            libe_rubr_115             = oNew_2.libe_rubr_115,
            libe_rubr_116             = oNew_2.libe_rubr_116,
            libe_rubr_117             = oNew_2.libe_rubr_117,
            libe_rubr_118             = oNew_2.libe_rubr_118,
            libe_rubr_119             = oNew_2.libe_rubr_119,
            libe_rubr_120             = oNew_2.libe_rubr_120,
            libe_rubr_121             = oNew_2.libe_rubr_121,
            libe_rubr_122             = oNew_2.libe_rubr_122,
            libe_rubr_123             = oNew_2.libe_rubr_123,
            libe_rubr_124             = oNew_2.libe_rubr_124,
            libe_rubr_125             = oNew_2.libe_rubr_125,
            libe_rubr_126             = oNew_2.libe_rubr_126,
            libe_rubr_127             = oNew_2.libe_rubr_127,
            libe_rubr_128             = oNew_2.libe_rubr_128,
            libe_rubr_129             = oNew_2.libe_rubr_129,
            libe_rubr_130             = oNew_2.libe_rubr_130,
            libe_rubr_131             = oNew_2.libe_rubr_131,
            libe_rubr_132             = oNew_2.libe_rubr_132,
            libe_rubr_133             = oNew_2.libe_rubr_133,
            libe_rubr_134             = oNew_2.libe_rubr_134,
            libe_rubr_135             = oNew_2.libe_rubr_135,
            libe_rubr_136             = oNew_2.libe_rubr_136,
            libe_rubr_137             = oNew_2.libe_rubr_137,
            libe_rubr_138             = oNew_2.libe_rubr_138,
            libe_rubr_139             = oNew_2.libe_rubr_139,
            libe_rubr_140             = oNew_2.libe_rubr_140,
            libe_rubr_141             = oNew_2.libe_rubr_141,
            libe_rubr_142             = oNew_2.libe_rubr_142,
            libe_rubr_143             = oNew_2.libe_rubr_143,
            libe_rubr_144             = oNew_2.libe_rubr_144,
            libe_rubr_145             = oNew_2.libe_rubr_145,
            libe_rubr_146             = oNew_2.libe_rubr_146,
            libe_rubr_147             = oNew_2.libe_rubr_147,
            libe_rubr_148             = oNew_2.libe_rubr_148,
            libe_rubr_149             = oNew_2.libe_rubr_149,
            libe_rubr_150             = oNew_2.libe_rubr_150,

            id_rubr_51          = oNew_2.id_rubr_51  ,
            id_rubr_52          = oNew_2.id_rubr_52  ,
            id_rubr_53          = oNew_2.id_rubr_53  ,
            id_rubr_54          = oNew_2.id_rubr_54  ,
            id_rubr_55          = oNew_2.id_rubr_55  ,
            id_rubr_56          = oNew_2.id_rubr_56  ,
            id_rubr_57          = oNew_2.id_rubr_57  ,
            id_rubr_58          = oNew_2.id_rubr_58  ,
            id_rubr_59          = oNew_2.id_rubr_59  ,
            id_rubr_60          = oNew_2.id_rubr_60  ,
            id_rubr_61          = oNew_2.id_rubr_61  ,
            id_rubr_62          = oNew_2.id_rubr_62  ,
            id_rubr_63          = oNew_2.id_rubr_63  ,
            id_rubr_64          = oNew_2.id_rubr_64  ,
            id_rubr_65          = oNew_2.id_rubr_65  ,
            id_rubr_66          = oNew_2.id_rubr_66  ,
            id_rubr_67          = oNew_2.id_rubr_67  ,
            id_rubr_68          = oNew_2.id_rubr_68  ,
            id_rubr_69          = oNew_2.id_rubr_69  ,
            id_rubr_70          = oNew_2.id_rubr_70  ,
            id_rubr_71          = oNew_2.id_rubr_71  ,
            id_rubr_72          = oNew_2.id_rubr_72  ,
            id_rubr_73          = oNew_2.id_rubr_73  ,
            id_rubr_74          = oNew_2.id_rubr_74  ,
            id_rubr_75          = oNew_2.id_rubr_75  ,
            id_rubr_76          = oNew_2.id_rubr_76  ,
            id_rubr_77          = oNew_2.id_rubr_77  ,
            id_rubr_78          = oNew_2.id_rubr_78  ,
            id_rubr_79          = oNew_2.id_rubr_79  ,
            id_rubr_80          = oNew_2.id_rubr_80  ,
            id_rubr_81          = oNew_2.id_rubr_81  ,
            id_rubr_82          = oNew_2.id_rubr_82  ,
            id_rubr_83          = oNew_2.id_rubr_83  ,
            id_rubr_84          = oNew_2.id_rubr_84  ,
            id_rubr_85          = oNew_2.id_rubr_85  ,
            id_rubr_86          = oNew_2.id_rubr_86  ,
            id_rubr_87          = oNew_2.id_rubr_87  ,
            id_rubr_88          = oNew_2.id_rubr_88  ,
            id_rubr_89          = oNew_2.id_rubr_89  ,
            id_rubr_90          = oNew_2.id_rubr_90  ,
            id_rubr_91          = oNew_2.id_rubr_91  ,
            id_rubr_92          = oNew_2.id_rubr_92  ,
            id_rubr_93          = oNew_2.id_rubr_93  ,
            id_rubr_94          = oNew_2.id_rubr_94  ,
            id_rubr_95          = oNew_2.id_rubr_95  ,
            id_rubr_96          = oNew_2.id_rubr_96  ,
            id_rubr_97          = oNew_2.id_rubr_97  ,
            id_rubr_98          = oNew_2.id_rubr_98  ,
            id_rubr_99          = oNew_2.id_rubr_99  ,
            id_rubr_100          = oNew_2.id_rubr_100  ,
            id_rubr_101          = oNew_2.id_rubr_101  ,
            id_rubr_102          = oNew_2.id_rubr_102  ,
            id_rubr_103          = oNew_2.id_rubr_103  ,
            id_rubr_104          = oNew_2.id_rubr_104  ,
            id_rubr_105          = oNew_2.id_rubr_105  ,
            id_rubr_106          = oNew_2.id_rubr_106  ,
            id_rubr_107          = oNew_2.id_rubr_107  ,
            id_rubr_108          = oNew_2.id_rubr_108  ,
            id_rubr_109          = oNew_2.id_rubr_109  ,
            id_rubr_110          = oNew_2.id_rubr_110  ,
            id_rubr_111          = oNew_2.id_rubr_111  ,
            id_rubr_112          = oNew_2.id_rubr_112  ,
            id_rubr_113          = oNew_2.id_rubr_113  ,
            id_rubr_114          = oNew_2.id_rubr_114  ,
            id_rubr_115          = oNew_2.id_rubr_115  ,
            id_rubr_116          = oNew_2.id_rubr_116  ,
            id_rubr_117          = oNew_2.id_rubr_117  ,
            id_rubr_118          = oNew_2.id_rubr_118  ,
            id_rubr_119          = oNew_2.id_rubr_119  ,
            id_rubr_120          = oNew_2.id_rubr_120  ,
            id_rubr_121          = oNew_2.id_rubr_121  ,
            id_rubr_122          = oNew_2.id_rubr_122  ,
            id_rubr_123          = oNew_2.id_rubr_123  ,
            id_rubr_124          = oNew_2.id_rubr_124  ,
            id_rubr_125          = oNew_2.id_rubr_125  ,
            id_rubr_126          = oNew_2.id_rubr_126  ,
            id_rubr_127          = oNew_2.id_rubr_127  ,
            id_rubr_128          = oNew_2.id_rubr_128  ,
            id_rubr_129          = oNew_2.id_rubr_129  ,
            id_rubr_130          = oNew_2.id_rubr_130  ,
            id_rubr_131          = oNew_2.id_rubr_131  ,
            id_rubr_132          = oNew_2.id_rubr_132  ,
            id_rubr_133          = oNew_2.id_rubr_133  ,
            id_rubr_134          = oNew_2.id_rubr_134  ,
            id_rubr_135          = oNew_2.id_rubr_135  ,
            id_rubr_136          = oNew_2.id_rubr_136  ,
            id_rubr_137          = oNew_2.id_rubr_137  ,
            id_rubr_138          = oNew_2.id_rubr_138  ,
            id_rubr_139          = oNew_2.id_rubr_139  ,
            id_rubr_140          = oNew_2.id_rubr_140  ,
            id_rubr_141          = oNew_2.id_rubr_141  ,
            id_rubr_142          = oNew_2.id_rubr_142  ,
            id_rubr_143          = oNew_2.id_rubr_143  ,
            id_rubr_144          = oNew_2.id_rubr_144  ,
            id_rubr_145          = oNew_2.id_rubr_145  ,
            id_rubr_146          = oNew_2.id_rubr_146  ,
            id_rubr_147          = oNew_2.id_rubr_147  ,
            id_rubr_148          = oNew_2.id_rubr_148  ,
            id_rubr_149          = oNew_2.id_rubr_149  ,
            id_rubr_150          = oNew_2.id_rubr_150  ,

            vale_rubr_51         = oNew_2.vale_rubr_51,
            vale_rubr_52         = oNew_2.vale_rubr_52,
            vale_rubr_53         = oNew_2.vale_rubr_53,
            vale_rubr_54         = oNew_2.vale_rubr_54,
            vale_rubr_55         = oNew_2.vale_rubr_55,
            vale_rubr_56         = oNew_2.vale_rubr_56,
            vale_rubr_57         = oNew_2.vale_rubr_57,
            vale_rubr_58         = oNew_2.vale_rubr_58,
            vale_rubr_59         = oNew_2.vale_rubr_59,
            vale_rubr_60         = oNew_2.vale_rubr_60,
            vale_rubr_61         = oNew_2.vale_rubr_61,
            vale_rubr_62         = oNew_2.vale_rubr_62,
            vale_rubr_63         = oNew_2.vale_rubr_63,
            vale_rubr_64         = oNew_2.vale_rubr_64,
            vale_rubr_65         = oNew_2.vale_rubr_65,
            vale_rubr_66         = oNew_2.vale_rubr_66,
            vale_rubr_67         = oNew_2.vale_rubr_67,
            vale_rubr_68         = oNew_2.vale_rubr_68,
            vale_rubr_69         = oNew_2.vale_rubr_69,
            vale_rubr_70         = oNew_2.vale_rubr_70,
            vale_rubr_71         = oNew_2.vale_rubr_71,
            vale_rubr_72         = oNew_2.vale_rubr_72,
            vale_rubr_73         = oNew_2.vale_rubr_73,
            vale_rubr_74         = oNew_2.vale_rubr_74,
            vale_rubr_75         = oNew_2.vale_rubr_75,
            vale_rubr_76         = oNew_2.vale_rubr_76,
            vale_rubr_77         = oNew_2.vale_rubr_77,
            vale_rubr_78         = oNew_2.vale_rubr_78,
            vale_rubr_79         = oNew_2.vale_rubr_79,
            vale_rubr_80         = oNew_2.vale_rubr_80,
            vale_rubr_81         = oNew_2.vale_rubr_81,
            vale_rubr_82         = oNew_2.vale_rubr_82,
            vale_rubr_83         = oNew_2.vale_rubr_83,
            vale_rubr_84         = oNew_2.vale_rubr_84,
            vale_rubr_85         = oNew_2.vale_rubr_85,
            vale_rubr_86         = oNew_2.vale_rubr_86,
            vale_rubr_87         = oNew_2.vale_rubr_87,
            vale_rubr_88         = oNew_2.vale_rubr_88,
            vale_rubr_89         = oNew_2.vale_rubr_89,
            vale_rubr_90         = oNew_2.vale_rubr_90,
            vale_rubr_91         = oNew_2.vale_rubr_91,
            vale_rubr_92         = oNew_2.vale_rubr_92,
            vale_rubr_93         = oNew_2.vale_rubr_93,
            vale_rubr_94         = oNew_2.vale_rubr_94,
            vale_rubr_95         = oNew_2.vale_rubr_95,
            vale_rubr_96         = oNew_2.vale_rubr_96,
            vale_rubr_97         = oNew_2.vale_rubr_97,
            vale_rubr_98         = oNew_2.vale_rubr_98,
            vale_rubr_99         = oNew_2.vale_rubr_99,
            vale_rubr_100        = oNew_2.vale_rubr_100,
            vale_rubr_101        = oNew_2.vale_rubr_101,
            vale_rubr_102        = oNew_2.vale_rubr_102,
            vale_rubr_103        = oNew_2.vale_rubr_103,
            vale_rubr_104        = oNew_2.vale_rubr_104,
            vale_rubr_105        = oNew_2.vale_rubr_105,
            vale_rubr_106        = oNew_2.vale_rubr_106,
            vale_rubr_107        = oNew_2.vale_rubr_107,
            vale_rubr_108        = oNew_2.vale_rubr_108,
            vale_rubr_109        = oNew_2.vale_rubr_109,
            vale_rubr_110        = oNew_2.vale_rubr_110,
            vale_rubr_111        = oNew_2.vale_rubr_111,
            vale_rubr_112        = oNew_2.vale_rubr_112,
            vale_rubr_113        = oNew_2.vale_rubr_113,
            vale_rubr_114        = oNew_2.vale_rubr_114,
            vale_rubr_115        = oNew_2.vale_rubr_115,
            vale_rubr_116        = oNew_2.vale_rubr_116,
            vale_rubr_117        = oNew_2.vale_rubr_117,
            vale_rubr_118        = oNew_2.vale_rubr_118,
            vale_rubr_119        = oNew_2.vale_rubr_119,
            vale_rubr_120        = oNew_2.vale_rubr_120,
            vale_rubr_121        = oNew_2.vale_rubr_121,
            vale_rubr_122        = oNew_2.vale_rubr_122,
            vale_rubr_123        = oNew_2.vale_rubr_123,
            vale_rubr_124        = oNew_2.vale_rubr_124,
            vale_rubr_125        = oNew_2.vale_rubr_125,
            vale_rubr_126        = oNew_2.vale_rubr_126,
            vale_rubr_127        = oNew_2.vale_rubr_127,
            vale_rubr_128        = oNew_2.vale_rubr_128,
            vale_rubr_129        = oNew_2.vale_rubr_129,
            vale_rubr_130        = oNew_2.vale_rubr_130,
            vale_rubr_131        = oNew_2.vale_rubr_131,
            vale_rubr_132        = oNew_2.vale_rubr_132,
            vale_rubr_133        = oNew_2.vale_rubr_133,
            vale_rubr_134        = oNew_2.vale_rubr_134,
            vale_rubr_135        = oNew_2.vale_rubr_135,
            vale_rubr_136        = oNew_2.vale_rubr_136,
            vale_rubr_137        = oNew_2.vale_rubr_137,
            vale_rubr_138        = oNew_2.vale_rubr_138,
            vale_rubr_139        = oNew_2.vale_rubr_139,
            vale_rubr_140        = oNew_2.vale_rubr_140,
            vale_rubr_141        = oNew_2.vale_rubr_141,
            vale_rubr_142        = oNew_2.vale_rubr_142,
            vale_rubr_143        = oNew_2.vale_rubr_143,
            vale_rubr_144        = oNew_2.vale_rubr_144,
            vale_rubr_145        = oNew_2.vale_rubr_145,
            vale_rubr_146        = oNew_2.vale_rubr_146,
            vale_rubr_147        = oNew_2.vale_rubr_147,
            vale_rubr_148        = oNew_2.vale_rubr_148,
            vale_rubr_149        = oNew_2.vale_rubr_149,
            vale_rubr_150        = oNew_2.vale_rubr_150,

            calc_rubr_01         = oNew_2.calc_rubr_01,
            calc_rubr_02         = oNew_2.calc_rubr_02,
            calc_rubr_03         = oNew_2.calc_rubr_03,
            calc_rubr_04         = oNew_2.calc_rubr_04,
            calc_rubr_05         = oNew_2.calc_rubr_05,
            calc_rubr_06         = oNew_2.calc_rubr_06,
            calc_rubr_07         = oNew_2.calc_rubr_07,
            calc_rubr_08         = oNew_2.calc_rubr_08,
            calc_rubr_09         = oNew_2.calc_rubr_09,
            calc_rubr_10         = oNew_2.calc_rubr_10,
            calc_rubr_11         = oNew_2.calc_rubr_11,
            calc_rubr_12         = oNew_2.calc_rubr_12,
            calc_rubr_13         = oNew_2.calc_rubr_13,
            calc_rubr_14         = oNew_2.calc_rubr_14,
            calc_rubr_15         = oNew_2.calc_rubr_15,
            calc_rubr_16         = oNew_2.calc_rubr_16,
            calc_rubr_17         = oNew_2.calc_rubr_17,
            calc_rubr_18         = oNew_2.calc_rubr_18,
            calc_rubr_19         = oNew_2.calc_rubr_19,
            calc_rubr_20         = oNew_2.calc_rubr_20,
            calc_rubr_21         = oNew_2.calc_rubr_21,
            calc_rubr_22         = oNew_2.calc_rubr_22,
            calc_rubr_23         = oNew_2.calc_rubr_23,
            calc_rubr_24         = oNew_2.calc_rubr_24,
            calc_rubr_25         = oNew_2.calc_rubr_25,
            calc_rubr_26         = oNew_2.calc_rubr_26,
            calc_rubr_27         = oNew_2.calc_rubr_27,
            calc_rubr_28         = oNew_2.calc_rubr_28,
            calc_rubr_29         = oNew_2.calc_rubr_29,
            calc_rubr_30         = oNew_2.calc_rubr_30,
            calc_rubr_31         = oNew_2.calc_rubr_31,
            calc_rubr_32         = oNew_2.calc_rubr_32,
            calc_rubr_33         = oNew_2.calc_rubr_33,
            calc_rubr_34         = oNew_2.calc_rubr_34,
            calc_rubr_35         = oNew_2.calc_rubr_35,
            calc_rubr_36         = oNew_2.calc_rubr_36,
            calc_rubr_37         = oNew_2.calc_rubr_37,
            calc_rubr_38         = oNew_2.calc_rubr_38,
            calc_rubr_39         = oNew_2.calc_rubr_39,
            calc_rubr_40         = oNew_2.calc_rubr_40,
            calc_rubr_41         = oNew_2.calc_rubr_41,
            calc_rubr_42         = oNew_2.calc_rubr_42,
            calc_rubr_43         = oNew_2.calc_rubr_43,
            calc_rubr_44         = oNew_2.calc_rubr_44,
            calc_rubr_45         = oNew_2.calc_rubr_45,
            calc_rubr_46         = oNew_2.calc_rubr_46,
            calc_rubr_47         = oNew_2.calc_rubr_47,
            calc_rubr_48         = oNew_2.calc_rubr_48,
            calc_rubr_49         = oNew_2.calc_rubr_49,
            calc_rubr_50         = oNew_2.calc_rubr_50,

            calc_rubr_51        = oNew_2.calc_rubr_51,
            calc_rubr_52        = oNew_2.calc_rubr_52,
            calc_rubr_53        = oNew_2.calc_rubr_53,
            calc_rubr_54        = oNew_2.calc_rubr_54,
            calc_rubr_55        = oNew_2.calc_rubr_55,
            calc_rubr_56        = oNew_2.calc_rubr_56,
            calc_rubr_57        = oNew_2.calc_rubr_57,
            calc_rubr_58        = oNew_2.calc_rubr_58,
            calc_rubr_59        = oNew_2.calc_rubr_59,
            calc_rubr_60        = oNew_2.calc_rubr_60,
            calc_rubr_61        = oNew_2.calc_rubr_61,
            calc_rubr_62        = oNew_2.calc_rubr_62,
            calc_rubr_63        = oNew_2.calc_rubr_63,
            calc_rubr_64        = oNew_2.calc_rubr_64,
            calc_rubr_65        = oNew_2.calc_rubr_65,
            calc_rubr_66        = oNew_2.calc_rubr_66,
            calc_rubr_67        = oNew_2.calc_rubr_67,
            calc_rubr_68        = oNew_2.calc_rubr_68,
            calc_rubr_69        = oNew_2.calc_rubr_69,
            calc_rubr_70        = oNew_2.calc_rubr_70,
            calc_rubr_71        = oNew_2.calc_rubr_71,
            calc_rubr_72        = oNew_2.calc_rubr_72,
            calc_rubr_73        = oNew_2.calc_rubr_73,
            calc_rubr_74        = oNew_2.calc_rubr_74,
            calc_rubr_75        = oNew_2.calc_rubr_75,
            calc_rubr_76        = oNew_2.calc_rubr_76,
            calc_rubr_77        = oNew_2.calc_rubr_77,
            calc_rubr_78        = oNew_2.calc_rubr_78,
            calc_rubr_79        = oNew_2.calc_rubr_79,
            calc_rubr_80        = oNew_2.calc_rubr_80,
            calc_rubr_81        = oNew_2.calc_rubr_81,
            calc_rubr_82        = oNew_2.calc_rubr_82,
            calc_rubr_83        = oNew_2.calc_rubr_83,
            calc_rubr_84        = oNew_2.calc_rubr_84,
            calc_rubr_85        = oNew_2.calc_rubr_85,
            calc_rubr_86        = oNew_2.calc_rubr_86,
            calc_rubr_87        = oNew_2.calc_rubr_87,
            calc_rubr_88        = oNew_2.calc_rubr_88,
            calc_rubr_89        = oNew_2.calc_rubr_89,
            calc_rubr_90        = oNew_2.calc_rubr_90,
            calc_rubr_91        = oNew_2.calc_rubr_91,
            calc_rubr_92        = oNew_2.calc_rubr_92,
            calc_rubr_93        = oNew_2.calc_rubr_93,
            calc_rubr_94        = oNew_2.calc_rubr_94,
            calc_rubr_95        = oNew_2.calc_rubr_95,
            calc_rubr_96        = oNew_2.calc_rubr_96,
            calc_rubr_97        = oNew_2.calc_rubr_97,
            calc_rubr_98        = oNew_2.calc_rubr_98,
            calc_rubr_99        = oNew_2.calc_rubr_99,
            calc_rubr_100        = oNew_2.calc_rubr_100,
            calc_rubr_101        = oNew_2.calc_rubr_101,
            calc_rubr_102        = oNew_2.calc_rubr_102,
            calc_rubr_103        = oNew_2.calc_rubr_103,
            calc_rubr_104        = oNew_2.calc_rubr_104,
            calc_rubr_105        = oNew_2.calc_rubr_105,
            calc_rubr_106        = oNew_2.calc_rubr_106,
            calc_rubr_107        = oNew_2.calc_rubr_107,
            calc_rubr_108        = oNew_2.calc_rubr_108,
            calc_rubr_109        = oNew_2.calc_rubr_109,
            calc_rubr_110        = oNew_2.calc_rubr_110,
            calc_rubr_111        = oNew_2.calc_rubr_111,
            calc_rubr_112        = oNew_2.calc_rubr_112,
            calc_rubr_113        = oNew_2.calc_rubr_113,
            calc_rubr_114        = oNew_2.calc_rubr_114,
            calc_rubr_115        = oNew_2.calc_rubr_115,
            calc_rubr_116        = oNew_2.calc_rubr_116,
            calc_rubr_117        = oNew_2.calc_rubr_117,
            calc_rubr_118        = oNew_2.calc_rubr_118,
            calc_rubr_119        = oNew_2.calc_rubr_119,
            calc_rubr_120        = oNew_2.calc_rubr_120,
            calc_rubr_121        = oNew_2.calc_rubr_121,
            calc_rubr_122        = oNew_2.calc_rubr_122,
            calc_rubr_123        = oNew_2.calc_rubr_123,
            calc_rubr_124        = oNew_2.calc_rubr_124,
            calc_rubr_125        = oNew_2.calc_rubr_125,
            calc_rubr_126        = oNew_2.calc_rubr_126,
            calc_rubr_127        = oNew_2.calc_rubr_127,
            calc_rubr_128        = oNew_2.calc_rubr_128,
            calc_rubr_129        = oNew_2.calc_rubr_129,
            calc_rubr_130        = oNew_2.calc_rubr_130,
            calc_rubr_131        = oNew_2.calc_rubr_131,
            calc_rubr_132        = oNew_2.calc_rubr_132,
            calc_rubr_133        = oNew_2.calc_rubr_133,
            calc_rubr_134        = oNew_2.calc_rubr_134,
            calc_rubr_135        = oNew_2.calc_rubr_135,
            calc_rubr_136        = oNew_2.calc_rubr_136,
            calc_rubr_137        = oNew_2.calc_rubr_137,
            calc_rubr_138        = oNew_2.calc_rubr_138,
            calc_rubr_139        = oNew_2.calc_rubr_139,
            calc_rubr_140        = oNew_2.calc_rubr_140,
            calc_rubr_141        = oNew_2.calc_rubr_141,
            calc_rubr_142        = oNew_2.calc_rubr_142,
            calc_rubr_143        = oNew_2.calc_rubr_143,
            calc_rubr_144        = oNew_2.calc_rubr_144,
            calc_rubr_145        = oNew_2.calc_rubr_145,
            calc_rubr_146        = oNew_2.calc_rubr_146,
            calc_rubr_147        = oNew_2.calc_rubr_147,
            calc_rubr_148        = oNew_2.calc_rubr_148,
            calc_rubr_149        = oNew_2.calc_rubr_149,
            calc_rubr_150        = oNew_2.calc_rubr_150,

            cons_21                  = oNew_2.cons_21     ,
            cons_22                  = oNew_2.cons_22     ,
            cons_23                  = oNew_2.cons_23     ,
            cons_24                  = oNew_2.cons_24     ,
            cons_25                  = oNew_2.cons_25     ,
            cons_26                  = oNew_2.cons_26     ,
            cons_27                  = oNew_2.cons_27     ,
            cons_28                  = oNew_2.cons_28     ,
            cons_29                  = oNew_2.cons_29     ,
            cons_30                  = oNew_2.cons_30     ,
            cons_31                  = oNew_2.cons_31     ,
            cons_32                  = oNew_2.cons_32     ,
            cons_33                  = oNew_2.cons_33     ,
            cons_34                  = oNew_2.cons_34     ,
            cons_35                  = oNew_2.cons_35     ,
            cons_36                  = oNew_2.cons_36     ,
            cons_37                  = oNew_2.cons_37     ,
            cons_38                  = oNew_2.cons_38     ,
            cons_39                  = oNew_2.cons_39     ,
            cons_40                  = oNew_2.cons_40     ,
            cons_41                  = oNew_2.cons_41     ,
            cons_42                  = oNew_2.cons_42     ,
            cons_43                  = oNew_2.cons_43     ,
            cons_44                  = oNew_2.cons_44     ,
            cons_45                  = oNew_2.cons_45     ,
            cons_46                  = oNew_2.cons_46     ,
            cons_47                  = oNew_2.cons_47     ,
            cons_48                  = oNew_2.cons_48     ,
            cons_49                  = oNew_2.cons_49     ,
            cons_50                  = oNew_2.cons_50     ,

            libe_cons_21        = oNew_2.libe_cons_21,
            libe_cons_22        = oNew_2.libe_cons_22,
            libe_cons_23        = oNew_2.libe_cons_23,
            libe_cons_24        = oNew_2.libe_cons_24,
            libe_cons_25        = oNew_2.libe_cons_25,
            libe_cons_26        = oNew_2.libe_cons_26,
            libe_cons_27        = oNew_2.libe_cons_27,
            libe_cons_28        = oNew_2.libe_cons_28,
            libe_cons_29        = oNew_2.libe_cons_29,
            libe_cons_30        = oNew_2.libe_cons_30,
            libe_cons_31        = oNew_2.libe_cons_31,
            libe_cons_32        = oNew_2.libe_cons_32,
            libe_cons_33        = oNew_2.libe_cons_33,
            libe_cons_34        = oNew_2.libe_cons_34,
            libe_cons_35        = oNew_2.libe_cons_35,
            libe_cons_36        = oNew_2.libe_cons_36,
            libe_cons_37        = oNew_2.libe_cons_37,
            libe_cons_38        = oNew_2.libe_cons_38,
            libe_cons_39        = oNew_2.libe_cons_39,
            libe_cons_40        = oNew_2.libe_cons_40,
            libe_cons_41        = oNew_2.libe_cons_41,
            libe_cons_42        = oNew_2.libe_cons_42,
            libe_cons_43        = oNew_2.libe_cons_43,
            libe_cons_44        = oNew_2.libe_cons_44,
            libe_cons_45        = oNew_2.libe_cons_45,
            libe_cons_46        = oNew_2.libe_cons_46,
            libe_cons_47        = oNew_2.libe_cons_47,
            libe_cons_48        = oNew_2.libe_cons_48,
            libe_cons_49        = oNew_2.libe_cons_49,
            libe_cons_50        = oNew_2.libe_cons_50,

            cons_repa_21        = oNew_2.cons_repa_21,
            cons_repa_22        = oNew_2.cons_repa_22,
            cons_repa_23        = oNew_2.cons_repa_23,
            cons_repa_24        = oNew_2.cons_repa_24,
            cons_repa_25        = oNew_2.cons_repa_25,
            cons_repa_26        = oNew_2.cons_repa_26,
            cons_repa_27        = oNew_2.cons_repa_27,
            cons_repa_28        = oNew_2.cons_repa_28,
            cons_repa_29        = oNew_2.cons_repa_29,
            cons_repa_30        = oNew_2.cons_repa_30,
            cons_repa_31        = oNew_2.cons_repa_31,
            cons_repa_32        = oNew_2.cons_repa_32,
            cons_repa_33        = oNew_2.cons_repa_33,
            cons_repa_34        = oNew_2.cons_repa_34,
            cons_repa_35        = oNew_2.cons_repa_35,
            cons_repa_36        = oNew_2.cons_repa_36,
            cons_repa_37        = oNew_2.cons_repa_37,
            cons_repa_38        = oNew_2.cons_repa_38,
            cons_repa_39        = oNew_2.cons_repa_39,
            cons_repa_40        = oNew_2.cons_repa_40,
            cons_repa_41        = oNew_2.cons_repa_41,
            cons_repa_42        = oNew_2.cons_repa_42,
            cons_repa_43        = oNew_2.cons_repa_43,
            cons_repa_44        = oNew_2.cons_repa_44,
            cons_repa_45        = oNew_2.cons_repa_45,
            cons_repa_46        = oNew_2.cons_repa_46,
            cons_repa_47        = oNew_2.cons_repa_47,
            cons_repa_48        = oNew_2.cons_repa_48,
            cons_repa_49        = oNew_2.cons_repa_49,
            cons_repa_50        = oNew_2.cons_repa_50,

            code_cons_21        = oNew_2.code_cons_21,
            code_cons_22        = oNew_2.code_cons_22,
            code_cons_23        = oNew_2.code_cons_23,
            code_cons_24        = oNew_2.code_cons_24,
            code_cons_25        = oNew_2.code_cons_25,
            code_cons_26        = oNew_2.code_cons_26,
            code_cons_27        = oNew_2.code_cons_27,
            code_cons_28        = oNew_2.code_cons_28,
            code_cons_29        = oNew_2.code_cons_29,
            code_cons_30        = oNew_2.code_cons_30,
            code_cons_31        = oNew_2.code_cons_31,
            code_cons_32        = oNew_2.code_cons_32,
            code_cons_33        = oNew_2.code_cons_33,
            code_cons_34        = oNew_2.code_cons_34,
            code_cons_35        = oNew_2.code_cons_35,
            code_cons_36        = oNew_2.code_cons_36,
            code_cons_37        = oNew_2.code_cons_37,
            code_cons_38        = oNew_2.code_cons_38,
            code_cons_39        = oNew_2.code_cons_39,
            code_cons_40        = oNew_2.code_cons_40,
            code_cons_41        = oNew_2.code_cons_41,
            code_cons_42        = oNew_2.code_cons_42,
            code_cons_43        = oNew_2.code_cons_43,
            code_cons_44        = oNew_2.code_cons_44,
            code_cons_45        = oNew_2.code_cons_45,
            code_cons_46        = oNew_2.code_cons_46,
            code_cons_47        = oNew_2.code_cons_47,
            code_cons_48        = oNew_2.code_cons_48,
            code_cons_49        = oNew_2.code_cons_49,
            code_cons_50        = oNew_2.code_cons_50,
            SALA_FORF_TEMP      = pSALA_FORF_TEMP,
            NOMB_JOUR_FORF_TEMP = pNOMB_JOUR_FORF_TEMP,
            NOMB_HEUR_FORF_TEMP = pNOMB_HEUR_FORF_TEMP,
            code_fine_geog      = pCODE_FINE_GEOG     ,
            cota                = pCOTA               ,
            clas                = pCLAS               ,
            seui                = pSEUI               ,
            pali                = pPALI               ,
            grad                = pGRAD               ,
            degr                = pDEGR               ,
            rib_guic_1          = pRIB_GUIC_1         ,
            rib_comp_1          = pRIB_COMP_1         ,
            rib_cle_1           = pRIB_CLE_1          ,
            rib_banq_01         = pRIB_BANQ_01        ,
            rib_banq_02         = pRIB_BANQ_02        ,
            prof_temp_libe      = pPROF_TEMP_LIBE     ,
            NOMB_JOUR_CONG_ANCI = pNOMB_JOUR_CONG_ANCI,
            MONT_ANCI_PA        = pMONT_ANCI_PA       ,
            ANCI_CADR           = pANCI_CADR          ,
            TOTA_HEUR_TRAV      = pTOTA_HEUR_TRAV     ,
            DPAE_ENVO           = pDPAE_ENVO          ,
            DISP_POLI_PUBL_CONV = pDISP_POLI_PUBL_CONV ,
            DATE_ANCI_CADR_FORF = pDATE_ANCI_CADR_FORF 

         where id_list = iID_LIST
         ;
         commit;
      end if;

      -- Fin de test des erreurs
      errtools.pr_errlistfinal(pXML, Err);
      commit;
end ;
/
