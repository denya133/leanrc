

module.exports = (Module)->
  {
    Resource
    BodyParseMixin
  } = Module::

  class CucumbersResource extends Resource
    @inheritProtected()
    @include BodyParseMixin
    @module Module

    @beforeHook 'parseBody', only: ['create', 'update']

    @public entityName: String,
      default: 'cucumber'


  CucumbersResource.initialize()
