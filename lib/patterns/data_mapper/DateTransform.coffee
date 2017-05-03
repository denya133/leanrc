_ = require 'lodash'


module.exports = (Module)->
  class DateTransform extends Module::CoreObject
    @inheritProtected()
    @implements Module::TransformInterface
    @module Module

    @public @static normalize: Function,
      default: (serialized)->
        if _.isNil(serialized) then null else new Date serialized

    @public @static serialize: Function,
      default: (deserialized)->
        if _.isDate(deserialized) and not _.isNaN(deserialized)
          return deserialized.toISOString()
        else
          return null


  DateTransform.initialize()
