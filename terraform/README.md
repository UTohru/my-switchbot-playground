
## Usage
1. `.env.sample`から`.env`作成
2. run terraform
    1. `docker compose run --rm terraform -chdir=environments/prd/platform init` -> apply
       - `.env`のdynamodb_arnsを追加
    2. `docker compose run --rm terraform -chdir=environments/prd/iam init` -> apply
       - `.env`のlambda_role_arnを追加
    3. `docker compose run --rm terraform -chdir=environments/prd/state-switch-lambda init` -> apply
