

module.exports = (Module) ->
  {
    Mediator
  } = Module::

  class ApplicationMediator extends Mediator
    @inheritProtected()
    @module Module

    # ... в случае Schema тут наверно вообще ничего не будет.

  ApplicationMediator.initialize()
