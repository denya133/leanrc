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

# миксин может подмешиваться в наследники классa JunctionMediator

module.exports = (Module)->
  {
    LogMessage
    LogFilterMessage
    Pipes
    Mixin
    PointerT
    FuncG
    NotificationInterface
  } = Module::
  {
    JunctionMediator
    PipeAwareModule
    FilterControlMessage
  } = Pipes::
  {
    SET_PARAMS
  } = FilterControlMessage
  {
    STDLOG
  } = PipeAwareModule
  {
    SEND_TO_LOG
    LEVELS
    DEBUG
    ERROR
    FATAL
    INFO
    WARN
    CHANGE
  } = LogMessage

  Module.defineMixin Mixin 'LoggingJunctionMixin', (BaseClass = JunctionMediator) ->
    class extends BaseClass
      @inheritProtected()

      ipoMultitonKey = PointerT Symbol.for '~multitonKey'
      ipoJunction = PointerT Symbol.for '~junction'

      @public listNotificationInterests: FuncG([], Array),
        default: (args...)->
          interests = @super args...
          interests.push SEND_TO_LOG
          interests.push LogFilterMessage.SET_LOG_LEVEL
          interests

      @public handleNotification: FuncG(NotificationInterface),
        default: (note)->
          switch note.getName()
            when SEND_TO_LOG
              switch note.getType()
                when LEVELS[DEBUG]
                  level = DEBUG
                  break
                when LEVELS[ERROR]
                  level = ERROR
                  break
                when LEVELS[FATAL]
                  level = FATAL
                  break
                when LEVELS[INFO]
                  level = INFO
                  break
                when LEVELS[WARN]
                  level = WARN
                  break
                else
                  level = DEBUG
                  break
              logMessage = LogMessage.new level, @[ipoMultitonKey], note.getBody()
              @[ipoJunction].sendMessage STDLOG, logMessage
              break
            when LogFilterMessage.SET_LOG_LEVEL
              logLevel = note.getBody()
              setLogLevelMessage = LogFilterMessage.new SET_PARAMS, logLevel

              @[ipoJunction].sendMessage STDLOG, setLogLevelMessage
              changedLevelMessage = LogMessage.new CHANGE, @[ipoMultitonKey], "
                Changed Log Level to: #{LogMessage.LEVELS[logLevel]}
              "
              @[ipoJunction].sendMessage STDLOG, changedLevelMessage
              break
            else
              @super note
          return


      @initializeMixin()
