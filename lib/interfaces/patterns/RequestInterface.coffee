

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class RequestInterface extends BaseClass
      @inheritProtected()


    RequestInterface.initializeInterface()
