

# написать пример использования в приложении

module.exports = (Module)->
  {ASYNC} = Module::

  class DelayedJobScript extends Module::Script
    @inheritProtected()

    @module Module

    @do (aoData)->
      {
        moduleName
        className
        methodName
        args
      } = aoData
      LocalClass = @Module::[className]
      if LocalClass.classMethods[methodName].async is ASYNC
        yield LocalClass[methodName]? args...
      else
        LocalClass[methodName]? args...
      yield return


  DelayedJobScript.initialize()
