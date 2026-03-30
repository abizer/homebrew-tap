cask "wtop" do
  version "0.3.0"
  sha256 "31e9a34a402e862bef2a7212cb00d1ef38ebd7ee0235a883223b6135d26bee53"

  url "https://github.com/abizer/wtop/releases/download/v#{version}/wtop.app.zip"
  name "wtop"
  desc "Real-time power monitor for Apple Silicon Macs"
  homepage "https://github.com/abizer/wtop"

  depends_on macos: ">= :sonoma"
  depends_on arch: :arm64

  app "wtop.app"

  postflight do
    # Strip quarantine — app is ad-hoc signed, not notarized
    system_command "/usr/bin/xattr",
                   args: ["-r", "-d", "com.apple.quarantine", "#{appdir}/wtop.app"]
    # Install privileged helper daemon (prompts for password)
    system_command "#{appdir}/wtop.app/Contents/Resources/install-helper.sh",
                   sudo: true
  end

  caveats <<~EOS
    The privileged helper has been installed. It runs on-demand (only
    while wtop is open) and auto-exits 30 seconds after the app closes.
  EOS

  uninstall launchctl: "me.abizer.wtop.helper",
            delete:    "/Library/PrivilegedHelperTools/me.abizer.wtop.helper",
            trash:     "/Library/LaunchDaemons/me.abizer.wtop.helper.plist"

  zap trash: [
    "~/Library/Preferences/me.abizer.wtop.plist",
    "~/Library/Caches/me.abizer.wtop",
  ]
end
