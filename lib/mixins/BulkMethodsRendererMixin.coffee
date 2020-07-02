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
    AnyT
    FuncG, MaybeG, InterfaceG
    ContextInterface, ResourceInterface
    Renderer, Mixin
  } = Module::

  Module.defineMixin Mixin 'BulkMethodsRendererMixin', (BaseClass = Renderer) ->
    class extends BaseClass
      @inheritProtected()

      @public bulkDelete: FuncG([String, String, AnyT], MaybeG AnyT),
        default: (resource, action, aoData)->

      @public bulkDestroy: FuncG([String, String, AnyT], MaybeG AnyT),
        default: (resource, action, aoData)->

      @public @async render: FuncG([ContextInterface, AnyT, ResourceInterface, MaybeG InterfaceG {
        method: String
        path: String
        resource: String
        action: String
        tag: String
        template: String
        keyName: MaybeG String
        entityName: String
        recordName: MaybeG String
      }], MaybeG AnyT),
        default: (args...)->
          [ctx, aoData, resource, options = {}] = args
          {path, resource:resourceName, action, template:templatePath} = options
          if path? and resourceName? and action?
            {templates} = @Module
            return yield Module::Promise.resolve(
              if templates?[templatePath]?
                templates?[templatePath]?.call(
                  resource, resourceName, action, aoData
                )
              else if action in [
                'bulkDelete', 'bulkDestroy'
              ]
                @[action].call(
                  resource, resourceName, action, aoData, templatePath
                )
              else
                yield @super args...
            )
          else
            yield return aoData


      @initializeMixin()
