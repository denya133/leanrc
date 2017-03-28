

RC = require 'RC'


###
```coffee
class App::TomatoEntry extends LeanRC::Entry
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

# класс Entry нужен чтобы его указывали в делегатах инстансов Ресурсов в клиентских ядрах
# сигнатуры наследников классов Entry и Record могут отличаться (иногда не существенно, а иногда существенно)


module.exports = (LeanRC)->
  class LeanRC::Entry extends RC::CoreObject
    @inheritProtected()
    @implements LeanRC::RecordInterface
    @include LeanRC::RecordMixin

    @Module: LeanRC

    @attribute id: String
    @attribute rev: String
    @attribute type: String
    @attribute isHidden: Boolean, {default: no}
    @attribute createdAt: Date
    @attribute updatedAt: Date
    @attribute deletedAt: Date


  return LeanRC::Entry.initialize()
