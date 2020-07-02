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

# здесь нужно определить интерфейс класса Router
# ApplicationRouter будет наследоваться от Command класса, и в него будет подмешиваться миксин RouterMixin
# на основе декларативно объявленной карты роутов, он будет оркестрировать медиаторы, которые будут отвечать за принятие сигналов от Express или Foxx

module.exports = (Module)->
  {
    FuncG, MaybeG, InterfaceG, EnumG, ListG, UnionG
    ProxyInterface
  } = Module::

  class RouterInterface extends ProxyInterface
    @inheritProtected()
    @module Module

    @virtual path: MaybeG String

    @virtual name: MaybeG String

    @virtual above: MaybeG Object

    @virtual tag: MaybeG String

    @virtual templates: MaybeG String

    @virtual param: MaybeG String

    @virtual defaultEntityName: FuncG [], String

    @virtual @static map: FuncG [MaybeG Function]

    @virtual map: Function

    @virtual root: FuncG [InterfaceG {
      to: MaybeG String
      at: MaybeG EnumG 'collection', 'member'
      resource: MaybeG String
      action: MaybeG String
    }]

    @virtual defineMethod: FuncG [
      MaybeG ListG InterfaceG {
        method: String
        path: String
        resource: String
        action: String
        tag: String
        template: String
        keyName: MaybeG String
        entityName: String
        recordName: MaybeG String
      }
      String
      String
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]

    @virtual get: FuncG [
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]

    @virtual post: FuncG [
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]

    @virtual put: FuncG [
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]

    @virtual delete: FuncG [
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]

    @virtual head: FuncG [
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]

    @virtual options: FuncG [
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]

    @virtual patch: FuncG [
      String,
      MaybeG InterfaceG {
        to: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        action: MaybeG String
        tag: MaybeG String
        template: MaybeG String
        keyName: MaybeG String
        entityName: MaybeG String
        recordName: MaybeG String
      }
    ]

    @virtual resource: FuncG [
      String
      MaybeG UnionG(InterfaceG({
        path: MaybeG String
        module: MaybeG String
        only: MaybeG UnionG String, ListG String
        via: MaybeG UnionG String, ListG String
        except: MaybeG UnionG String, ListG String
        tag: MaybeG String
        templates: MaybeG String
        param: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        resource: MaybeG String
        above: MaybeG Object
      }), Function)
      MaybeG Function
    ]

    @virtual namespace: FuncG [
      MaybeG String
      UnionG(InterfaceG({
        module: MaybeG String
        prefix: MaybeG String
        tag: MaybeG String
        templates: MaybeG String
        at: MaybeG EnumG 'collection', 'member'
        above: MaybeG Object
      }), Function)
      MaybeG Function
    ]

    @virtual member: FuncG Function

    @virtual collection: FuncG Function

    @virtual routes: ListG InterfaceG {
      method: String
      path: String
      resource: String
      action: String
      tag: String
      template: String
      keyName: MaybeG String
      entityName: String
      recordName: MaybeG String
    }


    @initialize()
