

module.exports = (Module)->
  class BooleanTransform extends Module::CoreObject
    @inheritProtected()
    @implements Module::TransformInterface

    @Module: Module

    @public @static normalize: Function,
      default: (serialized)->
        type = typeof serialized

        if type is "boolean"
          return serialized
        else if type is "string"
          return serialized.match(/^true$|^t$|^1$/i) isnt null
        else if type is "number"
          return serialized is 1
        else
          return no

    @public @static serialize: Function,
      default: (deserialized)->
        Boolean deserialized


  BooleanTransform.initialize()
