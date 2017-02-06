require 'fileutils'
require 'rake/testtask'

$:.unshift(File.join(File.dirname(__FILE__), './lib'))

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
  t.verbose = true
end

BUILD_PATH = File.join(File.dirname(__FILE__), 'lib/.build')
FileUtils.mkdir_p(BUILD_PATH)
desc 'Build the native math library'
file 'libmath.dylib' => File.join(File.dirname(__FILE__), 'lib/hako/math.c') do |f|
  sh "clang -shared -o #{File.join(BUILD_PATH, f.name)} #{f.prerequisites.join(' ')}"
end

task :default => [:test]
