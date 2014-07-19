require 'spec_helper'

Name = Functional::Record.new(:first, :middle, :last, :suffix)

name = Name.new(first: "Gerald", middle: "Alfred", last: "D'Antonio")

name.first
name.middle
name.last
name.suffix

name.members
name.values

name.to_h

module Functional

  describe Record do

    pending

  end
end
