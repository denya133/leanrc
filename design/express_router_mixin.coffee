{SELF, NILL} = FoxxMC::Constants

# возможно эта примесь должна быть объявлена в отдельном npm модуле,
# чтобы не было ошибки в недостоющих зависимостях при прогрузке на другой платформе.

class ExpressRouterMixinInterface extends Interface
  @include RouterMixinInterface


class ExpressRouterMixin extends Mixin
  @implements ExpressRouterMixinInterface

  createNativeRoute: (method, path, controller, action)->
