_             = require 'lodash'
inflect       = require('i')()
fs            = require 'fs'
semver        = require 'semver'
FoxxRouter    = require '@arangodb/foxx/router'


FOLDERS       = [
  'utils'
  'mixins'
  'models'
  'controllers'
]

###
  ```
  ```
###

module.exports = (FoxxMC)->
  CoreObject    = require('./CoreObject') FoxxMC
  extend        = require('./utils/extend') FoxxMC

  class FoxxMC::Module extends CoreObject
    Utils:      null # must be defined as {} in child classes
    Scripts:    null # must be defined as {} in child classes
    @context:   null # must be defined as module.context in child classes

    @defineClassProperty 'Module', -> @

    @getClassesFor: (subfolder)->
      subfolderDir = fs.join @context.basePath, 'dist', subfolder

      _files = _.chain fs.listTree subfolderDir
        .filter (i) -> fs.isFile fs.join subfolderDir, i
        .map (i) -> i.replace /\.js$/, ''
        .orderBy()
        .value()
      for _file in _files
        require fs.join subfolderDir, _file
      return

    @initializeModules: ->
      if @context.manifest.dependencies?
        for own dependencyName, dependencyDefinition of @context.manifest.dependencies
          do ({name, version}=dependencyDefinition)=>
            vModule = @context.dependencies[dependencyName]
            unless semver.satisfies vModule.context.manifest.version, version
              throw new Error "
                Dependent module #{vModule.name} not compatible.
                This module required version #{version} but #{vModule.name} version is #{vModule.context.manifest.version}.
              "
              return
            return
      return

    @use: ->
      applicationRouter = new @::ApplicationRouter()
      router = FoxxRouter()
      Mapping = {}
      applicationRouter._routes.forEach (item)->
        controllerName = inflect.camelize inflect.underscore "#{item.controller.replace /[/]/g, '_'}Controller"
        Mapping[controllerName] ?= []
        Mapping[controllerName].push item.action unless _.includes Mapping[controllerName], item.action
      allSections = Object.keys Mapping
      availableSections = []
      availableSections.push
        id: 'system'
        module: @name
        actions: ['administrator']
      availableSections.push
        id: 'moderator'
        module: @name
        actions: allSections
      availableSections = availableSections.concat allSections.map (section)->
        id: section
        module: @name
        actions: Mapping[section]
      router.get '/permitted_sections', (req, res)->
        res.send {availableSections}
      router.get '/permitted_sections/:section', (req, res)=>
        switch req.pathParams.section
          when 'system'
            availableSection =
              id: 'system'
              module: @name
              actions: ['administrator']
          when 'moderator'
            availableSection =
              id: 'moderator'
              module: @name
              actions: allSections
          else
            availableSection =
              id: req.pathParams.section
              module: @name
              actions: Mapping[req.pathParams.section]
        res.send {availableSection}
      router.get '/version', (req, res)=>
        res.send @context.manifest.version

      @context.use router

      applicationRouter

  FoxxMC::Module.initialize()

  FoxxMC::Module.initialize = ->
    # console.log '??????????????>>>> Module.initialize 111', @, @name, @context
    FoxxMC::Module.super('initialize') arguments
    global[@name] = @
    # console.log '??????????????>>>> Module.initialize 222', @, @name, @context
    # extend @, _.omit @context.manifest, ['name']

    global['classes'] ?= {}
    global['classes'][@name] = @
    @initializeModules()

    FOLDERS.forEach (subfolder)=>
      @getClassesFor subfolder
    require fs.join @context.basePath, 'dist', 'router'
    @

  FoxxMC::Module
