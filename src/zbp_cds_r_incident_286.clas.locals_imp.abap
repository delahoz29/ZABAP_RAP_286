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
    METHODS createlHistory FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incident~createlHistory.
    METHODS setHistoryInc FOR MODIFY
      IMPORTING keys FOR ACTION Incident~setHistoryInc.
    METHODS createInitialHistory FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incident~createInitialHistory.
    METHODS validateDescrip FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validateDescrip.

ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_instance_features.

    DATA: lv_user TYPE c..
    lv_user = cl_abap_context_info=>get_user_technical_name( ).

    DATA(lv_is_admin) = COND #( WHEN lv_user = 'CB9980000286' THEN abap_true ELSE abap_false ).

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
           ENTITY Incident
           ALL FIELDS
           WITH CORRESPONDING #( keys )
           RESULT DATA(incidents)
           FAILED failed.



    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
         ENTITY Incident BY \_history FIELDS ( HisId )
         WITH VALUE #( ( %tky = incidents[ 1 ]-%tky ) )
         RESULT DATA(lt_current_history).

    DATA(lv_his_id) = lines( lt_current_history ).

    result = VALUE #( FOR incident IN incidents
       ( %tky = incident-%tky
         %action-NewStatus = COND #( WHEN incident-Status EQ inc_status-completed
                                          OR incident-Status EQ inc_status-canceled
                                          OR incident-Status EQ inc_status-closed
                                          OR ( incident-Status EQ inc_status-in_progress )
                                        THEN if_abap_behv=>fc-o-disabled
                                        ELSE if_abap_behv=>fc-o-enabled )
        %assoc-_History      = COND #( WHEN incident-Status EQ inc_status-completed
                                         OR incident-Status EQ inc_status-canceled
                                         OR incident-Status EQ inc_status-closed
                                         OR ( incident-Status EQ inc_status-in_progress
                                               AND lv_is_admin EQ abap_false   )
                                       THEN if_abap_behv=>fc-o-disabled
                                       ELSE if_abap_behv=>fc-o-enabled )
*      %delete              =  COND #( WHEN incident-Status = mc_status-open
*                                      THEN if_abap_behv=>fc-o-enabled
*                                      ELSE if_abap_behv=>fc-o-disabled )

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

    LOOP AT incidents INTO DATA(incident).

      IF lv_technical_name  EQ 'CB9980000286'.
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

        APPEND VALUE #( %msg    = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>not_authorized
                                                         severity =  if_abap_behv_message=>severity-error )
                       %global = if_abap_behv=>mk-on ) TO reported-incident.
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

        APPEND VALUE #( %msg    = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>not_authorized
                                                                  severity =  if_abap_behv_message=>severity-error )
                                %global = if_abap_behv=>mk-on ) TO reported-incident.
      ENDIF.


    ENDIF.

    IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

      IF lv_technical_name  EQ 'CB9980000286'.
        result-%delete          = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete          = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #( %msg    = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>not_authorized
                                                          severity =  if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-incident.

      ENDIF.

    ENDIF.


  ENDMETHOD.

  METHOD ChangeStatus.


  ENDMETHOD.

  METHOD NewStatus.

    DATA: lv_status              TYPE zde_status_code,
          lt_incident_for_update TYPE TABLE FOR UPDATE zcds_r_incident_286,
          lt_history_for_create  TYPE TABLE FOR CREATE zcds_r_incident_286\_history,
          ls_incident_history    TYPE zdt_inct_h_286.

    DATA:  lv_user TYPE c LENGTH 20.

    lv_user = cl_abap_context_info=>get_user_technical_name( ).

    DATA(lv_is_admin) = COND #( WHEN lv_user = 'CB9980000286' THEN abap_true ELSE abap_false ).

    DATA(ls_parameter) = keys[ 1 ]-%param.


    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
     ENTITY Incident
     ALL FIELDS
     WITH CORRESPONDING #( keys )
     RESULT DATA(incidents).

    lv_status = ls_parameter-new_status.


    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).

      IF <incident>-Status EQ inc_status-pending AND ls_parameter-new_status EQ inc_status-completed.

        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.

        APPEND VALUE #( %tky        = <incident>-%tky
                        %state_area = 'VALIDATE_INCIDENT'
                        %msg = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>status_unkown
                                                            severity = if_abap_behv_message=>severity-error )
                      ) TO reported-incident.
        CONTINUE.

      ELSE.

        READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
          ENTITY Incident BY \_history FIELDS ( HisId )
          WITH VALUE #( ( %tky = <incident>-%tky ) )
          RESULT DATA(lt_current_history).

        DATA(lv_next_his_id) = lines( lt_current_history ) + 1.


        DATA lv_generated_uuid TYPE sysuuid_x16.
        TRY.
            lv_generated_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error INTO DATA(lv_error).

        ENDTRY.


        APPEND VALUE #( %tky = <incident>-%tky
                        %target = VALUE #( ( HisUuid        = lv_generated_uuid
                                             IncUuid        = <incident>-Incuuid
                                             HisId          = lv_next_his_id
                                             PreviousStatus = <incident>-Status
                                             NewStatus      = ls_parameter-new_status
                                             Text           = ls_parameter-observation ) )
                      ) TO lt_history_for_create.

      ENDIF.

    ENDLOOP.

    UNASSIGN <incident>.


    IF lt_incident_for_update IS NOT INITIAL.

      MODIFY ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
      ENTITY Incident
      UPDATE  FIELDS ( ChangedDate
                       CreationDate
                       Status
                       Description
                       title
                        )
      WITH lt_incident_for_update.


      MODIFY ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
       ENTITY Incident
       CREATE BY \_History FIELDS ( HisUUID
                                    IncUUID
                                    HisID
                                    PreviousStatus
                                    NewStatus
                                    Text )
          AUTO FILL CID
          WITH lt_history_for_create
       MAPPED mapped
       FAILED failed
       REPORTED reported.


    ENDIF.

