joi           = require 'joi'
request       = require '@arangodb/request'
util          = require 'util'
runJob        = require '../utils/runJob'
defineClasses = require '../utils/defineClasses'

{streamServer} = module.context.configuration

# For test
# {
#   "mount": "api",
#   "db": "<db name>",
#   "signal": "updateObject",
#   "modelName": "user",
#   "record_id": "5aa055e2-6a53-4868-9b61-4cfa885164ef"
# }

dataSchema =  joi.object(
  mount:        joi.string().required()
  db:           joi.string().required()
  signal:       joi.string().required()
  modelName:    joi.string().required()
  record_id:    joi.string().required()
).required()

runScript = ({ROOT, context}={})->
  defineClasses "#{ROOT}dist", no
  response = {}

  runJob
    context: context ? module.context
    command: (rawData, jobId) ->
      {value:data} = dataSchema.validate rawData

      payload = {}
      {
        signal    :payload.signal
        modelName :payload.modelName
        record_id :payload.record_id
      } = data

      response = request.post "#{streamServer}_stream/#{data.db}/#{data.mount}/signals",
        body: JSON.stringify payload
        headers:
          'accept': 'application/json'
          'Content-Type': 'application/json'

  # чтобы не накапливались не законченные джобы о доставке сигнала.
  # if response.body
  #   console.log 'response.body', response.body
  #   response.body = JSON.parse response.body
  #   if response.statusCode // 100 isnt 2
  #     throw new Error util.format(
  #       'Server returned HTTP status %s with message: %s'
  #       response.statusCode
  #       response.body.message
  #     )
  # else if response.statusCode // 100 isnt 2
  #   throw new Error 'Server sent an empty response with status ' + response.statusCode
  response.body

module.exports = runScript
