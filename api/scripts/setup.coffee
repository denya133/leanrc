{ db } = require '@arangodb'


do ->
  qualifiedName = module.context.collectionName 'migrations'
  unless db._collection qualifiedName
    db._createDocumentCollection qualifiedName, waitForSync: yes

  db._collection(qualifiedName).ensureIndex
    type: 'skiplist'
    fields: ['name']


module.exports = yes
