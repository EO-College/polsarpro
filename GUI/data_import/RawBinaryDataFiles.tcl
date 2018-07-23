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

        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}

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
    set base .top232
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd74 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd74 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd120 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd75 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd121 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd76 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd76 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd122 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.but67 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent69 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top232
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
    wm geometry $top 200x200+88+88; update
    wm maxsize $top 1604 1185
    wm minsize $top 104 1
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

proc vTclWindow.top232 {base} {
    if {$base == ""} {
        set base .top232
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
    wm geometry $top 500x237+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "RawBinary Input Data Files"
    vTcl:DefineAlias "$top" "Toplevel232" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.cpd73 \
        -ipad 0 -text {Input Data File ( s11 )} 
    vTcl:DefineAlias "$top.cpd73" "TitleFrame232_1" vTcl:WidgetProc "Toplevel232" 1
    bind $top.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd73 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputRawData1 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry232_1" vTcl:WidgetProc "Toplevel232" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame25" vTcl:WidgetProc "Toplevel232" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global FileName RawBinaryDirInput RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput
global FileInputRawData1 FileInput1 FileInput5 FileInput9 FileInput13 RawBinaryDataPage

set types {
    {{All Files}        *        }
    }
set FileName ""

if {$RawBinaryDataPage == 1} {

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 modulus)"}
    }
if {$RawBinaryDataFormat == "SPP"} {
    if {$RawBinaryDataFormatPP == "PP1"} {
        if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11)"}
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 real)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 modulus)"}
        }
    if {$RawBinaryDataFormatPP == "PP2"} {
        if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22)"}
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 real)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 modulus)"}
        }
    if {$RawBinaryDataFormatPP == "PP3"} {
        if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11)"}
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 real)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 modulus)"}
        }
    }
if {$RawBinaryDataFormat == "IPP"} {
    if {$RawBinaryDataFormatPP == "PP5"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (I11)"}
    if {$RawBinaryDataFormatPP == "PP6"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (I22)"}
    if {$RawBinaryDataFormatPP == "PP7"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (I11)"}
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T11)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T11)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T11)"}
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T11)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T11)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T11)"}
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C11)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C11)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C11)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C11)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C11)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C11)"}
    }
}

if {$RawBinaryDataPage == 2} {

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s21 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s21 modulus)"}
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T23)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T13 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T13 phase)"}
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T22)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T13 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T13 phase)"}
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C23)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C13 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C13 phase)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C22)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C13 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C13 phase)"}
    }
}

if {$RawBinaryDataPage == 3} {

if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T33)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T33)"}
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T34)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T23 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T23 modulus)"}
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C33)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C33)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C34)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C23 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C23 modulus)"}
    }
}

if {$RawBinaryDataPage == 4} {

if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T33)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T33)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C33)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C33)"}
    }
}

set FileInputRawData1 $FileName
if {$RawBinaryDataPage == 1} { set FileInput1 $FileInputRawData1 }
if {$RawBinaryDataPage == 2} { set FileInput5 $FileInputRawData1 }
if {$RawBinaryDataPage == 3} { set FileInput9 $FileInputRawData1 }
if {$RawBinaryDataPage == 4} { set FileInput13 $FileInputRawData1 }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button232_1" vTcl:WidgetProc "Toplevel232" 1
    bindtags $site_5_0.cpd119 "$site_5_0.cpd119 Button $top all _vTclBalloon"
    bind $site_5_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd119 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd74 \
        -ipad 0 -text {Input Data File ( s12 )} 
    vTcl:DefineAlias "$top.cpd74" "TitleFrame232_2" vTcl:WidgetProc "Toplevel232" 1
    bind $top.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd74 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputRawData2 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry232_2" vTcl:WidgetProc "Toplevel232" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame26" vTcl:WidgetProc "Toplevel232" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd120 \
        \
        -command {global FileName RawBinaryDirInput RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput
global FileInputRawData2 FileInput2 FileInput6 FileInput10 FileInput14 RawBinaryDataPage

set types {
    {{All Files}        *        }
    }
set FileName ""

if {$RawBinaryDataPage == 1} {

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s12)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 phase)"}
    }
