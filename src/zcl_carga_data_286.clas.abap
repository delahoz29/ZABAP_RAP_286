CLASS zcl_carga_data_286 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    DATA: lt_status   TYPE TABLE OF zdt_status286,
          lt_priority TYPE TABLE OF zdt_priority286.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_carga_data_286 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DELETE FROM zdt_status286.
    DELETE FROM zdt_priority286.
    delete from zdt_inct_286.

    lt_status = VALUE #(
        ( status_code = 'OP' status_description = 'Open' )
        ( status_code = 'IP' status_description = 'In Progress' )
        ( status_code = 'PE' status_description = 'Pending' )
        ( status_code = 'CO' status_description = 'Completed' )
        ( status_code = 'CL' status_description = 'Closed' )
        ( status_code = 'CN' status_description = 'Canceled' )
      ).

    INSERT zdt_status286 FROM TABLE @lt_status.

    IF sy-subrc EQ 0.
      out->write( | Total estados cargados satisfactoriamente: { sy-dbcnt } .| ).
    ELSE.
      out->write( | Error al cargar estados.| ).
    ENDIF.


    lt_priority = VALUE #(
    ( priority_code = 'L' priority_description = 'Low' )
    ( priority_code = 'M' priority_description = 'Medium' )
    ( priority_code = 'H' priority_description = 'High' )
  ).

    INSERT zdt_priority286 FROM TABLE @lt_priority.

    IF sy-subrc EQ 0.
      out->write( | Total prioridades cargados satisfactoriamente: { sy-dbcnt } .| ).
    ELSE.
      out->write( | Error al cargar prioridades.| ).
    ENDIF.


  ENDMETHOD.

ENDCLASS.
