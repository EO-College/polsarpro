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

        {{[file join . GUI Images GF3.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
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
    set base .top463
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab66 {
        array set save {-image 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.cpd114 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd72 getframe]
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
    namespace eval ::widgets::$base.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra73
    namespace eval ::widgets::$site_3_0.fra66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra66
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra76
    namespace eval ::widgets::$site_4_0.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra77
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd79
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd80
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd79
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd80
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd81
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd80
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd77
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
    namespace eval ::widgets::$site_6_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd116 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd120 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd117 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd121 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd118 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd122 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra70 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra70
    namespace eval ::widgets::$site_3_0.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra71
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab77 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.lab77 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd75
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab79 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent80 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd73
    namespace eval ::widgets::$site_5_0.lab79 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent80 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra71
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
            vTclWindow.top463
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
    wm geometry $top 200x200+75+75; update
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

proc vTclWindow.top463 {base} {
    if {$base == ""} {
        set base .top463
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
    wm geometry $top 500x630+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 120 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "GF3 Input Data File"
    vTcl:DefineAlias "$top" "Toplevel463" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab66 \
        -image [vTcl:image:get_image [file join . GUI Images GF3.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab66" "Label281" vTcl:WidgetProc "Toplevel463" 1
    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame1" vTcl:WidgetProc "Toplevel463" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel463" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable GF3DirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel463" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd114 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd114" "Button39" vTcl:WidgetProc "Toplevel463" 1
    pack $site_6_0.cpd114 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd71 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$top.cpd71" "TitleFrame463" vTcl:WidgetProc "Toplevel463" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable GF3DirOutput 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry463" vTcl:WidgetProc "Toplevel463" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame29" vTcl:WidgetProc "Toplevel463" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global DirName DataDir GF3DirOutput
global VarWarning WarningMessage WarningMessage2

set GF3OutputDirTmp $GF3DirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set GF3DirOutput $DirName
        } else {
        set GF3DirOutput $GF3OutputDirTmp
        }
    } else {
    set GF3DirOutput $GF3OutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button463" vTcl:WidgetProc "Toplevel463" 1
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
    TitleFrame $top.cpd72 \
        -ipad 0 -text {SAR Product File} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame220" vTcl:WidgetProc "Toplevel463" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable GF3ProductFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry220" vTcl:WidgetProc "Toplevel463" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame30" vTcl:WidgetProc "Toplevel463" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global FileName GF3DirInput GF3ProductFile

set types {
    {{XML Files}        {.xml}        }
    {{All Files}        *        }
    }
set FileName ""
OpenFile $GF3DirInput $types "SAR PRODUCT FILE"
set GF3ProductFile $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button220" vTcl:WidgetProc "Toplevel463" 1
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
    frame $top.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra73" "Frame4" vTcl:WidgetProc "Toplevel463" 1
    set site_3_0 $top.fra73
    frame $site_3_0.fra66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra66" "Frame2" vTcl:WidgetProc "Toplevel463" 1
    set site_4_0 $site_3_0.fra66
    button $site_4_0.cpd67 \
        -background #ffff00 \
        -command {global GF3DirInput GF3DirOutput GF3FileInputFlag GF3ProductFile
global GF3Mode GF3Orbit GF3Direction GF3Type GF3Level GF3Polar GF3Frequency 
global GF3IncAng GF3IncAngNear GF3IncAngFar GF3PixRow GF3PixCol GF3DataFormat
global GF3QualifyValueHH GF3QualifyValueHV GF3QualifyValueVH GF3QualifyValueVV
global FileInput1 FileInput2 FileInput3 FileInput4
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPGf3Config TMPGoogle OpenDirFile PolarType
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global VarAdvice WarningMessage WarningMessage2 WarningMessage3 WarningMessage4

if {$OpenDirFile == 0} {

#####################################################################
#Create Directory
set GF3DirOutput [PSPCreateDirectoryMask $GF3DirOutput $GF3DirOutput $GF3DirInput]
#####################################################################       

if {"$VarWarning"=="ok"} {

DeleteFile $TMPGf3Config
DeleteFile $TMPGoogle

if [file exists $GF3ProductFile] {
    set GF3File "$GF3DirOutput/product_header.txt"
    set Sensor "gf3"
    ReadXML $GF3ProductFile $GF3File $TMPGf3Config $Sensor
    WaitUntilCreated $TMPGf3Config
    if [file exists $TMPGf3Config] {
        set f [open $TMPGf3Config r]
        gets $f GF3Orbit
        gets $f GF3Mode
        gets $f GF3Frequency
        gets $f GF3Direction
        gets $f GF3Level
        gets $f GF3Type
        gets $f GF3Polar
        gets $f GoogleLatCenter
        gets $f GoogleLongCenter
        gets $f GoogleLat00
        gets $f GoogleLong00
        gets $f GoogleLat0N
        gets $f GoogleLong0N
        gets $f GoogleLatN0
        gets $f GoogleLongN0
        gets $f GoogleLatNN
        gets $f GoogleLongNN
        gets $f NcolFullSize
        gets $f NligFullSize
        gets $f GF3PixCol
        gets $f GF3PixRow
        gets $f GF3QualifyValueHH
        gets $f GF3QualifyValueHV
        gets $f GF3QualifyValueVH
        gets $f GF3QualifyValueVV
        gets $f GF3IncAngNear
        gets $f GF3IncAngFar
        close $f

        set GF3IncAng [expr ($GF3IncAngNear + $GF3IncAngFar) / 2 ]

        if {$GF3Type == "SLC" } {
            if {$GF3Polar == "AHV" } {
                set PolarType "full"

                if {$GF3Orbit == "ASC" } { set GF3AntennaPass "A" } else { set GF3AntennaPass "D" }
                if {$GF3Direction == "Right" } { append GF3AntennaPass "R" } else { append GF3AntennaPass "L" }
                set f [open "$GF3DirOutput/config_acquisition.txt" w]
                puts $f $GF3AntennaPass
                puts $f [expr ($GF3IncAngNear + $GF3IncAngFar) / 2 ]
                puts $f $GF3PixCol
                puts $f $GF3PixRow
                close $f

                $widget(Button463_01) configure -state normal; 

                $widget(Label463_01) configure -state normal; $widget(Entry463_01) configure -disabledbackground #FFFFFF
                $widget(Label463_02) configure -state normal; $widget(Entry463_02) configure -disabledbackground #FFFFFF
                $widget(Label463_03) configure -state normal; $widget(Entry463_03) configure -disabledbackground #FFFFFF
                $widget(Label463_04) configure -state normal; $widget(Entry463_04) configure -disabledbackground #FFFFFF
                $widget(Label463_05) configure -state normal; $widget(Entry463_05) configure -disabledbackground #FFFFFF
                $widget(Label463_06) configure -state normal; $widget(Entry463_06) configure -disabledbackground #FFFFFF
                $widget(Label463_07) configure -state normal; $widget(Entry463_07) configure -disabledbackground #FFFFFF
                $widget(Label463_08) configure -state normal; $widget(Entry463_08) configure -disabledbackground #FFFFFF
                $widget(Label463_09) configure -state normal; $widget(Entry463_09) configure -disabledbackground #FFFFFF
                $widget(Label463_10) configure -state normal; $widget(Entry463_10) configure -disabledbackground #FFFFFF
                $widget(Label463_11) configure -state normal; $widget(Entry463_11) configure -disabledbackground #FFFFFF
                $widget(Label463_12) configure -state normal; $widget(Entry463_12) configure -disabledbackground #FFFFFF

                set FileData [file rootname $GF3ProductFile]; set FileData [file rootname $FileData]
                set FileDataInit [string first AHV $FileData]; set FileDataEnd [expr $FileDataInit + 2]
                $widget(TitleFrame463_1) configure -state normal
                $widget(Entry463_1) configure -disabledbackground #FFFFFF; $widget(Button463_1) configure -state normal
                set FileInput [string replace $FileData $FileDataInit $FileDataEnd HH]; append FileInput ".tiff"
                if [file exists $FileInput] {set FileInput1 $FileInput } else { set FileInput1 "ENTER INPUT DATA FILE S11" }
                $widget(TitleFrame463_2) configure -state normal
                $widget(Entry463_2) configure -disabledbackground #FFFFFF; $widget(Button463_2) configure -state normal
                set FileInput [string replace $FileData $FileDataInit $FileDataEnd HV]; append FileInput ".tiff"
                if [file exists $FileInput] {set FileInput2 $FileInput } else { set FileInput2 "ENTER INPUT DATA FILE S12" }
                $widget(TitleFrame463_3) configure -state normal
                $widget(Entry463_3) configure -disabledbackground #FFFFFF; $widget(Button463_3) configure -state normal
                set FileInput [string replace $FileData $FileDataInit $FileDataEnd VH]; append FileInput ".tiff"
                if [file exists $FileInput] {set FileInput3 $FileInput } else { set FileInput3 "ENTER INPUT DATA FILE S21" }
                $widget(TitleFrame463_4) configure -state normal
                $widget(Entry463_4) configure -disabledbackground #FFFFFF; $widget(Button463_4) configure -state normal
                set FileInput [string replace $FileData $FileDataInit $FileDataEnd VV]; append FileInput ".tiff"
                if [file exists $FileInput] {set FileInput4 $FileInput } else { set FileInput4 "ENTER INPUT DATA FILE S22" }

                $widget(Button463_6) configure -state normal

                set f [open "$GF3DirOutput/GEARTH_POLY.kml" w]
                puts $f "<!-- ?xml version=\"1.0\" encoding=\"UTF-8\"? -->"
                puts $f "<kml xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
                puts $f "<Placemark>"
                puts $f "<name>"
                puts $f "Image GF3"
                puts $f "</name>"
                puts $f "<LookAt>"
                puts $f "<longitude>"
                puts $f "$GoogleLongCenter"
                puts $f "</longitude>"
                puts $f "<latitude>"
                puts $f "$GoogleLatCenter"
                puts $f "</latitude>"
                puts $f "<range>"
                puts $f "250000.0"
                puts $f "</range>"
                puts $f "<tilt>0</tilt>"
                puts $f "<heading>0</heading>"
                puts $f "</LookAt>"
                puts $f "<Style>"
                puts $f "<LineStyle>"
                puts $f "<color>ff0000ff</color>"
                puts $f "<width>4</width>"
                puts $f "</LineStyle>"
                puts $f "</Style>"
                puts $f "<LineString>"
                puts $f "<coordinates>"
                puts $f "$GoogleLong00,$GoogleLat00,8000.0"
                puts $f "$GoogleLongN0,$GoogleLatN0,8000.0"
                puts $f "$GoogleLongNN,$GoogleLatNN,8000.0"
                puts $f "$GoogleLong0N,$GoogleLat0N,8000.0"
                puts $f "$GoogleLong00,$GoogleLat00,8000.0"
                puts $f "</coordinates>"
                puts $f "</LineString>"
                puts $f "</Placemark>"
                puts $f "</kml>"
                close $f
                $widget(Button463_02) configure -state normal
                } else {
                set ErrorMessage "ERROR IN THE GF-3 DATA FORMAT (QUAD)"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set GF3ProductFile ""; set GF3FileInputFlag 0
                MenuRAZ
                ClosePSPViewer
                CloseAllWidget
                Window hide $widget(Toplevel463); TextEditorRunTrace "Close Window GF3 Input File" "b"
                }
            } else {
            set ErrorMessage "ERROR IN THE GF-3 DATA TYPE (SLC - Complex)"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set GF3ProductFile ""; set GF3FileInputFlag 0
            MenuRAZ
            ClosePSPViewer
            CloseAllWidget
            Window hide $widget(Toplevel463); TextEditorRunTrace "Close Window GF3 Input File" "b"
            }
        } else {
        set ErrorMessage "PRODUCT FILE IS NOT AN XML FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set GF3ProductFile ""
        }
        #TMPGF3Config Exists
    } else {
    set ErrorMessage "ENTER THE XML - PRODUCT FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set GF3ProductFile ""; set GF3FileInputFlag 0
    }
    #ProductFile Exists
}
#VarWarning
}
#OpenDirFile} \
        -padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_4_0.cpd67" "Button2" vTcl:WidgetProc "Toplevel463" 1
    button $site_4_0.cpd68 \
        -background #ffff00 \
        -command {global FileName VarError ErrorMessage GF3DirOutput
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

set GF3File "$GF3DirOutput/product_header.txt"
if [file exists $GF3File] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top463 $GF3File
    }} \
        -padx 4 -pady 2 -text {Edit Header} 
    vTcl:DefineAlias "$site_4_0.cpd68" "Button463_01" vTcl:WidgetProc "Toplevel463" 1
    button $site_4_0.cpd69 \
        \
        -command {global FileName VarError ErrorMessage GF3DirInput

set GF3File "$GF3DirInput/GEARTH_POLY.kml"
if [file exists $GF3File] {
    GoogleEarth $GF3File
    }} \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -padx 4 -pady 2 -text Google 
    vTcl:DefineAlias "$site_4_0.cpd69" "Button463_02" vTcl:WidgetProc "Toplevel463" 1
    bindtags $site_4_0.cpd69 "$site_4_0.cpd69 Button $top all _vTclBalloon"
    bind $site_4_0.cpd69 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Google Earth}
    }
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side top 
    frame $site_3_0.fra76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra76" "Frame5" vTcl:WidgetProc "Toplevel463" 1
    set site_4_0 $site_3_0.fra76
    frame $site_4_0.fra77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra77" "Frame15" vTcl:WidgetProc "Toplevel463" 1
    set site_5_0 $site_4_0.fra77
    frame $site_5_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame6" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd78
    label $site_6_0.lab82 \
        -text Mode 
    vTcl:DefineAlias "$site_6_0.lab82" "Label463_01" vTcl:WidgetProc "Toplevel463" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GF3Mode -width 7 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry463_01" vTcl:WidgetProc "Toplevel463" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd79" "Frame16" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd79
    label $site_6_0.lab82 \
        -text Orbit 
    vTcl:DefineAlias "$site_6_0.lab82" "Label463_02" vTcl:WidgetProc "Toplevel463" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GF3Orbit -width 5 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry463_02" vTcl:WidgetProc "Toplevel463" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd80 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd80" "Frame17" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd80
    label $site_6_0.lab82 \
        -text Direction 
    vTcl:DefineAlias "$site_6_0.lab82" "Label463_03" vTcl:WidgetProc "Toplevel463" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GF3Direction -width 7 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry463_03" vTcl:WidgetProc "Toplevel463" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd82" "Frame21" vTcl:WidgetProc "Toplevel463" 1
    set site_5_0 $site_4_0.cpd82
    frame $site_5_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame23" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd78
    label $site_6_0.lab82 \
        -text {Type } 
    vTcl:DefineAlias "$site_6_0.lab82" "Label463_04" vTcl:WidgetProc "Toplevel463" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GF3Type -width 7 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry463_04" vTcl:WidgetProc "Toplevel463" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd79" "Frame24" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd79
    label $site_6_0.lab82 \
        -text Level 
    vTcl:DefineAlias "$site_6_0.lab82" "Label463_05" vTcl:WidgetProc "Toplevel463" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GF3Level -width 5 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry463_05" vTcl:WidgetProc "Toplevel463" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd80 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd80" "Frame31" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd80
    label $site_6_0.lab82 \
        -text Polar 
    vTcl:DefineAlias "$site_6_0.lab82" "Label463_06" vTcl:WidgetProc "Toplevel463" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GF3Polar -width 7 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry463_06" vTcl:WidgetProc "Toplevel463" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    frame $site_4_0.cpd81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd81" "Frame18" vTcl:WidgetProc "Toplevel463" 1
    set site_5_0 $site_4_0.cpd81
    frame $site_5_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame19" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd78
    label $site_6_0.lab82 \
        -text Frequency 
    vTcl:DefineAlias "$site_6_0.lab82" "Label463_07" vTcl:WidgetProc "Toplevel463" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GF3Frequency -width 9 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry463_07" vTcl:WidgetProc "Toplevel463" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd80 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd80" "Frame22" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd80
    label $site_6_0.lab82 \
        -text {Incidence Angle} 
    vTcl:DefineAlias "$site_6_0.lab82" "Label463_08" vTcl:WidgetProc "Toplevel463" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GF3IncAng -width 9 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry463_08" vTcl:WidgetProc "Toplevel463" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.fra77 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.fra66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipady 10 \
        -side left 
    pack $site_3_0.fra76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 10 -ipady 10 \
        -side left 
    frame $top.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame3" vTcl:WidgetProc "Toplevel463" 1
    set site_3_0 $top.cpd77
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Input Data File ( s11 )} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame463_1" vTcl:WidgetProc "Toplevel463" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput1 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry463_1" vTcl:WidgetProc "Toplevel463" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame25" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd119 \
        \
        -command {global FileName GF3DirInput GF3DataFormat FileInput1

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $GF3DirInput $types "HH INPUT FILE (s11)"
set FileInput1 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd119" "Button463_1" vTcl:WidgetProc "Toplevel463" 1
    bindtags $site_6_0.cpd119 "$site_6_0.cpd119 Button $top all _vTclBalloon"
    bind $site_6_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd119 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd116 \
        -ipad 0 -text {Input Data File ( s12 )} 
    vTcl:DefineAlias "$site_3_0.cpd116" "TitleFrame463_2" vTcl:WidgetProc "Toplevel463" 1
    bind $site_3_0.cpd116 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput2 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry463_2" vTcl:WidgetProc "Toplevel463" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame26" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd120 \
        \
        -command {global FileName GF3DirInput GF3DataFormat FileInput2

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $GF3DirInput $types "HV INPUT FILE (s12)"
set FileInput2 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd120" "Button463_2" vTcl:WidgetProc "Toplevel463" 1
    bindtags $site_6_0.cpd120 "$site_6_0.cpd120 Button $top all _vTclBalloon"
    bind $site_6_0.cpd120 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd120 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd117 \
        -ipad 0 -text {Input Data File ( s21 )} 
    vTcl:DefineAlias "$site_3_0.cpd117" "TitleFrame463_3" vTcl:WidgetProc "Toplevel463" 1
    bind $site_3_0.cpd117 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd117 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput3 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry463_3" vTcl:WidgetProc "Toplevel463" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame27" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd121 \
        \
        -command {global FileName GF3DirInput GF3DataFormat FileInput3

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $GF3DirInput $types "VH INPUT FILE (s21)"
set FileInput3 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd121" "Button463_3" vTcl:WidgetProc "Toplevel463" 1
    bindtags $site_6_0.cpd121 "$site_6_0.cpd121 Button $top all _vTclBalloon"
    bind $site_6_0.cpd121 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd121 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd118 \
        -ipad 0 -text {Input Data File ( s22 )} 
    vTcl:DefineAlias "$site_3_0.cpd118" "TitleFrame463_4" vTcl:WidgetProc "Toplevel463" 1
    bind $site_3_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput4 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry463_4" vTcl:WidgetProc "Toplevel463" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame28" vTcl:WidgetProc "Toplevel463" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd122 \
        \
        -command {global FileName GF3DirInput GF3DataFormat FileInput4

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $GF3DirInput $types "VV INPUT FILE (s22)"
set FileInput4 $FileName} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd122" "Button463_4" vTcl:WidgetProc "Toplevel463" 1
    bindtags $site_6_0.cpd122 "$site_6_0.cpd122 Button $top all _vTclBalloon"
    bind $site_6_0.cpd122 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd122 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd116 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd117 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd118 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra70 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra70" "Frame7" vTcl:WidgetProc "Toplevel463" 1
    set site_3_0 $top.fra70
    frame $site_3_0.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra71" "Frame8" vTcl:WidgetProc "Toplevel463" 1
    set site_4_0 $site_3_0.fra71
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame9" vTcl:WidgetProc "Toplevel463" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab77 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_5_0.lab77" "Label463_09" vTcl:WidgetProc "Toplevel463" 1
    entry $site_5_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligFullSize -width 9 
    vTcl:DefineAlias "$site_5_0.ent78" "Entry463_09" vTcl:WidgetProc "Toplevel463" 1
    pack $site_5_0.lab77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 \
        -side right 
    frame $site_4_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd73" "Frame10" vTcl:WidgetProc "Toplevel463" 1
    set site_5_0 $site_4_0.cpd73
    label $site_5_0.lab77 \
        -text {Row Pixel Spacing} 
    vTcl:DefineAlias "$site_5_0.lab77" "Label463_10" vTcl:WidgetProc "Toplevel463" 1
    entry $site_5_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GF3PixRow -width 9 
    vTcl:DefineAlias "$site_5_0.ent78" "Entry463_10" vTcl:WidgetProc "Toplevel463" 1
    pack $site_5_0.lab77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 \
        -side right 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $site_3_0.cpd75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd75" "Frame12" vTcl:WidgetProc "Toplevel463" 1
    set site_4_0 $site_3_0.cpd75
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame13" vTcl:WidgetProc "Toplevel463" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab79 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_5_0.lab79" "Label463_11" vTcl:WidgetProc "Toplevel463" 1
    entry $site_5_0.ent80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolFullSize -width 9 
    vTcl:DefineAlias "$site_5_0.ent80" "Entry463_11" vTcl:WidgetProc "Toplevel463" 1
    pack $site_5_0.lab79 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 \
        -side right 
    frame $site_4_0.cpd73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd73" "Frame14" vTcl:WidgetProc "Toplevel463" 1
    set site_5_0 $site_4_0.cpd73
    label $site_5_0.lab79 \
        -text {Col Pixel Spacing} 
    vTcl:DefineAlias "$site_5_0.lab79" "Label463_12" vTcl:WidgetProc "Toplevel463" 1
    entry $site_5_0.ent80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable GF3PixCol -width 9 
    vTcl:DefineAlias "$site_5_0.ent80" "Entry463_12" vTcl:WidgetProc "Toplevel463" 1
    pack $site_5_0.lab79 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 \
        -side right 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.fra71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra71 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame20" vTcl:WidgetProc "Toplevel463" 1
    set site_3_0 $top.fra71
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global GF3DirInput GF3DirOutput GF3FileInputFlag GF3ProductFile
global GF3Mode GF3Orbit GF3Direction GF3Type GF3Level GF3Polar GF3Frequency 
global GF3IncAng GF3IncAngNear GF3IncAngFar GF3PixRow GF3PixCol
global GF3QualifyValueHH GF3QualifyValueHV GF3QualifyValueVH GF3QualifyValueVV
global FileInput1 FileInput2 FileInput3 FileInput4



global GF3DirOutput GF3FileInputFlag GF3DataFormat
global OpenDirFile TMPGf3Config GF3LutFile
global IEEEFormat FileInput1 FileInput2 FileInput3 FileInput4
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput

if {$OpenDirFile == 0} {

set GF3FileInputFlag 0
set GF3FileFlag 0
if {$FileInput1 != ""} {incr GF3FileFlag}
if {$FileInput2 != ""} {incr GF3FileFlag}
if {$FileInput3 != ""} {incr GF3FileFlag}
if {$FileInput4 != ""} {incr GF3FileFlag}
if {$GF3FileFlag == 4} {set GF3FileInputFlag 1}

if {$GF3FileInputFlag == 1} {

    DeleteFile $TMPGf3Config

    TextEditorRunTrace "Process The Function Soft/bin/data_import/gf3_header.exe" "k"
    TextEditorRunTrace "Arguments: -if \x22$FileInput1\x22 -of \x22$TMPGf3Config\x22" "k"
    set f [ open "| Soft/bin/data_import/gf3_header.exe -if \x22$FileInput1\x22 -of \x22$TMPGf3Config\x22" r]
    PsPprogressBar $f
    TextEditorRunTrace "Check RunTime Errors" "r"
    CheckRunTimeError
    
    set NligFullSize 0
    set NcolFullSize 0
    set NligInit 0
    set NligEnd 0
    set NcolInit 0
    set NcolEnd 0
    set NligFullSizeInput 0
    set NcolFullSizeInput 0
    set ConfigFile $TMPGf3Config
    set ErrorMessage ""
    WaitUntilCreated $ConfigFile
    if [file exists $ConfigFile] {
        set f [open $ConfigFile r]
        gets $f tmp
        gets $f NligFullSize
        gets $f tmp
        gets $f tmp
        gets $f NcolFullSize
        gets $f tmp
        gets $f tmp
        gets $f IEEEFormat
        close $f

        set NligInit 1
        set NligEnd $NligFullSize
        set NcolInit 1
        set NcolEnd $NcolFullSize
        set NligFullSizeInput $NligFullSize
        set NcolFullSizeInput $NcolFullSize

        set ErrorMessage ""
        set WarningMessage "DON'T FORGET TO EXTRACT DATA"
        set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
        set VarAdvice ""
        Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
        tkwait variable VarAdvice
        Window hide $widget(Toplevel463); TextEditorRunTrace "Close Window GF3 Input File" "b"
        } else {
        set ErrorMessage "ROWS / COLS EXTRACTION ERROR"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        Window hide $widget(Toplevel463); TextEditorRunTrace "Close Window GF3 Input File" "b"
        }
    } else {
    set GF3FileInputFlag 0
    set ErrorMessage "ENTER THE GF3 DATA FILE NAMES"
    set VarError ""
    Window show $widget(Toplevel44)
    }
}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button463_6" vTcl:WidgetProc "Toplevel463" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 -command {HelpPdfEdit "Help/GF3_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel463" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel463); TextEditorRunTrace "Close Window GF3 Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel463" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Cancel the Function}
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
    pack $top.lab66 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra70 \
        -in $top -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $top.fra71 \
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
Window show .top463

main $argc $argv
