class Heycx < Formula
  desc "Opinionated utility toolkit that makes developer life better"
  homepage "https://github.com/ch0ngxian/homebrew-heycx"
  url "https://github.com/ch0ngxian/homebrew-heycx/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "4eba1d3d27103a63fa93b3753f5f46253cff68c459334a25c078137eaa2b16e6"
  license "MIT"
  version "1.0.1"

  bottle do
    root_url "https://github.com/ch0ngxian/homebrew-heycx/releases/download/v1.0.1"
    sha256 cellar: :any_skip_relocation, all: "94a20debd89ce11f773af14f23e1d2da4a9b6811fb9a6db607d8acde49d3dddd"
  end

  def install
    bin.install "heycx"
  end

  def caveats
    <<~EOS
      heycx - Opinionated utility toolkit

      Commands:
        heycx hotfix start     Start a new hotfix branch
        heycx hotfix finish    Complete hotfix (merge to master & develop)
        heycx sync             Update master & develop branches

      Note: 'heycx hotfix finish' uses gh CLI for deployment triggers.
      Run 'gh auth login' if not already authenticated.
    EOS
  end

  test do
    assert_match "heycx", shell_output("#{bin}/heycx --help")
    assert_match version.to_s, shell_output("#{bin}/heycx --version")
  end
end
