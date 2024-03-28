# frozen_string_literal: true

require 'socket'

# SamplePlayer reads telemetry stream data from an external file (use SampleRecorder to create a new file)
# and broadcasts that datastream to a specified IP/Port - allowing you to replay saved race data or test code using
# sample data instead of live UDP stream from an active Forza Motorsport race.
#
# Instantiating a new FMDatasport object to listen on the same IP/Port as the SamplePlayer brodcast provides access to
# parsed, processed data
class SamplePlayer
  # This reader enables the use of Thread#join method to ensure file playback Thread stays alive
  # when SamplePlayer is instantiated by the fmdoplayer command-line tool
  #
  # static_data = {"symbolized string": integer, ...}
  attr_reader :play_thread

  # [file_path] relative path to recorded UDP stream file
  # [destination_ip] IP to send UDP stream
  # [destination_port] Port to send UDP stream
  # [loop_count] Number of times to loop through the file (default is 1)
  # Default values for IP/Port are (localhost) 127.0.0.1:9876
  #
  # If you want to parse and process the stream, use the same IP/Port specified here when calling FMDatasport.new
  def initialize(file_path, destination_ip = '127.0.0.1', destination_port = '9876', loop_count = 1)
    @file_path = file_path
    @destination_ip = destination_ip
    @destination_port = destination_port
    @loop_count = loop_count
  end

  # Spawns a new Thread to simulate FM Data Out UDP data stream
  # - Reads 331 bytes at a time from recorded binary file and sends to destination IP/Port at 60packets/sec
  # - Closes socket when file read is complete
  def play # rubocop:disable Metrics
    puts 'Setting up playback'
    @play_thread = Thread.new do
      @loop_count.times do
        puts 'Starting file read'
        File.open(@file_path, 'rb') do |file| # Open the file in binary mode
          sc = UDPSocket.new
          while (data = file.read(331)) # Read 331 bytes at a time
            sc.send(data, 0, @destination_ip, @destination_port)
            sleep 0.01667 # 1/60 second sleep = 60hz update
          end
          sc.close
          puts 'finished sending data'
        end
      end
    end
  end
end
