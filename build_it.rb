require 'net/http'

class HooksController
  def bounce_callback
    post_hash = JSON.parse('BOUNCE_JSON_DATA')
    bounce_id = post_hash["ID"]
    if post_hash["CanActivate"] == true
      #send PUT request back to Postmark to reactivate the bounce
      uri = URI("/bounces/#{bounce_id}/activate")
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Put.new(uri)
        #setting HTTP headers
        request['X-Postmark-Server-Token'] = API_KEY
        #creating response object
        response = Net::HTTP.get_response(uri)
      end
    end
    #check the response for error code
    if response.code == 422
      #Do something?
    end
  end
end
