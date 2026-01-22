@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection - Contract Type Query'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zcds_03_Query_286 
provider contract transactional_query
as projection on ZCDS_R_INCIDENT_286
{
    key IncUuid,
    IncidentId,
    Title,
    Description,
    Status,
    Priority,
    CreationDate,
    ChangedDate,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Priority,
    _Status,
    _History : redirected to composition child ZCDS_04_CHILD_286 // Make association public
}
