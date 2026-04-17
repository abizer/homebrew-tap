class Nssh < Formula
  desc "Paste images into Claude Code over SSH"
  homepage "https://github.com/abizer/nssh"
  url "https://github.com/abizer/nssh/archive/refs/tags/v1.4.0.tar.gz"
  sha256 "b0d5c95f29d913579ef89622728b9f96d4f2152cb85cc712258dc7fde9d18b30"
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
