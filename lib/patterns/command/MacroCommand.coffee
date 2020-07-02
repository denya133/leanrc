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

module.exports = (Module)->
  {
    ListG, FuncG, SubsetG
    CommandInterface, NotificationInterface
    Notifier
  } = Module::

  class MacroCommand extends Notifier
    @inheritProtected()
    @implements CommandInterface
    @module Module

    iplSubCommands = @private subCommands: ListG SubsetG CommandInterface

    @public execute: FuncG(NotificationInterface),
      default: (aoNotification)->
        vlSubCommands = @[iplSubCommands][..]
        for vCommand in vlSubCommands
          do (vCommand)=>
            voCommand = vCommand.new()
            voCommand.initializeNotifier @[Symbol.for '~multitonKey']
            voCommand.execute aoNotification
        @[iplSubCommands][..]
        return

    @public initializeMacroCommand: Function,
      default: ->

    @public addSubCommand: FuncG([SubsetG CommandInterface]),
      default: (aClass)->
        @[iplSubCommands].push aClass
        return

    @public init: Function,
      default: ->
        @super arguments...

        @[iplSubCommands] = []
        @initializeMacroCommand()
        return

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