if {$RawBinaryDataFormat == "SPP"} {
    if {$RawBinaryDataFormatPP == "PP1"} {
        if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s21)"}
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 imag)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 phase)"}
        }
    if {$RawBinaryDataFormatPP == "PP2"} {
        if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s12)"}
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 imag)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 phase)"}
        }
    if {$RawBinaryDataFormatPP == "PP3"} {
        if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22)"}
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 imag)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s11 phase)"}
        }
    }
if {$RawBinaryDataFormat == "IPP"} {
    if {$RawBinaryDataFormatPP == "PP5"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (I21)"}
    if {$RawBinaryDataFormatPP == "PP6"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (I12)"}
    if {$RawBinaryDataFormatPP == "PP7"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (I22)"}
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T12)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T12 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T12 modulus)"}
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T12)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T12 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T12 modulus)"}
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C12)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C12 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C12 modulus)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C12)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C12 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C12 modulus)"}
    }
}

if {$RawBinaryDataPage == 2} {

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s21 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s21 phase)"}
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T33)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T22)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T22)"}
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T23)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T14 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T14 modulus)"}
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C33)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C22)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C22)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C23)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C14 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C14 modulus)"}
    }
}

if {$RawBinaryDataPage == 3} {

if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T44)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T23 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T23 phase)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C44)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C23 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C23 phase)"}
    }
}

if {$RawBinaryDataPage == 4} {

if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T34 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T34 modulus)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C34 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C34 modulus)"}
    }
}

set FileInputRawData2 $FileName
if {$RawBinaryDataPage == 1} { set FileInput2 $FileInputRawData2 }
if {$RawBinaryDataPage == 2} { set FileInput6 $FileInputRawData2 }
if {$RawBinaryDataPage == 3} { set FileInput10 $FileInputRawData2 }
if {$RawBinaryDataPage == 4} { set FileInput14 $FileInputRawData2 }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd120" "Button232_2" vTcl:WidgetProc "Toplevel232" 1
    bindtags $site_5_0.cpd120 "$site_5_0.cpd120 Button $top all _vTclBalloon"
    bind $site_5_0.cpd120 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd120 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd75 \
        -ipad 0 -text {Input Data File ( s21 )} 
    vTcl:DefineAlias "$top.cpd75" "TitleFrame232_3" vTcl:WidgetProc "Toplevel232" 1
    bind $top.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd75 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputRawData3 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry232_3" vTcl:WidgetProc "Toplevel232" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame27" vTcl:WidgetProc "Toplevel232" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd121 \
        \
        -command {global FileName RawBinaryDirInput RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput
global FileInputRawData3 FileInput3 FileInput7 FileInput11 FileInput15 RawBinaryDataPage

set types {
    {{All Files}        *        }
    }
set FileName ""

if {$RawBinaryDataPage == 1} {

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s21)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s12 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s12 modulus)"}
    }
if {$RawBinaryDataFormat == "SPP"} {
    if {$RawBinaryDataFormatPP == "PP1"} {
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s21 real)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s21 modulus)"}
        }
    if {$RawBinaryDataFormatPP == "PP2"} {
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s12 real)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s12 modulus)"}
        }
    if {$RawBinaryDataFormatPP == "PP3"} {
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 real)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 modulus)"}
        }
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T13)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T12 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T12 phase)"}
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T13)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T12 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T12 phase)"}
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C13)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C12 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C12 phase)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C13)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C12 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C12 phase)"}
    }
}

if {$RawBinaryDataPage == 2} {

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 modulus)"}
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T23 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T23 modulus)"}
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T24)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T14 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T14 phase)"}
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C23 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C23 modulus)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C24)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C14 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C14 phase)"}
    }
}

if {$RawBinaryDataPage == 3} {

if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T24 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T24 modulus)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C24 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C24 modulus)"}
    }
}

if {$RawBinaryDataPage == 4} {

if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T34 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T34 phase)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C34 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C34 phase)"}
    }
}

