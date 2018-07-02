

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

    Utils: { joi }
  } = Module::

  # TODO: надо решить - надо ли наследовать Record от ObjectTransform
  class Record extends CoreObject
    @inheritProtected()
    # @implements RecordInterface
    @include ChainsMixin
    @include RecordMixin
    @module Module

    @attribute id: String
    @attribute rev: String
    @attribute type: String
    @attribute isHidden: Boolean,
      validate: -> joi.boolean().empty(null).default(no, 'false by default')
      default: no
    @attribute createdAt: Date
    @attribute updatedAt: Date
    @attribute deletedAt: Date

    @chains ['create', 'update', 'delete', 'destroy']

    @beforeHook 'beforeUpdate', only: ['update']
    @beforeHook 'beforeCreate', only: ['create']

    @afterHook 'afterUpdate', only: ['update']
    @afterHook 'afterCreate', only: ['create']

    @beforeHook 'beforeDelete', only: ['delete']
    @afterHook 'afterDelete', only: ['delete']

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
