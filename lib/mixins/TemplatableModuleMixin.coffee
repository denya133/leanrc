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
    FuncG, DictG
    Mixin
    Module: ModuleClass
    Utils: { _, filesTreeSync }
  } = Module::

  Module.defineMixin Mixin 'TemplatableModuleMixin', (BaseClass = ModuleClass) ->
    class extends BaseClass
      @inheritProtected()

      @public @static templates: DictG(String, Function),
        get: -> @metaObject.getGroup 'templates', no

      @public @static defineTemplate: FuncG([String, Function], Function),
        default: (filename, fun)->
          vsRoot = @::ROOT ? '.'
          vsTemplatesDir = "#{vsRoot}/templates/"
          templateName = filename
            .replace vsTemplatesDir, ''
            .replace /\.js|\.coffee/, ''
          @metaObject.addMetaData 'templates', templateName, fun
          return fun

      @public @static resolveTemplate: FuncG([], Function),
        default: (args...)->
          vsRoot = @::ROOT ? '.'
          vsTemplatesDir = "#{vsRoot}/templates/"
          path = require 'path'
          templateName = path.resolve args...
            .replace vsTemplatesDir, ''
            .replace /\.js|\.coffee/, ''
          return @templates[templateName]

      @public @static loadTemplates: Function,
        default: ->
          vsRoot = @::ROOT ? '.'
          vsTemplatesDir = "#{vsRoot}/templates"
          files = filesTreeSync vsTemplatesDir, filesOnly: yes
          (files ? []).forEach (i)=>
            templateName = i.replace /\.js|\.coffee/, ''
            vsTemplatePath = "#{vsTemplatesDir}/#{templateName}"
            require(vsTemplatePath) @Module
          return


      @initializeMixin()
