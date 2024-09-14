require 'spec_helper'
require_relative '../../../libraries/onepassword'

describe Boxcutter::OnePassword do
  context '1Password Service Account token in file' do
    # let(:shellout_double) { double('Mixlib::ShellOut', run_command: nil, error!: nil, stdout: 'foo') }
    let(:shellout_double) { double('Mixlib::ShellOut') }

    before do
      allow(Chef::Config).to receive(:[]).with(:encrypted_data_bag_secret).and_return('/path/encrypted_data_bag_secret')
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/path/op_service_account_token').and_return(true)
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with('/path/op_service_account_token', 'r').and_yield(StringIO.new('service account token'))
      allow(ENV).to receive(:[]).with('OP_SERVICE_ACCOUNT_TOKEN').and_return(nil)
      allow(File).to receive(:exist?).with('/path/op_connect_host').and_return(false)
      allow(File).to receive(:exist?).with('/path/op_connect_token').and_return(false)
      allow(ENV).to receive(:[]).with('OP_CONNECT_HOST').and_return(nil)
      allow(ENV).to receive(:[]).with('OP_CONNECT_TOKEN').and_return(nil)

      # allow(Mixlib::ShellOut).to receive(:new).with('/usr/local/bin/op user get --me', env: { 'OP_SERVICE_ACCOUNT_TOKEN' => 'service account token' }).and_return(shellout_double)
      # allow(Mixlib::ShellOut).to receive(:new).with("/usr/local/bin/op read 'secret reference'", env: { 'OP_SERVICE_ACCOUNT_TOKEN' => 'service account token' }).and_return(shellout_double)

    end

    # it 'does not find a 1Password Connect host/token' do
    #   expect(described_class.op_connect_host_path).to eq('/path/op_connect_host')
    #   expect(described_class.op_connect_token_path).to eq('/path/op_connect_token')
    #   expect(described_class.op_connect_server_token_found?).to be(false)
    #   expect(File).not_to receive(:open).with('/path/op_connect_host', 'r')
    #   expect(File).not_to receive(:open).with('/path/op_connect_token', 'r')
    # end

    it 'finds a 1Password Service Account token' do
      expect(described_class.op_service_account_token_path).to eq('/path/op_service_account_token')
      expect(described_class.op_service_account_token_found?).to be(true)
      expect(described_class.token_from_env_or_file('OP_SERVICE_ACCOUNT_TOKEN', '/path/op_service_account_token')).to eq('service account token')
      # puts "MISCHA: #{described_class.token_from_env_or_file('OP_SERVICE_ACCOUNT_TOKEN', '/path/op_service_account_token')}"
      # double('Mixlib::ShellOut', run_command: nil, error!: nil, stdout: 'foo')
      # expect(described_class.op_read('secret reference')).to eq('output from op read')
      # puts "MISCHA: #{described_class.op_read('secret reference')}"
      # puts "MISCHA: #{::File.exist?('/path/op_service_account_token')}"
      # ::File.open('/path/op_service_account_token', 'r') do |file|
      #   token = file.read
      #   puts "MISCHA: #{token}"
      # end
      # puts "MISCHA: #{described_class.op_read('secret reference')}"
    end
  end
end

