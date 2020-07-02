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

# миксин подмешивается к классам унаследованным от Module::Collection
# если необходимы методы для работы с collection как с итерируемым объектом

module.exports = (Module)->
  {
    AnyT
    FuncG
    IterableInterface
    Collection
    Mixin
  } = Module::

  Module.defineMixin Mixin 'IterableMixin', (BaseClass = Collection) ->
    class extends BaseClass
      @inheritProtected()
      @implements IterableInterface

      @public @async forEach: FuncG(Function),
        default: (lambda)->
          cursor = yield @takeAll()
          yield cursor.forEach (item)-> yield lambda item
          return

      @public @async filter: FuncG(Function, Array),
        default: (lambda)->
          cursor = yield @takeAll()
          yield cursor.filter (item)-> yield lambda item

      @public @async map: FuncG(Function, Array),
        default: (lambda)->
          cursor = yield @takeAll()
          yield cursor.map (item)-> yield lambda item

      @public @async reduce: FuncG([Function, AnyT], AnyT),
        default: (lambda, initialValue)->
          cursor = yield @takeAll()
          yield cursor.reduce ((prev, item)-> yield lambda prev, item), initialValue


      @initializeMixin()
