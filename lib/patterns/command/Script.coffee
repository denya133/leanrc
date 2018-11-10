

# написать пример использования в приложении

module.exports = (Module)->
  {
    JOB_RESULT
    AnyT, NilT
    FuncG
    ScriptInterface, NotificationInterface
    ConfigurableMixin
    SimpleCommand
    Utils: { co }
  } = Module::

  class Script extends SimpleCommand
    @inheritProtected()
    @implements ScriptInterface
    @include ConfigurableMixin
    @module Module

    @public @static do: FuncG(Function, NilT),
      default: (lambda)->
        @public @async body: FuncG(AnyT, AnyT),
          default: lambda
        return

    @public @async execute: FuncG(NotificationInterface, NilT),
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
        @sendNotification JOB_RESULT, voResult, reverse
        return


    @initialize()
