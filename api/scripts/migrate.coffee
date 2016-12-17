_         = require 'lodash'
joi       = require 'joi'
fs        = require 'fs'
require 'FoxxMC'

{ db }    = require '@arangodb'

require '../index'

dataSchema =  joi.object(
  until:     joi.string().optional()
).required()

###
{
  "until": "20161001145600_name_of_migration"
}
###

[rawData, jobId] = module.context.argv
{value:data} = dataSchema.validate rawData


migrate = ()->
  error = null
  migrations = module.context.collection 'migrations'
  migrationsDir = fs.join __dirname, '../migrations'
  migrationNames = _.orderBy fs.list(migrationsDir).map (i)-> i.replace '.js', ''
  query = "
    FOR doc
    IN #{module.context.collectionPrefix}migrations
    FILTER doc.name == @migrationName
    RETURN doc
  "

  for migrationName in migrationNames
    unless db._query(query, {migrationName}).next()?
      migration = require fs.join migrationsDir, migrationName
      try
        migration.up(classes)
      catch err
        error = "!!! Error in migration #{migrationName}"
        console.error error, err.message, err.stack
        break

      migrations.save
        name: migrationName

    if data?.until? and data.until is migrationName
      break
  return error ? yes


module.exports = migrate()