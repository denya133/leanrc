

module.exports = (Module) ->
  {
    LoggingJunctionMixin
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
    @include LoggingJunctionMixin
    @module Module

    @public @static NAME: String,
      default: 'TomatosHttpClientJunctionMediator'

    @public listNotificationInterests: Function,
      default: (args...)->
        @super args...

    @public handleNotification: Function,
      default: (note)->
        switch note.getName()
          when 'some_signal_name'

          else
            @super note

    @public handlePipeMessage: Function,
      default: (aoMessage)->
        # ... some code
        return

    @public init: Function,
      default: ->
        @super HttpClientJunctionMediator.NAME, Junction.new()


  HttpClientJunctionMediator.initialize()
