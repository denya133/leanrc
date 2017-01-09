require('supererror');
var changeCase            = require('change-case');
var path                  = require('path');

module.exports = function(Handlebars) {
  Handlebars.registerHelper('addonPrefix', (function() {
    return function(options) {
      var current_path = process.cwd();
      var _manifest = require(path.join(current_path, 'manifest.json'));
      return changeCase.pascalCase(_manifest.foxxmcModule.prefix);
    };
  })());
};
