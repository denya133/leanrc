

module.exports = (Module)->
  Module.defineMixin Module::Resource, (BaseClass) ->
    class BodyParseMixin extends BaseClass
      @inheritProtected()

      @public @async parseBody: Function,
        default: (args...)->
          # ... TODO: some code
          @context.request.body = body
          yield return args


    BodyParseMixin.initializeMixin()
