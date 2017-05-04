{ db } = require '@arangodb'

migration =
  up: ->
    {read, write} = Basis::Space.getLocksFor '.createFromBatch'
    db._executeTransaction
      collections:
        read: read
        write: write
        allowImplicit: no
      action: ->
        Basis::Space.createFromBatch
          id:         '_default'
          shortName:  '_default'
          ownerId:    'admin'
          kind:       'default'
          description: 'Global space for any public content'
        return
    return
  down: ->
    {read, write} = Basis::Space.getLocksFor '.destroy'
    db._executeTransaction
      collections:
        read: read
        write: write
        allowImplicit: no
      action: ->
        Basis::Space.destroy('_default')
        return
    return



module.exports = (Module)->
  {
    BaseMigration

  } = Module::
  {wrap} = Module::Utils.co

  class CreateTomatosMigration extends BaseMigration
    @inheritProtected()
    @module Module

    @change ->
      @reversible wrap (dir)->
        TomatosCollection = @collection.facade.retriveProxy 'TomatosCollection'
        items = [
          id: '1'
          name: '1-test'
          description: '1-test description'
        ,
          id: '2'
          name: '2-test'
          description: '2-test description'
        ,
          id: '3'
          name: '3-test'
          description: '3-test description'
        ,
          id: '4'
          name: '4-test'
          description: '4-test description'
        ,
          id: '5'
          name: '5-test'
          description: '5-test description'
        ]
        for item in items
          yield dir.up   wrap ->
            yield TomatosCollection.create item
            yield return
          yield dir.down wrap ->
            yield TomatosCollection.destroy item.id
            yield return
          yield return
        yield return


  CreateTomatosMigration.initialize()