set FileInputRawData3 $FileName
if {$RawBinaryDataPage == 1} { set FileInput3 $FileInputRawData3 }
if {$RawBinaryDataPage == 2} { set FileInput7 $FileInputRawData3 }
if {$RawBinaryDataPage == 3} { set FileInput11 $FileInputRawData3 }
if {$RawBinaryDataPage == 4} { set FileInput15 $FileInputRawData3 }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd121" "Button232_3" vTcl:WidgetProc "Toplevel232" 1
    bindtags $site_5_0.cpd121 "$site_5_0.cpd121 Button $top all _vTclBalloon"
    bind $site_5_0.cpd121 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd121 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $top.cpd76 \
        -ipad 0 -text {Input Data File ( s22 )} 
    vTcl:DefineAlias "$top.cpd76" "TitleFrame232_4" vTcl:WidgetProc "Toplevel232" 1
    bind $top.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd76 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputRawData4 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry232_4" vTcl:WidgetProc "Toplevel232" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame28" vTcl:WidgetProc "Toplevel232" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd122 \
        \
        -command {global FileName RawBinaryDirInput RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput
global FileInputRawData4 FileInput4 FileInput8 FileInput12 FileInput16 RawBinaryDataPage

set types {
    {{All Files}        *        }
    }
set FileName ""

if {$RawBinaryDataPage == 1} {

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s12 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s12 phase)"}
    }
if {$RawBinaryDataFormat == "SPP"} {
    if {$RawBinaryDataFormatPP == "PP1"} {
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s21 imag)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s21 phase)"}
        }
    if {$RawBinaryDataFormatPP == "PP2"} {
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s12 imag)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s12 phase)"}
        }
    if {$RawBinaryDataFormatPP == "PP3"} {
        if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 imag)"}
        if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 phase)"}
        }
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T22)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T13 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T13 modulus)"}
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T14)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T13 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T13 modulus)"}
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C22)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C13 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C13 modulus)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C13)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C13 real)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C13 modulus)"}
    }
}

if {$RawBinaryDataPage == 2} {

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (s22 phase)"}
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T23 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T23 phase)"}
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T33)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T22)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T22)"}
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C23 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C23 phase)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C33)"}
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C22)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C22)"}
    }
}

if {$RawBinaryDataPage == 3} {

if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T24 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T24 phase)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C24 imag)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C24 phase)"}
    }
}

if {$RawBinaryDataPage == 4} {

if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T44)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (T44)"}
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "RealImag"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C44)"}
    if {$RawBinaryDataInput == "ModPha"} {OpenFile $RawBinaryDirInput $types "INPUT FILE (C44)"}
    }
}

set FileInputRawData4 $FileName
if {$RawBinaryDataPage == 1} { set FileInput4 $FileInputRawData4 }
if {$RawBinaryDataPage == 2} { set FileInput8 $FileInputRawData4 }
if {$RawBinaryDataPage == 3} { set FileInput12 $FileInputRawData4 }
if {$RawBinaryDataPage == 4} { set FileInput16 $FileInputRawData4 }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd122" "Button232_4" vTcl:WidgetProc "Toplevel232" 1
    bindtags $site_5_0.cpd122 "$site_5_0.cpd122 Button $top all _vTclBalloon"
    bind $site_5_0.cpd122 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd122 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $top.fra66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame1" vTcl:WidgetProc "Toplevel232" 1
    set site_3_0 $top.fra66
    button $site_3_0.but67 \
        -background #ffff00 \
        -command {global RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput
global RawBinaryDataPage RawBinaryDataPageMax RawBinaryDataPageCurrent PSPBackgroundColor
global FileInputRawData1 FileInputRawData2 FileInputRawData3 FileInputRawData4
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6 FileInput7 FileInput8
global FileInput9 FileInput10 FileInput11 FileInput12 FileInput13 FileInput14 FileInput15 FileInput16

set RawBinaryDataPage [expr  $RawBinaryDataPage - 1]
if {$RawBinaryDataPage < 1 } { set RawBinaryDataPage $RawBinaryDataPageMax }

set RawBinaryDataPageCurrent "$RawBinaryDataPage / $RawBinaryDataPageMax"

if {$RawBinaryDataPage == 1} {
    set FileInputRawData1 $FileInput1
    set FileInputRawData2 $FileInput2
    set FileInputRawData3 $FileInput3
    set FileInputRawData4 $FileInput4
}
if {$RawBinaryDataPage == 2} {
    set FileInputRawData1 $FileInput5
    set FileInputRawData2 $FileInput6
    set FileInputRawData3 $FileInput7
    set FileInputRawData4 $FileInput8
}
if {$RawBinaryDataPage == 3} {
    set FileInputRawData1 $FileInput9
    set FileInputRawData2 $FileInput10
    set FileInputRawData3 $FileInput11
    set FileInputRawData4 $FileInput12
}
if {$RawBinaryDataPage == 4} {
    set FileInputRawData1 $FileInput13
    set FileInputRawData2 $FileInput14
    set FileInputRawData3 $FileInput15
    set FileInputRawData4 $FileInput16
}

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s21)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22)"
            }
        }
    if {$RawBinaryDataInput == "RealImag"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 real)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 imag)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 imag)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s21 real)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s21 imag)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s22 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22 imag)"
            }
        }
    if {$RawBinaryDataInput == "ModPha"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 mod)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 phase)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 phase)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s21 mod)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s21 phase)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s22 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22 phase)"
            }
        }
    }
