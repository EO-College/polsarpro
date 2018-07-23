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
        {{[file join . GUI Images smiley_transparent.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}

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
    set base .top406
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd78 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd78 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra81
    namespace eval ::widgets::$site_3_0.fra82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra82
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd86
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd88
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd80 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd80 getframe]
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
    namespace eval ::widgets::$site_5_0.cpd81 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd89 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.cpd89
    namespace eval ::widgets::$site_3_0.fra82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra82
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd86
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd88
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd66
    namespace eval ::widgets::$site_3_0.fra82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra82
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd86 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd86
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd88
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd67
    namespace eval ::widgets::$site_4_0.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent84 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra57 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra57
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.tit90 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.tit90 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-image 1}
    }
    namespace eval ::widgets::$site_3_0.but67 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
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
            vTclWindow.top406
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
    wm geometry $top 200x200+25+25; update
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

proc vTclWindow.top406 {base} {
    if {$base == ""} {
        set base .top406
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
    wm geometry $top 500x250+160+100; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Compare Binary Files"
    vTcl:DefineAlias "$top" "Toplevel406" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.cpd78 \
        -ipad 0 -text {Binary File 1} 
    vTcl:DefineAlias "$top.cpd78" "TitleFrame6" vTcl:WidgetProc "Toplevel406" 1
    bind $top.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd78 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CompareFile1 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel406" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel406" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.cpd80 \
        \
        -command {global DataDir FileName 
global ErrorMessage VarError
global CompareDataDir1 CompareFile1 
global CompareLine1 CompareSample1 CompareFormat1
global CompareOffLig CompareOffCol CompareSubNlig CompareSubNcol

set types {
    {{Bin Files}        .bin     }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $CompareDataDir1 $types "BINARY FILE 1"
if {$FileName != ""} {
    package require Img
    image create photo ImageConfig
    ImageConfig blank
    $widget(Label406_2) configure -anchor nw -image ImageConfig
    image delete ImageConfig
    image create photo ImageConfig -file "GUI/Images/smiley_transparent.gif"
    $widget(Label406_2) configure -anchor nw -image ImageConfig
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; set CompareSample1 [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp; set CompareLine1 [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            if {$tmp == "data type = 2"} {set CompareFormat1 "int"}
            if {$tmp == "data type = 4"} {set CompareFormat1 "float"}
            if {$tmp == "data type = 6"} {set CompareFormat1 "cmplx"}
            set CompareFile1 $FileName
            set CompareDataDir1 [file dir $FileName]
            set CompareOffLig 0; set CompareOffCol 0
            set CompareSubNlig $CompareLine1; set CompareSubNcol $CompareSample1
            } else {
            set VarError ""
            set ErrorMessage "THIS FILE IS NOT A PolSARpro BINARY FILE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }    
        close $f
        } else {
        set VarError ""
        set ErrorMessage "THIS FILE IS NOT A PolSARpro BINARY FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd80" "Button29" vTcl:WidgetProc "Toplevel406" 1
    bindtags $site_5_0.cpd80 "$site_5_0.cpd80 Button $top all _vTclBalloon"
    bind $site_5_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $top.fra81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra81" "Frame3" vTcl:WidgetProc "Toplevel406" 1
    set site_3_0 $top.fra81
    frame $site_3_0.fra82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra82" "Frame4" vTcl:WidgetProc "Toplevel406" 1
    set site_4_0 $site_3_0.fra82
    label $site_4_0.lab83 \
        -text Lines 
    vTcl:DefineAlias "$site_4_0.lab83" "Label2" vTcl:WidgetProc "Toplevel406" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CompareLine1 -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry1" vTcl:WidgetProc "Toplevel406" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd86" "Frame5" vTcl:WidgetProc "Toplevel406" 1
    set site_4_0 $site_3_0.cpd86
    label $site_4_0.lab83 \
        -text Samples 
    vTcl:DefineAlias "$site_4_0.lab83" "Label5" vTcl:WidgetProc "Toplevel406" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CompareSample1 -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry2" vTcl:WidgetProc "Toplevel406" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd88" "Frame6" vTcl:WidgetProc "Toplevel406" 1
    set site_4_0 $site_3_0.cpd88
    label $site_4_0.lab83 \
        -text {Data Format} 
    vTcl:DefineAlias "$site_4_0.lab83" "Label6" vTcl:WidgetProc "Toplevel406" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CompareFormat1 -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry3" vTcl:WidgetProc "Toplevel406" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.fra82 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd88 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd80 \
        -ipad 0 -text {Binary File 2} 
    vTcl:DefineAlias "$top.cpd80" "TitleFrame7" vTcl:WidgetProc "Toplevel406" 1
    bind $top.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd80 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CompareFile2 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel406" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame14" vTcl:WidgetProc "Toplevel406" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd81 \
        \
        -command {global DataDir FileName 
global ErrorMessage VarError
global CompareDataDir2 CompareFile2 
global CompareLine2 CompareSample2 CompareFormat2
global CompareOffLig CompareOffCol CompareSubNlig CompareSubNcol

set types {
    {{Bin Files}        .bin     }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $CompareDataDir2 $types "BINARY FILE 2"
if {$FileName != ""} {
    package require Img
    image create photo ImageConfig
    ImageConfig blank
    $widget(Label406_2) configure -anchor nw -image ImageConfig
    image delete ImageConfig
    image create photo ImageConfig -file "GUI/Images/smiley_transparent.gif"
    $widget(Label406_2) configure -anchor nw -image ImageConfig
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp; set CompareSample2 [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp; set CompareLine2 [string range $tmp [expr [string first "=" $tmp] + 2 ] [string length $tmp] ]
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            if {$tmp == "data type = 2"} {set CompareFormat2 "int"}
            if {$tmp == "data type = 4"} {set CompareFormat2 "float"}
            if {$tmp == "data type = 6"} {set CompareFormat2 "cmplx"}
            close $f
            set CompareFile2 $FileName
            set CompareDataDir2 [file dir $FileName]
            set CompareOffLig 0; set CompareOffCol 0
            set CompareSubNlig $CompareLine2; set CompareSubNcol $CompareSample2
            } else {
            set VarError ""
            set ErrorMessage "THIS FILE IS NOT A PolSARpro BINARY FILE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }    
        } else {
        set VarError ""
        set ErrorMessage "THIS FILE IS NOT A PolSARpro BINARY FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd81" "Button38" vTcl:WidgetProc "Toplevel406" 1
    bindtags $site_5_0.cpd81 "$site_5_0.cpd81 Button $top all _vTclBalloon"
    bind $site_5_0.cpd81 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $top.cpd89 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd89" "Frame7" vTcl:WidgetProc "Toplevel406" 1
    set site_3_0 $top.cpd89
    frame $site_3_0.fra82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra82" "Frame8" vTcl:WidgetProc "Toplevel406" 1
    set site_4_0 $site_3_0.fra82
    label $site_4_0.lab83 \
        -text Lines 
    vTcl:DefineAlias "$site_4_0.lab83" "Label3" vTcl:WidgetProc "Toplevel406" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CompareLine2 -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry4" vTcl:WidgetProc "Toplevel406" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd86" "Frame9" vTcl:WidgetProc "Toplevel406" 1
    set site_4_0 $site_3_0.cpd86
    label $site_4_0.lab83 \
        -text Samples 
    vTcl:DefineAlias "$site_4_0.lab83" "Label7" vTcl:WidgetProc "Toplevel406" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CompareSample2 -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry5" vTcl:WidgetProc "Toplevel406" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd88" "Frame10" vTcl:WidgetProc "Toplevel406" 1
    set site_4_0 $site_3_0.cpd88
    label $site_4_0.lab83 \
        -text {Data Format} 
    vTcl:DefineAlias "$site_4_0.lab83" "Label8" vTcl:WidgetProc "Toplevel406" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CompareFormat2 -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry6" vTcl:WidgetProc "Toplevel406" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.fra82 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd88 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd66" "Frame11" vTcl:WidgetProc "Toplevel406" 1
    set site_3_0 $top.cpd66
    frame $site_3_0.fra82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra82" "Frame12" vTcl:WidgetProc "Toplevel406" 1
    set site_4_0 $site_3_0.fra82
    label $site_4_0.lab83 \
        -text {Off Row} 
    vTcl:DefineAlias "$site_4_0.lab83" "Label4" vTcl:WidgetProc "Toplevel406" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable CompareOffLig -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry7" vTcl:WidgetProc "Toplevel406" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd86 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd86" "Frame15" vTcl:WidgetProc "Toplevel406" 1
    set site_4_0 $site_3_0.cpd86
    label $site_4_0.lab83 \
        -text {Off Col} 
    vTcl:DefineAlias "$site_4_0.lab83" "Label9" vTcl:WidgetProc "Toplevel406" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable CompareOffCol -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry8" vTcl:WidgetProc "Toplevel406" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd88" "Frame16" vTcl:WidgetProc "Toplevel406" 1
    set site_4_0 $site_3_0.cpd88
    label $site_4_0.lab83 \
        -text {N Row} 
    vTcl:DefineAlias "$site_4_0.lab83" "Label10" vTcl:WidgetProc "Toplevel406" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable CompareSubNlig -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry9" vTcl:WidgetProc "Toplevel406" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd67" "Frame17" vTcl:WidgetProc "Toplevel406" 1
    set site_4_0 $site_3_0.cpd67
    label $site_4_0.lab83 \
        -text {N Col} 
    vTcl:DefineAlias "$site_4_0.lab83" "Label11" vTcl:WidgetProc "Toplevel406" 1
    entry $site_4_0.ent84 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable CompareSubNcol -width 7 
    vTcl:DefineAlias "$site_4_0.ent84" "Entry10" vTcl:WidgetProc "Toplevel406" 1
    pack $site_4_0.lab83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 3 -side left 
    pack $site_4_0.ent84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.fra82 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd86 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd88 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra57 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra57" "Frame20" vTcl:WidgetProc "Toplevel406" 1
    set site_3_0 $top.fra57
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global OpenDirFile ErrorMessage VarError
global CompareFile1 CompareLine1 CompareSample1 CompareFormat1
global CompareFile2 CompareLine2 CompareSample2 CompareFormat2
global CompareOffLig CompareOffCol CompareSubNlig CompareSubNcol
global TMPCompareBinaryData

if {$OpenDirFile == 0} {

DeleteFile "$TMPCompareBinaryData.txt"

package require Img
image create photo ImageConfig
ImageConfig blank
$widget(Label406_2) configure -anchor nw -image ImageConfig
image delete ImageConfig
image create photo ImageConfig -file "GUI/Images/smiley_transparent.gif"
$widget(Label406_2) configure -anchor nw -image ImageConfig

set config "true"
if {$CompareLine1 != $CompareLine2} {
    set config "false"
    set VarError ""
    set ErrorMessage "THE BINARY FILES MUST HAVE THE SAME NUMBER OF LINES"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$CompareSample1 != $CompareSample2} {
    set config "false"
    set VarError ""
    set ErrorMessage "THE BINARY FILES MUST HAVE THE SAME NUMBER OF SAMPLES"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$CompareFormat1 != $CompareFormat2} {
    set config "false"
    set VarError ""
    set ErrorMessage "THE BINARY FILES MUST HAVE THE SAME DATA FORMAT"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
if {$config == "true"} {
    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
    set ProgressLine "0"
    update
    TextEditorRunTrace "Process The Function Soft/tools/compare_binary_data_file.exe" "k"
    TextEditorRunTrace "Arguments: -if1 \x22$CompareFile1\x22 -if2 \x22$CompareFile2\x22 -ofr $CompareOffLig -ofc $CompareOffCol -fnr $CompareSubNlig -fnc $CompareSubNcol -inc $CompareSample1 -idf $CompareFormat1 -of \x22$TMPCompareBinaryData\x22" "k"
    set f [ open "| Soft/tools/compare_binary_data_file.exe -if1 \x22$CompareFile1\x22 -if2 \x22$CompareFile2\x22 -ofr $CompareOffLig -ofc $CompareOffCol -fnr $CompareSubNlig -fnc $CompareSubNcol -inc $CompareSample1 -idf $CompareFormat1 -of \x22$TMPCompareBinaryData\x22" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    WaitUntilCreated "$TMPCompareBinaryData.txt"
    if [file exists "$TMPCompareBinaryData.txt"] {
        set f [open "$TMPCompareBinaryData.txt" "r"]
        gets $f CompareResult
        close $f
        package require Img
        image create photo ImageConfig
        ImageConfig blank
        $widget(Label406_2) configure -anchor nw -image ImageConfig
        image delete ImageConfig
        if {$CompareResult == "1"} {
            image create photo ImageConfig -file "GUI/Images/smiley_ok.gif"
            $widget(Label406_2) configure -anchor nw -image ImageConfig
            } 
        if {$CompareResult == "0"} {
            image create photo ImageConfig -file "GUI/Images/smiley_ko.gif"
            $widget(Label406_2) configure -anchor nw -image ImageConfig
            } 

        set BMPFileInput "$TMPCompareBinaryData.bin"
        set BMPFileOutput "$TMPCompareBinaryData.bmp"
        PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $CompareSubNcol  $CompareOffLig $CompareOffCol $CompareSubNlig $CompareSubNcol 0 0 1
        }
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel406" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    TitleFrame $site_3_0.tit90 \
        -ipad 0 -text Result 
    vTcl:DefineAlias "$site_3_0.tit90" "TitleFrame1" vTcl:WidgetProc "Toplevel406" 1
    bind $site_3_0.tit90 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit90 getframe]
    label $site_5_0.cpd91 \
        \
        -image [vTcl:image:get_image [file join . GUI Images smiley_transparent.gif]] 
    vTcl:DefineAlias "$site_5_0.cpd91" "Label406_2" vTcl:WidgetProc "Toplevel406" 1
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    button $site_3_0.but67 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/DataFileManagement.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.but67" "Button1" vTcl:WidgetProc "Toplevel406" 1
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel406); TextEditorRunTrace "Close Window Compare Binary Files" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel406" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.tit90 \
        -in $site_3_0 -anchor center -expand 1 -fill y -side left 
    pack $site_3_0.but67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd78 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra81 \
        -in $top -anchor center -expand 0 -fill both -pady 2 -side top 
    pack $top.cpd80 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd89 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra57 \
        -in $top -anchor center -expand 1 -fill x -pady 3 -side top 

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
Window show .top406

main $argc $argv
