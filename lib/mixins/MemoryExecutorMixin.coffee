# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

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
    RESQUE_EXECUTOR
    PointerT
    FuncG, DictG, StructG, MaybeG, UnionG
    ResqueInterface, NotificationInterface
    Mediator, Mixin
    DelayableMixin, ConfigurableMixin
    Utils: { _, co, isArangoDB, genRandomAlphaNumbers }
  } = Module::

  Module.defineMixin Mixin 'MemoryExecutorMixin', (BaseClass = Mediator) ->
    class extends BaseClass
      @inheritProtected()
      @include DelayableMixin
      @include ConfigurableMixin

      @public fullQueueName: FuncG(String, String),
        default: (queueName)-> @[ipoResque].fullQueueName queueName

      ipsMultitonKey = PointerT Symbol.for '~multitonKey'
      ipoTimer = PointerT @private timer: MaybeG UnionG Object, Number
      ipbIsStopped = PointerT @private isStopped: Boolean
      ipoDefinedProcessors = PointerT @private definedProcessors: DictG(
        String
        StructG {
          listener: Function
          concurrency: Number
        }
      )
      ipoConcurrencyCount = PointerT @private concurrencyCount: DictG(
        String, Number
      )
      ipoResque = PointerT @private resque: ResqueInterface

      @public listNotificationInterests: FuncG([], Array),
        default: ->
          [
            JOB_RESULT
            START_RESQUE
          ]

      @public handleNotification: FuncG(NotificationInterface),
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
          EventEmitter = require 'events'
          @setViewComponent new EventEmitter()
          @[ipoConcurrencyCount] = {}
          @[ipoDefinedProcessors] = {}
          @[ipoResque] = @facade.retrieveProxy RESQUE
          @defineProcessors()
          return

      @public @async reDefineProcessors: Function,
        default: ->
          @stop()
          @[ipoDefinedProcessors] = {}
          yield @defineProcessors()
          yield return

      @public @async defineProcessors: Function,
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
        default: ->
          if @[ipbIsStopped]
            yield return
          self = @
          @[ipoTimer] = setTimeout((co.wrap ->
            clearTimeout self[ipoTimer]
            return yield self.cyclePart()
          ), 100)
          yield return

      @public @async start: Function,
        default: ->
          if isArangoDB()
            throw new Error 'MemoryExecutorMixin can not been used for ArrangoDB apps'
            yield return
          @[ipbIsStopped] = no
          yield @recursion()
          yield return

      @public stop: Function,
        default: ->
          if isArangoDB()
            throw new Error 'MemoryExecutorMixin can not been used for ArrangoDB apps'
            return
          @[ipbIsStopped] = yes
          if @[ipoTimer]?
            clearTimeout @[ipoTimer]
          return

      @public define: FuncG([String, StructG(concurrency: Number), Function]),
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


      @initializeMixin()
