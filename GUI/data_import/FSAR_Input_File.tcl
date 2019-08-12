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

        {{[file join . GUI Images FSAR.gif]} {user image} user {}}
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
    set base .top431
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
    namespace eval ::widgets::$base.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd67 getframe]
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
    namespace eval ::widgets::$base.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd69 getframe]
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
    namespace eval ::widgets::$base.cpd70 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd70 getframe]
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
    namespace eval ::widgets::$base.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra73
    namespace eval ::widgets::$site_3_0.but74 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but75 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but66 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd87 {
        array set save {-borderwidth 1 -relief 1}
    }
    set site_3_0 $base.cpd87
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.fra75 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra75
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd79
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd77
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd80
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd69
    namespace eval ::widgets::$site_4_0.fra81 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra81
    namespace eval ::widgets::$site_5_0.cpd84 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd84
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd85
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd83
    namespace eval ::widgets::$site_5_0.cpd86 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd86
    namespace eval ::widgets::$site_6_0.lab82 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd66
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
    namespace eval ::widgets::$base.fra76 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra76
    namespace eval ::widgets::$site_3_0.lab77 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab79 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.ent80 {
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
    namespace eval ::widgets::$base.m88 {
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
            vTclWindow.top431
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

proc vTclWindow.top431 {base} {
    if {$base == ""} {
        set base .top431
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m88" 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 500x690+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "FSAR Input Data File"
    vTcl:DefineAlias "$top" "Toplevel431" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab66 \
        -image [vTcl:image:get_image [file join . GUI Images FSAR.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab66" "Label281" vTcl:WidgetProc "Toplevel431" 1
    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame1" vTcl:WidgetProc "Toplevel431" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel431" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FSARDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel431" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel431" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd114 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.cpd114" "Button39" vTcl:WidgetProc "Toplevel431" 1
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
    vTcl:DefineAlias "$top.cpd71" "TitleFrame431" vTcl:WidgetProc "Toplevel431" 1
    bind $top.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd71 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable FSARDirOutput 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry431" vTcl:WidgetProc "Toplevel431" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame29" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global DirName DataDir FSARDirOutput
global VarWarning WarningMessage WarningMessage2

set FSAROutputDirTmp $FSARDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set FSARDirOutput $DirName
        } else {
        set FSARDirOutput $FSAROutputDirTmp
        }
    } else {
    set FSARDirOutput $FSAROutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button431" vTcl:WidgetProc "Toplevel431" 1
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
    TitleFrame $top.cpd67 \
        -ipad 0 -text {F-SAR RGI Directory} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame432" vTcl:WidgetProc "Toplevel431" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FSARRGIDir 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry433" vTcl:WidgetProc "Toplevel431" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame42" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global DirName FSARDirInput FSARRGIDir FSARProductFile
global VarWarning WarningMessage WarningMessage2 PSPBackgroundColor
global FSARProductFileHH FSARProductFileHV FSARProductFileVH FSARProductFileVV
global FSARFreq FSARResolRg FSARPixRg FSARCalib FSARResolAz FSARPixAz
global FileInputHH FileInputHV FileInputVH FileInputVV NligFullSize NcolFullSize
global FSARIncAngFile FSARMaskFile
global ErrorMessage VarError

set FSARRGIDir ""
set FSARProductFileHH ""
set FSARProductFileHV ""
set FSARProductFileVH ""
set FSARProductFileVV ""
set FSARFreq ""; set FSARResolRg ""; set FSARPixRg ""
set FSARCalib ""; set FSARResolAz ""; set FSARPixAz ""
set FileInputHH ""; set FileInputHV ""; set FileInputVH ""; set FileInputVV ""
set NligFullSize ""; set NcolFullSize ""
set FSARIncAngFile ""; set FSARMaskFile ""

$widget(Button431_00) configure -state disable
$widget(Button431_7) configure -state disable
$widget(Button431_8) configure -state disable
$widget(Button431_9) configure -state disable
$widget(Label431_001) configure -state disable
$widget(Entry431_001) configure -disabledbackground $PSPBackgroundColor
$widget(Label431_002) configure -state disable
$widget(Entry431_002) configure -disabledbackground $PSPBackgroundColor
$widget(Label431_003) configure -state disable
$widget(Entry431_003) configure -disabledbackground $PSPBackgroundColor
$widget(Label431_004) configure -state disable
$widget(Entry431_004) configure -disabledbackground $PSPBackgroundColor
$widget(Label431_005) configure -state disable
$widget(Entry431_005) configure -disabledbackground $PSPBackgroundColor
$widget(Label431_006) configure -state disable
$widget(Entry431_006) configure -disabledbackground $PSPBackgroundColor
$widget(TitleFrame431_5) configure -state disable
$widget(Entry431_5) configure -disabledbackground $PSPBackgroundColor
$widget(TitleFrame431_6) configure -state disable
$widget(Entry431_6) configure -disabledbackground $PSPBackgroundColor
$widget(Label431_1) configure -state disable
$widget(Entry431_7) configure -disabledbackground $PSPBackgroundColor
$widget(Label431_2) configure -state disable
$widget(Entry431_8) configure -disabledbackground $PSPBackgroundColor

set FSARRGIDir ""
$widget(TitleFrame431_01) configure -state disable
$widget(Entry431_01) configure -disabledbackground $PSPBackgroundColor
$widget(Button431_01) configure -state disable
$widget(TitleFrame431_02) configure -state disable
$widget(Entry431_02) configure -disabledbackground $PSPBackgroundColor
$widget(Button431_02) configure -state disable
$widget(TitleFrame431_03) configure -state disable
$widget(Entry431_03) configure -disabledbackground $PSPBackgroundColor
$widget(Button431_03) configure -state disable
$widget(TitleFrame431_04) configure -state disable
$widget(Entry431_04) configure -disabledbackground $PSPBackgroundColor
$widget(Button431_04) configure -state disable

OpenDir $FSARDirInput "F-SAR RGI DIRECTORY"
if {$DirName != "" } {
    set config "false"
    if [file isdirectory "$DirName/RGI-QL"] {
        if [file isdirectory "$DirName/RGI-RDP"] {
            if [file isdirectory "$DirName/RGI-SR"] {
                if [file isdirectory "$DirName/RGI-TRACK"] {
                    set config "true"
                    }
                }
            }
        }
    if {$config == "true"} {
        set FSARRGIDir $DirName
        $widget(TitleFrame431_01) configure -state normal
        $widget(Entry431_01) configure -disabledbackground #FFFFFF
        $widget(Button431_01) configure -state normal
        $widget(TitleFrame431_02) configure -state normal
        $widget(Entry431_02) configure -disabledbackground #FFFFFF
        $widget(Button431_02) configure -state normal
        $widget(TitleFrame431_03) configure -state normal
        $widget(Entry431_03) configure -disabledbackground #FFFFFF
        $widget(Button431_03) configure -state normal
        $widget(TitleFrame431_04) configure -state normal
        $widget(Entry431_04) configure -disabledbackground #FFFFFF
        $widget(Button431_04) configure -state normal
        } else { 
        set ErrorMessage "THE DIRECTORY IS NOT A F-SAR RGI DIRECTORY"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }    
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button433" vTcl:WidgetProc "Toplevel431" 1
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
    TitleFrame $top.cpd69 \
        -ipad 0 -text {F-SAR Processing Parameters File - HH} 
    vTcl:DefineAlias "$top.cpd69" "TitleFrame431_01" vTcl:WidgetProc "Toplevel431" 1
    bind $top.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd69 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FSARProductFileHH 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry431_01" vTcl:WidgetProc "Toplevel431" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame44" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global FileName FSARRGIDir FSARProductFileHH FSARProductFileHV FSARProductFileVH FSARProductFileVV

set types {
    {{XML Files}        {.xml}        }
    }
set FileName ""
OpenFile "$FSARRGIDir/RGI-RDP" $types "F-SAR PROCESSING PARAMETERS FILE HH"
if {$FileName != ""} {
    set FSARProductFileHH $FileName
    if {$FSARProductFileHH != ""} {
        if {$FSARProductFileHV != ""} {
            if {$FSARProductFileVH != ""} {
                if {$FSARProductFileVV != ""} {
                    $widget(Button431_00) configure -state normal
                    }
                }
            }
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button431_01" vTcl:WidgetProc "Toplevel431" 1
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
    TitleFrame $top.cpd70 \
        -ipad 0 -text {F-SAR Processing Parameters File - HV} 
    vTcl:DefineAlias "$top.cpd70" "TitleFrame431_02" vTcl:WidgetProc "Toplevel431" 1
    bind $top.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd70 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FSARProductFileHV 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry431_02" vTcl:WidgetProc "Toplevel431" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame45" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global FileName FSARRGIDir FSARProductFileHH FSARProductFileHV FSARProductFileVH FSARProductFileVV

set types {
    {{XML Files}        {.xml}        }
    }
set FileName ""
OpenFile "$FSARRGIDir/RGI-RDP" $types "F-SAR PROCESSING PARAMETERS FILE HV"
if {$FileName != ""} {
    set FSARProductFileHV $FileName
    if {$FSARProductFileHH != ""} {
        if {$FSARProductFileHV != ""} {
            if {$FSARProductFileVH != ""} {
                if {$FSARProductFileVV != ""} {
                    $widget(Button431_00) configure -state normal
                    }
                }
            }
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button431_02" vTcl:WidgetProc "Toplevel431" 1
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
        -ipad 0 -text {F-SAR Processing Parameters File - VH} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame431_03" vTcl:WidgetProc "Toplevel431" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FSARProductFileVH 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry431_03" vTcl:WidgetProc "Toplevel431" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame46" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global FileName FSARRGIDir FSARProductFileHH FSARProductFileHV FSARProductFileVH FSARProductFileVV

set types {
    {{XML Files}        {.xml}        }
    }
set FileName ""
OpenFile "$FSARRGIDir/RGI-RDP" $types "F-SAR PROCESSING PARAMETERS FILE VH"
if {$FileName != ""} {
    set FSARProductFileVH $FileName
    if {$FSARProductFileHH != ""} {
        if {$FSARProductFileHV != ""} {
            if {$FSARProductFileVH != ""} {
                if {$FSARProductFileVV != ""} {
                    $widget(Button431_00) configure -state normal
                    }
                }
            }
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button431_03" vTcl:WidgetProc "Toplevel431" 1
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
    TitleFrame $top.cpd73 \
        -ipad 0 -text {F-SAR Processing Parameters File - VV} 
    vTcl:DefineAlias "$top.cpd73" "TitleFrame431_04" vTcl:WidgetProc "Toplevel431" 1
    bind $top.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd73 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FSARProductFileVV 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry431_04" vTcl:WidgetProc "Toplevel431" 1
    frame $site_4_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame47" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.cpd91
    button $site_5_0.cpd119 \
        \
        -command {global FileName FSARRGIDir FSARProductFileHH FSARProductFileHV FSARProductFileVH FSARProductFileVV

set types {
    {{XML Files}        {.xml}        }
    }
set FileName ""
OpenFile "$FSARRGIDir/RGI-RDP" $types "F-SAR PROCESSING PARAMETERS FILE VV"
if {$FileName != ""} {
    set FSARProductFileVV $FileName
    if {$FSARProductFileHH != ""} {
        if {$FSARProductFileHV != ""} {
            if {$FSARProductFileVH != ""} {
                if {$FSARProductFileVV != ""} {
                    $widget(Button431_00) configure -state normal
                    }
                }
            }
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button431_04" vTcl:WidgetProc "Toplevel431" 1
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
    vTcl:DefineAlias "$top.fra73" "Frame4" vTcl:WidgetProc "Toplevel431" 1
    set site_3_0 $top.fra73
    button $site_3_0.but74 \
        -background #ffff00 \
        -command {global FSARDirInput FSARDirOutput FSARFileInputFlag
global FSARDataFormat FSARProductFile FSARRGIDir FSARMaskFile FSARIncAngFile
global FSARFreq FSARCalib FSARResolRg FSARResolAz FSARPixRg FSARPixAz FsarHeader
global FileInputHH FileInputHV FileInputVH FileInputVV
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPFsarConfig TMPGoogle OpenDirFile PolarType
global GoogleLatCenter GoogleLongCenter GoogleLat00 GoogleLong00 GoogleLat0N GoogleLong0N
global GoogleLatN0 GoogleLongN0 GoogleLatNN GoogleLongNN
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global VarAdvice WarningMessage WarningMessage2 WarningMessage3 WarningMessage4
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput

if {$OpenDirFile == 0} {

set datalevelerror 0
#####################################################################
#Create Directory
set FSARDirOutput [PSPCreateDirectoryMask $FSARDirOutput $FSARDirOutput $FSARDirInput]
#####################################################################       

if {"$VarWarning"=="ok"} {

DeleteFile $TMPFsarConfig
DeleteFile $TMPGoogle

set ConfigProductFile "true"
if [file exists $FSARProductFileHH] {
    set FSARFile1 "$FSARDirOutput/product_header_HH.txt"
    set Sensor "FSAR"
    ReadXML $FSARProductFileHH $FSARFile1 $TMPFsarConfig $Sensor
    WaitUntilCreated $TMPFsarConfig
    if [file exists $TMPFsarConfig] {
        set f [open $TMPFsarConfig r]
        gets $f FSARbandHH
        gets $f FSARpolarHH
        gets $f FSARcampaignHH
        gets $f FSARflightHH
        gets $f FSARpassHH
        gets $f FSARpixrgHH
        gets $f FSARpixazHH
        close $f
        DeleteFile $TMPFsarConfig
        } else {
        set ErrorMessage "PP FILE HH IS NOT AN XML FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set FSARProductFileHH ""
        set ConfigProductFile "false"
        }
        #TMPFsarConfig Exists
    } else {
    set ErrorMessage "ENTER THE XML - PP FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set FSARProductFileHH ""; set FSARFileInputFlag 0
    set ConfigProductFile "false"
    }
    #ProductFile Exists
if [file exists $FSARProductFileHV] {
    set FSARFile1 "$FSARDirOutput/product_header_HV.txt"
    set Sensor "FSAR"
    ReadXML $FSARProductFileHV $FSARFile1 $TMPFsarConfig $Sensor
    WaitUntilCreated $TMPFsarConfig
    if [file exists $TMPFsarConfig] {
        set f [open $TMPFsarConfig r]
        gets $f FSARbandHV
        gets $f FSARpolarHV
        gets $f FSARcampaignHV
        gets $f FSARflightHV
        gets $f FSARpassHV
        gets $f FSARpixrgHV
        gets $f FSARpixazHV
        close $f
        DeleteFile $TMPFsarConfig
        } else {
        set ErrorMessage "PP FILE HV IS NOT AN XML FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set FSARProductFileHV ""
        set ConfigProductFile "false"
        }
        #TMPFsarConfig Exists
    } else {
    set ErrorMessage "ENTER THE XML - PP FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set FSARProductFileHV ""; set FSARFileInputFlag 0
    set ConfigProductFile "false"
    }
    #ProductFile Exists
if [file exists $FSARProductFileVH] {
    set FSARFile1 "$FSARDirOutput/product_header_VH.txt"
    set Sensor "FSAR"
    ReadXML $FSARProductFileVH $FSARFile1 $TMPFsarConfig $Sensor
    WaitUntilCreated $TMPFsarConfig
    if [file exists $TMPFsarConfig] {
        set f [open $TMPFsarConfig r]
        gets $f FSARbandVH
        gets $f FSARpolarVH
        gets $f FSARcampaignVH
        gets $f FSARflightVH
        gets $f FSARpassVH
        gets $f FSARpixrgVH
        gets $f FSARpixazVH
        close $f
        DeleteFile $TMPFsarConfig
        } else {
        set ErrorMessage "PP FILE VH IS NOT AN XML FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set FSARProductFileVH ""
        set ConfigProductFile "false"
        }
        #TMPFsarConfig Exists
    } else {
    set ErrorMessage "ENTER THE XML - PP FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set FSARProductFileVH ""; set FSARFileInputFlag 0
    set ConfigProductFile "false"
    }
    #ProductFile Exists
if [file exists $FSARProductFileVV] {
    set FSARFile1 "$FSARDirOutput/product_header_VV.txt"
    set Sensor "FSAR"
    ReadXML $FSARProductFileVV $FSARFile1 $TMPFsarConfig $Sensor
    WaitUntilCreated $TMPFsarConfig
    if [file exists $TMPFsarConfig] {
        set f [open $TMPFsarConfig r]
        gets $f FSARbandVV
        gets $f FSARpolarVV
        gets $f FSARcampaignVV
        gets $f FSARflightVV
        gets $f FSARpassVV
        gets $f FSARpixrgVV
        gets $f FSARpixazVV
        close $f
        DeleteFile $TMPFsarConfig
        } else {
        set ErrorMessage "PP FILE VV IS NOT AN XML FILE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set FSARProductFileVV ""
        set ConfigProductFile "false"
        }
        #TMPFsarConfig Exists
    } else {
    set ErrorMessage "ENTER THE XML - PP FILE NAME"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set FSARProductFileVV ""; set FSARFileInputFlag 0
    set ConfigProductFile "false"
    }
    #ProductFile Exists

if {$ConfigProductFile == "true"} {
    set ConfigBand "false"
    if {$FSARbandHH == $FSARbandHV} {
    if {$FSARbandHH == $FSARbandVH} {
    if {$FSARbandHH == $FSARbandVV} {
        set ConfigBand "true"
        } } }
    if {$ConfigBand == "false"} {
        set ErrorMessage "DIFFERENT FREQUENCY BANDS"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    set ConfigCampaign "false"
    if {$FSARcampaignHH == $FSARcampaignHV} {
    if {$FSARcampaignHH == $FSARcampaignVH} {
    if {$FSARcampaignHH == $FSARcampaignVV} {
        set ConfigCampaign "true"
        } } }
    if {$ConfigCampaign == "false"} {
        set ErrorMessage "DIFFERENT CAMPAIGN"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    set ConfigFlight "false"
    if {$FSARflightHH == $FSARflightHV} {
    if {$FSARflightHH == $FSARflightVH} {
    if {$FSARflightHH == $FSARflightVV} {
        set ConfigFlight "true"
        } } }
    if {$ConfigFlight == "false"} {
        set ErrorMessage "DIFFERENT FLIGHT"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    set ConfigPass "false"
    if {$FSARpassHH == $FSARpassHV} {
    if {$FSARpassHH == $FSARpassVH} {
    if {$FSARpassHH == $FSARpassVV} {
        set ConfigPass "true"
        } } }
    if {$ConfigPass == "false"} {
        set ErrorMessage "DIFFERENT PASS"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    set ConfigPolar "false"
    if {$FSARpolarHH == "HH"} {
    if {$FSARpolarHV == "HV"} {
    if {$FSARpolarVH == "VH"} {
    if {$FSARpolarVV == "VV"} {
        set ConfigPolar "true"
        } } } }
    if {$ConfigPolar == "false"} {
        set ErrorMessage "DIFFERENT POLAR"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    set ConfigPixRg "false"
    if {$FSARpixrgHH == $FSARpixrgHV} {
    if {$FSARpixrgHH == $FSARpixrgVH} {
    if {$FSARpixrgHH == $FSARpixrgVV} {
        set ConfigPixRg "true"
        } } }
    if {$ConfigPixRg == "false"} {
        set ErrorMessage "DIFFERENT RG PIXEL SIZE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    set ConfigPixAz "false"
    if {$FSARpixazHH == $FSARpixazHV} {
    if {$FSARpixazHH == $FSARpixazVH} {
    if {$FSARpixazHH == $FSARpixazVV} {
        set ConfigPixAz "true"
        } } }
    if {$ConfigPixAz == "false"} {
        set ErrorMessage "DIFFERENT AZ PIXEL SIZE"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }

    set ConfigTotal "false"
    if {$ConfigBand == "true"} {
    if {$ConfigCampaign == "true"} {
    if {$ConfigFlight == "true"} {
    if {$ConfigPass == "true"} {
    if {$ConfigPolar == "true"} {
    if {$ConfigPixRg == "true"} {
    if {$ConfigPixAz == "true"} {
        set ConfigTotal "true"
        } } } } } } }

    if {$ConfigTotal == "true"} {
        set FileTmp [file rootname [file tail $FSARProductFileHH]]
        set LenFileTmp [string length $FileTmp] 
        set IndFileTmp [string last hh_ $FileTmp] 
        set TermFileTmp [string range $FileTmp [expr $IndFileTmp + 2] $LenFileTmp] 

        set ConfigFileHH "false"
        set FSARFile2 "$FSARRGIDir/RGI-SR/slc_"; append FSARFile2 $FSARcampaignHH; append FSARFile2 $FSARflightHH; append FSARFile2 $FSARpassHH
        append FSARFile2 "_$FSARbandHH"; append FSARFile2 "hh"; append FSARFile2 $TermFileTmp; append FSARFile2 ".rat"
        set FileInputHH $FSARFile2
        if [file exists $FileInputHH] {
            set ConfigFileHH "true"
            } else {
            set ErrorMessage "SLC DATA FILE HH DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        set ConfigFileHV "false"
        set FSARFile2 "$FSARRGIDir/RGI-SR/slc_"; append FSARFile2 $FSARcampaignHH; append FSARFile2 $FSARflightHH; append FSARFile2 $FSARpassHH
        append FSARFile2 "_$FSARbandHH"; append FSARFile2 "hv"; append FSARFile2 $TermFileTmp; append FSARFile2 ".rat"
        set FileInputHV $FSARFile2
        if [file exists $FileInputHV] {
            set ConfigFileHV "true"
            } else {
            set ErrorMessage "SLC DATA FILE HV DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        set ConfigFileVH "false"
        set FSARFile2 "$FSARRGIDir/RGI-SR/slc_"; append FSARFile2 $FSARcampaignHH; append FSARFile2 $FSARflightHH; append FSARFile2 $FSARpassHH
        append FSARFile2 "_$FSARbandHH"; append FSARFile2 "vh"; append FSARFile2 $TermFileTmp; append FSARFile2 ".rat"
        set FileInputVH $FSARFile2
        if [file exists $FileInputVH] {
            set ConfigFileVH "true"
            } else {
            set ErrorMessage "SLC DATA FILE VH DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        set ConfigFileVV "false"
        set FSARFile2 "$FSARRGIDir/RGI-SR/slc_"; append FSARFile2 $FSARcampaignHH; append FSARFile2 $FSARflightHH; append FSARFile2 $FSARpassHH
        append FSARFile2 "_$FSARbandHH"; append FSARFile2 "vv"; append FSARFile2 $TermFileTmp; append FSARFile2 ".rat"
        set FileInputVV $FSARFile2
        if [file exists $FileInputVV] {
            set ConfigFileVV "true"
            } else {
            set ErrorMessage "SLC DATA FILE VV DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        set ConfigFileMask "false"
        set FSARFile2 "$FSARRGIDir/RGI-SR/mask_"; append FSARFile2 $FSARcampaignHH; append FSARFile2 $FSARflightHH; append FSARFile2 $FSARpassHH
        append FSARFile2 "_$FSARbandHH"; append FSARFile2 $TermFileTmp; append FSARFile2 ".rat"
        set FSARMaskFile $FSARFile2
        if [file exists $FSARMaskFile] {
            set ConfigFileMask "true"
            } else {
            set FSARMaskFile ""
            set ErrorMessage "SLC MASK FILE DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        set ConfigFileIncAng "false"
        set FSARFile2 "$FSARRGIDir/RGI-SR/incidence_"; append FSARFile2 $FSARcampaignHH; append FSARFile2 $FSARflightHH; append FSARFile2 $FSARpassHH
        append FSARFile2 "_$FSARbandHH"; append FSARFile2 $TermFileTmp; append FSARFile2 ".rat"
        set FSARIncAngFile $FSARFile2
        if [file exists $FSARIncAngFile] {
            set ConfigFileIncAng "true"
            } else {
            set FSARIncAngFile ""
            set ErrorMessage "SLC INCIDENCE ANGLE FILE DOES NOT EXIST"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }

        set ConfigFileTotal "false"
        if {$ConfigFileHH == "true"} {
        if {$ConfigFileHV == "true"} {
        if {$ConfigFileVH == "true"} {
        if {$ConfigFileVV == "true"} {
        if {$ConfigFileMask == "true"} {
        if {$ConfigFileIncAng == "true"} {
            set ConfigFileTotal "true"
            } } } } } }

        if {$ConfigFileTotal == "true"} {

            set FSARFile1 "$FSARDirOutput/product_header_HH.txt"
            set FSARFile2 "$FileInputHH.hdr"
            TextEditorRunTrace "Process The Function Soft/bin/data_import/fsar_config.exe" "k"
            TextEditorRunTrace "Arguments: -if1 \x22$FSARFile1\x22 -if2 \x22$FSARFile2\x22 -od \x22$FSARDirOutput\x22 -ocf \x22$TMPFsarConfig\x22 -ogf \x22$TMPGoogle\x22" "k"
            set f [ open "| Soft/bin/data_import/fsar_config.exe -if1 \x22$FSARFile1\x22 -if2 \x22$FSARFile2\x22 -od \x22$FSARDirOutput\x22 -ocf \x22$TMPFsarConfig\x22 -ogf \x22$TMPGoogle\x22" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WaitUntilCreated $TMPFsarConfig
            if [file exists $TMPFsarConfig] {
                $widget(Label431_001) configure -state normal
                $widget(Entry431_001) configure -disabledbackground #FFFFFF
                $widget(Label431_002) configure -state normal
                $widget(Entry431_002) configure -disabledbackground #FFFFFF
                $widget(Label431_003) configure -state normal
                $widget(Entry431_003) configure -disabledbackground #FFFFFF
                $widget(Label431_004) configure -state normal
                $widget(Entry431_004) configure -disabledbackground #FFFFFF
                $widget(Label431_005) configure -state normal
                $widget(Entry431_005) configure -disabledbackground #FFFFFF
                $widget(Label431_006) configure -state normal
                $widget(Entry431_006) configure -disabledbackground #FFFFFF
                $widget(TitleFrame431_5) configure -state normal
                $widget(Entry431_5) configure -disabledbackground #FFFFFF
                $widget(TitleFrame431_6) configure -state normal
                $widget(Entry431_6) configure -disabledbackground #FFFFFF
                $widget(Label431_1) configure -state normal
                $widget(Entry431_7) configure -disabledbackground #FFFFFF
                $widget(Label431_2) configure -state normal
                $widget(Entry431_8) configure -disabledbackground #FFFFFF
            
                set f [open $TMPFsarConfig r]
                gets $f FSARFreq
                gets $f FSARCalib
                gets $f FSARResolRg
                gets $f FSARResolAz
                gets $f FSARPixRg
                gets $f FSARPixAz
                gets $f FSARNcol
                gets $f FSARNlig
                gets $f FsarHeader
                close $f

                $widget(Button431_7) configure -state normal
                set NligFullSize $FSARNlig
                set NcolFullSize $FSARNcol
                set NligInit 1
                set NligEnd $NligFullSize
                set NcolInit 1
                set NcolEnd $NcolFullSize
                set NligFullSizeInput $NligFullSize
                set NcolFullSizeInput $NcolFullSize
                $widget(Button431_9) configure -state normal
                }
            WaitUntilCreated $TMPGoogle
            if [file exists $TMPGoogle] {
                set f [open $TMPGoogle r]
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
                close $f
                $widget(Button431_8) configure -state normal
                }
            }
            #ConfigFileTotal
        }
        #ConfigTotal
    }
    #ConfigProductFile
}
#VarWarning
}
#OpenDirFile} \
        -padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_3_0.but74" "Button431_00" vTcl:WidgetProc "Toplevel431" 1
    button $site_3_0.but75 \
        -background #ffff00 \
        -command {global FileName VarError ErrorMessage FSARDirOutput
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

set FSARFile "$FSARDirOutput/product_header_HH.txt"
if [file exists $FSARFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top431 $FSARFile
    }} \
        -padx 4 -pady 2 -text {Edit Header} 
    vTcl:DefineAlias "$site_3_0.but75" "Button431_7" vTcl:WidgetProc "Toplevel431" 1
    button $site_3_0.but66 \
        \
        -command {global FileName VarError ErrorMessage FSARDirInput

set FSARFile "$FSARDirInput/GEARTH_POLY.kml"
if [file exists $FSARFile] {
    GoogleEarth $FSARFile
    }} \
        -image [vTcl:image:get_image [file join . GUI Images google_earth.gif]] \
        -padx 4 -pady 2 -text Google 
    vTcl:DefineAlias "$site_3_0.but66" "Button431_8" vTcl:WidgetProc "Toplevel431" 1
    bindtags $site_3_0.but66 "$site_3_0.but66 Button $top all _vTclBalloon"
    bind $site_3_0.but66 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Google Earth}
    }
    pack $site_3_0.but74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but75 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd87 \
        -borderwidth 2 -relief sunken 
    set site_3_0 $top.cpd87
    frame $site_3_0.cpd66 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame22" vTcl:WidgetProc "Toplevel431" 1
    set site_4_0 $site_3_0.cpd66
    frame $site_4_0.fra75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra75" "Frame6" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.fra75
    frame $site_5_0.cpd78 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame23" vTcl:WidgetProc "Toplevel431" 1
    set site_6_0 $site_5_0.cpd78
    label $site_6_0.lab82 \
        -text Frequency 
    vTcl:DefineAlias "$site_6_0.lab82" "Label431_001" vTcl:WidgetProc "Toplevel431" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FSARFreq -width 15 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry431_001" vTcl:WidgetProc "Toplevel431" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side right 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame24" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.cpd76
    frame $site_5_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd79" "Frame31" vTcl:WidgetProc "Toplevel431" 1
    set site_6_0 $site_5_0.cpd79
    label $site_6_0.lab82 \
        -text {Range Resolution (m)} 
    vTcl:DefineAlias "$site_6_0.lab82" "Label431_002" vTcl:WidgetProc "Toplevel431" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FSARResolRg -width 15 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry431_002" vTcl:WidgetProc "Toplevel431" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side right 
    pack $site_5_0.cpd79 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd77" "Frame32" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.cpd77
    frame $site_5_0.cpd80 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd80" "Frame33" vTcl:WidgetProc "Toplevel431" 1
    set site_6_0 $site_5_0.cpd80
    label $site_6_0.lab82 \
        -text {Pixel Spacing in Range (m)} 
    vTcl:DefineAlias "$site_6_0.lab82" "Label431_003" vTcl:WidgetProc "Toplevel431" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FSARPixRg -width 15 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry431_003" vTcl:WidgetProc "Toplevel431" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side right 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.fra75 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $site_3_0.cpd69 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd69" "Frame34" vTcl:WidgetProc "Toplevel431" 1
    set site_4_0 $site_3_0.cpd69
    frame $site_4_0.fra81 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra81" "Frame35" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.fra81
    frame $site_5_0.cpd84 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd84" "Frame36" vTcl:WidgetProc "Toplevel431" 1
    set site_6_0 $site_5_0.cpd84
    label $site_6_0.lab82 \
        -text Calibration 
    vTcl:DefineAlias "$site_6_0.lab82" "Label431_004" vTcl:WidgetProc "Toplevel431" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FSARCalib -width 15 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry431_004" vTcl:WidgetProc "Toplevel431" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side right 
    pack $site_5_0.cpd84 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd82 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd82" "Frame37" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.cpd82
    frame $site_5_0.cpd85 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd85" "Frame38" vTcl:WidgetProc "Toplevel431" 1
    set site_6_0 $site_5_0.cpd85
    label $site_6_0.lab82 \
        -text {Azimuth Resolution (m)} 
    vTcl:DefineAlias "$site_6_0.lab82" "Label431_005" vTcl:WidgetProc "Toplevel431" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FSARResolAz -width 15 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry431_005" vTcl:WidgetProc "Toplevel431" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side right 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd83 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd83" "Frame39" vTcl:WidgetProc "Toplevel431" 1
    set site_5_0 $site_4_0.cpd83
    frame $site_5_0.cpd86 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd86" "Frame40" vTcl:WidgetProc "Toplevel431" 1
    set site_6_0 $site_5_0.cpd86
    label $site_6_0.lab82 \
        -text {Pixel Spacing in Azimuth (m)} 
    vTcl:DefineAlias "$site_6_0.lab82" "Label431_006" vTcl:WidgetProc "Toplevel431" 1
    entry $site_6_0.ent83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable FSARPixAz -width 15 
    vTcl:DefineAlias "$site_6_0.ent83" "Entry431_006" vTcl:WidgetProc "Toplevel431" 1
    pack $site_6_0.lab82 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_6_0.ent83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -pady 2 -side right 
    pack $site_5_0.cpd86 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.fra81 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.cpd66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd66" "Frame7" vTcl:WidgetProc "Toplevel431" 1
    set site_3_0 $top.cpd66
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Mask File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame431_5" vTcl:WidgetProc "Toplevel431" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FSARMaskFile 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry431_5" vTcl:WidgetProc "Toplevel431" 1
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $site_3_0.cpd116 \
        -ipad 0 -text {Incidence Angle File} 
    vTcl:DefineAlias "$site_3_0.cpd116" "TitleFrame431_6" vTcl:WidgetProc "Toplevel431" 1
    bind $site_3_0.cpd116 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd116 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FSARIncAngFile 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry431_6" vTcl:WidgetProc "Toplevel431" 1
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd116 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra76 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra76" "Frame5" vTcl:WidgetProc "Toplevel431" 1
    set site_3_0 $top.fra76
    label $site_3_0.lab77 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_3_0.lab77" "Label431_1" vTcl:WidgetProc "Toplevel431" 1
    entry $site_3_0.ent78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligFullSize -width 7 
    vTcl:DefineAlias "$site_3_0.ent78" "Entry431_7" vTcl:WidgetProc "Toplevel431" 1
    label $site_3_0.lab79 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_3_0.lab79" "Label431_2" vTcl:WidgetProc "Toplevel431" 1
    entry $site_3_0.ent80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolFullSize -width 7 
    vTcl:DefineAlias "$site_3_0.ent80" "Entry431_8" vTcl:WidgetProc "Toplevel431" 1
    pack $site_3_0.lab77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.lab79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_3_0.ent80 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    frame $top.fra71 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame20" vTcl:WidgetProc "Toplevel431" 1
    set site_3_0 $top.fra71
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global FSARDirOutput FSARFileInputFlag FSARDataFormat
global OpenDirFile 
global FileInputHH FileInputHV FileInputVH FileInputVV
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError

if {$OpenDirFile == 0} {

set FSARFileInputFlag 0
if {$FSARDataFormat == "quad"} {
    set FSARFileFlag 0
    if {$FileInputHH != ""} {incr FSARFileFlag}
    if {$FileInputHV != ""} {incr FSARFileFlag}
    if {$FileInputVH != ""} {incr FSARFileFlag}
    if {$FileInputVV != ""} {incr FSARFileFlag}
    if {$FSARFileFlag == 4} {set FSARFileInputFlag 1}
    }
if {$FSARFileInputFlag == 1} {
    set ErrorMessage ""
    set WarningMessage "DON'T FORGET TO EXTRACT DATA"
    set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
    set VarAdvice ""
    Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
    tkwait variable VarAdvice
    Window hide $widget(Toplevel431); TextEditorRunTrace "Close Window FSAR Input File" "b"
    } else {
    set FSARFileInputFlag 0
    set ErrorMessage "ENTER THE FSAR DATA FILE NAMES"
    set VarError ""
    Window show $widget(Toplevel44)
    }
}} \
        -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button431_9" vTcl:WidgetProc "Toplevel431" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 -command {HelpPdfEdit "Help/FSAR_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel431" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel431); TextEditorRunTrace "Close Window FSAR Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel431" 1
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
    menu $top.m88 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab66 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd69 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd70 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra73 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd87 \
        -in $top -anchor center -expand 0 -fill x -ipady 2 -padx 2 -pady 2 \
        -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra76 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
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
Window show .top431

main $argc $argv
