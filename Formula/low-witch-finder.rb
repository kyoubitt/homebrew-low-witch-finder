class LowWitchFinder < Formula
  desc "Terminal map and finder for low-Y witch huts in Minecraft"
  homepage "https://github.com/kyoubitt/Low-Witch-Finder"
  url "https://github.com/kyoubitt/Low-Witch-Finder/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "4f78faa94a6150887f1362c17ae56fc1cdfeeea1aa18c130d35cdfb707a02aa2"
  head "https://github.com/kyoubitt/Low-Witch-Finder.git", branch: "master"

  depends_on "python@3.13"

  def install
    # the map engine and the CPU hunt tools; the GPU engine is CUDA, which macOS doesn't have
    system "./build.sh", "cpu"
    rm_r "build"
    rm Dir["bin/*.exe"]
    libexec.install Dir["*"]

    # hunts and finds go here, not into the Cellar (which every upgrade replaces)
    data_home = OS.mac? ? "$HOME/Library/Application Support/Low Witch Finder" : "${XDG_DATA_HOME:-$HOME/.local/share}/low-witch-finder"
    (bin/"low-witch-finder").write <<~EOS
      #!/bin/bash
      export WITCHHUT_RUNS="${WITCHHUT_RUNS:-#{data_home}/runs}"
      export WITCHHUT_RESULTS="${WITCHHUT_RESULTS:-#{data_home}/results}"
      exec "#{Formula["python@3.13"].opt_bin}/python3.13" "#{libexec}/witchhut_studio.py" "$@"
    EOS
  end

  def caveats
    <<~EOS
      Run:  low-witch-finder

      On a Mac the map and the CPU hunt (floors -50 to -54) work. The deeper floors (-55 to -59) need an NVIDIA GPU.
    EOS
  end

  test do
    assert_match "Low Witch Finder", shell_output("#{bin}/low-witch-finder --frame 100 24 1 dark")
    assert_predicate libexec/"bin/biome_map", :executable?
  end
end
