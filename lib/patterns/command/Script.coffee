

# написать пример использования в приложении

module.exports = (Module)->
  {co} = Module::Utils

  class Script extends Module::SimpleCommand
    @inheritProtected()
    # @implements Module::ScriptInterface
    @include Module::ConfigurableMixin
    @module Module

    @public @static do: Function,
      default: (lambda)->
        @public @async body: Function,
          default: lambda

    @public @async execute: Function,
      default: (aoNotification)->
        #принимаем из нотификации данные, запускаем @body(), ждем пока отработает, посылаем сигнал о том, что обработка закончилась
        # в конце надо послать сигнал либо с пустым телом, либо с ошибкой.
        voBody = aoNotification.getBody()
        reverse = aoNotification.getType()
        try
          res = yield @body voBody
          voResult = {result: res}
        catch err
          voResult = {error: err}
        @sendNotification Module::JOB_RESULT, voResult, reverse
        return

  Script.initialize()
