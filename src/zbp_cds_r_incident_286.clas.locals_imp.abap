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

    METHODS NewStatus FOR MODIFY
      IMPORTING keys FOR ACTION Incident~NewStatus RESULT result.

    METHODS setHistoryInc FOR MODIFY
      IMPORTING keys FOR ACTION Incident~setHistoryInc.

    METHODS setValuesInitial FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Incident~setValuesInitial.

    METHODS createInitialHistory FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incident~createInitialHistory.

    METHODS setChangeDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incident~setChangeDate.

    METHODS setHistoryInitial FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incident~setHistoryInitial.

    METHODS validaCamposObligatorios FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validaCamposObligatorios.

ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_instance_features.

    DATA: lv_user TYPE zde_responsable_286..
    lv_user = cl_abap_context_info=>get_user_technical_name( ).

    DATA(lv_is_admin) = COND #( WHEN lv_user = 'CB9980000286' THEN abap_true ELSE abap_false ).

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
     ENTITY Incident
       ALL FIELDS
       WITH CORRESPONDING #( keys )
     RESULT DATA(incidents).

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
                                      OR lv_his_id EQ 0
                                      OR ( incident-Status EQ inc_status-in_progress
                                           AND   incident-Responsable NE lv_user  AND lv_is_admin EQ abap_false   )
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )
     %assoc-_History      = COND #( WHEN incident-Status EQ inc_status-completed
                                      OR incident-Status EQ inc_status-canceled
                                      OR incident-Status EQ inc_status-closed
                                      OR ( incident-Status EQ inc_status-in_progress
                                           AND   incident-Responsable NE lv_user  AND lv_is_admin EQ abap_false   )
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )
*      %delete              =  COND #( WHEN incident-Status = inc_status-open
*                                      THEN if_abap_behv=>fc-o-enabled
*                                      ELSE if_abap_behv=>fc-o-disabled )

   ) ).


  ENDMETHOD.

  METHOD get_instance_authorizations.

    DATA: lv_user TYPE zde_responsable_286..
    lv_user = cl_abap_context_info=>get_user_technical_name( ).

    DATA(lv_is_admin) = COND #( WHEN lv_user = 'CB9980000286' THEN abap_true ELSE abap_false ).


    DATA(delete_requested) = COND #( WHEN ( requested_authorizations-%delete = if_abap_behv=>mk-on )
                                 THEN abap_true
                                 ELSE abap_false ).

    IF delete_requested EQ abap_true.

      READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
        ENTITY Incident
        FIELDS ( IncidentID ) WITH CORRESPONDING #( keys )
        RESULT DATA(incidents).

      LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).


        IF lv_is_admin = abap_true.
          DATA(lv_delete_granted) = abap_true.

        ELSE.

          lv_delete_granted = abap_false.

          APPEND VALUE #( %tky = <incident>-%tky
                          %state_area = 'VALIDATE_INCIDENT'
                          %msg = NEW zcl_mensajes_286( textid    = zcl_mensajes_286=>user_unauthorized
                                                               userid   = lv_user
                                                               incident_id = <incident>-IncidentID
                                                               severity  = if_abap_behv_message=>severity-error )
                         ) TO reported-incident.
        ENDIF.

        APPEND VALUE #( LET upd_auth = COND #( WHEN lv_delete_granted EQ abap_true
                                                 THEN if_abap_behv=>auth-allowed
                                                 ELSE if_abap_behv=>auth-unauthorized )
                          IN
                        %tky = <incident>-%tky
                        %delete = upd_auth
                       ) TO result.
      ENDLOOP.

    ENDIF.


  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD NewStatus.

    DATA: lv_status              TYPE zde_status_code,
          lt_incident_for_update TYPE TABLE FOR UPDATE zcds_r_incident_286,
          lv_responsable         TYPE zde_responsable_286,
          lv_title               TYPE zde_title_286,
          lv_description         TYPE zde_description_286,
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
    lv_responsable = ls_parameter-responsible.
    lv_title = ls_parameter-Title.
    lv_description = ls_parameter-text.

    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).

      IF lv_is_admin EQ abap_false AND  (  <incident>-Responsable IS NOT INITIAL AND  lv_user NE <incident>-Responsable ).
        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.

        APPEND VALUE #( %tky        = <incident>-%tky
                        %state_area = 'VALIDATE_INCIDENT'
                        %msg = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>responsible_required
                                                            severity = if_abap_behv_message=>severity-error )
                      ) TO reported-incident.
        CONTINUE.
      ENDIF.



      IF <incident>-Status EQ inc_status-pending AND ( ls_parameter-new_status EQ inc_status-completed
                                                      OR  ls_parameter-new_status EQ inc_status-closed ).

        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.

        APPEND VALUE #( %tky        = <incident>-%tky
                        %state_area = 'VALIDATE_INCIDENT'
                        %msg = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>status_unkown
                                                            severity = if_abap_behv_message=>severity-error )
                      ) TO reported-incident.
        CONTINUE.

      ELSE.

        IF lv_status = inc_status-in_progress AND lv_responsable IS INITIAL AND <incident>-Responsable IS INITIAL.


          APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.

          APPEND VALUE #(
              %tky = incidents[ 1 ]-%tky
              %state_area = 'VALIDATE_INCIDENT'
              %msg = NEW zcl_mensajes_286(
                          textid   = zcl_mensajes_286=>responsible_required
                          severity = if_abap_behv_message=>severity-error )
              %element-responsable = if_abap_behv=>mk-on
          ) TO reported-incident.

          RETURN.


        ENDIF.

        IF  <incident>-Responsable IS INITIAL..
          DATA(lv_respon_final) = lv_responsable.
        ELSE.
          lv_respon_final = <incident>-Responsable.
        ENDIF.

        APPEND VALUE #( %tky       = <incident>-%tky
                       Status = lv_status
                       Title = lv_title
                       Description = lv_description
                       Responsable = lv_respon_final
                       CreationDate = cl_abap_context_info=>get_system_date( )

                      ) TO lt_incident_for_update.



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
                                             Text           = ls_parameter-text ) )
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
                       Responsable
                       Title
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


    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
             ENTITY Incident
             ALL FIELDS
             WITH CORRESPONDING #( keys )
             RESULT DATA(incident_update).

    result = VALUE #( FOR incident IN incidents ( %tky = incident-%tky
                                                  %param = incident  ) ).
