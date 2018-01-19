

# describe 'Performance', ->
#   it 'should require LeanRC', ->
ttt = Date.now()
# console.log '!!!', require.main
LeanRC = require '../../dist'
console.log '!!!', Date.now() - ttt
console.log '!!! IN static methods', LeanRC.____dt
console.log '!!! IN defineProperty', LeanRC.____dt1
