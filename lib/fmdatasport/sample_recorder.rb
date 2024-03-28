# frozen_string_literal: true

require 'socket'
require 'optparse'

##
# SampleRecorder records the Forza Data Out UDP stream data to a file.
# It listens on a specified port, records data for a given length of time,
# and saves the data to a specified file path.
#
# SampleRecorder also works as a stand-alone command-line tool.
class SampleRecorder
  ##
  # Creates a new SampleRecorder instance.
  #
  # @param listen_port [Integer] The port to listen on for UDP data.
  #
  # @param file_name [String] The name the file where the recorded data will be saved.
  #
  # @param recording_length [Integer] The length of time (in seconds) to record data.
  def initialize(listen_port, file_path, recording_length)
    @listen_port = listen_port
    @base_file_path = file_path
    @recording_length = recording_length
  end

  ##
  # Starts the recording process.
  #
  # This method binds to the specified port, listens for incoming UDP data,
  # and writes the received data to the specified file for the duration of the recording length.
  # Recorded files are saved to ../sessions/file_name_[timestamp]
  # @return [void]
  def start # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    ss = UDPSocket.new
    ss.bind('0.0.0.0', @listen_port) # Listen on all interfaces

    start_time = Time.now
    timestamp = Time.now.strftime("%Y%m%d%H%M") # Get timestamp in YYYYMMDDHHMM format

    directory = File.join(Dir.pwd, 'sessions') # Directory to prepend to the base file path

    Dir.mkdir(directory) unless File.exist?(directory)

    file_path = File.join(directory, "#{@base_file_path}_#{timestamp}") # Prepend directory to base file path

    File.open(file_path, 'wb') do |file|
      puts "Recording to #{file_path}"
      loop do
        break if Time.now - start_time > @recording_length

        data, _addr = ss.recvfrom(331) # Receive data
        file.write(data) # Write data to file
      end
    end

    ss.close
    puts 'Recording complete'
  end
end
