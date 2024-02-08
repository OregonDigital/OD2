# frozen_string_literal:true

module OregonDigital
  # requires list of pids, iterates through the batch and launches a verify work job for each work.
  class BatchVerificationService
    def initialize(pids, options = {})
      @pids = pids
      @options = options
    end

    def verify
      @pids.each do |pid|
        args = @options.merge({ pid: pid })
        OregonDigital::VerifyWorkJob.perform_later(args)
      end
    end
  end
end
