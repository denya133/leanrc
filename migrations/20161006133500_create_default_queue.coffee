{ db } = require '@arangodb'
Queues = require '@arangodb/foxx/queues'

migration =
  up: ()->
    queueName = 'default'
    try
      Queues.get queueName
    catch e
      Queues.create queueName, 1
    return
  down: ()->
    queueName = 'default'
    try
      Queues.get queueName
      Queues.delete queueName
    return

module.exports = migration
