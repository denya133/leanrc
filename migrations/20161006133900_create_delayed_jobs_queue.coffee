{ db } = require '@arangodb'
Queues = require '@arangodb/foxx/queues'

migration =
  up: ()->
    queueName = 'delayed_jobs'
    try
      Queues.get queueName
    catch e
      Queues.create queueName, 4
    return
  down: ()->
    queueName = 'delayed_jobs'
    try
      Queues.get queueName
      Queues.delete queueName
    return

module.exports = migration
