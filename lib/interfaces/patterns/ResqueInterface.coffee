

module.exports = (Module)->
  {ANY, NILL} = Module::

  class ResqueInterface extends Module::Interface
    @inheritProtected()

    @module Module

    @public @virtual fullQueueName: Function,
      args: [String]
      return: String

    @public @async @virtual create: Function,
      args: [String, Number]
      return: Module::DelayedQueueInterface

    @public @async @virtual all: Function,
      args: []
      return: Array

    @public @async @virtual get: Function,
      args: [String]
      return: Module::DelayedQueueInterface

    @public @async @virtual remove: Function,
      args: [String]
      return: NILL

    @public @async @virtual update: Function,
      args: [String, Number]
      return: Module::DelayedQueueInterface

    #=============== Must be realized in mixin =========

    @public @async @virtual ensureQueue: Function,
      args: [String, Number] # queueName, concurrency
      return: Object # {name, concurrency}
      # ... плфтформозависимая реализация

    @public @async @virtual getQueue: Function,
      args: [String] # queueName
      return: Object # {name, concurrency}
      # ... плфтформозависимая реализация

    @public @async @virtual removeQueue: Function,
      args: [String]
      return: NILL
      # ... плфтформозависимая реализация

    @public @async @virtual allQueues: Function,
      args: []
      return: Array
      # ... плфтформозависимая реализация

    @public @async @virtual pushJob: Function,
      args: [String, String, ANY, [NILL, Number]] # queueName, scriptName, data
      # последний аргумент не обязательный - delay в миллисекундах
      return: String # будем возвращать просто jobID

    @public @async @virtual getJob: Function,
      args: [String, String] # queueName, jobId
      return: Object

    @public @async @virtual deleteJob: Function,
      args: [String, String] # queueName, jobId
      return: Boolean # yes - если удалено, no - если не существут job в очереди

    @public @async @virtual abortJob: Function, # если еще не "completed", меняем на "failed"
      args: [String, String] # queueName, jobId
      return: NILL

    @public @async @virtual allJobs: Function,
      args: [String, [String, NILL]] # queueName, (scriptName or undefined)
      return: Array # массив строк jobId's

    @public @async @virtual pendingJobs: Function,
      args: [String, [String, NILL]] # queueName, (scriptName or undefined)
      return: Array # массив строк jobId's

    @public @async @virtual progressJobs: Function,
      args: [String, [String, NILL]] # queueName, (scriptName or undefined)
      return: Array # массив строк jobId's

    @public @async @virtual completedJobs: Function,
      args: [String, [String, NILL]] # queueName, (scriptName or undefined)
      return: Array # массив строк jobId's

    @public @async @virtual failedJobs: Function,
      args: [String, [String, NILL]] # queueName, (scriptName or undefined)
      return: Array # массив строк jobId's


  ResqueInterface.initialize()
