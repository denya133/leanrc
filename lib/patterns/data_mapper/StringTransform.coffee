_ = require 'lodash'


module.exports = (Module)->
  class StringTransform extends Module::CoreObject
    @inheritProtected()
    @module Module
    @implements Module::TransformInterface

    @public @static normalize: Function,
      default: (serialized)->
        if _.isNil(serialized) then null else String serialized

    @public @static serialize: Function,
      default: (deserialized)->
        if _.isNil(deserialized) then null else String deserialized


  StringTransform.initialize()
