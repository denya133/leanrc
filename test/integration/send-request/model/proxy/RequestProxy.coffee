LeanRC = require.main.require 'lib'

module.exports = (RequestApp) ->
  class RequestApp::RequestProxy extends LeanRC::Proxy
    @inheritProtected()
    @Module: RequestApp

    @public @static REQUEST_PROXY: String,
      default: 'requestProxy'

    @public animate: Function,
      default: ->
        @setData yes
        if @getData()
          @sendNotification RequestApp::AppConstants.RECEIVE_RESPONSE, 'I am awaken. Hello World'

  RequestApp::RequestProxy.initialize()
