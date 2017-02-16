
module.exports = (FoxxMC)->
  Interface  = require('../Interface') FoxxMC
  ModelInterface = require './model'
  StoreInterface = require './store'
  SnapshotInterface = require './snapshot'
  {SELF, NILL, ANY, CLASS} = require('../Constants') FoxxMC

  class FoxxMC::SerializerInterface extends Interface
    @public store: StoreInterface

    @public @virtual normalize: Function
    ,
      [
        typeClass: CLASS
      ,
        hash: Object
      ]
    , ->
      return: Object
    @public @virtual normalizeResponse: Function
    ,
      [
        store: StoreInterface
      ,
        primaryModelClass: ModelInterface
      ,
        payload: Object
      ,
        id: String
      ,
        requestType: String
      ]
    , ->
      return: Object
    @public @virtual serialize: Function
    ,
      [
        snapshot: SnapshotInterface
      ,
        options: Object
      ]
    , ->
      return: Object

  FoxxMC::SerializerInterface.initialize()
