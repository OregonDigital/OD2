# frozen_string_literal:true

ClamAV.instance.loaddb if defined? ClamAV && Rails.env.production?
