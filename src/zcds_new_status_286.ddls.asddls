@EndUserText.label: 'Abstract - Change Status'
define abstract entity ZCDS_NEW_STATUS_286

{
  @EndUserText.label: 'New Status'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCDS_STATUS_286',
                                                 element: 'StatusCode'},
                                                 useForValidation: true }]
  new_status      : zde_status_code;

  @EndUserText.label: 'Observaciones'
  text            : zde_observation_286;

  @UI.hidden      : true
  HideResponsible : abap_boolean;

  @EndUserText.label: 'Title'
  Title           : zde_title_286;

  @EndUserText.label: 'Responsable'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCDS_USERS_286', element: 'UserId'  },
                                                 useForValidation: true }]
  @UI.hidden      : #(HideResponsible)
  responsible     : zde_responsable_286;


}
