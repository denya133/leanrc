joi = require 'joi'


###
```coffee
class App::TomatoRecord extends Module::Record
  @inheritProtected()

  @module App

  @attr title: String,
    validate: -> joi.string() # !!! нужен для сложной валидации данных
    # transform указывать не надо, т.к. стандартный тип, Module::StringTransform

  @attr nameObj: App::NameObj,
    validate: -> joi.object().required().start().end().default({})
    transform: -> App::NameObjTransform # or some record class App::OnionRecord

  @attr description: String

  @attr registeredAt: Date,
    validate: -> joi.date()
    transform: -> App::MyDateTransform
```
###


module.exports = (Module)->
  {ANY, NILL} = Module::

  class Record extends Module::CoreObject
    @inheritProtected()
    @implements Module::RecordInterface
    @include Module::ChainsMixin
    @include Module::RecordMixin
    @module Module

    @attribute _key: String
    @attribute _rev: String
    @attribute _type: String
    @attribute isHidden: Boolean, {default: no}
    @attribute createdAt: Date
    @attribute updatedAt: Date
    @attribute deletedAt: Date

    @computed id: String, {valuable: 'id', get: -> @_key}
    @computed rev: String, {valuable: 'rev', get: -> @_rev}
    @computed type: String, {valuable: 'type', get: -> @_type}

    ############################################################################

    # # под вопросом ?????? возможно надо искать через (из) модуля
    # @public @static findModelByName: Function, [String], -> Array
    # @public findModelByName: Function, [String], -> Array

    # # под вопросом ??????
    # @public updateEdges: Function, [ANY], -> ANY # any type

    ############################################################################

    @chains ['create', 'update', 'delete', 'destroy']

    @beforeHook 'beforeUpdate', only: ['update']
    @beforeHook 'beforeCreate', only: ['create']

    @afterHook 'afterUpdate', only: ['update']
    @afterHook 'afterCreate', only: ['create']

    @beforeHook 'beforeDelete', only: ['delete']
    @afterHook 'afterDelete', only: ['delete']

    # под вопросом ???????????????
    # @afterHook 'updateEdges', only: ['create', 'update', 'delete']


    @afterHook 'afterDestroy', only: ['destroy']

    @public @async afterCreate: Function,
      args: [Module::RecordInterface]
      return: Module::RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'createdRecord', aoRecord
        yield return @

    @public @async beforeUpdate: Function,
      args: []
      return: NILL
      default: ->
        @updatedAt = new Date().toISOString()
        yield return

    @public @async beforeCreate: Function,
      args: []
      return: NILL
      default: ->
        @_key ?= @collection.generateId()
        @createdAt ?= new Date().toISOString()
        yield return

    @public @async afterUpdate: Function,
      args: [Module::RecordInterface]
      return: Module::RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'updatedRecord', aoRecord
        yield return @

    @public beforeDelete: Function,
      args: []
      return: NILL
      default: ->
        @isHidden = yes
        @updatedAt = new Date().toISOString()
        @deletedAt = new Date().toISOString()
        return

    @public afterDelete: Function,
      args: [Module::RecordInterface]
      return: Module::RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'deletedRecord', aoRecord
        return @

    @public afterDestroy: Function,
      args: [Module::RecordInterface]
      return: Module::RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'destroyedRecord', aoRecord
        return


  Record.initialize()
