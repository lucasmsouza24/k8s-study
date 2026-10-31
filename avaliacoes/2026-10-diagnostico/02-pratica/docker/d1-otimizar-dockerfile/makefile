IMAGE = aval-d1

setup:
	mkdir -p dataset
	test -f dataset/dump.bin || head -c 150M /dev/urandom > dataset/dump.bin
	printf 'API_TOKEN=supersecret123\nDB_PASSWORD=postgres123\n' > .env
	test -f Dockerfile.original || cp Dockerfile Dockerfile.original

run-bad:
	docker build -f Dockerfile.original -t $(IMAGE):bad .
	docker run --rm -p 8000:8000 --name $(IMAGE)-bad $(IMAGE):bad

check:
	bash check.sh

clean:
	docker rm -f $(IMAGE)-bad $(IMAGE)-check 2>/dev/null || true
	docker rmi -f $(IMAGE):bad $(IMAGE):check 2>/dev/null || true
	rm -rf dataset .env
