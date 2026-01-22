@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection - Contract Type Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCDS_I_INCIDENT_286 
provider contract transactional_interface
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
    _History : redirected to composition child ZCDS_02_CHILD_286
    
     
}
