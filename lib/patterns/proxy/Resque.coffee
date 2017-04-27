# 1. Некоторая миграция должна создать очередь, чтобы ей потом можно было пользоваться, например Resque.create(<queueName>, <concurrency>)
# адаптер для аранги реализованный в виде миксина для Resque класса спроецирует запрос с использованием @arango/queue
# адаптер для nodejs просто сохранит эти данные в какую нибудь базу данных (чтобы в нужный момент к ним обратиться и заиспользовать)
# 2. В аранго ничего делать в этом пункте не надо, движок базы данных сам будет заниматься менеджментом очередей и будет плодить потоки выполнения. Для nodejs при старте сервера надо проинициализировать Agenda сервис - взять из базы данных сохраненные <queueName> и <concurrency> и задефайнить хендлеры - внутри хендлера из принимаемых данных надо вычленить имя запускаемого скрипта, сделать require(<scriptName>) и заэкзекютить этот скрипт передав в него все данные поступившие в хендлер. (Agenda - должен покрывать функционал аранги по менеджменту очердей.)
# 3. класс DelayedQueue будет работать аналогично Record классу - проксировать вызовы методов к Resque классу (чтобы срабатывала нужная платформозависимая логика из миксина)
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
  {NILL} = Module::

  class Resque extends Module::Proxy
    @inheritProtected()
    @implements Module::ResqueInterface

    @module Module

    @public fullQueueName: Function,
      default: (queueName)-> "#{@moduleName}|>#{queueName}"

    @public @async create: Function,
      default: (queueName, concurrency)->
        vhNewQueue = yield @ensureQueue queueName, concurrency
        yield return Module::DelayedQueue.new vhNewQueue, @

    @public @async all: Function,
      default: ->
        yield return for vhQueue in yield @allQueues()
          Module::DelayedQueue.new vhQueue, @

    @public @async get: Function,
      default: (queueName)->
        vhQueue = yield @getQueue queueName
        if vhQueue?
          yield return Module::DelayedQueue.new vhQueue, @
        else
          return

    @public @async remove: Function,
      default: (queueName)->
        yield @removeQueue queueName
        yield return

    @public @async update: Function,
      default: (queueName, concurrency)->
        vhNewQueue = yield @ensureQueue queueName, concurrency
        yield return Module::DelayedQueue.new vhNewQueue, @


  Resque.initialize()
