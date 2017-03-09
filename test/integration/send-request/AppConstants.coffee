LeanRC = require.main.require 'lib'

module.exports = (RequestApp) ->
  RequestApp::AppConstants =
    STARTUP: 'startup'
    SEND_REQUEST: 'sendRequest'
    RECEIVE_RESPONSE: 'receiveResponse'
