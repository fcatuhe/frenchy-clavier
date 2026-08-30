module PagesHelper
  def link_to_page(slug, html_options = nil)
    link_to Page.find(slug).title, page_path(slug), html_options
  end

  def pages
    Page.all.sort_by { it.position.to_i }
  end
end
