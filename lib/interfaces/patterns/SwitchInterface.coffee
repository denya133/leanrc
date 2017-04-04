RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::SwitchInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual routerName: String

    @public @virtual responseFormats: Array

    @public @virtual jsonRendererName: String
    @public @virtual htmlRendererName: String
    @public @virtual xmlRendererName: String
    @public @virtual atomRendererName: String

    @public @virtual rendererFor: Function,
      args: [String]
      return: LeanRC::RendererInterface

    @public @virtual sendHttpResponse: Function,
      args: [Object, Object, Object, Object]
      return: RC::Constants.NILL

    @public @virtual defineRoutes: Function,
      args: []
      return: RC::Constants.NILL

    @public @virtual handler: Function,
      args: [String, Object, Object]
      return: RC::Constants.NILL

    @public @virtual defineSwaggerEndpoint: Function,
      args: [Object]
      return: RC::Constants.NILL

    @public @virtual createNativeRoute: Function,
      args: [Object]
      return: RC::Constants.NILL


  return LeanRC::SwitchInterface.initialize()
