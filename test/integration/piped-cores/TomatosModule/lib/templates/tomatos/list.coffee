inflect = do require 'i'
_ = require 'lodash'

module.exports = (resource, action, aoData)->
  # voData = if _.isArray aoData then aoData else [ aoData ]
  resource = resource.replace(/[/]/g, '_').replace /[_]$/g, ''
  meta: aoData.meta
  "#{inflect.pluralize inflect.underscore resource}": aoData.items.map (i)->
    _.omit i, '_key', '_type', '_owner'
