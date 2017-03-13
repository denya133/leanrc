# надо реализовать в отдельном модуле (npm-пакете) так как является платформозависимым
# эта реализация должна имплементировать методы `parseQuery` и `executeQuery`.
# последний должен возврашать результат с интерфейсом CursorInterface
# но для хранения и получения данных должна обращаться к ArangoDB коллекциям.

_             = require 'lodash'
joi           = require 'joi'
{ db }        = require '@arangodb'
qb            = require 'aqb'
crypto        = require '@arangodb/crypto'
inflect       = require('i')()
fs            = require 'fs'
RC            = require 'RC'

SIMPLE_TYPES  = ['string', 'number', 'boolean', 'date', 'object']

# здесь же будем использовать ArangoCursor

module.exports = (LeanRC)->
  class LeanRC::ArangoCollectionMixin extends RC::Mixin
    @inheritProtected()

    @Module: LeanRC

    @public parseQuery: Function,
      default: (query)->
        return query

    @public executeQuery: Function,
      default: (query, options)->
        return result


  return LeanRC::ArangoCollection.initialize()
