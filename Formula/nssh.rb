class Nssh < Formula
  desc "Paste images into Claude Code over SSH"
  homepage "https://github.com/abizer/nssh"
  url "https://github.com/abizer/nssh/archive/refs/tags/v2.0.0.tar.gz"
  sha256 "90a7fec78575764a3aa8e2454f9e825403c9b92871da67ace8aa891d97607a6c"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build",
      *std_go_args(ldflags: "-s -w -X main.buildVersion=v#{version}"),
      "./cmd/nssh"
  end

  test do
    assert_match "usage: nssh", shell_output("#{bin}/nssh --help 2>&1", 1)
  end
end
