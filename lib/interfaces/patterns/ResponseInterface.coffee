

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class ResponseInterface extends BaseClass
      @inheritProtected()


    ResponseInterface.initializeInterface()
