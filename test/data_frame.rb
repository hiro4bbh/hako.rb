require 'hako.rb'

require 'minitest/autorun'

class TestDataFrame < MiniTest::Test
  def test_initialize_and_getters
    iris = Dataset::iris
    assert_equal(150, iris.nrows)
    assert_equal(5, iris.ncols)
    assert_equal([
      [5.1, 3.5, 1.4, 0.2, "setosa"],
      [7.0, 3.2, 4.7, 1.4, "versicolor"],
      [6.3, 3.3, 6.0, 2.5, "virginica"]
    ], iris.select(0, 50, 100).to_a)
    assert_equal([
      [:sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [5.1, 3.5, 1.4, 0.2, "setosa"],
      [7.0, 3.2, 4.7, 1.4, "versicolor"],
      [6.3, 3.3, 6.0, 2.5, "virginica"]
    ], iris.select(0, 50, 100).to_a(with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [0, 5.1, 3.5, 1.4, 0.2, "setosa"],
      [50, 7.0, 3.2, 4.7, 1.4, "versicolor"],
      [100, 6.3, 3.3, 6.0, 2.5, "virginica"]
    ], iris.select(0, 50, 100).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [49, 5.0, 3.3, 1.4, 0.2, "setosa"],
      [50, 7.0, 3.2, 4.7, 1.4, "versicolor"],
      [51, 6.4, 3.2, 4.5, 1.5, "versicolor"]
    ], iris.select(49..51).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [147, 6.5, 3.0, 5.2, 2.0, "virginica"],
      [148, 6.2, 3.4, 5.4, 2.3, "virginica"],
      [149, 5.9, 3.0, 5.1, 1.8, "virginica"]
    ], iris.select(-3..-1).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [105, 7.6, 3.0, 6.6, 2.1, "virginica"],
      [117, 7.7, 3.8, 6.7, 2.2, "virginica"],
      [118, 7.7, 2.6, 6.9, 2.3, "virginica"],
      [122, 7.7, 2.8, 6.7, 2.0, "virginica"],
      [131, 7.9, 3.8, 6.4, 2.0, "virginica"],
      [135, 7.7, 3.0, 6.1, 2.3, "virginica"]
    ], iris.select do |row| row[:sepal_length] >= 7.5 end.to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [0, 5.1, 3.5, 1.4, 0.2, "setosa"],
      [50, 7.0, 3.2, 4.7, 1.4, "versicolor"],
      [100, 6.3, 3.3, 6.0, 2.5, "virginica"]
    ], iris.select do |row| row.rowid%50 == 0 end.to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [41, 4.5, 2.3, 1.3, 0.3, "setosa"],
      [53, 5.5, 2.3, 4.0, 1.3, "versicolor"],
      [57, 4.9, 2.4, 3.3, 1.0, "versicolor"],
      [60, 5.0, 2.0, 3.5, 1.0, "versicolor"],
      [62, 6.0, 2.2, 4.0, 1.0, "versicolor"],
      [68, 6.2, 2.2, 4.5, 1.5, "versicolor"],
      [80, 5.5, 2.4, 3.8, 1.1, "versicolor"],
      [81, 5.5, 2.4, 3.7, 1.0, "versicolor"],
      [87, 6.3, 2.3, 4.4, 1.3, "versicolor"],
      [93, 5.0, 2.3, 3.3, 1.0, "versicolor"],
      [119, 6.0, 2.2, 5.0, 1.5, "virginica"]
    ], iris.select do |row| row[1] < 2.5 end.to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :species],
      [13, 4.3, 3.0, "setosa"],
      [22, 4.6, 3.6, "setosa"]
    ], iris.select do |row| row[:petal_length] < 1.2 end.project(0, 1, 4).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :petal_length, :petal_width, :species],
      [13, 1.1, 0.1, "setosa"],
      [22, 1.0, 0.2, "setosa"]
    ], iris.select do |row| row[:petal_length] < 1.2 end.project(2..4).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :petal_length, :species],
      [13, 4.3, 1.1, "setosa"],
      [22, 4.6, 1.0, "setosa"]
    ], iris.select do |row| row[:petal_length] < 1.2 end.project(:sepal_length, :petal_length, :species).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :species, :sepal_length, :petal_length],
      [13, "setosa", 4.3, 1.1],
      [22, "setosa", 4.6, 1.0]
    ], iris.select do |row| row[:petal_length] < 1.2 end.project(:species, :sepal_length, :petal_length).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :petal_length],
      [13, 4.3, 1.1],
      [22, 4.6, 1.0]
    ], iris.select do |row| row[:petal_length] < 1.2 end.project(/length/i).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :petal_length, :petal_width],
      [13, 1.1, 0.1],
      [22, 1.0, 0.2]
    ], iris.select do |row| row[:petal_length] < 1.2 end.project(2..-2).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :petal_length],
      [13, 1.1],
      [22, 1.0]
    ], iris.select do |row| row[:petal_length] < 1.2 end.project(2..-2).project(0).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :petal_length],
      [13, 4.3, 1.1],
      [22, 4.6, 1.0]
    ], iris.project(/length/i).select do |row| row[:petal_length] < 1.2 end.to_a(with_rownames: true, with_colnames: true))
    assert_equal([5.1, 3.5, 1.4, 0.2, "setosa"], iris.row(0)[:*])
  end
  def test_converter
    iris = Dataset::iris
    assert_equal([
      ["", :a, :b],
      [0, 1, 2],
      [1, 3, 4]
    ], DataFrame.from_a([{:a => 1, :b => 2}, {:a => 3, :b => 4}]).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :a, :b],
      [0, 1, 2],
      [1, 3, 4]
    ], DataFrame.from_a([{:a => 1, :b => 2}, {:a => 3, :b => 4}]).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :a, :b],
      [:row1, 1, 2],
      [:row2, 3, 4]
    ], DataFrame.from_a([{:a => 1, :b => 2}, {:a => 3, :b => 4}], rownames: {:row1 => 0, :row2 => 1}).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :b, :a],
      [0, 2, 1],
      [1, 4, 3]
    ], DataFrame.from_a([{:a => 1, :b => 2}, {:a => 3, :b => 4, :c => 5}], colnames: [:b, :a]).to_a(with_rownames: true, with_colnames: true))
    assert_equal("sepal_length,petal_length\n4.3,1.1\n4.6,1.0\n", iris.select do |row| row[:petal_length] < 1.2 end.project(/length/i).to_csv)
    assert_equal("\"\",sepal_length,petal_length\n13,4.3,1.1\n22,4.6,1.0\n", iris.select do |row| row[:petal_length] < 1.2 end.project(/length/i).to_csv(with_rownames: true, with_colnames: true))
    assert_equal("4.3,1.1\n4.6,1.0\n", iris.select do |row| row[:petal_length] < 1.2 end.project(/length/i).to_csv(with_colnames: false))
    assert_equal([["", :sepal_length, :petal_length], [0, 4.3, 1.1], [1, 4.6, 1.0]], DataFrame.from_csv("sepal_length,petal_length\n4.3,1.1\n4.6,1.0\n").to_a(with_rownames: true, with_colnames: true))
    assert_equal([["", :sepal_length, :petal_length], [13, 4.3, 1.1], [22, 4.6, 1.0]], DataFrame.from_csv("\"\",sepal_length,petal_length\n13,4.3,1.1\n22,4.6,1.0\n", with_rownames: true, with_colnames: true).to_a(with_rownames: true, with_colnames: true))
    assert_equal([["", :var0, :var1], [0, 4.3, 1.1], [1, 4.6, 1.0]], DataFrame.from_csv("4.3,1.1\n4.6,1.0\n", with_colnames: false).to_a(with_rownames: true, with_colnames: true))
    assert_equal(
      Matrix[[1.0],[1.0],[1.0],[1.0],[1.0],[0.0],[0.0],[0.0],[0.0],[0.0],[0.0],[0.0],[0.0],[0.0],[0.0]],
      iris.select(0..4, 50..54, 100..104).set_column!(colname: :is_setosa) do |row| row[:species] == 'setosa' end.project(:is_setosa).to_matrix)
  end
  def test_rownames
    iris = Dataset::iris
    iris.rownames[0] = 'special'
    iris.rownames[2] = 'very_special'
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      ["special", 5.1, 3.5, 1.4, 0.2, "setosa"],
      [1, 4.9, 3.0, 1.4, 0.2, "setosa"],
      ["very_special", 4.7, 3.2, 1.3, 0.2, "setosa"]
    ], iris.select(0, 1, 2).to_a(with_rownames: true, with_colnames: true))
    iris.rownames.delete_at(1)
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      ["special", 5.1, 3.5, 1.4, 0.2, "setosa"],
      ["very_special", 4.7, 3.2, 1.3, 0.2, "setosa"],
      [3, 4.6, 3.1, 1.5, 0.2, "setosa"]
    ], iris.select(0, 1, 2).to_a(with_rownames: true, with_colnames: true))
    iris.rownames.fill(-1..-149)
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [-149, 5.1, 3.5, 1.4, 0.2, "setosa"],
      [-148, 4.7, 3.2, 1.3, 0.2, "setosa"],
      [-147, 4.6, 3.1, 1.5, 0.2, "setosa"],
      [-100, 7.0, 3.2, 4.7, 1.4, "versicolor"],
      [-50, 6.3, 3.3, 6.0, 2.5, "virginica"]
    ], iris.select(0, 1, 2, 49, 99).to_a(with_rownames: true, with_colnames: true))
  end
  def test_set_apply
    iris = Dataset::iris
    iris_copy = iris.copy
    iris_copy << [0.0, 0.0, 0.0, 0.0, 'unknown']
    assert_equal(151, iris_copy.nrows)
    iris_copy.set_row!([0.0, 0.0, 0.0, 0.0, 'illegal'], rowname: 150)
    assert_equal(151, iris_copy.nrows)
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [150, 0.0, 0.0, 0.0, 0.0, "illegal"]
    ], iris_copy.select(150).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :value], [2, 6.0], [6, 6.0], [47, 6.0], [62, 10.0], [116, 12.0], [128, 12.0], [132, 12.0], [141, 12.0], [150, 0.0]
    ], iris_copy.apply_rows do |row| row[:sepal_length] + row[:petal_length] end.select do |row| row[:value]%2.0 == 0.0 end.to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species, :length],
      [2, 4.7, 3.2, 1.3, 0.2, "setosa", 6.0],
      [6, 4.6, 3.4, 1.4, 0.3, "setosa", 6.0],
      [47, 4.6, 3.2, 1.4, 0.2, "setosa", 6.0]
    ], iris_copy.set_column(colname: :length) do |row| row[:sepal_length] + row[:petal_length] end.select(2, 6, 47).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species, :length],
      [2, 4.7, 3.2, 1.3, 0.2, "setosa", 0],
      [6, 4.6, 3.4, 1.4, 0.3, "setosa", 0],
      [47, 4.6, 3.2, 1.4, 0.2, "setosa", 0]
    ], iris_copy.select(2, 6, 47).set_column(0, colname: :length).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species, :length],
      [2, 4.7, 3.2, 1.3, 0.2, "setosa", 3.0],
      [6, 4.6, 3.4, 1.4, 0.3, "setosa", 2.0],
      [47, 4.6, 3.2, 1.4, 0.2, "setosa", 1.0]
    ], iris_copy.select(2, 6, 47).set_column(Vector[3.0, 2.0, 1.0], colname: :length).to_a(with_rownames: true, with_colnames: true))
    # Testing Dataset.copy
    assert_equal(150, iris.nrows)
  end
  def test_fill
    iris = Dataset::iris
    assert_equal([
      ["", :sepal_width, :petal_width],
      [0, 5.1, 5.1],
      [1, 4.9, 4.9],
      [2, 4.7, 4.7],
      [3, 4.6, 4.6],
      [4, 5.0, 5.0]
    ], iris.select(0..4).project(:sepal_width, :petal_width).fill(iris.select(0..4).project(:sepal_length, :sepal_length)).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [0, 0, 0, 0, 0, "unknown"]
    ], iris.select(0).fill([0, 0, 0, 0, 'unknown']).to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length],
      [0, 1],
      [50, 51],
      [100, 101]
    ], iris.project(0).fill(1..150).select(0, 50, 100).to_a(with_rownames: true, with_colnames: true))
    assert_equal([5.1, 3.5, 1.4, 0.2, 'setosa'], iris.row(0)[:*])
  end
  def test_sort
    iris = Dataset::iris
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [13, 4.3, 3.0, 1.1, 0.1, "setosa"],
      [8, 4.4, 2.9, 1.4, 0.2, "setosa"],
      [38, 4.4, 3.0, 1.3, 0.2, "setosa"],
      [42, 4.4, 3.2, 1.3, 0.2, "setosa"]
    ], iris.sort do |row| row[:sepal_length] end.select do |row| row[:sepal_length] < 4.5 end.to_a(with_rownames: true, with_colnames: true))
    assert_equal([
      ["", :sepal_length, :sepal_width, :petal_length, :petal_width, :species],
      [13, 4.3, 3.0, 1.1, 0.1, "setosa"],
      [8, 4.4, 2.9, 1.4, 0.2, "setosa"],
      [38, 4.4, 3.0, 1.3, 0.2, "setosa"],
      [42, 4.4, 3.2, 1.3, 0.2, "setosa"]
    ], iris.sort_by do |row| row[:sepal_length] end.select do |row| row[:sepal_length] < 4.5 end.to_a(with_rownames: true, with_colnames: true))
    # Testing Dataset.copy
    assert_equal([5.1, 3.5, 1.4, 0.2, 'setosa'], iris.row(0)[:*])
  end
end
