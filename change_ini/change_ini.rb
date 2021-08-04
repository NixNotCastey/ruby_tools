# frozen_string_literal: true

require 'iniparse'
require 'optparse'

# Class for parsing arguments and changing php.ini files
class PHPChanger
  attr_accessor :username, :values, :dir, :include_user

  def initialize(username, values, dir, include_user)
    @username = username
    @values = values
    @dir = dir
    @include_user = include_user
    @params ||= {}
    @files ||= []

    # Parse params into Hash
    parse_params
    # Find all of user ini files
    find_ini

    puts "[ERROR] No ini files found! Directory #{@dir} is correct?" if @files.empty?
    exit 1 if @files.empty?
  end

  def change_ini(selector)
    @files.each do |file|
      File.open(file, 'r+') do |f|
        ini = IniParse.parse(f.read)
        @params.each do |key, val|
          ini[selector.to_s.strip][key] = val
        end
        ini.save(f.path)
      end
    end
  end

  private

  def parse_params
    @values.each do |pair|
      param, val = pair.split('=', 2)
      @params.store(param.strip, val)
    end
  end

  def find_ini
    dir = @include_user ? @dir + @username : @dir
    @files = Dir["#{dir}/*.ini"] if Dir.exist?(dir)
  end
end

options = {
  selector: 'PHP',
  dir: '/home/php-fastcgi/',
  include_user: true
}
opts = OptionParser.new
opts.banner = "Usage: #{opts.program_name} [options]"

opts.on('-n', '--name USERNAME', 'Username for which You want to change php.ini values') do |name|
  options[:name] = name
end
opts.on('-p', '--param parameter=value',
        'Specify parameter and desired value. You can pass multiple params seoarated by comas', Array) do |params|
  options[:params] = params
end
opts.on('-s', '--selector SELECTOR', 'Specify selector within php.ini which contain params. DEFAULT=PHP',
        Array) do |selector|
  options[:selector] = selector
end
opts.on('-d', '--dir PATH', 'Path to directory with php.ini files. DEFAULT=/home/php-fastcgi/') do |dir|
  options[:dir] = dir
end
opts.on('-i', '--[no-]include-user', 'Include User dir in path.') do |include_user|
  options[:include_user] = include_user
end
opts.on('-h', '--help', 'Prints this help') do
  puts opts
  exit
end

opts.parse!

if options.key?(:name) && options.key?(:params)
  php_ini = PHPChanger.new(options[:name], options[:params], options[:dir], options[:include_user])
  php_ini.change_ini options[:selector]
else
  puts opts
  exit 1
end