*    MODIFY ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
*          ENTITY Incident
*          UPDATE
*          FIELDS ( Status )
*          WITH VALUE #( FOR ls_key IN keys ( %tky          = ls_key-%tky
*                                             Status = inc_status-completed ) ).

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
             ENTITY Incident
             ALL FIELDS
             WITH CORRESPONDING #( keys )
             RESULT DATA(incident_update).

    result = VALUE #( FOR incident IN incidents ( %tky = incident-%tky
                                                  %param = incident  ) ).
*

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

    LOOP AT incidents INTO DATA(incident).

      IF incident-Priority IS INITIAL.
        APPEND VALUE #( %tky        = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        =  incident-%tky
                        %state_area = 'VALIDATE_PRIORITY'
                        %msg        = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>enter_priority
                                                            severity =  if_abap_behv_message=>severity-error )
                        %element-Priority =  if_abap_behv=>mk-on
                        ) TO reported-incident.
      ELSEIF incident-Priority IS NOT INITIAL AND NOT line_exists( valid_priorities[ priority_code = incident-Priority ] ).
        APPEND VALUE #( %tky        = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = incident-%tky
                        %state_area = 'VALIDATE_PRIORITY'
                        %msg        = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>priority_unkown
                                                            severity =  if_abap_behv_message=>severity-error )
                        %element-Priority =  if_abap_behv=>mk-on
                       ) TO reported-incident.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateRange.

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
             ENTITY Incident
             FIELDS ( CreationDate
                      ChangedDate )
             WITH CORRESPONDING #( keys )
             RESULT DATA(incidents).
