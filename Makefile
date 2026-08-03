.DEFAULT_GOAL := help
.PHONY: help up down logs ps rebuild test test-jobs test-api test-front \
        lint lint-jobs lint-api lint-front check migrate shell-jobs shell-api \
        shell-front build-prod verify

help:  ## lista os alvos disponíveis
	@grep -E '^[a-z-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

up:  ## sobe todos os serviços
	docker compose up -d --build

down:  ## derruba os serviços, preservando o banco
	docker compose down

logs:  ## acompanha os logs de todos os serviços
	docker compose logs -f

ps:  ## estado dos serviços
	docker compose ps

rebuild:  ## reconstrói as imagens do zero
	docker compose build --no-cache

test: test-jobs test-api test-front  ## suíte dos três repositórios

test-jobs:  ## pytest no container de jobs
	docker compose exec jobs uv run pytest -v

test-api:  ## phpunit no container da api
	docker compose exec api ./vendor/bin/phpunit

test-front:  ## specs do dashboard
	docker compose exec frontend npm test -- --watch=false

lint: lint-jobs lint-api lint-front  ## lint e análise estática das três stacks

lint-jobs:
	docker compose exec jobs uv run ruff check .
	docker compose exec jobs uv run ruff format --check .
	docker compose exec jobs uv run mypy

lint-api:
	docker compose exec api ./vendor/bin/pint --test
	docker compose exec api php -d memory_limit=1G ./vendor/bin/phpstan analyse --no-progress

lint-front:
	docker compose exec frontend npm run lint

check: lint test  ## tudo que o CI roda: lint, análise estática e testes

migrate:  ## aplica as migrations
	docker compose exec jobs uv run alembic upgrade head

shell-jobs:  ## shell no container de jobs
	docker compose exec jobs bash

shell-api:  ## shell no container da api
	docker compose exec api sh

shell-front:  ## shell no container do dashboard
	docker compose exec frontend sh

build-prod:  ## verifica que os estágios de produção compilam
	docker build --target prod -t tcc-jobs:prod ../tcc-jobs
	docker build --target prod -t tcc-api:prod ../tcc-api
	docker build --target prod -t tcc-frontend:prod ../tcc-frontend

verify:  ## verificação fim a fim da cadeia inteira
	@echo "-- serviços"
	@docker compose ps --format 'table {{.Name}}\t{{.Status}}'
	@echo "\n-- api"
	@curl -sf http://localhost:8000/api/health || echo "FALHOU"
	@echo "\n\n-- dashboard"
	@curl -sf -o /dev/null -w 'HTTP %{http_code}\n' http://localhost:4200 || echo "FALHOU"
	@echo "\n-- tabelas no banco"
	@docker compose exec -T postgres psql -U tcc -d tcc -tc \
		"SELECT count(*) FROM information_schema.tables WHERE table_schema='public'" | tr -d ' '
