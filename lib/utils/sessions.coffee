sessionsMiddleware  = require '@arangodb/foxx/sessions'
cookieTransport     = require '@arangodb/foxx/sessions/transports/cookie'

{secret} = module.context.configuration

FoxxMC::Utils.sessions = if module.context.collectionPrefix is 'internal_'
  (req, res, next)->
    next()
    return
else
  sessionsMiddleware
    storage: module.context.collection 'sessions'
    transport: 'cookie'
    autoCreate: yes
  # при использовании cookieTransport при попытке обратиться без куков вываливается ошибка гдето в недрах HMAC()
  # на данный момент указанный выше вариант единственный стабильно-работоспособный.
  # transport: cookieTransport
  #   name: 'sid'
  #   ttl: 60 * 60 * 24 * 7
  #   algorithm: 'sha256'
  #   secret: secret
  # autoCreate: yes


module.exports = FoxxMC::Utils.sessions
