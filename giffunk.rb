require 'sinatra'
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
  `wget #{uri.to_s} -O #{File.dirname(__FILE__)}/public/#{filename}-1.gif`
    
  # Reverse and concat
  `convert #{File.dirname(__FILE__)}/public/#{filename}-1.gif -coalesce -reverse -quiet -layers OptimizePlus -loop 0 #{File.dirname(__FILE__)}/public/#{filename}-2.gif && convert #{File.dirname(__FILE__)}/public/#{filename}-1.gif -delete -1 #{File.dirname(__FILE__)}/public/#{filename}-2.gif -delete -1 #{File.dirname(__FILE__)}/public/#{filename}.gif`

  # Remove the temp files
  `rm #{File.dirname(__FILE__)}/public/#{filename}-1.gif`
  `rm #{File.dirname(__FILE__)}/public/#{filename}-2.gif`

  "<img src='#{filename}.gif' />"
end