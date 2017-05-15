# класс Resource нужен чтобы от него инстанцировать прокси ресурсов в клиентских ядрах с нужным миксином (например с использованием HttpCollectionMixin)
# в HttpClient будет использоваться HttpCollectionMixin для подмешивания к Resource'ам
# работающий модуль внутри себя будет инициализировать клиентское ядро нужного стороннего сервиса, а за взаимодействие между ядрами внутри некоторого модуля будет отвечать глобальный медиатор с пайпами (pipes)

###
```coffee

```
###

module.exports = (Module)->
  class Resource extends Module::Collection
    @inheritProtected()
    @module Module


  Resource.initialize()
