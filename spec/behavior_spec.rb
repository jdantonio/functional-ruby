require 'spec_helper'

describe 'behavior/interface definitions' do

  context 'behavior_info/2' do

    it 'accepts a symbol name'

    it 'accepts a string name'

    it 'accepts zero function names'

    it 'accepts numeric arity values'

    it 'accepts :any as an arity value'
  end

  context 'behavior/1' do

    it 'raises an exception if the behavior has not been defined'

    it 'can be called multiple times for one class'
  end

  context '#behaves_as?' do

    it 'returns true when the behavior is fully suported'

    it 'returns false when the behavior is partially supported'

    it 'returns false when the behavior is not supported at all'

    it 'returns false when the behavior does not exist'
  end

  context 'aliases' do

    it 'aliases behaviour_info for behavior_info'

    it 'aliases interface for behavior_info'

    it 'aliases behaviour for behavior'

    it 'aliases behaves_as for behavior'
  end

end
