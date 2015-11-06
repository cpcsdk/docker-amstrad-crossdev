#!/usr/bin/env python
# -*- coding: utf-8 -*-


import get_palette_from_png as g

c = (
(1,1,1),
(0,0.00784314,0.00392157),
(0.443137,0.952941,0.956863),
(0.0470588,0.482353,0.956863),
(0.431373,0.482353,0.427451),
(0.423529,0.00784314,0.94902),
(0.411765,0.00784314,0.407843),
(0.423529,0.00784314,0.00392157),
(0.952941,0.0196078,0.0235294),
(0.952941,0.490196,0.0509804),
(0.952941,0.952941,0.0509804),
(0.952941,0.952941,0.427451),
(0.952941,0.490196,0.419608),

)

def build_color(tmp):
    return 255*tmp[0], 255*tmp[1], 255*tmp[2]

c = [build_color(a) for a in c]

print '; Color extraction'
print '; Krusty/Benediction'
for ink, color in enumerate(c):
    print '\tdb 0x%x\t; ink %d' % (g.get_closer_color(color), ink)
