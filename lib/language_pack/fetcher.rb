require "yaml"
require "language_pack/shell_helpers"

module LanguagePack
  class Fetcher
    include ShellHelpers

    DEFAULT_BOOTSTRAP_FILE = File.expand_path("../../../config/fetchers.yml", __FILE__)

    def self.bootstrap(file = DEFAULT_BOOTSTRAP_FILE)
      fetchers = {}
      (YAML.load_file(file) || {}).each do |key, url|
        fetchers[key] = new(url)
      end

      fetchers
    end

    def initialize(host_url)
      @host_url = host_url
    end

    def fetch(path)
      run("curl -O #{@host_url}/#{path}")
    end

    def fetch_untar(path)
      run("curl #{@host_url}/#{path} -s -o - | tar zxf -")
    end

    def fetch_bunzip2(path)
      run("curl #{@host_url}/#{path} -s -o - | tar jxf -")
    end
  end
end
