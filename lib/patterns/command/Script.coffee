

# написать пример использования в приложении

module.exports = (Module)->
  {co} = Module::Utils

  class Script extends Module::SimpleCommand
    @inheritProtected()
    @implements Module::ScriptInterface

    @module Module

    @public @static do: Function,
      default: (lambda)->
        @public @async body: Function,
          default: lambda

    @public execute: Function,
      default: (aoNotification)->
        co =>
          #принимаем из нотификации данные, запускаем @body(), ждем пока отработает, посылаем сигнал о том, что обработка закончилась
          # в конце надо послать сигнал либо с пустым телом, либо с ошибкой.
          voBody = aoNotification.getBody()
          reverse = aoNotification.getType()
          try
            yield @body voBody
            voResult = null
          catch err
            voResult = err
          @sendNotification Module::JOB_RESULT, voResult, reverse
        return

  Script.initialize()
