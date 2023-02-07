# frozen_string_literal: true

module OregonDigital
  # Adds method to strip words from the config/solr/stopwords.txt
  module StripsStopwords
    def strip_stopwords(str)
      articles = %w[a an and are as at be but by for if in into is it no not of on or s such t that the their then there these they this to was will with]
      str.split.reject { |w| w.in? articles }.join(' ')
    end
  end
end
