require "json"
require "rack"

require_relative "router"

PUBLIC_DIR = File.expand_path("public", __dir__)

PUBLIC_ENDPOINTS = ["/login", "/users"].freeze

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
    def initialize(router, users_repository)
        @router = router
        @users_repository = users_repository
    end

    def call(env)
        request = Rack::Request.new env
        puts request.path_info

        if STATIC_FILES.key? request.path_info
            serve_static_file STATIC_FILES[request.path_info]
        else
            unless PUBLIC_ENDPOINTS.include?(request.path_info)
                auth_error = authorize(env)
                return auth_error if auth_error
            end

            @router.call(env)
        end
    end
        
    private

    def authorize(env)
        token = session_token(env)
        return json_response(401, {error: "Unauthorized"}) if token.nil? || token.empty?

        user = @users_repository.find_by_session_token(token)
        return json_response(403, {error: "Forbidden"}) if user.nil?

        nil
    end

    def session_token(env)
        authorization = env["HTTP_AUTHORIZATION"]
        return nil if authorization.nil?

        scheme, token = authorization.split(" ", 2)
        return token if scheme&.casecmp("Bearer")&.zero?

        nil
    end

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
