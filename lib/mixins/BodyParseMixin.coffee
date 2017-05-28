

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
            console.log '!!!!1111', @context
            console.log '!!!!222', context.request

            parse = require 'co-body'
            @context.request.body = yield parse @context.req
          yield return args


    BodyParseMixin.initializeMixin()
