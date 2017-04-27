

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class NotifierInterface extends BaseClass
      @inheritProtected()

      @public @virtual sendNotification: Function,
        args: [String, ANY, String]
        return: NILL
      @public @virtual initializeNotifier: Function,
        args: [String]
        return: NILL


    NotifierInterface.initializeInterface()
