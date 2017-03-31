RC            = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::Renderer extends LeanRC::Proxy
    @inheritProtected()
    @implements LeanRC::RendererInterface

    @Module: LeanRC

    # may be redefine at inheritance
    @public render: Function,
      default: (aoData, aoOptions)->
        JSON.stringify aoData


  return LeanRC::Renderer.initialize()
