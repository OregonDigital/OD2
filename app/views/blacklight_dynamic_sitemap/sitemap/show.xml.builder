# frozen_string_literal: true

xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.urlset(
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd',
  'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9'
) do
  config = BlacklightDynamicSitemap::Engine.config
  @sitemap_entries.each do |doc|
    # OVERRIDE FROM blacklight_dynamic_sitemap to convert doc from Hash to "mock" SolrDocument
    doc = SolrDocument.new doc
    xml.url do
      # OVERRIDE FROM blacklight_dynamic_sitemap to present correct polymorphic path
      xml.loc(main_app.polymorphic_url(doc))
      last_modified = doc[config.last_modified_field]
      xml.lastmod(config.format_last_modified&.call(last_modified) || last_modified)
    end
  end
end
