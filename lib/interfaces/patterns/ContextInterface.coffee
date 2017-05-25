

module.exports = (Module)->
  {
    ANY
    NILL

    RequestInterface
    ResponseInterface
  } = Module::

  Module.defineInterface (BaseClass) ->
    class ContextInterface extends BaseClass
      @inheritProtected()

      @public @virtual req: Object
      @public @virtual res: Object
      @public @virtual request: RequestInterface
      @public @virtual response: ResponseInterface
      @public @virtual state: Object

      @public @virtual throw: Function,
        args: [[String, Number], [String, NILL], [Object, NILL]]
        return: NILL

      @public @virtual assert: Function,
        args: [ANY, [String, Number], [String, NILL], [Object, NILL]]
        return: NILL

      # TODO: решить - нужно ли здесь перечислять алиасы request'а и response'а

    ContextInterface.initializeInterface()