*

    LOOP AT incidents INTO DATA(incident).

      IF incident-CreationDate IS INITIAL.
        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = incident-%tky
                        %state_area = 'VALIDATE_DATES'
                        %msg        = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>enter_create_date
                                                                   severity =  if_abap_behv_message=>severity-error )
                        %element-CreationDate =  if_abap_behv=>mk-on
                        ) TO reported-incident.

      ENDIF.

      IF incident-ChangedDate IS INITIAL.
        APPEND VALUE #( %tky        = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = incident-%tky
                        %state_area = 'VALIDATE_DATES'
                        %msg        = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>enter_change_date
                                                                   severity =  if_abap_behv_message=>severity-error )
                        %element-ChangedDate =  if_abap_behv=>mk-on
                        ) TO reported-incident.

      ENDIF.

      IF incident-ChangedDate < incident-CreationDate AND incident-CreationDate IS NOT  INITIAL
                                           AND incident-ChangedDate IS NOT  INITIAL.
        APPEND VALUE #( %tky        = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = incident-%tky
                        %state_area = 'VALIDATE_DATES'
                        %msg        = NEW zcl_mensajes_286( textid     = zcl_mensajes_286=>enter_create_date
                                                                   "created_date = incident-CreationDate
                                                                  " changed_date   = incident-ChangedDate
                                                                   severity   =  if_abap_behv_message=>severity-error )
                        %element-CreationDate =  if_abap_behv=>mk-on
                        %element-ChangedDate =  if_abap_behv=>mk-on
                        ) TO reported-incident.

      ENDIF.

      IF incident-CreationDate < cl_abap_context_info=>get_system_date(  ) AND incident-CreationDate IS NOT  INITIAL.
        APPEND VALUE #( %tky        = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = incident-%tky
                        %state_area = 'VALIDATE_DATES'
                        %msg        = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>enter_create_date
                                                                   severity =  if_abap_behv_message=>severity-error )
                        %element-CreationDate =  if_abap_behv=>mk-on
                         ) TO reported-incident.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
               ENTITY Incident
               FIELDS ( Status )
               WITH CORRESPONDING #( keys )
               RESULT DATA(incidents).

    DATA status TYPE SORTED TABLE OF zdt_status286 WITH UNIQUE KEY client status_code .

    status = CORRESPONDING #( incidents DISCARDING DUPLICATES MAPPING status_code = Status EXCEPT * ).
    DELETE status WHERE status_code IS INITIAL.

    IF status IS NOT INITIAL.
      SELECT FROM zdt_status286 AS ddbb
      INNER JOIN @status AS http_req ON ddbb~status_code EQ http_req~status_code
      FIELDS ddbb~status_code
      INTO TABLE @DATA(valid_status).

    ENDIF.

    LOOP AT incidents INTO DATA(incident).

      IF incident-Status IS INITIAL.
        APPEND VALUE #( %tky        = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        =  incident-%tky
                        %state_area = 'VALIDATE_STATUS'
                        %msg        = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>enter_status
                                                            severity =  if_abap_behv_message=>severity-error )
                        %element-Status =  if_abap_behv=>mk-on
                        ) TO reported-incident.
      ELSEIF incident-Status IS NOT INITIAL AND NOT line_exists( valid_status[ status_code = incident-Status ] ).
        APPEND VALUE #( %tky        = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = incident-%tky
                        %state_area = 'VALIDATE_STATUS'
                        %msg        = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>status_unkown
                                                                   severity =  if_abap_behv_message=>severity-error )
                        %element-Status =  if_abap_behv=>mk-on
                       ) TO reported-incident.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD createlHistory.
  ENDMETHOD.

  METHOD setHistoryInc.

    DATA: lv_status              TYPE zde_status_code,
          lt_incident_for_update TYPE TABLE FOR UPDATE zcds_r_incident_286,
          lt_history_for_create  TYPE TABLE FOR CREATE zcds_r_incident_286\_history,
          ls_incident_history    TYPE zdt_inct_h_286.


    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
    ENTITY Incident
     FIELDS ( IncidentID )
     WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).

    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).


      READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
        ENTITY Incident BY \_history FIELDS ( HisId )
        WITH VALUE #( ( %tky = <incident>-%tky ) )
        RESULT DATA(lt_current_history).

      DATA(lv_next_his_id) = lines( lt_current_history ) + 1.


      DATA lv_generated_uuid TYPE sysuuid_x16.
      TRY.
          lv_generated_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error INTO DATA(lv_error).

      ENDTRY.


      APPEND VALUE #( %tky = <incident>-%tky
                      %target = VALUE #( ( HisUuid        = lv_generated_uuid
                                           IncUuid        = <incident>-Incuuid
                                           HisId          = lv_next_his_id
                                           NewStatus      = inc_status-open
                                           Text           = 'Primer Incident' ) )
                    ) TO lt_history_for_create.

    ENDLOOP.

    UNASSIGN <incident>.
    FREE incidents.


    MODIFY ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
    ENTITY Incident
    CREATE BY \_History FIELDS ( HisUUID
                                 IncUUID
                                 HisID
                                 NewStatus
                                 Text )
       AUTO FILL CID
       WITH lt_history_for_create.

  ENDMETHOD.

  METHOD createInitialHistory.
    MODIFY ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
    ENTITY Incident
      EXECUTE setHistoryInc
      FROM CORRESPONDING #( keys )
    REPORTED DATA(lt_reported)
    FAILED DATA(lt_failed).
  ENDMETHOD.

  METHOD validateDescrip.

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
                ENTITY Incident
                FIELDS ( Description )
                WITH CORRESPONDING #( keys )
                RESULT DATA(incidents).

    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).

      IF <incident>-Description IS INITIAL.
        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = <incident>-%tky
                        %state_area = 'VALIDATE_INCIDENT'
                        %msg = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>enter_description
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-Description = if_abap_behv=>mk-on
                       ) TO reported-incident.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
