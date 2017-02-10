{SELF, NULL} = FoxxMC::Constants

# Здесь задекларировано как сейчас этот класс выглядит
# возможно большая часть этого останется и перейдет в финальный вариант
# Важно: в финале у инстанса не будет метода `exec` который есть сейчас, но будет метод `getQueryObject` который будет вызывать адаптер, чтобы получить в виде json объекта результат работы класса Query, чтобы потом на основе этих данных конструировать на нужном языке запрос в базу данных

class FoxxMC::QueryInInterface extends FoxxMC::Interface
  @public in: Function, [collection], -> SELF

class FoxxMC::QueryObjectInterface extends FoxxMC::Interface
  @public where: Array
  @public letBeforeWhereParams: Array
  @public letAfterWhereParams: Array
  @public letAfterCollectParams: Array
  @public sort: Array
  @public sortAfterCollectParams: Array
  @public select: String
  @public limit: String
  @public group: String
  @public aggregate: String
  @public into: String
  @public having: Array
  @public havingJoins: Array
  @public joins: Array
  @public from: String
  @public includes: Array
  @public count: String
  @public distinct: String
  @public average: String
  @public minimum: String
  @public maximum: String
  @public sum: String
  @public pluck: String

class FoxxMC::QueryInterface extends FoxxMC::Interface
  @public setCustomFilters: Function, [config], -> SELF
  @public model: Function, [Class], -> SELF
  @public includes: Function, [definitions], -> SELF
  @public from: Function, [collectionName], -> SELF
  @public joins: Function, [definitions], -> SELF
  @public for: Function, [definitions], -> FoxxMC::QueryInInterface
  @public where: Function, [conditions, [bindings, NULL]], -> SELF
  @public filter: Function, [conditions, [bindings, NULL]], -> SELF
  @public let: Function, [definition, [bindings, NULL]], -> SELF
  @public group: Function, [definition], -> SELF
  @public collect: Function, [definition], -> SELF
  @public aggregate: Function, [definition], -> SELF
  @public into: Function, [variable], -> SELF
  @public having: Function, [conditions, [bindings, NULL]], -> SELF
  @public sort: Function, [definition], -> SELF
  @public limit: Function, [definition], -> SELF
  @public distinct: Function, [], -> SELF
  @public select: Function, [fields], -> SELF
  @public return: Function, [], -> SELF
  @public pluck: Function, [field], -> SELF
  @public count: Function, [], -> SELF
  @public length: Function, [], -> SELF
  @public average: Function, [field], -> SELF
  @public avg: Function, [field], -> SELF
  @public minimum: Function, [field], -> SELF
  @public min: Function, [field], -> SELF
  @public maximum: Function, [field], -> SELF
  @public max: Function, [field], -> SELF
  @public sum: Function, [field], -> SELF
  @public query: Function, [query], -> SELF
  @public getQueryObject: Function, [], -> FoxxMC::QueryObjectInterface

  @private parseQuery: Function, [], -> SELF
  @private updateOptions: Function, [], -> SELF
  @private updateConditions: Function, [], -> SELF
  @private callCustomFilters: Function, [], -> SELF

class FoxxMC::Query extends FoxxMC::CoreObject
  @implements FoxxMC::QueryInterface
