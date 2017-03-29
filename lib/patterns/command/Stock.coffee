# по сути здесь надо повторить (скопипастить) код из FoxxMC::Controller

RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Stock extends LeanRC::SimpleCommand
    @inheritProtected()
    @include RC::ChainsMixin
    @implements LeanRC::StockInterface

    @Module: LeanRC

    @public @virtual Collection: RC::Class # like Model in FoxxMC::Controller

    # под вопросом
    @public @virtual query: Object
    @public @virtual body: Object
    @public @virtual recordId: String
    @public @virtual patchData: Object
    @public @virtual currentUser: RC::Constants.ANY


    @public @static actions: Object,
      default: {}
      get: (__actions)->
        fromSuper = if @__super__?
          @__super__.constructor.actions
        __actions[@name] ?= do =>
          RC::Utils.extend []
          , (fromSuper ? [])
          , (@["_#{@name}_actions"] ? [])
        __actions[@name]

    @public @static action: Function,
      default: (nameDefinition, config)->
        [actionName] = Object.keys nameDefinition
        @["_#{@name}_actions"] ?= []
        @["_#{@name}_actions"].push actionName
        @public arguments...

    # под вопросом ??????
    @public permitBody: Function, # через эту функцию должен пропускаться payload пришедший от браузера
      args: []
      return: RC::Constants.NILL

    @action list: Function,
      default: ({queryParams, pathPatams, currentUserId, headers, body })->
        return
    @action detail: Function,
      default: ({queryParams, pathPatams, currentUserId, headers, body })->
        return
    @action create: Function,
      default: ({queryParams, pathPatams, currentUserId, headers, body })->
        return
    @action update: Function,
      default: ({queryParams, pathPatams, currentUserId, headers, body })->
        return
    @action delete: Function,
      default: ({queryParams, pathPatams, currentUserId, headers, body })->
        return

    # здесь не декларируются before/after хуки, потому что их использование относится сугубо к реализации, но не к спецификации интерфейса как такового.


    @public execute: Function,
      default: (aoNotification)->
        voBody = aoNotification.getBody()
        voResult = @[aoNotification.getType()]? voBody
        @sendNotification LeanRC::Constants.HANDLER_RESULT, voResult, voBody.reverse


  return LeanRC::Stock.initialize()
