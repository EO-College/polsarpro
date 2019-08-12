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
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}

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
    set base .top461
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
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd71
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$base.tit84 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit84 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd66 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.fra67 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra67
    namespace eval ::widgets::$site_4_0.che68 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd70 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd82
    namespace eval ::widgets::$site_6_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra39
    namespace eval ::widgets::$site_7_0.lab33 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra40
    namespace eval ::widgets::$site_7_0.ent34 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra39
    namespace eval ::widgets::$site_7_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra40
    namespace eval ::widgets::$site_7_0.ent36 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd66
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd79
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_8_0.cpd78 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd72 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd72
    namespace eval ::widgets::$site_3_0.fra67 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra67
    namespace eval ::widgets::$site_4_0.che68 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd70 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd82
    namespace eval ::widgets::$site_6_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra39
    namespace eval ::widgets::$site_7_0.lab33 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra40
    namespace eval ::widgets::$site_7_0.ent34 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.ent36 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd74
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd75
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_8_0.cpd78 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd79
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_8_0.cpd78 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra39
    namespace eval ::widgets::$site_7_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.lab35 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra40
    namespace eval ::widgets::$site_7_0.ent36 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.ent37 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd80 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd80
    namespace eval ::widgets::$site_3_0.fra67 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra67
    namespace eval ::widgets::$site_4_0.che68 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd70 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd82
    namespace eval ::widgets::$site_6_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra39
    namespace eval ::widgets::$site_7_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra40
    namespace eval ::widgets::$site_7_0.ent36 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd74
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd79
    namespace eval ::widgets::$site_8_0.cpd77 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_8_0.cpd78 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd78
    namespace eval ::widgets::$site_6_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra39
    namespace eval ::widgets::$site_7_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.lab35 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra40
    namespace eval ::widgets::$site_7_0.ent36 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.ent37 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1 -width 1}
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
            vTclWindow.top461
            CSRAZMenu
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
## Procedure:  CSRAZMenu

