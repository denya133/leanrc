

module.exports = (Module)->
  {
    BaseMigration
  } = Module::

  class CreateTomatosMigration extends BaseMigration
    @inheritProtected()
    @module Module

    @change ->
      @createCollection 'tomatos'
      @addField 'tomatos', _id, 'string'
      @addField 'tomatos', _key, 'string'
      @addField 'tomatos', _type, 'string'
      @addField 'tomatos', _rev, 'string'
      @addField 'tomatos', isHidden, 'boolean'
      @addTimestamps()

      @addField 'tomatos', name, 'string'
      @addField 'tomatos', description, 'text'

      @addIndex 'tomatos', ['_id'], type: 'hash', unique: yes
      @addIndex 'tomatos', ['_key'], type: 'hash', unique: yes
      @addIndex 'tomatos', ['_key', '_type'], type: 'hash'
      @addIndex 'tomatos', ['_key', '_type', 'isHidden'], type: 'hash'
      @addIndex 'tomatos', ['_rev'], type: 'hash'
      @addIndex 'tomatos', ['name'], type: 'hash', unique: yes
      @addIndex 'tomatos', ['name'], type: 'skiplist'
      @addIndex 'tomatos', ['description'], type: 'skiplist', sparse: yes
      @addIndex 'tomatos', ['name', 'description'], type: 'fulltext'

      @addIndex 'tomatos', ['isHidden'], type: 'hash', sparse: yes
      @addIndex 'tomatos', ['createdAt'], type: 'skiplist', sparse: yes
      @addIndex 'tomatos', ['updatedAt'], type: 'skiplist', sparse: yes
      @addIndex 'tomatos', ['deletedAt'], type: 'skiplist', sparse: yes


  CreateTomatosMigration.initialize()
