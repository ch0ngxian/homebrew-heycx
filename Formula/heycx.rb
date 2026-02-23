class Heycx < Formula
  desc "Opinionated utility toolkit that makes developer life better"
  homepage "https://github.com/ch0ngxian/homebrew-heycx"
  url "https://github.com/ch0ngxian/homebrew-heycx/archive/refs/tags/v1.2.0.tar.gz"
  sha256 "7dc384be2e76fddbbb14d98f8e5b70eb6d203d1390e65638011dc35fc8dad9b7"
  license "MIT"
  version "1.2.0"

  def install
    bin.install "heycx"
  end

  def caveats
    <<~EOS
      heycx - Opinionated utility toolkit

      Commands:
        heycx hotfix start [name]  Start a new hotfix branch
        heycx hotfix finish        Complete hotfix (merge to master & develop)
        heycx pr create            Create a GitHub pull request
        heycx sync                 Update master & develop branches

      Note: 'heycx hotfix finish' uses gh CLI for deployment triggers.
      Run 'gh auth login' if not already authenticated.
    EOS
  end

  test do
    assert_match "heycx", shell_output("#{bin}/heycx --help")
    assert_match version.to_s, shell_output("#{bin}/heycx --version")
  end
end
