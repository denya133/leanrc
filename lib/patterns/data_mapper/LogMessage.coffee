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

module.exports = (Module) ->
  {
    AnyT
    FuncG, ListG, MaybeG
  } = Module::
  {
    PipeMessage
  } = Module::Pipes::

  class LogMessage extends PipeMessage
    @inheritProtected()
    @module Module

    @public @static DEBUG: Number,
      default: 5
    @public @static INFO: Number,
      default: 4
    @public @static WARN: Number,
      default: 3
    @public @static ERROR: Number,
      default: 2
    @public @static FATAL: Number,
      default: 1
    @public @static NONE: Number,
      default: 0
    @public @static CHANGE: Number,
      default: -1

    @public @static LEVELS: ListG(String),
      default: [ 'NONE', 'FATAL', 'ERROR', 'WARN', 'INFO', 'DEBUG' ]
    @public @static SEND_TO_LOG: String,
      get: ->
        PipeMessage.BASE + 'LoggerModule/sendToLog'
    @public @static STDLOG: String,
      default: 'standardLog'

    @public logLevel: Number,
      get: -> @getHeader().logLevel
      set: (logLevel)->
        header = @getHeader()
        header.logLevel = logLevel
        @setHeader header
        logLevel

    @public sender: String,
      get: -> @getHeader().sender
      set: (sender)->
        header = @getHeader()
        header.sender = sender
        @setHeader header
        sender

    @public time: String,
      get: -> @getHeader().time
      set: (time)->
        header = @getHeader()
        header.time = time
        @setHeader header
        time

    @public message: MaybeG(AnyT),
      get: -> @getBody()

    @public init: FuncG([Number, String, AnyT]),
      default: (logLevel, sender, message)->
        time = new Date().toISOString()
        headers = {logLevel, sender, time}
        @super PipeMessage.NORMAL, headers, message
        return


    @initialize()
