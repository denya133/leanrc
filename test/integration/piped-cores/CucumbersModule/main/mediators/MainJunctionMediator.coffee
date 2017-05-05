

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

  class MainJunctionMediator extends JunctionMediator
    @inheritProtected()
    @include LoggingJunctionMixin
    @module Module

    ipoMultitonKey = Symbol.for '~multitonKey'

    @public @static NAME: String,
      default: 'CucumbersMainJunctionMediator'

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
        @super MainJunctionMediator.NAME, Junction.new()


  MainJunctionMediator.initialize()
