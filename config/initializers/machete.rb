# Ugly monkey patch to allow Machete read in environment
# variable for the data root
class OSC::Machete::Crimson
  def initialize(portal, user = nil)
    @portal = portal
    @user = user || OSC::Machete::User.new

    @files_path = Pathname.new(AwesimRails.dataroot)
    @config_path = Pathname.new(AwesimRails.dataroot).join(".cfg")
  end
end
