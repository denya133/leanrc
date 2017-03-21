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
    cpsController = @protected @static controller: String

    @public @static map: Function,
      default: (lambda = ->)->
        lambda.apply @, []

    @public @static root: Function,
      default: ({to, at, controller, action})->
        return

    @public @static defineMethod: Function,
      default: (container, method, path, {to, at, controller, action}={})->
        unless path?
          throw new Error 'path is required'
        path = path.replace /^[/]/, ''
        if to?
          unless /[#]/.test to
            throw new Error '`to` must be in format `<controller>#<action>`'
          [controller, action] = to.split '#'
        if not controller? and (_controller = @_controller) isnt ''
          controller = _controller
        if not controller? and (_name = @_name) isnt ''
          controller = _name
        unless controller?
          throw new Error 'options `to` or `controller` must be defined'
        unless action?
          action = path

        path = switch at ? @_at
          when 'member'
            "#{@_path}:#{inflect.singularize inflect.underscore controller.replace(/[/]/g, '_').replace /[_]$/g, ''}/#{path}"
          when 'collection'
            "#{@_path}#{path}"
          else
            "#{@_path}#{path}"

        container.push
          method: method
          path: path
          controller: controller
          action: action
        # скорее всего здесь надо логику переделать.
        # основная мысль в том, что когда SimpleCommand "Router" запускается (скорее всего будет запускаться из стартапа), она должна обработать карту. которую Роутер должен сохранить у себя-инстанса в определенную переменную-атрибут. Затем либо в конце, либо в процессе обработки карты он должен послать специальный сигнал (нотификацию) в сторону View - чтобы соответсвующий медиатор (который будет связывать ядро с нужным роутером) в ответ на эти сигналы реально задефайнил роуты на платформозависимом роутере (на Express, Koa или ArangoFoxxRouter)
        # теоретичски внутри инстанса роутера нет необходимости сохранять методанные в атрибуте, т.к. объект после отработки будет вычищен сборщиком мусора (т.к. свою работу он сделал, он же наследник от SimpleCommand)
        # теоретически ключ сигнала можно назвать как "defineRoute", медиаторы заинтересованные именно в этом сигнале будут подписаны как раз на этот ключ.
        @createFoxxRouter method, path, controller, action # TODO надо заменить
        return

    @public @static get: Function,
      default: (path, opts)->
        @_routes ?= []
        @defineMethod @_routes, 'get', path, opts
        return

    @public @static post: Function,
      default: (path, opts)->
        @_routes ?= []
        @defineMethod @_routes, 'post', path, opts
        return

    @public @static put: Function,
      default: (path, opts)->
        @_routes ?= []
        @defineMethod @_routes, 'put', path, opts
        return

    @public @static patch: Function,
      default: (path, opts)->
        @_routes ?= []
        @defineMethod @_routes, 'patch', path, opts
        return

    @public @static delete: Function,
      default: (path, opts)->
        @_routes ?= []
        @defineMethod @_routes, 'delete', path, opts
        return

    @public @static resource: Function,
      default: (name, opts = null, lambda = null)->
        vModule = @Module
        if opts?.constructor is Function
          lambda = opts
          opts = {}
        opts = {} unless opts?
        {path, module:_module, only, via, except, at, controller} = opts
        path = path?.replace /^[/]/, ''
        _path = if path? and path isnt ''
          "#{path}/"
        else if path? and path is ''
          ''
        else
          "#{name}/"
        full_path = switch at ? @_at
          when 'member'
            [..., previously, empty] = @_path.split '/'
            "#{@_path}:#{inflect.singularize inflect.underscore previously}/#{_path}"
          when 'collection'
            "#{@_path}#{_path}"
          else
            "#{@_path}#{_path}"
        parent_name = @_name
        _name = if _module? and _module isnt ''
          "#{_module}/"
        else if _module? and _module is ''
          ''
        else
          "#{name}/"
        @_resources ?= []
        @_resources.push class ResourceRouter extends Router
          @Module: vModule
          @_path: full_path
          @_name: "#{parent_name}#{_name}"
          @_module: _module
          @_only: only
          @_via: via
          @_except: except
          @_controller: controller
          @map lambda

    @public @static namespace: Function,
      default: (name, opts = null, lambda = null)->
        vModule = @Module
        if opts?.constructor is Function
          lambda = opts
          opts = {}
        opts = {} unless opts?
        {module:_module, prefix, at} = opts
        parent_path = @_path
        _path = if prefix? and prefix isnt ''
          "#{prefix}/"
        else if prefix? and prefix is ''
          ''
        else
          "#{name}/"
        parent_name = @_name
        _name = if _module? and _module isnt ''
          "#{_module}/"
        else if _module? and _module is ''
          ''
        else
          "#{name}/"
        @_resources ?= []
        if lambda?.constructor is Function
          @_resources.push class NamespaceRouter extends Router
            @Module: vModule
            @_path: "#{parent_path}#{_path}"
            @_name: "#{parent_name}#{_name}"
            @_except: 'all'
            @_at: at
            @map lambda

    @public @static member: Function,
      default: (lambda)->
        @namespace null, module: '', prefix: '', at: 'member', lambda

    @public @static collection: Function,
      default: (lambda = ->)->
        @namespace null, module: '', prefix: '', at: 'collection', lambda

    @public execute: Function,
      default: (aoNotification)->
        # здесь надо написать код, который объявит все роуты на основе карты

    constructor: ->
      super arguments...
      @_routes ?= []
      @_resources ?= []

      {
        _name:name
        _only:only
        _via:via
        _except:except
        _controller:controller
      } = @constructor
      if only?.constructor is String
        only = [only]
      if via?.constructor is String
        via = [via]
      if except?.constructor is String
        except = [except]

      methods =
        list: 'get'
        detail: 'get'
        create: 'post'
        patch: 'patch'
        update: 'put'
        delete: 'delete'

      paths =
        list: ''
        detail: null
        create: ''
        patch: null
        update: null
        delete: null

      @_routes = @_routes.concat @constructor._routes if @constructor._routes?

      if name? and name isnt ''
        if only?
          only.forEach (action)=>
            _path = paths[action]
            _path ?= ':' + inflect.singularize inflect.underscore (controller ? name).replace(/[/]/g, '_').replace /[_]$/g, ''
            @constructor.defineMethod @_routes, methods[action], _path,
              action: action
              controller: controller ? name
        else if except?
          for own action, method of methods
            do (action, method)=>
              if not except.includes('all') and not except.includes action
                _path = paths[action]
                _path ?= ':' + inflect.singularize inflect.underscore (controller ? name).replace(/[/]/g, '_').replace /[_]$/g, ''
                @constructor.defineMethod @_routes, method, _path,
                  action: action
                  controller: controller ? name
        else if via?
          via.forEach (action)=>
            _path = paths[action]
            _path ?= ':' + inflect.singularize inflect.underscore (controller ? name).replace(/[/]/g, '_').replace /[_]$/g, ''
            if action is 'all'
              for own action, method of methods
                do (action, method)=>
                  @constructor.defineMethod @_routes, method, _path,
                    action: action
                    controller: controller ? name
            else
              @constructor.defineMethod @_routes, methods[action], _path,
                action: action
                controller: controller ? name
        else
          for own action, method of methods
            do (action, method)=>
              _path = paths[action]
              _path ?= ':' + inflect.singularize inflect.underscore (controller ? name).replace(/[/]/g, '_').replace /[_]$/g, ''
              @constructor.defineMethod @_routes, method, _path,
                action: action
                controller: controller ? name

      @constructor._resources?.forEach (ResourceRouter)=>
        resourceRouter = new ResourceRouter()
        if resourceRouter._routes?
          @_routes = @_routes.concat resourceRouter._routes

      return


  return LeanRC::Router.initialize()
