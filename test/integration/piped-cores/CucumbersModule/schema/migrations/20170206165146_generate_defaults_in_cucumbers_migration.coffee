

module.exports = (Module)->
  {
    BaseMigration

  } = Module::
  {wrap} = Module::Utils.co

  class GenerateDefaultsInCucumbersMigration extends BaseMigration
    @inheritProtected()
    @module Module

    @change ->
      @reversible wrap (dir)->
        CucumbersCollection = @collection.facade.retrieveProxy 'CucumbersCollection'
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
            yield CucumbersCollection.create item
            yield return
          yield dir.down wrap ->
            yield CucumbersCollection.destroy item.id
            yield return
          yield return
        yield return


  GenerateDefaultsInCucumbersMigration.initialize()
