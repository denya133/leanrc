_             = require 'lodash'
joi           = require 'joi'
inflect       = require('i')()
{ db }        = require '@arangodb'
queues        = require '@arangodb/foxx/queues'
runJob        = require '../utils/runJob'
defineClasses = require '../utils/defineClasses'


dataSchema =  joi.object(
  moduleName: joi.string().required()
  className:  joi.string().required()
  id:         joi.string().empty(null)
  methodName: joi.string().required()
  args:       joi.array().items(joi.any())
)

###
{

}
###

runScript = ({ROOT, context}={})->
  defineClasses "#{ROOT}dist", no
  runJob
    context: context ? module.context
    command: (rawData, jobId) ->
      {value:data} = dataSchema.validate rawData

      Class = classes[data.moduleName]::[data.className]
      methodNameForLocks = if data.id?
        ['.find', "::#{data.methodName}"]
      else
        ".#{data.methodName}"
      {read, write} = Class.getLocksFor methodNameForLocks

      db._executeTransaction
        collections:
          read: read
          write: write
          allowImplicit: no
        action: (params) ->
          do (
            {
              moduleName
              className
              id
              methodName
              args
            }       = params
          ) ->
            LocalClass = classes[moduleName]::[className]
            if id?
              record = LocalClass.find id
              record[methodName]? args...
            else
              LocalClass[methodName]? args...
            return

        params:
          moduleName: data.moduleName
          className:  data.className
          id:         data.id
          methodName: data.methodName
          args:       data.args

      queues._updateQueueDelay()


module.exports = runScript
