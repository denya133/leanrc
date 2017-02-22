

module.exports = (FoxxMC)->
  Service  = require('./Service') FoxxMC
  # ModelInterface  = require('../interfaces/model') FoxxMC
  # InternalModelInterface  = require('../interfaces/internal_model') FoxxMC
  StoreInterface = require('./interfaces/Store') FoxxMC
  {SELF, NILL, ANY, CLASS} = require('./Constants') FoxxMC

  class FoxxMC::Store extends Service
    @implements StoreInterface
    ipmModelFactoryFor    = Symbol 'modelFactoryFor'
    ipmModelForMixin      = Symbol 'modelForMixin'
    ipmInternalModelForId = Symbol 'internalModelForId'
    ipmGenerateId         = Symbol 'generateId'

    # public
    # adapter type by default ['-arangodb', '-mongodb', '-rest', '-json-api']
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

    @instanceMethod 'getInternalModel', (modelName, id)->
      @[ipmInternalModelForId] modelName, id

    @instanceMethod 'adapterFor', (modelName)->
      assert "You need to pass a model name to the store's adapterFor method", not _.isEmpty modelName
      assert "Passing classes to store.adapterFor has been removed. Please pass a dasherized string instead of #{FoxxMC::Utils.inspect(modelName)}", typeof modelName is 'string'

      normalizedModelName = normalizeModelName modelName
      @_instanceCache.get 'adapter', normalizedModelName

    @instanceMethod 'serializerFor', (modelName)->
      assert "You need to pass a model name to the store's serializerFor method", not _.isEmpty modelName
      assert "Passing classes to store.serializerFor has been removed. Please pass a dasherized string instead of #{FoxxMC::Utils.inspect(modelName)}", typeof modelName is 'string'

      normalizedModelName = normalizeModelName modelName
      @_instanceCache.get 'serializer', normalizedModelName

    @instanceMethod 'modelFor', (modelName)->
      assert "You need to pass a model name to the store's modelFor method", not _.isEmpty modelName
      assert "Passing classes to store methods has been removed. Please pass a dasherized string instead of #{FoxxMC::Utils.inspect(modelName)}", typeof modelName is 'string'

      factory = @[ipmModelFactoryFor] modelName
      unless factory
        factory = @[ipmModelForMixin] modelName
      unless factory
        throw new FoxxMC::Error "No model was found for '#{modelName}'"
      factory.modelName = factory.modelName ? normalizeModelName modelName
      return factory

    @instanceMethod ipmModelFactoryFor, (modelName)->
      assert "You need to pass a model name to the store's modelFactoryFor method", not _.isEmpty modelName
      assert "Passing classes to store methods has been removed. Please pass a dasherized string instead of #{FoxxMC::Utils.inspect(modelName)}", typeof modelName is 'string'

      normalizedModelName = normalizeModelName modelName
      owner = getOwner @
      owner._lookupFactory "model:#{normalizedModelName}"

    @instanceMethod ipmModelForMixin, (modelName)->
      normalizedModelName = normalizeModelName modelName
      owner = getOwner @
      mixin = owner._lookupFactory "mixin:#{normalizedModelName}"
      if mixin
        owner.register "model:#{normalizedModelName}", class extends FoxxMC::Model
          @include mixin
      @[ipmModelFactoryFor] normalizedModelName

    @instanceMethod ipmInternalModelForId, (modelName, id)->
      modelClass = @modelFor modelName
      idToRecord = @typeMapFor(modelClass).idToRecord
      internalModel = idToRecord[id]

      unless internalModel?
         internalModel = @buildInternalModel modelClass, id

    @instanceMethod 'create', (modelName, data)->
      assert "You need to pass a model name to the store's create method", not _.isEmpty modelName
      assert "Passing classes to store methods has been removed. Please pass a dasherized string instead of #{FoxxMC::Utils.inspect(modelName)}", typeof modelName is 'string'

      modelClass = @modelFor modelName
      properties = FoxxMC::Utils.copy(data) ? {}

      if _.isEmpty properties.id
        properties.id = @[ipmGenerateId] modelName, properties

      internalModel = @buildInternalModel modelClass, properties.id
      record = internalModel.getRecord()
      record.setProperties properties

      record

  # @public defaultAdapter: String # adapter type by default ['-arangodb', '-mongodb', '-rest', '-json-api']
  # @public adapterFor: Function, [modelName], -> AdapterInterface
  # @public serializerFor: Function, [modelName], -> SerializerInterface
  # @public modelFor: Function, [modelName], -> ModelClass

  # @public create: Function, [modelName, Object], -> ModelInterface
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
  @public unload: Function, [modelName, id], -> NILL
  @public unloadBy: Function, [modelName, query], -> NILL

  # @public getInternalModel: Function, [type, id], -> InternalModelInterface

  # normalize converts a json payload into the normalized form that push expects.
  # @public normalize: Function, [modelName, Object], -> Object # eq. serializeFromClient
  # @public serialize: Function, [modelName, String], -> Object
