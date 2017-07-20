
###
for example

```coffee
module.exports = (Module)->
  {
    Collection
    QueryableCollectionMixin
    ArangoCollectionMixin
    IterableMixin
    GenerateUuidIdMixin
  } = Module::

  class MainCollection extends Collection
    @inheritProtected()
    @include QueryableCollectionMixin
    @include ArangoCollectionMixin
    @include IterableMixin
    @include GenerateUuidIdMixin
    @module Module


  MainCollection.initialize()
```
###

module.exports = (Module)->
  {
    Collection
    Utils
  } = Module::
  { uuid } = Utils

  Module.defineMixin Collection, (BaseClass) ->
    class GenerateUuidIdMixin extends BaseClass
      @inheritProtected()

      @public @async generateId: Function,
        default: -> yield return uuid.v4()


    GenerateUuidIdMixin.initializeMixin()
