# NOTE: through источники для relatedTo и belongsTo связей с опцией through НАДО ОБЪЯВЛЯТЬ ЧЕРЕЗ hasEmbed чтобы корректно отрабатывал сеттер сохраняющий данные об айдишнике подвязанного объекта в промежуточную коллекцию


module.exports = (Module)->
  {
    PointerT, JoiT
    PropertyDefinitionT, EmbedOptionsT, EmbedConfigT
    FuncG, MaybeG, DictG, SubsetG, AsyncFuncG, ListG, UnionG
    EmbeddableInterface, RecordInterface, CollectionInterface, CursorInterface
    Record, Mixin
    Utils: { _, inflect, joi, co }
  } = Module::

  Module.defineMixin Mixin 'EmbeddableRecordMixin', (BaseClass = Record) ->
    class extends BaseClass
      @inheritProtected()
      @implements EmbeddableInterface

      ipoInternalRecord = PointerT @instanceVariables['~internalRecord'].pointer

      @public @static schema: JoiT,
        default: joi.object()
        get: (_data)->
          _data[@name] ?= do =>
            vhAttrs = {}
            for own asAttr, ahValue of @attributes
              vhAttrs[asAttr] = do (asAttr, ahValue)=>
                if _.isFunction ahValue.validate
                  ahValue.validate.call(@)
                else
                  ahValue.validate

            for own asAttr, ahValue of @computeds
              vhAttrs[asAttr] = do (asAttr, ahValue)=>
                if _.isFunction ahValue.validate
                  ahValue.validate.call(@)
                else
                  ahValue.validate

            for own asAttr, ahValue of @embeddings
              vhAttrs[asAttr] = do (asAttr, ahValue)=>
                if _.isFunction ahValue.validate
                  ahValue.validate.call(@)
                else
                  ahValue.validate
            joi.object vhAttrs
          _data[@name]

      @public @static relatedEmbed: FuncG([PropertyDefinitionT, EmbedOptionsT]),
        default: (typeDefinition, opts={})->
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.pluralize inflect.camelize @name.replace(/Record$/, ''), no}"
          opts.inverseType ?= null # manually only string
          opts.attr ?= "#{vsAttr}Id"
          opts.embedding = 'relatedEmbed'
          opts.through ?= null

          opts.putOnly ?= no
          opts.loadOnly ?= no

          opts.recordName ?= FuncG([MaybeG String], String) (recordType = null)->
            if recordType?
              recordClass = @findRecordByName recordType
              classNames = _.filter recordClass.parentClassNames(), (name)-> /.*Record$/.test name
              vsRecordName = classNames[1] # ['Record', 'FtRecord', 'SdRecord']
            else
              [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            vsRecordName
          opts.collectionName ?= FuncG([MaybeG String], String) (recordType = null)->
            "#{
              inflect.pluralize opts.recordName.call(@, recordType).replace /Record$/, ''
            }Collection"

          opts.validate = FuncG([], JoiT) ->
            if opts.inverseType?
              return Record.schema.unknown(yes).allow(null).optional()
            else
              EmbedRecord = @findRecordByName opts.recordName.call(@)
              return EmbedRecord.schema.allow(null).optional()
          opts.load = AsyncFuncG([], RecordInterface) co.wrap ->
            if opts.putOnly
              yield return null
            recordType = null
            if opts.inverseType?
              recordType = @[opts.inverseType]
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call @, recordType
            # NOTE: может быть ситуация, что hasOne связь не хранится в классическом виде атрибуте рекорда, а хранение вынесено в отдельную промежуточную коллекцию по аналогии с М:М , но с добавленным uniq констрейнтом на одном поле (чтобы эмулировать 1:М связи)

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::

            res = unless opts.through
              yield (yield EmbedsCollection.takeBy(
                "@doc.#{opts.refKey}": @[opts.attr]
              ,
                $limit: 1
              )).first()
            else
              # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода relatedEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
              through = @constructor.embeddings[opts.through[0]]
              unless through?
                throw new Error "Metadata about #{opts.through[0]} must be defined by `EmbeddableRecordMixin.relatedEmbed` method"
              ThroughCollection = @collection.facade.retrieveProxy through.collectionName.call(@)
              ThroughRecord = @findRecordByName through.recordName.call(@)
              inverse = ThroughRecord.relations[opts.through[1].by]
              embedId = (yield (yield ThroughCollection.takeBy(
                "@doc.#{through.inverse}": @[through.refKey]
              ,
                $limit: 1
              )).first())[opts.through[1].by]
              yield (yield EmbedsCollection.takeBy(
                "@doc.#{inverse.refKey}": embedId
              ,
                $limit: 1
              )).first()

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbed.load #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            yield return res

          opts.put = AsyncFuncG([]) co.wrap ->
            if opts.loadOnly
              yield return
            EmbedsCollection = null
            EmbedRecord = null
            aoRecord = @[vsAttr]

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbed.put #{vsAttr} embed #{JSON.stringify aoRecord}", LEVELS[DEBUG])

            if aoRecord?
              if aoRecord.constructor is Object
                if opts.inverseType?
                  unless aoRecord.type?
                    throw new Error 'When set polymorphic relatedEmbed `type` is required'
                  EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call @, aoRecord.type
                  EmbedRecord = @findRecordByName aoRecord.type
                else
                  EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call(@)
                  EmbedRecord = @findRecordByName opts.recordName.call(@)

                aoRecord.type ?= "#{EmbedRecord.moduleName()}::#{EmbedRecord.name}"
                aoRecord = yield EmbedsCollection.build aoRecord
              unless opts.through
                aoRecord.spaceId = @spaceId if @spaceId?
                aoRecord.teamId = @teamId if @teamId?
                aoRecord.spaces = @spaces
                aoRecord.creatorId = @creatorId
                aoRecord.editorId = @editorId
                aoRecord.ownerId = @ownerId
                if (yield aoRecord.isNew()) or Object.keys(yield aoRecord.changedAttributes()).length
                  savedRecord = yield aoRecord.save()
                else
                  savedRecord = aoRecord
                @[opts.attr] = savedRecord[opts.refKey]
                if opts.inverseType?
                  @[opts.inverseType] = savedRecord.type
              else
                # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода relatedEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
                through = @constructor.embeddings[opts.through[0]]
                unless through?
                  throw new Error "Metadata about #{opts.through[0]} must be defined by `EmbeddableRecordMixin.relatedEmbed` method"
                ThroughCollection = @collection.facade.retrieveProxy through.collectionName.call(@)
                ThroughRecord = @findRecordByName through.recordName.call(@)
                inverse = ThroughRecord.relations[opts.through[1].by]
                aoRecord.spaceId = @spaceId if @spaceId?
                aoRecord.teamId = @teamId if @teamId?
                aoRecord.spaces = @spaces
                aoRecord.creatorId = @creatorId
                aoRecord.editorId = @editorId
                aoRecord.ownerId = @ownerId
                if yield aoRecord.isNew()
                  savedRecord = yield aoRecord.save()
                  yield ThroughCollection.create(
                    "#{through.inverse}": @[through.refKey]
                    "#{opts.through[1].by}": savedRecord[inverse.refKey]
                    spaceId: @spaceId if @spaceId?
                    teamId: @teamId if @teamId?
                    spaces: @spaces
                    creatorId: @creatorId
                    editorId: @editorId
                    ownerId: @ownerId
                  )
                else
                  if Object.keys(yield aoRecord.changedAttributes()).length
                    savedRecord = yield aoRecord.save()
                  else
                    savedRecord = aoRecord
                yield (yield ThroughCollection.takeBy(
                  "@doc.#{through.inverse}": @[through.refKey]
                  "@doc.#{opts.through[1].by}": $ne: savedRecord[inverse.refKey]
                )).forEach co.wrap (voRecord)->
                  yield voRecord.destroy()
                  yield return
            yield return

          opts.restore = AsyncFuncG([MaybeG Object], MaybeG RecordInterface) co.wrap (replica)->
            EmbedsCollection = null
            EmbedRecord = null

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbed.restore #{vsAttr} replica #{JSON.stringify replica}", LEVELS[DEBUG])

            res = if replica?
              if opts.inverseType?
                unless replica.type?
                  throw new Error 'When set polymorphic relatedEmbed `type` is required'
                EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call @, replica.type
                EmbedRecord = @findRecordByName replica.type
              else
                EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call(@)
                EmbedRecord = @findRecordByName opts.recordName.call(@)

              replica.type ?= "#{EmbedRecord.moduleName()}::#{EmbedRecord.name}"
              yield EmbedsCollection.build replica
            else
              null

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbed.restore #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            yield return res

          opts.replicate = FuncG([], Object) ->
            aoRecord = @[vsAttr]

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbed.replicate #{vsAttr} embed #{JSON.stringify aoRecord}", LEVELS[DEBUG])

            res = aoRecord.constructor.objectize aoRecord

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbed.replicate #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            res

          @metaObject.addMetaData 'embeddings', vsAttr, opts
          @public "#{vsAttr}": MaybeG UnionG RecordInterface, Object
          return

      @public @static relatedEmbeds: FuncG([PropertyDefinitionT, EmbedOptionsT]),
        default: (typeDefinition, opts={})->
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.pluralize inflect.camelize @name.replace(/Record$/, ''), no}"
          opts.inverseType ?= null # manually only string
          opts.attr ?= "#{inflect.pluralize inflect.camelize vsAttr, no}"
          opts.embedding = 'relatedEmbeds'
          opts.through ?= null

          opts.putOnly ?= no
          opts.loadOnly ?= no

          opts.recordName ?= FuncG([MaybeG String], String) (recordType = null)->
            if recordType?
              recordClass = @findRecordByName recordType
              classNames = _.filter recordClass.parentClassNames(), (name)-> /.*Record$/.test name
              vsRecordName = classNames[1] # ['Record', 'FtRecord', 'SdRecord']
            else
              [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            vsRecordName
          opts.collectionName ?= FuncG([MaybeG String], String) (recordType = null)->
            "#{
              inflect.pluralize opts.recordName.call(@, recordType).replace /Record$/, ''
            }Collection"

          opts.validate = FuncG([], JoiT) ->
            if inverseType?
              return joi.array().items [
                Record.schema.unknown(yes)
                joi.any().strip()
              ]
            else
              EmbedRecord = @findRecordByName opts.recordName.call(@)
              return joi.array().items [EmbedRecord.schema, joi.any().strip()]
          opts.load = AsyncFuncG([], ListG RecordInterface) co.wrap ->
            if opts.putOnly
              yield return null
            EmbedsCollection = null
            # NOTE: может быть ситуация, что hasOne связь не хранится в классическом виде атрибуте рекорда, а хранение вынесено в отдельную промежуточную коллекцию по аналогии с М:М , но с добавленным uniq констрейнтом на одном поле (чтобы эмулировать 1:М связи)

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::

            res = unless opts.through
              if opts.inverseType?
                for { id, inverseType } in @[opts.attr]
                  EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call @, inverseType
                  yield EmbedsCollection.take id
              else
                EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call(@)
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{opts.refKey}": $in: @[opts.attr]
                )).toArray()
            else
              through = @constructor.embeddings[opts.through[0]] ? @constructor.relations?[opts.through[0]]
              ThroughCollection = @collection.facade.retrieveProxy through.collectionName.call(@)
              ThroughRecord = @findRecordByName through.recordName.call(@)
              inverse = ThroughRecord.relations[opts.through[1].by]
              embedIds = yield (yield ThroughCollection.takeBy(
                "@doc.#{through.inverse}": @[through.refKey]
              )).map (voRecord)-> voRecord[opts.through[1].by]
              yield (yield EmbedsCollection.takeBy(
                "@doc.#{inverse.refKey}": $in: embedIds
              )).toArray()

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbeds.load #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            yield return res

          opts.put = AsyncFuncG([]) co.wrap ->
            if opts.loadOnly
              yield return
            EmbedsCollection = null
            EmbedRecord = null
            alRecords = @[vsAttr]

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbeds.put #{vsAttr} embeds #{JSON.stringify alRecords}", LEVELS[DEBUG])

            if alRecords.length > 0
              unless opts.through
                alRecordIds = []
                for aoRecord in alRecords
                  if aoRecord.constructor is Object
                    if opts.inverseType?
                      unless aoRecord.type?
                        throw new Error 'When set polymorphic relatedEmbeds `type` is required'
                      EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call @, aoRecord.type
                      EmbedRecord = @findRecordByName aoRecord.type
                    else
                      EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call(@)
                      EmbedRecord = @findRecordByName opts.recordName.call(@)

                    aoRecord.type ?= "#{EmbedRecord.moduleName()}::#{EmbedRecord.name}"
                    aoRecord = yield EmbedsCollection.build aoRecord
                  aoRecord.spaceId = @spaceId if @spaceId?
                  aoRecord.teamId = @teamId if @teamId?
                  aoRecord.spaces = @spaces
                  aoRecord.creatorId = @creatorId
                  aoRecord.editorId = @editorId
                  aoRecord.ownerId = @ownerId
                  if (yield aoRecord.isNew()) or Object.keys(yield aoRecord.changedAttributes()).length
                    { id, type: inverseType } = yield aoRecord.save()
                  else
                    { id, type: inverseType } = aoRecord
                  if opts.inverseType?
                    alRecordIds.push { id, inverseType }
                  else
                    alRecordIds.push id
                @[opts.attr] = alRecordIds
              else
                through = @constructor.embeddings[opts.through[0]] ? @constructor.relations?[opts.through[0]]
                ThroughCollection = @collection.facade.retrieveProxy through.collectionName.call(@)
                ThroughRecord = @findRecordByName through.recordName.call(@)
                inverse = ThroughRecord.relations[opts.through[1].by]
                alRecordIds = []
                newRecordIds = []
                for aoRecord in alRecords
                  if aoRecord.constructor is Object
                    aoRecord.type ?= "#{EmbedRecord.moduleName()}::#{EmbedRecord.name}"
                    aoRecord = yield EmbedsCollection.build aoRecord
                  aoRecord.spaceId = @spaceId if @spaceId?
                  aoRecord.teamId = @teamId if @teamId?
                  aoRecord.spaces = @spaces
                  aoRecord.creatorId = @creatorId
                  aoRecord.editorId = @editorId
                  aoRecord.ownerId = @ownerId
                  if yield aoRecord.isNew()
                    savedRecord = yield aoRecord.save()
                    alRecordIds.push savedRecord[inverse.refKey]
                    newRecordIds.push savedRecord[inverse.refKey]
                  else
                    if Object.keys(yield aoRecord.changedAttributes()).length
                      savedRecord = yield aoRecord.save()
                    else
                      savedRecord = aoRecord
                    alRecordIds.push savedRecord[inverse.refKey]
                unless opts.putOnly
                  yield (yield ThroughCollection.takeBy(
                    "@doc.#{through.inverse}": @[through.refKey]
                    "@doc.#{opts.through[1].by}": $nin: alRecordIds
                  )).forEach co.wrap (voRecord)->
                    yield voRecord.destroy()
                    yield return
                for newRecordId in newRecordIds
                  yield ThroughCollection.create(
                    "#{through.inverse}": @[through.refKey]
                    "#{opts.through[1].by}": newRecordId
                    spaceId: @spaceId if @spaceId?
                    teamId: @teamId if @teamId?
                    spaces: @spaces
                    creatorId: @creatorId
                    editorId: @editorId
                    ownerId: @ownerId
                  )
            yield return

          opts.restore = AsyncFuncG([MaybeG Object], ListG RecordInterface) co.wrap (replica)->
            EmbedsCollection = null
            EmbedRecord = null

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbeds.restore #{vsAttr} replica #{JSON.stringify replica}", LEVELS[DEBUG])

            res = if replica? and replica.length > 0
              for item in replica
                if opts.inverseType?
                  unless replica.type?
                    throw new Error 'When set polymorphic relatedEmbeds `type` is required'
                  EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call @, replica.type
                  EmbedRecord = @findRecordByName replica.type
                else
                  EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call(@)
                  EmbedRecord = @findRecordByName opts.recordName.call(@)

                item.type ?= "#{EmbedRecord.moduleName()}::#{EmbedRecord.name}"
                yield EmbedsCollection.build item
            else
              []

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbeds.restore #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            yield return res

          opts.replicate = FuncG([], ListG Object) ->
            alRecords = @[vsAttr]

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbeds.replicate #{vsAttr} embed #{JSON.stringify alRecords}", LEVELS[DEBUG])

            res = for item in alRecords
              EmbedRecord = item.constructor
              EmbedRecord.objectize item

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.relatedEmbeds.replicate #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            res

          @metaObject.addMetaData 'embeddings', vsAttr, opts
          @public "#{vsAttr}": MaybeG ListG UnionG RecordInterface, Object
          return

      @public @static hasEmbed: FuncG([PropertyDefinitionT, EmbedOptionsT]),
        default: (typeDefinition, opts={})->
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.singularize inflect.camelize @name.replace(/Record$/, ''), no}Id"
          opts.attr = null
          opts.inverseType ?= null # manually only string
          opts.embedding = 'hasEmbed'
          opts.through ?= null

          opts.putOnly ?= no
          opts.loadOnly ?= no

          opts.recordName ?= FuncG([MaybeG String], String) (recordType = null)->
            if recordType?
              recordClass = @findRecordByName recordType
              classNames = _.filter recordClass.parentClassNames(), (name)-> /.*Record$/.test name
              vsRecordName = classNames[1] # ['Record', 'FtRecord', 'SdRecord']
            else
              [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            vsRecordName
          opts.collectionName ?= FuncG([MaybeG String], String) (recordType = null)->
            "#{
              inflect.pluralize opts.recordName.call(@, recordType).replace /Record$/, ''
            }Collection"

          opts.validate = FuncG([], JoiT) ->
            if opts.inverseType?
              return Record.schema.unknown(yes).allow(null).optional()
            else
              EmbedRecord = @findRecordByName opts.recordName.call(@)
              return EmbedRecord.schema.allow(null).optional()
          opts.load = AsyncFuncG([], RecordInterface) co.wrap ->
            if opts.putOnly
              yield return null
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call(@)
            # NOTE: может быть ситуация, что hasOne связь не хранится в классическом виде атрибуте рекорда, а хранение вынесено в отдельную промежуточную коллекцию по аналогии с М:М , но с добавленным uniq констрейнтом на одном поле (чтобы эмулировать 1:М связи)

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::

            res = unless opts.through
              query = "@doc.#{opts.inverse}": @[opts.refKey]
              if inverseType?
                query["@doc.#{opts.inverseType}"] = @type
              yield (yield EmbedsCollection.takeBy(
                query, $limit: 1
              )).first()
            else
              # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода hasEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
              through = @constructor.embeddings[opts.through[0]]
              unless through?
                throw new Error "Metadata about #{opts.through[0]} must be defined by `EmbeddableRecordMixin.hasEmbed` method"
              ThroughCollection = @collection.facade.retrieveProxy through.collectionName.call(@)
              ThroughRecord = @findRecordByName through.recordName.call(@)
              inverse = ThroughRecord.relations[opts.through[1].by]
              embedId = (yield (yield ThroughCollection.takeBy(
                "@doc.#{through.inverse}": @[opts.refKey]
              ,
                $limit: 1
              )).first())[opts.through[1].by]
              yield (yield EmbedsCollection.takeBy(
                "@doc.#{inverse.refKey}": embedId
              ,
                $limit: 1
              )).first()

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbed.load #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            yield return res

          opts.put = AsyncFuncG([]) co.wrap ->
            if opts.loadOnly
              yield return
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call(@)
            EmbedRecord = @findRecordByName opts.recordName.call(@)
            aoRecord = @[vsAttr]

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbed.put #{vsAttr} embed #{JSON.stringify aoRecord}", LEVELS[DEBUG])

            if aoRecord?
              if aoRecord.constructor is Object
                aoRecord.type ?= "#{EmbedRecord.moduleName()}::#{EmbedRecord.name}"
                aoRecord = yield EmbedsCollection.build aoRecord
              unless opts.through
                aoRecord[opts.inverse] = @[opts.refKey]
                aoRecord[opts.inverseType] = @type if opts.inverseType?
                aoRecord.spaceId = @spaceId if @spaceId?
                aoRecord.teamId = @teamId if @teamId?
                aoRecord.spaces = @spaces
                aoRecord.creatorId = @creatorId
                aoRecord.editorId = @editorId
                aoRecord.ownerId = @ownerId
                if (yield aoRecord.isNew()) or Object.keys(yield aoRecord.changedAttributes()).length
                  savedRecord = yield aoRecord.save()
                else
                  savedRecord = aoRecord
                query =
                  "@doc.#{opts.inverse}": @[opts.refKey]
                  "@doc.id": $ne: savedRecord.id # NOTE: проверяем по айдишнику только-что сохраненного
                if inverseType?
                  query["@doc.#{opts.inverseType}"] = @type
                yield (yield EmbedsCollection.takeBy(
                  query
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
              else
                # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода hasEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
                through = @constructor.embeddings[opts.through[0]]
                unless through?
                  throw new Error "Metadata about #{opts.through[0]} must be defined by `EmbeddableRecordMixin.hasEmbed` method"
                ThroughCollection = @collection.facade.retrieveProxy through.collectionName.call(@)
                ThroughRecord = @findRecordByName through.recordName.call(@)
                inverse = ThroughRecord.relations[opts.through[1].by]
                aoRecord.spaceId = @spaceId if @spaceId?
                aoRecord.teamId = @teamId if @teamId?
                aoRecord.spaces = @spaces
                aoRecord.creatorId = @creatorId
                aoRecord.editorId = @editorId
                aoRecord.ownerId = @ownerId
                if yield aoRecord.isNew()
                  savedRecord = yield aoRecord.save()
                  yield ThroughCollection.create(
                    "#{through.inverse}": @[opts.refKey]
                    "#{opts.through[1].by}": savedRecord[inverse.refKey]
                    spaceId: @spaceId if @spaceId?
                    teamId: @teamId if @teamId?
                    spaces: @spaces
                    creatorId: @creatorId
                    editorId: @editorId
                    ownerId: @ownerId
                  )
                else
                  if Object.keys(yield aoRecord.changedAttributes()).length
                    savedRecord = yield aoRecord.save()
                  else
                    savedRecord = aoRecord
                embedIds = yield (yield ThroughCollection.takeBy(
                  "@doc.#{through.inverse}": @[opts.refKey]
                  "@doc.#{opts.through[1].by}": $ne: savedRecord[inverse.refKey]
                )).map co.wrap (voRecord)->
                  id = voRecord[opts.through[1].by]
                  yield voRecord.destroy()
                  yield return id
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{inverse.refKey}": $in: embedIds
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
            else unless opts.putOnly
              unless opts.through
                voRecord = yield (yield EmbedsCollection.takeBy(
                  "@doc.#{opts.inverse}": @[opts.refKey]
                ,
                  $limit: 1
                )).first()
                if voRecord?
                  yield voRecord.destroy()
              else
                # NOTE: метаданные о through в случае с релейшеном к одному объекту должны быть описаны с помощью метода hasEmbed. Поэтому здесь идет обращение только к @constructor.embeddings
                through = @constructor.embeddings[opts.through[0]]
                unless through?
                  throw new Error "Metadata about #{opts.through[0]} must be defined by `EmbeddableRecordMixin.hasEmbed` method"
                ThroughCollection = @collection.facade.retrieveProxy through.collectionName.call(@)
                ThroughRecord = @findRecordByName through.recordName.call(@)
                inverse = ThroughRecord.relations[opts.through[1].by]
                embedIds = yield (yield ThroughCollection.takeBy(
                  "@doc.#{through.inverse}": @[opts.refKey]
                ,
                  $limit: 1
                )).map co.wrap (voRecord)->
                  id = voRecord[opts.through[1].by]
                  yield voRecord.destroy()
                  yield return id
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{inverse.refKey}": $in: embedIds
                ,
                  $limit: 1
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
            yield return

          opts.restore = AsyncFuncG([MaybeG Object], MaybeG RecordInterface) co.wrap (replica)->
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call(@)
            EmbedRecord = @findRecordByName opts.recordName.call(@)

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbed.restore #{vsAttr} replica #{JSON.stringify replica}", LEVELS[DEBUG])

            res = if replica?
              replica.type ?= "#{EmbedRecord.moduleName()}::#{EmbedRecord.name}"
              yield EmbedsCollection.build replica
            else
              null

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbed.restore #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            yield return res

          opts.replicate = FuncG([], Object) ->
            aoRecord = @[vsAttr]

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbed.replicate #{vsAttr} embed #{JSON.stringify aoRecord}", LEVELS[DEBUG])

            res = aoRecord.constructor.objectize aoRecord

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbed.replicate #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            res

          @metaObject.addMetaData 'embeddings', vsAttr, opts
          @public "#{vsAttr}": MaybeG UnionG RecordInterface, Object
          return

      @public @static hasEmbeds: FuncG([PropertyDefinitionT, EmbedOptionsT]),
        default: (typeDefinition, opts={})->
          [vsAttr] = Object.keys typeDefinition
          opts.refKey ?= 'id'
          opts.inverse ?= "#{inflect.singularize inflect.camelize @name.replace(/Record$/, ''), no}Id"
          opts.attr = null
          opts.inverseType ?= null # manually only string
          opts.embedding = 'hasEmbeds'
          opts.through ?= null

          opts.putOnly ?= no
          opts.loadOnly ?= no

          opts.recordName ?= FuncG([MaybeG String], String) (recordType = null)->
            if recordType?
              recordClass = @findRecordByName recordType
              classNames = _.filter recordClass.parentClassNames(), (name)-> /.*Record$/.test name
              vsRecordName = classNames[1] # ['Record', 'FtRecord', 'SdRecord']
            else
              [vsModuleName, vsRecordName] = @parseRecordName vsAttr
            vsRecordName
          opts.collectionName ?= FuncG([MaybeG String], String) (recordType = null)->
            "#{
              inflect.pluralize opts.recordName.call(@, recordType).replace /Record$/, ''
            }Collection"

          opts.validate = FuncG([], JoiT) ->
            if inverseType?
              return joi.array().items [
                Record.schema.unknown(yes)
                joi.any().strip()
              ]
            else
              EmbedRecord = @findRecordByName opts.recordName.call(@)
              return joi.array().items [EmbedRecord.schema, joi.any().strip()]

          opts.load = AsyncFuncG([], ListG RecordInterface) co.wrap ->
            if opts.putOnly
              yield return []
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call(@)

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::

            res = unless opts.through
              query = "@doc.#{opts.inverse}": @[opts.refKey]
              if inverseType?
                query["@doc.#{opts.inverseType}"] = @type
              yield (yield EmbedsCollection.takeBy(
                query
              )).toArray()
            else
              through = @constructor.embeddings[opts.through[0]] ? @constructor.relations?[opts.through[0]]
              ThroughCollection = @collection.facade.retrieveProxy through.collectionName.call(@)
              ThroughRecord = @findRecordByName through.recordName.call(@)
              inverse = ThroughRecord.relations[opts.through[1].by]
              embedIds = yield (yield ThroughCollection.takeBy(
                "@doc.#{through.inverse}": @[opts.refKey]
              )).map (voRecord)-> voRecord[opts.through[1].by]
              yield (yield EmbedsCollection.takeBy(
                "@doc.#{inverse.refKey}": $in: embedIds
              )).toArray()

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbeds.load #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            yield return res

          opts.put = AsyncFuncG([]) co.wrap ->
            if opts.loadOnly
              yield return
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call(@)
            EmbedRecord = @findRecordByName opts.recordName.call(@)
            alRecords = @[vsAttr]

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbeds.put #{vsAttr} embeds #{JSON.stringify alRecords}", LEVELS[DEBUG])

            if alRecords.length > 0
              unless opts.through
                alRecordIds = []
                for aoRecord in alRecords
                  if aoRecord.constructor is Object
                    aoRecord.type ?= "#{EmbedRecord.moduleName()}::#{EmbedRecord.name}"
                    aoRecord = yield EmbedsCollection.build aoRecord
                  aoRecord[opts.inverse] = @[opts.refKey]
                  aoRecord[opts.inverseType] = @type if opts.inverseType?
                  aoRecord.spaceId = @spaceId if @spaceId?
                  aoRecord.teamId = @teamId if @teamId?
                  aoRecord.spaces = @spaces
                  aoRecord.creatorId = @creatorId
                  aoRecord.editorId = @editorId
                  aoRecord.ownerId = @ownerId
                  if (yield aoRecord.isNew()) or Object.keys(yield aoRecord.changedAttributes()).length
                    { id } = yield aoRecord.save()
                  else
                    { id } = aoRecord
                  alRecordIds.push id
                unless opts.putOnly
                  query =
                    "@doc.#{opts.inverse}": @[opts.refKey]
                    "@doc.id": $nin: alRecordIds # NOTE: проверяем айдишники всех только-что сохраненных
                  if inverseType?
                    query["@doc.#{opts.inverseType}"] = @type
                  yield (yield EmbedsCollection.takeBy(
                    query
                  )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
              else
                through = @constructor.embeddings[opts.through[0]] ? @constructor.relations?[opts.through[0]]
                ThroughCollection = @collection.facade.retrieveProxy through.collectionName.call(@)
                ThroughRecord = @findRecordByName through.recordName.call(@)
                inverse = ThroughRecord.relations[opts.through[1].by]
                alRecordIds = []
                newRecordIds = []
                for aoRecord in alRecords
                  if aoRecord.constructor is Object
                    aoRecord.type ?= "#{EmbedRecord.moduleName()}::#{EmbedRecord.name}"
                    aoRecord = yield EmbedsCollection.build aoRecord
                  aoRecord.spaceId = @spaceId if @spaceId?
                  aoRecord.teamId = @teamId if @teamId?
                  aoRecord.spaces = @spaces
                  aoRecord.creatorId = @creatorId
                  aoRecord.editorId = @editorId
                  aoRecord.ownerId = @ownerId
                  if yield aoRecord.isNew()
                    savedRecord = yield aoRecord.save()
                    alRecordIds.push savedRecord[inverse.refKey]
                    newRecordIds.push savedRecord[inverse.refKey]
                  else
                    if Object.keys(yield aoRecord.changedAttributes()).length
                      savedRecord = yield aoRecord.save()
                    else
                      savedRecord = aoRecord
                    alRecordIds.push savedRecord[inverse.refKey]
                unless opts.putOnly
                  embedIds = yield (yield ThroughCollection.takeBy(
                    "@doc.#{through.inverse}": @[opts.refKey]
                    "@doc.#{opts.through[1].by}": $nin: alRecordIds
                  )).map co.wrap (voRecord)->
                    id = voRecord[opts.through[1].by]
                    yield voRecord.destroy()
                    yield return id
                  yield (yield EmbedsCollection.takeBy(
                    "@doc.#{inverse.refKey}": $in: embedIds
                  )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
                for newRecordId in newRecordIds
                  yield ThroughCollection.create(
                    "#{through.inverse}": @[opts.refKey]
                    "#{opts.through[1].by}": newRecordId
                    spaceId: @spaceId if @spaceId?
                    teamId: @teamId if @teamId?
                    spaces: @spaces
                    creatorId: @creatorId
                    editorId: @editorId
                    ownerId: @ownerId
                  )
            else unless opts.putOnly
              unless opts.through
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{opts.inverse}": @[opts.refKey]
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
              else
                through = @constructor.embeddings[opts.through[0]] ? @constructor.relations?[opts.through[0]]
                ThroughCollection = @collection.facade.retrieveProxy through.collectionName.call(@)
                ThroughRecord = @findRecordByName through.recordName.call(@)
                inverse = ThroughRecord.relations[opts.through[1].by]
                embedIds = yield (yield ThroughCollection.takeBy(
                  "@doc.#{through.inverse}": @[opts.refKey]
                )).map co.wrap (voRecord)->
                  id = voRecord[opts.through[1].by]
                  yield voRecord.destroy()
                  yield return id
                yield (yield EmbedsCollection.takeBy(
                  "@doc.#{inverse.refKey}": $in: embedIds
                )).forEach co.wrap (voRecord)-> yield voRecord.destroy()
            yield return

          opts.restore = AsyncFuncG([MaybeG Object], ListG RecordInterface) co.wrap (replica)->
            EmbedsCollection = @collection.facade.retrieveProxy opts.collectionName.call(@)
            EmbedRecord = @findRecordByName opts.recordName.call(@)

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbeds.restore #{vsAttr} replica #{JSON.stringify replica}", LEVELS[DEBUG])

            res = if replica? and replica.length > 0
              for item in replica
                item.type ?= "#{EmbedRecord.moduleName()}::#{EmbedRecord.name}"
                yield EmbedsCollection.build item
            else
              []

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbeds.restore #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            yield return res

          opts.replicate = FuncG([], ListG Object) ->
            alRecords = @[vsAttr]

            {
              LogMessage: {
                SEND_TO_LOG
                LEVELS
                DEBUG
              }
            } = Module::
            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbeds.replicate #{vsAttr} embeds #{JSON.stringify alRecords}", LEVELS[DEBUG])

            res = for item in alRecords
              EmbedRecord = item.constructor
              EmbedRecord.objectize item

            @collection.sendNotification(SEND_TO_LOG, "EmbeddableRecordMixin.hasEmbeds.replicate #{vsAttr} result #{JSON.stringify res}", LEVELS[DEBUG])

            res

          @metaObject.addMetaData 'embeddings', vsAttr, opts
          @public "#{vsAttr}": MaybeG ListG UnionG RecordInterface, Object
          return

      @public @static embeddings: DictG(String, EmbedConfigT),
        get: -> @metaObject.getGroup 'embeddings', no

      @public @static @async normalize: FuncG([MaybeG(Object), CollectionInterface], RecordInterface),
        default: (args...)->
          voRecord = yield @super args...
          for own asAttr, { load } of voRecord.constructor.embeddings
            voRecord[asAttr] = yield load.call voRecord
          voRecord[ipoInternalRecord] = voRecord.constructor.makeSnapshotWithEmbeds voRecord
          yield return voRecord

      @public @static @async serialize: FuncG([MaybeG RecordInterface], MaybeG Object),
        default: (aoRecord)->
          for own asAttr, { put } of aoRecord.constructor.embeddings
            yield put.call aoRecord
          vhResult = yield @super aoRecord
          yield return vhResult

      @public @static @async recoverize: FuncG([MaybeG(Object), CollectionInterface], MaybeG RecordInterface),
        default: (args...)->
          [ahPayload] = args
          voRecord = yield @super args...
          for own asAttr, { restore } of voRecord.constructor.embeddings when asAttr of ahPayload
            voRecord[asAttr] = yield restore.call voRecord, ahPayload[asAttr]
          yield return voRecord

      @public @static objectize: FuncG([MaybeG(RecordInterface), MaybeG Object], MaybeG Object),
        default: (args...)->
          [aoRecord] = args
          vhResult = @super args...
          for own asAttr, { replicate } of aoRecord.constructor.embeddings when aoRecord[asAttr]?
            vhResult[asAttr] = replicate.call aoRecord
          return vhResult

      @public @static makeSnapshotWithEmbeds: FuncG(RecordInterface, MaybeG Object),
        default: (aoRecord)->
          vhResult = aoRecord[ipoInternalRecord]
          for own asAttr, { replicate } of aoRecord.constructor.embeddings
            vhResult[asAttr] = replicate.call aoRecord
          vhResult

      @public @async reloadRecord: FuncG(UnionG Object, RecordInterface),
        default: (response)->
          yield @super response
          if response?
            for own asEmbed of @constructor.embeddings
              @[asEmbed] = response[asEmbed]
            @[ipoInternalRecord] = response[ipoInternalRecord]
          yield return

      # TODO: не учтены установки значений, которые раньше не были установлены
      @public @async changedAttributes: FuncG([], DictG String, Array),
        default: ->
          vhResult = yield @super()
          for own vsAttrName, { replicate } of @constructor.embeddings
            voOldValue = @[ipoInternalRecord]?[vsAttrName]
            voNewValue = replicate.call @
            unless _.isEqual voNewValue, voOldValue
              vhResult[vsAttrName] = [voOldValue, voNewValue]
          yield return vhResult

      @public @async resetAttribute: FuncG(String),
        default: (args...)->
          yield @super args...
          [asAttribute] = args
          if @[ipoInternalRecord]?
            if (attrConf = @constructor.embeddings[asAttribute])?
              { restore } = attrConf
              voOldValue = @[ipoInternalRecord][asAttribute]
              @[asAttribute] = yield restore.call @, voOldValue
          yield return

      @public @async rollbackAttributes: Function,
        default: (args...)->
          yield @super args...
          if @[ipoInternalRecord]?
            for own vsAttrName, { restore } of @constructor.embeddings
              voOldValue = @[ipoInternalRecord][vsAttrName]
              @[vsAttrName] = yield restore.call @, voOldValue
          yield return


      @initializeMixin()
