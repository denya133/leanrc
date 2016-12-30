queues        = require '@arangodb/foxx/queues'
runJob        = require '../utils/runJob'


FoxxMC::Scripts.touchQueue = ({ROOT, context}={})->
  runJob
    context: context ? module.context
    command: (rawData, jobId) ->
      queues._updateQueueDelay()
  return yes

module.exports = FoxxMC::Scripts.touchQueue
