# encoding: utf-8
require "sinatra/base"
require "sinatra/json"

class App < Sinatra::Base
  
  # Set up environment
  register Sinatra::ActiveRecordExtension
  
  get '/' do
    
    @companies = get_companies_sorted_by_amount_sold
    erb :index
  end


  get '/company/:ticker' do
    
    @transactions = Transaction.all.joins(:company)
      .references(:company)
      .select("company_id, companies.name, companies.ticker, transactions.document_url, transactions.amount, transactions.document_date")
      .where("transactions.document_date > '2019-12-31' AND companies.ticker = :ticker", {ticker:  params['ticker']})
      .order(amount: :desc)
    erb :company
  end

end