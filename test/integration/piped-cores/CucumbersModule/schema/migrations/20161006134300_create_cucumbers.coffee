

module.exports = (Module)->
  {
    BaseMigration
  } = Module::

  class CreateCucumbersMigration extends BaseMigration
    @inheritProtected()
    @module Module

    @change ->
      @createCollection 'cucumbers'
      @addField 'cucumbers', 'id', 'string'
      @addField 'cucumbers', 'key', 'string'
      @addField 'cucumbers', 'type', 'string'
      @addField 'cucumbers', 'rev', 'string'
      @addField 'cucumbers', 'isHidden', 'boolean'
      @addTimestamps()

      @addField 'cucumbers', 'name', 'string'
      @addField 'cucumbers', 'description', 'text'

      @addIndex 'cucumbers', ['id'], type: 'hash', unique: yes
      @addIndex 'cucumbers', ['key'], type: 'hash', unique: yes
      @addIndex 'cucumbers', ['key', 'type'], type: 'hash'
      @addIndex 'cucumbers', ['key', 'type', 'isHidden'], type: 'hash'
      @addIndex 'cucumbers', ['rev'], type: 'hash'
      @addIndex 'cucumbers', ['name'], type: 'hash', unique: yes
      @addIndex 'cucumbers', ['name'], type: 'skiplist'
      @addIndex 'cucumbers', ['description'], type: 'skiplist', sparse: yes
      @addIndex 'cucumbers', ['name', 'description'], type: 'fulltext'

      @addIndex 'cucumbers', ['isHidden'], type: 'hash', sparse: yes
      @addIndex 'cucumbers', ['createdAt'], type: 'skiplist', sparse: yes
      @addIndex 'cucumbers', ['updatedAt'], type: 'skiplist', sparse: yes
      @addIndex 'cucumbers', ['deletedAt'], type: 'skiplist', sparse: yes


  CreateCucumbersMigration.initialize()
