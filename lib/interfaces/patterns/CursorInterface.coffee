
RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::CursorInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual setRecord: Function,
      args: [RC::Class]
      return: LeanRC::CursorInterface

    @public @async @virtual toArray: Function,
      args: [[RC::Class, RC::Constants.NILL]]
      return: Array

    @public @async @virtual next: Function,
      args: [[RC::Class, RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public @async @virtual hasNext: Function,
      args: []
      return: Boolean

    @public @async @virtual close: Function,
      args: []
      return: RC::Constants.NILL

    @public @async @virtual count: Function,
      args: []
      return: Number

    @public @async @virtual forEach: Function,
      args: [Function, [RC::Class, RC::Constants.NILL]]
      return: RC::Constants.NILL

    @public @async @virtual map: Function,
      args: [Function, [RC::Class, RC::Constants.NILL]]
      return: Array

    @public @async @virtual filter: Function,
      args: [Function, [RC::Class, RC::Constants.NILL]]
      return: Array

    @public @async @virtual find: Function,
      args: [Function, [RC::Class, RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public @async @virtual compact: Function,
      args: [[RC::Class, RC::Constants.NILL]]
      return: Array

    @public @async @virtual reduce: Function,
      args: [Function, RC::Constants.ANY, [RC::Class, RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public @async @virtual first: Function,
      args: [[RC::Class, RC::Constants.NILL]]
      return: RC::Constants.ANY


  return LeanRC::CursorInterface.initialize()
