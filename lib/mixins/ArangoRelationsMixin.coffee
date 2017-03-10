# этот миксин должен инклудиться в классах унаследованных от рекорда.
_             = require 'lodash'
joi           = require 'joi'
{ db }        = require '@arangodb'
qb            = require 'aqb'
inflect       = require('i')()
RC            = require 'RC'

SIMPLE_TYPES  = ['string', 'number', 'boolean', 'date', 'object']


module.exports = (LeanRC)->
  class LeanRC::ArangoRelationsMixin extends RC::Mixin
    @inheritProtected()
    @implements LeanRC::RelationsMixinInterface

    @Module: LeanRC

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

    @public @static property: Function,
      default: ->
        @prop arguments...
        return

    @public @static prop: Function,
      default: (name, opts={})->
        opts.serializeFromClient ?= (value)-> value
        opts.serializeForClient ?= (value)-> value
        {
          attr, refKey, type, model,
          definition, bindings, valuable, valuableAs,
          sortable, groupable, filterable,
          serializeFromClient, serializeForClient
        } = opts
        unless definition? and type? and model?
          return throw new Error '`definition`, `type` and `model` options is required'
        if valuable?
          schema = =>
            unless model in SIMPLE_TYPES
              [ModelClass, vModel] = @findModelByName model
            else
              vModel = model
            return if vModel in ['string', 'boolean', 'number']
              joi[vModel]().empty(null).optional()
            else if vModel is 'date'
              joi.string().empty(null).optional()
            else if type is 'item' and vModel is 'object'
              joi.object().empty(null).optional()
            else if type is 'array' and vModel is 'object'
              joi.array().items joi.object().empty(null).optional()
            else if type is 'item' and not /.*[.].*/.test valuable
              ModelClass.schema()
            else if type is 'item' and /.*[.].*/.test valuable
              [..., prop_name] = valuable.split '.'
              ModelClass.attributes[prop_name]
            else if type is 'array' and not /.*[.].*/.test valuable
              joi.array().items ModelClass.schema()
            else if type is 'array' and /.*[.].*/.test valuable
              [..., prop_name] = valuable.split '.'
              joi.array().items ModelClass.attributes[prop_name]
        else
          schema = -> {}
        opts.schema ?= schema
        @["_#{@name}_props"] ?= {}
        model ?= inflect.singularize inflect.underscore name
        unless @["_#{@name}_props"][name]
          @["_#{@name}_props"][name] = opts
          switch type
            when 'item'
              @defineProperty name,
                get: ->
                  ModelClass = null
                  unless model in SIMPLE_TYPES
                    [ModelClass, vModel] = @findModelByName model
                  else
                    vModel = model
                  if (item = @["__#{name}"])?
                    if vModel in SIMPLE_TYPES
                      return serializeForClient item
                    if @[refKey ? '_key'] is item[refKey ? '_key']
                     return @
                    ModelClass.new item
                  else if @["__#{name}"] is undefined
                    _snapshot = @getSnapshot()
                    _snapshot._id = "
                      #{@constructor.collectionNameInDB()}/#{_snapshot._key}
                    "
                    _bindings = extend {}, (bindings ? {}), {doc: _snapshot}
                    _query = "
                        LET doc = (RETURN @doc)[0]
                        RETURN #{definition}
                      "
                    console.log '???????????????????????KKKKKKKKKKKKKKKKKKKKKkk _query, _bindings', _query, _bindings
                    item = new Cursor()
                      .setCursor db._query _query, _bindings
                      .currentUser @currentUser
                      .next()
                    @["__#{name}"] = item
                    if vModel in SIMPLE_TYPES
                      return serializeForClient item
                    if @[refKey ? '_key'] is item[refKey ? '_key']
                     return @
                    ModelClass.new item
                  else
                    null
                set: (value)->
                  if model in SIMPLE_TYPES
                    @["__#{name}"] = serializeFromClient value
                    value
                  else
                    if (id = value?[refKey ? '_key'])
                      @[attr ? "#{name}Id"] = id
                      @["__#{name}"] = value
                      value
                    else
                      @[attr ? "#{name}Id"] = null
                      @["__#{name}"] = null
                      null
            when 'array'
              @defineProperty name,
                get: ->
                  ModelClass = null
                  unless model in SIMPLE_TYPES
                    [ModelClass] = @findModelByName model
                    _bindings = extend {}, bindings
                    if _bindings.docKey is 'docKey'
                      _bindings.docKey = @_key
                    if _bindings.docId is 'docId'
                      _bindings.docId = @_id
                  console.log '$$$$$$$$$$$$$$$$$$$$$$$$$$$$ hasMany.query definition, bindings', definition, _bindings
                  new Cursor(ModelClass)
                    .setCursor db._query definition, _bindings
                    .currentUser @currentUser
            else
              throw new Error 'type must be `item` or `array` only'
        else
          throw new Error "prop `#{name}` has been defined previously"
        return

    @public @static belongsTo: Function,
      default: (name, opts={})->
        opts.attr ?= "#{name}Id"
        opts.refKey ?= '_key'
        @attr opts.attr, opts.schema, opts
        if opts.attr isnt "#{name}Id"
          @prop "#{name}Id",
            type: 'item'
            model: 'string'
            attr: opts.attr
            schema: -> opts.schema
            definition: "(doc.#{opts.attr})"
            valuable: "#{name}Id"
            filterable: "#{name}Id"
            serializeFromClient: opts.serializeFromClient
            serializeForClient: opts.serializeForClient
        opts.type = 'item'
        opts.model ?= inflect.singularize inflect.underscore name
        [vFullModelName, vModel] = @parseModelName opts.model
        # console.log '?????????????? in belongsTo', vFullModelName, vModel
        opts.collection ?= inflect.pluralize inflect.underscore vModel
        unless opts.through
          opts.definition ?= "(#{qb.for("#{vModel}_item")
            .in(@collectionNameInDB opts.collection)
            .filter(qb.eq qb.ref("doc.#{opts.attr}"), qb.ref("#{vModel}_item.#{opts.refKey}"))
            .limit(1)
            .return(qb.ref "#{vModel}_item")
            .toAQL()})[0]
          "
        else
          opts.definition ?= "(
            FOR #{vModel}_item
            IN 1..1
            #{opts.through[1].as} doc._id #{@collectionNameInDB opts.through[0]}
            LIMIT 0, 1
            RETURN #{vModel}_item
          )[0]"
        unless opts.model in SIMPLE_TYPES
          opts.methods = ["#{vFullModelName}.find"]
        @prop name, opts
        return

    @public @static hasMany: Function,
      default: (name, opts={})->
        opts.refKey ?= '_key'
        opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
        opts.type = 'array'
        opts.model ?= inflect.singularize inflect.underscore name
        [vFullModelName, vModel] = @parseModelName opts.model
        opts.collection ?= inflect.pluralize inflect.underscore vModel
        unless opts.through
          if opts.refKey is '_key'
            opts.bindings = docKey: 'docKey'
            binding = '@docKey'
          else
            opts.bindings = docId: 'docId'
            binding = '@docId'
          opts.definition ?= "#{qb.for("#{vModel}_array")
            .in(@collectionNameInDB opts.collection)
            .filter(qb.eq qb.expr(binding), qb.ref("#{vModel}_array.#{opts.inverse}"))
            .return(qb.ref "#{vModel}_array")
            .toAQL()}
          "
        else
          opts.bindings = docId: '@docId'
          opts.definition ?= "
            FOR #{vModel}_array
            IN 1..1
            #{opts.through[1].as} @docId #{@collectionNameInDB opts.through[0]}
            RETURN #{vModel}_array
          "
        @prop name, opts
        return

    @public @static hasOne: Function,
      default: (name, opts={})->
        opts.refKey ?= '_key'
        opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
        opts.type = 'item'
        opts.model ?= inflect.singularize inflect.underscore name
        [vFullModelName, vModel] = @parseModelName opts.model
        [moduleName] = vFullModelName.split '::'
        vCollectionName = "#{inflect.underscore moduleName}_#{inflect.pluralize vModel}"
        opts.definition ?= "(#{qb.for("#{vModel}_item")
          .in(vCollectionName)
          .filter(qb.eq qb.ref("doc.#{opts.refKey}"), qb.ref("#{vModel}_item.#{opts.inverse}"))
          .limit(1)
          .return(qb.ref "#{vModel}_item")
          .toAQL()})[0]
        "
        @prop name, opts
        return

    # Cucumber.inverseFor 'tomato' #-> {type: App::Tomato, name: 'cucumbers', kind: 'hasMany'} - в этом ли виде отдавать результат
    @public @static inverseFor: Function,
      default: (asAttrName)->
        vhResult = {}
        # @properties[asAttrName] # что дальше делать пока не понятно
        return vhResult


  return LeanRC::ArangoRelationsMixin.initialize()
