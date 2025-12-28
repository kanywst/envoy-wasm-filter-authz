use proxy_wasm::traits::*;
use proxy_wasm::types::*;

proxy_wasm::main! {{
    proxy_wasm::set_log_level(LogLevel::Trace);
    proxy_wasm::set_root_context(|_| -> Box<dyn RootContext> {
        Box::new(AuthRootContext)
    });
}}

struct AuthRootContext;

impl Context for AuthRootContext {}

impl RootContext for AuthRootContext {
    fn create_http_context(&self, _context_id: u32) -> Option<Box<dyn HttpContext>> {
        Some(Box::new(AuthFilter))
    }

    fn get_type(&self) -> Option<ContextType> {
        Some(ContextType::HttpContext)
    }
}

struct AuthFilter;

impl Context for AuthFilter {}

impl HttpContext for AuthFilter {
    fn on_http_request_headers(&mut self, _: usize, _: bool) -> Action {
        match self.get_http_request_header("Authorization") {
            Some(token) if token == "OpenSesame" => Action::Continue,
            _ => {
                self.send_http_response(
                    401,
                    vec![("Content-Type", "text/plain")],
                    Some(b"Unauthorized: Invalid or missing token.\n"),
                );
                Action::Pause
            }
        }
    }
}
