require 'thor'
require File.expand_path(File.dirname(__FILE__) + '/grapevine_skeleton.rb')

module Structure
  class Grapevine < Thor
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    method_option :withdb, type: :string, default: ''
    method_option :dbms, type: :string, default: 'pg'
    desc "new <AppName> --withdb sequel|activerecord --dbms pg|mysql2", "create a new app, --withdb is optional"
    def new(app_name)
      error_message = "new <AppName> --withdb sequel|activerecord --dbms pg|mysql2", "create a new app, --withdb is optional"
      p error_message if options.include?(:withdb) && withdb(options[:witdb]) == ''

      a = dbms(options[:dbms])
      Structure::GrapevineSkeleton.start([app_name, withdb(options[:withdb]), dbms(options[:dbms])])
    end

    desc "add_api_version", "creates a new routes.rb file under the new incremented version folder"
    def add_api_version

      if Dir.exists?(information_path)
        version = "v#{api_version}"
        
        Dir.mkdir("#{information_path}/#{version}")

        template(source, destination(version), opts_with_version(version))
      else
        p "it looks like you're not inside a grapevine project"
      end
    end

    private

    def dbms(options)
      if !options.nil? || options =~ /^(pg|mysql2)$/
        options
      else
        "pg"
      end
    end

    def withdb(options)
      if !options.nil? && options =~ /^(sequel|activerecord)$/
        options
      else
        ""
      end
    end

    def information_path
      "app/information"
    end

    def application_name
      file = File.open('config/application.rb', 'r')
      file.read.each_line do |line|
        if line =~ /module/
          return line.gsub('module ', '')          
        end
      end
    end

    def api_version
      api_version = [0]
      
      Dir.entries(information_path).each do |version|
        if version =~ /v\d/
          api_version << version[1..-1].to_i
        end
      end

      api_version.uniq.sort.last + 1
    end

    def opts_with_version(version)
      {
        version: version,
        app_name: application_name,
        verbose: false
      }
    end

    def source
      File.dirname(__FILE__) + '/templates/routes.rb.tt'
    end

    def destination(version)
      "#{information_path}/#{version}/routes.rb"
    end
  end
end
