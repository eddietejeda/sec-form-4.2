require 'uri'
require 'curb'
require 'smarter_csv'
require 'feedjira'
require 'net/http'
require 'xmlhasher'
require 'roo'
require 'iex-ruby-client'

def get_historical_pricing_data(ticker)
  puts "Getting stock pricing data"
  
  csv_file = "#{download_path}#{ticker.downcase}_prices.csv"

  if !File.exists?(csv_file)
    remote_file = File.basename(csv_file)
    url_list = [{
      url: "https://query1.finance.yahoo.com/v7/finance/download/#{ticker.upcase}?period1=1577836800&period2=1599177600&interval=1d&events=history",   
      filename: remote_file
    }]
    download_sequential(url_list)
  end
end


def load_ticker_historical_pricing_data(ticker)
  puts "Adding companies to database"
  options = {}
  
  get_historical_pricing_data(ticker)

  SmarterCSV.process("#{download_path}#{ticker.downcase}_prices.csv", options) do |chunk|
    chunk.each do |r|
      Stock.create!({ ticker: ticker, date: r[:date], price: r[:close] }) if Stock.where("ticker = :ticker AND date = :date", {ticker: ticker, date: r[:date].to_date}).empty?
    end
  end
end


def get_index_fund_companies(ticker)
  csv_file = "#{download_path}#{ticker.downcase}.csv"

  if !File.exists?(csv_file)
    remote_file = "#{ticker.downcase}.xlsx"
    url_list = [{
      url: "https://www.ssga.com/us/en/individual/etfs/library-content/products/fund-data/etfs/us/holdings-daily-us-en-#{remote_file}",   
      filename: remote_file
    }]
    download_sequential(url_list)
    excel_to_csv(remote_file)
    trim_csv_cruft(csv_file)
  end
end


def load_companies_from_index_fund(ticker)
  puts "Adding companies to database"
  options = {}
  
  get_index_fund_companies(ticker)
  SmarterCSV.process("data/#{ticker.downcase}.csv", options) do |chunk|
    chunk.each do |r|
      Company.create!({ name: r[:name], ticker: r[:ticker] })  if Company.where("ticker = :ticker", {ticker: ticker}).empty?
    end
  end
end



def get_sales_transaction_proceeds(date_group='day', start_date='2019-12-31', end_date='2020-09-01')
  query = "SELECT 
        date_trunc(:date_group, document_date) AS date_group,
        SUM(amount) as amount
    FROM 
        transactions  
    WHERE
        document_date > :start_date AND
        document_date < :end_date
    GROUP BY 
        date_trunc(:date_group, document_date)
    ORDER BY
        date_group
    ASC"

  Transaction.find_by_sql [query, { date_group: date_group, start_date: start_date, end_date: end_date }]
end



def load_financial_data_for_backup

  Company.all.where("data->>'q1q2_2019' = '0' OR  data->>'q1q2_2020' = '0'")
  
end

def load_financial_data_for_all_companies
  puts "Loading financial data"
  client = IEX::Api::Client.new
 
  Company.all.each do |c|
    q1q2_2019 = 0
    q1q2_2020 = 0
    
    statement = json_file_cache("income-#{c[:ticker]}") do
      client.income(c[:ticker], {period: 'quarter', last: 8})
    end
    
    statement.each do |s|  
      report_date = s["report_date"].to_date
      if report_date > Date.parse("2018-12-31") && report_date < Date.parse("2019-07-01")
        q1q2_2019 = q1q2_2019 + s["total_revenue"].to_i 
      elsif report_date > Date.parse("2019-12-31") && report_date < Date.parse("2020-07-01")
        q1q2_2020 = q1q2_2020 + s["total_revenue"].to_i
      end
    end
    
    if q1q2_2019 == 0 || q1q2_2020 == 0
      #MDLA
      #MA
      #RPAY
      #VHC
      puts c[:ticker]
    end

    if c.data.class == String
      data = JSON.parse(c.data) 
    else
      data = {}
    end
    
    data["q1q2_2019"] = q1q2_2019
    data["q1q2_2020"] = q1q2_2020

    if q1q2_2019 == 0 || q1q2_2020 == 0
      data["q1q2_difference"] = 0
    else
      data["q1q2_difference"] = (Float(q1q2_2020 - q1q2_2019) / q1q2_2020 * 100).ceil
    end
    
    puts "#{c.ticker} #{data.inspect}"
    c.data = data
    c.save!
  end
  
end




def write_results_json_data
  write_x_axis_data('XSW')
  write_stock_pricing_data('SPY')
  write_stock_pricing_data('XSW')
  write_insider_sales_data
end

def reset_historical_pricing_data(ticker)
  Stock.where("ticker = :ticker", {ticker: ticker}).delete_all
end


def get_companies_sorted_by_revenue_difference
  Company.all.sort_by { |hash| hash['data']['q1q2_difference'] }
end

def get_companies_sorted_by_amount_sold
  Transaction.all.joins(:company)
    .references(:company)
    .group('company_id, companies.name, companies.ticker, companies.data')
    .select("company_id, companies.name, companies.ticker, companies.data->'q1q2_difference' AS company_growth, SUM(amount) AS amount_sold")
    .where("transactions.document_date > '2019-12-31'")
    .order(amount_sold: :desc)
end

