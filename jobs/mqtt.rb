require 'mqtt'
require 'json'
# Set your MQTT server

ENV['MQTT_SERVER'] = 'mqtt://127.0.0.1' unless ENV.has_key?('MQTT_SERVER')

MQTT_SERVER = ENV['MQTT_SERVER']

# Set the MQTT topics you're interested in and the tag (data-id) to send for dashing events
MQTT_TOPICS = {
	'tinkerforge/bricklet/humidity_v2/Dhv/humidity' => 'humidity',
  'tinkerforge/bricklet/humidity_v2/Dhv/temperature' => 'temperature',
  'tinkerforge/brick/master/6QkmMq/chip_temperature' => 'temperature_sensor',
  'tinkerforge/bricklet/ambient_light_v2/yLs/illuminance' => 'illuminance',
  'tinkerforge/bricklet/ptc_v2/GqF/temperature' => 'ptc_temperature',
  #'tinkerforge/brick/master/6QkmMq/usb_voltage' => 'voltage',
              }

# Start a new thread for the MQTT client
Thread.new {
  MQTT::Client.connect(MQTT_SERVER) do |client|
    client.subscribe( MQTT_TOPICS.keys )

    # Sets the default values to 0 - used when updating 'last_values'
    current_values = Hash.new(0)

    client.get do |topic,message|
      tag = MQTT_TOPICS[topic]
      last_value = current_values[tag]

      m_val = JSON.parse(message)
      if m_val.has_key?("humidity")
        val = m_val["humidity"]
      end
      if m_val.has_key?("temperature")
        val = m_val["temperature"]
      end
      if m_val.has_key?("voltage")
        puts "stack_voltage"
        val = m_val["voltage"]
      end
      if m_val.has_key?("illuminance")
        val = m_val["illuminance"]
      end

      #puts val.to_s
      val = val / 100.0

      current_values[tag] = val
      send_event(tag, { value: val, current: val, last: last_value })
    end
  end
}
