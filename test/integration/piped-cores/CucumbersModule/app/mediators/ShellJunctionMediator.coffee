RC      = require 'RC'
LeanRC  = require 'LeanRC'

# это медиатор, для ораганизации пайпов между Core и сторонними ядрами-клиентами чтобы обмениваться данными со сторонними (отдельно запущенными) микросервисами.

module.exports = (Module) ->
  class Module::ShellJunctionMediator extends LeanRC::JunctionMediator
    @inheritProtected()
    @Module: Module

    @public @static CONSOLE_MEDIATOR: String,
      default: 'consoleMediator'

    @public listNotificationInterests: Function,
      default: (args...)->
        interests = @super args...
        interests.push LogMessage.SEND_TO_LOG
        interests.push LogFilterMessage.SET_LOG_LEVEL

        interests.push Module::Constants.REQUEST_LOG_WINDOW
        interests.push Module::Constants.REQUEST_LOG_BUTTON
        interests.push Module::Constants.CONNECT_MODULE_TO_SHELL
        interests

    @public handleNotification: Function,
      default: (aoNotification)->
        switch aoNotification.getName()
          when Module::Constants.REQUEST_LOG_WINDOW
            sendNotification(LogMessage.SEND_TO_LOG,"Requesting log button from LoggerModule.",LogMessage.LEVELS[LogMessage.DEBUG])
            junction.sendMessage(PipeAwareModule.STDLOG,new UIQueryMessage(UIQueryMessage.GET,LoggerModule.LOG_BUTTON_UI))
            break
          when Module::Constants.REQUEST_LOG_BUTTON
            sendNotification(LogMessage.SEND_TO_LOG,"Requesting log window from LoggerModule.",LogMessage.LEVELS[LogMessage.DEBUG])
            junction.sendMessage(PipeAwareModule.STDLOG,new UIQueryMessage(UIQueryMessage.GET,LoggerModule.LOG_WINDOW_UI))
            break
          when Module::Constants.CONNECT_MODULE_TO_SHELL
            sendNotification(LogMessage.SEND_TO_LOG,"Connecting new module instance to Shell.",LogMessage.LEVELS[LogMessage.DEBUG])

            # Connect a module's STDSHELL to the shell's STDIN
            var module = note.getBody()
            var moduleToShell = LeanRC::Pipe.new()
            module.acceptOutputPipe(PipeAwareModule.STDSHELL, moduleToShell)
            var shellIn = junction.retrievePipe(PipeAwareModule.STDIN)
            shellIn.connectInput(moduleToShell)

            # Connect the shell's STDOUT to the module's STDIN
            var shellToModule = LeanRC::Pipe.new()
            module.acceptInputPipe(PipeAwareModule.STDIN, shellToModule)
            var shellOut = junction.retrievePipe(PipeAwareModule.STDOUT)
            shellOut.connect(shellToModule)
            break
          else
            @super aoNotification

    @public handlePipeMessage: Function,
      default: (aoMessage)->
        switch aoMessage.name
          when LoggerModule.LOG_BUTTON_UI
            sendNotification(ApplicationFacade.SHOW_LOG_BUTTON, UIQueryMessage(message).component, UIQueryMessage(message).name )
            junction.sendMessage(PipeAwareModule.STDLOG,new LogMessage(LogMessage.INFO,this.multitonKey,'Recieved the Log Button on STDSHELL'))
            break
          when LoggerModule.LOG_WINDOW_UI
            sendNotification(ApplicationFacade.SHOW_LOG_WINDOW, UIQueryMessage(message).component, UIQueryMessage(message).name )
            junction.sendMessage(PipeAwareModule.STDLOG,new LogMessage(LogMessage.INFO,this.multitonKey,'Recieved the Log Window on STDSHELL'))
            break
          when PrattlerModule.FEED_WINDOW_UI
            sendNotification(ApplicationFacade.SHOW_FEED_WINDOW, UIQueryMessage(message).component, UIQueryMessage(message).name )
            junction.sendMessage(PipeAwareModule.STDLOG,new LogMessage(LogMessage.INFO,this.multitonKey,'Recieved the Feed Window on STDSHELL'))
            break

    @public onRegister: Function,
      default: ->
        # The STDOUT pipe from the shell to all modules
        junction.registerPipe( PipeAwareModule.STDOUT,  LeanRC::Junction.OUTPUT, LeanRC::TeeSplit.new() )

        # The STDIN pipe to the shell from all modules
        junction.registerPipe( PipeAwareModule.STDIN,  LeanRC::Junction.INPUT, LeanRC::TeeMerge.new() )
        junction.addPipeListener( PipeAwareModule.STDIN, this, handlePipeMessage )

        # The STDLOG pipe from the shell to the logger
        junction.registerPipe( PipeAwareModule.STDLOG, LeanRC::Junction.OUTPUT, LeanRC::Pipe.new() )
        sendNotification(ApplicationFacade.CONNECT_SHELL_TO_LOGGER, junction )

    constructor: ->
      super 'ShellJunctionMediator', LeanRC::Junction.new()


  Module::ShellJunctionMediator.initialize()
