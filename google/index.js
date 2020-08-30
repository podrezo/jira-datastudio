const communityConnector = DataStudioApp.createCommunityConnector();
const dsTypes = communityConnector.FieldType;
// const dsAggregationTypes = communityConnector.AggregationType;

function _getField(fields, fieldId) {
  switch (fieldId) {
    case 'date':
      fields
        .newDimension()
        .setId('date')
        .setName('Date')
        .setType(dsTypes.YEAR_MONTH_DAY);
      break;
    case 'wip':
      fields
        .newMetric()
        .setId('wip')
        .setName('WIP')
        .setType(dsTypes.NUMBER);
      break;
    case 'cumulative_finished_issues':
      fields
        .newMetric()
        .setId('cumulative_finished_issues')
        .setName('Cumulative Finished Issues')
        .setType(dsTypes.NUMBER);
      break;
    case 'throughput':
      fields
        .newMetric()
        .setId('throughput')
        .setName('Throughput')
        .setType(dsTypes.NUMBER);
      break;
    default:
      throw new Error(`Invalid fieldId: ${fieldId}`)
  }
  return fields;
}

// REQUEST OBJECT EXAMPLE:
// {
//   "configParams": {
//     "exampleSelectMultiple": "foobar,amet",
//     "exampleSelectSingle": "ipsum",
//     "exampleTextInput": "Lorem Ipsum Dolor Sit Amet",
//     "exampleTextArea": "NA",
//     "exampleCheckbox": "true"
//   }
// }
function getSchema(request) {
  let fields = communityConnector.getFields();
  const fieldIds = request.fields ? request.fields.map(field => field.name) : ['date', 'wip', 'cumulative_finished_issues', 'throughput'];
  fieldIds.forEach(fieldId => {
    fields = _getField(fields, fieldId);
  });
  fields.setDefaultMetric('wip');
  fields.setDefaultDimension('date');
  return { 'schema': fields.build() };
}

function __tryParseJson(text) {
  try {
    return JSON.parse(text);
  } catch (e) {
    Logger.log('Tried to parse invalid JSON body:');
    Logger.log(text);
    sendUserError('Received an invalid response from the API; try refreshing the data later');
  }
}

// REQUEST OBJECT EXAMPLE:
// {
//   "configParams": object,
//   "scriptParams": {
//     "sampleExtraction": boolean,
//     "lastRefresh": string
//   },
//   "dateRange": {
//     "startDate": string,
//     "endDate": string
//   },
//   "fields": [
//     {
//       "name": string
//     }
//   ],
//   "dimensionsFilters": [
//     [{
//       "fieldName": string,
//       "values": string[],
//       "type": DimensionsFilterType,
//       "operator": Operator
//     }]
//   ]
// }
function getData(request) {
  let fields = communityConnector.getFields();
  const fieldIds = request.fields.map(field => field.name);
  fieldIds.forEach(fieldId => {
    fields = _getField(fields, fieldId);
  });

  const data = [
    {
      "date": "20200812",
      "wip": 1,
      "cumulative_finished_issues": 0,
      "throughput": 0
    },
    {
      "date": "20200813",
      "wip": 1,
      "cumulative_finished_issues": 0,
      "throughput": 0
    },
    {
      "date": "20200814",
      "wip": 1,
      "cumulative_finished_issues": 0,
      "throughput": 0
    },
    {
      "date": "20200815",
      "wip": 1,
      "cumulative_finished_issues": 0,
      "throughput": 0
    },
    {
      "date": "20200816",
      "wip": 1,
      "cumulative_finished_issues": 0,
      "throughput": 0
    },
    {
      "date": "20200817",
      "wip": 0,
      "cumulative_finished_issues": 1,
      "throughput": 1
    },
    {
      "date": "20200818",
      "wip": 0,
      "cumulative_finished_issues": 1,
      "throughput": 1
    },
    {
      "date": "20200819",
      "wip": 0,
      "cumulative_finished_issues": 1,
      "throughput": 1
    },
    {
      "date": "20200820",
      "wip": 0,
      "cumulative_finished_issues": 1,
      "throughput": 1
    },
    {
      "date": "20200821",
      "wip": 0,
      "cumulative_finished_issues": 1,
      "throughput": 1
    },
    {
      "date": "20200822",
      "wip": 0,
      "cumulative_finished_issues": 1,
      "throughput": 1
    },
    {
      "date": "20200823",
      "wip": 0,
      "cumulative_finished_issues": 1,
      "throughput": 1
    },
    {
      "date": "20200824",
      "wip": 0,
      "cumulative_finished_issues": 1,
      "throughput": 0
    },
    {
      "date": "20200825",
      "wip": 1,
      "cumulative_finished_issues": 2,
      "throughput": 1
    },
    {
      "date": "20200826",
      "wip": 0,
      "cumulative_finished_issues": 3,
      "throughput": 2
    },
    {
      "date": "20200827",
      "wip": 0,
      "cumulative_finished_issues": 4,
      "throughput": 3
    }
  ];
  const rows = data.map(dataPoint => {
    return {
      values: fieldIds.map(fieldId => dataPoint[fieldId])
    };
  });

  const result = {
    schema: fields.build(),
    rows: rows,
    filtersApplied: false, // TODO: Some fields are only for filtering. This will be evident from `fields[].forFilterOnly` and those should not be in the data
  };
  return result;
}

function getConfig(request) {
  var communityConnector = DataStudioApp.createCommunityConnector();
  var config = communityConnector.getConfig();

  config
    .newTextInput()
    .setId('atlassianTenantName')
    .setName('Atlassian tenant name (e.g. the subdomain. If you sign in at my-company.atlassian.net then this value is "my-company")')
    .setPlaceholder('my-company');

  config
    .newTextInput()
    .setId('atlassianUsername')
    .setName('Your Atlassian username (typically your e-mail address)')
    .setPlaceholder('joe@my-company.com');

  config
    .newTextInput()
    .setId('atlassianToken')
    .setName('Your security token to access the API')
    .setHelpText('You can get this value by going to your account settings, then "security" and then "Create and manage API tokens". Just copy paste the value here.')
    .setPlaceholder('This is required to access the API and pull down data');

  config
    .newTextInput()
    .setId('jqlIssueQuery')
    .setName('JQL Issue Query')
    .setHelpText('If you go to your "Issues" view you can filter down to the issues you are interested in then switch to "advanced" view to see the JQL query.')
    .setPlaceholder('project = XYZ AND issuetype != Sub-task AND resolved > -30d');

  config.setDateRangeRequired(false);
  return config.build();
}

function isAdminUser() {
  return false;
}

function getAuthType() {
  var response = { type: 'NONE' };
  return response;
}

// Helper method to show an error to the user
function sendUserError(message) {
  var cc = DataStudioApp.createCommunityConnector();
  cc.newUserError()
    .setText(message)
    .throwException();
}