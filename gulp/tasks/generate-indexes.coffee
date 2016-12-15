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
  folders.forEach (subfolder)->
    pathToModules = join _path, subfolder
    index_file = normalize join _path, subfolder, 'index.coffee'
    var_name = pluralize subfolder, 10
    file_content = "module.exports = #{var_name} = {}"
    glob.sync join pathToModules, '**/*.coffee'
      .forEach (file)->
        unless (_name = basename file, '.coffee') is 'index'
          suffix = pluralize subfolder, 1
          prefix = "#{_addonConfig.prefix}_"
          name = changeCase.pascalCase "#{prefix}#{_name}_#{suffix}"
          file_content += "\n#{var_name}['#{name}'] = require './#{_name}'"
    file_content += '\n'
    fs.writeFileSync index_file, file_content
  cb()
