# frozen_string_literal:true

# Temporary monkey patch for CVE-2020-5267: https://github.com/advisories/GHSA-65cv-r6x7-79hv
# Can be removed once Hyrax and Active Fedora support rails >= 5.2 and rails is >= 5.2.4.2 or >= 6.0.2.2
ActionView::Helpers::JavaScriptHelper::JS_ESCAPE_MAP.merge!(
  {
    "`" => "\\`",
    "$" => "\\$"
  }
)

module ActionView::Helpers::JavaScriptHelper
  alias :old_ej :escape_javascript
  alias :old_j :j

  def escape_javascript(javascript)
    javascript = javascript.to_s
    if javascript.empty?
      result = ""
    else
      result = javascript.gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"']|[`]|[$])/u, JS_ESCAPE_MAP)
    end
    javascript.html_safe? ? result.html_safe : result
  end

  alias :j :escape_javascript
end