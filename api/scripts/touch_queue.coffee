queues        = require '@arangodb/foxx/queues'
runJob        = require '../lib/run_job'

runJob
  context: module.context
  command: (rawData, jobId) ->
    queues._updateQueueDelay()


module.exports = yes
