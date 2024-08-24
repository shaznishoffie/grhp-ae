{%- macro exec_date() -%}
  {{ "DATE('{}')".format(var("exec_date")) }}
{%- endmacro -%}
