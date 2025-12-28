FROM envoyproxy/envoy:v1.31-latest

COPY envoy/envoy.yaml /etc/envoy/envoy.yaml
COPY target/wasm32-wasip1/release/envoy_auth_filter.wasm /etc/envoy/auth_filter.wasm

CMD ["/usr/local/bin/envoy", "-c", "/etc/envoy/envoy.yaml"]
