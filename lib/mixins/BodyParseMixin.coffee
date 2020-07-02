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

###
for example

```coffee
module.exports = (Module)->
  {
    Resource
    BodyParseMixin
  } = Module::

  class CucumbersResource extends Resource
    @inheritProtected()
    @include BodyParseMixin
    @module Module

    @initialHook 'parseBody', only: ['create', 'update']

    @public entityName: String,
      default: 'cucumber'


  CucumbersResource.initialize()
```
###

module.exports = (Module)->
  {
    Resource, Mixin
    Utils: { isArangoDB }
  } = Module::

  Module.defineMixin Mixin 'BodyParseMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @public @async parseBody: Function,
        default: (args...)->
          if isArangoDB()
            @context.request.body = @context.req.body
          else
            parse = require 'co-body'
            @context.request.body = yield parse @context.req
          yield return args


      @initializeMixin()
