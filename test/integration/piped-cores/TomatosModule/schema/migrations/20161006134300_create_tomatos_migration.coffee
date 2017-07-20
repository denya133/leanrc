

module.exports = (Module)->
  {
    BaseMigration
  } = Module::

  class CreateTomatosMigration extends BaseMigration
    @inheritProtected()
    @module Module

    @change ->
      @createCollection 'tomatos'
      @addField 'tomatos', 'id', 'string'
      @addField 'tomatos', 'key', 'string'
      @addField 'tomatos', 'type', 'string'
      @addField 'tomatos', 'rev', 'string'
      @addField 'tomatos', 'isHidden', 'boolean'
      @addTimestamps 'tomatos'

      @addField 'tomatos', 'name', 'string'
      @addField 'tomatos', 'description', 'text'

      @addIndex 'tomatos', ['id'], type: 'hash', unique: yes
      @addIndex 'tomatos', ['key'], type: 'hash', unique: yes
      @addIndex 'tomatos', ['key', 'type'], type: 'hash'
      @addIndex 'tomatos', ['key', 'type', 'isHidden'], type: 'hash'
      @addIndex 'tomatos', ['rev'], type: 'hash'
      @addIndex 'tomatos', ['name'], type: 'hash', unique: yes
      @addIndex 'tomatos', ['name'], type: 'skiplist'
      @addIndex 'tomatos', ['description'], type: 'skiplist', sparse: yes
      @addIndex 'tomatos', ['name', 'description'], type: 'fulltext'

      @addIndex 'tomatos', ['isHidden'], type: 'hash', sparse: yes
      @addIndex 'tomatos', ['createdAt'], type: 'skiplist', sparse: yes
      @addIndex 'tomatos', ['updatedAt'], type: 'skiplist', sparse: yes
      @addIndex 'tomatos', ['deletedAt'], type: 'skiplist', sparse: yes


  CreateTomatosMigration.initialize()
