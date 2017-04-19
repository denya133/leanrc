

module.exports = (Module)->
  {ANY, NILL} = Module::

  class NotifierInterface extends Module::Interface
    @inheritProtected()
    @Module: Module

    @public @virtual sendNotification: Function,
      args: [String, ANY, String]
      return: NILL
    @public @virtual initializeNotifier: Function,
      args: [String]
      return: NILL


  NotifierInterface.initialize()
