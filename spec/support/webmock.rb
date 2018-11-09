# frozen_string_literal:true

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true, allow: ['fcrepo-test:8080', 'solr-test:8983', 'selenium-hub:4444', 'test:3001'])
