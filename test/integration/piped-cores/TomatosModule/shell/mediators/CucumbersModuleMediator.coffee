

module.exports = (Module) ->
  {
    Mediator
    Pipes
  } = Module::
  {
    PipeAwareInterface
  } = Pipes::

  class CucumbersModuleMediator extends Mediator
    @inheritProtected()
    @Module: Module

    @public cucumbers: PipeAwareInterface,
      get: -> @getViewComponent()

    @public init: Function,
      default: (cucumbersModule)->
        @super CucumbersModuleMediator.name, cucumbersModule


  CucumbersModuleMediator.initialize()
