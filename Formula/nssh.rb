class Nssh < Formula
  desc "Paste images into Claude Code over SSH"
  homepage "https://github.com/abizer/nssh"
  url "https://github.com/abizer/nssh/archive/refs/tags/v1.3.0.tar.gz"
  sha256 "02a8639b2f6fe011d74aa119349bde173b3edc74b4fc8e05b3cf924aeede6e99"
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
