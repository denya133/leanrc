# здесь нужно определить интерфейс класса Router
# ApplicationRouter будет наследоваться от Command класса, и в него будет подмешиваться миксин RouterMixin
# на основе декларативно объявленной карты роутов, он будет оркестрировать медиаторы, которые будут отвечать за принятие сигналов от Express или Foxx

RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::RouterInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @static @virtual map: Function,
      args: [[Function, RC::Constants.NILL]]
      return: RC::Constants.NILL

    @public @virtual map: Function,
      args: [[Function, RC::Constants.NILL]]
      return: RC::Constants.ANY

    @public @virtual root: Function,
      args: [Object] # {to, at, controller, action}
      return: RC::Constants.NILL

    @public @virtual defineMethod: Function,
      args: [String, String, String, Object] # container, method, path, {to, at, controller, action}
      return: RC::Constants.NILL

    @public @virtual get: Function,
      args: [String, Object] # path, opts
      return: RC::Constants.NILL

    @public @virtual post: Function,
      args: [String, Object] # path, opts
      return: RC::Constants.NILL

    @public @virtual put: Function,
      args: [String, Object] # path, opts
      return: RC::Constants.NILL

    @public @virtual patch: Function,
      args: [String, Object] # path, opts
      return: RC::Constants.NILL

    @public @virtual delete: Function,
      args: [String, Object] # path, opts
      return: RC::Constants.NILL

    @public @virtual resource: Function,
      args: [String, Object, Function] # name, opts, lambda
      return: RC::Constants.ANY

    @public @virtual namespace: Function,
      args: [String, Object, Function] # name, opts, lambda
      return: RC::Constants.ANY

    @public @virtual member: Function,
      args: [Function] # lambda
      return: RC::Constants.ANY

    @public @virtual collection: Function,
      args: [[Function, RC::Constants.NILL]] # lambda
      return: RC::Constants.ANY

    @public @virtual routes: Array


  return LeanRC::RouterInterface.initialize()
