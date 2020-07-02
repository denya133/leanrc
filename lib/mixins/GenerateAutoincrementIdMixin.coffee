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
    Collection
    QueryableCollectionMixin
    ArangoCollectionMixin
    IterableMixin
    GenerateAutoincrementIdMixin
  } = Module::

  class MainCollection extends Collection
    @inheritProtected()
    @include QueryableCollectionMixin
    @include ArangoCollectionMixin
    @include IterableMixin
    @include GenerateAutoincrementIdMixin
    @module Module


  MainCollection.initialize()
```
###

module.exports = (Module)->
  {
    FuncG
    Collection, Mixin, Query
    RecordInterface
  } = Module::

  Module.defineMixin Mixin 'GenerateAutoincrementIdMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()

      @public @async generateId: FuncG([RecordInterface], Number),
        default: ->
          voQuery = Query.new()
            .forIn '@doc': @collectionFullName()
            .max '@doc.id'
          maxId = yield (yield @query voQuery).first()
          maxId ?= 0
          yield return ++maxId


      @initializeMixin()
