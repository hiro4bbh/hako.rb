require 'csv'
require 'json'

# DataFrame is the high level interface to any underlying two-dimensional
# data structure in hako.
# DataFrame's underlying data structure must have Array interface
# containing Hash for row information whose key is the corresponding column
# name.
class DataFrame
  # Reference to row in DataFrame.
  class Row
    attr_reader :df, :rowid, :rowname
    # DO NOT use this externally.
    def initialize(df, rowid, row)
      @df = df
      @rowid = rowid
      @rowname = df.rownames[rowid]
      @row = row
    end
    def inspect
      "DataFrame::Row<df=#{df}, rowid=#{rowid}, rowname=#{rowname}>"
    end
    alias to_s inspect

    # Accessor to cell in row selected by _J.
    #
    # @param _J indices Array
    def [](_J)
      row = df.colnames(_J).collect do |j| @row[j] end
      if not _J.is_a? Enumerable and row.length == 1 then row[0] else row end
    end
  end

  # DO NOT use this externally because this doesn't check arguments, which
  # would cause unexpected mysterious errors.
  #
  # @param rows underlying two-dimensional data structure.
  # @param rownames Hash mapping row name to index of @rows.
  # @param colnames Array of column names (Symbol) if specified.
  def initialize(rows, rownames: nil, colnames: nil)
    @rows = rows
    @rownames = (rownames || Hash[*rows.length.times.map do |i| [i, i] end.flatten(1)]).to_ordered_hash
    unless colnames then
      colnames = {}
      rows.each do |row| row.keys.each do |colname| colnames[colname] = true end end
      colnames = colnames.keys
    end
    @colnames = colnames.collect do |colname| colname.to_s.to_sym end
  end
  # Returns DataFrame refers to a.
  #
  # @param a is Array used as underlying two-dimensional data structure.
  # @param rownames Hash mapping row name to index of @rows.
  # @param colnames Array of column names if specified.
  def DataFrame.from_a(a=[], rownames: nil, colnames: nil)
    a.each.with_index do |row, i| raise "a[#{i}] must be Hash" unless row.is_a? Hash end
    if rownames then
      raise 'rownames must be Hash' unless rownames.is_a? Hash
      rownames.each do |rowname, i| raise "rownames[#{rowname}] must be valid index to a" unless 0 <= i and i < a.length end
    end
    if colnames then
      raise 'colnames must be Array' unless colnames.is_a? Array
    end
    DataFrame.new(a, rownames: rownames, colnames: colnames)
  end
  # Returns DataFrame constructed by csvdata.
  #
  # @param csvdata is CSV string.
  # @param with_rownames first cell in rows in CSV is treated as row name
  #                      if true.
  # @param with_colnames first row in CSV is treated as Array of column
  #                      names if true.
  # @param infer_types values in a column are converted into automatically
  #                    inferred types if true.
  def DataFrame.from_csv(csvdata, with_rownames: false, with_colnames: true, infer_types: true)
    rows = CSV::parse(csvdata)
    header = if with_colnames then
      raise "csvdata must have header row at first" if rows.length < 1
      row = rows.shift
      if with_rownames then
        raise 'CSV row should have at least 1 column if with_rownames == true' if row.length < 1
        row.shift
      end
      row
    else
      if rows.length < 1 then
        []
      else
        row = rows[0]
        if with_rownames then
          raise 'CSV row should have at least 1 column if with_rownames == true' if row.length < 1
          row.shift
        end
        row.length.times.collect do |j| "var#{j}" end
      end
    end
    rownames = if with_rownames then
      column = rows.collect do |row| row[0] end
      type = column.infer_string_type
      if type == Integer then
        column.collect! do |cell| Integer(cell) end
      elsif type == Float then
        column.collect! do |cell| Float(cell) end
      end
      rownames = Hash[*column.collect!.with_index do |cell, i| [cell, i] end.flatten(1)]
    end
    header.collect! do |colname| colname.to_s.to_sym end
    df = DataFrame.new(
      if with_rownames then
        rows.collect do |row| Hash[*header.zip(row[1..-1]).flatten(1)] end
      else
        rows.collect do |row| Hash[*header.zip(row).flatten(1)] end
      end,
      rownames: rownames,
      colnames: header)
    df.infer_types! if infer_types
  end
  def inspect
    "DataFrame<nrows=#{nrows}, colnames=#{colnames}>"
  end
  alias to_s inspect
  def display(maxrows=nil, terminal: $HAKO_TERMINAL)
    InspectString.new("#{self.class}<nrows=#{nrows}, ncols=#{ncols}>\n" + terminal.dump_table(maxrows: maxrows, nheaders: 1) do |i|
      next [''] + @colnames.map do |colname| colname.inspect end if i < 0
      next nil unless i < nrows
      rowname = @rownames.keys[i]
      row = @rows[@rownames[rowname]]
      [rowname] + @colnames.collect do |colname| row[colname].inspect end
    end)
  end
  # Returns Array converted from self.
  #
  # @param with_rownames returned row contains its row name at first column
  #                      if true.
  # @param with_colnames first row in returned Array contains column names
  #                      if true.
  def to_a(with_rownames: false, with_colnames: false)
    a = if with_colnames then [(if with_rownames then [''] else [] end) + colnames.clone] else [] end
    each do |row| a << (if with_rownames then [row.rowname] else [] end) + row[colnames] end
    a
  end
  # Returns CSV string converted from self.
  #
  # @param with_rownames returned row contains its row name at first column
  #                      if true.
  # @param with_colnames first row in returned Array contains column names
  #                      if true.
  def to_csv(with_rownames: false, with_colnames: true)
    a = to_a(with_rownames: with_rownames, with_colnames: with_colnames)
    CSV::generate do |csv| a.each do |row| csv << row end end
  end
  # Returns Matrix converted from self.
  # If some cells contains values which cannot be converted into Float, it
  # will be Float::NAN.
  def to_matrix
    rows = to_a(with_colnames: false)
    rows.each do |row|
      row.collect! do |x|
        case x
        when true then 1.0
        when false then 0.0
        else Float(x) rescue Float::NAN
        end
      end
    end
    rows.to_matrix
  end
  # Returns number of rows in self.
  def nrows
    @rownames.size
  end
  # Returns number of columns in self.
  def ncols
    @colnames.length
  end
  # Returns copied self which won't be affected changes by self.
  def copy
    DataFrame.new(@rows.copy, rownames: @rownames.copy, colnames: @colnames.copy)
  end

  # Converts values in column into automatically inferred typed values.
  def infer_types!
    types = Array.new(ncols)
    each do |row| merge_types(types, row[:*].infer_string_types) end
    types.each.with_index do |type, i|
      colname = @colnames[i]
      if type <= Integer then
        @rownames.each do |_, rowid| @rows[rowid][colname] = Integer(@rows[rowid][colname]) end
      elsif type <= Float then
        @rownames.each do |_, rowid| @rows[rowid][colname] = Float(@rows[rowid][colname]) end
      end
    end
    self
  end
  # (see #infer_types!)
  def infer_types
    copy.infer_types!
  end

  # Returns Row of rowid-th row.
  def row(rowid)
    raise 'rowid is out of index' unless 0 <= rowid and rowid < nrows
    Row.new(self, rowid, @rows[@rownames[@rownames.keys[rowid]]])
  end
  # Iterates rows.
  def each
    return to_enum unless block_given?
    @rownames.each.with_index do |(rowname, i), rowid| yield Row.new(self, rowid, @rows[i]) end
    self
  end
  # Returns row names selected by _I.
  #
  # @param _I indices Array.
  def rownames(_I=:*)
    return @rownames.keys if _I == :*
    case _I
    when Array then
      _I.collect do |i| rownames(i) end.flatten(1)
    when Range then
      first = if _I.first < 0 then nrows + _I.first else _I.first end
      last = if _I.last < 0 then nrows + _I.last else _I.last end
      first.upto(last).collect do |j| @rownames.keys[j] end
    when Integer then
      _I = nrows + _I if _I < 0
      [@rownames.keys[_I]]
    when Regexp then
      rownames.select do |rowname| _I.match?(rowname) end
    else
      [_I]
    end
  end
  # Selects rows which block returns true or selected by _I if given.
  #
  # @param _I indices Array.
  def select(*_I)
    rownames = if block_given? then
      rownames = {}
      @rownames.each.with_index do |(rowname, i), rowid| rownames[rowname] = i if yield Row.new(self, rowid, @rows[i]) end
      rownames
    else
      return to_enum if _I.length == 0
      Hash[*rownames(_I).collect do |rowname| [rowname, @rownames[rowname]] end.flatten(1)]
    end
    DataFrame.new(@rows, rownames: rownames, colnames: @colnames)
  end

  # colnames returns column names selected by _J.
  #
  # @param _J indices Array.
  def colnames(_J=:*)
    return @colnames if _J == :*
    case _J
    when Array then
      _J.collect do |j| colnames(j) end.flatten(1)
    when Range then
      first = if _J.first < 0 then ncols + _J.first else _J.first end
      last = if _J.last < 0 then ncols + _J.last else _J.last end
      first.upto(last).collect do |j| @colnames[j] end
    when Integer then
      _J = ncols + _J if _J < 0
      [@colnames[_J]]
    when Regexp then
      colnames.select do |colname| _J.match?(colname) end
    else
      [_J]
    end
  end
  # Projects self into columns selected by _J
  def project(*_J)
    DataFrame.new(@rows, rownames: @rownames, colnames: colnames(_J))
  end

  # Returns new row name for appending new row.
  def get_new_rowname
    id = nrows
    while true do
      break id unless rownames[id]
      id += 1
    end
  end
  # Append row.
  #
  # @param row Array or Hash containing row data.
  def <<(row)
    set_row!(row)
  end
  # Set row, which would cause overwrite.
  #
  # @param row Array or Hash containing row data.
  # @param rowname row name.
  def set_row!(row, rowname: nil)
    rowname ||= get_new_rowname
    case row
    when Array then
      raise "row must have #{ncols} columns" unless row.length == ncols
      row = Hash[*colnames.zip(row).flatten(1)]
    when Hash then
    else raise 'row must be Array or Hash'
    end
    if @rownames[rowname] then
      @rows[@rownames[rowname]] = row
    else
      @rownames[rowname] = @rows.length
      @rows << row
    end
    self
  end
  # (see #set_row!)
  def set_row(row, rowname: nil)
    copy.set_row!(row, rowname: rowname)
  end

  # Returns new column name for appending column
  def get_new_colname
    id = ncols
    while true do
      break :"var#{id}" unless colnames.include?(:"var#{id}")
      id += 1
    end
  end
  # Set column, which would cause overwrite.
  # If neither column nor callback is given, returns Enumerator.
  #
  # @param column Array-like Object containing column data or Object for
  # filled value unless callback is given.
  # @param colname column name
  # @param callback filled by values callback returns given row if given.
  def set_column!(column=nil, colname: nil, &callback)
    colname ||= get_new_colname
    if callback then
      each do |row| @rows[@rownames[row.rowname]][colname] = yield(row) end
    else
      return to_enum unless column
      column = column.to_a if column.respond_to? :to_a
      case column
      when Array then
        raise "arg must have #{nrow} elements" unless column.length == nrows
        each do |row| @rows[@rownames[row.rowname]][colname] = column[row.rowid] end
      else
        each do |row| @rows[@rownames[row.rowname]][colname] = column end
      end
    end
    @colnames << colname
    self
  end
  # (see set_column!)
  def set_column(column=nil, colname: nil, &callback)
    copy.set_column!(column, colname: colname, &callback)
  end
  # Fill self with values.
  #
  # @param values Array-like Object which contains values and would be
  # flattened at first level if needed, or Object for filled value.
  def fill!(values)
    values = values.to_a if values.respond_to? :to_a
    if nrows == 1 then
      raise "values must have #{ncols} elements" unless values.length == ncols
    elsif ncols == 1 then
      raise "values must have #{nrows} elements" unless values.length == nrows
    else
      values = values.flatten(1) if values.length > 0 and values[0].is_a? Array
      raise "values must have #{nrows}x#{ncols} (= #{nrows*ncols}) elements" unless values.length == nrows*ncols
    end
    nrows.times do |rowid|
      row = @rows[@rownames.keys[rowid]]
      colnames.each.with_index do |colname, j| row[colname] = values[rowid*ncols + j] end
    end
    self
  end
  # (see #fill!)
  def fill(values)
    copy.fill!(values)
  end

  # Returns new DataFrame which contains a column having evaluated values
  # returned by block.
  # If block is not given, returns Enumerator.
  def apply_rows
    return to_enum unless block_given?
    DataFrame.new(each.collect do |row| {:value => yield(row)} end, rownames: @rownames, colnames: [:value])
  end

  # Sorts rows in stable manner with block.
  def sort_by!
    return to_enum unless block_given?
    @rownames = Hash[*@rownames.sort_by.with_index do |(rowname, i), rowid| [yield(Row.new(self, rowid, @rows[i])), rowid] end.flatten(1)]
    self
  end
  # (see sort_by!)
  def sort_by(&callback)
    copy.sort_by!(&callback)
  end
  alias sort sort_by
  alias sort! sort_by!
end
