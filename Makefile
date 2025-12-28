IMAGE_NAME := my-envoy-wasm
IMAGE_TAG  := latest
KIND_CLUSTER := wasm-test
WASM_PATH := target/wasm32-wasip1/release/envoy_auth_filter.wasm

.PHONY: all build image load deploy restart clean test

all: build image load restart

build:
	cargo build --target wasm32-wasip1 --release

image:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f envoy/Dockerfile .

load:
	kind load docker-image $(IMAGE_NAME):$(IMAGE_TAG) --name $(KIND_CLUSTER)

deploy:
	kubectl apply -f k8s/base/backend-nginx.yaml
	kubectl apply -f k8s/base/envoy-deploy.yaml
	kubectl apply -f k8s/debug/curl-pod.yaml

restart:
	kubectl delete pod envoy-wasm --ignore-not-found
	kubectl apply -f k8s/base/envoy-deploy.yaml

test:
	@echo "--- Testing Unauthorized (Should be 401) ---"
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s -i http://envoy-service/
	@echo "\n--- Testing Authorized (Should be 200) ---"
	kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s -i -H "Authorization: OpenSesame" http://envoy-service/

clean:
	cargo clean
	kubectl delete -f k8s/base/ --ignore-not-found
	kubectl delete -f k8s/debug/ --ignore-not-found
