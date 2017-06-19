

###
example of usage

```coffee

module.exports = (Module)->
  {
    APPLICATION_RENDERER
    APPLICATION_ROUTER

    Switch
    ArangoSwitchMixin
    CheckSchemaVersionMixin
  } = Module::

  class MainSwitch extends Switch
    @inheritProtected()
    @include ArangoSwitchMixin
    @include CheckSchemaVersionMixin
    @module Module

    @public routerName: String,
      default: APPLICATION_ROUTER
    @public jsonRendererName: String,
      default: APPLICATION_RENDERER


  MainSwitch.initialize()
```
###

module.exports = (Module)->
  {
    MIGRATIONS
    Switch
    Utils
  } = Module::
  { co } = Utils

  Module.defineMixin Switch, (BaseClass) ->
    class CheckSchemaVersionMixin extends BaseClass
      @inheritProtected()

      @public defineRoutes: Function,
        default: (args...)->
          @all '/*', co.wrap (context, next)=>
            voMigrations = @facade.retrieveProxy MIGRATIONS
            [..., lastMigration] = @Module::MIGRATION_NAMES
            includes = yield voMigrations.includes lastMigration
            if includes
              yield return next?()
            else
              throw new Error 'Code schema version is not equal current DB version'
              yield return
          @super args...
          return


    CheckSchemaVersionMixin.initializeMixin()
