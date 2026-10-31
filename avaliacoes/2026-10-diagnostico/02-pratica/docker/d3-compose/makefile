up:
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f

check:
	bash check.sh

clean:
	docker compose down -v --rmi local 2>/dev/null || true
