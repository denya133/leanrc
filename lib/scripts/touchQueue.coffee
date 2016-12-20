queues        = require '@arangodb/foxx/queues'
runJob        = require '../utils/runJob'


runScript = ->
  runJob
    context: module.context
    command: (rawData, jobId) ->
      queues._updateQueueDelay()
  return yes

module.exports = runScript
