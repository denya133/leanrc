# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

###
```coffee
Module = require 'Module'

module.exports = (App)->
  App::ModelingGateway extends Module::Gateway
    @inheritProtected()
    @include Module::ModelingGatewayMixin

    @module App

  return App::ModelingGateway.initialize()
```

###

module.exports = (Module)->
  {
    FuncG, SubsetG
    EndpointInterface
    Gateway, Mixin
    Utils: { _, inflect, joi, statuses }
  } = Module::

  HTTP_NOT_FOUND    = statuses 'not found'
  HTTP_CONFLICT     = statuses 'conflict'
  UNAUTHORIZED      = statuses 'unauthorized'
  FORBIDDEN         = statuses 'forbidden'
  UPGRADE_REQUIRED  = statuses 'upgrade required'

  Module.defineMixin Mixin 'ModelingGatewayMixin', (BaseClass = Gateway) ->
    class extends BaseClass
      @inheritProtected()

      @public getStandardActionEndpoint: FuncG([String, String], SubsetG EndpointInterface),
        default: (asResourse, asAction) ->
          vsEndpointName = if _.startsWith asResourse.toLowerCase(), 'modeling'
            "Modeling#{inflect.camelize asAction}Endpoint"
          else
            "#{inflect.camelize asAction}Endpoint"
          @ApplicationModule::[vsEndpointName] ? @ApplicationModule::Endpoint

      @initializeMixin()
