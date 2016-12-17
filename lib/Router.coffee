_             = require 'lodash'
inflect       = require('i')()
FoxxRouter    = require '@arangodb/foxx/router'
{db}          = require '@arangodb'
queues        = require '@arangodb/foxx/queues'
CoreObject    = require './CoreObject'

status        = require 'statuses'
{ errors }    = require '@arangodb'


ARANGO_NOT_FOUND  = errors.ERROR_ARANGO_DOCUMENT_NOT_FOUND.code
ARANGO_DUPLICATE  = errors.ERROR_ARANGO_UNIQUE_CONSTRAINT_VIOLATED.code
ARANGO_CONFLICT   = errors.ERROR_ARANGO_CONFLICT.code
HTTP_NOT_FOUND    = status 'not found'
HTTP_CONFLICT     = status 'conflict'
UNAUTHORIZED      = status 'unauthorized'

###
 надо смотреть примеры реального кода в файле `src/router.coffee` и документацию в
 http://rusrails.ru/rails-routing
 http://guides.rubyonrails.org/routing.html
 ... - можно и многие другие по Rails т.к. многие методы модели работают идентичным способом.

 От работы в рельсах отличается следующим:
  - символ `:on` по техническим причинам заменен на `at:`
  - скопы через @scope дефайнить нельзя, но для этого можно дефайнить неймспейсы с параметрами @namespace 'admin', prefix: '', module: '', ()->
  - концерны через @concern дефайнить нельзя, а следоватльено имена концерном в ресурсах так же нельзя указывать - реализовать этот сахар по техническим причинам не получилось.
  - при объявлении атомарного роута в опциях нельзя указывать ключи `redirect:`, `defaults:`, `as:`, `constraints:`
  - на данный момент не реализовано тело функции @root - т.к. не было необходимости - для апи-сервера это не актуальный роут.
###

###
  Пример роутера

  ```
    Router    = require './lib/router'

    module.context.use require './lib/sessions'

    class ApplicationRouter extends Router
      @map ()->
        # @root ''
        @post '/auth/signin', to: 'auth#signin'
        @post '/auth/signout', to: 'auth#signout'
        @get '/auth/whoami', to: 'auth#whoami'

        @resource 'users', except: 'delete', ()->
          @collection ()->
            @post 'verify'
            @post 'reset-password'
            @post 'update-password'
          @member ()->
            @get 'today_adz_watches'
            @get 'provisions_per_level'
            @post 'switch_membership'
            @resource 'descendants', only: 'list', controller: 'users', ()->
              @get 'count', at: 'collection'

        @resource 'user_earnings', only: 'list'
        @resource 'referrals', except: 'delete', ()->
          @post 'confirm', at: 'collection'
          @member ()->
            @get 'sendInvite'
            @resource 'descendants', only: 'list', controller: 'referrals', ()->
              @get 'count', at: 'collection'
        @resource 'recipes'
        @resource 'adzs', ()->
          @member ()->
            @get 'rating'
            @get 'watches'
        @resource 'uploads'
        @resource 'promotions', ()->
          @get 'create_offer', at: 'member'
        @resource 'order_items', only: ['list', 'detail', 'create']
          @get 'unused', at: 'collection'

        @namespace 'admin', ()->
          @resource 'tomatos', except: ['delete']

        @namespace 'test', module: '', ()->
          @resource 'tomatos', except: ['delete']

        @namespace 'super', module: '', prefix: '', ()->
          @resource 'tomatos', except: ['delete']

        @namespace 'cucumber', prefix: '', ()->
          @resource 'tomatos', except: ['delete']

        @namespace 'cucumber', prefix: 'onion', ()->
          @resource 'tomatos', except: ['delete']

        @namespace 'carrot', prefix: 'onion', ()->
          @resource 'tomatos', except: ['delete']


    module.exports = ApplicationRouter

  ```
###

