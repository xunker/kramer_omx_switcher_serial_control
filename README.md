# Control Kramer, Ocean Matrix, or BTX Video Switchers via RS-232 Serial

Proof of concept for controlling an Ocean Matrix OMX-7190A (Kramer VP-719) via serial. Should also
work for similar models rebranded by other manufacturers.

Kramer   | Ocean Matrix | BTX
---------|--------------|---------
VP-719   | OMX-7190A    | BTX-719
VP-720   | OMX-7200A    |
VP-723   |              |
VP-724   | OMX-7240A    |
VP-7xx   |              |

## Using

Requires file
[vp-7xx.json](https://github.com/xunker/kramer_vp_control_protocol/blob/main/vp-7xx.json)
from the [kramer_vp_control_protocol](https://github.com/xunker/kramer_vp_control_protocol) project.

Edit `json_omx.rb` and update `JSON_COMMAND_FILE` and `SERIAL_DEVICE` as appropriate.

Run `bundle install` (requires Ruby >= 2.6.9 to be installed on your system).

Finally `ruby json_omx.rb` (on *nix systems `./json_omx.rb` will also work). The program should then send each command listed in vp-7xx.json to your Switcher device.