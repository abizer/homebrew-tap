class Wtop < Formula
  desc "Real-time power monitor for Apple Silicon Macs"
  homepage "https://github.com/abizer/wtop"
  url "https://github.com/abizer/wtop/archive/refs/tags/v0.2.0.tar.gz"
  license "MIT"

  depends_on arch: :arm64
  depends_on :macos

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"

    bin_path = Utils.safe_popen_read(
      "swift", "build", "-c", "release", "--disable-sandbox", "--show-bin-path"
    ).strip

    bin.install "#{bin_path}/wtop"
    libexec.install "#{bin_path}/wtop-helper"

    # Build .app bundle BEFORE etc.install (which moves the file)
    plist_src = buildpath/"support/me.abizer.wtop.helper.plist"
    app_dir = prefix/"wtop.app/Contents"
    (app_dir/"MacOS").mkpath
    (app_dir/"Helpers").mkpath
    (app_dir/"Resources").mkpath
    cp bin/"wtop", app_dir/"MacOS/wtop"
    cp libexec/"wtop-helper", app_dir/"Helpers/wtop-helper"
    cp buildpath/"Info.plist", app_dir/"Info.plist"
    cp plist_src, app_dir/"Resources/me.abizer.wtop.helper.plist"
    system "codesign", "--force", "--sign", "-", prefix/"wtop.app"

    # Install plist and helper installer to etc/libexec
    (etc/"wtop").install plist_src
    libexec.install buildpath/"support/install-helper.sh" => "wtop-helper-install"
  end

  def post_install
    # Symlink .app to ~/Applications for Spotlight
    apps_dir = File.expand_path("~/Applications")
    mkdir_p apps_dir
    rm_r "#{apps_dir}/wtop.app" if File.exist?("#{apps_dir}/wtop.app")
    ln_sf "#{prefix}/wtop.app", "#{apps_dir}/wtop.app"

    # Install privileged helper if running as root (sudo brew install)
    if Process.uid.zero?
      helper_dest = "/Library/PrivilegedHelperTools/me.abizer.wtop.helper"
      plist_dest = "/Library/LaunchDaemons/me.abizer.wtop.helper.plist"

      mkdir_p "/Library/PrivilegedHelperTools"
      cp libexec/"wtop-helper", helper_dest
      chmod 0755, helper_dest
      cp etc/"wtop/me.abizer.wtop.helper.plist", plist_dest

      begin
        system "launchctl", "bootout", "system/me.abizer.wtop.helper"
      rescue ErrorDuringExecution
        nil
      end
      system "launchctl", "bootstrap", "system", plist_dest
      ohai "Privileged helper installed (on-demand)"
    end
  end

  def caveats
    if Process.uid.zero?
      <<~EOS
        wtop is installed with full privileges:

          CLI:  wtop
          GUI:  Search "wtop" in Spotlight/Raycast

        The privileged helper runs on-demand (only while wtop is open)
        and auto-exits 30 seconds after the app closes.

        To uninstall the helper:
          sudo launchctl bootout system/me.abizer.wtop.helper
          sudo rm -f /Library/PrivilegedHelperTools/me.abizer.wtop.helper
          sudo rm -f /Library/LaunchDaemons/me.abizer.wtop.helper.plist
      EOS
    else
      <<~EOS
        wtop is installed as both a CLI tool and a GUI app:

          CLI:  wtop
          GUI:  Search "wtop" in Spotlight/Raycast

        For full system process energy data, install the privileged helper:

          sudo brew postinstall abizer/tap/wtop

        Or manually:

          sudo #{libexec}/wtop-helper-install
      EOS
    end
  end

  test do
    assert_predicate bin/"wtop", :executable?
    assert_predicate libexec/"wtop-helper", :executable?
  end
end
