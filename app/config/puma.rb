host = ENV.fetch("HOST", "0.0.0.0")
port = ENV.fetch("PORT", 3000)

bind "tcp://#{host}:#{port}"

plugin :tmp_restart
