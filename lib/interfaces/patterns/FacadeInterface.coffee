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

module.exports = (Module)->
  {
    AnyT
    FuncG, SubsetG, MaybeG
    CommandInterface, ProxyInterface, MediatorInterface
    NotificationInterface
    NotifierInterface
  } = Module::

  class FacadeInterface extends NotifierInterface
    @inheritProtected()
    @module Module

    @virtual remove: FuncG []

    @virtual registerCommand: FuncG [String, SubsetG CommandInterface]
    @virtual removeCommand: FuncG String
    @virtual hasCommand: FuncG String, Boolean

    @virtual registerProxy: FuncG ProxyInterface
    @virtual retrieveProxy: FuncG String, MaybeG ProxyInterface
    @virtual removeProxy: FuncG String, MaybeG ProxyInterface
    @virtual hasProxy: FuncG String, Boolean

    @virtual registerMediator: FuncG MediatorInterface
    @virtual retrieveMediator: FuncG String, MaybeG MediatorInterface
    @virtual removeMediator: FuncG String, MaybeG MediatorInterface
    @virtual hasMediator: FuncG String, Boolean

    @virtual notifyObservers: FuncG NotificationInterface
    @virtual sendNotification: FuncG [String, MaybeG(AnyT), MaybeG String]


    @initialize()
