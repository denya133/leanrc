inflect = do require 'i'
_ = require 'lodash'

module.exports = (resource, action, aoData)->
  voData = if _.isArray aoData then aoData else [ aoData ]
  "#{inflect.pluralize inflect.underscore resource}": voData.map (i)->
    _.omit i, '_key', '_type', '_owner'
