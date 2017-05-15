_ = require 'lodash'


module.exports = (aoData)->
  _.pick aoData, [
    'id', 'type', 'rev', 'isHidden'
    'name', 'description'
    'createdAt', 'updatedAt', 'deletedAt'
  ]
