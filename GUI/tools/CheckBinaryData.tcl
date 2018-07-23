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

        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images FixingErrorOff.gif]} {user image} user {}}

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
    set base .top316
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd79
    namespace eval ::widgets::$site_3_0.cpd97 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd87 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd82
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.fra28 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra28
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit81 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra71
    namespace eval ::widgets::$site_5_0.rad114 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra92
    namespace eval ::widgets::$site_6_0.cpd93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd93
    namespace eval ::widgets::$site_7_0.lab89 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd94
    namespace eval ::widgets::$site_7_0.lab89 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd95
    namespace eval ::widgets::$site_7_0.lab89 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd96 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd96
    namespace eval ::widgets::$site_6_0.cpd93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd93
    namespace eval ::widgets::$site_7_0.rad97 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd94
    namespace eval ::widgets::$site_7_0.cpd98 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd95
    namespace eval ::widgets::$site_7_0.cpd99 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd100 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd100
    namespace eval ::widgets::$site_6_0.cpd93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd93
    namespace eval ::widgets::$site_7_0.rad97 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd94
    namespace eval ::widgets::$site_7_0.cpd98 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd95
    namespace eval ::widgets::$site_7_0.cpd99 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd101 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd101
    namespace eval ::widgets::$site_6_0.cpd93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd93
    namespace eval ::widgets::$site_7_0.rad97 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd95
    namespace eval ::widgets::$site_7_0.cpd99 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra72
    namespace eval ::widgets::$site_5_0.cpd115 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra102 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra102
    namespace eval ::widgets::$site_6_0.fra103 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra103
    namespace eval ::widgets::$site_7_0.cpd105 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd106 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd104 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd104
    namespace eval ::widgets::$site_7_0.rad107 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd109 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd110 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra111 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra111
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd112 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab73 {
        array set save {-image 1}
    }
    namespace eval ::widgets::$base.fra42 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra42
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.m102 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top316
            CheckDataCovariance
            CheckDataIntensity
            CheckDataSinclair
            CheckDataCoherency
            CheckDataFile
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
## Procedure:  CheckDataCovariance

