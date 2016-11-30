OodJobRails.configure do |config|
  config.adapter  = OodJob::Adapters::Torque
  config.dataroot = OodAppkit.dataroot
  config.clusters = OodAppkit.clusters.each_with_object({}) { |c, h| h[c.id] = c }
end
