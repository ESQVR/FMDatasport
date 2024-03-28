# frozen_string_literal: true

require 'json'

# CarInfo
#
# CarInfo offers methods to convert static integer values from FMDOParser into readable strings.
#
# Upon loading, the CarInfo module reads data from car_list.json into the symbolized hash constant CAR_LIST.
# Year, make, and model string values are retrievable by passing Car Ordinal keys to the car_lookup method which uses
# the CAR_LIST to identify the currently selected car.
#
# Additional methods for converting static values from FMDOParser (car class and drivetrain type) into readable strings.
module CarInfo
  # Constant for storing hashed year, make, model info using Car Ordinal keys.
  #
  # "2740":{"year":2017,"make":"Abarth","model":"124 Spider"},
  CAR_LIST = {} # rubocop:disable Style/MutableConstant

  # Load (and merge) from car_list.json external file into CAR_LIST.
  def self.load_and_merge_list(file_path)
    # Load external list from JSON file (symbolized)
    #   - symbolizes names for use by car_lookup
    external_list = JSON.parse(File.read(file_path), symbolize_names: true)

    # Merge external list with CAR_LIST constant
    # Return the merged list
    CAR_LIST.merge!(external_list)
  end

  # Ensures external list file is loaded when modulue is first loaded
  # load_and_merge_list('lib/data/car_list.json')
  load_and_merge_list(File.join(Gem.loaded_specs['fmdatasport'].full_gem_path, 'lib', 'data', 'car_list.json'))

  ##
  # Retrieves car details from CAR_LIST by Ordinal.
  #
  # @param ordinal [Integer] The ID of the car to look up.
  #
  # @return [Array<String>] An array containing the car's year, make, and model.
  #
  # @example
  #   car_lookup(2740) # => ["2017", "Abarth", "124 Spider"]
  def car_lookup(ordinal)
    return nil if ordinal.nil?

    # Retrieves current car info by ordinal from CAR_LIST hash
    # Arguments passed by extract_static_data calls are symbolized
    car_info = CAR_LIST[ordinal.to_s.to_sym]
    return "Car Ordinal #{ordinal} is not in data file. Please Update" if car_info.nil?

    [car_info[:year], car_info[:make], car_info[:model]]
  end

  # Converts :car_class integer into readable class letters for display
  #
  # convert_class(3)  => 'B'
  def convert_class(num)
    conversion = { 0 => 'E', 1 => 'D', 2 => 'C', 3 => 'B', 4 => 'A', 5 => 'S', 6 => 'R', 7 => 'P', 8 => 'X' }
    conversion.keys.include?(num) ? conversion[num] : 'Error: Invalid Class ID Number'
  end

  # Converts drivetrain-type integers into readable drivetrain labels for display
  def convert_drive(num)
    conversion = { 0 => 'FWD', 1 => 'RWD', 2 => 'AWD' }
    conversion.keys.include?(num) ? conversion[num] : 'Error: Invalid drive type'
  end

  # TODO: ADD method for calling file writing class to modify external file (add or modify car list)
end
