require "json"
require "rack"

require_relative "router"

PUBLIC_DIR = File.expand_path("public", __dir__)

STATIC_FILES = {
    "/AUTHORS" => {
        disk_path: File.join(PUBLIC_DIR, "AUTHORS"),
        cache_control: "public, max-age=#{24 * 60 * 60}"
    },
    "/openapi.yaml" => {
        disk_path: File.join(PUBLIC_DIR, "openapi.yaml"),
        cache_control: "no-store, no-cache, must-revalidate, max-age=0"
    }
}.freeze

class App
    def initialize(router)
        @router = router
    end

    def call(env)
        request = Rack::Request.new env
        puts request.path_info

        if STATIC_FILES.key? request.path_info
            serve_static_file STATIC_FILES[request.path_info]
        else
            @router.call(env)
        end
    end
        
    private

    def serve_static_file(file)
        return not_found unless File.exist? file[:disk_path]

        body = File.binread(file[:disk_path])
        headers = {
            "Content-Type" => "text/html; charset=UTF-8",
            "Cache-Control" => file[:cache_control],
            "Content-Length" => body.bytesize.to_s
        }

        [200, headers, [body]]
    end

    def not_found
        json_response(404, {error: "404 - Not Found"})
    end

    def json_response(status, payload)
        body = payload.to_json
        [status, json_header(body), [body]]
    end

    def json_header(body)
        {
        "Content-Type" => "application-json",
        "Content-Length" => body.bytesize.to_s
        }
    end

end
