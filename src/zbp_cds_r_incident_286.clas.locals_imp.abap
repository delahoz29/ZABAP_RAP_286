CLASS lhc_Incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS: BEGIN OF inc_status,
                 open        TYPE zde_status_code VALUE 'OP',
                 in_progress TYPE zde_status_code VALUE 'IP',
                 pending     TYPE zde_status_code VALUE 'PE',
                 completed   TYPE zde_status_code VALUE 'CO',
                 closed      TYPE zde_status_code VALUE 'CL',
                 canceled    TYPE zde_status_code VALUE 'CN',
               END OF inc_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Incident RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS ChangeStatus FOR MODIFY
      IMPORTING keys FOR ACTION Incident~ChangeStatus.

    METHODS NewStatus FOR MODIFY
      IMPORTING keys FOR ACTION Incident~NewStatus RESULT result.

    METHODS setStatusOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Incident~setStatusOpen.

    METHODS setIncidentNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incident~setIncidentNumber.

    METHODS validatePriority FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validatePriority.

    METHODS validateRange FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validateRange.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validateStatus.

ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_instance_features.


    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
           ENTITY Incident
           FIELDS ( Status )
           WITH CORRESPONDING #( keys )
           RESULT DATA(incidents)
           FAILED failed.

    result = VALUE #( FOR incident IN incidents
     ( %tky = incident-%tky
       %action-NewStatus = COND #( WHEN incident-Status EQ inc_status-completed
                                        OR incident-Status EQ inc_status-canceled
                                        OR incident-Status EQ inc_status-closed
                                        OR ( incident-Status EQ inc_status-in_progress )
                                      THEN if_abap_behv=>fc-o-disabled
                                      ELSE if_abap_behv=>fc-o-enabled )

   ) ).



  ENDMETHOD.

  METHOD get_instance_authorizations.

    DATA: update_requested TYPE abap_bool,
          update_granted   TYPE abap_bool,
          delete_requested TYPE abap_bool,
          delete_granted   TYPE abap_bool.


    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
         ENTITY Incident
         FIELDS ( CreationDate )
         WITH CORRESPONDING #( keys )
         RESULT DATA(incidents)
         FAILED failed.

    update_requested = COND #( WHEN requested_authorizations-%update EQ if_abap_behv=>mk-on
                                 OR requested_authorizations-%action-Edit EQ if_abap_behv=>mk-on
                                 THEN abap_true
                                 ELSE abap_false ).

    delete_requested = COND #( WHEN requested_authorizations-%delete EQ if_abap_behv=>mk-on
                                THEN abap_true
                                ELSE abap_false ).

    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).

    LOOP AT incidents INTO DATA(incident)
         WHERE IncidentId EQ '000001'.

      IF lv_technical_name  EQ 'CB9980000286' AND incident-IncidentId NE '000001'.
        update_granted = abap_true.
        delete_granted = abap_true.
      ELSE.
        update_granted = abap_false.
        delete_granted = abap_false.

        APPEND VALUE #( %tky        = incident-%tky
                        %msg        = NEW zcl_mensajes_286( textid    = zcl_mensajes_286=>incident_unkown
                                                                           incident_id = incident-IncidentId
                                                                           severity  =  if_abap_behv_message=>severity-error )
                        %element-IncidentId =  if_abap_behv=>mk-on ) TO reported-incident.


      ENDIF.

      APPEND VALUE #( LET upd_auth = COND #( WHEN update_granted EQ abap_true
                                             THEN if_abap_behv=>auth-allowed
                                             ELSE if_abap_behv=>auth-unauthorized )
                      del_auth = COND #( WHEN delete_granted EQ abap_true
                                             THEN if_abap_behv=>auth-allowed
                                             ELSE if_abap_behv=>auth-unauthorized )
                      IN
                      %tky         = incident-%tky
                      %update      = upd_auth
                      %action-Edit = upd_auth
                      %delete      = del_auth ) TO result.

    ENDLOOP.


  ENDMETHOD.

  METHOD get_global_authorizations.

    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).

    IF requested_authorizations-%create EQ if_abap_behv=>mk-on.

      IF lv_technical_name  EQ 'CB9980000286'.
        result-%create          = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create          = if_abap_behv=>auth-unauthorized.

        " AQUI VA MENSAJE DE ERROR DE AUTORIZACIÓN
      ENDIF.

    ENDIF.

    IF requested_authorizations-%update EQ if_abap_behv=>mk-on OR
       requested_authorizations-%action-Edit EQ if_abap_behv=>mk-on.

      IF lv_technical_name  EQ 'CB9980000286'.
        result-%update          = if_abap_behv=>auth-allowed .
        result-%action-edit     = if_abap_behv=>auth-allowed.
      ELSE.
        result-%update          = if_abap_behv=>auth-unauthorized.
        result-%action-edit     = if_abap_behv=>auth-unauthorized.
        " AQUI VA MENSAJE DE ERROR DE AUTORIZACIÓN
      ENDIF.


    ENDIF.

    IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

      IF lv_technical_name  EQ 'CB9980000286'.
        result-%delete          = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete          = if_abap_behv=>auth-unauthorized.
        " AQUI VA MENSAJE DE ERROR DE AUTORIZACIÓN
      ENDIF.

    ENDIF.


  ENDMETHOD.

  METHOD ChangeStatus.


  ENDMETHOD.

  METHOD NewStatus.

    MODIFY ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
          ENTITY Incident
          UPDATE
          FIELDS ( Status )
          WITH VALUE #( FOR ls_key IN keys ( %tky          = ls_key-%tky
                                             Status = inc_status-completed ) ).

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
         ENTITY Incident
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(incidents).

    result = VALUE #( FOR incident IN incidents ( %tky = incident-%tky ) ).


  ENDMETHOD.

  METHOD setStatusOpen.


    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
          ENTITY Incident
          FIELDS ( Status )
          WITH CORRESPONDING #( keys )
          RESULT DATA(incidents).

    DELETE incidents WHERE Status IS NOT INITIAL.

    CHECK incidents IS NOT INITIAL.

    MODIFY ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
   ENTITY Incident
   UPDATE FIELDS ( Status )
   WITH VALUE #(  FOR incident IN incidents  INDEX INTO i
                      ( %tky        = incident-%tky
                      Status = inc_status-open ) ).
  ENDMETHOD.

  METHOD setIncidentNumber.

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
           ENTITY Incident
           FIELDS ( IncidentId )
           WITH CORRESPONDING #( keys )
           RESULT DATA(incidents).

    DELETE incidents WHERE IncidentId IS NOT INITIAL.

    CHECK incidents IS NOT INITIAL.

    SELECT SINGLE FROM zdt_inct_286
    FIELDS MAX( incident_id )
    INTO @DATA(lv_max_incident_id).

    MODIFY ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
    ENTITY Incident
    UPDATE FIELDS ( IncidentId )
    WITH VALUE #(  FOR incident IN incidents  INDEX INTO i
                       ( %tky   = incident-%tky
                       IncidentId = lv_max_incident_id + 1 ) ).


  ENDMETHOD.

  METHOD validatePriority.

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
              ENTITY Incident
              FIELDS ( Priority )
              WITH CORRESPONDING #( keys )
              RESULT DATA(incidents).

    DATA priorities TYPE SORTED TABLE OF zdt_priority286 WITH UNIQUE KEY client priority_code .

    priorities = CORRESPONDING #( incidents DISCARDING DUPLICATES MAPPING priority_code = Priority EXCEPT * ).
    DELETE priorities WHERE priority_code IS INITIAL.

    IF priorities IS NOT INITIAL.
      SELECT FROM zdt_priority286 AS ddbb
      INNER JOIN @priorities AS http_req ON ddbb~priority_code EQ http_req~priority_code
      FIELDS ddbb~priority_code
      INTO TABLE @DATA(valid_priorities).

    ENDIF.

    LOOP AT priorities INTO DATA(priority).

      IF priority-priority_code IS INITIAL.
        " MENSAJE DE EXISTE!
      ELSEIF priority-priority_code IS NOT INITIAL AND NOT line_exists( valid_priorities[ priority_code = priority-priority_code ] ).
        " MENSAJE DE NO EXISTE
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateRange.
  ENDMETHOD.

  METHOD validateStatus.
  ENDMETHOD.

ENDCLASS.
