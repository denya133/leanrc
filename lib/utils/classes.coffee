_         = require 'lodash'
fs        = require 'fs'
inflect   = require('i')()


classes = {}
models = {}
controllersDir = fs.join __dirname, '../controllers'
controllerNames = _.chain fs.listTree controllersDir
  .filter (i) -> fs.isFile fs.join controllersDir, i
  .map (i) -> i.replace /\.js$/, ''
  .orderBy()
  .value()
modelsDir = fs.join __dirname, '../models'
modelNames = _.chain fs.listTree modelsDir
  .filter (i) -> fs.isFile fs.join modelsDir, i
  .map (i) -> i.replace /\.js$/, ''
  .orderBy()
  .value()

for controllerName in controllerNames
  controller = require fs.join controllersDir, controllerName
  classes[controller.name] = controller
  classes[controller::Model.name] = controller::Model if controller::Model?

for modelName in modelNames
  unless classes[inflect.classify modelName]?
    Model = require fs.join modelsDir, modelName
    classes[Model.name] = Model

module.exports = classes
