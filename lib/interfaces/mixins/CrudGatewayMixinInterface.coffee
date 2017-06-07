

module.exports = (Module)->
  Module.defineInterface (BaseClass) ->
    class CrudGatewayMixinInterface extends BaseClass
      @inheritProtected()

      @public @virtual keyName: String

      @public @virtual itemEntityName: String

      @public @virtual listEntityName: String

      @public @virtual schema: Object

      @public @virtual listSchema: Object

      @public @virtual itemSchema: Object

      @public @virtual keySchema: Object

      @public @virtual querySchema: Object

      @public @virtual versionSchema: Object

      @public @virtual onRegister: Function,
        args: []
        return: Module::NILL


    CrudGatewayMixinInterface.initializeInterface()
