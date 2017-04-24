
###
```coffee
module.exports = (Module)->
  class BaseJob extends Module::Job
    @inheritProtected()
    @include Module::ArangoJobMixin # в этом миксине должны быть реализованы платформозависимые методы, которые будут посылать нативные запросы к реальной базе данных

    @module Module

  return BaseJob.initialize()
```

```coffee
module.exports = (Module)->
  {DELAYED_JOBS} = Module::

  class PrepareModelCommand extends Module::SimpleCommand
    @inheritProtected()

    @module Module

    @public execute: Function,
      default: ->
        #...
        @facade.registerProxy Module::BaseCollection.new DELAYED_JOBS,
          delegate: Module::BaseJob
        #...

  PrepareModelCommand.initialize()
```
###

module.exports = (Module)->
  class Job extends Module::Record
    @inheritProtected()
    @implements Module::JobInterface

    @module Module

    @attribute type: Object, # зарезервирован в Record под computed
      validate: ->
        joi.object({mount: joi.string(), name: joi.string()}).required()
      transform: -> Module::Transform


  Job.initialize()
