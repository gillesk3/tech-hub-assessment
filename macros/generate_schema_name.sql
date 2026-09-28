{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set user = modules.re.sub('[^a-z0-9_]', '_', env_var('USER', '') | trim | lower) -%}

    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- elif user and target.name != 'prod' -%}
        dbt_{{ user }}_{{ custom_schema_name | trim }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
