_             = require 'lodash'
crypto        = require '@arangodb/crypto'
inflect       = require('i')()


###
  Chains
  ```
    @beforeHook 'beforeVerify', only: ['verify']
    @afterHook 'afterVerify', only: ['verify']

    @beforeHook 'beforeCount', only: ['count']
    @afterHook 'afterCount', only: ['count']

    @chains ['verify', 'count'] # если в классе, унаследованном от Model, Controller, CoreObject надо объявить цепи для методов

    constructor: -> # именно в конструкторе надо через методы beforeHook и afterHook объявить методы инстанса класса, которые будут использованы в качестве звеньев цепей
      super

    beforeVerify: ->

    beforeCount: ->

    afterVerify: (data)->
      data

    afterCount: (data)->
      data
  ```
###

###
  ````
    class Aaa extends Mixin
      k: ->
        console.trace()
        console.log '^^Aaa::k', @yy
      @hh: ->
        console.log '^^Aaa.hh'


    class Ccc extends Mixin
      @jk: 6
      yy: 90
      @kl: ->
      @hh: ->
        console.log 'before super @hh() in Ccc.hh'
        super
        console.log 'after super @hh() in Ccc.hh'
      k: ->
        console.log 'before super k() in Ccc::k'
        super
        console.log 'after super k() in Ccc::k'


    class Jjj extends Mixin
      @ll: 6
      oo: ->
        this.k()
      #k: ->
      #  console.log 'before super k() in Jjj::k'
      #  super
      #  console.log 'after super k() in Jjj::k'


    class Kkk extends Mixin
      @ll: 6
      oo: ->
        this.k()
      k: ->
        console.log 'before super k() in Kkk::k', @yy
        super
        console.log 'after super k() in Kkk::k'
      #@hh: ->
      #  console.log 'before super @hh() in Kkk.hh'
      #  super
      #  console.log 'after super @hh() in Kkk.hh'


    class Lll extends Kkk
      @ll: 6
      oo: ->
        this.k()
      k: ->
        console.log 'before super k() in Lll::k'
        super
        console.log 'after super k() in Lll::k'
      @hh: ->
        console.log 'before super @hh() in Lll.hh'
        super
        console.log 'after super @hh() in Lll.hh'


    class Iii extends Mixin
      @including: ->
        @attr 'jhj'

    # Parameterized mixin
    Formattable = (classname, properties...) ->
      class extends Mixin
        toString: ->
          if properties.length is 0
            "[#{classname}]"
          else
            formattedProperties = ("#{p}=#{@[p]}" for p in properties)
            "[#{classname}(#{formattedProperties.join ', '})]"

        classname: -> classname


    class Bbb extends CoreObject
      @include [
        Aaa
        Ccc
      ]
      @include Jjj, Lll
      @include Iii
      @include Formattable('Bbb', 'yy')
      k: ->
        console.log 'before super k() in Bbb::k'
        super
        console.log 'after super k() in Bbb::k'
      @hh: ->
        console.log 'before super @hh() in Bbb.hh'
        super
        console.log 'after super @hh() in Bbb.hh'

    b = new Bbb()
    b.k()
    Bbb.hh()
    console.log 'Bbb', String(b), Bbb.__super__
  ```
###

###
  # Технология машины состояний проектировалась с оглядкой на
  https://github.com/aasm/aasm

class Tomato extends CoreObject
  @StateMachine 'default', ->
    @beforeAllEvents 'beforeAllEvents'
    @afterAllTransitions 'afterAllTransitions'
    @afterAllEvents 'afterAllEvents'
    @errorOnAllEvents 'errorOnAllEvents'
    @state 'first',
      initial: yes
      beforeExit: 'beforeExitFromFirst'
      afterExit: 'afterExitFromFirst'
    @state 'sleeping',
      beforeExit: 'beforeExitFromSleeping'
      afterExit: 'afterExitFromSleeping'
    @state 'running',
      beforeEnter: 'beforeEnterToRunning'
      afterEnter: 'afterEnterFromRunning'
    @event 'run',
      before: 'beforeRun'
      after: 'afterRun'
      error: 'errorOnRun'
     , =>
        @transition ['first', 'second'], 'third',
          guard: 'checkSomethingCondition'
          after: 'afterFirstSecondToThird'
        @transition 'third', 'running',
          if: 'checkThirdCondition'
          after: 'afterThirdToRunning'
        @transition ['first', 'third', 'sleeping', 'running'], 'superRunning',
          unless: 'checkThirdCondition'
          after: 'afterSleepingToRunning'

  checkSomethingCondition: ->
    console.log '!!!???? checkSomethingCondition'
    yes
  checkThirdCondition: ->
    console.log '!!!???? checkThirdCondition'
    yes
  beforeExitFromSleeping: ->
    console.log 'DFSDFSD beforeExitFromSleeping'
  beforeExitFromFirst: ->
    console.log 'DFSDFSD beforeExitFromFirst'
  afterExitFromSleeping: ->
    console.log 'DFSDFSD afterExitFromSleeping'
  afterExitFromFirst: ->
    console.log 'DFSDFSD afterExitFromFirst'
  beforeEnterToRunning: ->
    console.log 'DFSDFSD beforeEnterToRunning'
  beforeRun: ->
    console.log 'DFSDFSD beforeRun'
  afterRun: ->
    console.log 'DFSDFSD afterRun'
  afterFirstSecondToThird: (firstArg, secondArg)->
    console.log firstArg, secondArg # => {key: 'value'}, 125
    console.log 'DFSDFSD afterFirstSecondToThird'
  afterThirdToRunning: (firstArg, secondArg)->
    console.log firstArg, secondArg # => {key: 'value'}, 125
    console.log 'DFSDFSD afterThirdToRunning'
  afterSleepingToRunning: (firstArg, secondArg)->
    console.log firstArg, secondArg # => {key: 'value'}, 125
    console.log 'DFSDFSD afterSleepingToRunning'
  afterRunningToSleeping: ->
    console.log 'DFSDFSD afterRunningToSleeping'

  beforeAllEvents: ->
    console.log 'DFSDFSD beforeAllEvents'
  afterAllTransitions: ->
    console.log 'DFSDFSD afterAllTransitions'
  afterAllEvents: ->
    console.log 'DFSDFSD afterAllEvents'
  errorOnAllEvents: (err)->
    console.log 'DFSDFSD errorOnAllEvents', err, err.stack
  errorOnRun: ->
    console.log 'DFSDFSD errorOnRun'

tomato = new Tomato()
tomato.run({key: 'value'}, 125) # можно передать как аргументы какие нибудь данные, они будут переданы внутырь коллбеков указанных на транзишенах в ключах :after
console.log 'tomato.state', tomato.state
###

###
StateMachine flow

try
  event           beforeAllEvents
  event           before
  event           guard
    transition      guard
    old_state       beforeExit
    old_state       exit
    ...update state...
                    afterAllTransitions
    transition      after
    new_state       beforeEnter
    new_state       enter
    ...save state...
    transition      success             # if persist successful
    old_state       afterExit
    new_state       afterEnter
  event           success             # if persist successful
  event           after
  event           afterAllEvents
catch
  event           error
  event           errorOnAllEvents
###

###
  # если в методе экземпляра класса идет работа с коллекцией в базе данных (чтение, запись), то надо сделать описание этого, для механизма конструирующего локи на базе для транцикции
  ```
    afterCreateMethods: -> ['::recordHasBeenChanged'] # т.к. внутри afterCreate метода экземпляра идет работа с @recordHasBeenChanged методом тоже экземпляра этого же класса
    afterCreateCollections: ->
      {}
    afterCreate: (data)->
      @recordHasBeenChanged 'createdObject', data
      data

    @createMethods: ['.new', '::save'] # '.new' - т.к. вызывается метод класса, '::save' - т.к. вызывается метод экземпляра класса
    @createCollections: -> # может быть ничего не указано, если непосредственно внутри метода нет работы с конкретной коллекцией
      {}
    @create: (attributes)->
      record = @new attributes
      record.save()

    @resetAttrMethods: -> ['Account.new', 'TransactionsController::save'] # перед '.' или '::' в полной записи может идти имя класса, если оно отличается от текущего
    @resetAttrCollections: ->
      {}
    @resetAttr: (attributes)->
      record = Account.new attributes
      transactions = record.transactions
      transactions.forEach (transaction)->
        transaction.some_attr += 1
        transaction.save()

    recordHasBeenChangedMethods: -> [] # может быть ничего не указано, если методы других классов или инстансов классов не вызываются
    recordHasBeenChangedCollections: -> # указываем '_queues' лок на чтение и '_jobs' лок на запись, тк. queues.get('signals').push внутри работает с этими коллекциями.
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
###

