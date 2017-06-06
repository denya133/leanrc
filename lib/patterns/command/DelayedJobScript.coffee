

# написать пример использования в приложении

module.exports = (Module)->
  {
    ASYNC

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
      unless moduleName is @Module.name
        throw new Error "Job was defined with moduleName = `#{moduleName}`, but its Module = `#{@Module.name}`"
        yield return
      if replica.type is 'class'
        replicated = Class.restoreObject @Module, replica
        if (config = replicated.classMethods[methodName]).async is ASYNC
          yield replicated[config.pointer]? args...
        else
          replicated[config.pointer]? args...
        yield return
      else if replica.type is 'instance'
        replicated = @Module.restoreObject @Module, replica
        if (config = replicated.instanceMethods[methodName]).async is ASYNC
          yield replicated[config.pointer]? args...
        else
          replicated[config.pointer]? args...
        yield return
      else
        throw new Error 'Replica type must be `instance` or `class`'
        yield return


  DelayedJobScript.initialize()
