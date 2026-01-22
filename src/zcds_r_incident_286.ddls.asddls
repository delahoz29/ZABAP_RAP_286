@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCDS_R_INCIDENT_286 
as select from zdt_inct_286
composition  [0..*] of ZCDS_01_History_286 as _History 

association [1..1] to zdt_status_286 as _Status on _Status.status_code = $projection.Status
association [1..1] to zdt_priority_286 as _Priority on _Priority.priority_code = $projection.Priority
{
    key inc_uuid as IncUuid,
    incident_id as IncidentId,
    title as Title,
    description as Description,
    status as Status,
    priority as Priority,
    creation_date as CreationDate,
    changed_date as ChangedDate,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt,
    _History, // Make association public
    _Status,
    _Priority
}
