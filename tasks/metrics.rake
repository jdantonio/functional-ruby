desc 'Display LOC (lines of code) report'
task :loc do
  sh 'countloc -r lib'
end

desc 'Display code quality analysis report'
task :critic do
  sh 'rubycritic lib --path critic'
end
