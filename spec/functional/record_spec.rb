require 'spec_helper'
require_relative 'abstract_struct_shared'

module Functional

  describe Record do

    let!(:expected_members){ [:a, :b, :c] }
    let!(:expected_values){ [42, nil, nil] }

    let(:struct_class) { Record.new(*expected_members) }
    let(:struct_object) { struct_class.new(struct_class::MEMBERS.first => 42) }

    it_should_behave_like :abstract_struct

  end
end
