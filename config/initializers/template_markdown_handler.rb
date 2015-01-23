# This module parses files passing through the
# ActionView::Template engine ending in .md or .markdown
#
# It first parses it using the ERB parser followed
# by the markdown parser supplied by Redcarpet
#
# I added a few of the features implemented in GitHub
# flavored markdown

module MarkdownTemplateHandler
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                          autolink: true,
                                          tables: true,
                                          strikethrough: true,
                                          fenced_code_blocks: true)
  end

  def self.call(template)
    template = erb.call(template)
    "MarkdownTemplateHandler.markdown.render(begin;#{template};end).html_safe"
  end

end

ActionView::Template.register_template_handler :md, MarkdownTemplateHandler
ActionView::Template.register_template_handler :markdown, MarkdownTemplateHandler
