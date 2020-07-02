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
    Resource, Mixin
    Utils: { _, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'

  Module.defineMixin Mixin 'PersoningResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @public namespace: String,
        default: 'personing'

      @public currentSpaceId: String,
        get: -> @session.userSpaceId

      @beforeHook 'limitByUserSpace', only: ['list']
      @beforeHook 'setSpaces',      only: ['create']
      @beforeHook 'setOwnerId',     only: ['create']
      @beforeHook 'protectSpaces',  only: ['update']
      @beforeHook 'protectOwnerId', only: ['update']

      @public @async limitByUserSpace: Function,
        default: (args...)->
          @listQuery ?= {}
          if @listQuery.$filter?
            @listQuery.$filter = $and: [
              @listQuery.$filter
            ,
              '@doc.spaces': $all: [@currentSpaceId]
            ]
          else
            @listQuery.$filter = '@doc.spaces': $all: [@currentSpaceId]
          yield return args

      @public @async checkExistence: Function,
        default: (args...)->
          unless @recordId?
            @context.throw HTTP_NOT_FOUND
          unless (yield @collection.exists
            '@doc.id': $eq: @recordId
            '@doc.spaces': $all: [@currentSpaceId]
          )
            @context.throw HTTP_NOT_FOUND
          yield return args

      @public @async setSpaces: Function,
        default: (args...)->
          @recordBody.spaces ?= []
          unless _.includes @recordBody.spaces, '_internal'
            @recordBody.spaces.push '_internal'
          unless _.includes @recordBody.spaces, @currentSpaceId
            @recordBody.spaces.push @currentSpaceId
          yield return args

      @public @async protectSpaces: Function,
        default: (args...)->
          @recordBody = _.omit @recordBody, ['spaces']
          yield return args


      @initializeMixin()
