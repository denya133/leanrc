queues        = require '@arangodb/foxx/queues'
require 'FoxxMC'

FoxxMC::Utils.runJob
  context: module.context
  command: (rawData, jobId) ->
    queues._updateQueueDelay()


module.exports = yes
