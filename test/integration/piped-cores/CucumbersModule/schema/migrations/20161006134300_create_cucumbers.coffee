

module.exports = (Module)->
  {
    BaseMigration
  } = Module::

  class CreateCucumbersMigration extends BaseMigration
    @inheritProtected()
    @module Module

    @change ->
      @createCollection 'cucumbers'
      @addField 'cucumbers', '_id', 'string'
      @addField 'cucumbers', '_key', 'string'
      @addField 'cucumbers', '_type', 'string'
      @addField 'cucumbers', '_rev', 'string'
      @addField 'cucumbers', 'isHidden', 'boolean'
      @addTimestamps()

      @addField 'cucumbers', 'name', 'string'
      @addField 'cucumbers', 'description', 'text'

      @addIndex 'cucumbers', ['_id'], type: 'hash', unique: yes
      @addIndex 'cucumbers', ['_key'], type: 'hash', unique: yes
      @addIndex 'cucumbers', ['_key', '_type'], type: 'hash'
      @addIndex 'cucumbers', ['_key', '_type', 'isHidden'], type: 'hash'
      @addIndex 'cucumbers', ['_rev'], type: 'hash'
      @addIndex 'cucumbers', ['name'], type: 'hash', unique: yes
      @addIndex 'cucumbers', ['name'], type: 'skiplist'
      @addIndex 'cucumbers', ['description'], type: 'skiplist', sparse: yes
      @addIndex 'cucumbers', ['name', 'description'], type: 'fulltext'

      @addIndex 'cucumbers', ['isHidden'], type: 'hash', sparse: yes
      @addIndex 'cucumbers', ['createdAt'], type: 'skiplist', sparse: yes
      @addIndex 'cucumbers', ['updatedAt'], type: 'skiplist', sparse: yes
      @addIndex 'cucumbers', ['deletedAt'], type: 'skiplist', sparse: yes


  CreateCucumbersMigration.initialize()
