_             = require 'lodash'
joi           = require 'joi'
{ db }        = require '@arangodb'
qb            = require 'aqb'
crypto        = require '@arangodb/crypto'
inflect       = require('i')()
fs            = require 'fs'


SIMPLE_TYPES  = ['string', 'number', 'boolean', 'date', 'object']

###
 надо смотреть примеры реального кода в папке `src/models` и документацию в
 http://apidock.com/rails/v4.2.7/ActiveRecord/Base
 http://rusrails.ru/active-record-basics
 http://rusrails.ru/active-record-query-interface
 http://rusrails.ru/active-record-validations
 http://rusrails.ru/active-record-callbacks
 ... - можно и многие другие по Rails т.к. многие методы модели работают идентичным способом.
###

###
Model = require '../lib/model'
class Tomato extends Model
  @attr 'title',        joi.string().empty(null) # определяем атрибут объекта
  @attr 'description',  joi.string().empty(null), sortable: yes, filterable: yes, groupable: yes

  @hasMany 'accounts', inverse: 'kindId' # определяем релейшен hasMany типа 'accounts' - для того, чтобы указать из какого атрибута в инверсном объекте брать данные inverse: 'kindId'
  @hasOne 'kind', model: 'onions', inverse: 'tomatoId' # похож на hasMany, так же является парным к belongsTo, но для связей 1:1

  # Возможно includes стоит все-таки заиспользовать и указывать там в массиве имена computed свойств,
  # которые должны быть вычислены сразу (в этом же запросе)
  # т.е. по умолчанию не делать лишней обработки на каждом запросе.
  @belongsTo 'category',    joi.string().required(), # belongsTo внутри должна вызывать @attr и @prop - definition для prop она же должна сконструировать и передать.
    model: 'account_operation_type'
    # definition: '...' # если не определено, belongsTo сам построит, если объявлено, то сразу будет передано в @prop
    valuable: 'category.title'
    sortable: 'category.title' # говорит о том, можно ли сортировать по этому вычисляемому проперти, если можно то как
    filterable: 'category.title' # говорит о том, можно ли фильтровать по этому вычисляемому проперти, если можно то как
    groupable: 'category.title' # говорит о том, можно ли группировать по этому вычисляемому проперти, если можно то как
    # attr: 'categoryId'
    # refKey: '_key'
  @belongsTo 'currency',    joi.string().required()
  @belongsTo 'transaction', joi.string().required(), model: 'account_transaction'

  # если не был указан в includes, он не будет вычисляться в момент получения объекта account_operation, но в геттере будет заиспользован difinition из опций и объект будет получен отдельным запросом.
  @prop 'cat', # joi-схему не передаем, т.к. это вычисляемое значение и сохраняться в документе оно не будет. joi-схему можно вычислить через указанные опции
    type: 'item' # item or array
    model: 'account_operation_type' # any model name or simple type ['string', 'number', 'boolean', 'date']
    collections: read: ['account_operation_types'] # если в подзапросе идет чтение из каких то коллекций кроме целевой `model` - Это нужно чтобы выставить read-локи
    definition: "(#{qb.for('operation_type')
      .in(@collectionNameInDB 'account_operation_types')
      .filter(qb.eq qb.ref('doc.categoryId'), qb.ref('operation_type._key'))
      .limit(1)
      .return(qb.ref 'operation_type')
      .toAQL()})[0]"
    valuable: 'cat' # говорит о том, можно ли сериализовывать значение вычисляемого проперти, если можно то как
    valuableAs: 'catty' # говорит о том, под каким ключем сериализовывать проперти при отправке в браузер
    sortable: 'cat.title' # говорит о том, можно ли сортировать по этому вычисляемому проперти, если можно то как
    filterable: 'cat.title' # говорит о том, можно ли фильтровать по этому вычисляемому проперти, если можно то как
    groupable: 'cat.title' # говорит о том, можно ли группировать по этому вычисляемому проперти, если можно то как
    attr: 'categoryId'

  @prop 'cats',
    type: 'array'
    model: 'account_operation_type'
    definition: "(#{qb.for('operation_type')
      .in(@collectionNameInDB 'account_operation_types')
      .filter(qb.eq qb.ref('doc.categoryId'), qb.ref('operation_type._key'))
      .return(qb.ref 'operation_type')
      .toAQL()})"
    valuable: 'cats[*].title' # если вычисляемое свойство содержит массив, то в valuable можно указать либо массив целиком `cats`, либо деструктуризацию `cats[*].title` - что эквивалентно cats.mapBy 'title'
    attr: 'categoryId'

  @collectionName: ()-> 'cucumbers' # задаем явным образом если модель должна работать с абсолютно другой коллекцией в базе данных - не зависящей от имени модели.

  # если в методе экземпляра класса идет работа с коллекцией в базе данных (чтение, запись), то надо сделать описание этого, для механизма конструирующего локи на базе для транцикции
  ```
    afterCreateMethods: ()-> ['::recordHasBeenChanged'] # т.к. внутри afterCreate метода экземпляра идет работа с @recordHasBeenChanged методом тоже экземпляра этого же класса
    afterCreateCollections: ()->
      {}
    afterCreate: (data)->
      @recordHasBeenChanged 'createdObject', data
      data

    @createMethods: ['.new', '::save'] # '.new' - т.к. вызывается метод класса, '::save' - т.к. вызывается метод экземпляра класса
    @createCollections: ()-> # может быть ничего не указано, если непосредственно внутри метода нет работы с конкретной коллекцией
      {}
    @create: (attributes)->
      record = @new attributes
      record.save()

    @resetAttrMethods: ()-> ['Account.new', 'TransactionsController::save'] # перед '.' или '::' в полной записи может идти имя класса, если оно отличается от текущего
    @resetAttrCollections: ()->
      {}
    @resetAttr: (attributes)->
      record = Account.new attributes
      transactions = record.transactions
      transactions.forEach (transaction)->
        transaction.some_attr += 1
        transaction.save()

    recordHasBeenChangedMethods: ()-> [] # может быть ничего не указано, если методы других классов или инстансов классов не вызываются
    recordHasBeenChangedCollections: ()-> # указываем '_queues' лок на чтение и '_jobs' лок на запись, тк. queues.get('signals').push внутри работает с этими коллекциями.
      read: ['_queues'], write: ['_jobs']
    recordHasBeenChanged: (signal, data)->
      console.log '%%%%%%%%%%%%%%%%%%% recordHasBeenChanged data', data
      queues  = require '@arangodb/foxx/queues'
      {db}    = require '@arangodb'
      {cleanCallback} = require('./utils/cleanConfig') FoxxMC
      mount = module.context.mount

      queues.get('signals').push(
        {mount: mount, name: 'send_signal'}
        {
          mount:      mount.replace '/', ''
          db:         db._name()
          signal:     signal
          modelName:  data._type
          record_id:  data._key
        }
        {
          success: cleanCallback "success: `send_signal`"
          failure: cleanCallback "failure: `send_signal`"
        }
      )
      return
  ```

  # т.к. Model унаследован от CoreObject мы можем обявить звенья для цепочек и указать какие методы экземпляра будут преобразованы в цепи
  ```
    @beforeHook 'beforeVerify', only: ['verify']
    @afterHook 'afterVerify', only: ['verify']

    @beforeHook 'beforeCount', only: ['count']
    @afterHook 'afterCount', only: ['count']

    @chains ['verify', 'count'] # если в модели унаследованной от Model надо объявить цепи для методов

    constructor: () -> # именно в конструкторе надо через методы beforeHook и afterHook объявить методы инстанса класса, которые будут использованы в качестве звеньев цепей
      super

    beforeVerify: ()->

    beforeCount: ()->

    afterVerify: (data)->
      data

    afterCount: (data)->
      data
  ```

  # так же в модели можно задефайнить машину состояний - управляющий код для ее работы реализован в CoreObject
  @StateMachine 'default', ()->
    <...>

  # Со всеми остальными методами класса и методами экземпляра класса Model лучше ознакомитсья самостоятельно ниже по коду
  # их логика работы довольно проста для понимания. Многие из них реализованы по аналогии с ActiveRecord::Base из Rails

  # Помимо прочего в модели можно указать кастомные фильтры, которые могут быть применены, при запросах из браузера на произвольную фильтрацию
  ```
    @customFilters ()->
      _pack_valid:
        '{=}': ()=>
          date_now = new Date().toISOString()
          condition: "
            (doc._type != 'adz' || doc._type == 'adz' && doc.packId IN (
              FOR pack IN #{@collectionNameInDB 'packs'}
                FILTER pack._owner == doc._owner
                FILTER pack.isActivated == true &&
                  pack.activatedSince <= @_pack_valid_date_now &&
                  @_pack_valid_date_now < pack.activatedTill
                RETURN pack._key
            ))
          "
          bindings:
            _pack_valid_date_now: date_now
      _adz_owner:
        '{!}': ([ownerId])->
          condition: "(doc._type == 'adz' && doc._owner != @_adz_owner || doc._type != 'adz')"
          bindings:
            _adz_owner: ownerId
      _not_viewed_by:
        '{=}': ([userId])=>
          condition: "
            (doc._type != 'adz' || doc._type == 'adz' && doc._id NOT IN (
              FOR vote IN #{@collectionNameInDB 'publication_user_votes'}
              FILTER vote.rate >= @rate && vote._from == doc._id && vote._to == @_to
              LIMIT 0, 1
              RETURN vote._from
            ))
          "
          bindings:
            rate: 0
            _to: "#{@collectionNameInDB 'users'}/#{userId}"

  ```

  # Delayed method call
  # (это будет асинхронное выполнение в другом потоке - не надо ждать от этого метода возвращаемое значение)
  ```
    class Tomato extends Model
      k: (g)->
        console.log 'call k() in Tomato::k', @, g
      @hh: (g)->
        console.log 'call @hh() in Tomato.hh', @name, g

    tomato = Tomato.new(id: '98607650757567886')

    tomato.delay().k(3)
    Tomato.delay().hh(88)

    # and with options

    tomato.delay
      queue: '<queue name different from `delayed_jobs`>'
      backOff: <some value>
      maxFailures: <some value>
      schema: <some value>
      preprocess: <some value>
      repeatTimes: <some value>
      repeatUntil: <some value>
      repeatDelay: <some value>
      delayUntil: <some value>
    .k(3)
    Tomato.delay
      queue: '<queue name different from `delayed_jobs`>'
      backOff: <some value>
      maxFailures: <some value>
      schema: <some value>
      preprocess: <some value>
      repeatTimes: <some value>
      repeatUntil: <some value>
      repeatDelay: <some value>
      delayUntil: <some value>
    .hh(88)
  ```

  # Current chains flow
    * Создание документа
    beforeSave
    beforeValidate
    afterValidate
    beforeCreate
    afterCreate
    afterSave

    * Обновление документа
    beforeSave
    beforeValidate
    afterValidate
    beforeUpdate
    afterUpdate
    afterSave

    * Удаление объекта (сокрытие)
    beforeDelete
    afterDelete

  # Список методов класса
    @schema
    @collectionName
    @collectionNameInDB
    @chains
    @getLocksFor

    @attr
    @prop
    @belongsTo
    @hasMany
    @hasOne

    @query
    @includes # пока не реализован
    @distinct
    @select
    @from
    @joins
    @where
    @group
    @having
    @sort
    @limit
    @pluck
    @count
    @avg
    @min
    @max
    @sum
    @all

    @delay

    @attributes
    @find
    @first
    @last
    @find_by
    @forEach
    @map
    @reduce
    @find_by_aql

    @create
    @delete
    @destroy # пока не реализован
    @delete_all
    @destroy_all # пока не реализован
    @exists
    @update
    @update_all

  # Список методов экземпляра класса
    beforeSave
    afterSave
    beforeCreate
    afterCreate
    beforeUpdate
    afterUpdate
    beforeDelete
    afterDelete

    recordHasBeenChanged
    updateEdges

    delay

    attributes
    properties
    clone # пока не реализован
    copy # пока не реализован
    create
    deep_copy # пока не реализован
    decrement
    delete
    destroy # пока не реализован
    increment
    isNew
    reload
    getSnapshot
    _forClient
    serializeForClient
    validate
    save
    toggle
    touch
    update
    update_attribute
    update_attributes

