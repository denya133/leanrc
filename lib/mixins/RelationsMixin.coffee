# вычленяем из Record'а все что связано с релейшенами, т.к. Рекорды на основе key-value базы данных (Redis-like) не смогут поддерживать связи - т.к. на фундаментальном уровне кроме поиска по id в них нереализован поиск по НЕ-первичным ключам или сложным условиям


# NOTE: Это миксин для подмешивания в классы унаследованные от Module::Record
# если в этих классах необходим функционал релейшенов.

# NOTE: Главная цель этих методов, когда они используются в рекорд-классе - предоставить удобные в использовании (в коде) ассинхронные геттеры, создаваемые на основе объявленных метаданных. (т.е. чтобы не писать лишних строчек кода, для получения объектов по связями из других коллекций)


module.exports = (Module)->
  {
    CoreObject
    Utils: { _, inflect, joi, co }
  } = Module::

  Module.defineMixin 'RelationsMixin', (BaseClass = CoreObject) ->
    class extends BaseClass
      @inheritProtected()
      # @implements Module::RelationsMixinInterface

      # NOTE: отличается от belongsTo тем, что сама связь не является обязательной (образуется между объектами "в одной плоскости"), а в @[opts.attr] может содержаться null значение
      @public @static relatedTo: Function,
        default: (typeDefinition, opts={})->
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.attr ?= "#{vsAttr}Id"
          opts.inverse ?= "#{inflect.pluralize inflect.camelize @name, no}"
          opts.relation = 'relatedTo'

          # # TODO: надо решить проблему с когнитивным диссанансом из-за того, что для простых relatedTo/belongsTo связей связь формулируется через строковый айдишник в атрибуте, а для through - связь формулируется через ембедед объект содержащий айдишник объекта.
          # # TODO: чтобы решить эту проблему, надо удалить из тела этого метода объявление атрибута, тем более что если through указан, здесь бы пришлось объявлять ебмед атрибут, а это уже выходит за область ответственности этого миксина
          # @attribute "#{opts.attr}": String

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
              # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода hasEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
              through = @constructor.embeddings?[opts.through[0]]
              unless through?
                throw new Error "Metadata about #{opts.through[0]} must be defined by `EmbeddableRecordMixin.hasEmbed` method"
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

      # NOTE: отличается от relatedTo тем, что сама связь является обязательной (образуется между объектами "в иерархии"), а в @[opts.attr] обязательно должно храниться значение айдишника родительского объекта, которому "belongs to" - "принадлежит" этот объект
      # NOTE: если указана опция through, то получение данных о связи будет происходить не из @[opts.attr], а из промежуточной коллекции, где помимо айдишника объекта могут храниться дополнительные атрибуты с данными о связи
      @public @static belongsTo: Function,
        # default: (typeDefinition, {attr, recordName, collectionName, refKey, get, set, transform, through, inverse, valuable, sortable, groupable, filterable, validate}={})->
        default: (typeDefinition, opts={})->
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.attr ?= "#{vsAttr}Id"
          opts.inverse ?= "#{inflect.pluralize inflect.camelize @name, no}"
          opts.relation = 'belongsTo'

          # # TODO: надо решить проблему с когнитивным диссанансом из-за того, что для простых relatedTo/belongsTo связей связь формулируется через строковый айдишник в атрибуте, а для through - связь формулируется через ембедед объект содержащий айдишник объекта.
          # # TODO: чтобы решить эту проблему, надо удалить из тела этого метода объявление атрибута, тем более что если through указан, здесь бы пришлось объявлять ебмед атрибут, а это уже выходит за область ответственности этого миксина
          # @attribute "#{opts.attr}": String,
          #   validate: joi.string().required()
          #   # TODO: более общая проблема состоит в том, что если указана опция through то сдесь должно быть определение геттера и сеттера, которые возьмут проксируемое значение, либо сохранят проксируемое значение в промежуточной коллекции, А если опции нет, то атрибут должен работать с сохраняемым в default значением
          #   # возможно надо сделать отдельный миксин для таких случаев типа EmbeddableRelationsMixin чтобы они проксировались в промежуточные коллекции "синхронно"
          #   # если это проксирование many связей, то это может быть не просто массив айдишников связанных рекордов, а так как у каждой связи может быть добавлен как минимум атрибут типа "type", то надо возвращать как минимум еще и его, а это значит что структура данных устремляется к виду полного Рекорда (т.к. помимо типа могут быть введены дополнительные атрибуты для каждой связи)
          #   # для belongsTo связи добавлять тип бессмысленно, т.к. связь там все равно строго одна, однако для нее могут быть добавлены некоторые атрибуты, что устремит структуру связи так же к виду полного Рекорда
          #   # из чего можно сделать вывод - хранение связи belongsTo для проксируемых связей некорректно в виде Строки (String) - Их надо хранить как проксируемый embed (объект)
          #   # А так же вовод о том, что сами through связи надо объявлять не так, как запланировано сейчас через hasMany (как обычная связь, чтобы ее название потом указать в through опции другой связи), а через синхронный embed - так как надо чтобы сеттер сохранил данные, в случае если они установлены.
          #   # !!! Если синхронно нормализировать а потом обжектизировать массивы связей типа many - то это могут получиться ОЧЕНЬ большие респонзы от сервера, т.к. это могут быть и сотни и тысячи связей
          #   # делать такие through синхронными наверно будет ошибкой :(
          #   # но для штучных связей, возможно ничего плохого в этом не будет.
          #   # Для массива надо ответить на вопрос: нужно ли делать возможность управления массивом через объект (внутри атрибута объекта) ?
          #   # На данный момент код релейшенов и ембедов сделан так, что в случае если указана опция through они берут по ней метаданные о релейшене, не используя его непосредственно, а следовательно ему все равно синхронные в нем данные или асинхронные - это сделано хорошо. :)


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
              # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода hasEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
              through = @constructor.embeddings?[opts.through[0]]
              unless through?
                throw new Error "Metadata about #{opts.through[0]} must be defined by `EmbeddableRecordMixin.hasEmbed` method"
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
              # TODO: в свете обдумывания edges всплыла более общая проблема для relatedTo и belongsTo - точнее для самих релейшенов проблемы вроде нет, так как они спроэктированы только на чтение связей и упрощение кода за счет их использования, однако, для работы сохраняющего айдишник атрибута возникает следующая проблема: если происходит запись (set) айдишника, но сам релейшен указан с опцией through , то айдишник не должен храниться в этом рекорде, а должен сохраняться в промежуточной коллекции чтобы геттер смог потом по сохраненным данным получить связь (код в геттере релейшена), НО этой особой логики тут не указано для сеттера!!!

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
              through = @constructor.embeddings?[opts.through[0]] ? @constructor.relations[opts.through[0]]
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
              through = @constructor.embeddings?[opts.through[0]] ? @constructor.relations[opts.through[0]]
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