if {$RawBinaryDataFormat == "SPP"} {
    if {$RawBinaryDataFormatPP == "PP1"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s21)"
                .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
                .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
                }
            }
        if {$RawBinaryDataInput == "RealImag"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 real)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 imag)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s21 real)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s21 imag)"
                }
            }
        if {$RawBinaryDataInput == "ModPha"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 mod)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 phase)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s21 mod)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s21 phase)"
                }
            }
        }
    if {$RawBinaryDataFormatPP == "PP2"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s22)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s12)"
                .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
                .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
                }
            }
        if {$RawBinaryDataInput == "RealImag"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s22 real)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s22 imag)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 real)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 imag)"
                }
            }
        if {$RawBinaryDataInput == "ModPha"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s22 mod)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s22 phase)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 mod)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 phase)"
                }
            }
        }
    if {$RawBinaryDataFormatPP == "PP3"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s22)"
                .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
                .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
                }
            }
        if {$RawBinaryDataInput == "RealImag"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 real)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 imag)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s22 real)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22 imag)"
                }
            }
        if {$RawBinaryDataInput == "ModPha"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 mod)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 phase)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s22 mod)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22 phase)"
                }
            }
        }
    }
if {$RawBinaryDataFormat == "IPP"} {
    if {$RawBinaryDataFormatPP == "PP5"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (I11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (I21)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataFormatPP == "PP6"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (I22)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (I12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataFormatPP == "PP7"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (I11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (I22)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T13)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T22)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T23)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T33)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "RealImag"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 real)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T13 imag)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T22)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T23 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T23 imag)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd74.f.cpd91.cpd120 configure -state disable; .top232.cpd74 configure -text ""
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "ModPha"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 mod)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T13 phase)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T22)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T23 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T23 phase)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd74.f.cpd91.cpd120 configure -state disable; .top232.cpd74 configure -text ""
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T13)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T14)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T22)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T23)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T24)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T33)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T34)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T44)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "RealImag"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 real)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T13 imag)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T14 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T14 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T22)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T23 real)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T23 imag)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T24 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T24 imag)"
            }
        if {$RawBinaryDataPage == 4} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T34 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T34 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T44)"
            }
        }
    if {$RawBinaryDataInput == "ModPha"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 mod)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T13 phase)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T14 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T14 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T22)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T23 mod)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T23 phase)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T24 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T24 phase)"
            }
        if {$RawBinaryDataPage == 4} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T34 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T34 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T44)"
            }
        }
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C13)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C22)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C23)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C33)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "RealImag"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 real)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C13 imag)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C22)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C23 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C23 imag)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd74.f.cpd91.cpd120 configure -state disable; .top232.cpd74 configure -text ""
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "ModPha"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 mod)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C13 phase)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C22)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C23 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C23 phase)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd74.f.cpd91.cpd120 configure -state disable; .top232.cpd74 configure -text ""
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C13)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C14)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C22)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C23)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C24)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C33)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C34)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C44)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "RealImag"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 real)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C13 imag)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C14 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C14 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C22)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C23 real)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C23 imag)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C24 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C24 imag)"
            }
        if {$RawBinaryDataPage == 4} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C34 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C34 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C44)"
            }
        }
    if {$RawBinaryDataInput == "ModPha"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 mod)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C13 imag)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C14 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C14 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C22)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C23 mod)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C23 phase)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C24 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C24 phase)"
            }
        if {$RawBinaryDataPage == 4} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C34 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C34 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C44)"
            }
        }
    }} \
        -padx 4 -pady 2 -text {Previous Page} 
    vTcl:DefineAlias "$site_3_0.but67" "Button232_11" vTcl:WidgetProc "Toplevel232" 1
    entry $site_3_0.ent69 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable RawBinaryDataPageCurrent -width 5 
    vTcl:DefineAlias "$site_3_0.ent69" "Entry1" vTcl:WidgetProc "Toplevel232" 1
    button $site_3_0.cpd68 \
        -background #ffff00 \
        -command {global RawBinaryDataFormat RawBinaryDataFormatPP RawBinaryDataInput
global RawBinaryDataPage RawBinaryDataPageMax RawBinaryDataPageCurrent PSPBackgroundColor
global FileInputRawData1 FileInputRawData2 FileInputRawData3 FileInputRawData4
global FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6 FileInput7 FileInput8
global FileInput9 FileInput10 FileInput11 FileInput12 FileInput13 FileInput14 FileInput15 FileInput16

set RawBinaryDataPage [expr  $RawBinaryDataPage + 1]
if {$RawBinaryDataPage > $RawBinaryDataPageMax} { set RawBinaryDataPage 1 }

set RawBinaryDataPageCurrent "$RawBinaryDataPage / $RawBinaryDataPageMax"

if {$RawBinaryDataPage == 1} {
    set FileInputRawData1 $FileInput1
    set FileInputRawData2 $FileInput2
    set FileInputRawData3 $FileInput3
    set FileInputRawData4 $FileInput4
}
if {$RawBinaryDataPage == 2} {
    set FileInputRawData1 $FileInput5
    set FileInputRawData2 $FileInput6
    set FileInputRawData3 $FileInput7
    set FileInputRawData4 $FileInput8
}
if {$RawBinaryDataPage == 3} {
    set FileInputRawData1 $FileInput9
    set FileInputRawData2 $FileInput10
    set FileInputRawData3 $FileInput11
    set FileInputRawData4 $FileInput12
}
if {$RawBinaryDataPage == 4} {
    set FileInputRawData1 $FileInput13
    set FileInputRawData2 $FileInput14
    set FileInputRawData3 $FileInput15
    set FileInputRawData4 $FileInput16
}

if {$RawBinaryDataFormat == "S2"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s21)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22)"
            }
        }
    if {$RawBinaryDataInput == "RealImag"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 real)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 imag)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 imag)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s21 real)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s21 imag)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s22 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22 imag)"
            }
        }
    if {$RawBinaryDataInput == "ModPha"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 mod)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 phase)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 phase)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s21 mod)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s21 phase)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s22 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22 phase)"
            }
        }
    }
