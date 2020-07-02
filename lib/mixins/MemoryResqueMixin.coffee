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
  class BaseResque extends Module::Resque
    @inheritProtected()
    @module Module
    @include Module::MemoryResqueMixin

  return BaseResque.initialize()
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
        @facade.registerProxy Module::BaseResque.new RESQUE
        #...

  PrepareModelCommand.initialize()
```
###

module.exports = (Module)->
  {
    DEFAULT_QUEUE
    AnyT, PointerT
    FuncG, DictG, ListG, StructG, EnumG, MaybeG, InterfaceG, UnionG
    Resque, Mixin
    Utils: { _, inflect }
  } = Module::

  Module.defineMixin Mixin 'MemoryResqueMixin', (BaseClass = Resque) ->
    class extends BaseClass
      @inheritProtected()

      ipoJobs = PointerT @protected jobs: DictG String, MaybeG ListG MaybeG InterfaceG {
        queueName: String
        data: StructG {scriptName: String, data: AnyT}
        delayUntil: Number
        status: EnumG ['scheduled', 'failed', 'queued', 'running', 'completed']
        lockLifetime: EnumG [5000]
        lockLimit: EnumG [2]
      }
      ipoQueues = PointerT @protected queues: DictG String, MaybeG StructG {
        name: String
        concurrency: Number
      }

      @public onRegister: Function,
        default: (args...)->
          @super args...
          @[ipoQueues] = {}
          @[ipoJobs] = {}
          fullName = @fullQueueName DEFAULT_QUEUE
          @[ipoQueues][fullName] = name: DEFAULT_QUEUE, concurrency: 1
          return

      @public onRemove: Function,
        default: (args...)->
          @super args...
          for queueName in Reflect.ownKeys @[ipoQueues]
            delete @[ipoQueues][queueName]
          @[ipoQueues] = {}
          # delete @[ipoQueues]
          for queueName in Reflect.ownKeys @[ipoJobs]
            delete @[ipoJobs][queueName]
          # delete @[ipoJobs]
          @[ipoJobs] = {}
          return

      @public @async ensureQueue: FuncG([String, MaybeG Number], StructG name: String, concurrency: Number),
        default: (name, concurrency = 1)->
          fullName = @fullQueueName name
          if (queue = @[ipoQueues][fullName])?
            queue.concurrency = concurrency
            @[ipoQueues][fullName] = queue
          else
            @[ipoQueues][fullName] = {name, concurrency}
          yield return {name, concurrency}

      @public @async getQueue: FuncG(String, MaybeG StructG name: String, concurrency: Number),
        default: (name)->
          fullName = @fullQueueName name
          if (queue = @[ipoQueues][fullName])?
            {concurrency} = queue
            yield return {name, concurrency}
          else
            yield return

      @public @async removeQueue: FuncG(String),
        default: (queueName)->
          fullName = @fullQueueName queueName
          if (queue = @[ipoQueues][fullName])?
            delete @[ipoQueues][fullName]
          yield return

      @public @async allQueues: FuncG([], ListG StructG name: String, concurrency: Number),
        default: ->
          yield return _.values(@[ipoQueues]).map ({name, concurrency})->
            {name, concurrency}

      @public @async pushJob: FuncG([String, String, AnyT, MaybeG Number], UnionG String, Number),
        default: (queueName, scriptName, data, delayUntil)->
          fullName = @fullQueueName queueName
          delayUntil ?= Date.now()
          @[ipoJobs][fullName] ?= []
          length = @[ipoJobs][fullName].push
            queueName: fullName
            data: {scriptName, data}
            delayUntil: delayUntil
            status: 'scheduled'
            lockLifetime: 5000
            lockLimit: 2
          jobId = length - 1
          yield return jobId

      @public @async getJob: FuncG([String, UnionG String, Number], MaybeG Object),
        default: (queueName, jobId)->
          fullName = @fullQueueName queueName
          @[ipoJobs][fullName] ?= []
          yield return @[ipoJobs][fullName][jobId] ? null

      @public @async deleteJob: FuncG([String, UnionG String, Number], Boolean),
        default: (queueName, jobId)->
          fullName = @fullQueueName queueName
          @[ipoJobs][fullName] ?= []
          if @[ipoJobs][fullName][jobId]?
            delete @[ipoJobs][fullName][jobId]
            isDeleted = yes
          else
            isDeleted = no
          yield return isDeleted

      @public @async abortJob: FuncG([String, UnionG String, Number]),
        default: (queueName, jobId)->
          fullName = @fullQueueName queueName
          @[ipoJobs][fullName] ?= []
          if (job = @[ipoJobs][fullName][jobId])?
            if job.status is 'scheduled'
              job.status = 'failed'
              job.reason = new Error 'Job has been aborted'
          yield return

      @public @async allJobs: FuncG([String, MaybeG String], ListG Object),
        default: (queueName, scriptName=null)->
          fullName = @fullQueueName queueName
          @[ipoJobs][fullName] ?= []
          res = @[ipoJobs][fullName].filter (job)->
            if scriptName?
              if job.data.scriptName is scriptName
                yes
              else
                no
            else
              yes
          yield return res ? []

      @public @async pendingJobs: FuncG([String, MaybeG String], ListG Object),
        default: (queueName, scriptName)->
          fullName = @fullQueueName queueName
          @[ipoJobs][fullName] ?= []
          res = @[ipoJobs][fullName].filter (job)->
            if scriptName?
              if job.data.scriptName is scriptName and job.status in ['scheduled', 'queued']
                yes
              else
                no
            else
              if job.status in ['scheduled', 'queued']
                yes
              else
                no
          yield return res ? []

      @public @async progressJobs: FuncG([String, MaybeG String], ListG Object),
        default: (queueName, scriptName)->
          fullName = @fullQueueName queueName
          @[ipoJobs][fullName] ?= []
          res = @[ipoJobs][fullName].filter (job)->
            if scriptName?
              if job.data.scriptName is scriptName and job.status is 'running'
                yes
              else
                no
            else
              if job.status is 'running'
                yes
              else
                no
          yield return res ? []

      @public @async completedJobs: FuncG([String, MaybeG String], ListG Object),
        default: (queueName, scriptName)->
          fullName = @fullQueueName queueName
          @[ipoJobs][fullName] ?= []
          res = @[ipoJobs][fullName].filter (job)->
            if scriptName?
              if job.data.scriptName is scriptName and job.status is 'completed'
                yes
              else
                no
            else
              if job.status is 'completed'
                yes
              else
                no
          yield return res ? []

      @public @async failedJobs: FuncG([String, MaybeG String], ListG Object),
        default: (queueName, scriptName)->
          fullName = @fullQueueName queueName
          @[ipoJobs][fullName] ?= []
          res = @[ipoJobs][fullName].filter (job)->
            if scriptName?
              if job.data.scriptName is scriptName and job.status is 'failed'
                yes
              else
                no
            else
              if job.status is 'failed'
                yes
              else
                no
          yield return res ? []


      @initializeMixin()
