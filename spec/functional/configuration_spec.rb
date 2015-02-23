module Functional

  context Configuration do

    it 'configures the gem' do
      cfg = nil
      Functional.configure do |config|
        cfg = config
      end

      expect(cfg).to be_a Configuration
      expect(cfg).to eq Functional.configuration
    end
  end
end
