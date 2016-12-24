_             = require 'lodash'
joi           = require 'joi'
{ db }        = require '@arangodb'
qb            = require 'aqb'
CoreObject    = require './CoreObject'
Cursor        = require './Cursor'
lowerCase     = require 'lower-case'
moment        = require 'moment'

reservedKeys = [
  'ids'
  '_id'
  'set_filter'
  'sort'
  'offset'
  'limit'
  'page'
  'c'
  'f', 'fields'
  'op', 'operators'
  'v', 'values'
]

MS_PER_DAY = 24 * 60 * 60 * 1000

operatorsShortMap = [ # просто чтобы долго не листать полный список
  '{>[]}' # attr value contains in some array
  '{!>[]}' # attr value not contains in some array
  '{=}' # equal
  '{!}' # not equal
  '{*}' # all
  '{!*}' # none
  '{>=}' # greater than or equal
  '{<=}' # less than or equal
  '{>}' # greater than
  '{<}' # less than
  '{><}' # between
  '{~}' # contains
  '{!~}' # does not contain
  '{t}' # today
  '{ld}' # yesterday
  '{t+}' # = today + n days
  '{>t+}' # >= today + n days
  '{<t+}' # <= today + n days
  '{><t+}' # between today and today + n days
  '{t-}' # = n days in past
  '{>t-}' # >= today - n days
  '{<t-}' # <= today - n days
  '{><t-}' # between today - n days an today
  '{w}' # this week
  '{lw}' # last week
  '{l2w}' # last two weeks
  '{m}' # this month
  '{lm}' # last month
  '{y}' # this year
  '{o}' # open (only for field values 'open'/'closed')
  '{c}' # closed (only for field values 'open'/'closed')
]

normalizedOperators = [
  '{>[]}' # attr value contains in some array
  '{!>[]}' # attr value not contains in some array
  '{=}' # equal
  '{!}' # not equal
  '{*}' # all
  '{!*}' # none
  '{>=}' # greater than or equal
  '{<=}' # less than or equal
  '{>}' # greater than
  '{<}' # less than
  '{><}' # between
  '{~}' # contains
  '{!~}' # does not contain
]

