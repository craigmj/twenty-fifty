require 'sinatra'
require 'haml'
require_relative 'helper'
require 'decc_2050_model'

# This has the methods needed to dynamically create the view
class ServeHTML < Sinatra::Base
  puts "Here we are in serve_html.rb"
  puts "Decc2050Model last modified date = #{Decc2050Model.last_modified_date}"
  puts "Decc2050Model version = #{Decc2050Model.version}"
  puts "Decc2050Version.control_a1 = #{ModelShim.new.control_a1}"

  if development?

    helpers Helper
    set :views, settings.root 

    get '*' do
      haml :'default.html'
    end
  else
    get '*' do 
      send_file 'public/default.html'
    end
  end
end
