@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCDS_R_INCIDENT_286
  as select from zdt_inct_286
  composition [0..*] of ZCDS_INC_HISTORY_286 as _History

  association [1..1] to zdt_status286      as _Status   on $projection.Status = _Status.status_code
  association [1..1] to zdt_priority286    as _Priority on $projection.Priority = _Priority.priority_code
{

  key inc_uuid                as Incuuid, 
      incident_id             as IncidentId,
      title                   as Title,
      description             as Description,
      status     as Status,
      //status as Status,
      priority as Priority,
      //priority as Priority,
      creation_date           as CreationDate,
      changed_date            as ChangedDate,
      @Semantics.user.createdBy: true
      local_created_by        as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at        as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by   as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at   as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at         as LastChangedAt,
      _History, // Make association public
      _Status,
      _Priority
}
