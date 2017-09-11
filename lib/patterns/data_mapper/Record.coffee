joi = require 'joi'


###
```coffee
module.exports = (Module)->
  Module.defineMixin Module::Record, (BaseClass) ->
    class TomatoEntryMixin extends BaseClass
      @inheritProtected()

      # Place for attributes and computeds definitions
      @attribute title: String,
        validate: -> joi.string() # !!! нужен для сложной валидации данных
        # transform указывать не надо, т.к. стандартный тип, Module::StringTransform

      @attribute nameObj: Module::NameObj,
        validate: -> joi.object().required().start().end().default({})
        transform: -> Module::NameObjTransform # or some record class Module::OnionRecord

      @attribute description: String

      @attribute registeredAt: Date,
        validate: -> joi.date().iso()
        transform: -> Module::MyDateTransform
    TomatoEntryMixin.initializeMixin()
```

```coffee
module.exports = (Module)->
  {
    Record
    TomatoEntryMixin
  } = Module::

  class TomatoRecord extends Record
    @inheritProtected()
    @include TomatoEntryMixin
    @module Module

    # business logic and before-, after- colbacks

  TomatoRecord.initialize()
```
###


module.exports = (Module)->
  {
    ANY
    NILL

    CoreObject
    RecordInterface
    ChainsMixin
    RecordMixin
  } = Module::

  class Record extends CoreObject
    @inheritProtected()
    # @implements RecordInterface
    @include ChainsMixin
    @include RecordMixin
    @module Module

    @attribute id: String,
      validate: -> joi.string().empty(null).default(null)
      # TODO: после того как в аранге наконец-то обновится свайгер можно будет использовать `.allow(null)`, а пока пробуем через трюк `.empty(null).default(null)`
    @attribute rev: String,
      validate: -> joi.string().empty(null).default(null)
    @attribute type: String,
      validate: -> joi.string().empty(null).default(null)
    @attribute isHidden: Boolean,
      validate: -> joi.boolean().default((-> no), 'by default')
      default: no
    @attribute createdAt: Date,
      validate: -> joi.date().iso().empty(null)
    @attribute updatedAt: Date,
      validate: -> joi.date().iso().empty(null)
    @attribute deletedAt: Date,
      validate: -> joi.date().iso().empty(null).default(null)
      default: null

    ############################################################################

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
      args: [RecordInterface]
      return: RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'createdRecord', aoRecord
        yield return @

    @public @async beforeUpdate: Function,
      args: []
      return: NILL
      default: ->
        @updatedAt = new Date()
        yield return

    @public @async beforeCreate: Function,
      args: []
      return: NILL
      default: ->
        @id ?= yield @collection.generateId()
        now = new Date()
        @createdAt ?= now
        @updatedAt ?= now
        yield return

    @public @async afterUpdate: Function,
      args: [RecordInterface]
      return: RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'updatedRecord', aoRecord
        yield return @

    @public beforeDelete: Function,
      args: []
      return: NILL
      default: ->
        @isHidden = yes
        now = new Date()
        @updatedAt = now
        @deletedAt = now
        return

    @public afterDelete: Function,
      args: [RecordInterface]
      return: RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'deletedRecord', aoRecord
        return @

    @public afterDestroy: Function,
      args: [RecordInterface]
      return: RecordInterface
      default: (aoRecord)->
        @collection.recordHasBeenChanged 'destroyedRecord', aoRecord
        return


  Record.initialize()
