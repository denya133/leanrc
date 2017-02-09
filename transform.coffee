_ = require 'lodash'

{Null, Undefined} = FoxxMC::Utils

# Virtual Interface
class FoxxMC::TransformInterface extends FoxxMC::Interface
  @public @virtual deserialize: Function # virtual declaration of method
  @public @virtual serialize:   Function # virtual declaration of method

# Virtual class. serialize and deserialize declared as `virtual` in interface
class FoxxMC::Transform extends FoxxMC::CoreObject
  @implements FoxxMC::TransformInterface
  deserialize: (serialized, options)->
  serialize: (deserialized, options)->

class FoxxMC::TransformOptionsInterface extends FoxxMC::Interface
  @public allowNull:   Boolean

# Generic Interface
FoxxMC::GenericTransformInterface = (Type)->
  class GenericTransformInterface extends FoxxMC::Interface
    @public deserialize: Function, [Type], -> Type
    @public serialize:   Function, [Type], -> Type

class BooleanTransformInterface extends FoxxMC::Interface
  @public deserialize: Function, [[Boolean, Null, Undefined, String, Number], FoxxMC::TransformOptionsInterface], -> [Boolean, Null]
  @public serialize:   Function, [[Boolean, Null, Undefined], FoxxMC::TransformOptionsInterface], -> [Boolean, Null]

class FoxxMC::BooleanTransform extends FoxxMC::Transform
  @implements BooleanTransformInterface
  deserialize: (serialized, options)->
    type = typeof serialized

    if not serialized? and options.allowNull is yes
      return null

    if type is "boolean"
      return serialized
    else if type is "string"
      return serialized.match(/^true$|^t$|^1$/i) isnt null
    else if type is "number"
      return serialized is 1
    else
      return no
  serialize: (deserialized, options)->
    if not deserialized? and options.allowNull is yes
      return null

    return Boolean deserialized

class FoxxMC::NumberTransformInterface extends FoxxMC::Interface
  @public deserialize: Function, [
    [Number, Null, Undefined, String, Boolean, Date]
    FoxxMC::TransformOptionsInterface
  ], -> [Number, Null]
  @public serialize:   Function, [
    [Number, Null, Undefined, String, Boolean, Date]
    FoxxMC::TransformOptionsInterface
  ], -> [Number, Null]

class FoxxMC::NumberTransform extends FoxxMC::Transform
  @implements FoxxMC::NumberTransformInterface
  deserialize: (serialized)->
    if _.isEmpty serialized
      return null
    else
      transformed = Number serialized
      return if _.isNumber(transformed) then transformed else null

  serialize: (deserialized)->
    if _.isEmpty deserialized
      return null
    else
      transformed = Number deserialized
      return if _.isNumber(transformed) then transformed else null

class FoxxMC::StringTransformInterface extends FoxxMC::Interface
  @public deserialize: Function, [
    [String, Null, Undefined, Number, Boolean, Date]
    FoxxMC::TransformOptionsInterface
  ], -> [String, Null]
  @public serialize:   Function, [
    [String, Null, Undefined, Number, Boolean, Date
  ], -> [String, Null]

class FoxxMC::StringTransform extends FoxxMC::Transform
  @implements FoxxMC::StringTransformInterface
  deserialize: (serialized)->
    if _.isNil(serialized) then null else String serialized

  serialize: (deserialized)->
    if _.isNil(deserialized) then null else String deserialized

class FoxxMC::DateTransformInterface extends FoxxMC::Interface
  @public deserialize: Function, [
    [Date, Null, Undefined, String, Boolean, Number]
    FoxxMC::TransformOptionsInterface
  ], -> [Date, Null]
  @public serialize:   Function, [
    [Date, Null, Undefined, String, Boolean, Number]
    FoxxMC::TransformOptionsInterface
  ], -> [Date, Null]

class FoxxMC::DateTransform extends FoxxMC::Transform
  @implements FoxxMC::DateTransformInterface
  deserialize: (serialized)->
    if _.isNil(serialized) then null else Date serialized

  serialize: (deserialized)->
    if deserialized instanceof Date and not _.isNaN deserialized
      return deserialized.toISOString()
    else
      return null
