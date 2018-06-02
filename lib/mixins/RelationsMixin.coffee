# вычленяем из Record'а все что связано с релейшенами, т.к. Рекорды на основе key-value базы данных (Redis-like) не смогут поддерживать связи - т.к. на фундаментальном уровне кроме поиска по id в них нереализован поиск по НЕ-первичным ключам или сложным условиям


# миксин для подмешивания в классы унаследованные от Module::Record
# если в этих классах необходим функционал релейшенов.


module.exports = (Module)->
  {
    CoreObject
    Utils: { _, inflect, joi, co }
  } = Module::

  Module.defineMixin 'RelationsMixin', (BaseClass = CoreObject) ->
    class extends BaseClass
      @inheritProtected()
      # @implements Module::RelationsMixinInterface

      # NOTE: отличается от belongsTo тем, что в атрибуте `<name>Id` может храниться null значение, а сама связь не является обязательной (образуется между объектами "в одной плоскости")
      @public @static relatedTo: Function,
        default: (typeDefinition, opts={})->
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.attr ?= "#{vsAttr}Id"
          opts.inverse ?= "#{inflect.pluralize inflect.camelize @name, no}"
          opts.relation = 'relatedTo'

          @attribute "#{opts.attr}": String

          opts.recordName ?= ->
            [vsModuleName, vsRecordName] = recordClass.parseRecordName vsAttr
            vsRecordName
          opts.collectionName ?= ->
            "#{
              inflect.pluralize opts.recordName.replace /Record$/, ''
            }Collection"

          opts.get = co.wrap ->
            RelatedToCollection = @collection.facade.retrieveProxy opts.collectionName
            # NOTE: может быть ситуация, что relatedTo связь не хранится в классическом виде атрибуте рекорда, а хранение вынесено в отдельную промежуточную коллекцию по аналогии с М:М , но с добавленным uniq констрейнтом на одном поле (чтобы эмулировать 1:М связи)
            unless opts.through
              return yield (yield RelatedToCollection.takeBy(
                "@doc.#{opts.refKey}": @[opts.attr]
              )).first()
            else
              through = @constructor.relations[opts.through[0]]
              ThroughCollection = @collection.facade.retrieveProxy through.collectionName
              ThroughRecord = @findRecordByName through.recordName
              inverse = ThroughRecord.relations[opts.through[1].by]
              relatedId = (yield (yield ThroughCollection.takeBy(
                "@doc.#{through.inverse}": @[through.refKey]
              ,
                $limit: 1
              )).first())[opts.through[1].by]
              return yield (yield RelatedToCollection.takeBy(
                "@doc.#{inverse.refKey}": relatedId
              ,
                $limit: 1
              )).first()
              # TODO: возможно надо как то с учетом возможного задания through решить вопрос с оформлением edges в RecordMixin

          @metaObject.addMetaData 'relations', vsAttr, opts
          @public @async "#{vsAttr}": Module::RecordInterface, opts
          return

      # NOTE: отличается от relatedTo тем, что в атрибуте `<name>Id` обязательно должно храниться значение айдишника родительского объекта, которому "belongs to" - "принадлежит" этот объект. Сама связь является обязательной (образуется между объектами "в иерархии")
      @public @static belongsTo: Function,
        # default: (typeDefinition, {attr, recordName, collectionName, refKey, get, set, transform, through, inverse, valuable, sortable, groupable, filterable, validate}={})->
        default: (typeDefinition, opts={})->
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.attr ?= "#{vsAttr}Id"
          opts.inverse ?= "#{inflect.pluralize inflect.camelize @name, no}"
          opts.relation = 'belongsTo'

          @attribute "#{opts.attr}": String,
            validate: joi.string().required()

          # # TODO: нет смысла делать это вычисляемое свойство, т.к. оно нигде не используется
          # if attr isnt "#{vsAttr}Id"
          #   @public "#{vsAttr}Id": String,
          #     # valuable: "#{vsAttr}Id"
          #     # filterable: "#{vsAttr}Id"
          #     set: (aoData)->
          #       aoData = set?.apply(@, [aoData]) ? aoData
          #       @[attr] = aoData
          #       return
          #     get: ->
          #       get?.apply(@, [@[attr]]) ? @[attr]


          opts.recordName ?= ->
            [vsModuleName, vsRecordName] = recordClass.parseRecordName vsAttr
            vsRecordName
          opts.collectionName ?= ->
            "#{
              inflect.pluralize opts.recordName.replace /Record$/, ''
            }Collection"

            # TODO: эти valuable,.. можно удалить, так как вводится миксин для встроенных-проксируемых объектов, а решейшены оставляем только в виде промисов и только для удобства кода на сервере.
            # valuable: valuable
            # sortable: sortable
            # groupable: groupable
            # filterable: filterable

            # transform: transform ? -> # есть ощущение, что передавать трансформ в релейшенах немного бессмысленно - ведь сами релейшены не могут трансформировать данные - они всего лишь возвращают промисы
            #   [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            #   (@Module.NS ? @Module::)[vsRecordName]
            # validate: -> opts.transform.call(@).schema # TODO: есть ощущение, что в релейшенах validate не нужен, т.к. они не сериализуются в респонз с сервера и в реквесте не присылаются (нужны только внутри сервера для упрощения кода)

            # # TODO: зачем set на вычисляемом релейшене, когда get возвращает все равно промис, который к тому же надо резолвить? ("разрыв шаблона" - т.к. гетится один тип данных, а устанавливается другой)
            # set: (aoData)->
            #   if (id = aoData?[refKey])?
            #     @[attr] = set?.apply(@, [id]) ? id #id
            #     return
            #   else
            #     @[attr] = set?.apply(@, [null]) ? null #null
            #     return
          opts.get = co.wrap ->
            BelongsToCollection = @collection.facade.retrieveProxy opts.collectionName
            # NOTE: может быть ситуация, что belongsTo связь не хранится в классическом виде атрибуте рекорда, а хранение вынесено в отдельную промежуточную коллекцию по аналогии с М:М , но с добавленным uniq констрейнтом на одном поле (чтобы эмулировать 1:М связи)

              # vcRecord = opts.transform.call(@)
              # vsCollectionName = "#{inflect.pluralize vcRecord.name.replace /Record$/, ''}Collection"
              # vsCollectionName = switch vsCollectionName
              #   when 'UsersCollection'
              #     Module::USERS
              #   when 'SessionsCollection'
              #     Module::SESSIONS
              #   when 'SpacesCollection'
              #     Module::SPACES
              #   when 'MigrationsCollection'
              #     Module::MIGRATIONS
              #   when 'RolesCollection'
              #     Module::ROLES
              #   when 'UploadsCollection'
              #     Module::UPLOADS
              #   else
              #     vsCollectionName
              # voCollection = @collection.facade.retrieveProxy vsCollectionName

            unless opts.through
              return yield (yield BelongsToCollection.takeBy(
                "@doc.#{opts.refKey}": @[opts.attr]
              )).first()
            else
              through = @constructor.relations[opts.through[0]]
              ThroughCollection = @collection.facade.retrieveProxy through.collectionName
              ThroughRecord = @findRecordByName through.recordName
              inverse = ThroughRecord.relations[opts.through[1].by]
              belongsId = (yield (yield ThroughCollection.takeBy(
                "@doc.#{through.inverse}": @[through.refKey]
              ,
                $limit: 1
              )).first())[opts.through[1].by]
              return yield (yield BelongsToCollection.takeBy(
                "@doc.#{inverse.refKey}": belongsId
              ,
                $limit: 1
              )).first()
              # TODO: возможно надо как то с учетом возможного задания through решить вопрос с оформлением edges в RecordMixin

          @metaObject.addMetaData 'relations', vsAttr, opts
          @public @async "#{vsAttr}": Module::RecordInterface, opts
          return

      @public @static hasMany: Function,
        default: (typeDefinition, opts={})->
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
          opts.relation = 'hasMany'
          opts.recordName ?= ->
            [vsModuleName, vsRecordName] = recordClass.parseRecordName vsAttr
            vsRecordName
          opts.collectionName ?= ->
            "#{
              inflect.pluralize opts.recordName.replace /Record$/, ''
            }Collection"
          # opts.transform ?= ->
          #   [vsModuleName, vsRecordName] = @parseRecordName vsAttr
          #   (@Module.NS ? @Module::)[vsRecordName]
          # opts.validate = -> joi.array().items opts.transform.call(@).schema # TODO: есть ощущение, что в релейшенах validate не нужен, т.к. они не сериализуются в респонз с сервера и в реквесте не присылаются (нужны только внутри сервера для упрощения кода)
          opts.get = co.wrap ->
            HasManyCollection = @collection.facade.retrieveProxy opts.collectionName

            # vcRecord = opts.transform.call(@)
            # vsCollectionName = "#{inflect.pluralize vcRecord.name.replace /Record$/, ''}Collection"
            # vsCollectionName = switch vsCollectionName
            #   when 'UsersCollection'
            #     Module::USERS
            #   when 'SessionsCollection'
            #     Module::SESSIONS
            #   when 'SpacesCollection'
            #     Module::SPACES
            #   when 'MigrationsCollection'
            #     Module::MIGRATIONS
            #   when 'RolesCollection'
            #     Module::ROLES
            #   when 'UploadsCollection'
            #     Module::UPLOADS
            #   else
            #     vsCollectionName
            # voCollection = @collection.facade.retrieveProxy vsCollectionName
            unless opts.through
              return yield HasManyCollection.takeBy(
                "@doc.#{opts.inverse}": @[opts.refKey]
              )
            else
              through = @constructor.relations[opts.through[0]]
              ThroughCollection = @collection.facade.retrieveProxy through.collectionName
              ThroughRecord = @findRecordByName through.recordName
              inverse = ThroughRecord.relations[opts.through[1].by]
              manyIds = yield (yield ThroughCollection.takeBy(
                "@doc.#{through.inverse}": @[opts.refKey]
              )).map (voRecord)-> voRecord[opts.through[1].by]
              return yield HasManyCollection.takeBy(
                "@doc.#{inverse.refKey}": $in: manyIds
              )

          @metaObject.addMetaData 'relations', vsAttr, opts
          @public @async "#{vsAttr}": Module::CursorInterface, opts
          return

      @public @static hasOne: Function,
        default: (typeDefinition, opts={})->
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.singularize inflect.camelize @name, no}Id"
          opts.relation = 'hasOne'
          opts.recordName ?= ->
            [vsModuleName, vsRecordName] = recordClass.parseRecordName vsAttr
            vsRecordName
          opts.collectionName ?= ->
            "#{
              inflect.pluralize opts.recordName.replace /Record$/, ''
            }Collection"
          # opts.transform ?= ->
          #   [vsModuleName, vsRecordName] = @parseRecordName vsAttr
          #   (@Module.NS ? @Module::)[vsRecordName]
          # opts.validate = -> opts.transform.call(@).schema # TODO: есть ощущение, что в релейшенах validate не нужен, т.к. они не сериализуются в респонз с сервера и в реквесте не присылаются (нужны только внутри сервера для упрощения кода)
          opts.get = co.wrap ->
            HasOneCollection = @collection.facade.retrieveProxy opts.collectionName
            # NOTE: может быть ситуация, что hasOne связь не хранится в классическом виде атрибуте рекорда, а хранение вынесено в отдельную промежуточную коллекцию по аналогии с М:М , но с добавленным uniq констрейнтом на одном поле (чтобы эмулировать 1:М связи)

            # vcRecord = opts.transform.call(@)
            # vsCollectionName = "#{inflect.pluralize vcRecord.name.replace /Record$/, ''}Collection"
            # vsCollectionName = switch vsCollectionName
            #   when 'UsersCollection'
            #     Module::USERS
            #   when 'SessionsCollection'
            #     Module::SESSIONS
            #   when 'SpacesCollection'
            #     Module::SPACES
            #   when 'MigrationsCollection'
            #     Module::MIGRATIONS
            #   when 'RolesCollection'
            #     Module::ROLES
            #   when 'UploadsCollection'
            #     Module::UPLOADS
            #   else
            #     vsCollectionName
            # voCollection = @collection.facade.retrieveProxy vsCollectionName
            unless opts.through
              return yield (yield HasOneCollection.takeBy(
                "@doc.#{opts.inverse}": @[opts.refKey]
              ,
                $limit: 1
              )).first()
            else
              through = @constructor.relations[opts.through[0]]
              ThroughCollection = @collection.facade.retrieveProxy through.collectionName
              ThroughRecord = @findRecordByName through.recordName
              inverse = ThroughRecord.relations[opts.through[1].by]
              oneId = (yield (yield ThroughCollection.takeBy(
                "@doc.#{through.inverse}": @[opts.refKey]
              ,
                $limit: 1
              )).first())[opts.through[1].by]
              return yield (yield HasOneCollection.takeBy(
                "@doc.#{inverse.refKey}": oneId
              ,
                $limit: 1
              )).first()

          @metaObject.addMetaData 'relations', vsAttr, opts
          @public @async "#{vsAttr}": RecordInterface, opts
          return

      # Cucumber.inverseFor 'tomato' #-> {recordClass: App::Tomato, attrName: 'cucumbers', relation: 'hasMany'}
      @public @static inverseFor: Function,
        default: (asAttrName)->
          opts = @relations[asAttrName]
          RecordClass = @findRecordByName opts.recordName
          {inverse:attrName} = opts
          {relation} = RecordClass.relations[attrName]
          return {recordClass: RecordClass, attrName, relation}

      @public @static relations: Object,
        get: -> @metaObject.getGroup 'relations', no


      @initializeMixin()
