def add_sec_ids_to_companies
  puts "Getting company IDs from SEC"

  Company.all.where("cik IS NULL").each do |c|
    puts "#{c.ticker}"
    json = Curl.post("https://efts.sec.gov/LATEST/search-index", {'keysTyped': c.ticker ,'narrow':true}.to_json).body_str
    response = JSON.parse(json)
    c.cik = "%010d" % response.to_h['hits'].to_h['hits'].to_a.first['_id']
    c.save!
  end
end

def generate_document_urls
  Company.all.where("cik IS NOT NULL").map do |c|
    { filename: c.cik, url: "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK=#{c.cik}&type=&dateb=&owner=include&start=0&count=100&output=atom" }
  end
end

def get_transaction_xml(url)

  cache_file = "data/#{url.gsub(/[^0-9]/, '')}" 

  if !File.exists?(cache_file)
    puts "Cache miss for #{cache_file}"
    uri = URI.parse(url)

    document_url = uri.to_s.gsub("-index.htm", ".txt")
    uri = URI(document_url)
    response = Net::HTTP.get(uri)    
    
    File.write(cache_file, response.split("<XML>\n").last.split("</XML>").first)
  end

  File.read(cache_file)
end


def add_sec_transaction_data_to_companies
  companies = Company.all

  Dir["data/00*"].each do |c|

    xml = File.new(c, encoding: "iso-8859-1").read
    feed = Feedjira.parse(xml)
    cik = feed.title.match(/\(([0-9]+)\)/).to_a.last
  
    company = companies.where("cik = :cik", {cik: cik}).first

    unless company
      puts "Company not found #{cik}"
      next
    end
  
    feed.entries.each do |entry|
    
      if entry.categories.first == "4"
        
        # byebug
        transaction_xml = get_transaction_xml(entry['url'])
        transactions = XmlHasher.parse(transaction_xml).to_h[:ownershipDocument].to_h[:nonDerivativeTable].to_h[:nonDerivativeTransaction]


        # Each transaction does not have a unique ID, so we have to see how many transactions are in each document
        current_transactions =  Transaction.where("document_url = :document_url", {document_url: entry['url']})
        if transactions && current_transactions.count > transactions.count
          current_transactions.destroy_all
          puts "Clearing potential duplicate transactions"
        end
        
        transactions.to_a.each do |t|
          if  t.class == Array
            next
          end
          
          document_date = t.to_h[:transactionDate].to_h[:value].to_date
          transaction_shares = t.to_h[:transactionAmounts].to_h[:transactionShares].to_h[:value].to_f
          transaction_price_per_share = t.to_h[:transactionAmounts].to_h[:transactionPricePerShare].to_h[:value].to_f
          transaction_sold = t.to_h[:transactionAmounts].to_h[:transactionAcquiredDisposedCode].to_h[:value] == "D"
        
          unless transaction_sold
            next
          end  
        
          amount = transaction_shares * transaction_price_per_share
        
          begin
            ActiveRecord::Base.transaction do
              result = Transaction.create!(company_id: company.id, data: t, document_url: entry['url'], document_date: document_date, amount: amount)
              puts "====> Success creating Transaction #{result.id}"
            end
          rescue Exception => ex
            if ex.message.include? "PG::UniqueViolation"
              puts "====> Skipping Duplicate: #{ex}"
            else
              puts "====> Exception: #{ex}"
            end
          end
        end
      end
    end
  end
end

