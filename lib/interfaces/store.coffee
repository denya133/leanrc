

module.exports = (FoxxMC)->
  Interface  = require('../Interface') FoxxMC
  AdapterInterface = require './adapter'
  SerializerInterface = require './serializer'
  ModelInterface = require './model'
  InternalModelInterface = require './internal_model'
  QueryInterface = require './query'
  CursorInterface = require './cursor'
  {SELF, NILL, ANY, CLASS} = require('../Constants') FoxxMC

  class FoxxMC::StoreInterface extends Interface
    @public defaultAdapter: String # adapter type by default ['-arangodb', '-mongodb', '-rest', '-json-api']
    @public adapterFor: Function
    , [modelName: String]
    , -> return: AdapterInterface
    @public serializerFor: Function
    , [modelName: String]
    , -> return: SerializerInterface
    @public modelFor: Function
    , [modelName: String]
    , -> return: CLASS

    @public create: Function
    ,
      [
        modelName: String
      ,
        data: Object
      ]
    , -> return: ModelInterface
    @public createDirectly: Function
    ,
      [
        modelName: String
      ,
        data: Object
      ]
    , -> return: ModelInterface
    @public delete: Function
    ,
      [
        modelName: String
      ,
        id: String
      ]
    , -> return: ModelInterface
    @public deleteBy: Function
    ,
      [
        modelName: String
      ,
        query: QueryInterface
      ]
    , -> return: ModelInterface
    @public destroy: Function
    ,
      [
        modelName: String
      ,
        id: String
      ]
    , -> return: NILL
    @public destroyBy: Function
    ,
      [
        modelName: String
      ,
        query: QueryInterface
      ]
    , -> return: NILL
    @public find: Function
    ,
      [
        modelName: String
      ,
        id: String
      ]
    , -> return: ModelInterface
    @public findBy: Function
    ,
      [
        modelName: String
      ,
        query: QueryInterface
      ]
    , -> return: ModelInterface
    @public filter: Function
    ,
      [
        modelName: String
      ,
        query: QueryInterface
      ]
    , -> return: CursorInterface
    @public update: Function
    ,
      [
        modelName: String
      ,
        id: String
      ,
        data: Object
      ]
    , -> return: ModelInterface
    @public updateBy: Function
    ,
      [
        modelName: String
      ,
        query: QueryInterface
      ,
        data: Object
      ]
    , -> return: ModelInterface
    @public query: Function
    ,
      [
        modelName: String
      ,
        query: QueryInterface
      ]
    , -> return: ANY
    @public forEach: Function
    ,
      [
        modelName: String
      ,
        lambda: Function
      ]
    , -> return: NILL
    @public map: Function
    ,
      [
        modelName: String
      ,
        lambda: Function
      ]
    , -> return: CursorInterface
    @public reduce: Function
    ,
      [
        modelName: String
      ,
        lambda: Function
      ,
        initial: ANY
      ]
    , -> return: ANY
    @public sortBy: Function
    ,
      [
        modelName: String
      ,
        definitions: Object
      ]
    , -> return: CursorInterface
    @public groupBy: Function
    ,
      [
        modelName: String
      ,
        definitions: Object
      ]
    , -> return: ANY
    @public includes: Function
    ,
      [
        modelName: String
      ,
        id: String
      ]
    , -> return: Boolean
    @public exists: Function
    ,
      [
        modelName: String
      ,
        query: QueryInterface
      ]
    , -> return: Boolean
    @public length: Function
    , [modelName: String]
    , -> return: Number
    @public pushInto: Function
    ,
      [
        modelName: String
      ,
        data: [Array, Object]
      ]
    , -> return: Boolean
    @public push: Function
    , [data: Object]
    , -> return: Boolean # when keys are modelNames

    @public getInternalModel: Function
    ,
      [
        modelName: String
      ,
        id: String
      ]
    , -> return: InternalModelInterface

    # normalize converts a json payload into the normalized form that push expects.
    @public normalize: Function
    ,
      [
        modelName: String
      ,
        payload: Object
      ]
    , -> return: Object # eq. serializeFromClient
    @public serialize: Function
    ,
      [
        modelName: String
      ,
        id: String
      ,
        options: Object
      ]
    , -> return: Object # eq. serializeForClient

  FoxxMC::StoreInterface.initialize()
