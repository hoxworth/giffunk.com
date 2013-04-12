require 'sinatra'
require 'open-uri'
require 'uri'
require 'digest/sha1'

get '/' do
  erb :index
end

get '/funkify' do
  if params[:uri].nil? || params[:uri] == ''
    return "Yeah no"
  end

  uri = params[:uri]
  begin
    uri = URI.parse(params[:uri])
  rescue
    return "Please provide a valid URL!"
  end

  filehash = Digest::SHA1.hexdigest(Time.now.to_f.to_s)
  filename = ''

  1.upto(32) do |x|
    filename = filehash[0,x]
    if !File.exists?(File.dirname(__FILE__) + "/public/#{filename}.gif")
      break
    end
  end

  # Fetch the file
  `wget #{uri.to_s} -O #{File.dirname(__FILE__)}/public/#{filename}.gif`

  # Explode
  `cd #{File.dirname(__FILE__)}/public && gifsicle -e -U #{filename}.gif`
  exploded_files = Dir["#{File.dirname(__FILE__)}/public/#{filename}.*"]

  # Create the command
  command = "gifsicle --append #{File.dirname(__FILE__)}/public/#{filename}.gif"
  (exploded_files.length-2).downto(1) do |x|
    command = "#{command} #{File.dirname(__FILE__)}/public/#{filename}.gif.#{sprintf("%03d",x)}"
  end

  # Do it!
  `#{command} > #{File.dirname(__FILE__)}/public/#{filename}.gif.tmp`
  `mv #{File.dirname(__FILE__)}/public/#{filename}.gif.tmp #{File.dirname(__FILE__)}/public/#{filename}.gif`
  `rm #{File.dirname(__FILE__)}/public/#{filename}.gif.*`

  "<img src='#{filename}.gif' />"
end