
## Usage
1. `.env.sample`から`.env`作成
2. run terraform
    1. `docker compose run --rm terraform -chdir=environments/prd/platform init` -> apply
    2. `docker compose run --rm terraform -chdir=environments/prd/iam init` -> apply
    3. `docker compose run --rm terraform -chdir=environments/prd/state-switch-lambda init` -> apply
