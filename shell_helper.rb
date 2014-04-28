module ShellHelper
  def shell_ok?
    $?.exitstatus == 0
  end

  def runcmd cmd
    out = `#{cmd}`
    if shell_ok?
      puts "OK (#{cmd})"
    else
      puts "FAIL (#{cmd})"
      raise "Command failed"
    end
    return out
  end
end