*

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
                                           Text           = 'Primer Incidente' ) )
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
                                 Text
                                  )
       AUTO FILL CID
       WITH lt_history_for_create.


  ENDMETHOD.

  METHOD setValuesInitial.

    DATA: lt_incident_for_update TYPE TABLE FOR UPDATE zcds_r_incident_286.

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
     ENTITY Incident
      ALL FIELDS
      WITH CORRESPONDING #( keys )
     RESULT DATA(incidents).

    DELETE incidents WHERE IncidentID IS NOT INITIAL.

    CHECK incidents IS NOT INITIAL.


    SELECT FROM zdt_inct_286
     FIELDS MAX( incident_id ) AS max_inct_id
     WHERE incident_id IS NOT NULL
     INTO @DATA(lv_max_incident_id).

    IF lv_max_incident_id IS INITIAL.
      lv_max_incident_id = 1.
    ELSE.
      lv_max_incident_id += 1.
    ENDIF.


    MODIFY ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
        ENTITY Incident
        UPDATE
        FIELDS ( IncidentID
                 CreationDate
                 Status )
        WITH VALUE #(  FOR incident IN incidents ( %tky = incident-%tky
                               IncidentID = lv_max_incident_id
                               CreationDate = cl_abap_context_info=>get_system_date( )
                               Status       = inc_status-open )  ).


  ENDMETHOD.

  METHOD createInitialHistory.

    MODIFY ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
      ENTITY Incident
        EXECUTE setHistoryInc
        FROM CORRESPONDING #( keys )
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).

  ENDMETHOD.

  METHOD setChangeDate.

    DATA: lt_incident_for_update TYPE TABLE FOR UPDATE zcds_r_incident_286.

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
     ENTITY Incident
      FIELDS ( ChangedDate )
      WITH CORRESPONDING #( keys )
     RESULT DATA(incidents).

    DELETE incidents WHERE ChangedDate = cl_abap_context_info=>get_system_date( ).

    MODIFY ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
     ENTITY Incident
     UPDATE
     FIELDS ( ChangedDate )
     WITH VALUE #(  FOR incident IN incidents ( %tky = incident-%tky
                            ChangedDate = cl_abap_context_info=>get_system_date( )
                 ) ).

  ENDMETHOD.

  METHOD setHistoryInitial.

  ENDMETHOD.

  METHOD validaCamposObligatorios.

    READ ENTITIES OF zcds_r_incident_286 IN LOCAL MODE
       ENTITY Incident
        FIELDS ( Title Description Priority status CreationDate )
        WITH CORRESPONDING #( keys )
       RESULT DATA(incidents).

    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).
      APPEND VALUE #( %tky = <incident>-%tky
            %state_area = 'VALIDATE_INCIDENT' ) TO reported-incident.


      IF <incident>-Title IS INITIAL.
        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = <incident>-%tky
                        %state_area = 'VALIDATE_TITLE'
                        %msg = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>enter_title
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-Title = if_abap_behv=>mk-on
                       ) TO reported-incident.
        RETURN.
      ENDIF.


      IF <incident>-Description IS INITIAL.
        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = <incident>-%tky
                        %state_area = 'VALIDATE_DESCRIPTION'
                        %msg = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>enter_description
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-Description = if_abap_behv=>mk-on
                       ) TO reported-incident.
        RETURN.
      ENDIF.


      IF <incident>-Priority IS INITIAL.
        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = <incident>-%tky
                        %state_area = 'VALIDATE_PRIORITY'
                        %msg = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>enter_priority
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-Priority = if_abap_behv=>mk-on
                       ) TO reported-incident.
        RETURN.
      ENDIF.

      IF <incident>-Status IS INITIAL.
        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky        = <incident>-%tky
                        %state_area = 'VALIDATE_STATUS'
                        %msg = NEW zcl_mensajes_286( textid   = zcl_mensajes_286=>enter_status
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-Status = if_abap_behv=>mk-on
                       ) TO reported-incident.
        RETURN.
      ENDIF.


    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
