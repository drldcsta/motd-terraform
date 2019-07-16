provider "fastly" {
  api_key = var.api_key
}

resource "fastly_service_v1" "demo" {
  name = var.service_name

  domain {
    name    = var.domain
    comment = "This demo configured automagically"
  }

  domain {
    name = var.bypass_domain
    comment = "This demo configured automatically"
  }

  backend {
    address = var.backend
    name    = "This backend configured automaigcally"
    port    = 80
    healthcheck = "keep alive"
    shield = "iad-va-us"
    error_threshold = 5
    auto_loadbalance = false
  }

  healthcheck {
    name = "keep alive"
    host = var.backend
    path = "/healthcheck/check"
    check_interval = 285000
    threshold = 1 
  }

  request_setting {
    #TODO - figure out how to enable HSTS
    name = var.domain
    force_ssl = true
  }

  snippet {
    name = "Call set host header on miss"
    type = "miss"
    content = "${file("${path.module}/call_set_host_header.snippet")}"
  }

   snippet {
    name = "Call set host header on pass"
    type = "pass"
    content = "${file("${path.module}/call_set_host_header.snippet")}"
  }

   snippet {
    name = "miss_or_pass"
    type = "init"
    content = "sub miss_or_pass {\n  if (req.backend.is_origin) {\n    set bereq.http.host = \"${var.backend}\";\n  }\n}"
    #TODO - figure out how to interpolate the ${var.backend} into the file so I don't have to put this inline
    # content = "${file("${path.module}/miss_or_pass.snippet")}"
  }

   snippet {
    name = "device detect"
    type = "init"
    content = "${file("${path.module}/device_detect.snippet")}"
  }

   snippet {
    #TODO - move snippets specific to demos into separate file (maybe)?
    name = "pass not root"
    type = "recv"
    content = "${file("${path.module}/pass_not_root.snippet")}"
  }

   snippet {
    name = "set decorator headers"
    type = "recv"
    content = "${file("${path.module}/set_decorator_headers.snippet")}"
  }

   snippet {
    name = "user agent normalizer"
    type = "recv"
    content = "${file("${path.module}/uap.snippet")}"
  }

  snippet {
    name = "simulate origin"
    type = "recv"
    content = "${file("${path.module}/simulate_origin.snippet")}"
  }

  force_destroy = true
}
