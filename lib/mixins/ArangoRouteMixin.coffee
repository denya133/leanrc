# надо реализовать в отдельном модуле (npm-пакете) так как является платформозависимым
# здесь должна быть реализация интерфейса RouteInterface работающая с Foxx роутером.



class FoxxRouterMixinInterface extends Interface
  @include RouterMixinInterface


class FoxxRouterMixin extends Mixin
  @implements FoxxRouterMixinInterface

  createNativeRoute: (method, path, controller, action)->
    router = FoxxRouter()
    # console.log 'GGGGGGGGGGGGGGGG createFoxxRouter', @moduleName()
    controllerName = inflect.camelize inflect.underscore "#{controller.replace /[/]/g, '_'}Controller"
    Controller = classes[@moduleName()]::[controllerName]

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
                  moduleName
                  controllerName
                  action
                  req
                  res
                }       = params
              ) ->
                # console.log '????????????????/ classes[moduleName]::[controllerName].new', moduleName, controllerName, classes[moduleName], classes[moduleName]::, classes[moduleName]::[controllerName]
                classes[moduleName]::[controllerName].new(req: req, res: res)[action]? []...
            params:
              moduleName: @moduleName()
              controllerName: controllerName
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

    @Module.context.use router
