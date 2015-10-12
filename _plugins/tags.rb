require "kramdown"

module JekyllTags
  class Hidden < Liquid::Block
    def initialize(tag_name, text, tokens)
      @title = text.strip
      super
    end

    def render(text)
      header = @title
      hidden_text = super
      content = Kramdown::Document.new(hidden_text.strip).to_html
      "<div class=\"hiding-example\"><span class=\"hiding-example-header\">#{header}</span><button class=\"hiding-example-toggle\"></button><span class=\"hiding-example-content\">#{content}</span></div>"
    end
  end

end

Liquid::Template.register_tag('hide', JekyllTags::Hidden)