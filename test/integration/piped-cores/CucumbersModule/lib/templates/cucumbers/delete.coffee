inflect = do require 'i'
_ = require 'lodash'

module.exports = (resource, action, aoData)->
  voData = if _.isArray aoData then aoData[0] else aoData
  "#{inflect.singularize inflect.underscore resource}": _.omit voData, '_key', '_type', '_owner'
