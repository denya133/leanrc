# медиатор для запуска Core (возможно надо для инстанцирования клиента заиспользовать соответствующий комманд, а инстанс будет предан в нотификации в этот медиатор.)
# Core-приложение является целевым приложением модуля, потому что именно его медиаторы будут принимать по нужным протоколам сигналы из внешнего мира и как то на них реагировать.
# В этом Core отличается от Client-приложений. т.к. Client-приложения из текущего модуля не могут быть доступны извне, они нужны только для того, чтобы Core мог послать сигналы или молучить данные из сторонних (удаленных) микросервисов.


module.exports = (Module) ->
  {
    Mediator
    Pipes
  } = Module::
  {
    PipeAwareInterface
  } = Pipes::

  class CoreModuleMediator extends Mediator
    @inheritProtected()
    @Module: Module

    @public core: PipeAwareInterface,
      get: -> @getViewComponent()

    @public init: Function,
      default: (coreModule)->
        @super CoreModuleMediator.name, coreModule


  CoreModuleMediator.initialize()
