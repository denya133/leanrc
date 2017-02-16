

module.exports = (FoxxMC)->
  CoreObject  = require('./CoreObject') FoxxMC
  AdapterInterface = require('./interfaces/adapter') FoxxMC

  # Virtual class. serialize and deserialize declared as `virtual` in interface
  class FoxxMC::Adapter extends CoreObject
    @implements AdapterInterface

    @defineAccessor String, 'defaultSerializer', '-default'

    @instanceMethod 'generateIdForRecord', -> null

    @instanceMethod 'insertRecord', ->
    @instanceMethod 'destroyRecord', ->
    @instanceMethod 'updateRecord', ->
    @instanceMethod 'findRecord', ->

    @instanceMethod 'insertMany', ->
    @instanceMethod 'destroyMany', ->
    @instanceMethod 'updateMany', ->
    @instanceMethod 'findMany', ->

    @instanceMethod 'query', ->
    @instanceMethod 'copy', ->
    @instanceMethod 'deepCopy', ->
    @instanceMethod 'map', ->
    @instanceMethod 'forEach', ->
    @instanceMethod 'reduce', ->

    @instanceMethod 'serialize', (snapshot, options)->
      snapshot.serialize options

  FoxxMC::Adapter.initialize()


# example in use
###
```coffee
  class Test::ApplicationAdapter extends ArangodbAdapter
    @Module: Test
  module.exports = Test::ApplicationAdapter.initialize()
```
###
