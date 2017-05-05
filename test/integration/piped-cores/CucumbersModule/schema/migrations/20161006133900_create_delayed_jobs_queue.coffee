

module.exports = (Module)->
  {
    RESQUE

    BaseMigration
  } = Module::
  {wrap} = Module::Utils.co

  class CreateDelayedJobsQueueMigration extends BaseMigration
    @inheritProtected()
    @module Module

    @up ->
      yield @execute wrap ->
        resque = @facade.retriveProxy RESQUE
        yield resque.create 'delayed_jobs', 4
        yield return
      yield return

    @down ->
      yield @execute wrap ->
        resque = @facade.retriveProxy RESQUE
        yield resque.remove 'delayed_jobs'
        yield return
      yield return


  CreateDelayedJobsQueueMigration.initialize()
