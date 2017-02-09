class CoreObject


class Interface extends CoreObject
  # методы с такими же названиями будут объявлены в CoreObject
  # но реализоация у них будет другая. В Interface эти методы должны в специальные проперти положить результаты их вызовов при формировании классов-интерфейсов, однако реализация этих методов в CoreObject будет дефайнить реальные атрибуты и методы инстанса и самого класса. (своего рода перегрузка)
  @public: (typeDefinition, params, returnValue)->
    key = Object.keys(typeDefinition)[0]
    Type = typeDefinition[key]
    isFunction = Type is Function
    if isFunction
      functionArguments = params
      return {key, Type, functionArguments, returnValue}
    else
      defaultValue = params
      return {key, Type, defaultValue}

  @protected: (typeDefinition, params, returnValue)->
    # like public but outter objects does not get data or call methods
    # если ключ объявлен с использованием
    # `protected_key = Symbol.for('protected_key')`
    # то естественно он доступен и внутри текущего класса, т.к. указатель на него находится в зоне видимости методов класса (и инстанса класса).
    # но также в унаследованных классах есть возможность получить этот же Символ
    # чтобы обратиться к этому же проперти.
    # Плюсы в его использовании все же есть, т.к. protected дефиниция позволяет унаследованным классам переопределять свойства и методы родительского класса.
    throw new Error 'It is not been implemented yet'

  @private: (typeDefinition, params, returnValue)->
    # like public but outter objects does not get data or call methods
    # если ключ объявлен с использованием
    # `private_key = Symbol('private_key')`
    # то естественно он доступен ТОЛЬКО внутри текущего класса, т.к. уникальный указатель на него находится в зоне видимости методов класса (и инстанса класса).
    throw new Error 'It is not been implemented yet'


class CucumberInterface extends Interface

  @public color:              String,   'default'
  @public length:             Number,   90
  @public culculateSomeText:  Function, [String, String], -> null
  @protected processingColor: Function, [String],         -> String


class TomatoInterface extends Interface
  @public color:              String
  @public length:             Number
  @private cucumber:          CucumberInterface
  @protected processAmount:   Function, [], -> CucumberInterface

class Test
# обобщенное программирование
Test::CarrotInterface = (colorType = String)->
  class CarrotInterface extends Interface
    @public color:              colorType

class Carrot extends CoreObject
  @implements Test::CarrotInterface


class Cucumber extends CoreObject
  @implements CucumberInterface


class Tomato extends CoreObject
  @implements TomatoInterface

class Core
# обобщенное программирование
Core::ItemsInterface = (itemsType)->
  class ItemsInterface extends Interface
    @public items: itemsType

class CarrotsInterface extends Core::ItemsInterface Test::CarrotInterface()
  @public getItemByIndex:  Function, [Number], -> Test::CarrotInterface()

class Carrots extends CoreObject
  @implements Test::CarrotsInterface
