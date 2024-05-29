#!/usr/bin/env ruby

require "serialport"
require 'json'

# Path to the vp-7xx.json file from the kramer_vp_control_protocol project.
# The file can be found here: https://github.com/xunker/kramer_vp_control_protocol/blob/main/vp-7xx.json
JSON_COMMAND_FILE = '../kramer_vp_control_protocol/vp-7xx.json'

# Serial device is the path to the serial port to be used. It will be in the format of /dev/tty.xyz
# on Linux/Unix/MacOS systems, or COMn (ex: COM6) on Windows.
SERIAL_DEVICE = "/dev/tty.usbserial-110"

# {
#   "comments" : "VGA-2 is VP-724 Only",
#   "control_type" : {
#       "get" : 4,
#       "set" : 3
#   },
#   "description" : "Select Input Source",
#   "group": null,
#   "function_code" : 0,
#   "response_values" : {
#       "0" : "VGA-1",
#       "1" : "VGA-2",
#       "2" : "DVI",
#       "3" : "Component",
#       "4" : "YC-1",
#       "5" : "AV-1",
#       "6" : "YV-2",
#       "7" : "AV-2",
#       "8" : "Scart",
#       "9" : "TV"
#   },
#   "set_parameters" : [
#       "integer",
#       0,
#       9
#   ]
# }

commands = JSON.parse(File.read(JSON_COMMAND_FILE))

serial = SerialPort.new('/dev/tty.usbserial-110', 9600, 8, 1, SerialPort::NONE) # device, baud, data bits, stop bits, parity
serial.flow_control = SerialPort::NONE
serial.flush_input

response_regex = /\nZ\s+(.+)\r/

action = :get
commands.each do |command|
  print "#{command['group']}:\t" if command['group']
  print "#{command['description']}:\t"

  control_type = command['control_type']
  if action == :get && control_type['get'].nil?
    puts "has no 'get', skipping"
    next
  end

  cmd = "Y #{control_type['get']} #{command['function_code']}"

  serial.write("#{cmd}\n")
  resp = ''
  if action == :get
    until (read_char = serial.getc) == '>' do
      resp << read_char
    end
  elsif action == :set
    until (resp.match(/Done/)) do
      resp << serial.getc
    end
  end

  if resp.match?(response_regex)
    value = resp.match(response_regex)[1].strip.split(/\s+/)[2..-1].join(' ')

    if command['response_values']
      puts "#{value}\t#{command['response_values'][value]}"
    else
      puts value.inspect
    end
  else
    puts "Couldn't parse: #{resp.inspect}"
  end

  sleep(0.1)
end