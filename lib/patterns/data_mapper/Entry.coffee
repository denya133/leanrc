joi = require 'joi'


###
```coffee
class App::TomatoEntry extends Module::Entry
  @inheritProtected()

  @Module: App

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

# класс Entry нужен чтобы его указывали в делегатах инстансов Ресурсов в клиентских ядрах
# сигнатуры наследников классов Entry и Record могут отличаться (иногда не существенно, а иногда существенно)


module.exports = (Module)->
  class Entry extends Module::CoreObject
    @inheritProtected()
    @implements Module::RecordInterface
    @include Module::RecordMixin

    @Module: Module

    @attribute id: String
    @attribute rev: String
    @attribute type: String
    @attribute isHidden: Boolean, {default: no}
    @attribute createdAt: Date
    @attribute updatedAt: Date
    @attribute deletedAt: Date


  Entry.initialize()
