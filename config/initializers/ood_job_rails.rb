module OscHelper
  def self.get_account_name
    OodSupport::Process.groups.map(&:name).grep(/^P./).first
  end
end

OodJobRails.configure do |config|
  config.adapter  = OodJob::Adapters::Torque

  config.default_job_script = {
    accounting_id: OscHelper.get_account_name
  }
end

# clear cache
OodJobRails::Uploader.storages[:cache].clear!(older_than: Time.now - 3600) # delete files older than an hour
