_ = require 'lodash'


module.exports = (Module)->
  class NumberTransform extends Module::CoreObject
    @inheritProtected()
    @implements Module::TransformInterface
    @module Module

    @public @static normalize: Function,
      default: (serialized)->
        if _.isNil serialized
          return null
        else
          transformed = Number serialized
          return if _.isNumber(transformed) then transformed else null

    @public @static serialize: Function,
      default: (deserialized)->
        if _.isNil deserialized
          return null
        else
          transformed = Number deserialized
          return if _.isNumber(transformed) then transformed else null


  NumberTransform.initialize()
