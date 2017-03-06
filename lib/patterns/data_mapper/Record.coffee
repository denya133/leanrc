# по сути здесь надо повторить (что-то скопипастить) код из FoxxMC::Model
# так как все взаимодействие с конкретной платформой (базой)
# должно быть объявлено в конкретном CollectionMixin'е,
# в данном миксине будет платформонезависимый код.

RC = require 'RC'

# так как рекорд будет работать с простыми структурами данных в памяти, он не зависит от платформы.
# если ему надо будет взаимодействовать с платформозависимой логикой - он будет делать это через прокси, но не напрямую (как в эмбере со стором)

module.exports = (LeanRC)->
  class LeanRC::Record extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::RecordInterface

    @Module: LeanRC

    @public @virtual collection: LeanRC::CollectionInterface

    # объявлю пока здесь, чтобы не забыть
    ipoInternalRecord = @private internalRecord: Object # тип и формат хранения надо обдумать. Это инкапсулированные данные последнего сохраненного состояния из базы - нужно для функционала вычисления дельты изменений. (относительно изменений которые проведены над объектом но еще не сохранены в базе данных - хранилище.)


    ############################################################################

    # под вопросом ??????
    # @public @static schema: JoiSchema # это используется в медиаторе на входе и выходе, поэтому это надо объявить там.


    # под вопросом ??????
    @public @static parseModelName: Function, [String], -> Array
    @public @static findModelByName: Function, [String], -> Array
    @public findModelByName: Function, [String], -> Array
    @public parseModelName: Function, [String], -> Array



    # здесь не декларируются before/after хуки, потому что их использование относится сугубо к реализации, но не к спецификации интерфейса как такового.



    # под вопросом ??????
    @public updateEdges: Function, [ANY], -> ANY # any type



    # под вопросом ?????? # возможно надо это определять в сериалайзере
    @public getSnapshot: Function, [], -> Object
    @private _forClient: Function, [Object], -> Object
    @public @static serializableAttributes: Function, [], -> Object
    @public @static serializeFromBatch: Function, [Object], -> Object
    @public @static serializeFromClient: Function, [Object], -> Object
    @public serializeForClient: Function, [Object], -> Object


    ############################################################################


    @public @static parentClassNames: Function,
      default: (AbstractClass = null)->
        AbstractClass ?= @
        fromSuper = if AbstractClass.__super__?
          @parentClassNames AbstractClass.__super__.constructor
        _.uniq [].concat(fromSuper ? [])
          .concat [AbstractClass.name]

    @public @static attributes: Object,
      default: {}
      get: (__attrs)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.attributes
        __attrs[AbstractClass.name] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass["_#{AbstractClass.name}_attrs"] ? {})
        __attrs[AbstractClass.name]

    @public @static edges: Object,
      default: {}
      get: (__edges)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.edges
        __edges[AbstractClass.name] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass["_#{AbstractClass.name}_edges"] ? {})
        __edges[AbstractClass.name]

    @public @static properties: Object,
      default: {}
      get: (__props)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.properties
        __props[AbstractClass.name] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass["_#{AbstractClass.name}_props"] ? {})
        __props[AbstractClass.name]

    @public @static computeds: Object,
      default: {}
      get: (__comps)->
        AbstractClass = @
        fromSuper = if AbstractClass.__super__?
          AbstractClass.__super__.constructor.computeds
        __comps[AbstractClass.name] ?= do ->
          RC::Utils.extend {}
          , (fromSuper ? {})
          , (AbstractClass["_#{AbstractClass.name}_comps"] ? {})
        __comps[AbstractClass.name]

    @public @static attribute: Function,
      default: ->
        @attr arguments...
        return
    @public @static attr: Function,
      default: (name, schema, opts={})->
        return
    @public @static property: Function,
      default: ->
        @prop arguments...
        return
    @public @static prop: Function,
      default: (name, opts={})->
        return
    @public @static computed: Function,
      default: ->
        @comp arguments...
        return
    @public @static comp: Function,
      default: (name, opts, lambda)->
        return
    @public @static belongsTo: Function,
      default: (name, schema, opts={})->
        return
    @public @static hasMany: Function,
      default: (name, opts={})->
        return
    @public @static hasOne: Function,
      default: (name, opts={})->
        return
    @public @static new: Function,
      default: (attributes)->
        if attributes._type is "#{@moduleName()}::#{@name}"
          @super arguments...
        else
          [ModelClass] = @findModelByName attributes._type
          ModelClass?.new(attributes) ? @super arguments...

    @public @static @virtual inverseFor: Function,
      args: [String]
      return: Object # Cucumber.inverseFor 'tomato' #-> {type: App::Tomato, name: 'cucumbers', kind: 'hasMany'}
    @public @static validate: Function, # что внутри делать пока не понятно.
      default: (attribute, options)->
        return

    @public _key: String
    @public _rev: String
    @public _type: String
    @public isHidden: Boolean, {default: no}
    @public createdAt: Date
    @public updatedAt: Date
    @public id: String
    @public rev: String
    @public type: String

    @public validate: Function, [], -> RecordInterface
    # @public beforeValidate: Function, [], -> NILL
    # @public afterValidate: Function, [], -> NILL
    @public save: Function, [], -> RecordInterface
    # @public beforeSave: Function, [], -> NILL
    # @public afterSave: Function, [ANY], -> ANY # any type
    @public create: Function, [], -> RecordInterface
    # @public beforeCreate: Function, [], -> NILL
    # @public afterCreate: Function, [ANY], -> ANY # any type
    @public update: Function, [], -> RecordInterface
    # @public beforeUpdate: Function, [], -> NILL
    # @public afterUpdate: Function, [ANY], -> ANY # any type
    @public delete: Function, [], -> RecordInterface
    # @public beforeDelete: Function, [], -> NILL
    # @public afterDelete: Function, [ANY], -> ANY # any type
    @public destroy: Function, [], -> RecordInterface
    # @public beforeDestroy: Function, [], -> NILL
    # @public afterDestroy: Function, [], -> NILL

    @public @virtual attributes: Function, # метод должен вернуть список атрибутов данного рекорда.
      args: []
      return: Array
    @public @virtual clone: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual copy: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual deepCopy: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual decrement: Function,
      args: [String, [Number, RC::Constants.NILL]] #attribute, step
      return: LeanRC::RecordInterface
    @public @virtual increment: Function,
      args: [String, [Number, RC::Constants.NILL]] #attribute, step
      return: LeanRC::RecordInterface
    @public @virtual toggle: Function,
      args: [String] #attribute
      return: LeanRC::RecordInterface
    @public @virtual touch: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual updateAttribute: Function,
      args: [String, RC::Constants.ANY] #name, value
      return: LeanRC::RecordInterface
    @public @virtual updateAttributes: Function,
      args; [Object] #attributes
      return: LeanRC::RecordInterface
    @public @virtual isNew: Function,
      args: []
      return: Boolean
    @public @virtual reload: Function,
      args: []
      return: LeanRC::RecordInterface
    @public @virtual changedAttributes: Function,
      args: []
      return: Object # { isAdmin: [undefined, true], name: [undefined, 'Tomster'] }
    @public @virtual resetAttribute: Function,
      args: [String]
      return: RC::Constants.NILL
    @public @virtual rollbackAttributes: Function,
      args: []
      return: RC::Constants.NILL

    constructor: (properties) ->
      super arguments...
      console.log 'Init of Record', @constructor.name, properties

      for own k, v of properties
        do (k, v)=>
          @[k] = v

      console.log 'dfdfdf 666'


  return LeanRC::Record.initialize()
