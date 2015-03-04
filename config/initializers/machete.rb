class OSC::Machete::Crimson
  def initialize(portal, user = nil)
    @portal = portal
    @user = user || OSC::Machete::User.new

    @files_path = Pathname.new(ENV["RAILS_DATAROOT"])
    @config_path = Pathname.new(ENV["RAILS_DATAROOT"]).join(".cfg")
  end
end
