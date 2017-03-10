{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
NativePromise = Promise
Promise = LeanRC::Promise

describe 'Promise', ->
  describe '.new', ->
    beforeEach ->
      global.Promise = undefined
    afterEach ->
      global.Promise = NativePromise
    it 'should create new promise (resolving)', (done) ->
      expect ->
        Promise.new (resolve, reject) ->
          resolve 'RESOLVE'
        .then ->
          done()
      .to.not.throw Error
    it 'should create new promise (rejecting)', (done) ->
      expect ->
        Promise.new (resolve, reject) ->
          reject new Error 'REJECT'
        .catch (err) ->
          done()
      .to.not.throw Error
