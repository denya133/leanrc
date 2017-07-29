_             = require 'lodash'
inflect       = do require 'i'


module.exports = (Module)->
  {
    APPLICATION_ROUTER

    Resource
    # CheckSessionsMixin
  } = Module::

  class ItselfResource extends Resource
    @inheritProtected()
    # @include CheckSessionsMixin
    @module Module

    @public entityName: String,
      default: 'info'

    @public listNonTransactionables: Function,
      default: ->
        list = @super()
        list.push 'info'
        list

    # TODO: надо перепроверить эти хуки
    @chains ['info']

    # @initialHook 'checkSchemaVersion'
    # @initialHook 'checkSession', only: ['info']

    @action @async info: Function,
      default: ->
        applicationRouter = @facade.retrieveProxy APPLICATION_ROUTER
        Mapping = {}
        applicationRouter.routes.forEach (aoRoute)=>
          resourceName = inflect.camelize inflect.underscore "#{aoRoute.resource.replace /[/]/g, '_'}Resource"
          Mapping[resourceName] ?= []
          unless _.includes Mapping[resourceName], aoRoute.action
            Mapping[resourceName].push aoRoute.action
        allSections = Object.keys Mapping
        sections = []
        sections.push
          id: 'system'
          module: @Module.name
          actions: ['administrator']
        sections.push
          id: 'moderator'
          module: @Module.name
          actions: allSections
        sections = sections.concat allSections.map (section)=>
          id: section
          module: @Module.name
          actions: Mapping[section]

        yield return {
          version: @configs.version
          sections
        }


  ItselfResource.initialize()
