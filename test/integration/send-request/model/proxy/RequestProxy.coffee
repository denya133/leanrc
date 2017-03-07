LeanRC = require.main.require 'lib'
request = require 'request'

module.exports = (RequestApp) ->
  class RequestApp::RequestProxy extends LeanRC::Proxy
    @inheritProtected()
    @Module: RequestApp

    @public @static REQUEST_PROXY: String,
      default: 'requestProxy'

    @public request: Function,
      default: (data) ->
        request.get '/test/data.json', (err, response, body) =>
          if err?
            message = "Error: #{err.message ? err}"
          else
            message = JSON.parse(body ? null)?.message ? body
          @sendNotification RequestApp::AppConstants.RECEIVE_RESPONSE, message

  RequestApp::RequestProxy.initialize()
