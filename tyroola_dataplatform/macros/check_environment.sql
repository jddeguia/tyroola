{% macro check_branch() %}
  {% if target.name == 'prod' and flags.WHICH in ['run','build'] %}
    {% set current_branch = env_var('GIT_BRANCH', 'unknown') %}
    {% if current_branch not in ['main', 'origin/main'] %}
      {{ exceptions.raise_compiler_error("🚫 Production runs require main branch") }}
    {% endif %}
  {% endif %}
{% endmacro %}