# Wire Dispenser

A simple box for holding equipment wire, with center dowel to allow dispensing
through front slots. Since the design uses OpenSCAD, the code is designed to
be configurable to any size/number of reels one requires. 

# Usage

Set the variables at the top of the code to your reel diamensions and number
required. The _baseSlots_ and _sideSlots_ require a bit of tinkering until it
looks right - probably a better way to do that.

By default, the code is to make a 6 reel holder of this 24AWG AlphaWire:
http://uk.farnell.com/alpha-wire/1550-bk005/wire-blk-24awg-7-32awg-30-5m/dp/2291093.

# Assembly

To view everything slotted together, leave `export=false` - this arranges the
3d parts.

![Assembly Render](/img/assembly.png)

# DXF Export

Once your happy, to create a .dxf for sending to a cutter, set `export=true`.
It uses `projection()` to get the 2d sections of each piece and arranges them
on a flat area.

![Print Sheet](/img/print.png)
