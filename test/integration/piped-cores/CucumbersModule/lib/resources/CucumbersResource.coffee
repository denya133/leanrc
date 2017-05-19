

module.exports = (Module)->
  {
    Resource
  } = Module::

  class CucumbersResource extends Resource
    @inheritProtected()
    @module Module

    @public entityName: String,
      default: 'cucumber'


  CucumbersResource.initialize()
