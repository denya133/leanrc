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

  Module.defineMixin Mixin 'EditableResourceMixin', (BaseClass = Resource) ->
    class extends BaseClass
      @inheritProtected()

      @beforeHook 'protectEditable',        only: ['create', 'update', 'delete']
      @beforeHook 'setCurrentUserOnCreate', only: ['create']
      @beforeHook 'setCurrentUserOnUpdate', only: ['update']
      @beforeHook 'setCurrentUserOnDelete', only: ['delete']

      @public @async setCurrentUserOnCreate: Function,
        default: (args...)->
          @recordBody.creatorId = @session.uid ? null
          @recordBody.editorId = @recordBody.creatorId
          yield return args

      @public @async setCurrentUserOnUpdate: Function,
        default: (args...)->
          @recordBody.editorId = @session.uid ? null
          yield return args

      @public @async setCurrentUserOnDelete: Function,
        default: (args...)->
          @recordBody.editorId = @session.uid ? null
          @recordBody.removerId = @recordBody.editorId
          yield return args

      @public @async protectEditable: Function,
        default: (args...)->
          @recordBody = _.omit @recordBody, ['creatorId', 'editorId', 'removerId']
          yield return args


      @initializeMixin()
