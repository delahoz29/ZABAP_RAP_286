CLASS zcl_mensajes_286 DEFINITION
  PUBLIC
   INHERITING FROM cx_static_check

  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .
    INTERFACES if_abap_behv_message .

    CONSTANTS:
      gc_msgid TYPE symsgid VALUE 'ZCM_INCIDENT',

      BEGIN OF incident_unkown,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'MV_INCIDENT_ID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF incident_unkown,

      BEGIN OF not_authorized,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF not_authorized,

      BEGIN OF enter_priority,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enter_priority,

      BEGIN OF priority_unkown,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF priority_unkown,

      BEGIN OF enter_status,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enter_status,

 BEGIN OF status_unkown,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF status_unkown,


      BEGIN OF enter_create_date,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enter_create_date,

      BEGIN OF enter_change_date,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enter_change_date.




    METHODS constructor
      IMPORTING
        textid      LIKE if_t100_message=>t100key OPTIONAL
        attr1       TYPE string OPTIONAL
        attr2       TYPE string OPTIONAL
        attr3       TYPE string OPTIONAL
        attr4       TYPE string OPTIONAL
        incident_id TYPE n OPTIONAL
        severity    TYPE if_abap_behv_message=>t_severity OPTIONAL.

    DATA:
      mv_attr1       TYPE string,
      mv_attr2       TYPE string,
      mv_attr3       TYPE string,
      mv_attr4       TYPE string,
      mv_incident_id TYPE n LENGTH 16.



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_mensajes_286 IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( previous = previous ).
    me->mv_attr1                = attr1.
    me->mv_attr2                 = attr2.
    me->mv_attr3                 = attr3.
    me->mv_attr4                 = attr4.
    me->mv_incident_id            = incident_id.

    if_abap_behv_message~m_severity = severity.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
