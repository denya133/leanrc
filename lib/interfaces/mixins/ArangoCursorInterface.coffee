
RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::ArangoCursorInterface extends RC::Interface
    @inheritProtected()
    @include LeanRC::CursorInterface

    @Module: LeanRC

    @public setCursor: Function,
      args: [RC::Constants.ANY]
      return: ArangoCursorInterface

    @public getExtra: Function,
      args: []
      return: RC::Constants.ANY

    @public setBatchSize: Function,
      args: [Number]
      return: RC::Constants.NILL

    @public getBatchSize: Function,
      args: []
      return: RC::Constants.ANY

    @public dispose: Function,
      args: []
      return: RC::Constants.NILL


  return LeanRC::ArangoCursorInterface.initialize()
