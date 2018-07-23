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
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}

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
    set base .top70
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd97 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd97
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
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra72 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra72
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
    namespace eval ::widgets::$base.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra73
    namespace eval ::widgets::$site_3_0.ent25 {
        array set save {-_tooltip 1 -background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.fra76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra76
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-padx 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd66
    namespace eval ::widgets::$site_4_0.lab57 {
        array set save {-padx 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent58 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra67
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd68
    namespace eval ::widgets::$site_5_0.che78 {
        array set save {-_tooltip 1 -foreground 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.lab79 {
        array set save {-_tooltip 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.lab80 {
        array set save {-_tooltip 1 -foreground 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-_tooltip 1 -command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd71
    namespace eval ::widgets::$site_4_0.lab30 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.che31 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.lab32 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent33 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.ent35 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
    namespace eval ::widgets::$site_3_0.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra75
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-_tooltip 1 -command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd77
    namespace eval ::widgets::$site_5_0.lab78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.rad79 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd78 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd79 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd79 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd80 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd80 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd81 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
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
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd74
    namespace eval ::widgets::$site_6_0.cpd71 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra75 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra75
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
            vTclWindow.top70
            DecompTGT
            DecompRGB
            DecompBMP
            DecompREC
            DecompON
            DecompOFF
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
## Procedure:  DecompTGT

proc ::DecompTGT {} {
global DecompDirInput DecompDirOutput TMPDecompDir
global DecompDecompositionFonction DecompFonction
global NwinDecompL NwinDecompC RGBPolarDecomp BMPPolarDecomp
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine 
global NligInit NligFullSize NcolInit NcolFullSize NligEnd NcolEnd PSPMemory TMPMemoryAllocError TestVarErrorTGT
global OpenDirFile ConfigFile FinalNlig FinalNcol PolarCase PolarType 

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Window Size Row"; set TestVarType(0) "int"; set TestVarValue(0) $NwinDecompL; set TestVarMin(0) "1"; set TestVarMax(0) "1000"
        set TestVarName(1) "Window Size Col"; set TestVarType(1) "int"; set TestVarValue(1) $NwinDecompC; set TestVarMin(1) "1"; set TestVarMax(1) "1000"
        TestVar 2
        set TestVarErrorTGT $TestVarError 
        if {$TestVarError == "ok"} {

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        DeleteMatrixC $TMPDecompDir
        DeleteMatrixT $TMPDecompDir

        set ConfigFile "$TMPDecompDir/config.txt"
        WriteConfig

        set MaskCmd ""
        set MaskFile "$DecompDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

        if [file exists $MaskFile] { 
            CopyFile "$DecompDirInput/mask_valid_pixels.bin" "$TMPDecompDir/mask_valid_pixels.bin"
            CopyFile "$DecompDirInput/mask_valid_pixels.bin.hdr" "$TMPDecompDir/mask_valid_pixels.bin.hdr"
            }

        set Fonction "Creation of all the Binary Data Files"

        set DecompDecompositionF $DecompDecompositionFonction
        if {"$DecompDecompositionFonction" == "S2"} { set DecompDecompositionF "S2T3" }

        if {"$DecompFonction"=="Huynen"} {
            set Fonction2 "of the Huynen Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/huynen_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/huynen_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            }
        if {"$DecompFonction"=="Barnes1"} {
            set Fonction2 "of the Barnes1 Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/barnes1_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/barnes1_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            }
        if {"$DecompFonction"=="Barnes2"} {
            set Fonction2 "of the Barnes2 Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/barnes2_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/barnes2_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            }
        if {"$DecompFonction"=="Cloude"} {
            set Fonction2 "of the Cloude Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/cloude_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/cloude_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            }
        if {"$DecompFonction"=="Holm1"} {
            set Fonction2 "of the Holm1 Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/holm1_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/holm1_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            }
        if {"$DecompFonction"=="Holm2"} {
            set Fonction2 "of the Holm2 Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/holm2_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/holm2_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            }
        if {"$DecompFonction"=="HAAlpha"} {
            set Fonction2 "of the H/A/Alpha Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/haalpha_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/haalpha_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$TMPDecompDir\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $TMPDecompDir $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $TMPDecompDir $FinalNlig $FinalNcol }
            }

        if {"$DecompFonction"=="AnYang3"} {
            set Fonction2 "of the An & Yang Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/an_yang_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/an_yang_3components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/An_Yang3_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/An_Yang3_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/An_Yang3_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/An_Yang3_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/An_Yang3_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/An_Yang3_Vol.bin" $FinalNlig $FinalNcol 4}
            }
        if {"$DecompFonction"=="AnYang4"} {
            set Fonction2 "of the An & Yang Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/an_yang_4components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/an_yang_4components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/An_Yang4_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/An_Yang4_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/An_Yang4_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/An_Yang4_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/An_Yang4_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/An_Yang4_Vol.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/An_Yang4_Hlx.bin"] {EnviWriteConfig "$DecompDirOutput/An_Yang4_Hlx.bin" $FinalNlig $FinalNcol 4}
            }
        if {"$DecompFonction"=="Freeman2"} {
            set Fonction2 "of the Freeman Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/freeman_2components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/freeman_2components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Freeman2_Ground.bin"] {EnviWriteConfig "$DecompDirOutput/Freeman2_Ground.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Freeman2_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Freeman2_Vol.bin" $FinalNlig $FinalNcol 4}
            }
        if {"$DecompFonction"=="Freeman3"} {
            set Fonction2 "of the Freeman Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/freeman_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/freeman_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Freeman_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Freeman_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Freeman_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Freeman_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Freeman_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Freeman_Vol.bin" $FinalNlig $FinalNcol 4}
            }
        if {"$DecompFonction"=="VanZyl3"} {
            set Fonction2 "of the Van Zyl (1992) Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/vanzyl92_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/vanzyl92_3components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/VanZyl3_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/VanZyl3_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/VanZyl3_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/VanZyl3_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/VanZyl3_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/VanZyl3_Vol.bin" $FinalNlig $FinalNcol 4}
            }
        if {"$DecompFonction"=="AriiNNED3"} {
            set Fonction2 "of the Arii NNED Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/arii_nned_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/arii_nned_3components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Arii3_NNED_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_NNED_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Arii3_NNED_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_NNED_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Arii3_NNED_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_NNED_Vol.bin" $FinalNlig $FinalNcol 4}
            }
        if {"$DecompFonction"=="AriiANNED3"} {
            set Fonction2 "of the Arii ANNED Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/arii_anned_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/arii_anned_3components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Arii3_ANNED_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_ANNED_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Arii3_ANNED_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_ANNED_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Arii3_ANNED_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_ANNED_Vol.bin" $FinalNlig $FinalNcol 4}
            }
        if {"$DecompFonction"=="Yamaguchi3"} {
            set Fonction2 "of the Yamaguchi Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/yamaguchi_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/yamaguchi_3components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Yamaguchi3_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi3_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Yamaguchi3_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi3_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Yamaguchi3_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi3_Vol.bin" $FinalNlig $FinalNcol 4}
            }
        if {"$DecompFonction"=="Neumann"} {
            set Fonction2 "of the Neumann Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/neumann_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/neumann_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Neumann_psi.bin"] {EnviWriteConfig "$DecompDirOutput/Neumann_psi.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Neumann_delta_mod.bin"] {EnviWriteConfig "$DecompDirOutput/Neumann_delta_mod.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Neumann_delta_pha.bin"] {EnviWriteConfig "$DecompDirOutput/Neumann_delta_pha.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Neumann_tau.bin"] {EnviWriteConfig "$DecompDirOutput/Neumann_tau.bin" $FinalNlig $FinalNcol 4}
            }
        if {"$DecompFonction"=="Krogager"} {
            set Fonction2 "of the Krogager Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/krogager_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/krogager_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Krogager_Ks.bin"] {EnviWriteConfig "$DecompDirOutput/Krogager_Ks.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Krogager_Kd.bin"] {EnviWriteConfig "$DecompDirOutput/Krogager_Kd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Krogager_Kh.bin"] {EnviWriteConfig "$DecompDirOutput/Krogager_Kh.bin" $FinalNlig $FinalNcol 4}
            }
        if {"$DecompFonction"=="Raney"} {
            set Fonction2 "of the Raney Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/raney_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/raney_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Raney_m.bin"] {EnviWriteConfig "$DecompDirOutput/Raney_m.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Raney_delta.bin"] {EnviWriteConfig "$DecompDirOutput/Raney_delta.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Raney_chi.bin"] {EnviWriteConfig "$DecompDirOutput/Raney_chi.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Raney_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Raney_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Raney_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Raney_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Raney_Rnd.bin"] {EnviWriteConfig "$DecompDirOutput/Raney_Rnd.bin" $FinalNlig $FinalNcol 4}
            }
        if {"$DecompFonction"=="MCSM5"} {
            set Fonction2 "of the MCSM Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/mcsm_5components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/mcsm_5components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/MCSM_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/MCSM_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/MCSM_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/MCSM_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/MCSM_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/MCSM_Vol.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/MCSM_Hlx.bin"] {EnviWriteConfig "$DecompDirOutput/MCSM_Hlx.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/MCSM_Wire.bin"] {EnviWriteConfig "$DecompDirOutput/MCSM_Wire.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/MCSM_DblHlx.bin"] {EnviWriteConfig "$DecompDirOutput/MCSM_DblHlx.bin" $FinalNlig $FinalNcol 4}
            }
        }
        #TestVar
        }
        #Warning
}
#############################################################################
## Procedure:  DecompRGB

proc ::DecompRGB {} {
global DecompDirInput DecompDirOutput
global DecompDecompositionFonction DecompFonction
global RGBPolarDecomp TMPDecompDir PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine 
global NligInit NligFullSize NcolInit NcolFullSize NligEnd NcolEnd FinalNlig FinalNcol PSPViewGimpBMP

if {"$RGBPolarDecomp"=="1"} {
    if {"$VarWarning"=="ok"} {
        #####################################################################       
        
        #Update the Nlig/Ncol of the new image after processing
        set NligInit 1
        set NcolInit 1
        set NligEnd $FinalNlig
        set NcolEnd $FinalNcol
            
        #####################################################################       

        set Fonction "Creation of the RGB File"

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        if {"$DecompDecompositionFonction" == "C3"} { 
            set DecompDecompositionF "C3"
            } else {
            set DecompDecompositionF "T3"
            }
                
        set RGBstyle "pauli"
        if {"$DecompFonction"=="Huynen"} {
            set RGBDirInput $TMPDecompDir
            set RGBFileOutput "$DecompDirOutput/Huynen_RGB.bmp"
            }
        if {"$DecompFonction"=="Barnes1"} {
            set RGBDirInput $TMPDecompDir
            set RGBFileOutput "$DecompDirOutput/Barnes1_RGB.bmp"
            }
        if {"$DecompFonction"=="Barnes2"} {
            set RGBDirInput $TMPDecompDir
            set RGBFileOutput "$DecompDirOutput/Barnes2_RGB.bmp"
            }
        if {"$DecompFonction"=="Cloude"} {
            set RGBDirInput $TMPDecompDir
            set RGBFileOutput "$DecompDirOutput/Cloude_RGB.bmp"
            }
        if {"$DecompFonction"=="Holm1"} {
            set RGBDirInput $TMPDecompDir
            set RGBFileOutput "$DecompDirOutput/Holm1_RGB.bmp"
            }
        if {"$DecompFonction"=="Holm2"} {
            set RGBDirInput $TMPDecompDir
            set RGBFileOutput "$DecompDirOutput/Holm2_RGB.bmp"
            }
        if {"$DecompFonction"=="HAAlpha"} {
            set RGBDirInput $TMPDecompDir
            set RGBFileOutput "$DecompDirOutput/HAAlpha_RGB.bmp"
            }

        if {"$DecompFonction"=="Freeman3"} {
            set RGBDirInput $DecompDirOutput
            set FileInputBlue "$DecompDirOutput/Freeman_Odd.bin"
            set FileInputGreen "$DecompDirOutput/Freeman_Vol.bin"
            set FileInputRed "$DecompDirOutput/Freeman_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/Freeman_RGB.bmp"
            set RGBstyle "combine"
            }
        if {"$DecompFonction"=="VanZyl3"} {
            set RGBDirInput $DecompDirOutput
            set FileInputBlue "$DecompDirOutput/VanZyl3_Odd.bin"
            set FileInputGreen "$DecompDirOutput/VanZyl3_Vol.bin"
            set FileInputRed "$DecompDirOutput/VanZyl3_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/VanZyl3_RGB.bmp"
            set RGBstyle "combine"
            }
        if {"$DecompFonction"=="AriiNNED3"} {
            set RGBDirInput $DecompDirOutput
            set FileInputBlue "$DecompDirOutput/Arii3_NNED_Odd.bin"
            set FileInputGreen "$DecompDirOutput/Arii3_NNED_Vol.bin"
            set FileInputRed "$DecompDirOutput/Arii3_NNED_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/Arii3_NNED_RGB.bmp"
            set RGBstyle "combine"
            }
        if {"$DecompFonction"=="AriiANNED3"} {
            set RGBDirInput $DecompDirOutput
            set FileInputBlue "$DecompDirOutput/Arii3_ANNED_Odd.bin"
            set FileInputGreen "$DecompDirOutput/Arii3_ANNED_Vol.bin"
            set FileInputRed "$DecompDirOutput/Arii3_ANNED_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/Arii3_ANNED_RGB.bmp"
            set RGBstyle "combine"
            }
        if {"$DecompFonction"=="AnYang3"} {
            set RGBDirInput $DecompDirOutput
            set FileInputBlue "$DecompDirOutput/An_Yang3_Odd.bin"
            set FileInputGreen "$DecompDirOutput/An_Yang3_Vol.bin"
            set FileInputRed "$DecompDirOutput/An_Yang3_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/An_Yang3_RGB.bmp"
            set RGBstyle "combine"
            }
        if {"$DecompFonction"=="AnYang4"} {
            set RGBDirInput $DecompDirOutput
            set FileInputBlue "$DecompDirOutput/An_Yang4_Odd.bin"
            set FileInputGreen "$DecompDirOutput/An_Yang4_Vol.bin"
            set FileInputRed "$DecompDirOutput/An_Yang4_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/An_Yang4_RGB.bmp"
            set RGBstyle "combine"
            }
        if {"$DecompFonction"=="Yamaguchi3"} {
            set RGBDirInput $DecompDirOutput
            set FileInputBlue "$DecompDirOutput/Yamaguchi3_Odd.bin"
            set FileInputGreen "$DecompDirOutput/Yamaguchi3_Vol.bin"
            set FileInputRed "$DecompDirOutput/Yamaguchi3_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/Yamaguchi3_RGB.bmp"
            set RGBstyle "combine"
            }
        if {"$DecompFonction"=="Krogager"} {
            set RGBDirInput $DecompDirOutput
            set FileInputBlue "$DecompDirOutput/Krogager_Ks.bin"
            set FileInputGreen "$DecompDirOutput/Krogager_Kh.bin"
            set FileInputRed "$DecompDirOutput/Krogager_Kd.bin"
            set RGBFileOutput "$DecompDirOutput/Krogager_RGB.bmp"
            set RGBstyle "combine"
            }
        if {"$DecompFonction"=="Raney"} {
            set RGBDirInput $DecompDirOutput
            set FileInputBlue "$DecompDirOutput/Raney_Odd.bin"
            set FileInputGreen "$DecompDirOutput/Raney_Rnd.bin"
            set FileInputRed "$DecompDirOutput/Raney_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/Raney_RGB.bmp"
            set RGBstyle "combine"
            }
        if {"$DecompFonction"=="MCSM5"} {
            set RGBDirInput $DecompDirOutput
            set FileInputBlue "$DecompDirOutput/MCSM_Odd.bin"
            set FileInputGreen "$DecompDirOutput/MCSM_Vol.bin"
            set FileInputRed "$DecompDirOutput/MCSM_Dbl.bin"
            set RGBFileOutput "$DecompDirOutput/MCSM_DVS_RGB.bmp"
            set RGBstyle "combine"
            }

        set MaskCmd ""
        set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

        set Fonction2 "$RGBFileOutput"    
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$RGBstyle == "pauli"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $DecompDecompositionF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $DecompDecompositionF -ofr 0 -ofc 0 -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            }
        if {$RGBstyle == "combine"} {
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -ifb $FileInputBlue -ifg $FileInputGreen -ifr $FileInputRed -of $RGBFileOutput -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_rgb_file.exe -ifb $FileInputBlue -ifg $FileInputGreen -ifr $FileInputRed -of $RGBFileOutput -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            }
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        set BMPDirInput $DecompDirOutput
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }

        if {"$DecompFonction"=="MCSM5"} {
            set MaskCmd ""
            set MaskFile "$RGBDirInput/mask_valid_pixels.bin"
            if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }
            set RGBstyle "combine"
            set Fonction2 "$RGBFileOutput"    
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set RGBDirInput $DecompDirOutput

            set FileInputBlue "$DecompDirOutput/MCSM_Odd.bin"
            set FileInputGreen "$DecompDirOutput/MCSM_Vol.bin"
            set FileInputRed "$DecompDirOutput/MCSM_DblHlx.bin"
            set RGBFileOutput "$DecompDirOutput/MCSM_DHVS_RGB.bmp"
            set ProgressLine "0"
            update
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -ifb $FileInputBlue -ifg $FileInputGreen -ifr $FileInputRed -of $RGBFileOutput -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_rgb_file.exe -ifb $FileInputBlue -ifg $FileInputGreen -ifr $FileInputRed -of $RGBFileOutput -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }

            set FileInputBlue "$DecompDirOutput/MCSM_Odd.bin"
            set FileInputGreen "$DecompDirOutput/MCSM_Vol.bin"
            set FileInputRed "$DecompDirOutput/MCSM_Wire.bin"
            set RGBFileOutput "$DecompDirOutput/MCSM_WVS_RGB.bmp"
            set ProgressLine "0"
            update
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -ifb $FileInputBlue -ifg $FileInputGreen -ifr $FileInputRed -of $RGBFileOutput -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_rgb_file.exe -ifb $FileInputBlue -ifg $FileInputGreen -ifr $FileInputRed -of $RGBFileOutput -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }

            set FileInputBlue "$DecompDirOutput/MCSM_Hlx.bin"
            set FileInputGreen "$DecompDirOutput/MCSM_Vol.bin"
            set FileInputRed "$DecompDirOutput/MCSM_Wire.bin"
            set RGBFileOutput "$DecompDirOutput/MCSM_WVH_RGB.bmp"
            set ProgressLine "0"
            update
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -ifb $FileInputBlue -ifg $FileInputGreen -ifr $FileInputRed -of $RGBFileOutput -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_rgb_file.exe -ifb $FileInputBlue -ifg $FileInputGreen -ifr $FileInputRed -of $RGBFileOutput -inc $FinalNcol -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }

            set BMPDirInput $DecompDirOutput
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            }
        }
    }
    #RGBPolarDecomp
}
#############################################################################
## Procedure:  DecompBMP

