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
    it 'should call `test` 4 times', (done) ->
      expect ->
        test = sinon.spy ->
        Promise.new (resolve, reject) ->
          resolve 'RESOLVE'
        .then test
        .then test
        .then test
        .then test
        .then ->
          assert.equal test.callCount, 4, 'Not every `test` called'
          done()
      .to.not.throw Error
    it 'should call `test` 2 times and then fall with error', (done) ->
      expect ->
        test = sinon.spy ->
        Promise.new (resolve, reject) ->
          resolve 'RESOLVE'
        .then test
        .then test
        .then ->
          throw new Error 'ERROR'
        .then test
        .then test
        .then null, (err) ->
          assert.equal err.message, 'ERROR', 'No error message'
          assert.equal test.callCount, 2, 'Wrong count of `test` called'
          done()
      .to.not.throw Error
    it 'should call `test` 1 time, then fall with error, and continue 2 times', (done) ->
      expect ->
        test = sinon.spy ->
        Promise.new (resolve, reject) ->
          resolve 'RESOLVE'
        .then test
        .then ->
          throw new Error 'ERROR'
        .then test
        .then test
        .then null, (err) ->
          assert.equal err.message, 'ERROR', 'No error message'
        .then test
        .then test
        .then ->
          assert.equal test.callCount, 3, 'Wrong count of `test` called'
          done()
      .to.not.throw Error
