# frozen_string_literal: true

class HeyDoctor::CheckApplicationHealthService
  class << self
    SUCCESS = {
      success: true,
      message: 'Application is running'
    }.freeze

    ERROR = {
      success: false,
      message: 'Application down, call the firefighters'
    }.freeze

    def call
      return SUCCESS if responding?

      ERROR
    end

    private

    def responding?
      app_http_code == '200'
    rescue StandardError
      false
    end

    def app_http_code
      port = ENV['RAILS_PORT'] || ENV['PORT']

      Net::HTTP.start('localhost', port) do |http|
        http.use_ssl = true if port.to_i == 443
        http.head('/_ah/app_health')
      end.code
    end
  end
end
