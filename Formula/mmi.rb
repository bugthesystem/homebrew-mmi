class Mmi < Formula
  desc "Me, Myself and I — strip AI trails from your git commits"
  homepage "https://github.com/bugthesystem/mmi"
  url "https://github.com/bugthesystem/mmi/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "d44697efdc0e4017bd972f86c47890f5a12c874e4aac347d5169158073e45401"
  license "MIT"
  head "https://github.com/bugthesystem/mmi.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "mmi #{version}", shell_output("#{bin}/mmi --version") unless build.head?

    # `mmi clean` strips a known AI trailer and leaves the subject intact.
    (testpath/"msg.txt").write <<~MSG
      feat: brew test

      Body.

      Co-authored-by: Claude <noreply@anthropic.com>
    MSG
    cleaned = shell_output("#{bin}/mmi clean #{testpath}/msg.txt")
    assert_match "feat: brew test", cleaned
    refute_match(/Co-authored-by:\s+Claude/, cleaned)

    # `mmi check` exits 1 on dirty input, 0 on clean input.
    shell_output("#{bin}/mmi check #{testpath}/msg.txt 2>&1", 1)
    (testpath/"clean.txt").write("feat: clean message\n")
    system bin/"mmi", "check", testpath/"clean.txt"
  end
end
