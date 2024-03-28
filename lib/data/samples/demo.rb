# frozen_string_literal: true

require 'fmdatasport'
# Define the directory path
directory_path = '.'

# List all files in the directory
files = Dir.entries(directory_path).select { |f| File.file?("#{directory_path}/#{f}") }

# Print the list of files
puts 'Files in the directory:'
files.each_with_index do |file, index|
  puts "#{index + 1}. #{file}"
end

# Prompt the user to choose a file
print 'Enter the number of the file you want to load: '
choice = gets.chomp.to_i

# Validate the user's choice
if choice >= 1 && choice <= files.length
  selected_file = files[choice - 1]
  puts "You selected: #{selected_file}"

  play_file = File.join(Dir.pwd, directory_path, selected_file)

  fmdo_sample = FMDatasport.new('127.0.0.1', 9876)    # Same IP/Port as SamplePlayer
  player = SamplePlayer.new(play_file, '127.0.0.1', 9876)
  player.play                                         # Begin sample playback

  start_time = Time.now                               # Set for loop control
  sleep 0.05                                          # 3/60 sec wait for data

  # Loop for 1 second, output selected telemetry and static values
  loop do
    break if Time.now - start_time > 1                # limit loop to 1 second

    # Wait 3/60th of a second before beginning log (Forza Data Out rate)
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

  # After the playback is complete, log (static) car information once
  car = fmdo_sample.static_data[:"Car Ordinal"] # => [year, make, model]
  puts "\nCar Info"
  car.each do |info|
    puts info
  end

else
  puts "Invalid choice. Please enter a number between 1 and #{files.length}."
end
