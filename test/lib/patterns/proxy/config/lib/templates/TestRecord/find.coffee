_ = require 'lodash'
LeanRC = require.main.require 'lib'
{co, map} = LeanRC::Utils


module.exports = co.wrap (resource, action, aoData)->
  "#{@listEntityName}": yield map aoData, (i)->
    res = _.omit i, '_key', '_type', '_owner'
    yield return res
