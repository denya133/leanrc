# здесь нужно определить интерфейс класса Router
# ApplicationRouter будет наследоваться от Command класса, и в него будет подмешиваться миксин RouterMixin
# на основе декларативно объявленной карты роутов, он будет оркестрировать медиаторы, которые будут отвечать за принятие сигналов от Express или Foxx


module.exports = (Module)->
  {ANY, NILL} = Module::

  Module.defineInterface (BaseClass) ->
    class RouterInterface extends BaseClass
      @inheritProtected()

      @public @static @virtual map: Function,
        args: [[Function, NILL]]
        return: NILL

      @public @virtual map: Function,
        args: [[Function, NILL]]
        return: ANY

      @public @virtual root: Function,
        args: [Object] # {to, at, controller, action}
        return: NILL

      @public @virtual defineMethod: Function,
        args: [String, String, String, Object] # container, method, path, {to, at, controller, action}
        return: NILL

      @public @virtual get: Function,
        args: [String, Object] # path, opts
        return: NILL

      @public @virtual post: Function,
        args: [String, Object] # path, opts
        return: NILL

      @public @virtual put: Function,
        args: [String, Object] # path, opts
        return: NILL

      @public @virtual patch: Function,
        args: [String, Object] # path, opts
        return: NILL

      @public @virtual delete: Function,
        args: [String, Object] # path, opts
        return: NILL

      @public @virtual resource: Function,
        args: [String, Object, Function] # name, opts, lambda
        return: ANY

      @public @virtual namespace: Function,
        args: [String, Object, Function] # name, opts, lambda
        return: ANY

      @public @virtual member: Function,
        args: [Function] # lambda
        return: ANY

      @public @virtual collection: Function,
        args: [[Function, NILL]] # lambda
        return: ANY

      @public @virtual routes: Array


    RouterInterface.initializeInterface()