proc ::DecompBMP {} {
global DecompDirInput DecompDirOutput TMPDecompDir
global DecompDecompositionFonction DecompFonction
global BMPPolarDecomp
global MinMaxBMPDecomp MinBMPDecomp MaxBMPDecomp
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine 
global NligInit NligFullSize NcolInit NcolFullSize NligEnd NcolEnd FinalNlig FinalNcol

if {"$BMPPolarDecomp"=="1"} {
    if {"$VarWarning"=="ok"} {
        #####################################################################       
        
        #Update the Nlig/Ncol of the new image after processing
        set NligInit 1
        set NcolInit 1
        set NligEnd $FinalNlig
        set NcolEnd $FinalNcol
            
        #####################################################################       

        if {"$MinMaxBMPDecomp"=="1"} {
            set MinBMPDecomp "-9999"
            set MaxBMPDecomp "+9999"
            }

        set TestVarName(0) "Min Value"; set TestVarType(0) "float"; set TestVarValue(0) $MinBMPDecomp; set TestVarMin(0) "-10000.00"; set TestVarMax(0) "10000.00"
        set TestVarName(1) "Max Value"; set TestVarType(1) "float"; set TestVarValue(1) $MaxBMPDecomp; set TestVarMin(1) "-10000.00"; set TestVarMax(1) "10000.00"
        TestVar 2
        if {$TestVarError == "ok"} {

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        if {"$DecompFonction"=="Huynen"} {
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C11.bin"
                set BMPFileOutput "$DecompDirOutput/Huynen_C11_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T11.bin"
                set BMPFileOutput "$DecompDirOutput/Huynen_T11_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C22.bin"
                set BMPFileOutput "$DecompDirOutput/Huynen_C22_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T22.bin"
                set BMPFileOutput "$DecompDirOutput/Huynen_T22_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C33.bin"
                set BMPFileOutput "$DecompDirOutput/Huynen_C33_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T33.bin"
                set BMPFileOutput "$DecompDirOutput/Huynen_T33_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="Barnes1"} {
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C11.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes1_C11_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T11.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes1_T11_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C22.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes1_C22_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T22.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes1_T22_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C33.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes1_C33_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T33.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes1_T33_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="Barnes2"} {
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C11.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes2_C11_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T11.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes2_T11_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C22.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes2_C22_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T22.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes2_T22_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C33.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes2_C33_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T33.bin"
                set BMPFileOutput "$DecompDirOutput/Barnes2_T33_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="Cloude"} {
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C11.bin"
                set BMPFileOutput "$DecompDirOutput/Cloude_C11_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T11.bin"
                set BMPFileOutput "$DecompDirOutput/Cloude_T11_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C22.bin"
                set BMPFileOutput "$DecompDirOutput/Cloude_C22_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T22.bin"
                set BMPFileOutput "$DecompDirOutput/Cloude_T22_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C33.bin"
                set BMPFileOutput "$DecompDirOutput/Cloude_C33_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T33.bin"
                set BMPFileOutput "$DecompDirOutput/Cloude_T33_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="Holm1"} {
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C11.bin"
                set BMPFileOutput "$DecompDirOutput/Holm1_C11_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T11.bin"
                set BMPFileOutput "$DecompDirOutput/Holm1_T11_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C22.bin"
                set BMPFileOutput "$DecompDirOutput/Holm1_C22_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T22.bin"
                set BMPFileOutput "$DecompDirOutput/Holm1_T22_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C33.bin"
                set BMPFileOutput "$DecompDirOutput/Holm1_C33_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T33.bin"
                set BMPFileOutput "$DecompDirOutput/Holm1_T33_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="Holm2"} {
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C11.bin"
                set BMPFileOutput "$DecompDirOutput/Holm2_C11_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T11.bin"
                set BMPFileOutput "$DecompDirOutput/Holm2_T11_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C22.bin"
                set BMPFileOutput "$DecompDirOutput/Holm2_C22_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T22.bin"
                set BMPFileOutput "$DecompDirOutput/Holm2_T22_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C33.bin"
                set BMPFileOutput "$DecompDirOutput/Holm2_C33_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T33.bin"
                set BMPFileOutput "$DecompDirOutput/Holm2_T33_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="HAAlpha"} {
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C11.bin"
                set BMPFileOutput "$DecompDirOutput/HAAlpha_C11_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T11.bin"
                set BMPFileOutput "$DecompDirOutput/HAAlpha_T11_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C22.bin"
                set BMPFileOutput "$DecompDirOutput/HAAlpha_C22_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T22.bin"
                set BMPFileOutput "$DecompDirOutput/HAAlpha_T22_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            if {"$DecompDecompositionFonction" == "C3"} {
                set BMPFileInput "$TMPDecompDir/C33.bin"
                set BMPFileOutput "$DecompDirOutput/HAAlpha_C33_dB.bmp"
                } else {
                set BMPFileInput "$TMPDecompDir/T33.bin"
                set BMPFileOutput "$DecompDirOutput/HAAlpha_T33_dB.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }

        if {"$DecompFonction"=="Freeman2"} {
            set BMPFileInput "$DecompDirOutput/Freeman2_Ground.bin"
            set BMPFileOutput "$DecompDirOutput/Freeman2_Ground_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Freeman2_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/Freeman2_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="Freeman3"} {
            set BMPFileInput "$DecompDirOutput/Freeman_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/Freeman_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Freeman_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/Freeman_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Freeman_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/Freeman_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="VanZyl3"} {
            set BMPFileInput "$DecompDirOutput/VanZyl3_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/VanZyl3_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/VanZyl3_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/VanZyl3_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/VanZyl3_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/VanZyl3_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="AriiNNED3"} {
            set BMPFileInput "$DecompDirOutput/Arii3_NNED_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/Arii3_NNED_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Arii3_NNED_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/Arii3_NNED_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Arii3_NNED_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/Arii3_NNED_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="AriiANNED3"} {
            set BMPFileInput "$DecompDirOutput/Arii3_ANNED_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/Arii3_ANNED_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Arii3_ANNED_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/Arii3_ANNED_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Arii3_ANNED_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/Arii3_ANNED_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="AnYang3"} {
            set BMPFileInput "$DecompDirOutput/An_Yang3_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/An_Yang3_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/An_Yang3_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/An_Yang3_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/An_Yang3_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/An_Yang3_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="AnYang4"} {
            set BMPFileInput "$DecompDirOutput/An_Yang4_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/An_Yang4_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/An_Yang4_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/An_Yang4_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/An_Yang4_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/An_Yang4_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/An_Yang4_Hlx.bin"
            set BMPFileOutput "$DecompDirOutput/An_Yang4_Hlx_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="Yamaguchi3"} {
            set BMPFileInput "$DecompDirOutput/Yamaguchi3_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi3_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Yamaguchi3_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi3_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Yamaguchi3_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/Yamaguchi3_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="Neumann"} {
            set BMPFileInput "$DecompDirOutput/Neumann_psi.bin"
            set BMPFileOutput "$DecompDirOutput/Neumann_psi.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -180 +180
            set BMPFileInput "$DecompDirOutput/Neumann_delta_mod.bin"
            set BMPFileOutput "$DecompDirOutput/Neumann_delta_mod.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Neumann_delta_pha.bin"
            set BMPFileOutput "$DecompDirOutput/Neumann_delta_pha.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -180 +180
            set BMPFileInput "$DecompDirOutput/Neumann_tau.bin"
            set BMPFileOutput "$DecompDirOutput/Neumann_tau.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            }
        if {"$DecompFonction"=="Krogager"} {
            set BMPFileInput "$DecompDirOutput/Krogager_Ks.bin"
            set BMPFileOutput "$DecompDirOutput/Krogager_Ks_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Krogager_Kd.bin"
            set BMPFileOutput "$DecompDirOutput/Krogager_Kd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Krogager_Kh.bin"
            set BMPFileOutput "$DecompDirOutput/Krogager_Kh_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="Raney"} {
            set BMPFileInput "$DecompDirOutput/Raney_m.bin"
            set BMPFileOutput "$DecompDirOutput/Raney_m.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            set BMPFileInput "$DecompDirOutput/Raney_delta.bin"
            set BMPFileOutput "$DecompDirOutput/Raney_deltal.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -90 +90
            set BMPFileInput "$DecompDirOutput/Raney_chi.bin"
            set BMPFileOutput "$DecompDirOutput/Raney_chi.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -45 +45
            set BMPFileInput "$DecompDirOutput/Raney_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/Raney_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Raney_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/Raney_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/Raney_Rnd.bin"
            set BMPFileOutput "$DecompDirOutput/Raney_Rnd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }
        if {"$DecompFonction"=="MCSM5"} {
            set BMPFileInput "$DecompDirOutput/MCSM_Odd.bin"
            set BMPFileOutput "$DecompDirOutput/MCSM_Odd_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/MCSM_Dbl.bin"
            set BMPFileOutput "$DecompDirOutput/MCSM_Dbl_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/MCSM_Vol.bin"
            set BMPFileOutput "$DecompDirOutput/MCSM_Vol_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/MCSM_Hlx.bin"
            set BMPFileOutput "$DecompDirOutput/MCSM_Hlx_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/MCSM_Wire.bin"
            set BMPFileOutput "$DecompDirOutput/MCSM_Wire_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            set BMPFileInput "$DecompDirOutput/MCSM_DblHlx.bin"
            set BMPFileOutput "$DecompDirOutput/MCSM_DblHlx_dB.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float db10 gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol $MinMaxBMPDecomp $MinBMPDecomp $MaxBMPDecomp
            }

        set BMPDirInput $DecompDirOutput

        }
        #TestVar
        }
        #Warning
    }
    #BMPPolarDecomp
   
}
#############################################################################
## Procedure:  DecompREC

proc ::DecompREC {} {
global DecompDirInput DecompDirOutput DecompOutputSubDirTmp
global DecompDirOutput1 DecompOutputDir1 DecompOutputSubDir1
global DecompDirOutput2 DecompOutputDir2 DecompOutputSubDir2
global DecompDirOutput3 DecompOutputDir3 DecompOutputSubDir3
global DecompDirOutput4 DecompOutputDir4 DecompOutputSubDir4
global DecompDecompositionFonction DecompFonction
global NwinDecompL NwinDecompC RGBPolarDecomp BMPPolarDecomp
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax 
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine 
global NligInit NligFullSize NcolInit NcolFullSize NligEnd NcolEnd PSPMemory TMPMemoryAllocError
global OpenDirFile ConfigFile FinalNlig FinalNcol PolarCase PolarType PSPViewGimpBMP


if {"$DecompFonction"=="Huynen"} { set CreateDirDecomp "1" }
if {"$DecompFonction"=="Barnes1"} { set CreateDirDecomp "1" }
if {"$DecompFonction"=="Barnes2"} { set CreateDirDecomp "1" }
if {"$DecompFonction"=="Cloude"} { set CreateDirDecomp "1" }
if {"$DecompFonction"=="Holm1"} { set CreateDirDecomp "1" }
if {"$DecompFonction"=="Holm2"} { set CreateDirDecomp "1" }
if {"$DecompFonction"=="HAAlpha"} { set CreateDirDecomp "1" }
if {"$DecompFonction"=="Freeman2"} { set CreateDirDecomp "2" }
if {"$DecompFonction"=="Freeman3"} { set CreateDirDecomp "3" }
if {"$DecompFonction"=="VanZyl3"} { set CreateDirDecomp "3" }
if {"$DecompFonction"=="Yamaguchi3"} { set CreateDirDecomp "3" }

if { $CreateDirDecomp == 1 } {
    set DecompDirOutput1 $DecompOutputDir1
    if {$DecompOutputSubDir1 != ""} {append DecompDirOutput1 "/$DecompOutputSubDir1"}
    #####################################################################
    #Create Directory
    set DecompDirOutput1 [PSPCreateDirectory $DecompDirOutput1 $DecompOutputDir1 $DecompOutputSubDir1]
    #####################################################################       
    }
if { $CreateDirDecomp == 2 } {
    set VarWarning2 ""
    set DecompDirOutput1 $DecompOutputDir1
    if {$DecompOutputSubDir1 != ""} {append DecompDirOutput1 "/$DecompOutputSubDir1"}
    #####################################################################
    #Create Directory
    set DecompDirOutput1 [PSPCreateDirectory $DecompDirOutput1 $DecompOutputDir1 $DecompOutputSubDir1]
    ##################################################################### 
    append VarWarning2 $VarWarning
    set DecompDirOutput2 $DecompOutputDir2
    if {$DecompOutputSubDir2 != ""} {append DecompDirOutput2 "/$DecompOutputSubDir2"}
    #####################################################################
    #Create Directory
    set DecompDirOutput2 [PSPCreateDirectory $DecompDirOutput2 $DecompOutputDir2 $DecompOutputSubDir2]
    ##################################################################### 
    append VarWarning2 $VarWarning
    if {$VarWarning2 == "okok"} { set VarWarning "ok"}      
    }
if { $CreateDirDecomp == 3 } {
    set VarWarning3 ""
    set DecompDirOutput1 $DecompOutputDir1
    if {$DecompOutputSubDir1 != ""} {append DecompDirOutput1 "/$DecompOutputSubDir1"}
    #####################################################################
    #Create Directory
    set DecompDirOutput1 [PSPCreateDirectory $DecompDirOutput1 $DecompOutputDir1 $DecompOutputSubDir1]
    ##################################################################### 
    append VarWarning3 $VarWarning
    set DecompDirOutput2 $DecompOutputDir2
    if {$DecompOutputSubDir2 != ""} {append DecompDirOutput2 "/$DecompOutputSubDir2"}
    #####################################################################
    #Create Directory
    set DecompDirOutput2 [PSPCreateDirectory $DecompDirOutput2 $DecompOutputDir2 $DecompOutputSubDir2]
    ##################################################################### 
    append VarWarning3 $VarWarning
    set DecompDirOutput3 $DecompOutputDir3
    if {$DecompOutputSubDir3 != ""} {append DecompDirOutput3 "/$DecompOutputSubDir3"}
    #####################################################################
    #Create Directory
    set DecompDirOutput3 [PSPCreateDirectory $DecompDirOutput3 $DecompOutputDir3 $DecompOutputSubDir3]
    ##################################################################### 
    append VarWarning3 $VarWarning
    if {$VarWarning3 == "okokok"} { set VarWarning "ok"}      
    }

    if {"$VarWarning"=="ok"} {
        set TestVarName(0) "Window Size Row"; set TestVarType(0) "int"; set TestVarValue(0) $NwinDecompL; set TestVarMin(0) "1"; set TestVarMax(0) "1000"
        set TestVarName(1) "Window Size Col"; set TestVarType(1) "int"; set TestVarValue(1) $NwinDecompC; set TestVarMin(1) "1"; set TestVarMax(1) "1000"
        TestVar 2
        if {$TestVarError == "ok"} {

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        set ConfigFile "$DecompDirOutput1/config.txt"
        WriteConfig

        set MaskCmd ""
        set MaskFile "$DecompDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] { set MaskCmd "-mask \x22$MaskFile\x22" }

        set Fonction "Creation of all the Binary Data Files"

        set DecompDecompositionF $DecompDecompositionFonction
        if {"$DecompDecompositionFonction" == "S2"} { set DecompDecompositionF "S2T3" }

        if {"$DecompFonction"=="Huynen"} {
            set Fonction2 "of the Huynen Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/huynen_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/huynen_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionF
            if {"$DecompDecompositionF"=="S2T3"} { set RGBiodf "T3" }
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $RGBDirOutput
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="Barnes1"} {
            set Fonction2 "of the Barnes1 Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/barnes1_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/barnes1_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionF
            if {"$DecompDecompositionF"=="S2T3"} { set RGBiodf "T3" }
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $RGBDirOutput
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="Barnes2"} {
            set Fonction2 "of the Barnes2 Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/barnes2_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/barnes2_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionF
            if {"$DecompDecompositionF"=="S2T3"} { set RGBiodf "T3" }
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $RGBDirOutput
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="Cloude"} {
            set Fonction2 "of the Cloude Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/cloude_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/cloude_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionF
            if {"$DecompDecompositionF"=="S2T3"} { set RGBiodf "T3" }
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $RGBDirOutput
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="Holm1"} {
            set Fonction2 "of the Holm1 Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/holm1_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/holm1_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionF
            if {"$DecompDecompositionF"=="S2T3"} { set RGBiodf "T3" }
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $RGBDirOutput
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="Holm2"} {
            set Fonction2 "of the Holm2 Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/holm2_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/holm2_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionF
            if {"$DecompDecompositionF"=="S2T3"} { set RGBiodf "T3" }
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $RGBDirOutput
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="HAAlpha"} {
            set Fonction2 "of the H/A/Alpha Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/haalpha_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/haalpha_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput1\x22 -iodf $DecompDecompositionF -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionF"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionF"=="S2T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionF
            if {"$DecompDecompositionF"=="S2T3"} { set RGBiodf "T3" }
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $RGBDirOutput
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="Freeman2"} {
            set ConfigFile "$DecompDirOutput2/config.txt"; WriteConfig
            set Fonction2 "of the Freeman Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/freeman_2components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/freeman_2components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Freeman2_Ground.bin"] {EnviWriteConfig "$DecompDirOutput/Freeman2_Ground.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Freeman2_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Freeman2_Vol.bin" $FinalNlig $FinalNcol 4}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/freeman_2components_reconstruction.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/freeman_2components_reconstruction.exe -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionFonction"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigC $DecompDirOutput2 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="S2"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionFonction
            if {"$DecompDecompositionFonction"=="S2"} { set RGBiodf "T3" }
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput2; set RGBDirOutput $DecompDirOutput2
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $DecompDirOutput1
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="Freeman3"} {
            set ConfigFile "$DecompDirOutput2/config.txt"; WriteConfig
            set ConfigFile "$DecompDirOutput3/config.txt"; WriteConfig
            set Fonction2 "of the Freeman Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/freeman_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/freeman_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Freeman_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Freeman_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Freeman_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Freeman_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Freeman_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Freeman_Vol.bin" $FinalNlig $FinalNcol 4}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/freeman_reconstruction.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -od3 \x22$DecompDirOutput3\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/freeman_reconstruction.exe -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -od3 \x22$DecompDirOutput3\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionFonction"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput3 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigC $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigC $DecompDirOutput3 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="S2"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput3 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionFonction
            if {"$DecompDecompositionFonction"=="S2"} { set RGBiodf "T3" }
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput2; set RGBDirOutput $DecompDirOutput2
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput3; set RGBDirOutput $DecompDirOutput3
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $DecompDirOutput1
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="VanZyl3"} {
            set ConfigFile "$DecompDirOutput2/config.txt"; WriteConfig
            set ConfigFile "$DecompDirOutput3/config.txt"; WriteConfig
            set Fonction2 "of the Van Zyl (1992) Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/vanzyl92_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/vanzyl92_3components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/VanZyl3_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/VanZyl3_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/VanZyl3_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/VanZyl3_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/VanZyl3_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/VanZyl3_Vol.bin" $FinalNlig $FinalNcol 4}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/vanzyl92_3components_reconstruction.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -od3 \x22$DecompDirOutput3\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/vanzyl92_3components_reconstruction.exe -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -od3 \x22$DecompDirOutput3\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionFonction"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput3 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigC $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigC $DecompDirOutput3 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="S2"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput3 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionFonction
            if {"$DecompDecompositionFonction"=="S2"} { set RGBiodf "T3" }
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput2; set RGBDirOutput $DecompDirOutput2
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput3; set RGBDirOutput $DecompDirOutput3
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $DecompDirOutput1
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="AriiNNED3"} {
            set ConfigFile "$DecompDirOutput2/config.txt"; WriteConfig
            set ConfigFile "$DecompDirOutput3/config.txt"; WriteConfig
            set Fonction2 "of the Arii - NNED Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/arii_nned_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/arii_nned_3components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Arii3_NNED_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_NNED_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Arii3_NNED_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_NNED_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Arii3_NNED_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_NNED_Vol.bin" $FinalNlig $FinalNcol 4}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/arii_nned_3components_reconstruction.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -od3 \x22$DecompDirOutput3\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/arii_nned_3components_reconstruction.exe -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -od3 \x22$DecompDirOutput3\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionFonction"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput3 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigC $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigC $DecompDirOutput3 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="S2"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput3 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionFonction
            if {"$DecompDecompositionFonction"=="S2"} { set RGBiodf "T3" }
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput2; set RGBDirOutput $DecompDirOutput2
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput3; set RGBDirOutput $DecompDirOutput3
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $DecompDirOutput1
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="AriiANNED3"} {
            set ConfigFile "$DecompDirOutput2/config.txt"; WriteConfig
            set ConfigFile "$DecompDirOutput3/config.txt"; WriteConfig
            set Fonction2 "of the Arii - ANNED Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/arii_anned_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/arii_anned_3components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Arii3_ANNED_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_ANNED_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Arii3_ANNED_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_ANNED_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Arii3_ANNED_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Arii3_ANNED_Vol.bin" $FinalNlig $FinalNcol 4}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/arii_anned_3components_reconstruction.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -od3 \x22$DecompDirOutput3\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/arii_anned_3components_reconstruction.exe -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -od3 \x22$DecompDirOutput3\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionFonction"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput3 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigC $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigC $DecompDirOutput3 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="S2"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput3 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionFonction
            if {"$DecompDecompositionFonction"=="S2"} { set RGBiodf "T3" }
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput2; set RGBDirOutput $DecompDirOutput2
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput3; set RGBDirOutput $DecompDirOutput3
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $DecompDirOutput1
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        if {"$DecompFonction"=="Yamaguchi3"} {
            set ConfigFile "$DecompDirOutput2/config.txt"; WriteConfig
            set ConfigFile "$DecompDirOutput3/config.txt"; WriteConfig
            set Fonction2 "of the Yamaguchi Decomposition"
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/yamaguchi_3components_decomposition.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/yamaguchi_3components_decomposition.exe -id \x22$DecompDirInput\x22 -od \x22$DecompDirOutput\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if [file exists "$DecompDirOutput/Yamaguchi3_Odd.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi3_Odd.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Yamaguchi3_Dbl.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi3_Dbl.bin" $FinalNlig $FinalNcol 4}
            if [file exists "$DecompDirOutput/Yamaguchi3_Vol.bin"] {EnviWriteConfig "$DecompDirOutput/Yamaguchi3_Vol.bin" $FinalNlig $FinalNcol 4}
            set ProgressLine "0"
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            update
            TextEditorRunTrace "Process The Function Soft/data_process_sngl/yamaguchi_3components_reconstruction.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -od3 \x22$DecompDirOutput3\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
            set f [ open "| Soft/data_process_sngl/yamaguchi_3components_reconstruction.exe -id \x22$DecompDirInput\x22 -od1 \x22$DecompDirOutput1\x22 -od2 \x22$DecompDirOutput2\x22 -od3 \x22$DecompDirOutput3\x22 -iodf $DecompDecompositionFonction -nwr $NwinDecompL -nwc $NwinDecompC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {"$DecompDecompositionFonction"=="T3"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput3 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="C3"} { EnviWriteConfigC $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigC $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigC $DecompDirOutput3 $FinalNlig $FinalNcol }
            if {"$DecompDecompositionFonction"=="S2"} { EnviWriteConfigT $DecompDirOutput1 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput2 $FinalNlig $FinalNcol; EnviWriteConfigT $DecompDirOutput3 $FinalNlig $FinalNcol }
            set RGBiodf $DecompDecompositionFonction
            if {"$DecompDecompositionFonction"=="S2"} { set RGBiodf "T3" }
            WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput1; set RGBDirOutput $DecompDirOutput1
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput2; set RGBDirOutput $DecompDirOutput2
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            set ProgressLine "0"
            update
            set RGBDirInput $DecompDirOutput3; set RGBDirOutput $DecompDirOutput3
            set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp"
            TextEditorRunTrace "Process The Function Soft/bmp_process/create_pauli_rgb_file.exe" "k"
            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" "k"
            set f [ open "| Soft/bmp_process/create_pauli_rgb_file.exe -id \x22$RGBDirInput\x22 -of \x22$RGBFileOutput\x22 -iodf $RGBiodf -ofr 0 -ofc 0 -fnr $NligFullSize -fnc $NcolFullSize -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd -auto 1" r]
            PsPprogressBar $f
            TextEditorRunTrace "Check RunTime Errors" "r"
            CheckRunTimeError
            set BMPDirInput $DecompDirOutput1
            WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
            if {$PSPViewGimpBMP == 1} { Gimp $RGBFileOutput }
            }

        }
        #TestVar
        }
        #Warning
}
#############################################################################
## Procedure:  DecompON

