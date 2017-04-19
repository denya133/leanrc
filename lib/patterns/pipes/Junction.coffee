

module.exports = (Module)->
  class Junction extends Module::CoreObject
    @inheritProtected()

    @Module: Module

    @public @static INPUT: String,
      default: 'input'
    @public @static OUTPUT: String,
      default: 'output'

    iplInputPipes = @protected inputPipes: Array
    iplOutputPipes = @protected outputPipes: Array
    iplPipesMap = @protected pipesMap: Object
    iplPipeTypesMap = @protected pipeTypesMap: Object


    @public registerPipe: Function,
      args: [String, String, Module::PipeFittingInterface]
      return: Boolean
      default: (name, type, pipe)->
        vbSuccess = yes
        unless @[iplPipesMap][name]?
          @[iplPipesMap][name] = pipe
          @[iplPipeTypesMap][name] = type
          switch type
            when Module::Junction.INPUT
              @[iplInputPipes].push name
            when Module::Junction.OUTPUT
              @[iplOutputPipes].push name
            else
              vbSuccess = no
        else
          vbSuccess = no
        vbSuccess

    @public hasPipe: Function,
      args: [String]
      return: Boolean
      default: (name)->
        @[iplPipesMap][name]?

    @public hasInputPipe: Function,
      args: [String]
      return: Boolean
      default: (name)->
        @hasPipe(name) and @[iplPipeTypesMap][name] is Module::Junction.INPUT

    @public hasOutputPipe: Function,
      args: [String]
      return: Boolean
      default: (name)->
        @hasPipe(name) and @[iplPipeTypesMap][name] is Module::Junction.OUTPUT

    @public removePipe: Function,
      args: [String]
      return: Module::NILL
      default: (name)->
        if @hasPipe name
          type = @[iplPipeTypesMap][name]
          pipesList = switch type
            when Module::Junction.INPUT
              @[iplInputPipes]
            when Module::Junction.OUTPUT
              @[iplOutputPipes]
            else
              []
          for pipe, i in pipesList
            if pipe is name
              pipesList[i..i] = []
              break
          delete @[iplPipesMap][name]
          delete @[iplPipeTypesMap][name]
        return

    @public retrievePipe: Function,
      args: [String]
      return: Module::PipeFittingInterface
      default: (name)->
        @[iplPipesMap][name]

    @public addPipeListener: Function,
      args: [String, Object, Function]
      return: Boolean
      default: (inputPipeName, context, listener)->
        vbSuccess = no
        if @hasInputPipe inputPipeName
          pipe = @[iplPipesMap][inputPipeName]
          vbSuccess = pipe.connect Module::PipeListener.new context, listener
        vbSuccess

    @public sendMessage: Function,
      args: [String, Module::PipeMessageInterface]
      return: Boolean
      default: (outputPipeName, message)->
        vbSuccess = no
        if @hasOutputPipe outputPipeName
          pipe = @[iplPipesMap][outputPipeName]
          vbSuccess = pipe.write message
        vbSuccess

    constructor: (args...) ->
      super args...
      @[iplInputPipes] = []
      @[iplOutputPipes] = []
      @[iplPipesMap] = {}
      @[iplPipeTypesMap] = {}


  Junction.initialize()
