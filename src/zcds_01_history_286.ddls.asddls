@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Association to parent'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDS_01_History_286
  as select from zdt_inct_h_286

  association        to parent ZCDS_R_INCIDENT_286 as _Incident  on _Incident.Incuuid = $projection.IncUuid

  association [1..1] to zdt_status286             as _Status    on _Status.status_code = $projection.PreviousStatus
  association [1..1] to zdt_status286             as _StatusNew on _StatusNew.status_code = $projection.NewStatus

{
  key his_uuid              as HisUuid,
  key inc_uuid              as IncUuid,
      his_id                as HisId,
      previous_status       as PreviousStatus,
      new_status            as NewStatus,
      text                  as Text,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,
      _Incident,
      _Status,
      _StatusNew
}
