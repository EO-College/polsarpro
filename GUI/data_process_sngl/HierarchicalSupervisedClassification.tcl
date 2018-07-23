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

        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
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
    set base .top262
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd88 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd88
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
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd72
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra55 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra55
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-text 1}
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
    namespace eval ::widgets::$base.tit109 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit109 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.che73 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra74 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra74
    namespace eval ::widgets::$site_6_0.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra75
    namespace eval ::widgets::$site_7_0.cpd77 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_7_0.lab76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd78
    namespace eval ::widgets::$site_7_0.ent79 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd80 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd73 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd73 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd93
    namespace eval ::widgets::$site_5_0.lab42 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent44 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd94
    namespace eval ::widgets::$site_6_0.cpd105 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd106 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd106
    namespace eval ::widgets::$site_5_0.fra23 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra23
    namespace eval ::widgets::$site_6_0.but68 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd103 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd103 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd93
    namespace eval ::widgets::$site_5_0.lab42 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.ent44 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd94
    namespace eval ::widgets::$site_6_0.cpd105 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd106 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd106
    namespace eval ::widgets::$site_5_0.fra23 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra23
    namespace eval ::widgets::$site_6_0.but68 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd100 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd100 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra90 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra90
    namespace eval ::widgets::$site_5_0.fra91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra91
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra92
    namespace eval ::widgets::$site_6_0.but80 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd102 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
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
            vTclWindow.top262
            TreeWriteFiles
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
## Procedure:  TreeWriteFiles

