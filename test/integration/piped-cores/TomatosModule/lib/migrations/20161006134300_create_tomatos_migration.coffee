

module.exports = (Module)->
  {
    BaseMigration
  } = Module::

  class CreateTomatosMigration extends BaseMigration
    @inheritProtected()
    @module Module

    @change ->
      name = 'tomatos'
      @createCollection name
      @addField name, 'id', 'string'
      @addField name, 'key', 'string'
      @addField name, 'type', 'string'
      @addField name, 'rev', 'string'
      @addField name, 'isHidden', 'boolean'
      @addTimestamps name

      @addField name, 'name', 'string'
      @addField name, 'description', 'text'

      @addIndex name, ['id'], type: 'hash', unique: yes
      @addIndex name, ['key'], type: 'hash', unique: yes
      @addIndex name, ['key', 'type'], type: 'hash'
      @addIndex name, ['key', 'type', 'isHidden'], type: 'hash'
      @addIndex name, ['rev'], type: 'hash'
      @addIndex name, ['name'], type: 'hash', unique: yes
      @addIndex name, ['name'], type: 'skiplist'
      @addIndex name, ['description'], type: 'skiplist', sparse: yes

      @addIndex name, ['isHidden'], type: 'hash', sparse: yes
      @addIndex name, ['createdAt'], type: 'skiplist', sparse: yes
      @addIndex name, ['updatedAt'], type: 'skiplist', sparse: yes
      @addIndex name, ['deletedAt'], type: 'skiplist', sparse: yes


  CreateTomatosMigration.initialize()
