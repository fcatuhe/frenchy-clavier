class Keyboard
  class << self
    delegate :all, :[], to: Clavier::Boards

    def layout = @layout ||= Clavier::Layout.load(root.join("layout.yml"))

    def keymap = @keymap ||= Clavier::Keymap.new(layout, compose_path: root.join("compose.yml"))

    def default = Clavier::Boards.default

    private

    def root = Rails.application.config.clavier.root
  end
end
