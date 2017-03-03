{SELF, NILL} = FoxxMC::Constants

# Здесь задекларировано как сейчас этот класс выглядит
# возможно большая часть этого останется и перейдет в финальный вариант
# Важно: в финале у инстанса не будет метода `exec` который есть сейчас, но будет метод `query` который будет вызываться извне, а в результате будет возвращатся объект с интерфейсом QueryObjectInterface , чтобы потом на основе этих данных конструировать на нужном языке запрос в базу данных


class FoxxMC::QueryObjectInterface extends FoxxMC::Interface
  @public @virtual where: Array
  @public @virtual letBeforeWhereParams: Array
  @public @virtual letAfterWhereParams: Array
  @public @virtual letAfterCollectParams: Array
  @public @virtual sort: Array
  @public @virtual sortAfterCollectParams: Array
  @public @virtual select: String
  @public @virtual limit: String
  @public @virtual group: String
  @public @virtual aggregate: String
  @public @virtual into: String
  @public @virtual having: Array
  @public @virtual havingJoins: Array
  @public @virtual joins: Array
  @public @virtual from: String
  @public @virtual includes: Array
  @public @virtual count: String
  @public @virtual distinct: String
  @public @virtual average: String
  @public @virtual minimum: String
  @public @virtual maximum: String
  @public @virtual sum: String
  @public @virtual pluck: String

  constructor: (
    {
      @where
      @letBeforeWhereParams
      @letAfterWhereParams
      @letAfterCollectParams
      @sort
      @sortAfterCollectParams
      @select
      @limit
      @offset
      @group
      @aggregate
      @into
      @having
      @havingJoins
      @joins
      @from
      @includes
      @count
      @distinct
      @average
      @minimum
      @maximum
      @sum
      @pluck
    } = {}
  )

class FoxxMC::QueryInterface extends FoxxMC::Interface
  # @public setCustomFilters: Function, [config], -> SELF # все равно объект будет передан в collection proxy и реальный запрос будет строиться уже там.
  # @public model: Function, [Class], -> SELF # все равно объект будет передан в collection proxy и реальный запрос будет строиться уже там.
  @public includes: Function, [definitions], -> SELF
  @public from: Function, [collectionName], -> SELF
  @public joins: Function, [definitions], -> SELF
  @public for: Function, [definitions], -> Object # {in: ->}
  @public where: Function, [conditions, [bindings, NILL]], -> SELF
  @public filter: Function, [conditions, [bindings, NILL]], -> SELF
  @public let: Function, [definition, [bindings, NILL]], -> SELF
  @public group: Function, [definition], -> SELF
  @public collect: Function, [definition], -> SELF
  @public aggregate: Function, [definition], -> SELF
  @public into: Function, [variable], -> SELF
  @public having: Function, [conditions, [bindings, NILL]], -> SELF
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
  @public min: Function, [field], -> SELF
  @public max: Function, [field], -> SELF
  @public sum: Function, [field], -> SELF
  @public setQuery: Function, [Object], -> SELF # query object (from browser)
  @public query: Function, [], -> QueryObjectInterface # query object for Collection Proxy
  # возможно есть смысл выровнять принимаемый объект из браузера и выходной объект для Collection Proxy

  @private parseQuery: Function, [], -> SELF
  @private updateOptions: Function, [], -> SELF
  @private updateConditions: Function, [], -> SELF
  @private callCustomFilters: Function, [], -> SELF
