desc 'Display LOC (lines of code) report'
task :loc do
  puts `countloc -r lib`
  #puts `countloc -r spec`
end
