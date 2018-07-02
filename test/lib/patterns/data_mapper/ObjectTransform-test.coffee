{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co, joi } = LeanRC::Utils
ObjectTransform = LeanRC::ObjectTransform

describe 'ObjectTransform', ->
  describe '.schema', ->
    it 'should has correct schema value', ->
      expect ObjectTransform.schema
      .deep.equal joi.object().allow(null).optional()
    it 'should has correct validate null value', ->
      expect joi.validate null, ObjectTransform.schema
      .deep.equal {error: null, value: null}
    it 'should has correct validate empty object value', ->
      expect joi.validate {}, ObjectTransform.schema
      .deep.equal {error: null, value: {}}
    it 'should has correct validate any object value', ->
      expect joi.validate {one: 1, two: true, three: 'three', four: "2018-06-05T12:52:43.160Z"}, ObjectTransform.schema
      .deep.equal {error: null, value: {one: 1, two: true, three: 'three', four: "2018-06-05T12:52:43.160Z"}}
  describe '.normalize', ->
    it 'should normalize null value', ->
      co ->
        assert.deepEqual (yield ObjectTransform.normalize null), {}
        yield return
    it 'should normalize empty object', ->
      co ->
        assert.deepEqual (yield ObjectTransform.normalize {}), {}
        yield return
    it 'should normalize simple object', ->
      co ->
        assert.deepEqual (yield ObjectTransform.normalize {one: 1, two: true, three: 'three', four: "2018-06-05T12:52:43.160Z"}), {one: 1, two: true, three: 'three', four: new Date("2018-06-05T12:52:43.160Z")}
        yield return
    it 'should normalize complex object', ->
      co ->
        assert.deepEqual (yield ObjectTransform.normalize {one: 1, two: {three: 'three'}, four: [1, 2]}), {one: 1, two: {three: 'three'}, four: [1, 2]}
        yield return
  describe '.serialize', ->
    it 'should serialize null value', ->
      co ->
        assert.deepEqual (yield ObjectTransform.serialize null), {}
        yield return
    it 'should serialize empty object', ->
      co ->
        assert.deepEqual (yield ObjectTransform.serialize {}), {}
        yield return
    it 'should serialize simple object', ->
      co ->
        assert.deepEqual (yield ObjectTransform.serialize {one: 1, two: true, three: 'three', four: new Date("2018-06-05T12:52:43.160Z")}), {one: 1, two: true, three: 'three', four: "2018-06-05T12:52:43.160Z"}
        yield return
    it 'should serialize complex object', ->
      co ->
        assert.deepEqual (yield ObjectTransform.serialize {one: 1, two: {three: 'three'}, four: [1, 2]}), {one: 1, two: {three: 'three'}, four: [1, 2]}
        yield return
  describe '.objectize', ->
    it 'should objectize null value', ->
      expect ObjectTransform.objectize null
      .deep.equal {}
    it 'should objectize empty object', ->
      expect ObjectTransform.objectize {}
      .deep.equal {}
    it 'should objectize simple object', ->
      expect(
        ObjectTransform.objectize {one: 1, two: true, three: 'three', four: new Date("2018-06-05T12:52:43.160Z")}
      ).deep.equal {one: 1, two: true, three: 'three', four: "2018-06-05T12:52:43.160Z"}
    it 'should objectize complex object', ->
      expect(
        ObjectTransform.objectize {one: 1, two: {three: 'three'}, four: [1, 2]}
      ).deep.equal {one: 1, two: {three: 'three'}, four: [1, 2]}
