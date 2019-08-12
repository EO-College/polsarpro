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
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images ALOS2.gif]} {user image} user {}}

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
    set base .top454
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab49 {
        array set save {-image 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd71 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd71
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
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.but71 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra88 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra88
    namespace eval ::widgets::$site_3_0.cpd89 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra90
    namespace eval ::widgets::$site_4_0.fra91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra91
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd97
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd67
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd68
    namespace eval ::widgets::$site_6_0.cpd69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd98
    namespace eval ::widgets::$site_5_0.cpd97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd97
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd99 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd99
    namespace eval ::widgets::$site_6_0.cpd94 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd90 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd90 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.lab91 {
        array set save {-width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.lab91 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd97 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd97
    namespace eval ::widgets::$site_5_0.lab91 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd100 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd100
    namespace eval ::widgets::$site_5_0.lab91 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd101 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd101
    namespace eval ::widgets::$site_5_0.lab91 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd96 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.cpd85 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.cpd85
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.men90 {
        array set save {-_tooltip 1 -background 1 -menu 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.men90.m {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
        namespace eval subOptions {
            array set save {-command 1 -label 1}
        }
    }
    namespace eval ::widgets::$site_3_0.fra71 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.fra71
    namespace eval ::widgets::$site_4_0.che72 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra57 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra57
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd70
    namespace eval ::widgets::$site_4_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra39
    namespace eval ::widgets::$site_5_0.lab40 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent41 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab42 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent43 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd74
    namespace eval ::widgets::$site_4_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra39
    namespace eval ::widgets::$site_5_0.lab40 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent41 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab42 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent43 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
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
            vTclWindow.top454
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
    wm geometry $top 200x200+100+100; update
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

proc vTclWindow.top454 {base} {
    if {$base == ""} {
        set base .top454
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
    wm geometry $top 500x570+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "ALOS Input Data File (JAXA - CEOS Format)"
    vTcl:DefineAlias "$top" "Toplevel454" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    label $top.lab49 \
        -image [vTcl:image:get_image [file join . GUI Images ALOS2.gif]] \
        -text label 
    vTcl:DefineAlias "$top.lab49" "Label73" vTcl:WidgetProc "Toplevel454" 1
    frame $top.cpd71 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd71" "Frame1" vTcl:WidgetProc "Toplevel454" 1
    set site_3_0 $top.cpd71
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel454" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ALOSDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel454" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame11" vTcl:WidgetProc "Toplevel454" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button1" vTcl:WidgetProc "Toplevel454" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd71 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame5" vTcl:WidgetProc "Toplevel454" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable ALOSDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel454" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame12" vTcl:WidgetProc "Toplevel454" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.but71 \
        \
        -command {global DirName DataDir ALOSDirOutput
global VarWarning WarningMessage WarningMessage2

set ALOSOutputDirTmp $ALOSDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set ALOSDirOutput $DirName
        } else {
        set ALOSDirOutput $ALOSOutputDirTmp
        }
    } else {
    set ALOSDirOutput $ALOSOutputDirTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but71" "Button2" vTcl:WidgetProc "Toplevel454" 1
    pack $site_6_0.but71 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd72 \
        -ipad 0 -text {SAR Leader File  ( LED-xxxxxxxxxxxx-xx.x__x )} 
    vTcl:DefineAlias "$top.cpd72" "TitleFrame6" vTcl:WidgetProc "Toplevel454" 1
    bind $top.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd72 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ALOSLeaderFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel454" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame13" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.but71 \
        \
        -command {global FileName ALOSDirInput ALOSLeaderFile
global ErrorMessage VarError

set types {
    {{All Files}        *        }
    }
set FileName ""
OpenFile $ALOSDirInput $types "SAR LEADER INPUT FILE"

set LeaderDirName [file dirname $FileName]
set LeaderDirNameLength [string length $LeaderDirName]
set index1 [expr ($LeaderDirNameLength + 1)]
set index2 [expr ($index1 + 2)]
set LeaderFile [string range $FileName $index1 $index2]

if {$LeaderFile == "LED"} {
    set ALOSLeaderFile $FileName
    } else {
    set ALOSLeaderFile ""
    set VarError ""
    set ErrorMessage "THIS IS NOT A SAR LEADER FILE"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but71" "Button3" vTcl:WidgetProc "Toplevel454" 1
    pack $site_5_0.but71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra88 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra88" "Frame30" vTcl:WidgetProc "Toplevel454" 1
    set site_3_0 $top.fra88
    button $site_3_0.cpd89 \
        -background #ffff00 \
        -command {global ALOSLeaderFile ALOSTrailerFile ALOSDataFormat
global ALOSDirInput ALOSDirOutput TMPGoogle
global ALOSMode ALOSNode ALOSDataLevel ALOSSceneID ALOSOrbit ALOSDate ALOSDirection
global FileInput1 FileInput2 FileInput3 FileInput4
global ErrorMessage VarError PolarType ActiveProgram
global VarAdvice WarningMessage WarningMessage2 WarningMessage3 WarningMessage4

if {$OpenDirFile == 0} {

DeleteFile  $TMPGoogle

set config "true"
if {$ALOSLeaderFile == ""} { set config "false" }

if {$config == "true"} {
    set LeaderFile [file tail $ALOSLeaderFile]
    set ALOSScene [string range $LeaderFile 14 17]
    set ALOSOrbit [string range $LeaderFile 9 13]
    set ALOSDate [string range $LeaderFile 19 24]
    set ALOSNode [string range $LeaderFile 35 35]
    
    set ALOSSceneID [string range $LeaderFile 4 24]
    set ALOSProductID [string range $LeaderFile 26 35]

    set ModeALOS [string range $LeaderFile 26 28]
    set ALOSDirection [string range $LeaderFile 29 29]
    if {$ALOSDirection == "L"} { set ALOSDirection "Left"}
    if {$ALOSDirection == "R"} { set ALOSDirection "Right"}
    set ALOSDataLevel [string range $LeaderFile 30 32]

    $widget(Label454_8) configure -state normal; $widget(Entry454_8) configure -disabledbackground #FFFFFF
    $widget(Label454_9) configure -state normal; $widget(Entry454_9) configure -disabledbackground #FFFFFF
    $widget(Label454_10) configure -state normal; $widget(Entry454_10) configure -disabledbackground #FFFFFF
    $widget(Label454_11) configure -state normal; $widget(Entry454_11) configure -disabledbackground #FFFFFF
    $widget(Label454_17) configure -state normal; $widget(Entry454_17) configure -disabledbackground #FFFFFF
    $widget(Label454_18) configure -state normal; $widget(Entry454_18) configure -disabledbackground #FFFFFF
    $widget(Label454_19) configure -state normal; $widget(Entry454_19) configure -disabledbackground #FFFFFF

    if {$ModeALOS == "HBQ" || $ModeALOS == "FBQ"} {
        set ALOSMode "Quad Pol ($ModeALOS)"
        set ModeALOS "quad"
        }
    if {$ModeALOS == "UBD" || $ModeALOS == "HBD" || $ModeALOS == "FBD"} {
        set ALOSMode "Dual Pol ($ModeALOS)"
        set ModeALOS "dual"
        }

    append ModeALOS $ALOSDataLevel
    if {$ALOSDataFormat != $ModeALOS} {
        set ErrorMessage "ERROR IN THE ALOS2-PALSAR DATA MODE and/or LEVEL"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        MenuRAZ
        ClosePSPViewer
        CloseAllWidget
        Window hide $widget(Toplevel454); TextEditorRunTrace "Close Window ALOS2 Input File" "b"

        } else {

        set LeaderDirName [file dirname $ALOSLeaderFile]; append LeaderDirName "/"
        set ALOSTrailerFile $LeaderDirName; append ALOSTrailerFile "TRL-"
        append ALOSTrailerFile $ALOSSceneID; append ALOSTrailerFile "-"
        append ALOSTrailerFile $ALOSProductID
        if [file exists $ALOSTrailerFile] {
            $widget(TitleFrame454_1) configure -state normal
            $widget(Entry454_12) configure -disabledbackground #FFFFFF

            set WarningMessage "PolSARpro WILL TAKE INTO ACCOUNT THE"
            set WarningMessage2 "ALOS-PALSAR ENGINEER CONVENTION FOR THE"
            set WarningMessage3 "DEFINITION OF THE POLARIMETRIC CHANNELS"
            set WarningMessage4 "WITH : s12 = VH and s21 = HV"
            set VarAdvice ""
            Window show $widget(Toplevel377); TextEditorRunTrace "Open Window Advice" "b"
            tkwait variable VarAdvice

            set FileHH $LeaderDirName; append FileHH "IMG-HH-"; append FileHH $ALOSSceneID; append FileHH "-"; append FileHH $ALOSProductID
            set FileHV $LeaderDirName; append FileHV "IMG-HV-"; append FileHV $ALOSSceneID; append FileHV "-"; append FileHV $ALOSProductID
            set FileVH $LeaderDirName; append FileVH "IMG-VH-"; append FileVH $ALOSSceneID; append FileVH "-"; append FileVH $ALOSProductID
            set FileVV $LeaderDirName; append FileVV "IMG-VV-"; append FileVV $ALOSSceneID; append FileVV "-"; append FileVV $ALOSProductID

            if {$ModeALOS == "quad1.1"} {
                set config "true"
                if [file exists $FileHH] { } else { set config "false" }
                if [file exists $FileHV] { } else { set config "false" }
                if [file exists $FileVH] { } else { set config "false" }
                if [file exists $FileVV] { } else { set config "false" }
                if {$config == "true"} {
                    $widget(TitleFrame454_2) configure -state normal
                    set FileInput1 $FileHH
                    $widget(Label454_13) configure -state normal; $widget(Entry454_13) configure -disabledbackground #FFFFFF
                    set FileInput2 $FileVH
                    $widget(Label454_14) configure -state normal; $widget(Entry454_14) configure -disabledbackground #FFFFFF
                    set FileInput3 $FileHV
                    $widget(Label454_15) configure -state normal; $widget(Entry454_15) configure -disabledbackground #FFFFFF
                    set FileInput4 $FileVV
                    $widget(Label454_16) configure -state normal; $widget(Entry454_16) configure -disabledbackground #FFFFFF
                    $widget(Button454_9) configure -state normal
                    } else {
                    set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 ""
                    set VarError ""
                    set ErrorMessage "THE IMAGE DATA FILES DO NOT EXIST" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    Window hide $widget(Toplevel454); TextEditorRunTrace "Close Window ALOS Input File" "b"
                    }
               }
            if {$ModeALOS == "dual1.1"} {
                set PolarType ""
                if [file exists $FileHH] { 
                    if [file exists $FileHV] { set PolarType "pp1" }
                    if [file exists $FileVV] { set PolarType "pp3" }
                    }
                if [file exists $FileVV] { 
                    if [file exists $FileVH] { set PolarType "pp2" }
                    if [file exists $FileHH] { set PolarType "pp3" }
                    }
                if {$PolarType != ""} {
                    $widget(TitleFrame454_2) configure -state normal
                    if {$PolarType == "pp1"} {set FileInput1 $FileHH }
                    if {$PolarType == "pp2"} {set FileInput1 $FileVV }
                    if {$PolarType == "pp3"} {set FileInput1 $FileHH }
                    $widget(Label454_13) configure -state normal; $widget(Entry454_13) configure -disabledbackground #FFFFFF
                    if {$PolarType == "pp1"} {set FileInput2 $FileHV }
                    if {$PolarType == "pp2"} {set FileInput2 $FileVH }
                    if {$PolarType == "pp3"} {set FileInput2 $FileVV }
                    $widget(Label454_14) configure -state normal; $widget(Entry454_14) configure -disabledbackground #FFFFFF
                    $widget(Label454_15) configure -state disable; $widget(Entry454_15) configure -disabledbackground $PSPBackgroundColor
                    $widget(Label454_16) configure -state disable; $widget(Entry454_16) configure -disabledbackground $PSPBackgroundColor
                    $widget(Button454_9) configure -state normal
                    } else {
                    set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 ""
                    set VarError ""
                    set ErrorMessage "THE IMAGE DATA FILES DO NOT EXIST" 
                    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                    tkwait variable VarError
                    Window hide $widget(Toplevel454); TextEditorRunTrace "Close Window ALOS Input File" "b"
                    }
                }            
            } else {
            set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 "" 
            set VarError ""
            set ErrorMessage "THE SAR TRAILER FILE DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            Window hide $widget(Toplevel454); TextEditorRunTrace "Close Window ALOS Input File" "b"
            }
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER THE SAR LEADER FILE"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -cursor {} -padx 4 -pady 2 -text {Check Files} 
    vTcl:DefineAlias "$site_3_0.cpd89" "Button219" vTcl:WidgetProc "Toplevel454" 1
    bindtags $site_3_0.cpd89 "$site_3_0.cpd89 Button $top all _vTclBalloon"
    bind $site_3_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    frame $site_3_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra90" "Frame31" vTcl:WidgetProc "Toplevel454" 1
    set site_4_0 $site_3_0.fra90
    frame $site_4_0.fra91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra91" "Frame32" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.fra91
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame34" vTcl:WidgetProc "Toplevel454" 1
    set site_6_0 $site_5_0.fra93
    label $site_6_0.cpd94 \
        -text {Scene ID   } 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label454_10" vTcl:WidgetProc "Toplevel454" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ALOSScene -width 7 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry454_10" vTcl:WidgetProc "Toplevel454" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd97" "Frame35" vTcl:WidgetProc "Toplevel454" 1
    set site_6_0 $site_5_0.cpd97
    label $site_6_0.cpd94 \
        -text Date 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label454_11" vTcl:WidgetProc "Toplevel454" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ALOSDate -width 8 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry454_11" vTcl:WidgetProc "Toplevel454" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    frame $site_5_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd67" "Frame39" vTcl:WidgetProc "Toplevel454" 1
    set site_6_0 $site_5_0.cpd67
    label $site_6_0.cpd94 \
        -text {Orbit   } 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label454_8" vTcl:WidgetProc "Toplevel454" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ALOSNode -width 3 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry454_8" vTcl:WidgetProc "Toplevel454" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd68" "Frame40" vTcl:WidgetProc "Toplevel454" 1
    set site_6_0 $site_5_0.cpd68
    label $site_6_0.cpd69 \
        -text {n° : } 
    vTcl:DefineAlias "$site_6_0.cpd69" "Label454_9" vTcl:WidgetProc "Toplevel454" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ALOSOrbit -width 7 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry454_9" vTcl:WidgetProc "Toplevel454" 1
    pack $site_6_0.cpd69 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd97 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd98 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd98" "Frame33" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.cpd98
    frame $site_5_0.cpd97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd97" "Frame37" vTcl:WidgetProc "Toplevel454" 1
    set site_6_0 $site_5_0.cpd97
    label $site_6_0.cpd94 \
        -text Mode 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label454_18" vTcl:WidgetProc "Toplevel454" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ALOSMode -width 14 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry454_18" vTcl:WidgetProc "Toplevel454" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 9 -side left 
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame36" vTcl:WidgetProc "Toplevel454" 1
    set site_6_0 $site_5_0.fra93
    label $site_6_0.cpd94 \
        -text {Data Level } 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label454_17" vTcl:WidgetProc "Toplevel454" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ALOSDataLevel -width 5 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry454_17" vTcl:WidgetProc "Toplevel454" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.cpd99 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd99" "Frame38" vTcl:WidgetProc "Toplevel454" 1
    set site_6_0 $site_5_0.cpd99
    label $site_6_0.cpd94 \
        -text Direction 
    vTcl:DefineAlias "$site_6_0.cpd94" "Label454_19" vTcl:WidgetProc "Toplevel454" 1
    entry $site_6_0.cpd95 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ALOSDirection -width 8 
    vTcl:DefineAlias "$site_6_0.cpd95" "Entry454_19" vTcl:WidgetProc "Toplevel454" 1
    pack $site_6_0.cpd94 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.cpd97 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd99 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side right 
    pack $site_4_0.fra91 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.cpd89 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra90 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd90 \
        -ipad 0 -text {SAR Trailer File} 
    vTcl:DefineAlias "$top.cpd90" "TitleFrame454_1" vTcl:WidgetProc "Toplevel454" 1
    bind $top.cpd90 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd90 getframe]
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame14" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.cpd92
    label $site_5_0.lab91 \
        -width 3 
    vTcl:DefineAlias "$site_5_0.lab91" "Label8" vTcl:WidgetProc "Toplevel454" 1
    pack $site_5_0.lab91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ALOSTrailerFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry454_12" vTcl:WidgetProc "Toplevel454" 1
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    TitleFrame $top.cpd92 \
        -ipad 0 -text {SAR Image Files} 
    vTcl:DefineAlias "$top.cpd92" "TitleFrame454_2" vTcl:WidgetProc "Toplevel454" 1
    bind $top.cpd92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd92 getframe]
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.cpd92
    label $site_5_0.lab91 \
        -text s11 -width 3 
    vTcl:DefineAlias "$site_5_0.lab91" "Label454_13" vTcl:WidgetProc "Toplevel454" 1
    entry $site_5_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput1 
    vTcl:DefineAlias "$site_5_0.cpd96" "Entry454_13" vTcl:WidgetProc "Toplevel454" 1
    pack $site_5_0.lab91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd96 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd97 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd97" "Frame16" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.cpd97
    label $site_5_0.lab91 \
        -text s12 -width 3 
    vTcl:DefineAlias "$site_5_0.lab91" "Label454_14" vTcl:WidgetProc "Toplevel454" 1
    entry $site_5_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput2 
    vTcl:DefineAlias "$site_5_0.cpd96" "Entry454_14" vTcl:WidgetProc "Toplevel454" 1
    pack $site_5_0.lab91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd96 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd100 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd100" "Frame17" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.cpd100
    label $site_5_0.lab91 \
        -text s21 -width 3 
    vTcl:DefineAlias "$site_5_0.lab91" "Label454_15" vTcl:WidgetProc "Toplevel454" 1
    entry $site_5_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput3 
    vTcl:DefineAlias "$site_5_0.cpd96" "Entry454_15" vTcl:WidgetProc "Toplevel454" 1
    pack $site_5_0.lab91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd96 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    frame $site_4_0.cpd101 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd101" "Frame18" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.cpd101
    label $site_5_0.lab91 \
        -text s22 -width 3 
    vTcl:DefineAlias "$site_5_0.lab91" "Label454_16" vTcl:WidgetProc "Toplevel454" 1
    entry $site_5_0.cpd96 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInput4 
    vTcl:DefineAlias "$site_5_0.cpd96" "Entry454_16" vTcl:WidgetProc "Toplevel454" 1
    pack $site_5_0.lab91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd96 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd97 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd100 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd101 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.cpd85 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.cpd85" "Frame21" vTcl:WidgetProc "Toplevel454" 1
    set site_3_0 $top.cpd85
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global ALOSDirInput ALOSDirOutput ALOSFileInputFlag
global ALOSDataFormat ALOSDataLevel ALOSDataType ALOSPixRow ALOSPixCol
global FileInput1 FileInput2 FileInput3 FileInput4
global VarWarning VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError
global NligInit NligEnd NligFullSize NcolInit NcolEnd NcolFullSize NligFullSizeInput NcolFullSizeInput
global TMPALOSConfig OpenDirFile
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

#####################################################################
#Create Directory
set ALOSDirOutput [PSPCreateDirectoryMask $ALOSDirOutput $ALOSDirOutput $ALOSDirInput]
#####################################################################       

if {"$VarWarning"=="ok"} {

DeleteFile  $TMPALOSConfig

TextEditorRunTrace "Process The Function Soft/bin/data_import/alos2_header.exe" "k"
TextEditorRunTrace "Arguments: -od \x22$ALOSDirOutput\x22 -ilf \x22$ALOSLeaderFile\x22 -iif \x22$FileInput1\x22 -itf \x22$ALOSTrailerFile\x22 -ocf \x22$TMPALOSConfig\x22" "k"
set f [ open "| Soft/bin/data_import/alos2_header.exe -od \x22$ALOSDirOutput\x22 -ilf \x22$ALOSLeaderFile\x22 -iif \x22$FileInput1\x22 -itf \x22$ALOSTrailerFile\x22 -ocf \x22$TMPALOSConfig\x22" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError

set ALOSFileInputFlag 0
    
set NligFullSize 0
set NcolFullSize 0
set NligInit 0
set NligEnd 0
set NcolInit 0
set NcolEnd 0
set NligFullSizeInput 0
set NcolFullSizeInput 0
set ConfigFile $TMPALOSConfig
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
    gets $f tmp; gets $f tmp; gets $f tmp
    gets $f tmp; gets $f tmp; gets $f tmp
    gets $f tmp; gets $f tmp; gets $f tmp
    gets $f tmp; gets $f tmp; gets $f tmp
    gets $f tmp; gets $f tmp; gets $f tmp
    gets $f ALOSAntennaPass
    gets $f ALOSIncAng
    gets $f ALOSResAz; set ALOSPixRow $ALOSResAz
    gets $f ALOSResRg; set ALOSPixCol $ALOSResRg
    close $f
    set TestVarName(0) "Initial Number of Rows"; set TestVarType(0) "int"; set TestVarValue(0) $NligFullSize; set TestVarMin(0) "0"; set TestVarMax(0) ""
    set TestVarName(1) "Initial Number of Cols"; set TestVarType(1) "int"; set TestVarValue(1) $NcolFullSize; set TestVarMin(1) "0"; set TestVarMax(1) ""
    TestVar 2
    if {$TestVarError == "ok"} {
        if { $ALOSAntennaPass == "ASCEND"} {set ALOSAntennaPass "AR"} else {set ALOSAntennaPass "DR"} 
        set f [open "$ALOSDirOutput/config_acquisition.txt" w]
        puts $f $ALOSAntennaPass
        puts $f $ALOSIncAng
        puts $f $ALOSResRg
        puts $f $ALOSResAz
        close $f

        set ALOSFileInputFlag 1
        if {$ALOSDataLevel == "1.1" } { set ALOSDataType "COMPLEX SAR IMAGE" }
        if {$ALOSDataLevel == "1.5" } { set ALOSDataType "GEOREFERENCED SAR IMAGE" }
        set NligInit 1
        set NligEnd $NligFullSize
        set NcolInit 1
        set NcolEnd $NcolFullSize
        set NligFullSizeInput $NligFullSize
        set NcolFullSizeInput $NcolFullSize
        $widget(Button454_9) configure -state normal; $widget(Menubutton454_1) configure -state normal
        if {$ALOSDataFormat == "quad1.1" } { $widget(Checkbutton454_1) configure -state normal }
        $widget(Label454_1) configure -state normal; $widget(Entry454_1) configure -disabledbackground #FFFFFF
        $widget(Label454_2) configure -state normal; $widget(Entry454_2) configure -disabledbackground #FFFFFF
        $widget(Label454_3) configure -state normal; $widget(Entry454_3) configure -disabledbackground #FFFFFF
        $widget(Label454_4) configure -state normal; $widget(Entry454_4) configure -disabledbackground #FFFFFF
        $widget(Button454_10) configure -state normal
        } else {
        set ErrorMessage "ROWS / COLS EXTRACTION ERROR"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {
    set ErrorMessage "HEADER EXTRACTION ERROR"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
   }
if {$ALOSFileInputFlag == 0 } {
    set NligInit ""; set NligEnd ""; set NligFullSize ""; set NcolInit ""; set NcolEnd ""; set NcolFullSize ""
    set NligFullSizeInput ""; set NcolFullSizeInput ""
    set FileInput1 ""; set FileInput2 ""; set FileInput3 ""; set FileInput4 ""; 
    Window hide $widget(Toplevel454); TextEditorRunTrace "Close Window ALOS Input File" "b"
    }    
  }} \
        -cursor {} -padx 4 -pady 2 -text {Read Header} 
    vTcl:DefineAlias "$site_3_0.but93" "Button454_9" vTcl:WidgetProc "Toplevel454" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Read Header Files}
    }
    menubutton $site_3_0.men90 \
        -background #ffff00 -menu "$site_3_0.men90.m" -padx 5 -pady 4 \
        -relief raised -text {Edit Header} 
    vTcl:DefineAlias "$site_3_0.men90" "Menubutton454_1" vTcl:WidgetProc "Toplevel454" 1
    bindtags $site_3_0.men90 "$site_3_0.men90 Menubutton $top all _vTclBalloon"
    bind $site_3_0.men90 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit Header Files}
    }
    menu $site_3_0.men90.m \
        -activeborderwidth 1 -borderwidth 1 -tearoff 0 
    $site_3_0.men90.m add command \
        \
        -command {global FileName VarError ErrorMessage ALOSDirOutput
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

set ALOSFile "$ALOSDirOutput/ceos_leader.txt"
if [file exists $ALOSFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top454 $ALOSFile
    }} \
        -label {Leader Header} 
    $site_3_0.men90.m add command \
        \
        -command {global FileName VarError ErrorMessage ALOSDirOutput
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

set ALOSFile "$ALOSDirOutput/ceos_trailer.txt"
if [file exists $ALOSFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top454 $ALOSFile
    }} \
        -label {Trailer Header} 
    $site_3_0.men90.m add command \
        \
        -command {global FileName VarError ErrorMessage ALOSDirOutput
#UTIL
global Load_TextEdit PSPTopLevel
if {$Load_TextEdit == 0} {
    source "GUI/util/TextEdit.tcl"
    set Load_TextEdit 1
    WmTransient $widget(Toplevel95) $PSPTopLevel
    }

set ALOSFile "$ALOSDirOutput/ceos_image.txt"
if [file exists $ALOSFile] {
    TextEditorRunTrace "Open Window Text Editor" "b"
    TextEditorFromWidget .top454 $ALOSFile
    }} \
        -label {Image Header} 
    frame $site_3_0.fra71 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra71" "Frame2" vTcl:WidgetProc "Toplevel454" 1
    set site_4_0 $site_3_0.fra71
    checkbutton $site_4_0.che72 \
        -text {Extract Uncalibrated Raw Binary Data} \
        -variable ALOSUnCalibration 
    vTcl:DefineAlias "$site_4_0.che72" "Checkbutton454_1" vTcl:WidgetProc "Toplevel454" 1
    pack $site_4_0.che72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.men90 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra57 \
        -borderwidth 2 -relief sunken -height 76 -width 200 
    vTcl:DefineAlias "$top.fra57" "Frame" vTcl:WidgetProc "Toplevel454" 1
    set site_3_0 $top.fra57
    frame $site_3_0.cpd70 \
        -borderwidth 2 -height 76 -width 200 
    vTcl:DefineAlias "$site_3_0.cpd70" "Frame3" vTcl:WidgetProc "Toplevel454" 1
    set site_4_0 $site_3_0.cpd70
    frame $site_4_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra39" "Frame108" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.fra39
    label $site_5_0.lab40 \
        -text {Initial Number of Rows} 
    vTcl:DefineAlias "$site_5_0.lab40" "Label454_1" vTcl:WidgetProc "Toplevel454" 1
    entry $site_5_0.ent41 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligFullSize -width 9 
    vTcl:DefineAlias "$site_5_0.ent41" "Entry454_1" vTcl:WidgetProc "Toplevel454" 1
    pack $site_5_0.lab40 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.ent41 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 \
        -side right 
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame109" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab42 \
        -text {Row Pixel Spacing} 
    vTcl:DefineAlias "$site_5_0.lab42" "Label454_3" vTcl:WidgetProc "Toplevel454" 1
    entry $site_5_0.ent43 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ALOSPixRow -width 9 
    vTcl:DefineAlias "$site_5_0.ent43" "Entry454_3" vTcl:WidgetProc "Toplevel454" 1
    pack $site_5_0.lab42 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.ent43 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 \
        -side right 
    pack $site_4_0.fra39 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $site_3_0.cpd74 \
        -borderwidth 2 -height 76 -width 200 
    vTcl:DefineAlias "$site_3_0.cpd74" "Frame4" vTcl:WidgetProc "Toplevel454" 1
    set site_4_0 $site_3_0.cpd74
    frame $site_4_0.fra39 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra39" "Frame110" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.fra39
    label $site_5_0.lab40 \
        -text {Col Pixel Spacing} 
    vTcl:DefineAlias "$site_5_0.lab40" "Label454_4" vTcl:WidgetProc "Toplevel454" 1
    entry $site_5_0.ent41 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ALOSPixCol -width 9 
    vTcl:DefineAlias "$site_5_0.ent41" "Entry454_4" vTcl:WidgetProc "Toplevel454" 1
    pack $site_5_0.lab40 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.ent41 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 \
        -side right 
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame111" vTcl:WidgetProc "Toplevel454" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab42 \
        -text {Initial Number of Cols} 
    vTcl:DefineAlias "$site_5_0.lab42" "Label454_2" vTcl:WidgetProc "Toplevel454" 1
    entry $site_5_0.ent43 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolFullSize -width 9 
    vTcl:DefineAlias "$site_5_0.ent43" "Entry454_2" vTcl:WidgetProc "Toplevel454" 1
    pack $site_5_0.lab42 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_5_0.ent43 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 \
        -side right 
    pack $site_4_0.fra39 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side bottom 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd74 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel454" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global OpenDirFile ALOSFileInputFlag
global VarAdvice WarningMessage WarningMessage2 ErrorMessage VarError

if {$OpenDirFile == 0} {
    if {$ALOSFileInputFlag == 1} {
        set ErrorMessage ""
        set WarningMessage "DON'T FORGET TO EXTRACT DATA"
        set WarningMessage2 "BEFORE RUNNING ANY DATA PROCESS"
        set VarAdvice ""
        Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
        tkwait variable VarAdvice
        Window hide $widget(Toplevel454); TextEditorRunTrace "Close Window ALOS Input File" "b"
        }
    }} \
        -cursor {} -padx 4 -pady 2 -text OK 
    vTcl:DefineAlias "$site_3_0.but93" "Button454_10" vTcl:WidgetProc "Toplevel454" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run and Exit the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/ALOS2_Input_File.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel454" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel454); TextEditorRunTrace "Close Window ALOS Input File" "b"
}} \
        -padx 4 -pady 2 -text Cancel 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel454" 1
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
    pack $top.lab49 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.cpd71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd72 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra88 \
        -in $top -anchor center -expand 0 -fill both -side top 
    pack $top.cpd90 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd92 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd85 \
        -in $top -anchor center -expand 1 -fill x -pady 2 -side top 
    pack $top.fra57 \
        -in $top -anchor center -expand 1 -fill none -side top 
    pack $top.fra59 \
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
Window show .top454

main $argc $argv
