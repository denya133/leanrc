RC      = require 'RC'
LeanRC  = require 'LeanRC'

# медиатор для запуска Permissions-клиента (возможно надо для инстанцирования клиента заиспользовать соответствующий комманд, а инстанс будет предан в нотификации в этот медиатор.)

module.exports = (Module) ->
  class Module::PermissionsModuleMediator extends LeanRC::Mediator
    @inheritProtected()
    @Module: Module

    @public permissions: Permissions::Client,
      get: -> @getViewComponent()

    @public listNotificationInterests: Function,
      default: -> [
        ApplicationFacade.CONNECT_MODULE_TO_LOGGER
        ApplicationFacade.CONNECT_SHELL_TO_LOGGER
      ]

    @public handleNotification: Function,
      default: (notification)->
        switch notification.getName()
          # Connect any Module's STDLOG to the logger's STDIN
          when ApplicationFacade.CONNECT_MODULE_TO_LOGGER
            var module = note.getBody()
            var pipe = LeanRC::Pipe.new()
            module.acceptOutputPipe(PipeAwareModule.STDLOG,pipe)
            @auth.acceptInputPipe(PipeAwareModule.STDIN,pipe)
            break
          # Bidirectionally connect shell and logger on STDLOG/STDSHELL
          when ApplicationFacade.CONNECT_SHELL_TO_LOGGER
            # The junction was passed from ShellJunctionMediator
            var junction = note.getBody()

            # Connect the shell's STDLOG to the logger's STDIN
            var shellToLog = junction.retrievePipe(PipeAwareModule.STDLOG)
            @auth.acceptInputPipe(PipeAwareModule.STDIN, shellToLog)

            # Connect the logger's STDSHELL to the shell's STDIN
            var logToShell = LeanRC::Pipe.new()
            var shellIn = junction.retrievePipe(PipeAwareModule.STDIN)
            shellIn.connectInput(logToShell)
            @auth.acceptOutputPipe(PipeAwareModule.STDSHELL,logToShell)
            break

    constructor: ->
      super 'PermissionsModuleMediator', Permissions::Client


  Module::PermissionsModuleMediator.initialize()
