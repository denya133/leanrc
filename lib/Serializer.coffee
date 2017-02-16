

module.exports = (FoxxMC)->
  CoreObject  = require('./CoreObject') FoxxMC
  StoreInterface  = require('../interfaces/store') FoxxMC
  SerializerInterface = require('./interfaces/serializer') FoxxMC

  # Virtual class. serialize and deserialize declared as `virtual` in interface
  class FoxxMC::Serializer extends CoreObject
    @implements SerializerInterface

    # public
    @defineAccessor StoreInterface,   'store'

    @instanceMethod 'normalize', ->

    @instanceMethod 'normalizeResponse', ->

    @instanceMethod 'serialize', ->


  FoxxMC::Serializer.initialize()

# example in use
###
```coffee
  class Test::ApplicationSerializer extends ArangodbSerializer
    @Module: Test
  module.exports = Test::ApplicationSerializer.initialize()
```
###
