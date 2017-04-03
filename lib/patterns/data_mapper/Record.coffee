joi = require 'joi'

RC = require 'RC'


###
```coffee
class App::TomatoRecord extends LeanRC::Record
  @inheritProtected()

  @Module: App

  @attr title: String,
    validate: -> joi.string() # !!! нужен для сложной валидации данных
    # transform указывать не надо, т.к. стандартный тип, LeanRC::StringTransform

  @attr nameObj: App::NameObj,
    validate: -> joi.object().required().start().end().default({})
    transform: -> App::NameObjTransform # or some record class App::OnionRecord

  @attr description: String

  @attr registeredAt: Date,
    validate: -> joi.date()
    transform: -> App::MyDateTransform
```
###


module.exports = (LeanRC)->
  class LeanRC::Record extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::RecordInterface
    @include RC::ChainsMixin
    @include LeanRC::RecordMixin

    @Module: LeanRC

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

    @afterHook 'afterUpdate', only: ['update']
    @afterHook 'afterCreate', only: ['create']

    @beforeHook 'beforeDelete', only: ['delete']
    @afterHook 'afterDelete', only: ['delete']

    # под вопросом ???????????????
    # @afterHook 'updateEdges', only: ['create', 'update', 'delete']


    @afterHook 'afterDestroy', only: ['destroy']

    @public afterCreate: Function,
      args: [LeanRC::RecordInterface]
      return: LeanRC::RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'createdRecord', aoRecord
        return

    @public beforeUpdate: Function,
      args: []
      return: RC::Constants.NILL
      default: ->
        @updatedAt = new Date().toISOString()
        return

    @public afterUpdate: Function,
      args: [LeanRC::RecordInterface]
      return: LeanRC::RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'updatedRecord', aoRecord
        return

    @public beforeDelete: Function,
      args: []
      return: RC::Constants.NILL
      default: ->
        @isHidden = yes
        @updatedAt = new Date().toISOString()
        @deletedAt = new Date().toISOString()
        return

    @public afterDelete: Function,
      args: [LeanRC::RecordInterface]
      return: LeanRC::RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'deletedRecord', aoRecord
        return

    @public afterDestroy: Function,
      args: [LeanRC::RecordInterface]
      return: LeanRC::RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'destroyedRecord', aoRecord
        return


  return LeanRC::Record.initialize()
