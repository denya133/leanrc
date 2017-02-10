class AdapterInterface extends Interface
  @public defaultSerializer: String
  @public createRecord: Function, [store, type, snapshot],            -> data #
  @public deleteRecord: Function, [store, type, snapshot],            -> data #
  @public findAll:      Function, [store, type, snapshotRecordArray], -> data #
  @public findMany:     Function, [store, type, ids, snapshots],      -> data #
  @public findRecord:   Function, [store, type, id, snapshot],        -> data #
  @public query:        Function, [store, type, query, recordArray],  -> data #
  @public queryRecord:  Function, [store, type, query],               -> data
  @public serialize:    Function, [snapshot, options],                -> data
  @public updateRecord: Function, [store, type, snapshot],            -> data #

class Adapter extends CoreObject
  @implements AdapterInterface
