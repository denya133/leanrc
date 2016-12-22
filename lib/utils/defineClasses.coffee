_                     = require 'lodash'
inflect               = require('i')()
fs                    = require 'fs'
extend                = require './extend'

folders = [
  'mixins'
  'models'
  'controllers'
]

defineClasses = (path, reDefine = yes)->

  manifest = require "#{path}/../manifest.json"
  {prefix} = manifest.foxxmcModule
  Prefix = inflect.classify prefix

  getModulesPathes = ()->
    pathToModules = fs.join "#{path}/node_modules"
    fs.listTree pathToModules
      .filter (i)->
        /^foxxmc\-/.test i
      .map (i)->
        fs.join pathToModules, i

  getClassesFor = (subfolder)->
    require(fs.join path, subfolder, 'index')()
    return

  getUtils = ->
    utilsDir = fs.join path, 'utils'
    fs.list(utilsDir).forEach (path)->
      name = path.replace '.js', ''
      global["#{Prefix}"]::Utils[name] = require fs.join utilsDir, name
      return
    return

  initializeModule = (addonPath, cb)->
    module.exports addonPath
    cb()

  recursionModulesInitializing = (addonsPathes, index)->
    if addonsPathes[index]?
      addonPath = addonsPathes[index].replace '/index.js', ''
      Module = require addonsPathes[index]

      if Module.initialize? and _.isFunction Module.initialize
        Module.initialize ()->
          index += 1
          if addonsPathes[index]?
            return recursionModulesInitializing addonsPathes, index
          else
            return
      else
        initializeModule addonPath, ()->
          index += 1
          if addonsPathes[index]?
            return recursionModulesInitializing addonsPathes, index
          else
            return
    else
      return

  # здесь надо проинициализоировать все аддоны, от которых зависит это приложение/аддон
  recursionModulesInitializing getModulesPathes(), 0

  if reDefine or not global["#{Prefix}"]? or not global['classes']?["#{Prefix}"]?
    global["#{Prefix}"] = eval "(
      function() {
        function #{Prefix}() {}
        return #{Prefix};
    })();"
    extend global["#{Prefix}"], _.omit manifest, ['name']
    global["#{Prefix}"].use = ->
      new @::ApplicationRouter()
    global["#{Prefix}"]::Utils = {}
    global['classes'] ?= {}
    global['classes']["#{Prefix}"] = global["#{Prefix}"]

    getUtils()
    folders.forEach (subfolder)->
      getClassesFor subfolder
      return
    global["#{Prefix}"]::ApplicationRouter = require fs.join path, 'router'
  return global["#{Prefix}"]

module.exports = defineClasses
