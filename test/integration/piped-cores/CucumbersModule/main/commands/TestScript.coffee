

# написать пример использования в приложении

module.exports = (Module)->
  class TestScript extends Module::Script
    @inheritProtected()
    @module Module

    @do (aoData)->
      yield return


  TestScript.initialize()
