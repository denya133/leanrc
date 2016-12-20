{ db } = require '@arangodb'
Queues = require '@arangodb/foxx/queues'

migration =
  up: ()->
    queueName = 'signals'
    try
      Queues.get queueName
    catch e
      Queues.create queueName, 4
    return
  down: ()->
    queueName = 'signals'
    try
      Queues.get queueName
      Queues.delete queueName
    return

module.exports = migration
