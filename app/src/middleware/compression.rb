require "zlib"

class CompressionMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call env

    accept_encoding = env["HTTP_ACCEPT_ENCODING"]
    return [status, headers, body] unless accept_encoding&.include?("gzip")
    return [status, headers, body] if headers["Content-Encoding"]

    body_content = +""
    body.each do |chunk|
      body_content << chunk
    end

    compressed_body = Zlib.gzip body_content

    headers = headers.dup
    headers["Content-Encoding"] = "gzip"
    headers["Content-Length"] = compressed_body.bytesize.to_s
    
    [status, headers, [compressed_body]]
  end
end