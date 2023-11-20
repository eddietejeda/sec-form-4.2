require './lib/transform'

reset_historical_pricing_data("SPY")
reset_historical_pricing_data("XSW")

load_ticker_historical_pricing_data("SPY")
load_ticker_historical_pricing_data("XSW")
load_companies_from_index_fund("XSW")


load_financial_data_for_all_companies



add_sec_ids_to_companies
add_sec_transaction_data_to_companies

# reset_results_json_data
# write_results_json_data