class Query extends CoreObject
  @operatorMap:
    # equal ids
    '{>[]}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      condition: "#{attrForComparison} IN @#{field}"
      bindings:
        "#{field}": values
    # not equal ids
    '{!>[]}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      condition: "#{attrForComparison} NOT IN @#{field}"
      bindings:
        "#{field}": values
    # equal
    '{=}': (field, values)->
      console.log '$$$$$$$$$$$$$$$$$$$$$LLLLLLLLLLLLNNNNNNNNNNNNNNNNNNNNNNNNNNNNN', (prop = @Model.properties()[field])?
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      condition: "#{attrForComparison} == @#{field}"
      bindings:
        "#{field}": values[0]
    # not equal
    '{!}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      condition: "#{attrForComparison} != @#{field}"
      bindings:
        "#{field}": values[0]
    # # all
    # '*': (field, values)->
    #   result = {}
    #   result[field] = $exists: yes, $nin: [ null ]
    #   result
    # # none
    # '!*': (field, values)->
    #   result = {}
    #   result[field] = $exists: no
    #   result
    # greater than or equal
    '{>=}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      condition: "#{attrForComparison} >= @#{field}"
      bindings:
        "#{field}": values[0]
    # greater than
    '{>}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      condition: "#{attrForComparison} > @#{field}"
      bindings:
        "#{field}": values[0]
    # less than or equal
    '{<=}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      condition: "#{attrForComparison} <= @#{field}"
      bindings:
        "#{field}": values[0]
    # less than
    '{<}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      condition: "#{attrForComparison} < @#{field}"
      bindings:
        "#{field}": values[0]
    # between
    '{><}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      condition: "@#{field}_1 < #{attrForComparison} && #{attrForComparison} < @#{field}_2"
      bindings:
        "#{field}_1": values[0]
        "#{field}_2": values[1]
    # contains
    '{~}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      condition: "LOWER(#{attrForComparison}) LIKE @#{field}"
      bindings:
        "#{field}": "%#{lowerCase values[0]}%"
      # result = {}
      # result[field] = new RegExp(escapeRegExp(values[0]), 'ig')
      # result
    # does not contain
    '{!~}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      condition: "LOWER(#{attrForComparison}) NOT LIKE @#{field}"
      bindings:
        "#{field}": "%#{lowerCase values[0]}%"
      # result = {}
      # result[field] = new RegExp(notContaing(escapeRegExp(values[0])), 'ig')
      # result
    # today
    '{t}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      todayStart = moment().startOf 'day'
      todayEnd = moment().endOf 'day'
      condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
      bindings:
        "#{field}_1": todayStart.toISOString()
        "#{field}_2": todayEnd.toISOString()
    # yesterday
    '{ld}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      yesterdayStart = moment().subtract(1, 'days').startOf 'day'
      yesterdayEnd = moment().subtract(1, 'days').endOf 'day'
      condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
      bindings:
        "#{field}_1": yesterdayStart.toISOString()
        "#{field}_2": yesterdayEnd.toISOString()
    # = today + n days
    '{t+}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      days = parseInt values[0], 10
      unless isNaN days
        dayStart = moment().add(days, 'days').startOf 'day'
        dayEnd = dayStart.clone().add 1, 'days'
        result =
          condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
          bindings:
            "#{field}_1": dayStart.toISOString()
            "#{field}_2": dayEnd.toISOString()
      result
    # >= today + n days
    '{>t+}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      days = parseInt values[0], 10
      unless isNaN days
        dayStart = moment().add(days, 'days').startOf 'day'
        result =
          condition: "#{attrForComparison} >= @#{field}"
          bindings:
            "#{field}": dayStart.toISOString()
      result
    # <= today + n days
    '{<t+}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      days = parseInt values[0], 10
      unless isNaN days
        dayEnd = moment().add(days, 'days').endOf 'day'
        result =
          condition: "#{attrForComparison} < @#{field}"
          bindings:
            "#{field}": dayEnd.toISOString()
      result
    # between today and today + n days
    '{><t+}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      days = parseInt values[0], 10
      unless isNaN days
        today = moment().startOf 'day'
        dayEnd = today.clone().endOf 'day'
        result =
          condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
          bindings:
            "#{field}_1": today.toISOString()
            "#{field}_2": dayEnd.toISOString()
      result
    # = n days in past
    '{t-}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      days = parseInt values[0], 10
      unless isNaN days
        dayStart = moment().subtract(days, 'days').startOf 'day'
        dayEnd = dayStart.clone().endOf 'day'
        result =
          condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
          bindings:
            "#{field}_1": dayStart.toISOString()
            "#{field}_2": dayEnd.toISOString()
      result
    # >= today - n days
    '{>t-}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      days = parseInt values[0], 10
      unless isNaN days
        firstStart = moment().subtract(days, 'days').startOf 'day'
        result =
          condition: "#{attrForComparison} => @#{field}"
          bindings:
            "#{field}": firstStart.toISOString()
      result
    # <= today - n days
    '{<t-}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      days = parseInt values[0], 10
      unless isNaN days
        firstEnd = moment().substract(days, 'days').startOf 'day'
        result =
          condition: "#{attrForComparison} < @#{field}"
          bindings:
            "#{field}": firstEnd.toISOString()
      result
    # between today - n days an today
    '{><t-}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      days = parseInt values[0], 10
      unless isNaN days
        today = moment().startOf 'day'
        firstStart = today.clone().subtract days, 'days'
        todayEnd = today.clone().endOf 'day'
        result =
          condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
          bindings:
            "#{field}_1": firstStart.toISOString()
            "#{field}_2": todayEnd.toISOString()
      result
    # this week
    '{w}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      weekStart = moment().startOf 'week'
      weekEnd = moment().endOf 'week'
      result =
        condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
        bindings:
          "#{field}_1": weekStart.toISOString()
          "#{field}_2": weekEnd.toISOString()
      result
    # last week
    '{lw}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      weekStart = moment().subtract(1, 'weeks').startOf 'week'
      weekEnd = weekStart.clone().endOf 'week'
      result =
        condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
        bindings:
          "#{field}_1": weekStart.toISOString()
          "#{field}_2": weekEnd.toISOString()
      result
    # last two weeks
    '{l2w}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      weeksStart = moment().subtract(2, 'weeks').startOf 'week'
      weeksEnd = weeksStart.clone().endOf 'week'
      result =
        condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
        bindings:
          "#{field}_1": weeksStart.toISOString()
          "#{field}_2": weeksEnd.toISOString()
      result
    # this month
    '{m}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      firstDayStart = moment().startOf 'month'
      lastDayEnd = moment().endOf 'month'
      result =
        condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
        bindings:
          "#{field}_1": firstDayStart.toISOString()
          "#{field}_2": lastDayEnd.toISOString()
      result
    # last month
    '{lm}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      firstDayStart = moment().subtract(1, 'months').startOf 'month'
      lastDayEnd = firstDayStart.clone().endOf 'month'
      result =
        condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
        bindings:
          "#{field}_1": firstDayStart.toISOString()
          "#{field}_2": lastDayEnd.toISOString()
      result
    # this year
    '{y}': (field, values)->
      attrForComparison = if (prop = @Model.properties()[field])?
        prop.filterable ? field
      else
        "doc.#{field}"
      result = null
      firstDayStart = moment().startOf 'year'
      lastDayEnd = firstDayStart.clone().endOf 'year'
      result =
        condition: "@#{field}_1 <= #{attrForComparison} && #{attrForComparison} < @#{field}_2"
        bindings:
          "#{field}_1": firstDayStart.toISOString()
          "#{field}_2": lastDayEnd.toISOString()
      result



  Model: null
  _ops: null

  constructor: ()->
    @where.params = []
    @let.beforeWhereParams = []
    @let.afterWhereParams = []
    @let.afterCollectParams = []
    @sort.params = []
    @sort.afterCollectParams = []
    @select.params = null
    @limit.params = null
    @group.params = null
    @aggregate.params = null
    @into.params = null
    @having.params = []
    @having.joins = []
    @joins.params = []
    @from.params = null
    @includes.params = []
    @count.params = null
    @distinct.params = null
    @average.params = null
    @minimum.params = null
    @maximum.params = null
    @sum.params = null
    @pluck.params = null

    @__customFilters ?= {}
    @_customFilters ?= []
    opKeys = Object.keys @constructor.operatorMap
    opKeys.sort (a, b)->
      b.length - a.length
    @_ops = new RegExp "^(#{ opKeys.map((str)->str.replace(/[\+\-\*\{\}\[\]]/g, '\\$&')).join '|' })", 'ig'
    return

  setCustomFilters: (config)->
    for own key, value of config
      do (field = key, operatorsMap = value)=>
        @_customFilters.push field
        for own _key, _value of operatorsMap
          do (op = _key, func = _value)=>
            @__customFilters["#{field}:#{op}"] = func
    return @

  model: (Model)->
    @Model = Model
    @setCustomFilters @Model._customFilters()
    return @

  currentUser: (currentUser = null)->
    @__currentUser = currentUser
    return @

  includes: (definitions)->
    # в exec не реализовано его использование, т.к. довольно тяжело реализовать такую абстрактуню логику обертывания.
    definitions = [definitions] if definitions.constructor is String
    @includes.params = _.uniq @includes.params.concat definitions
    return @

  from: (collectionName)->
    @from.params = collectionName
    return @

  joins: (definitions)->
    @joins.params.push definitions
    return @

  for: (variable)->
    if variable is 'doc'
      throw new Error 'variable in `for` method must not be `doc` (`doc` is reserved keyword)'
    in: (collection)=>
      unless @group.params?
        @joins.params.push "#{variable}": collection
      else
        @having.joins.push "#{variable}": collection
      return @

  where: (conditions, bindings=null)->
    @where.params.push {conditions, bindings}
    return @

  filter: ->
    unless @group.params?
      @where arguments...
    else
      @having arguments...

  let: (definition, bindings=null)->
    if @where.params.length is 0
      console.log '????MMMMM definition, bindings', definition, bindings
      @let.beforeWhereParams.push {definition, bindings}
    else unless @group.params?
      @let.afterWhereParams.push {definition, bindings}
    else
      @let.afterCollectParams.push {definition, bindings}
    return @

  group: (definition)->
    @group.params ?= {}
    @group.params = _.merge @group.params, (definition ? {})
    return @

  collect: ->
    @group arguments...

  aggregate: (definition)->
    @aggregate.params = definition
    return @

  into: (variable)->
    @into.params = variable
    return @

  having: (conditions, bindings=null)->
    @having.params.push conditions: conditions, bindings: bindings
    return @

  sort: (definition)->
    unless @group.params?
      @sort.params.push definition
    else
      @sort.afterCollectParams.push definition
    return @

  limit: (args...)->
    @limit.params = args
    return @

  distinct: ()->
    @distinct.params = yes
    return @

  select: (fields)->
    @select.params = fields
    return @exec()

  return: ->
    @select arguments...

  pluck: (field)->
    @pluck.params = field
    return @exec()

  count: ()->
    @count.params = yes
    return @exec()

  length: ()->
    @count()

  average: (field)->
    @average.params = field
    return @exec()

  avg: (field)->
    @average field

  minimum: (field)->
    @minimum.params = field
    return @exec()

  min: (field)->
    @minimum field

  maximum: (field)->
    @maximum.params = field
    return @exec()

  max: (field)->
    @maximum field

  sum: (field)->
    @sum.params = field
    return @exec()

  isRecordsReturn: ()->
    # console.log '$$$$$$$$$$$$$ isRecordsReturn', (not @from.params? or (@from.params? and @from.params is @Model.collectionName()))
    res = Object.keys(@group.params ? {}).length is 0 and
      @having.params.length is 0 and
      not @pluck.params? and (
        not @select.params? or (
          @select.params? and @select.params in ['*', 'doc']
        )
      ) and (
        not @from.params? or (
          @from.params? and @from.params is @Model.collectionName()
        )
      ) and
      not @isAggregate()
    # console.log '??????????????????>>>>>>>>>>>>>>> @isAggregate()', @isAggregate()
    res

  isSingleReturnResult: ()->
    @limit.params is 1 or
      @count.params? or
      @average.params? or
      @minimum.params? or
      @maximum.params? or
      @sum.params?

  isAggregate: ()->
    @count.params? or
      @average.params? or
      @minimum.params? or
      @maximum.params? or
      @sum.params?

  query: (query)->
    @_query = query
    @parseQuery()
    @updateOptions()
    @updateConditions()
    @callCustomFilters()
    @_query =     null
    @_fields =    null
    @_operators = null
    @_values =    null
    return @

  serializeFromClient: (fieldName, value)->
    if (prop_opts = @Model.properties()?[fieldName])?
      prop_opts.serializeFromClient value
    else
      value

  normalizeFieldValue: (fieldName, value, needNormalize = no) ->
    @serializeFromClient fieldName, unless needNormalize
      value
    else if (serializableAttributes = @Model.serializableAttributes())?
      fieldSchema = try
        joi.reach serializableAttributes, fieldName
      catch
        serializableAttributes[fieldName]
      switch fieldSchema?._type
        when 'boolean'
          "#{value}".toLowerCase() in [ 'true', 'yes', 'on' ]
        when 'number'
          +value
        when 'date'
          unless isNaN +value
            new Date(+value).toISOString()
          else
            new Date(value).toISOString()
        else
          value
    else
      value

  parseQuery: ()->
    fields = []
    operators = {}
    values = {}
    fields = Object.keys(@_query).filter (item)->
      item not in reservedKeys
    fields.forEach (field)=>
      rawValue = @_query[field]
      match = if rawValue.match?
        (rawValue.match @_ops) ? [ '{=}' ]
      else
        [ '{=}' ]
      operator = match[0]
      if operator?
        needNormalize = operator in normalizedOperators
        operators[field] = operator
        valuesArray = if rawValue.replace?
          rawValue.replace(@_ops, '').split '|'
        else
          [rawValue]
        values[field] = valuesArray.map (value) =>
          @normalizeFieldValue field, value, needNormalize
      return
    @_fields = fields
    @_operators = operators
    @_values = values

  updateOptions: ()->
    @limit.params = [@_query.offset, @_query.limit] if @_query.offset? and @_query.limit?
    @limit.params = [0, @_query.limit] if @_query.limit? and not @_query.offset?
    if @_query.sort?
      sortParameters = @_query.sort.split(',').map (item)->
        pair = item.split ':'
        unless pair[0]?
          pair = null
        else
          pair[1] = if pair[1] is 'desc' then 'DESC' else 'ASC'
        pair
      .filter (item)->
        item?
      if sortParameters.length > 0
        sortParameters.forEach (item)=>
          unless item[0] in @_customFilters
            attrForSorting = if (prop = @Model.properties()[item[0]])?
              prop.sortable ? item[0]
            else
              "doc.#{item[0]}"
            @sort.params.push "#{attrForSorting} #{item[1]}"
          return
    return

  updateConditions: ()->
    @_fields.forEach (field)=>
      valueArray = @_values[field] ? []
      operator = @_operators[field]
      if operator?
        unless field in @_customFilters
          operation = @constructor.operatorMap[operator]
          if operation?
            if (_filter = operation.apply @, [field, valueArray])?
              {condition, bindings} = _filter
              @where.params.push conditions: condition, bindings: bindings if condition? and bindings?
              @where.params.push conditions: condition if condition? and not bindings?
      return
    if @_query.ids?
      ids = @_query.ids
      unless Array.isArray ids
        ids = ids.split '|'
      do ({condition, bindings} = @constructor.operatorMap['{>[]}'].apply @, ['_key', ids])=>
        @where.params.push conditions: condition, bindings: bindings if condition? and bindings?
        @where.params.push conditions: condition if condition? and not bindings?
    return

  callCustomFilters: ()->
    @_fields.forEach (field)=>
      valueArray = @_values[field] ? []
      op = @_operators[field]
      if (func = @__customFilters["#{field}:#{op}"])?
        {condition, bindings} = func?([valueArray]...) ? {}
        @where.params.push conditions: condition, bindings: bindings if condition? and bindings?
        @where.params.push conditions: condition if condition? and not bindings?
      return

  execute: ()->
    @exec arguments...

  exec: ()->
    unless @Model?
      throw new Error 'Model must be defined'
      return
    bindings = {}
    # console.log 'DDDDDDDDDDD<<<<<<<<<<<<<<<<<<<<< @from.params', @from.params
    query = qb.for qb.ref 'doc'
      .in if @from.params? then "#{@Model.collectionPrefix()}#{@from.params}" else @Model.collectionNameInDB()
    @joins.params.forEach (joins)=>
      for own k, v of joins
        do (k, v)=>
          query = query.for(k).in("#{@Model.collectionNameInDB v}")
    valuables = Object.keys(@Model.properties()).filter (prop)=> @Model.properties()[prop].valuable?
    @includes.params = _.uniq @includes.params.concat valuables
    @includes.params.forEach (prop)=>
      if @Model._props()?[prop]? and @Model._props()[prop].type is 'item'
        query = query.let prop, qb.expr @Model._props()[prop].definition
        if @Model._props()[prop].bindings?
          _.merge bindings, @Model._props()[prop].bindings
    @let.beforeWhereParams.forEach ({definition, bindings:_bindings})->
      console.log '????????????????????^^^^^^^^^^^666 _bindings', _bindings
      if _bindings?
        _.merge bindings, _bindings
      if definition.constructor is String
        _let = qb.expr definition
      else if definition.constructor is Object
        _let = _.mapValues definition, (value)->
          if value.constructor is qb.expr('').constructor
            value
          else
            qb.expr value
      else
        _let = definition
      query = query.let _let
    @where.params.forEach (where)=>
      if where.bindings?
        _.merge bindings, where.bindings
      if where.conditions.constructor is String
        filter = qb.expr where.conditions
      else if where.conditions.constructor is Object
        filters = for own k, v of where.conditions
          do (k, v)=>
            qb.eq qb.ref(if @includes.params.includes(k) then k else "doc.#{k}"), qb v
        filter = qb.and filters...
      else if where.conditions.constructor.name in ['Number', 'Date', 'Boolean', 'Array']
        throw new Error 'conditions must be String or Object or AQB definition'
      else
        filter = where.conditions
      query = query.filter filter

    totalQuery = query
    totalQuery = totalQuery.collectWithCountInto 'counter'
      .return qb.ref('counter').then('counter').else('0')

    @let.afterWhereParams.forEach ({definition, bindings:_bindings})->
      if _bindings?
        _.merge bindings, _bindings
      if definition.constructor is String
        _let = qb.expr definition
      else if definition.constructor is Object
        _let = _.mapValues definition, (value)->
          if value.constructor is qb.expr('').constructor
            value
          else
            qb.expr value
      else
        _let = definition
      query = query.let _let

    if @sort.params.length
      query = query.sort qb.expr @sort.params.join ', '
    if @limit.params?
      query = query.limit @limit.params...
    if Object.keys(@group.params ? {}).length > 0
      query = query.collect @group.params
    if @aggregate.params?
      aggregateFindPartial = _.escapeRegExp "FILTER {{AGGREGATE #{@aggregate.params}}}"
      if Object.keys(@group.params ? {}).length > 0
        aggregatePartial = "AGGREGATE #{@aggregate.params}"
      else
        aggregatePartial = "COLLECT AGGREGATE #{@aggregate.params}"
      query = query.filter qb.expr "{{AGGREGATE #{@aggregate.params}}}"
    if @into.params?
      intoFindPartial = _.escapeRegExp "FILTER {{INTO #{@into.params}}}"
      intoPartial = "INTO #{@into.params}"
      query = query.filter qb.expr "{{INTO #{@into.params}}}"

    @let.afterCollectParams.forEach ({definition, bindings:_bindings})->
      if _bindings?
        _.merge bindings, _bindings
      if definition.constructor is String
        _let = qb.expr definition
      else if definition.constructor is Object
        _let = _.mapValues definition, (value)->
          if value.constructor is qb.expr('').constructor
            value
          else
            qb.expr value
      else
        _let = definition
      query = query.let _let

    @having.joins.forEach (joins)=>
      for own k, v of joins
        do (k, v)=>
          query = query.for(k).in("#{@Model.collectionNameInDB v}")

    @having.params.forEach (having)=>
      if having.bindings?
        _.merge bindings, having.bindings
      if having.conditions.constructor is String
        filter = qb.expr having.conditions
      else if having.conditions.constructor is Object
        filters = for own k, v of having.conditions
          do (k, v)->
            qb.eq qb.ref(k), qb v
        filter = qb.and filters...
      else if having.conditions.constructor.name is 'BinaryOperation'
        filter = having.conditions
      else
        throw new Error 'conditions must be String or Object or AQB definition'
      query = query.filter filter

    if @sort.afterCollectParams.length
      query = query.sort qb.expr @sort.afterCollectParams.join ', '

    if @isAggregate()
      if @count.params?
        query = query.collectWithCountInto 'counter'
          .return qb.ref('counter').then('counter').else('0')
      if @average.params?
        finallyAggregateFindPartial = "RETURN {{COLLECT AGGREGATE result = AVG\\(TO_NUMBER\\(doc.#{@average.params}\\)\\) RETURN result}}"
        finallyAggregatePartial = "COLLECT AGGREGATE result = AVG(TO_NUMBER(doc.#{@average.params})) RETURN result"
        query = query.return qb.expr "{{COLLECT AGGREGATE result = AVG(TO_NUMBER(doc.#{@average.params})) RETURN result}}"
      if @sum.params?
        finallyAggregateFindPartial = "RETURN {{COLLECT AGGREGATE result = SUM\\(TO_NUMBER\\(doc.#{@sum.params}\\)\\) RETURN result}}"
        finallyAggregatePartial = "COLLECT AGGREGATE result = SUM(TO_NUMBER(doc.#{@sum.params})) RETURN result"
        query = query.return qb.expr "{{COLLECT AGGREGATE result = SUM(TO_NUMBER(doc.#{@sum.params})) RETURN result}}"
      if @minimum.params?
        query = query.sort "doc.#{@minimum.params}"
          .limit 1
          .return "doc.#{@minimum.params}"
      if @maximum.params?
        query = query.sort "doc.#{@maximum.params}", 'DESC'
          .limit 1
          .return "doc.#{@maximum.params}"
    else
      if @pluck.params?
        if @distinct.params
          query = query.returnDistinct "doc.#{@pluck.params}"
        else
          query = query.return "doc.#{@pluck.params}"
      else if @select.params?
        if @select.params.constructor is String
          if @select.params in ['*', 'doc']
            if @includes.params.length
              extentions = @includes.params.map (i)->
                "__#{i}: #{i}"
              query = query.let 'extended_doc', qb.expr "MERGE(doc, {#{extentions.join ', '}})"
              _select_params = 'extended_doc'
            else
              _select_params = 'doc'
          else
            _select_params = @select.params
          if @distinct.params
            query = query.returnDistinct qb.expr _select_params
          else
            query = query.return qb.expr _select_params
        else if @select.params.constructor is Array
          obj = {}
          @select.params.forEach (k)->
            obj["#{k}"] = qb.ref "doc.#{k}"
          if @distinct.params
            query = query.returnDistinct qb.obj obj
          else
            query = query.return qb.obj obj
        else if @select.params.constructor.name is 'Identifier'
          if @distinct.params
            query = query.returnDistinct @select.params
          else
            query = query.return @select.params
        else
          console.log 'select !!!!!!!!!!!!!!?????????????', @select.params.constructor.name
          throw new Error 'select must be String or Array or AQB definition'
      else
        if @includes.params.length
          extentions = @includes.params.map (i)->
            "__#{i}: #{i}"
          query = query.let 'extended_doc', qb.expr "MERGE(doc, {#{extentions.join ', '}})"
          query = query.return 'extended_doc'
        else
          query = query.return 'doc'

    query = query.toAQL()

    if aggregateFindPartial and new RegExp(aggregateFindPartial).test query
      query = query.replace new RegExp(aggregateFindPartial), aggregatePartial
    if intoFindPartial and new RegExp(intoFindPartial).test query
      query = query.replace new RegExp(intoFindPartial), intoPartial
    if finallyAggregateFindPartial and new RegExp(finallyAggregateFindPartial).test query
      query = query.replace new RegExp(finallyAggregateFindPartial), finallyAggregatePartial
    console.log '$$$$$$$$$$$$$$??????????????????? query', query, bindings
    console.log '$$$$$$$$$$$$$$??????????????????? totalQuery', totalQuery.toAQL(), bindings

    total = db._query(totalQuery.toAQL(), bindings).toArray()[0]
    console.log '$$$$$$$$$$$$$$??????????????????? totalQuery total', total
    result = db._query query, bindings

    if @isSingleReturnResult()
      console.log '%#$%EFFSDF$%#$%SDAF$#$111'
      result = result.toArray()[0]
      if @isRecordsReturn()
        console.log '%#$%EFFSDF$%#$%SDAF$#$222'
        result = @Model.new result, @__currentUser
      else
        result
    else
      # console.log '$$$$$$$$$$$$$ !!!! isRecordsReturn', @isRecordsReturn()
      if @isRecordsReturn()
        console.log '%#$%EFFSDF$%#$%SDAF$#$333'
        if @limit.params?
          if @limit.params.length is 1
            _limit = @limit.params[0]
            _offset = 0
          else
            _limit = @limit.params[1]
            _offset = @limit.params[0]
        else
          _limit = null
          _offset = null
        new Cursor(@Model).currentUser(@__currentUser).setTotal(total).setLimit(_limit).setOffset(_offset).setCursor result
      else
        console.log '%#$%EFFSDF$%#$%SDAF$#$!!!!!'
        result

