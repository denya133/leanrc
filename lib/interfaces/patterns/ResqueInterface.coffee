

module.exports = (Module)->
  {
    AnyT, NilT
    FuncG, ListG, StructG, MaybeG, UnionG
    QueueInterface
    ProxyInterface
  } = Module::

  class ResqueInterface extends ProxyInterface
    @inheritProtected()
    @module Module

    @virtual tmpJobs: ListG StructG {
      queueName: String
      scriptName: String
      data: AnyT
      delay: MaybeG Number
      id: String
    }

    @virtual fullQueueName: FuncG String, String

    @virtual @async create: FuncG [String, MaybeG Number], QueueInterface

    @virtual @async all: FuncG [], ListG QueueInterface

    @virtual @async get: FuncG String, MaybeG QueueInterface

    @virtual @async remove: FuncG String, NilT

    @virtual @async update: FuncG [String, Number], QueueInterface

    @virtual @async delay: FuncG [String, String, AnyT, MaybeG Number], UnionG String, Number

    @virtual @async getDelayed: FuncG [], ListG StructG {
      queueName: String
      scriptName: String
      data: AnyT
      delay: MaybeG Number
      id: String
    }

    #=============== Must be realized in mixin =========

    @virtual @async ensureQueue: FuncG [String, MaybeG Number], StructG name: String, concurrency: Number

    @virtual @async getQueue: FuncG String, MaybeG StructG name: String, concurrency: Number

    @virtual @async removeQueue: FuncG String, NilT

    @virtual @async allQueues: FuncG [], ListG StructG name: String, concurrency: Number

    @virtual @async pushJob: FuncG [String, String, AnyT, MaybeG Number], UnionG String, Number

    @virtual @async getJob: FuncG [String, UnionG String, Number], MaybeG Object

    @virtual @async deleteJob: FuncG [String, UnionG String, Number], Boolean

    @virtual @async abortJob: FuncG [String, UnionG String, Number], NilT

    @virtual @async allJobs: FuncG [String, MaybeG String], ListG Object

    @virtual @async pendingJobs: FuncG [String, MaybeG String], ListG Object

    @virtual @async progressJobs: FuncG [String, MaybeG String], ListG Object

    @virtual @async completedJobs: FuncG [String, MaybeG String], ListG Object

    @virtual @async failedJobs: FuncG [String, MaybeG String], ListG Object


    @initialize()
