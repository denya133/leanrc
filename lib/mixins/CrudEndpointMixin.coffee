# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

###
```coffee

module.exports = (Module)->
  {
    Endpoint
    CrudEndpointMixin
  }
  UploadsDownloadEndpoint extends Endpoint
    @inheritProtected()
    @include CrudEndpointMixin
    @module Module

    @public init: Function,
      default: (args...)->
        @super args...
        @pathParam    'v', @versionSchema
        .pathParam    'space', joi.string().required()
        .pathParam    @keyName, @keySchema
        .pathParam    'attachment', joi.string().required()
        .response     joi.binary(), 'The binary stream of upload file'
        .error        UNAUTHORIZED
        .summary      'Download attached file'
        .description  '
          Find and send as stream attached file.
        '


  UploadsDownloadEndpoint.initialize()
```
###

module.exports = (Module)->
  {
    APPLICATION_MEDIATOR
    PointerT, JoiT
    FuncG, SubsetG, InterfaceG, MaybeG
    GatewayInterface
    CrudableInterface
    Endpoint
    Mixin
    Utils: {
      _, joi, inflect
    }
  } = Module::

  Module.defineMixin Mixin 'CrudEndpointMixin', (BaseClass = Endpoint) ->
    class extends BaseClass
      @inheritProtected()
      @implements CrudableInterface

      ipsKeyName = PointerT @private keyName: MaybeG String
      ipsEntityName = PointerT @private entityName: MaybeG String
      ipsRecordName = PointerT @private recordName: MaybeG String
      ipoSchema = PointerT @private schema: MaybeG Object

      # Endpoint.keyNames ?= {}
      # Endpoint.itemEntityNames ?= {}
      # Endpoint.listEntityNames ?= {}
      # Endpoint.itemSchemas ?= {}
      # Endpoint.listSchemas ?= {}

      @public keyName: String,
        get: ->
          keyName = @[ipsKeyName] ? @[ipsEntityName]
          Endpoint.keyNames[keyName] ?= inflect.singularize inflect.underscore keyName

      @public itemEntityName: String,
        get: -> Endpoint.itemEntityNames[@[ipsEntityName]] ?= inflect.singularize inflect.underscore @[ipsEntityName]

      @public listEntityName: String,
        get: -> Endpoint.listEntityNames[@[ipsEntityName]] ?= inflect.pluralize inflect.underscore @[ipsEntityName]

      @public schema: JoiT,
        get: -> @[ipoSchema]

      @public listSchema: JoiT,
        get: ->
          Endpoint.listSchemas["#{@[ipsEntityName]}|#{@[ipsRecordName]}"] ?= joi.object {
            meta: joi.object()
            "#{@listEntityName}": joi.array().items @schema
          }

      @public itemSchema: JoiT,
        get: ->
          Endpoint.itemSchemas["#{@[ipsEntityName]}|#{@[ipsRecordName]}"] ?= joi.object "#{@itemEntityName}": @schema

      @public keySchema: JoiT,
        default: joi.string().required().description 'The key of the objects.'

      @public querySchema: JoiT,
        default: joi.string().empty('{}').optional().default '{}', '
          The query for finding objects.
        '

      @public executeQuerySchema: JoiT,
        default: joi.object(query: joi.object().required()).required(), '
          The query for execute.
        '

      @public bulkResponseSchema: JoiT,
        default: joi.object success: joi.boolean()

      @public versionSchema: JoiT,
        default: joi.string().required().description '
          The version of api endpoint in semver format `^x.x`
        '

      @public ApplicationModule: SubsetG(Module),
        get: -> @gateway?.ApplicationModule ? @Module

      @public init: FuncG(InterfaceG(gateway: GatewayInterface)),
        default: (args...) ->
          @super args...
          [ options ] = args
          { keyName, entityName, recordName } = options
          @[ipsKeyName] = keyName
          @[ipsEntityName] = entityName
          @[ipsRecordName] = recordName
          if recordName? and _.isString recordName
            recordName = inflect.camelize recordName
            recordName += 'Record'  unless /Record$/.test recordName
            voSchema = @gateway?.getSchema recordName
            voSchema ?= (@ApplicationModule.NS ? @ApplicationModule::)[recordName].schema
            @[ipoSchema] = voSchema
          @[ipoSchema] ?= joi.object()
          return


      @initializeMixin()
