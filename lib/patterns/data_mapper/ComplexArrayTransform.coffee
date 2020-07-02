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

# NOTE: от этого класса можно унаследовать отдельный класс с кастомным определением схемы и использовать его внутри объявления атрибутов рекорда

module.exports = (Module)->
  {
    FuncG, MaybeG, TupleG, SubsetG
    RecordInterface
    ArrayTransform
    Utils: { _, inflect, moment }
  } = Module::

  class ComplexArrayTransform extends ArrayTransform
    @inheritProtected()
    @module Module

    @public @static parseRecordName: FuncG(String, TupleG String, String),
      default: (asName)->
        if /.*[:][:].*/.test(asName)
          [vsModuleName, vsRecordName] = asName.split '::'
        else
          [vsModuleName, vsRecordName] = [@moduleName(), inflect.camelize inflect.underscore inflect.singularize asName]
        unless /(Record$)|(Migration$)/.test vsRecordName
          vsRecordName += 'Record'
        [vsModuleName, vsRecordName]

    @public @static findRecordByName: FuncG(String, SubsetG RecordInterface),
      default: (asName)->
        [vsModuleName, vsRecordName] = @parseRecordName asName
        (@Module.NS ? @Module::)[vsRecordName]

    @public @static @async normalize: FuncG([MaybeG Array], Array),
      default: (serialized)->
        unless serialized?
          yield return []
        result = for item in serialized
          switch
            when _.isString(item) and moment(item, moment.ISO_8601).isValid()
              Module::DateTransform.normalizeSync item
            when _.isString item
              Module::StringTransform.normalizeSync item
            when _.isNumber item
              Module::NumberTransform.normalizeSync item
            when _.isBoolean item
              Module::BooleanTransform.normalizeSync item
            when _.isPlainObject(item) and /.{2,}[:][:].{2,}/.test item.type
              RecordClass = @findRecordByName item.type
              # NOTE: в правильном использовании вторым аргументом должна передаваться ссылка на коллекцию, то тут мы не можем ее получить
              # а так как рекорды в этом случае используются ТОЛЬКО для оформления структуры и хранения данных внутри родительского рекорда, то коллекции физически просто нет.
              yield RecordClass.normalize item
            when _.isPlainObject item
              yield Module::ComplexObjectTransform.normalize item
            when _.isArray item
              yield Module::ComplexArrayTransform.normalize item
            else
              Module::Transform.normalizeSync item
        yield return result

    @public @static @async serialize: FuncG([MaybeG Array], Array),
      default: (deserialized)->
        unless deserialized?
          yield return []
        result = for item in deserialized
          switch
            when _.isString item
              Module::StringTransform.serializeSync item
            when _.isNumber item
              Module::NumberTransform.serializeSync item
            when _.isBoolean item
              Module::BooleanTransform.serializeSync item
            when _.isDate item
              Module::DateTransform.serializeSync item
            when _.isObject(item) and /.{2,}[:][:].{2,}/.test item.type
              RecordClass = @findRecordByName item.type
              yield RecordClass.serialize item
            when _.isPlainObject item
              yield Module::ComplexObjectTransform.serialize item
            when _.isArray item
              yield Module::ComplexArrayTransform.serialize item
            else
              Module::Transform.serializeSync item
        yield return result

    @public @static objectize: FuncG([MaybeG Array], Array),
      default: (deserialized)->
        unless deserialized?
          return []
        result = for item in deserialized
          switch
            when _.isString item
              Module::StringTransform.objectize item
            when _.isNumber item
              Module::NumberTransform.objectize item
            when _.isBoolean item
              Module::BooleanTransform.objectize item
            when _.isDate item
              Module::DateTransform.objectize item
            when _.isObject(item) and /.{2,}[:][:].{2,}/.test item.type
              RecordClass = @findRecordByName item.type
              RecordClass.objectize item
            when _.isPlainObject item
              Module::ComplexObjectTransform.objectize item
            when _.isArray item
              Module::ComplexArrayTransform.objectize item
            else
              Module::Transform.objectize item
        return result


    @initialize()
