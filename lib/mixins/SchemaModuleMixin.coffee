# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

# миксин может подмешиваться в наследники класса Module

module.exports = (Module)->
  {
    FuncG, MaybeG
    Module: ModuleClass
    Mixin
    Utils: { _, filesListSync }
  } = Module::

  Module.defineMixin Mixin 'SchemaModuleMixin', (BaseClass = ModuleClass) ->
    class extends BaseClass
      @inheritProtected()

      # TODO: после того как все приложения будут переведены на использование связки loadMigrations-requireMigrations, этот метод надо удалить.
      @public @static defineMigrations: FuncG([MaybeG String]), # deprecated
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

      @public @static loadMigrations: FuncG([MaybeG String]),
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

      @public @static requireMigrations: FuncG([MaybeG String]),
        default: (asRoot = @::ROOT ? '.') ->
          vsMigratonsDir = "#{asRoot}/migrations"
          @::MIGRATION_NAMES.forEach (i)=>
            migrationName = i.replace /\.js|\.coffee/, ''
            vsMigrationPath = "#{vsMigratonsDir}/#{migrationName}"
            require(vsMigrationPath) @Module
          return


      @initializeMixin()