class Router extends CoreObject
  @_path: '/'
  @_name: ''
  @_module: null
  @_only: null
  @_via: null
  @_except: null
  @_at: null
  @_controller: null

  @map: (lambda = ()->)->
    lambda.apply @, []

  @root: ({to, at, controller, action})->

  @createFoxxRouter: (method, path, controller, action)->
    router = FoxxRouter()
    # console.log 'GGGGGGGGGGGGGGGG classes', Object.keys classes
    controllerName = inflect.camelize inflect.underscore "#{controller.replace /[/]/g, '_'}Controller"
    Controller = classes[controllerName]
    # console.log '$$$$$$$$$$$$$$$$$ inflect.camelize inflect.underscore "#{controller}_controller"', inflect.camelize inflect.underscore "#{controller.replace /[/]/g, '_'}Controller"
    unless Controller?
      throw new Error "controller `#{controller}` is not exist"
    endpoint = router[method]? [path, (req, res)=>
      try
        if method is 'get'
          data = Controller.new(req: req, res: res)[action]? []...
        else
          # t1 = Date.now()
          {read, write} = Controller.getLocksFor "#{Controller.name}::#{action}"
          # console.log '$$$$$$$$$$$$$$$$$LLLLLLLLLLLlllllllllllllllllll read, write', (Date.now() - t1), read, write
          data = db._executeTransaction
            collections:
              read: read
              write: write
              allowImplicit: no
            action: (params)->
              do (
                {
                  controller
                  action
                  req
                  res
                }       = params
                Controller = require "../controllers/#{controller.replace /[/]$/g, ''}"
              ) ->
                Controller.new(req: req, res: res)[action]? []...
            params:
              controller: controller
              action: action
              req: req
              res: res

        queues._updateQueueDelay()
      catch e
        console.log '???????????????????!!', JSON.stringify e
        if e.isArangoError and e.errorNum is ARANGO_NOT_FOUND
          res.throw HTTP_NOT_FOUND, e.message
          return
        if e.isArangoError and e.errorNum is ARANGO_CONFLICT
          res.throw HTTP_CONFLICT, e.message
          return
        else if e.statusCode?
          console.error e.message, e.stack
          res.throw e.statusCode, e.message
        else
          console.error 'kkkkkkkk', e.message, e.stack
          res.throw 500, e.message, e.stack
          return
      # console.log '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ data', data.constructor
      if data?.constructor?.name isnt 'SyntheticResponse'
        res.send data
    , action]...
    # console.log '$$$$$$$$$$$$$ !!!! endpoint', endpoint, method, path, controller, action
    Controller["_swaggerDefFor_#{action}"]? [endpoint]...

    module.context.use router

  @defineMethod: (container, method, path, {to, at, controller, action}={})->
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
        "#{@_path}:key/#{path}"
      when 'collection'
        "#{@_path}#{path}"
      else
        "#{@_path}#{path}"

    container.push
      method: method
      path: path
      controller: controller
      action: action
    @createFoxxRouter method, path, controller, action
    return

  @get: (path, opts)->
    @_routes ?= []
    @defineMethod @_routes, 'get', path, opts

  @post: (path, opts)->
    @_routes ?= []
    @defineMethod @_routes, 'post', path, opts

  @put: (path, opts)->
    @_routes ?= []
    @defineMethod @_routes, 'put', path, opts

  @patch: (path, opts)->
    @_routes ?= []
    @defineMethod @_routes, 'patch', path, opts

  @delete: (path, opts)->
    @_routes ?= []
    @defineMethod @_routes, 'delete', path, opts

  @resource: (name, opts = null, lambda = null)->
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
        "#{@_path}:key/#{_path}"
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
      @_path: full_path
      @_name: "#{parent_name}#{_name}"
      @_module: _module
      @_only: only
      @_via: via
      @_except: except
      @_controller: controller
      @map lambda

  @namespace: (name, opts = null, lambda = null)->
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
        @_path: "#{parent_path}#{_path}"
        @_name: "#{parent_name}#{_name}"
        @_except: 'all'
        @_at: at
        @map lambda

  @member: (lambda)->
    @namespace null, module: '', prefix: '', at: 'member', lambda

  @collection: (lambda = ()->)->
    @namespace null, module: '', prefix: '', at: 'collection', lambda

  constructor: ()->
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
      detail: ':key'
      create: ''
      patch: ':key'
      update: ':key'
      delete: ':key'

    @_routes = @_routes.concat @constructor._routes if @constructor._routes?

    if name? and name isnt ''
      if only?
        only.forEach (action)=>
          @constructor.defineMethod @_routes, methods[action], paths[action], action: action, controller: controller ? name
      else if except?
        for own action, method of methods
          do (action, method)=>
            if not except.includes('all') and not except.includes action
              @constructor.defineMethod @_routes, method, paths[action], action: action, controller: controller ? name
      else if via?
        via.forEach (action)=>
          if action is 'all'
            for own action, method of methods
              do (action, method)=>
                @constructor.defineMethod @_routes, method, paths[action], action: action, controller: controller ? name
          else
            @constructor.defineMethod @_routes, methods[action], paths[action], action: action, controller: controller ? name
      else
        for own action, method of methods
          do (action, method)=>
            @constructor.defineMethod @_routes, method, paths[action], action: action, controller: controller ? name

    @constructor._resources?.forEach (ResourceRouter)=>
      resourceRouter = new ResourceRouter()
      @_routes = @_routes.concat resourceRouter._routes if resourceRouter._routes?

    return

module.exports = Router.initialize()
