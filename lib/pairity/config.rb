require 'yaml'

module Pairity
  class Config

    FILENAME = '.pairity'
    PATH = "#{Dir.home}/#{FILENAME}"

    @@config = {}

    def self.config
      @@config
    end

    def self.configured?
      self.load
      !@@config.any? { |key, value| value.nil? || value.empty? }
    end

    def self.add(options={})
      add_option(:channel, options[:channel])
      add_option(:url, options[:url])
    end

    def self.save
      File.open(PATH, 'w+') do |f|
        f.write(YAML.dump(config))
      end
    end

    def self.load
      file_exists = File.exists?(PATH)
      if File.exists?(PATH)
        value = YAML.load_file(PATH)
      else
        value = defaults
      end
      @@config = value
    end

    def self.get(key)
      config[key]
    end

    def self.display
      if config.empty?
        puts "No config values set"
      else
        config.each do |key, value|
          puts "#{key.upcase}: #{value}"
        end
      end
    end

    private

    def self.defaults
      {
        :channel => 'general',
        :url => '',
      }
    end

    def self.add_option(key, value)
      config[key] = value unless value.nil?
    end

  end
end
