inflect = do require 'i'
itemDecorator = require './itemDecorator'


module.exports = (resource, action, aoData)->
  resource = resource.replace(/[/]/g, '_').replace /[_]$/g, ''
  "#{inflect.singularize inflect.underscore resource}": itemDecorator aoData
