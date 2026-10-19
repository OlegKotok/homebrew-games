class Tenris < Formula
  include Language::Python::Virtualenv

  desc "Tetris with Numbers - Collect the blocks which equal 10"
  homepage "https://github.com/OlegKotok/TeNRiS"
  url "https://github.com/OlegKotok/TeNRiS/archive/refs/tags/build-45.tar.gz"
  sha256 "74442e7a31e832814d33d6f00b1cf47a3018f148e6c1e819805eab88feb375a8"
  license "GPL-3.0-or-later"

  depends_on "python@3.12"

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/source/p/packaging/packaging-26.2.tar.gz"
    sha256 "ff452ff5a3e828ce110190feff1178bb1f2ea2281fa2075aadb987c2fb221661"
  end

  resource "pygame-ce" do
    url "https://files.pythonhosted.org/packages/57/a7/cd305034f505bfa1a1acdafd3d86af54da14b29151a0d99f348306272773/pygame_ce-2.5.7-cp312-cp312-macosx_10_13_universal2.whl", using: :nounzip
    sha256 "dca2f8ba56bf3b4b8c73c4863d0603773403f4f66bc2fe25784ea74aee3fffc3"
  end

  on_arm do
    resource "pillow" do
      url "https://files.pythonhosted.org/packages/d8/95/0a351b9289c2b5cbde0bacd4a83ebc44023e835490a727b2a3bd60ddc0f4/pillow-12.2.0-cp312-cp312-macosx_11_0_arm64.whl", using: :nounzip
      sha256 "f3f40b3c5a968281fd507d519e444c35f0ff171237f4fdde090dd60699458421"
    end
  end

  on_intel do
    resource "pillow" do
      url "https://files.pythonhosted.org/packages/58/be/7482c8a5ebebbc6470b3eb791812fff7d5e0216c2be3827b30b8bb6603ed/pillow-12.2.0-cp312-cp312-macosx_10_13_x86_64.whl", using: :nounzip
      sha256 "2d192a155bbcec180f8564f693e6fd9bccff5a7af9b32e2e4bf8c9c69dbad6b5"
    end
  end

  # Хелпер для очищення префікса Homebrew та коректного монтування .whl
  def install_wheel(venv_python, res_name)
    cached = resource(res_name).cached_download
    clean_name = cached.basename.to_s.sub(/^.*--/, "")
    clean_name += ".whl" unless clean_name.end_with?(".whl")

    whl_path = buildpath/clean_name
    cp cached, whl_path
    system venv_python, "-m", "pip", "install", "--no-deps", whl_path
  end

  def install
    venv = virtualenv_create(libexec, "python3")
    venv_python = libexec/"bin/python3"

    # 1. Джерельні пакети (.tar.gz)
    venv.pip_install resource("packaging")

    # 2. Wheel пакети (.whl) через наш очищувач назв
    install_wheel(venv_python, "pillow")
    install_wheel(venv_python, "pygame-ce")

    # 3. Скопіювати вихідні файли гри
    libexec.install Dir["*"]

    # 4. Створити виконуваний файл-обгортку
    (bin/"tenris").write <<~EOS
      #!/bin/bash
      cd "#{libexec}" && exec "#{libexec}/bin/python3" "#{libexec}/tenris.py" "$@"
    EOS
  end

  test do
    assert_path_exists bin/"tenris"
    assert_predicate bin/"tenris", :executable?
  end
end
