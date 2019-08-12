#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    # Provoke name search
    catch {package require bogus-package-name}
    set packageNames [package names]

    package require BWidget
    switch $tcl_platform(platform) {
	windows {
	}
	default {
	    option add *ScrolledWindow.size 14
	}
    }
    
    package require Tk
    switch $tcl_platform(platform) {
	windows {
            option add *Button.padY 0
	}
	default {
            option add *Scrollbar.width 10
            option add *Scrollbar.highlightThickness 0
            option add *Scrollbar.elementBorderWidth 2
            option add *Scrollbar.borderWidth 2
	}
    }
    
}

#############################################################################
# Visual Tcl v1.60 Project
#




#############################################################################
## vTcl Code to Load Stock Images


if {![info exist vTcl(sourcing)]} {
#############################################################################
## Procedure:  vTcl:rename

proc ::vTcl:rename {name} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret
    regsub -all "::" $ret "__" ret

    return [string tolower $ret]
}

#############################################################################
## Procedure:  vTcl:image:create_new_image

proc ::vTcl:image:create_new_image {filename {description {no description}} {type {}} {data {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    # Does the image already exist?
    if {[info exists ::vTcl(images,files)]} {
        if {[lsearch -exact $::vTcl(images,files) $filename] > -1} { return }
    }

    if {![info exists ::vTcl(sourcing)] && [string length $data] > 0} {
        set object [image create  [vTcl:image:get_creation_type $filename]  -data $data]
    } else {
        # Wait a minute... Does the file actually exist?
        if {! [file exists $filename] } {
            # Try current directory
            set script [file dirname [info script]]
            set filename [file join $script [file tail $filename] ]
        }

        if {![file exists $filename]} {
            set description "file not found!"
            ## will add 'broken image' again when img is fixed, for now create empty
            set object [image create photo -width 1 -height 1]
        } else {
            set object [image create  [vTcl:image:get_creation_type $filename]  -file $filename]
        }
    }

    set reference [vTcl:rename $filename]
    set ::vTcl(images,$reference,image)       $object
    set ::vTcl(images,$reference,description) $description
    set ::vTcl(images,$reference,type)        $type
    set ::vTcl(images,filename,$object)       $filename

    lappend ::vTcl(images,files) $filename
    lappend ::vTcl(images,$type) $object

    # return image name in case caller might want it
    return $object
}

#############################################################################
## Procedure:  vTcl:image:get_image

proc ::vTcl:image:get_image {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    set reference [vTcl:rename $filename]

    # Let's do some checking first
    if {![info exists ::vTcl(images,$reference,image)]} {
        # Well, the path may be wrong; in that case check
        # only the filename instead, without the path.

        set imageTail [file tail $filename]

        foreach oneFile $::vTcl(images,files) {
            if {[file tail $oneFile] == $imageTail} {
                set reference [vTcl:rename $oneFile]
                break
            }
        }
    }
    return $::vTcl(images,$reference,image)
}

#############################################################################
## Procedure:  vTcl:image:get_creation_type

proc ::vTcl:image:get_creation_type {filename} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    switch [string tolower [file extension $filename]] {
        .ppm -
        .jpg -
        .bmp -
        .gif    {return photo}
        .xbm    {return bitmap}
        default {return photo}
    }
}

foreach img {


            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

}
#############################################################################
## vTcl Code to Load User Images

catch {package require Img}

foreach img {

        {{[file join . GUI Images SaveFile.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images GIMPshortcut.gif]} {user image} user {}}

            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
}

#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
#############################################################################
## Library Procedure:  Window

proc ::Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    foreach {cmd name newname} [lrange $args 0 2] {}
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists} {
                wm deiconify $newname
            } elseif {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[winfo exists $newname] && [wm state $newname] == "normal"} {
                vTcl:FireEvent $newname <<Show>>
            }
        }
        hide    {
            if {$exists} {
                wm withdraw $newname
                vTcl:FireEvent $newname <<Hide>>
                return}
        }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}
#############################################################################
## Library Procedure:  vTcl:DefineAlias

