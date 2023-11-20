
# def write_stock_pricing_data_OLD(ticker)
#   results_file = "#{download_path}result.json"
#   results = JSON.parse(File.read(results_file))
  
#   if results['datasets'].class != Array
#     results['datasets'] = []    
#   end

#   data = []
#   Stock.where("ticker = :ticker", {ticker: ticker}).order(date: :desc).each do |s|
#     data << s[:price].to_i
#   end
  
#   results['datasets'] << {
#     "name": ticker,
#     "data": data,
#     "unit": "dollar",
#     "type": "line",
#     "valueDecimals": 1
#   }
  
#   File.write(results_file, JSON.pretty_generate(results))
# end



def write_insider_sales_data
  results_file = "#{public_data_path}secform4.json"
  # byebug
  content = File.exists?(results_file) ? File.read(results_file) : '{}'
  results = JSON.parse(content)
  
  if results['datasets'].class != Array
    results['datasets'] = []    
  end

  data = []
  sales = get_sales_transaction_proceeds
  
  Stock.where("ticker = :ticker", {ticker: 'SPY'}).order(date: :desc).each do |stock|
    current = sales.filter{|sale| sale.date_group.to_date == stock.date.to_date }
    
    if current.count > 0
      data << current.first[:amount].to_i
    else
      data << 0
    end
  end
  
  results['datasets'] << {
    "name": "Insider sales",
    "data": data,
    "unit": "dollar",
    "type": "area",
    "valueDecimals": 1
  }
  
  File.write(results_file, JSON.pretty_generate(results))
end


def reset_results_json_data
  results_file = "#{public_data_path}secform4.json"
  File.write(results_file, JSON.pretty_generate({}))
end


def write_x_axis_data(ticker)
  results_file = "#{public_data_path}secform4.json"
  results = JSON.parse(File.read(results_file))
  results['xData'] = []
  
  Stock.where("ticker = :ticker", {ticker: ticker}).order(date: :desc).each do |s|
    results['xData'] <<  s[:date].to_i * 1000 # Javascript calculates milliseconds
  end
  
  File.write(results_file, results.to_json)
end

def write_stock_pricing_data(ticker)
  results_file = "#{public_data_path}#{ticker}.json"

  data = []
  Stock.where("ticker = :ticker", {ticker: ticker}).order(date: :asc).each do |s|
    data << [s[:date].to_i + 1000, s[:price].to_f]
  end
  
  File.write(results_file, JSON.pretty_generate(data))
end
