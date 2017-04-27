

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface 'SwitchInterface', (BaseClass) ->
    class SwitchInterface extends BaseClass
      @inheritProtected()

      @module Module

      @public @virtual routerName: String

      @public @virtual responseFormats: Array

      @public @virtual jsonRendererName: String
      @public @virtual htmlRendererName: String
      @public @virtual xmlRendererName: String
      @public @virtual atomRendererName: String

      @public @virtual rendererFor: Function,
        args: [String]
        return: Module::RendererInterface

      @public @virtual sendHttpResponse: Function,
        args: [Object, Object, Object, Object]
        return: NILL

      @public @virtual defineRoutes: Function,
        args: []
        return: NILL

      @public @virtual handler: Function,
        args: [String, Object, Object]
        return: NILL

      @public @virtual defineSwaggerEndpoint: Function,
        args: [Object]
        return: NILL

      @public @virtual createNativeRoute: Function,
        args: [Object]
        return: NILL


    SwitchInterface.initializeInterface()
