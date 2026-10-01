{#
    True if the array contains the value (exact match).
    value is a SQL expression, so pass string literals with their quotes: array_contains_value('amenities', "'lockbox'")
#}
{% macro array_contains_value(array, value) -%}
    {{ return(adapter.dispatch('array_contains_value')(array, value)) }}
{%- endmacro %}


{% macro duckdb__array_contains_value(array, value) -%}
    list_contains({{ array }}, {{ value }})
{%- endmacro %}


{% macro snowflake__array_contains_value(array, value) -%}
    array_contains(({{ value }})::variant, {{ array }})
{%- endmacro %}


{% macro default__array_contains_value(array, value) -%}
    {{ exceptions.raise_compiler_error("array_contains_value is not implemented for adapter " ~ adapter.type()) }}
{%- endmacro %}
