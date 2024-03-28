# frozen_string_literal: true

require 'socket'
require_relative 'fmdatasport/parser_module'
require_relative 'fmdatasport/version'
require_relative 'fmdatasport/sample_player'
require_relative 'fmdatasport/sample_recorder'

# Instantiating an FMDatasport object initializes a UDP socket listener in a separate thread which waits(blocks)
# until data is available to read.
#
# The hash_udp_stream and extract_static_values methods from the included FMDOParser module unpack the binary stream
# into readable values, returning hashes of realtime and static data. Both are read-only attributes
class FMDatasport
  include FMDOParser
  # Parsed per-race static data is availble here - updated once when a new race begins.
  #
  # static_data = {"symbolized string": integer, ...}
  attr_reader :static_data
  # Parsed realtime telemetry data is available here -  updated 60 times/sec.
  #
  # udp_data = {symbol: integer, ...}
  attr_reader :udp_data

  # When calling FMDatasport.new provide the same IP/Port as specified in your Forza Motorsport's Data Out settings
  # (found at the bottom of the Gameplay/HUD tab in the Forza Settings menu)
  #
  # This is the IP/Port that the datasport object will *listen* on.
  #
  # If you are using the SamplePlayer, provide the same IP/Port arguments given to SamplePlayer.new
  def initialize(ip_addr, port)
    @collector = spawn_udp_receive_thread # @collector not used, assigned for thread mgmt & protect from garbage collect
    @my_ip = ip_addr
    @my_port = port
    @static_data = {}
    @udp_data = {}
  end

  private

  # Spawn a new Thread that instantiates a UDPSocket, binds it to the IP and port specified when initialized
  # - Static Data (Car ID, PI, Drivetrain / Track Info) is extracted and parsed once into @static_data
  # - Thread continues to update @udp_data with every 331 bytes received from FM Data Out stream
  # - Checks to see if race is on, and toggles static_data_sent when race is false, to induce refresh.
  def spawn_udp_receive_thread # rubocop:disable Metrics/MethodLength
    Thread.new do
      udp = UDPSocket.new
      udp.bind(@my_ip, @my_port)

      static_data_sent = false
      loop do
        IO.select([udp]) # blocks thread until udp is ready to be read
        data, _addr = udp.recvfrom(331)
        @udp_data = hash_udp_stream(data)
        static_data_sent = false if (@udp_data[:is_race_on]).zero? && static_data_sent == true
        next unless static_data_sent == false && @udp_data[:is_race_on] == 1

        @static_data = extract_static_values(data)
        static_data_sent = true
      end
    end
  end
end
