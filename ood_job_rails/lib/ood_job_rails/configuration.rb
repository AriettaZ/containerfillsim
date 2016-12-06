require 'ood_job'

module OodJobRails
  # An object that stores and adds configuration options
  module Configuration
    # Adapter used for job management with the resource manager
    # @return [OodJob::Adapter] job adapter
    attr_accessor :adapter

    # Location where app data is stored on local filesystem
    # @return [Pathname, nil] path to app data
    def dataroot
      Pathname.new(@dataroot) if @dataroot
    end
    attr_writer :dataroot


    # Cluster information for local HPC center
    # @return [Hash{Symbol=>OodCluster::Cluster}] hash of available clusters
    attr_accessor :clusters

    attr_accessor :default_job_script

    def storages
      @storages || {
        cache: Uploader::Storage::FileSystem.new(dataroot.join("attachments").to_s, prefix: "cache"),
        store: Uploader::Storage::FileSystem.new(dataroot.join("attachments").to_s, prefix: "store")
      }
    end
    attr_writer :storages

    # Customize configuration for this object
    # @yield [self]
    def configure
      yield self
    end

    # Sets the default configuration for this object
    # @return [void]
    def set_default_configuration
      self.adapter  = OodJob::Adapters::Torque
      self.dataroot = ENV['OOD_DATAROOT']
      self.clusters = {}
      self.default_job_script = {}
    end
  end
end
