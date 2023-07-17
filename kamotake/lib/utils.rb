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
