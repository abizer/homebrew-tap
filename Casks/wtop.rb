cask "wtop" do
  version "0.2.0"
  sha256 :no_check

  url "https://github.com/abizer/wtop/releases/download/v#{version}/wtop.app.zip"
  name "wtop"
  desc "Real-time power monitor for Apple Silicon Macs"
  homepage "https://github.com/abizer/wtop"

  depends_on macos: ">= :sonoma"
  depends_on arch: :arm64

  app "wtop.app"

  postflight do
    set_permissions "#{appdir}/wtop.app/Contents/Helpers/wtop-helper", "0755"
  end

  caveats <<~EOS
    For full system process energy data, install the privileged helper:
      sudo #{appdir}/wtop.app/Contents/Helpers/install-helper.sh

    The helper runs on-demand (only while wtop is open) and auto-exits
    30 seconds after the app closes.
  EOS

  uninstall launchctl: "me.abizer.wtop.helper",
            delete:    "/Library/PrivilegedHelperTools/me.abizer.wtop.helper",
            trash:     "/Library/LaunchDaemons/me.abizer.wtop.helper.plist"

  zap trash: [
    "~/Library/Preferences/me.abizer.wtop.plist",
    "~/Library/Caches/me.abizer.wtop",
  ]
end
