# gem install pdf-reader
require 'pdf-reader'
require 'colorize'

def load_pdf_records(page_limit = 1_000_000)
  files = Dir.glob('records/**/*').select { |e| File.file? e }
  puts "files count #{files.count}".green
  
  records = []

  page = 1
  files = ["pdf_record.pdf"]
  files.each do |f|
    reader = PDF::Reader.new(f)
    reader.pages.each{|x| 
      # puts "---- Page Number #{page} ----".green
      # puts x.text
      x.text.scan(/\n\s+[[:digit:]]{1,6}\s/).each{|c| 
        records << c.strip.to_i
      } 
      if page > page_limit
        break
        return records
      end
      page = page + 1

    }
  end
  return records
end

records = load_pdf_records

puts "records count #{records.count}".green


def load_excel_routes(page_limit = 1_000_000)
  files = Dir.glob('routes/**/*').select { |e| File.file? e }
  routes = []

  page = 1
  files.each do |r|
    routes << (r.match(/\d+/)[0]).to_i
    if page > page_limit
      break
      return routes
    end
    page = page + 1
  end

  return routes.sort
end

routes = load_excel_routes

def find_missing_records(records, routes)
  routes.each do |route|

    if records.include?(route)
      puts "Found: #{record}".green
    else
      puts "Not Found: #{route}".red
    end

  end
end