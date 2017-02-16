

module.exports = (FoxxMC)->
  Service  = require('./Service') FoxxMC
  # ModelInterface  = require('../interfaces/model') FoxxMC
  # InternalModelInterface  = require('../interfaces/internal_model') FoxxMC
  StoreInterface = require('./interfaces/Store') FoxxMC
  {SELF, NILL, ANY, CLASS} = require('./Constants') FoxxMC

  class FoxxMC::Store extends Service
    @implements StoreInterface

    # public
    @defineAccessor String, 'defaultAdapter', '-default'

    @instanceMethod 'serialize', (modelName, id, options)->
      # eq. serializeForClient
      snapshot = @getInternalModel(modelName, id).createSnapshot()
      snapshot.serialize options

    @instanceMethod 'normalize', (modelName, payload)->
      # eq. serializeFromClient
      assert "You need to pass a model name to the store's normalize method", not _.isEmpty modelName
      assert "Passing classes to store methods has been removed. Please pass a dasherized string instead of #{FoxxMC::Utils.inspect(modelName)}", typeof modelName is 'string'
      serializer = @serializerFor modelName
      model = @modelFor modelName
      serializer.normalize model, payload

  @public defaultAdapter: String # adapter type by default ['-arangodb', '-mongodb', '-rest', '-json-api']
  @public adapterFor: Function, [modelName], -> AdapterInterface
  @public serializerFor: Function, [modelName], -> SerializerInterface
  @public modelFor: Function, [modelName], -> ModelClass

  @public create: Function, [modelName, Object], -> ModelInterface
  @public createDirectly: Function, [modelName, Object], -> ModelInterface
  @public delete: Function, [modelName, String], -> ModelInterface
  @public deleteBy: Function, [modelName, QueryObjectInterface], -> ModelInterface
  @public destroy: Function, [modelName, String], -> NILL
  @public destroyBy: Function, [modelName, QueryObjectInterface], -> NILL
  @public find: Function, [modelName, String], -> ModelInterface
  @public findBy: Function, [modelName, QueryObjectInterface], -> ModelInterface
  @public filter: Function, [modelName, QueryObjectInterface], -> CursorInterface
  @public update: Function, [modelName, String, Object], -> ModelInterface
  @public updateBy: Function, [modelName, QueryObjectInterface, Object], -> ModelInterface
  @public query: Function, [modelName, QueryObjectInterface], -> ANY
  @public forEach: Function, [modelName, Function], -> NILL
  @public map: Function, [modelName, Function], -> CursorInterface
  @public reduce: Function, [modelName, Function, ANY], -> ANY
  @public sortBy: Function, [modelName, Object], -> CursorInterface
  @public groupBy: Function, [modelName, Object], -> ANY
  @public includes: Function, [modelName, String], -> Boolean
  @public exists: Function, [modelName, QueryObjectInterface], -> Boolean
  @public length: Function, [modelName], -> Number
  @public pushInto: Function, [modelName, [Array, Object]], -> Boolean
  @public push: Function, [Object], -> Boolean # when keys are modelNames

  @public getInternalModel: Function, [type, id], -> InternalModelInterface

  # normalize converts a json payload into the normalized form that push expects.
  @public normalize: Function, [modelName, Object], -> Object # eq. serializeFromClient
  # @public serialize: Function, [modelName, String], -> Object
