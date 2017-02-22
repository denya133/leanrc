

module.exports = (FoxxMC)->
  CoreObject  = require('./CoreObject') FoxxMC
  ModelInterface  = require('../interfaces/model') FoxxMC
  InternalModelInterface  = require('../interfaces/internal_model') FoxxMC
  SnapshotInterface = require('./interfaces/snapshot') FoxxMC
  {SELF, NILL, ANY, CLASS} = require('./Constants') FoxxMC

  class FoxxMC::Snapshot extends CoreObject
    @implements SnapshotInterface
    ipoAttributes         = Symbol 'attributes'
    ipoInternalModel      = Symbol 'internalModel'
    ipoChangedAttributes  = Symbol 'changedAttributes'

    # public
    @defineAccessor String,           'id'
    @defineAccessor Object,           'adapterOptions'
    @defineAccessor String,           'modelName'
    @defineAccessor ModelInterface,   'record'
    @defineAccessor CLASS,            'type'

    # private
    @defineAccessor Object,           ipoAttributes
    @defineAccessor InternalModelInterface, ipoInternalModel
    @defineAccessor Object,           ipoChangedAttributes

    @instanceMethod 'attr', (keyName)->
      if keyName of @_attributes
        return @_attributes[keyName]

      throw new FoxxMC::Error "Model '#{FoxxMC::Utils.inspect @record}' has no attribute named '#{keyName}' defined."

    @instanceMethod 'attributes', ->
      FoxxMC::Utils.copy @_attributes

    @instanceMethod 'belongsTo', (keyName, options)->
      # реализация под вопросом

    @instanceMethod 'changedAttributes', ->
      vChangedAttributes = {}
      vChangedAttributeKeys = Object.keys @[ipoChangedAttributes]
      for vKey in vChangedAttributeKeys
        do (vKey)=>
          vChangedAttributes[vKey] = FoxxMC::Utils.copy @[ipoChangedAttributes][vKey]
      vChangedAttributes

    @instanceMethod 'eachAttribute', (lambda, binding)->
      @record.eachAttribute lambda, binding

    @instanceMethod 'eachRelationship', (lambda, binding)->
      @record.eachRelationship lambda, binding

    @instanceMethod 'hasMany', (keyName, options)->
      # реализация под вопросом

    @instanceMethod 'serialize', (options)->
      @record.store.serializerFor(@modelName).serialize @, options

    constructor: (internalModel, options = {})->
      @super('constructor') Snapshot, []
      @[ipoAttributes] = {}
      record = internalModel.getRecord()
      @record = record
      record.eachAttribute (keyName) =>
        @[ipoAttributes][keyName] = record[keyName]
      {
        @id
        @type
      } = internalModel
      @modelName = internalModel.type.modelName
      {
        @adapterOptions
        @include
      } = options
      @[ipoInternalModel] = internalModel
      @[ipoChangedAttributes] = record.changedAttributes()


  FoxxMC::Snapshot.initialize()
