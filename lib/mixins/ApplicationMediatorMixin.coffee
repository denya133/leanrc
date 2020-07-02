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
    HANDLER_RESULT
    STOPPED_MIGRATE
    STOPPED_ROLLBACK
    AnyT, PointerT, EventEmitterT
    FuncG, MaybeG, StructG
    ContextInterface, ResourceInterface, NotificationInterface
    Mediator, Mixin
    Utils: { genRandomAlphaNumbers }
  } = Module::

  Module.defineMixin Mixin 'ApplicationMediatorMixin', (BaseClass = Mediator) ->
    class extends BaseClass
      @inheritProtected()

      ipoEmitter = PointerT @private emitter: EventEmitterT

      @public listNotificationInterests: FuncG([], Array),
        default: (args...)->
          interests = @super args...
          interests.push HANDLER_RESULT
          interests.push JOB_RESULT
          interests.push STOPPED_MIGRATE
          interests.push STOPPED_ROLLBACK
          interests

      @public handleNotification: FuncG(NotificationInterface),
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

      @public @async migrate: FuncG([MaybeG StructG until: MaybeG String]),
        default: (opts)->
          return yield Module::Promise.new (resolve, reject)=>
            try
              reverse = genRandomAlphaNumbers 32
              @[ipoEmitter].once reverse, ({error})->
                if error?
                  reject error
                  return
                resolve()
                return
              @facade.sendNotification MIGRATE, opts, reverse
            catch err
              reject err
            return

      @public @async rollback: FuncG([MaybeG StructG steps: MaybeG(Number), until: MaybeG String]),
        default: (opts)->
          return yield Module::Promise.new (resolve, reject)=>
            try
              reverse = genRandomAlphaNumbers 32
              @[ipoEmitter].once reverse, ({error})->
                if error?
                  reject error
                  return
                resolve()
                return
              @facade.sendNotification ROLLBACK, opts, reverse
            catch err
              reject err
            return

      @public @async run: FuncG([String, MaybeG AnyT], MaybeG AnyT),
        default: (scriptName, data)->
          return yield Module::Promise.new (resolve, reject)=>
            try
              reverse = genRandomAlphaNumbers 32
              @[ipoEmitter].once reverse, ({error, result})->
                if error?
                  reject error
                  return
                resolve(result)
                return
              @facade.sendNotification scriptName, data, reverse
            catch err
              reject err
            return

      @public @async execute: FuncG([String, StructG({
        context: ContextInterface, reverse: String
      }), String], StructG {
        result: MaybeG(AnyT), resource: ResourceInterface
      }),
        default: (resourceName, {context, reverse}, action)->
          return yield Module::Promise.new (resolve, reject)=>
            try
              @[ipoEmitter].once reverse, ({error, result, resource})->
                if error?
                  reject error
                  return
                resolve {result, resource}
                return
              @sendNotification resourceName, {context, reverse}, action, null
            catch err
              reject err
            return

      @public init: FuncG([String, AnyT]),
        default: (args...)->
          EventEmitter = require 'events'
          voEmitter = new EventEmitter()
          @[ipoEmitter] = voEmitter
          return @super args...


      @initializeMixin()
