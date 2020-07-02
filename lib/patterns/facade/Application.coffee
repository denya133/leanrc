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
    LIGHTWEIGHT
    APPLICATION_MEDIATOR
    AnyT
    FuncG, MaybeG, StructG, UnionG
    ApplicationInterface, ContextInterface, ResourceInterface
    Pipes
    ConfigurableMixin
    Utils: {uuid}
  } = Module::
  {
    PipeAwareModule
  } = Pipes::

  class Application extends PipeAwareModule
    @inheritProtected()
    @include ConfigurableMixin
    @implements ApplicationInterface
    @module Module

    @const LOGGER_PROXY: 'LoggerProxy'
    @const CONNECT_MODULE_TO_LOGGER: 'connectModuleToLogger'
    @const CONNECT_SHELL_TO_LOGGER: 'connectShellToLogger'
    @const CONNECT_MODULE_TO_SHELL: 'connectModuleToShell'

    @public isLightweight: Boolean
    @public context: MaybeG ContextInterface

    @public @static NAME: String,
      get: -> @Module.name

    @public start: Function,
      default: ->
        @facade.startup @
        return

    @public finish: Function,
      default: ->
        @facade.remove()
        # @facade = undefined
        return

    @public @async migrate: FuncG([MaybeG StructG until: MaybeG String]),
      default: (opts)->
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.migrate opts

    @public @async rollback: FuncG([MaybeG StructG steps: MaybeG(Number), until: MaybeG String]),
      default: (opts)->
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.rollback opts

    @public @async run: FuncG([String, MaybeG AnyT], MaybeG AnyT),
      default: (scriptName, data)->
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.run scriptName, data

    @public @async execute: FuncG([String, StructG({
      context: ContextInterface, reverse: String
    }), String], StructG {
      result: MaybeG(AnyT), resource: ResourceInterface
    }),
      default: (resourceName, {context, reverse}, action)->
        @context = context
        appMediator = @facade.retrieveMediator APPLICATION_MEDIATOR
        return yield appMediator.execute resourceName, {context, reverse}, action

    @public init: FuncG([
      MaybeG UnionG Symbol, Object
      MaybeG Object
    ]),
      default: (symbol, data)->
        {ApplicationFacade} = @constructor.Module.NS ? @constructor.Module::
        isLightweight = symbol is LIGHTWEIGHT
        {NAME, name} = @constructor
        if isLightweight
          @super ApplicationFacade.getInstance "#{NAME ? name}|>#{uuid.v4()}"
        else
          @super ApplicationFacade.getInstance NAME ? name
        @isLightweight = isLightweight
        return


    @initialize()
