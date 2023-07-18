# Measure the time it takes to execute a block
#
# @param block [Block] the block to measure
# @return [Float] the time it took to execute the block
def measure_time(&block)
  start = Time.now
  block.call
  Time.now - start
end

# Extract solution from a solution file
#
# @param solution_filename [String] the name of the solution file
# @param n_rows [Integer] the number of rows
# @param n_cols [Integer] the number of columns
# @return [Array] the solution matrix
def extract_solution(solution_filename, n_rows, n_cols)
  File.open(solution_filename, "r") do |f|
    solution_string = f.readline.strip

    if solution_string == "UNSAT"
      return []
    end

    dimension = n_rows * n_cols

    matrix = []
    line = []
    count = 0

    solution_string.split(" ")
      .take(dimension)
      .map do |n|
      line << (n.to_i > 0)
      count += 1
      if count == n_cols
        matrix << line
        line = []
        count = 0
      end
    end

    matrix
  end
end

# Solves a SAT problem in CNF format using the minisat solver.
#
# @param [String] filename Name of the CNF file
# @param [String] bin_path Path to the SAT Solver binary
# @return [String] Name of the solution file
def solve_cnf(filename, bin_path)
  solution_filename = ".tmp_kamotake/" \
  "#{File.basename(filename, File.extname(filename))}_solution.cnf"

  # Run in background to avoid blocking
  t_start = Time.now
  pid = spawn("#{bin_path} #{filename} #{solution_filename}", out: "/dev/null")
  Process.detach(pid)

  # Wait for the child process to exit and retrieve its exit status
  begin
    loop do
      # Check if the child process has exited
      begin
        status = Process.waitpid2(pid, Process::WNOHANG)
      rescue Errno::ECHILD
        # Child process has exited, do something
        puts "\rWe're finished in #{Time.now - t_start} seconds! 🦛 (Solution found in #{solution_filename})\n\n"
        break
      end

      # Child process is still running
      for char in ["—", "\\", "|", "/"]
        print "\rPlease wait we're attempting to schedule 🍳... #{char}"
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
