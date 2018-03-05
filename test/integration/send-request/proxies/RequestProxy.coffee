
request = require 'request'

module.exports = (Module) ->
  class RequestProxy extends Module.NS.Proxy
    @inheritProtected()
    @module Module

    @const REQUEST_PROXY: 'requestProxy'

    @public request: Function,
      default: (data) ->
        request.get '/test/data.json', (err, response, body) =>
          if err?
            message = "Error: #{err.message ? err}"
          else
            message = JSON.parse(body ? null)?.message ? body
          @sendNotification Module.NS.RECEIVE_RESPONSE, message

  RequestProxy.initialize()
