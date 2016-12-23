CoreObject  = require './CoreObject'

###
  ````
    class Aaa extends Mixin
      k: ()->
        console.trace()
        console.log '^^Aaa::k', @yy
      @hh: ()->
        console.log '^^Aaa.hh'


    class Ccc extends Mixin
      @jk: 6
      yy: 90
      @kl: ()->
      @hh: ()->
        console.log 'before super @hh() in Ccc.hh'
        super
        console.log 'after super @hh() in Ccc.hh'
      k: ()->
        console.log 'before super k() in Ccc::k'
        super
        console.log 'after super k() in Ccc::k'


    class Jjj extends Mixin
      @ll: 6
      oo: ()->
        this.k()
      #k: ()->
      #  console.log 'before super k() in Jjj::k'
      #  super
      #  console.log 'after super k() in Jjj::k'


    class Kkk extends Mixin
      @ll: 6
      oo: ()->
        this.k()
      k: ()->
        console.log 'before super k() in Kkk::k', @yy
        super
        console.log 'after super k() in Kkk::k'
      #@hh: ()->
      #  console.log 'before super @hh() in Kkk.hh'
      #  super
      #  console.log 'after super @hh() in Kkk.hh'


    class Iii extends Mixin
      @including: ()->
        @attr 'jhj'

    # Parameterized mixin
    Formattable = (classname, properties...) ->
      class extends Mixin
        toString: ->
          if properties.length is 0
            "[#{classname}]"
          else
            formattedProperties = ("#{p}=#{@[p]}" for p in properties)
            "[#{classname}(#{formattedProperties.join ', '})]"

        classname: -> classname

    class Bbb extends CoreObject
      @include [
        Aaa
        Ccc
      ]
      @include Jjj, Kkk
      @include Iii
      @include Formattable('Bbb', 'yy')
      k: ()->
        console.log 'before super k() in Bbb::k'
        super
        console.log 'after super k() in Bbb::k'
      @hh: ()->
        console.log 'before super @hh() in Bbb.hh'
        super
        console.log 'after super @hh() in Bbb.hh'

    b = new Bbb()
    b.k()
    Bbb.hh()
    console.log 'Bbb', String(b), Bbb.__super__
  ```
###

class Mixin extends CoreObject

module.exports = Mixin.initialize()