proc ::DecompON {} {
global PolarDecomp DecompOutputDir DecompOutputSubDir DecompDirOutputTmp DecompFonction DecompDecompositionFonction
global DecompOutputDir1 DecompOutputSubDir1 DecompOutputDir2 DecompOutputSubDir2
global DecompOutputDir3 DecompOutputSubDir3 DecompOutputDir4 DecompOutputSubDir4
global DecompOutputSubDirTmp PSPBackgroundColor

set widget_TitleFrame70_1 .top70.fra74.cpd78
set widget_TitleFrame70_2 .top70.fra74.cpd79
set widget_TitleFrame70_3 .top70.fra74.cpd80
set widget_TitleFrame70_4 .top70.fra74.cpd81
set widget_Entry70_4 .top70.fra74.cpd78.f.cpd85
set widget_Entry70_5 .top70.fra74.cpd79.f.cpd85
set widget_Entry70_6 .top70.fra74.cpd80.f.cpd85
set widget_Entry70_7 .top70.fra74.cpd81.f.cpd85
set widget_Entry70_8 .top70.fra74.cpd78.f.cpd91.cpd75
set widget_Entry70_9 .top70.fra74.cpd79.f.cpd91.cpd75
set widget_Entry70_10 .top70.fra74.cpd80.f.cpd91.cpd75
set widget_Entry70_11 .top70.fra74.cpd81.f.cpd91.cpd75
set widget_Button70_1 .top70.fra74.cpd78.f.cpd74.cpd71
set widget_Button70_2 .top70.fra74.cpd79.f.cpd74.cpd71
set widget_Button70_3 .top70.fra74.cpd80.f.cpd74.cpd71
set widget_Button70_4 .top70.fra74.cpd81.f.cpd74.cpd71
set widget_Label70_4 .top70.fra74.fra75.cpd77.lab78
set widget_Radiobutton70_1 .top70.fra74.fra75.cpd77.rad79
set widget_Radiobutton70_2 .top70.fra74.fra75.cpd77.cpd80

    $widget_TitleFrame70_1 configure -state disable; $widget_TitleFrame70_1 configure -text ""
    $widget_TitleFrame70_2 configure -state disable; $widget_TitleFrame70_2 configure -text ""
    $widget_TitleFrame70_3 configure -state disable; $widget_TitleFrame70_3 configure -text ""
    $widget_TitleFrame70_4 configure -state disable; $widget_TitleFrame70_4 configure -text ""
    $widget_Entry70_4 configure -state disable; $widget_Entry70_4 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_5 configure -state disable; $widget_Entry70_5 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_6 configure -state disable; $widget_Entry70_6 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_7 configure -state disable; $widget_Entry70_7 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_9 configure -state disable; $widget_Entry70_9 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_10 configure -state disable; $widget_Entry70_10 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_11 configure -state disable; $widget_Entry70_11 configure -disabledbackground $PSPBackgroundColor
    $widget_Button70_1 configure -state disable; $widget_Button70_2 configure -state disable
    $widget_Button70_3 configure -state disable; $widget_Button70_4 configure -state disable

    set DecompOutputDir1 ""; set DecompOutputSubDir1 ""; set DecompOutputDir2 ""; set DecompOutputSubDir2 ""
    set DecompOutputDir3 ""; set DecompOutputSubDir3 ""; set DecompOutputDir4 ""; set DecompOutputSubDir4 ""
    set DecompOutputSubDirTmp ""
    $widget_Label70_4 configure -state disable
    $widget_Radiobutton70_1 configure -state disable
    $widget_Radiobutton70_2 configure -state disable

    set DecompOutputSubDirTmp $DecompOutputSubDir
    if {"$DecompDecompositionFonction" == "S2"} {
        set DecompOutputSubDirTmp "T3"
        $widget_Label70_4 configure -state normal
        $widget_Radiobutton70_1 configure -state normal
        $widget_Radiobutton70_2 configure -state normal
        }

    if {$DecompFonction == "Huynen"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_JRH"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Target Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal;
        }

    if {$DecompFonction == "Barnes1"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_RMB1"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Target Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal;
        }

    if {$DecompFonction == "Barnes2"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_RMB2"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Target Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal;
        }

    if {$DecompFonction == "Cloude"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_SRC"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Target Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal;
        }

    if {$DecompFonction == "Holm1"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_WAH1"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Target Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal;
        }

    if {$DecompFonction == "Holm2"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_WAH2"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Target Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal;
        }

    if {$DecompFonction == "HAAlpha"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_HAA"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Target Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal;
        }

    if {$DecompFonction == "Freeman2"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_FRE2_GRD"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        set DecompOutputDir2 $DecompOutputDir; append DecompOutputDir2 "_FRE2_VOL"
        set DecompOutputSubDir2 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Ground Component"
        $widget_TitleFrame70_2 configure -state normal; $widget_TitleFrame70_2 configure -text "Output Directory - Volume Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_5 configure -state normal; $widget_Entry70_5 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Entry70_9 configure -state disable; $widget_Entry70_9 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal; $widget_Button70_2 configure -state normal;
        }

    if {$DecompFonction == "Freeman3"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_FRE3_ODD"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        set DecompOutputDir2 $DecompOutputDir; append DecompOutputDir2 "_FRE3_DBL"
        set DecompOutputSubDir2 $DecompOutputSubDirTmp
        set DecompOutputDir3 $DecompOutputDir; append DecompOutputDir3 "_FRE3_VOL"
        set DecompOutputSubDir3 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Odd Bounce Component"
        $widget_TitleFrame70_2 configure -state normal; $widget_TitleFrame70_2 configure -text "Output Directory - Double Bounce Component"
        $widget_TitleFrame70_3 configure -state normal; $widget_TitleFrame70_3 configure -text "Output Directory - Volume Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_5 configure -state normal; $widget_Entry70_5 configure -disabledbackground #FFFFFF
        $widget_Entry70_6 configure -state normal; $widget_Entry70_6 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Entry70_9 configure -state disable; $widget_Entry70_9 configure -disabledbackground #FFFFFF
        $widget_Entry70_10 configure -state disable; $widget_Entry70_10 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal; $widget_Button70_2 configure -state normal; $widget_Button70_3 configure -state normal;
        }

    if {$DecompFonction == "VanZyl3"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_VZ3_ODD"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        set DecompOutputDir2 $DecompOutputDir; append DecompOutputDir2 "_VZ3_DBL"
        set DecompOutputSubDir2 $DecompOutputSubDirTmp
        set DecompOutputDir3 $DecompOutputDir; append DecompOutputDir3 "_VZ3_VOL"
        set DecompOutputSubDir3 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Odd Bounce Component"
        $widget_TitleFrame70_2 configure -state normal; $widget_TitleFrame70_2 configure -text "Output Directory - Double Bounce Component"
        $widget_TitleFrame70_3 configure -state normal; $widget_TitleFrame70_3 configure -text "Output Directory - Volume Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_5 configure -state normal; $widget_Entry70_5 configure -disabledbackground #FFFFFF
        $widget_Entry70_6 configure -state normal; $widget_Entry70_6 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Entry70_9 configure -state disable; $widget_Entry70_9 configure -disabledbackground #FFFFFF
        $widget_Entry70_10 configure -state disable; $widget_Entry70_10 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal; $widget_Button70_2 configure -state normal; $widget_Button70_3 configure -state normal;
        }

    if {$DecompFonction == "AriiNNED3"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_NNED_ODD"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        set DecompOutputDir2 $DecompOutputDir; append DecompOutputDir2 "_NNED_DBL"
        set DecompOutputSubDir2 $DecompOutputSubDirTmp
        set DecompOutputDir3 $DecompOutputDir; append DecompOutputDir3 "_NNED_VOL"
        set DecompOutputSubDir3 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Odd Bounce Component"
        $widget_TitleFrame70_2 configure -state normal; $widget_TitleFrame70_2 configure -text "Output Directory - Double Bounce Component"
        $widget_TitleFrame70_3 configure -state normal; $widget_TitleFrame70_3 configure -text "Output Directory - Volume Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_5 configure -state normal; $widget_Entry70_5 configure -disabledbackground #FFFFFF
        $widget_Entry70_6 configure -state normal; $widget_Entry70_6 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Entry70_9 configure -state disable; $widget_Entry70_9 configure -disabledbackground #FFFFFF
        $widget_Entry70_10 configure -state disable; $widget_Entry70_10 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal; $widget_Button70_2 configure -state normal; $widget_Button70_3 configure -state normal;
        }

    if {$DecompFonction == "AriiANNED3"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_ANNED_ODD"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        set DecompOutputDir2 $DecompOutputDir; append DecompOutputDir2 "_ANNED_DBL"
        set DecompOutputSubDir2 $DecompOutputSubDirTmp
        set DecompOutputDir3 $DecompOutputDir; append DecompOutputDir3 "_ANNED_VOL"
        set DecompOutputSubDir3 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Odd Bounce Component"
        $widget_TitleFrame70_2 configure -state normal; $widget_TitleFrame70_2 configure -text "Output Directory - Double Bounce Component"
        $widget_TitleFrame70_3 configure -state normal; $widget_TitleFrame70_3 configure -text "Output Directory - Volume Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_5 configure -state normal; $widget_Entry70_5 configure -disabledbackground #FFFFFF
        $widget_Entry70_6 configure -state normal; $widget_Entry70_6 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Entry70_9 configure -state disable; $widget_Entry70_9 configure -disabledbackground #FFFFFF
        $widget_Entry70_10 configure -state disable; $widget_Entry70_10 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal; $widget_Button70_2 configure -state normal; $widget_Button70_3 configure -state normal;
        }

    if {$DecompFonction == "Yamaguchi3"} {
        set DecompOutputDir1 $DecompOutputDir; append DecompOutputDir1 "_YAM3_ODD"
        set DecompOutputSubDir1 $DecompOutputSubDirTmp
        set DecompOutputDir2 $DecompOutputDir; append DecompOutputDir2 "_YAM3_DBL"
        set DecompOutputSubDir2 $DecompOutputSubDirTmp
        set DecompOutputDir3 $DecompOutputDir; append DecompOutputDir3 "_YAM3_VOL"
        set DecompOutputSubDir3 $DecompOutputSubDirTmp
        $widget_TitleFrame70_1 configure -state normal; $widget_TitleFrame70_1 configure -text "Output Directory - Odd Bounce Component"
        $widget_TitleFrame70_2 configure -state normal; $widget_TitleFrame70_2 configure -text "Output Directory - Double Bounce Component"
        $widget_TitleFrame70_3 configure -state normal; $widget_TitleFrame70_3 configure -text "Output Directory - Volume Component"
        $widget_Entry70_4 configure -state normal; $widget_Entry70_4 configure -disabledbackground #FFFFFF
        $widget_Entry70_5 configure -state normal; $widget_Entry70_5 configure -disabledbackground #FFFFFF
        $widget_Entry70_6 configure -state normal; $widget_Entry70_6 configure -disabledbackground #FFFFFF
        $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground #FFFFFF
        $widget_Entry70_9 configure -state disable; $widget_Entry70_9 configure -disabledbackground #FFFFFF
        $widget_Entry70_10 configure -state disable; $widget_Entry70_10 configure -disabledbackground #FFFFFF
        $widget_Button70_1 configure -state normal; $widget_Button70_2 configure -state normal; $widget_Button70_3 configure -state normal;
        }

    if {"$DecompDecompositionFonction" == "S2"} {
        set DecompOutputSubDir "T3"
        $widget_Label70_4 configure -state normal
        $widget_Radiobutton70_1 configure -state normal
        $widget_Radiobutton70_2 configure -state normal
        }
}
#############################################################################
## Procedure:  DecompOFF

