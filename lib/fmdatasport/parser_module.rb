# frozen_string_literal: true

require_relative 'car_info'
require_relative 'track_info'

# Offers methods for unpacking FM Data Out UDP datagrams and hashing the resulting values.
#
# Official Output Structure specs can be found here: https://support.forzamotorsport.net/hc/en-us/articles/21742934024211-Forza-Motorsport-Data-Out-Documentation
#
# **Methods:**
# - **parse_dashdata:** Converts packet segments into readable values.
# - **hash_udp_data:** Uses parse_dashdata to hash readable real-time values to :symbol keys.
# This excludes "static" values that are only set once per race (commented out in method body).
# - **extract_static_values:** Uses parse_dashdata to hash readable static values to descriptive "string" keys.
#   - Relies on convert_class and convert_drive to convert these integer values to readable strings.
#   - Relies on car_lookup to convert the Car Ordinal integer to an array of readable strings from the
#   CAR_LIST hash:
#     - Format: CAR_LIST[ordinal] => [CAR_LIST[:year], CAR_LIST[:make], CAR_LIST[:model]].
module FMDOParser # rubocop:disable Metrics/ModuleLength
  include CarInfo
  include TrackInfo
  # Returns unpacked values from UDP datagrams
  #
  # [data] this must be a 331-byte Forza Motorsport Data Out datagram
  # [offset] starting position of bytes read for the value requested
  # [size] byte length of value requested
  # [format] data type (i.e., integer directive - float, signed-integer, etc.) of value requested
  #
  # Additional info on unpack1: https://ruby-doc.org/3.2.2/packed_data_rdoc.html#label-Integer+Directives
  def parse_dashdata(data, offset, size, format)
    data[offset, size].unpack1(format)
  end

  # Returns hash of converted values with "official" :symbol keys
  # - Some values from the official specification are instead handled by extract_static_values,
  # and are commented out for clarity.
  def hash_udp_stream(data) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    {
      is_race_on: parse_dashdata(data, 0, 4, 'l'),
      timestamp_ms: parse_dashdata(data, 4, 4, 'L'),

      engine_max_rpm: parse_dashdata(data, 8, 4, 'e'),
      # engine_idle_rpm: parse_dashdata(data, 12, 4, 'e'), <-- static value

      current_engine_rpm: parse_dashdata(data, 16, 4, 'e'),

      acceleration_x: parse_dashdata(data, 20, 4, 'e'),
      acceleration_y: parse_dashdata(data, 24, 4, 'e'),
      acceleration_z: parse_dashdata(data, 28, 4, 'e'),

      velocity_x: parse_dashdata(data, 32, 4, 'e'),
      velocity_y: parse_dashdata(data, 36, 4, 'e'),
      velocity_z: parse_dashdata(data, 40, 4, 'e'),

      angular_velocity_x: parse_dashdata(data, 44, 4, 'e'),
      angular_velocity_y: parse_dashdata(data, 48, 4, 'e'),
      angular_velocity_z: parse_dashdata(data, 52, 4, 'e'),

      yaw: parse_dashdata(data, 56, 4, 'e'),
      pitch: parse_dashdata(data, 60, 4, 'e'),
      roll: parse_dashdata(data, 64, 4, 'e'),

      normalized_suspension_travel_front_left: parse_dashdata(data, 68, 4, 'e'),
      normalized_suspension_travel_front_right: parse_dashdata(data, 72, 4, 'e'),
      normalized_suspension_travel_rear_left: parse_dashdata(data, 76, 4, 'e'),
      normalized_suspension_travel_rear_right: parse_dashdata(data, 80, 4, 'e'),

      tire_slip_ratio_front_left: parse_dashdata(data, 84, 4, 'e'),
      tire_slip_ratio_front_right: parse_dashdata(data, 88, 4, 'e'),
      tire_slip_ratio_rear_left: parse_dashdata(data, 92, 4, 'e'),
      tire_slip_ratio_rear_right: parse_dashdata(data, 96, 4, 'e'),

      wheel_rotation_speed_front_left: parse_dashdata(data, 100, 4, 'e'),
      wheel_rotation_speed_front_right: parse_dashdata(data, 104, 4, 'e'),
      wheel_rotation_speed_rear_left: parse_dashdata(data, 108, 4, 'e'),
      wheel_rotation_speed_rear_right: parse_dashdata(data, 112, 4, 'e'),

      wheel_on_rumble_strip_front_left: parse_dashdata(data, 116, 4, 'l'),
      wheel_on_rumble_strip_front_right: parse_dashdata(data, 120, 4, 'l'),
      wheel_on_rumble_strip_rear_left: parse_dashdata(data, 124, 4, 'l'),
      wheel_on_rumble_strip_rear_right: parse_dashdata(data, 128, 4, 'l'),

      wheel_in_puddle_depth_front_left: parse_dashdata(data, 132, 4, 'e'),
      wheel_in_puddle_depth_front_right: parse_dashdata(data, 136, 4, 'e'),
      wheel_in_puddle_depth_rear_left: parse_dashdata(data, 140, 4, 'e'),
      wheel_in_puddle_depth_rear_right: parse_dashdata(data, 144, 4, 'e'),

      surface_rumble_front_left: parse_dashdata(data, 148, 4, 'e'),
      surface_rumble_front_right: parse_dashdata(data, 152, 4, 'e'),
      surface_rumble_rear_left: parse_dashdata(data, 156, 4, 'e'),
      surface_rumble_rear_right: parse_dashdata(data, 160, 4, 'e'),

      tire_slip_angle_front_left: parse_dashdata(data, 164, 4, 'e'),
      tire_slip_angle_front_right: parse_dashdata(data, 168, 4, 'e'),
      tire_slip_angle_rear_left: parse_dashdata(data, 172, 4, 'e'),
      tire_slip_angle_rear_right: parse_dashdata(data, 176, 4, 'e'),

      tire_combined_slip_front_left: parse_dashdata(data, 180, 4, 'e'),
      tire_combined_slip_front_right: parse_dashdata(data, 184, 4, 'e'),
      tire_combined_slip_rear_left: parse_dashdata(data, 188, 4, 'e'),
      tire_combined_slip_rear_right: parse_dashdata(data, 192, 4, 'e'),

      suspension_travel_meters_front_left: parse_dashdata(data, 196, 4, 'e'),
      suspension_travel_meters_front_right: parse_dashdata(data, 200, 4, 'e'),
      suspension_travel_meters_rear_left: parse_dashdata(data, 204, 4, 'e'),
      suspension_travel_meters_rear_right: parse_dashdata(data, 208, 4, 'e'),

      # car_ordinal: parse_dashdata(data, 212, 4, 'l'), <-- static value
      # car_class: parse_dashdata(data, 216, 4, 'l'), <-- static value
      # car_performance_index: parse_dashdata(data, 220, 4, 'l'), <-- static value
      # drivetrain_type: parse_dashdata(data, 224, 4, 'l'), <-- static value
      # num_cylinders: parse_dashdata(data, 228, 4, 'l'), <-- static value

      position_x: parse_dashdata(data, 232, 4, 'e'),
      position_y: parse_dashdata(data, 236, 4, 'e'),
      position_z: parse_dashdata(data, 240, 4, 'e'),
      speed: parse_dashdata(data, 244, 4, 'e'),
      power: parse_dashdata(data, 248, 4, 'e'),
      torque: parse_dashdata(data, 252, 4, 'e'),

      tire_temp_front_left: parse_dashdata(data, 256, 4, 'e'),
      tire_temp_front_right: parse_dashdata(data, 260, 4, 'e'),
      tire_temp_rear_left: parse_dashdata(data, 264, 4, 'e'),
      tire_temp_rear_right: parse_dashdata(data, 268, 4, 'e'),

      boost: parse_dashdata(data, 272, 4, 'e'),
      fuel: parse_dashdata(data, 276, 4, 'e'),
      distance_traveled: parse_dashdata(data, 280, 4, 'e'),
      best_lap: parse_dashdata(data, 284, 4, 'e'),
      last_lap: parse_dashdata(data, 288, 4, 'e'),
      current_lap: parse_dashdata(data, 292, 4, 'e'),
      current_race_time: parse_dashdata(data, 296, 4, 'e'),

      lap_number: parse_dashdata(data, 300, 2, 'S'),
      race_position: parse_dashdata(data, 302, 1, 'C'),
      accel: parse_dashdata(data, 303, 1, 'C'),
      brake: parse_dashdata(data, 304, 1, 'C'),
      clutch: parse_dashdata(data, 305, 1, 'C'),
      hand_brake: parse_dashdata(data, 306, 1, 'C'),
      gear: parse_dashdata(data, 307, 1, 'C'),
      steer: parse_dashdata(data, 308, 1, 'c'),
      normalized_driving_line: parse_dashdata(data, 309, 1, 'c'),
      normalized_aibrake_difference: parse_dashdata(data, 310, 1, 'c'),

      tire_wear_front_left: parse_dashdata(data, 311, 4, 'e'),
      tire_wear_front_right: parse_dashdata(data, 315, 4, 'e'),
      tire_wear_rear_left: parse_dashdata(data, 319, 4, 'e'),
      tire_wear_rear_right: parse_dashdata(data, 323, 4, 'e')

      # track_ordinal: parse_dashdata(data, 327, 4, 'l') <-- static value
    }
  end

  # Returns hash of static values (Car/Track Info) with descriptive "string" keys
  # FMDatasport conditionally updates @static_values when :is_race_on toggles from 1->0->1
  # This allows these values to be refreshed if, and only if, they are modified by starting a new race
  #
  # Relies on CarInfo module to further process Car Ordinal, Car Class, and Drivetrain integers into readable values
  # Relies on TrackInfo module to further process Track Ordinal into readable values
  def extract_static_values(data)
    {
      "Car Ordinal": car_lookup(parse_dashdata(data, 212, 4, 'l')), # converted to retrieved year/make/model info
      "Car Class": convert_class(parse_dashdata(data, 216, 4, 'l')), # converted to readable string (Ex: 'A')
      "Car PI": parse_dashdata(data, 220, 4, 'l'),
      "Drivetrain": convert_drive(parse_dashdata(data, 224, 4, 'l')), # converted to readable string (Ex: 'AWD')
      "Cylinders": parse_dashdata(data, 228, 4, 'l'),
      "Track Ordinal": track_lookup(parse_dashdata(data, 327, 4, 'l')), # converted to retrieved track info
      "Max RPM": parse_dashdata(data, 8, 4, 'e').round(0), # rounded to whole number
      "Idle RPM": parse_dashdata(data, 12, 4, 'e').round(0) # rounded to whole number
    }
  end
end
