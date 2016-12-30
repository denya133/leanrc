cleanCallback = (message = 'Job ID:') ->
  eval """
  (function (result, jobData, job) {
    var queueName = job.queue;
    var queue = require('@arangodb/foxx/queues').get(job.queue);
    var job = queue.get(job._id);
    console.log('#{message}', queueName, job.id, job.status);
    if (job.status === 'complete') {
      queue.delete(job.id);
    }
  })
  """

cleanConfig = (successMessage = 'Job success:', failureMessage = 'Job failure:') ->
  success: cleanCallback successMessage
  failure: cleanCallback failureMessage

module.exports = FoxxMC::Utils.cleanConfig =
  cleanCallback: cleanCallback
  cleanConfig: cleanConfig
