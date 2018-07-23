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
    set base .top312
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
    namespace eval ::widgets::$site_3_0.cpd83 {
        array set save {-ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd83 getframe]
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
    namespace eval ::widgets::$base.cpd77 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd77 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra73 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra73
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-command 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.cpd109 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd98 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd100 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.cpd109 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd98 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd100 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd80
    namespace eval ::widgets::$site_5_0.cpd109 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd98 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd100 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd81
    namespace eval ::widgets::$site_5_0.cpd109 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd98 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd100 {
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
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra39
    namespace eval ::widgets::$site_6_0.lab33 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra40
    namespace eval ::widgets::$site_6_0.cpd85 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.ent36 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.cpd109 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd98 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd100 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit89 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit89 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd91 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd91
    namespace eval ::widgets::$site_5_0.rad93 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd94 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd95 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd96 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd97 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd92
    namespace eval ::widgets::$site_5_0.cpd109 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd98 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd100 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit84 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit84 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra90 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra90
    namespace eval ::widgets::$site_5_0.fra91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra91
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra92 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra92
    namespace eval ::widgets::$site_6_0.cpd79 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd76 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd77
    namespace eval ::widgets::$site_6_0.cpd81 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1 -width 1}
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
            vTclWindow.top312
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

proc vTclWindow.top312 {base} {
    if {$base == ""} {
        set base .top312
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
    wm geometry $top 500x550+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: POLinSAR - Unsurpervised Classification"
    vTcl:DefineAlias "$top" "Toplevel312" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame4" vTcl:WidgetProc "Toplevel312" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Master Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame312_01" vTcl:WidgetProc "Toplevel312" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable POLinSARMasterDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry312_01" vTcl:WidgetProc "Toplevel312" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel312" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button42" vTcl:WidgetProc "Toplevel312" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd83 \
        -ipad 0 -text {Input Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd83" "TitleFrame312_02" vTcl:WidgetProc "Toplevel312" 1
    bind $site_3_0.cpd83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd83 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable POLinSARSlaveDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "Entry312_02" vTcl:WidgetProc "Toplevel312" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame18" vTcl:WidgetProc "Toplevel312" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button43" vTcl:WidgetProc "Toplevel312" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Master - Slave Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel312" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable POLinSAROutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel312" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel312" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd73 \
        -padx 1 -text / 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label14" vTcl:WidgetProc "Toplevel312" 1
    entry $site_6_0.cpd74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable POLinSAROutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd74" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel312" 1
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame17" vTcl:WidgetProc "Toplevel312" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.cpd80 \
        \
        -command {global DirName POLinSARMasterDirInput POLinSAROutputDir

set POLinSARDirOutputTmp $POLinSAROutputDir
set DirName ""
OpenDir $POLinSARDirInput "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set POLinSAROutputDir $DirName
    } else {
    set POLinSAROutputDir $POLinSARDirOutputTmp
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
    pack $site_3_0.cpd83 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra28 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra28" "Frame9" vTcl:WidgetProc "Toplevel312" 1
    set site_3_0 $top.fra28
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel312" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel312" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel312" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel312" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel312" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel312" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel312" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel312" 1
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
    TitleFrame $top.cpd77 \
        -ipad 0 -text {Optimal Coherence Set Segmentation} 
    vTcl:DefineAlias "$top.cpd77" "TitleFrame312" vTcl:WidgetProc "Toplevel312" 1
    bind $top.cpd77 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd77 getframe]
    frame $site_4_0.fra73 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra73" "Frame8" vTcl:WidgetProc "Toplevel312" 1
    set site_5_0 $site_4_0.fra73
    checkbutton $site_5_0.cpd75 \
        \
        -command {global OptCohFlag WishartFlag OptCohAvg COLORMAPDir
global Opt1CohFile Opt2CohFile Opt3CohFile
global OptCohColorMap OptCohClassFile
global POLinSAROutputDir POLinSAROutputSubDir

set OptCohAvg 0
set OptCohClassFile ""
set OptCohColorMap ""
set Opt1CohFile ""; set Opt2CohFile ""; set Opt3CohFile ""

if {$OptCohFlag == 1} {
    $widget(Checkbutton312_1) configure -state normal
    $widget(Label312_1) configure -state normal
    $widget(Entry312_1) configure -disabledbackground #FFFFFF
    $widget(Button312_1) configure -state normal
    $widget(Label312_2) configure -state normal
    $widget(Entry312_2) configure -disabledbackground #FFFFFF
    $widget(Button312_2) configure -state normal
    $widget(Label312_3) configure -state normal
    $widget(Entry312_3) configure -disabledbackground #FFFFFF
    $widget(Button312_3) configure -state normal
    $widget(Label312_4) configure -state normal
    $widget(Entry312_4) configure -disabledbackground #FFFFFF
    $widget(Button312_4) configure -state normal
    $widget(Button312_5) configure -state normal
    set OptCohColorMap "$COLORMAPDir/Planes_A1_A2_ColorMap9.pal"
    set DirOutput $POLinSAROutputDir
    if {$POLinSAROutputSubDir != ""} {append DirOutput "/$POLinSAROutputSubDir"}
    if [file exists "$DirOutput/cmplx_coh_Opt1.bin"] {
        set Opt1CohFile "$DirOutput/cmplx_coh_Opt1.bin"
        } else {
        set Opt1CohFile "ENTER THE OPTIMAL-1 COHERENCE FILE NAME"
        }
    if [file exists "$DirOutput/cmplx_coh_Opt2.bin"] {
        set Opt2CohFile "$DirOutput/cmplx_coh_Opt2.bin"
        } else {
        set Opt2CohFile "ENTER THE OPTIMAL-2 COHERENCE FILE NAME"
        }
    if [file exists "$DirOutput/cmplx_coh_Opt3.bin"] {
        set Opt3CohFile "$DirOutput/cmplx_coh_Opt3.bin"
        } else {
        set Opt3CohFile "ENTER THE OPTIMAL-3 COHERENCE FILE NAME"
        }
    } else {
    $widget(Checkbutton312_1) configure -state disable
    $widget(Label312_1) configure -state disable
    $widget(Entry312_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button312_1) configure -state disable
    $widget(Label312_2) configure -state disable
    $widget(Entry312_2) configure -disabledbackground $PSPBackgroundColor
    $widget(Button312_2) configure -state disable
    $widget(Label312_3) configure -state disable
    $widget(Entry312_3) configure -disabledbackground $PSPBackgroundColor
    $widget(Button312_3) configure -state disable
    $widget(Label312_4) configure -state disable
    $widget(Entry312_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button312_4) configure -state disable
    $widget(Button312_5) configure -state disable
    }} \
        -variable OptCohFlag 
    vTcl:DefineAlias "$site_5_0.cpd75" "Checkbutton312_2" vTcl:WidgetProc "Toplevel312" 1
    checkbutton $site_5_0.cpd76 \
        \
        -command {global OptCohAvg
global Opt1CohFile Opt2CohFile Opt3CohFile
global Opt1CohFileTmp Opt2CohFileTmp Opt3CohFileTmp
global POLinSAROutputDir POLinSAROutputSubDir


if {$OptCohAvg == 1} {
    set Opt1CohFileTmp $Opt1CohFile
    set Opt2CohFileTmp $Opt2CohFile
    set Opt3CohFileTmp $Opt3CohFile
    set DirOutput $POLinSAROutputDir
    if {$POLinSAROutputSubDir != ""} {append DirOutput "/$POLinSAROutputSubDir"}
    if [file exists "$DirOutput/cmplx_coh_avg_Opt1.bin"] {
        set Opt1CohFile "$DirOutput/cmplx_coh_avg_Opt1.bin"
        } else {
        set Opt1CohFile "ENTER THE AVERAGED OPTIMAL-1 COHERENCE FILE NAME"
        }
    if [file exists "$DirOutput/cmplx_coh_avg_Opt2.bin"] {
        set Opt2CohFile "$DirOutput/cmplx_coh_avg_Opt2.bin"
        } else {
        set Opt2CohFile "ENTER THE AVERAGED OPTIMAL-2 COHERENCE FILE NAME"
        }
    if [file exists "$DirOutput/cmplx_coh_avg_Opt3.bin"] {
        set Opt3CohFile "$DirOutput/cmplx_coh_avg_Opt3.bin"
        } else {
        set Opt3CohFile "ENTER THE AVERAGED OPTIMAL-3 COHERENCE FILE NAME"
        }
    } else {
    set Opt1CohFile $Opt1CohFileTmp
    set Opt2CohFile $Opt2CohFileTmp
    set Opt3CohFile $Opt3CohFileTmp
    }} \
        -text {Averaged Complex Optimal Coherences} -variable OptCohAvg 
    vTcl:DefineAlias "$site_5_0.cpd76" "Checkbutton312_1" vTcl:WidgetProc "Toplevel312" 1
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 10 \
        -side right 
    frame $site_4_0.cpd78 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd78" "Frame12" vTcl:WidgetProc "Toplevel312" 1
    set site_5_0 $site_4_0.cpd78
    label $site_5_0.cpd109 \
        -text {  Optimal 1 File } 
    vTcl:DefineAlias "$site_5_0.cpd109" "Label312_1" vTcl:WidgetProc "Toplevel312" 1
    entry $site_5_0.cpd98 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable Opt1CohFile -width 40 
    vTcl:DefineAlias "$site_5_0.cpd98" "Entry312_1" vTcl:WidgetProc "Toplevel312" 1
    button $site_5_0.cpd100 \
        \
        -command {global FileName POLinSARMasterDirInput Opt1CohFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE INPUT FILE MUST HAVE THE SAME DATA"
set WarningMessage2 "SIZE AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$POLinSARMasterDirInput" $types "INPUT OPTIMAL-1 COHERENCE FILE"
if {$FileName != ""} {
    set Opt1CohFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd100" "Button312_1" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_5_0.cpd100 "$site_5_0.cpd100 Button $top all _vTclBalloon"
    bind $site_5_0.cpd100 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd109 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd98 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd100 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    frame $site_4_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame13" vTcl:WidgetProc "Toplevel312" 1
    set site_5_0 $site_4_0.cpd79
    label $site_5_0.cpd109 \
        -text {  Optimal 2 File } 
    vTcl:DefineAlias "$site_5_0.cpd109" "Label312_2" vTcl:WidgetProc "Toplevel312" 1
    entry $site_5_0.cpd98 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable Opt2CohFile -width 40 
    vTcl:DefineAlias "$site_5_0.cpd98" "Entry312_2" vTcl:WidgetProc "Toplevel312" 1
    button $site_5_0.cpd100 \
        \
        -command {global FileName POLinSARMasterDirInput Opt2CohFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE INPUT FILE MUST HAVE THE SAME DATA"
set WarningMessage2 "SIZE AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$POLinSARMasterDirInput" $types "INPUT OPTIMAL-2 COHERENCE FILE"
if {$FileName != ""} {
    set Opt2CohFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd100" "Button312_2" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_5_0.cpd100 "$site_5_0.cpd100 Button $top all _vTclBalloon"
    bind $site_5_0.cpd100 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd109 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd98 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd100 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    frame $site_4_0.cpd80 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd80" "Frame14" vTcl:WidgetProc "Toplevel312" 1
    set site_5_0 $site_4_0.cpd80
    label $site_5_0.cpd109 \
        -text {  Optimal 3 File } 
    vTcl:DefineAlias "$site_5_0.cpd109" "Label312_3" vTcl:WidgetProc "Toplevel312" 1
    entry $site_5_0.cpd98 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable Opt3CohFile -width 40 
    vTcl:DefineAlias "$site_5_0.cpd98" "Entry312_3" vTcl:WidgetProc "Toplevel312" 1
    button $site_5_0.cpd100 \
        \
        -command {global FileName POLinSARMasterDirInput Opt3CohFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE INPUT FILE MUST HAVE THE SAME DATA"
set WarningMessage2 "SIZE AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$POLinSARMasterDirInput" $types "INPUT OPTIMAL-3 COHERENCE FILE"
if {$FileName != ""} {
    set Opt3CohFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd100" "Button312_3" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_5_0.cpd100 "$site_5_0.cpd100 Button $top all _vTclBalloon"
    bind $site_5_0.cpd100 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd109 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd98 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd100 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    frame $site_4_0.cpd81 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd81" "Frame11" vTcl:WidgetProc "Toplevel312" 1
    set site_5_0 $site_4_0.cpd81
    label $site_5_0.cpd109 \
        -text {  ColorMap 9    } 
    vTcl:DefineAlias "$site_5_0.cpd109" "Label312_4" vTcl:WidgetProc "Toplevel312" 1
    entry $site_5_0.cpd98 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable OptCohColorMap -width 40 
    vTcl:DefineAlias "$site_5_0.cpd98" "Entry312_4" vTcl:WidgetProc "Toplevel312" 1
    button $site_5_0.cpd82 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_5_0.cpd82 {global OptCohColorMap VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette OpenDirFile
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient .top38 $PSPTopLevel
    }

set ColorMapNumber 9
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
WaitUntilCreated $OptCohColorMap
if [file exists $OptCohColorMap] {
    set f [open $OptCohColorMap r]
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
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur
   
.top38.fra35.but38 configure -state normal

set VarColorMap ""
set ColorMapIn $OptCohColorMap
set ColorMapOut $OptCohColorMap
WidgetShowFromWidget $widget(Toplevel312) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set OptCohColorMap $ColorMapOut
   }
}}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_5_0.cpd82" "Button312_5" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_5_0.cpd82 "$site_5_0.cpd82 Button $top all _vTclBalloon"
    bind $site_5_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    button $site_5_0.cpd100 \
        \
        -command {global FileName POLinSARMasterDirInput OptCohColorMap

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$POLinSARMasterDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set OptCohColorMap $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd100" "Button312_4" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_5_0.cpd100 "$site_5_0.cpd100 Button $top all _vTclBalloon"
    bind $site_5_0.cpd100 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd109 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd98 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 2 -side right 
    pack $site_5_0.cpd100 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 2 -side right 
    pack $site_4_0.fra73 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side bottom 
    TitleFrame $top.cpd73 \
        -ipad 0 \
        -text {Wishart  - Optimal Coherences Unsupervised Classification} 
    vTcl:DefineAlias "$top.cpd73" "TitleFrame3120" vTcl:WidgetProc "Toplevel312" 1
    bind $top.cpd73 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd73 getframe]
    frame $site_4_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd82" "Frame54" vTcl:WidgetProc "Toplevel312" 1
    set site_5_0 $site_4_0.cpd82
    checkbutton $site_5_0.cpd73 \
        \
        -command {global WishartFlag WishartPourcentage WishartIteration 
global WishartMaskType WishartMaskFile WishartOptCohClassFile
global ColorMap9 ColorMap27

set ColorMap9 ""
set ColorMap27 ""
set WishartPourcentage ""
set WishartIteration ""
set WishartMaskType ""
set WishartMaskFile ""
set WishartOptCohClassFile ""

if {$WishartFlag == 1} {
    set WishartPourcentage 10
    set WishartIteration 10
    $widget(Label312_5) configure -state normal
    $widget(Entry312_5) configure -state normal
    $widget(Entry312_5) configure -disabledbackground #FFFFFF
    $widget(Label312_6) configure -state normal
    $widget(Entry312_6) configure -state normal
    $widget(Entry312_6) configure -disabledbackground #FFFFFF
    $widget(Label312_5) configure -state normal
    $widget(Entry312_5) configure -state normal
    $widget(Entry312_5) configure -disabledbackground #FFFFFF
    $widget(Button312_1) configure -state normal
    $widget(Button312_2) configure -state normal
    $widget(TitleFrame312_1) configure -state normal
    $widget(Radiobutton312_1) configure -state normal
    $widget(Radiobutton312_2) configure -state normal
    $widget(Radiobutton312_3) configure -state normal
    $widget(Radiobutton312_4) configure -state normal
    $widget(Radiobutton312_5) configure -state normal
    $widget(Label312_7) configure -state normal
    $widget(Entry312_7) configure -disabledbackground #FFFFFF
    $widget(Button312_6) configure -state normal
    $widget(Label312_10) configure -state normal
    $widget(Entry312_10) configure -disabledbackground #FFFFFF
    $widget(Button312_11) configure -state normal
    if {$OptCohFlag == 1} { 
        set WishartOptCohClassFile "WILL BE SET AFTER RUNNING THE OPTIMAL COHERENCE SET SEGMENTATION PROCESS"
        } else {
        set WishartOptCohClassFile "ENTER THE OPTIMAL COHERENCE SET CLASS FILE NAME"
        }
    } else {
    $widget(Label312_5) configure -state disable
    $widget(Entry312_5) configure -state disable
    $widget(Entry312_5) configure -disabledbackground $PSPBackgroundColor
    $widget(Label312_6) configure -state disable
    $widget(Entry312_6) configure -state disable
    $widget(Entry312_6) configure -disabledbackground $PSPBackgroundColor
    $widget(TitleFrame312_1) configure -state disable
    $widget(Radiobutton312_1) configure -state disable
    $widget(Radiobutton312_2) configure -state disable
    $widget(Radiobutton312_3) configure -state disable
    $widget(Radiobutton312_4) configure -state disable
    $widget(Radiobutton312_5) configure -state disable
    $widget(Label312_7) configure -state disable
    $widget(Entry312_7) configure -disabledbackground $PSPBackgroundColor
    $widget(Button312_6) configure -state disable
    $widget(TitleFrame312_2) configure -state disable
    $widget(Label312_8) configure -state disable
    $widget(Entry312_8) configure -disabledbackground $PSPBackgroundColor
    $widget(Button312_7) configure -state disable
    $widget(Button312_8) configure -state disable
    $widget(Label312_9) configure -state disable
    $widget(Entry312_9) configure -disabledbackground $PSPBackgroundColor
    $widget(Button312_9) configure -state disable
    $widget(Button312_10) configure -state disable
    $widget(Label312_10) configure -state disable
    $widget(Entry312_10) configure -disabledbackground $PSPBackgroundColor
    $widget(Button312_11) configure -state disable
    }} \
        -variable WishartFlag 
    vTcl:DefineAlias "$site_5_0.cpd73" "Checkbutton313" vTcl:WidgetProc "Toplevel312" 1
    frame $site_5_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_5_0.fra39" "Frame52" vTcl:WidgetProc "Toplevel312" 1
    set site_6_0 $site_5_0.fra39
    label $site_6_0.lab33 \
        -padx 1 -text {% of Pixels Switching Class} 
    vTcl:DefineAlias "$site_6_0.lab33" "Label312_5" vTcl:WidgetProc "Toplevel312" 1
    entry $site_6_0.cpd84 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable WishartPourcentage -width 5 
    vTcl:DefineAlias "$site_6_0.cpd84" "Entry312_5" vTcl:WidgetProc "Toplevel312" 1
    pack $site_6_0.lab33 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    frame $site_5_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_5_0.fra40" "Frame55" vTcl:WidgetProc "Toplevel312" 1
    set site_6_0 $site_5_0.fra40
    label $site_6_0.cpd85 \
        -padx 1 -text {Maximum Number of Iterations} 
    vTcl:DefineAlias "$site_6_0.cpd85" "Label312_6" vTcl:WidgetProc "Toplevel312" 1
    entry $site_6_0.ent36 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable WishartIteration -width 5 
    vTcl:DefineAlias "$site_6_0.ent36" "Entry312_6" vTcl:WidgetProc "Toplevel312" 1
    pack $site_6_0.cpd85 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.ent36 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra39 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra40 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd74 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame19" vTcl:WidgetProc "Toplevel312" 1
    set site_5_0 $site_4_0.cpd74
    label $site_5_0.cpd109 \
        -text {  Opt Coh File  } 
    vTcl:DefineAlias "$site_5_0.cpd109" "Label312_10" vTcl:WidgetProc "Toplevel312" 1
    entry $site_5_0.cpd98 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable WishartOptCohClassFile -width 40 
    vTcl:DefineAlias "$site_5_0.cpd98" "Entry312_10" vTcl:WidgetProc "Toplevel312" 1
    button $site_5_0.cpd100 \
        \
        -command {global FileName POLinSARMasterDirInput WishartOptCohClassFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE INPUT FILE MUST HAVE THE SAME DATA"
set WarningMessage2 "SIZE AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$POLinSARMasterDirInput" $types "INPUT OPT-COH CLASS FILE"
if {$FileName != ""} {
    set WishartOptCohClassFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd100" "Button312_11" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_5_0.cpd100 "$site_5_0.cpd100 Button $top all _vTclBalloon"
    bind $site_5_0.cpd100 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd109 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd98 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd100 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.tit89 \
        -ipad 0 -text {Scattering Mechanism Mask} 
    vTcl:DefineAlias "$top.tit89" "TitleFrame312_1" vTcl:WidgetProc "Toplevel312" 1
    bind $top.tit89 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit89 getframe]
    frame $site_4_0.cpd91 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd91" "Frame7" vTcl:WidgetProc "Toplevel312" 1
    set site_5_0 $site_4_0.cpd91
    radiobutton $site_5_0.rad93 \
        \
        -command {global POLinSARMasterDirInput COLORMAPDir
global WishartMaskFile WishartMaskFileSgl
global ColorMap9 ColorMap27

set ColorMap9 "$COLORMAPDir/Sgl_ColorMap9.pal"
set ColorMap27 ""
$widget(TitleFrame312_2) configure -state normal
$widget(Label312_8) configure -state normal
$widget(Entry312_8) configure -disabledbackground #FFFFFF
$widget(Button312_7) configure -state normal
$widget(Button312_8) configure -state normal
$widget(Label312_9) configure -state disable
$widget(Entry312_9) configure -disabledbackground $PSPBackgroundColor
$widget(Button312_9) configure -state disable
$widget(Button312_10) configure -state disable
set config "true"
if {$WishartMaskFileSgl == "" } { set config "false" }
if {$WishartMaskFileSgl == "ENTER THE SINGLE BOUNCE MASK FILE NAME" } { set config "false" }
if {$config == "false" } {
    if [file exists "$POLinSARMasterDirInput/sgl_class.bin"] {
        set WishartMaskFile "$POLinSARMasterDirInput/sgl_class.bin"
        } else {
        set WishartMaskFile "ENTER THE SINGLE BOUNCE MASK FILE NAME"
        }
    } else {
    set WishartMaskFile $WishartMaskFileSgl
    }
set WishartMaskFileSgl $WishartMaskFile} \
        -text Single -value sgl -variable WishartMaskType 
    vTcl:DefineAlias "$site_5_0.rad93" "Radiobutton312_1" vTcl:WidgetProc "Toplevel312" 1
    radiobutton $site_5_0.cpd94 \
        \
        -command {global POLinSARMasterDirInput COLORMAPDir
global WishartMaskFile WishartMaskFileDbl
global ColorMap9 ColorMap27

set ColorMap9 "$COLORMAPDir/Dbl_ColorMap9.pal"
set ColorMap27 ""
$widget(TitleFrame312_2) configure -state normal
$widget(Label312_8) configure -state normal
$widget(Entry312_8) configure -disabledbackground #FFFFFF
$widget(Button312_7) configure -state normal
$widget(Button312_8) configure -state normal
$widget(Label312_9) configure -state disable
$widget(Entry312_9) configure -disabledbackground $PSPBackgroundColor
$widget(Button312_9) configure -state disable
$widget(Button312_10) configure -state disable
set config "true"
if {$WishartMaskFileDbl == "" } { set config "false" }
if {$WishartMaskFileDbl == "ENTER THE DOUBLE BOUNCE MASK FILE NAME" } { set config "false" }
if {$config == "false" } {
    if [file exists "$POLinSARMasterDirInput/dbl_class.bin"] {
        set WishartMaskFile "$POLinSARMasterDirInput/dbl_class.bin"
        } else {
        set WishartMaskFile "ENTER THE DOUBLE BOUNCE MASK FILE NAME"
        }
    } else {
    set WishartMaskFile $WishartMaskFileDbl
    }
set WishartMaskFileDbl $WishartMaskFile} \
        -text Double -value dbl -variable WishartMaskType 
    vTcl:DefineAlias "$site_5_0.cpd94" "Radiobutton312_2" vTcl:WidgetProc "Toplevel312" 1
    radiobutton $site_5_0.cpd95 \
        \
        -command {global POLinSARMasterDirInput COLORMAPDir
global WishartMaskFile WishartMaskFileVol
global ColorMap9 ColorMap27

set ColorMap9 "$COLORMAPDir/Vol_ColorMap9.pal"
set ColorMap27 ""
$widget(TitleFrame312_2) configure -state normal
$widget(Label312_8) configure -state normal
$widget(Entry312_8) configure -disabledbackground #FFFFFF
$widget(Button312_7) configure -state normal
$widget(Button312_8) configure -state normal
$widget(Label312_9) configure -state disable
$widget(Entry312_9) configure -disabledbackground $PSPBackgroundColor
$widget(Button312_9) configure -state disable
$widget(Button312_10) configure -state disable
set config "true"
if {$WishartMaskFileVol == "" } { set config "false" }
if {$WishartMaskFileVol == "ENTER THE FILE NAME" } { set config "false" }
if {$config == "false" } {
    if [file exists "$POLinSARMasterDirInput/vol_class.bin"] {
        set WishartMaskFile "$POLinSARMasterDirInput/vol_class.bin"
        } else {
        set WishartMaskFile "ENTER THE FILE NAME"
        }
    } else {
    set WishartMaskFile $WishartMaskFileVol
    }
set WishartMaskFileVol $WishartMaskFile} \
        -text Volume -value vol -variable WishartMaskType 
    vTcl:DefineAlias "$site_5_0.cpd95" "Radiobutton312_3" vTcl:WidgetProc "Toplevel312" 1
    radiobutton $site_5_0.cpd96 \
        \
        -command {global POLinSARMasterDirInput COLORMAPDir
global WishartMaskFile
global WishartRunSgl WishartRunDbl WishartRunVol WishartRunAll
global ColorMap9 ColorMap27

set ColorMap9 ""
set ColorMap27 "$COLORMAPDir/Dbl_Vol_Sgl_ColorMap27.pal"
$widget(TitleFrame312_2) configure -state normal
$widget(Label312_8) configure -state disable
$widget(Entry312_8) configure -disabledbackground $PSPBackgroundColor
$widget(Button312_7) configure -state disable
$widget(Button312_8) configure -state disable
$widget(Label312_9) configure -state normal
$widget(Entry312_9) configure -disabledbackground #FFFFFF 
$widget(Button312_9) configure -state normal
$widget(Button312_10) configure -state normal
set WishartRunAll "no"
set config ""
if {$WishartRunSgl == "no" } { append config "S" }
if {$WishartRunDbl == "no" } { append config "D" }
if {$WishartRunVol == "no" } { append config "V" }
if {$config == "" } {
    set WishartRunAll "ok"
    set WishartMaskFile "OK TO PROCESS ALL"
    } else {
    if {$config == "S" } { set WishartMaskFile "RUN FIRST : SINGLE" }
    if {$config == "D" } { set WishartMaskFile "RUN FIRST : DOUBLE" }
    if {$config == "V" } { set WishartMaskFile "RUN FIRST : VOLUME" }
    if {$config == "SD" } { set WishartMaskFile "RUN FIRST : SINGLE THEN DOUBLE" }
    if {$config == "SV" } { set WishartMaskFile "RUN FIRST : SINGLE THEN VOLUME" }
    if {$config == "DV" } { set WishartMaskFile "RUN FIRST : DOUBLE THEN VOLUME" }
    if {$config == "SDV" } { set WishartMaskFile "RUN FIRST : SINGLE, DOUBLE THEN VOLUME" }
    }} \
        -text {Merge All} -value all -variable WishartMaskType 
    vTcl:DefineAlias "$site_5_0.cpd96" "Radiobutton312_4" vTcl:WidgetProc "Toplevel312" 1
    radiobutton $site_5_0.cpd97 \
        \
        -command {global WishartMaskFile COLORMAPDir
global ColorMap9 ColorMap27

set ColorMap9 ""
set ColorMap27 "$COLORMAPDir/Random_ColorMap32.pal"
$widget(TitleFrame312_2) configure -state normal
$widget(Label312_8) configure -state disable
$widget(Entry312_8) configure -disabledbackground $PSPBackgroundColor
$widget(Button312_7) configure -state disable
$widget(Button312_8) configure -state disable
$widget(Label312_9) configure -state normal
$widget(Entry312_9) configure -disabledbackground #FFFFFF 
$widget(Button312_9) configure -state normal
$widget(Button312_10) configure -state normal
set WishartMaskFile "ENTER THE FILE NAME"} \
        -text Other -value other -variable WishartMaskType 
    vTcl:DefineAlias "$site_5_0.cpd97" "Radiobutton312_5" vTcl:WidgetProc "Toplevel312" 1
    pack $site_5_0.rad93 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd94 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd95 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd96 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd97 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd92 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame10" vTcl:WidgetProc "Toplevel312" 1
    set site_5_0 $site_4_0.cpd92
    label $site_5_0.cpd109 \
        -text {  Mask File      } 
    vTcl:DefineAlias "$site_5_0.cpd109" "Label312_7" vTcl:WidgetProc "Toplevel312" 1
    entry $site_5_0.cpd98 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable WishartMaskFile -width 40 
    vTcl:DefineAlias "$site_5_0.cpd98" "Entry312_7" vTcl:WidgetProc "Toplevel312" 1
    button $site_5_0.cpd100 \
        \
        -command {global FileName POLinSARMasterDirInput WishartMaskFile WishartMaskType
global WishartMaskFileSgl WishartMaskFileDbl WishartMaskFileVol
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE INPUT FILE MUST HAVE THE SAME DATA"
set WarningMessage2 "SIZE AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile "$POLinSARMasterDirInput" $types "INPUT MASK FILE"
if {$FileName != ""} {
    set WishartMaskFile $FileName
    }
if {$WishartMaskType == "sgl"} {set WishartMaskFileSgl $WishartMaskFile }
if {$WishartMaskType == "dbl"} {set WishartMaskFileDbl $WishartMaskFile }
if {$WishartMaskType == "vol"} {set WishartMaskFileVol $WishartMaskFile }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd100" "Button312_6" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_5_0.cpd100 "$site_5_0.cpd100 Button $top all _vTclBalloon"
    bind $site_5_0.cpd100 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd109 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd98 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd100 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_4_0.cpd91 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.tit84 \
        -ipad 0 -text {Color Maps} 
    vTcl:DefineAlias "$top.tit84" "TitleFrame312_2" vTcl:WidgetProc "Toplevel312" 1
    bind $top.tit84 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit84 getframe]
    frame $site_4_0.fra90 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra90" "Frame1" vTcl:WidgetProc "Toplevel312" 1
    set site_5_0 $site_4_0.fra90
    frame $site_5_0.fra91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra91" "Frame2" vTcl:WidgetProc "Toplevel312" 1
    set site_6_0 $site_5_0.fra91
    label $site_6_0.cpd78 \
        -text {ColorMap 9  } 
    vTcl:DefineAlias "$site_6_0.cpd78" "Label312_8" vTcl:WidgetProc "Toplevel312" 1
    label $site_6_0.cpd73 \
        -text {ColorMap 27} 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label312_9" vTcl:WidgetProc "Toplevel312" 1
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.fra92 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra92" "Frame3" vTcl:WidgetProc "Toplevel312" 1
    set site_6_0 $site_5_0.fra92
    button $site_6_0.cpd79 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_6_0.cpd79 {global ColorMap9 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette OpenDirFile
#BMP PROCESS
global Load_colormap PSPTopLevel
 
if {$OpenDirFile == 0} {

if {$Load_colormap == 0} {
    source "GUI/bmp_process/colormap.tcl"
    set Load_colormap 1
    WmTransient .top38 $PSPTopLevel
    }

set ColorMapNumber 9
set ColorNumber 256
for {set i 0} {$i < 256} {incr i} {
    set RedPalette($i) 1
    set GreenPalette($i) 1
    set BluePalette($i) 1
    }
WaitUntilCreated $ColorMap9
if [file exists $ColorMap9] {
    set f [open $ColorMap9 r]
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
 
set c1 .top38.fra35.but36
set couleur [format "#%02x%02x%02x" $RedPalette(1) $GreenPalette(1) $BluePalette(1)]    
$c1 configure -background $couleur
set c2 .top38.fra35.but37
set couleur [format "#%02x%02x%02x" $RedPalette(2) $GreenPalette(2) $BluePalette(2)]    
$c2 configure -background $couleur
set c3 .top38.fra35.but38
set couleur [format "#%02x%02x%02x" $RedPalette(3) $GreenPalette(3) $BluePalette(3)]    
$c3 configure -background $couleur
set c4 .top38.fra35.but39
set couleur [format "#%02x%02x%02x" $RedPalette(4) $GreenPalette(4) $BluePalette(4)]    
$c4 configure -background $couleur
set c5 .top38.fra35.but40
set couleur [format "#%02x%02x%02x" $RedPalette(5) $GreenPalette(5) $BluePalette(5)]    
$c5 configure -background $couleur
set c6 .top38.fra35.but41
set couleur [format "#%02x%02x%02x" $RedPalette(6) $GreenPalette(6) $BluePalette(6)]    
$c6 configure -background $couleur
set c7 .top38.fra35.but42
set couleur [format "#%02x%02x%02x" $RedPalette(7) $GreenPalette(7) $BluePalette(7)]    
$c7 configure -background $couleur
set c8 .top38.fra35.but43
set couleur [format "#%02x%02x%02x" $RedPalette(8) $GreenPalette(8) $BluePalette(8)]    
$c8 configure -background $couleur
set c9 .top38.fra35.but44
set couleur [format "#%02x%02x%02x" $RedPalette(9) $GreenPalette(9) $BluePalette(9)]    
$c9 configure -background $couleur
set c10 .top38.fra35.but45
set couleur [format "#%02x%02x%02x" $RedPalette(10) $GreenPalette(10) $BluePalette(10)]    
$c10 configure -background $couleur
set c11 .top38.fra35.but46
set couleur [format "#%02x%02x%02x" $RedPalette(11) $GreenPalette(11) $BluePalette(11)]    
$c11 configure -background $couleur
set c12 .top38.fra35.but47
set couleur [format "#%02x%02x%02x" $RedPalette(12) $GreenPalette(12) $BluePalette(12)]    
$c12 configure -background $couleur
set c13 .top38.fra35.but48
set couleur [format "#%02x%02x%02x" $RedPalette(13) $GreenPalette(13) $BluePalette(13)]    
$c13 configure -background $couleur
set c14 .top38.fra35.but49
set couleur [format "#%02x%02x%02x" $RedPalette(14) $GreenPalette(14) $BluePalette(14)]    
$c14 configure -background $couleur
set c15 .top38.fra35.but50
set couleur [format "#%02x%02x%02x" $RedPalette(15) $GreenPalette(15) $BluePalette(15)]    
$c15 configure -background $couleur
set c16 .top38.fra35.but51
set couleur [format "#%02x%02x%02x" $RedPalette(16) $GreenPalette(16) $BluePalette(16)]    
$c16 configure -background $couleur
   
.top38.fra35.but38 configure -state normal

set VarColorMap ""
set ColorMapIn $ColorMap9
set ColorMapOut $ColorMap9
WidgetShowFromWidget $widget(Toplevel312) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMap9 $ColorMapOut
   }
}}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd79" "Button312_8" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_6_0.cpd79 "$site_6_0.cpd79 Button $top all _vTclBalloon"
    bind $site_6_0.cpd79 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    button $site_6_0.cpd76 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_6_0.cpd76 {global ColorMap27 VarColorMap ColorMapIn ColorMapOut ColorNumber ColorMapNumber
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
WaitUntilCreated $ColorMap27
if [file exists $ColorMap27] {
    set f [open $ColorMap27 r]
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
set ColorMapIn $ColorMap27
set ColorMapOut $ColorMap27
WidgetShowFromWidget $widget(Toplevel312) $widget(Toplevel254); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMap27 $ColorMapOut
   }
}}] \
        -padx 4 -pady 2 -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd76" "Button312_10" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_6_0.cpd76 "$site_6_0.cpd76 Button $top all _vTclBalloon"
    bind $site_6_0.cpd76 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    pack $site_6_0.cpd79 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.cpd76 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd77" "Frame6" vTcl:WidgetProc "Toplevel312" 1
    set site_6_0 $site_5_0.cpd77
    button $site_6_0.cpd81 \
        \
        -command {global FileName POLinSARMasterDirInput ColorMap9

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$POLinSARMasterDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMap9 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd81" "Button312_7" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_6_0.cpd81 "$site_6_0.cpd81 Button $top all _vTclBalloon"
    bind $site_6_0.cpd81 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    button $site_6_0.cpd75 \
        \
        -command {global FileName POLinSARMasterDirInput ColorMap27

set types {
{{PAL Files}        {.pal}        }
}
set FileName ""
OpenFile "$POLinSARMasterDirInput" $types "INPUT COLORMAP FILE"
if {$FileName != ""} {
    set ColorMap27 $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd75" "Button312_9" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_6_0.cpd75 "$site_6_0.cpd75 Button $top all _vTclBalloon"
    bind $site_6_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd81 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side top 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 3 -side top 
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame5" vTcl:WidgetProc "Toplevel312" 1
    set site_6_0 $site_5_0.fra93
    entry $site_6_0.cpd80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMap9 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd80" "Entry312_8" vTcl:WidgetProc "Toplevel312" 1
    entry $site_6_0.cpd74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable ColorMap27 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd74" "Entry312_9" vTcl:WidgetProc "Toplevel312" 1
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra91 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side left 
    pack $site_5_0.fra92 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.fra90 \
        -in $site_4_0 -anchor center -expand 1 -fill both -side top 
    frame $top.fra42 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra42" "Frame20" vTcl:WidgetProc "Toplevel312" 1
    set site_3_0 $top.fra42
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global OpenDirFile POLinSARDirInput POLinSARDirOutput POLinSAROutputDir POLinSAROutputSubDir
global OptCohFlag OptCohAvg OptCohClassFile
global Opt1CohFile Opt2CohFile Opt3CohFile 
global WishartFlag WishartOptCohAvg WishartOptCohClassFile 
global WishartPourcentage WishartIteration WishartMaskType WishartMaskFile
global WishartRunSgl WishartRunDbl WishartRunVol WishartRunAll 
global WishartMaskFileSgl WishartMaskFileDbl WishartMaskFileVol
global WishartClassFileSgl WishartClassFileDbl WishartClassFileVol
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine
global OptCohColorMap ColorMap9 ColorMap27
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set config "false"
if {$OptCohFlag =="1"} { set config "true" }
if {$WishartFlag =="1"} { set config "true" }

if {"$config"=="true"} {

    set POLinSARDirOutput $POLinSAROutputDir
    if {$POLinSAROutputSubDir != ""} {append POLinSARDirOutput "/$POLinSAROutputSubDir"}

    #####################################################################
    #Create Directory
    set POLinSARDirOutput [PSPCreateDirectoryMask $POLinSARDirOutput $POLinSAROutputDir $POLinSARDirInput]
    #####################################################################       

if {"$VarWarning"=="ok"} {

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    TestVar 4
    if {$TestVarError == "ok"} {

        if {$OptCohFlag == "1"} {
            set TestVarName(0) "ColorMap9"; set TestVarType(0) "file"; set TestVarValue(0) $OptCohColorMap; set TestVarMin(0) ""; set TestVarMax(0) ""
            set TestVarName(1) "Optimal-1 Coherence File"; set TestVarType(1) "file"; set TestVarValue(1) $Opt1CohFile; set TestVarMin(1) ""; set TestVarMax(1) ""
            set TestVarName(2) "Optimal-2 Coherence File"; set TestVarType(2) "file"; set TestVarValue(2) $Opt2CohFile; set TestVarMin(2) ""; set TestVarMax(2) ""
            set TestVarName(3) "Optimal-3 Coherence File"; set TestVarType(3) "file"; set TestVarValue(3) $Opt3CohFile; set TestVarMin(3) ""; set TestVarMax(3) ""
            TestVar 4
            if {$TestVarError == "ok"} {
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]
                set Fonction "OPTIMAL COHERENCE SET SEGMENTATION"
                set Fonction2 "and the associated BMP files"
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/data_process_dual/opt_coh_classifier.exe" "k"
                #TextEditorRunTrace "Arguments: -id \x22$POLinSARMasterDirInput\x22 -od \x22$POLinSARDirOutput\x22 -ifc1 \x22$Opt1CohFile\x22 -ifc2 \x22$Opt2CohFile\x22 -ifc3 \x22$Opt3CohFile\x22 -col $OptCohColorMap -avg $OptCohAvg" "k"
                TextEditorRunTrace "Arguments: \x22$POLinSARMasterDirInput\x22 \x22$POLinSARDirOutput\x22 \x22$Opt1CohFile\x22 \x22$Opt2CohFile\x22 \x22$Opt3CohFile\x22 $OptCohColorMap $OptCohAvg" "k"
                #set f [ open "| Soft/data_process_dual/opt_coh_classifier.exe -id \x22$POLinSARMasterDirInput\x22 -od \x22$POLinSARDirOutput\x22 -ifc1 \x22$Opt1CohFile\x22 -ifc2 \x22$Opt2CohFile\x22 -ifc3 \x22$Opt3CohFile\x22 -col $OptCohColorMap -avg $OptCohAvg" r]
                set f [ open "| Soft/data_process_dual/opt_coh_classifier.exe \x22$POLinSARMasterDirInput\x22 \x22$POLinSARDirOutput\x22 \x22$Opt1CohFile\x22 \x22$Opt2CohFile\x22 \x22$Opt3CohFile\x22 $OptCohColorMap $OptCohAvg" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {$OptCohAvg == 0 } {
                   if [file exists "$POLinSARDirOutput/class_coh_opt.bin"] {EnviWriteConfigClassif "$POLinSARDirOutput/class_coh_opt.bin" $FinalNlig $FinalNcol 4 $OptCohColorMap 9}
                   } else {
                   if [file exists "$POLinSARDirOutput/class_coh_avg_opt.bin"] {EnviWriteConfigClassif "$POLinSARDirOutput/class_coh_avg_opt.bin" $FinalNlig $FinalNcol 4 $OptCohColorMap 9}
                   }
                if [file exists "$POLinSARDirOutput/A1.bin"] {EnviWriteConfig "$POLinSARDirOutput/A1.bin" $FinalNlig $FinalNcol 4}
                if [file exists "$POLinSARDirOutput/A2.bin"] {EnviWriteConfig "$POLinSARDirOutput/A2.bin" $FinalNlig $FinalNcol 4}
                set OptCohRun "ok"
                if {$OptCohAvg == 0 } { set OptCohClassFile "$POLinSARDirOutput/class_coh_opt.bin" }
                if {$OptCohAvg == 1 } { set OptCohClassFile "$POLinSARDirOutput/class_coh_avg_opt.bin" }
                if {$WishartFlag == "1"} { set WishartOptCohClassFile $OptCohClassFile;  set WishartOptCohAvg $OptCohAvg }
                #Switch Off OptCoh
                set OptCohFlag "0"; set OptCohAvg "0"
                $widget(Checkbutton312_1) configure -state disable
                $widget(Label312_1) configure -state disable
                $widget(Entry312_1) configure -disabledbackground $PSPBackgroundColor
                $widget(Button312_1) configure -state disable
                $widget(Label312_2) configure -state disable
                $widget(Entry312_2) configure -disabledbackground $PSPBackgroundColor
                $widget(Button312_2) configure -state disable
                $widget(Label312_3) configure -state disable
                $widget(Entry312_3) configure -disabledbackground $PSPBackgroundColor
                $widget(Button312_3) configure -state disable
                $widget(Label312_4) configure -state disable
                $widget(Entry312_4) configure -disabledbackground $PSPBackgroundColor
                $widget(Button312_4) configure -state disable
                $widget(Button312_5) configure -state disable
                set OptCohColorMap ""
                set Opt1CohFile ""; set Opt2CohFile ""; set Opt3CohFile ""                
                }
                #TestVar
            }
            # IdentFlag

        if {$WishartFlag == "1"} {
            set TestVarName(0) "Optimal Coherence Class File"; set TestVarType(0) "file"; set TestVarValue(0) $WishartOptCohClassFile; set TestVarMin(0) ""; set TestVarMax(0) ""
            set TestVarName(1) "Pourcentage"; set TestVarType(1) "float"; set TestVarValue(1) $WishartPourcentage; set TestVarMin(1) "0"; set TestVarMax(1) "100"
            set TestVarName(2) "Iteration"; set TestVarType(2) "int"; set TestVarValue(2) $WishartIteration; set TestVarMin(2) "1"; set TestVarMax(2) "100"
            set WishartColorMap $ColorMap9; set ColorMapNum 9
            if {$WishartMaskType == "all"} { set WishartColorMap $ColorMap27; set ColorMapNum 27 }
            if {$WishartMaskType == "other"} { set WishartColorMap $ColorMap27; set ColorMapNum 27 }
            set TestVarName(3) "ColorMap"; set TestVarType(3) "file"; set TestVarValue(3) $WishartColorMap; set TestVarMin(3) ""; set TestVarMax(3) ""
            if {$WishartMaskType != "all"} {
                set TestVarName(4) "Mask File"; set TestVarType(4) "file"; set TestVarValue(4) $WishartMaskFile; set TestVarMin(4) ""; set TestVarMax(4) ""
                TestVar 5
                } else {
                TestVar 4
                }

            if {$TestVarError == "ok"} {
                if {$WishartMaskType == "all"} {
                    if {$WishartRunAll == "ok"} {
                        set Fonction "Creation of all the Binary Data and BMP Files"
                        set Fonction2 "of the WISHART - OPTIMAL COHERENCES CLASSIFICATION"
                        set ProgressLine "0"
                        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                        update
                        TextEditorRunTrace "Process The Function Soft/data_process_dual/wishart_opt_coh_classifier_all.exe" "k"
                        TextEditorRunTrace "Arguments: -id \x22$POLinSARMasterDirInput\x22 -od \x22$POLinSARDirOutput\x22 -ms \x22$WishartMaskFileSgl\x22 -md \x22$WishartMaskFileDbl\x22 -mv \x22$WishartMaskFileVol\x22 -cs \x22$WishartClassFileSgl\x22 -cd \x22$WishartClassFileDbl\x22 -cv \x22$WishartClassFileVol\x22 -fnr $FinalNlig -fnc $FinalNcol -co27 $WishartColorMap -avg $WishartOptCohAvg" "k"
                        set f [ open "| Soft/data_process_dual/wishart_opt_coh_classifier_all.exe -id \x22$POLinSARMasterDirInput\x22 -od \x22$POLinSARDirOutput\x22 -ms \x22$WishartMaskFileSgl\x22 -md \x22$WishartMaskFileDbl\x22 -mv \x22$WishartMaskFileVol\x22 -cs \x22$WishartClassFileSgl\x22 -cd \x22$WishartClassFileDbl\x22 -cv \x22$WishartClassFileVol\x22 -fnr $FinalNlig -fnc $FinalNcol -co27 $WishartColorMap -avg $WishartOptCohAvg" r]
                        PsPprogressBar $f
                        TextEditorRunTrace "Check RunTime Errors" "r"
                        CheckRunTimeError
                        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                        set WishartClassFileAll "$POLinSARDirOutput/wishart_coh_opt_class.bin"
                        if {$WishartOptCohAvg == "1"} { set WishartClassFileAll "$POLinSARDirOutput/wishart_coh_avg_opt_class.bin" }
                        if [file exists $WishartClassFileAll] { EnviWriteConfigClassif $WishartClassFileAll $FinalNlig $FinalNcol 4 $WishartColorMap $ColorMapNum}
                        } else {
                        set VarError ""
                        set ErrorMessage "IMPOSSIBLE TO PROCESS ALL" 
                        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                        tkwait variable VarError
                        }
                    } else {
                    if {$WishartMaskType == "sgl"} { set WishartRunSgl "no"; set WishartClassFileSgl ""; set WishartTypeMask 1}
                    if {$WishartMaskType == "dbl"} { set WishartRunDbl "no"; set WishartClassFileDbl ""; set WishartTypeMask 2 }
                    if {$WishartMaskType == "vol"} { set WishartRunVol "no"; set WishartClassFileVol ""; set WishartTypeMask 3 }
                    if {$WishartMaskType == "other"} { set WishartRunSgl "no"; set WishartClassFileSgl ""; set WishartRunDbl "no"; set WishartClassFileDbl "";
                                                       set WishartRunVol "no"; set WishartClassFileVol ""; set WishartTypeMask 0 }
                    set Fonction "Creation of all the Binary Data and BMP Files"
                    set Fonction2 "of the WISHART - OPTIMAL COHERENCES CLASSIFICATION"
                    set ProgressLine "0"
                    WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                    update
                    TextEditorRunTrace "Process The Function Soft/data_process_dual/wishart_opt_coh_classifier.exe" "k"
                    if {$POLinSAROutputSubDir == ""} {
                        TextEditorRunTrace "Arguments: -idm \x22$POLinSARMasterDirInput\x22 -ids \x22$POLinSARSlaveDirInput\x22 -od \x22$POLinSARDirOutput\x22 -iodf S2T6 -msk \x22$WishartMaskFile\x22 -cls \x22$WishartOptCohClassFile\x22 -fnr $FinalNlig -fnc $FinalNcol -nit $WishartIteration -pct $WishartPourcentage -col $WishartColorMap -mt $WishartTypeMask -avg $WishartOptCohAvg" "k"
                        set f [ open "| Soft/data_process_dual/wishart_opt_coh_classifier.exe -idm \x22$POLinSARMasterDirInput\x22 -ids \x22$POLinSARSlaveDirInput\x22 -od \x22$POLinSARDirOutput\x22 -iodf S2T6 -msk \x22$WishartMaskFile\x22 -cls \x22$WishartOptCohClassFile\x22 -fnr $FinalNlig -fnc $FinalNcol -nit $WishartIteration -pct $WishartPourcentage -col $WishartColorMap -mt $WishartTypeMask -avg $WishartOptCohAvg" r]
                         }
                    if {$POLinSAROutputSubDir == "T6"} {
                        TextEditorRunTrace "Arguments: -id \x22$POLinSARMasterDirInput\x22 -od \x22$POLinSARDirOutput\x22 -iodf T6 -msk \x22$WishartMaskFile\x22 -cls \x22$WishartOptCohClassFile\x22 -fnr $FinalNlig -fnc $FinalNcol -nit $WishartIteration -pct $WishartPourcentage -col $WishartColorMap -mt $WishartTypeMask -avg $WishartOptCohAvg" "k"
                        set f [ open "| Soft/data_process_dual/wishart_opt_coh_classifier.exe -id \x22$POLinSARMasterDirInput\x22 -od \x22$POLinSARDirOutput\x22 -iodf T6 -msk \x22$WishartMaskFile\x22 -cls \x22$WishartOptCohClassFile\x22 -fnr $FinalNlig -fnc $FinalNcol -nit $WishartIteration -pct $WishartPourcentage -col $WishartColorMap -mt $WishartTypeMask -avg $WishartOptCohAvg" r]
                        }
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError
                    WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
    
                    if {$WishartMaskType == "sgl"} {
                        set WishartClassFileSgl "$POLinSARDirOutput/wishart_coh_opt_sgl_class.bin"
                        if {$WishartOptCohAvg == "1"} { set WishartClassFileSgl "$POLinSARDirOutput/wishart_coh_avg_opt_sgl_class.bin" }
                        if [file exists $WishartClassFileSgl] {set WishartRunSgl "ok"; EnviWriteConfigClassif $WishartClassFileSgl $FinalNlig $FinalNcol 4 $WishartColorMap $ColorMapNum}
                        }
                    if {$WishartMaskType == "dbl"} {
                        set WishartClassFileDbl "$POLinSARDirOutput/wishart_coh_opt_dbl_class.bin"
                        if {$WishartOptCohAvg == "1"} { set WishartClassFileDbl "$POLinSARDirOutput/wishart_coh_avg_opt_dbl_class.bin" }
                        if [file exists $WishartClassFileDbl] {set WishartRunDbl "ok"; EnviWriteConfigClassif $WishartClassFileDbl $FinalNlig $FinalNcol 4 $WishartColorMap $ColorMapNum}
                        }
                    if {$WishartMaskType == "vol"} {
                        set WishartClassFileVol "$POLinSARDirOutput/wishart_coh_opt_vol_class.bin"
                        if {$WishartOptCohAvg == "1"} { set WishartClassFileVol "$POLinSARDirOutput/wishart_coh_avg_opt_vol_class.bin" }
                        if [file exists $WishartClassFileVol] {set WishartRunVol "ok"; EnviWriteConfigClassif $WishartClassFileVol $FinalNlig $FinalNcol 4 $WishartColorMap $ColorMapNum}
                        }
                    if {$WishartMaskType == "other"} {
                        set WishartClassFileOther "$POLinSARDirOutput/wishart_coh_opt_xxx_class.bin"
                        if {$WishartOptCohAvg == "1"} { set WishartClassFileOther "$POLinSARDirOutput/wishart_coh_avg_opt_xxx_class.bin" }
                        if [file exists $WishartClassFileOther] {EnviWriteConfigClassif $WishartClassFileOther $FinalNlig $FinalNcol 4 $WishartColorMap $ColorMapNum}
                        }
                    }
                }
                #TestVar
            }
            # WishartFlag
        }
        #TestVar
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel312); TextEditorRunTrace "Close Window POLinSAR - Unsupervised Classification" "b"}
        } 
    }
    # config
}
# opendirfile} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/POLinSARUnsupervisedClassification.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel312" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel312); TextEditorRunTrace "Close Window POLinSAR - Unsupervised Classification" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel312" 1
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
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill both -side top 
    pack $top.cpd73 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit89 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit84 \
        -in $top -anchor center -expand 0 -fill x -side top 
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
Window show .top312

main $argc $argv
