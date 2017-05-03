_             = require 'lodash'
inflect       = do require 'i'


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
  {ANY, NILL} = Module::

  Module.defineMixin (BaseClass) ->
    class MemoryResqueMixin extends BaseClass
      @inheritProtected()

      ipoDelayedJobs = @protected delayedJobs: Object
      ipoDelayedQueues = @protected delayedQueues: Object

      @public onRegister: Function,
        default: (args...)->
          @super args...
          @[ipoDelayedQueues] = {}
          @[ipoDelayedJobs] = {}
          return

      @public onRemove: Function,
        default: (args...)->
          @super args...
          for own queueName, queuedJobs of @[ipoDelayedQueues]
            for own jobId, job of queuedJobs
              delete queuedJobs.jobId
              return
            delete @[ipoDelayedQueues].queueName
            return
          delete @[ipoDelayedQueues]
          delete @[ipoDelayedJobs]
          return

      @public @async ensureQueue: Function,
        default: (name, concurrency = 1)->
          fullName = @fullQueueName name
          if (queue = @[ipoDelayedQueues][fullName])?
            queue.concurrency = concurrency
            @[ipoDelayedQueues][fullName] = queue
          else
            @[ipoDelayedQueues][fullName] = {name, concurrency}
          yield return {name, concurrency}

      @public @async getQueue: Function,
        default: (name)->
          fullName = @fullQueueName name
          if (queue = @[ipoDelayedQueues][fullName])?
            {concurrency} = queue
            yield return {name, concurrency}
          else
            yield return

      @public @async removeQueue: Function,
        default: (queueName)->
          fullName = @fullQueueName queueName
          if (queue = @[ipoDelayedQueues][fullName])?
            delete @[ipoDelayedQueues][fullName]
          yield return

      @public @async allQueues: Function,
        default: ->
          yield return _.values(@[ipoDelayedQueues]).map ({name, concurrency})->
            {name, concurrency}

      @public @async pushJob: Function,
        default: (queueName, scriptName, data, delayUntil)->
          fullName = @fullQueueName queueName
          delayUntil ?= Date.now()
          @[ipoDelayedJobs][fullName] ?= []
          length = @[ipoDelayedJobs][fullName].push
            queueName: fullName
            data: {scriptName, data}
            delayUntil: delayUntil
            status: 'scheduled'
            lockLifetime: 5000
            lockLimit: 2
          jobId = length - 1
          yield return jobId

      @public @async getJob: Function,
        default: (queueName, jobId)->
          fullName = @fullQueueName queueName
          @[ipoDelayedJobs][fullName] ?= []
          yield return @[ipoDelayedJobs][fullName][jobId] ? null

      @public @async deleteJob: Function,
        default: (queueName, jobId)->
          fullName = @fullQueueName queueName
          @[ipoDelayedJobs][fullName] ?= []
          if @[ipoDelayedJobs][fullName][jobId]?
            delete @[ipoDelayedJobs][fullName][jobId]
            isDeleted = yes
          else
            isDeleted = no
          yield return isDeleted

      @public @async abortJob: Function,
        default: (queueName, jobId)->
          fullName = @fullQueueName queueName
          @[ipoDelayedJobs][fullName] ?= []
          if (job = @[ipoDelayedJobs][fullName][jobId])?
            if job.status is 'scheduled'
              job.status = 'failed'
              job.reason = new Error 'Job has been aborted'
          yield return

      @public @async allJobs: Function,
        default: (queueName, scriptName=null)->
          fullName = @fullQueueName queueName
          @[ipoDelayedJobs][fullName] ?= []
          res = @[ipoDelayedJobs][fullName].filter (job)->
            if scriptName?
              if job.data.scriptName is scriptName
                yes
              else
                no
            else
              yes
          yield return res ? []

      @public @async pendingJobs: Function,
        default: (queueName, scriptName)->
          fullName = @fullQueueName queueName
          @[ipoDelayedJobs][fullName] ?= []
          res = @[ipoDelayedJobs][fullName].filter (job)->
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

      @public @async progressJobs: Function,
        default: (queueName, scriptName)->
          fullName = @fullQueueName queueName
          @[ipoDelayedJobs][fullName] ?= []
          res = @[ipoDelayedJobs][fullName].filter (job)->
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

      @public @async completedJobs: Function,
        default: (queueName, scriptName)->
          fullName = @fullQueueName queueName
          @[ipoDelayedJobs][fullName] ?= []
          res = @[ipoDelayedJobs][fullName].filter (job)->
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

      @public @async failedJobs: Function,
        default: (queueName, scriptName)->
          fullName = @fullQueueName queueName
          @[ipoDelayedJobs][fullName] ?= []
          res = @[ipoDelayedJobs][fullName].filter (job)->
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


    MemoryResqueMixin.initializeMixin()
