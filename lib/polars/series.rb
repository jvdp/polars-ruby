module Polars
  class Series
    attr_accessor :_s

    def initialize(name = nil, values = nil, dtype: nil, strict: true, nan_to_null: false, dtype_if_empty: nil)
      # Handle case where values are passed as the first argument
      if !name.nil? && !name.is_a?(String)
        if values.nil?
          values = name
          name = nil
        else
          raise ArgumentError, "Series name must be a string."
        end
      end

      name = "" if name.nil?

      if values.nil?
        self._s = sequence_to_rbseries(name, [], dtype: dtype, dtype_if_empty: dtype_if_empty)
      elsif values.is_a?(Range)
        self._s =
          Polars.arange(
            values.first,
            values.last + (values.exclude_end? ? 0 : 1),
            step: 1,
            eager: true,
            dtype: dtype
          )
          .rename(name, in_place: true)
          ._s
      elsif values.is_a?(Array)
        self._s = sequence_to_rbseries(name, values, dtype: dtype, strict: strict, dtype_if_empty: dtype_if_empty)
      else
        raise ArgumentError, "Series constructor called with unsupported type; got #{values.class.name}"
      end
    end

    def self._from_rbseries(s)
      series = Series.allocate
      series._s = s
      series
    end

    def dtype
      _s.dtype.to_sym
    end

    def flags
      {
        "SORTED_ASC" => _s.is_sorted_flag,
        "SORTED_DESC" => _s.is_sorted_reverse_flag
      }
    end

    def inner_dtype
      _s.inner_dtype&.to_sym
    end

    def name
      _s.name
    end

    def shape
      [_s.len]
    end

    def to_s
      _s.to_s
    end
    alias_method :inspect, :to_s

    def &(other)
      Utils.wrap_s(_s.bitand(other._s))
    end

    def |(other)
      Utils.wrap_s(_s.bitor(other._s))
    end

    def ^(other)
      Utils.wrap_s(_s.bitxor(other._s))
    end

    def +(other)
     Utils. wrap_s(_s.add(other._s))
    end

    def -(other)
      Utils.wrap_s(_s.sub(other._s))
    end

    def *(other)
      Utils.wrap_s(_s.mul(other._s))
    end

    def /(other)
      Utils.wrap_s(_s.div(other._s))
    end

    def **(power)
      # if is_datelike
      #   raise ArgumentError, "first cast to integer before raising datelike dtypes to a power"
      # end
      to_frame.select(Polars.col(name).pow(power)).to_series
    end

    def [](item)
      _s.get_idx(item)
    end

    def estimated_size(unit = "b")
      sz = _s.estimated_size
      Utils.scale_bytes(sz, to: unit)
    end

    def sqrt
      self ** 0.5
    end

    def any
      to_frame.select(Polars.col(name).any).to_series[0]
    end

    def all
      to_frame.select(Polars.col(name).all).to_series[0]
    end

    def to_frame
      Utils.wrap_df(RbDataFrame.new([_s]))
    end

    def sum
      _s.sum
    end

    def mean
      _s.mean
    end

    def product
      to_frame.select(Polars.col(name).product).to_series[0]
    end

    def min
      _s.min
    end

    def max
      _s.max
    end

    def std(ddof: 1)
      if !is_numeric
        nil
      else
        to_frame.select(Polars.col(name).std(ddof: ddof)).to_series[0]
      end
    end

    def var(ddof: 1)
      if !is_numeric
        nil
      else
        to_frame.select(Polars.col(name).var(ddof: ddof)).to_series[0]
      end
    end

    def median
      _s.median
    end

    def quantile(quantile, interpolation: "nearest")
      _s.quantile(quantile, interpolation)
    end

    def to_dummies
      Utils.wrap_df(_s.to_dummies)
    end

    def value_counts(sort: false)
      Utils.wrap_df(_s.value_counts(sort))
    end

    def alias(name)
      s = dup
      s._s.rename(name)
      s
    end

    def rename(name, in_place: false)
      if in_place
        _s.rename(name)
        self
      else
        self.alias(name)
      end
    end

    def chunk_lengths
      _s.chunk_lengths
    end

    def n_chunks
      _s.n_chunks
    end

    def cumsum(reverse: false)
      Utils.wrap_s(_s.cumsum(reverse))
    end

    def cummin(reverse: false)
      Utils.wrap_s(_s.cummin(reverse))
    end

    def cummax(reverse: false)
      Utils.wrap_s(_s.cummax(reverse))
    end

    def cumprod(reverse: false)
      Utils.wrap_s(_s.cumprod(reverse))
    end

    def limit(n = 10)
      to_frame.select(Utils.col(name).limit(n)).to_series
    end

    def slice(offset, length = nil)
      length = len if length.nil?
      Utils.wrap_s(_s.slice(offset, length))
    end

    def append(other)
      _s.append(other._s)
      self
    end

    def filter(predicate)
      Utils.wrap_s(_s.filter(predicate._s))
    end

    def head(n = 10)
      to_frame.select(Utils.col(name).head(n)).to_series
    end

    def tail(n = 10)
      to_frame.select(Utils.col(name).tail(n)).to_series
    end

    def sort(reverse: false, in_place: false)
      if in_place
        self._s = _s.sort(reverse)
        self
      else
        Utils.wrap_s(_s.sort(reverse))
      end
    end

    def arg_min
      _s.arg_min
    end

    def arg_max
      _s.arg_max
    end

    def null_count
      _s.null_count
    end

    def has_validity
      _s.has_validity
    end

    def is_empty
      len == 0
    end
    alias_method :empty?, :is_empty

    def series_equal(other, null_equal: false, strict: false)
      _s.series_equal(other._s, null_equal, strict)
    end

    def len
      _s.len
    end

    def to_a
      _s.to_a
    end

    def rechunk(in_place: false)
      opt_s = _s.rechunk(in_place)
      in_place ? self : Utils.wrap_s(opt_s)
    end

    def is_numeric
      [:i8, :i16, :i32, :i64, :u8, :u16, :u32, :u64, :f32, :f64].include?(dtype)
    end
    alias_method :numeric?, :is_numeric

    def is_float
      [:f32, :f64].include?(dtype)
    end
    alias_method :float?, :is_float

    def is_bool
      dtype == :bool
    end
    alias_method :bool?, :is_bool

    def is_utf8
      dtype == :str
    end
    alias_method :utf8?, :is_utf8

    private

    def initialize_copy(other)
      super
      self._s = _s._clone
    end

    def sequence_to_rbseries(name, values, dtype: nil, strict: true, dtype_if_empty: nil)
      ruby_dtype = nil

      if (values.nil? || values.empty?) && dtype.nil?
        if dtype_if_empty
          # if dtype for empty sequence could be guessed
          # (e.g comparisons between self and other)
          dtype = dtype_if_empty
        else
          # default to Float32 type
          dtype = "f32"
        end
      end

      # _get_first_non_none
      value = values.find { |v| !v.nil? }

      if !dtype.nil? && is_polars_dtype(dtype) && ruby_dtype.nil?
        constructor = polars_type_to_constructor(dtype)
        rbseries = constructor.call(name, values, strict)
        return rbseries
      end

      constructor = rb_type_to_constructor(value.class)
      constructor.call(name, values, strict)
    end

    POLARS_TYPE_TO_CONSTRUCTOR = {
      f32: RbSeries.method(:new_opt_f32),
      f64: RbSeries.method(:new_opt_f64),
      i8: RbSeries.method(:new_opt_i8),
      i16: RbSeries.method(:new_opt_i16),
      i32: RbSeries.method(:new_opt_i32),
      i64: RbSeries.method(:new_opt_i64),
      u8: RbSeries.method(:new_opt_u8),
      u16: RbSeries.method(:new_opt_u16),
      u32: RbSeries.method(:new_opt_u32),
      u64: RbSeries.method(:new_opt_u64),
      bool: RbSeries.method(:new_opt_bool),
      str: RbSeries.method(:new_str)
    }

    def polars_type_to_constructor(dtype)
      POLARS_TYPE_TO_CONSTRUCTOR.fetch(dtype.to_sym)
    rescue KeyError
      raise ArgumentError, "Cannot construct RbSeries for type #{dtype}."
    end

    RB_TYPE_TO_CONSTRUCTOR = {
      Float => RbSeries.method(:new_opt_f64),
      Integer => RbSeries.method(:new_opt_i64),
      String => RbSeries.method(:new_str),
      TrueClass => RbSeries.method(:new_opt_bool),
      FalseClass => RbSeries.method(:new_opt_bool)
    }

    def rb_type_to_constructor(dtype)
      RB_TYPE_TO_CONSTRUCTOR.fetch(dtype)
    rescue KeyError
      # RbSeries.method(:new_object)
      raise ArgumentError, "Cannot determine type"
    end

    def is_polars_dtype(data_type)
      true
    end
  end
end