proc ::vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global widget
    set widget($alias) $target
    set widget(rev,$target) $alias
    if {$cmdalias} {
        interp alias {} $alias {} $widgetProc $target
    }
    if {$top_or_alias != ""} {
        set widget($top_or_alias,$alias) $target
        if {$cmdalias} {
            interp alias {} $top_or_alias.$alias {} $widgetProc $target
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:DoCmdOption

proc ::vTcl:DoCmdOption {target cmd} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}
#############################################################################
## Library Procedure:  vTcl:FireEvent

proc ::vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
        set tag_events [bind $bindtag]
        set stop_processing 0
        foreach tag_event $tag_events {
            if {$tag_event == $event} {
                set bind_code [bind $bindtag $tag_event]
                foreach rep "\{%W $target\} $params" {
                    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
                }
                set result [catch {uplevel #0 $bind_code} errortext]
                if {$result == 3} {
                    ## break exception, stop processing
                    set stop_processing 1
                } elseif {$result != 0} {
                    bgerror $errortext
                }
                break
            }
        }
        if {$stop_processing} {break}
    }
}
#############################################################################
## Library Procedure:  vTcl:Toplevel:WidgetProc

proc ::vTcl:Toplevel:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    set command [lindex $args 0]
    set args [lrange $args 1 end]
    switch -- [string tolower $command] {
        "setvar" {
            foreach {varname value} $args {}
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "show" {
            Window [string tolower $command] $w
        }
        "showmodal" {
            ## modal dialog ends when window is destroyed
            Window show $w; raise $w
            grab $w; tkwait window $w; grab release $w
        }
        "startmodal" {
            ## ends when endmodal called
            Window show $w; raise $w
            set ::${w}::_modal 1
            grab $w; tkwait variable ::${w}::_modal; grab release $w
        }
        "endmodal" {
            ## ends modal dialog started with startmodal, argument is var name
            set ::${w}::_modal 0
            Window hide $w
        }
        default {
            uplevel $w $command $args
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:WidgetProc

proc ::vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }

    set command [lindex $args 0]
    set args [lrange $args 1 end]
    uplevel $w $command $args
}
#############################################################################
## Library Procedure:  vTcl:toplevel

proc ::vTcl:toplevel {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {set _modal 0}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top389
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.tit76 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit76 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd84
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd83 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd83 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.but74 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.fra76 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.fra76
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.tit71 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.tit71 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.fra74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra74
    namespace eval ::widgets::$site_8_0.but75 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_8_0.but76 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_7_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-background 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.but66 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd81
    namespace eval ::widgets::$site_6_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra90
    namespace eval ::widgets::$site_7_0.cpd92 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd91
    namespace eval ::widgets::$site_7_0.cpd93 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top389
            PlotSquint
            PlotSquintThumb
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  main

proc ::main {argc argv} {
## This will clean up and call exit properly on Windows.
#vTcl:WindowsCleanup
}
#############################################################################
## Procedure:  PlotSquint

proc ::PlotSquint {} {
global TMPRawSpectrumTxt TMPRawSpectrumBin TMPAvgSpectrumTxt TMPAvgSpectrumBin
global GnuplotPipeFid GnuplotPipeSquint GnuOutputFormat GnuOutputFile 
global GnuSpectrumChannelId GnuSpectrumChannel GnuSpectrumFile
global TMPGnuPlotTk1 TMPGnuPlot1Tk

set xwindow [winfo x .top389]; set ywindow [winfo y .top389]

DeleteFile $TMPGnuPlotTk1
DeleteFile $TMPGnuPlot1Tk

if {$GnuplotPipeSquint == ""} {
    GnuPlotInit 0 0 1 1
    set GnuplotPipeSquint $GnuplotPipeFid
    }
    
#PlotSquintThumb

set GnuOutputFile $TMPGnuPlotTk1
set GnuOutputFormat "gif"
GnuPlotTerm $GnuplotPipeSquint $GnuOutputFormat

if {$GnuSpectrumChannelId == 1} {set GnuSpectrumChannel "s11"}
if {$GnuSpectrumChannelId == 2} {set GnuSpectrumChannel "s12"}
if {$GnuSpectrumChannelId == 3} {set GnuSpectrumChannel "s21"}
if {$GnuSpectrumChannelId == 4} {set GnuSpectrumChannel "s22"}
#if {$GnuSpectrumChannelId == 5} {set GnuSpectrumChannel "All"}

if {$GnuSpectrumFile == "raw"} {
    WaitUntilCreated $TMPRawSpectrumTxt 
    if [file exists $TMPRawSpectrumTxt] {
        set f [open $TMPRawSpectrumTxt r]
        gets $f xmax; gets $f ymin; gets $f ymax
        close $f
        }
    }
if {$GnuSpectrumFile == "avg"} {
    WaitUntilCreated $TMPAvgSpectrumTxt 
    if [file exists $TMPAvgSpectrumTxt] {
        set f [open $TMPAvgSpectrumTxt r]
        gets $f xmax; gets $f ymin; gets $f ymax
        close $f
        }
    }
set xmin "0"
incr xmax -1

puts $GnuplotPipeSquint "set autoscale"; flush $GnuplotPipeSquint
puts $GnuplotPipeSquint "set xlabel 'Doppler Freq'"; flush $GnuplotPipeSquint
puts $GnuplotPipeSquint "set ylabel 'Amplitude - dB'"; flush $GnuplotPipeSquint
set xrg "\x5B$xmin:$xmax\x5D"; puts $GnuplotPipeSquint "set xrange $xrg noreverse nowriteback"; flush $GnuplotPipeSquint
set yrg "\x5B$ymin:$ymax\x5D"; puts $GnuplotPipeSquint "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeSquint
puts $GnuplotPipeSquint "set title 'Doppler Spectrum - Channel $GnuSpectrumChannel' textcolor lt 3"; flush $GnuplotPipeSquint
if {$GnuSpectrumFile == "raw"} {
    if {$GnuSpectrumChannelId == 1} {puts $GnuplotPipeSquint "plot '$TMPRawSpectrumBin' using 1:2 title 's11 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 2} {puts $GnuplotPipeSquint "plot '$TMPRawSpectrumBin' using 1:3 title 's12 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 3} {puts $GnuplotPipeSquint "plot '$TMPRawSpectrumBin' using 1:4 title 's21 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 4} {puts $GnuplotPipeSquint "plot '$TMPRawSpectrumBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeSquint}
    #if {$GnuSpectrumChannelId == 5} {puts $GnuplotPipeSquint "plot '$TMPRawSpectrumBin' using 1:2 title 's11 channel' with lines, '$TMPRawSpectrumBin' using 1:3 title 's12 channel' with lines, '$TMPRawSpectrumBin' using 1:4 title 's21 channel' with lines, '$TMPRawSpectrumBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeSquint}
    }
if {$GnuSpectrumFile == "avg"} {
    if {$GnuSpectrumChannelId == 1} {puts $GnuplotPipeSquint "plot '$TMPAvgSpectrumBin' using 1:2 title 's11 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 2} {puts $GnuplotPipeSquint "plot '$TMPAvgSpectrumBin' using 1:3 title 's12 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 3} {puts $GnuplotPipeSquint "plot '$TMPAvgSpectrumBin' using 1:4 title 's21 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 4} {puts $GnuplotPipeSquint "plot '$TMPAvgSpectrumBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeSquint}
    #if {$GnuSpectrumChannelId == 5} {puts $GnuplotPipeSquint "plot '$TMPAvgSpectrumBin' using 1:2 title 's11 channel' with lines, '$TMPAvgSpectrumBin' using 1:3 title 's12 channel' with lines, '$TMPAvgSpectrumBin' using 1:4 title 's21 channel' with lines, '$TMPAvgSpectrumBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeSquint}
    }

puts $GnuplotPipeSquint "unset output"; flush $GnuplotPipeSquint

set ErrorCatch [catch {puts $GnuplotPipeSquint "quit"}]
if { $ErrorCatch == "0" } {
    puts $GnuplotPipeSquint "quit"; flush $GnuplotPipeSquint
    }
catch "close $GnuplotPipeSquint"
set GnuplotPipeSquint ""

WaitUntilCreated $TMPGnuPlotTk1
Gimp $TMPGnuPlotTk1
#ViewGnuPlotTKThumb 1 .top389 "Doppler Spectrum"
}
#############################################################################
## Procedure:  PlotSquintThumb

proc ::PlotSquintThumb {} {
global TMPRawSpectrumTxt TMPRawSpectrumBin TMPAvgSpectrumTxt TMPAvgSpectrumBin
global GnuplotPipeFid GnuplotPipeSquint GnuOutputFormat GnuOutputFile 
global GnuSpectrumChannelId GnuSpectrumChannel GnuSpectrumFile
global TMPGnuPlotTk1 TMPGnuPlot1Tk

set xwindow [winfo x .top389]; set ywindow [winfo y .top389]

DeleteFile $TMPGnuPlot1Tk

set GnuOutputFile $TMPGnuPlot1Tk
set GnuOutputFormat "png"
GnuPlotTerm $GnuplotPipeSquint $GnuOutputFormat

if {$GnuSpectrumChannelId == 1} {set GnuSpectrumChannel "s11"}
if {$GnuSpectrumChannelId == 2} {set GnuSpectrumChannel "s12"}
if {$GnuSpectrumChannelId == 3} {set GnuSpectrumChannel "s21"}
if {$GnuSpectrumChannelId == 4} {set GnuSpectrumChannel "s22"}
#if {$GnuSpectrumChannelId == 5} {set GnuSpectrumChannel "All"}

if {$GnuSpectrumFile == "raw"} {
    WaitUntilCreated $TMPRawSpectrumTxt 
    if [file exists $TMPRawSpectrumTxt] {
        set f [open $TMPRawSpectrumTxt r]
        gets $f xmax; gets $f ymin; gets $f ymax
        close $f
        }
    }
if {$GnuSpectrumFile == "avg"} {
    WaitUntilCreated $TMPAvgSpectrumTxt 
    if [file exists $TMPAvgSpectrumTxt] {
        set f [open $TMPAvgSpectrumTxt r]
        gets $f xmax; gets $f ymin; gets $f ymax
        close $f
        }
    }
set xmin "0"
incr xmax -1

puts $GnuplotPipeSquint "set autoscale"; flush $GnuplotPipeSquint
puts $GnuplotPipeSquint "set xlabel 'Doppler Freq'"; flush $GnuplotPipeSquint
puts $GnuplotPipeSquint "set ylabel 'Amplitude - dB'"; flush $GnuplotPipeSquint
set xrg "\x5B$xmin:$xmax\x5D"; puts $GnuplotPipeSquint "set xrange $xrg noreverse nowriteback"; flush $GnuplotPipeSquint
set yrg "\x5B$ymin:$ymax\x5D"; puts $GnuplotPipeSquint "set yrange $yrg noreverse nowriteback"; flush $GnuplotPipeSquint
puts $GnuplotPipeSquint "set title 'Doppler Spectrum - Channel $GnuSpectrumChannel' textcolor lt 3"; flush $GnuplotPipeSquint
if {$GnuSpectrumFile == "raw"} {
    if {$GnuSpectrumChannelId == 1} {puts $GnuplotPipeSquint "plot '$TMPRawSpectrumBin' using 1:2 title 's11 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 2} {puts $GnuplotPipeSquint "plot '$TMPRawSpectrumBin' using 1:3 title 's12 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 3} {puts $GnuplotPipeSquint "plot '$TMPRawSpectrumBin' using 1:4 title 's21 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 4} {puts $GnuplotPipeSquint "plot '$TMPRawSpectrumBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeSquint}
    #if {$GnuSpectrumChannelId == 5} {puts $GnuplotPipeSquint "plot '$TMPRawSpectrumBin' using 1:2 title 's11 channel' with lines, '$TMPRawSpectrumBin' using 1:3 title 's12 channel' with lines, '$TMPRawSpectrumBin' using 1:4 title 's21 channel' with lines, '$TMPRawSpectrumBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeSquint}
    }
if {$GnuSpectrumFile == "avg"} {
    if {$GnuSpectrumChannelId == 1} {puts $GnuplotPipeSquint "plot '$TMPAvgSpectrumBin' using 1:2 title 's11 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 2} {puts $GnuplotPipeSquint "plot '$TMPAvgSpectrumBin' using 1:3 title 's12 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 3} {puts $GnuplotPipeSquint "plot '$TMPAvgSpectrumBin' using 1:4 title 's21 channel' with lines"; flush $GnuplotPipeSquint}
    if {$GnuSpectrumChannelId == 4} {puts $GnuplotPipeSquint "plot '$TMPAvgSpectrumBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeSquint}
    #if {$GnuSpectrumChannelId == 5} {puts $GnuplotPipeSquint "plot '$TMPAvgSpectrumBin' using 1:2 title 's11 channel' with lines, '$TMPAvgSpectrumBin' using 1:3 title 's12 channel' with lines, '$TMPAvgSpectrumBin' using 1:4 title 's21 channel' with lines, '$TMPAvgSpectrumBin' using 1:5 title 's22 channel' with lines"; flush $GnuplotPipeSquint}
    }

puts $GnuplotPipeSquint "unset output"; flush $GnuplotPipeSquint

WaitUntilCreated $TMPGnuPlot1Tk
}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {
global tk_strictMotif MouseInitX MouseInitY MouseEndX MouseEndY BMPMouseX BMPMouseY

catch {package require unsafe}
set tk_strictMotif 1
global TrainingAreaTool; 
global x;
global y;

set TrainingAreaTool rect
}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $top passive
    wm geometry $top 200x200+175+175; update
    wm maxsize $top 3360 1028
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl"
    bindtags $top "$top Vtcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top389 {base} {
    if {$base == ""} {
        set base .top389
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x310+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Calibration : Squint Check"
    vTcl:DefineAlias "$top" "Toplevel389" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit71 \
        -ipad 2 -text {Input Directory} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel389" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable SquintDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry389_149" vTcl:WidgetProc "Toplevel389" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel389" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button1" vTcl:WidgetProc "Toplevel389" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit76 \
        -ipad 2 -text {Output Directory} 
    vTcl:DefineAlias "$top.tit76" "TitleFrame2" vTcl:WidgetProc "Toplevel389" 1
    bind $top.tit76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit76 getframe]
    entry $site_4_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable SquintOutputDir 
    vTcl:DefineAlias "$site_4_0.cpd82" "Entry389_73" vTcl:WidgetProc "Toplevel389" 1
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame2" vTcl:WidgetProc "Toplevel389" 1
    set site_5_0 $site_4_0.cpd84
    button $site_5_0.cpd85 \
        \
        -command {global DirName DataDir SquintOutputDir

set SquintOutputDirTmp $SquintOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT MAIN DIRECTORY"
if {$DirName != "" } {
    set SquintOutputDir $DirName
    } else {
    set SquintOutputDir $SquintOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd85" "Button389_92" vTcl:WidgetProc "Toplevel389" 1
    bindtags $site_5_0.cpd85 "$site_5_0.cpd85 Button $top all _vTclBalloon"
    bind $site_5_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel389" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label389_01" vTcl:WidgetProc "Toplevel389" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry389_01" vTcl:WidgetProc "Toplevel389" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label389_02" vTcl:WidgetProc "Toplevel389" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry389_02" vTcl:WidgetProc "Toplevel389" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label389_03" vTcl:WidgetProc "Toplevel389" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry389_03" vTcl:WidgetProc "Toplevel389" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label389_04" vTcl:WidgetProc "Toplevel389" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry389_04" vTcl:WidgetProc "Toplevel389" 1
    pack $site_3_0.lab57 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent58 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab59 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent60 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab61 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent62 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab63 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 10 \
        -side left 
    pack $site_3_0.ent64 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd83 \
        -text {Azimut / Range Orientation} 
    vTcl:DefineAlias "$top.cpd83" "TitleFrame7" vTcl:WidgetProc "Toplevel389" 1
    bind $top.cpd83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd83 getframe]
    radiobutton $site_4_0.cpd80 \
        -text {Azimut = Row / Range = Col} -value 1 \
        -variable SquintAzimutFlag 
    vTcl:DefineAlias "$site_4_0.cpd80" "Radiobutton236" vTcl:WidgetProc "Toplevel389" 1
    radiobutton $site_4_0.cpd81 \
        -text {Azimut = Col / Range = Row} -value 0 \
        -variable SquintAzimutFlag 
    vTcl:DefineAlias "$site_4_0.cpd81" "Radiobutton237" vTcl:WidgetProc "Toplevel389" 1
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd73 \
        -text {Check Doppler Spectrum} 
    vTcl:DefineAlias "$top.cpd73" "TitleFrame5" vTcl:WidgetProc "Toplevel389" 1
    bind $top.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd73 getframe]
    button $site_4_0.but74 \
        -background #ffff00 \
        -command {global OpenDirFile SquintDirInput SquintAzimutFlag SquintCheck
global TMPRawSpectrumTxt TMPRawSpectrumBin TMPAvgSpectrumTxt TMPAvgSpectrumBin
global VarError ErrorMessage 
global GnuplotPipeFid GnuplotPipeSquint GnuSpectrumFile GnuSpectrumChannel
global GnuOutputFormat GnuOutputFile SpectrumOutputFile GnuSpectrumChannelId

if {$OpenDirFile == 0} {
$widget(Button389_1) configure -state disable
$widget(Button389_2) configure -state disable
$widget(Button389_3) configure -state disable
$widget(TitleFrame389_0) configure -state disable
$widget(Entry389_0) configure -state disable
$widget(Button389_4) configure -state disable
$widget(Button389_5) configure -state disable
$widget(Button389_6) configure -state disable
$widget(Radiobutton389_1) configure -state disable
$widget(Radiobutton389_2) configure -state disable
set GnuSpectrumFile " "
set GnuSpectrumChannel ""

DeleteFile $TMPRawSpectrumTxt
DeleteFile $TMPRawSpectrumBin
DeleteFile $TMPAvgSpectrumTxt
DeleteFile $TMPAvgSpectrumBin
set Fonction "CHECK THE SAR IMAGE DOPPLER SPECTRUM"
set Fonction2 ""
set ProgressLine "0"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
update
TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/sub_aperture_check_spectrum.exe" "k"
TextEditorRunTrace "Arguments: -id \x22$SquintDirInput\x22 -azf $SquintAzimutFlag -of1 \x22$TMPRawSpectrumTxt\x22 -of2 \x22$TMPRawSpectrumBin\x22 -of3 \x22$TMPAvgSpectrumTxt\x22 -of4 \x22$TMPAvgSpectrumBin\x22" "k"
set f [ open "| Soft/bin/data_process_sngl/sub_aperture_check_spectrum.exe -id \x22$SquintDirInput\x22 -azf $SquintAzimutFlag -of1 \x22$TMPRawSpectrumTxt\x22 -of2 \x22$TMPRawSpectrumBin\x22 -of3 \x22$TMPAvgSpectrumTxt\x22 -of4 \x22$TMPAvgSpectrumBin\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

set config ""
if [file exists $TMPRawSpectrumTxt] {set config "ok"}
if [file exists $TMPRawSpectrumBin] {append config "ok"}
if [file exists $TMPAvgSpectrumTxt] {append config "ok"}
if [file exists $TMPAvgSpectrumBin] {append config "ok"}
if {$config == "okokokok"} {
    set SquintCheck 1
    $widget(Button389_1) configure -state normal
    $widget(Button389_2) configure -state normal
    $widget(Button389_3) configure -state normal
    $widget(TitleFrame389_0) configure -state normal
    $widget(Entry389_0) configure -state normal
    $widget(Button389_4) configure -state normal
    $widget(Button389_5) configure -state normal
    $widget(Button389_6) configure -state normal
    $widget(Radiobutton389_1) configure -state normal
    $widget(Radiobutton389_2) configure -state normal
    set GnuOutputFormat "SCREEN"
    set GnuOutputFile ""
    set SpectrumOutputFile ""
    set GnuSpectrumChannelId "0"
    set GnuSpectrumFile "raw"
    }
}} \
        -padx 4 -pady 2 -text Check 
    vTcl:DefineAlias "$site_4_0.but74" "Button389_0" vTcl:WidgetProc "Toplevel389" 1
    frame $site_4_0.fra76 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra76" "Frame11" vTcl:WidgetProc "Toplevel389" 1
    set site_5_0 $site_4_0.fra76
    button $site_5_0.cpd77 \
        -background #ffff00 \
        -command {global GnuSpectrumChannelId

set GnuSpectrumChannelId 1
PlotSquint} \
        -padx 4 -pady 2 -text Plot 
    vTcl:DefineAlias "$site_5_0.cpd77" "Button389_1" vTcl:WidgetProc "Toplevel389" 1
    TitleFrame $site_5_0.tit71 \
        -text Channel 
    vTcl:DefineAlias "$site_5_0.tit71" "TitleFrame389_0" vTcl:WidgetProc "Toplevel389" 1
    bind $site_5_0.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.tit71 getframe]
    frame $site_7_0.fra74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra74" "Frame21" vTcl:WidgetProc "Toplevel389" 1
    set site_8_0 $site_7_0.fra74
    button $site_8_0.but75 \
        \
        -command {global GnuSpectrumChannelId

incr GnuSpectrumChannelId
#if {$GnuSpectrumChannelId == 6} {set GnuSpectrumChannelId 1}
if {$GnuSpectrumChannelId == 5} {set GnuSpectrumChannelId 1}

PlotSquint} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_8_0.but75" "Button389_4" vTcl:WidgetProc "Toplevel389" 1
    button $site_8_0.but76 \
        \
        -command {global GnuSpectrumChannelId

incr GnuSpectrumChannelId -1
#if {$GnuSpectrumChannelId == 0} {set GnuSpectrumChannelId 5}
if {$GnuSpectrumChannelId == 0} {set GnuSpectrumChannelId 4}

PlotSquint} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_8_0.but76" "Button389_5" vTcl:WidgetProc "Toplevel389" 1
    pack $site_8_0.but75 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    pack $site_8_0.but76 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side top 
    entry $site_7_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GnuSpectrumChannel -width 4 
    vTcl:DefineAlias "$site_7_0.cpd72" "Entry389_0" vTcl:WidgetProc "Toplevel389" 1
    pack $site_7_0.fra74 \
        -in $site_7_0 -anchor center -expand 1 -fill y -side left 
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    button $site_5_0.cpd73 \
        -background #ffff00 \
        -command {global ErrorMessage VarError VarSaveGnuPlotFile
global SaveDisplayDirOutput SquintDirOutput
global GnuplotPipeFid
global GnuSpectrumChannel GnuSpectrumFile
global SaveDisplayOutputFile1

#BMP_PROCESS
global Load_SaveDisplay1 PSPTopLevel

if {$GnuplotPipeFid == ""} {
    set ErrorMessage "GNUPLOT IS NOT RUNNING" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    } else {

    if {$Load_SaveDisplay1 == 0} {
        source "GUI/bmp_process/SaveDisplay1.tcl"
        set Load_SaveDisplay1 1
        WmTransient $widget(Toplevel456) $PSPTopLevel
        }

    set SaveDisplayDirOutput $SquintDirOutput

    if {$GnuSpectrumFile == "raw"} {
        if {$GnuSpectrumChannel == "s11"} {set SaveDisplayOutputFile1 "Raw_Spectrum_Channel_$GnuSpectrumChannel" }
        if {$GnuSpectrumChannel == "s12"} {set SaveDisplayOutputFile1 "Raw_Spectrum_Channel_$GnuSpectrumChannel" }
        if {$GnuSpectrumChannel == "s21"} {set SaveDisplayOutputFile1 "Raw_Spectrum_Channel_$GnuSpectrumChannel" }
        if {$GnuSpectrumChannel == "s22"} {set SaveDisplayOutputFile1 "Raw_Spectrum_Channel_$GnuSpectrumChannel" }
        #if {$GnuSpectrumChannel == "All"} {set SaveDisplayOutputFile1 "Raw_Spectrum_All_Channels" }
        }
    if {$GnuSpectrumFile == "avg"} {
        if {$GnuSpectrumChannel == "s11"} {set SaveDisplayOutputFile1 "Avg_Spectrum_Channel_$GnuSpectrumChannel" }
        if {$GnuSpectrumChannel == "s12"} {set SaveDisplayOutputFile1 "Avg_Spectrum_Channel_$GnuSpectrumChannel" }
        if {$GnuSpectrumChannel == "s21"} {set SaveDisplayOutputFile1 "Avg_Spectrum_Channel_$GnuSpectrumChannel" }
        if {$GnuSpectrumChannel == "s22"} {set SaveDisplayOutputFile1 "Avg_Spectrum_Channel_$GnuSpectrumChannel" }
        #if {$GnuSpectrumChannel == "All"} {set SaveDisplayOutputFile1 "Avg_Spectrum_All_Channels" }
        }
    set VarSaveGnuPlotFile ""
    WidgetShowFromWidget $widget(Toplevel389) $widget(Toplevel456); TextEditorRunTrace "Open Window Save Display 1" "b"
    tkwait variable VarSaveGnuPlotFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -padx 4 -pady 2 -text button 
    vTcl:DefineAlias "$site_5_0.cpd73" "Button389_2" vTcl:WidgetProc "Toplevel389" 1
    button $site_5_0.but66 \
        -background #ffffff \
        -command {global TMPGnuPlotTk1

Gimp $TMPGnuPlotTk1} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -pady 0 -text { } 
    vTcl:DefineAlias "$site_5_0.but66" "Button389_6" vTcl:WidgetProc "Toplevel389" 1
    button $site_5_0.cpd80 \
        -background #ffff00 \
        -command {global GnuplotPipeFid GnuplotPipeSquint

if {$GnuplotPipeSquint != ""} {
    catch "close $GnuplotPipeSquint"
    set GnuplotPipeSquint ""
    }
set GnuplotPipeFid ""
Window hide .top401} \
        -padx 4 -pady 2 -text Close 
    vTcl:DefineAlias "$site_5_0.cpd80" "Button389_3" vTcl:WidgetProc "Toplevel389" 1
    frame $site_5_0.cpd81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd81" "Frame5" vTcl:WidgetProc "Toplevel389" 1
    set site_6_0 $site_5_0.cpd81
    frame $site_6_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra90" "Frame8" vTcl:WidgetProc "Toplevel389" 1
    set site_7_0 $site_6_0.fra90
    radiobutton $site_7_0.cpd92 \
        -command PlotSquint -text {Raw Spectrum} -value raw \
        -variable GnuSpectrumFile 
    vTcl:DefineAlias "$site_7_0.cpd92" "Radiobutton389_1" vTcl:WidgetProc "Toplevel389" 1
    pack $site_7_0.cpd92 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd91" "Frame10" vTcl:WidgetProc "Toplevel389" 1
    set site_7_0 $site_6_0.cpd91
    radiobutton $site_7_0.cpd93 \
        -command PlotSquint -text {Avg Spectrum} -value avg \
        -variable GnuSpectrumFile 
    vTcl:DefineAlias "$site_7_0.cpd93" "Radiobutton389_2" vTcl:WidgetProc "Toplevel389" 1
    pack $site_7_0.cpd93 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.fra90 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side top 
    pack $site_6_0.cpd91 \
        -in $site_6_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.tit71 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but66 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd81 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.but74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra76 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side left 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel389" 1
    set site_3_0 $top.fra83
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CalibrationSquintCheck.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text ? -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel389" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile Load_SaveDisplay1
global GnuplotPipeFid GnuplotPipeSquint

if {$Load_SaveDisplay1 == 1} {Window hide $widget(Toplevel456); TextEditorRunTrace "Close Window Save Display 1" "b"}

if {$OpenDirFile == 0} {
if {$GnuplotPipeSquint != ""} {
    catch "close $GnuplotPipeSquint"
    set GnuplotPipeSquint ""
    }
set GnuplotPipeFid ""
Window hide .top401
Window hide $widget(Toplevel389); TextEditorRunTrace "Close Window Calibration - Squint Check Procedure" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel389" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.tit71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit76 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd83 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra83 \
        -in $top -anchor center -expand 1 -fill x -side top 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {exit}
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}
#############################################################################
## Binding tag:  _vTclBalloon


if {![info exists vTcl(sourcing)]} {
}

Window show .
Window show .top389

main $argc $argv
