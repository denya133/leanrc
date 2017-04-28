inflect = do require 'i'
_ = require 'lodash'

module.exports = (resource, action, aoData)->
  "#{inflect.pluralize inflect.underscore resource}": aoData.map (i)->
    _.omit i, '_key', '_type', '_owner'
