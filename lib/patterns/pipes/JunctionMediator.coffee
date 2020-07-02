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
    PointerT
    FuncG, SampleG, SubsetG
    NotificationInterface, PipeMessageInterface, MediatorInterface
    Junction
    Mediator
  } = Module::
  {
    INPUT
    OUTPUT
  } = Junction

  class JunctionMediator extends Mediator
    @inheritProtected()

    @module Module

    @public @static ACCEPT_INPUT_PIPE: String,
      default: 'acceptInputPipe'
    @public @static ACCEPT_OUTPUT_PIPE: String,
      default: 'acceptOutputPipe'
    @public @static REMOVE_PIPE: String,
      default: 'removePipe'

    ipoJunction = PointerT @protected junction: SampleG(Junction),
      get: ->
        @getViewComponent()

    @public listNotificationInterests: FuncG([], Array),
      default: ->
        [
          JunctionMediator.ACCEPT_INPUT_PIPE
          JunctionMediator.ACCEPT_OUTPUT_PIPE
          JunctionMediator.REMOVE_PIPE
        ]

    @public handleNotification: FuncG(NotificationInterface),
      default: (aoNotification)->
        switch aoNotification.getName()
          when JunctionMediator.ACCEPT_INPUT_PIPE
            inputPipeName = aoNotification.getType()
            inputPipe = aoNotification.getBody()
            if @[ipoJunction].registerPipe inputPipeName, INPUT, inputPipe
              @[ipoJunction].addPipeListener inputPipeName, @, @handlePipeMessage
          when JunctionMediator.ACCEPT_OUTPUT_PIPE
            outputPipeName = aoNotification.getType()
            outputPipe = aoNotification.getBody()
            @[ipoJunction].registerPipe outputPipeName, OUTPUT, outputPipe
          when JunctionMediator.REMOVE_PIPE
            outputPipeName = aoNotification.getType()
            @[ipoJunction].removePipe outputPipeName
        return

    @public handlePipeMessage: FuncG(PipeMessageInterface),
      default: (aoMessage)->
        @sendNotification aoMessage.getType(), aoMessage

    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], MediatorInterface),
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: FuncG(MediatorInterface, Object),
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
