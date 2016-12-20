moment = require('moment');
var changeCase            = require('change-case');
var path                  = require('path');

module.exports = function(Handlebars) {
  Handlebars.registerHelper('migration_id', (function() {
    return function(options) {
      var date = new Date();
      return moment(date).format("YYYYMMDDHHmmss");
    };
  })());
};
