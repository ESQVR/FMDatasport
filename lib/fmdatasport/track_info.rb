# frozen_string_literal: true

require 'json'

# Module: TrackInfo
#
# TrackInfo reads track information data from an external file and makes this available to FMDatasport
#
module TrackInfo # rubocop:disable Metrics/ModuleLength
  TRACK_LIST = {} # rubocop:disable Style/MutableConstant

  def self.load_and_merge_tracks(file_path)
    external_list = JSON.parse(File.read(file_path), symbolize_names: true)
    TRACK_LIST.merge!(external_list)
  end

  load_and_merge_tracks(File.join(Gem.loaded_specs['fmdatasport'].full_gem_path, 'lib', 'data', 'track_info.json'))

  def track_lookup(ordinal) # rubocop:disable Metrics/MethodLength
    return nil if ordinal.nil?

    # Retrieves current track info by ordinal from TRACK_LIST hash
    # Arguments passed by FMDOParser::extract_static_data calls are integers and must be symbolized
    track_info = TRACK_LIST[ordinal.to_s.to_sym]
    return "Track Ordinal #{ordinal} is not in data file. Please Update" if track_info.nil?

    # Current list of IOC codes - source: https://en.wikipedia.org/wiki/List_of_IOC_country_codes
    ioc_hash = {
      'afg' => 'Afghanistan',
      'alb' => 'Albania',
      'alg' => 'Algeria',
      'and' => 'Andorra',
      'ang' => 'Angola',
      'ant' => 'Antigua and Barbuda',
      'arg' => 'Argentina',
      'arm' => 'Armenia',
      'aru' => 'Aruba',
      'asa' => 'American Samoa',
      'aus' => 'Australia',
      'aut' => 'Austria',
      'aze' => 'Azerbaijan',
      'bah' => 'Bahamas',
      'ban' => 'Bangladesh',
      'bar' => 'Barbados',
      'bdi' => 'Burundi',
      'bel' => 'Belgium',
      'ben' => 'Benin',
      'ber' => 'Bermuda',
      'bhu' => 'Bhutan',
      'bih' => 'Bosnia and Herzegovina',
      'biz' => 'Belize',
      'blr' => 'Belarus',
      'bol' => 'Bolivia',
      'bot' => 'Botswana',
      'bra' => 'Brazil',
      'brn' => 'Bahrain',
      'bru' => 'Brunei',
      'bul' => 'Bulgaria',
      'bur' => 'Burkina Faso',
      'caf' => 'Central African Republic',
      'cam' => 'Cambodia',
      'can' => 'Canada',
      'cay' => 'Cayman Islands',
      'cgo' => 'Republic of the Congo',
      'cha' => 'Chad',
      'chi' => 'Chile',
      'chn' => 'China',
      'civ' => 'Ivory Coast',
      'cmr' => 'Cameroon',
      'cod' => 'Democratic Republic of the Congo',
      'cok' => 'Cook Islands',
      'col' => 'Colombia',
      'com' => 'Comoros',
      'cpv' => 'Cape Verde',
      'crc' => 'Costa Rica',
      'cro' => 'Croatia',
      'cub' => 'Cuba',
      'cyp' => 'Cyprus',
      'cze' => 'Czechia',
      'den' => 'Denmark',
      'dji' => 'Djibouti',
      'dma' => 'Dominica',
      'dom' => 'Dominican Republic',
      'ecu' => 'Ecuador',
      'egy' => 'Egypt',
      'eri' => 'Eritrea',
      'esa' => 'El Salvador',
      'esp' => 'Spain',
      'est' => 'Estonia',
      'eth' => 'Ethiopia',
      'fij' => 'Fiji',
      'fin' => 'Finland',
      'fra' => 'France',
      'fsm' => 'Federated States of Micronesia',
      'gab' => 'Gabon',
      'gam' => 'The Gambia',
      'gbr' => 'Great Britain',
      'gbs' => 'Guinea-Bissau',
      'geo' => 'Georgia',
      'geq' => 'Equatorial Guinea',
      'ger' => 'Germany',
      'gha' => 'Ghana',
      'gre' => 'Greece',
      'grn' => 'Grenada',
      'gua' => 'Guatemala',
      'gui' => 'Guinea',
      'gum' => 'Guam',
      'guy' => 'Guyana',
      'hai' => 'Haiti',
      'hkg' => 'Hong Kong, China',
      'hon' => 'Honduras',
      'hun' => 'Hungary',
      'ina' => 'Indonesia',
      'ind' => 'India',
      'iri' => 'Iran',
      'irl' => 'Ireland',
      'irq' => 'Iraq',
      'isl' => 'Iceland',
      'isr' => 'Israel',
      'isv' => 'Virgin Islands',
      'ita' => 'Italy',
      'ivb' => 'British Virgin Islands',
      'jam' => 'Jamaica',
      'jor' => 'Jordan',
      'jpn' => 'Japan',
      'kaz' => 'Kazakhstan',
      'ken' => 'Kenya',
      'kgz' => 'Kyrgyzstan',
      'kir' => 'Kiribati',
      'kor' => 'South Korea',
      'kos' => 'Kosovo',
      'ksa' => 'Saudi Arabia',
      'kuw' => 'Kuwait',
      'lao' => 'Laos',
      'lat' => 'Latvia',
      'lba' => 'Libya',
      'lbn' => 'Lebanon',
      'lbr' => 'Liberia',
      'lca' => 'Saint Lucia',
      'les' => 'Lesotho',
      'lie' => 'Liechtenstein',
      'ltu' => 'Lithuania',
      'lux' => 'Luxembourg',
      'mad' => 'Madagascar',
      'mar' => 'Morocco',
      'mas' => 'Malaysia',
      'maw' => 'Malawi',
      'mda' => 'Moldova',
      'mdv' => 'Maldives',
      'mex' => 'Mexico',
      'mgl' => 'Mongolia',
      'mhl' => 'Marshall Islands',
      'mkd' => 'North Macedonia',
      'mli' => 'Mali',
      'mlt' => 'Malta',
      'mne' => 'Montenegro',
      'mon' => 'Monaco',
      'moz' => 'Mozambique',
      'mri' => 'Mauritius',
      'mtn' => 'Mauritania',
      'mya' => 'Myanmar',
      'nam' => 'Namibia',
      'nca' => 'Nicaragua',
      'ned' => 'Netherlands',
      'nep' => 'Nepal',
      'ngr' => 'Nigeria',
      'nig' => 'Niger',
      'nor' => 'Norway',
      'nru' => 'Nauru',
      'nzl' => 'New Zealand',
      'oma' => 'Oman',
      'pak' => 'Pakistan',
      'pan' => 'Panama',
      'par' => 'Paraguay',
      'per' => 'Peru',
      'phi' => 'Philippines',
      'ple' => 'Palestine',
      'plw' => 'Palau',
      'png' => 'Papua New Guinea',
      'pol' => 'Poland',
      'por' => 'Portugal',
      'prk' => 'North Korea',
      'pur' => 'Puerto Rico',
      'qat' => 'Qatar',
      'rou' => 'Romania',
      'rsa' => 'South Africa',
      'rus' => 'Russia',
      'rwa' => 'Rwanda',
      'sam' => 'Samoa',
      'sen' => 'Senegal',
      'sey' => 'Seychelles',
      'sgp' => 'Singapore',
      'skn' => 'Saint Kitts and Nevis',
      'sle' => 'Sierra Leone',
      'slo' => 'Slovenia',
      'smr' => 'San Marino',
      'sol' => 'Solomon Islands',
      'som' => 'Somalia',
      'srb' => 'Serbia',
      'sri' => 'Sri Lanka',
      'ssd' => 'South Sudan',
      'stp' => 'São Tomé and Príncipe',
      'sud' => 'Sudan',
      'sui' => 'Switzerland',
      'sur' => 'Suriname',
      'svk' => 'Slovakia',
      'swe' => 'Sweden',
      'swz' => 'Eswatini',
      'syr' => 'Syria',
      'tan' => 'Tanzania',
      'tga' => 'Tonga',
      'tha' => 'Thailand',
      'tjk' => 'Tajikistan',
      'tkm' => 'Turkmenistan',
      'tls' => 'East Timor',
      'tog' => 'Togo',
      'tpe' => 'Chinese Taipei',
      'tto' => 'Trinidad and Tobago',
      'tun' => 'Tunisia',
      'tur' => 'Turkey',
      'tuv' => 'Tuvalu',
      'uae' => 'United Arab Emirates',
      'uga' => 'Uganda',
      'ukr' => 'Ukraine',
      'uru' => 'Uruguay',
      'usa' => 'United States',
      'uzb' => 'Uzbekistan',
      'van' => 'Vanuatu',
      'ven' => 'Venezuela',
      'vie' => 'Vietnam',
      'vin' => 'Saint Vincent and the Grenadines',
      'yem' => 'Yemen',
      'zam' => 'Zambia',
      'zim' => 'Zimbabwe'
    }

    [track_info[:circuit], track_info[:location], ioc_hash[track_info[:ioc_code]], track_info[:track],
     "#{track_info[:length_in_km]} km"]
  end
end
