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

module.exports = (Module)->
  {
    JoiT
    FuncG, MaybeG, UnionG
    TransformInterface
    CoreObject
    Utils: { joi }
  } = Module::

  class BooleanTransform extends CoreObject
    @inheritProtected()
    @implements TransformInterface
    @module Module

    @public @static schema: JoiT,
      get: -> joi.boolean().allow(null).optional()

    @public @static @async normalize: FuncG([MaybeG UnionG Boolean, String, Number], Boolean),
      default: (args...)->
        yield return @normalizeSync args...

    @public @static @async serialize: FuncG([MaybeG UnionG Boolean, String, Number], Boolean),
      default: (args...)->
        yield return @serializeSync args...

    @public @static normalizeSync: FuncG([MaybeG UnionG Boolean, String, Number], Boolean),
      default: (serialized)->
        type = typeof serialized

        if type is "boolean"
          return serialized
        else if type is "string"
          return serialized.match(/^true$|^t$|^1$/i) isnt null
        else if type is "number"
          return serialized is 1
        else
          return no

    @public @static serializeSync: FuncG([MaybeG UnionG Boolean, String, Number], Boolean),
      default: (deserialized)-> Boolean deserialized

    @public @static objectize: FuncG([MaybeG UnionG Boolean, String, Number], Boolean),
      default: (deserialized)-> Boolean deserialized

    @public @static @async restoreObject: Function,
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: Function,
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
