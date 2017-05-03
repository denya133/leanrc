RC      = require 'RC'
LeanRC  = require 'LeanRC'

handleAnimateRobot = null

module.exports = (Module) ->
  class Module::CoreMediator extends LeanRC::JunctionMediator
    @inheritProtected()
    @Module: Module

    @public @static NAME: String,
      default: 'GroupsCoreJunctionMediator'

    @public listNotificationInterests: Function,
      default: (args...)->
        interests = @super args...
        # interests.push ApplicationFacade.EXPORT_LOG_BUTTON
        interests

    @public handleNotification: Function,
      default: (aoNotification)->
        switch aoNotification.getName()
          when LeanRC::JunctionMediator.ACCEPT_INPUT_PIPE
            name = aoNotification.getType()
            if name is LeanRC::PipeAwareModule.STDIN
              pipe = aoNotification.getBody()
              tee = junction.retrievePipe LeanRC::PipeAwareModule.STDIN
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
        teeMerge = LeanRC::TeeMerge.new()
        filter = LeanRC::Filter.new LogFilterMessage.LOG_FILTER_NAME, null, LogFilterMessage.filterLogByLevel
        filter.connect LeanRC::PipeListener.new @, @handlePipeMessage
        teeMerge.connect filter
        junction.registerPipe LeanRC::PipeAwareModule.STDIN, LeanRC::Junction.INPUT, teeMerge
        return

    constructor: ->
      super @constructor.NAME, LeanRC::Junction.new()


  Module::CoreMediator.initialize()
