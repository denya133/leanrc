

# возможно этот адаптер должен быть объявлен в отдельном npm модуле,
# чтобы не было ошибки в недостоющих зависимостях при прогрузке на другой платформе.


class ArangodbAdapterInterface extends Interface
  @include AdapterInterface

class ArangodbAdapter extends Adapter
  @implements ArangodbAdapterInterface
