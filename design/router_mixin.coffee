{SELF, NILL} = FoxxMC::Constants


class RouterMixinInterface extends Interface
  @public createNativeRoute: Function
  ,
    [
      method:     String
    ,
      path:       String
    ,
      controller: String
    ,
      action:     String
    ]
  , ->
    return: NILL
