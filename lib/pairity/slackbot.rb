require 'slack-poster'

module Pairity
  class Slackbot

    def initialize
      Config.load
      hook = Config.get(:url)
      options = {
        icon_url: 'https://static1.squarespace.com/static/54e22d6be4b00617871820ca/54e567bbe4b022f3194c63b5/55ddd86ae4b0f0c3127f8483/1440605037480/?format=1000w',
        username: 'Pairity',
        channel: slack_channel
      }
      @poster = Slack::Poster.new(hook, options)
    end

    def post(message)
      @poster.send_message(message)
    end

    def slack_channel
      channel = Config.get(:channel)
      return "#" + channel unless channel =~ /^#/
      channel
    end

  end
end
