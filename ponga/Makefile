.PHONY: up down logs populate reset-db test lint unit integration e2e clean

up:          ## build and start db, backend and frontend
	docker compose up -d --build --wait
down:        ## stop the stack (keeps the database volume)
	docker compose down
clean:       ## stop the stack and delete the database volume
	docker compose down -v --remove-orphans
logs:
	docker compose logs -f
populate:    ## load demo data and verify the database
	scripts/populate_and_test_db.sh
reset-db:    ## wipe all data, reload demo data and verify
	scripts/populate_and_test_db.sh --reset
lint:
	scripts/run_tests.sh lint
unit:
	scripts/run_tests.sh unit
integration:
	scripts/run_tests.sh integration
e2e:
	scripts/run_tests.sh e2e
test:        ## everything: lint, unit, integration, e2e
	scripts/run_tests.sh all
