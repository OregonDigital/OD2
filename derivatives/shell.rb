# frozen_string_literal: true

def shell(command, *args)
  _, err, status = Open3.capture3(command, *args)
  return if status.success?

  cmdstr = format('"%<command>s %<args>s"', command: command, args: args.join(' '))
  raise "Unable to execute command #{cmdstr}; Error message: #{err}"
end
