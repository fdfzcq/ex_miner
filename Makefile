docker-image:
	docker build -t ex_miner .

run-docker:
	$(MAKE) docker-image
	docker run -p 8990:8990 ex_miner:latest
