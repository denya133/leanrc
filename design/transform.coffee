_ = require 'lodash'

{NILL, Undefined} = FoxxMC::Utils

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
  @public allowNILL:   Boolean

# Generic Interface
FoxxMC::GenericTransformInterface = (Type)->
  class GenericTransformInterface extends FoxxMC::Interface
    @public deserialize: Function, [Type], -> Type
    @public serialize:   Function, [Type], -> Type

class BooleanTransformInterface extends FoxxMC::Interface
  @public deserialize: Function, [[Boolean, NILL, Undefined, String, Number], FoxxMC::TransformOptionsInterface], -> [Boolean, NILL]
  @public serialize:   Function, [[Boolean, NILL, Undefined], FoxxMC::TransformOptionsInterface], -> [Boolean, NILL]

class FoxxMC::BooleanTransform extends FoxxMC::Transform
  @implements BooleanTransformInterface
  deserialize: (serialized, options)->
    type = typeof serialized

    if not serialized? and options.allowNILL is yes
      return NILL

    if type is "boolean"
      return serialized
    else if type is "string"
      return serialized.match(/^true$|^t$|^1$/i) isnt NILL
    else if type is "number"
      return serialized is 1
    else
      return no
  serialize: (deserialized, options)->
    if not deserialized? and options.allowNILL is yes
      return NILL

    return Boolean deserialized

class FoxxMC::NumberTransformInterface extends FoxxMC::Interface
  @public deserialize: Function, [
    [Number, NILL, Undefined, String, Boolean, Date]
    FoxxMC::TransformOptionsInterface
  ], -> [Number, NILL]
  @public serialize:   Function, [
    [Number, NILL, Undefined, String, Boolean, Date]
    FoxxMC::TransformOptionsInterface
  ], -> [Number, NILL]

class FoxxMC::NumberTransform extends FoxxMC::Transform
  @implements FoxxMC::NumberTransformInterface
  deserialize: (serialized)->
    if _.isEmpty serialized
      return NILL
    else
      transformed = Number serialized
      return if _.isNumber(transformed) then transformed else NILL

  serialize: (deserialized)->
    if _.isEmpty deserialized
      return NILL
    else
      transformed = Number deserialized
      return if _.isNumber(transformed) then transformed else NILL

class FoxxMC::StringTransformInterface extends FoxxMC::Interface
  @public deserialize: Function, [
    [String, NILL, Undefined, Number, Boolean, Date]
    FoxxMC::TransformOptionsInterface
  ], -> [String, NILL]
  @public serialize:   Function, [
    [String, NILL, Undefined, Number, Boolean, Date
  ], -> [String, NILL]

class FoxxMC::StringTransform extends FoxxMC::Transform
  @implements FoxxMC::StringTransformInterface
  deserialize: (serialized)->
    if _.isNil(serialized) then NILL else String serialized

  serialize: (deserialized)->
    if _.isNil(deserialized) then NILL else String deserialized

class FoxxMC::DateTransformInterface extends FoxxMC::Interface
  @public deserialize: Function, [
    [Date, NILL, Undefined, String, Boolean, Number]
    FoxxMC::TransformOptionsInterface
  ], -> [Date, NILL]
  @public serialize:   Function, [
    [Date, NILL, Undefined, String, Boolean, Number]
    FoxxMC::TransformOptionsInterface
  ], -> [Date, NILL]

class FoxxMC::DateTransform extends FoxxMC::Transform
  @implements FoxxMC::DateTransformInterface
  deserialize: (serialized)->
    if _.isNil(serialized) then NILL else Date serialized

  serialize: (deserialized)->
    if deserialized instanceof Date and not _.isNaN deserialized
      return deserialized.toISOString()
    else
      return NILL
