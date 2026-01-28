@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS INCUUID'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDS_INCUUID_VH as select from zdt_inct_286
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
    last_changed_at as LastChangedAt
}
