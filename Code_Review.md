## Code Review

**What does it do?**
It's the controller for the "portal" model, meaning it retreives and sets all the information about a user's various proposals. 

It retreives all of the proposals and their comments along with information about the status (viewed, accepted, etc). Then based on user input it sets information about things like what optional fees are added on, if/when it has been visited or accepted by the client, what the status of the proposal is, etc.

**What do I like about it?**
A lot of stuff is taken out into before filters, that's nice for readability. Also nice for readability, it's not trying to play Ruby golf. It's cool to be able to get your method down to one line I guess and I can see the value in attempting to do so as an exercise, but no one can quickly figure out what shit like this does:

```ruby
def zeros(n, pow = 5)
  pow <= n ? zeros(n, pow * 5) + (n/pow).floor : 0
end
```

(it calculates the number of trailing zeros in a factorial of a given number. I encountered this problem/solution on codewars recently)

**What don't I like about it?**
It seems like there is some logic in here that could be moved to the model.  For instance:

This little bit that creates a new visit to the proposal could probably be made into a method in the model and taken out of the conroller:

```ruby
proposal_visit = ProposalVisit.create( :client => proposal.client
    :proposal => proposal,
    :http_agent => request.env['HTTP_USER_AGENT'],
    :ip_address => request.remote_ip,
    :session_id => request.session_options[:id],
    :left_at => Time.now,
    :email => session[:email] ||= current_user.email ) if proposal
```
    
    
Something like this:

```ruby
#app/models/portal.rb
def create_visit
  proposal_visit = ProposalVisit.create( :client => proposal.client,
                                         :proposal => proposal,
                                         :http_agent => request.env['HTTP_USER_AGENT'],
                                         :ip_address => request.remote_ip,
                                         :session_id => request.session_options[:id],
                                         :left_at => Time.now,
                                         :email => session[:email] ||= current_user.email ) if proposal
end


#app/controllers/portal_controller.rb
def record_visit(params = {:proposal => nil})
  proposal = params[:proposal]

  # First try to retrieve current visit.
  proposal_visit = current_user.current_visit( :proposal_id => proposal.id,
                                               :email => session[:email],
                                               :session_id => request.session_options[:id]
)
# if there is no current visit, create one.
  if proposal_visit.blank?
    begin
      create_visit
    rescue Exception => e
      notify_honeybadger(e)
    end
  end
 
  return proposal_visit
end
```