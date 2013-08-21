module Functional

  module Inflect
    extend self

    # By default, +camelize+ converts strings to UpperCamelCase. If the argument
    # to +camelize+ is set to <tt>:lower</tt> then +camelize+ produces
    # lowerCamelCase.
    #
    # +camelize+ will also convert '/' to '::' which is useful for converting
    # paths to namespaces.
    #
    #   'active_model'.camelize                # => "ActiveModel"
    #   'active_model'.camelize(:lower)        # => "activeModel"
    #   'active_model/errors'.camelize         # => "ActiveModel::Errors"
    #   'active_model/errors'.camelize(:lower) # => "activeModel::Errors"
    #
    # As a rule of thumb you can think of +camelize+ as the inverse of
    # +underscore+, though there are cases where that does not hold:
    #
    #   'SSLError'.underscore.camelize # => "SslError"
    #
    # @see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb
    def camelize(term, uppercase_first_letter = true)
      string = term.to_s
      if uppercase_first_letter == true
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      else
        string = string.sub(/^(?:(?=\b|[A-Z_])|\w)/) { $&.downcase }
      end
      string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end

    # Makes an underscored, lowercase form from the expression in the string.
    #
    # Changes '::' to '/' to convert namespaces to paths.
    #
    #   'ActiveModel'.underscore         # => "active_model"
    #   'ActiveModel::Errors'.underscore # => "active_model/errors"
    #
    # As a rule of thumb you can think of +underscore+ as the inverse of
    # +camelize+, though there are cases where that does not hold:
    #
    #   'SSLError'.underscore.camelize # => "SslError"
    #
    # @see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb
    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!('::', '/')
      word.gsub!(/\s+/, '_')
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    # Capitalizes the first word and turns underscores into spaces and strips a
    # trailing "_id", if any. Like +titleize+, this is meant for creating pretty
    # output.
    #
    #   'employee_salary'.humanize # => "Employee salary"
    #   'author_id'.humanize       # => "Author"
    #
    # @see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb
    def humanize(lower_case_and_underscored_word)
      result = lower_case_and_underscored_word.to_s.dup
      result.gsub!(/_id$/, "")
      result.tr!('_', ' ')
      result.gsub(/([a-z\d]*)/i) { |match| "#{match.downcase}" }.gsub(/^\w/) { $&.upcase }
    end

    # Capitalizes all the words and replaces some characters in the string to
    # create a nicer looking title. +titleize+ is meant for creating pretty
    # output. It is not used in the Rails internals.
    #
    # +titleize+ is also aliased as +titlecase+.
    #
    #   'man from the boondocks'.titleize   # => "Man From The Boondocks"
    #   'x-men: the last stand'.titleize    # => "X Men: The Last Stand"
    #   'TheManWithoutAPast'.titleize       # => "The Man Without A Past"
    #   'raiders_of_the_lost_ark'.titleize  # => "Raiders Of The Lost Ark"
    #
    # @see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb
    def titleize(word)
      #humanize(underscore(word)).gsub(/\b(?<!['`])[a-z]/) { $&.capitalize }
      humanize(underscore(word)).gsub(/\b["'`]?[a-z]/) { $&.capitalize }
    end

    # Replaces underscores with dashes in the string.
    #
    #   'puni_puni'.dasherize # => "puni-puni"
    #
    # @see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb
    def dasherize(underscored_word)
      underscored_word.to_s.dup.tr('_', '-')
    end

    # Add the given extension to the given file name. Removes the current
    # extension if one exists. Strips trailing characters from the file name
    # if present. Does nothing if the file name already has the given
    # extension.
    #
    # @example
    #   extensionize('my_file.png', :png) #=> 'my_file.png'
    #   extensionize('my_file', :png)     #=> 'my_file.png'
    #   extensionize('my_file.png', :jpg) #=> 'my_file.png.jpg'
    #   extensionize('My File', :png)     #=> 'My File.png'
    #   extensionize('My File    ', :png) #=> 'My File.png'
    #   extensionize('my_file.png', :jpg, :chomp => true) #=> 'my_file.jpg'
    #
    # @param [String] fname the name of the file to add an extension to
    # @param [String, Symbol] ext the extension to append, with or without a leading dot
    # @param [Hash] opts processing options
    #
    # @option opts [Symbol] :chomp when true removes the existing entension
    #   from the file name (default: false)
    #
    # @return [String] the *fname* with *ext* appended
    def extensionize(fname, ext, opts={})
      extname = File.extname(fname)
      return fname if (extname =~ /\.?#{ext}$/i) == 0
      fname = fname.gsub(/#{extname}$/, '') if opts[:chomp] == true
      return fname.strip + '.' + ext.to_s.gsub(/^\./, '')
    end
  end
end
