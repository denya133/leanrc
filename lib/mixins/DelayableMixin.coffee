# миксин может подмешиваеться к любым классам унаследованным от Module::CoreObject
# в классе появляется статический атрибут `delay` после обращения к которому через '.' можно вызвать один из статических методов класса так, чтобы он отработал асинхронно в фоновом режиме (условно говоря в отдельном внешнем процессе).
# для этого используется функционал Resque и Queue
# апи технологии сделано по аналогии с https://github.com/collectiveidea/delayed_job


module.exports = (Module)->
  {
    PointerT
    FuncG, StructG, MaybeG, InterfaceG
    DelayableInterface
    FacadeInterface
    CoreObject
    Mixin
    Utils: { _, co }
  } = Module::

  Module.defineMixin Mixin 'DelayableMixin', (BaseClass = CoreObject) ->
    class extends BaseClass
      @inheritProtected()
      @implements DelayableInterface

      cpmDelayJob = PointerT @private @static @async delayJob: FuncG([
        FacadeInterface
        StructG {
          moduleName: String
          replica: Object
          methodName: String
          args: Array
          opts: InterfaceG queue: MaybeG(String), delayUntil: MaybeG Number
        }
        InterfaceG queue: MaybeG(String), delayUntil: MaybeG Number
      ]),
        default: (facade, data, options)->
          resque = facade.retrieveProxy Module::RESQUE
          queue = yield resque.get options.queue ? Module::DELAYED_JOBS_QUEUE
          yield queue.delay Module::DELAYED_JOBS_SCRIPT, data, options.delayUntil
          yield return

      ###
      ```coffee
        #...
        yield CucumbersProxy.delay(@facade).calculateAvgPrice 'cucu123'
        #...
      ```
      or
      ```coffee
        #...
        yield TomatoRecord.delay(@facade,
          queue: 'FilesJobs'
          delayUntil: Date.now() + 60000
        ).imageProcessing '480x900'
        #...
      ```
      ###

      # !!! Специально сделано так что ставить на отложенную обработку можно только статические методы, чтобы не решать проблемы с сериализацией инстансов, для последующей фоновой обработки.
      # т.к. статические методы объявлены на классах, а следовательно нет проблемы в том, чтобы найти в неймспейсе нужный класс и вызвать его статический метод.
      @public @static delay: FuncG([
        FacadeInterface
        MaybeG InterfaceG queue: MaybeG(String), delayUntil: MaybeG Number
      ]),
        default: (facade, opts = {})->
          return new Proxy @, {
            get: (target, name, receiver)->
              if (name is 'delay')
                throw new Error "Method `delay` can not been delayed"
              if (not(name of target) or typeof target[name] isnt "function")
                throw new Error "Method \`#{if _.isSymbol(name) then Symbol.keyFor(name) else name}\` absent in class #{target.name}"
              return co.wrap (args...)->
                data = {
                  moduleName: target.moduleName()
                  replica: yield target.constructor.replicateObject target
                  methodName: name
                  args
                  opts
                }
                return yield target[cpmDelayJob] facade, data, opts
          }
          # obj = {}
          # for own methodName of @classMethods
          #   if methodName isnt 'delay'
          #     self = @
          #     do (methodName) ->
          #       obj[methodName] = co.wrap (args...) ->
          #         data =
          #           moduleName: self.moduleName()
          #           replica: yield self.constructor.replicateObject self
          #           methodName: methodName
          #           args: args
          #           opts: opts
          #         return yield self[cpmDelayJob] facade, data, opts
          # obj

      @public delay: FuncG([
        FacadeInterface
        MaybeG InterfaceG queue: MaybeG(String), delayUntil: MaybeG Number
      ]),
        default: (facade, opts = {})->
          return new Proxy @, {
            get: (target, name, receiver)->
              if (name is 'delay')
                throw new Error "Method `delay` can not been delayed"
              if (not(name of target) or typeof target[name] isnt "function")
                throw new Error "Method \`#{if _.isSymbol(name) then Symbol.keyFor(name) else name}\` absent in class #{target.name}.prototype"
              return co.wrap (args...)->
                data = {
                  moduleName: target.moduleName()
                  replica: yield target.constructor.replicateObject target
                  methodName: name
                  args
                  opts
                }
                return yield target.constructor[cpmDelayJob] facade, data, opts
          }
          # obj = {}
          # for own methodName of @constructor.instanceMethods
          #   if methodName isnt 'delay'
          #     self = @
          #     do (methodName) ->
          #       obj[methodName] = co.wrap (args...) ->
          #         data =
          #           moduleName: self.moduleName()
          #           replica: yield self.constructor.replicateObject self
          #           methodName: methodName
          #           args: args
          #           opts: opts
          #         return yield self.constructor[cpmDelayJob] facade, data, opts
          # obj


      @initializeMixin()
