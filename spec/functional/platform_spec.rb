require 'spec_helper'

module Functional

  describe Platform do


    # rubinius-2.0.0.rc1 (rbx) 1.8 mode
    let(:rubinius_18) do
      {
        :ruby_install_name => 'rbx',
        :host_os => 'darwin11.4.2',
        :ruby_version => '1.8',
        :TEENY => '7',
        :MAJOR => '1',
        :MINOR => '8'
      }
    end

    # rubinius-2.0.0.rc1 (rbx) 1.9 mode
    let(:rubinius_19) do
      {
        :ruby_install_name => 'rbx',
        :MAJOR => '1',
        :MINOR => '9',
        :TEENY => '3',
        :ruby_version => '1.9',
        :host_os => 'darwin11.4.2'
      }
    end

    # jruby-1.6.7
    let(:jruby_167) do
      {
        :MAJOR => '1',
        :MINOR => '8',
        :TEENY => '7',
        :ruby_version => '1.8',
        :ruby_install_name => 'jruby',
        :host_os => 'linux'
      }
    end

    # jruby-1.6.7.2
    let(:jruby_1672) do
      {
        :MAJOR => '1',
        :MINOR => '8',
        :TEENY => '7',
        :ruby_version => '1.8',
        :ruby_install_name => 'jruby',
        :host_os => 'linux'
      }
    end

    # jruby-1.6.8
    let(:jruby_168) do
      {
        :MAJOR => '1',
        :MINOR => '8',
        :TEENY => '7',
        :ruby_version => '1.8',
        :ruby_install_name => 'jruby',
        :host_os => 'linux'
      }
    end

    # jruby-1.7.0
    let(:jruby_170) do
      {
        :MAJOR => '1',
        :MINOR => '9',
        :TEENY => '3',
        :ruby_version => '1.9',
        :ruby_install_name => 'jruby',
        :host_os => 'linux'
      }
    end

    let(:jruby_170_osx) do
      {
        :MAJOR => '1',
        :MINOR => '9',
        :TEENY => '3',
        :ruby_version => '1.9',
        :ruby_install_name => 'jruby',
        :host_os => 'darwin'
      }
    end

    # ree-1.8.7-2012.02
    let(:ree_187) do
      {
        :MINOR => '8',
        :MAJOR => '1',
        :host_os => 'linux-gnu',
        :PATCHLEVEL => '358',
        :ruby_install_name => 'ruby',
        :TEENY => '7',
        :ruby_version => '1.8'
      }
    end

    let(:ree_187_osx) do
      {
        :host_os => 'darwin11.4.2',
        :ruby_install_name => 'ruby',
        :MINOR => '8',
        :MAJOR => '1',
        :ruby_version => '1.8',
        :TEENY => '7',
        :PATCHLEVEL => '358'
      }
    end

    # ruby-1.8.6
    let(:mri_186) do
      {
        :MAJOR => '1',
        :ruby_version => '1.8',
        :MINOR => '8',
        :host_os => 'linux-gnu',
        :ruby_install_name => 'ruby',
        :TEENY => '6'
      }
    end

    # ruby-1.8.7
    let(:mri_187) do
      {
        :MAJOR => '1',
        :ruby_version => '1.8',
        :PATCHLEVEL => '371',
        :MINOR => '8',
        :host_os => 'linux-gnu',
        :TEENY => '7',
        :ruby_install_name => 'ruby'
      }
    end

    # ruby-1.9.2
    let(:mri_192) do
      {
        :MAJOR => '1',
        :MINOR => '9',
        :TEENY => '1',
        :PATCHLEVEL => '320',
        :ruby_install_name => 'ruby',
        :ruby_version => '1.9.1',
        :host_os => 'linux-gnu'
      }
    end

    # ruby-1.9.3
    let(:mri_193) do
      {
        :MAJOR => '1',
        :MINOR => '9',
        :TEENY => '1',
        :PATCHLEVEL => '327',
        :ruby_install_name => 'ruby',
        :ruby_version => '1.9.1',
        :host_os => 'linux-gnu'
      }
    end

    # ruby-2.0.0
    let(:mri_200) do
      {
        :MAJOR => '2',
        :MINOR => '0',
        :TEENY => '0',
        :PATCHLEVEL => '195',
        :ruby_install_name => 'ruby',
        :ruby_version => '2.0.0',
        :host_os => 'linux-gnu'
      }
    end

    def platform_for(config)
      return Platform.new(config[:ruby_version], config[:host_os],
                          config[:ruby_install_name])
    end

    context 'operating system' do

      it 'properly detects Linux' do
        platform = platform_for(mri_193)
        platform.should be_linux
        platform.should_not be_windows
        platform.should_not be_osx
      end

      it 'properly detects Windows'

      it 'properly detects OS X' do
        platform = platform_for(jruby_170_osx)
        platform.should_not be_linux
        platform.should_not be_windows
        platform.should be_osx
      end
    end

    context 'Ruby version' do

      it 'properly detects Rubinius (rbx) 1.8 mode (Linux)' do
        platform = platform_for(rubinius_18)

        platform.should be_ruby
        platform.should be_ruby_18
        platform.should_not be_ruby_19
        platform.should_not be_ruby_20
        platform.should_not be_mri
        platform.should_not be_mri_18
        platform.should_not be_mri_19
        platform.should_not be_mri_20
        platform.should be_rbx
        platform.should_not be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects Rubinius (rbx) 1.9 mode (Linux)' do
        platform = platform_for(rubinius_19)

        platform.should be_ruby
        platform.should_not be_ruby_18
        platform.should be_ruby_19
        platform.should_not be_mri
        platform.should_not be_mri_18
        platform.should_not be_mri_19
        platform.should_not be_mri_20
        platform.should be_rbx
        platform.should_not be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects JRuby 1.6.7 (Linux)' do
        platform = platform_for(jruby_167)

        platform.should_not be_ruby
        platform.should_not be_ruby_18
        platform.should_not be_ruby_19
        platform.should_not be_ruby_20
        platform.should_not be_mri
        platform.should_not be_mri_18
        platform.should_not be_mri_19
        platform.should_not be_mri_20
        platform.should_not be_rbx
        platform.should be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects JRuby 1.6.7.2 (Linux)' do
        platform = platform_for(jruby_1672)

        platform.should_not be_ruby
        platform.should_not be_ruby_18
        platform.should_not be_ruby_19
        platform.should_not be_ruby_20
        platform.should_not be_mri
        platform.should_not be_mri_18
        platform.should_not be_mri_19
        platform.should_not be_mri_20
        platform.should_not be_rbx
        platform.should be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects JRuby 1.6.8 (Linux)' do
        platform = platform_for(jruby_168)

        platform.should_not be_ruby
        platform.should_not be_ruby_18
        platform.should_not be_ruby_19
        platform.should_not be_ruby_20
        platform.should_not be_mri
        platform.should_not be_mri_18
        platform.should_not be_mri_19
        platform.should_not be_mri_20
        platform.should_not be_rbx
        platform.should be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects JRuby 1.7.0 (Linux)' do
        platform = platform_for(jruby_170)

        platform.should_not be_ruby
        platform.should_not be_ruby_18
        platform.should_not be_ruby_19
        platform.should_not be_ruby_20
        platform.should_not be_mri
        platform.should_not be_mri_18
        platform.should_not be_mri_19
        platform.should_not be_mri_20
        platform.should_not be_rbx
        platform.should be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects JRuby 1.7.0 (OS X)' do
        platform = platform_for(jruby_170_osx)

        platform.should_not be_ruby
        platform.should_not be_ruby_18
        platform.should_not be_ruby_19
        platform.should_not be_ruby_20
        platform.should_not be_mri
        platform.should_not be_mri_18
        platform.should_not be_mri_19
        platform.should_not be_mri_20
        platform.should_not be_rbx
        platform.should be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects REE 1.8.7 (Linux)' do
        platform = platform_for(ree_187)

        platform.should be_ruby
        platform.should be_ruby_18
        platform.should_not be_ruby_19
        platform.should_not be_ruby_20
        platform.should be_mri
        platform.should be_mri_18
        platform.should_not be_mri_19
        platform.should_not be_mri_20
        platform.should_not be_rbx
        platform.should_not be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects REE 1.8.7 (OS X)' do
        platform = platform_for(ree_187_osx)

        platform.should be_ruby
        platform.should be_ruby_18
        platform.should_not be_ruby_19
        platform.should_not be_ruby_20
        platform.should be_mri
        platform.should be_mri_18
        platform.should_not be_mri_19
        platform.should_not be_mri_20
        platform.should_not be_rbx
        platform.should_not be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects MRI 1.8.6 (Linux)' do
        platform = platform_for(mri_186)

        platform.should be_ruby
        platform.should be_ruby_18
        platform.should_not be_ruby_19
        platform.should_not be_ruby_20
        platform.should be_mri
        platform.should be_mri_18
        platform.should_not be_mri_19
        platform.should_not be_mri_20
        platform.should_not be_rbx
        platform.should_not be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects MRI 1.8.7 (Linux)' do
        platform = platform_for(mri_187)

        platform.should be_ruby
        platform.should be_ruby_18
        platform.should_not be_ruby_19
        platform.should_not be_ruby_20
        platform.should be_mri
        platform.should be_mri_18
        platform.should_not be_mri_19
        platform.should_not be_mri_20
        platform.should_not be_rbx
        platform.should_not be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects MRI 1.9.2 (Linux)' do
        platform = platform_for(mri_192)

        platform.should be_ruby
        platform.should_not be_ruby_18
        platform.should be_ruby_19
        platform.should be_mri
        platform.should_not be_mri_18
        platform.should be_mri_19
        platform.should_not be_rbx
        platform.should_not be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects MRI 1.9.3 (Linux)' do
        platform = platform_for(mri_193)

        platform.should be_ruby
        platform.should_not be_ruby_18
        platform.should be_ruby_19
        platform.should be_mri
        platform.should_not be_mri_18
        platform.should be_mri_19
        platform.should_not be_rbx
        platform.should_not be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end

      it 'properly detects MRI 2.0.0 (Linux)' do
        platform = platform_for(mri_200)

        platform.should be_ruby
        platform.should_not be_ruby_18
        platform.should_not be_ruby_19
        platform.should be_ruby_20
        platform.should be_mri
        platform.should_not be_mri_18
        platform.should_not be_mri_19
        platform.should be_mri_20
        platform.should_not be_rbx
        platform.should_not be_jruby
        platform.should_not be_mswin
        platform.should_not be_mingw
        platform.should_not be_mingw_18
        platform.should_not be_mingw_19
        platform.should_not be_mingw_20
      end
    end
  end
end
