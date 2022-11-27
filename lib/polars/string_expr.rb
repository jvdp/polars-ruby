module Polars
  # Namespace for string related expressions.
  class StringExpr
    # @private
    attr_accessor :_rbexpr

    def initialize(expr)
      self._rbexpr = expr._rbexpr
    end

    # def strptime
    # end

    # Get length of the strings as `:u32` (as number of bytes).
    #
    # @return [Expr]
    #
    # @note
    #   The returned lengths are equal to the number of bytes in the UTF8 string. If you
    #   need the length in terms of the number of characters, use `n_chars` instead.
    #
    # @example
    #   df = Polars::DataFrame.new({"s" => ["Café", nil, "345", "東京"]}).with_columns(
    #     [
    #       Polars.col("s").str.lengths.alias("length"),
    #       Polars.col("s").str.n_chars.alias("nchars")
    #     ]
    #   )
    #   df
    #   # =>
    #   # shape: (4, 3)
    #   # ┌──────┬────────┬────────┐
    #   # │ s    ┆ length ┆ nchars │
    #   # │ ---  ┆ ---    ┆ ---    │
    #   # │ str  ┆ u32    ┆ u32    │
    #   # ╞══════╪════════╪════════╡
    #   # │ Café ┆ 5      ┆ 4      │
    #   # ├╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┤
    #   # │ null ┆ null   ┆ null   │
    #   # ├╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┤
    #   # │ 345  ┆ 3      ┆ 3      │
    #   # ├╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┤
    #   # │ 東京 ┆ 6      ┆ 2      │
    #   # └──────┴────────┴────────┘
    def lengths
      Utils.wrap_expr(_rbexpr.str_lengths)
    end

    # Get length of the strings as `:u32` (as number of chars).
    #
    # @return [Expr]
    #
    # @note
    #  If you know that you are working with ASCII text, `lengths` will be
    #  equivalent, and faster (returns length in terms of the number of bytes).
    #
    # @example
    #   df = Polars::DataFrame.new({"s" => ["Café", nil, "345", "東京"]}).with_columns(
    #     [
    #       Polars.col("s").str.lengths.alias("length"),
    #       Polars.col("s").str.n_chars.alias("nchars")
    #     ]
    #   )
    #   df
    #   # =>
    #   # shape: (4, 3)
    #   # ┌──────┬────────┬────────┐
    #   # │ s    ┆ length ┆ nchars │
    #   # │ ---  ┆ ---    ┆ ---    │
    #   # │ str  ┆ u32    ┆ u32    │
    #   # ╞══════╪════════╪════════╡
    #   # │ Café ┆ 5      ┆ 4      │
    #   # ├╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┤
    #   # │ null ┆ null   ┆ null   │
    #   # ├╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┤
    #   # │ 345  ┆ 3      ┆ 3      │
    #   # ├╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┼╌╌╌╌╌╌╌╌┤
    #   # │ 東京 ┆ 6      ┆ 2      │
    #   # └──────┴────────┴────────┘
    def n_chars
      Utils.wrap_expr(_rbexpr.str_n_chars)
    end

    # Vertically concat the values in the Series to a single string value.
    #
    # @param delimiter [String]
    #   The delimiter to insert between consecutive string values.
    #
    # @return [Expr]
    #
    # @example
    #   df = Polars::DataFrame.new({"foo" => [1, nil, 2]})
    #   df.select(Polars.col("foo").str.concat("-"))
    #   # =>
    #   # shape: (1, 1)
    #   # ┌──────────┐
    #   # │ foo      │
    #   # │ ---      │
    #   # │ str      │
    #   # ╞══════════╡
    #   # │ 1-null-2 │
    #   # └──────────┘
    def concat(delimiter = "-")
      Utils.wrap_expr(_rbexpr.str_concat(delimiter))
    end

    # Transform to uppercase variant.
    #
    # @return [Expr]
    #
    # @example
    #   df = Polars::DataFrame.new({"foo" => ["cat", "dog"]})
    #   df.select(Polars.col("foo").str.to_uppercase)
    #   # =>
    #   # shape: (2, 1)
    #   # ┌─────┐
    #   # │ foo │
    #   # │ --- │
    #   # │ str │
    #   # ╞═════╡
    #   # │ CAT │
    #   # ├╌╌╌╌╌┤
    #   # │ DOG │
    #   # └─────┘
    def to_uppercase
      Utils.wrap_expr(_rbexpr.str_to_uppercase)
    end

    # Transform to lowercase variant.
    #
    # @return [Expr]
    #
    # @example
    #   df = Polars::DataFrame.new({"foo" => ["CAT", "DOG"]})
    #   df.select(Polars.col("foo").str.to_lowercase)
    #   # =>
    #   # shape: (2, 1)
    #   # ┌─────┐
    #   # │ foo │
    #   # │ --- │
    #   # │ str │
    #   # ╞═════╡
    #   # │ cat │
    #   # ├╌╌╌╌╌┤
    #   # │ dog │
    #   # └─────┘
    def to_lowercase
      Utils.wrap_expr(_rbexpr.str_to_lowercase)
    end

    def strip(matches = nil)
      if !matches.nil? && matches.length > 1
        raise ArgumentError, "matches should contain a single character"
      end
      Utils.wrap_expr(_rbexpr.str_strip(matches))
    end

    def lstrip(matches = nil)
      if !matches.nil? && matches.length > 1
        raise ArgumentError, "matches should contain a single character"
      end
      Utils.wrap_expr(_rbexpr.str_lstrip(matches))
    end

    def rstrip(matches = nil)
      if !matches.nil? && matches.length > 1
        raise ArgumentError, "matches should contain a single character"
      end
      Utils.wrap_expr(_rbexpr.str_rstrip(matches))
    end

    def zfill(alignment)
      Utils.wrap_expr(_rbexpr.str_zfill(alignment))
    end

    def ljust(width, fillchar = " ")
      Utils.wrap_expr(_rbexpr.str_ljust(width, fillchar))
    end

    def rjust(width, fillchar = " ")
      Utils.wrap_expr(_rbexpr.str_rjust(width, fillchar))
    end

    def contains(pattern, literal: false)
      Utils.wrap_expr(_rbexpr.str_contains(pattern, literal))
    end

    def ends_with(sub)
      Utils.wrap_expr(_rbexpr.str_ends_with(sub))
    end

    def starts_with(sub)
      Utils.wrap_expr(_rbexpr.str_starts_with(sub))
    end

    # def json_path_match
    # end

    # def decode
    # end

    # def encode
    # end

    #
    def extract(pattern, group_index: 1)
      Utils.wrap_expr(_rbexpr.str_extract(pattern, group_index))
    end

    def extract_all(pattern)
      Utils.wrap_expr(_rbexpr.str_extract_all(pattern))
    end

    def count_match(pattern)
      Utils.wrap_expr(_rbexpr.count_match(pattern))
    end

    def split(by, inclusive: false)
      if inclusive
        Utils.wrap_expr(_rbexpr.str_split_inclusive(by))
      else
        Utils.wrap_expr(_rbexpr.str_split(by))
      end
    end

    def split_exact(by, n, inclusive: false)
      if inclusive
        Utils.wrap_expr(_rbexpr.str_split_exact_inclusive(by, n))
      else
        Utils.wrap_expr(_rbexpr.str_split_exact(by, n))
      end
    end

    def splitn(by, n)
      Utils.wrap_expr(_rbexpr.str_splitn(by, n))
    end

    def replace(pattern, literal: false)
      pattern = Utils.expr_to_lit_or_expr(pattern, str_to_lit: true)
      value = Utils.expr_to_lit_or_expr(value, str_to_lit: true)
      Utils.wrap_expr(_rbexpr.str_replace(pattern._rbexpr, value._rbexpr, literal))
    end

    def replace_all(pattern, literal: false)
      pattern = Utils.expr_to_lit_or_expr(pattern, str_to_lit: true)
      value = Utils.expr_to_lit_or_expr(value, str_to_lit: true)
      Utils.wrap_expr(_rbexpr.str_replace_all(pattern._rbexpr, value._rbexpr, literal))
    end

    def slice(offset, length = nil)
      Utils.wrap_expr(_rbexpr.str_slice(offset, length))
    end
  end
end
