require 'hako/data_frame'

module Dataset
  @@data_path = File.join(File.dirname(__FILE__), '../../data')
  # Fisher's iris data.
  # From Fisher, R. A. (1936) The use of multiple measurements in taxonomic problems. Annals of Eugenics, 7, Part II, 179–188.
  def Dataset::iris
    DataFrame.from_csv(File.read(File.join(@@data_path, 'iris.csv')))
  end

  # Fate of passengers on the fatal maiden voyage of the ocean liner ‘Titanic’ data.
  # From Dawson, Robert J. MacG. (1995), The ‘Unusual Episode’ Data Revisited. Journal of Statistics Education, 3.
  def Dataset::titanic
    DataFrame.from_csv(File.read(File.join(@@data_path, 'titanic.csv')))
  end

  # Savings ratio data in 1960–1970.
  # From Belsley, D. A., Kuh. E. and Welsch, R. E. (1980) Regression Diagnostics. New York: Wiley.
  def Dataset::life_cycle_savings
    DataFrame.from_csv(File.read(File.join(@@data_path, 'life_cycle_savings.csv')))
  end
end
