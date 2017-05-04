RC      = require 'RC'
LeanRC  = require 'LeanRC'

handleAnimateRobot = null

module.exports = (Module) ->
  {
    Pipes
  } = Module::
  {
    JunctionMediator
    Junction
    PipeAwareModule
    TeeMerge
    Filter
    PipeListener
  } = Pipes::

  class HttpClientJunctionMediator extends JunctionMediator
    @inheritProtected()
    @module Module

    @public @static NAME: String,
      default: 'TomatosHttpClientJunctionMediator'

    @public listNotificationInterests: Function,
      default: (args...)->
        interests = @super args...
        # interests.push ApplicationFacade.EXPORT_LOG_BUTTON
        interests

    @public handleNotification: Function,
      default: (aoNotification)->
        switch aoNotification.getName()
          when JunctionMediator.ACCEPT_INPUT_PIPE
            name = aoNotification.getType()
            if name is PipeAwareModule.STDIN
              pipe = aoNotification.getBody()
              tee = junction.retrievePipe PipeAwareModule.STDIN
              tee.connectInput pipe
            else
              @super aoNotification
          else
            @super aoNotification

    @public handlePipeMessage: Function,
      default: (aoMessage)->
        # ... some code
        return

    @public onRegister: Function,
      default: ->
        teeMerge = TeeMerge.new()
        filter = Filter.new LogFilterMessage.LOG_FILTER_NAME, null, LogFilterMessage.filterLogByLevel
        filter.connect PipeListener.new @, @handlePipeMessage
        teeMerge.connect filter
        junction.registerPipe PipeAwareModule.STDIN, Junction.INPUT, teeMerge
        return

    @public init: Function,
      default: ->
        @super HttpClientJunctionMediator.NAME, Junction.new()


  HttpClientJunctionMediator.initialize()
