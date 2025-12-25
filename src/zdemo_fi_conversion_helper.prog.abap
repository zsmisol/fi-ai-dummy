REPORT zfi_ecc_select_loop_demo.
* DUMMY ECC PROGRAM FOR AI / GITHUB TESTING ONLY
* THIS PROGRAM IS FOR ANALYSIS PURPOSES AND AI TESTS.
* DO NOT CHANGE, DO NOT EXECUTE, DO NOT USE IN PRODUCTION.
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

"***** BKPF Kontrol *****
SELECT * FROM bkpf
  INTO TABLE @DATA(lt_bkpf)
  WHERE bukrs = @p_bukrs
  AND gjahr = '2025'.  "Simülasyon yılı

IF sy-subrc = 0.
  LOOP AT lt_bkpf INTO DATA(ls_bkpf).
    gs_log-table_name = 'BKPF'.
    gs_log-bukrs = ls_bkpf-bukrs.
    gs_log-belnr = ls_bkpf-belnr.
    gs_log-message = 'SELECT * ve LOOP kullanımı tespit edildi'.
    APPEND gs_log TO gt_log.
  ENDLOOP.
ENDIF.

"***** BSEG Kontrol *****
LOOP AT lt_bkpf INTO DATA(ls_bkpf2).
  SELECT * FROM bseg
    INTO TABLE @DATA(lt_bseg)
    WHERE bukrs = @ls_bkpf2-bukrs
    AND belnr = @ls_bkpf2-belnr
    AND gjahr = @ls_bkpf2-gjahr.

  LOOP AT lt_bseg INTO DATA(ls_bseg_line).
    gs_log-table_name = 'BSEG'.
    gs_log-bukrs = ls_bkpf2-bukrs.
    gs_log-belnr = ls_bkpf2-belnr.
    gs_log-message = 'BSEG LOOP ve SELECT * kullanımı'.
    APPEND gs_log TO gt_log.
  ENDLOOP.
ENDLOOP.

"***** BSIS Kontrol (Genel Ledger Açık Hesap) *****
SELECT * FROM bsis
  INTO TABLE @DATA(lt_bsis)
  WHERE bukrs = @p_bukrs
  AND gjahr = '2025'.

LOOP AT lt_bsis INTO DATA(ls_bsis).
  gs_log-table_name = 'BSIS'.
  gs_log-bukrs = ls_bsis-bukrs.
  gs_log-belnr = ls_bsis-belnr.
  gs_log-message = 'BSIS SELECT * kullanımı tespit edildi'.
  APPEND gs_log TO gt_log.
ENDLOOP.

"***** Logları Ekrana Yazdır *****
WRITE: / 'ECC Select & Loop FI Conversion Check'.
WRITE: / '----------------------------------------'.

LOOP AT gt_log INTO gs_log.
  WRITE: / gs_log-table_name, gs_log-bukrs, gs_log-belnr, gs_log-message.
ENDLOOP.
