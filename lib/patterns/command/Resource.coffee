# по сути здесь надо повторить (скопипастить) код из FoxxMC::Controller

RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Resource extends LeanRC::SimpleCommand
    @inheritProtected()
    @include RC::ChainsMixin
    @implements LeanRC::ResourceInterface

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

    # input and output декорирующих функций здесь не должно быть. Этим должны заниматься viewSerializers, которые должны объявляться в медиаторах либо в viewComponent's. (может быть их лучше назвать Presenter'ами, потому что рендеринг html перед отправкой в браузер должен осуществляться черезь подобные классы.)

    @public execute: Function,
      default: (aoNotification)->
        voBody = aoNotification.getBody()
        switch aoNotification.getType()
          when 'list'
            @list voBody
          when 'detail'
            @detail voBody
          when 'create'
            @create voBody
          when 'update'
            @update voBody
          when 'delete'
            @delete voBody


  return LeanRC::Resource.initialize()
