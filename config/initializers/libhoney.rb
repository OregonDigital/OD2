Libhoney::LogTransmissionClient.class_eval do
  def add(event)
    if @verbose
      metadata = "Honeycomb dataset '#{event.dataset}' | #{event.timestamp.iso8601}"
      metadata << " (sample rate: #{event.sample_rate})" if event.sample_rate != 1
      @output.print("#{metadata} | ")
    end
    @output.puts(event.data.to_s.to_json)
  end
end