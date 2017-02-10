{SELF, NULL, ANY} = FoxxMC::Constants

# В InternalModel будут скрываться внутрение механизмы, в то время как Model будет внутри себя иметь ссылку на InternalModel-объект, выступая в качестве Proxy (т.к. все методы InternalModel она будет зеркально отображать на своем интерфейсе без добавления дополнительной функциональности)

class InternalModelInterface extends Interface
  @public modelClass: ModelClass
  @public id: String
  @public store: StoreInterface
  @public _data: ANY

  @public type: Function, [], -> ModelClass
  @public recordReference: Function, [], -> Object
  @public references: Function, [snapshot, options], -> Object
  @public record: Function, [], -> Object
  @public deleteRecord: Function, [], -> NULL
  # ... здесь еще много всяко-рзных методов.

class InternalModel extends CoreObject
  @implements InternalModelInterface
