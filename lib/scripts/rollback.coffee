_             = require 'lodash'
joi           = require 'joi'
fs            = require 'fs'
runJob        = require '../utils/runJob'
defineClasses = require '../utils/defineClasses'

{ db }        = require '@arangodb'


dataSchema =  joi.object(
  steps:     joi.number().required().min(1)
).required()

###
{
  "steps": 1
}
###

[rawData, jobId] = module.context.argv
{value:data} = dataSchema.validate rawData

runScript = ({ROOT}={})->
  defineClasses ROOT + "dist"
  rollback = (steps)->
    error = null
    migrations = module.context.collection 'migrations'
    migrationsDir = fs.join ROOT, 'compiled_migrations'
    query = "
      FOR doc
      IN #{module.context.collectionPrefix}migrations
      SORT doc.name DESC
      LIMIT 0, @limit
      RETURN doc.name
    "
    executedMigrations = db._query(query, limit: steps).toArray()
    for executedMigration in executedMigrations
      try
        migration = require fs.join migrationsDir, "#{executedMigration}.js"
        migration.down()
      catch err
        error = "!!! Error in migration #{executedMigration}"
        console.error error, err.message, err.stack
        break
      migrations.removeByExample name: executedMigration
    return error ? yes

  result = null
  if data?.steps? and data.steps.constructor isnt Number
    result = 'Not valid steps params'
  else
    result = rollback data?.steps ? 1

  result

module.exports = runScript
