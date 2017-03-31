
RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::CursorInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual setRecord: Function,
      args: [RC::Class]
      return: LeanRC::CursorInterface

    @public @virtual toArray: Function,
      args: [[RC::Class, RC::Constants.NILL]]
      return: Array

    @public @virtual next: Function,
      args: [[RC::Class, RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public @virtual hasNext: Function,
      args: []
      return: Boolean

    @public @virtual close: Function,
      args: []
      return: RC::Constants.NILL

    @public @virtual count: Function,
      args: []
      return: Number

    @public @virtual forEach: Function,
      args: [Function, [RC::Class, RC::Constants.NILL]]
      return: RC::Constants.NILL

    @public @virtual map: Function,
      args: [Function, [RC::Class, RC::Constants.NILL]]
      return: Array

    @public @virtual filter: Function,
      args: [Function, [RC::Class, RC::Constants.NILL]]
      return: Array

    @public @virtual find: Function,
      args: [Function, [RC::Class, RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public @virtual compact: Function,
      args: [[RC::Class, RC::Constants.NILL]]
      return: Array

    @public @virtual reduce: Function,
      args: [Function, RC::Constants.ANY, [RC::Class, RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public @virtual first: Function,
      args: [[RC::Class, RC::Constants.NILL]]
      return: RC::Constants.ANY


  return LeanRC::CursorInterface.initialize()
