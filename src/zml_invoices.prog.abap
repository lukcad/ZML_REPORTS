*&---------------------------------------------------------------------*
*& Report zml_invoices
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zml_invoices.

**********************************************************************
*
* SELECTION PAARAMETERS
*
**********************************************************************
TYPES: BEGIN OF ts_selection,
         company_name  TYPE snwd_bpa-company_name,
         currency_code TYPE snwd_so_inv_item-currency_code,
       END OF ts_selection.
DATA: lv_company_name TYPE ts_selection-company_name.
DATA: lv_currency TYPE ts_selection-currency_code.

SELECTION-SCREEN BEGIN OF BLOCK a.
  SELECT-OPTIONS: s_cname FOR lv_company_name.
  SELECT-OPTIONS: s_curr FOR lv_currency.
SELECTION-SCREEN END OF BLOCK a.

**********************************************************************

CLASS lcl_main DEFINITION CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS create
      RETURNING
        VALUE(r_result) TYPE REF TO lcl_main.
    METHODS: run.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES: BEGIN OF ts_items,
             company_name   TYPE snwd_bpa-company_name,
             gross_amount   TYPE snwd_so_inv_item-gross_amount,
             currency_code  TYPE snwd_so_inv_item-currency_code,
             payment_status TYPE snwd_so_inv_head-payment_status,
           END OF ts_items.
    TYPES: tt_items TYPE STANDARD TABLE OF ts_items.
    DATA: lt_items TYPE tt_items.

    METHODS get_data
      RETURNING
        VALUE(rt_result) LIKE lt_items.
ENDCLASS.

CLASS lcl_main IMPLEMENTATION.

  METHOD create.

    r_result = NEW #( ).

  ENDMETHOD.

  METHOD run.
    lt_items = me->get_data(  ).
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table   = DATA(alv_table)
          CHANGING
            t_table        = lt_items
        ).
      CATCH cx_salv_msg.
        "handle exception
    ENDTRY.
    " optimize column width
    alv_table->get_columns( )->set_optimize( abap_true ).
    " show panel with function buttons
    alv_table->get_functions( )->set_default( abap_true ).
    " remove restrictions on saving layouts
    alv_table->get_layout( )->set_save_restriction( if_salv_c_layout=>restrict_none ).
    " show rows with a zebra effect
    alv_table->get_display_settings( )->set_striped_pattern( if_salv_c_bool_sap=>true ).

    alv_table->display( ).

  ENDMETHOD.


  METHOD get_data.
    SELECT
       snwd_bpa~company_name,
       snwd_so_inv_item~gross_amount,
       snwd_so_inv_item~currency_code,
       snwd_so_inv_head~payment_status
     FROM
      snwd_so_inv_item
      JOIN snwd_so_inv_head
      ON snwd_so_inv_item~parent_key = snwd_so_inv_head~node_key
      JOIN snwd_bpa
      ON snwd_so_inv_head~buyer_guid = snwd_bpa~node_key
     WHERE
      snwd_so_inv_item~currency_code IN @s_curr
      AND
      snwd_bpa~company_name IN @s_cname
     ORDER BY
      snwd_bpa~company_name
     INTO CORRESPONDING FIELDS OF TABLE @rt_result.
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  lcl_main=>create( )->run( ).
