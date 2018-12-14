require 'mqtt'
require 'json'
# Set your MQTT server
MQTT_SERVER = 'mqtt://10.0.10.163'
# Set the MQTT topics you're interested in and the tag (data-id) to send for dashing events
MQTT_TOPICS = {
	'tinkerforge/bricklet/humidity_v2/Dhv/humidity' => 'humidity',
  'tinkerforge/bricklet/humidity_v2/Dhv/temperature' => 'temperature',
  'tinkerforge/brick/master/6QkmMq/chip_temperature' => 'temperature_sensor',
  'tinkerforge/bricklet/ambient_light_v2/yLs/illuminance' => 'illuminance',
  'tinkerforge/brick/master/6QkmMq/stack_voltage' => 'voltage',
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

      puts val.to_s
      val = val / 100.0

      current_values[tag] = val
      send_event(tag, { value: val, current: val, last: last_value })
    end
  end
}
