# frozen_string_literal: true

require 'fmdatasport'
require 'sample_player'

player = SamplePlayer.new('lib/data/samples/sample_data', '127.0.0.1', 9876)
fmdo_sample = FMDatasport.new('127.0.0.1', 9876)    # Same IP/Port as SamplePlayer

player.play                                         # Begin sample playback
start_time = Time.now                               # Set for loop control

# Loop for 1 second, output selected telemetry and static values
loop do
  break if Time.now - start_time > 1                # limit loop to 1 second

  # Wait 1/60th of a second before beginning log (Forza Data Out rate)
  sleep 0.01667

  # Set variables to desired fields from @udp_data
  rpm = fmdo_sample.udp_data[:current_engine_rpm].round(0)
  gear = fmdo_sample.udp_data[:gear]
  speed = fmdo_sample.udp_data[:speed]

  # Print values to console
  puts "RPM: #{rpm}"
  puts "Gear: #{gear}"
  puts "Speed (unconverted): #{speed}"
end

# After the playback data has been logged, log the (static) car information once for reference
car = fmdo_sample.static_data[:"Car Ordinal"] # Access Car Ordinal info [year, make, model]
puts "\nCar Info"
car.each do |info|
  puts info
end
