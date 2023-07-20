class HomeController < ApplicationController
  def index
    # Render a hello world message as HTML
    "Hello world!"
  end

  def order
    # Get :file from the request parameters
    file = params[:file]

    # Get the file's original filename
    filename = file.original_filename

    puts "Received file: #{filename}"

  end
end
