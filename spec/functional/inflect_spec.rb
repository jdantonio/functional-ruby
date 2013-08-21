require 'spec_helper'

module Functional

  describe Inflect do

    context '#camelize' do

      specify { Inflect.camelize('active_model').should eq 'ActiveModel' }
      specify { Inflect.camelize('active_model', :lower).should eq 'activeModel' }
      specify { Inflect.camelize(:active_model).should eq 'ActiveModel' }
      specify { Inflect.camelize(:active_model, :lower).should eq 'activeModel' }

      specify { Inflect.camelize('active_model/errors').should eq 'ActiveModel::Errors' }
      specify { Inflect.camelize('active_model/errors', :lower).should eq 'activeModel::Errors' }
      specify { Inflect.camelize(:'active_model/errors').should eq 'ActiveModel::Errors' }
      specify { Inflect.camelize(:'active_model/errors', :lower).should eq 'activeModel::Errors' }
    end

    context '#underscore' do

      specify { Inflect.underscore('ActiveModel').should eq 'active_model' }
      specify { Inflect.underscore(:'ActiveModel').should eq 'active_model' }

      specify { Inflect.underscore('ActiveModel::Errors').should eq 'active_model/errors' }
      specify { Inflect.underscore(:'ActiveModel::Errors').should eq 'active_model/errors' }
    end

    context '#humanize' do

      specify { Inflect.humanize('employee_salary').should eq 'Employee salary' }
      specify { Inflect.humanize('author_id').should eq 'Author' }

      specify { Inflect.humanize(:employee_salary).should eq 'Employee salary' }
      specify { Inflect.humanize(:author_id).should eq 'Author' }
    end

    context '#titleize' do

      specify { Inflect.titleize('man from the boondocks').should eq 'Man From The Boondocks' }
      specify { Inflect.titleize('x-men: the last stand').should eq 'X Men: The Last Stand' }
      specify { Inflect.titleize('TheManWithoutAPast').should eq 'The Man Without A Past' }
      specify { Inflect.titleize('raiders_of_the_lost_ark').should eq 'Raiders Of The Lost Ark' }

      specify { Inflect.titleize(:'man from the boondocks').should eq 'Man From The Boondocks' }
      specify { Inflect.titleize(:'x-men: the last stand').should eq 'X Men: The Last Stand' }
      specify { Inflect.titleize(:'TheManWithoutAPast').should eq 'The Man Without A Past' }
      specify { Inflect.titleize(:'raiders_of_the_lost_ark').should eq 'Raiders Of The Lost Ark' }
    end

    context '#dasherize' do

      specify { Inflect.dasherize('puni_puni').should eq 'puni-puni' }
      specify { Inflect.dasherize(:'puni_puni').should eq 'puni-puni' }
    end

    context '#extensionize' do

      specify { Inflect.extensionize('my_file.png', :png).should eq 'my_file.png' }
      specify { Inflect.extensionize('my_file.png', 'png').should eq 'my_file.png' }
      specify { Inflect.extensionize('my_file.png', '.png').should eq 'my_file.png' }
      specify { Inflect.extensionize('MY_FILE.PNG', '.png').should eq 'MY_FILE.PNG' }

      specify { Inflect.extensionize('my_file.png', :jpg).should eq 'my_file.png.jpg' }
      specify { Inflect.extensionize('my_file.png', 'jpg').should eq 'my_file.png.jpg' }
      specify { Inflect.extensionize('my_file.png', '.jpg').should eq 'my_file.png.jpg' }

      specify { Inflect.extensionize('my_file.png', :jpg, :chomp => true).should eq 'my_file.jpg' }
      specify { Inflect.extensionize('my_file.png', 'jpg', :chomp => true).should eq 'my_file.jpg' }
      specify { Inflect.extensionize('my_file.png', '.jpg', :chomp => true).should eq 'my_file.jpg' }

      specify { Inflect.extensionize('my_file', :png).should eq 'my_file.png' }
      specify { Inflect.extensionize('my_file', 'png').should eq 'my_file.png' }
      specify { Inflect.extensionize('my_file', '.png').should eq 'my_file.png' }

      specify { Inflect.extensionize('My File', :png).should eq 'My File.png' }
      specify { Inflect.extensionize('My File', 'png').should eq 'My File.png' }
      specify { Inflect.extensionize('My File', '.png').should eq 'My File.png' }

      specify { Inflect.extensionize('My File  ', :png).should eq 'My File.png' }
      specify { Inflect.extensionize('My File  ', 'png').should eq 'My File.png' }
      specify { Inflect.extensionize('My File  ', '.png').should eq 'My File.png' }
    end
  end
end
