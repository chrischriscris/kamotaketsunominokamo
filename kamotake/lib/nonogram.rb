require "fileutils"

require_relative "../lib/utils"
# require_relative "../lib/constraints"

class Nonogram
  attr_reader :n_rows, :n_cols, :row_constraints, :col_constraints

  # Parse an instance of a nonogram problem from a file
  #
  # @param filename [String] the name of the file
  def initialize(filename)
    File.open(filename) do |file|
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
    end
  end

  # Generates a CNF file from the nonogram instance
  def to_cnf
    # ...
  end

  def solve

    File.open("nonogram.cnf", "w") do |file|
      for r in rows:
        write_clauses(i, r, true)

      for c in cols:
        write_clauses(i, c, false)
    end

    # ...
  end

  def to_s
    # ...
  end

  # Definir variables privadas para Tseitin y funciones para generar las
  # cláusulas de cada restricción

  private

  # Generate all possible combinations of groups and empty spaces for a row or
  # column of the nonogram as an array of 1s and -1s.
  #
  # @param [Array<Integer>] groups Array of groups of filled cells
  # @param [Boolean] is_row Whether the groups are for a row or a column
  def generate_possibilities(groups, is_row)
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
end

# Calculates the number of clauses in the CNF translation.
#
# @param [Integer] rows Number of rows in the nonogram
# @param [Integer] cols Number of columns in the nonogram
# @return [Integer] Number of clauses to be written
def calculate_number_of_clauses(rows, cols)
  0
end
