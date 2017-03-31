RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Junction extends RC::CoreObject
    @inheritProtected()

    @Module: LeanRC

    @public @static INPUT: String,
      default: 'input'
    @public @static OUTPUT: String,
      default: 'output'

    iplInputPipes = @protected inputPipes: Array
    iplOutputPipes = @protected outputPipes: Array
    iplPipesMap = @protected pipesMap: Array
    iplPipeTypesMap = @protected pipeTypesMap: Array


    @public registerPipe: Function,
      args: [String, String, LeanRC::PipeFittingInterface]
      return: Boolean
      default: (name, type, pipe)->
        vbSuccess = yes
        unless @[iplPipesMap][name]?
          @[iplPipesMap][name] = pipe
          @[iplPipeTypesMap][name] = type
          switch type
            when LeanRC::Junction.INPUT
              @[iplInputPipes].push name
              break
            when LeanRC::Junction.OUTPUT
              @[iplOutputPipes].push name
              break
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
        @hasPipe(name) and @[iplPipeTypesMap][name] is LeanRC::Junction.INPUT

    @public hasOutputPipe: Function,
      args: [String]
      return: Boolean
      default: (name)->
        @hasPipe(name) and @[iplPipeTypesMap][name] is LeanRC::Junction.OUTPUT

    @public removePipe: Function,
      args: [String]
      return: RC::Constants.NILL
      default: (name)->
        if @hasPipe name
          type = @[iplPipeTypesMap][name]
          pipesList = []
          switch type
            when LeanRC::Junction.INPUT
              pipesList = @[iplInputPipes]
              break
            when LeanRC::Junction.OUTPUT
              pipesList = @[iplOutputPipes]
              break
          for pipe, i in pipesList
            if pipe is name
              pipesList.splice i, 1
              break
          @[iplPipesMap].splice @[iplPipesMap].indexOf(name), name
          @[iplPipeTypesMap].splice @[iplPipeTypesMap].indexOf(name), name
        return

    @public retrievePipe: Function,
      args: [String]
      return: LeanRC::PipeFittingInterface
      default: (name)->
        @[iplPipesMap][name]

    @public addPipeListener: Function,
      args: [String, Object, Function]
      return: Boolean
      default: (inputPipeName, context, listener)->
        vbSuccess = no
        if @hasInputPipe inputPipeName
          pipe = @[iplPipesMap][inputPipeName]
          vbSuccess = pipe.connect LeanRC::PipeListener.new context, listener
        vbSuccess

    @public sendMessage: Function,
      args: [String, LeanRC::PipeMessageInterface]
      return: Boolean
      default: (outputPipeName, message)->
        vbSuccess = no
        if @hasOutputPipe outputPipeName
          pipe = @[iplPipesMap][outputPipeName]
          vbSuccess = pipe.write message
        vbSuccess


  return LeanRC::Junction.initialize()
