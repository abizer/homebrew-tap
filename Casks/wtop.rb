cask "wtop" do
  version "0.4.1"
  sha256 "f7b8b71373a9eae33c4557d4c300f874a20b387e001bb2b90aba664e9014cfdb"

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

  uninstall launchctl: "me.abizer.wtop.helper",
            delete:    "/Library/PrivilegedHelperTools/me.abizer.wtop.helper",
            trash:     "/Library/LaunchDaemons/me.abizer.wtop.helper.plist"

  zap trash: [
    "~/Library/Caches/me.abizer.wtop",
    "~/Library/Preferences/me.abizer.wtop.plist",
  ]

  caveats <<~EOS
    The privileged helper has been installed. It runs on-demand (only
    while wtop is open) and auto-exits 30 seconds after the app closes.
  EOS
end
