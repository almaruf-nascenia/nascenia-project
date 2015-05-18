Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env == "development"
    provider :google_oauth2, "422289888657-pt064766l8lt97f965hi9d298pskpm3a.apps.googleusercontent.com", "pfT0D9p2AJxXCGAyzEbSvplJ"
  elsif Rails.env == "staging"
    provider :google_oauth2, "422289888657-pt064766l8lt97f965hi9d298pskpm3a.apps.googleusercontent.com", "pfT0D9p2AJxXCGAyzEbSvplJ"
  end
end