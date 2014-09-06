require 'sinatra'
require 'haml'
require_relative 'helper'
require 'decc_2050_model'

# This has the methods needed to dynamically create the view
class ServeHTML < Sinatra::Base
  puts "Decc2050Model last modified date = #{Decc2050Model.last_modified_date}"
  #puts "Decc2050Model version = #{Decc2050Model.version}"
  puts "Decc2050Version.control_a1 = #{ModelShim.new.control_a1}"

  set :protection, :except => :frame_options
  puts "Set frame_options off"

  if development?

    helpers Helper
    set :views, settings.root 

    get '*' do
      headers({ 'X-Frame-Options' => '' }) #'ALLOW-FROM apps.facebook.com' })
      haml :'default.html'
    end
  else
    get '*' do 
      headers({ 'X-Frame-Options' => '' }) #ALLOW-FROM apps.facebook.com' })
      send_file 'public/default.html'
    end
  end
end
