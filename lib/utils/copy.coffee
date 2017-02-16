_       = require 'lodash'

module.exports = (FoxxMC)->
  extend = require('./extend') FoxxMC
  FoxxMC::Utils.copy = (aObject)->
    if _.isArray aObject
      extend [], aObject
    else if _.isObject aObject
      extend {}, aObject
    else
      _.cloneDeep aObject


  FoxxMC::Utils.copy
