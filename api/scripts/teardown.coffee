{ db }  = require '@arangodb'
Module = require '../../index'


collections = [
  ## documentCollections
  'migrations'

  ## edgeCollections
]

collections.forEach (localName)->
  qualifiedName = Module.context.collectionName localName
  if db._collection qualifiedName
    db._drop qualifiedName


module.exports = yes
