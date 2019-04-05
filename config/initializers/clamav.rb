# frozen_string_literal:true

# `defined? ClamAV` raises an exception in environments other than production,
# and the application should only load the database if ClamAV is loaded
if Rails.env.production?
  ClamAV.instance.loaddb if defined? ClamAV
end
