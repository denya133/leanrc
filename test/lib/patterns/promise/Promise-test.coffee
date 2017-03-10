{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
NativePromise = global.Promise
Promise = LeanRC::Promise

cleanNativePromise = -> global.Promise = undefined
restoreNativePromise = -> global.Promise = NativePromise

describe 'Promise', ->
  describe '.new', ->
    beforeEach cleanNativePromise
    afterEach restoreNativePromise
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
  describe '#then', ->
    beforeEach cleanNativePromise
    afterEach restoreNativePromise
    it 'should call `#then` 4 times', (done) ->
      expect ->
        test = sinon.spy ->
        Promise.new (resolve, reject) ->
          resolve 'RESOLVE'
        .then test
        .then test
        .then test
        .then test
        .then ->
          assert.equal test.callCount, 4, 'Not every `#then` called'
          done()
      .to.not.throw Error