proc ::TreeWriteFiles {} {
global TMPTreeClassRulesTxt TMPTreeClassPrmListTxt
global TreeInputNum TreeInputParaFile
global TreeNodeType TreeNodeClass
global TreeNodePara1 TreeNodePara2
global TreeNodeCoeff1 TreeNodeCoeff2
global TreeNodeCoeff3 TreeNodeOperator

DeleteFile $TMPTreeClassRulesTxt
DeleteFile $TMPTreeClassPrmListTxt

set f [open $TMPTreeClassPrmListTxt w]
for {set i 1} {$i <= $TreeInputNum} {incr i} { puts $f $TreeInputParaFile($i) }
close $f

set NodeList(0) 0
set NodeList(1) 1; set NodeList(2) 2; set NodeList(3) 4; set NodeList(4) 8; set NodeList(5) 16; set NodeList(6) 17
set NodeList(7) 9; set NodeList(8) 18; set NodeList(9) 19; set NodeList(10) 5; set NodeList(11) 10; set NodeList(12) 20
set NodeList(13) 21; set NodeList(14) 11; set NodeList(15) 22; set NodeList(16) 23; set NodeList(17) 3; set NodeList(18) 6
set NodeList(19) 12; set NodeList(20) 24; set NodeList(21) 25; set NodeList(22) 13; set NodeList(23) 26; set NodeList(24) 27
set NodeList(25) 7; set NodeList(26) 14; set NodeList(27) 28; set NodeList(28) 29; set NodeList(29) 15; set NodeList(30) 30
set NodeList(31) 31
set f [open $TMPTreeClassRulesTxt w]
puts $f "a  b     c  p1 p2 T F"
puts $f "---------------------"
puts $f ""
for {set i 1} {$i <32} {incr i} {
    set NumNode $NodeList($i)
    if {$TreeNodeType($NumNode) == "node"} {
        set NumNodeTrue [expr 2 * $NumNode]; set NumNodeFalse [expr 2 * $NumNode + 1]
        if {$TreeNodeType($NumNodeTrue) == "node"} {
            if {$TreeNodeType($NumNodeFalse) == "node"} { set PrmTrue 0; set PrmFalse 0 }
            if {$TreeNodeType($NumNodeFalse) == "class"} { set PrmTrue 0; set PrmFalse $TreeNodeClass($NumNodeFalse) }
            }
        if {$TreeNodeType($NumNodeTrue) == "class"} {
            if {$TreeNodeType($NumNodeFalse) == "node"} { set PrmTrue $TreeNodeClass($NumNodeTrue); set PrmFalse 0 }
            if {$TreeNodeType($NumNodeFalse) == "class"} { set PrmTrue $TreeNodeClass($NumNodeTrue); set PrmFalse $TreeNodeClass($NumNodeFalse) }
            }
        if {$TreeNodeOperator($NumNode) == "sup"} {
            set PrmC1 $TreeNodeCoeff1($NumNode)
            set PrmC2 $TreeNodeCoeff2($NumNode)
            set PrmC3 $TreeNodeCoeff3($NumNode)
            }
        if {$TreeNodeOperator($NumNode) == "inf"} {
            set PrmC1 [expr -1 * $TreeNodeCoeff1($NumNode)]
            set PrmC2 [expr -1 * $TreeNodeCoeff2($NumNode)]
            set PrmC3 [expr -1 * $TreeNodeCoeff3($NumNode)]
            }
        set PrmString ""
        append PrmString "$PrmC1  ";append PrmString "$PrmC2 ";append PrmString "$PrmC3   "
        append PrmString "$TreeNodePara1($NumNode) ";append PrmString "$TreeNodePara2($NumNode) "
        append PrmString "$PrmTrue ";append PrmString "$PrmFalse"
        puts $f $PrmString
        }
    }
close $f
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
    wm geometry $top 200x200+66+66; update
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

proc vTclWindow.top262 {base} {
    if {$base == ""} {
        set base .top262
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
    wm geometry $top 500x430+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Rule-Based Hierarchical Classification"
    vTcl:DefineAlias "$top" "Toplevel262" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd88 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd88" "Frame5" vTcl:WidgetProc "Toplevel262" 1
    set site_3_0 $top.cpd88
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel262" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable HierarchicalDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel262" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame19" vTcl:WidgetProc "Toplevel262" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button43" vTcl:WidgetProc "Toplevel262" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel262" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable HierarchicalOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel262" 1
    frame $site_5_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame1" vTcl:WidgetProc "Toplevel262" 1
    set site_6_0 $site_5_0.cpd72
    label $site_6_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab73" "Label2" vTcl:WidgetProc "Toplevel262" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable HierarchicalOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel262" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame21" vTcl:WidgetProc "Toplevel262" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd89 \
        \
        -command {global DirName DataDir HierarchicalOutputDir HierarchicalOutputSubDir
global OpenDirFile TreeInputParameterFile TreeInputStructureFile
global TreeInputNum
global TreeInputParaLabel TreeInputParaFile
global TreeNodeType TreeNodeClass
global TreeNodePara1 TreeNodePara2
global TreeNodeCoeff1 TreeNodeCoeff2
global TreeNodeCoeff3 TreeNodeOperator
global VarError ErrorMessage CONFIGDir
#DATA PROCESS SNGL
global Load_HierarchicalTreeArchitecture Load_HierarchicalInputParameters

if {$OpenDirFile == 0} {

if {$Load_HierarchicalInputParameters == 1} {
    Window hide $widget(Toplevel264); TextEditorRunTrace "Close Window Hierarchical Classification - Input Parameters Definition" "b"
    }
if {$Load_HierarchicalTreeArchitecture == 1} {
    Window hide $widget(Toplevel263); TextEditorRunTrace "Close Window Hierarchical Classification - Tree Structure Definition" "b"
    }

set HierarchicalDirOutputTmp $HierarchicalOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set HierarchicalOutputDir $DirName
    } else {
    set HierarchicalOutputDir $HierarchicalDirOutputTmp
    }

set TreeInputParameterFile "$HierarchicalOutputDir"
if {$HierarchicalOutputSubDir != ""} {append TreeInputParameterFile "/$HierarchicalOutputSubDir"}
append TreeInputParameterFile "/tree_parameters_list.txt"
if [file exists $TreeInputParameterFile] {
    } else {
    set TreeInputParameterFile "$CONFIGDir/tree_parameters_list.txt"
    } 
WaitUntilCreated $TreeInputParameterFile 
set config "true"
set f [open $TreeInputParameterFile r]
gets $f tmp
if {$tmp == "TREE INPUT PARAMETERS"} {
    gets $f TreeInputNum
    if {$TreeInputNum != 0} {
        for {set i 1} {$i <= $TreeInputNum} {incr i} {
            gets $f TreeInputParaLabel($i)
            gets $f TreeInputParaFile($i)
            if [file exists $TreeInputParaFile($i)] {
                } else {
                set config "false"
                }
            }
        }
    } else {
    set config "false"
    }
close $f
if {$config == "false" } {
    set TreeInputParameterFile "$CONFIGDir/tree_parameters_list.txt"
    WaitUntilCreated $TreeInputParameterFile 
    set f [open $TreeInputParameterFile r]
    gets $f tmp
    if {$tmp == "TREE INPUT PARAMETERS"} {
        gets $f TreeInputNum
        if {$TreeInputNum != 0} {
            for {set i 1} {$i <= $TreeInputNum} {incr i} {
                gets $f TreeInputParaLabel($i)
                gets $f TreeInputParaFile($i)
                }
            }
        }                
    close $f
    }

set TreeInputStructureFile "$HierarchicalOutputDir"
if {$HierarchicalOutputSubDir != ""} {append TreeInputStructureFile "/$HierarchicalOutputSubDir"}
append TreeInputStructureFile "/tree_structure.txt"
if [file exists $TreeInputStructureFile] {
    } else {
    set TreeInputStructureFile "$CONFIGDir/tree_structure.txt"
    } 
set config "true"
WaitUntilCreated $TreeInputStructureFile 
set f [open $TreeInputStructureFile r]
gets $f tmp
if {$tmp == "TREE STRUCTURE"} {
    for {set i 1} {$i < 64} {incr i} {
        gets $f tmp
        gets $f tmptype
        if {$tmptype == "node" } {
            set TreeNodeType($i) $tmptype
            gets $f tmp; set TreeNodePara1($i) $tmp
            gets $f tmp; set TreeNodePara2($i) $tmp
            gets $f tmp; set TreeNodeCoeff1($i) $tmp
            gets $f tmp; set TreeNodeCoeff2($i) $tmp
            gets $f tmp; set TreeNodeCoeff3($i) $tmp
            gets $f tmp; set TreeNodeOperator($i) $tmp
            }            
        if {$tmptype == "class" } {
            set TreeNodeType($i) $tmptype
            gets $f tmp; set TreeNodeClass($i) $tmp
            }            
        gets $f tmp
        }
    } else {
    set config "false"
    }
close $f
if {$config == "false" } {
    set TreeInputStructureFile "$CONFIGDir/tree_structure.txt"
    WaitUntilCreated $TreeInputStructureFile 
    set f [open $TreeInputStructureFile r]
    gets $f tmp
    if {$tmp == "TREE STRUCTURE"} {
        for {set i 1} {$i < 64} {incr i} {
            gets $f tmp
            gets $f tmptype
            if {$tmptype == "node" } {
                set TreeNodeType($i) $tmptype
                gets $f tmp; set TreeNodePara1($i) $tmp
                gets $f tmp; set TreeNodePara2($i) $tmp
                gets $f tmp; set TreeNodeCoeff1($i) $tmp
                gets $f tmp; set TreeNodeCoeff2($i) $tmp
                gets $f tmp; set TreeNodeCoeff3($i) $tmp
                gets $f tmp; set TreeNodeOperator($i) $tmp
                }            
            if {$tmptype == "class" } {
                set TreeNodeType($i) $tmptype
                gets $f tmp; set TreeNodeClass($i) $tmp
                }            
            gets $f tmp
            }
        }
    close $f
    }        
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd89 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra55 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra55" "Frame9" vTcl:WidgetProc "Toplevel262" 1
    set site_3_0 $top.fra55
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel262" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel262" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel262" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel262" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel262" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel262" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel262" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel262" 1
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
    TitleFrame $top.tit109 \
        -ipad 0 -text {Classification Configuration} 
    vTcl:DefineAlias "$top.tit109" "TitleFrame3" vTcl:WidgetProc "Toplevel262" 1
    bind $top.tit109 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit109 getframe]
    frame $site_4_0.cpd74
    set site_5_0 $site_4_0.cpd74
    checkbutton $site_5_0.che73 \
        \
        -command {global HierarchicalKmean HierarchicalIteration HierarchicalPourcentage

if {$HierarchicalKmean == 0} {
    set HierarchicalIteration ""
    set HierarchicalPourcentage ""
    $widget(Label262_1) configure -state disable
    $widget(Entry262_1) configure -state disable
    $widget(Entry262_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Label262_2) configure -state disable
    $widget(Entry262_2) configure -state disable
    $widget(Entry262_2) configure -disabledbackground $PSPBackgroundColor
     }
if {$HierarchicalKmean == 1} {
    set HierarchicalIteration 10
    set HierarchicalPourcentage 10
    $widget(Label262_1) configure -state normal
    $widget(Entry262_1) configure -state normal
    $widget(Entry262_1) configure -disabledbackground #FFFFFF
    $widget(Label262_2) configure -state normal
    $widget(Entry262_2) configure -state normal
    $widget(Entry262_2) configure -disabledbackground #FFFFFF
     }} \
        -text {K-Mean Procedure} -variable HierarchicalKmean 
    vTcl:DefineAlias "$site_5_0.che73" "Checkbutton1" vTcl:WidgetProc "Toplevel262" 1
    frame $site_5_0.fra74 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra74" "Frame3" vTcl:WidgetProc "Toplevel262" 1
    set site_6_0 $site_5_0.fra74
    frame $site_6_0.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra75" "Frame4" vTcl:WidgetProc "Toplevel262" 1
    set site_7_0 $site_6_0.fra75
    label $site_7_0.cpd77 \
        -text {Maximum Number of Iterations} 
    vTcl:DefineAlias "$site_7_0.cpd77" "Label262_1" vTcl:WidgetProc "Toplevel262" 1
    label $site_7_0.lab76 \
        -text {% of Pixels Switching Class} 
    vTcl:DefineAlias "$site_7_0.lab76" "Label262_2" vTcl:WidgetProc "Toplevel262" 1
    pack $site_7_0.cpd77 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.lab76 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    frame $site_6_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd78" "Frame6" vTcl:WidgetProc "Toplevel262" 1
    set site_7_0 $site_6_0.cpd78
    entry $site_7_0.ent79 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable HierarchicalIteration -width 5 
    vTcl:DefineAlias "$site_7_0.ent79" "Entry262_1" vTcl:WidgetProc "Toplevel262" 1
    entry $site_7_0.cpd80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable HierarchicalPourcentage -width 5 
    vTcl:DefineAlias "$site_7_0.cpd80" "Entry262_2" vTcl:WidgetProc "Toplevel262" 1
    pack $site_7_0.ent79 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd80 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.fra75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.che73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra74 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd73 \
        -ipad 0 -text {Input Parameters Specification} 
    vTcl:DefineAlias "$top.cpd73" "TitleFrame4" vTcl:WidgetProc "Toplevel262" 1
    bind $top.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd73 getframe]
    frame $site_4_0.cpd93 \
        -relief groove -height 77 -width 437 
    vTcl:DefineAlias "$site_4_0.cpd93" "Frame271" vTcl:WidgetProc "Toplevel262" 1
    set site_5_0 $site_4_0.cpd93
    label $site_5_0.lab42 \
        -text {Parameters File} -width 12 
    vTcl:DefineAlias "$site_5_0.lab42" "Label276" vTcl:WidgetProc "Toplevel262" 1
    entry $site_5_0.ent44 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TreeInputParameterFile 
    vTcl:DefineAlias "$site_5_0.ent44" "Entry189" vTcl:WidgetProc "Toplevel262" 1
    frame $site_5_0.cpd94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd94" "Frame23" vTcl:WidgetProc "Toplevel262" 1
    set site_6_0 $site_5_0.cpd94
    button $site_6_0.cpd105 \
        \
        -command {global OpenDirFile FileName HierarchicalDirInput TreeInputParameterFile
global TreeInputNum TreeInputParaLabel TreeInputParaFile
global VarError ErrorMessage
#DATA PROCESS SNGL
global Load_HierarchicalInputParameters

if {$OpenDirFile == 0} {

if {$Load_HierarchicalInputParameters == 1} {
    Window hide $widget(Toplevel264); TextEditorRunTrace "Close Window Hierarchical Classification - Input Parameters Definition" "b"
    }

set TreeInputParameterFileTmp $TreeInputParameterFile

set types {
{{TXT Files}        {.txt}        }
}
set FileName ""
OpenFile "$HierarchicalDirInput" $types "TREE INPUT PARAMETERS FILE"
if {$FileName != ""} {
    set TreeInputParameterFile $FileName
    } else {
    set TreeInputParameterFile $TreeInputParameterFileTmp
    }

WaitUntilCreated $TreeInputParameterFile 
if [file exists $TreeInputParameterFile] {
    set f [open $TreeInputParameterFile r]
    gets $f tmp
    if {$tmp == "TREE INPUT PARAMETERS"} {
        set config "true"
        gets $f TreeInputNum
        if {$TreeInputNum != 0 } {
            for {set i 1} {$i <= $TreeInputNum} {incr i} {
                gets $f TreeInputParaLabel($i)
                gets $f TreeInputParaFile($i)
                if [file exists $TreeInputParaFile($i)] {
                    } else {
                    set config "false"
                    }
                }
            if {$config == "false" } {
                for {set i 1} {$i <= $TreeInputNum} {incr i} {
                    set TreeInputParaLabel($i) "XX"
                    set TreeInputParaFile($i) "XX"
                    }
                set TreeInputNum 0; set TreeNum 0
                set VarError ""
                set ErrorMessage "WRONG TREE INPUT PARAMETERS ARGUMENTS"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set TreeInputParameterFile $TreeInputParameterFileTmp
                }
            }
        close $f
        } else {
        set VarError ""
        set ErrorMessage "TREE INPUT PARAMETERS FILE NOT VALID"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set TreeInputParameterFile $TreeInputParameterFileTmp
        }
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd105" "Button20" vTcl:WidgetProc "Toplevel262" 1
    bindtags $site_6_0.cpd105 "$site_6_0.cpd105 Button $top all _vTclBalloon"
    bind $site_6_0.cpd105 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd105 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.lab42 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.ent44 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd106 \
        -borderwidth 2 -height 123 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd106" "Frame280" vTcl:WidgetProc "Toplevel262" 1
    set site_5_0 $site_4_0.cpd106
    frame $site_5_0.fra23 \
        -borderwidth 2 -height 123 -width 125 
    vTcl:DefineAlias "$site_5_0.fra23" "Frame475" vTcl:WidgetProc "Toplevel262" 1
    set site_6_0 $site_5_0.fra23
    button $site_6_0.but68 \
        -background #ffff00 \
        -command {global OpenDirFile
global TreeInputNum TreeNum
global TreeParaLabel TreeInputParaLabel
global TreeParaFile TreeInputParaFile
#DATA PROCESS SNGL
global Load_HierarchicalInputParameters PSPTopLevel

if {$OpenDirFile == 0} {

if {$Load_HierarchicalInputParameters == 0} {
    source "GUI/data_process_sngl/HierarchicalInputParameters.tcl"
    set Load_HierarchicalInputParameters 1
    WmTransient $widget(Toplevel264) $PSPTopLevel
    }

if {$TreeInputNum == 0 } {
    set TreeNum ""
    set TreeParaLabel ""
    set TreeParaFile ""
    $widget(Label264_1) configure -state disable
    $widget(Entry264_1) configure -state disable
    $widget(Entry264_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Label264_2) configure -state disable
    $widget(Entry264_2) configure -state disable
    $widget(Entry264_2) configure -disabledbackground $PSPBackgroundColor
    $widget(Button264_1) configure -state disable
    $widget(Button264_2) configure -state disable
    $widget(Button264_3) configure -state disable
    } else {
    set TreeNum 1
    set TreeParaLabel $TreeInputParaLabel(1)
    set TreeParaFile $TreeInputParaFile(1)
    $widget(Label264_1) configure -state normal
    $widget(Entry264_1) configure -state normal
    $widget(Entry264_1) configure -disabledbackground #FFFFFF
    $widget(Label264_2) configure -state normal
    $widget(Entry264_2) configure -state disable
    $widget(Entry264_2) configure -disabledbackground #FFFFFF
    $widget(Button264_1) configure -state normal
    $widget(Button264_2) configure -state normal
    $widget(Button264_3) configure -state normal
    }
WidgetShowFromWidget $widget(Toplevel262) $widget(Toplevel264); TextEditorRunTrace "Open Window Hierarchical Classification - Input Parameters Definition" "b"
}} \
        -padx 4 -pady 2 -text {Input Parameters List Editor} 
    vTcl:DefineAlias "$site_6_0.but68" "Button644" vTcl:WidgetProc "Toplevel262" 1
    pack $site_6_0.but68 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra23 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd106 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd103 \
        -ipad 0 -text {Hierarchical Structure Definition} 
    vTcl:DefineAlias "$top.cpd103" "TitleFrame1" vTcl:WidgetProc "Toplevel262" 1
    bind $top.cpd103 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd103 getframe]
    frame $site_4_0.cpd93 \
        -relief groove -height 77 -width 437 
    vTcl:DefineAlias "$site_4_0.cpd93" "Frame270" vTcl:WidgetProc "Toplevel262" 1
    set site_5_0 $site_4_0.cpd93
    label $site_5_0.lab42 \
        -text {Structure File} -width 12 
    vTcl:DefineAlias "$site_5_0.lab42" "Label275" vTcl:WidgetProc "Toplevel262" 1
    entry $site_5_0.ent44 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable TreeInputStructureFile 
    vTcl:DefineAlias "$site_5_0.ent44" "Entry188" vTcl:WidgetProc "Toplevel262" 1
    frame $site_5_0.cpd94 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd94" "Frame22" vTcl:WidgetProc "Toplevel262" 1
    set site_6_0 $site_5_0.cpd94
    button $site_6_0.cpd105 \
        \
        -command {global OpenDirFile FileName HierarchicalDirInput TreeInputStructureFile
global TreeNodeType TreeNodeClass
global TreeNodePara1 TreeNodePara2
global TreeNodeCoeff1 TreeNodeCoeff2
global TreeNodeCoeff3 TreeNodeOperator
global VarError ErrorMessage
#DATA PROCESS SNGL
global Load_HierarchicalTreeArchitecture

if {$OpenDirFile == 0} {

if {$Load_HierarchicalTreeArchitecture == 1} {
    Window hide $widget(Toplevel263); TextEditorRunTrace "Close Window Hierarchical Classification - Tree Structure Definition" "b"
    }

set TreeInputStructureFileTmp $TreeInputStructureFile

set types {
{{TXT Files}        {.txt}        }
}
set FileName ""
OpenFile "$HierarchicalDirInput" $types "TREE STRUCTURE FILE"
if {$FileName != ""} {
    set TreeInputStructureFile $FileName
    } else {
    set TreeInputStructureFile $TreeInputStructureFileTmp
    }


WaitUntilCreated $TreeInputStructureFile 
if [file exists $TreeInputStructureFile] {
    set f [open $TreeInputStructureFile r]
    gets $f tmp
    if {$tmp == "TREE STRUCTURE"} {
        for {set i 1} {$i < 64} {incr i} {
            gets $f tmp
            gets $f tmptype
            if {$tmptype == "node" } {
                set TreeNodeType($i) $tmptype
                gets $f tmp; set TreeNodePara1($i) $tmp
                gets $f tmp; set TreeNodePara2($i) $tmp
                gets $f tmp; set TreeNodeCoeff1($i) $tmp
                gets $f tmp; set TreeNodeCoeff2($i) $tmp
                gets $f tmp; set TreeNodeCoeff3($i) $tmp
                gets $f tmp; set TreeNodeOperator($i) $tmp
                }            
            if {$tmptype == "class" } {
                set TreeNodeType($i) $tmptype
                gets $f tmp; set TreeNodeClass($i) $tmp
                }            
            gets $f tmp
            }
        }                
    close $f
    } else {
    set VarError ""
    set ErrorMessage "TREE STRUCTURE FILE NOT VALID"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set TreeInputParameterFile $TreeInputParameterFileTmp
    }
}} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd105" "Button19" vTcl:WidgetProc "Toplevel262" 1
    bindtags $site_6_0.cpd105 "$site_6_0.cpd105 Button $top all _vTclBalloon"
    bind $site_6_0.cpd105 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd105 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.lab42 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.ent44 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd106 \
        -borderwidth 2 -height 123 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd106" "Frame279" vTcl:WidgetProc "Toplevel262" 1
    set site_5_0 $site_4_0.cpd106
    frame $site_5_0.fra23 \
        -borderwidth 2 -height 123 -width 125 
    vTcl:DefineAlias "$site_5_0.fra23" "Frame474" vTcl:WidgetProc "Toplevel262" 1
    set site_6_0 $site_5_0.fra23
    button $site_6_0.but68 \
        -background #ffff00 \
        -command {global OpenDirFile TreeInputNum
global TreePara1 TreePara1Id TreePara2 TreePara2Id
global TreeInputNum TreeInputParaLabel
global ImageSymbolClass ImageSymbolNode ImageSymbolVide
global ImageSymbolHorz ImageSymbolVert ImageSymbolRightCorner
global ImageSymbolLeftCorner ImageSymbolRightDiag ImageSymbolLeftDiag
global ImageSymbolActive VarError ErrorMessage
#DATA PROCESS SNGL
global Load_HierarchicalTreeArchitecture PSPTopLevel

if {$OpenDirFile == 0} {

if {$TreeInputNum != 0} {

if {$Load_HierarchicalTreeArchitecture == 0} {
    source "GUI/data_process_sngl/HierarchicalTreeArchitecture.tcl"
    set Load_HierarchicalTreeArchitecture 1
    WmTransient .top263 $PSPTopLevel
    package require Img
    image create photo ImageSymbolClass -file "GUI/Images/TreeClass.gif"
    image create photo ImageSymbolNode -file "GUI/Images/TreeNode.gif"
    image create photo ImageSymbolVide -file "GUI/Images/TreeVide.gif"
    image create photo ImageSymbolHorz -file "GUI/Images/TreeHorzLine.gif"
    image create photo ImageSymbolVert -file "GUI/Images/TreeVertLine.gif"
    image create photo ImageSymbolRightCorner -file "GUI/Images/TreeRightCorner.gif"
    image create photo ImageSymbolLeftCorner -file "GUI/Images/TreeLeftCorner.gif"
    image create photo ImageSymbolRightDiag -file "GUI/Images/TreeRightDiag.gif"
    image create photo ImageSymbolLeftDiag -file "GUI/Images/TreeLeftDiag.gif"
    image create photo ImageSymbolActive -file "GUI/Images/TreeActive.gif"
    }

set TreePara1 $TreeInputParaLabel(1); set TreePara1Id 0
set TreePara2 $TreeInputParaLabel(1); set TreePara2Id 0
set TreeLabelString ""
for {set i 1} {$i <= $TreeInputNum} {incr i} { lappend TreeLabelString $TreeInputParaLabel($i) }
.top263.fra118.fra73.cpd74.f.fra75.cpd76.cpd74 configure -values $TreeLabelString
.top263.fra118.fra73.cpd74.f.fra75.cpd77.cpd75 configure -values $TreeLabelString
TreeInitWidget
TreeConstructStructure
WidgetShowFromWidget $widget(Toplevel262) $widget(Toplevel263); TextEditorRunTrace "Open Window Hierarchical Classification - Tree Structure Definition" "b"
} else {
set VarError ""
set ErrorMessage "TREE INPUT PARAMETERS LIST NOT CREATED"
Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
tkwait variable VarError
}
}} \
        -padx 4 -pady 2 -text {Hierarchical Structure Editor} 
    vTcl:DefineAlias "$site_6_0.but68" "Button643" vTcl:WidgetProc "Toplevel262" 1
    pack $site_6_0.but68 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra23 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd106 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd100 \
        -ipad 0 -text {Color Maps} 
    vTcl:DefineAlias "$top.cpd100" "TitleFrame2" vTcl:WidgetProc "Toplevel262" 1
    bind $top.cpd100 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd100 getframe]
    frame $site_4_0.fra90 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra90" "Frame2" vTcl:WidgetProc "Toplevel262" 1
    set site_5_0 $site_4_0.fra90
    frame $site_5_0.fra91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra91" "Frame8" vTcl:WidgetProc "Toplevel262" 1
    set site_6_0 $site_5_0.fra91
    label $site_6_0.cpd95 \
        -text {ColorMap 32} -width 12 
    vTcl:DefineAlias "$site_6_0.cpd95" "Label126" vTcl:WidgetProc "Toplevel262" 1
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side top 
    frame $site_5_0.fra92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra92" "Frame10" vTcl:WidgetProc "Toplevel262" 1
    set site_6_0 $site_5_0.fra92
    button $site_6_0.but80 \
        \
        -command {global FileName HierarchicalDirInput ColorMapHierarchical32

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$HierarchicalDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMapHierarchical32 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but80" "Button1" vTcl:WidgetProc "Toplevel262" 1
    bindtags $site_6_0.but80 "$site_6_0.but80 Button $top all _vTclBalloon"
    bind $site_6_0.but80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    button $site_6_0.cpd102 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_6_0.cpd102 {global ColorMapHierarchical32 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette OpenDirFile
#BMP PROCESS
global Load_colormap2 PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_colormap2 == 0} {
    source "GUI/bmp_process/colormap2.tcl"
    set Load_colormap2 1
    WmTransient .top254 $PSPTopLevel
    }

set ColorMapNumber 32
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
if [file exists $ColorMapHierarchical32] {
    set f [open $ColorMapHierarchical32 r]
    gets $f tmp
    gets $f tmp
    gets $f tmp
    for {set i 0} {$i < $ColorNumber} {incr i} {
        gets $f couleur
        set RedPalette($i) [lindex $couleur 0]
        set GreenPalette($i) [lindex $couleur 1]
        set BluePalette($i) [lindex $couleur 2]
        }
    close $f
    }
 
set c1 .top254.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top254.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top254.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top254.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top254.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top254.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top254.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top254.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top254.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top254.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top254.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top254.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top254.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top254.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top254.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top254.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur
set c17 .top254.cpd73.but36
set couleur [format "#%02x%02x%02x" $RedPalette(17) $GreenPalette(17) $BluePalette(17)]    
$c17 configure -background $couleur
set c18 .top254.cpd73.but37
set couleur [format "#%02x%02x%02x" $RedPalette(18) $GreenPalette(18) $BluePalette(18)]    
$c18 configure -background $couleur
set c19 .top254.cpd73.but38
set couleur [format "#%02x%02x%02x" $RedPalette(19) $GreenPalette(19) $BluePalette(19)]    
$c19 configure -background $couleur
set c20 .top254.cpd73.but39
set couleur [format "#%02x%02x%02x" $RedPalette(20) $GreenPalette(20) $BluePalette(20)]    
$c20 configure -background $couleur
set c21 .top254.cpd73.but40
set couleur [format "#%02x%02x%02x" $RedPalette(21) $GreenPalette(21) $BluePalette(21)]    
$c21 configure -background $couleur
set c22 .top254.cpd73.but41
set couleur [format "#%02x%02x%02x" $RedPalette(22) $GreenPalette(22) $BluePalette(22)]    
$c22 configure -background $couleur
set c23 .top254.cpd73.but42
set couleur [format "#%02x%02x%02x" $RedPalette(23) $GreenPalette(23) $BluePalette(23)]    
$c23 configure -background $couleur
set c24 .top254.cpd73.but43
set couleur [format "#%02x%02x%02x" $RedPalette(24) $GreenPalette(24) $BluePalette(24)]    
$c24 configure -background $couleur
set c25 .top254.cpd73.but44
set couleur [format "#%02x%02x%02x" $RedPalette(25) $GreenPalette(25) $BluePalette(25)]    
$c25 configure -background $couleur
set c26 .top254.cpd73.but45
set couleur [format "#%02x%02x%02x" $RedPalette(26) $GreenPalette(26) $BluePalette(26)]    
$c26 configure -background $couleur
set c27 .top254.cpd73.but46
set couleur [format "#%02x%02x%02x" $RedPalette(27) $GreenPalette(27) $BluePalette(27)]    
$c27 configure -background $couleur
set c28 .top254.cpd73.but47
set couleur [format "#%02x%02x%02x" $RedPalette(28) $GreenPalette(28) $BluePalette(28)]    
$c28 configure -background $couleur
set c29 .top254.cpd73.but48
set couleur [format "#%02x%02x%02x" $RedPalette(29) $GreenPalette(29) $BluePalette(29)]    
$c29 configure -background $couleur
set c30 .top254.cpd73.but49
set couleur [format "#%02x%02x%02x" $RedPalette(30) $GreenPalette(30) $BluePalette(30)]    
$c30 configure -background $couleur
set c31 .top254.cpd73.but50
set couleur [format "#%02x%02x%02x" $RedPalette(31) $GreenPalette(31) $BluePalette(31)]    
$c31 configure -background $couleur
set c32 .top254.cpd73.but51
set couleur [format "#%02x%02x%02x" $RedPalette(32) $GreenPalette(32) $BluePalette(32)]    
$c32 configure -background $couleur

.top254.fra35.but38 configure -state normal
   
set VarColorMap ""
set ColorMapIn $ColorMapHierarchical32
set ColorMapOut $ColorMapHierarchical32
WidgetShowFromWidget $widget(Toplevel262) $widget(Toplevel254); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapHierarchical32 $ColorMapOut
   }
}}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd102" "Button42" vTcl:WidgetProc "Toplevel262" 1
    bindtags $site_6_0.cpd102 "$site_6_0.cpd102 Button $top all _vTclBalloon"
    bind $site_6_0.cpd102 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    pack $site_6_0.but80 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd102 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame11" vTcl:WidgetProc "Toplevel262" 1
    set site_6_0 $site_5_0.fra93
    entry $site_6_0.cpd97 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMapHierarchical32 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd97" "Entry262" vTcl:WidgetProc "Toplevel262" 1
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra91 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side left 
    pack $site_5_0.fra92 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.fra90 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel262" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global HierarchicalDirInput HierarchicalDirOutput HierarchicalOutputDir HierarchicalOutputSubDir
