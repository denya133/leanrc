# миксин может подмешиваться в наследники класса Module


module.exports = (Module)->
  {
    Module: ModuleClass
    Utils: { _, filesListSync }
  } = Module::

  Module.defineMixin 'SchemaModuleMixin', (BaseClass = ModuleClass) ->
    class extends BaseClass
      @inheritProtected()

      # TODO: после того как все приложения будут переведены на использование связки loadMigrations-requireMigrations, этот метод надо удалить.
      @public @static defineMigrations: Function, # deprecated
        default: (asRoot = @::ROOT ? '.') ->
          vsMigratonsDir = "#{asRoot}/migrations"
          files = filesListSync vsMigratonsDir
          vlMigrationNames = _.orderBy _.compact (files ? []).map (i)=>
            migrationName = i.replace /\.js|\.coffee/, ''
            if migrationName isnt 'BaseMigration' and not /^\.|\.md$/.test migrationName
              vsMigrationPath = "#{vsMigratonsDir}/#{migrationName}"
              require(vsMigrationPath) @Module
              migrationName
            else
              null
          @const MIGRATION_NAMES: vlMigrationNames
          return

      @public @static loadMigrations: Function,
        default: (asRoot = @::ROOT ? '.') ->
          vsMigratonsDir = "#{asRoot}/migrations"
          files = filesListSync vsMigratonsDir
          vlMigrationNames = _.orderBy _.compact (files ? []).map (i)=>
            migrationName = i.replace /\.js|\.coffee/, ''
            if migrationName isnt 'BaseMigration' and not /^\.|\.md$/.test migrationName
              migrationName
            else
              null
          @const MIGRATION_NAMES: vlMigrationNames
          return

      @public @static requireMigrations: Function,
        default: (asRoot = @::ROOT ? '.') ->
          vsMigratonsDir = "#{asRoot}/migrations"
          @::MIGRATION_NAMES.forEach (i)=>
            migrationName = i.replace /\.js|\.coffee/, ''
            vsMigrationPath = "#{vsMigratonsDir}/#{migrationName}"
            require(vsMigrationPath) @Module
          return


      @initializeMixin()
