{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co, joi } = LeanRC::Utils
ArrayTransform = LeanRC::ArrayTransform

describe 'ArrayTransform', ->
  describe '.schema', ->
    it 'should has correct schema value', ->
      expect ArrayTransform.schema
      .deep.equal joi.array().items(joi.any()).allow(null).optional()
    it 'should has correct validate empty array value', ->
      expect joi.validate [], ArrayTransform.schema
      .deep.equal {error: null, value: []}
    it 'should has correct validate any array value', ->
      expect joi.validate [1, true, 'three', four: "2018-06-05T12:52:43.160Z"], ArrayTransform.schema
      .deep.equal {error: null, value: [1, true, 'three', four: "2018-06-05T12:52:43.160Z"]}
  describe '.normalize', ->
    it 'should normalize null value', ->
      co ->
        assert.deepEqual (yield ArrayTransform.normalize null), []
        yield return
    it 'should normalize empty array', ->
      co ->
        assert.deepEqual (yield ArrayTransform.normalize []), []
        yield return
    it 'should normalize simple array', ->
      co ->
        assert.deepEqual (yield ArrayTransform.normalize [1, true, 'three', "2018-06-05T12:52:43.160Z"]), [1, true, 'three', new Date("2018-06-05T12:52:43.160Z")]
        yield return
    it 'should normalize complex array', ->
      co ->
        assert.deepEqual (yield ArrayTransform.normalize [1, two: {three: 'three'}, [1, 2]]), [1, two: {three: 'three'}, [1, 2]]
        yield return
  describe '.serialize', ->
    it 'should serialize null value', ->
      co ->
        assert.deepEqual (yield ArrayTransform.serialize null), []
        yield return
    it 'should serialize empty array', ->
      co ->
        assert.deepEqual (yield ArrayTransform.serialize []), []
        yield return
    it 'should serialize simple array', ->
      co ->
        assert.deepEqual (yield ArrayTransform.serialize [1, true, 'three', new Date("2018-06-05T12:52:43.160Z")]), [1, true, 'three', "2018-06-05T12:52:43.160Z"]
        yield return
    it 'should serialize complex array', ->
      co ->
        assert.deepEqual (yield ArrayTransform.serialize [1, two: {three: 'three'}, [1, 2]]), [1, two: {three: 'three'}, [1, 2]]
        yield return
  describe '.objectize', ->
    it 'should objectize null value', ->
      expect ArrayTransform.objectize null
      .deep.equal []
    it 'should objectize empty array', ->
      expect ArrayTransform.objectize []
      .deep.equal []
    it 'should objectize simple array', ->
      expect(
        ArrayTransform.objectize [1, true, 'three', new Date("2018-06-05T12:52:43.160Z")]
      ).deep.equal [1, true, 'three', "2018-06-05T12:52:43.160Z"]
    it 'should objectize complex array', ->
      expect(
        ArrayTransform.objectize [1, two: {three: 'three'}, [1, 2]]
      ).deep.equal [1, two: {three: 'three'}, [1, 2]]
