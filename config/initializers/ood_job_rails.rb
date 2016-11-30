module OscHelper
  def self.get_account_name
    OodSupport::Process.groups.map(&:name).grep(/^P./).first
  end
end

OodJobRails.configure do |config|
  config.adapter  = OodJob::Adapters::Torque
  config.dataroot = OodAppkit.dataroot
  config.clusters = OodAppkit.clusters.each_with_object({}) { |c, h| h[c.id] = c }

  config.default_job_script = {
    accounting_id: OscHelper.get_account_name
  }
end
