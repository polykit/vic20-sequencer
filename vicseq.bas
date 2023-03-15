10 print "{clr}"
20 rem init variables
30 dim n%(0,15), t%(0,15), l%(0,15), o%(1,12), m(0,15), nl(0,15) : rem note, transpose, length, octave mapping, midi note, note length
31 o%(0,0)=45:o%(0,1)=3:o%(0,2)=3:o%(1,2)=35:o%(0,3)=4:o%(0,4)=4:o%(1,4)=35:o%(0,5)=5:o%(0,6)=6
32 o%(0,7)=6:o%(1,7)=35:o%(0,8)=7:o%(0,9)=7:o%(1,9)=35:o%(0,10)=1:o%(0,11)=1:o%(1,11)=35:o%(0,12)=2
40 base=39936 : rem uart base address
43 track%=0
45 channel%=0
50 tempo%=200
60 s%=0 : rem sequencer step
65 ls%=-1 : rem last step
66 cp=42 : rem character to poke
67 un%=0 : rem update note
68 ut%=0 : rem update table
69 play%=0 : rem is playing
70 no=0 : rem note on
71 nt=0 : rem note time
72 sl=0 : rem step length
73 pl=0 : rem note already played
74 gosub 1000
90 for i=0 to 15 : s%=i : l%(0,i)=50 : gosub 500 : gosub 400 : next i : s% = 0 : gosub 500
91 gosub 300 : rem update table
92 rem init uart midi device
93 poke base+3, 128 : poke base+1, 0 : poke base, 37 : poke base+3, 3 : poke base+4, 4

95 gosub 700 : rem read keys
96 gosub 500 : rem update step
97 gosub 200 : rem play note
100 goto 95

200 rem play note
201 if play%=0 then return
203 if no=0 and nt=0 then nt=ti
204 if no=0 and pl=0 and n%(track%,s%)>0 then gosub 800 : no=1 : pl=1 : rem note on
205 if no=1 and ti-nt>nl(track%,s%) then gosub 900 : no=0 : rem note off
206 if nt<>0 and ti-nt>sl then nt=0 : s%=s%+1 : pl=0 : if s%>15 then s%=0 : rem next step
299 return

300 rem update transpose/length/tempo/channel table
301 if t%(0,s%)>=0 then poke 7984, 32 : poke 7985, t%(track%,s%)+48
302 if t%(0,s%)<0 then poke 7984, 45 : poke 7985, abs(t%(track%,s%))+48
303 if l%(0,s%)<10 then poke 8005, 32 : poke 8006, 32 : poke 8007, l%(track%,s%)+48
304 if l%(0,s%)>=10 then n=int(l%(track%,s%)/10) : poke 8005, 32 : poke 8006, n+48 : poke 8007, l%(track%,s%)-n*10+48
305 if l%(0,s%)>=100 then poke 8005, 49 : poke 8006, 48
306 if tempo%<10 then poke 8027, 32 : poke 8028, 32 : poke 8029, tempo%+48
307 if tempo%>=10 then n=int(tempo%/10) : poke 8027, 32 : poke 8028, n+48 : poke 8029, tempo%-n*10+48
308 if tempo%>=100 then n=int(tempo%/100) : poke 8027, n+48 : poke 8028, int((tempo%-n*100)/10)+48
309 if channel%+1<10 then poke 8050, 32 : poke 8051, channel%+49
310 if channel%+1>=10 then poke 8050, 49 : poke 8051, channel%+39
311 sl=int((60000/tempo%)/(1000/60))
312 nl(track%,s%)=int(sl*l%(track%,s%)/100)
319 ut%=0
320 return

400 rem update note
410 xp=xp+1
425 cp=o%(0,n%(track%,s%)) : gosub 600
426 xp=xp+1
427 cp=32
428 if o%(1,n%(track%,s%))<>0 then cp=o%(1,n%(track%,s%))
429 gosub 600
430 xp=xp-2
431 m(track%,s%)=n%(track%,s%)+59+t%(track%,s%)*12
432 un%=0
440 return

500 rem update step
510 if s%=ls% then return
511 cp=32 : gosub 600
520 xp=s%*4+3 : yp=4
521 if s%>3 then xp=xp+28
522 if s%>7 then xp=xp+28
523 if s%>11 then xp=xp+28
525 cp=42 : gosub 600
530 ls%=s%
540 return

600 rem print char at position
610 poke 7680+yp*22+xp, cp
620 return