###
module.exports = (FoxxMC)->
  uuid          = require('./utils/uuid') FoxxMC
  extend        = require('./utils/extend') FoxxMC
  Cursor        = require('./Cursor') FoxxMC
  Query         = require('./Query') FoxxMC
  CoreObject    = require('./CoreObject') FoxxMC

  class FoxxMC::Model extends CoreObject
    @["_#{@name}_customFilters"] = {}

    @schema:        ()->
      joi.object @_attrs()

    @customFilters: (statement)->
      if statement.constructor is Object
        config = statement
      else if statement.constructor is Function
        config = statement.apply @, []
      @["_#{@name}_customFilters"] ?= {}
      @["_#{@name}_customFilters"] = extend {}, @["_#{@name}_customFilters"], config
      return

    @_customFilters: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @_customFilters AbstractClass.__super__.constructor
      extend {}
      , (fromSuper ? {})
      , (AbstractClass["_#{AbstractClass.name}_customFilters"] ? {})

    @_parentClassesNames: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @_parentClassesNames AbstractClass.__super__.constructor
      _.uniq [].concat(fromSuper ? [])
        .concat [AbstractClass.name]

    @collectionName: ()->
      # console.log '!!!!!!!!!!!!$$$$$$$$$$$$$$ @collectionName', @name, @__super__?.constructor?.name
      firstClassName = _.first _.remove @_parentClassesNames(), (name)->
        not (/Mixin$/.test(name) or name in ['CoreObject', 'Model'])
      inflect.pluralize inflect.underscore firstClassName

    @collectionNameInDB: (name = null)->
      # console.log '!!!!!!!!!!!!$$$$$$$$$$$$$$ @collectionNameInDB', @name, name, @__super__?.constructor?.name
      @Module.context.collectionName name ? @collectionName()

    @collectionPrefix: ()->
      @Module.context.collectionPrefix

    constructor: (snapshot, currentUser=null) ->
      console.log 'Init of Model', snapshot

      super

      for own k, v of snapshot
        do (k, v)=>
          @[k] = v

      @__currentUser = currentUser

      console.log 'dfdfdf 666'
      # return

    @getLocksFor: (keys, processedMethods = [])->
      unless Array.isArray keys
        keys = [keys]
      hash = crypto.sha1 'Model|' + String keys
      @locks["#{@name}|#{hash}"] ?= do =>
        collections = @super('getLocksFor') Model, keys, processedMethods

        for own key, value of @_edges()
          do ({through:[edge]} = value)=>
            collectionName = @Module.context.collectionName edge
            unless collectionName in collections.write
              collections.write.push collectionName
            unless collectionName in collections.read
              collections.read.push collectionName

        methods = []

        for own key, value of @_props()
          if value.serializable? or value.valuable?
            do ({model, collections:_collections} = value)=>
              unless model in SIMPLE_TYPES
                methods.push "#{inflect.classify model}.find" if value.valuable?
                collectionName = @Module.context.collectionName inflect.pluralize inflect.underscore model
                collections.read.push collectionName unless collectionName in collections.read
              if _collections?
                if _collections.constructor is Array
                  items = _collections
                else if _collections.constructor is String
                  items = [_collections]
                else if _collections.constructor is Object and _collections.read.constructor is Array
                  items = _collections.read
                else if _collections.constructor is Object and _collections.read.constructor is String
                  items = [_collections.read]
                items.forEach (item)=>
                  collectionName = @Module.context.collectionName item
                  collections.read.push collectionName unless collectionName in collections.read

        for own key, value of @_comps()
          if value.serializable? or value.valuable?
            do (key, value)=>
              _collections = @::["#{key}Collections"]? []...
              _collections ?= @::["#{key}Collections"] ? {}
              _collections = extend {}, _collections, @::["_#{key}Collections"]?([]...) ? {}

              collections = @_mergeLocks collections, _collections

              _methods = @::["#{key}Methods"]? []...
              _methods ?= @::["#{key}Methods"] ? []
              _methods = extend [], _methods, @::["_#{key}Methods"]?([]...) ? []
              methods = extend [], methods, _methods

        if methods.length > 0
          methods.forEach (_key)=>
            _moduleName = null
            if /.*[:][:].*/.test(_key) and /.*[.].*/.test _key
              [_moduleName, _key] = _key.split '::'
            if _key.split('::').length is 3
              [_moduleName, __className, __methodName] = _key.split '::'
              _key = "#{__className}::#{__methodName}"
            unless _moduleName?
              _moduleName = @moduleName()

            if /.*[#].*/.test _key
              [..., _signal] = _key.split '#'
              [_macro_signal] = _signal.split '.'
              for own _className, OtherAbstractClass of classes[_moduleName]::
                do (_className, OtherAbstractClass)=>
                  subscribers = []
                  subscribers = subscribers.concat OtherAbstractClass["_#{className}_subs"]?[_signal] ? []
                  subscribers = subscribers.concat OtherAbstractClass["_#{className}_subs"]?["#{_macro_signal}.*"] ? []
                  if subscribers.length > 0
                    subscribers.forEach ({methodName, opts})=>
                      if opts.invoke is yes
                        __key = "#{_className}.#{methodName}"
                        unless __key in  processedMethods
                          processedMethods.push __key
                          __collections = OtherAbstractClass.getLocksFor __key, processedMethods
                          collections = @mergeLocks collections, __collections
              return
            if /.*[.].*/.test _key
              [_className, _methodName] = _key.split '.'
              _className = @name if _className is ''
              __key = "#{_className}.#{_methodName}"
            else if /.*[:][:].*/.test _key
              [_className, _methodName] = _key.split '::'
              _className = @name if _className is ''
              __key = "#{_className}::#{_methodName}"
            unless __key in  processedMethods
              OtherAbstractClass = classes[_moduleName]::[_className]
              __collections = OtherAbstractClass.getLocksFor __key, processedMethods
              collections = @mergeLocks collections, __collections


        # console.log '$%$%$%$%$% collections666******', collections
        collections

    beforeSave: ()->

    afterSave: (data)->
      data

    beforeCreate: ()->

    beforeUpdate: ()->
      @updatedAt = new Date().toISOString()
      # console.log '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ beforeUpdate'
      return @

    beforeDelete: ()->
      @isHidden = yes
      @updatedAt = new Date().toISOString()
      return

    afterCreate: @method ['::recordHasBeenChanged'], (data)->
      @recordHasBeenChanged 'createdObject', data
      data

    afterUpdate: @method ['::recordHasBeenChanged'], (data)->
      # console.log '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ afterUpdate'
      @recordHasBeenChanged 'updatedObject', data
      data

    afterDelete: @method ['::recordHasBeenChanged'], (data)->
      @recordHasBeenChanged 'deletedObject', data
      data

    recordHasBeenChanged: @method []
    , {read: ['_queues'], write: ['_jobs']}
    , (signal, data)->
      # console.log '%%%%%%%%%%%%%%%%%%% recordHasBeenChanged data', data
      queues  = require '@arangodb/foxx/queues'
      {db}    = require '@arangodb'
      {cleanCallback} = require('./utils/cleanConfig') FoxxMC
      mount = @Module.context.mount

      queues.get('signals').push(
        {mount: mount, name: 'send_signal'}
        {
          mount:      mount.replace '/', ''
          db:         db._name()
          signal:     signal
          modelName:  data._type
          record_id:  data._key
        }
        {
          success: cleanCallback "success: `send_signal`"
          failure: cleanCallback "failure: `send_signal`"
        }
      )
      return

    # recordHasBeenChanged: ->
    #   return

    @parseModelName: (aName)->
      if /.*[:][:].*/.test(aName)
        [moduleName, vModel] = aName.split '::'
      else
        [moduleName, vModel] = [@moduleName(), inflect.camelize inflect.underscore aName]
      modelName = inflect.singularize inflect.underscore vModel
      ["#{moduleName}::#{vModel}", modelName]

    @findModelByName: (aName)->
      if /.*[:][:].*/.test(aName)
        [moduleName, vModel] = aName.split '::'
      else
        [moduleName, vModel] = [@moduleName(), inflect.camelize inflect.underscore aName]

      modelName = inflect.singularize inflect.underscore vModel
      unless (ModelClass = classes[moduleName]::[vModel])?
        ModelClass = require fs.join classes[moduleName].context.basePath, 'dist', 'models', modelName
      [ModelClass, modelName]

    findModelByName: (aName)->
      @constructor.findModelByName aName

    parseModelName: (aName)->
      @constructor.parseModelName aName

    updateEdges: (data)->
      oldObject = @_old
      newObject = @
      # console.log '$$$$$$$$$$$$$$$ updateEdges', oldObject, newObject
      for own key, value of @constructor._edges()
        do (key, {model, through:[edge]}=value)=>
          if oldObject[key] isnt newObject[key]
            [RelatedModel] = @findModelByName model
            if oldObject[key]?
              relatedObject = RelatedModel.find oldObject[key]
              db[@constructor.collectionNameInDB edge].removeByExample
                _from:  newObject._id
                _to:    relatedObject._id
            if newObject[key]?
              relatedObject = RelatedModel.find newObject[key]
              db[@constructor.collectionNameInDB edge].save
                _from:  newObject._id
                _to:    relatedObject._id
                _type:  "#{@moduleName()}::#{inflect.camelize edge}" # edge
      return data

    @attribute: ->
      @attr arguments...

    @attr: (name, scheme, opts={})->
      {valuable, sortable, groupable, filterable} = opts
      @["_#{@name}_attrs"] ?= {}
      @["_#{@name}_edges"] ?= {}
      unless @["_#{@name}_attrs"][name]
        @["_#{@name}_attrs"][name] = scheme
        @["_#{@name}_edges"][name] = opts if opts.through
      else
        throw new Error "attr `#{name}` has been defined previously"

    @__attrs: {}
    @_attrs: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @_attrs AbstractClass.__super__.constructor
      @__attrs[AbstractClass.name] ?= do ->
        extend {}
        , (fromSuper ? {})
        , (AbstractClass["_#{AbstractClass.name}_attrs"] ? {})
      @__attrs[AbstractClass.name]

    @__edges: {}
    @_edges: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @_edges AbstractClass.__super__.constructor
      @__edges[AbstractClass.name] ?= do ->
        extend {}
        , (fromSuper ? {})
        , (AbstractClass["_#{AbstractClass.name}_edges"] ? {})
      @__edges[AbstractClass.name]

    @__props: {}
    @_props: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @_props AbstractClass.__super__.constructor
      @__props[AbstractClass.name] ?= do ->
        extend {}
        , (fromSuper ? {})
        , (AbstractClass["_#{AbstractClass.name}_props"] ? {})
      @__props[AbstractClass.name]

    @__comps: {}
    @_comps: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @_comps AbstractClass.__super__.constructor
      @__comps[AbstractClass.name] ?= do ->
        extend {}
        , (fromSuper ? {})
        , (AbstractClass["_#{AbstractClass.name}_comps"] ? {})
      @__comps[AbstractClass.name]

    @property: ->
      @prop arguments...

    @prop: (name, opts={})->
      opts.serializeFromClient ?= (value)-> value
      opts.serializeForClient ?= (value)-> value
      {
        attr, refKey, type, model,
        definition, bindings, valuable, valuableAs,
        sortable, groupable, filterable, collections, methods,
        serializeFromClient, serializeForClient
      } = opts
      unless definition? and type? and model?
        return throw new Error '`definition`, `type` and `model` options is required'
      if valuable?
        schema = ()=>
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
            ModelClass.attributes()[prop_name]
          else if type is 'array' and not /.*[.].*/.test valuable
            joi.array().items ModelClass.schema()
          else if type is 'array' and /.*[.].*/.test valuable
            [..., prop_name] = valuable.split '.'
            joi.array().items ModelClass.attributes()[prop_name]
      else
        schema = ()-> {}
      opts.schema ?= schema
      @["_#{@name}_props"] ?= {}
      model ?= inflect.singularize inflect.underscore name
      unless @["_#{@name}_props"][name]
        @["_#{@name}_props"][name] = opts
        @::["#{name}Collections"] = collections
        @::["#{name}Methods"] = methods
        switch type
          when 'item'
            @defineProperty name,
              get: ()->
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
              get: ()->
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

    @computed: ->
      @comp arguments...

    @comp: (name, methods, collections, opts, lambda)->
      {type, model, valuable, valuableAs} = opts
      model ?= inflect.singularize inflect.underscore name
      if not lambda? or not type?
        return throw new Error '`lambda` and `type` options is required'
      if valuable?
        schema = ()=>
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
            ModelClass.attributes()[prop_name]
          else if type is 'array' and not /.*[.].*/.test valuable
            joi.array().items ModelClass.schema()
          else if type is 'array' and /.*[.].*/.test valuable
            [..., prop_name] = valuable.split '.'
            joi.array().items ModelClass.attributes()[prop_name]
      else
        schema = ()-> {}
      opts.schema ?= schema
      @["_#{@name}_comps"] ?= {}
      unless @["_#{@name}_comps"][name]
        @["_#{@name}_comps"][name] = opts
        empty_result = switch type
          when 'item'
            null
          when 'array'
            []
          else
            throw new Error 'type must be `item` or `array` only'
        @::["#{name}Methods"] = methods if methods?
        @::["#{name}Collections"] = collections if collections?
        @defineProperty name,
          get: ()->
            result = @["__#{name}"]
            result ?= @["__#{name}"] = lambda.apply(@, []) ? empty_result
            result
      else
        throw new Error "comp `#{name}` has been defined previously"
      return

    @belongsTo: (name, scheme, opts = {})->
      opts.attr ?= "#{name}Id"
      opts.refKey ?= '_key'
      @attr opts.attr, scheme, opts
      if opts.attr isnt "#{name}Id"
        @prop "#{name}Id",
          type: 'item'
          model: 'string'
          attr: opts.attr
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

    @hasMany: (name, opts = {})->
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

    @hasOne: (name, opts = {})->
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

    # под вопросом, т.к. есть валидация через joi - надо определиться что использовать.
    @validate: (attribute, options)->

    # -------------------------- ORM oriented ------------------
    @let: @method [], ->
      read: [@collectionName()]
    , (definitions, bindings, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .let definitions, bindings
    @includes: @method [], ->
      read: [@collectionName()]
    , (definitions, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .includes definitions

    @distinct: @method [], ->
      read: [@collectionName()]
    , (currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .distinct()

    @select: @method [], ->
      read: [@collectionName()]
    , (fields, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .select fields

    @return: @method ['.select'], (fields, currentUser = null)->
      @select fields, currentUser

    @from: @method [], ->
      read: [@collectionName()]
    , (collectionName, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .from collectionName

    @joins: @method [], ->
      read: [@collectionName()]
    , (definitions, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .joins definitions

    @for: @method [], ->
      read: [@collectionName()]
    , (variable, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .for variable

    @where: @method [], ->
      read: [@collectionName()]
    , (conditions, bindings=null, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .where conditions, bindings

    @filter: @method ['.where']
    , (conditions, bindings=null, currentUser = null)->
      @where conditions, bindings, currentUser

    @group: @method [], ->
      read: [@collectionName()]
    , (definition, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .group definition

    @collect: @method ['.group'], (definition, currentUser = null)->
      @group definition, currentUser

    @having: @method [], ->
      read: [@collectionName()]
    , (conditions, bindings, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .having conditions, bindings

    @sort: @method [], ->
      read: [@collectionName()]
    , (fields, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .sort fields

    @limit: @method [], ->
      read: [@collectionName()]
    , (currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .limit()

    # pluck позволяет заменить такой код: `Client.select('id').map (c)-> c.id` на `Client.pluck('id').toArray()`
    @pluck: @method [], ->
      read: [@collectionName()]
    , (attribute, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .pluck attribute

    @count: @method [], ->
      read: [@collectionName()]
    , (currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .count()

    @avg: @method ['.average'], ->
      @average arguments...
    @average: @method [], ->
      read: [@collectionName()]
    , (attribute, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .average attribute

    @min: @method ['.minimum'], ->
      @minimum arguments...
    @minimum: @method [], ->
      read: [@collectionName()]
    , (attribute, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .minimum attribute

    @max: @method ['.maximum'], ->
      @maximum arguments...
    @maximum: @method [], ->
      read: [@collectionName()]
    , (attribute, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .maximum attribute

    @sum: @method [], ->
      read: [@collectionName()]
    , (attribute, currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .sum attribute

    # ------------------------- Class methods -----------------
    # получение итератора по всем (создание курсора)
    @all: @method [], ->
      read: [@collectionName()]
    , (currentUser = null)->
      new Query()
        .model @
        .currentUser currentUser
        .sort 'doc.createdAt', 'doc._key'
        .select 'doc'

    @new: @method (attributes, currentUser=null)->
      if attributes._type is "#{@moduleName()}::#{@name}"
        @super('new') arguments
      else
        [ModelClass] = @findModelByName attributes._type
        ModelClass?.new(attributes, currentUser) ? @super('new') arguments

    # возвращает все доступные для определения в документе атрибуты
    @attributes:  ->
      @_attrs()
    @properties:  ->
      @_props()
    @computeds:   ->
      @_comps()
    @serializableAttributes: ()->
      @["_#{@name}_serializableAttributes"] ?= _.omit extend(
        {}
      ,
        @attributes()
      ,
        _.transform @properties(),
          (result, value, key)->
            unless (_key = value.valuableAs)?
              _key = key
            result[_key] = value.schema() if value.serializable? or value.valuable?
          , {}
      ,
        _.transform @computeds(),
          (result, value, key)->
            unless (_key = value.valuableAs)?
              _key = key
            result[_key] = value.schema() if value.serializable? or value.valuable?
          , {}
      ), ['_key', '_rev', '_type', '_owner', '_space', '_from', '_to']
      @["_#{@name}_serializableAttributes"]

    # возвращает 1 объект
    @find: @method [], (-> read: [@collectionName()]), (id, currentUser=null)->
      result = @where qb.or qb.eq(qb.ref('doc._key'), qb id), qb.eq(qb.ref('doc._id'), qb id)
        .limit 1
        .select 'doc'
        .toArray()[0]
      if result?
        @new result, currentUser
      else
        result

    # возвращает 1 объект (сортирует по id и возвращает первый)
    @first: @method [], (-> read: [@collectionName()]), (count = 1, currentUser=null)->
      result = @sort 'doc.createdAt', 'doc._key'
        .limit count
        .select 'doc'
        .toArray()
      if count is 1
        @new result[0], currentUser
      else
        result.map (item)=>
          @new item, currentUser

    # возвращает 1 объект (сортирует по id и возвращает последний)
    @last: @method [], (-> read: [@collectionName()]), (count = 1, currentUser=null)->
      result = @sort 'doc.createdAt', 'DESC', 'doc._key', 'DESC'
        .limit count
        .select 'doc'
        .toArray()
      if count is 1
        @new result[0], currentUser
      else
        result.map (item)=>
          @new item, currentUser

    # возвращает 1 объект
    @find_by: @method [], (-> read: [@collectionName()]), (conditions, currentUser=null)->
      result = @where conditions
        .limit 1
        .select 'doc'
        .toArray()[0]
      console.log '$$$$$$$$$$$$ result', result
      if result?
        @new result, currentUser
      else
        result

    @forEach: @method [], (-> read: [@collectionName()]), (lambda, currentUser = null)->
      @all(currentUser).forEach lambda
      return

    @map: @method [], (-> read: [@collectionName()]), (lambda, currentUser = null)->
      @all(currentUser).map lambda

    @reduce: @method [], (-> read: [@collectionName()]), (lambda, initialValue, currentUser = null)->
      @all(currentUser).reduce lambda, initialValue

    # @find_in_batches: (lambda)->

    @find_by_aql: @method (query, bindings, currentUser=null)->
      result = db._query arguments...
      new Cursor(@).currentUser(currentUser).setCursor result

    @query: @method [], (-> read: [@collectionName()]), (query, currentUser=null)->
      query = _.pick query, Object.keys(query).filter (key)-> query[key]?
      new Query()
        .model @
        .currentUser currentUser
        .query query

    # возвращает 1 объект, который был автоматически сохранен в базе
    @create: @method ['.new', '::save'], (attributes, currentUser=null)->
      _attributes = @serializeFromClient attributes
      record = @new _attributes, currentUser
      record.save()

    @createFromBatch: @method ->
      ['.new', '::save']
    , (attributes, currentUser=null)->
      _attributes = @serializeFromBatch attributes
      record = @new _attributes, currentUser
      record.save()

    # помечает как удаленный
    @delete: @method ['.find', '::delete'], (id, currentUser=null)->
      record = @find id, currentUser
      record.delete()

    # реально удаляет объект в базе данных (не безопасный метод, т.к. могут остаться зависимости.)
    @destroy: @method ['.find', '::destroy'], (id, currentUser=null)->
      record = @find id, currentUser
      record.destroy()

    # помечает как удаленные несколько за раз ! conditions must be qbValue
    @delete_all: @method [], ->
      read: [@collectionName()], write: [@collectionName()]
    , (conditions)->
      if conditions.constructor is String
        filter = qb.expr conditions
      else if conditions.constructor is Object
        filters = for own k, v of conditions
          do (k, v)->
            qb.eq qb.ref("doc.#{k}"), qb v
        filter = qb.and filters...
      else
        throw new Error 'conditions must be qbValue'
      query = qb.for 'doc'
        .in @collectionNameInDB()
        .filter filter
        .update qb.ref 'doc._key'
        .with qb
          isHidden: yes
          updatedAt: new Date().toISOString()
        .in @collectionNameInDB()
      db._query query
      return yes

    # реально удаляет несколько за раз (не безопасный метод, т.к. могут остаться зависимости.)
    @destroy_all: (conditions)->
      # в итераторе (курсоре) будем каждый документ вернувшийся после фильтрации сериализовывать и вызывать на объекте метод .destroy()

    # проверяет есть ли по этому условию объекты в базе
    @exists: @method ['.filter'], (conditions)->
      @filter conditions
        .return 'doc._key'
        .hasNext()

    # обновляет в документе, найденном по id, некоторые атрибуты
    @update: @method ['.find', '::update_attributes'], (id, attributes, currentUser=null)->
      # console.log 'LLLLLLLLLLLLLllllllllllllllllllll', id, attributes
      record = @find id, currentUser
      # console.log 'LLLLLLLLLLLLLllllllllllllllllllll1111111'
      _attributes = @serializeFromClient attributes
      record.update_attributes _attributes

    # обновляет в документах, найденных по условию, некоторые атрибуты
    @update_all: @method [], ->
      read: [@collectionName()], write: [@collectionName()]
    , (conditions, attributes)->
      if conditions.constructor is String
        filter = qb.expr conditions
      else if conditions.constructor is Object
        filters = for own k, v of conditions
          do (k, v)->
            qb.eq qb.ref("doc.#{k}"), qb v
        filter = qb.and filters...
      else
        throw new Error 'conditions must be qbValue'
      _attributes = _.merge attributes, updatedAt: new Date().toISOString()
      query = qb.for 'doc'
        .in @collectionNameInDB()
        .filter filter
        .update qb.ref 'doc._key'
        .with qb _attributes
        .in @collectionNameInDB()
      db._query query
      return yes

    # ------------ Default attributes definitions ---------
    @attr '_key',         joi.string().empty(null).default(uuid.v4, 'uuid.v4() by default')
    @attr '_rev',         joi.number().empty(null).optional()
    @attr '_type',        joi.string().empty(null).optional()
    @attr 'isHidden',     joi.boolean().empty(null).default(no, 'Visible by default')
    @attr 'createdAt',    joi.date().empty(null).default((()-> new Date().toISOString()), 'Datetime of creating')
    @attr 'updatedAt',    joi.date().empty(null).default((()-> new Date().toISOString()), 'Datetime of updating')

    @prop 'id',
      type: 'item'
      model: 'string'
      attr: '_key'
      definition: "(doc._key)"
      valuable: 'id'
      sortable: 'id'
      filterable: 'id'
      groupable: 'id'

    @prop 'rev',
      type: 'item'
      model: 'string'
      attr: '_rev'
      definition: "(doc._rev)"
      valuable: 'rev'
      sortable: 'rev'
      filterable: 'rev'
      groupable: 'rev'

    @prop 'type',
      type: 'item'
      model: 'string'
      attr: '_type'
      definition: "(doc._type)"
      valuable: 'type'
      sortable: 'type'
      filterable: 'type'
      groupable: 'type'

    @comp 'currentUser', [], {}, {type: 'item', model: 'user'}, ->

    @chains ['validate', 'save', 'create', 'update', 'delete', 'destroy']

    @beforeHook 'beforeValidate', only: ['validate']
    @afterHook 'afterValidate', only: ['validate']

    @beforeHook 'beforeSave', only: ['save']
    @beforeHook 'beforeCreate', only: ['create']
    @beforeHook 'beforeUpdate', only: ['update']

    @afterHook 'afterUpdate', only: ['update']
    @afterHook 'afterCreate', only: ['create']
    @afterHook 'afterSave', only: ['save']

    @beforeHook 'beforeDelete', only: ['delete']
    @afterHook 'afterDelete', only: ['delete']

    @afterHook 'updateEdges', only: ['create', 'update', 'delete']

    @beforeHook 'beforeDestroy', only: ['destroy']
    @afterHook 'afterDestroy', only: ['destroy']

    # ------------- Instanse methods ----------
    delay: @method ['::save', '.delayJob'], (opts = null)->
      @save()
      self = @
      obj = {}
      for key, value of @
        do (methodName=key, value)->
          if methodName isnt 'delay' and _.isFunction value
            obj[methodName] = (args...)->
              data =
                moduleName: self.constructor.moduleName()
                className: self.constructor.name
                id: self.id
                methodName: methodName
                args: args
              self.constructor.delayJob data, opts
      obj

    # возвращает атрибуты документа
    attributes: @method [], ->
      read: [@constructor.collectionName()]
    , ->
      {db} = require '@arangodb'
      qb = require 'aqb'
      query = qb.for 'doc'
        .in @constructor.collectionNameInDB()
        .filter qb.eq qb.ref('doc._key'), qb @_key
        .return qb.expr 'ATTRIBUTES(doc)'
      db._query(query).next()

    # клонирует документ (поверхностная копия без автоматического сохранения в базу)
    clone: ()->

    # клонирует документ (поверхностная копия с автоматическим сохранением в базу)
    copy: ()->

    create: @method ['::isNew'], ->
      write: [@constructor.collectionName()]
    , ->
      unless @isNew()
        throw new Error 'Document is exist in collection'
      console.log '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!$%$%$% @getSnapshot()', @getSnapshot()
      query = qb.insert qb @getSnapshot()
        .in @constructor.collectionNameInDB()
        .returnNew 'doc'
      console.log '!!! query', query.toAQL()
      [newObject] = db._query(query).toArray()
      @_resetAttributes newObject
      @_old = {}
      return @

    # клонирует документ (глубокая копия с автоматическим сохранением в базу - т.е. копируются так же и связи)
    deep_copy: ()->

    decrement: @method ['::save'], (attribute, step = 1)->
      if @[attribute]?.constructor isnt Number
        throw new Error "doc.attribute `#{attribute}` is not Number"
      @[attribute] -= step
      @save()

    delete: @method ['::isNew'], ->
      read: [@constructor.collectionName()], write: [@constructor.collectionName()]
    ,()->
      if @isNew()
        throw new Error 'Document is not exist in collection'
      query = qb.update qb _key: @_key
        .with qb @getSnapshot()
        .in @constructor.collectionNameInDB()
        .return qb.obj oldObject: qb.ref('OLD'), newObject: qb.ref('NEW')

      [{oldObject, newObject}] = db._query(query).toArray()
      @_resetAttributes newObject
      @_old = oldObject
      return @

    # реально удаляет объект в базе данных (не безопасный метод, т.к. могут остаться зависимости.)
    destroy: @method ['::isNew'], ->
      read: [@constructor.collectionName()], write: [@constructor.collectionName()]
    , ()->

    increment: @method ['::save'], (attribute, step = 1)->
      if @[attribute]?.constructor isnt Number
        throw new Error "doc.attribute `#{attribute}` is not Number"
      @[attribute] += step
      @save()

    isNew: @method [], ->
      read: [@constructor.collectionName()]
    , ()->
      {db} = require '@arangodb'
      not @_key? or not db[@constructor.collectionNameInDB()].exists @_key

    _resetAttributes: (newRawDoc)->
      for own k, v of newRawDoc
        do (k, v)=>
          @[k] = v
      return

    reload: @method [], ->
      read: [@constructor.collectionName()]
    , ->
      doc = db[@constructor.collectionNameInDB()].document @_key
      @_resetAttributes doc
      return @

    getSnapshot: ()->
      snapshot = {}
      attributes = _.omit @constructor.attributes(), ['_rev']
      for own attr, v of attributes
        if attr is '_key'
          snapshot[attr] = @[attr] if @[attr]?
        else
          snapshot[attr] = @[attr] ? null
      snapshot

    _forClient: (obj)->
      _.omit obj, [
        '_id'
        '_oldRev'
        '_key'
        '_type'
        '_owner'
        '_space'
        '_rev'
        '_from'
        '_to'
      ]

    @serializeFromBatch: (obj)->
      res = _.omit obj, ['_id', '_rev', 'rev', 'type', '_type', '_owner', '_space', '_from', '_to']
      res._type = "#{@moduleName()}::#{@name}" #inflect.underscore @name
      for own prop, prop_opts of @properties()
        unless (serializableName = prop_opts.valuableAs)?
          serializableName = prop
        do (prop)->
          if (value = res[serializableName])? and prop_opts.valuable? and prop_opts.attr?
            {attr, serializeFromClient} = prop_opts
            res[attr] = serializeFromClient value
          delete res[prop]
      for own comp, comp_opts of @computeds()
        do (comp)-> delete res[comp]
      res

    @serializeFromClient: (obj) ->
      @serializeFromBatch obj

    serializeForClient: (opts)->
      snapshot = {}
      for own attr, v of @constructor.attributes()
        snapshot[attr] = @[attr] ? null
      for own prop, prop_opts of @constructor.properties()
        unless (serializableName = prop_opts.valuableAs)?
          serializableName = prop
        if prop_opts.valuable? and prop_opts.valuable.constructor is String
          if prop_opts.type is 'item'
            unless @[prop]?
              snapshot[serializableName] = null
            else if prop_opts.model in SIMPLE_TYPES
              snapshot[serializableName] = @[prop]
            else
              if /[.]/.test prop_opts.valuable
                [..., prop_attr] = prop_opts.valuable.split '.'
                snapshot[serializableName] = @[prop][prop_attr]
              else
                snapshot[serializableName] = @[prop].serializeForClient(opts)
          else if prop_opts.type is 'array'
            # console.log '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ @[prop].length', @[prop].length
            if not @[prop]? or @[prop].length is 0
              snapshot[serializableName] = []
            else if prop_opts.model in SIMPLE_TYPES
              snapshot[serializableName] = @[prop].map (i)-> i
            else
              if /\[\]\./.test prop_opts.valuable
                [..., prop_attr] = prop_opts.valuable.split '[].'
                snapshot[serializableName] = @[prop].map (i)-> i[prop_attr] ? null
              else if /\[\*\]\./.test prop_opts.valuable
                [..., prop_attr] = prop_opts.valuable.split '[*].'
                snapshot[serializableName] = @[prop].map (i)-> i[prop_attr] ? null
              else
                snapshot[serializableName] = @[prop].map (i)-> i.serializeForClient(opts)
      for own comp, comp_opts of @constructor.computeds()
        unless (serializableName = comp_opts.valuableAs)?
          serializableName = comp
        if comp_opts.valuable? and comp_opts.valuable.constructor is String
          if comp_opts.model in SIMPLE_TYPES
            snapshot[serializableName] = @[comp] ? null
          else if comp_opts.type is 'item'
            unless @[comp]?
              snapshot[serializableName] = null
            else
              if /[.]/.test comp_opts.valuable
                [..., comp_attr] = comp_opts.valuable.split '.'
                snapshot[serializableName] = @[comp][comp_attr]
              else
                snapshot[serializableName] = @[comp].serializeForClient(opts)
          else if comp_opts.type is 'array'
            # console.log '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ @[comp].length', @[comp].length
            if @[comp].length is 0
              snapshot[serializableName] = []
            else
              if /\[\]\./.test comp_opts.valuable
                [..., comp_attr] = comp_opts.valuable.split '[].'
                snapshot[serializableName] = @[comp].map (i)-> i[comp_attr] ? null
              else if /\[\*\]\./.test comp_opts.valuable
                [..., comp_attr] = comp_opts.valuable.split '[*].'
                snapshot[serializableName] = @[comp].map (i)-> i[comp_attr] ? null
              else
                snapshot[serializableName] = @[comp].map (i)-> i.serializeForClient(opts)
      @_forClient snapshot, opts

    validate: ()->
      console.log 'DDDDDDDDDDD @constructor.schema()', @getSnapshot()
      {value:snapshot} = @constructor.schema().validate @getSnapshot()
      # console.log 'DDDD snapshot', snapshot
      for own k, v of snapshot
        do (k, v)=>
          @[k] = v
      return @

    save: @method ['::validate', '::isNew', '::create', '::update'], ()->
      @validate()
      if @isNew()
        @create()
      else
        @update()

    # инвертирует булевое значение в атрибуте
    toggle: @method ['::save'], (attribute)->
      if @[attribute]?.constructor isnt Boolean
        throw new Error "doc.attribute `#{attribute}` is not Boolean"
      @[attribute] = not @[attribute]
      @save()

    # обновляет значения в timestamp атрибутах
    touch: @method ['::save'], ()->
      @updatedAt = new Date().toISOString()
      @save()

    update: @method ['::isNew'], ->
      read: [@constructor.collectionName()], write: [@constructor.collectionName()]
    , ()->
      # console.log 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000', @_key
      if @isNew()
        throw new Error 'Document does not exist in collection'
      query = qb.update qb _key: @_key
        .with qb @getSnapshot()
        .in @constructor.collectionNameInDB()
        .return qb.obj oldObject: qb.ref('OLD'), newObject: qb.ref('NEW')

      # console.log 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', query
      [{oldObject, newObject}] = db._query(query).toArray()
      console.log 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF11111111', JSON.stringify newObject

      # @updateEdges oldObject, newObject
      # console.log 'DFDFDFDF newObject', newObject
      @_resetAttributes newObject
      @_old = oldObject
      return @

    # сетим значение в атрибут и вызываем save()
    update_attribute: @method ['::save'], (name, value)->
      @[name] = value
      @save()

    # сетим несколько значений в атрибуты, вызываем валидацию а затем save()
    update_attributes: @method ['::save'], (attributes)->
      @_resetAttributes attributes
      @save()

  FoxxMC::Model.initialize()
