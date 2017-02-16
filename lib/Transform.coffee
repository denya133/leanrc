
module.exports = (FoxxMC)->
  CoreObject  = require('./CoreObject') FoxxMC
  TransformInterface = require('./interfaces/transform') FoxxMC
  # Virtual class. serialize and deserialize declared as `virtual` in interface
  class FoxxMC::Transform extends CoreObject
    @implements TransformInterface
    deserialize: ->
    serialize: ->

  FoxxMC::Transform.initialize()
