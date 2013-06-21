# require everything in lib
Dir.glob(File.join(File.dirname(__FILE__), '*.rb')).each do|file|
  unless __FILE__ == file
    require_relative File.basename(file).chomp(File.extname(file))
  end
end
