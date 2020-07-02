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

module.exports = (Module)->
  {
    PointerT
    FuncG, ListG, DictG, EnumG
    PipeFittingInterface, PipeMessageInterface
    PipeListener
    CoreObject
  } = Module::

  class Junction extends CoreObject
    @inheritProtected()
    @module Module

    @public @static INPUT: String,
      default: 'input'
    @public @static OUTPUT: String,
      default: 'output'

    iplInputPipes = PointerT @protected inputPipes: ListG String
    iplOutputPipes = PointerT @protected outputPipes: ListG String
    iplPipesMap = PointerT @protected pipesMap: DictG String, PipeFittingInterface
    iplPipeTypesMap = PointerT @protected pipeTypesMap: DictG String, EnumG [
      Junction.INPUT
      Junction.OUTPUT
    ]

    @public registerPipe: FuncG([
      String, String, PipeFittingInterface
    ], Boolean),
      default: (name, type, pipe)->
        vbSuccess = yes
        unless @[iplPipesMap][name]?
          @[iplPipesMap][name] = pipe
          @[iplPipeTypesMap][name] = type
          switch type
            when Junction.INPUT
              @[iplInputPipes].push name
            when Junction.OUTPUT
              @[iplOutputPipes].push name
            else
              vbSuccess = no
        else
          vbSuccess = no
        vbSuccess

    @public hasPipe: FuncG(String, Boolean),
      default: (name)->
        @[iplPipesMap][name]?

    @public hasInputPipe: FuncG(String, Boolean),
      default: (name)->
        @hasPipe(name) and @[iplPipeTypesMap][name] is Junction.INPUT

    @public hasOutputPipe: FuncG(String, Boolean),
      default: (name)->
        @hasPipe(name) and @[iplPipeTypesMap][name] is Junction.OUTPUT

    @public removePipe: FuncG(String),
      default: (name)->
        if @hasPipe name
          type = @[iplPipeTypesMap][name]
          pipesList = switch type
            when Junction.INPUT
              @[iplInputPipes]
            when Junction.OUTPUT
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

    @public retrievePipe: FuncG(String, PipeFittingInterface),
      default: (name)->
        @[iplPipesMap][name]

    @public addPipeListener: FuncG([String, Object, Function], Boolean),
      default: (inputPipeName, context, listener)->
        vbSuccess = no
        if @hasInputPipe inputPipeName
          pipe = @[iplPipesMap][inputPipeName]
          vbSuccess = pipe.connect PipeListener.new context, listener
        vbSuccess

    @public sendMessage: FuncG([String, PipeMessageInterface], Boolean),
      default: (outputPipeName, message)->
        vbSuccess = no
        if @hasOutputPipe outputPipeName
          pipe = @[iplPipesMap][outputPipeName]
          vbSuccess = pipe.write message
        vbSuccess

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return

    @public init: Function,
      default: (args...) ->
        @super args...
        @[iplInputPipes] = []
        @[iplOutputPipes] = []
        @[iplPipesMap] = {}
        @[iplPipeTypesMap] = {}
        return


    @initialize()
