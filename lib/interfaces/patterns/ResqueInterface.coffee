# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

module.exports = (Module)->
  {
    AnyT
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

    @virtual @async remove: FuncG String

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

    @virtual @async removeQueue: FuncG String

    @virtual @async allQueues: FuncG [], ListG StructG name: String, concurrency: Number

    @virtual @async pushJob: FuncG [String, String, AnyT, MaybeG Number], UnionG String, Number

    @virtual @async getJob: FuncG [String, UnionG String, Number], MaybeG Object

    @virtual @async deleteJob: FuncG [String, UnionG String, Number], Boolean

    @virtual @async abortJob: FuncG [String, UnionG String, Number]

    @virtual @async allJobs: FuncG [String, MaybeG String], ListG Object

    @virtual @async pendingJobs: FuncG [String, MaybeG String], ListG Object

    @virtual @async progressJobs: FuncG [String, MaybeG String], ListG Object

    @virtual @async completedJobs: FuncG [String, MaybeG String], ListG Object

    @virtual @async failedJobs: FuncG [String, MaybeG String], ListG Object


    @initialize()
