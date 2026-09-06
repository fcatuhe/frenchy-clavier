class Keyboard
  class << self
    def iso = Clavier::Boards["framework-13-iso"]

    def ansi = Clavier::Boards["framework-13-ansi"]

    def all = [ iso, ansi ]

    def layout = @layout ||= Clavier::Layout.load(root.join("layout.yml"))

    def keymap = @keymap ||= Clavier::Keymap.new(layout, compose_path: root.join("compose.yml"))

    def azerty = Clavier::Reference.keys(Clavier::Reference::AZERTY)

    def qwerty_us = Clavier::Reference.keys(Clavier::Reference::QWERTY_US)

    private

    def root = Rails.application.config.clavier.root
  end
end
