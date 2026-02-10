@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incident - Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZCDS_C_INCIDENT_286
  provider contract transactional_query
  as projection on ZCDS_R_INCIDENT_286
{
  key Incuuid,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @ObjectModel.text.element: [ 'IncidentId' ]
      IncidentId,
      Title,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #MEDIUM
      @ObjectModel.text.element: [ 'Description' ]
      Description,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @ObjectModel.text.element: [ 'StatusName' ]
      Status,
      _Status.status_description     as StatusName,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @ObjectModel.text.element: [ 'PriorityName' ]
      Priority,
      _Priority.priority_description as PriorityName,
      @Search.defaultSearchElement: true
      CreationDate,
      @Search.defaultSearchElement: true
      ChangedDate,
      Responsable, 
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      /* Associations */ 
      _History : redirected to composition child zcds_c_history_286,
      _Priority,
      _Status 
}
