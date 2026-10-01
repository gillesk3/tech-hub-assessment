{#
    Parse a JSON array stored as text (e.g. '["Wifi", "Oven"]') into the warehouse's native array type.
    Pass lower(column) to lowercase the values as they are parsed.
#}
{% macro parse_json_array(column) -%}
    {{ return(adapter.dispatch('parse_json_array')(column)) }}
{%- endmacro %}


{% macro duckdb__parse_json_array(column) -%}
    from_json({{ column }}, '["VARCHAR"]')
{%- endmacro %}


{% macro snowflake__parse_json_array(column) -%}
    parse_json({{ column }})::array
{%- endmacro %}


{% macro default__parse_json_array(column) -%}
    {{ exceptions.raise_compiler_error("parse_json_array is not implemented for adapter " ~ adapter.type()) }}
{%- endmacro %}