global HierarchicalKmean HierarchicalPourcentage HierarchicalIteration
global BMPHierarchical HierarchicalHAAlphaClassifFonction
global ColorMapHierarchical32 TMPTreeClassRulesTxt TMPTreeClassPrmListTxt
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2 OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set HierarchicalDirOutput $HierarchicalOutputDir
if {$HierarchicalOutputSubDir != ""} {append HierarchicalDirOutput "/$HierarchicalOutputSubDir"}

    #####################################################################
    #Create Directory
    set HierarchicalDirOutput [PSPCreateDirectoryMask $HierarchicalDirOutput $HierarchicalOutputDir $HierarchicalDirInput]
    #####################################################################       
    
if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "ColorMap16"; set TestVarType(4) "file"; set TestVarValue(4) $ColorMapHierarchical32; set TestVarMin(4) ""; set TestVarMax(4) ""
    if {$HierarchicalKmean == 1} {
        set TestVarName(5) "Pourcentage"; set TestVarType(5) "float"; set TestVarValue(5) $HierarchicalPourcentage; set TestVarMin(5) "0"; set TestVarMax(5) "100"
        set TestVarName(6) "Iteration"; set TestVarType(6) "int"; set TestVarValue(6) $HierarchicalIteration; set TestVarMin(6) "1"; set TestVarMax(6) "100"
        TestVar 7
        } else {
        TestVar 5
        }

    if {$TestVarError == "ok"} {
        if {$HierarchicalKmean == 0} { 
            set HPo 0; set HIt 0
            } else {
            set HPo $HierarchicalPourcentage; set HIt $HierarchicalIteration
            }
        TreeWriteFiles
        set Fonction "Creation of all the Binary Data and BMP Files"
        set Fonction2 "of the Rule-Based Hierarchical Classification"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/tree_classifier.exe" "k"
        TextEditorRunTrace "Arguments: -od \x22$HierarchicalDirOutput\x22 -irf \x22$TMPTreeClassRulesTxt\x22 -ipf \x22$TMPTreeClassPrmListTxt\x22 -fnr $FinalNlig -fnc $FinalNcol -nit $HIt -pct $HPo -col \x22$ColorMapHierarchical32\x22" "k"
        set f [ open "| Soft/data_process_sngl/tree_classifier.exe -od \x22$HierarchicalDirOutput\x22 -irf \x22$TMPTreeClassRulesTxt\x22 -ipf \x22$TMPTreeClassPrmListTxt\x22 -fnr $FinalNlig -fnc $FinalNcol -nit $HIt -pct $HPo -col \x22$ColorMapHierarchical32\x22" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set ClassificationFile "$HierarchicalDirOutput/tree_class.bin"
        if [file exists $ClassificationFile] {EnviWriteConfigClassif $ClassificationFile $FinalNlig $FinalNcol 4 $ColorMapHierarchical32 32}
        set ClassificationFile "$HierarchicalDirOutput/kmeans_tree_class.bin"
        if [file exists $ClassificationFile] {EnviWriteConfigClassif $ClassificationFile $FinalNlig $FinalNcol 4 $ColorMapHierarchical32 32}
        } 

    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel262); TextEditorRunTrace "Close Window Rule-Based Hierarchical Classification" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button262_4" vTcl:WidgetProc "Toplevel262" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command { HelpPdfEdit "Help/HierarchicalSupervisedClassification.pdf" } \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel262" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
#DATA PROCESS SNGL
global Load_HierarchicalInputParameters Load_HierarchicalTreeArchitecture

if {$OpenDirFile == 0} {

if {$Load_HierarchicalInputParameters == 1} {
    Window hide $widget(Toplevel264); TextEditorRunTrace "Close Window Hierarchical Classification - Input Parameters Definition" "b"
    }
if {$Load_HierarchicalTreeArchitecture == 1} {
    Window hide $widget(Toplevel263); TextEditorRunTrace "Close Window Hierarchical Classification - Tree Structure Definition" "b"
    }

Window hide $widget(Toplevel262); TextEditorRunTrace "Close Window Rule-Based Hierarchical Classification" "b"

}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel262" 1
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
    pack $top.cpd88 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra55 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit109 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd103 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd100 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra59 \
        -in $top -anchor center -expand 1 -fill x -side bottom 

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
Window show .top262

main $argc $argv
