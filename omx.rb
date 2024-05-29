#!/usr/bin/env ruby

# This is for the "New" protocol for devices with firmware > KB2.33
# https://cdn.kramerav.com/web/downloads/protocols/vp-719xl_720xl_vp-724xl_protocol.pdf
# Guide to the "old" protocol is here: https://k.kramerav.com/downloads/protocols/vp-723xl.pdf)

require "serialport"



CONTROL_TYPES = {
  zero: { set: 0, get: nil },
  set_a: { set: 1, get: 2 },
  set_b: { set: 3, get: 4 },
  five: { set: 5, get: nil },
  set_c: { set: 6, get: 7 },
  eight: { set: nil, get: 8 }
}

COMMANDS = [
  [:zero, 0, :none, 'Output'],
  [:zero, 1, :none, 'Freeze'],
  [:zero, 2, :none, 'Power'],
  [:zero, 3, :none, 'AV1'],
  [:zero, 4, :none, 'AV2'],
  [:zero, 5, :none, 'Comp'],
  [:zero, 6, :none, 'YC1'],
  [:zero, 7, :none, 'YC2'],
  [:zero, 8, :none, 'VGA1'],
  [:zero, 9, :none, 'VGA2 VP724 DS/XL Only'],
  [:zero, 10, :none, 'DVI'],
  [:zero, 11, :none, 'Information'],
  [:zero, 12, :none, 'Area Left Up'],
  [:zero, 13, :none, 'Area Middle Up'],
  [:zero, 14, :none, 'Area Right Up'],
  [:zero, 15, :none, 'Area Left Center'],
  [:zero, 16, :none, 'Area Middle Center'],
  [:zero, 17, :none, 'Area Right Center'],
  [:zero, 18, :none, 'Area Left Down'],
  [:zero, 19, :none, 'Area Middle Down'],
  [:zero, 20, :none, 'Area Right Dow'],
  [:zero, 21, :none, 'Auto Image'],
  [:zero, 22, :none, 'Menu'],
  [:zero, 23, :none, 'Up'],
  [:zero, 24, :none, 'Left'],
  [:zero, 25, :none, 'Enter'],
  [:zero, 26, :none, 'Right'],
  [:zero, 27, :none, 'Down'],
  [:zero, 28, :none, 'Auto Gain'],
  [:zero, 29, :none, 'PIP'],
  [:zero, 30, :none, 'Swap'],
  [:zero, 31, :none, 'Contrast'],
  [:zero, 32, :none, 'Brightness'],
  [:zero, 33, :none, 'Zoom In'],
  [:zero, 34, :none, 'Zoom Out'],
  [:zero, 35, :none, 'Volume Down'],
  [:zero, 36, :none, 'Mute'],
  [:zero, 37, :none, 'Volume Up'],
  [:zero, 38, :none, 'Color Mode'],
  [:zero, 39, :none, 'Aspect Ratio'],

  [:set_a, 0, [:integer, -10, 10], 'Gamma and Color: User1 Gamma'],
  [:set_a, 1, [:integer, 0, 127], 'Gamma and Color: User1 Color Temp Red'],
  [:set_a, 2, [:integer, 0, 127], 'Gamma and Color: User1 Color Temp Green'],
  [:set_a, 3, [:integer, 0, 127], 'Gamma and Color: User1 Color Temp Blue'],
  [:set_a, 4, [:integer, 0, 32], 'Gamma and Color: User1 Color Manager Red'],
  [:set_a, 5, [:integer, 0, 32], 'Gamma and Color: User1 Color Manager Green'],
  [:set_a, 6, [:integer, 0, 32], 'Gamma and Color: User1 Color Manager Blue'],
  [:set_a, 7, [:integer, 0, 32], 'Gamma and Color: User1 Color Manager Yellow'],
  [:set_a, 8, [:integer, -10, 10], 'Gamma and Color: User2 Gamma'],
  [:set_a, 9, [:integer, 0, 127], 'Gamma and Color: User2 Color Temp Red'],
  [:set_a, 10, [:integer, 0, 127], 'Gamma and Color: User2 Color Temp Green'],
  [:set_a, 11, [:integer, 0, 127], 'Gamma and Color: User2 Color Temp Blue'],
  [:set_a, 12, [:integer, 0, 32], 'Gamma and Color: User2 Color Manager Red'],
  [:set_a, 13, [:integer, 0, 32], 'Gamma and Color: User2 Color Manager Green'],
  [:set_a, 14, [:integer, 0, 32], 'Gamma and Color: User2 Color Manager Blue'],
  [:set_a, 15, [:integer, 0, 32], 'Gamma and Color: User2 Color Manager Yellow'],
  [:set_a, 16, [:integer, 0, 127], 'Brightness'],
  [:set_a, 17, [:integer, 0, 127], 'Contrast'],
  [:set_a, 18, [:integer, -32, 32], 'Aspect Ratio: User Define H-Zoom'],
  [:set_a, 19, [:integer, -32, 32], 'Aspect Ratio: User Define V-Zoom'],
  [:set_a, 20, [:integer, -32, 32], 'Aspect Ratio: User Define H-Pan'],
  [:set_a, 21, [:integer, -32, 32], 'Aspect Ratio: User Define V-Pan'],
  [:set_a, 22, [:integer, 0, 255], 'Graphics Setting: H-Position'],
  [:set_a, 23, [:integer, 0, 255], 'Graphics Setting: V-Position'],
  [:set_a, 24, [:integer, 0, 127], 'Graphics Setting: Color'],
  [:set_a, 25, [:integer, 0, 127], 'Graphics Setting: Hue'],
  [:set_a, 26, [:integer, 0, 16], 'Graphics Setting: Sharpness'],
  [:set_a, 27, [:integer, 0, 100], 'Graphics Setting: Frequency'],
  [:set_a, 28, [:integer, 0, 31], 'Graphics Setting: Phase'],
  [:set_a, 29, [:integer, 0, 127], 'Video Setting: Color'],
  [:set_a, 30, [:integer, 0, 127], 'Video Setting: Hue'],
  [:set_a, 31, [:integer, 0, 16], 'Video Setting: Sharpness'],
  [:set_a, 32, [:integer, 0, 20], 'Video Setting: H-Position'],
  [:set_a, 33, [:integer, 0, 20], 'Video V-Position for NTSC/NTSC 4.43/PAL-M/PAL 60 (0~20) or PAL/PAL-N/SECAM/NTSC 4.43 50 (0~39)'],
  [:set_a, 34, [:integer, 0, 32], 'Audio Setting: Volume'],
  [:set_a, 35, [:integer, 0, 12], 'Audio Setting: Treble'],
  [:set_a, 36, [:integer, 0, 12], 'Audio Setting: Bass'],
  [:set_a, 37, [:integer, 0, 36], 'PIP Setting: H-Position'],
  [:set_a, 38, [:integer, 0, 36], 'PIP Setting: V-Position'],
  [:set_a, 39, [:integer, 0, 255], 'PIP Setting: User Define V-Size'],
  [:set_a, 40, [:integer, 0, 255], 'PIP Setting: User Define H-Size'],
  [:set_a, 41, [:integer, 0, 36], 'OSD Setting :H-Position'],
  [:set_a, 42, [:integer, 0, 36], 'OSD Setting: V-Position'],
  [:set_a, 43, [:integer, 3, 60], 'OSD Setting: OSD Time Out'],
  [:set_a, 44, [:gt, 100], 'HT, H-Sync Cycle (Setting Command should be a reasonable value)'],
  [:set_a, 45, [:gt, 0], 'HW, H-Sync Width'],
  [:set_a, 46, [:gt, 0], 'HS, Active Pixel Start'],
  [:set_a, 47, :any, 'HA, Active Pixel'],
  [:set_a, 48, [:integer, 0, 1], 'HP, H-Sync Polarity (0 for positive polarity, 1 for negative polarity)'],
  [:set_a, 49, [:gt, 0], 'VT, V-Sync Cycle'],
  [:set_a, 50, [:gt, 0], 'VW, V-Sync Width'],
  [:set_a, 51, [:gt, 0], 'VS, Active Line Start'],
  [:set_a, 52, :any, 'VA, Active Line'],
  [:set_a, 53, [:integer, 0, 1], 'VA, Active Line (0 for positive polarity, 1 for negative polarity0'],
  [:set_a, 54, [:gt, 100], 'OCLK, value is Param / 10 Mhz'],

  [:set_b, 0, [:integer, 0, 9], 'Select Input Source. 0: VGA-1, 1: VGA-2(VP-724 Only), 3: Component, 5: AV-1, 7: AV-2, 2: DVI, 4: YC-1, 6: YV-2, 8: Scart, 9: TV'],
  [:set_b, 1, [:integer, 0, 5], 'Geometry: Video Aspect Ratio, 0: Normal, 1: Wide Screen, 2: Pan & Scan, 3: 4:3, 4: 16:9, 5: UserDefine'],
  [:set_b, 2, [:integer, 0, 3], 'Geometry: Video Nonlinear, 0:Off 1:Side 2:Middle'],
  [:set_b, 3, [:integer, 0, 5], 'Geometry: VGA Aspect Ratio, 0:Full Screen 4:16:9 1:Native 2:NonLinear 3:4:3 4:16:9 5:UserDefine'],
  [:set_b, 4, [:integer, 0, 10], 'Zoom: Zoom Ratio, 0: Off ... 10: 400%'],
  [:set_b, 5, [:integer, 0, 2], 'Graphics Setting: Color Format, 0: Default 1: RGB 2: YUV'],
  [:set_b, 6, [:integer, 0, 2], 'Video Setting: Color Format, 0: Default 1: RGB 2: YUV'],

  [:set_b, 7, [:integer, 0, 6], 'Video Setting: Video Standard. 2: Video Standard - NTSC 4.43 0: Video Standard - Auto 1: Video Standard - NTSC 3: Video Standard - PAL 4: Video Standard - PAL-N 5: Video Standard - PAL-M 6: Video Standard - SECAM'],
  [:set_b, 8, [:integer, 0, 1], 'Video Setting: Film Mode. 0: Off 1: On'],
  [:set_b, 9, [:integer, 0, 1], 'Audio Setting: Stereo. 0: Off 1: On'],
  [:set_b, 10, [:integer, 0, 1], 'PIP Setting: PIP On/Off. 0: Off 1: On'],
  [:set_b, 11, [:integer, 0, 9], 'PIP Setting: PIP Source. 0: VGA-1 1: VGA-2(VP-724 Only) 3: Component 5: AV-1 7: AV-2 2: DVI 4: YC-1 6: YV-2 9: TV 8: SCART'],
  [:set_b, 12, [:integer, 0, 5], 'PIP Setting: PIP Size. 1: 1/16 3: 1/4 0: 1/25 2: 1/9 5: User Define 4: Split'],
  [:set_b, 13, [:integer, 0, 5], 'PIP Setting: PIP Frame. 0: Off 1: O'],

  [:set_b, 14, [:integer, 0, 2], 'Seamless Switch: Mode. 0: Fast 1: Moderate 2: Safe'],
  [:set_b, 15, [:integer, 0, 2], 'Seamless Switch: Background. 0: Black 1: Blue 2: Disable Analog Syncs'],
  [:set_b, 16, [:integer, 0, 2], 'Seamless Switch: Auto Search. 0: Off 1: On'],
  [:set_b, 17, [:integer, 0, 1], 'OSD Setting: Startup Logo. 0: Off 1: On'],
  [:set_b, 18, [:integer, 0, 1], 'OSD Setting: Size. 0: Normal 1: Double'],
  [:set_b, 19, [:integer, 0, 1], 'OSD Setting: Source Prompt. 0: Off 1: On'],
  [:set_b, 20, [:integer, 0, 1], 'OSD Setting: Blank Color. 0: Blue 1: Black'],
  [:set_b, 21, [:integer, 0, 17], 'Output Resolution. 0: 640x480 2: 1024x768 5: 852x1024i 7: 1366x768 9: 1280x720 11: 852x480 13: 480P 19: User Define 18: 1280x768 1: 800x600 17: 1080P 14: 720P 16: 576P 4: 1600x1200 6: 1024x1024i 8: 1365x1024 12: 1400x1050 10: 720x483, 3: 1280x1024, 15: 1080i. HDTV output is VP723/724 Only 1080P only on KI238 and 80P DAC Board'],

  [:set_b, 22, [:integer, 0, 3], 'Output Refresh Rate. 0: 60Hz 1: 75Hz 2: 85Hz 3: 50Hz
  '],
  [:set_b, 23, [:integer, 0, 1], 'Factory Reset. 0:Cancel, 1:ok'],
  [:set_b, 24, [:integer, 0, 3], 'Advanced: Input Button. 0: Freeze/Blank 1: Freeze 2: Blank 3: Ignore'],
  [:set_b, 25, [:integer, 0, 1], 'Key Lock Save'],
  [:set_b, 26, [:integer, 0, 1], 'Input Lock'],
  [:set_b, 27, [:integer, 0, 1], 'SOG Setting. 0:Auto, 1:RGsB, 2:DTV. KI239 Only'],
  [:set_b, 28, [:integer, 0, 1], 'Enable OSD Timeout. 0: Disable 1: Enable'],
  [:set_b, 29, [:integer, 0, 2], 'Select Output Mode Userdefined Parameter Group. 0: Group 1 1: Group 2 2: Group 3'],
  [:set_b, 30, [:integer, 0, 2], 'Set the control way of Saving Audio Volume / Treble / Bass values. 1: Individual 0: Master 2: Linked'],

  [:five, 0, :none, 'Load Gamma/Color - Normal'],
  [:five, 1, :none, 'Load Gamma/Color - Presentation'],
  [:five, 2, :none, 'Load Gamma/Color - Cinema'],
  [:five, 3, :none, 'Load Gamma/Color - Nature'],
  [:five, 4, :none, 'Load Gamma/Color - User1'],
  [:five, 5, :none, 'Load Gamma/Color - User2'],

  [:set_c, 0, [:integer, 0, 1], 'Power. 0: Power Down 1: Power On'],
  [:set_c, 1, [:integer, 0, 1], 'Freeze. 0: Off 1: On'],
  [:set_c, 2, [:integer, 0, 1], 'Blank. 0: Off 1: On'],
  [:set_c, 3, [:integer, 0, 1], 'Mute. 0: Off 1: On'],
  [:set_c, 4, [:integer, 0, 1], 'Key Lock. 0: Off 1: On'],

  [:eight, 0, :none, '"Resolution/Refresh Rate" Or "Video Stand". Example: "Y 8 0 CR" return: "Z 8 0 1080i CR"'],
] 

# serial = SerialPort.new('/dev/tty.usbserial-110', baud: 9600, data_bits: 8, parity: NONE, stop_bits: 1)
serial = SerialPort.new('/dev/tty.usbserial-110', 9600, 8, 1, SerialPort::NONE) # device, baud, data bits, stop bits, parity
serial.flow_control = SerialPort::NONE
serial.flush_input

action = :get
COMMANDS.each do |control_type_name, function, arg_set, desc|
  control_type = CONTROL_TYPES[control_type_name]
  if action == :get && control_type[:get].nil?
    puts "Skipping #{desc}: has no 'get'"
    next
  end

  if action == :set && CONTROL_TYPES.map{|_k, val| val[:set]}.include?(control_type[:get])
    argval = case arg_set.first
    when :integer
      # rand(arg_set.last + arg_set[-2].abs) - arg_set[-2].abs
      puts "VALIDATE :integer"
    when :gt
      # rand(arg_set.last + arg_set[-2])
      puts "VALIDATE :gt"
    else
      puts "Skipping #{desc}; unknown arg type: #{arg_set.first}"
      next
    end
  end

  cmd = "Y #{control_type[:get]} #{function}"
  print "#{desc.inspect}: "
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
  puts resp.inspect
  # puts "next cmmand"
  sleep(0.1)
end