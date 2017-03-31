
RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::CursorInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public setRecord: Function,
      args: [RC::Class]
      return: ArangoCursorInterface

    @public toArray: Function,
      args: [[RC::Class. RC::Constants.NILL]]
      return: Array

    @public next: Function,
      args: [[RC::Class. RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public hasNext: Function,
      args: []
      return: Boolean

    @public close: Function,
      args: []
      return: RC::Constants.NILL

    @public count: Function,
      args: []
      return: Number

    @public forEach: Function,
      args: [Function, [RC::Class. RC::Constants.NILL]]
      return: RC::Constants.NILL

    @public map: Function,
      args: [Function, [RC::Class. RC::Constants.NILL]]
      return: Array

    @public filter: Function,
      args: [Function, [RC::Class. RC::Constants.NILL]]
      return: Array

    @public find: Function,
      args: [Function, [RC::Class. RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public compact: Function,
      args: [[RC::Class. RC::Constants.NILL]]
      return: Array

    @public reduce: Function,
      args: [Function, RC::Constants.ANY, [RC::Class. RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public first: Function,
      args: [[RC::Class. RC::Constants.NILL]]
      return: RC::Constants.ANY


  return LeanRC::CursorInterface.initialize()
