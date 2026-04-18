class Nssh < Formula
  desc "Paste images into Claude Code over SSH"
  homepage "https://github.com/abizer/nssh"
  url "https://github.com/abizer/nssh/archive/refs/tags/v2.0.1.tar.gz"
  sha256 "4ad5db6849972f5bdbac17ffdc336b0973b4f135576293c65620f5393ba4f903"
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
