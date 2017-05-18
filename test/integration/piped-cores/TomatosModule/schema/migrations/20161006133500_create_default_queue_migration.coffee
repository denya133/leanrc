

module.exports = (Module)->
  {
    RESQUE

    BaseMigration
  } = Module::
  {wrap} = Module::Utils.co

  class CreateDefaultQueueMigration extends BaseMigration
    @inheritProtected()
    @module Module

    @up ->
      yield @execute wrap ->
        resque = @collection.facade.retrieveProxy RESQUE
        yield resque.create 'default', 1
        yield return
      yield return

    @down ->
      yield @execute wrap ->
        resque = @collection.facade.retrieveProxy RESQUE
        yield resque.remove 'default'
        yield return
      yield return


  CreateDefaultQueueMigration.initialize()
