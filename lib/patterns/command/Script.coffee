# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

# написать пример использования в приложении

module.exports = (Module)->
  {
    JOB_RESULT
    AnyT
    FuncG, MaybeG
    ScriptInterface, NotificationInterface
    ConfigurableMixin
    SimpleCommand
    Utils: { co }
  } = Module::

  class Script extends SimpleCommand
    @inheritProtected()
    @include ConfigurableMixin
    @implements ScriptInterface
    @module Module

    @public @async body: FuncG([MaybeG AnyT], MaybeG AnyT),
      default: -> yield return

    @public @static do: FuncG(Function),
      default: (lambda)->
        @public @async body: FuncG([MaybeG AnyT], MaybeG AnyT),
          default: lambda
        return

    @public @async execute: FuncG(NotificationInterface),
      default: (aoNotification)->
        #принимаем из нотификации данные, запускаем @body(), ждем пока отработает, посылаем сигнал о том, что обработка закончилась
        # в конце надо послать сигнал либо с пустым телом, либо с ошибкой.
        voBody = aoNotification.getBody()
        reverse = aoNotification.getType()
        try
          res = yield @body voBody
          voResult = {result: res}
        catch err
          console.log 'ERROR in Script::execute', err
          voResult = {error: err}
        @sendNotification JOB_RESULT, voResult, reverse
        return


    @initialize()
