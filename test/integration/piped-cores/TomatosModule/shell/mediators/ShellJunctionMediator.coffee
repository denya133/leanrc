

# это медиатор, для ораганизации пайпов между Core и сторонними ядрами-клиентами чтобы обмениваться данными со сторонними (отдельно запущенными) микросервисами.

module.exports = (Module) ->
  {
    LoggingJunctionMixin
    LogMessage
    Pipes
    ApplicationFacade
    Application
  } = Module::
  {
    CONNECT_MODULE_TO_SHELL
    CONNECT_SHELL_TO_LOGGER
  } = Application::
  {
    JunctionMediator
    PipeAwareModule
    Pipe
    TeeMerge
    TeeSplit
    Junction
  } = Pipes::
  {
    INPUT
    OUTPUT
  } = Junction
  {
    STDIN
    STDOUT
    STDLOG
    STDSHELL
  } = PipeAwareModule
  {
    SEND_TO_LOG
    LEVELS
    DEBUG
    INFO
  } = LogMessage

  class ShellJunctionMediator extends JunctionMediator
    @inheritProtected()
    @include LoggingJunctionMixin
    @module Module

    @public @static NAME: String,
      default: 'TomatosShellJunctionMediator'

    @public listNotificationInterests: Function,
      default: (args...)->
        interests = @super args...

        # interests.push Module::Constants.REQUEST_LOG_WINDOW
        # interests.push Module::Constants.REQUEST_LOG_BUTTON
        interests.push CONNECT_MODULE_TO_SHELL
        interests

    @public handleNotification: Function,
      default: (aoNotification)->
        switch aoNotification.getName()
          # when Module::Constants.REQUEST_LOG_WINDOW
          #   sendNotification(LogMessage.SEND_TO_LOG,"Requesting log button from LoggerModule.",LogMessage.LEVELS[LogMessage.DEBUG])
          #   junction.sendMessage(PipeAwareModule.STDLOG,new UIQueryMessage(UIQueryMessage.GET,LoggerModule.LOG_BUTTON_UI))
          #   break
          # when Module::Constants.REQUEST_LOG_BUTTON
          #   sendNotification(LogMessage.SEND_TO_LOG,"Requesting log window from LoggerModule.",LogMessage.LEVELS[LogMessage.DEBUG])
          #   junction.sendMessage(PipeAwareModule.STDLOG,new UIQueryMessage(UIQueryMessage.GET,LoggerModule.LOG_WINDOW_UI))
          #   break
          when CONNECT_MODULE_TO_SHELL
            sendNotification(LogMessage.SEND_TO_LOG,"Connecting new module instance to Shell.",LogMessage.LEVELS[LogMessage.DEBUG])

            # Connect a module's STDSHELL to the shell's STDIN
            module = aoNotification.getBody()
            moduleToShell = Pipe.new()
            module.acceptOutputPipe STDSHELL, moduleToShell
            shellIn = junction.retrievePipe STDIN
            shellIn.connectInput moduleToShell

            # Connect the shell's STDOUT to the module's STDIN
            shellToModule = Pipe.new()
            module.acceptInputPipe STDIN, shellToModule
            shellOut = junction.retrievePipe STDOUT
            shellOut.connect shellToModule
            break
          else
            @super aoNotification

    @public handlePipeMessage: Function,
      default: (aoMessage)->
        # switch aoMessage.name
        #   when LoggerModule.LOG_BUTTON_UI
        #     sendNotification(ApplicationFacade.SHOW_LOG_BUTTON, UIQueryMessage(message).component, UIQueryMessage(message).name )
        #     junction.sendMessage(PipeAwareModule.STDLOG,new LogMessage(LogMessage.INFO,this.multitonKey,'Recieved the Log Button on STDSHELL'))
        #     break
        #   when LoggerModule.LOG_WINDOW_UI
        #     sendNotification(ApplicationFacade.SHOW_LOG_WINDOW, UIQueryMessage(message).component, UIQueryMessage(message).name )
        #     junction.sendMessage(PipeAwareModule.STDLOG,new LogMessage(LogMessage.INFO,this.multitonKey,'Recieved the Log Window on STDSHELL'))
        #     break
        #   when PrattlerModule.FEED_WINDOW_UI
        #     sendNotification(ApplicationFacade.SHOW_FEED_WINDOW, UIQueryMessage(message).component, UIQueryMessage(message).name )
        #     junction.sendMessage(PipeAwareModule.STDLOG,new LogMessage(LogMessage.INFO,this.multitonKey,'Recieved the Feed Window on STDSHELL'))
        #     break

    @public onRegister: Function,
      default: ->
        # The STDOUT pipe from the shell to all modules
        junction.registerPipe STDOUT,  OUTPUT, TeeSplit.new()

        # The STDIN pipe to the shell from all modules
        junction.registerPipe STDIN,  INPUT, TeeMerge.new()
        junction.addPipeListener STDIN, @, @handlePipeMessage

        # The STDLOG pipe from the shell to the logger
        junction.registerPipe STDLOG, OUTPUT, Pipe.new()
        sendNotification CONNECT_SHELL_TO_LOGGER, junction

    @public init: Function,
      default: ->
        @super ShellJunctionMediator.NAME, Junction.new()


  ShellJunctionMediator.initialize()
