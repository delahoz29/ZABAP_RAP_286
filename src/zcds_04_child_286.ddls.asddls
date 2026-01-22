@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection - Contract Type Int. Child'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCDS_04_CHILD_286 
as projection on  ZCDS_01_History_286
{
    key HisUuid,
    key IncUuid,
    HisId,
    PreviousStatus,
    NewStatus,
    Text,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Status,
    _StatusNew,
    _Incident : redirected to parent zcds_03_Query_286 
      
}
