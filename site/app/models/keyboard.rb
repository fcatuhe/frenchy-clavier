class Keyboard
  SHOWN = %w[framework-13-iso framework-13-ansi].freeze

  class << self
    def all = SHOWN.map { Clavier::Boards[it] }

    def layout = @layout ||= Clavier::Layout.load(root.join("layout.yml"))

    def keymap = @keymap ||= Clavier::Keymap.new(layout, compose_path: root.join("compose.yml"))

    private

    def root = Rails.application.config.clavier.root
  end
end