if {$RawBinaryDataFormat == "SPP"} {
    if {$RawBinaryDataFormatPP == "PP1"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s21)"
                .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
                .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
                }
            }
        if {$RawBinaryDataInput == "RealImag"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 real)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 imag)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s21 real)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s21 imag)"
                }
            }
        if {$RawBinaryDataInput == "ModPha"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 mod)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 phase)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s21 mod)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s21 phase)"
                }
            }
        }
    if {$RawBinaryDataFormatPP == "PP2"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s22)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s12)"
                .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
                .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
                }
            }
        if {$RawBinaryDataInput == "RealImag"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s22 real)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s22 imag)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 real)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 imag)"
                }
            }
        if {$RawBinaryDataInput == "ModPha"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s22 mod)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s22 phase)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s12 mod)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s12 phase)"
                }
            }
        }
    if {$RawBinaryDataFormatPP == "PP3"} {
        if {$RawBinaryDataInput == "Cmplx"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s22)"
                .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
                .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
                .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
                }
            }
        if {$RawBinaryDataInput == "RealImag"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 real)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 imag)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s22 real)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22 imag)"
                }
            }
        if {$RawBinaryDataInput == "ModPha"} {
            if {$RawBinaryDataPage == 1} {
                .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (s11 mod)"
                .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (s11 phase)"
                .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (s22 mod)"
                .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
                .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (s22 phase)"
                }
            }
        }
    }
