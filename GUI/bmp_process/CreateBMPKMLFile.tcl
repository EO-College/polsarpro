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

        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images google_earth.gif]} {user image} user {}}

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
    set base .top397
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd75
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra51 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra51
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.lab59 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd68
    namespace eval ::widgets::$site_4_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd69
    namespace eval ::widgets::$site_4_0.lab63 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
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
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.cpd99 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd99 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd67
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd78
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra73
    namespace eval ::widgets::$site_5_0.but74 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd79
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.fra68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra68
    namespace eval ::widgets::$site_5_0.rad69 {
        array set save {-background 1 -relief 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-background 1 -relief 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-background 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che66 {
        array set save {-_tooltip 1 -image 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra38 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra38
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -width 1}
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
            vTclWindow.top397
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
    wm geometry $top 200x200+175+175; update
    wm maxsize $top 3364 1032
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

proc vTclWindow.top397 {base} {
    if {$base == ""} {
        set base .top397
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
    wm geometry $top 500x290+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Create BMP - KML File"
    vTcl:DefineAlias "$top" "Toplevel397" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd75" "Frame2" vTcl:WidgetProc "Toplevel397" 1
    set site_3_0 $top.cpd75
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input BMP File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel397" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable BMPFileInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel397" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel397" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global FileName BMPDirInput BMPDirOutput BMPFileInput BMPFileOutput 
global VarError ErrorMessage
global NLigBMPColor NColBMPColor NColorBMPColor

set BMPFileInput ""; set BMPFileOutput ""
set NLigBMPColor ""; set NColBMPColor ""; set NColorBMPColor ""

set BMPDirInputTmp $BMPDirInput
set BMPDirOutputTmp $BMPDirOutput

set types {
{{BMP Files}        {.bmp}        }
}
set FileName ""
OpenFile $BMPDirInput $types "INPUT BMP FILE"
    
if {$FileName != ""} {
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; set NColBMPColor [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp; set NLigBMPColor [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp; gets $f tmp; gets $f tmp
            if {[string first "8 bytes" $tmp] != "-1"} { set NColorBMPColor "BMP 8 Bits"}
            if {[string first "24 bytes" $tmp] != "-1"} { set NColorBMPColor "BMP 24 Bits"}
            set BMPDirInput [file dirname $FileName]
            set BMPDirOutput $BMPDirInput
            set BMPFileInput $FileName
            set BMPFileOutput [file rootname $BMPFileInput]
            append BMPFileOutput ".kml"
            } else {
            set ErrorMessage "NOT A PolSARpro BMP FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set BMPDirInput $BMPDirInputTmp
            set BMPDirOutput $BMPDirOutputTmp
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set BMPDirInput $BMPDirInputTmp
        set BMPDirOutput $BMPDirOutputTmp
        }    
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Output KML Directory} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame9" vTcl:WidgetProc "Toplevel397" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable BMPDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel397" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame22" vTcl:WidgetProc "Toplevel397" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd79 \
        \
        -command {global DirName DataDir BMPDirOutput BMPFileOutput

set BMPDirOutputTmp $BMPDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set BMPDirOutput $DirName
    } else {
    set BMPDirOutput $BMPDirOutputTmp
    }
set FileTmp "$BMPDirOutput/"
append FileTmp [file tail $BMPFileOutput]
set BMPFileOutput $FileTmp} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra51 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra51" "Frame9" vTcl:WidgetProc "Toplevel397" 1
    set site_3_0 $top.fra51
    frame $site_3_0.cpd66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame10" vTcl:WidgetProc "Toplevel397" 1
    set site_4_0 $site_3_0.cpd66
    label $site_4_0.lab59 \
        -padx 1 -text {N Row} 
    vTcl:DefineAlias "$site_4_0.lab59" "Label12" vTcl:WidgetProc "Toplevel397" 1
    entry $site_4_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NLigBMPColor -width 7 
    vTcl:DefineAlias "$site_4_0.ent60" "Entry8" vTcl:WidgetProc "Toplevel397" 1
    pack $site_4_0.lab59 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.ent60 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd68" "Frame11" vTcl:WidgetProc "Toplevel397" 1
    set site_4_0 $site_3_0.cpd68
    label $site_4_0.lab63 \
        -text {N Col} 
    vTcl:DefineAlias "$site_4_0.lab63" "Label16" vTcl:WidgetProc "Toplevel397" 1
    entry $site_4_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NColBMPColor -width 7 
    vTcl:DefineAlias "$site_4_0.ent64" "Entry12" vTcl:WidgetProc "Toplevel397" 1
    pack $site_4_0.lab63 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.ent64 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd69" "Frame12" vTcl:WidgetProc "Toplevel397" 1
    set site_4_0 $site_3_0.cpd69
    label $site_4_0.lab63 \
        -text {N Color} 
    vTcl:DefineAlias "$site_4_0.lab63" "Label18" vTcl:WidgetProc "Toplevel397" 1
    entry $site_4_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -justify center \
        -state disabled -textvariable NColorBMPColor -width 13 
    vTcl:DefineAlias "$site_4_0.ent64" "Entry14" vTcl:WidgetProc "Toplevel397" 1
    pack $site_4_0.lab63 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.ent64 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    TitleFrame $top.cpd66 \
        -ipad 0 -text {Input GEARTH_POLY File} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame397_5" vTcl:WidgetProc "Toplevel397" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable BMPGearthPolyFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry397_5" vTcl:WidgetProc "Toplevel397" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame24" vTcl:WidgetProc "Toplevel397" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd79 \
        \
        -command {global FileName BMPDirInput BMPGearthPolyFile

set GPDirInput [file dirname $BMPDirInput]

set types {
{{KML Files}        {.kml}        }
}
set FileName ""
OpenFile $GPDirInput $types "INPUT GEARTH POLY FILE" 
if {$FileName != ""} {
    set BMPGearthPolyFile $FileName
    } else {
    set BMPGearthPolyFile "ENTER THE GEARTH POLY FILE"
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd79" "Button397_5" vTcl:WidgetProc "Toplevel397" 1
    bindtags $site_5_0.cpd79 "$site_5_0.cpd79 Button $top all _vTclBalloon"
    bind $site_5_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $top.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame5" vTcl:WidgetProc "Toplevel397" 1
    set site_3_0 $top.cpd72
    TitleFrame $site_3_0.cpd99 \
        -ipad 0 -text {Output KML File} 
    vTcl:DefineAlias "$site_3_0.cpd99" "TitleFrame12" vTcl:WidgetProc "Toplevel397" 1
    bind $site_3_0.cpd99 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd99 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable BMPFileOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh12" vTcl:WidgetProc "Toplevel397" 1
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd99 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side top 
    frame $top.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd67" "Frame16" vTcl:WidgetProc "Toplevel397" 1
    set site_3_0 $top.cpd67
    frame $site_3_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd78" "Frame25" vTcl:WidgetProc "Toplevel397" 1
    set site_4_0 $site_3_0.cpd78
    label $site_4_0.cpd76 \
        -text {Reduction Factor} 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label6" vTcl:WidgetProc "Toplevel397" 1
    entry $site_4_0.ent72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ReducFactor -width 5 
    vTcl:DefineAlias "$site_4_0.ent72" "Entry4" vTcl:WidgetProc "Toplevel397" 1
    frame $site_4_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra73" "Frame26" vTcl:WidgetProc "Toplevel397" 1
    set site_5_0 $site_4_0.fra73
    button $site_5_0.but74 \
        \
        -command {global ReducFactor

set ReducFactor [expr $ReducFactor + 1]
if  {$ReducFactor == 7}  { set ReducFactor 1 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_5_0.but74" "Button7" vTcl:WidgetProc "Toplevel397" 1
    button $site_5_0.but75 \
        \
        -command {global ReducFactor

set ReducFactor [expr $ReducFactor - 1]
if  {$ReducFactor < 1 }  { set ReducFactor 6 }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button8" vTcl:WidgetProc "Toplevel397" 1
    pack $site_5_0.but74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.ent72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_4_0.fra73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd79" "Frame27" vTcl:WidgetProc "Toplevel397" 1
    set site_4_0 $site_3_0.cpd79
    label $site_4_0.cpd76 \
        -text Transparency 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label7" vTcl:WidgetProc "Toplevel397" 1
    frame $site_4_0.fra68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra68" "Frame1" vTcl:WidgetProc "Toplevel397" 1
    set site_5_0 $site_4_0.fra68
    radiobutton $site_5_0.rad69 \
        -background #ffffff -relief ridge -value 0 -variable TranspColor 
    vTcl:DefineAlias "$site_5_0.rad69" "Radiobutton1" vTcl:WidgetProc "Toplevel397" 1
    radiobutton $site_5_0.cpd70 \
        -background #cccccc -relief ridge -value 1 -variable TranspColor 
    vTcl:DefineAlias "$site_5_0.cpd70" "Radiobutton2" vTcl:WidgetProc "Toplevel397" 1
    radiobutton $site_5_0.cpd71 \
        -background #000000 -value 2 -variable TranspColor 
    vTcl:DefineAlias "$site_5_0.cpd71" "Radiobutton3" vTcl:WidgetProc "Toplevel397" 1
    pack $site_5_0.rad69 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    checkbutton $site_3_0.che66 \
        \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -variable DisplayGoogleEarth 
    vTcl:DefineAlias "$site_3_0.che66" "Checkbutton1" vTcl:WidgetProc "Toplevel397" 1
    bindtags $site_3_0.che66 "$site_3_0.che66 Checkbutton $top all _vTclBalloon"
    bind $site_3_0.che66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Display with Google Earth}
    }
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -pady 3 -side left 
    pack $site_3_0.cpd79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.che66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra38 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra38" "Frame20" vTcl:WidgetProc "Toplevel397" 1
    set site_3_0 $top.fra38
    button $site_3_0.but93 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_3_0.but93 {global BMPDirOutput BMPFileInput BMPFileOutput BMPGearthPolyFile
global VarError ErrorMessage Fonction Fonction2 ProgressLine
global OpenDirFile ImageMagickMaker ReducFactor TranspColor DisplayGoogleEarth
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

    set config "true"
    if {"$BMPFileInput"==""} {set config "false"}
    
    if {"$config"=="false"} {
        set VarError ""
        set ErrorMessage "INVALID INPUT BMP FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    if {"$config"=="true"} {

    set BMPDirOutput [file dirname $BMPFileOutput]
    
    #####################################################################
    #Create Directory
    set BMPDirOutput [PSPCreateDirectoryMask $BMPDirOutput $BMPDirOutput $BMPDirInput]
    #####################################################################       

        if {"$VarWarning"=="ok"} {
            WidgetShowTop399; TextEditorRunTrace "Open Window Processing" "b"

            set ImageMagickCommand " $BMPFileInput"
            if {$ReducFactor == 2} { append ImageMagickCommand " -resize 50%" }
            if {$ReducFactor == 3} { append ImageMagickCommand " -resize 33%" }
            if {$ReducFactor == 4} { append ImageMagickCommand " -resize 25%" }
            if {$ReducFactor == 5} { append ImageMagickCommand " -resize 20%" }
            if {$ReducFactor == 6} { append ImageMagickCommand " -resize 17%" }
            if {$TranspColor == 0} { append ImageMagickCommand " -transparent \x22rgb(254,255,254)\x22" }
            if {$TranspColor == 1} { append ImageMagickCommand " -transparent \x22rgb(127,128,127)\x22" }
            if {$TranspColor == 2} { append ImageMagickCommand " -transparent \x22rgb(0,1,0)\x22" }
            append ImageMagickCommand " -quiet"
            set PNGFileOutput [file rootname $BMPFileOutput]; append PNGFileOutput ".png"
            append ImageMagickCommand " $PNGFileOutput"

            set Fonction "Creation of a KML - PNG File"
            set Fonction2 ""
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function $ImageMagickMaker" "k"
            TextEditorRunTrace "Arguments: $ImageMagickCommand" "k"
            set f [ open "| \x22$ImageMagickMaker\x22 $ImageMagickCommand" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

            DeleteFile $BMPFileOutput
            set PNGFileInput [file tail $PNGFileOutput]
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bin/tools/google_to_kml_file.exe" "k"
            TextEditorRunTrace "Arguments: -ifg \x22$BMPGearthPolyFile\x22 -ofk \x22$BMPFileOutput\x22 -ifp \x22$PNGFileInput\x22" "k"
            set f [ open "| Soft/bin/tools/google_to_kml_file.exe -ifg \x22$BMPGearthPolyFile\x22 -ofk \x22$BMPFileOutput\x22 -ifp \x22$PNGFileInput\x22" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            WaitUntilCreated $BMPFileOutput           

            if {$DisplayGoogleEarth == 1} {
                GoogleEarth $BMPFileOutput
                }
                
            Window hide $widget(Toplevel397); TextEditorRunTrace "Close Window Create BMP - KML File" "b"
            WidgetHideTop399; TextEditorRunTrace "Close Window Processing" "b"
            } else {
            if {"$VarWarning"=="no"} {Window hide $widget(Toplevel397); TextEditorRunTrace "Close Window Create BMP - KML File" "b"}
            }
        }
    }}] \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel397" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CreateBMPKMLFile.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel397" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global DisplayMainMenu OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel397); TextEditorRunTrace "Close Window Create BMP File" "b"
if {$DisplayMainMenu == 1} {
    set DisplayMainMenu 0
    WidgetShow $widget(Toplevel2)
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel397" 1
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
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd75 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra51 \
        -in $top -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra38 \
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
Window show .top397

main $argc $argv