# describe Boxcutter::OnePassword do
#   describe 'op_read' do
#     let(:reference) { 'secret reference' }
#     let(:shellout_double) { double('Mixlib::ShellOut') }
#
#     before do
#       allow(Mixlib::ShellOut).to receive(:new).and_return(shellout_double)
#       allow(shellout_double).to receive(:run_command)
#       allow(File).to receive(:exist?).and_call_original
#     end
#
#     # context 'when no tokens are found' do
#     #   before do
#     #     allow(ENV).to receive(:[]).with('OP_SERVICE_ACCOUNT_TOKEN').and_return(nil)
#     #     allow(ENV).to receive(:[]).with('OP_CONNECT_HOST').and_return(nil)
#     #     allow(ENV).to receive(:[]).with('OP_CONNECT_TOKEN').and_return(nil)
#     #     allow(Chef::Config).to receive(:[]).with(:encrypted_data_bag_secret).and_return('/path/encrypted_data_bag_secret')
#     #     allow(File).to receive(:exist?).with('/path/op_service_account_token').and_return(false)
#     #     allow(File).to receive(:exist?).with('/path/op_connect_host').and_return(false)
#     #     allow(File).to receive(:exist?).with('/path/op_connect_token').and_return(false)
#     #   end
#     #
#     #   it 'raises an error' do
#     #   end
#     # end
#
#     context 'when a 1Password Service Account Token is found in a file' do
#       before do
#         allow(ENV).to receive(:[]).with('OP_SERVICE_ACCOUNT_TOKEN').and_return(nil)
#         allow(ENV).to receive(:[]).with('OP_CONNECT_HOST').and_return(nil)
#         allow(ENV).to receive(:[]).with('OP_CONNECT_TOKENN').and_return(nil)
#         allow(Chef::Config).to receive(:[]).with(:encrypted_data_bag_secret).and_return('/path/encrypted_data_bag_secret')
#         allow(File).to receive(:exist?).with('/path/op_service_account_token').and_return(true)
#         allow(File).to receive(:open).and_yield(StringIO.new('service_account_value'))
#         allow(File).to receive(:exist?).with('/path/op_connect_host').and_return(false)
#         allow(File).to receive(:exist?).with('/path/op_connect_token').and_return(false)
#         allow(Mixlib::ShellOut).to receive(:new).with('/usr/local/bin/op user get --me',
#                                                       anything).and_return(shellout_double)
#         allow(Mixlib::ShellOut).to receive(:new).with("/usr/local/bin/op read 'secret reference'",
#                                                       anything).and_return(shellout_double)
#       end
#
#       it 'reads the secret' do
#         expect(described_class.op_read(reference)).to eq('service_account_value')
#         expect(shellout_double).to have_received(:run_command).twice
#         expect(shellout_double).to have_received(:error!).twice
#       end
#     end
#
#     # context 'when a 1Password Service Account token is found in the environment' do
#     #   before do
#     #     allow(ENV).to receive(:[]).with('OP_SERVICE_ACCOUNT_TOKEN').and_return('service account token')
#     #     allow(ENV).to receive(:[]).with('OP_CONNECT_HOST').and_return(nil)
#     #     allow(ENV).to receive(:[]).with('OP_CONNECT_TOKENN').and_return(nil)
#     #     allow(Chef::Config).to receive(:[]).with(:encrypted_data_bag_secret).and_return('/path/encrypted_data_bag_secret')
#     #     allow(File).to receive(:exist?).with('/path/op_service_account_token').and_return(false)
#     #     allow(File).to receive(:exist?).with('/path/op_connect_host').and_return(false)
#     #     allow(File).to receive(:exist?).with('/path/op_connect_token').and_return(false)
#     #   end
#     #
#     #   it 'reads the secret' do
#     #     expect(described_class.op_read(reference)).to eq('expected_service_account_output')
#     #   end
#     # end
#   end
#
#   # describe '.op_read' do
#   # let(:reference) { 'item_name' }
#   # let(:shellout_double) { instance_double("Mixlib::ShellOut") }
#   #
#   # before do
#   #   allow(Mixlib::ShellOut).to receive(:new).and_return(shellout_double)
#   #   allow(shellout_double).to receive(:run_command)
#   #   allow(shellout_double).to receive(:error!)
#   #   allow(shellout_double).to receive(:stdout).and_return('output from op read')
#   # end
#   #
#   # context 'when no tokens are found' do
#   #   before do
#   #     allow(described_class).to receive(:op_connect_server_token_found?).and_return(false)
#   #     allow(described_class).to receive(:op_service_account_token_found?).and_return(false)
#   #   end
#   #
#   #   it 'raises an error' do
#   #     expect { described_class.op_read(reference) }.to raise_error(RuntimeError, 'polymath_onepassword[op_read]: 1Password token not found')
#   #   end
#   # end
#   #
#   # context 'when 1Password Service Account token is found' do
#   #   before do
#   #     allow(described_class).to receive(:op_connect_server_token_found?).and_return(false)
#   #     allow(described_class).to receive(:op_service_account_token_found?).and_return(true)
#   #     allow(described_class).to receive(:token_from_env_or_file).with('OP_SERVICE_ACCOUNT_TOKEN', anything()).and_return('service_account_token')
#   #   end
#   #
#   #   it 'executes op read with OP_SERVICE_ACCOUNT_TOKEN' do
#   #     expect(shellout_double).to receive(:run_command)
#   #     expect(described_class.op_read(reference)).to eq('output from op read')
#   #   end
#   # end
#   #
#   # context 'when 1Password Connect token is found' do
#   #   before do
#   #     allow(described_class).to receive(:op_connect_server_token_found?).and_return(true)
#   #     allow(described_class).to receive(:token_from_env_or_file).with('OP_CONNECT_HOST', anything()).and_return('host_value')
#   #     allow(described_class).to receive(:token_from_env_or_file).with('OP_CONNECT_TOKEN', anything()).and_return('token_value')
#   #   end
#   #
#   #   it 'executes op read with OP_CONNECT tokens' do
#   #     expect(shellout_double).to receive(:run_command)
#   #     expect(described_class.op_read(reference)).to eq('output from op read')
#   #   end
#   # end
#
#   # context 'when both OP_CONNECT and OP_SERVICE_ACCOUNT_TOKEN are found' do
#   #   before do
#   #     allow(described_class).to receive(:op_connect_server_token_found?).and_return(true)
#   #     allow(described_class).to receive(:op_service_account_token_found?).and_return(true)
#   #     allow(described_class).to receive(:token_from_env_or_file).with('OP_CONNECT_HOST', anything()).and_return('host_value')
#   #     allow(described_class).to receive(:token_from_env_or_file).with('OP_CONNECT_TOKEN', anything()).and_return('token_value')
#   #     allow(described_class).to receive(:token_from_env_or_file).with('OP_SERVICE_ACCOUNT_TOKEN', anything()).and_return('service_account_token')
#   #   end
#   #
#   #   it 'prefers OP_CONNECT tokens over OP_SERVICE_ACCOUNT_TOKEN' do
#   #     environment = {
#   #       'OP_CONNECT_HOST' => 'host_value',
#   #       'OP_CONNECT_TOKEN' => 'token_value'
#   #     }
#   #     command = "/usr/local/bin/op read '#{reference}'"
#   #
#   #     expect(Mixlib::ShellOut).to receive(:new).with(command, env: environment).and_return(shellout_double)
#   #     expect(shellout_double).to receive(:run_command)
#   #     described_class.op_read(reference)
#   #   end
#   # end
#   # end
# end
