# Measure the time it takes to execute a block
#
# @param block [Block] the block to measure
# @return [Float] the time it took to execute the block
def measure_time(&block)
  start = Time.now
  block.call
  Time.now - start
end

# Solves a SAT problem in CNF format using the minisat solver.
#
# @param [String] header_filename Name of the header file
# @param [String] cnf_filename Name of the CNF file
# @param [String] bin_path Path to the SAT Solver binary
# @return [String] Name of the solution file
def solve_cnf(header_filename, cnf_filename, bin_path)
  solution_filename = ".tmp_kamotake/" \
  "#{File.basename(cnf_filename, File.extname(cnf_filename))}_solution.cnf"

  # Run in background to avoid blocking
  t_start = Time.now
  pid = spawn(
    "cat #{header_filename} #{cnf_filename} |" \
    "#{bin_path} /dev/stdin #{solution_filename}",
    out: "/dev/null",
  )
  Process.detach(pid)

  # Wait for the child process to exit and retrieve its exit status
  begin
    loop do
      # Check if the child process has exited
      begin
        status = Process.waitpid2(pid, Process::WNOHANG)
      rescue Errno::ECHILD
        # Child process has exited, do something
        puts "\rWe're finished in #{Time.now - t_start} seconds! 🦛 (Solution found in #{solution_filename})"
        break
      end

      # Child process is still running
      for char in ["—", "\\", "|", "/"]
        print "\rPlease wait we're computing posssibilities 🧠... #{char}"
        sleep 0.1
      end
    end
    # Ctrl-C to stop the process
  rescue Interrupt
    puts "\rInterrupted! 🤬#{" " * 44}\n\n"

    # Remove .temp_sat-planner directory
    FileUtils.rm_rf(".tmp_kamotake")

    # Kill the child process
    Process.kill("TERM", pid)
    exit 1
  end

  solution_filename
end
