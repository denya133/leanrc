queues        = require '@arangodb/foxx/queues'
runJob        = require '../utils/runJob'


module.exports = (FoxxMC)->
  FoxxMC::Scripts.touchQueue = ({ROOT, context}={})->
    runJob
      context: context ? module.context
      command: (rawData, jobId) ->
        queues._updateQueueDelay()
    return yes

  FoxxMC::Scripts.touchQueue
