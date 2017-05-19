

module.exports = (Module)->
  {
    Router
  } = Module::

  class ApplicationRouter extends Router
    @inheritProtected()
    @module Module

    @map ->
      @namespace 'version', module: '', prefix: ':v', ->
        @resource 'tomatos'
        @get 'cucumbers', to: 'tomatos#getCucumbers'


  ApplicationRouter.initialize()
