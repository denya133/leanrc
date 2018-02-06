

# написать пример использования в приложении

module.exports = (Module)->
  {
    ASYNC
    APPLICATION_MEDIATOR

    Script
    Class
  } = Module::

  class DelayedJobScript extends Script
    @inheritProtected()
    @module Module

    @do (aoData)->
      {
        moduleName
        replica
        methodName
        args
      } = aoData
      replica.multitonKey = @[Symbol.for '~multitonKey']
      app = @facade.retrieveMediator APPLICATION_MEDIATOR
        .getViewComponent()
      unless moduleName is app.Module.name
        throw new Error "Job was defined with moduleName = `#{moduleName}`, but its Module = `#{app.Module.name}`"
        yield return
      switch replica.type
        when 'class'
          replicated = yield Class.restoreObject app.Module, replica
          if (config = replicated.classMethods[methodName]).async is ASYNC
            yield replicated[config.pointer]? args...
          else
            replicated[config.pointer]? args...
        when 'instance'
          vcInstanceClass = app.Module::[replica.class]
          replicated = yield vcInstanceClass.restoreObject app.Module, replica
          if (config = vcInstanceClass.instanceMethods[methodName]).async is ASYNC
            yield replicated[config.pointer]? args...
          else
            replicated[config.pointer]? args...
        else
          throw new Error 'Replica type must be `instance` or `class`'
      yield return


  DelayedJobScript.initialize()
