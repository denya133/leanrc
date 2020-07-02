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
    FuncG
    Resource, Query, Mixin
    Utils: { _, joi }
  } = Module::

  Module.defineMixin Mixin 'CountMethodsResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @chains ['count', 'length']
      @beforeHook 'getQuery', only: ['count', 'length']

      @action @async count: FuncG([], Number),
        default: ->
          receivedQuery = _.pick @listQuery, [
            '$filter'
          ]
          unless receivedQuery.$filter
            @context.throw 400, 'ValidationError: `$filter` must be defined'

          do =>
            { error } = joi.validate receivedQuery.$filter, joi.object()
            if error?
              @context.throw 400, 'ValidationError: `$filter` must be an object', error.stack
          voQuery = Query.new()
            .forIn '@doc': @collection.collectionFullName()
            .filter receivedQuery.$filter
            .count '@doc'
          return yield (yield @collection.query voQuery).first()

      @action @async length: FuncG([], Number),
        default: ->
          return yield @collection.length()


      @initializeMixin()
