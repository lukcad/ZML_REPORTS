# Overview

This examples shows steps how you can create ALV report from scratch.

Goal: create ALV report where user can choose parameters on initial selection screen of program and then get result using SALV framework.

Outcom:
you will have two templates in explanation below:
- Template `Add PROGRAM with class`
- Template `Add PROGRAM with class of ALV report`
	
Path to do it:

## 1-- create Program

Name:	ZML_INVOICES
Description:	Invoices report

Notice: Description will be excly the name of report which customer expects from you as a developer.

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/334b6262-fbed-4ab8-b954-c2fc10c3817b)

	

## 2-- create ABAP local class

### 2--1-- generate local class
Type `lcl` and press Ctrl+Space to get code completion proposals. Select `lcl - Local class`

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/00b34eb6-a4aa-4a27-b896-258610b9edf7)


adjust the name of local class to `lcl_main` using inline editing:

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/a5eb4a21-7a32-4ba8-bd68-855abf9da4d8)
		
### 2--2-- Generate CREATE method
Choose the name of class by cursor and press Ctrl+1 keys to open the Quick Fix menu. Use `Generate factory method create` to create static factory method.

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/80531207-9597-46ba-9861-0188f08dacc1)

Code at this moment will be:

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/e52381f9-cff1-4396-9160-294f0deb3a44)

		
### 2--3-- Create run method
Type in public sction of lcl_main class definition method run:

  METHODS: run.
and choose method run by cursor and press Ctrl+1 to get proposals from Quickfix menu and choose `Add implementation for run`

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/e6bb1b12-2089-4394-8686-18d373c6b1fa)
		
		
### 2--4-- Add selection screen.
	
Add a `START-OF-SELECTION` event to your report after endclass of your lcl_main class and add code of executing run method from selection area.
		
		START-OF-SELECTION.
			lcl_main=>create( )->run( ).
			
			
### 2--5-- Initial template of your program.
	
Now you code looks like below, i recomment to create using this code template to save time when you develop new report.
		
		
		*&---------------------------------------------------------------------*
		*& Report zml_invoices
		*&---------------------------------------------------------------------*
		*&
		*&---------------------------------------------------------------------*
		REPORT zml_invoices.
		
		CLASS lcl_main DEFINITION CREATE PRIVATE.
		
		  PUBLIC SECTION.
		    CLASS-METHODS create
		      RETURNING
		        VALUE(r_result) TYPE REF TO lcl_main.
		    METHODS: run.
		  PROTECTED SECTION.
		  PRIVATE SECTION.
		
		ENDCLASS.
		
		CLASS lcl_main IMPLEMENTATION.
		
		  METHOD create.
		
		    r_result = NEW #( ).
		
		  ENDMETHOD.
		
		  METHOD run.
		
		  ENDMETHOD.
		
		ENDCLASS.
		
		START-OF-SELECTION.
		  lcl_main=>create( )->run( ).
		
  
  ## 3-- Template `Add PROGRAM with class`

You can create new template into your Eclipse ADT using `Templates` view and just choosing from Context menu the `New..` button:

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/07286347-9811-4388-8ae5-ee236cdae5f9)
  

Where you can paste your code and change name report in comment area and into operator node by insert variable: ${enclosing_object}

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/9501990f-d7cc-4f0d-90e8-d5caef89ef9a)
  
Your template can be as below. Such template lets you after creating program put all previouse code in one sec and name will be taken from name of your new program:
	
		
		*&---------------------------------------------------------------------*
		*& Report ${enclosing_object}
		*&---------------------------------------------------------------------*
		*&
		*&---------------------------------------------------------------------*
		REPORT ${enclosing_object}.
		
		CLASS lcl_main DEFINITION CREATE PRIVATE.
		
		  PUBLIC SECTION.
		    CLASS-METHODS create
		      RETURNING
		        VALUE(r_result) TYPE REF TO lcl_main.
		    METHODS: run.
		  PROTECTED SECTION.
		  PRIVATE SECTION.
		
		ENDCLASS.
		
		CLASS lcl_main IMPLEMENTATION.
		
		  METHOD create.
		
		    r_result = NEW #( ).
		
		  ENDMETHOD.
		
		  METHOD run.
		
		  ENDMETHOD.
		
		ENDCLASS.
		
		START-OF-SELECTION.
		  lcl_main=>create( )->run( ).
		
## 4-- Add ALV report

### 4--1-- create selection options
	
Before open ALV report developers have requirements how to filter data. Assume, in our exmple you have requirements:
 - company can be selected ( if not then all companies can be requested)
 - currency code can be selected (if not then all currency codes can be requested)

Add selection parameters to the beginning of report:
			
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
			
![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/0c8805ca-f5d9-43c2-8e8c-8a3b4c79a9e1)
		

