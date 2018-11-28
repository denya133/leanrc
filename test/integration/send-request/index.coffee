LeanRC = require.main.require 'lib'


class RequestApp extends LeanRC
  @inheritProtected()
  @include LeanRC::NamespaceModuleMixin

  @root __dirname

  @const SEND_REQUEST: 'sendRequest'
  @const RECEIVE_RESPONSE: 'receiveResponse'


module.exports = RequestApp.initialize()
