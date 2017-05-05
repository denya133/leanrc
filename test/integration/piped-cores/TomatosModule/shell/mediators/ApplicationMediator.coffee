

module.exports = (Module) ->
  {
    Mediator
  } = Module::

  class ApplicationMediator extends Mediator
    @inheritProtected()
    @module Module

    # ... здесь надо что-то написать

  ApplicationMediator.initialize()
