require "rack"
require 'line/bot'
require 'rest-client'

module Line
  module Bot
    class HTTPClient
      def post(url, payload, header = {})
        Ruboty.logger.debug "======= HTTPClient#post ======="
        Ruboty.logger.debug "payload #{payload}"
        Ruboty.logger.debug "FIXIT_URL #{ENV["RUBOTY_FIXIE_URL"]}"
        RestClient.proxy = ENV["RUBOTY_FIXIE_URL"] if ENV["RUBOTY_FIXIE_URL"]
        RestClient.post(url, payload, header)
      end
    end
  end
end


module Ruboty module Adapters
	class LINE < Base
		env :RUBOTY_LINE_CHANNEL_ID,     "YOUR LINE BOT Channel ID"
		env :RUBOTY_LINE_CHANNEL_SECRET, "YOUR LINE BOT Channel Secret"
		env :RUBOTY_LINE_CHANNEL_MID,    "YOUR LINE BOT MID"
		env :RUBOTY_LINE_ENDPOINT,       "LINE bot endpoint(Callback URL). (e.g. '/ruboty/line'"
		def run
			Ruboty.logger.info "======= LINE#run ======="
			start_server
		end

		def say msg
			Ruboty.logger.info "======= LINE#say ======="

			text = msg[:body]
			to   = msg[:original][:message].from_mid

			Ruboty.logger.info "text : #{text}"
			Ruboty.logger.debug "to : #{to}"

			client.send_text(
				to_mid: to,
				text: text
			)
		end

		private
		def start_server
			Rack::Handler::Thin.run(Proc.new{ |env|
				Ruboty.logger.info "======= LINE access ======="
				Ruboty.logger.debug "env : #{env}"

				request = ::Line::Bot::Receive::Request.new(env)
				result = on_post request

				[200, {"Content-Type" => "text/plain"}, [result]]
			}, { Port: ENV["PORT"] || "8080" })
		end

		def on_post req
			Ruboty.logger.info "======= LINE#on_post ======="
			Ruboty.logger.debug "request : #{req}"

			return "OK" unless req.post? && req.fullpath == ENV["RUBOTY_LINE_ENDPOINT"]

			Ruboty.logger.debug "request.body : #{req.data}"

			req.data.each { |message|
				case message.content
				when ::Line::Bot::Message::Text
					on_message message
				end
			}

			return ""
		end

		def on_message msg
			Ruboty.logger.info "======= LINE#on_message ======="
			Ruboty.logger.debug "content : #{msg.content}"

			Thread.start {
				robot.receive(body: msg.content[:text], message: msg)
			}
		end

		def client
			@client ||= ::Line::Bot::Client.new { |config|
				config.channel_id     = ENV["RUBOTY_LINE_CHANNEL_ID"]
				config.channel_secret = ENV["RUBOTY_LINE_CHANNEL_SECRET"]
				config.channel_mid    = ENV["RUBOTY_LINE_CHANNEL_MID"]
 			}
		end
	end
end end
