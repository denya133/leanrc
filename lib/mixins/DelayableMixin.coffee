# миксин может подмешиваеться к любым классам унаследованным от Module::CoreObject
# в классе появляется статический атрибут `delay` после обращения к которому через '.' можно вызвать один из статических методов класса так, чтобы он отработал асинхронно в фоновом режиме (условно говоря в отдельном внешнем процессе).
# для этого используется функционал Resque и DelayedQueue
# апи технологии сделано по аналогии с https://github.com/collectiveidea/delayed_job


module.exports = (Module)->
  {
    Utils: {co}
  } = Module::

  Module.defineMixin Module::CoreObject, (BaseClass) ->
    class DelayableMixin extends BaseClass
      @inheritProtected()
      @implements Module::DelayableMixinInterface

      cpmDelayJob = @private @static @async delayJob: Function,
        default: (facade, data, options = {})->
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
      @public @static delay: Function,
        default: (facade, opts = null)->
          obj = {}
          for own methodName of @classMethods
            if methodName isnt 'delay'
              do (methodName)=>
                obj[methodName] = co.wrap (args...)=>
                  data =
                    moduleName: @moduleName()
                    replica: yield @constructor.replicateObject @
                    methodName: methodName
                    args: args
                  return yield @[cpmDelayJob] facade, data, opts
          obj

      @public delay: Function,
        default: (facade, opts = null)->
          obj = {}
          for own methodName of @constructor.instanceMethods
            if methodName isnt 'delay'
              do (methodName)=>
                obj[methodName] = co.wrap (args...)=>
                  data =
                    moduleName: @moduleName()
                    replica: yield @constructor.replicateObject @
                    methodName: methodName
                    args: args
                  return yield @constructor[cpmDelayJob] facade, data, opts
          obj


    DelayableMixin.initializeMixin()
