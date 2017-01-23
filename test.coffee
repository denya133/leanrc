class CoreObject
  @defineGetter: (Class, aName, aGetter)->
    if aName.constructor.name is 'Symbol'
      vSymbol = aName
      [vSource, v1, aName, v2] = String(vSymbol).match /(^.*\()(.*)(\)$)/
    else
      vSymbol = Symbol.for aName
    aGetter ?= -> @[vSymbol]
    @::__defineGetter__ aName, aGetter
    return

  @defineSetter: (Class, aName, aSetter)->
    if aName.constructor.name is 'Symbol'
      vSymbol = aName
      [vSource, v1, aName, v2] = String(vSymbol).match /(^.*\()(.*)(\)$)/
    else
      vSymbol = Symbol.for aName
    aSetter ?= (aValue)->
      if aValue.constructor isnt Class
        throw new Error 'not acceptable type'
        return
      @[vSymbol] = aValue
    @::__defineSetter__ aName, aSetter
    return

  @defineAccessor: (Class, aName, aGetter, aSetter)->
    @defineGetter Class, aName, aGetter
    @defineSetter Class, aName, aSetter
    return


class Person extends CoreObject
  ipsFirstName      = Symbol 'firstName'
  ipsLastName       = Symbol 'lastName'
  ipmCalculateSize  = Symbol 'calculateSize'

  @defineAccessor   String, ipsFirstName
  @defineSetter     String, ipsLastName

  # example of private method definition
  @instanceMethod ipmCalculateSize, ->

  # example of public method definition (special glyphs not need)
  mixVegetables: ->

  constructor: (aOptions={})->
    @[ipsFirstName]    = aOptions.firstName if aOptions.firstName?
    @[ipsLastName]     = aOptions.lastName if aOptions.lastName?


class Teacher extends Person
  ipoSomePerson = Symbol 'somePerson'

  @defineAccessor Person, ipoSomePerson

  constructor: (aOptions={})->
    super
    @[ipoSomePerson]   = aOptions.somePerson


vTeacher = new Teacher
  firstName: 'denya'
  lastName: 'T'
  somePerson: new Person(firstName: 'glum')

console.log vTeacher.firstName
vTeacher.firstName = 'denya1'
console.log vTeacher.firstName
console.log vTeacher
