

_             = require 'lodash'
EventEmitter  = require 'events'
crypto        = require 'crypto'


###
```coffee
module.exports = (Module)->
  class BaseResqueExecutor extends Module::MemoryResqueExecutor
    @inheritProtected()
    @module Module

  return BaseResqueExecutor.initialize()
```

```coffee
module.exports = (Module)->
  {RESQUE} = Module::

  class PrepareViewCommand extends Module::SimpleCommand
    @inheritProtected()

    @module Module

    @public execute: Function,
      default: ->
        #...
        @facade.registerMediator Module::BaseResqueExecutor.new MEM_RESQUE_EXEC
        #...

  PrepareViewCommand.initialize()
```
###

# TODO: Чтобы запустить экзекютор нужно послать сиграл с ключем START_RESQUE
# TODO: Медиатор надо регистрировать с ключем MEM_RESQUE_EXEC

module.exports = (Module)->
  {
    JOB_RESULT
    START_RESQUE
    RESQUE
    NILL
    MEM_RESQUE_EXEC

    Mediator
    DelayableMixin
    ConfigurableMixin
    ResqueInterface
  } = Module::
  {co, isArangoDB} = Module::Utils

  class MemoryResqueExecutor extends Mediator
    @inheritProtected()
    @include DelayableMixin
    @include ConfigurableMixin
    @module Module

    @public fullQueueName: Function,
      args: [String]
      return: String
      default: (queueName)-> @[ipoResque].fullQueueName queueName

    ipsMultitonKey = Symbol.for '~multitonKey'
    ipoTimer = @private timer: Object
    ipbIsStopped = @private isStopped: Boolean
    ipoDefinedProcessors = @private definedProcessors: Object
    ipoConcurrencyCount = @private concurrencyCount: Object
    ipoResque = @private resque: ResqueInterface

    @public listNotificationInterests: Function,
      default: ->
        [
          JOB_RESULT
          START_RESQUE
        ]

    @public handleNotification: Function,
      default: (aoNotification)->
        vsName = aoNotification.getName()
        voBody = aoNotification.getBody()
        vsType = aoNotification.getType()
        switch vsName
          when JOB_RESULT
            @getViewComponent().emit vsType, voBody
          when START_RESQUE
            @start()
        return

    @public onRegister: Function,
      default: (args...)->
        @super args...
        @setViewComponent new EventEmitter()
        @[ipoConcurrencyCount] = {}
        @[ipoDefinedProcessors] = {}
        @[ipoResque] = @facade.retrieveProxy RESQUE
        @defineProcessors()
        return

    @public @async defineProcessors: Function,
      args: []
      return: NILL
      default: ->
        for {name, concurrency} in yield @[ipoResque].allQueues()
          fullQueueName = @[ipoResque].fullQueueName name
          [moduleName] = fullQueueName.split '|>'
          if moduleName is @moduleName()
            @define name, {concurrency}, co.wrap (job, done)=>
              reverse = if isArangoDB()
                crypto.genRandomAlphaNumbers 32
              else
                crypto.randomBytes 32
              @getViewComponent().once reverse, (aoError)=>
                done aoError
              {scriptName, data} = job.data
              @sendNotification scriptName, data, reverse
              return
          continue
        yield return

    @public onRemove: Function,
      default: (args...)->
        @super args...
        @stop()
        return

    @public @static @async staticRunner: Function,
      args: []
      return: NILL
      default: (multitonKey)->
        facade = Module::Facade.getInstance multitonKey
        executor = facade.retrieveMediator MEM_RESQUE_EXEC
        yield executor.cyclePart()
        return

    @public @async cyclePart: Function,
      args: []
      return: NILL
      default: ->
        for own queueName, queueConfig of @[ipoDefinedProcessors]
          {listener, concurrency} = queueConfig
          currentQC = @[ipoConcurrencyCount][queueName]
          now = Date.now()

          progressJobs = yield @[ipoResque].progressJobs queueName
          for job in progressJobs
            if (now - job.startedAt) < job.lockLifetime
              job.status = 'scheduled'

          pendingJobs = yield @[ipoResque].pendingJobs queueName
          if (currentQC? and currentQC < concurrency) or not currentQC?
            for job in pendingJobs
              if job.delayUntil < now
                listener job
              if currentQC >= concurrency
                break
        @recursion()
        yield return

    @public @async recursion: Function,
      args: []
      return: NILL
      default: ->
        if @[ipbIsStopped]
          yield return
        if isArangoDB()
          yield MemoryResqueExecutor.delay(@facade,
            delayUntil: Date.now() + 100
          ).staticRunner @[ipsMultitonKey]
        else
          @[ipoTimer] = setTimeout co.wrap =>
            clearTimeout @[ipoTimer]
            yield @cyclePart()
          , 100
        yield return

    @public @async start: Function,
      args: []
      return: NILL
      default: ->
        @[ipbIsStopped] = no
        yield @recursion()
        yield return

    @public stop: Function,
      args: []
      return: NILL
      default: ->
        @[ipbIsStopped] = yes
        return

    @public define: Function,
      args: [String, Object, Function]
      return: NILL
      default: (queueName, {concurrency}, lambda)->
        listener = (job)=>
          done = (err)=>
            if err?
              job.status = 'failed'
              job.reason = err
            else
              job.status = 'completed'
            @[ipoConcurrencyCount][queueName] -= 1
            return
          @[ipoConcurrencyCount][queueName] ?= 0
          @[ipoConcurrencyCount][queueName] += 1
          job.status = 'running'
          job.startedAt = Date.now()
          lambda job, done
          return
        @[ipoDefinedProcessors][queueName] = {listener, concurrency}
        return


  MemoryResqueExecutor.initialize()
