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
    FuncG, MaybeG
  } = Module::
  {
    PipeMessageInterface
    FilterControlMessage
  } = Module::Pipes::

  class LogFilterMessage extends FilterControlMessage
    @inheritProtected()
    @module Module

    @public @static BASE: String,
      get: -> "#{FilterControlMessage.BASE}LoggerModule/"
    @public @static LOG_FILTER_NAME: String,
      get: -> "#{@BASE}logFilter/"
    @public @static SET_LOG_LEVEL: String,
      get: -> "#{@BASE}setLogLevel/"

    @public logLevel: Number

    @public @static filterLogByLevel: FuncG([PipeMessageInterface, MaybeG Object]),
      default: (message, params = {})->
        { logLevel } = params
        logLevel ?= 0
        if message.getHeader().logLevel > params.logLevel
          throw new Error()

    @public init: FuncG(String, MaybeG Number),
      default: (action, logLevel = 0)->
        @super action, @constructor.LOG_FILTER_NAME, null, {logLevel}
        @logLevel = logLevel
        return


    @initialize()
