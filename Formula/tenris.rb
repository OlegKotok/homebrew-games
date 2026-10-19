class Tenris < Formula
  desc "Tetris with Numbers. Collect the blocks which equal 10."
  homepage "https://github.com/OlegKotok/TeNRiS"
  url "https://github.com/OlegKotok/TeNRiS/archive/refs/tags/build-45.tar.gz"
  sha256 "74442e7a31e832814d33d6f00b1cf47a3018f148e6c1e819805eab88feb375a8"
  license "GPLv3" # Вкажіть вашу ліцензію

  depends_on "python@3.12"

  include Language::Python::Virtualenv

  # Залежності з requirements.txt для роботи гри (PyPI)
  resource "packaging" do
    url "https://files.pythonhosted.org/packages/source/p/packaging/packaging-26.2.tar.gz"
    sha256 "1d76391a6d4e2a878d464dbb24018f3a38890731633cf483eb9e51c6b12a865f"
  end

  resource "pillow" do
    url "https://files.pythonhosted.org/packages/source/p/pillow/pillow-12.2.0.tar.gz"
    sha256 "1c02eb928a39a6a8b13d288a7db326d2e6702d7e1e6f77ec95ed9b40019b8dfa"
  end

  resource "pygame-ce" do
    url "https://files.pythonhosted.org/packages/source/p/pygame-ce/pygame_ce-2.5.7.tar.gz"
    sha256 "3b92ecbc189873d6ba2f89c44569d4d2994e7ba451df671f11a84c8a81eb8989"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/source/s/setuptools/setuptools-82.0.1.tar.gz"
    sha256 "5191c9cb481e4b8bc00705f15d7e5d84a7e9373cf5d22227dcf9cf2fb93fa4ec"
  end

  def install
    # Створюємо venv всередині системного каталогу libexec Homebrew
    venv = virtualenv_create(libexec, "python3")

    # Автоматично інсталюємо описані ресурси без доступу до мережі
    resources.each do |r|
      venv.pip_install r
    end

    # Скопіювати всі файли проєкту у libexec
    libexec.install Dir["*"]

    # Створити бінарник-обгортку в bin/tenris з точкою входу tenris.py
    (bin/"tenris").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/python3" "#{libexec}/tenris.py" "$@"
    EOS
  end

  test do
    assert_predicate bin/"tenris", :exist?
    assert_predicate bin/"tenris", :executable?
  end
end
