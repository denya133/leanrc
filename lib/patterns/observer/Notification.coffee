RC = require 'RC'

module.exports = (LeanRC)->
  class LeanRC::Notification extends RC::CoreObject
    @implements LeanRC::NotificationInterface



  return LeanRC::Notification.initialize()
