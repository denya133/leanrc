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
    FuncG, MaybeG
    PipeFittingInterface
    Pipe
  } = Module::

  class TeeMerge extends Pipe
    @inheritProtected()
    @module Module

    @public connectInput: FuncG(PipeFittingInterface, Boolean),
      default: (aoInput)->
        aoInput.connect @

    @public init: FuncG([
      MaybeG(PipeFittingInterface), MaybeG PipeFittingInterface
    ]),
      default: (input1=null, input2=null)->
        @super arguments...
        if input1?
          @connectInput input1
        if input2?
          @connectInput input2
        return


    @initialize()
