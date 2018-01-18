

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
        @facade.registerMediator Module::BaseResqueExecutor.new RESQUE_EXECUTOR
        #...

  PrepareViewCommand.initialize()
```
###

# Чтобы запустить экзекютор нужно послать сиграл с ключем START_RESQUE
# Медиатор надо регистрировать с ключем RESQUE_EXECUTOR

module.exports = (Module)->
  {
    JOB_RESULT
    START_RESQUE
    RESQUE
    NILL
    RESQUE_EXECUTOR

    Mediator
    DelayableMixin
    ConfigurableMixin
    ResqueInterface
    Utils: { _, co, isArangoDB, genRandomAlphaNumbers }
  } = Module::

  EventEmitter  = require 'events'

  Module.defineMixin Module::Mediator, (BaseClass) ->
    class MemoryExecutorMixin extends BaseClass
      @inheritProtected()
      @include DelayableMixin
      @include ConfigurableMixin

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

      @public @async reDefineProcessors: Function,
        args: []
        return: NILL
        default: ->
          @stop()
          @[ipoDefinedProcessors] = {}
          yield @defineProcessors()
          yield return

      @public @async defineProcessors: Function,
        args: []
        return: NILL
        default: ->
          for {name, concurrency} in yield @[ipoResque].allQueues()
            fullQueueName = @[ipoResque].fullQueueName name
            [moduleName] = fullQueueName.split '|>'
            if moduleName is @moduleName()
              self = @
              @define name, {concurrency}, co.wrap (job, done)->
                reverse = genRandomAlphaNumbers 32
                self.getViewComponent().once reverse, (aoError)->
                  done aoError
                {scriptName, data} = job.data
                self.sendNotification scriptName, data, reverse
                return
            continue
          yield return

      @public onRemove: Function,
        default: (args...)->
          @super args...
          @stop()
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
          self = @
          @[ipoTimer] = setTimeout co.wrap ->
            clearTimeout self[ipoTimer]
            yield self.cyclePart()
          , 100
          yield return

      @public @async start: Function,
        args: []
        return: NILL
        default: ->
          if isArangoDB()
            throw new Error 'MemoryExecutorMixin can not been used for ArrangoDB apps'
            yield return
          @[ipbIsStopped] = no
          yield @recursion()
          yield return

      @public stop: Function,
        args: []
        return: NILL
        default: ->
          if isArangoDB()
            throw new Error 'MemoryExecutorMixin can not been used for ArrangoDB apps'
            return
          @[ipbIsStopped] = yes
          clearTimeout @[ipoTimer]
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


    MemoryExecutorMixin.initializeMixin()
