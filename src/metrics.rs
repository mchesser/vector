use futures::Future;
use metrics_runtime::{
    exporters::HttpExporter, observers::PrometheusBuilder, Controller, Receiver, Sink
};
use std::net::SocketAddr;

/// Build the metrics receiver, controller and sink
pub fn build() -> (Controller, Sink) {
    let receiver = Receiver::builder().build().unwrap();
    let controller = receiver.get_controller();
    let sink = receiver.get_sink();

    receiver.install();

    (controller, sink)
}

/// Serve the metrics server via the address from the metrics controller
pub fn serve(addr: &SocketAddr, controller: Controller) -> impl Future<Item = (), Error = ()> {
    HttpExporter::new(controller, PrometheusBuilder::new(), *addr)
        .into_future()
}
