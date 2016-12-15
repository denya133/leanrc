require 'supererror'
scaffolt            = require 'scaffolt'
pluralize           = require 'pluralize'
changeCase          = require 'change-case'
nodepath            = require 'path'
fse                 = require 'fs-extra'
glob                = require 'glob'

copySync = (foxxmcRoot, rootPath, folder)->
  fse.copySync nodepath.resolve(foxxmcRoot, folder), nodepath.resolve(rootPath, folder)

readme_dirs = [
  'api'
  'migrations'
]

init_copy_dirs = [
  'gulp'
  'assets'
  'api/scripts'
  # 'servers' # cteation in init generator
]

module.exports = (scope, cb)->
  type = scope.generatorType
  generatorsPath = "#{scope.foxxmcRoot}/generators"

  app_name = scope.app_name ? 'project'
  switch type
    when 'init'
      scaffolt 'init', app_name,
        generatorsPath: generatorsPath
      , (error)->
        if error
          cb.log.error "Error in \"#{type}\" generator"
          throw error
        readme_dirs.forEach (folder)->
          pathToReadme = nodepath.join scope.foxxmcRoot, folder
          all_files = glob.sync nodepath.join pathToReadme, '**'
          all_files.forEach (file)->
            if /Readme.md$/.test(file)
              suffix = file.replace scope.foxxmcRoot, ''
              fse.copySync file, scope.rootPath + suffix
        init_copy_dirs.forEach (folder)->
          copySync scope.foxxmcRoot, scope.rootPath, folder
        cb?()
    else
      scope.destDir = "#{scope.rootPath}/api/#{pluralize(type, 5)}"
      scope.destDir = "#{scope.rootPath}/#{pluralize(type, 5)}" if type is 'migration'
      scope.id = []
      scope.args.forEach (name)->
        scope.id.push changeCase.pascalCase "#{pluralize(name, 5)}_#{type}"
        scaffolt type, name,
          generatorsPath: generatorsPath
        , (error)->
          if error
            cb.log.error "Error in \"#{type}\" generator"
            throw error
          cb?()
      delete scope.id if type is 'migration'
