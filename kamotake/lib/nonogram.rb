require "fileutils"

require_relative "../lib/utils"
require_relative "../lib/constraints"

class Nonogram
  # Parse an instance of a nonogram problem from a file
  #
  # @param filename [String] the name of the file
  def initialize(filename)
    # Lo que debe tener la clase (por ahora)
    # - @n_rows (Integer)
    # - @n_cols (Integer)
    # - @row_constraints (Array<Array<Integer>>)
    # - @col_constraints (Array<Array<Integer>>)
  end

  def to_cnf
    # ...
  end

  def solve
    # ...
  end

  def to_s
    # ...
  end

  # Definir variables privadas para Tseitin y funciones para generar las
  # cláusulas de cada restricción
end



# Calculates the number of clauses in the CNF translation.
#
# @param [Integer] rows Number of rows in the nonogram
# @param [Integer] cols Number of columns in the nonogram
# @return [Integer] Number of clauses to be written
def calculate_number_of_clauses(rows, cols)
  0
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
