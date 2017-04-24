http = require 'http'
URL = require 'url'
_ = require 'lodash'
RC = require 'RC'

module.exports = (options) ->

  server = {}

  FIXTURE_NAME = "#{__dirname}/fixtures/#{options.fixture}.json"
  FIXTURE = (try require FIXTURE_NAME) ? {
    "/": {
      "OPTIONS": {
        "headers": {
          "Allow": "HEAD, OPTIONS"
        },
        "statusCode": 200,
        "statusMessage": "OK"
      },
      "HEAD": {
        "statusCode": 200,
        "statusMessage": "OK"
      },
    }
  }

  for own path, methods of FIXTURE
    for own method, methodConfig of methods
      if method is '*' or ',' in method
        names = if method is '*' then [
          'HEAD', 'OPTIONS', 'GET', 'POST', 'PUT', 'PATCH', 'DELETE'
        ] else method.split ','
        delete methods[method]
        for name in names
          methods[name] = methodConfig  unless _.isEmpty name

  server.server = http.createServer (req, res) ->
    res.setHeader 'Content-Type', req.headers['accept'] ? 'text/plain'
    url = URL.parse req.url

    path = FIXTURE[url.pathname]
    if path?
      if (method = path[req.method])?
        if method.redirect?
          res.statusCode = 302
          res.statusMessage = 'Found'
          res.setHeader 'Location', method.redirect
        else
          res.statusCode = method.statusCode
          res.statusCode ?= if req.method is 'DELETE' then 202 else 200
          res.statusMessage = method.statusMessage
          res.statusMessage ?= if req.method is 'DELETE' then 'No Content' else 'OK'
          if method.headers?
            for own headerName, headerValue of method.headers
              res.setHeader headerName, headerValue
          response = JSON.stringify method.data  if method.data?
      else
        res.statusCode = 405
        res.statusMessage = 'Method Not Allowed'
    else
      res.statusCode = 404
      res.statusMessage = 'Not Found'
    res.end response
    return

  server.listen = (args...) ->
    @server.listen args...
    return

  server.close = (callback) ->
    @server.close callback

  server
