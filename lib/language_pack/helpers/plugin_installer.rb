require "language_pack/shell_helpers"

module LanguagePack
  module Helpers
    # Takes an array of plugin names and a fetcher
    # fetches plugins from fetcher, installs them
    class PluginsInstaller
      attr_accessor :plugins, :fetcher
      include LanguagePack::ShellHelpers

      def initialize(plugins, fetcher)
        @plugins    = plugins || []
        @vendor_url = vendor_url
      end

      # vendors all the plugins into the slug
      def install
        return true unless plugins.any?
        plugins.each { |plugin| vendor(plugin) }
      end

      def plugin_dir(name = "")
        Pathname.new("vendor/plugins").join(name)
      end

      # vendors an individual plugin
      # @param [String] name of the plugin
      def vendor(name)
        directory = plugin_dir(name)
        return true if directory.exist?
        directory.mkpath
        Dir.chdir(directory) do |dir|
          fetcher.fetch_untar("#{name}.tgz")
        end
      end
    end
  end
end
