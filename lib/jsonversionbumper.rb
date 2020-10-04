# frozen_string_literal: true

require 'sinatra'

require_relative 'jsonversionbumper/vcs'
require_relative 'jsonversionbumper/hmac'

get '/' do
  'Alive'
end

post '/handler' do
  return halt 500, "Signatures didn't match!" unless validate_request(request)

  payload = JSON.parse(params[:payload])
  case request.env['HTTP_X_GITHUB_EVENT']
  when 'release'
    return "Unhandled action: #{payload['action']}" unless payload['action'] == 'released'

    vcs = JsonVersionBumper::Vcs.new(token: ENV['GITHUB_TOKEN'], repository: ENV['TARGET_REPO'])
    release_metadata = gather_release_metadata(payload)
    response = vcs.update_file(ENV['JSON_FILE_PATH'], release_metadata)
    return halt 500, 'Error updating file, see server logs for details' if response == 'Error'

    return response
  end
  return "Unhandled event: #{request.env['HTTP_X_GITHUB_EVENT']}"
end

def gather_release_metadata(payload)
  response = {}
  response['app_name'] = payload['repository']['name']
  response['version'] = payload['release']['tag_name']
  response
end

def validate_request(request)
  true unless ENV['SECRET_TOKEN']
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
end
