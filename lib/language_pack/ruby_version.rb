require "forwardable"
require "language_pack/shell_helpers"

module LanguagePack
  class RubyVersion
    DEFAULT_VERSION_NUMBER = "2.0.0"
    DEFAULT_VERSION        = "ruby-#{DEFAULT_VERSION_NUMBER}"
    LEGACY_VERSION_NUMBER  = "1.9.2"
    LEGACY_VERSION         = "ruby-#{LEGACY_VERSION_NUMBER}"

    attr_reader :set, :version, :version_without_patchlevel, :ruby_version, :engine
    include LanguagePack::ShellHelpers
    extend Forwardable
    def_delegators :@bundler_rv, :engine_version, :patchlevel

    def initialize(bundler, app = {})
      @set          = nil
      @bundler_rv   = bundler.ruby_version
      @app          = app
      set_version
      @ruby_version = @bundler_rv.version
      @engine       = @bundler_rv.engine.to_sym

      @version_without_patchlevel = @version.sub(/-p[\d]+/, '')
    end

    def default?
      @version == none
    end

    # determine if we're using jruby
    # @return [Boolean] true if we are and false if we aren't
    def jruby?
      engine == :jruby
    end

    # determine if we're using rbx
    # @return [Boolean] true if we are and false if we aren't
    def rbx?
      engine == :rbx
    end

    # determines if a build ruby is required
    # @return [Boolean] true if a build ruby is required
    def build?
      engine == :ruby && %w(1.8.7 1.9.2).include?(ruby_version)
    end

    # convert to a Gemfile ruby DSL incantation
    # @return [String] the string representation of the Gemfile ruby DSL
    def to_gemfile
      if @engine == :ruby
        "ruby '#{ruby_version}'"
      else
        "ruby '#{ruby_version}', :engine => '#{engine}', :engine_version => '#{engine_version}'"
      end
    end

    private
    def gemfile
      ruby_version = @bundler_rv.to_s.sub("p", "-p")
    end

    def none
      if @app[:is_new]
        DEFAULT_VERSION
      elsif @app[:last_version]
        @app[:last_version]
      else
        LEGACY_VERSION
      end
    end

    def set_version
      bundler_output = gemfile
      if bundler_output.empty?
        @set     = false
        @version = none
      else
        @set     = :gemfile
        @version = bundler_output.sub('(', '').sub(')', '').split.join('-')
      end
    end
  end
end
