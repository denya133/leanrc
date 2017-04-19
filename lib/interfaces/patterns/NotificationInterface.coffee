

module.exports = (Module)->
  {ANY, NILL} = Module::

  class NotificationInterface extends Module::Interface
    @inheritProtected()
    @Module: Module

    @public @virtual getName: Function,
      args: []
      return: String
    @public @virtual setBody: Function,
      args: [Object]
      return: NILL
    @public @virtual getBody: Function,
      args: []
      return: ANY
    @public @virtual setType: Function,
      args: [String]
      return: NILL
    @public @virtual getType: Function,
      args: []
      return: String
    @public @virtual toString: Function,
      args: []
      return: String


  NotificationInterface.initialize()
