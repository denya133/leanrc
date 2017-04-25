

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface 'NotifierInterface', (BaseClass) ->
    class NotifierInterface extends BaseClass
      @inheritProtected()
      @module Module

      @public @virtual sendNotification: Function,
        args: [String, ANY, String]
        return: NILL
      @public @virtual initializeNotifier: Function,
        args: [String]
        return: NILL


    NotifierInterface.initializeInterface()
