{ db } = require '@arangodb'
Module = require '../../index'


do ->
  qualifiedName = Module.context.collectionName 'migrations'
  unless db._collection qualifiedName
    db._createDocumentCollection qualifiedName, waitForSync: yes

  db._collection(qualifiedName).ensureIndex
    type: 'skiplist'
    fields: ['name']


module.exports = yes
