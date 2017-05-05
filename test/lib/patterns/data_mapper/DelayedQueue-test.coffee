{ expect, assert } = require 'chai'
sinon = require 'sinon'
LeanRC = require.main.require 'lib'
{ co } = LeanRC::Utils

describe 'DelayedQueue', ->
  describe '.new', ->
    it 'should create delayed queue instance', ->
      co ->
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::Resque extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
        Test::Resque.initialize()
        class Test::DelayedQueue extends LeanRC::DelayedQueue
          @inheritProtected()
          @module Test
        Test::DelayedQueue.initialize()
        queue = Test::DelayedQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , Test::Resque.new()
        assert.property queue, 'name', 'TEST_QUEUE', 'No correct `id` property'
        assert.property queue, 'concurrency', 4, 'No correct `rev` property'
        assert.instanceOf queue.resque, Test::Resque, '`resque` is not a Resque instance'
        yield return
  describe '#push', ->
    it 'should push job into queue', ->
      co ->
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return JOB
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::Resque extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public @async pushJob: Function,
            default: spyMethod
        Test::Resque.initialize()
        class Test::DelayedQueue extends LeanRC::DelayedQueue
          @inheritProtected()
          @module Test
        Test::DelayedQueue.initialize()
        queue = Test::DelayedQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , Test::Resque.new()
        UNTIL_DATE = new Date()
        job = yield queue.push 'TEST_SCRIPT', { data: 'data' }, UNTIL_DATE
        assert.equal job, JOB
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], 'TEST_SCRIPT'
        assert.deepEqual spyMethod.args[0][2], data: 'data'
        assert.equal spyMethod.args[0][3], UNTIL_DATE
        yield return
  describe '#get', ->
    it 'should get job from queue', ->
      co ->
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return JOB
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::Resque extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public @async getJob: Function,
            default: spyMethod
        Test::Resque.initialize()
        class Test::DelayedQueue extends LeanRC::DelayedQueue
          @inheritProtected()
          @module Test
        Test::DelayedQueue.initialize()
        queue = Test::DelayedQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , Test::Resque.new()
        UNTIL_DATE = new Date()
        job = yield queue.get '42'
        assert.equal job, JOB
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], '42'
        yield return
  describe '#delete', ->
    it 'should remove job from queue', ->
      co ->
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return JOB
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::Resque extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public @async deleteJob: Function,
            default: spyMethod
        Test::Resque.initialize()
        class Test::DelayedQueue extends LeanRC::DelayedQueue
          @inheritProtected()
          @module Test
        Test::DelayedQueue.initialize()
        queue = Test::DelayedQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , Test::Resque.new()
        UNTIL_DATE = new Date()
        job = yield queue.delete '42'
        assert.equal job, JOB
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], '42'
        yield return
  describe '#abort', ->
    it 'should stop job from queue', ->
      co ->
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return JOB
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::Resque extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public @async abortJob: Function,
            default: spyMethod
        Test::Resque.initialize()
        class Test::DelayedQueue extends LeanRC::DelayedQueue
          @inheritProtected()
          @module Test
        Test::DelayedQueue.initialize()
        queue = Test::DelayedQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , Test::Resque.new()
        UNTIL_DATE = new Date()
        job = yield queue.abort '42'
        assert.equal job, JOB
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], '42'
        yield return
  describe '#all', ->
    it 'should get all jobs from queue', ->
      co ->
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return [ JOB ]
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::Resque extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public @async allJobs: Function,
            default: spyMethod
        Test::Resque.initialize()
        class Test::DelayedQueue extends LeanRC::DelayedQueue
          @inheritProtected()
          @module Test
        Test::DelayedQueue.initialize()
        queue = Test::DelayedQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , Test::Resque.new()
        UNTIL_DATE = new Date()
        jobs = yield queue.all 'TEST_SCRIPT'
        assert.deepEqual jobs, [ JOB ]
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], 'TEST_SCRIPT'
        yield return
  describe '#pending', ->
    it 'should get pending jobs from queue', ->
      co ->
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return [ JOB ]
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::Resque extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public @async pendingJobs: Function,
            default: spyMethod
        Test::Resque.initialize()
        class Test::DelayedQueue extends LeanRC::DelayedQueue
          @inheritProtected()
          @module Test
        Test::DelayedQueue.initialize()
        queue = Test::DelayedQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , Test::Resque.new()
        UNTIL_DATE = new Date()
        jobs = yield queue.pending 'TEST_SCRIPT'
        assert.deepEqual jobs, [ JOB ]
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], 'TEST_SCRIPT'
        yield return
  describe '#progress', ->
    it 'should get processing jobs from queue', ->
      co ->
        JOB = id: '42', job: 'job'
        spyMethod = sinon.spy -> yield return [ JOB ]
        class Test extends LeanRC::Module
          @inheritProtected()
        Test.initialize()
        class Test::Resque extends LeanRC::CoreObject
          @inheritProtected()
          @module Test
          @public @async progressJobs: Function,
            default: spyMethod
        Test::Resque.initialize()
        class Test::DelayedQueue extends LeanRC::DelayedQueue
          @inheritProtected()
          @module Test
        Test::DelayedQueue.initialize()
        queue = Test::DelayedQueue.new
          name: 'TEST_QUEUE'
          concurrency: 4
        , Test::Resque.new()
        UNTIL_DATE = new Date()
        jobs = yield queue.progress 'TEST_SCRIPT'
        assert.deepEqual jobs, [ JOB ]
        assert.isTrue spyMethod.called
        assert.equal spyMethod.args[0][0], 'TEST_QUEUE'
        assert.equal spyMethod.args[0][1], 'TEST_SCRIPT'
        yield return
