def excel_to_csv(old_excel)
  new_csv       = "#{File.basename(old_excel, File.extname(old_excel))}.csv"
  new_csv_path  = "#{download_path}#{new_csv}"
  excel = Roo::Excelx.new("#{download_path}#{old_excel}")
  excel.to_csv(new_csv_path)
end


def trim_csv_cruft(filepath)
  clean_csv = ''
  CSV.parse(File.read(filepath),:col_sep=>',',:headers=>false) do |row|
    if (row[3] && row[3] != "Unassigned") && (row.last == "Local Currency" || row.last == "USD") 
      clean_csv = clean_csv + CSV.generate_line(row)
    end
  end
  
  File.write(filepath, clean_csv)
end
