EventEmitter  = require 'events'

###
for example

```coffee
module.exports = (Module)->
  {
    Resource
    BodyParseMixin
  } = Module::

  class CucumbersResource extends Resource
    @inheritProtected()
    @include BodyParseMixin
    @module Module

    @initialHook 'parseBody', only: ['create', 'update']

    @public entityName: String,
      default: 'cucumber'


  CucumbersResource.initialize()
```
###

module.exports = (Module)->
  {
    MIGRATE
    ROLLBACK
    JOB_RESULT
    STOPPED_MIGRATE
    STOPPED_ROLLBACK

    Mediator
    Utils
  } = Module::
  { genRandomAlphaNumbers } = Utils

  Module.defineMixin Mediator, (BaseClass) ->
    class ApplicationMediatorMixin extends BaseClass
      @inheritProtected()

      ipoEmitter = @private emitter: Object

      @public listNotificationInterests: Function,
        default: (args...)->
          interests = @super args...
          interests.push HANDLER_RESULT
          interests.push JOB_RESULT
          interests.push STOPPED_MIGRATE
          interests.push STOPPED_ROLLBACK
          interests

      @public handleNotification: Function,
        default: (aoNotification)->
          vsName = aoNotification.getName()
          voBody = aoNotification.getBody()
          vsType = aoNotification.getType()
          switch vsName
            when HANDLER_RESULT, STOPPED_MIGRATE, STOPPED_ROLLBACK, JOB_RESULT
              @[ipoEmitter].emit vsType, voBody
              break
            else
              @super aoNotification
          return

      @public @async migrate: Function,
        default: (opts)->
          return yield Module::Promise.new (resolve, reject)=>
            try
              reverse = genRandomAlphaNumbers 32
              @[ipoEmitter].once reverse, (error)->
                if error?
                  reject error
                  return
                resolve()
                return
              @facade.sendNotification MIGRATE, opts, reverse
            catch err
              reject err
            return

      @public @async rollback: Function,
        default: (opts)->
          return yield Module::Promise.new (resolve, reject)=>
            try
              reverse = genRandomAlphaNumbers 32
              @[ipoEmitter].once reverse, (error)->
                if error?
                  reject error
                  return
                resolve()
                return
              @facade.sendNotification ROLLBACK, opts, reverse
            catch err
              reject err
            return

      @public @async run: Function,
        default: (scriptName, data)->
          return yield Module::Promise.new (resolve, reject)=>
            try
              reverse = genRandomAlphaNumbers 32
              @[ipoEmitter].once reverse, (error)->
                if error?
                  reject error
                  return
                resolve()
                return
              @facade.sendNotification scriptName, data, reverse
            catch err
              reject err
            return

      @public @async execute: Function,
        default: (resourceName, {context, reverse}, action)->
          return yield Module::Promise.new (resolve, reject)=>
            try
              @[ipoEmitter].once reverse, ({error, result})->
                if error?
                  reject error
                  return
                resolve result
                return
              @facade.sendNotification resourceName, {context, reverse}, action
            catch err
              reject err
            return

      @public init: Function,
        default: (args...)->
          voEmitter = new EventEmitter()
          @[ipoEmitter] = voEmitter
          return @super args...


    ApplicationMediatorMixin.initializeMixin()
