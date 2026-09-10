require "rack"
require "rack/reloader"
require_relative "src/app"

use Rack::Reloader, 0
use Rack::CommonLogger

static_directory = Rack::Directory.new("src/public")
app = App.new

STATIC_FILE_CACHE_RULES = {
    "/AUTHORS" => "no-store, no-cache, must-revalidate, max-age=0",
    "/openapi.yaml" => "public, max-age=#{24 * 60 * 60}"
}

run lambda { |env|
    status, headers, body = static_directory.call(env)

    if status == 404
        app.call(env)
    else
        requested_path = env["PATH_INFO"]
        if STATIC_FILE_CACHE_RULES.key?(requested_path)
            headers["cache-control"] = STATIC_FILE_CACHE_RULES[requested_path]
        end
        
        [status, headers, body]
    end
}
