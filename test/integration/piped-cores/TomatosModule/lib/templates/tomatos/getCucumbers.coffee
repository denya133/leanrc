itemDecorator = require './itemDecorator'


module.exports = (resource, action, aoData)->
  cucumbers:
    aoData.map itemDecorator
