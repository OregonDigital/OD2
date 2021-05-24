# frozen_string_literal: true

module OregonDigital
  # Displays ntriples for a given work
  class NtriplesController < ApplicationController
    def show
      @ntriples = ActiveFedora::Base.find(params[:id]).resource.dump(:ntriples) 
    end
  end
end