{ db }  = require '@arangodb'


collections = [
  ## documentCollections
  'migrations'

  ## edgeCollections
]

collections.forEach (localName)->
  qualifiedName = module.context.collectionName localName
  if db._collection qualifiedName
    db._drop qualifiedName


module.exports = yes
