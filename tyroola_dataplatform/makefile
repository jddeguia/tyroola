# Makefile for DBT Project Execution

### Variables
DBT_FLAGS ?=  # Allows passing additional flags like --target, --vars, etc.

### Targets
.PHONY: help list-models run-model run-all full-refresh full-refresh-all full-refresh-upstream-all

## Default target
help:
	@echo "DBT Model Execution Makefile"
	@echo "Usage:"
	@echo "  make list-models               List all available models"
	@echo "  make run-model MODEL=name      Run model + dependencies (incremental)"
	@echo "  make run-all                   Run all models (standard build)"
	@echo "  make full-refresh MODEL=name   Fully rebuild model + dependencies"
	@echo "  make full-refresh-all          Fully rebuild all models"
	@echo "  make full-refresh-upstream-all Fully rebuild ENTIRE DAG from scratch"
	@echo ""
	@echo "Options:"
	@echo "  DBT_FLAGS='...'   Pass additional dbt flags (e.g., '--target prod')"

## List all available models
list-models:
	@dbt ls --output name $(DBT_FLAGS)

## Run specific model with dependencies (incremental)
run-model:
ifndef MODEL
	$(error MODEL is required. Usage: make run-model MODEL=model_name)
endif
	@dbt run --select +$(MODEL) $(DBT_FLAGS)

## Run all models (standard incremental build)
run-all:
	@dbt run $(DBT_FLAGS)

## Fully rebuild specific model + all upstream dependencies
full-refresh:
ifndef MODEL
	$(error MODEL is required. Usage: make full-refresh MODEL=model_name)
endif
	@dbt run --select +$(MODEL) --full-refresh $(DBT_FLAGS)

## Fully rebuild all models in project
full-refresh-all:
	@dbt run --full-refresh $(DBT_FLAGS)

## Nuclear option: fully rebuild ENTIRE DAG from scratch
full-refresh-upstream-all:
	@dbt run --select +* --full-refresh $(DBT_FLAGS)