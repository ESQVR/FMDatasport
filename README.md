# FMDatasport

FMDatasport is a Ruby gem for receiving and parsing data from the Forza Motorsport Data Out (FMDO) UDP stream.
It provides real-time access to telemetry as well as car and track information, facilitating the development of Ruby
applications for Forza Motorsport. FMDatasport currently supports only Forza Motorsport 2023 (AKA FM8).

Official Forza Motorsport Data Out specs can be found here:
https://support.forzamotorsport.net/hc/en-us/articles/21742934024211-Forza-Motorsport-Data-Out-Documentation

This gem also contains fmdoplayer and fmdorecorder; standalone executables for recording and simulating playback of FMDO
streams. The resulting files can be used for application testing without the need for a live stream.

Saved sessions can also be used with the forthcoming `FMDatasportR` analysis engine. Details on this project can be
found here: https://github.com/ESQVR/ForzaDatasport-Ruby

For detailed information on using this gem please review the [RDocs Documentation](doc/index.html)

# Installation
To install FMDatasport use:

  ```
  gem install fmdatasport
  ```

# Command Line Tools

## 1. Record telemetry data with standalone fmdorecorder
In addition to the SampleRecorder class, the `fmdorecorder` command-line application can be used to record FMDO streams
to a local file for playback.

`fmdorecorder` generates files containing the raw binary received from FMDO. These files are saved to the `/sessions`
directory with a timestamp (YYYY/DD/MM/H/M) appended to their name.

### Usage

```
fmdorecorder [options]
```

### Options / Defaults

- `-p, --port PORT`: Specify the port number to which the sample data will be broadcasting

If not provided, the default port number `9876` will be used.
(This port is commonly available, but you can specify any open port)

- `-f, --file FILE`: Specify the name of the recorded data file

If not provided, the default name `recorded_stream[time_stamp]` will be used

- `-l, --length LENGTH`: Specify the length of the recording, in seconds

If not provided, the default recording length is 60 seconds

### Example

```
fmdorecorder -p 1234 -f output.txt -l 30
```
This example command:
- records sample data
- saves it to the file `/sessions/output.txt`
- for 30 seconds total

## 2. Playback saved telemetry data with fmdoplayer
The `fmdoplayer` command-line tool allows playback / broadcasting of saved telemetry session files.

Instantiating a new FMDatasport object that listens on the same IP/Port as the `fmdoplayer` broadcast will simulate
receiving a live FM Data Out stream - allowing for application testing or data analysis with other tools.

The `fmdoplayer` is also able to loop the stream from a file a specified number of times if specified in [options].
### Usage

```
fmdoplayer [options]
```

### Options / Defaults

- `-f, --file [FILENAME]`: Specify the name of the recorded data file.

If not provided the default name `recorded_stream` will be used.

- `-i, --ip [IP_ADDR]`: Specifiy the IP address to which the sample data will be broadcasting.

If not provided, the default IP address `127.0.0.1` will be used.
(The localhost IP is the best choice in most situations)

- `-p, --port [PORT]`: Specify the port number to which the sample data will be broadcasting.

If not provided, the default port number `9876` will be used.
(This port is commonly available, but you can specify any open port)

- `-l, --loop [LOOPS]`: Specify the number of times the sample data will be looped for broadcasting

If not provided, the default loop count is `1`.

### Example

```
fmdoplayer -f output.txt -i 192.168.1.100 -p 1234 -l 3
```

1. reads from the file output.txt,
2. broadcasts the stream to the IP address 192.168.1.100
3. on port 1234
4. loops the data broadcasting three times



# Demo Implementation using SamplePlayer

See example below for a simple implementation that will output to console 1 second of selected data
from a recorded sample file: `lib/data/samples/sample_data`

### [Demo Script (click here)](lib/data/samples/demo.rb)

```ruby
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

# After the playback is complete, log (static) car information once
car = fmdo_sample.static_data[:"Car Ordinal"] # => [year, make, model]
puts "\nCar Info"
car.each do |info|
  puts info
end
```
