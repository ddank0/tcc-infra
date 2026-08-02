# tcc-infra

Orquestração do TCC - Sistema Inteligente para Licitações.

Sobe PostgreSQL, API e dashboard com um comando. Ponto de entrada do projeto.

## Layout esperado

O compose faz build por caminho relativo. Clone os repositórios lado a lado:

```bash
mkdir TCC && cd TCC
git clone git@github.com:ddank0/brain.git
git clone <tcc-jobs>
git clone <tcc-api>
git clone <tcc-frontend>
git clone <tcc-infra>
```

## Uso

```bash
cd tcc-infra
cp .env.example .env
docker compose up -d
```

Depois, carregue os dados a partir do `tcc-jobs` (ver README de lá) - os jobs
rodam por CLI, não como serviço.

## Documentação

Vault completo em `../brain/content/`, publicado em
[ddank0.github.io/brain](https://ddank0.github.io/brain).
