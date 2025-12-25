REPORT zfi_ecc_select_loop_demo.
* DUMMY ECC PROGRAM FOR AI / GITHUB TESTING ONLY
* THIS PROGRAM IS FOR ANALYSIS PURPOSES AND AI TESTS.
* DO NOT CHANGE, DO NOT EXECUTE, DO NOT USE IN PRODUCTION.
*
* Refactor notes:
* - Replaced `SELECT *` with explicit field lists to minimize I/O and be S/4HANA friendly.
* - Eliminated per-row DB reads for BSEG by using one set-based SELECT (FOR ALL ENTRIES).
* - Replaced `IF sy-subrc = 0` checks with `IS NOT INITIAL` checks on result tables.
* - Added comments marking classic ECC tables (BKPF, BSEG, BSIS) and recommending ACDOCA/CDS usage in S/4HANA.
*
* Table categorization:
* - Classic ECC tables used: BKPF, BSEG, BSIS
* - S/4HANA recommended: ACDOCA (Universal Journal), use CDS views/AMDP for complex queries

"***** Tip ve Tablo Tanımları *****
TYPES: BEGIN OF ty_conv_log,
         table_name TYPE string,
         bukrs      TYPE bukrs,
         belnr      TYPE belnr_d,
         message    TYPE string,
       END OF ty_conv_log.

DATA: gt_log TYPE TABLE OF ty_conv_log,
      gs_log TYPE ty_conv_log.

"***** Parametreler *****
PARAMETERS p_bukrs TYPE bukrs DEFAULT '1000'.

"***** BKPF Kontrol (explicit fields) *****
" Note: BKPF is a classic ECC table. In S/4HANA prefer ACDOCA/CDS for ledger queries.
SELECT bukrs belnr gjahr
  FROM bkpf
  INTO TABLE @DATA(lt_bkpf)
  WHERE bukrs = @p_bukrs
  AND gjahr = '2025'.  "Simülasyon yılı

IF lt_bkpf IS NOT INITIAL.
  LOOP AT lt_bkpf INTO DATA(ls_bkpf).
    gs_log-table_name = 'BKPF'.
    gs_log-bukrs = ls_bkpf-bukrs.
    gs_log-belnr = ls_bkpf-belnr.
    gs_log-message = 'SELECT bukrs, belnr, gjahr (replaced SELECT *) - detected SELECT & LOOP'.       
    APPEND gs_log TO gt_log.
  ENDLOOP.
ENDIF.

"***** BSEG Kontrol *****
" Original code performed a DB read per BKPF row (N+1 problem). We replace that
" with one set-based SELECT for all related BSEG rows. BSEG is a classic ECC table.
IF lt_bkpf IS NOT INITIAL.
  " Use FOR ALL ENTRIES to fetch all BSEG rows related to the BKPF rows in one DB call.
  SELECT bukrs belnr gjahr
    FROM bseg
    INTO TABLE @DATA(lt_bseg)
    FOR ALL ENTRIES IN @lt_bkpf
    WHERE bukrs = @lt_bkpf-bukrs
      AND belnr = @lt_bkpf-belnr
      AND gjahr = @lt_bkpf-gjahr.

  IF lt_bseg IS NOT INITIAL.
    LOOP AT lt_bseg INTO DATA(ls_bseg_line).
      gs_log-table_name = 'BSEG'.
      gs_log-bukrs = ls_bseg_line-bukrs.
      gs_log-belnr = ls_bseg_line-belnr.
      gs_log-message = 'BSEG set-based SELECT (replaced per-row SELECT *)'.
      APPEND gs_log TO gt_log.
    ENDLOOP.
  ENDIF.
ENDIF.

"***** BSIS Kontrol (explicit fields) *****
" BSIS is a classic ECC open items table. In S/4HANA, consider ACDOCA or CDS views.
SELECT bukrs belnr gjahr
  FROM bsis
  INTO TABLE @DATA(lt_bsis)
  WHERE bukrs = @p_bukrs
  AND gjahr = '2025'.

IF lt_bsis IS NOT INITIAL.
  LOOP AT lt_bsis INTO DATA(ls_bsis).
    gs_log-table_name = 'BSIS'.
    gs_log-bukrs = ls_bsis-bukrs.
    gs_log-belnr = ls_bsis-belnr.
    gs_log-message = 'BSIS SELECT with explicit fields (replaced SELECT *)'.
    APPEND gs_log TO gt_log.
  ENDLOOP.
ENDIF.

"***** Logları Ekrana Yazdır *****
WRITE: / 'ECC Select & Loop FI Conversion Check'.
WRITE: / '----------------------------------------'.

LOOP AT gt_log INTO gs_log.
  WRITE: / gs_log-table_name, gs_log-bukrs, gs_log-belnr, gs_log-message.
ENDLOOP.
