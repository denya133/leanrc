

# example in use
###
```coffee
  Test.context.use Basis::SessionsUtil.middleware

  class Test::ApplicationRouter extends Module::Router
    @inheritProtected()
    @module Test
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
inflect       = do require 'i'



module.exports = (Module)->
  {
    NILL
    ANY

    Class
  } = Module::

  class Router extends Module::Proxy
    @inheritProtected()
    # @implements Module::RouterInterface
    @include Module::ConfigurableMixin
    @module Module

    ipsPath       = @protected path: String,
      default: '/'
    ipsName       = @protected name: String,
      default: ''
    ipsModule     = @protected module: String
    iplOnly       = @protected only: Array
    iplVia        = @protected via: Array
    iplExcept     = @protected except: Array
    ipsAt         = @protected at: String
    ipsResource   = @protected resource: String
    iplTags       = @protected tags: Array
    ipsTemplates  = @protected templates: String

    iplResources  = @protected resources: Array
    iplRoutes     = @protected routes: Array

    @public @static map: Function,
      default: (lambda = ->)->
        @public map: Function,
          args: []
          return: ANY
          default: lambda
        return

    @public map: Function,
      args: []
      return: ANY
      default: ->

    @public root: Function,
      default: ({to, at, resource, action})->
        return

    @public defineMethod: Function,
      default: (container, method, path, {to, at, resource, action, tags, template}={})->
        unless path?
          throw new Error 'path is required'
        path = path.replace /^[/]/, ''
        if to?
          unless /[#]/.test to
            throw new Error '`to` must be in format `<resource>#<action>`'
          [resource, action] = to.split '#'
        if not resource? and (vsResource = @[ipsResource]) isnt ''
          resource = vsResource
        if not resource? and (vsName = @[ipsName]) isnt ''
          resource = vsName
        unless resource?
          throw new Error 'options `to` or `resource` must be defined'
        unless action?
          action = path
        unless /[/]$/.test resource
          resource += '/'

        path = switch at ? @[ipsAt]
          when 'member'
            "#{@[ipsPath]}:#{inflect.singularize inflect.underscore resource.replace(/[/]/g, '_').replace /[_]$/g, ''}/#{path}"
          when 'collection'
            "#{@[ipsPath]}#{path}"
          else
            "#{@[ipsPath]}#{path}"
        template ?= resource + action
        container.push {method, path, resource, action, tags, template}
        return

    @public get: Function,
      default: (asPath, aoOpts)->
        @[iplRoutes] ?= []
        @defineMethod @[iplRoutes], 'get', asPath, aoOpts
        return

    @public post: Function,
      default: (asPath, aoOpts)->
        @[iplRoutes] ?= []
        @defineMethod @[iplRoutes], 'post', asPath, aoOpts
        return

    @public put: Function,
      default: (asPath, aoOpts)->
        @[iplRoutes] ?= []
        @defineMethod @[iplRoutes], 'put', asPath, aoOpts
        return

    @public delete: Function,
      default: (asPath, aoOpts)->
        @[iplRoutes] ?= []
        @defineMethod @[iplRoutes], 'delete', asPath, aoOpts
        return

    @public head: Function,
      default: (asPath, aoOpts)->
        @[iplRoutes] ?= []
        @defineMethod @[iplRoutes], 'head', asPath, aoOpts
        return

    @public options: Function,
      default: (asPath, aoOpts)->
        @[iplRoutes] ?= []
        @defineMethod @[iplRoutes], 'options', asPath, aoOpts
        return

    @public patch: Function,
      default: (asPath, aoOpts)->
        @[iplRoutes] ?= []
        @defineMethod @[iplRoutes], 'patch', asPath, aoOpts
        return

    @public resource: Function,
      default: (asName, aoOpts = null, lambda = null)->
        vcModule = @Module
        if aoOpts?.constructor is Function
          lambda = aoOpts
          aoOpts = {}
        aoOpts = {} unless aoOpts?
        {
          path, module:vsModule
          only, via, except
          tags:vlTags, templates:alTemplates
          at, resource
        } = aoOpts
        path = path?.replace /^[/]/, ''
        vsPath = if path? and path isnt ''
          "#{path}/"
        else if path? and path is ''
          ''
        else
          "#{asName}/"
        vsFullPath = switch at ? @[ipsAt]
          when 'member'
            [..., previously, empty] = @[ipsPath].split '/'
            "#{@[ipsPath]}:#{inflect.singularize inflect.underscore previously}/#{vsPath}"
          when 'collection'
            "#{@[ipsPath]}#{vsPath}"
          else
            "#{@[ipsPath]}#{vsPath}"
        vsParentName = @[ipsName]
        vsParentTemplates = if @[ipsTemplates]? and @[ipsTemplates] isnt ''
          "#{@[ipsTemplates]}/"
        else
          ''
        vsName = if vsModule? and vsModule isnt ''
          "#{vsModule}/"
        else if vsModule? and vsModule is ''
          ''
        else
          "#{asName}/"
        vsTemplates = if alTemplates? and alTemplates isnt ''
          alTemplates
        else if alTemplates? and alTemplates is ''
          ''
        else
          if vsModule? and vsModule isnt ''
            vsModule
          else if vsModule? and vsModule is ''
            ''
          else
            asName
        @[iplResources] ?= []
        tags = [].concat(@[iplTags] ? []).concat(vlTags ? [])
        class ResourceRouter extends Router
          @inheritProtected()
          @module vcModule
          @protected path: String,
            default: vsFullPath
          @protected name: String,
            default: "#{vsParentName}#{vsName}"
          @protected module: String,
            default: vsModule
          @protected only: Array,
            default: only
          @protected via: Array,
            default: via
          @protected except: Array,
            default: except
          @protected tags: Array,
            default: tags
          @protected templates: String,
            default: "#{vsParentTemplates}#{vsTemplates}"
          @protected resource: String,
            default: resource
          @map lambda
        ResourceRouter.constructor = Class
        @[iplResources].push ResourceRouter

    @public namespace: Function,
      default: (asName, aoOpts = null, lambda = null)->
        vcModule = @Module
        if aoOpts?.constructor is Function
          lambda = aoOpts
          aoOpts = {}
        aoOpts = {} unless aoOpts?
        {
          module:vsModule, prefix
          tags:vlTags, templates:alTemplates
          at
        } = aoOpts
        vsParentPath = @[ipsPath]
        vsPath = if prefix? and prefix isnt ''
          "#{prefix}/"
        else if prefix? and prefix is ''
          ''
        else
          "#{asName}/"
        vsParentName = @[ipsName]
        vsParentTemplates = if @[ipsTemplates]? and @[ipsTemplates] isnt ''
          "#{@[ipsTemplates]}/"
        else
          ''
        vsName = if vsModule? and vsModule isnt ''
          "#{vsModule}/"
        else if vsModule? and vsModule is ''
          ''
        else
          "#{asName}/"
        vsTemplates = if alTemplates? and alTemplates isnt ''
          alTemplates
        else if alTemplates? and alTemplates is ''
          ''
        else
          if vsModule? and vsModule isnt ''
            vsModule
          else if vsModule? and vsModule is ''
            ''
          else
            asName
        @[iplResources] ?= []
        tags = [].concat(@[iplTags] ? []).concat(vlTags ? [])
        class NamespaceRouter extends Router
          @inheritProtected()
          @module vcModule
          @protected path: String,
            default: "#{vsParentPath}#{vsPath}"
          @protected name: String,
            default: "#{vsParentName}#{vsName}"
          @protected except: Array,
            default: 'all'
          @protected tags: Array,
            default: tags
          @protected templates: String,
            default: "#{vsParentTemplates}#{vsTemplates}"
          @protected at: String,
            default: at
          @map lambda
        NamespaceRouter.constructor = Class
        @[iplResources].push NamespaceRouter

    @public member: Function,
      default: (lambda)->
        @namespace null, module: '', prefix: '', templates: '', at: 'member', lambda

    @public collection: Function,
      default: (lambda = ->)->
        @namespace null, module: '', prefix: '', templates: '', at: 'collection', lambda

    @public routes: Array,
      get: ->
        vlRoutes = []
        vlRoutes = vlRoutes.concat @[iplRoutes] ? []

        @[iplResources]?.forEach (ResourceRouter)=>
          resourceRouter = ResourceRouter.new()
          vlRoutes = vlRoutes.concat resourceRouter.routes ? []
        return vlRoutes

    constructor: (args...)->
      super args...
      @map()

      if @[iplOnly]?.constructor is String
        @[iplOnly] = [@[iplOnly]]
      if @[iplVia]?.constructor is String
        @[iplVia] = [@[iplVia]]
      if @[iplExcept]?.constructor is String
        @[iplExcept] = [@[iplExcept]]

      voMethods =
        list: 'get'
        detail: 'get'
        create: 'post'
        update: 'put'
        delete: 'delete'
        query: 'post'

      voPaths =
        list: ''
        detail: null
        create: ''
        update: null
        delete: null
        query: 'query'

      @[iplRoutes] ?= []

      if @[ipsName]? and @[ipsName] isnt ''
        if @[iplOnly]?
          @[iplOnly].forEach (asAction)=>
            vsPath = voPaths[asAction]
            vsPath ?= ':' + inflect.singularize inflect.underscore (@[ipsResource] ? @[ipsName]).replace(/[/]/g, '_').replace /[_]$/g, ''
            @defineMethod @[iplRoutes], voMethods[asAction], vsPath,
              action: asAction
              resource: @[ipsResource] ? @[ipsName]
              tags: @[iplTags] ? []
              template: @[ipsTemplates] + '/' + asAction
        else if @[iplExcept]?
          for own asAction, asMethod of voMethods
            do (asAction, asMethod)=>
              if not @[iplExcept].includes('all') and not @[iplExcept].includes asAction
                vsPath = voPaths[asAction]
                vsPath ?= ':' + inflect.singularize inflect.underscore (@[ipsResource] ? @[ipsName]).replace(/[/]/g, '_').replace /[_]$/g, ''
                @defineMethod @[iplRoutes], asMethod, vsPath,
                  action: asAction
                  resource: @[ipsResource] ? @[ipsName]
                  tags: @[iplTags] ? []
                  template: @[ipsTemplates] + '/' + asAction
        else if @[iplVia]?
          @[iplVia].forEach (asCustomAction)=>
            vsPath = voPaths[asCustomAction]
            vsPath ?= ':' + inflect.singularize inflect.underscore (@[ipsResource] ? @[ipsName]).replace(/[/]/g, '_').replace /[_]$/g, ''
            if asCustomAction is 'all'
              for own asAction, asMethod of voMethods
                do (asAction, asMethod)=>
                  @defineMethod @[iplRoutes], asMethod, vsPath,
                    action: asAction
                    resource: @[ipsResource] ? @[ipsName]
                    tags: @[iplTags] ? []
                    template: @[ipsTemplates] + '/' + asAction
            else
              @defineMethod @[iplRoutes], voMethods[asCustomAction], vsPath,
                action: asCustomAction
                resource: @[ipsResource] ? @[ipsName]
                tags: @[iplTags] ? []
                template: @[ipsTemplates] + '/' + asAction
        else
          for own asAction, asMethod of voMethods
            do (asAction, asMethod)=>
              vsPath = voPaths[asAction]
              vsPath ?= ':' + inflect.singularize inflect.underscore (@[ipsResource] ? @[ipsName]).replace(/[/]/g, '_').replace /[_]$/g, ''
              @defineMethod @[iplRoutes], asMethod, vsPath,
                action: asAction
                resource: @[ipsResource] ? @[ipsName]
                tags: @[iplTags] ? []
                template: @[ipsTemplates] + '/' + asAction


  Router.initialize()
