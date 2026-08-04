# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "academic-org-theme"
  spec.version       = "0.1.0"
  spec.authors       = ["Charles Martin"]
  spec.email         = ["cpm@charlesmartin.au"]

  spec.summary       = "A simple and clear Jekyll theme for academic conferences, associations and organisations."
  spec.homepage      = "https://github.com/smcclab/academic-org-theme"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r!^(assets|_data|_layouts|_includes|_sass|LICENSE|README|_config\.yml)!i) }

  spec.add_runtime_dependency "jekyll", "~> 4.3"
  spec.add_runtime_dependency "jekyll-fontawesome-svg", "~> 0.4.0"
  spec.add_runtime_dependency "jekyll-toc", "~> 0.19.0"
  spec.add_runtime_dependency "jekyll-datapage-generator", "~> 1.4"
  spec.add_runtime_dependency "jekyll-seo-tag", "~> 2.8"
  spec.add_runtime_dependency "jekyll-redirect-from", "~> 0.16"
end
