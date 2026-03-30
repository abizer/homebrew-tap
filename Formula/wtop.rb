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

    debug = []
    debug << "bin_path=#{bin_path}"
    debug << "wtop_exists=#{File.exist?("#{bin_path}/wtop")}"
    debug << "helper_exists=#{File.exist?("#{bin_path}/wtop-helper")}"
    debug << "plist_exists=#{File.exist?(buildpath/"support/me.abizer.wtop.helper.plist")}"

    begin
      bin.install "#{bin_path}/wtop"
      debug << "bin.install OK"
    rescue => e
      debug << "bin.install FAILED: #{e.class} #{e.message}"
    end

    begin
      libexec.install "#{bin_path}/wtop-helper"
      debug << "libexec.install OK"
    rescue => e
      debug << "libexec.install FAILED: #{e.class} #{e.message}"
    end

    begin
      (etc/"wtop").install buildpath/"support/me.abizer.wtop.helper.plist"
      debug << "etc.install OK"
    rescue => e
      debug << "etc.install FAILED: #{e.class} #{e.message}"
    end

    begin
      app_dir = prefix/"wtop.app/Contents"
      (app_dir/"MacOS").mkpath
      (app_dir/"Helpers").mkpath
      (app_dir/"Resources").mkpath
      cp bin/"wtop", app_dir/"MacOS/wtop"
      cp libexec/"wtop-helper", app_dir/"Helpers/wtop-helper"
      cp buildpath/"Info.plist", app_dir/"Info.plist"
      cp buildpath/"support/me.abizer.wtop.helper.plist", app_dir/"Resources/me.abizer.wtop.helper.plist"
      system "codesign", "--force", "--sign", "-", prefix/"wtop.app"
      debug << "app bundle OK"
    rescue => e
      debug << "app bundle FAILED: #{e.class} #{e.message}"
    end

    File.write("/tmp/wtop-debug.txt", debug.join("\n") + "\n")
  end

  def post_install
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

    apps_dir = File.expand_path("~/Applications")
    mkdir_p apps_dir
    rm_r "#{apps_dir}/wtop.app" if File.exist?("#{apps_dir}/wtop.app")
    ln_sf "#{prefix}/wtop.app", "#{apps_dir}/wtop.app"
  end

  def caveats
    <<~EOS
      wtop is installed as both a CLI tool and a GUI app:

        CLI:  wtop
        GUI:  Search "wtop" in Spotlight/Raycast

      A privileged helper runs on-demand (only while wtop is open)
      to provide system process energy data. It auto-exits 30s after
      the app closes.

      To fully uninstall (remove the helper daemon):
        sudo launchctl bootout system/me.abizer.wtop.helper
        sudo rm -f /Library/PrivilegedHelperTools/me.abizer.wtop.helper
        sudo rm -f /Library/LaunchDaemons/me.abizer.wtop.helper.plist
        rm -f ~/Applications/wtop.app
    EOS
  end

  test do
    assert_predicate bin/"wtop", :executable?
    assert_predicate libexec/"wtop-helper", :executable?
  end
end
