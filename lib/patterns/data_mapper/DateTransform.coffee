_ = require 'lodash'
RC = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::DateTransform extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::TransformInterface

    @Module: LeanRC

    @public @static normalize: Function,
      default: (serialized)->
        if _.isNil(serialized) then null else Date serialized

    @public @static serialize: Function,
      default: (deserialized)->
        if deserialized instanceof Date and not _.isNaN deserialized
          return deserialized.toISOString()
        else
          return null


  return LeanRC::DateTransform.initialize()
