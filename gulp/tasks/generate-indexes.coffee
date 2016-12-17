require 'supererror'
gulp              = require 'gulp'
fs                = require 'fs-extra'
glob                  = require 'glob'
pluralize             = require 'pluralize'
changeCase            = require 'change-case'
# gcopy             = require 'gulp-copy'
{ join }          = require 'path'
{basename}            = require 'path'
{normalize}            = require 'path'

ROOT = join __dirname, '../..'

folders = [
  'mixins'
  'utils'
  'models'
  'controllers'
]


gulp.task 'generate_indexes', (cb)->
  _path = join ROOT, 'api'
  {prefix} = require("#{ROOT}/manifest.json").foxxmcAddon
  Prefix = changeCase.pascalCase prefix
  folders.forEach (subfolder)->
    pathToModules = join _path, subfolder
    index_file = normalize join _path, subfolder, 'index.coffee'
    var_name = pluralize subfolder, 10
    # file_content = "
    #   \nglobal['#{Prefix}'] ?= class #{Prefix}
    #   \nmodule.exports = #{var_name} = {}
    # "
    # file_content = "
    #   \nglobal['#{Prefix}'] ?= class #{Prefix}
    # "
    file_content = ""
    glob.sync join pathToModules, '**/*.coffee'
      .forEach (file)->
        unless (_name = basename file, '.coffee') is 'index'
          suffix = pluralize subfolder, 1
          Name = changeCase.pascalCase "#{_name}_#{suffix}"
          # file_content += "
          #   \n#{var_name}['#{Name}'] = require './#{_name}'
          #   \nglobal['#{Prefix}']::#{Name} =
          # "
          # file_content += "
          #   \nglobal['#{Prefix}']::#{Name} = require './#{_name}'
          # "
          file_content += "
            \n#{Prefix}::#{Name} = require './#{_name}'
          "
    file_content += '\n'
    fs.writeFileSync index_file, file_content
  cb()
