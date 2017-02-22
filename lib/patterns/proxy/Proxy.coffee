RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Proxy extends RC::CoreObject
    @implements LeanRC::ProxyInterface



  return LeanRC::Proxy.initialize()
