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

# миксин может подмешиваться в наследники класса Module

module.exports = (Module)->
  {
    PointerT
    MaybeG
    Mixin
    Module: ModuleClass
    Utils: { _, inflect, filesTreeSync }
  } = Module::

  Module.defineMixin Mixin 'NamespaceModuleMixin', (BaseClass = ModuleClass) ->
    class extends BaseClass
      @inheritProtected()

      cphPathMap = PointerT @private @static pathMap: MaybeG Object

      cpmHandler = PointerT @private @static handler: Function,
        default: (Class) ->
          get: (aoTarget, asName) ->
            unless Reflect.get aoTarget, asName
              vsPath = Class[cphPathMap][asName]
              if vsPath
                require(vsPath) Class
            Reflect.get aoTarget, asName
      cpoNamespace = PointerT @private @static proto: MaybeG Object

      @public @static NS: Object,
        get: ->
          vsRoot = @::ROOT
          @[cphPathMap] ?= filesTreeSync vsRoot, filesOnly: yes
            .reduce (vhResult, vsItem) ->
              if /\.(js|coffee)$/.test vsItem
                [ blackhole, vsName ] = vsItem.match(/(\w+)\.(js|coffee)$/) ? []
                if vsItem and vsName
                  vhResult[vsName] = "#{vsRoot}/#{vsItem}"
              vhResult
            , {}
          @[cpoNamespace] ?= new Proxy @::, @[cpmHandler] @

      @public @static inheritProtected: Function,
        default: (args...) ->
          @super args...
          @[cphPathMap] = undefined
          @[cpoNamespace] = undefined
          return


      @initializeMixin()

###
Module.NS.CoreObject
{ CoreObject } = Module.NS
###
