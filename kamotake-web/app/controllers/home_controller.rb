require 'kamotake/nonogram'

class HomeController < ApplicationController
  @@nonogram = nil

  def index
  end

  def handle_file
    # Get :file from the request parameters
    file = params[:file]

    # Get the file's original name
    name = file.original_filename
    @@nonogram = Nonogram.new(file.tempfile, name)

    # Print nonogram to console
    @@nonogram.solve

    # Get request to /order and pass the solution as a parameter
    redirect_to :order
  end

  def order
    if @@nonogram.nil?
      redirect_to :root
    end

    @solution = @@nonogram.solution
    @name = @@nonogram.name
  end
end
