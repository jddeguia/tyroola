{% macro enforce_prod_branch() %}
  {% if target.name == 'prod' %}
    {% set branch_check_query %}
      DECLARE current_branch STRING DEFAULT '{{ env_var("GIT_BRANCH", "unknown") }}';
      SELECT
        CASE
          WHEN current_branch != 'main' THEN ERROR(CONCAT('Production runs only allowed from main branch! Current branch: ', current_branch))
        END
    {% endset %}
    
    {% do run_query(branch_check_query) %}
  {% endif %}
{% endmacro %}