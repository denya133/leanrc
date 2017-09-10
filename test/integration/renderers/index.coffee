
module.exports = (Namespace) ->
  require('./json') Namespace
  require('./html') Namespace
  require('./xml') Namespace
  require('./atom') Namespace
