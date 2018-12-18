

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


module.exports = (Module)->
  {
    AnyT, PointerT
    FuncG, MaybeG, InterfaceG, EnumG, ListG, UnionG, SubsetG, SampleG
    RouterInterface
    ConfigurableMixin
    Class
    Utils: { _, inflect }
  } = Module::

  class Router extends Module::Proxy
    @inheritProtected()
    @implements RouterInterface
    @include ConfigurableMixin
    @module Module

    ipsPath       = PointerT @protected path: MaybeG(String),
      default: '/'
    ipsName       = PointerT @protected name: MaybeG(String),
      default: ''
    ipsModule     = PointerT @protected module: MaybeG String
    iplOnly       = PointerT @protected only: MaybeG UnionG String, ListG String
    iplVia        = PointerT @protected via: MaybeG UnionG String, ListG String
    iplExcept     = PointerT @protected except: MaybeG UnionG String, ListG String
    ipoAbove      = PointerT @protected above: MaybeG Object
    ipsAt         = PointerT @protected at: MaybeG EnumG 'collection', 'member'
    ipsResource   = PointerT @protected resource: MaybeG String
    ipsTag        = PointerT @protected tag: MaybeG String
    ipsTemplates  = PointerT @protected templates: MaybeG String
    ipsParam      = PointerT @protected param: MaybeG String

    iplRouters    = PointerT @protected routers: MaybeG ListG SubsetG Router
    iplPathes     = PointerT @protected pathes: MaybeG ListG InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: MaybeG String
      entityName: String
      recordName: MaybeG String
    }
    iplResources  = PointerT @protected resources: MaybeG ListG SampleG Router
    iplRoutes     = PointerT @protected routes: MaybeG ListG InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: MaybeG String
      entityName: String
      recordName: MaybeG String
    }

    @public path: MaybeG(String),
      get: -> @[ipsPath]

    @public name: MaybeG(String),
      get: -> @[ipsResource] ? @[ipsName]

    @public above: MaybeG(Object),
      get: -> @[ipoAbove]

    @public tag: MaybeG(String),
      get: -> @[ipsTag]

    @public templates: MaybeG(String),
      get: -> @[ipsTemplates]

    @public param: MaybeG(String),
      get: -> @[ipsParam]

    @public defaultEntityName: FuncG([], String),
      default: ->
        [..., vsEntityName] = @[ipsName]
          .replace /\/$/, ''
          .split '/'
        inflect.singularize vsEntityName

    @public @static map: FuncG([MaybeG Function]),
      default: (lambda)->
        lambda ?= ->
        @public map: Function,
          default: lambda
        return

    @public map: Function,
      default: -> return

    @public root: FuncG([InterfaceG {
      to: MaybeG String
      at: MaybeG EnumG 'collection', 'member'
      resource: MaybeG String
      action: MaybeG String
    }]),
      default: ({to, at, resource, action})->
        return

    @public defineMethod: FuncG([
      MaybeG ListG InterfaceG {
        method: String
        path: String
        resource: String
        action: String
        tag: String
        template: String
        keyName: MaybeG String
        entityName: String
        recordName: MaybeG String
      }
      String
      String
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]),
      default: (container, method, path, {to, at, resource, action, tag:asTag, template, keyName, entityName, recordName}={})->
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
        keyName ?= @[ipsParam]?.replace /^\:/, ''
        entityName ?= @defaultEntityName()
        unless _.isString(recordName) or _.isNull(recordName)
          recordName = @defaultEntityName()

        vsParentTag = if @[ipsTag]? and @[ipsTag] isnt ''
          @[ipsTag]
        else
          ''
        vsTag = if asTag? and asTag isnt ''
          "/#{asTag}"
        else
          ''
        tag = "#{vsParentTag}#{vsTag}"

        path = switch at ? @[ipsAt]
          when 'member'
            "#{@[ipsPath]}:#{inflect.singularize inflect.underscore resource.replace(/[/]/g, '_').replace /[_]$/g, ''}/#{path}"
          when 'collection'
            "#{@[ipsPath]}#{path}"
          else
            "#{@[ipsPath]}#{path}"
        template ?= resource + action
        container.push {method, path, resource, action, tag, template, keyName, entityName, recordName}
        return

    @public get: FuncG([
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]),
      default: (asPath, aoOpts)->
        # @[iplPathes] ?= []
        @defineMethod @[iplPathes], 'get', asPath, aoOpts
        return

    @public post: FuncG([
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]),
      default: (asPath, aoOpts)->
        # @[iplPathes] ?= []
        @defineMethod @[iplPathes], 'post', asPath, aoOpts
        return

    @public put: FuncG([
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]),
      default: (asPath, aoOpts)->
        # @[iplPathes] ?= []
        @defineMethod @[iplPathes], 'put', asPath, aoOpts
        return

    @public delete: FuncG([
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]),
      default: (asPath, aoOpts)->
        # @[iplPathes] ?= []
        @defineMethod @[iplPathes], 'delete', asPath, aoOpts
        return

    @public head: FuncG([
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]),
      default: (asPath, aoOpts)->
        # @[iplPathes] ?= []
        @defineMethod @[iplPathes], 'head', asPath, aoOpts
        return

    @public options: FuncG([
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]),
      default: (asPath, aoOpts)->
        # @[iplPathes] ?= []
        @defineMethod @[iplPathes], 'options', asPath, aoOpts
        return

    @public patch: FuncG([
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]),
      default: (asPath, aoOpts)->
        # @[iplPathes] ?= []
        @defineMethod @[iplPathes], 'patch', asPath, aoOpts
        return

    @public resource: FuncG([
      String
      MaybeG UnionG(InterfaceG({
        path: MaybeG String
        module: MaybeG String
        only: MaybeG UnionG String, ListG String
        via: MaybeG UnionG String, ListG String
        except: MaybeG UnionG String, ListG String
        tag: MaybeG String
        templates: MaybeG String
        param: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        above: MaybeG Object
      }), Function)
      MaybeG Function
    ]),
      default: (asName, aoOpts = null, lambda = null)->
        vcModule = @Module
        if _.isFunction aoOpts
          lambda = aoOpts
          aoOpts = {}
        aoOpts = {} unless aoOpts?
        {
          path, module:vsModule
          only, via, except
          tag:asTag, templates:alTemplates, param:asParam
          at, resource:asResource, above
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
        vsParentTag = if @[ipsTag]? and @[ipsTag] isnt ''
          @[ipsTag]
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
        vsTag = if asTag? and asTag isnt ''
          "/#{asTag}"
        else
          ''
        vsParam = if asParam? and asParam isnt ''
          asParam
        else
          ':' + inflect.singularize inflect.underscore (asResource ? "#{vsParentName}#{vsName}").replace(/[/]/g, '_').replace /[_]$/g, ''
        # @[iplRouters] ?= []
        class ResourceRouter extends Router
          @inheritProtected()
          @module vcModule
          @protected path: String,
            default: vsFullPath
          @protected name: String,
            default: "#{vsParentName}#{vsName}"
          @protected module: String,
            default: vsModule
          @protected only: MaybeG(UnionG String, ListG String),
            default: only
          @protected via: MaybeG(UnionG String, ListG String),
            default: via
          @protected except: MaybeG(UnionG String, ListG String),
            default: except
          @protected above: MaybeG(Object),
            default: above
          @protected tag: String,
            default: "#{vsParentTag}#{vsTag}"
          @protected templates: String,
            default: "#{vsParentTemplates}#{vsTemplates}".replace /[\/][\/]/g, '/'
          @protected param: String,
            default: vsParam
          @protected resource: MaybeG(String),
            default: asResource
          @map lambda
        ResourceRouter.constructor = Class
        @[iplRouters].push ResourceRouter
        return

    @public namespace: FuncG([
      MaybeG String
      UnionG(InterfaceG({
        module: MaybeG String
        prefix: MaybeG String
        tag: MaybeG String
        templates: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        above: MaybeG Object
      }), Function)
      MaybeG Function
    ]),
      default: (asName, aoOpts = null, lambda = null)->
        vcModule = @Module
        if aoOpts?.constructor is Function
          lambda = aoOpts
          aoOpts = {}
        aoOpts = {} unless aoOpts?
        {
          module:vsModule, prefix
          tag:asTag, templates:alTemplates
          at, above
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
        vsParentTag = if @[ipsTag]? and @[ipsTag] isnt ''
          @[ipsTag]
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
        vsTag = if asTag? and asTag isnt ''
          "/#{asTag}"
        else
          ''
        # @[iplRouters] ?= []
        class NamespaceRouter extends Router
          @inheritProtected()
          @module vcModule
          @protected path: String,
            default: "#{vsParentPath}#{vsPath}"
          @protected name: String,
            default: "#{vsParentName}#{vsName}"
          @protected except: MaybeG(UnionG String, ListG String),
            default: ['all']
          @protected tag: String,
            default: "#{vsParentTag}#{vsTag}"
          @protected templates: String,
            default: "#{vsParentTemplates}#{vsTemplates}".replace /[\/][\/]/g, '/'
          @protected at: MaybeG(EnumG 'collection', 'member'),
            default: at
          @protected above: MaybeG(Object),
            default: above
          @map lambda
        NamespaceRouter.constructor = Class
        @[iplRouters].push NamespaceRouter
        return

    @public member: FuncG(Function),
      default: (lambda)->
        @namespace null, module: '', prefix: '', templates: '', at: 'member', lambda
        return

    @public collection: FuncG(Function),
      default: (lambda)->
        @namespace null, module: '', prefix: '', templates: '', at: 'collection', lambda
        return

    @public resources: ListG(SampleG Router),
      get: -> return @[iplResources]

    @public routes: ListG(InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: MaybeG String
      entityName: String
      recordName: MaybeG String
    }),
      get: ->
        if @[iplRoutes]? and @[iplRoutes].length > 0
          return @[iplRoutes]
        else
          vlRoutes = []
          vlRoutes = vlRoutes.concat @[iplPathes] ? []
          vlResources = []
          @[iplRouters]?.forEach (ResourceRouter)=>
            resourceRouter = ResourceRouter.new()
            vlResources.push resourceRouter
            vlRoutes = vlRoutes.concat resourceRouter.routes ? []
            vlResources = vlResources.concat resourceRouter.resources ? []
          @[iplRoutes] = vlRoutes
          @[iplResources] = vlResources
        return @[iplRoutes]

    constructor: (args...)->
      super args...
      @init args...
      @map()

      if _.isString @[iplOnly]
        @[iplOnly] = [@[iplOnly]]
      if _.isString @[iplVia]
        @[iplVia] = [@[iplVia]]
      if _.isString @[iplExcept]
        @[iplExcept] = [@[iplExcept]]

      voMethods =
        list: 'get'
        detail: 'get'
        create: 'post'
        update: 'put'
        delete: 'delete'

      voPaths =
        list: ''
        detail: null
        create: ''
        update: null
        delete: null

      # @[iplPathes] ?= []

      if @[ipsName]? and @[ipsName] isnt ''
        vsKeyName = @[ipsParam]?.replace /^\:/, ''
        vsEntityName = @[ipoAbove]?.entityName
        vsEntityName ?= @defaultEntityName()
        vsRecordName = @[ipoAbove]?.recordName
        if _.isNil(vsRecordName) and not _.isNull vsRecordName
          vsRecordName = @defaultEntityName()
        if @[iplOnly]?
          @[iplOnly].forEach (asAction)=>
            vsPath = voPaths[asAction]
            vsPath ?= @[ipsParam]
            @defineMethod @[iplPathes], voMethods[asAction], vsPath,
              action: asAction
              resource: @[ipsResource] ? @[ipsName]
              template: @[ipsTemplates] + '/' + asAction
              keyName: vsKeyName
              entityName: vsEntityName
              recordName: vsRecordName
        else if @[iplExcept]?
          for own asAction, asMethod of voMethods
            do (asAction, asMethod)=>
              if not @[iplExcept].includes('all') and not @[iplExcept].includes asAction
                vsPath = voPaths[asAction]
                vsPath ?= @[ipsParam]
                @defineMethod @[iplPathes], asMethod, vsPath,
                  action: asAction
                  resource: @[ipsResource] ? @[ipsName]
                  template: @[ipsTemplates] + '/' + asAction
                  keyName: vsKeyName
                  entityName: vsEntityName
                  recordName: vsRecordName
        else if @[iplVia]?
          @[iplVia].forEach (asCustomAction)=>
            vsPath = voPaths[asCustomAction]
            vsPath ?= @[ipsParam]
            if asCustomAction is 'all'
              for own asAction, asMethod of voMethods
                do (asAction, asMethod)=>
                  @defineMethod @[iplPathes], asMethod, vsPath,
                    action: asAction
                    resource: @[ipsResource] ? @[ipsName]
                    template: @[ipsTemplates] + '/' + asAction
                    keyName: vsKeyName
                    entityName: vsEntityName
                    recordName: vsRecordName
            else
              @defineMethod @[iplPathes], voMethods[asCustomAction], vsPath,
                action: asCustomAction
                resource: @[ipsResource] ? @[ipsName]
                template: @[ipsTemplates] + '/' + asAction
                keyName: vsKeyName
                entityName: vsEntityName
                recordName: vsRecordName
        else
          for own asAction, asMethod of voMethods
            do (asAction, asMethod)=>
              vsPath = voPaths[asAction]
              vsPath ?= @[ipsParam]
              @defineMethod @[iplPathes], asMethod, vsPath,
                action: asAction
                resource: @[ipsResource] ? @[ipsName]
                template: @[ipsTemplates] + '/' + asAction
                keyName: vsKeyName
                entityName: vsEntityName
                recordName: vsRecordName
      return

    @public init: FuncG([MaybeG(String), MaybeG AnyT]),
      default: (args...)->
        @super args...
        @[iplRouters] = []
        @[iplPathes] = []
        return


    @initialize()
