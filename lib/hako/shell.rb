class Object
  def display
    inspect
  end
end

class String
  def bold
    "\033[1m#{self}\033[22m"
  end
  def red
    "\033[31m#{self}\033[0m"
  end
  def green
    "\033[32m#{self}\033[0m"
  end
  def yellow
    "\033[33m#{self}\033[0m"
  end
  def blue
    "\033[34m#{self}\033[0m"
  end
  def purple
    "\033[35m#{self}\033[0m"
  end
  def cyan
    "\033[36m#{self}\033[0m"
  end
  def gray
    "\033[37m#{self}\033[0m"
  end
end

class InspectString
  def initialize(str)
    @str = str
  end
  def inspect
    @str.to_s
  end
  alias to_s inspect
end

class Terminal
  attr_reader :default_maxrows
  def initialize
    @default_maxrows = 25
  end

  def dump_table(maxrows: nil, nheaders: 1)
    maxrows = Float::INFINITY if maxrows == :all
    maxrows ||= @default_maxrows
    rows = []
    widths = []
    (-nheaders).upto(maxrows) do |i|
      row = yield(i)
      break unless row
      rows << row.collect.with_index do |cell, j|
        cell = cell.to_s
        widths[j] = [widths[j] || 0, cell.length].max
        cell
      end
    end
    format = widths.collect! do |width| "%-#{width+1}.#{width}s" end.join('')
    rows.collect! do |row| format % row end.join("\n")
  end
end

$HAKO_TERMINAL ||= Terminal.new

$HAKO_SHELL_NAME ||= 'hako.rb'
ENV['IRBRC'] = File.join(File.dirname(__FILE__), '../../init/.irbrc')

require 'irb'
require 'irb/completion'

# Start hako.rb shell
def start_hako_shell
  puts "#{$HAKO_SHELL_NAME}#{unless $HAKO_SHELL_NAME == 'hako.rb' then ' (powered by hako.rb)' end} interactive shell".purple.bold
  puts "running on #{RUBY_DESCRIPTION}".red
  puts "with #{BLAS::get_configure_string}".cyan
  IRB.start($HAKO_HELL_NAME)
end
