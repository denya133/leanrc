inflect = do require 'i'
itemDecorator = require './itemDecorator'

module.exports = (resource, action, aoData)->
  resource = resource.replace(/[/]/g, '_').replace /[_]$/g, ''
  meta: aoData.meta
  "#{inflect.pluralize inflect.underscore resource}":
    aoData.items.map itemDecorator
