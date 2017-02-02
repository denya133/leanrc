joi           = require 'joi'
request       = require '@arangodb/request'
util          = require 'util'


{streamServer} = module.context.configuration

# For test
# {
#   "db": "<db name>",
#   "signal": "updateObject",
#   "modelName": "user",
#   "record_id": "5aa055e2-6a53-4868-9b61-4cfa885164ef"
# }

dataSchema =  joi.object(
  db:           joi.string().required()
  signal:       joi.string().required()
  modelName:    joi.string().required()
  record_id:    joi.string().required()
).required()

module.exports = (FoxxMC)->
  runJob        = require('../utils/runJob') FoxxMC

  FoxxMC::Scripts.sendSignal = ({ROOT, context}={})->
    require "#{ROOT}index"
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

        response = request.post "#{streamServer}_stream/#{data.db}/stream/signals",
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

  FoxxMC::Scripts.sendSignal
