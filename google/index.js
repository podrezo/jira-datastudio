const communityConnector = DataStudioApp.createCommunityConnector();
const dsTypes = communityConnector.FieldType;
const dsAggregationTypes = communityConnector.AggregationType;

function _getField(fields, fieldId) {
  switch (fieldId) {
    case 'type':
      fields
        .newDimension()
        .setId('type')
        .setName('Issue Type')
        .setType(dsTypes.TEXT);
      break;
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
        .setType(dsTypes.NUMBER)
        .setAggregation(dsAggregationTypes.SUM);
      break;
    case 'cumulative_finished_issues':
      fields
        .newMetric()
        .setId('cumulative_finished_issues')
        .setName('Cumulative Finished Issues')
        .setType(dsTypes.NUMBER)
        .setAggregation(dsAggregationTypes.SUM);
      break;
    case 'throughput_day':
        fields
          .newMetric()
          .setId('throughput_day')
          .setName('Throughput (1 Day)')
          .setType(dsTypes.NUMBER)
          .setAggregation(dsAggregationTypes.SUM);
        break;
    case 'throughput_week':
      fields
        .newMetric()
        .setId('throughput_week')
        .setName('Throughput (7 Days)')
        .setType(dsTypes.NUMBER)
        .setAggregation(dsAggregationTypes.SUM);
      break;
    case 'cumulative_finished_issues_plus_wip':
      fields
        .newMetric()
        .setId('cumulative_finished_issues_plus_wip')
        .setName('Cumulative Finished Issues + WIP')
        .setType(dsTypes.NUMBER)
        .setFormula('$cumulative_finished_issues + $wip')
        .setAggregation(dsAggregationTypes.SUM);
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
  const fieldIds = request.fields ? request.fields.map(field => field.name) : ['type', 'date', 'wip', 'cumulative_finished_issues', 'throughput_day', 'throughput_week', 'cumulative_finished_issues_plus_wip'];
  fieldIds.forEach(fieldId => {
    fields = _getField(fields, fieldId);
  });
  fields.setDefaultMetric('wip');
  fields.setDefaultDimension('date');
  return { 'schema': fields.build() };
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

  const payload = {
    tenant_name: request.configParams.atlassianTenantName,
    username: request.configParams.atlassianUsername,
    token: request.configParams.atlassianToken,
    jql: request.configParams.jqlIssueQuery,
  };
  if(request.dateRange) {
    payload.dateRange = request.dateRange;
  }
  const endpoint = 'https://s4qjj6vqha.execute-api.us-east-1.amazonaws.com/jira-kanban';
  const requestOptions = {
    muteHttpExceptions: false,
    method: 'post',
    contentType: 'application/json',
    payload: JSON.stringify(payload)
  };
  const httpResponse = UrlFetchApp.fetch(endpoint, requestOptions);
  // handle errors from the API
  if(httpResponse.getResponseCode() !== 200) {
    Logger.log('An exception occurred accessing the API:');
    Logger.log(httpResponse.getResponseCode());
    Logger.log(httpResponse.getAllHeaders());
    Logger.log(httpResponse.getContentText());
    sendUserError(`The API replied with an unsuccessful status code of ${httpResponse.getResponseCode()}`);
    return;
  }
  const data = JSON.parse(httpResponse.getContentText());

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
    .setId('jqlIssueQuery')
    .setName('JQL Issue Query')
    .setHelpText('If you go to your "Issues" view you can filter down to the issues you are interested in then switch to "advanced" view to see the JQL query.')
    .setPlaceholder('project = XYZ AND issuetype != Sub-task AND type not in ("Epic")');

  config.setDateRangeRequired(true);
  return config.build();
}

function isAdminUser() {
  return false;
}

function getAuthType() {
  return communityConnector.newAuthTypeResponse()
    .setAuthType(communityConnector.AuthType.USER_TOKEN)
    // .setHelpUrl('https://www.example.org/connector-auth-help')
    .build();
}

function isAuthValid() {
  const userProperties = PropertiesService.getUserProperties();
  const username = userProperties.getProperty('jirakanban.username');
  const token = userProperties.getProperty('jirakanban.token');
  const tenant = userProperties.getProperty('jirakanban.tenant');

  if(username === null || token === null || tenant === null) {
    return false;
  }

  // This endpoint just gives some details about the currently logged in user.
  // We use it to ensure that the token provided has access to the API
  const endpoint = `https://${tenant}.atlassian.net/rest/api/3/myself`;
  const requestOptions = {
    muteHttpExceptions: false,
    method: 'get',
    headers: {
      Authorization: 'Basic ' + Utilities.base64Encode(username + ':' + token)
    }
  };
  const httpResponse = UrlFetchApp.fetch(endpoint, requestOptions);
  const responseCode = httpResponse.getResponseCode();
  switch(responseCode) {
    case 200:
      return true;
    case 401:
      return false;
    default:
      sendUserError(`Received HTTP status ${responseCode} during auth check. The credentials may be wrong or Jira might be down.`)
  }
}


function setCredentials(request) {
  // the "username" field must actually contain both the tenant and username because of DataStudio limitations
  // They should be separated by a single forward slash ("/") character, where the tenant is first.
  // For example: my-company/myuser@mycompany.com
  const usernameParts = request.userToken.username.split('/');
  if(usernameParts.length != 2) {
    return { errorCode: 'INVALID_CREDENTIALS' }
  }
  const tenant = usernameParts[0];
  const username = usernameParts[1];
  const token = request.userToken.token;

  const userProperties = PropertiesService.getUserProperties();
  userProperties.setProperty('jirakanban.username', username);
  userProperties.setProperty('jirakanban.token', token);
  userProperties.setProperty('jirakanban.tenant', tenant);
  return {
    errorCode: 'NONE'
  };
}

function resetAuth() {
  const userProperties = PropertiesService.getUserProperties();
  userProperties.deleteProperty('jirakanban.username');
  userProperties.deleteProperty('jirakanban.token');
  userProperties.deleteProperty('jirakanban.tenant');
  return true;
}

// Helper method to show an error to the user
function sendUserError(message) {
  communityConnector.newUserError()
    .setText(message)
    .throwException();
}