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
    FuncG, MaybeG
    PipeAwareInterface, PipeFittingInterface
    FacadeInterface
    CoreObject
  } = Module::
  {
    ACCEPT_INPUT_PIPE
    ACCEPT_OUTPUT_PIPE
  } = Module::JunctionMediator

  class PipeAwareModule extends CoreObject
    @inheritProtected()
    @implements PipeAwareInterface
    @module Module

    @public @static STDOUT: String,
      default: 'standardOutput'
    @public @static STDIN: String,
      default: 'standardInput'
    @public @static STDLOG: String,
      default: 'standardLog'
    @public @static STDSHELL: String,
      default: 'standardShell'

    @public facade: FacadeInterface

    @public acceptInputPipe: FuncG([String, PipeFittingInterface]),
      default: (asName, aoPipe)->
        @facade.sendNotification ACCEPT_INPUT_PIPE, aoPipe, asName
        return

    @public acceptOutputPipe: FuncG([String, PipeFittingInterface]),
      default: (asName, aoPipe)->
        @facade.sendNotification ACCEPT_OUTPUT_PIPE, aoPipe, asName
        return

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: FuncG(MaybeG FacadeInterface),
      default: (aoFacade)->
        @super arguments...
        @facade = aoFacade if aoFacade?
        return


    @initialize()
