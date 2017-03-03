# комманда эквивалентная контролеру в рельсах
# в зависимости от сингала, будет запускаться нужный ресурс CucumbersResource
# а в зависимости от типа нотификейшена внутри инстанса ресурса
# будет выполняться нужный экшен (метод) create, update, detail, list, delete

# в случае со стрим-сервером заливку и отдачу файла будет реализовывать платформозависимый код медиатора, а ресурсная команда Uploads этим заниматься не будет. (чтобы медиатор напрямую писал в нужный прокси, и считывал поток так же напрямую из прокси.)

RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::ResourceInterface extends RC::Interface
    @inheritProtected()

    @Module: LeanRC

    @public @virtual Collection: RC::Class # like Model in FoxxMC::Controller

    # под вопросом
    @public @virtual query: Object
    @public @virtual body: Object
    @public @virtual recordId: String
    @public @virtual patchData: Object
    @public @virtual currentUser: RC::Constants.ANY


    @public @static @virtual actions: Function,
      args: []
      return: Array
    @public @static @virtual action: Function, # alias for @public
      args: [Object, Object] # nameDefinition, config
      return: String


    @public @virtual permitBody: Function, # через эту функцию должен пропускаться payload пришедший от браузера
      args: []
      return: RC::Constants.NILL

    @public @virtual list: Function,
      args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
      return: RC::Constants.NILL # без return. данные посылаем сигналом
    @public @virtual detail: Function,
      args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
      return: RC::Constants.NILL # без return. данные посылаем сигналом
    @public @virtual create: Function,
      args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
      return: RC::Constants.NILL # без return. данные посылаем сигналом
    @public @virtual update: Function,
      args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
      return: RC::Constants.NILL # без return. данные посылаем сигналом
    @public @virtual delete: Function,
      args: [Object] # {queryParams, pathPatams, currentUserId, headers, body }
      return: RC::Constants.NILL # без return. данные посылаем сигналом

    # здесь не декларируются before/after хуки, потому что их использование относится сугубо к реализации, но не к спецификации интерфейса как такового.

    # input and output декорирующих функций здесь не должно быть. Этим должны заниматься viewSerializers, которые должны объявляться в медиаторах либо в viewComponent's. (может быть их лучше назвать Presenter'ами, потому что рендеринг html перед отправкой в браузер должен осуществляться черезь подобные классы.)

  return LeanRC::ResourceInterface.initialize()