Notice: the names of parameters `s_cname` and `s_curr` should be provided by text elements:

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/198a5d8c-0c90-4f32-a697-25b01922d846)

You can do it by context meny after selecting your parameter:

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/192c1724-dc51-4ca4-9cb5-45389f03986c)

			
### 4--2-- Define structure and table type of records 
	
Add type of records `ts_records` and table type `tt_records`

In private section of lcl_main add type of records and table type with your supposed structure.
In this example we use educational table from SAP so we would like to return such records:
		
        TYPES: BEGIN OF ts_items,
                 company_name   TYPE snwd_bpa-company_name,
                 gross_amount   TYPE snwd_so_inv_item-gross_amount,
                 currency_code  TYPE snwd_so_inv_item-currency_code,
                 payment_status TYPE snwd_so_inv_head-payment_status,
               END OF ts_items.
        TYPES: tt_items TYPE STANDARD TABLE OF ts_items.
			
	
### 4--3-- Define internal table for report
		
Add itab gt_items`
			
			DATA: gt_items TYPE tt_items.
		
### 4--4-- Add method get_data
	
In method run you shoudl add  itab `lv_items` where extracted data from databse will be saved, before those come to ALV.
		
			gt_items = me->get_data( ).
		
and generate method get_data by using Ctrl+1 combination keys:

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/1d613c16-b7d2-4b8b-9958-5a8f72b88258)

after generating method to follow name conventions use this name in definition mehtod get_data for returning: `rt_result` instead of `r_result`:
		
			    METHODS get_data
			      RETURNING
			        value(rt_result) LIKE gt_items.
			
	
### 4--5-- Put your select in method get_data.
		
Your select should return the simmilar structure which you described into type `ts_items`. Notice: your select should return structure which is compatible with structure of table GT_ITEMS or use corresponding to fill in RT_RESULT with corresponding fields.
		
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
			
Notice: if you have parameters you can point those directly from selection parameters. In our case we have two:
  - @s_curr
  - @s_cname
			
### 4--6-- Add GUI settings file
	
Add this file to be able adjust GUI settings as you need and let do it for user.

Copy file from this project 'SALV_STANDARD' to your own project just to save time.

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/c0014031-014d-43e6-8e65-1c075981644a)
		
		
		
### 4--7-- Display alv grid
	
Into method `run` add this code (study comments to understand how this code prepare your data to ALV GRID and display it:
		
			  METHOD run.
			    gt_items = me->get_data(  ).
			    TRY.
			        cl_salv_table=>factory(
			          IMPORTING
			            r_salv_table   = DATA(alv_table)
			          CHANGING
			            t_table        = gt_items
			        ).
			      CATCH cx_salv_msg.
			        "handle exception
			    ENDTRY.
			
			    DATA: lr_columns TYPE REF TO cl_salv_columns_table,
			          lr_column  TYPE REF TO cl_salv_column_table.
			
			    lr_columns = alv_table->get_columns( ).
			
			    " modify here technical representation of the columns if it is needing
			    data: ls_color type lvc_s_colo.
			    TRY.
			        lr_column ?= lr_columns->get_column( 'CURRENCY_CODE' ).
			        ls_color-col = col_negative.
			        ls_color-int = 0.
			        ls_color-inv = 0.
			        lr_column->set_color( ls_color ).
			      CATCH cx_salv_not_found.
			    ENDTRY.
			    " optimize column width
			    lr_columns->set_optimize( abap_true ).
			    " show panel with function buttons
			    alv_table->get_functions( )->set_default( abap_true ).
			    " remove restrictions on saving layouts
			    alv_table->get_layout( )->set_save_restriction( if_salv_c_layout=>restrict_none ).
			    " show rows with a zebra effect
			    alv_table->get_display_settings( )->set_striped_pattern( if_salv_c_bool_sap=>true ).
			    "Register a custom GUI status for an ALV
			    alv_table->set_screen_status(
			      pfstatus      = gui_status_name
			      report        = sy-repid
			      set_functions = alv_table->c_functions_all ).
			
			    alv_table->display( ).
			
			  ENDMETHOD.
			
### 4--8-- Test you report.
	
Activate all code before test.
-- Execute code by using F8 key to get selection screen:

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/da6fccb6-8891-4da5-a074-0ac6de4be281)
  
-- Execute your selection to get report:

![image](https://github.com/lukcad/ZML_REPORTS/assets/22641302/b42fe308-7f6a-4a2c-b3c3-495bcf905bd7)
		
			
			
## 5-- Template `Add PROGRAM with class of ALV report`

Create new template into your Eclipse ADT and add code from below, and use this code to get program with your name and then you should change code with comments to your own code:
	
		*&---------------------------------------------------------------------*
		*& Report ${enclosing_object}
		*&---------------------------------------------------------------------*
		*&
		*&---------------------------------------------------------------------*
		REPORT ${enclosing_object}.
		
		**********************************************************************
		*
		* SELECTION PAARAMETERS
		*
		**********************************************************************
		"TYPES: BEGIN OF ts_selection,
		"         company_name  TYPE snwd_bpa-company_name,
		"         currency_code TYPE snwd_so_inv_item-currency_code,
		"       END OF ts_selection.
		"DATA: lv_company_name TYPE ts_selection-company_name.
		"DATA: lv_currency TYPE ts_selection-currency_code.
		"
		"SELECTION-SCREEN BEGIN OF BLOCK a.
		"  SELECT-OPTIONS: s_cname FOR lv_company_name.
		"  SELECT-OPTIONS: s_curr FOR lv_currency.
		"SELECTION-SCREEN END OF BLOCK a.
		
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
								 changeme TYPE string,
		             "company_name   TYPE snwd_bpa-company_name,
		             "gross_amount   TYPE snwd_so_inv_item-gross_amount,
		             "currency_code  TYPE snwd_so_inv_item-currency_code,
		             "payment_status TYPE snwd_so_inv_head-payment_status,
		           END OF ts_items.
		    TYPES: tt_items TYPE STANDARD TABLE OF ts_items.
		    DATA: gt_items TYPE tt_items.
		
		    "CONSTANTS: gui_status_name TYPE sypfkey VALUE 'SALV_STANDARD'.
		
		    METHODS get_data
		      RETURNING
		        VALUE(rt_result) LIKE gt_items.
		ENDCLASS.
		
		CLASS lcl_main IMPLEMENTATION.
		
		  METHOD create.
		
		    r_result = NEW #( ).
		
		  ENDMETHOD.
		
		  METHOD run.
		    gt_items = me->get_data(  ).
		    TRY.
		        cl_salv_table=>factory(
		          IMPORTING
		            r_salv_table   = DATA(alv_table)
		          CHANGING
		            t_table        = gt_items
		        ).
		      CATCH cx_salv_msg.
		        "handle exception
		    ENDTRY.
		
		    DATA: lr_columns TYPE REF TO cl_salv_columns_table,
		          lr_column  TYPE REF TO cl_salv_column_table.
		
		    lr_columns = alv_table->get_columns( ).
		
		    " modify here technical representation of the columns if it is needing
		    "data: ls_color type lvc_s_colo.
		    "TRY.
		    "    lr_column ?= lr_columns->get_column( 'CURRENCY_CODE' ).
		    "    ls_color-col = col_negative.
		    "    ls_color-int = 0.
		    "    ls_color-inv = 0.
		    "    lr_column->set_color( ls_color ).
		    "  CATCH cx_salv_not_found.
		    "ENDTRY.
		    " optimize column width
		    lr_columns->set_optimize( abap_true ).
		    " show panel with function buttons
		    alv_table->get_functions( )->set_default( abap_true ).
		    " remove restrictions on saving layouts
		    alv_table->get_layout( )->set_save_restriction( if_salv_c_layout=>restrict_none ).
		    " show rows with a zebra effect
		    alv_table->get_display_settings( )->set_striped_pattern( if_salv_c_bool_sap=>true ).
		    "Register a custom GUI status for an ALV
		    "alv_table->set_screen_status(
		    "  pfstatus      = gui_status_name
		    "  report        = sy-repid
		    "  set_functions = alv_table->c_functions_all ).
		
		    alv_table->display( ).
		
		  ENDMETHOD.
		
		
		  METHOD get_data.
		    "SELECT
		    "   snwd_bpa~company_name,
		    "   snwd_so_inv_item~gross_amount,
		    "   snwd_so_inv_item~currency_code,
		    "   snwd_so_inv_head~payment_status
		    " FROM
		    "  snwd_so_inv_item
		    "  JOIN snwd_so_inv_head
		    "  ON snwd_so_inv_item~parent_key = snwd_so_inv_head~node_key
		    "  JOIN snwd_bpa
		    "  ON snwd_so_inv_head~buyer_guid = snwd_bpa~node_key
		    " WHERE
		    "  snwd_so_inv_item~currency_code IN @s_curr
		    "  AND
		    "  snwd_bpa~company_name IN @s_cname
		    " ORDER BY
		    "  snwd_bpa~company_name
		    " INTO CORRESPONDING FIELDS OF TABLE @rt_result.
		
				rt_result = VALUE #( ( changeme = 'test1' ) ).
		  ENDMETHOD.
		
		ENDCLASS.
		
		START-OF-SELECTION.
		
		  lcl_main=>create( )->run( ).
		
	
	

## 6-- Additional information

If you need event hundlers, or creating own specific functions you can find patterns of code into sap.community blog here:
	
[salv-alv-quickstart-snippets](https://community.sap.com/t5/application-development-blog-posts/salv-alv-quickstart-snippets/ba-p/13512702)
	
	
	
	
Happy programming,

Yours sincerely,

Mikhail.

