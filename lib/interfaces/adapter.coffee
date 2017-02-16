
module.exports = (FoxxMC)->
  Interface  = require('../Interface') FoxxMC
  StoreInterface = require './store'
  SnapshotInterface = require './snapshot'
  QueryInterface = require './query'
  CursorInterface = require './cursor'
  {SELF, NILL, ANY, CLASS} = require('../Constants') FoxxMC

  class FoxxMC::AdapterInterface extends Interface
    @public defaultSerializer: String # ['-arangodb', '-mongodb', '-rest']

    @public generateIdForRecord: Function, [], -> return: [String, NILL]

    # proxies serializer work
    @public serialize:    Function
    ,
      [
        snapshot: SnapshotInterface
      ,
        options: Object
      ]
    , ->
      return: Object

    @public @virtual insertRecord: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        snapshot: SnapshotInterface
      ]
    , ->
      return: Object
    @public @virtual destroyRecord: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        snapshot: SnapshotInterface
      ]
    , ->
      return: NILL
    @public @virtual updateRecord: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        snapshot: SnapshotInterface
      ]
    , ->
      return: Object
    @public @virtual findRecord: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        query: QueryInterface
      ]
    , ->
      return: Object
    @public @virtual insertMany: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        snapshots: Array
      ]
    , ->
      return: CursorInterface
    @public @virtual destroyMany: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        query: QueryInterface
      ]
    , ->
      return: NILL
    @public @virtual updateMany: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        query: QueryInterface
      ,
        data: Object
      ]
    , ->
      return: CursorInterface
    @public @virtual findMany: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        query: QueryInterface
      ]
    , ->
      return: CursorInterface

    @public @virtual query: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        query: QueryInterface
      ]
    , ->
      return: ANY
    @public @virtual copy: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        snapshot: SnapshotInterface
      ]
    , ->
      return: Object
    @public @virtual deepCopy: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        snapshot: SnapshotInterface
      ]
    , ->
      return: Object
    @public @virtual map: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        lambda: Function
      ]
    , ->
      return: CursorInterface
    @public @virtual forEach: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        lambda: Function
      ]
    , ->
      return: NILL
    @public @virtual reduce: Function
    ,
      [
        store: StoreInterface
      ,
        type: CLASS
      ,
        lambda: Function
      ,
        initial: ANY
      ]
    , ->
      return: ANY

  FoxxMC::AdapterInterface.initialize()
