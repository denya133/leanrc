RC = require 'RC'

# класс Resource нужен чтобы от него инстанцировать прокси ресурсов в клиентских ядрах с нужным миксином (например с использованием HttpCollectionMixin)
# в HttpClient будет использоваться HttpCollectionMixin для подмешивания к Resource'ам
# работающий модуль внутри себя будет инициализировать клиентское ядро нужного стороннего сервиса, а за взаимодействие между ядрами внутри некоторого модуля будет отвечать глобальный медиатор с пайпами (pipes)

###
```coffee

```
###

module.exports = (LeanRC)->
  class LeanRC::Resource extends LeanRC::Collection
    @inheritProtected()
    # @implements LeanRC::ResourceInterface # может и не нужен

    @Module: LeanRC


  return LeanRC::Resource.initialize()
