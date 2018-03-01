LeanRC = require.main.require 'lib'


class RequestApp extends LeanRC
  @inheritProtected()
  @include LeanRC::NamespaceModuleMixin

  @root __dirname

  @const SEND_REQUEST: Symbol 'sendRequest'
  @const RECEIVE_RESPONSE: Symbol 'receiveResponse'


module.exports = RequestApp.initialize()
