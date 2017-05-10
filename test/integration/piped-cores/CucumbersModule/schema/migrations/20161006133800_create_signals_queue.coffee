

module.exports = (Module)->
  {
    RESQUE

    BaseMigration
  } = Module::
  {wrap} = Module::Utils.co

  class CreateSignalsQueueMigration extends BaseMigration
    @inheritProtected()
    @module Module

    @up ->
      yield @execute wrap ->
        resque = @facade.retriveProxy RESQUE
        yield resque.create 'signals', 4
        yield return
      yield return

    @down ->
      yield @execute wrap ->
        resque = @facade.retriveProxy RESQUE
        yield resque.remove 'signals'
        yield return
      yield return


  CreateSignalsQueueMigration.initialize()
