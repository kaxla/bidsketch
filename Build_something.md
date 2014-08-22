## 4.1 Plan it
* it should reveive an HTTP POST request from Postmark
* it should parse the JSON sent in the POST request to find the bounce id ("ID")
* it should check that the MessageID has not been re-sent already
* It should also find the CanActivate key and only continue if the value is true (this filters out stuff marked as spam, which Postmark won't let you re-activate)
* it should send a PUT request back to Postmark with PUT /bounces/{bounceID}/activate
* it should include X-Postmark-Server-Token: api_key in the headers of this PUT request so it doesn't respond with 401 Unauthorized
* it should not fail silently (meaning it should do something if it receives an error code back from the reactivate PUT request)

##4.3 Write About It

This code first takes the JSON data returned by Postmark and pulls out the bounce id and whether or not the bounce is eligible to be reactivated. If the bounce can be reactivated it sends a PUT request back to postmark to reactivate, setting the X-Postmar-Server-Token in the header to avoid an unauthorized code. Next it checks to see if the PUT was successful and then...I ran out of time.

There were a couple of things I didn't get to in my hour of coding mainly pertaining to what should happen if a) there is some sort of error after the put request to re-activate the bounce and b)if the message has already been reactivated and bounced again.  I wasn't really sure how to implement checking for b. My first idea was to just make an array of all of the message ids that have been resent and check against it for each new bounced message, but that would be super inefficient on a large scale so I didn't implement it.

###OTHER ISSUES:
* I know that Postmark is sending you back JSON data after the hook, but I don't know how to get that into a variable which is why I just have

```ruby
post_hash = JSON.parse('BOUNCE_JSON_DATA')
```
* Similarly, I'm not sure what the URI should be. I think part of it should be `/bounces/#{bounce_id}/activate` but there should probably be something before that to make it an entire path.
* I didn't do anything with security. As the Postmark docs point out, you probably don't want an open URL that anyone can send data to, so you would want to set up HTTP basic authentication.

###OTHER NOTES:
* I did not test this at all, ran out of time.
* I'm not sure using ruby's built-in Net::HTTP is the best course of action here, I also looked in to using the httparty gem but the documentation on it is terrible so I went with Net::HTTP in the end.
* I had never dealt with sending/receiving HTTP requests/responses in ruby before so there was a lot of time spent researching how to do that. I understood the concept of the request/response cycle and I've used cURL a little bit so it was mostly figuring out syntax. Sources I used are:

[http://www.sitepoint.com/ruby-net-http-library/]() - 
This is not that old, but the syntax it uses is a little different than the [docs](http://ruby-doc.org/stdlib-2.1.1/libdoc/net/http/rdoc/Net/HTTP.html). I went with the docs syntax.

[http://stackoverflow.com/questions/11403728/how-can-i-send-an-http-put-request-in-ruby]()

[http://stackoverflow.com/questions/21219313/using-webhooks-with-rails]()