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
    FuncG, ListG, MaybeG
    PipeFittingInterface, PipeMessageInterface
    LineControlMessage: { SORT, FLUSH, FIFO }
    Pipe
  } = Module::

  class Line extends Pipe
    @inheritProtected()
    @module Module

    ipoOutput = PointerT Symbol.for '~output'
    ipsMode = PointerT @protected mode: String,
      default: SORT
    iplMessages = PointerT @protected messages: MaybeG ListG PipeMessageInterface

    ipmSort = PointerT @protected sortMessagesByPriority: FuncG([
      PipeMessageInterface, PipeMessageInterface
    ], Number),
      default: (msgA, msgB)->
        vnNum = 0
        if msgA.getPriority() < msgB.getPriority()
          vnNum = -1
        if msgA.getPriority() > msgB.getPriority()
          vnNum = 1
        return vnNum

    ipmStore = PointerT @protected store: FuncG(PipeMessageInterface),
      default: (aoMessage)->
        @[iplMessages] ?= []
        @[iplMessages].push aoMessage
        if @[ipsMode] is SORT
          @[iplMessages].sort @[ipmSort].bind @
        return

    ipmFlush = PointerT @protected flush: FuncG([], Boolean),
      default: ->
        vbSuccess = yes
        @[iplMessages] ?= []
        while (voMessage = @[iplMessages].shift())?
          ok = @[ipoOutput].write voMessage
          unless ok
            vbSuccess = no
        vbSuccess

    @public write: FuncG(PipeMessageInterface, Boolean),
      default: (aoMessage)->
        vbSuccess = yes
        voOutputMessage = null
        switch aoMessage.getType()
          when Module::PipeMessage.NORMAL
            @[ipmStore] aoMessage
          when FLUSH
            vbSuccess = @[ipmFlush]()
          when SORT, FIFO
            @[ipsMode] = aoMessage.getType()
        return vbSuccess

    @public init: FuncG([MaybeG PipeFittingInterface]),
      default: (aoOutput=null)->
        @super aoOutput
        return


    @initialize()
