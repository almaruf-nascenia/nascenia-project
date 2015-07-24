Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env == "development"
    provider :google_oauth2, '859503770764-bpatuj1j8prr1gadqgeid6lflls4esru.apps.googleusercontent.com', 'AhkPDlFTXff-lfItWGJf4X8I'
  elsif Rails.env == "staging"
    provider :google_oauth2, '531476693694-p75kjs26m538nfdf4qa5v5q49ddnq4rs.apps.googleusercontent.com', 'bx8atFsQrsnnp_Ke7Ku8FLV3'
  end
end