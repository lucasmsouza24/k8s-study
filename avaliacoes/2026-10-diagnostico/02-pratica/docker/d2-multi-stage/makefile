IMAGE = aval-d2

run:
	docker build -t $(IMAGE):dev .
	docker run --rm -p 8080:8080 --name $(IMAGE)-dev $(IMAGE):dev

check:
	bash check.sh

clean:
	docker rm -f $(IMAGE)-dev $(IMAGE)-check 2>/dev/null || true
	docker rmi -f $(IMAGE):dev $(IMAGE):check 2>/dev/null || true
