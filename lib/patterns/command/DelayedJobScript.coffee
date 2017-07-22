

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
      # if /\|\>/.test replica.multitonKey
      #   [ replica.multitonKey ] = replica.multitonKey.split '|>'
      replica.multitonKey = @[Symbol.for '~multitonKey']
      unless moduleName is @Module.name
        throw new Error "Job was defined with moduleName = `#{moduleName}`, but its Module = `#{@Module.name}`"
        yield return
      switch replica.type
        when 'class'
          replicated = yield Class.restoreObject @Module, replica
          if (config = replicated.classMethods[methodName]).async is ASYNC
            yield replicated[config.pointer]? args...
          else
            replicated[config.pointer]? args...
        when 'instance'
          vcInstanceClass = @Module::[replica.class]
          replicated = yield vcInstanceClass.restoreObject @Module, replica
          if (config = vcInstanceClass.instanceMethods[methodName]).async is ASYNC
            yield replicated[config.pointer]? args...
          else
            replicated[config.pointer]? args...
        else
          throw new Error 'Replica type must be `instance` or `class`'
      yield return


  DelayedJobScript.initialize()
