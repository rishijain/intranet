if Rails.env!= 'production'
  GOOGLE_APP_ID = "1071290624779-83kdqqic2n53ejdpapg78t32dl1v8l0g.apps.googleusercontent.com"
  GOOGLE_APP_SECRET = "7G9YaB6K3Ec4r9hnPpCOmVnw"
  #GOOGLE_APP_ID = "329232665779.apps.googleusercontent.com"
  #GOOGLE_APP_SECRET = "n2p9Gaf4ttIvmWWQGlvEq8d1"
end

GOOGLE_APT_REDIRECT_URL= "http://intranet.joshsoftware.com/google/auth_api"