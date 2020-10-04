# frozen_string_literal: true

require 'octokit'
require 'base64'
require 'json'

module JsonVersionBumper
  # Used to handle calls to VCS
  class Vcs
    def initialize(token:, repository:)
      @client = Octokit::Client.new(access_token: token)
      @repository_name = repository
      @default_branch = default_branch(repository)
    end

    def default_branch(repository)
      repo = @client.repository(repository)
      repo[:default_branch]
    end

    def get_file_contents(file_path)
      versions_content = @client.contents(@repository_name, path: file_path, ref: @default_branch)
      json_contents = base64_to_hash(versions_content[:content])
      response = {}
      response['content'] = json_contents
      response['sha'] = versions_content[:sha]
      response
    end

    def base64_to_hash(content)
      plain = Base64.decode64(content)
      JSON.parse(plain)
    end

    def update_file_contents(file_path, commit_message, file_sha, file_content)
      begin
        @client.update_contents(@repository_name, file_path,
                                commit_message, file_sha, file_content, branch: @default_branch)
      rescue StandardError => e
        puts(e)
        return e
      end
      commit_message
    end

    def update_file(file_path, metadata)
      file = get_file_contents(file_path)
      file['content'][metadata['app_name']] = metadata['version']
      file['encoded'] = file['content'].to_json
      commit_message = "Updated app #{metadata['app_name']} to #{metadata['version']}"
      update_file_contents(file_path, commit_message, file['sha'], file['encoded'])
    end
  end
end
