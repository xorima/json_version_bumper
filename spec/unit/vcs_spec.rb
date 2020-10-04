# frozen_string_literal: true

require 'spec_helper'

describe JsonVersionBumper::Vcs, :vcr do
  # Check Vcs creates an OctoKit client
  before(:each) do
    release = { 'base' => { 'ref' => 'master', 'repo' => { 'default_branch' => 'master', 'full_name' => 'Xorima/xor_test_cookbook' } },
                     'head' => { 'sha' => '202ae3fd1b76a28c9272372a29ae9b8070a79f48' },
                     'number' => 22 }
    @vcs_client = JsonVersionBumper::Vcs.new({
                                            token: ENV['GITHUB_TOKEN'] || 'temp_token',
                                            repository: 'xorima/xor_test_cookbook',
                                          })
  end

  it 'creates an octkit client' do
    expect(@vcs_client).to be_kind_of(JsonVersionBumper::Vcs)
  end

  it 'gets the contents and sha as expected' do
    file_contents = @vcs_client.get_file_contents('app_versions.json')
    expect(file_contents['sha']).to eq 'e2b7c3e3f5a070c10c9a1c46c21c89016dafc4c9'
    expect(file_contents['content']['xor_test_cookbook']).to eq '0.1.5'
  end

  it 'updates the contents of the file when requested to' do
    update = @vcs_client.update_file('app_versions.json', {'app_name' => 'xor_test_cookbook', 'version' => 'unit_test'})
    puts(update)
    expect(update).to eq 'Updated app xor_test_cookbook to unit_test'
  end
end
