
module.exports = (FoxxMC)->
  Interface  = require('./Interface') FoxxMC
  FoxxMC::GenericTransformInterface = (Type)->
    class GenericTransformInterface extends Interface
      @public deserialize: Function
      ,
        [
          serialized: Type
        ,
          options: Object
        ]
      , ->
        return: Type
      @public serialize: Function
      ,
        [
          deserialized: Type
        ,
          options: Object
        ]
      , ->
        return: Type

    GenericTransformInterface.initialize()
  FoxxMC::GenericTransformInterface
