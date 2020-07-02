# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

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
      replica.multitonKey = @[Symbol.for '~multitonKey']
      unless moduleName is @ApplicationModule.name
        throw new Error "Job was defined with moduleName = `#{moduleName}`, but its Module = `#{@ApplicationModule.name}`"
        yield return
      switch replica.type
        when 'class'
          replicated = yield Class.restoreObject @ApplicationModule, replica
          if (config = replicated.classMethods[methodName]).async is ASYNC
            yield replicated[config.pointer]? args...
          else
            replicated[config.pointer]? args...
        when 'instance'
          vcInstanceClass = (@ApplicationModule.NS ? @ApplicationModule::)[replica.class]
          replicated = yield vcInstanceClass.restoreObject @ApplicationModule, replica
          if (config = vcInstanceClass.instanceMethods[methodName]).async is ASYNC
            yield replicated[config.pointer]? args...
          else
            replicated[config.pointer]? args...
        else
          throw new Error 'Replica type must be `instance` or `class`'
      yield return


    @initialize()
