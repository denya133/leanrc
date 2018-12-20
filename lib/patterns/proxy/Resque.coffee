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
    DELAYED_JOBS_QUEUE
    AnyT
    FuncG, ListG, StructG, MaybeG, UnionG
    QueueInterface
    ResqueInterface
    ConfigurableMixin
    Utils: {uuid}
  } = Module::

  class Resque extends Module::Proxy
    @inheritProtected()
    @include ConfigurableMixin
    @implements ResqueInterface
    @module Module

    @public tmpJobs: ListG StructG {
      queueName: String
      scriptName: String
      data: AnyT
      delay: MaybeG Number
      id: String
    }

    @public fullQueueName: FuncG(String, String),
      default: (queueName)->
        unless /\|\>/.test queueName
          [ moduleName ] = @moduleName().split '|>'
          queueName = "#{moduleName}|>#{queueName}"
        queueName

    @public onRegister: Function,
      default: (args...)->
        @super args...
        return

    @public onRemove: Function,
      default: (args...)->
        @super args...
        @tmpJobs = []
        return

    @public @async create: FuncG([String, MaybeG Number], QueueInterface),
      default: (queueName, concurrency)->
        vhNewQueue = yield @ensureQueue queueName, concurrency
        yield return Module::Queue.new vhNewQueue, @

    @public @async all: FuncG([], ListG QueueInterface),
      default: ->
        results = for vhQueue in yield @allQueues()
          Module::Queue.new vhQueue, @
        yield return results

    @public @async get: FuncG(String, MaybeG QueueInterface),
      default: (queueName)->
        vhQueue = yield @getQueue queueName
        if vhQueue?
          yield return Module::Queue.new vhQueue, @
        else
          return

    @public @async remove: FuncG(String),
      default: (queueName)->
        yield @removeQueue queueName
        yield return

    @public @async update: FuncG([String, Number], QueueInterface),
      default: (queueName, concurrency)->
        vhNewQueue = yield @ensureQueue queueName, concurrency
        yield return Module::Queue.new vhNewQueue, @

    @public @async delay: FuncG([String, String, AnyT, MaybeG Number], UnionG String, Number),
      default: (queueName, scriptName, data, delay)->
        if /\|\>/.test @facade[Symbol.for '~multitonKey']
          id = uuid.v4()
          @tmpJobs.push {queueName, scriptName, data, delay, id}
        else
          queue = yield @get queueName ? DELAYED_JOBS_QUEUE
          id = yield queue.push scriptName, data, delay
        yield return id

    @public @async getDelayed: FuncG([], ListG StructG {
      queueName: String
      scriptName: String
      data: AnyT
      delay: MaybeG Number
      id: String
    }),
      default: -> yield return @tmpJobs


    @public @async ensureQueue: FuncG([String, MaybeG Number], StructG name: String, concurrency: Number),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async getQueue: FuncG(String, MaybeG StructG name: String, concurrency: Number),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async removeQueue: FuncG(String),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async allQueues: FuncG([], ListG StructG name: String, concurrency: Number),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async pushJob: FuncG([String, String, AnyT, MaybeG Number], UnionG String, Number),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async getJob: FuncG([String, UnionG String, Number], MaybeG Object),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async deleteJob: FuncG([String, UnionG String, Number], Boolean),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async abortJob: FuncG([String, UnionG String, Number]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async allJobs: FuncG([String, MaybeG String], ListG Object),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async pendingJobs: FuncG([String, MaybeG String], ListG Object),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async progressJobs: FuncG([String, MaybeG String], ListG Object),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async completedJobs: FuncG([String, MaybeG String], ListG Object),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public @async failedJobs: FuncG([String, MaybeG String], ListG Object),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    @public init: FuncG([MaybeG(String), MaybeG AnyT]),
      default: (args...)->
        @super args...

        @tmpJobs = []
        return


    @initialize()