proc ::CheckDataCovariance {CheckDir} {
global TMPCheckBinaryData TMPDirectory
global OpenDirFile CheckResult CheckFile
global Fonction Fonction2 ProgressLine
global ErrorMessage QuestionMessage VarQuestion VarError
global OffsetLig OffsetCol FinalNlig FinalNcol

if {$OpenDirFile == 0} {

set BinFile(0) 0
set BinFile(1) "C11"
set BinFile(2) "C12_real"; set BinFile(3) "C12_imag"
set BinFile(4) "C13_real"; set BinFile(5) "C13_imag"
set BinFile(6) "C14_real"; set BinFile(7) "C14_imag"
set BinFile(8) "C22"
set BinFile(9) "C23_real"; set BinFile(10) "C23_imag"
set BinFile(11) "C24_real"; set BinFile(12) "C24_imag"
set BinFile(13) "C33"
set BinFile(14) "C34_real"; set BinFile(15) "C34_imag"
set BinFile(16) "C44"
set NBinFile 17 

image create photo ImageFixError
ImageFixError blank
set cc .top316.fra111.lab73

for {set i 1} {$i < $NBinFile} {incr i} {
    set BinFileName "$CheckDir/$BinFile($i).bin"
    if [file exists $BinFileName] {
        image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOff.gif"
        $cc configure -image ImageFixError
        set CheckResult ""; set CheckFile $BinFile($i)
        set Fonction "Check the Raw Binary Data File"
        set Fonction2 $BinFileName
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/tools/check_data_file_float.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" "k"
        set f [ open "| Soft/tools/check_data_file_float.exe -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set ErrorMessage ""
        if [file exists $TMPCheckBinaryData] {
            set f [open $TMPCheckBinaryData r]
            gets $f CheckResult
            close $f
            if {$CheckResult != "No NaN or Infinity Detected"} {
                set QuestionMessage "DO YOU WANT TO FIX THE DATA ERROR ?"
                set VarQuestion ""
                Window show .top45; TextEditorRunTrace "Open Window Question" "b"
                tkwait variable VarQuestion
                if {$VarQuestion == "ok"} {
                    image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOn.gif"
                    $cc configure -image ImageFixError
                    set TmpBinFileName "$TMPDirectory/$BinFile($i).bin"
                    set Fonction "Repair the Raw Binary Data File"
                    set Fonction2 $BinFileName
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/tools/repair_data_file_float.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpBinFileName\x22" "k"
                    set f [ open "| Soft/tools/repair_data_file_float.exe -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpBinFileName\x22" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    if [file exists $TmpBinFileName] {
                        set copyerror [file copy -force -- $TmpBinFileName $BinFileName]
                        }
                    image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOff.gif"
                    $cc configure -image ImageFixError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    }
                Window hide .top45; TextEditorRunTrace "Close Window Question" "b"                 }
            } else {
            set ErrorMessage "BINARY DATA CHECKING ERROR"
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        }  
    }
}   
            
}
#############################################################################
## Procedure:  CheckDataIntensity

proc ::CheckDataIntensity {CheckDir} {
global TMPCheckBinaryData TMPDirectory
global OpenDirFile CheckResult CheckFile
global Fonction Fonction2 ProgressLine
global ErrorMessage QuestionMessage VarQuestion VarError
global OffsetLig OffsetCol FinalNlig FinalNcol

if {$OpenDirFile == 0} {

set BinFile(0) 0
set BinFile(1) "I11"; set BinFile(2) "I12"; set BinFile(3) "I21"; set BinFile(4) "I22"
set NBinFile 5 

image create photo ImageFixError
ImageFixError blank
set cc .top316.fra111.lab73

for {set i 1} {$i < $NBinFile} {incr i} {
    set BinFileName "$CheckDir/$BinFile($i).bin"
    if [file exists $BinFileName] {
        image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOff.gif"
        $cc configure -image ImageFixError
        set CheckResult ""; set CheckFile $BinFile($i)
        set Fonction "Check the Raw Binary Data File"
        set Fonction2 $BinFileName
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/tools/check_data_file_float.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" "k"
        set f [ open "| Soft/tools/check_data_file_float.exe -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set ErrorMessage ""
        if [file exists $TMPCheckBinaryData] {
            set f [open $TMPCheckBinaryData r]
            gets $f CheckResult
            close $f
            if {$CheckResult != "No NaN or Infinity Detected"} {
                set QuestionMessage "DO YOU WANT TO FIX THE DATA ERROR ?"
                set VarQuestion ""
                Window show .top45; TextEditorRunTrace "Open Window Question" "b"
                tkwait variable VarQuestion
                if {$VarQuestion == "ok"} {
                    image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOn.gif"
                    $cc configure -image ImageFixError
                    set TmpBinFileName "$TMPDirectory/$BinFile($i).bin"
                    set Fonction "Repair the Raw Binary Data File"
                    set Fonction2 $BinFileName
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/tools/repair_data_file_float.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpBinFileName\x22" "k"
                    set f [ open "| Soft/tools/repair_data_file_float.exe -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpBinFileName\x22" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    if [file exists $TmpBinFileName] {
                        set copyerror [file copy -force -- $TmpBinFileName $BinFileName]
                        }
                    image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOff.gif"
                    $cc configure -image ImageFixError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    }
                Window hide .top45; TextEditorRunTrace "Close Window Question" "b"                 }
            } else {
            set ErrorMessage "BINARY DATA CHECKING ERROR"
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        }  
    }
}   
            
}
#############################################################################
## Procedure:  CheckDataSinclair

proc ::CheckDataSinclair {CheckDir} {
global TMPCheckBinaryData TMPDirectory
global OpenDirFile CheckResult CheckFile
global Fonction Fonction2 ProgressLine
global ErrorMessage QuestionMessage VarQuestion VarError
global OffsetLig OffsetCol FinalNlig FinalNcol

if {$OpenDirFile == 0} {

set BinFile(0) 0
set BinFile(1) "s11"; set BinFile(2) "s12"; set BinFile(3) "s21"; set BinFile(4) "s22"
set NBinFile 5 

image create photo ImageFixError
ImageFixError blank
set cc .top316.fra111.lab73

for {set i 1} {$i < $NBinFile} {incr i} {
    set BinFileName "$CheckDir/$BinFile($i).bin"
    if [file exists $BinFileName] {
        image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOff.gif"
        $cc configure -image ImageFixError
        set CheckResult ""; set CheckFile $BinFile($i)
        set Fonction "Check the Raw Binary Data File"
        set Fonction2 $BinFileName
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/tools/check_data_file_cmplx.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" "k"
        set f [ open "| Soft/tools/check_data_file_cmplx.exe -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set ErrorMessage ""
        if [file exists $TMPCheckBinaryData] {
            set f [open $TMPCheckBinaryData r]
            gets $f CheckResult
            close $f
            if {$CheckResult != "No NaN or Infinity Detected"} {
                set QuestionMessage "DO YOU WANT TO FIX THE DATA ERROR ?"
                set VarQuestion ""
                Window show .top45; TextEditorRunTrace "Open Window Question" "b"
                tkwait variable VarQuestion
                if {$VarQuestion == "ok"} {
                    image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOn.gif"
                    $cc configure -image ImageFixError
                    set TmpBinFileName "$TMPDirectory/$BinFile($i).bin"
                    set Fonction "Repair the Raw Binary Data File"
                    set Fonction2 $BinFileName
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/tools/repair_data_file_cmplx.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpBinFileName\x22" "k"
                    set f [ open "| Soft/tools/repair_data_file_cmplx.exe -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpBinFileName\x22" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    if [file exists $TmpBinFileName] {
                        set copyerror [file copy -force -- $TmpBinFileName $BinFileName]
                        }
                    image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOff.gif"
                    $cc configure -image ImageFixError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    }
                Window hide .top45; TextEditorRunTrace "Close Window Question" "b"                 }
            } else {
            set ErrorMessage "BINARY DATA CHECKING ERROR"
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        }  
    }
}   
            
}
#############################################################################
## Procedure:  CheckDataCoherency

proc ::CheckDataCoherency {CheckDir} {
global TMPCheckBinaryData TMPDirectory
global OpenDirFile CheckResult CheckFile
global Fonction Fonction2 ProgressLine
global ErrorMessage QuestionMessage VarQuestion VarError
global OffsetLig OffsetCol FinalNlig FinalNcol

if {$OpenDirFile == 0} {

set BinFile(0) 0
set BinFile(1) "T11"
set BinFile(2) "T12_real"; set BinFile(3) "T12_imag"
set BinFile(4) "T13_real"; set BinFile(5) "T13_imag"
set BinFile(6) "T14_real"; set BinFile(7) "T14_imag"
set BinFile(8) "T22"
set BinFile(9) "T23_real"; set BinFile(10) "T23_imag"
set BinFile(11) "T24_real"; set BinFile(12) "T24_imag"
set BinFile(13) "T33"
set BinFile(14) "T34_real"; set BinFile(15) "T34_imag"
set BinFile(16) "T44"
set NBinFile 17 

image create photo ImageFixError
ImageFixError blank
set cc .top316.fra111.lab73

for {set i 1} {$i < $NBinFile} {incr i} {
    set BinFileName "$CheckDir/$BinFile($i).bin"
    if [file exists $BinFileName] {
        image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOff.gif"
        $cc configure -image ImageFixError
        set CheckResult ""; set CheckFile $BinFile($i)
        set Fonction "Check the Raw Binary Data File"
        set Fonction2 $BinFileName
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/tools/check_data_file_float.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" "k"
        set f [ open "| Soft/tools/check_data_file_float.exe -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set ErrorMessage ""
        if [file exists $TMPCheckBinaryData] {
            set f [open $TMPCheckBinaryData r]
            gets $f CheckResult
            close $f
            if {$CheckResult != "No NaN or Infinity Detected"} {
                set QuestionMessage "DO YOU WANT TO FIX THE DATA ERROR ?"
                set VarQuestion ""
                Window show .top45; TextEditorRunTrace "Open Window Question" "b"
                tkwait variable VarQuestion
                if {$VarQuestion == "ok"} {
                    image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOn.gif"
                    $cc configure -image ImageFixError
                    set TmpBinFileName "$TMPDirectory/$BinFile($i).bin"
                    set Fonction "Repair the Raw Binary Data File"
                    set Fonction2 $BinFileName
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/tools/repair_data_file_float.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpBinFileName\x22" "k"
                    set f [ open "| Soft/tools/repair_data_file_float.exe -if \x22$BinFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpBinFileName\x22" r]
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    if [file exists $TmpBinFileName] {
                        set copyerror [file copy -force -- $TmpBinFileName $BinFileName]
                        }
                    image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOff.gif"
                    $cc configure -image ImageFixError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                    }
                Window hide .top45; TextEditorRunTrace "Close Window Question" "b"                 }
            } else {
            set ErrorMessage "BINARY DATA CHECKING ERROR"
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        }  
    }
}   
            
}
#############################################################################
## Procedure:  CheckDataFile

proc ::CheckDataFile {} {
global TMPCheckBinaryData TMPDirectory
global OpenDirFile CheckResult CheckFileName CheckType
global Fonction Fonction2 ProgressLine
global ErrorMessage QuestionMessage VarQuestion VarError
global OffsetLig OffsetCol FinalNlig FinalNcol

if {$OpenDirFile == 0} {

image create photo ImageFixError
ImageFixError blank
set cc .top316.fra111.lab73

if [file exists $CheckFileName] {
    image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOff.gif"
    $cc configure -image ImageFixError
    set CheckResult "";
    set Fonction "Check the Raw Binary Data File"
    set Fonction2 $CheckFileName
    set ProgressLine "0"
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    update
    if {$CheckType == "Float"} {    
        TextEditorRunTrace "Process The Function Soft/tools/check_data_file_float.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" "k"
        set f [ open "| Soft/tools/check_data_file_float.exe -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" r]
        }
    if {$CheckType == "Cmplx"} {    
        TextEditorRunTrace "Process The Function Soft/tools/check_data_file_cmplx.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" "k"
        set f [ open "| Soft/tools/check_data_file_cmplx.exe -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" r]
        }
    if {$CheckType == "Int"} {    
        TextEditorRunTrace "Process The Function Soft/tools/check_data_file_int.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" "k"
        set f [ open "| Soft/tools/check_data_file_int.exe -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TMPCheckBinaryData\x22" r]
        }
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

    set ErrorMessage ""
    if [file exists $TMPCheckBinaryData] {
        set f [open $TMPCheckBinaryData r]
        gets $f CheckResult
        close $f
        if {$CheckResult != "No NaN or Infinity Detected"} {
            set QuestionMessage "DO YOU WANT TO FIX THE DATA ERROR ?"
            set VarQuestion ""
            Window show .top45; TextEditorRunTrace "Open Window Question" "b"
            tkwait variable VarQuestion
            if {$VarQuestion == "ok"} {
                image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOn.gif"
                $cc configure -image ImageFixError
                set TmpFileName "$TMPDirectory/TmpCheckFileName.bin"
                set Fonction "Repair the Raw Binary Data File"
                set Fonction2 $CheckFileName
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                if {$CheckType == "Float"} {    
                    TextEditorRunTrace "Process The Function Soft/tools/repair_data_file_float.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpFileName\x22" "k"
                    set f [ open "| Soft/tools/repair_data_file_float.exe -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpFileName\x22" r]
                    }
                if {$CheckType == "Cmplx"} {    
                    TextEditorRunTrace "Process The Function Soft/tools/repair_data_file_cmplx.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpFileName\x22" "k"
                    set f [ open "| Soft/tools/repair_data_file_cmplx.exe -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpFileName\x22" r]
                    }
                if {$CheckType == "Int"} {    
                    TextEditorRunTrace "Process The Function Soft/tools/repair_data_file_int.exe" "k"
                    TextEditorRunTrace "Arguments: -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpFileName\x22" "k"
                    set f [ open "| Soft/tools/repair_data_file_int.exe -if \x22$CheckFileName\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -of \x22$TmpFileName\x22" r]
                    }
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                if [file exists $TmpFileName] {
                    set copyerror [file copy -force -- $TmpFileName $CheckFileName]
                    }
                image delete ImageFixError; image create photo ImageFixError -file "GUI/Images/FixingErrorOff.gif"
                $cc configure -image ImageFixError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                }
            Window hide .top45; TextEditorRunTrace "Close Window Question" "b"                 }
        } else {
        set ErrorMessage "BINARY DATA CHECKING ERROR"
        Window show .top44; TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }  
}
   
            
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
    wm geometry $top 200x200+22+22; update
    wm maxsize $top 1284 785
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

proc vTclWindow.top316 {base} {
    if {$base == ""} {
        set base .top316
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
    wm geometry $top 500x310+160+100; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Check Binary Data"
    vTcl:DefineAlias "$top" "Toplevel316" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame4" vTcl:WidgetProc "Toplevel316" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel316" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CheckInputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel316" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel316" 1
    set site_6_0 $site_5_0.cpd92
    label $site_6_0.cpd85 \
        -text { / } 
    vTcl:DefineAlias "$site_6_0.cpd85" "Label1" vTcl:WidgetProc "Toplevel316" 1
    entry $site_6_0.cpd87 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckInputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd87" "Entry1" vTcl:WidgetProc "Toplevel316" 1
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd87 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd82" "Frame16" vTcl:WidgetProc "Toplevel316" 1
    set site_6_0 $site_5_0.cpd82
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button43" vTcl:WidgetProc "Toplevel316" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra28 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra28" "Frame9" vTcl:WidgetProc "Toplevel316" 1
    set site_3_0 $top.fra28
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel316" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel316" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel316" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel316" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel316" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel316" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel316" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel316" 1
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
    TitleFrame $top.tit81 \
        -ipad 0 -text {Binary Data Types} 
    vTcl:DefineAlias "$top.tit81" "TitleFrame1" vTcl:WidgetProc "Toplevel316" 1
    bind $top.tit81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit81 getframe]
    frame $site_4_0.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra71" "Frame7" vTcl:WidgetProc "Toplevel316" 1
    set site_5_0 $site_4_0.fra71
    radiobutton $site_5_0.rad114 \
        \
        -command {global CheckData CheckType CheckFileName CheckFile CheckResult

set CheckType ""
set CheckFileName ""
set CheckFile ""
set CheckResult ""
    
$widget(Button316_3) configure -state normal
$widget(Entry316_3) configure -disabledbackground $PSPBackgroundColor

if {$CheckData == "Raw"} {
    $widget(Entry316_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button316_1) configure -state disable
    $widget(Radiobutton316_9) configure -state disable
    $widget(Radiobutton316_10) configure -state disable
    $widget(Radiobutton316_11) configure -state disable
    $widget(Label316_1) configure -state normal
    $widget(Label316_2) configure -state normal
    $widget(Label316_3) configure -state normal
    $widget(Radiobutton316_1) configure -state normal
    $widget(Radiobutton316_2) configure -state normal
    $widget(Radiobutton316_3) configure -state normal
    $widget(Radiobutton316_4) configure -state normal
    $widget(Radiobutton316_5) configure -state normal
    $widget(Radiobutton316_6) configure -state normal
    $widget(Radiobutton316_7) configure -state normal
    $widget(Radiobutton316_8) configure -state normal
    }
if {$CheckData == "File"} {
    $widget(Entry316_1) configure -disabledbackground #FFFFFF
    $widget(Button316_1) configure -state normal
    $widget(Radiobutton316_9) configure -state normal
    $widget(Radiobutton316_10) configure -state normal
    $widget(Radiobutton316_11) configure -state normal
    $widget(Label316_1) configure -state disable
    $widget(Label316_2) configure -state disable
    $widget(Label316_3) configure -state disable
    $widget(Radiobutton316_1) configure -state disable
    $widget(Radiobutton316_2) configure -state disable
    $widget(Radiobutton316_3) configure -state disable
    $widget(Radiobutton316_4) configure -state disable
    $widget(Radiobutton316_5) configure -state disable
    $widget(Radiobutton316_6) configure -state disable
    $widget(Radiobutton316_7) configure -state disable
    $widget(Radiobutton316_8) configure -state disable
    }} \
        -text {Raw Binary Data} -value Raw -variable CheckData 
    vTcl:DefineAlias "$site_5_0.rad114" "Radiobutton12" vTcl:WidgetProc "Toplevel316" 1
    frame $site_5_0.fra92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra92" "Frame11" vTcl:WidgetProc "Toplevel316" 1
    set site_6_0 $site_5_0.fra92
    frame $site_6_0.cpd93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd93" "Frame10" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd93
    label $site_7_0.lab89 \
        -text {Sinclair Elements} 
    vTcl:DefineAlias "$site_7_0.lab89" "Label316_1" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.lab89 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd94" "Frame12" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd94
    label $site_7_0.lab89 \
        -text {Coherency Elements} 
    vTcl:DefineAlias "$site_7_0.lab89" "Label316_2" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.lab89 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd95 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd95" "Frame13" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd95
    label $site_7_0.lab89 \
        -text {Covariance Elements} 
    vTcl:DefineAlias "$site_7_0.lab89" "Label316_3" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.lab89 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd93 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd96 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd96" "Frame14" vTcl:WidgetProc "Toplevel316" 1
    set site_6_0 $site_5_0.cpd96
    frame $site_6_0.cpd93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd93" "Frame17" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd93
    radiobutton $site_7_0.rad97 \
        \
        -command {global CheckInputDir CheckInputSubDir CheckType CheckResult

set ErrorMessage ""; set CheckResult ""
if [file exists "$CheckInputDir/config.txt"] {
if [file exists "$CheckInputDir/s11.bin"] {
    set ConfigFile "$CheckInputDir/config.txt"
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if { "$PolarType" == "full"} {
            set CheckInputSubDir ""
            } else {
            set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$ErrorMessage != ""} { 
    set CheckType ""
    set CheckInputSubDir ""
    }} \
        -text {[ S2 ]} -value S2 -variable CheckType 
    vTcl:DefineAlias "$site_7_0.rad97" "Radiobutton316_1" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.rad97 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd94" "Frame18" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd94
    radiobutton $site_7_0.cpd98 \
        \
        -command {global CheckInputDir CheckInputSubDir CheckType CheckResult

set ErrorMessage ""; set CheckResult ""
if [file isdirectory "$CheckInputDir/T3"] {
if [file exists "$CheckInputDir/T3/config.txt"] {
if [file exists "$CheckInputDir/T3/T11.bin"] {
    set ConfigFile "$CheckInputDir/T3/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set CheckInputSubDir "T3"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T3 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$ErrorMessage != ""} { 
    set CheckType ""
    set CheckInputSubDir ""
    }} \
        -text {[ T3 ]} -value T3 -variable CheckType 
    vTcl:DefineAlias "$site_7_0.cpd98" "Radiobutton316_2" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.cpd98 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    frame $site_6_0.cpd95 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd95" "Frame19" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd95
    radiobutton $site_7_0.cpd99 \
        \
        -command {global CheckInputDir CheckInputSubDir CheckType CheckResult

set ErrorMessage ""; set CheckResult ""
if [file isdirectory "$CheckInputDir/C2"] {
if [file exists "$CheckInputDir/C2/config.txt"] {
if [file exists "$CheckInputDir/C2/C11.bin"] {
    set ConfigFile "$CheckInputDir/C2/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set CheckInputSubDir "C2"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY C2 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$ErrorMessage != ""} { 
    set CheckType ""
    set CheckInputSubDir ""
    }} \
        -text {[ C2 ]} -value C2 -variable CheckType 
    vTcl:DefineAlias "$site_7_0.cpd99" "Radiobutton316_3" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.cpd99 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.cpd93 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd100 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd100" "Frame21" vTcl:WidgetProc "Toplevel316" 1
    set site_6_0 $site_5_0.cpd100
    frame $site_6_0.cpd93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd93" "Frame22" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd93
    radiobutton $site_7_0.rad97 \
        \
        -command {global CheckInputDir CheckInputSubDir CheckType CheckResult

set ErrorMessage ""; set CheckResult ""
if [file exists "$CheckInputDir/config.txt"] {
set config "false"
if [file exists "$CheckInputDir/s11.bin"] {set config "true"}
if [file exists "$CheckInputDir/s22.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$CheckInputDir/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if { "$PolarType" != "full"} {
            set CheckInputSubDir ""
            } else {
            set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            }
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$ErrorMessage != ""} { 
    set CheckType ""
    set CheckInputSubDir ""
    }} \
        -text {(Sxx , Sxy)} -value Spp -variable CheckType 
    vTcl:DefineAlias "$site_7_0.rad97" "Radiobutton316_4" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.rad97 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd94" "Frame23" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd94
    radiobutton $site_7_0.cpd98 \
        \
        -command {global CheckInputDir CheckInputSubDir CheckType CheckResult 

set ErrorMessage ""; set CheckResult ""
if [file isdirectory "$CheckInputDir/T4"] {
if [file exists "$CheckInputDir/T4/config.txt"] {
if [file exists "$CheckInputDir/T4/T11.bin"] {
    set ConfigFile "$CheckInputDir/T3/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set CheckInputSubDir "T4"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY T4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$ErrorMessage != ""} { 
    set CheckType ""
    set CheckInputSubDir ""
    }} \
        -text {[ T4 ]} -value T4 -variable CheckType 
    vTcl:DefineAlias "$site_7_0.cpd98" "Radiobutton316_5" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.cpd98 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd95 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd95" "Frame24" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd95
    radiobutton $site_7_0.cpd99 \
        \
        -command {global CheckInputDir CheckInputSubDir CheckType CheckResult

set ErrorMessage ""; set CheckResult ""
if [file isdirectory "$CheckInputDir/C3"] {
if [file exists "$CheckInputDir/C3/config.txt"] {
if [file exists "$CheckInputDir/C3/C11.bin"] {
    set ConfigFile "$CheckInputDir/C3/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set CheckInputSubDir "C3"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY C3 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$ErrorMessage != ""} { 
    set CheckType ""
    set CheckInputSubDir ""
    }} \
        -text {[ C3 ]} -value C3 -variable CheckType 
    vTcl:DefineAlias "$site_7_0.cpd99" "Radiobutton316_6" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.cpd99 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd93 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.cpd101 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd101" "Frame25" vTcl:WidgetProc "Toplevel316" 1
    set site_6_0 $site_5_0.cpd101
    frame $site_6_0.cpd93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd93" "Frame26" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd93
    radiobutton $site_7_0.rad97 \
        \
        -command {global CheckInputDir CheckInputSubDir CheckType CheckResult 

set ErrorMessage ""; set CheckResult ""
if [file exists "$CheckInputDir/config.txt"] {
set config "false"
if [file exists "$CheckInputDir/I11.bin"] {set config "true"}
if [file exists "$CheckInputDir/I22.bin"] {set config "true"}
if {$config == "true"} {
    set ConfigFile "$CheckInputDir/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        if { "$PolarCase" != "intensities"} {
            set ErrorMessage "INPUT DATA MUST BE INTENSITY DATA"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set ErrorMessage ""
            } else {
            if { "$PolarType" != "full"} {
                set CheckInputSubDir ""
                } else {
                set ErrorMessage "INPUT DATA MUST BE PARTIAL POLAR"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set ErrorMessage ""
                }
            }                
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$ErrorMessage != ""} { 
    set CheckType ""
    set CheckInputSubDir ""
    }} \
        -text {(Ixx , Ixy)} -value Ipp -variable CheckType 
    vTcl:DefineAlias "$site_7_0.rad97" "Radiobutton316_7" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.rad97 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd94 \
        -borderwidth 2 -height 27 -width 48 
    vTcl:DefineAlias "$site_6_0.cpd94" "Frame27" vTcl:WidgetProc "Toplevel316" 1
    frame $site_6_0.cpd95 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd95" "Frame28" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd95
    radiobutton $site_7_0.cpd99 \
        \
        -command {global CheckInputDir CheckInputSubDir CheckType CheckResult 

set ErrorMessage ""; set CheckResult ""
if [file isdirectory "$CheckInputDir/C4"] {
if [file exists "$CheckInputDir/C4/config.txt"] {
if [file exists "$CheckInputDir/C4/C11.bin"] {
    set ConfigFile "$CheckInputDir/C4/config.txt"
    set ErrorMessage ""
    LoadConfig
    if {"$ErrorMessage" == ""} {
        set CheckInputSubDir "C4"
        } else {
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "CHANGE THE DATA INPUT DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
    } else {
    set ErrorMessage "THE DIRECTORY C4 DOES NOT EXIST" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$ErrorMessage != ""} { 
    set CheckType ""
    set CheckInputSubDir ""
    }} \
        -text {[ C4 ]} -value C4 -variable CheckType 
    vTcl:DefineAlias "$site_7_0.cpd99" "Radiobutton316_8" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.cpd99 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd93 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.rad114 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra92 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd96 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd100 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd101 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.fra72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra72" "Frame8" vTcl:WidgetProc "Toplevel316" 1
    set site_5_0 $site_4_0.fra72
    radiobutton $site_5_0.cpd115 \
        \
        -command {global CheckData CheckType CheckFileName CheckFile CheckResult

set CheckType ""
set CheckFileName ""
set CheckFile ""
set CheckResult ""
    
$widget(Button316_3) configure -state normal
$widget(Entry316_3) configure -disabledbackground $PSPBackgroundColor

if {$CheckData == "Raw"} {
    $widget(Entry316_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button316_1) configure -state disable
    $widget(Radiobutton316_9) configure -state disable
    $widget(Radiobutton316_10) configure -state disable
    $widget(Radiobutton316_11) configure -state disable
    $widget(Label316_1) configure -state normal
    $widget(Label316_2) configure -state normal
    $widget(Label316_3) configure -state normal
    $widget(Radiobutton316_1) configure -state normal
    $widget(Radiobutton316_2) configure -state normal
    $widget(Radiobutton316_3) configure -state normal
    $widget(Radiobutton316_4) configure -state normal
    $widget(Radiobutton316_5) configure -state normal
    $widget(Radiobutton316_6) configure -state normal
    $widget(Radiobutton316_7) configure -state normal
    $widget(Radiobutton316_8) configure -state normal
    }
if {$CheckData == "File"} {
    $widget(Entry316_1) configure -disabledbackground #FFFFFF
    $widget(Button316_1) configure -state normal
    $widget(Radiobutton316_9) configure -state normal
    $widget(Radiobutton316_10) configure -state normal
    $widget(Radiobutton316_11) configure -state normal
    $widget(Label316_1) configure -state disable
    $widget(Label316_2) configure -state disable
    $widget(Label316_3) configure -state disable
    $widget(Radiobutton316_1) configure -state disable
    $widget(Radiobutton316_2) configure -state disable
    $widget(Radiobutton316_3) configure -state disable
    $widget(Radiobutton316_4) configure -state disable
    $widget(Radiobutton316_5) configure -state disable
    $widget(Radiobutton316_6) configure -state disable
    $widget(Radiobutton316_7) configure -state disable
    $widget(Radiobutton316_8) configure -state disable
    }} \
        -text {Binary Data File  } -value File -variable CheckData 
    vTcl:DefineAlias "$site_5_0.cpd115" "Radiobutton13" vTcl:WidgetProc "Toplevel316" 1
    frame $site_5_0.fra102 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra102" "Frame29" vTcl:WidgetProc "Toplevel316" 1
    set site_6_0 $site_5_0.fra102
    frame $site_6_0.fra103 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra103" "Frame30" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.fra103
    entry $site_7_0.cpd105 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CheckFileName -width 10 
    vTcl:DefineAlias "$site_7_0.cpd105" "Entry316_1" vTcl:WidgetProc "Toplevel316" 1
    button $site_7_0.cpd106 \
        \
        -command {global FileName CheckInputDir CheckFileName

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$CheckInputDir" $types "INPUT BINARY DATA FILE"
if {$FileName != ""} {
    set CheckFileName $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.cpd106" "Button316_1" vTcl:WidgetProc "Toplevel316" 1
    bindtags $site_7_0.cpd106 "$site_7_0.cpd106 Button $top all _vTclBalloon"
    bind $site_7_0.cpd106 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_7_0.cpd105 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side left 
    pack $site_7_0.cpd106 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    frame $site_6_0.cpd104 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd104" "Frame31" vTcl:WidgetProc "Toplevel316" 1
    set site_7_0 $site_6_0.cpd104
    radiobutton $site_7_0.rad107 \
        -text Cmplx -value Cmplx -variable CheckType 
    vTcl:DefineAlias "$site_7_0.rad107" "Radiobutton316_9" vTcl:WidgetProc "Toplevel316" 1
    radiobutton $site_7_0.cpd109 \
        -text Float -value Float -variable CheckType 
    vTcl:DefineAlias "$site_7_0.cpd109" "Radiobutton316_10" vTcl:WidgetProc "Toplevel316" 1
    radiobutton $site_7_0.cpd110 \
        -text Integer -value Int -variable CheckType 
    vTcl:DefineAlias "$site_7_0.cpd110" "Radiobutton316_11" vTcl:WidgetProc "Toplevel316" 1
    pack $site_7_0.rad107 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd109 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd110 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.fra103 \
        -in $site_6_0 -anchor center -expand 1 -fill both -side top 
    pack $site_6_0.cpd104 \
        -in $site_6_0 -anchor center -expand 1 -fill both -side top 
    pack $site_5_0.cpd115 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra102 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.fra71 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.fra72 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    frame $top.fra111 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra111" "Frame32" vTcl:WidgetProc "Toplevel316" 1
    set site_3_0 $top.fra111
    entry $site_3_0.cpd71 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CheckFile -width 10 
    vTcl:DefineAlias "$site_3_0.cpd71" "Entry316_3" vTcl:WidgetProc "Toplevel316" 1
    entry $site_3_0.cpd112 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -state disabled -textvariable CheckResult -width 40 
    vTcl:DefineAlias "$site_3_0.cpd112" "Entry316_2" vTcl:WidgetProc "Toplevel316" 1
    label $site_3_0.lab73 \
        \
        -image [vTcl:image:get_image [file join . GUI Images FixingErrorOff.gif]] 
    vTcl:DefineAlias "$site_3_0.lab73" "Label2" vTcl:WidgetProc "Toplevel316" 1
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd112 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.lab73 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra42 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra42" "Frame20" vTcl:WidgetProc "Toplevel316" 1
    set site_3_0 $top.fra42
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global CheckDirInput CheckInputDir CheckInputSubDir
global CheckData CheckType CheckFileName CheckResult TMPCheckBinaryData
global Fonction Fonction2 ProgressLine VarError ErrorMessage OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

if {$CheckType == ""} {
set VarError ""
set ErrorMessage "ENTER THE BINARY DATA TYPE" 
Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
} else {

set config "true"
if {$CheckData == "File"} {
    if {$CheckFileName == ""} {
        set VarError ""
        set ErrorMessage "ENTER THE BINARY DATA FILE NAME" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set config "false"
        }
    }

if {$config == "true"} {
if [file exists $TMPCheckBinaryData] {
    set deleteerror [file delete -force -- $TMPCheckBinaryData]
    }

set OffsetLig [expr $NligInit - 1]
set OffsetCol [expr $NcolInit - 1]
set FinalNlig [expr $NligEnd - $NligInit + 1]
set FinalNcol [expr $NcolEnd - $NcolInit + 1]

set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
if {$CheckData == "File"} {
    set TestVarName(4) "Check Data File"; set TestVarType(4) "file"; set TestVarValue(4) $CheckFileName; set TestVarMin(4) ""; set TestVarMax(4) ""
    TestVar 5
    } else {
    TestVar 4
    }
    
if {$TestVarError == "ok"} {
    set CheckResult ""
    if {$CheckData == "Raw"} {
        set CheckDirInput $CheckInputDir
        if {$CheckInputSubDir != ""} {append CheckDirInput "/$CheckInputSubDir"}
        $widget(Entry316_3) configure -disabledbackground #FFFFFF
        if {$CheckType == "S2"} { CheckDataSinclair $CheckDirInput }
        if {$CheckType == "Spp"} { CheckDataSinclair $CheckDirInput }
        if {$CheckType == "T3"} { CheckDataCoherency $CheckDirInput }
        if {$CheckType == "T4"} { CheckDataCoherency $CheckDirInput }
        if {$CheckType == "C2"} { CheckDataCovariance $CheckDirInput }
        if {$CheckType == "C3"} { CheckDataCovariance $CheckDirInput }
        if {$CheckType == "C4"} { CheckDataCovariance $CheckDirInput }
        if {$CheckType == "Ipp"} { CheckDataIntensity $CheckDirInput }
        $widget(Entry316_3) configure -disabledbackground $PSPBackgroundColor
        set CheckFile ""; 
        }
    if {$CheckData == "File"} {
        $widget(Entry316_3) configure -disabledbackground $PSPBackgroundColor
        set CheckFile ""; 
        CheckDataFile
        }
    }

}
}
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button316_3" vTcl:WidgetProc "Toplevel316" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/DataFileManagement.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel316" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile BinaryDataCheck
if {$OpenDirFile == 0} {
set BinaryDataCheck 0
Window hide $widget(Toplevel316); TextEditorRunTrace "Close Window Check Binary Data" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel316" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but23 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    menu $top.m102 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra28 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit81 \
        -in $top -anchor center -expand 0 -fill both -side top 
    pack $top.fra111 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra42 \
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
Window show .top316

main $argc $argv