###
  Рекомендуемый способ объявлять методы класса:
  ```
    @new: @method (args...)->
      [attributes] = args
      if attributes._type is inflect.underscore @name
        @super('new') Model, args... # один из примеров использования
      else
        Model = require "../models/#{attributes._type}"
        Model?.new(attributes) ? @super('new') arguments # один из примеров использования
      r

    create: @method ->
      @super('create') arguments # один из примеров использования
  ```
###

###
  При использовании @method внутри может потребоваться вызвать super
  НО обычный super из coffeescript здесь работать не будет по понятным причинам.
  Поэтому в CoreObject объявлены реализации суперов для вызовов в методах классов и в методах инстансов классов.
  В обоих случаях синтаксис абсолютно эквивалентен
  ```
    @super('<имя метода, из родительского класса>') arguments # без деструктуризации
    - т.е. при какировании передается только один аргумент `arguments` - аргументы текущей функции.

    либо если метод из родительсткого класса должен быть вызван с отличными аргументами
    @super('<имя метода, из родительского класса>') <Имя текущего класса (ссылка на текущий класс)>, <arg1>, <arg2>, <arg3>...
    - т.е. при какировании передается 2 и более аргументов, но тогда первый аргумент - ссылка на текцщий класс
  ```
###

###
  Publish and subscribe examples
  - При объявлении класса
  ```
    @sub '<signal>', '<class method name>'
  ```
  или
  ```
    @sub '<signal>', [<methods array>], {<collections object>}, <lambda function> # т.е. по аналогии с @classMethod
  ```

  В рантайме, когда надо послать сигнал на асинхронную обработку заранее неизвестному количеству подписчиков:
  ```
    @pub(<publication options>) '<signal>', arg1, arg2, arg3...
  ```
  <publication options> - объект в котором можно задать имя очереди или спец опции, которые пробросятся в @delay()
  arg1, arg2, arg3 - любое количество аргументов, они будут проброшены в subscribed функции.

###

###

class Person extends CoreObject
  ipsFirstName      = Symbol 'firstName'
  ipsLastName       = Symbol 'lastName'
  ipmCalculateSize  = Symbol 'calculateSize'

  @defineAccessor   String, ipsFirstName
  @defineSetter     String, ipsLastName

  # example of private method definition
  @instanceMethod ipmCalculateSize, ->

  # example of public method definition (special glyphs not need)
  mixVegetables: ->

  constructor: (aOptions={})->
    @[ipsFirstName]    = aOptions.firstName if aOptions.firstName?
    @[ipsLastName]     = aOptions.lastName if aOptions.lastName?


class Teacher extends Person
  ipoSomePerson = Symbol 'somePerson'

  @defineAccessor Person, ipoSomePerson

  constructor: (aOptions={})->
    super
    @[ipoSomePerson]   = aOptions.somePerson


vTeacher = new Teacher
  firstName: 'denya'
  lastName: 'T'
  somePerson: new Person(firstName: 'glum')

console.log vTeacher.firstName
vTeacher.firstName = 'denya1'
console.log vTeacher.firstName
console.log vTeacher

