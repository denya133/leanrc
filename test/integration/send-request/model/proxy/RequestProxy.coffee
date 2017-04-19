
request = require 'request'

module.exports = (Module) ->
  class RequestProxy extends Module::Proxy
    @inheritProtected()
    @Module: Module

    @const REQUEST_PROXY: 'requestProxy'

    @public request: Function,
      default: (data) ->
        request.get '/test/data.json', (err, response, body) =>
          if err?
            message = "Error: #{err.message ? err}"
          else
            message = JSON.parse(body ? null)?.message ? body
          @sendNotification Module::RECEIVE_RESPONSE, message

  RequestProxy.initialize()
