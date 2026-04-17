class Nssh < Formula
  desc "Paste images into Claude Code over SSH"
  homepage "https://github.com/abizer/nssh"
  url "https://github.com/abizer/nssh/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "8c32292fe134b65cb958797618e7d86081b14caab94e5a8ed60ab6c948ac673b"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/nssh"
  end

  test do
    assert_match "usage: nssh", shell_output("#{bin}/nssh --help 2>&1", 1)
  end
end