###

module.exports = (FoxxMC)->
  extend        = require('./utils/extend') FoxxMC

  class FoxxMC::CoreObject
    @Module: null # must be defined in child classes
    @["_#{@name}_initialHooks"] = []
    @["_#{@name}_beforeHooks"] = []
    @["_#{@name}_afterHooks"] = []
    @["_#{@name}_finallyHooks"] = []
    @["_#{@name}_errorHooks"] = []
    @["_#{@name}_chains"] = []

    @chains: (chains)->
      @["_#{@name}_chains"] ?= []
      chains = [chains] if chains.constructor is String
      @["_#{@name}_chains"] = @["_#{@name}_chains"].concat chains

      chains.forEach (methodName)=>
        @::["_#{methodName}Collections"] = ->
          @collectionsInChain methodName
        @::["_#{methodName}Methods"] = ->
          @methodsInChain methodName
      return

    @_chains: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @_chains AbstractClass.__super__.constructor
      _.uniq [].concat(fromSuper ? [])
        .concat(AbstractClass["_#{AbstractClass.name}_chains"] ? [])


    @_currentSM: 'default'
    @_currentEvent: null

    @super: (methodName)->
      if arguments.length is 0
        return @__super__?.constructor
      (Class, args...)=>
        if arguments.length is 1
          [args] = arguments
          Class = args.callee?.class ? @
        else
          unless _.isFunction Class
            throw new Error 'First argument must be <Class> or arguments'
        method = Class.__super__?.constructor[methodName]
        method?.apply @, args

    super: (methodName)->
      if arguments.length is 0
        return @constructor.__super__
      (Class, args...)=>
        if arguments.length is 1
          [args] = arguments
          Class = args.callee?.class ? @constructor
        else
          unless _.isFunction Class
            throw new Error 'First argument must be <Class> or arguments'
        method = Class.__super__?[methodName]
        method?.apply @, args

    @new: (attributes, currentUser=null)->
      # console.log '!!!!???/', @, JSON.stringify attributes
      Model = @
      new Model attributes, currentUser

    save: ->
      @

    @defineProperty: (name, definition)->
      Object.defineProperty @::, name, definition

    @defineClassProperty: (name, definition)->
      Object.defineProperty @, name, definition

    @defineGetter: (aName, aDefault, aGetter)->
      if aName.constructor.name is 'Symbol'
        vSymbol = aName
        [vSource, v1, aName, v2] = String(vSymbol).match /(^.*\()(.*)(\)$)/
      else
        vSymbol = Symbol.for aName
      aGetter ?= -> @[vSymbol] ? aDefault
      @::__defineGetter__ aName, aGetter
      return

    @defineSetter: (Class, aName, aSetter)->
      if aName.constructor.name is 'Symbol'
        vSymbol = aName
        [vSource, v1, aName, v2] = String(vSymbol).match /(^.*\()(.*)(\)$)/
      else
        vSymbol = Symbol.for aName
      aSetter ?= (aValue)->
        if aValue.constructor isnt Class
          throw new Error 'not acceptable type'
          return
        @[vSymbol] = aValue
      @::__defineSetter__ aName, aSetter
      return

    @defineAccessor: (Class, aName, aDefault, aGetter, aSetter)->
      @defineGetter aName, aDefault, aGetter
      @defineSetter Class, aName, aSetter
      return

    @defineClassGetter: (aName, aDefault, aGetter)->
      if aName.constructor.name is 'Symbol'
        vSymbol = aName
        [vSource, v1, aName, v2] = String(vSymbol).match /(^.*\()(.*)(\)$)/
      else
        vSymbol = Symbol.for aName
      aGetter ?= -> @[vSymbol] ? aDefault
      @__defineGetter__ aName, aGetter
      return

    @defineClassSetter: (Class, aName, aSetter)->
      if aName.constructor.name is 'Symbol'
        vSymbol = aName
        [vSource, v1, aName, v2] = String(vSymbol).match /(^.*\()(.*)(\)$)/
      else
        vSymbol = Symbol.for aName
      aSetter ?= (aValue)->
        if aValue.constructor isnt Class
          throw new Error 'not acceptable type'
          return
        @[vSymbol] = aValue
      @__defineSetter__ aName, aSetter
      return

    @defineClassAccessor: (Class, aName, aDefault, aGetter, aSetter)->
      @defineClassGetter aName, aDefault, aGetter
      @defineClassSetter Class, aName, aSetter
      return

    # CoreObject::__defineGetter__ 'Module', ->
    #   @constructor.Module
    @defineGetter 'Module', ->
      @constructor.Module

    @moduleName: ->
      @Module.name

    @_functor: (methods, collections, ..., lambda)->
      if arguments.length is 0
        throw new Error 'lambda argument is required'
      if arguments.length is 1
        _methods = null
        _collections = null
      else if arguments.length is 2
        if _.isFunction methods
          _methods = methods
        else
          _methods = -> methods
        _collections = null
      else
        if _.isFunction methods
          _methods = methods
        else
          _methods = -> methods
        if _.isFunction collections
          _collections = collections
        else
          _collections = -> collections

      lambda.class = @

      (context, methodName)->
        context["#{methodName}Methods"] = _methods if _methods?
        context["#{methodName}Collections"] = _collections if _collections?
        context[methodName] = lambda

    @method: (methods, collections, ..., lambda)->
      if arguments.length is 0
        throw new Error 'lambda argument is required'
      if arguments.length is 1
        _methods = null
        _collections = null
      else if arguments.length is 2
        if _.isFunction methods
          _methods = methods
        else
          _methods = -> methods
        _collections = null
      else
        if _.isFunction methods
          _methods = methods
        else
          _methods = -> methods
        if _.isFunction collections
          _collections = collections
        else
          _collections = -> collections

      lambda.class = @
      lambda.methods = _methods if _methods?
      lambda.collections = _collections if _collections?
      lambda.locks = (__methods = [], __collections = {})->
        _lambda = arguments.callee.lambda
        _lambda.methods = if _.isFunction __methods
          __methods
        else
          -> __methods
        _lambda.collections = if _.isFunction __collections
          __collections
        else
          -> __collections
        _lambda
      lambda.locks.lambda = lambda

      lambda

    @instanceMethod: (methodName, args...)->
      @_functor(args...) @::, methodName

    @classMethod: (methodName, args...)->
      @_functor(args...) @, methodName

    @initialize: (Class)->
      Class ?= @
      for own methodName, method of Class
        do (_methodName=methodName, _method=method)->
          if _.isFunction(_method)
            {methods, collections} = _method
            Class["#{methodName}Methods"] = methods if methods?
            Class["#{methodName}Collections"] = collections if collections?
          return
      for methodName, method of Class::
        do (_methodName=methodName, _method=method)->
          if _.isFunction(_method)
            {methods, collections} = _method
            Class::["#{methodName}Methods"] = methods if methods?
            Class::["#{methodName}Collections"] = collections if collections?
          return
      Class

    publish: @method ['::pub'], ->
      @pub arguments...

    @publish: @method ['.pub'], ->
      @pub arguments...

    pub: @method ['.pub'], ->
      @constructor.pub arguments...

    @pub: @method ['.delay'], (opts)->
      (signal, args...)=>
        unless /[.]/.test signal
          throw new Error 'signal must be with dot (for example `billing.pay-order`)'
        [macro_signal] = signal.split '.'
        for own className, classObject of classes[@moduleName()]::
          do (className, classObject)->
            subscribers = []
            subscribers = subscribers.concat classObject["_#{className}_subs"]?[signal] ? []
            subscribers = subscribers.concat classObject["_#{className}_subs"]?["#{macro_signal}.*"] ? []
            if subscribers.length > 0
              subscribers.forEach ({methodName, opts:_opts})->
                if _opts.invoke is yes
                  classObject[methodName]?.apply classObject, args
                else
                  classObject.delay(opts)[methodName]? args...

    @sub: (signal, args...)->
      @["_#{@name}_subs"] ?= {}
      @["_#{@name}_subs"][signal] ?= []
      [methods, collections, ..., lambda] = args
      if args.length is 3
        opts = invoke: collections.invoke
        delete collections.invoke
      else
        opts = {}
      if _.isFunction lambda
        nextIndex = _.flatten(_.values(@_subs())).length
        methodName = "subFunctionIn#{@name}_#{nextIndex}"
        @classMethod methodName, args...
      else
        methodName = lambda
      @["_#{@name}_subs"][signal].push
        methodName: methodName
        opts: opts

    @_subs: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @_subs AbstractClass.__super__.constructor
      extend {}
      , (fromSuper ? {})
      , (AbstractClass["_#{AbstractClass.name}_subs"] ? {})

    @subscribe: ->
      @sub arguments...

    @delayJob: @method [], ->
      read: ['_queues'], write: ['_jobs']
    , (data, options = {})->
      queues  = require '@arangodb/foxx/queues'
      {cleanCallback} = require('./utils/cleanConfig') FoxxMC

      script =
        mount: @Module.context.mount
        name: 'delayed_job'
      script.backOff = options.backOff if options.backOff?
      script.maxFailures = options.maxFailures if options.maxFailures?
      script.schema = options.schema if options.schema?
      script.preprocess = options.preprocess if options.preprocess?
      script.repeatTimes = options.repeatTimes if options.repeatTimes?
      script.repeatUntil = options.repeatUntil if options.repeatUntil?
      script.repeatDelay = options.repeatDelay if options.repeatDelay?

      opts =
        success: cleanCallback "success: `delayed_job`"
        failure: cleanCallback "failure: `delayed_job`"
      opts.delayUntil = options.delayUntil if options.delayUntil?
      opts.maxFailures = options.maxFailures if options.maxFailures?
      opts.repeatTimes = options.repeatTimes if options.repeatTimes?
      opts.repeatUntil = options.repeatUntil if options.repeatUntil?
      opts.repeatDelay = options.repeatDelay if options.repeatDelay?

      console.log '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$123450000', opts
      queues.get(options.queue ? 'delayed_jobs').push script, data, opts
      return

    @delay: @method ['.delayJob'], (opts = null)->
      self = @
      obj = {}
      for key, value of @
        do (methodName=key, value)->
          if methodName isnt 'delay' and _.isFunction value
            obj[methodName] = (args...)->
              data =
                moduleName: self.moduleName()
                className:  self.name
                methodName: methodName
                args: args
              self.delayJob data, opts
      obj

    @locks: {}

    @_mergeLocks: (collections, otherCollections)->
      (otherCollections.read ? []).forEach (name)=>
        if new RegExp('^[_].*').test name
          collectionName = name
        else
          collectionName = @Module.context.collectionName name
        unless collectionName in collections.read
          collections.read.push collectionName

      (otherCollections.write ? []).forEach (name)=>
        if new RegExp('^[_].*').test name
          collectionName = name
        else
          collectionName = @Module.context.collectionName name
        unless collectionName in collections.write
          collections.write.push collectionName
      collections

    @mergeLocks: (collections, otherCollections)->
      (otherCollections.read ? []).forEach (collectionName)->
        unless collectionName in collections.read
          collections.read.push collectionName

      (otherCollections.write ? []).forEach (collectionName)->
        unless collectionName in collections.write
          collections.write.push collectionName
      collections

    @getLocksFor: (keys, processedMethods = [])->
      unless Array.isArray keys
        keys = [keys]
      self = @
      hash = crypto.sha1 String keys
      @locks["#{@name}|#{hash}"] ?= do =>
        collections = {read:[], write:[]}
        keys.forEach (key) =>
          methods = null
          moduleName = null
          if /.*[:][:].*/.test(key) and /.*[.].*/.test key
            [moduleName, key] = key.split '::'
          if key.split('::').length is 3
            [moduleName, __className, __methodName] = key.split '::'
            key = "#{__className}::#{__methodName}"
          unless moduleName?
            moduleName = @moduleName()
          if /.*[#].*/.test key
            [..., signal] = key.split '#'
            [macro_signal] = signal.split '.'
            for own className, AbstractClass of classes[moduleName]::
              do (className, AbstractClass)->
                subscribers = []
                subscribers = subscribers.concat AbstractClass["_#{className}_subs"]?[signal] ? []
                subscribers = subscribers.concat AbstractClass["_#{className}_subs"]?["#{macro_signal}.*"] ? []
                if subscribers.length > 0
                  subscribers.forEach ({methodName, opts})->
                    if opts.invoke is yes
                      (methods ?= []).push "#{className}.#{methodName}"

          else if /.*[.].*/.test key
            [className, methodName] = key.split '.'
            className = self.name if className is ''
            AbstractClass = classes[moduleName]::[className]

            unless "#{className}.#{methodName}" in processedMethods
              processedMethods.push "#{className}.#{methodName}"

              _collections = AbstractClass["#{methodName}Collections"]? []...
              _collections ?= AbstractClass["#{methodName}Collections"] ? {}
              _collections = extend {}, _collections, AbstractClass["_#{methodName}Collections"]?([]...) ? {}

              collections = @_mergeLocks collections, _collections

              methods = AbstractClass["#{methodName}Methods"]? []...
              methods ?= AbstractClass["#{methodName}Methods"] ? []
              methods = extend [], methods, AbstractClass["_#{methodName}Methods"]?([]...) ? []

              # console.log '$%$%$%$%$% collections666.', collections, methods

          else if /.*[:][:].*/.test key
            [className, instanceMethodName] = key.split '::'
            className = self.name if className is ''
            # console.log '????????????/ moduleName', moduleName, classes[moduleName]
            AbstractClass = classes[moduleName]::[className]

            unless "#{className}::#{instanceMethodName}" in processedMethods
              processedMethods.push "#{className}::#{instanceMethodName}"

              _collections = AbstractClass::["#{instanceMethodName}Collections"]? []...
              _collections ?= AbstractClass::["#{instanceMethodName}Collections"] ? {}
              _collections = extend {}, _collections, AbstractClass::["_#{instanceMethodName}Collections"]?([]...) ? {}

              collections = @_mergeLocks collections, _collections

              methods = AbstractClass::["#{instanceMethodName}Methods"]? []...
              methods ?= AbstractClass::["#{instanceMethodName}Methods"] ? []
              methods = extend [], methods, AbstractClass::["_#{instanceMethodName}Methods"]?([]...) ? []

          methods?.forEach (_key)=>
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
                        __collections = OtherAbstractClass.getLocksFor "#{_className}.#{methodName}", processedMethods
                        collections = @mergeLocks collections, __collections
              return
            if /.*[.].*/.test _key
              [_className, _methodName] = _key.split '.'
            else if /.*[:][:].*/.test _key
              [_className, _instanceMethodName] = _key.split '::'
            _className = AbstractClass.name if _className is ''
            OtherAbstractClass = classes[_moduleName]::[_className]
            __collections = OtherAbstractClass.getLocksFor _key, processedMethods
            collections = @mergeLocks collections, __collections

        # console.log '$%$%$%$%$% collections666', self.name, keys, collections
        collections

    constructor: ->
      if @constructor.chains.constructor is Function
        chains = @constructor._chains()
        if chains? and chains.constructor is Array
          # console.log 'DFASDFASDFffffffffffff9898 chains', chains
          chains.forEach (methodName)=>
            @["_#{methodName}"] = @[methodName]
            @[methodName] = ->
              @callAsChain methodName, arguments...
      return

    callAsChain: (methodName, args...) ->
      try
        initialData = @initialAction methodName, args...
        if initialData?.constructor isnt Array
          initialData = [initialData]
        data = @beforeAction methodName, initialData...
        if data?.constructor isnt Array
          data = [data]
        result = @["_#{methodName}"]? data...
        afterResult = @afterAction methodName, result
        @finallyAction methodName, afterResult
      catch err
        @errorInAction methodName, err
        throw err

    collectionsInChain: (methodName)->
      obj = read: [], write: []
      updateObj = (_method)=>
        if @[_method]? and @[_method].constructor is Function
          {read, write} = @[_method]()
          if read?
            if read.constructor is String
              read = [read]
            obj.read = _.uniq obj.read.concat read
          if write?
            if write.constructor is String
              write = [write]
            obj.write = _.uniq obj.write.concat write
        return
      @constructor.initialHooks().forEach ({method, type, actions})->
        if type is 'all'
          updateObj "#{method}Collections"
        else if type is 'only' and methodName in actions
          updateObj "#{method}Collections"
        else if type is 'except' and methodName not in actions
          updateObj "#{method}Collections"
        return
      @constructor.beforeHooks().forEach ({method, type, actions})->
        if type is 'all'
          updateObj "#{method}Collections"
        else if type is 'only' and methodName in actions
          updateObj "#{method}Collections"
        else if type is 'except' and methodName not in actions
          updateObj "#{method}Collections"
        return
      # updateObj "_#{method}Collections"
      @constructor.afterHooks().forEach ({method, type, actions})->
        if type is 'all'
          updateObj "#{method}Collections"
        else if type is 'only' and methodName in actions
          updateObj "#{method}Collections"
        else if type is 'except' and methodName not in actions
          updateObj "#{method}Collections"
        return
      @constructor.finallyHooks().forEach ({method, type, actions})->
        if type is 'all'
          updateObj "#{method}Collections"
        else if type is 'only' and methodName in actions
          updateObj "#{method}Collections"
        else if type is 'except' and methodName not in actions
          updateObj "#{method}Collections"
        return
      obj

    methodsInChain: (methodName)->
      array = []
      updateArray = (_method)=>
        if @[_method]? and @[_method].constructor is Function
          _array = @[_method]()
          if _array?.constructor isnt Array
            _array = [_array]
          array = _.uniq array.concat _array
        return
      @constructor.initialHooks().forEach ({method, type, actions})=>
        if type is 'all'
          updateArray "#{method}Methods"
        else if type is 'only' and methodName in actions
          updateArray "#{method}Methods"
        else if type is 'except' and methodName not in actions
          updateArray "#{method}Methods"
        return
      @constructor.beforeHooks().forEach ({method, type, actions})=>
        if type is 'all'
          updateArray "#{method}Methods"
        else if type is 'only' and methodName in actions
          updateArray "#{method}Methods"
        else if type is 'except' and methodName not in actions
          updateArray "#{method}Methods"
        return
      # updateArray "_#{method}Methods"
      @constructor.afterHooks().forEach ({method, type, actions})=>
        if type is 'all'
          updateArray "#{method}Methods"
        else if type is 'only' and methodName in actions
          updateArray "#{method}Methods"
        else if type is 'except' and methodName not in actions
          updateArray "#{method}Methods"
        return
      @constructor.finallyHooks().forEach ({method, type, actions})=>
        if type is 'all'
          updateArray "#{method}Methods"
        else if type is 'only' and methodName in actions
          updateArray "#{method}Methods"
        else if type is 'except' and methodName not in actions
          updateArray "#{method}Methods"
        return
      # console.log '%%%%%%%%%%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@ methodsInChain', array
      array


    @initialHook: (method, options = {})->
      @["_#{@name}_initialHooks"] ?= []
      if options.only
        @["_#{@name}_initialHooks"].push method: method, type: 'only', actions: options.only
        return
      else if options.except
        @["_#{@name}_initialHooks"].push method: method, type: 'except', actions: options.except
        return
      else
        @["_#{@name}_initialHooks"].push method: method, type: 'all'
        return

    @beforeHook: (method, options = {})->
      @["_#{@name}_beforeHooks"] ?= []
      if options.only
        @["_#{@name}_beforeHooks"].push method: method, type: 'only', actions: options.only
        return
      else if options.except
        @["_#{@name}_beforeHooks"].push method: method, type: 'except', actions: options.except
        return
      else
        @["_#{@name}_beforeHooks"].push method: method, type: 'all'
        return

    @afterHook: (method, options = {})->
      @["_#{@name}_afterHooks"] ?= []
      if options.only
        @["_#{@name}_afterHooks"].push method: method, type: 'only', actions: options.only
        return
      else if options.except
        @["_#{@name}_afterHooks"].push method: method, type: 'except', actions: options.except
        return
      else
        @["_#{@name}_afterHooks"].push method: method, type: 'all'
        return

    @finallyHook: (method, options = {})->
      @["_#{@name}_finallyHooks"] ?= []
      if options.only
        @["_#{@name}_finallyHooks"].push method: method, type: 'only', actions: options.only
        return
      else if options.except
        @["_#{@name}_finallyHooks"].push method: method, type: 'except', actions: options.except
        return
      else
        @["_#{@name}_finallyHooks"].push method: method, type: 'all'
        return

    @errorHook: (method, options = {})->
      @["_#{@name}_errorHooks"] ?= []
      if options.only
        @["_#{@name}_errorHooks"].push method: method, type: 'only', actions: options.only
        return
      else if options.except
        @["_#{@name}_errorHooks"].push method: method, type: 'except', actions: options.except
        return
      else
        @["_#{@name}_errorHooks"].push method: method, type: 'all'
        return

    @initialHooks: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @initialHooks AbstractClass.__super__.constructor
      _.uniq [].concat(fromSuper ? [])
        .concat(AbstractClass["_#{AbstractClass.name}_initialHooks"] ? [])

    @beforeHooks: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @beforeHooks AbstractClass.__super__.constructor
      _.uniq [].concat(fromSuper ? [])
        .concat(AbstractClass["_#{AbstractClass.name}_beforeHooks"] ? [])

    @afterHooks: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @afterHooks AbstractClass.__super__.constructor
      _.uniq [].concat(fromSuper ? [])
        .concat(AbstractClass["_#{AbstractClass.name}_afterHooks"] ? [])

    @finallyHooks: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @finallyHooks AbstractClass.__super__.constructor
      _.uniq [].concat(fromSuper ? [])
        .concat(AbstractClass["_#{AbstractClass.name}_finallyHooks"] ? [])

    @errorHooks: (AbstractClass = null)->
      AbstractClass ?= @
      fromSuper = if AbstractClass.__super__?
        @errorHooks AbstractClass.__super__.constructor
      _.uniq [].concat(fromSuper ? [])
        .concat(AbstractClass["_#{AbstractClass.name}_errorHooks"] ? [])

    initialAction: (action, data...)->
      # console.log 'DFASDFASDFffffffffffff9898 _beforeHooks'
      @constructor.initialHooks().forEach ({method, type, actions})=>
        if type is 'all'
          data = do (_data=data)=>
            if _data?.constructor isnt Array
              _data = [_data]
            if @[method]?
              @[method].chainName = action
              res = @[method] _data...
              delete @[method].chainName
              res
            else
              _data
        else if type is 'only' and action in actions
          data = do (_data=data)=>
            if _data?.constructor isnt Array
              _data = [_data]
            if @[method]?
              @[method].chainName = action
              res = @[method] _data...
              delete @[method].chainName
              res
            else
              _data
        else if type is 'except' and action not in actions
          data = do (_data=data)=>
            if _data?.constructor isnt Array
              _data = [_data]
            if @[method]?
              @[method].chainName = action
              res = @[method] _data...
              delete @[method].chainName
              res
            else
              _data
        return
      data

    beforeAction: (action, data...)->
      # console.log 'DFASDFASDFffffffffffff9898 _beforeHooks'
      @constructor.beforeHooks().forEach ({method, type, actions})=>
        if type is 'all'
          data = do (_data=data)=>
            if _data?.constructor isnt Array
              _data = [_data]
            if @[method]?
              @[method].chainName = action
              res = @[method] _data...
              delete @[method].chainName
              res
            else
              _data
        else if type is 'only' and action in actions
          data = do (_data=data)=>
            if _data?.constructor isnt Array
              _data = [_data]
            if @[method]?
              @[method].chainName = action
              res = @[method] _data...
              delete @[method].chainName
              res
            else
              _data
        else if type is 'except' and action not in actions
          data = do (_data=data)=>
            if _data?.constructor isnt Array
              _data = [_data]
            if @[method]?
              @[method].chainName = action
              res = @[method] _data...
              delete @[method].chainName
              res
            else
              _data
        return
      data

    afterAction: (action, data)->
      # console.log 'DFASDFASDFffffffffffff9898 _afterHooks', action, data
      @constructor.afterHooks().forEach ({method, type, actions})=>
        if type is 'all'
          data = do (_data=data)=>
            if @[method]?
              @[method].chainName = action
              res = @[method] _data
              delete @[method].chainName
              res
            else
              _data
        else if type is 'only' and action in actions
          data = do (_data=data)=>
            if @[method]?
              @[method].chainName = action
              res = @[method] _data
              delete @[method].chainName
              res
            else
              _data
        else if type is 'except' and action not in actions
          data = do (_data=data)=>
            if @[method]?
              @[method].chainName = action
              res = @[method] _data
              delete @[method].chainName
              res
            else
              _data
        return
      # console.log 'DFASDFASDFffffffffffff9898============ _afterHooks', action, data
      data

    finallyAction: (action, data)->
      # console.log 'DFASDFASDFffffffffffff9898 _finallyHooks', action, data
      @constructor.finallyHooks().forEach ({method, type, actions})=>
        if type is 'all'
          data = do (_data=data)=>
            if @[method]?
              @[method].chainName = action
              res = @[method] _data
              delete @[method].chainName
              res
            else
              _data
        else if type is 'only' and action in actions
          data = do (_data=data)=>
            if @[method]?
              @[method].chainName = action
              res = @[method] _data
              delete @[method].chainName
              res
            else
              _data
        else if type is 'except' and action not in actions
          data = do (_data=data)=>
            if @[method]?
              @[method].chainName = action
              res = @[method] _data
              delete @[method].chainName
              res
            else
              _data
        return
      # console.log 'DFASDFASDFffffffffffff9898===== _finallyHooks', action, data
      data

    errorInAction: (action, err)->
      # console.log 'DFASDFASDFffffffffffff9898 errorInAction'
      @constructor.errorHooks().forEach ({method, type, actions})=>
        if type is 'all'
          err = do (_err=err)=>
            if @[method]?
              @[method].chainName = action
              res = @[method] _err
              delete @[method].chainName
              res
            else
              _err
        else if type is 'only' and action in actions
          err = do (_err=err)=>
            if @[method]?
              @[method].chainName = action
              res = @[method] _err
              delete @[method].chainName
              res
            else
              _err
        else if type is 'except' and action not in actions
          err = do (_err=err)=>
            if @[method]?
              @[method].chainName = action
              res = @[method] _err
              delete @[method].chainName
              res
            else
              _err
        return
      err

    @__keywords: ['constructor', 'prototype', '__super__']

    @defineInstanceDescriptors: (definitions)->
      for own methodName, funct of definitions when methodName not in @__keywords
        @.__super__[methodName] = funct

        if not @::hasOwnProperty methodName
          @::[methodName] = funct
      return

    @defineClassDescriptors: (definitions)->
      for own methodName, funct of definitions when methodName not in @__keywords
        @.__super__.constructor[methodName] = funct

        if not @hasOwnProperty methodName
          @[methodName] = funct
      return

    @resetParentSuper: (_mixin)->
      __mixin = eval "(
        function() {
          function #{_mixin.name}() {
            #{_mixin.name}.__super__.constructor.apply(this, arguments);
          }
          return #{_mixin.name};
      })();"
      reserved_words = Object.keys CoreObject
      for own k, v of _mixin when k not in reserved_words
        __mixin[k] = v
      for own _k, _v of _mixin.prototype when _k not in @__keywords
        __mixin::[_k] = _v

      for own k, v of @.__super__.constructor when k isnt 'including'
        __mixin[k] = v unless __mixin[k]
      for own _k, _v of @.__super__ when _k not in @__keywords
        __mixin::[_k] = _v unless __mixin::[_k]
      __mixin::constructor.__super__ = @.__super__
      return __mixin

      # tmp = class extends @__super__
      # reserved_words = Object.keys CoreObject
      # for own k, v of _mixin when k not in reserved_words
      #   tmp[k] = v
      # for own _k, _v of _mixin.prototype when _k not in @__keywords
      #   tmp::[_k] = _v
      # return tmp

    @include: (mixins...)->
      if Array.isArray mixins[0]
        mixins = mixins[0]
      mixins.forEach (mixin)=>
        if not mixin
          throw new Error 'Supplied mixin was not found'
        if mixin.constructor isnt Function
          throw new Error 'Supplied mixin must be a class'
        if mixin.__super__.constructor.name isnt 'Mixin'
          throw new Error 'Supplied mixin must be a subclass of FoxxMC::Mixin'

        __mixin = @resetParentSuper mixin

        @.__super__ = __mixin::

        @defineClassDescriptors __mixin
        @defineInstanceDescriptors __mixin::

        __mixin.including?.apply @
      @

    @beforeAllEvents: (name)->
      @["beforeAllEvents_#{@_currentSM}"] = name
    @afterAllTransitions: (name)->
      @["afterAllTransitions_#{@_currentSM}"] = name
    @afterAllEvents: (name)->
      @["afterAllEvents_#{@_currentSM}"] = name
    @errorOnAllEvents: (name)->
      @["errorOnAllEvents_#{@_currentSM}"] = name

    @state: (name, {beforeExit, exit, beforeEnter, enter, afterExit, afterEnter, initial, attr}={})->
      if initial
        attr ?= 'state'
        attr = "#{@_currentSM}_#{attr}" if @_currentSM isnt 'default'
        @["_#{@_currentSM}_state_attr"] = attr
        @::[attr] = name
      if beforeExit
        @["beforeExit_#{@_currentSM}_#{name}"] = beforeExit
      if exit
        @["exit_#{@_currentSM}_#{name}"] = exit
      if beforeEnter
        @["beforeEnter_#{@_currentSM}_#{name}"] = beforeEnter
      if enter
        @["enter_#{@_currentSM}_#{name}"] = enter
      if afterExit
        @["afterExit_#{@_currentSM}_#{name}"] = afterExit
      if afterEnter
        @["afterEnter_#{@_currentSM}_#{name}"] = afterEnter
      return

    @event: (name, {before, guard, if:ifCond, unless:unlessCond, success, after, error}={}, cb)->
      @_currentEvent = name
      cb.apply @, []
      @_currentEvent = null
      _currentSM = @_currentSM
      @::["_#{_currentSM}_#{name}Methods"] = ->
        _.uniq(
          _.compact [
            @constructor["beforeAllEvents_#{_currentSM}"] ? null
            before ? null
            guard ? null
            ifCond ? null
            unlessCond ? null
            success ? null
            after ? null
            @constructor["afterAllEvents_#{_currentSM}"] ? null
            error ? null
            @constructor["errorOnAllEvents_#{_currentSM}"] ? null
          ]
            .map (methodName)->
              "::#{methodName}"
            .concat @constructor["transitions_#{_currentSM}_#{name}"].map (transition)->
              "::#{transition}"
        )
      @::["_#{_currentSM}_#{name}"] = (args...)->
        try
          @[@constructor["beforeAllEvents_#{_currentSM}"]]? []...
          @[before]? []...
          if not guard || (guard && @[guard] []...) || (ifCond && @[ifCond] []...) || (unlessCond && not @[unlessCond] []...)
            @constructor["transitions_#{_currentSM}_#{name}"].forEach (transition)=>
              @[transition]? args...
              return
            @[success]? []...
            @[after]? []...
            @[@constructor["afterAllEvents_#{_currentSM}"]]? []...
        catch err
          @[error]? [err]...
          @[@constructor["errorOnAllEvents_#{_currentSM}"]]? [err]...
        return
      @::["#{name}Methods"] ?= ->
        @constructor._smNames.map (smName)-> "::_#{smName}_#{name}"
      @::[name] ?= (args...) ->
        @constructor._smNames.forEach (smName)=>
          @["_#{smName}_#{name}"]? args...
      return

    @transition: (_from, to, {guard, if:ifCond, unless:unlessCond, after, success}={})->
      constructor = @
      _currentSM = @_currentSM
      _currentEvent = @_currentEvent
      @["transitions_#{_currentSM}_#{_currentEvent}"] ?= []
      if _from.constructor isnt Array
        _from = [_from]
      if to.constructor isnt String
        throw new Error 'transition `new_state` must be a string'

      name = "transition_#{_currentSM}_#{_currentEvent}|#{_from.join ','}|#{to}"

      @::["#{name}Methods"] = ->
        state_attr = @constructor["_#{_currentSM}_state_attr"]
        state_attr ?= if _currentSM is 'default'
          'state'
        else
          "#{_currentSM}_state"
        from = @[state_attr]
        _.uniq(
          _.compact [
            guard ? null
            ifCond ? null
            unlessCond ? null
            @constructor["beforeExit_#{_currentSM}_#{from}"]? null
            @constructor["exit_#{_currentSM}_#{from}"] ? null
            @constructor["afterAllTransitions_#{_currentSM}"] ? null
            @constructor["beforeEnter_#{_currentSM}_#{to}"] ? null
            @constructor["enter_#{_currentSM}_#{to}"] ? null
            success ? null
            after ? null
            @constructor["afterExit_#{_currentSM}_#{from}"] ? null
            @constructor["afterEnter_#{_currentSM}_#{to}"] ? null
          ]
            .map (methodName)->
              "::#{methodName}"
        )

      @::[name] = (args...)->
        state_attr = @constructor["_#{_currentSM}_state_attr"]
        state_attr ?= if _currentSM is 'default'
          'state'
        else
          "#{_currentSM}_state"
        unless @[state_attr] in _from
          throw new Error "current `state` is #{@[state_attr]} and is not includes in `[#{_from.join ','}]`"
        from = @[state_attr]
        if not guard || (guard && @[guard] []...) || (ifCond && @[ifCond] []...) || (unlessCond && not @[unlessCond] []...)
          @[@constructor["beforeExit_#{_currentSM}_#{from}"]]? []...
          @[@constructor["exit_#{_currentSM}_#{from}"]]? []...
          @[state_attr] = to
          @[@constructor["afterAllTransitions_#{_currentSM}"]]? []...
          @[@constructor["beforeEnter_#{_currentSM}_#{to}"]]? []...
          @[@constructor["enter_#{_currentSM}_#{to}"]]? []...
          @[after]? args...
          @save?()
          @[success]? []...
          @[@constructor["afterExit_#{_currentSM}_#{from}"]]? []...
          @[@constructor["afterEnter_#{_currentSM}_#{to}"]]? []...
        return

      @["transitions_#{_currentSM}_#{_currentEvent}"].push name
      return

    @StateMachine: (name, config)->
      unless config
        config = name
        name = 'default'
      @_currentSM = name
      @_smNames ?= []
      @_smNames.push name
      config.apply @, []
      @_currentSM = 'default'
      return


  FoxxMC::CoreObject.initialize()
