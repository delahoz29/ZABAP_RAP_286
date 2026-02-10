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

      BEGIN OF enter_title,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enter_title,

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
      END OF enter_change_date,

      BEGIN OF enter_description,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF enter_description,

      BEGIN OF responsible_required,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE 'MV_RESPOSABLE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF responsible_required,

        BEGIN OF user_unauthorized,
        msgid TYPE symsgid VALUE 'ZCM_INCIDENT',
        msgno TYPE symsgno VALUE '011',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF user_unauthorized.

    METHODS constructor
      IMPORTING
        textid      LIKE if_t100_message=>t100key OPTIONAL
        attr1       TYPE string OPTIONAL
        attr2       TYPE string OPTIONAL
        attr3       TYPE string OPTIONAL
        attr4       TYPE string OPTIONAL
        incident_id TYPE zde_incident_id_286 OPTIONAL
        status      TYPE zde_status_code OPTIONAL
        userid      TYPE zde_responsable_286 OPTIONAL
        severity    TYPE if_abap_behv_message=>t_severity OPTIONAL.

    DATA:
      mv_attr1       TYPE string,
      mv_attr2       TYPE string,
      mv_attr3       TYPE string,
      mv_attr4       TYPE string,
      mv_incident_id TYPE zde_incident_id_286,
      mv_status      TYPE zde_status_code,
      mv_nonaut      TYPE zde_responsable_286.



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_mensajes_286 IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( previous = previous ).
    me->mv_attr1                 = attr1.
    me->mv_attr2                 = attr2.
    me->mv_attr3                 = attr3.
    me->mv_attr4                 = attr4.
    me->mv_incident_id           = incident_id.
    me->mv_status = status.
    me->mv_nonaut = userid.



    if_abap_behv_message~m_severity = severity.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
