_             = require 'lodash'
extend        = require './utils/extend'
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

    constructor: () -> # именно в конструкторе надо через методы beforeHook и afterHook объявить методы инстанса класса, которые будут использованы в качестве звеньев цепей
      super

    beforeVerify: ()->

    beforeCount: ()->

    afterVerify: (data)->
      data

    afterCount: (data)->
      data
  ```
###

###
  ````
    class Aaa extends Mixin
      k: ()->
        console.trace()
        console.log '^^Aaa::k', @yy
      @hh: ()->
        console.log '^^Aaa.hh'


    class Ccc extends Mixin
      @jk: 6
      yy: 90
      @kl: ()->
      @hh: ()->
        console.log 'before super @hh() in Ccc.hh'
        super
        console.log 'after super @hh() in Ccc.hh'
      k: ()->
        console.log 'before super k() in Ccc::k'
        super
        console.log 'after super k() in Ccc::k'


    class Jjj extends Mixin
      @ll: 6
      oo: ()->
        this.k()
      #k: ()->
      #  console.log 'before super k() in Jjj::k'
      #  super
      #  console.log 'after super k() in Jjj::k'


    class Kkk extends Mixin
      @ll: 6
      oo: ()->
        this.k()
      k: ()->
        console.log 'before super k() in Kkk::k', @yy
        super
        console.log 'after super k() in Kkk::k'
      #@hh: ()->
      #  console.log 'before super @hh() in Kkk.hh'
      #  super
      #  console.log 'after super @hh() in Kkk.hh'


    class Lll extends Kkk
      @ll: 6
      oo: ()->
        this.k()
      k: ()->
        console.log 'before super k() in Lll::k'
        super
        console.log 'after super k() in Lll::k'
      @hh: ()->
        console.log 'before super @hh() in Lll.hh'
        super
        console.log 'after super @hh() in Lll.hh'


    class Iii extends Mixin
      @including: ()->
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
      k: ()->
        console.log 'before super k() in Bbb::k'
        super
        console.log 'after super k() in Bbb::k'
      @hh: ()->
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
  @StateMachine 'default', ()->
    @before_all_events 'before_all_events'
    @after_all_transitions 'after_all_transitions'
    @after_all_events 'after_all_events'
    @error_on_all_events 'error_on_all_events'
    @state 'first',
      initial: yes
      before_exit: 'before_exit_from_first'
      after_exit: 'after_exit_from_first'
    @state 'sleeping',
      before_exit: 'before_exit_from_sleeping'
      after_exit: 'after_exit_from_sleeping'
    @state 'running',
      before_enter: 'before_enter_to_running'
      after_enter: 'after_enter_from_running'
    @event 'run',
      before: 'before_run'
      after: 'after_run'
      error: 'error_on_run'
     , ()=>
        @transition ['first', 'second'], 'third',
          guard: 'check_something_condition'
          after: 'after_first_second_to_third'
        @transition 'third', 'running',
          if: 'check_third_condition'
          after: 'after_third_to_running'
        @transition ['first', 'third', 'sleeping', 'running'], 'super_running',
          unless: 'check_third_condition'
          after: 'after_sleeping_to_running'

  check_something_condition: ()->
    console.log '!!!???? check_something_condition'
    yes
  check_third_condition: ()->
    console.log '!!!???? check_third_condition'
    yes
  before_exit_from_sleeping: ()->
    console.log 'DFSDFSD before_exit_from_sleeping'
  before_exit_from_first: ()->
    console.log 'DFSDFSD before_exit_from_first'
  after_exit_from_sleeping: ()->
    console.log 'DFSDFSD after_exit_from_sleeping'
  after_exit_from_first: ()->
    console.log 'DFSDFSD after_exit_from_first'
  before_enter_to_running: ()->
    console.log 'DFSDFSD before_enter_to_running'
  before_run: ()->
    console.log 'DFSDFSD before_run'
  after_run: ()->
    console.log 'DFSDFSD after_run'
  after_first_second_to_third: (first_arg, second_arg)->
    console.log first_arg, second_arg # => {key: 'value'}, 125
    console.log 'DFSDFSD after_first_second_to_third'
  after_third_to_running: (first_arg, second_arg)->
    console.log first_arg, second_arg # => {key: 'value'}, 125
    console.log 'DFSDFSD after_third_to_running'
  after_sleeping_to_running: (first_arg, second_arg)->
    console.log first_arg, second_arg # => {key: 'value'}, 125
    console.log 'DFSDFSD after_sleeping_to_running'
  after_running_to_sleeping: ()->
    console.log 'DFSDFSD after_running_to_sleeping'

  before_all_events: ()->
    console.log 'DFSDFSD before_all_events'
  after_all_transitions: ()->
    console.log 'DFSDFSD after_all_transitions'
  after_all_events: ()->
    console.log 'DFSDFSD after_all_events'
  error_on_all_events: (err)->
    console.log 'DFSDFSD error_on_all_events', err, err.stack
  error_on_run: ()->
    console.log 'DFSDFSD error_on_run'

tomato = new Tomato()
tomato.run({key: 'value'}, 125) # можно передать как аргументы какие нибудь данные, они будут переданы внутырь коллбеков указанных на транзишенах в ключах :after
console.log 'tomato.state', tomato.state
###

###
StateMachine flow

try
  event           before_all_events
  event           before
  event           guard
    transition      guard
    old_state       before_exit
    old_state       exit
    ...update state...
                    after_all_transitions
    transition      after
    new_state       before_enter
    new_state       enter
    ...save state...
    transition      success             # if persist successful
    old_state       after_exit
    new_state       after_enter
  event           success             # if persist successful
  event           after
  event           after_all_events
catch
  event           error
  event           error_on_all_events
###

###
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
      {cleanCallback} = require './utils/cleanConfig'
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
      @::["_#{methodName}Collections"] = ()->
        @collectionsInChain methodName
      @::["_#{methodName}Methods"] = ()->
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

  save: ()->
    @

  @defineProperty: (name, definition)->
    Object.defineProperty @::, name, definition

  @defineClassProperty: (name, definition)->
    Object.defineProperty @, name, definition

  @defineProperty 'Module', ->
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
    {cleanCallback} = require './utils/cleanConfig'

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

  constructor: ()->
    if @constructor.chains.constructor is Function
      chains = @constructor._chains()
      if chains? and chains.constructor is Array
        # console.log 'DFASDFASDFffffffffffff9898 chains', chains
        chains.forEach (methodName)=>
          @["_#{methodName}"] = @[methodName]
          @[methodName] = ()->
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

  @before_all_events: (name)->
    @["before_all_events_#{@_currentSM}"] = name
  @after_all_transitions: (name)->
    @["after_all_transitions_#{@_currentSM}"] = name
  @after_all_events: (name)->
    @["after_all_events_#{@_currentSM}"] = name
  @error_on_all_events: (name)->
    @["error_on_all_events_#{@_currentSM}"] = name

  @state: (name, {before_exit, exit, before_enter, enter, after_exit, after_enter, initial, attr}={})->
    if initial
      attr ?= 'state'
      attr = "#{@_currentSM}_#{attr}" if @_currentSM isnt 'default'
      @["_#{@_currentSM}_state_attr"] = attr
      @::[attr] = name
    if before_exit
      @["before_exit_#{@_currentSM}_#{name}"] = before_exit
    if exit
      @["exit_#{@_currentSM}_#{name}"] = exit
    if before_enter
      @["before_enter_#{@_currentSM}_#{name}"] = before_enter
    if enter
      @["enter_#{@_currentSM}_#{name}"] = enter
    if after_exit
      @["after_exit_#{@_currentSM}_#{name}"] = after_exit
    if after_enter
      @["after_enter_#{@_currentSM}_#{name}"] = after_enter
    return

  @event: (name, {before, guard, if:if_cond, unless:unless_cond, success, after, error}={}, cb)->
    @_currentEvent = name
    cb.apply @, []
    @_currentEvent = null
    _currentSM = @_currentSM
    @::["_#{_currentSM}_#{name}Methods"] = ()->
      _.uniq(
        _.compact [
          @constructor["before_all_events_#{_currentSM}"] ? null
          before ? null
          guard ? null
          if_cond ? null
          unless_cond ? null
          success ? null
          after ? null
          @constructor["after_all_events_#{_currentSM}"] ? null
          error ? null
          @constructor["error_on_all_events_#{_currentSM}"] ? null
        ]
          .map (methodName)->
            "::#{methodName}"
          .concat @constructor["transitions_#{_currentSM}_#{name}"].map (transition)->
            "::#{transition}"
      )
    @::["_#{_currentSM}_#{name}"] = (args...)->
      try
        @[@constructor["before_all_events_#{_currentSM}"]]? []...
        @[before]? []...
        if not guard || (guard && @[guard] []...) || (if_cond && @[if_cond] []...) || (unless_cond && not @[unless_cond] []...)
          @constructor["transitions_#{_currentSM}_#{name}"].forEach (transition)=>
            @[transition]? args...
            return
          @[success]? []...
          @[after]? []...
          @[@constructor["after_all_events_#{_currentSM}"]]? []...
      catch err
        @[error]? [err]...
        @[@constructor["error_on_all_events_#{_currentSM}"]]? [err]...
      return
    @::["#{name}Methods"] ?= ()->
      @constructor._smNames.map (smName)-> "::_#{smName}_#{name}"
    @::[name] ?= (args...) ->
      @constructor._smNames.forEach (smName)=>
        @["_#{smName}_#{name}"]? args...
    return

  @transition: (_from, to, {guard, if:if_cond, unless:unless_cond, after, success}={})->
    constructor = @
    _currentSM = @_currentSM
    _currentEvent = @_currentEvent
    @["transitions_#{_currentSM}_#{_currentEvent}"] ?= []
    if _from.constructor isnt Array
      _from = [_from]
    if to.constructor isnt String
      throw new Error 'transition `new_state` must be a string'

    name = "transition_#{_currentSM}_#{_currentEvent}|#{_from.join ','}|#{to}"

    @::["#{name}Methods"] = ()->
      state_attr = @constructor["_#{_currentSM}_state_attr"]
      state_attr ?= if _currentSM is 'default'
        'state'
      else
        "#{_currentSM}_state"
      from = @[state_attr]
      _.uniq(
        _.compact [
          guard ? null
          if_cond ? null
          unless_cond ? null
          @constructor["before_exit_#{_currentSM}_#{from}"]? null
          @constructor["exit_#{_currentSM}_#{from}"] ? null
          @constructor["after_all_transitions_#{_currentSM}"] ? null
          @constructor["before_enter_#{_currentSM}_#{to}"] ? null
          @constructor["enter_#{_currentSM}_#{to}"] ? null
          success ? null
          after ? null
          @constructor["after_exit_#{_currentSM}_#{from}"] ? null
          @constructor["after_enter_#{_currentSM}_#{to}"] ? null
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
      if not guard || (guard && @[guard] []...) || (if_cond && @[if_cond] []...) || (unless_cond && not @[unless_cond] []...)
        @[@constructor["before_exit_#{_currentSM}_#{from}"]]? []...
        @[@constructor["exit_#{_currentSM}_#{from}"]]? []...
        @[state_attr] = to
        @[@constructor["after_all_transitions_#{_currentSM}"]]? []...
        @[@constructor["before_enter_#{_currentSM}_#{to}"]]? []...
        @[@constructor["enter_#{_currentSM}_#{to}"]]? []...
        @[after]? args...
        @save?()
        @[success]? []...
        @[@constructor["after_exit_#{_currentSM}_#{from}"]]? []...
        @[@constructor["after_enter_#{_currentSM}_#{to}"]]? []...
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


module.exports = FoxxMC::CoreObject.initialize()
