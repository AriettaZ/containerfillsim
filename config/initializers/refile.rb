Refile.store = Refile::Backend::FileSystem.new(OodAppkit.dataroot.join("attachments", "store").to_s)
Refile.cache = Refile::Backend::FileSystem.new(OodAppkit.dataroot.join("attachments", "cache").to_s)