module.exports = Query.initialize()

# query users { "email": "denya@saifas.com" }

# query users { "ids": ["admin", "5aa055e2-6a53-4868-9b61-4cfa885164ef"] }

# query users { "ids": ["admin", "5aa055e2-6a53-4868-9b61-4cfa885164ef"], "email": "denya@saifas.com" }

# query users { "offset": 10, "limit": 10 }

# query referrals { "email": "denya@saifas.com" }

# query publications { "type": "adz" }
# query publications { "type": "recipe" }
# query publications { "url": "{~}drive" }
# query publications { "_adz_owner": "{!}c44bb24d-9264-4426-ae87-220a2d7abe95" }

# query user_earnings { "accountToId": "e23fef41-5f97-4881-8237-a67c08182324" }
# query user_earnings { "accountToId": "admin" }

# query adzs { "ownerId": "f4004050-2c95-4a7b-b970-8d4d08b50cbf" }
# query adzs { "ownerId": "f4004050-2c95-4a7b-b970-8d4d08b50cbf" }

# query recipes { "ownerId": "f4004050-2c95-4a7b-b970-8d4d08b50cbf" }
# query recipes { "ownerId": "f4004050-2c95-4a7b-b970-8d4d08b50cbf" }

# query account_kinds { "id": "main" }
# query account_kinds { "type": "account_kind", "limit": 2, "offset": 1 }
