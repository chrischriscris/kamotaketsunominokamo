require "fileutils"

require_relative "utils"

class Nonogram
  attr_reader :n_rows, :n_cols, :row_constraints, :col_constraints, :name, :solution

  # Parse an instance of a nonogram problem from a file
  #
  # @param [File] file The file to read the instance from
  # @param [String] name The name of the instance
  def initialize(file, name)
    @name = File.basename(name, File.extname(name))

    # Get the first line of the file
    line = file.gets
    raise "Invalid file format: missing first line" if line.nil?

    # Verify that the first line contains n_rows and n_cols
    parts = line.split
    if parts.size != 2 || !parts.all? { |part| part =~ /^\d+$/ }
      raise "Invalid file format: first line must contain number of rows and columns"
    end

    # Get the number of rows and columns
    @n_cols, @n_rows = parts.map(&:to_i)
    if @n_rows <= 0 || @n_cols <= 0
      raise ArgumentError, "Invalid number of rows or columns"
    end

    # Initialize the constraints
    @row_constraints = Array.new(@n_rows) { [] }
    @col_constraints = Array.new(@n_cols) { [] }

    # Read the row constraints
    @n_rows.times do |i|
      line = file.gets
      raise "Incomplete file: missing row constraints" if line.nil?
      @row_constraints[i] = line.split.map(&:to_i)
    end

    # Read the column constraints
    @n_cols.times do |j|
      line = file.gets
      raise "Incomplete file: missing column constraints" if line.nil?
      @col_constraints[j] = line.split.map(&:to_i)
    end

    # To be used for the generation of the CNF file
    @n_clauses = 0
    @n_vars = @n_rows * @n_cols

    # Tseitin variables
    @ps = @n_rows * @n_cols
  end

  def solve
    # Writes in /tmp/kamotake from the project root
    filename = "#{Rails.root}/tmp/kamotake/#{@name}.cnf"

    # Create the directory if it doesn't exist
    FileUtils.mkdir_p(File.dirname(filename))

    File.open(filename, "w") do |file|
      @row_constraints.each_with_index do |row, i|
        start = i * @n_cols + 1
        _end = start + @n_cols
        cells = (start..._end).to_a

        write_clauses!(file, cells, row, true)
      end

      @col_constraints.each_with_index do |col, i|
        start = i + 1
        _end = start + @n_cols * @n_rows
        cells = (start..._end).step(@n_cols).to_a

        write_clauses!(file, cells, col, false)
      end
    end

    header_filename = "#{Rails.root}/tmp/kamotake/header.cnf"
    File.open(header_filename, "w") do |file|
      file.puts "p cnf #{@n_vars} #{@n_clauses}"
    end

    solution_filename = solve_cnf(
      header_filename,
      filename,
      "#{Rails.root}/bin/glucose",
    )
    @solution = extract_solution(solution_filename)
  end

  # Returns a string representation of the nonogram
  def to_s
    if @solution.nil? || @solution.empty?
      return "N = #{@n_rows} x #{@n_cols}\nNo solution found"
    end

    string = ""

    @solution.each do |row|
      row.each do |cell|
        string << (cell ? "■ " : ". ")
      end
      string << "\n"
    end

    string
  end

  private

  # Generate all possible combinations of groups and empty spaces for a row or
  # column of the nonogram as an array of 1s and -1s.
  #
  # @param [Array<Integer>] groups Array of groups of filled cells
  # @param [Boolean] is_row Whether the groups are for a row or a column
  def generate_possibilities(groups, is_row)
    if groups == [0]
      return [[-1] * (is_row ? @n_cols : @n_rows)]
    end

    n_groups = groups.size
    n_empty = (is_row ? @n_cols : @n_rows) - groups.sum - (n_groups - 1)

    # Generate all ways of taking n_groups elements from a set of n_blocks
    n_blocks = n_groups + n_empty
    combinations = (0...n_blocks).to_a.combination(n_groups).to_a

    # Generate the blocks to be placed in the empty spaces
    blocks = groups.map { |n| [1] * n + [-1] }

    possibilities = []
    combinations.each do |combination|
      possibility = [-1] * (n_blocks)
      combination.each_with_index do |i, j|
        possibility[i] = blocks[j]
      end

      possibilities << possibility.flatten[0...-1]
    end

    possibilities
  end

  # Write the clauses for a row or column of the nonogram
  #
  # @param [File] file The file to write the clauses to
  # @param [Array<Integer>] cells Array of cells corresponding to the row or column
  # @param [Array<Integer>] groups Array of groups of filled cells
  # @param [Boolean] is_row Whether the groups are for a row or a column
  def write_clauses!(file, cells, groups, is_row)
    possibilities = generate_possibilities(groups, is_row)
    n_possibilities = possibilities.size

    # Increase the number of variables and clauses for each possibility
    @n_vars += n_possibilities
    @n_clauses += 1 + n_possibilities * (cells.size + 1)

    # At least one possibility must be true
    for i in @ps + 1..@ps + n_possibilities
      file.print "#{i} "
    end
    file.puts "0"

    possibilities.each do |possibility|
      # Generate a Tseitin variable
      @ps += 1
      aux = "#{@ps} "

      # Writes the ==> clauses: (-p_i) v (l_1 ^ ... ^ l_n)
      possibility.each_with_index do |value, i|
        l_i = cells[i] * value
        file.puts "#{-@ps} #{l_i} 0"
        aux << "#{-l_i} "
      end
      aux << "0"

      # Writes the <== clauses: (p_i v -l_1 v ... v -l_n)
      file.puts aux
    end
  end

  # Extract solution from a solution file
  #
  # @param solution_filename [String] the name of the solution file
  # @return [Array<Array<Boolean>>] the solution as a matrix of booleans
  def extract_solution(solution_filename)
    File.open(solution_filename, "r") do |f|
      solution_string = f.readline.strip

      if solution_string == "UNSAT"
        return []
      end

      dimension = @n_rows * @n_cols
      matrix = []
      line = []
      count = 0

      solution_string.split(" ")
        .take(dimension)
        .map do |n|
        line << (n.to_i > 0)
        count += 1
        if count == @n_cols
          matrix << line
          line = []
          count = 0
        end
      end

      matrix
    end
  end
end
