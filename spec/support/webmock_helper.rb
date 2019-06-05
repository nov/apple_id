require 'webmock/rspec'

module WebMockHelper
  def mock_json(method, endpoint, response_file, options = {})
    stub_request(method, endpoint).to_return(
      response_for(response_file, options)
    )
    result = yield
    a_request(method, endpoint).should have_been_made.once
    result
  end

  private

  def response_for(response_file, options = {})
    response = {}
    response[:body] = File.new(File.join(File.dirname(__FILE__), '../mock_response', "#{response_file}.#{options[:format] || :json}"))
    if options[:status]
      response[:status] = options[:status]
    end
    response
  end
end

include WebMockHelper
WebMock.disable_net_connect!
