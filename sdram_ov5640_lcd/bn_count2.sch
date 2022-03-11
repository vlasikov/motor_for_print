<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="In_1" />
        <signal name="Out_1" />
        <signal name="XLXN_16" />
        <signal name="XLXN_18" />
        <port polarity="Input" name="In_1" />
        <port polarity="Output" name="Out_1" />
        <blockdef name="gnd">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-64" y2="-96" x1="64" />
            <line x2="52" y1="-48" y2="-48" x1="76" />
            <line x2="60" y1="-32" y2="-32" x1="68" />
            <line x2="40" y1="-64" y2="-64" x1="88" />
            <line x2="64" y1="-64" y2="-80" x1="64" />
            <line x2="64" y1="-128" y2="-96" x1="64" />
        </blockdef>
        <blockdef name="vcc">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-32" y2="-64" x1="64" />
            <line x2="64" y1="0" y2="-32" x1="64" />
            <line x2="32" y1="-64" y2="-64" x1="96" />
        </blockdef>
        <blockdef name="cb2ce">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <rect width="256" x="64" y="-384" height="320" />
            <line x2="320" y1="-128" y2="-128" x1="384" />
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="64" y1="-128" y2="-144" x1="80" />
            <line x2="80" y1="-112" y2="-128" x1="64" />
            <line x2="64" y1="-32" y2="-32" x1="192" />
            <line x2="192" y1="-64" y2="-32" x1="192" />
            <line x2="64" y1="-192" y2="-192" x1="0" />
            <line x2="320" y1="-192" y2="-192" x1="384" />
            <line x2="320" y1="-256" y2="-256" x1="384" />
            <line x2="320" y1="-320" y2="-320" x1="384" />
        </blockdef>
        <block symbolname="cb2ce" name="XLXI_9">
            <blockpin signalname="In_1" name="C" />
            <blockpin signalname="XLXN_18" name="CE" />
            <blockpin signalname="XLXN_16" name="CLR" />
            <blockpin name="CEO" />
            <blockpin signalname="Out_1" name="Q0" />
            <blockpin name="Q1" />
            <blockpin name="TC" />
        </block>
        <block symbolname="gnd" name="XLXI_10">
            <blockpin signalname="XLXN_16" name="G" />
        </block>
        <block symbolname="vcc" name="XLXI_11">
            <blockpin signalname="XLXN_18" name="P" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <instance x="752" y="1152" name="XLXI_9" orien="R0" />
        <branch name="In_1">
            <wire x2="752" y1="1024" y2="1024" x1="720" />
        </branch>
        <iomarker fontsize="28" x="720" y="1024" name="In_1" orien="R180" />
        <branch name="Out_1">
            <wire x2="1168" y1="832" y2="832" x1="1136" />
        </branch>
        <iomarker fontsize="28" x="1168" y="832" name="Out_1" orien="R0" />
        <branch name="XLXN_16">
            <wire x2="752" y1="1120" y2="1152" x1="752" />
        </branch>
        <instance x="688" y="1280" name="XLXI_10" orien="R0" />
        <instance x="560" y="880" name="XLXI_11" orien="R0" />
        <branch name="XLXN_18">
            <wire x2="624" y1="880" y2="960" x1="624" />
            <wire x2="752" y1="960" y2="960" x1="624" />
        </branch>
    </sheet>
</drawing>