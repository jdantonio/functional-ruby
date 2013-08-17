require 'rbconfig'

module Functional

  class Platform

    attr_reader :ruby_version
    attr_reader :host_os
    attr_reader :ruby_name

    def rubies
      @rubies ||= [
        :ruby,     # C Ruby (MRI) or Rubinius, but NOT Windows
        :ruby_18,  # ruby AND version 1.8
        :ruby_19,  # ruby AND version 1.9
        :mri,      # Same as ruby, but not Rubinius
        :mri_18,   # mri AND version 1.8
        :mri_19,   # mri AND version 1.9
        :mri_20,   # mri AND version 20
        :rbx,      # Same as ruby, but only Rubinius (not MRI)
        :jruby,    # JRuby
        :mswin,    # Windows
        :mingw,    # Windows 'mingw32' platform (aka RubyInstaller)
        :mingw_18, # mingw AND version 1.8
        :mingw_19, # mingw AND version 1.9
        :mingw_20, # mingw AND version 2.0
      ].freeze
    end

    def initialize(*args)
      unless args.size == 0 || args.size == 3
        raise ArgumentError.new("wrong number of arguments (#{args.size} for 0 or 3)")
      end

      @ruby_version = args[0] || RUBY_VERSION || RbConfig::CONFIG['ruby_version']
      @host_os = args[1] || RbConfig::CONFIG['host_os']
      @ruby_name = args[2] || RbConfig::CONFIG['ruby_install_name']
    end

    def windows?
      truthy(@host_os =~ /win32/i) || truthy(@host_os =~ /mingw32/i)
    end

    def linux?
      truthy(@host_os =~ /linux/i)
    end

    def osx?
      truthy(@host_os =~ /darwin/i)
    end

    def ruby?
      mri? || rbx?
    end

    def ruby_18?
      ruby? && truthy(@ruby_version =~ /^1\.8/)
    end

    def ruby_19?
      ruby? && truthy(@ruby_version =~ /^1\.9/)
    end

    def ruby_20?
      ruby? && truthy(@ruby_version =~ /^2\.0/)
    end

    def mri?
      truthy(@ruby_name =~ /^ruby$/i) && !windows?
    end

    def mri_18?
      mri? && truthy(@ruby_version =~ /^1\.8/)
    end

    def mri_19?
      mri? && truthy(@ruby_version =~ /^1\.9/)
    end

    def mri_20?
      mri? && truthy(@ruby_version =~ /^2\.0/)
    end

    def rbx?
      truthy(@ruby_name =~ /^rbx$/i)
    end

    def jruby?
      truthy(@ruby_name =~ /^jruby$/i)
    end

    def mswin?
      truthy(@host_os =~ /win32/i)
    end

    def mingw?
      truthy(@host_os =~ /mingw32/i)
    end

    def mingw_18?
      mingw? && truthy(@ruby_version =~ /^1\.8/)
    end

    def mingw_19?
      mingw? && truthy(@ruby_version =~ /^1\.9/)
    end

    def mingw_20?
      mingw? && truthy(@ruby_version =~ /^2\.0/)
    end

    private

    def truthy(value)
      return value == 0
    end
  end

  PLATFORM = Functional::Platform.new
end
