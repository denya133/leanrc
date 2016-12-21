require 'supererror'
gulp              = require 'gulp'
fs                = require 'fs-extra'
glob              = require 'glob'
pluralize         = require 'pluralize'
changeCase        = require 'change-case'
{
  join
  basename
  normalize
}                 = require 'path'

ROOT = join __dirname, '../..'

folders = [
  'mixins'
  'models'
  'controllers'
]


gulp.task 'generate_indexes', (cb)->
  _path = join ROOT, 'api'
  {prefix} = require("#{ROOT}/manifest.json").foxxmcModule
  Prefix = changeCase.pascalCase prefix
  folders.forEach (subfolder)->
    pathToModules = join _path, subfolder
    index_file = normalize join _path, subfolder, 'index.coffee'
    var_name = pluralize subfolder, 10
    if subfolder is 'models'
      suffix = ''
    else
      suffix = pluralize subfolder, 1
    file_content = "
      \nmodule.exports = ->
    "
    glob.sync join pathToModules, '**/*.coffee'
      .forEach (file)->
        unless basename(file, '.coffee') is 'index'
          file = file.replace '.coffee', ''
            .replace "#{pathToModules}", '.'
          name = file.replace "./", ''
            .replace /[/]/g, '_'
          Name = changeCase.pascalCase "#{name}_#{suffix}"
          file_content += "
            \n  #{Prefix}::#{Name} = require '#{file}'
          "
    file_content += '\n'
    fs.writeFileSync index_file, file_content
  cb()
