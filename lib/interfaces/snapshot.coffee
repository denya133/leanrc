
module.exports = (FoxxMC)->
  Interface  = require('../Interface') FoxxMC
  ModelInterface = require './model'
  InternalModelInterface = require './internal_model'
  {SELF, NILL, ANY, CLASS} = require('../Constants') FoxxMC

  class FoxxMC::SnapshotInterface extends Interface
    @public id:                 String
    @public adapterOptions:     Object
    @public modelName:          String
    @public record:             ModelInterface
    @public type:               CLASS
    @private attributes:        Object
    @private internalModel:     InternalModelInterface
    @private changedAttributes: Object

    @public constructor: Function
    ,
      [
        internalModel: InternalModelInterface
      ,
        options: Object
      ]
    , ->
      return: SELF

    @public attr: Function, [keyName: String], -> return: ANY
    @public attributes: Function, [], -> return: Object
    @public belongsTo: Function # реализация под вопросом
    ,
      [
        keyName: String
      ,
        options: Object
      ]
    , ->
      return: [SnapshotInterface, String, NILL]
    @public changedAttributes: Function, [], -> return: Object
    @public eachAttribute: Function
    ,
      [
        lambda: Function
      ,
        binding: Object
      ]
    , ->
      return: NILL
    @public eachRelationship: Function
    ,
      [
        lambda: Function
      ,
        binding: Object
      ]
    , ->
      return: NILL
    @public hasMany: Function # реализация под вопросом
    ,
      [
        keyName: String
      ,
        options: Object
      ]
    , ->
      return: [Array, NILL]
    @public serialize: Function, [options: Object], -> return: Object

  FoxxMC::SnapshotInterface.initialize()
