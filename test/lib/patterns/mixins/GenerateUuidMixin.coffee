{ expect, assert } = require 'chai'
sinon = require 'sinon'
_ = require 'lodash'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils


describe 'GenerateUuidIdMixin', ->
  describe '#generateId', ->
    it 'should get generated ID', ->
      co ->
        class Test extends LeanRC
          @inheritProtected()
        Test.initialize()

        class Test::TestRecord extends LeanRC::Record
          @inheritProtected()
          @module Test
        Test::TestRecord.initialize()
        class Test::TestCollection extends LeanRC::Collection
          @inheritProtected()
          @include LeanRC::GenerateUuidIdMixin
          @module Test
        Test::TestCollection.initialize()
        collection = Test::TestCollection.new 'TEST_COLLECTION',
          delegate: Test::TestRecord
        mask = ///
          ^
          [0-9a-fA-F]{8}
          \-
          [0-9a-fA-F]{4}
          \-
          4[0-9a-fA-F]{3}
          \-
          [0-38-9a-fA-F][0-9a-fA-F]{3}
          \-
          [0-9a-fA-F]{12}
          $
        ///
        for i in [1 .. 1000]
          assert.match yield collection.generateId(), mask
        yield return
