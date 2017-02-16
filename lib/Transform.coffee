
module.exports = (FoxxMC)->
  CoreObject  = require('./CoreObject') FoxxMC
  TransformInterface = require('./interfaces/transform') FoxxMC
  # Virtual class. serialize and deserialize declared as `virtual` in interface
  class FoxxMC::Transform extends CoreObject
    @implements TransformInterface
    @instanceMethod 'deserialize', ->
    @instanceMethod 'serialize', ->

  FoxxMC::Transform.initialize()