proc ::DecompOFF {} {
global PolarDecomp DecompOutputDir DecompOutputSubDir DecompDirOutputTmp DecompFonction DecompDecompositionFonction
global DecompOutputDir1 DecompOutputSubDir1 DecompOutputDir2 DecompOutputSubDir2
global DecompOutputDir3 DecompOutputSubDir3 DecompOutputDir4 DecompOutputSubDir4
global DecompOutputSubDirTmp PSPBackgroundColor

set widget_TitleFrame70_1 .top70.fra74.cpd78
set widget_TitleFrame70_2 .top70.fra74.cpd79
set widget_TitleFrame70_3 .top70.fra74.cpd80
set widget_TitleFrame70_4 .top70.fra74.cpd81
set widget_Entry70_4 .top70.fra74.cpd78.f.cpd85
set widget_Entry70_5 .top70.fra74.cpd79.f.cpd85
set widget_Entry70_6 .top70.fra74.cpd80.f.cpd85
set widget_Entry70_7 .top70.fra74.cpd81.f.cpd85
set widget_Entry70_8 .top70.fra74.cpd78.f.cpd91.cpd75
set widget_Entry70_9 .top70.fra74.cpd79.f.cpd91.cpd75
set widget_Entry70_10 .top70.fra74.cpd80.f.cpd91.cpd75
set widget_Entry70_11 .top70.fra74.cpd81.f.cpd91.cpd75
set widget_Button70_1 .top70.fra74.cpd78.f.cpd74.cpd71
set widget_Button70_2 .top70.fra74.cpd79.f.cpd74.cpd71
set widget_Button70_3 .top70.fra74.cpd80.f.cpd74.cpd71
set widget_Button70_4 .top70.fra74.cpd81.f.cpd74.cpd71
set widget_Label70_4 .top70.fra74.fra75.cpd77.lab78
set widget_Radiobutton70_1 .top70.fra74.fra75.cpd77.rad79
set widget_Radiobutton70_2 .top70.fra74.fra75.cpd77.cpd80

    $widget_TitleFrame70_1 configure -state disable; $widget_TitleFrame70_1 configure -text ""
    $widget_TitleFrame70_2 configure -state disable; $widget_TitleFrame70_2 configure -text ""
    $widget_TitleFrame70_3 configure -state disable; $widget_TitleFrame70_3 configure -text ""
    $widget_TitleFrame70_4 configure -state disable; $widget_TitleFrame70_4 configure -text ""
    $widget_Entry70_4 configure -state disable; $widget_Entry70_4 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_5 configure -state disable; $widget_Entry70_5 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_6 configure -state disable; $widget_Entry70_6 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_7 configure -state disable; $widget_Entry70_7 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_8 configure -state disable; $widget_Entry70_8 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_9 configure -state disable; $widget_Entry70_9 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_10 configure -state disable; $widget_Entry70_10 configure -disabledbackground $PSPBackgroundColor
    $widget_Entry70_11 configure -state disable; $widget_Entry70_11 configure -disabledbackground $PSPBackgroundColor
    $widget_Button70_1 configure -state disable; $widget_Button70_2 configure -state disable
    $widget_Button70_3 configure -state disable; $widget_Button70_4 configure -state disable

    set DecompOutputDir1 ""; set DecompOutputSubDir1 ""; set DecompOutputDir2 ""; set DecompOutputSubDir2 ""
    set DecompOutputDir3 ""; set DecompOutputSubDir3 ""; set DecompOutputDir4 ""; set DecompOutputSubDir4 ""
    set DecompOutputSubDirTmp ""
    $widget_Label70_4 configure -state disable
    $widget_Radiobutton70_1 configure -state disable
    $widget_Radiobutton70_2 configure -state disable
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

proc vTclWindow.top70 {base} {
    if {$base == ""} {
        set base .top70
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
    wm geometry $top 500x500+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Polarimetric Decomposition"
    vTcl:DefineAlias "$top" "Toplevel70" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd97 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd97" "Frame4" vTcl:WidgetProc "Toplevel70" 1
    set site_3_0 $top.cpd97
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel70" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable DecompDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel70" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel70" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel70" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel70" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable DecompOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel70" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel70" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd76 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd76" "Label14" vTcl:WidgetProc "Toplevel70" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DecompOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel70" 1
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame17" vTcl:WidgetProc "Toplevel70" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.cpd71 \
        \
        -command {global DirName DataDir DecompOutputDir

set DecompDirOutputTmp $DecompOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set DecompOutputDir $DirName
    } else {
    set DecompOutputDir $DecompDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button540" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_6_0.cpd71 "$site_6_0.cpd71 Button $top all _vTclBalloon"
    bind $site_6_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra72 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra72" "Frame9" vTcl:WidgetProc "Toplevel70" 1
    set site_3_0 $top.fra72
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel70" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel70" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel70" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel70" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel70" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel70" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel70" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel70" 1
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
    frame $top.fra73 \
        -borderwidth 2 -height 75 -width 159 
    vTcl:DefineAlias "$top.fra73" "Frame110" vTcl:WidgetProc "Toplevel70" 1
    set site_3_0 $top.fra73
    entry $site_3_0.ent25 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DecompType -width 35 
    vTcl:DefineAlias "$site_3_0.ent25" "Entry60" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_3_0.ent25 "$site_3_0.ent25 Entry $top all _vTclBalloon"
    bind $site_3_0.ent25 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Polarimetric Decomposition Theorem}
    }
    frame $site_3_0.fra76 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.fra76" "Frame385" vTcl:WidgetProc "Toplevel70" 1
    set site_4_0 $site_3_0.fra76
    label $site_4_0.lab57 \
        -padx 1 -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label70_5" vTcl:WidgetProc "Toplevel70" 1
    entry $site_4_0.ent58 \
        -background white -disabledforeground #0000ff -foreground #ff0000 \
        -justify center -textvariable NwinDecompL -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry70_3a" vTcl:WidgetProc "Toplevel70" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side right 
    frame $site_3_0.cpd66 \
        -borderwidth 2 -height 75 -width 216 
    vTcl:DefineAlias "$site_3_0.cpd66" "Frame386" vTcl:WidgetProc "Toplevel70" 1
    set site_4_0 $site_3_0.cpd66
    label $site_4_0.lab57 \
        -padx 1 -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab57" "Label70" vTcl:WidgetProc "Toplevel70" 1
    entry $site_4_0.ent58 \
        -background white -disabledforeground #0000ff -foreground #ff0000 \
        -justify center -textvariable NwinDecompC -width 5 
    vTcl:DefineAlias "$site_4_0.ent58" "Entry70_3b" vTcl:WidgetProc "Toplevel70" 1
    pack $site_4_0.lab57 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent58 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side right 
    pack $site_3_0.ent25 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.fra76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd66 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame3" vTcl:WidgetProc "Toplevel70" 1
    set site_3_0 $top.fra66
    frame $site_3_0.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra67" "Frame5" vTcl:WidgetProc "Toplevel70" 1
    set site_4_0 $site_3_0.fra67
    frame $site_4_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd68" "Frame440" vTcl:WidgetProc "Toplevel70" 1
    set site_5_0 $site_4_0.cpd68
    checkbutton $site_5_0.che78 \
        -foreground #0000ff -padx 1 -text TgtG -variable RGBPolarDecomp 
    vTcl:DefineAlias "$site_5_0.che78" "Checkbutton70_3" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_5_0.che78 "$site_5_0.che78 Checkbutton $top all _vTclBalloon"
    bind $site_5_0.che78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators RGB Image}
    }
    label $site_5_0.lab79 \
        -foreground #008000 -text TgtG 
    vTcl:DefineAlias "$site_5_0.lab79" "Label70_6" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_5_0.lab79 "$site_5_0.lab79 Label $top all _vTclBalloon"
    bind $site_5_0.lab79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators RGB Image}
    }
    label $site_5_0.lab80 \
        -foreground #ff0000 -text {TgtG  } 
    vTcl:DefineAlias "$site_5_0.lab80" "Label70_7" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_5_0.lab80 "$site_5_0.lab80 Label $top all _vTclBalloon"
    bind $site_5_0.lab80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators RGB Image}
    }
    pack $site_5_0.che78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.lab79 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    pack $site_5_0.lab80 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side left 
    checkbutton $site_4_0.cpd69 \
        \
        -command {if {"$BMPPolarDecomp"=="0"} {
$widget(Label70_1) configure -state disable
$widget(Label70_2) configure -state disable
$widget(Label70_3) configure -state disable
$widget(Checkbutton70_1) configure -state disable
$widget(Entry70_1) configure -state disable
$widget(Entry70_2) configure -state disable
set MinMaxBMPDecomp "0"
set MinBMPDecomp ""
set MaxBMPDecomp ""
} else {
$widget(Label70_1) configure -state normal
$widget(Label70_2) configure -state normal
$widget(Label70_3) configure -state normal
$widget(Checkbutton70_1) configure -state normal
$widget(Entry70_1) configure -state normal
$widget(Entry70_2) configure -state normal
set MinMaxBMPDecomp "1"
set MinBMPDecomp "Auto"
set MaxBMPDecomp "Auto"
}} \
        -text {BMP  Target Generators (TgtG)} -variable BMPPolarDecomp 
    vTcl:DefineAlias "$site_4_0.cpd69" "Checkbutton323" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_4_0.cpd69 "$site_4_0.cpd69 Checkbutton $top all _vTclBalloon"
    bind $site_4_0.cpd69 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Target Generators BMP Image}
    }
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.cpd71 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd71" "Frame67" vTcl:WidgetProc "Toplevel70" 1
    set site_4_0 $site_3_0.cpd71
    label $site_4_0.lab30 \
        -padx 1 -text {Minimum / Maximum Values} 
    vTcl:DefineAlias "$site_4_0.lab30" "Label70_1" vTcl:WidgetProc "Toplevel70" 1
    checkbutton $site_4_0.che31 \
        \
        -command {if {"$MinMaxBMPDecomp"=="1"} {
    $widget(Entry70_1) configure -state disable
    $widget(Entry70_2) configure -state disable
    set MinBMPDecomp "Auto"
    set MaxBMPDecomp "Auto"
    } else {
    $widget(Entry70_1) configure -state normal
    $widget(Entry70_2) configure -state normal
    set MinBMPDecomp "?"
    set MaxBMPDecomp "?"
    }} \
        -padx 1 -text auto -variable MinMaxBMPDecomp 
    vTcl:DefineAlias "$site_4_0.che31" "Checkbutton70_1" vTcl:WidgetProc "Toplevel70" 1
    label $site_4_0.lab32 \
        -padx 1 -text Min 
    vTcl:DefineAlias "$site_4_0.lab32" "Label70_2" vTcl:WidgetProc "Toplevel70" 1
    entry $site_4_0.ent33 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MinBMPDecomp -width 5 
    vTcl:DefineAlias "$site_4_0.ent33" "Entry70_1" vTcl:WidgetProc "Toplevel70" 1
    label $site_4_0.lab34 \
        -padx 1 -text Max 
    vTcl:DefineAlias "$site_4_0.lab34" "Label70_3" vTcl:WidgetProc "Toplevel70" 1
    entry $site_4_0.ent35 \
        -background white -foreground #ff0000 -justify center \
        -textvariable MaxBMPDecomp -width 5 
    vTcl:DefineAlias "$site_4_0.ent35" "Entry70_2" vTcl:WidgetProc "Toplevel70" 1
    pack $site_4_0.lab30 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.che31 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.lab32 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent33 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.lab34 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.ent35 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra67 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side top 
    frame $top.fra74 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame6" vTcl:WidgetProc "Toplevel70" 1
    set site_3_0 $top.fra74
    frame $site_3_0.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra75" "Frame7" vTcl:WidgetProc "Toplevel70" 1
    set site_4_0 $site_3_0.fra75
    checkbutton $site_4_0.cpd76 \
        \
        -command {global PolarDecomp

if {$PolarDecomp == "0"} {
    DecompOFF
    } else  {
    DecompON
    }} \
        -padx 1 -text {Decomposition / Reconstruction} -variable PolarDecomp 
    vTcl:DefineAlias "$site_4_0.cpd76" "Checkbutton70_2" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_4_0.cpd76 "$site_4_0.cpd76 Checkbutton $top all _vTclBalloon"
    bind $site_4_0.cpd76 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Apply the Decomposition}
    }
    frame $site_4_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd77" "Frame379" vTcl:WidgetProc "Toplevel70" 1
    set site_5_0 $site_4_0.cpd77
    label $site_5_0.lab78 \
        -text {Output Format} 
    vTcl:DefineAlias "$site_5_0.lab78" "Label70_4" vTcl:WidgetProc "Toplevel70" 1
    radiobutton $site_5_0.rad79 \
        \
        -command {global DecompOutputSubDir1 DecompOutputSubDir2
global DecompOutputSubDir3 DecompOutputSubDir4
global DecompOutputSubDirTmp

if {$DecompOutputSubDir1 != ""} {set DecompOutputSubDir1 $DecompOutputSubDirTmp}
if {$DecompOutputSubDir2 != ""} {set DecompOutputSubDir2 $DecompOutputSubDirTmp}
if {$DecompOutputSubDir3 != ""} {set DecompOutputSubDir3 $DecompOutputSubDirTmp}
if {$DecompOutputSubDir4 != ""} {set DecompOutputSubDir4 $DecompOutputSubDirTmp}} \
        -text T3 -value T3 -variable DecompOutputSubDirTmp 
    vTcl:DefineAlias "$site_5_0.rad79" "Radiobutton70_1" vTcl:WidgetProc "Toplevel70" 1
    radiobutton $site_5_0.cpd80 \
        \
        -command {global DecompOutputSubDir1 DecompOutputSubDir2
global DecompOutputSubDir3 DecompOutputSubDir4
global DecompOutputSubDirTmp

if {$DecompOutputSubDir1 != ""} {set DecompOutputSubDir1 $DecompOutputSubDirTmp}
if {$DecompOutputSubDir2 != ""} {set DecompOutputSubDir2 $DecompOutputSubDirTmp}
if {$DecompOutputSubDir3 != ""} {set DecompOutputSubDir3 $DecompOutputSubDirTmp}
if {$DecompOutputSubDir4 != ""} {set DecompOutputSubDir4 $DecompOutputSubDirTmp}} \
        -text C3 -value C3 -variable DecompOutputSubDirTmp 
    vTcl:DefineAlias "$site_5_0.cpd80" "Radiobutton70_2" vTcl:WidgetProc "Toplevel70" 1
    pack $site_5_0.lab78 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.rad79 \
        -in $site_5_0 -anchor center -expand 1 -fill none -ipadx 10 \
        -side left 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 1 -fill none -ipadx 10 \
        -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_3_0.cpd78 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd78" "TitleFrame70_1" vTcl:WidgetProc "Toplevel70" 1
    bind $site_3_0.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd78 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable DecompOutputDir1 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry70_4" vTcl:WidgetProc "Toplevel70" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame18" vTcl:WidgetProc "Toplevel70" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd76 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd76" "Label15" vTcl:WidgetProc "Toplevel70" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DecompOutputSubDir1 -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry70_8" vTcl:WidgetProc "Toplevel70" 1
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame19" vTcl:WidgetProc "Toplevel70" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.cpd71 \
        \
        -command {global DirName DataDir DecompOutputDir1

