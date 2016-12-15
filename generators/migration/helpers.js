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

  Handlebars.registerHelper('addonPrefix', (function() {
    return function(options) {
      var current_path = process.cwd();
      var _package = require(path.join(current_path, 'package.json'));
      return changeCase.pascalCase(_package.foxxmc_addon.prefix);
    };
  })());
};
