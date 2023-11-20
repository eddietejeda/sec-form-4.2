
# Examples from https://raw.githubusercontent.com/taf2/curb/d2949196a832ad6338bf51608d953fb12c864974/samples/downloader.rb
def delete_dowload(urls)
  urls.each do|url|
    filename = url.split(/\?/).first.split(/\//).last
    File.unlink("#{download_path}/#{filename}") if File.exist?("#{download_path}/#{filename}")
  end
end

# first sequential
def download_sequential(url_list)
  easy = Curl::Easy.new
  easy.follow_location = true

  url_list.each do|u|
    easy.url = u[:url]
    print "'#{u[:url]}' :"
    File.open("#{download_path}#{u[:filename]}", 'wb') do|f|
      easy.on_progress {|dl_total, dl_now, ul_total, ul_now| print "="; true }
      easy.on_body {|data| f << data; data.size }   
      easy.perform
      easy.on_complete { print "\n" }
    end
  end
end

# using multi interface
def download_parallel(urls)
  Curl::Multi.download(urls){|curl,code,method| 
    curl.headers["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36"
    filename = curl.url.split(/\?/).first.split(/\//).last
    puts "=> '#{filename}'\n"
  }
end

def download_path(local="data/")
  `mkdir -p #{local}`
  if !File.exists?(local) && !File.directory?(local)
    puts "'#{local}' is not a valid file path."
  end
  return local
end

def public_data_path(local="public/data/")
  `mkdir -p #{local}`
  if !File.exists?(local) && !File.directory?(local)
    puts "'#{local}' is not a valid file path."
  end
  return local
end

def json_file_cache(name)  
  cache_file = "#{download_path}#{name}-#{Digest::MD5.hexdigest(name)}" 

  if !File.exists?(cache_file)
    value = yield
    File.write(cache_file, value.to_json)
  end

  JSON.parse(File.read(cache_file))
end


def reload!
  puts "Reloading env...."
  load './bootup.rb'
end