class GaEventsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def create
    # unless valid_request_origin?
    #   render body: nil
    #   return
    # end
    json = JSON.parse(request.raw_post)
    user_id = user_signed_in? ? current_user.id : nil
    client_id = "#{ip[0..12]}_#{json['user_agent']}_#{user_id}"
    tracker = Staccato.tracker(ENV["GA_TRACKING_ID"], client_id)
    tracker.pageview(
      path: json["path"],
      user_id: user_id,
      user_ip: ip,
      user_language: json["user_language"],
      referrer: (json["referrer"] if json["referrer"] && !json["referrer"].start_with?("https://dev.to")),
      user_agent: json["user_agent"],
      viewport_size: json["viewport_size"],
      screen_resolution: json["screen_resolution"],
      document_title: json["document_title"],
      document_encoding: json["document_encoding"],
      document_path: json["document_path"],
      cache_buster: rand(100000000000).to_s,
      data_source: "web",
    )
    logger.info("Server-Side Google Analytics Tracking - #{client_id}")
    render body: nil
  end

  def ip
    request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip
  end
end