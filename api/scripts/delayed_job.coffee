_             = require 'lodash'
joi           = require 'joi'
inflect       = require('i')()
{ db }        = require '@arangodb'
queues        = require '@arangodb/foxx/queues'
runJob        = require '../lib/run_job'
classes       = require '../lib/classes'


dataSchema =  joi.object(
  className:  joi.string().required()
  id:         joi.string().empty(null)
  methodName: joi.string().required()
  args:       joi.array().items(joi.any())
)

###
{

}
###

runJob
  context: module.context
  command: (rawData, jobId) ->
    {value:data} = dataSchema.validate rawData

    Class = classes[data.className]
    methodNameForLocks = if data.id?
      ['.find', "::#{data.methodName}"]
    else
      ".#{data.methodName}"
    {read, write} = Class.getLocksFor methodNameForLocks, {in: classes}, null

    db._executeTransaction
      collections:
        read: read
        write: write
        allowImplicit: no
      action: (params) ->
        do (
          {
            className
            id
            methodName
            args
          }       = params
          classes = require '../lib/classes'
        ) ->
          LocalClass = classes[className]
          if id?
            record = LocalClass.find id
            record[methodName]? args...
          else
            LocalClass[methodName]? args...
          return

      params:
        className:  data.className
        id:         data.id
        methodName: data.methodName
        args:       data.args

    queues._updateQueueDelay()


module.exports = yes