proc ::CSRAZMenu {} {
global CSDirInput CSDirOutput CSOutputDir CSOutputSubDir CSInputFile
global CSEntropyIntensityFlag CSEntropyFile CSMagThreshold CSEntThreshold CSEntBMP CSEntropyOutputFile
global CSEntSubLookFlag CSEntSLNumber CSEntSLThreshold CSNwinLEnt CSNwinCEnt CSEntSLBMP CSEntSubLookOutputFile
global CSCohSubLookFlag CSCohSLThreshold CSNwinLCoh CSNwinCCoh CSCohSLBMP CSCohSubLookOutputFile
global PSPBackgroundColor

set CSInputFile "SELECT AN INPUT DATA FILE"
set CSEntropyIntensityFlag 0; set CSEntropyFile ""; set CSMagThreshold ""; set CSEntThreshold ""; set CSEntBMP 0; set CSEntropyOutputFile ""
set CSEntSubLookFlag 0; set CSEntSLNumber ""; set CSEntSLThreshold ""; set CSNwinLEnt ""; set CSNwinCEnt ""; set CSEntSLBMP 0; set CSEntSubLookOutputFile ""
set CSCohSubLookFlag 0; set CSCohSLThreshold ""; set CSNwinLCoh ""; set CSNwinCCoh ""; set CSCohSLBMP 0; set CSCohSubLookOutputFile ""

.top461.fra66.cpd69 configure -state disable
.top461.fra66.cpd70 configure -state disable
.top461.fra66.cpd71 configure -state disable
.top461.fra66.cpd69.f.cpd66 configure -state disable
.top461.fra66.cpd70.f.cpd82.fra40.ent34 configure -state disable
.top461.fra66.cpd70.f.cpd78.fra40.ent36 configure -state disable
.top461.fra66.cpd71.f.cpd66 configure -state disable
.top461.fra66.cpd69.f.cpd66 configure -disabledbackground $PSPBackgroundColor
.top461.fra66.cpd70.f.cpd82.fra40.ent34 configure -disabledbackground $PSPBackgroundColor
.top461.fra66.cpd70.f.cpd78.fra40.ent36 configure -disabledbackground $PSPBackgroundColor
.top461.fra66.cpd71.f.cpd66 configure -disabledbackground $PSPBackgroundColor
.top461.fra66.cpd69.f.cpd67 configure -state disable
.top461.fra66.cpd70.f.cpd78.cpd66.cpd79.cpd77 configure -state disable
.top461.fra66.cpd70.f.cpd78.cpd66.cpd79.cpd78 configure -state disable
.top461.fra66.cpd70.f.cpd82.fra39.lab33 configure -state disable
.top461.fra66.cpd70.f.cpd78.fra39.lab34 configure -state disable
.top461.fra66.cpd70.f.cpd83 configure -state disable
    
.top461.cpd72.cpd70 configure -state disable
.top461.cpd72.cpd71 configure -state disable
.top461.cpd72.cpd70.f.cpd82.fra40.ent34 configure -state disable
.top461.cpd72.cpd70.f.cpd82.fra40.ent36 configure -state disable
.top461.cpd72.cpd70.f.cpd78.fra40.ent36 configure -state disable
.top461.cpd72.cpd70.f.cpd78.fra40.ent37 configure -state disable
.top461.cpd72.cpd71.f.cpd66 configure -state disable
.top461.cpd72.cpd70.f.cpd82.fra40.ent34 configure -disabledbackground $PSPBackgroundColor
.top461.cpd72.cpd70.f.cpd82.fra40.ent36 configure -disabledbackground $PSPBackgroundColor
.top461.cpd72.cpd70.f.cpd78.fra40.ent36 configure -disabledbackground $PSPBackgroundColor
.top461.cpd72.cpd70.f.cpd78.fra40.ent37 configure -disabledbackground $PSPBackgroundColor
.top461.cpd72.cpd71.f.cpd66 configure -disabledbackground $PSPBackgroundColor
.top461.cpd72.cpd70.f.cpd82.cpd74.cpd75.cpd77 configure -state disable
.top461.cpd72.cpd70.f.cpd82.cpd74.cpd75.cpd78 configure -state disable
.top461.cpd72.cpd70.f.cpd82.cpd74.cpd79.cpd77 configure -state disable
.top461.cpd72.cpd70.f.cpd82.cpd74.cpd79.cpd78 configure -state disable
.top461.cpd72.cpd70.f.cpd82.fra39.lab33 configure -state disable
.top461.cpd72.cpd70.f.cpd82.fra39.lab34 configure -state disable
.top461.cpd72.cpd70.f.cpd78.fra39.lab34 configure -state disable
.top461.cpd72.cpd70.f.cpd78.fra39.lab35 configure -state disable
.top461.cpd72.cpd70.f.cpd83 configure -state disable
    
.top461.cpd80.cpd70 configure -state disable
.top461.cpd80.cpd71 configure -state disable
.top461.cpd80.cpd70.f.cpd82.fra40.ent36 configure -state disable
.top461.cpd80.cpd70.f.cpd78.fra40.ent36 configure -state disable
.top461.cpd80.cpd70.f.cpd78.fra40.ent37 configure -state disable
.top461.cpd80.cpd71.f.cpd66 configure -state disable
.top461.cpd80.cpd70.f.cpd82.fra40.ent36 configure -disabledbackground $PSPBackgroundColor
.top461.cpd80.cpd70.f.cpd78.fra40.ent36 configure -disabledbackground $PSPBackgroundColor
.top461.cpd80.cpd70.f.cpd78.fra40.ent37 configure -disabledbackground $PSPBackgroundColor
.top461.cpd80.cpd71.f.cpd66 configure -disabledbackground $PSPBackgroundColor
.top461.cpd80.cpd70.f.cpd82.cpd74.cpd79.cpd77 configure -state disable
.top461.cpd80.cpd70.f.cpd82.cpd74.cpd79.cpd78 configure -state disable
.top461.cpd80.cpd70.f.cpd82.fra39.lab34 configure -state disable
.top461.cpd80.cpd70.f.cpd78.fra39.lab34 configure -state disable
.top461.cpd80.cpd70.f.cpd78.fra39.lab35 configure -state disable
.top461.cpd80.cpd70.f.cpd83 configure -state disable
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
    wm geometry $top 200x200+110+110; update
    wm maxsize $top 3604 1065
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

proc vTclWindow.top461 {base} {
    if {$base == ""} {
        set base .top461
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
    wm geometry $top 500x645+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Coherent Scatterers Identification"
    vTcl:DefineAlias "$top" "Toplevel461" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame4" vTcl:WidgetProc "Toplevel461" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel461" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CSDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel461" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel461" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button42" vTcl:WidgetProc "Toplevel461" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel461" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable CSOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel461" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel461" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd73 \
        -padx 1 -text / 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label14" vTcl:WidgetProc "Toplevel461" 1
    entry $site_6_0.cpd74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd74" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel461" 1
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame17" vTcl:WidgetProc "Toplevel461" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.cpd80 \
        \
        -command {global DirName DataDir CSOutputDir

set CSDirOutputTmp $CSOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set CSOutputDir $DirName
    } else {
    set CSOutputDir $CSDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    bindtags $site_6_0.cpd80 "$site_6_0.cpd80 Button $top all _vTclBalloon"
    bind $site_6_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra28 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra28" "Frame9" vTcl:WidgetProc "Toplevel461" 1
    set site_3_0 $top.fra28
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel461" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel461" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel461" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel461" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel461" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel461" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel461" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel461" 1
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
    TitleFrame $top.tit84 \
        -ipad 0 -text {Input Data File} 
    vTcl:DefineAlias "$top.tit84" "TitleFrame2" vTcl:WidgetProc "Toplevel461" 1
    bind $top.tit84 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit84 getframe]
    entry $site_4_0.cpd66 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CSInputFile -width 40 
    vTcl:DefineAlias "$site_4_0.cpd66" "Entry53" vTcl:WidgetProc "Toplevel461" 1
    button $site_4_0.cpd67 \
        \
        -command {global FileName CSDirInput CSInputFile

CSRAZMenu
set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$CSDirInput" $types "INPUT DATA FILE"
if {$FileName != ""} {
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp
            gets $f tmp 
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            if {$tmp == "data type = 6"} {
                set CSInputFile $FileName
                } else {
                set ErrorMessage "NOT A COMPLEX DATA FILE TYPE"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set CSInputFile "SELECT AN INPUT DATA FILE"
                }
            } else {
            set ErrorMessage "NOT A PolSARpro BINARY DATA FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set CSInputFile "SELECT AN INPUT DATA FILE"
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set CSInputFile "SELECT AN INPUT DATA FILE"
        }    
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_4_0.cpd67" "Button2" vTcl:WidgetProc "Toplevel461" 1
    bindtags $site_4_0.cpd67 "$site_4_0.cpd67 Button $top all _vTclBalloon"
    bind $site_4_0.cpd67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_4_0.cpd66 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra42 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra42" "Frame20" vTcl:WidgetProc "Toplevel461" 1
    set site_3_0 $top.fra42
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global CSDirInput CSDirOutput CSOutputDir CSOutputSubDir
global CSInputFile
global CSEntropyIntensityFlag CSEntropyFile CSMagThreshold CSEntThreshold CSEntBMP CSEntropyOutputFile
global CSEntSubLookFlag CSEntSLNumber CSEntSLThreshold CSNwinLEnt CSNwinCEnt CSEntSLBMP CSEntSubLookOutputFile
global CSCohSubLookFlag CSCohSLThreshold CSNwinLCoh CSNwinCCoh CSCohSLBMP CSCohSubLookOutputFile
global VarError ErrorMessage ConfigFile
global TMPMemoryAllocError
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2 OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set CSDirOutput $CSOutputDir
if {$CSOutputSubDir != ""} {append CSDirOutput "/$CSOutputSubDir"}

    #####################################################################
    #Create Directory
    set CSDirOutput [PSPCreateDirectoryMask $CSDirOutput $CSOutputDir $CSDirInput]
    #####################################################################       
    
if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

if {$CSEntropyIntensityFlag == 1} {
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Magnitude Threshold"; set TestVarType(4) "float"; set TestVarValue(4) $CSMagThreshold; set TestVarMin(4) "0"; set TestVarMax(4) "1"
    set TestVarName(5) "Entropy Threshold"; set TestVarType(5) "float"; set TestVarValue(5) $CSEntThreshold; set TestVarMin(5) "0"; set TestVarMax(5) "1"
    TestVar 6
    if {$TestVarError == "ok"} {
        set Fonction "Creation of the Binary Data File :"; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$CSDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set CSOutputFile $CSOutputDir; append CSOutputFile "/$CSEntropyOutputFile"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/CS_entropy_intensity.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$CSInputFile\x22 -ife \x22$CSEntropyFile\x22 -of \x22$CSOutputFile\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ith $CSMagThreshold -eth $CSEntThreshold  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/CS_entropy_intensity.exe -if \x22$CSInputFile\x22 -ife \x22$CSEntropyFile\x22 -of \x22$CSOutputFile\x22 -inc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ith $CSMagThreshold -eth $CSEntThreshold  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig $CSOutputFile $FinalNlig $FinalNcol 4
        if {$CSEntBMP == "1"} {
            set BMPFileInput $CSOutputFile
            set BMPFileOutput [file rootname $CSOutputFile]; append BMPFileOutput ".bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol 0 0  $FinalNlig  $FinalNcol 1 0 0
            }
        }
    }

if {$CSEntSubLookFlag == 1} {
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $CSNwinLEnt; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $CSNwinCEnt; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {
        set Fonction "Creation of the Binary Data File :"; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$CSDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set CSOutputFile $CSOutputDir; append CSOutputFile "/$CSEntSubLookOutputFile"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/CS_entropy_sublook.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$CSInputFile\x22 -of \x22$CSOutputFile\x22 -inc $NcolFullSize -nwr $CSNwinLEnt -nwc $CSNwinCEnt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ns $CSEntSLNumber -tr $CSEntSLThreshold  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/CS_entropy_sublook.exe -if \x22$CSInputFile\x22 -of \x22$CSOutputFile\x22 -inc $NcolFullSize -nwr $CSNwinLEnt -nwc $CSNwinCEnt -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -ns $CSEntSLNumber -tr $CSEntSLThreshold  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig $CSOutputFile $FinalNlig $FinalNcol 4
        if {$CSEntSLBMP == "1"} {
            set BMPFileInput $CSOutputFile
            set BMPFileOutput [file rootname $CSOutputFile]; append BMPFileOutput ".bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol 0 0  $FinalNlig  $FinalNcol 1 0 0
            }
        }
    }

if {$CSCohSubLookFlag == 1} {
    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $CSNwinLCoh; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $CSNwinCCoh; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
    TestVar 6
    if {$TestVarError == "ok"} {
        set Fonction "Creation of the Binary Data File :"; set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$CSDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set CSOutputFile $CSOutputDir; append CSOutputFile "/$CSCohSubLookOutputFile"
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/CS_coherence_sublook.exe" "k"
        TextEditorRunTrace "Arguments: -if \x22$CSInputFile\x22 -of \x22$CSOutputFile\x22 -inc $NcolFullSize -nwr $CSNwinLCoh -nwc $CSNwinCCoh -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -tr $CSCohSLThreshold  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/CS_coherence_sublook.exe -if \x22$CSInputFile\x22 -of \x22$CSOutputFile\x22 -inc $NcolFullSize -nwr $CSNwinLCoh -nwc $CSNwinCCoh -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -tr $CSCohSLThreshold  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig $CSOutputFile $FinalNlig $FinalNcol 4
        if {$CSCohSLBMP == "1"} {
            set BMPFileInput $CSOutputFile
            set BMPFileOutput [file rootname $CSOutputFile]; append BMPFileOutput ".bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol 0 0  $FinalNlig  $FinalNcol 1 0 0
            }
        }
    }

    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel461); TextEditorRunTrace "Close Window Coherent Scatterer Identification" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel461" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/WishartHAAlphaClassification.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel461" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel461); TextEditorRunTrace "Close Window Wishart - H A Alpha Classification" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel461" 1
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
    frame $top.fra66 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame1" vTcl:WidgetProc "Toplevel461" 1
    set site_3_0 $top.fra66
    frame $site_3_0.fra67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra67" "Frame2" vTcl:WidgetProc "Toplevel461" 1
    set site_4_0 $site_3_0.fra67
    checkbutton $site_4_0.che68 \
        \
        -command {global CSEntropyIntensityFlag CSEntropyFile CSMagThreshold CSEntThreshold CSEntBMP CSEntropyOutputFile CSInputFile PSPBackgroundColor

if {$CSEntropyIntensityFlag == 0} {
    $widget(TitleFrame461_1) configure -state disable
    $widget(TitleFrame461_2) configure -state disable
    $widget(TitleFrame461_3) configure -state disable
    $widget(Entry461_1) configure -state disable
    $widget(Entry461_2) configure -state disable
    $widget(Entry461_3) configure -state disable
    $widget(Entry461_4) configure -state disable
    $widget(Entry461_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry461_2) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry461_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry461_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button461_1) configure -state disable
    $widget(Button461_8) configure -state disable
    $widget(Button461_9) configure -state disable
    $widget(Label461_1) configure -state disable
    $widget(Label461_2) configure -state disable
    $widget(Checkbutton461_1) configure -state disable
    set CSEntropyFile ""
    set CSMagThreshold ""; set CSEntThreshold ""
    set CSEntBMP 0
    set CSEntropyOutputFile ""
    } else {
if {$CSInputFile != "SELECT AN INPUT DATA FILE"} {
    $widget(TitleFrame461_1) configure -state normal
    $widget(TitleFrame461_2) configure -state normal
    $widget(TitleFrame461_3) configure -state normal
    $widget(Entry461_1) configure -state disable
    $widget(Entry461_2) configure -state normal
    $widget(Entry461_3) configure -state normal
    $widget(Entry461_4) configure -state disable
    $widget(Entry461_1) configure -disabledbackground #FFFFFF
    $widget(Entry461_2) configure -disabledbackground #FFFFFF
    $widget(Entry461_3) configure -disabledbackground #FFFFFF
    $widget(Entry461_4) configure -disabledbackground #FFFFFF
    $widget(Button461_1) configure -state normal
    $widget(Button461_8) configure -state normal
    $widget(Button461_9) configure -state normal
    $widget(Label461_1) configure -state normal
    $widget(Label461_2) configure -state normal
    $widget(Checkbutton461_1) configure -state normal
    set CSEntropyFile "SELECT AN INPUT ENTROPY FILE"
    set CSMagThreshold "0"; set CSEntThreshold "0.3"
    set CSEntBMP 0
    set toto [file tail $CSInputFile]
    set CSEntropyOutputFile "CS_Entropy-"
    append CSEntropyOutputFile $CSEntThreshold
    append CSEntropyOutputFile "_Intensity_"
    append CSEntropyOutputFile $toto
} else {
set CSEntropyIntensityFlag 0
}
    }} \
        -text {Entropy & Intensity Procedure} \
        -variable CSEntropyIntensityFlag 
    vTcl:DefineAlias "$site_4_0.che68" "Checkbutton1" vTcl:WidgetProc "Toplevel461" 1
    pack $site_4_0.che68 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd69 \
        -ipad 0 -text {Input Entropy File} 
    vTcl:DefineAlias "$site_3_0.cpd69" "TitleFrame461_1" vTcl:WidgetProc "Toplevel461" 1
    bind $site_3_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd69 getframe]
    entry $site_5_0.cpd66 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CSEntropyFile -width 40 
    vTcl:DefineAlias "$site_5_0.cpd66" "Entry461_1" vTcl:WidgetProc "Toplevel461" 1
    button $site_5_0.cpd67 \
        \
        -command {global FileName CSDirInput CSEntropyFile

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$CSDirInput" $types "INPUT ENTROPY FILE"
if {$FileName != ""} {
    set FileNameHdr "$FileName.hdr"
    if [file exists $FileNameHdr] {
        set f [open $FileNameHdr "r"]
        gets $f tmp
        gets $f tmp
        gets $f tmp
        if {[string first "PolSARpro" $tmp] != "-1"} {
            gets $f tmp
            gets $f tmp 
            gets $f tmp
            gets $f tmp
            gets $f tmp
            gets $f tmp
            if {$tmp == "data type = 4"} {
                set CSEntropyFile $FileName
                } else {
                set ErrorMessage "NOT A FLOAT DATA FILE TYPE"
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                set CSEntropyFile ""
                }
            } else {
            set ErrorMessage "NOT A PolSARpro BINARY DATA FILE TYPE"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            set CSEntropyFile ""
            }    
        close $f
        } else {
        set ErrorMessage "THE HDR FILE $FileNameHdr DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set CSEntropyFile ""
        }    
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd67" "Button461_1" vTcl:WidgetProc "Toplevel461" 1
    bindtags $site_5_0.cpd67 "$site_5_0.cpd67 Button $top all _vTclBalloon"
    bind $site_5_0.cpd67 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    TitleFrame $site_3_0.cpd70 \
        -ipad 0 -text Parameters 
    vTcl:DefineAlias "$site_3_0.cpd70" "TitleFrame461_2" vTcl:WidgetProc "Toplevel461" 1
    bind $site_3_0.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd70 getframe]
    frame $site_5_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd82" "Frame59" vTcl:WidgetProc "Toplevel461" 1
    set site_6_0 $site_5_0.cpd82
    frame $site_6_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_6_0.fra39" "Frame60" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra39
    label $site_7_0.lab33 \
        -padx 1 -text {Magnitude Threshold (dB)} 
    vTcl:DefineAlias "$site_7_0.lab33" "Label461_1" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.lab33 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    frame $site_6_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_6_0.fra40" "Frame61" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra40
    entry $site_7_0.ent34 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable CSMagThreshold -width 5 
    vTcl:DefineAlias "$site_7_0.ent34" "Entry461_2" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.ent34 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.fra39 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.fra40 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    checkbutton $site_5_0.cpd83 \
        -text BMP -variable CSEntBMP 
    vTcl:DefineAlias "$site_5_0.cpd83" "Checkbutton461_1" vTcl:WidgetProc "Toplevel461" 1
    frame $site_5_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame62" vTcl:WidgetProc "Toplevel461" 1
    set site_6_0 $site_5_0.cpd78
    frame $site_6_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_6_0.fra39" "Frame63" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra39
    label $site_7_0.lab34 \
        -padx 1 -text {Entropy Threshold} 
    vTcl:DefineAlias "$site_7_0.lab34" "Label461_2" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.lab34 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    frame $site_6_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_6_0.fra40" "Frame64" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra40
    entry $site_7_0.ent36 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable CSEntThreshold -width 5 
    vTcl:DefineAlias "$site_7_0.ent36" "Entry461_3" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.ent36 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    frame $site_6_0.cpd66 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd66" "Frame78" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.cpd66
    frame $site_7_0.cpd79 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd79" "Frame83" vTcl:WidgetProc "Toplevel461" 1
    set site_8_0 $site_7_0.cpd79
    button $site_8_0.cpd77 \
        \
        -command {global CSEntThreshold CSEntropyOutputFile CSInputFile

set CSEntThreshold [expr $CSEntThreshold + 0.1 ]
if {$CSEntThreshold == 1.1} { set CSEntThreshold 0.1}

set toto [file tail $CSInputFile]
set CSEntropyOutputFile "CS_Entropy-"
append CSEntropyOutputFile $CSEntThreshold
append CSEntropyOutputFile "_Intensity_"
append CSEntropyOutputFile $toto} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_8_0.cpd77" "Button461_8" vTcl:WidgetProc "Toplevel461" 1
    button $site_8_0.cpd78 \
        \
        -command {global CSEntThreshold CSEntropyOutputFile CSInputFile

set CSEntThreshold [expr $CSEntThreshold - 0.1 ]
if {$CSEntThreshold < 0.1} { set CSEntThreshold 1.0}

set toto [file tail $CSInputFile]
set CSEntropyOutputFile "CS_Entropy-"
append CSEntropyOutputFile $CSEntThreshold
append CSEntropyOutputFile "_Intensity_"
append CSEntropyOutputFile $toto} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_8_0.cpd78" "Button461_9" vTcl:WidgetProc "Toplevel461" 1
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.fra39 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.fra40 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side top 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side left 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {CS-Entropy-Intensity Output File} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame461_3" vTcl:WidgetProc "Toplevel461" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd66 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable CSEntropyOutputFile -width 40 
    vTcl:DefineAlias "$site_5_0.cpd66" "Entry461_4" vTcl:WidgetProc "Toplevel461" 1
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.fra67 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 0 -fill x -padx 5 -side top 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 0 -fill x -padx 5 -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -padx 5 -side top 
    frame $top.cpd72 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd72" "Frame3" vTcl:WidgetProc "Toplevel461" 1
    set site_3_0 $top.cpd72
    frame $site_3_0.fra67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra67" "Frame5" vTcl:WidgetProc "Toplevel461" 1
    set site_4_0 $site_3_0.fra67
    checkbutton $site_4_0.che68 \
        \
        -command {global CSEntSubLookFlag CSEntSLNumber CSEntSLThreshold CSNwinLEnt CSNwinCEnt CSEntSLBMP CSEntSubLookOutputFile CSInputFile PSPBackgroundColor

if {$CSEntSubLookFlag == 0} {
    $widget(TitleFrame461_4) configure -state disable
    $widget(TitleFrame461_5) configure -state disable
    $widget(Entry461_5) configure -state disable
    $widget(Entry461_6) configure -state disable
    $widget(Entry461_7) configure -state disable
    $widget(Entry461_8) configure -state disable
    $widget(Entry461_9) configure -state disable
    $widget(Entry461_5) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry461_6) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry461_7) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry461_8) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry461_9) configure -disabledbackground $PSPBackgroundColor
    $widget(Button461_2) configure -state disable
    $widget(Button461_3) configure -state disable
    $widget(Button461_4) configure -state disable
    $widget(Button461_5) configure -state disable
    $widget(Label461_3) configure -state disable
    $widget(Label461_4) configure -state disable
    $widget(Label461_5) configure -state disable
    $widget(Label461_6) configure -state disable
    $widget(Checkbutton461_2) configure -state disable
    set CSEntSLNumber ""; set CSEntSLThreshold ""
    set CSNwinLEnt ""; set CSNwinCEnt ""
    set CSEntSLBMP 0
    set CSEntSubLookOutputFile ""
    } else {
if {$CSInputFile != "SELECT AN INPUT DATA FILE"} {
    $widget(TitleFrame461_4) configure -state normal
    $widget(TitleFrame461_5) configure -state normal
    $widget(Entry461_5) configure -state disable
    $widget(Entry461_6) configure -state disable
    $widget(Entry461_7) configure -state normal
    $widget(Entry461_8) configure -state normal
    $widget(Entry461_9) configure -state normal
    $widget(Entry461_5) configure -disabledbackground #FFFFFF
    $widget(Entry461_6) configure -disabledbackground #FFFFFF
    $widget(Entry461_7) configure -disabledbackground #FFFFFF
    $widget(Entry461_8) configure -disabledbackground #FFFFFF
    $widget(Entry461_9) configure -disabledbackground #FFFFFF
    $widget(Button461_2) configure -state normal
    $widget(Button461_3) configure -state normal
    $widget(Button461_4) configure -state normal
    $widget(Button461_5) configure -state normal
    $widget(Label461_3) configure -state normal
    $widget(Label461_4) configure -state normal
    $widget(Label461_5) configure -state normal
    $widget(Label461_6) configure -state normal
    $widget(Checkbutton461_2) configure -state normal
    set CSEntSLNumber "4"; set CSEntSLThreshold "0.3"
    set CSNwinLEnt "5"; set CSNwinCEnt "5"
    set CSEntSLBMP 0
    set toto [file tail $CSInputFile]
    set CSEntSubLookOutputFile "CS_SubLook-"
    append CSEntSubLookOutputFile $CSEntSLNumber
    append CSEntSubLookOutputFile "_Entropy-" 
    append CSEntSubLookOutputFile $CSEntSLThreshold
    append CSEntSubLookOutputFile "_$toto"
} else {
set CSEntSubLookFlag 0
}
    }} \
        -text {Sub-Look Entropy Procedure} -variable CSEntSubLookFlag 
    vTcl:DefineAlias "$site_4_0.che68" "Checkbutton2" vTcl:WidgetProc "Toplevel461" 1
    pack $site_4_0.che68 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd70 \
        -ipad 0 -text Parameters 
    vTcl:DefineAlias "$site_3_0.cpd70" "TitleFrame461_4" vTcl:WidgetProc "Toplevel461" 1
    bind $site_3_0.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd70 getframe]
    frame $site_5_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd82" "Frame65" vTcl:WidgetProc "Toplevel461" 1
    set site_6_0 $site_5_0.cpd82
    frame $site_6_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_6_0.fra39" "Frame66" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra39
    label $site_7_0.lab33 \
        -padx 1 -text {Sub Look Number} 
    vTcl:DefineAlias "$site_7_0.lab33" "Label461_3" vTcl:WidgetProc "Toplevel461" 1
    label $site_7_0.lab34 \
        -padx 1 -text {Entropy Threshold} 
    vTcl:DefineAlias "$site_7_0.lab34" "Label461_4" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.lab33 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_7_0.lab34 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    frame $site_6_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_6_0.fra40" "Frame67" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra40
    entry $site_7_0.ent34 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSEntSLNumber -width 5 
    vTcl:DefineAlias "$site_7_0.ent34" "Entry461_5" vTcl:WidgetProc "Toplevel461" 1
    entry $site_7_0.ent36 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSEntSLThreshold -width 5 
    vTcl:DefineAlias "$site_7_0.ent36" "Entry461_6" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.ent34 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_7_0.ent36 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    frame $site_6_0.cpd74 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd74" "Frame71" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.cpd74
    frame $site_7_0.cpd75 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame72" vTcl:WidgetProc "Toplevel461" 1
    set site_8_0 $site_7_0.cpd75
    button $site_8_0.cpd77 \
        \
        -command {global CSEntSLNumber CSEntSLThreshold CSEntSubLookOutputFile CSInputFile

set CSEntSLNumber [expr $CSEntSLNumber * 2]
if {$CSEntSLNumber == 16} {set CSEntSLNumber 1}

set toto [file tail $CSInputFile]
set CSEntSubLookOutputFile "CS_SubLook-"
append CSEntSubLookOutputFile $CSEntSLNumber
append CSEntSubLookOutputFile "_Entropy-" 
append CSEntSubLookOutputFile $CSEntSLThreshold
append CSEntSubLookOutputFile "_$toto"} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_8_0.cpd77" "Button461_2" vTcl:WidgetProc "Toplevel461" 1
    button $site_8_0.cpd78 \
        \
        -command {global CSEntSLNumber CSEntSLThreshold CSEntSubLookOutputFile CSInputFile

set CSEntSLNumber [expr $CSEntSLNumber / 2]
if {$CSEntSLNumber < 1} {set CSEntSLNumber 8}

set toto [file tail $CSInputFile]
set CSEntSubLookOutputFile "CS_SubLook-"
append CSEntSubLookOutputFile $CSEntSLNumber
append CSEntSubLookOutputFile "_Entropy-" 
append CSEntSubLookOutputFile $CSEntSLThreshold
append CSEntSubLookOutputFile "_$toto"} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_8_0.cpd78" "Button461_3" vTcl:WidgetProc "Toplevel461" 1
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd79 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd79" "Frame73" vTcl:WidgetProc "Toplevel461" 1
    set site_8_0 $site_7_0.cpd79
    button $site_8_0.cpd77 \
        \
        -command {global CSEntSLNumber CSEntSLThreshold CSEntSubLookOutputFile CSInputFile

set CSEntSLThreshold [expr $CSEntSLThreshold + 0.1]
if {$CSEntSLThreshold == 1.1} {set CSEntSLThreshold 0.1}

set toto [file tail $CSInputFile]
set CSEntSubLookOutputFile "CS_SubLook-"
append CSEntSubLookOutputFile $CSEntSLNumber
append CSEntSubLookOutputFile "_Entropy-" 
append CSEntSubLookOutputFile $CSEntSLThreshold
append CSEntSubLookOutputFile "_$toto"} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_8_0.cpd77" "Button461_4" vTcl:WidgetProc "Toplevel461" 1
    button $site_8_0.cpd78 \
        \
        -command {global CSEntSLNumber CSEntSLThreshold CSEntSubLookOutputFile CSInputFile

set CSEntSLThreshold [expr $CSEntSLThreshold - 0.1]
if {$CSEntSLThreshold < 0.1} {set CSEntSLThreshold 1.0}

set toto [file tail $CSInputFile]
set CSEntSubLookOutputFile "CS_SubLook-"
append CSEntSubLookOutputFile $CSEntSLNumber
append CSEntSubLookOutputFile "_Entropy-" 
append CSEntSubLookOutputFile $CSEntSLThreshold
append CSEntSubLookOutputFile "_$toto"} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_8_0.cpd78" "Button461_5" vTcl:WidgetProc "Toplevel461" 1
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.fra39 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.fra40 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    checkbutton $site_5_0.cpd83 \
        -text BMP -variable CSEntSLBMP 
    vTcl:DefineAlias "$site_5_0.cpd83" "Checkbutton461_2" vTcl:WidgetProc "Toplevel461" 1
    frame $site_5_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame68" vTcl:WidgetProc "Toplevel461" 1
    set site_6_0 $site_5_0.cpd78
    frame $site_6_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_6_0.fra39" "Frame69" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra39
    label $site_7_0.lab34 \
        -padx 1 -text {Window Size Row} 
    vTcl:DefineAlias "$site_7_0.lab34" "Label461_5" vTcl:WidgetProc "Toplevel461" 1
    label $site_7_0.lab35 \
        -padx 1 -text {Window Size Col} 
    vTcl:DefineAlias "$site_7_0.lab35" "Label461_6" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.lab34 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_7_0.lab35 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_6_0.fra40" "Frame70" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra40
    entry $site_7_0.ent36 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable CSNwinLEnt -width 5 
    vTcl:DefineAlias "$site_7_0.ent36" "Entry461_7" vTcl:WidgetProc "Toplevel461" 1
    entry $site_7_0.ent37 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable CSNwinCEnt -width 5 
    vTcl:DefineAlias "$site_7_0.ent37" "Entry461_8" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.ent36 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_7_0.ent37 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.fra39 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.fra40 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side left 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {CS-SubLook-Entropy Output File} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame461_5" vTcl:WidgetProc "Toplevel461" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd66 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable CSEntSubLookOutputFile -width 40 
    vTcl:DefineAlias "$site_5_0.cpd66" "Entry461_9" vTcl:WidgetProc "Toplevel461" 1
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.fra67 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 0 -fill x -padx 5 -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -padx 5 -side top 
    frame $top.cpd80 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd80" "Frame6" vTcl:WidgetProc "Toplevel461" 1
    set site_3_0 $top.cpd80
    frame $site_3_0.fra67 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra67" "Frame7" vTcl:WidgetProc "Toplevel461" 1
    set site_4_0 $site_3_0.fra67
    checkbutton $site_4_0.che68 \
        \
        -command {global CSCohSubLookFlag CSCohSLThreshold CSNwinLCoh CSNwinCCoh CSCohSLBMP CSCohSubLookOutputFile CSInputFile PSPBackgroundColor

if {$CSCohSubLookFlag == 0} {
    $widget(TitleFrame461_6) configure -state disable
    $widget(TitleFrame461_7) configure -state disable
    $widget(Entry461_10) configure -state disable
    $widget(Entry461_11) configure -state disable
    $widget(Entry461_12) configure -state disable
    $widget(Entry461_13) configure -state disable
    $widget(Entry461_10) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry461_11) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry461_12) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry461_13) configure -disabledbackground $PSPBackgroundColor
    $widget(Button461_6) configure -state disable
    $widget(Button461_7) configure -state disable
    $widget(Label461_7) configure -state disable
    $widget(Label461_8) configure -state disable
    $widget(Label461_9) configure -state disable
    $widget(Checkbutton461_3) configure -state disable
    set CSCohSLThreshold ""
    set CSNwinLCoh ""; set CSNwinCCoh ""
    set CSCohSLBMP 0
    set CSCohSubLookOutputFile ""
    } else {
if {$CSInputFile != "SELECT AN INPUT DATA FILE"} {
    $widget(TitleFrame461_6) configure -state normal
    $widget(TitleFrame461_7) configure -state normal
    $widget(Entry461_10) configure -state disable
    $widget(Entry461_11) configure -state normal
    $widget(Entry461_12) configure -state normal
    $widget(Entry461_13) configure -state disable
    $widget(Entry461_10) configure -disabledbackground #FFFFFF
    $widget(Entry461_11) configure -disabledbackground #FFFFFF
    $widget(Entry461_12) configure -disabledbackground #FFFFFF
    $widget(Entry461_13) configure -disabledbackground #FFFFFF
    $widget(Button461_6) configure -state normal
    $widget(Button461_7) configure -state normal
    $widget(Label461_7) configure -state normal
    $widget(Label461_8) configure -state normal
    $widget(Label461_9) configure -state normal
    $widget(Checkbutton461_3) configure -state normal
    set CSCohSLThreshold "0.7"
    set CSNwinLCoh "5"; set CSNwinCCoh "5"
    set CSCohSLBMP 0
    set toto [file tail $CSInputFile]
    set CSCohSubLookOutputFile "CS_SubLook-2_Coherence-" 
    append CSCohSubLookOutputFile $CSCohSLThreshold
    append CSCohSubLookOutputFile "_$toto"
} else {
set CSCohSubLookFlag 0
}
    }} \
        -text {Sub-Look Coherence Procedure} -variable CSCohSubLookFlag 
    vTcl:DefineAlias "$site_4_0.che68" "Checkbutton3" vTcl:WidgetProc "Toplevel461" 1
    pack $site_4_0.che68 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd70 \
        -ipad 0 -text Parameters 
    vTcl:DefineAlias "$site_3_0.cpd70" "TitleFrame461_6" vTcl:WidgetProc "Toplevel461" 1
    bind $site_3_0.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd70 getframe]
    frame $site_5_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd82" "Frame74" vTcl:WidgetProc "Toplevel461" 1
    set site_6_0 $site_5_0.cpd82
    frame $site_6_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_6_0.fra39" "Frame75" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra39
    label $site_7_0.lab34 \
        -padx 1 -text {Coherence Threshold} 
    vTcl:DefineAlias "$site_7_0.lab34" "Label461_7" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.lab34 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    frame $site_6_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_6_0.fra40" "Frame76" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra40
    entry $site_7_0.ent36 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CSCohSLThreshold -width 5 
    vTcl:DefineAlias "$site_7_0.ent36" "Entry461_10" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.ent36 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    frame $site_6_0.cpd74 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_6_0.cpd74" "Frame77" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.cpd74
    frame $site_7_0.cpd79 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd79" "Frame79" vTcl:WidgetProc "Toplevel461" 1
    set site_8_0 $site_7_0.cpd79
    button $site_8_0.cpd77 \
        \
        -command {global CSCohSLNum CSCohSLThreshold CSCohSubLookOutputFile CSInputFile

set CSCohSLThreshold [expr $CSCohSLThreshold + 0.1]
if {$CSCohSLThreshold == 1.1} {set CSCohSLThreshold 0.1}

set toto [file tail $CSInputFile]
set CSCohSubLookOutputFile "CS_SubLook-2_Coherence-" 
append CSCohSubLookOutputFile $CSCohSLThreshold
append CSCohSubLookOutputFile "_$toto"} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_8_0.cpd77" "Button461_6" vTcl:WidgetProc "Toplevel461" 1
    button $site_8_0.cpd78 \
        \
        -command {global CSCohSLNum CSCohSLThreshold CSCohSubLookOutputFile CSInputFile

set CSCohSLThreshold [expr $CSCohSLThreshold - 0.1]
if {$CSCohSLThreshold < 0.1} {set CSCohSLThreshold 1.0}

set toto [file tail $CSInputFile]
set CSCohSubLookOutputFile "CS_SubLook-2_Coherence-" 
append CSCohSubLookOutputFile $CSCohSLThreshold
append CSCohSubLookOutputFile "_$toto"} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_8_0.cpd78" "Button461_7" vTcl:WidgetProc "Toplevel461" 1
    pack $site_8_0.cpd77 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.fra39 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.fra40 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    checkbutton $site_5_0.cpd83 \
        -text BMP -variable CSCohSLBMP 
    vTcl:DefineAlias "$site_5_0.cpd83" "Checkbutton461_3" vTcl:WidgetProc "Toplevel461" 1
    frame $site_5_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd78" "Frame80" vTcl:WidgetProc "Toplevel461" 1
    set site_6_0 $site_5_0.cpd78
    frame $site_6_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_6_0.fra39" "Frame81" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra39
    label $site_7_0.lab34 \
        -padx 1 -text {Window Size Row} 
    vTcl:DefineAlias "$site_7_0.lab34" "Label461_8" vTcl:WidgetProc "Toplevel461" 1
    label $site_7_0.lab35 \
        -padx 1 -text {Window Size Col} 
    vTcl:DefineAlias "$site_7_0.lab35" "Label461_9" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.lab34 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_7_0.lab35 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    frame $site_6_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_6_0.fra40" "Frame82" vTcl:WidgetProc "Toplevel461" 1
    set site_7_0 $site_6_0.fra40
    entry $site_7_0.ent36 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable CSNwinLCoh -width 5 
    vTcl:DefineAlias "$site_7_0.ent36" "Entry461_11" vTcl:WidgetProc "Toplevel461" 1
    entry $site_7_0.ent37 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable CSNwinCCoh -width 5 
    vTcl:DefineAlias "$site_7_0.ent37" "Entry461_12" vTcl:WidgetProc "Toplevel461" 1
    pack $site_7_0.ent36 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_7_0.ent37 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.fra39 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_6_0.fra40 \
        -in $site_6_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side left 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd78 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {CS-SubLook-Coherence Output File} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame461_7" vTcl:WidgetProc "Toplevel461" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd66 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable CSCohSubLookOutputFile -width 40 
    vTcl:DefineAlias "$site_5_0.cpd66" "Entry461_13" vTcl:WidgetProc "Toplevel461" 1
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.fra67 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 0 -fill x -padx 5 -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -padx 5 -side top 
    menu $top.m102 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd79 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra28 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit84 \
        -in $top -anchor center -expand 0 -fill x -padx 5 -pady 2 -side top 
    pack $top.fra42 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side bottom 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill x -ipady 2 -padx 5 -pady 5 \
        -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -ipady 2 -padx 5 -pady 5 \
        -side top 
    pack $top.cpd80 \
        -in $top -anchor center -expand 0 -fill x -ipady 2 -padx 5 -pady 5 \
        -side top 

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
Window show .top461

main $argc $argv
