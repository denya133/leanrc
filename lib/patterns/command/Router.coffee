# по сути здесь надо повторить (скопипастить) код из FoxxMC::Router

# example in use
###
```coffee
  Test.context.use Basis::SessionsUtil.middleware

  class Test::ApplicationRouter extends LeanRC::Router
    @inheritProtected()
    @Module: Test
    @map ->
      @namespace 'version', module: '', prefix: ':v', ->
        @resource 'invitations', except: 'delete', ->
          @post 'confirm', at: 'collection'
          @member ->
            @post 'sendInvite'
            @resource 'descendants', only: 'list', ->
              @get 'count', at: 'collection'
  module.exports = Test::ApplicationRouter.initialize()
```
###

_             = require 'lodash'
inflect       = require('i')()
RC            = require 'RC'


module.exports = (LeanRC)->
  class LeanRC::Router extends LeanRC::SimpleCommand
    @inheritProtected()
    @implements LeanRC::RouterInterface

    @Module: LeanRC

    cpsPath       = @protected @static path: String
    cpsName       = @protected @static name: String
    cpsModule     = @protected @static module: String
    cplOnly       = @protected @static only: Array
    cplVia        = @protected @static via: Array
    cplExcept     = @protected @static except: Array
    cpsAt         = @protected @static at: String
    cpsResource   = @protected @static resource: String

    cplResources  = @protected @static resources: Array
    cplRoutes     = @protected @static routes: Array

    @public @static map: Function,
      default: (lambda = ->)->
        lambda.apply @, []

    @public @static root: Function,
      default: ({to, at, resource, action})->
        return

    @public @static defineMethod: Function,
      default: (container, method, path, {to, at, resource, action}={})->
        unless path?
          throw new Error 'path is required'
        path = path.replace /^[/]/, ''
        if to?
          unless /[#]/.test to
            throw new Error '`to` must be in format `<resource>#<action>`'
          [resource, action] = to.split '#'
        if not resource? and (vsResource = @[cpsResource]) isnt ''
          resource = vsResource
        if not resource? and (vsName = @[cpsName]) isnt ''
          resource = vsName
        unless resource?
          throw new Error 'options `to` or `resource` must be defined'
        unless action?
          action = path

        path = switch at ? @[cpsAt]
          when 'member'
            "#{@[cpsPath]}:#{inflect.singularize inflect.underscore resource.replace(/[/]/g, '_').replace /[_]$/g, ''}/#{path}"
          when 'collection'
            "#{@[cpsPath]}#{path}"
          else
            "#{@[cpsPath]}#{path}"

        container.push {method, path, resource, action}
        return

    @public @static get: Function,
      default: (asPath, aoOpts)->
        @[cplRoutes] ?= []
        @defineMethod @[cplRoutes], 'get', asPath, aoOpts
        return

    @public @static post: Function,
      default: (asPath, aoOpts)->
        @[cplRoutes] ?= []
        @defineMethod @[cplRoutes], 'post', asPath, aoOpts
        return

    @public @static put: Function,
      default: (asPath, aoOpts)->
        @[cplRoutes] ?= []
        @defineMethod @[cplRoutes], 'put', asPath, aoOpts
        return

    @public @static patch: Function,
      default: (asPath, aoOpts)->
        @[cplRoutes] ?= []
        @defineMethod @[cplRoutes], 'patch', asPath, aoOpts
        return

    @public @static delete: Function,
      default: (asPath, aoOpts)->
        @[cplRoutes] ?= []
        @defineMethod @[cplRoutes], 'delete', asPath, aoOpts
        return

    @public @static resource: Function,
      default: (asName, aoOpts = null, lambda = null)->
        vcModule = @Module
        if aoOpts?.constructor is Function
          lambda = aoOpts
          aoOpts = {}
        aoOpts = {} unless aoOpts?
        {path, module:vsModule, only, via, except, at, resource} = aoOpts
        path = path?.replace /^[/]/, ''
        vsPath = if path? and path isnt ''
          "#{path}/"
        else if path? and path is ''
          ''
        else
          "#{asName}/"
        vsFullPath = switch at ? @[cpsAt]
          when 'member'
            [..., previously, empty] = @[cpsPath].split '/'
            "#{@[cpsPath]}:#{inflect.singularize inflect.underscore previously}/#{vsPath}"
          when 'collection'
            "#{@[cpsPath]}#{vsPath}"
          else
            "#{@[cpsPath]}#{vsPath}"
        vsParentName = @[cpsName]
        vsName = if vsModule? and vsModule isnt ''
          "#{vsModule}/"
        else if vsModule? and vsModule is ''
          ''
        else
          "#{asName}/"
        @[cplResources] ?= []
        class ResourceRouter extends Router
          @inheritProtected()
          @Module: vcModule
          @protected @static path: String,
            default: vsFullPath
          @protected @static name: String,
            default: "#{vsParentName}#{vsName}"
          @protected @static module: String,
            default: vsModule
          @protected @static only: Array,
            default: only
          @protected @static via: Array,
            default: via
          @protected @static except: Array,
            default: except
          @protected @static resource: String,
            default: resource
          @map lambda
        @[cplResources].push ResourceRouter.initialize()

    @public @static namespace: Function,
      default: (asName, aoOpts = null, lambda = null)->
        vcModule = @Module
        if aoOpts?.constructor is Function
          lambda = aoOpts
          aoOpts = {}
        aoOpts = {} unless aoOpts?
        {module:vsModule, prefix, at} = aoOpts
        vsParentPath = @[cpsPath]
        vsPath = if prefix? and prefix isnt ''
          "#{prefix}/"
        else if prefix? and prefix is ''
          ''
        else
          "#{asName}/"
        vsParentName = @[cpsName]
        vsName = if vsModule? and vsModule isnt ''
          "#{vsModule}/"
        else if vsModule? and vsModule is ''
          ''
        else
          "#{asName}/"
        @[cplResources] ?= []
        if lambda?.constructor is Function
          class NamespaceRouter extends Router
            @inheritProtected()
            @Module: vcModule
            @protected @static path: String,
              default: "#{vsParentPath}#{vsPath}"
            @protected @static name: String,
              default: "#{vsParentName}#{vsName}"
            @protected @static except: Array,
              default: 'all'
            @protected @static at: String,
              default: at
            @map lambda
          @[cplResources].push NamespaceRouter.initialize()

    @public @static member: Function,
      default: (lambda)->
        @namespace null, module: '', prefix: '', at: 'member', lambda

    @public @static collection: Function,
      default: (lambda = ->)->
        @namespace null, module: '', prefix: '', at: 'collection', lambda

    @public execute: Function,
      default: (aoNotification)->
        # написать код, который объявит все роуты из @constructor[cplRoutes]
        @constructor[cplRoutes].forEach (aoRouteDefinition)=>
          @sendNotification 'defineRoute', aoRouteDefinition

        @constructor[cplResources]?.forEach (ResourceRouter)=>
          resourceRouter = ResourceRouter.new()
          resourceRouter.execute aoNotification
        return

    @public @static initialize: Function,
      default: ->
        @super arguments...

        if @[cplOnly]?.constructor is String
          @[cplOnly] = [@[cplOnly]]
        if @[cplVia]?.constructor is String
          @[cplVia] = [@[cplVia]]
        if @[cplExcept]?.constructor is String
          @[cplExcept] = [@[cplExcept]]

        voMethods =
          list: 'get'
          detail: 'get'
          create: 'post'
          patch: 'patch'
          update: 'put'
          delete: 'delete'

        voPaths =
          list: ''
          detail: null
          create: ''
          patch: null
          update: null
          delete: null

        @[cplRoutes] ?= []

        if @[cpsName]? and @[cpsName] isnt ''
          if @[cplOnly]?
            @[cplOnly].forEach (asAction)=>
              vsPath = voPaths[asAction]
              vsPath ?= ':' + inflect.singularize inflect.underscore (@[cpsResource] ? @[cpsName]).replace(/[/]/g, '_').replace /[_]$/g, ''
              @defineMethod @[cplRoutes], voMethods[asAction], vsPath,
                action: asAction
                resource: @[cpsResource] ? @[cpsName]
          else if @[cplExcept]?
            for own asAction, asMethod of voMethods
              do (asAction, asMethod)=>
                if not @[cplExcept].includes('all') and not @[cplExcept].includes asAction
                  vsPath = voPaths[asAction]
                  vsPath ?= ':' + inflect.singularize inflect.underscore (@[cpsResource] ? @[cpsName]).replace(/[/]/g, '_').replace /[_]$/g, ''
                  @defineMethod @[cplRoutes], asMethod, vsPath,
                    action: asAction
                    resource: @[cpsResource] ? @[cpsName]
          else if @[cplVia]?
            @[cplVia].forEach (asCustomAction)=>
              vsPath = voPaths[asCustomAction]
              vsPath ?= ':' + inflect.singularize inflect.underscore (@[cpsResource] ? @[cpsName]).replace(/[/]/g, '_').replace /[_]$/g, ''
              if asCustomAction is 'all'
                for own asAction, asMethod of voMethods
                  do (asAction, asMethod)=>
                    @defineMethod @[cplRoutes], asMethod, vsPath,
                      action: asAction
                      resource: @[cpsResource] ? @[cpsName]
              else
                @defineMethod @[cplRoutes], voMethods[asCustomAction], vsPath,
                  action: asCustomAction
                  resource: @[cpsResource] ? @[cpsName]
          else
            for own asAction, asMethod of voMethods
              do (asAction, asMethod)=>
                vsPath = voPaths[asAction]
                vsPath ?= ':' + inflect.singularize inflect.underscore (@[cpsResource] ? @[cpsName]).replace(/[/]/g, '_').replace /[_]$/g, ''
                @defineMethod @[cplRoutes], asMethod, vsPath,
                  action: asAction
                  resource: @[cpsResource] ? @[cpsName]

        return @


  return LeanRC::Router.initialize()
