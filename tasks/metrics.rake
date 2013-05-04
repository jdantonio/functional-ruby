require 'code_statistics'

#NOTE: This task has been picked up from a dependency
#desc 'Display code metrics'
#task :stats do
  
  #STATS_DIRECTORIES = [
    #%w(Libraries lib/),
    ##%w(Tests spec/),
  #].collect { |name, dir| [ name, "./#{dir}" ] }.select { |name, dir| File.directory?(dir) }

  #CodeStatistics.new(*STATS_DIRECTORIES).to_s
#end

desc 'Display LOC (lines of code) report'
task :loc do
  puts `countloc -r lib`
  #puts `countloc -r spec`
end

desc 'Report code statistics'
task :metrics => [:stats, :loc]
