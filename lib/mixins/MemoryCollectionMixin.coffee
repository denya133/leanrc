_             = require 'lodash'
LokiJS        = require 'lokijs'
RC            = require 'RC'

###
```coffee
# in application when its need

class MemoryCollection extends LeanRC::Collection
  @include LeanRC::MemoryCollectionMixin
```
###

module.exports = (LeanRC)->
  class LeanRC::MemoryCollectionMixin extends RC::Mixin
    @inheritProtected()

    @Module: LeanRC

    @public parseQuery: Function,
      default: (query)->
        return query

    @public executeQuery: Function,
      default: (query, options)->
        return result


  return LeanRC::MemoryCollectionMixin.initialize()
