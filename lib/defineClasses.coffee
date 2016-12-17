_                     = require 'lodash'
inflect               = require('i')()
# Promise               = require 'promise'
# pluralize             = require 'pluralize'
# glob                  = require 'glob'
# {join}                = require 'path'
# {basename}            = require 'path'
# changeCase            = require 'change-case'
fs                    = require 'fs-extra'
extend                = require './extend'

isDirectoryExist = (dirName) -> (try fs.statSync(dirName)?.isDirectory()) ? no

folders = [
  'mixins'
  'utils'
  'models'
  'controllers'
]

defineClasses = (path, options={})->
  manifest = require "#{path}/../manifest.json"
  {prefix} = manifest.foxxmcAddon
  Prefix = inflect.classify prefix
  global["#{Prefix}"] = eval "(
    var #{Prefix};
    #{Prefix} = (function() {
      function #{Prefix}() {}
      return #{Prefix};
    })();
  )()"
  extend global["#{Prefix}"], _.omit manifest, ['name']
  global["#{Prefix}"].use = ->
    new global["#{Prefix}"]::ApplicationRouter()

  _path = "#{path}/api/"
  _addonConfig = require "#{path}/index.js"

  getAddonsPathes = ()->
    pathToAddons = join "#{path}/node_modules"
    # console.log '777777777777777777*************', join pathToAddons, '*.coffee'
    return glob.sync join pathToAddons, 'foxxmc-*/index.js'

  getModulesPathes = (subfolder)->
    pathToModules = join _path, subfolder
    # console.log '88888888888888888*************', join pathToModules, '*.coffee'
    return glob.sync join pathToModules, '*.coffee'

  defineModule = (subfolder, {isBigFirst = no, withoutPrefix = no})->
    # console.log ';;;;;;;;;;;;;;;;44444444444444', getModulesPathes(subfolder)
    unless options.without?[subfolder] is 'all'
      getModulesPathes(subfolder).forEach (file)->
        unless (_name = basename file, '.coffee') is 'index'
          # console.log "!!!!!!!!!!!!defineModule unless (_name = basename file, '.coffee') is 'index'"

          suffix = pluralize subfolder, 1
          prefix = ''
          prefix = "#{_addonConfig.prefix}_" unless withoutPrefix
          name = changeCase.camelCase "#{prefix}#{_name}_#{suffix}"
          name = changeCase.pascalCase name if isBigFirst
          unless _.includes (options.without?[subfolder] ? []), name
            console.log '$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Defining constant', name
            global[name] ?= require file

  matchFolder = (subfolder)->
    switch subfolder

      when 'controllers', 'mixins', 'utils'
        # console.log 'dfgsdfgsdfgsdg', subfolder
        defineModule subfolder, isBigFirst: yes

      when 'models'
        # console.log '7685768567856785678', subfolder
        unless options.without?.models is 'all'
          models = require join _path, 'models'
          Object.keys(models.mongoose).forEach (modelName)->
            _prefix = changeCase.pascalCase _addonConfig.prefix
            _modelName = modelName.replace new RegExp("^#{_prefix}"), ''
            _name = "#{_prefix}Mongoose#{_modelName}Schema"
            console.log '$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Defining constant', _name
            global[_name] ?= models.mongoose[modelName].schema

            name = "#{_prefix}Mongoose#{_modelName}Model"
            console.log '$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Defining constant', name
            global[name] ?= models.mongoose[modelName].model
            # console.log '%**************!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! global[name]', global[name]
          Object.keys(models.sequelize).forEach (modelName)->
            name = "#{changeCase.pascalCase _addonConfig.prefix}Sequelize#{modelName}Model"
            console.log '$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Defining constant', name
            global[name] ?= models.sequelize[modelName]
            # console.log '%**************!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! global[name]', global[name]

  initializeAddon = (addonPath, addonOptions, callback)->
    _addonOptions = extend {}, addonOptions
    if _addonOptions.without
      _addonOptions.without.services = 'all'
    else
      _addonOptions.without = services: 'all'
    module.exports addonPath, _addonOptions
    callback()

  addonConfigure = (dirname)->
    result = {}
    switch options.type
      when 'web'
        web_publishings   = require "#{dirname}/servers/web/publishings"
        result.web =
          publishings: web_publishings
      when 'core'
        core_publishings  = require "#{dirname}/servers/core/publishings"
        core_consumings   = require "#{dirname}/servers/core/consumings"
        result.core =
          publishings: core_publishings
          consumings: core_consumings
      when 'proc'
        proc_publishings  = require "#{dirname}/servers/proc/publishings"
        proc_consumings   = require "#{dirname}/servers/proc/consumings"
        result.proc =
          publishings: proc_publishings
          consumings: proc_consumings
    result

  _configure = {}
  mergeConfiguring = (dirname, configure=addonConfigure)->
    _configure = extend {}, _configure, configure(dirname)



  recursionAddonsInitializing = (addonsPathes, index)->
    if addonsPathes[index]?
      addonPath = addonsPathes[index].replace '/index.js', ''
      addonConfig = require addonsPathes[index]

      if (initialize = addonConfig.initialize)?
        initialize options.type, ()->
          mergeConfiguring addonPath, addonConfig.configure
          index += 1
          if addonsPathes[index]?
            return recursionAddonsInitializing addonsPathes, index
          else
            return
      else
        addonOptions = addonConfig.options[options.type]
        initializeAddon addonPath, addonOptions, ()->
          mergeConfiguring addonPath, addonConfig.configure
          index += 1
          if addonsPathes[index]?
            return recursionAddonsInitializing addonsPathes, index
          else
            return
    else
      return


  # здесь надо проинициализоировать все аддоны, от которых зависит это приложение/аддон
  recursionAddonsInitializing getAddonsPathes(), 0

  folders.forEach (subfolder)->
    matchFolder subfolder

  _addonConfigure = _addonConfig.configure ? addonConfigure


  _addonConfig.configure = extend _addonConfigure, _configure, _addonConfigure(path)


  return global["#{Prefix}"]

module.exports = defineClasses
