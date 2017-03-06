LeanRC = require.main.require 'lib'

module.exports = (TestApp) ->
  TestApp::AppConstants =
    STARTUP: 'startup'