if {$RawBinaryDataFormat == "IPP"} {
    if {$RawBinaryDataFormatPP == "PP5"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (I11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (I21)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataFormatPP == "PP6"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (I22)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (I12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataFormatPP == "PP7"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (I11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (I22)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    }
if {$RawBinaryDataFormat == "T3"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T13)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T22)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T23)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T33)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "RealImag"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 real)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T13 imag)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T22)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T23 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T23 imag)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd74.f.cpd91.cpd120 configure -state disable; .top232.cpd74 configure -text ""
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "ModPha"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 mod)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T13 phase)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T22)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T23 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T23 phase)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd74.f.cpd91.cpd120 configure -state disable; .top232.cpd74 configure -text ""
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    }
if {$RawBinaryDataFormat == "T4"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T13)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T14)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T22)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T23)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T24)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T33)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T34)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T44)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "RealImag"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 real)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T13 imag)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T14 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T14 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T22)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T23 real)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T23 imag)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T24 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T24 imag)"
            }
        if {$RawBinaryDataPage == 4} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T34 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T34 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T44)"
            }
        }
    if {$RawBinaryDataInput == "ModPha"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T12 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T12 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T13 mod)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T13 phase)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T14 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T14 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T22)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T23 mod)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T23 phase)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T24 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T24 phase)"
            }
        if {$RawBinaryDataPage == 4} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (T33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (T34 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (T34 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (T44)"
            }
        }
    }
if {$RawBinaryDataFormat == "C3"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C13)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C22)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C23)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C33)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "RealImag"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 real)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C13 imag)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C22)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C23 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C23 imag)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd74.f.cpd91.cpd120 configure -state disable; .top232.cpd74 configure -text ""
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "ModPha"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 mod)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C13 phase)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C22)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C23 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C23 phase)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd74.f.cpd91.cpd120 configure -state disable; .top232.cpd74 configure -text ""
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    }
if {$RawBinaryDataFormat == "C4"} {
    if {$RawBinaryDataInput == "Cmplx"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C13)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C14)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C22)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C23)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C24)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C33)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C34)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C44)"
            .top232.cpd75.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd75.f.cpd91.cpd121 configure -state disable; .top232.cpd75 configure -text ""
            .top232.cpd76.f.cpd85 configure -disabledbackground $PSPBackgroundColor
            .top232.cpd76.f.cpd91.cpd122 configure -state disable; .top232.cpd76 configure -text ""
            }
        }
    if {$RawBinaryDataInput == "RealImag"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 real)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C13 imag)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C14 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C14 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C22)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C23 real)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C23 imag)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C24 real)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C24 imag)"
            }
        if {$RawBinaryDataPage == 4} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C34 real)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C34 imag)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C44)"
            }
        }
    if {$RawBinaryDataInput == "ModPha"} {
        if {$RawBinaryDataPage == 1} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C11)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C12 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C12 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C13 mod)"
            }
        if {$RawBinaryDataPage == 2} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C13 imag)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C14 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C14 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C22)"
            }
        if {$RawBinaryDataPage == 3} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C23 mod)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C23 phase)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C24 mod)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C24 phase)"
            }
        if {$RawBinaryDataPage == 4} {
            .top232.cpd73.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd73.f.cpd91.cpd119 configure -state normal; .top232.cpd73 configure -text "Input Data File (C33)"
            .top232.cpd74.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd74.f.cpd91.cpd120 configure -state normal; .top232.cpd74 configure -text "Input Data File (C34 mod)"
            .top232.cpd75.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd75.f.cpd91.cpd121 configure -state normal; .top232.cpd75 configure -text "Input Data File (C34 phase)"
            .top232.cpd76.f.cpd85 configure -disabledbackground #FFFFFF
            .top232.cpd76.f.cpd91.cpd122 configure -state normal; .top232.cpd76 configure -text "Input Data File (C44)"
            }
        }
    }} \
        -padx 4 -pady 2 -text {   Next Page   } 
    vTcl:DefineAlias "$site_3_0.cpd68" "Button232_10" vTcl:WidgetProc "Toplevel232" 1
    pack $site_3_0.but67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 20 -side left 
    pack $site_3_0.ent69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 20 -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd76 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 1 -fill none -side top 

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
Window show .top232

main $argc $argv
