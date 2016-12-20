{ db }  = require '@arangodb'


collections = [
  ## documentCollections
  'migrations'
  'sessions'

  ## edgeCollections
]

collections.forEach (localName)->
  qualifiedName = module.context.collectionName localName
  if db._collection qualifiedName
    db._drop qualifiedName
