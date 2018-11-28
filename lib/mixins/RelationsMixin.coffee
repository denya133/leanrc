# вычленяем из Record'а все что связано с релейшенами, т.к. Рекорды на основе key-value базы данных (Redis-like) не смогут поддерживать связи - т.к. на фундаментальном уровне кроме поиска по id в них нереализован поиск по НЕ-первичным ключам или сложным условиям


# NOTE: Это миксин для подмешивания в классы унаследованные от Module::Record
# если в этих классах необходим функционал релейшенов.

# NOTE: Главная цель этих методов, когда они используются в рекорд-классе - предоставить удобные в использовании (в коде) ассинхронные геттеры, создаваемые на основе объявленных метаданных. (т.е. чтобы не писать лишних строчек кода, для получения объектов по связями из других коллекций)


module.exports = (Module)->
  {
    NilT, PromiseT
    PropertyDefinitionT, RelationOptionsT, RelationConfigT, RelationInverseT
    FuncG, SubsetG, AsyncFuncG, DictG
    RecordInterface, CursorInterface
    RelatableInterface
    Record, Mixin
    Utils: { _, inflect, joi, co }
  } = Module::

  Module.defineMixin Mixin 'RelationsMixin', (BaseClass = Record) ->
    class extends BaseClass
      @inheritProtected()
      @implements RelatableInterface

      # NOTE: отличается от belongsTo тем, что сама связь не является обязательной (образуется между объектами "в одной плоскости"), а в @[opts.attr] может содержаться null значение
      @public @static relatedTo: FuncG([PropertyDefinitionT, RelationOptionsT], NilT),
        default: (typeDefinition, {refKey, attr, inverse, recordName, collectionName, through}={})->
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          refKey ?= 'id'
          attr ?= "#{vsAttr}Id"
          inverse ?= "#{inflect.pluralize inflect.camelize @name.replace(/Record$/, ''), no}"
          relation = 'relatedTo'

          recordName ?= FuncG([], String) ->
            [vsModuleName, vsRecordName] = recordClass.parseRecordName vsAttr
            vsRecordName
          collectionName ?= FuncG([], String) ->
            "#{
              inflect.pluralize recordName().replace /Record$/, ''
            }Collection"

          opts = {
            refKey
            attr
            inverse
            relation
            recordName
            collectionName
            through
            get: AsyncFuncG([], RecordInterface) co.wrap ->
              RelatedToCollection = @collection.facade.retrieveProxy collectionName()
              # NOTE: может быть ситуация, что relatedTo связь не хранится в классическом виде атрибуте рекорда, а хранение вынесено в отдельную промежуточную коллекцию по аналогии с М:М , но с добавленным uniq констрейнтом на одном поле (чтобы эмулировать 1:М связи)
              unless through
                return yield (yield RelatedToCollection.takeBy(
                  "@doc.#{refKey}": @[attr]
                ,
                  $limit: 1
                )).first()
              else
                # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода hasEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
                throughEmbed = @constructor.embeddings?[through[0]]
                unless throughEmbed?
                  throw new Error "Metadata about #{through[0]} must be defined by `EmbeddableRecordMixin.hasEmbed` method"
                ThroughCollection = @collection.facade.retrieveProxy throughEmbed.collectionName()
                ThroughRecord = @findRecordByName throughEmbed.recordName()
                inverse = ThroughRecord.relations[through[1].by]
                relatedId = (yield (yield ThroughCollection.takeBy(
                  "@doc.#{throughEmbed.inverse}": @[throughEmbed.refKey]
                ,
                  $limit: 1
                )).first())[through[1].by]
                return yield (yield RelatedToCollection.takeBy(
                  "@doc.#{inverse.refKey}": relatedId
                ,
                  $limit: 1
                )).first()
          }
          property = {
            get: opts.get
          }

          @metaObject.addMetaData 'relations', vsAttr, opts
          @public "#{vsAttr}": PromiseT, property
          return

      # NOTE: отличается от relatedTo тем, что сама связь является обязательной (образуется между объектами "в иерархии"), а в @[opts.attr] обязательно должно храниться значение айдишника родительского объекта, которому "belongs to" - "принадлежит" этот объект
      # NOTE: если указана опция through, то получение данных о связи будет происходить не из @[opts.attr], а из промежуточной коллекции, где помимо айдишника объекта могут храниться дополнительные атрибуты с данными о связи
      @public @static belongsTo: FuncG([PropertyDefinitionT, RelationOptionsT], NilT),
        default: (typeDefinition, {refKey, attr, inverse, recordName, collectionName, through}={})->
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          refKey ?= 'id'
          attr ?= "#{vsAttr}Id"
          inverse ?= "#{inflect.pluralize inflect.camelize @name.replace(/Record$/, ''), no}"
          relation = 'belongsTo'

          recordName ?= FuncG([], String) ->
            [vsModuleName, vsRecordName] = recordClass.parseRecordName vsAttr
            vsRecordName
          collectionName ?= FuncG([], String) ->
            "#{
              inflect.pluralize recordName().replace /Record$/, ''
            }Collection"

          opts = {
            refKey
            attr
            inverse
            relation
            recordName
            collectionName
            through
            get: AsyncFuncG([], RecordInterface) co.wrap ->
              BelongsToCollection = @collection.facade.retrieveProxy collectionName()
              # NOTE: может быть ситуация, что belongsTo связь не хранится в классическом виде атрибуте рекорда, а хранение вынесено в отдельную промежуточную коллекцию по аналогии с М:М , но с добавленным uniq констрейнтом на одном поле (чтобы эмулировать 1:М связи)

              unless through
                return yield (yield BelongsToCollection.takeBy(
                  "@doc.#{refKey}": @[attr]
                ,
                  $limit: 1
                )).first()
              else
                # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода hasEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
                throughEmbed = @constructor.embeddings?[through[0]]
                unless throughEmbed?
                  throw new Error "Metadata about #{through[0]} must be defined by `EmbeddableRecordMixin.hasEmbed` method"
                ThroughCollection = @collection.facade.retrieveProxy throughEmbed.collectionName()
                ThroughRecord = @findRecordByName throughEmbed.recordName()
                inverse = ThroughRecord.relations[through[1].by]
                belongsId = (yield (yield ThroughCollection.takeBy(
                  "@doc.#{throughEmbed.inverse}": @[throughEmbed.refKey]
                ,
                  $limit: 1
                )).first())[through[1].by]
                return yield (yield BelongsToCollection.takeBy(
                  "@doc.#{inverse.refKey}": belongsId
                ,
                  $limit: 1
                )).first()
          }
          property = {
            get: opts.get
          }

          @metaObject.addMetaData 'relations', vsAttr, opts
          @public "#{vsAttr}": PromiseT, property
          return

      @public @static hasMany: FuncG([PropertyDefinitionT, RelationOptionsT], NilT),
        default: (typeDefinition, {refKey, inverse, recordName, collectionName, through}={})->
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          refKey ?= 'id'
          inverse ?= "#{inflect.singularize inflect.camelize @name.replace(/Record$/, ''), no}Id"
          relation = 'hasMany'
          recordName ?= FuncG([], String) ->
            [vsModuleName, vsRecordName] = recordClass.parseRecordName vsAttr
            vsRecordName
          collectionName ?= FuncG([], String) ->
            "#{
              inflect.pluralize recordName().replace /Record$/, ''
            }Collection"

          opts = {
            attr: null
            refKey
            inverse
            relation
            recordName
            collectionName
            through
            get: AsyncFuncG([], CursorInterface) co.wrap ->
              HasManyCollection = @collection.facade.retrieveProxy collectionName()

              unless through
                return yield HasManyCollection.takeBy(
                  "@doc.#{inverse}": @[refKey]
                )
              else
                throughEmbed = @constructor.embeddings?[through[0]] ? @constructor.relations[through[0]]
                ThroughCollection = @collection.facade.retrieveProxy throughEmbed.collectionName()
                ThroughRecord = @findRecordByName throughEmbed.recordName()
                inverse = ThroughRecord.relations[through[1].by]
                manyIds = yield (yield ThroughCollection.takeBy(
                  "@doc.#{throughEmbed.inverse}": @[refKey]
                )).map (voRecord)-> voRecord[through[1].by]
                return yield HasManyCollection.takeBy(
                  "@doc.#{inverse.refKey}": $in: manyIds
                )
          }
          property = {
            get: opts.get
          }

          @metaObject.addMetaData 'relations', vsAttr, opts
          @public "#{vsAttr}": PromiseT, property
          return

      @public @static hasOne: FuncG([PropertyDefinitionT, RelationOptionsT], NilT),
        default: (typeDefinition, {refKey, inverse, recordName, collectionName, through}={})->
          recordClass = @
          [vsAttr] = Object.keys typeDefinition
          refKey ?= 'id'
          inverse ?= "#{inflect.singularize inflect.camelize @name.replace(/Record$/, ''), no}Id"
          relation = 'hasOne'
          recordName ?= FuncG([], String) ->
            [vsModuleName, vsRecordName] = recordClass.parseRecordName vsAttr
            vsRecordName
          collectionName ?= FuncG([], String) ->
            "#{
              inflect.pluralize recordName().replace /Record$/, ''
            }Collection"

          opts = {
            attr: null
            refKey
            inverse
            relation
            recordName
            collectionName
            through
            get: AsyncFuncG([], RecordInterface) co.wrap ->
              HasOneCollection = @collection.facade.retrieveProxy collectionName()
              # NOTE: может быть ситуация, что hasOne связь не хранится в классическом виде атрибуте рекорда, а хранение вынесено в отдельную промежуточную коллекцию по аналогии с М:М , но с добавленным uniq констрейнтом на одном поле (чтобы эмулировать 1:М связи)

              unless through
                return yield (yield HasOneCollection.takeBy(
                  "@doc.#{inverse}": @[refKey]
                ,
                  $limit: 1
                )).first()
              else
                throughEmbed = @constructor.embeddings?[through[0]] ? @constructor.relations[through[0]]
                ThroughCollection = @collection.facade.retrieveProxy throughEmbed.collectionName()
                ThroughRecord = @findRecordByName throughEmbed.recordName()
                inverse = ThroughRecord.relations[through[1].by]
                oneId = (yield (yield ThroughCollection.takeBy(
                  "@doc.#{throughEmbed.inverse}": @[refKey]
                ,
                  $limit: 1
                )).first())[through[1].by]
                return yield (yield HasOneCollection.takeBy(
                  "@doc.#{inverse.refKey}": oneId
                ,
                  $limit: 1
                )).first()
          }
          property = {
            get: opts.get
          }

          @metaObject.addMetaData 'relations', vsAttr, opts
          @public "#{vsAttr}": PromiseT, property
          return

      # Cucumber.inverseFor 'tomato' #-> {recordClass: App::Tomato, attrName: 'cucumbers', relation: 'hasMany'}
      @public @static inverseFor: FuncG(String, RelationInverseT),
        default: (asAttrName)->
          opts = @relations[asAttrName]
          RecordClass = @findRecordByName opts.recordName()
          {inverse:attrName} = opts
          {relation} = RecordClass.relations[attrName]
          return {recordClass: RecordClass, attrName, relation}

      @public @static relations: DictG(String, RelationConfigT),
        get: -> @metaObject.getGroup 'relations', no


      @initializeMixin()
