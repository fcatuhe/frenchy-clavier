module PagesHelper
  ROOT_SLUG = "index".freeze

  def pages = Page.all.sort_by { it.position.to_i }

  def path_to_page(slug) = slug == ROOT_SLUG ? root_path : page_path(slug)

  def link_to_page(slug, html_options = nil)
    link_to Page.find(slug).title, path_to_page(slug), html_options
  end
end
