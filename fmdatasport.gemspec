# frozen_string_literal: true

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.7'
  s.name        = 'fmdatasport'
  s.version     = '0.1.1'
  s.date        = '2024-03-27'
  s.summary     = 'Receives, parses, and processes Forza Motorsport Data Out Telemetry'
  s.authors     = ['ESQVR']
  s.files       = [
    'lib/fmdatasport.rb',
    'lib/fmdatasport/car_info.rb',
    'lib/fmdatasport/parser_module.rb',
    'lib/fmdatasport/sample_player.rb',
    'lib/fmdatasport/sample_recorder.rb',
    'lib/fmdatasport/track_info.rb',
    'lib/fmdatasport/version.rb',
    'lib/data/car_list.json',
    'lib/data/track_info.json'
  ]
  s.license = 'MIT'
  s.post_install_message = 'No matter how strong the pain is, its our duty to move forward.'
  s.require_paths = ['lib']
  s.description = <<~DESC
    FMDatasport is a Ruby gem designed to listen for and parse data from a Forza Motorsport Data Out (FMDO) UDP stream.
    It provides real-time access to telemetry as well as car and track information, facilitating the development of
    Ruby applications for Forza Motorsport. This gem also includes two command-line tools for recording and playback of
    FMDO datastreams. FMDatasport currently supports only Forza Motorsport (2023 - AKA FM8).
  DESC
  s.bindir = 'bin'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.executables = ['fmdoplayer', 'fmdorecorder']
  s.homepage = 'https://esqvr.github.io/FMDatasport/'
end
