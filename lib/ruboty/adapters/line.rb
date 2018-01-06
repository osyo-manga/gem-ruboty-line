require "rack"
require 'line/bot'
require 'rest-client'


module Ruboty module Adapters
	class LINE < Base
		env :RUBOTY_LINE_CHANNEL_SECRET, "YOUR LINE BOT Channel Secret"
		env :RUBOTY_LINE_CHANNEL_TOKEN,  "YOUR LINE BOT Channel token"
		env :RUBOTY_LINE_ENDPOINT,       "LINE bot endpoint(Callback URL). (e.g. '/ruboty/line'"
		def run
			Ruboty.logger.info "======= LINE#run ======="
			start_server
		end

		def say msg
			Ruboty.logger.info "======= LINE#say ======="

			Ruboty.logger.info "msg : #{msg}"
			text = msg[:body]
			to   = msg[:to]

			Ruboty.logger.info "text : #{text}"
			Ruboty.logger.debug "to : #{to}"

			client.reply_message(to, {
				type: "text",
				text: text,
			})
		end

		private
		def start_server
			Rack::Handler::Thin.run(proc { |env|
				Ruboty.logger.info "======= LINE access ======="
				Ruboty.logger.debug "env : #{env}"

				request = Rack::Request.new(env)
				Ruboty.logger.debug "request : #{request}"

				result = on_post request

				[200, {"Content-Type" => "text/plain"}, [result]]
			}, { Port: ENV["PORT"] || "8080" })
		end

		def on_post request
			Ruboty.logger.info "======= LINE#on_post ======="

			Ruboty.logger.debug "request.fullpath : #{request.fullpath}"
			Ruboty.logger.debug "request.post? : #{request.post?}"
			Ruboty.logger.debug "RUBOTY_LINE_ENDPOINT : #{ENV["RUBOTY_LINE_ENDPOINT"]}"

			return "OK" unless request.post? && request.fullpath == ENV["RUBOTY_LINE_ENDPOINT"]

			body = request.body.read
			Ruboty.logger.debug "request.body : #{body}"

			events = client.parse_events_from(body)
			

			events.each { |event|
				Ruboty.logger.debug "event : #{event}"
				case event
				when ::Line::Bot::Event::Message
					case event.type
					when ::Line::Bot::Event::MessageType::Text
						on_message event
					end
				end
			}

			return ""
		end

		def on_message event
			Ruboty.logger.info "======= LINE#on_message ======="

			Thread.start {
				robot.receive(
					body: event.message["text"],
					from: event["replyToken"],
					to:   event["replyToken"],
					event: event
				)
			}
		end

		def client
			@client ||= ::Line::Bot::Client.new { |config|
				config.channel_secret = ENV["RUBOTY_LINE_CHANNEL_SECRET"]
				config.channel_token  = ENV["RUBOTY_LINE_CHANNEL_TOKEN"]
 			}
		end
	end
end end
