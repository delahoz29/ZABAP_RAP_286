@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'History- Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zcds_c_history_286 as projection on ZCDS_INC_HISTORY_286
{
 key HisUuid,
 IncUuid,
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
_Incident : redirected to parent  ZCDS_C_INCIDENT_286
}
