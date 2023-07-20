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
  solution_filename = "#{Rails.root}/tmp/kamotake/" \
  "#{File.basename(cnf_filename, File.extname(cnf_filename))}_solution.cnf"

  begin
    # Run in background to avoid blocking
    t_start = Time.now
    pid = spawn(
      "cat #{header_filename} #{cnf_filename} |" \
      "#{bin_path} /dev/stdin #{solution_filename}",
      out: "/dev/null",
    )
    Process.waitpid2(pid)
    t = Time.now - t_start
  rescue Interrupt
    # Remove the temporary files
    FileUtils.rm_rf(File.dirname(solution_filename))

    # Kill the child process
    Process.kill("TERM", pid)
    exit 1
  end

  solution_filename
end
