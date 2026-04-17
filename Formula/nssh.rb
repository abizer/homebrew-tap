class Nssh < Formula
  desc "Paste images into Claude Code over SSH"
  homepage "https://github.com/abizer/nssh"
  url "https://github.com/abizer/nssh/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "7b7522a701d520c241392b79e7f10308ec0c561181041bd6bcd62c21695502b2"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/nssh"
  end

  test do
    assert_match "usage: nssh", shell_output("#{bin}/nssh --help 2>&1", 1)
  end
end
