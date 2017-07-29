

module.exports = (Module)->
  {
    Resource
    BodyParseMixin
  } = Module::

  class CucumbersResource extends Resource
    @inheritProtected()
    @include BodyParseMixin
    @module Module

    # @initialHook 'checkSchemaVersion'
    @initialHook 'parseBody', only: ['create', 'update']

    @public entityName: String,
      default: 'cucumber'


  CucumbersResource.initialize()