700 rem read keys
701 get k$
702 if k$="p" then play%=abs(play%-1) : ut%=1
703 if k$="s" then play%=0 : s%=0 : ut%=1
704 if play%=1 then return
711 if k$="" then return
711 if k$="." then s%=s%+1 : ut%=1
712 if k$="," then s%=s%-1 : ut%=1
713 if s%<0 then s%=15
714 if s%>15 then s%=0
715 if k$="2" then n%(track%,s%)=n%(track%,s%)+1 : un%=1
716 if k$="1" then n%(track%,s%)=n%(track%,s%)-1 : un%=1
717 if n%(track%,s%)>12 then n%(track%,s%)=0
718 if n%(track%,s%)<0 then n%(track%,s%)=12
719 if k$="4" then t%(track%,s%)=t%(track%,s%)+1 : un%=1 : ut%=1
720 if k$="3" then t%(track%,s%)=t%(track%,s%)-1 : un%=1 : ut%=1
721 if t%(track%,s%)>4 then t%(track%,s%)=4
722 if t%(track%,s%)<-4 then t%(track%,s%)=-4
723 if k$="6" then l%(track%,s%)=l%(track%,s%)+10 : ut%=1
724 if k$="5" then l%(track%,s%)=l%(track%,s%)-10 : ut%=1
725 if l%(track%,s%)>100 then l%(track%,s%)=100
726 if l%(track%,s%)<0 then l%(track%,s%)=0
727 if k$="8" then tempo%=tempo%+10 : ut%=1
728 if k$="7" then tempo%=tempo%-10 : ut%=1
729 if tempo%>240 then tempo%=240
730 if tempo%<0 then tempo%=0
731 if k$="c" then channel%=channel%+1 : ut%=1
732 if channel%>15 then channel%=0
733 if k$="f" then gosub 750
733 if un%=1 then gosub 400
734 if ut%=1 then gosub 300
740 return

750 rem fill steps
751 for i=0 to 3
752   n%(track%,i+4)=n%(track%,i) : t%(track%,i+4)=t%(track%,i) : l%(track%,i+4)=l%(track%,i)
753   n%(track%,i+8)=n%(track%,i) : t%(track%,i+8)=t%(track%,i) : l%(track%,i+8)=l%(track%,i)
754   n%(track%,i+12)=n%(track%,i) : t%(track%,i+12)=t%(track%,i) : l%(track%,i+12)=l%(track%,i)
755 next i
756 for i=4 to 15 : s%=i : gosub 500 : gosub 400 : gosub 300 : next i : s% = 0 : gosub 500 : gosub 300
790 return

800 rem note on
810 if (peek(base+5) and 32)=1 then 810
820 poke base, 144+channel% : rem note on
830 if (peek(base+5) and 32)=1 then 830
840 poke base, m(track%,s%) : rem note value
850 if (peek(base+5) and 32)=1 then 850
860 poke base, 64 : rem velocity
890 return

900 rem note off
910 if (peek(base+5) and 32)=1 then 910
920 poke base, 128+channel% : rem note off
930 if (peek(base+5) and 32)=1 then 930
940 poke base, m(track%,s%) : rem note value
950 if (peek(base+5) and 32)=1 then 950
960 poke base, 0 : rem velocity
990 return

1000 rem init display
1010 print "{pur}polykit midi sequencer{blk}"
1015 for i=0 to 8
1017   print "  ";
1020   for j=0 to 16
1030     read b
1040     print chr$(b);
1050   next j
1053   print ""
1055 next i
1120 print "1/2         note"
1130 print "3/4    transpose:    "
1140 print "5/6       length:    "
1150 print "7/8        tempo:    "
1155 print "c        channel:    "
1160 print "p     play/pause"
1170 print "s           stop"
1175 print "f           fill"
1190 print ",/.         step"
1210 print "*** v0.1 **** 2023 ***";
1220 return
2000 data 117,96,96,96,178,96,96,96,178,96,96,96,178,96,96,96,105
2010 data 125,32,32,32,125,32,32,32,125,32,32,32,125,32,32,32,125
2020 data 171,96,96,96,123,96,96,96,123,96,96,96,123,96,96,96,179
2030 data 125,32,32,32,125,32,32,32,125,32,32,32,125,32,32,32,125
2040 data 171,96,96,96,123,96,96,96,123,96,96,96,123,96,96,96,179
2050 data 125,32,32,32,125,32,32,32,125,32,32,32,125,32,32,32,125
2060 data 171,96,96,96,123,96,96,96,123,96,96,96,123,96,96,96,179
2070 data 125,32,32,32,125,32,32,32,125,32,32,32,125,32,32,32,125
2080 data 106,96,96,96,177,96,96,96,177,96,96,96,177,96,96,96,107
