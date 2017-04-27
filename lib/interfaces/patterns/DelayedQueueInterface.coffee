

module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class DelayedQueueInterface extends BaseClass
      @inheritProtected()

      @public @virtual resque: Module::ResqueInterface
      @public @virtual name: String
      @public @virtual concurrency: Number

      @public @async @virtual push: Function,
        args: [String, ANY, [NILL, Number]] # scriptName, data
        # последний аргумент не обязательный - delay в миллисекундах
        return: String # будем возвращать просто jobID

      @public @async @virtual get: Function,
        args: [String]
        return: Object

      @public @async @virtual delete: Function,
        args: [String]
        return: Boolean # yes - если удалено, no - если не существут job в очереди

      @public @async @virtual abort: Function, # если еще не "completed", меняем на "failed"
        args: [String]
        return: NILL

      @public @async @virtual all: Function,
        args: [[String, NILL]] # scriptName or undefined
        return: Array # массив строк jobId's

      @public @async @virtual pending: Function,
        args: [[String, NILL]] # scriptName or undefined
        return: Array # массив строк jobId's

      @public @async @virtual progress: Function,
        args: [[String, NILL]] # scriptName or undefined
        return: Array # массив строк jobId's

      @public @async @virtual completed: Function,
        args: [[String, NILL]] # scriptName or undefined
        return: Array # массив строк jobId's

      @public @async @virtual failed: Function,
        args: [[String, NILL]] # scriptName or undefined
        return: Array # массив строк jobId's


    DelayedQueueInterface.initializeInterface()
