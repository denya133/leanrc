RC            = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::RendererInterface extends RC::Interface
    @inheritProtected()
    @include LeanRC::ProxyInterface

    @Module: LeanRC

    @public @virtual render: Function,
      args: [Object, Object]
      return: RC::ANY


  return LeanRC::RendererInterface.initialize()
