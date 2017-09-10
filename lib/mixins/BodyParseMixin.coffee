
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
    Resource
    Utils
  } = Module::
  { isArangoDB } = Utils

  Module.defineMixin Resource, (BaseClass) ->
    class BodyParseMixin extends BaseClass
      @inheritProtected()

      @public @async parseBody: Function,
        default: (args...)->
          if isArangoDB()
            @context.request.body = @context.req.body
          else
            parse = require 'co-body'
            @context.request.body = yield parse @context.req
          yield return args


    BodyParseMixin.initializeMixin()
