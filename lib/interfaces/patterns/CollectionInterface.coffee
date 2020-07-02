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
    AnyT, NilT
    FuncG, SubsetG, MaybeG, UnionG, ListG
    RecordInterface, CursorInterface
    SerializerInterface, ObjectizerInterface
    ProxyInterface
  } = Module::

  class CollectionInterface extends ProxyInterface
    @inheritProtected()
    @module Module

    @virtual recordHasBeenChanged: FuncG [String, Object]

    # надо определиться с этими двумя пунктами, так ли их объявлять?
    @virtual delegate: SubsetG RecordInterface
    # @virtual serializer: MaybeG SerializerInterface
    # @virtual objectizer: MaybeG ObjectizerInterface

    @virtual collectionName: FuncG [], String
    @virtual collectionPrefix: FuncG [], String
    @virtual collectionFullName: FuncG [MaybeG String], String

    @virtual @async generateId: FuncG [RecordInterface], UnionG String, Number, NilT

    # NOTE: создает инстанс рекорда
    @virtual @async build: FuncG Object, RecordInterface
    # NOTE: создает инстанс рекорда и делает save
    @virtual @async create: FuncG Object, RecordInterface
    # NOTE: обращается к БД
    @virtual @async push: FuncG RecordInterface, RecordInterface

    @virtual @async delete: FuncG [UnionG String, Number]

    @virtual @async destroy: FuncG [UnionG String, Number]
    # NOTE: обращается к БД
    @virtual @async remove: FuncG [UnionG String, Number]

    @virtual @async find: FuncG [UnionG String, Number], MaybeG RecordInterface
    @virtual @async findMany: FuncG [ListG UnionG String, Number], CursorInterface
    # NOTE: обращается к БД
    @virtual @async take: FuncG [UnionG String, Number], MaybeG RecordInterface
    # NOTE: обращается к БД
    @virtual @async takeMany: FuncG [ListG UnionG String, Number], CursorInterface
    # NOTE: обращается к БД
    @virtual @async takeAll: FuncG [], CursorInterface

    @virtual @async update: FuncG [UnionG(String, Number), Object], RecordInterface
    # NOTE: обращается к БД
    @virtual @async override: FuncG [UnionG(String, Number), RecordInterface], RecordInterface

    @virtual @async clone: FuncG RecordInterface, RecordInterface

    @virtual @async copy: FuncG RecordInterface, RecordInterface

    @virtual @async includes: FuncG [UnionG String, Number], Boolean
    # NOTE: количество объектов в коллекции
    @virtual @async length: FuncG [], Number

    # NOTE: нормализация данных из базы
    @virtual @async normalize: FuncG AnyT, RecordInterface
    # NOTE: сериализация рекорда для отправки в базу
    @virtual @async serialize: FuncG RecordInterface, AnyT


    @initialize()
