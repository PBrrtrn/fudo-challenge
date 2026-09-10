require "json"
require "rack"

class App
    def call(env)
        request = Rack::Request.new env

        puts request.path_info
        not_found
    end
        
    private

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
