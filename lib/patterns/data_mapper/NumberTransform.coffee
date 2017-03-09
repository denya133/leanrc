_ = require 'lodash'
RC = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::NumberTransform extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::TransformInterface

    @Module: LeanRC

    @public deserialize: Function,
      default: (serialized)->
        if _.isNil serialized
          return null
        else
          transformed = Number serialized
          return if _.isNumber(transformed) then transformed else null

    @public serialize: Function,
      default: (deserialized)->
        if _.isNil deserialized
          return null
        else
          transformed = Number deserialized
          return if _.isNumber(transformed) then transformed else null


  return LeanRC::NumberTransform.initialize()
