# 1. Некоторая миграция должна создать очередь, чтобы ей потом можно было пользоваться, например Resque.create(<queueName>, <concurrency>)
# адаптер для аранги реализованный в виде миксина для Resque класса спроецирует запрос с использованием @arango/queue
# адаптер для nodejs просто сохранит эти данные в какую нибудь базу данных (чтобы в нужный момент к ним обратиться и заиспользовать)
# 2. В аранго ничего делать в этом пункте не надо, движок базы данных сам будет заниматься менеджментом очередей и будет плодить потоки выполнения. Для nodejs при старте сервера надо проинициализировать Agenda сервис - взять из базы данных сохраненные <queueName> и <concurrency> и задефайнить хендлеры - внутри хендлера из принимаемых данных надо вычленить имя запускаемого скрипта, сделать require(<scriptName>) и заэкзекютить этот скрипт передав в него все данные поступившие в хендлер. (Agenda - должен покрывать функционал аранги по менеджменту очердей.)
# 3. класс Queue будет работать аналогично Record классу - проксировать вызовы методов к Resque классу (чтобы срабатывала нужная платформозависимая логика из миксина)
# 4. для job объектов не будет отдельного класса, потому что у них не будет никаких спец-методов - т.е. они будут чистыми структурами (обычный json объект)


###
```coffee
module.exports = (Module)->
  class ApplicationResque extends Module::Resque
    @inheritProtected()
    @include Module::ArangoResqueMixin # в этом миксине должны быть реализованы платформозависимые методы, которые будут посылать нативные запросы к реальной базе данных

    @module Module

  return ApplicationResque.initialize()
```

```coffee
module.exports = (Module)->
  {RESQUE} = Module::

  class PrepareModelCommand extends Module::SimpleCommand
    @inheritProtected()

    @module Module

    @public execute: Function,
      default: ->
        #...
        @facade.registerProxy Module::ApplicationResque.new RESQUE,
          <config key>: <config value>
        #...

  PrepareModelCommand.initialize()
```
###

module.exports = (Module)->
  {
    AnyT
    FuncG, SubsetG, MaybeG, UnionG, ListG
    QueueInterface, ResqueInterface
    CoreObject
  } = Module::


  class Queue extends CoreObject
    @inheritProtected()
    @implements QueueInterface
    @module Module

    # конструктор принимает второй аргумент, ссылку на resque proxy.
    @public resque: ResqueInterface
    @public name: String
    @public concurrency: Number

    @public @async delay: FuncG([String, AnyT, MaybeG Number], UnionG String, Number),
      default: (scriptName, data, delayUntil)->
        return yield @resque.delay @name, scriptName, data, delayUntil

    @public @async push: FuncG([String, AnyT, MaybeG Number], UnionG String, Number),
      default: (scriptName, data, delayUntil)->
        return yield @resque.pushJob @name, scriptName, data, delayUntil

    @public @async get: FuncG([UnionG String, Number], MaybeG Object),
      default: (jobId)->
        return yield @resque.getJob @name, jobId

    @public @async delete: FuncG([UnionG String, Number], Boolean),
      default: (jobId)->
        return yield @resque.deleteJob @name, jobId

    @public @async abort: FuncG([UnionG String, Number]),
      default: (jobId)->
        yield @resque.abortJob @name, jobId
        yield return

    @public @async all: FuncG([MaybeG String], ListG Object),
      default: (scriptName)->
        return yield @resque.allJobs @name, scriptName

    @public @async pending: FuncG([MaybeG String], ListG Object),
      default: (scriptName)->
        return yield @resque.pendingJobs @name, scriptName

    @public @async progress: FuncG([MaybeG String], ListG Object),
      default: (scriptName)->
        return yield @resque.progressJobs @name, scriptName

    @public @async completed: FuncG([MaybeG String], ListG Object),
      default: (scriptName)->
        return yield @resque.completedJobs @name, scriptName

    @public @async failed: FuncG([MaybeG String], ListG Object),
      default: (scriptName)->
        return yield @resque.failedJobs @name, scriptName

    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], QueueInterface),
      default: (Module, replica)->
        if replica?.class is @name and replica?.type is 'instance'
          Facade = Module::ApplicationFacade ? Module::Facade
          facade = Facade.getInstance replica.multitonKey
          resque = facade.retrieveProxy replica.resqueName
          instance = yield resque.get replica.name
          yield return instance
        else
          return yield @super Module, replica

    @public @static @async replicateObject: FuncG(QueueInterface, Object),
      default: (instance)->
        replica = yield @super instance
        ipsMultitonKey = Symbol.for '~multitonKey'
        replica.multitonKey = instance.resque[ipsMultitonKey]
        replica.resqueName = instance.resque.getProxyName()
        replica.name = instance.name
        yield return replica

    @public init: FuncG([Object, ResqueInterface]),
      default: (aoProperties, aoResque) ->
        @super arguments...
        @resque = aoResque

        for own vsAttrName, voAttrValue of aoProperties
          @[vsAttrName] = voAttrValue
        return


    @initialize()
