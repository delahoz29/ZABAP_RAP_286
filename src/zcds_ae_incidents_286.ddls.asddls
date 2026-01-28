@EndUserText.label: 'New Status'
define abstract entity zcds_ae_incidents_286
{
  @EndUserText.label: 'New Status'
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCDS_STATUS_286',
                                                 element: 'StatusCode'},
                                                 useForValidation: true }]
  new_status  : abap.char(20);
  @EndUserText.label: 'Observation'
  observation : abap.char(50);
}