set DecompDirOutputTmp $DecompOutputDir1
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set DecompOutputDir1 $DirName
    } else {
    set DecompOutputDir1 $DecompDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button70_1" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_6_0.cpd71 "$site_6_0.cpd71 Button $top all _vTclBalloon"
    bind $site_6_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd79 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd79" "TitleFrame70_2" vTcl:WidgetProc "Toplevel70" 1
    bind $site_3_0.cpd79 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd79 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable DecompOutputDir2 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry70_5" vTcl:WidgetProc "Toplevel70" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame21" vTcl:WidgetProc "Toplevel70" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd76 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd76" "Label16" vTcl:WidgetProc "Toplevel70" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DecompOutputSubDir2 -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry70_9" vTcl:WidgetProc "Toplevel70" 1
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame22" vTcl:WidgetProc "Toplevel70" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.cpd71 \
        \
        -command {global DirName DataDir DecompOutputDir2

set DecompDirOutputTmp $DecompOutputDir2
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set DecompOutputDir2 $DirName
    } else {
    set DecompOutputDir2 $DecompDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button70_2" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_6_0.cpd71 "$site_6_0.cpd71 Button $top all _vTclBalloon"
    bind $site_6_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd80 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd80" "TitleFrame70_3" vTcl:WidgetProc "Toplevel70" 1
    bind $site_3_0.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd80 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable DecompOutputDir3 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry70_6" vTcl:WidgetProc "Toplevel70" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame23" vTcl:WidgetProc "Toplevel70" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd76 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd76" "Label17" vTcl:WidgetProc "Toplevel70" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DecompOutputSubDir3 -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry70_10" vTcl:WidgetProc "Toplevel70" 1
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame24" vTcl:WidgetProc "Toplevel70" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.cpd71 \
        \
        -command {global DirName DataDir DecompOutputDir3

set DecompDirOutputTmp $DecompOutputDir3
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set DecompOutputDir3 $DirName
    } else {
    set DecompOutputDir3 $DecompDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button70_3" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_6_0.cpd71 "$site_6_0.cpd71 Button $top all _vTclBalloon"
    bind $site_6_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd81 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd81" "TitleFrame70_4" vTcl:WidgetProc "Toplevel70" 1
    bind $site_3_0.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd81 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable DecompOutputDir4 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry70_7" vTcl:WidgetProc "Toplevel70" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame25" vTcl:WidgetProc "Toplevel70" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd76 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd76" "Label18" vTcl:WidgetProc "Toplevel70" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable DecompOutputSubDir4 -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry70_11" vTcl:WidgetProc "Toplevel70" 1
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd74" "Frame26" vTcl:WidgetProc "Toplevel70" 1
    set site_6_0 $site_5_0.cpd74
    button $site_6_0.cpd71 \
        \
        -command {global DirName DataDir DecompOutputDir4

set DecompDirOutputTmp $DecompOutputDir4
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set DecompOutputDir4 $DirName
    } else {
    set DecompOutputDir4 $DecompDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd71" "Button70_4" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_6_0.cpd71 "$site_6_0.cpd71 Button $top all _vTclBalloon"
    bind $site_6_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.fra75 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd79 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd80 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd81 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra75 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra75" "Frame20" vTcl:WidgetProc "Toplevel70" 1
    set site_3_0 $top.fra75
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DecompDirInput DecompDirOutput DecompOutputDir DecompOutputSubDir
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine 
global DecompDecompositionFonction DecompFonction PolarDecomp RGBDecomp BMPDecomp OpenDirFile
global BMPDirInput TestVarErrorTGT
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global NligInit NligFullSize NcolInit NcolFullSize NligEnd NcolEnd FinalNlig FinalNcol

if {$OpenDirFile == 0} {

    set DecompDirOutput $DecompOutputDir
    if {$DecompOutputSubDir != ""} {append DecompDirOutput "/$DecompOutputSubDir"}

    #####################################################################
    #Create Directory
    set DecompDirOutput [PSPCreateDirectoryMask $DecompDirOutput $DecompOutputDir $DecompDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {

set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
TestVar 4
if {$TestVarError == "ok"} {

set TestVarErrorTGT ""
DecompTGT
if {$TestVarErrorTGT == "ok"} {
    if {"$BMPPolarDecomp"=="1"} { DecompBMP }
    if {"$RGBPolarDecomp"=="1"} { DecompRGB }
    }
    #Config Creation TgtGenerators Bin Files

if {"$PolarDecomp" == "1"} {
    DecompREC
    if {$DecompDecompositionFonction == "S2"} {
        set config "true"
        if {"$DecompFonction"=="Neumann"} { set config "false" }
        if {"$DecompFonction"=="Krogager"} { set config "false" }
        if {$config == "true"} {
            set WarningMessage "THE DATA FORMAT TO BE PROCESSED IS NOW:"
            if {$DecompOutputSubDir == "T3"} {set WarningMessage2 "3x3 COHERENCY MATRIX - T3"}
            if {$DecompOutputSubDir == "C3"} {set WarningMessage2 "3x3 COVARIANCE MATRIX - C3"}
            set VarWarning ""
            Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
            tkwait variable VarWarning
            }
        }
    } 
    #PolarDecomp

    $widget(Checkbutton70_3) configure -state normal
    $widget(Label70_6) configure -state normal
    $widget(Label70_7) configure -state normal
    Window hide $widget(Toplevel70); TextEditorRunTrace "Close Window Polarimetric Decomposition" "b"

    }
    #TestVar
    } else {
    if {"$VarWarning"=="no"} {
        $widget(Checkbutton70_3) configure -state normal
        $widget(Label70_6) configure -state normal
        $widget(Label70_7) configure -state normal
        Window hide $widget(Toplevel70); TextEditorRunTrace "Close Window Polarimetric Decomposition" "b"
        }
    }
    #Warning

    $widget(Label70_5) configure -state normal
    $widget(Entry70_3a) configure -state normal
    $widget(Entry70_3b) configure -state normal
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/PolarimetricDecomposition.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel70" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
$widget(Checkbutton70_3) configure -state normal
$widget(Label70_6) configure -state normal
$widget(Label70_7) configure -state normal
Window hide $widget(Toplevel70); TextEditorRunTrace "Close Window Polarimetric Decomposition" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel70" 1
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
    pack $top.cpd97 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra73 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill none -ipadx 20 -ipady 2 \
        -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -ipady 2 -pady 5 -side top 
    pack $top.fra75 \
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
Window show .top70

main $argc $argv
