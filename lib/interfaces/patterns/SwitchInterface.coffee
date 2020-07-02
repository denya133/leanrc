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
    FuncG, ListG, MaybeG, InterfaceG, StructG, UnionG
    ContextInterface, MediatorInterface, RendererInterface, ResourceInterface
    SwitchInterface: SwitchInterfaceDef
  } = Module::

  class SwitchInterface extends MediatorInterface
    @inheritProtected()
    @module Module

    @virtual routerName: String

    @virtual responseFormats: ListG String

    @virtual use: FuncG [UnionG(Number, Function), MaybeG Function], SwitchInterfaceDef

    @virtual @async handleStatistics: FuncG [Number, Number, Number, ContextInterface]

    @virtual rendererFor: FuncG String, RendererInterface

    @virtual @async sendHttpResponse: FuncG [ContextInterface, MaybeG(AnyT), ResourceInterface, InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: MaybeG String
      entityName: String
      recordName: MaybeG String
    }]

    @virtual defineRoutes: Function

    @virtual sender: FuncG [String, StructG({
      context: ContextInterface
      reverse: String
    }), InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: MaybeG String
      entityName: String
      recordName: MaybeG String
    }]

    @virtual createNativeRoute: FuncG [InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: MaybeG String
      entityName: String
      recordName: MaybeG String
    }]


    @initialize()
