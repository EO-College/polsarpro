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
    set base .top209
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd77
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
    namespace eval ::widgets::$site_5_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd77
    namespace eval ::widgets::$site_6_0.lab78 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd80 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd78 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra88 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra88
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
    namespace eval ::widgets::$base.fra71 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra71
    namespace eval ::widgets::$site_3_0.tit72 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.tit72 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd75 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.rad28 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd79
    namespace eval ::widgets::$site_8_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.rad28 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd80 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd80
    namespace eval ::widgets::$site_8_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.rad28 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd81 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd81
    namespace eval ::widgets::$site_8_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.rad28 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd82 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd84 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd79
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd85 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd83 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd71 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd81 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd81
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd71 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd79
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd72 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd80 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd80
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd72 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd72
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd73
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd74 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd74
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd75
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd77 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd77
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd74 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd74 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd75 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.rad28 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd79
    namespace eval ::widgets::$site_8_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.rad28 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd80 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd80
    namespace eval ::widgets::$site_8_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.rad28 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd81 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd81
    namespace eval ::widgets::$site_8_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.rad28 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd82 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd82 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd84 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd79
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd85 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd83 {
        array set save {-ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd83 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd71 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd81 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd81
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd72 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd79 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd79
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd72 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd80 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd80
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd73 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd73
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd78 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd78
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd85 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd85
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd83 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd83
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd84 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd84
    namespace eval ::widgets::$site_8_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd73 {
        array set save {-command 1 -padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra77
    namespace eval ::widgets::$site_3_0.fra79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra79
    namespace eval ::widgets::$site_4_0.lab80 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent81 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd69
    namespace eval ::widgets::$site_4_0.lab80 {
        array set save {-text 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.ent81 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd82 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra94 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra94
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
            vTclWindow.top209
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

proc vTclWindow.top209 {base} {
    if {$base == ""} {
        set base .top209
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
    wm geometry $top 500x620+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Stokes Parameters"
    vTcl:DefineAlias "$top" "Toplevel209" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd77" "Frame4" vTcl:WidgetProc "Toplevel209" 1
    set site_3_0 $top.cpd77
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel209" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable StkDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel209" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel209" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button40" vTcl:WidgetProc "Toplevel209" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel209" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable StkOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel209" 1
    frame $site_5_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd77" "Frame5" vTcl:WidgetProc "Toplevel209" 1
    set site_6_0 $site_5_0.cpd77
    label $site_6_0.lab78 \
        -text / 
    vTcl:DefineAlias "$site_6_0.lab78" "Label2" vTcl:WidgetProc "Toplevel209" 1
    entry $site_6_0.cpd80 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable StkOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd80" "Entry2" vTcl:WidgetProc "Toplevel209" 1
    pack $site_6_0.lab78 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd80 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel209" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd78 \
        \
        -command {global DirName DataDir StkOutputDir

set StkDirOutputTmp $StkOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set StkOutputDir $DirName
    } else {
    set StkOutputDir $StkDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd78 "$site_6_0.cpd78 Button $top all _vTclBalloon"
    bind $site_6_0.cpd78 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd78 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd77 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra88 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra88" "Frame9" vTcl:WidgetProc "Toplevel209" 1
    set site_3_0 $top.fra88
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel209" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel209" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel209" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel209" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel209" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel209" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel209" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel209" 1
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
    frame $top.fra71 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame1" vTcl:WidgetProc "Toplevel209" 1
    set site_3_0 $top.fra71
    TitleFrame $site_3_0.tit72 \
        -text {Jones Vector (s11 / s21)} 
    vTcl:DefineAlias "$site_3_0.tit72" "TitleFrame1" vTcl:WidgetProc "Toplevel209" 1
    bind $site_3_0.tit72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit72 getframe]
    TitleFrame $site_5_0.cpd75 \
        -ipad 2 -text {Stokes Components} 
    vTcl:DefineAlias "$site_5_0.cpd75" "TitleFrame3" vTcl:WidgetProc "Toplevel209" 1
    bind $site_5_0.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd75 getframe]
    frame $site_7_0.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame430" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd76
    radiobutton $site_8_0.rad48 \
        -command {$widget(Checkbutton209_1) configure -state normal} -padx 1 \
        -text g0 -value 1 -variable StkG0v1 
    vTcl:DefineAlias "$site_8_0.rad48" "Radiobutton209_1" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkG0v1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_1" vTcl:WidgetProc "Toplevel209" 1
    radiobutton $site_8_0.rad28 \
        -command {$widget(Checkbutton209_1) configure -state normal} -padx 1 \
        -text {g0 (dB)} -value 2 -variable StkG0v1 
    vTcl:DefineAlias "$site_8_0.rad28" "Radiobutton209_2" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.rad48 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.rad28 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd79" "Frame431" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd79
    radiobutton $site_8_0.rad48 \
        -command {$widget(Checkbutton209_2) configure -state normal} -padx 1 \
        -text g1 -value 1 -variable StkG1v1 
    vTcl:DefineAlias "$site_8_0.rad48" "Radiobutton209_3" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkG1v1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_2" vTcl:WidgetProc "Toplevel209" 1
    radiobutton $site_8_0.rad28 \
        -command {$widget(Checkbutton209_2) configure -state normal} -padx 1 \
        -text {g1 (dB)} -value 2 -variable StkG1v1 
    vTcl:DefineAlias "$site_8_0.rad28" "Radiobutton209_4" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.rad48 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.rad28 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd80 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd80" "Frame432" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd80
    radiobutton $site_8_0.rad48 \
        -command {$widget(Checkbutton209_3) configure -state normal} -padx 1 \
        -text g2 -value 1 -variable StkG2v1 
    vTcl:DefineAlias "$site_8_0.rad48" "Radiobutton209_5" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkG2v1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_3" vTcl:WidgetProc "Toplevel209" 1
    radiobutton $site_8_0.rad28 \
        -command {$widget(Checkbutton209_3) configure -state normal} -padx 1 \
        -text {g2 (dB)} -value 2 -variable StkG2v1 
    vTcl:DefineAlias "$site_8_0.rad28" "Radiobutton209_6" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.rad48 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.rad28 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd81 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd81" "Frame433" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd81
    radiobutton $site_8_0.rad48 \
        -command {$widget(Checkbutton209_4) configure -state normal} -padx 1 \
        -text g3 -value 1 -variable StkG3v1 
    vTcl:DefineAlias "$site_8_0.rad48" "Radiobutton209_7" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkG3v1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_4" vTcl:WidgetProc "Toplevel209" 1
    radiobutton $site_8_0.rad28 \
        -command {$widget(Checkbutton209_4) configure -state normal} -padx 1 \
        -text {g3 (dB)} -value 2 -variable StkG3v1 
    vTcl:DefineAlias "$site_8_0.rad28" "Radiobutton209_8" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.rad48 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.rad28 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd80 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd81 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $site_5_0.cpd82 \
        -ipad 2 -text {Stokes Angles} 
    vTcl:DefineAlias "$site_5_0.cpd82" "TitleFrame4" vTcl:WidgetProc "Toplevel209" 1
    bind $site_5_0.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd82 getframe]
    frame $site_7_0.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame435" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd76
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkPhiv1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_6" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd84 \
        \
        -command {global BMPStkPhiv1 StkPhiv1
if {$StkPhiv1 == 1} {
    $widget(Checkbutton209_6) configure -state normal
    } else {
    $widget(Checkbutton209_6) configure -state disable
    set BMPStkPhiv1 0
    }} \
        -padx 1 -text {Orientation Angle} -variable StkPhiv1 
    vTcl:DefineAlias "$site_8_0.cpd84" "Checkbutton209_5" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor ne -expand 0 -fill none -side right 
    pack $site_8_0.cpd84 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd79" "Frame436" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd79
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkTauv1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_8" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd85 \
        \
        -command {global BMPStkTauv1 StkTauv1
if {$StkTauv1 == 1} {
    $widget(Checkbutton209_8) configure -state normal
    } else {
    $widget(Checkbutton209_8) configure -state disable
    set BMPStkTauv1 0
    }} \
        -padx 1 -text {Ellipticity Angle} -variable StkTauv1 
    vTcl:DefineAlias "$site_8_0.cpd85" "Checkbutton209_7" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd85 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $site_5_0.cpd83 \
        -ipad 2 -text {Wave Descriptors} 
    vTcl:DefineAlias "$site_5_0.cpd83" "TitleFrame5" vTcl:WidgetProc "Toplevel209" 1
    bind $site_5_0.cpd83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd83 getframe]
    frame $site_7_0.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame437" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd76
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkEigv1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_10" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd71 \
        \
        -command {global BMPStkEigv1 StkEigv1
if {$StkEigv1 == 1} {
    $widget(Checkbutton209_10) configure -state normal
    } else {
    $widget(Checkbutton209_10) configure -state disable
    set BMPStkEigv1 0
    }} \
        -padx 1 -text {Eigenvalues ( l1, l2 )} -variable StkEigv1 
    vTcl:DefineAlias "$site_8_0.cpd71" "Checkbutton209_9" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd71 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd81 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd81" "Frame440" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd81
    checkbutton $site_8_0.che51 \
        \
        -command {global BMPStkProbv1 StkProbv1
if {$StkProbv1 == 1} {
    $widget(Checkbutton209_18) configure -state normal
    } else {
    $widget(Checkbutton209_18) configure -state disable
    set BMPStkProbv1 0
    }} \
        -padx 1 -text {Probabilities ( p1, p2 )} -variable StkProbv1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_17" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd71 \
        -padx 1 -text BMP -variable BMPStkProbv1 
    vTcl:DefineAlias "$site_8_0.cpd71" "Checkbutton209_18" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd71 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    frame $site_7_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd79" "Frame438" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd79
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkHv1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_12" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd72 \
        \
        -command {global BMPStkHv1 StkHv1
if {$StkHv1 == 1} {
    $widget(Checkbutton209_12) configure -state normal
    } else {
    $widget(Checkbutton209_12) configure -state disable
    set BMPStkHv1 0
    }} \
        -padx 1 -text {Entropy (H)} -variable StkHv1 
    vTcl:DefineAlias "$site_8_0.cpd72" "Checkbutton209_11" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd72 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd80 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd80" "Frame439" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd80
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkAv1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_14" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkAv1 StkAv1
if {$StkAv1 == 1} {
    $widget(Checkbutton209_14) configure -state normal
    } else {
    $widget(Checkbutton209_14) configure -state disable
    set BMPStkAv1 0
    }} \
        -padx 1 -text {Anisotropy (A <-> DoP)} -variable StkAv1 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_13" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd72 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd72" "Frame451" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd72
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkCv1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_16" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkCv1 StkCv1
if {$StkCv1 == 1} {
    $widget(Checkbutton209_16) configure -state normal
    } else {
    $widget(Checkbutton209_16) configure -state disable
    set BMPStkCv1 0
    }} \
        -padx 1 -text {Contrast ( g1 / g0)} -variable StkCv1 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_15" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd73 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd73" "Frame453" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd73
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkDoLP1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_42" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkDoLP1 StkDoLP1
if {$StkDoLP1 == 1} {
    $widget(Checkbutton209_42) configure -state normal
    } else {
    $widget(Checkbutton209_42) configure -state disable
    set BMPStkDoLP1 0
    }} \
        -padx 1 -text {Deg of Lin Polar (DoLP)} -variable StkDoLP1 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_41" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd74 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd74" "Frame454" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd74
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkDoCP1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_44" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkDoCP1 StkDoCP1
if {$StkDoCP1 == 1} {
    $widget(Checkbutton209_44) configure -state normal
    } else {
    $widget(Checkbutton209_44) configure -state disable
    set BMPStkDoCP1 0
    }} \
        -padx 1 -text {Deg of Cir Polar (DoCP)} -variable StkDoCP1 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_43" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd75" "Frame455" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd75
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkLPR1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_46" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkLPR1 StkLPR1
if {$StkLPR1 == 1} {
    $widget(Checkbutton209_46) configure -state normal
    } else {
    $widget(Checkbutton209_46) configure -state disable
    set BMPStkLPR1 0
    }} \
        -padx 1 -text {Lin Polar Ratio (LPR)} -variable StkLPR1 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_45" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd77 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd77" "Frame456" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd77
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkCPR1 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_48" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkCPR1 StkCPR1
if {$StkCPR1 == 1} {
    $widget(Checkbutton209_48) configure -state normal
    } else {
    $widget(Checkbutton209_48) configure -state disable
    set BMPStkCPR1 0
    }} \
        -padx 1 -text {Cir Polar Ratio (CPR)} -variable StkCPR1 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_47" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd81 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd80 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd72 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd74 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd75 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd77 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $site_3_0.cpd74 \
        -text {Jones Vector (s12 / s22)} 
    vTcl:DefineAlias "$site_3_0.cpd74" "TitleFrame2" vTcl:WidgetProc "Toplevel209" 1
    bind $site_3_0.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd74 getframe]
    TitleFrame $site_5_0.cpd75 \
        -ipad 2 -text {Stokes Components} 
    vTcl:DefineAlias "$site_5_0.cpd75" "TitleFrame6" vTcl:WidgetProc "Toplevel209" 1
    bind $site_5_0.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd75 getframe]
    frame $site_7_0.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame441" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd76
    radiobutton $site_8_0.rad48 \
        -command {$widget(Checkbutton209_21) configure -state normal} -padx 1 \
        -text g0 -value 1 -variable StkG0v2 
    vTcl:DefineAlias "$site_8_0.rad48" "Radiobutton209_10" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkG0v2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_21" vTcl:WidgetProc "Toplevel209" 1
    radiobutton $site_8_0.rad28 \
        -command {$widget(Checkbutton209_21) configure -state normal} -padx 1 \
        -text {g0 (dB)} -value 2 -variable StkG0v2 
    vTcl:DefineAlias "$site_8_0.rad28" "Radiobutton209_11" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.rad48 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.rad28 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd79" "Frame442" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd79
    radiobutton $site_8_0.rad48 \
        -command {$widget(Checkbutton209_22) configure -state normal} -padx 1 \
        -text g1 -value 1 -variable StkG1v2 
    vTcl:DefineAlias "$site_8_0.rad48" "Radiobutton209_12" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkG1v2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_22" vTcl:WidgetProc "Toplevel209" 1
    radiobutton $site_8_0.rad28 \
        -command {$widget(Checkbutton209_22) configure -state normal} -padx 1 \
        -text {g1 (dB)} -value 2 -variable StkG1v2 
    vTcl:DefineAlias "$site_8_0.rad28" "Radiobutton209_13" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.rad48 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.rad28 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd80 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd80" "Frame443" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd80
    radiobutton $site_8_0.rad48 \
        -command {$widget(Checkbutton209_23) configure -state normal} -padx 1 \
        -text g2 -value 1 -variable StkG2v2 
    vTcl:DefineAlias "$site_8_0.rad48" "Radiobutton209_14" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkG2v2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_23" vTcl:WidgetProc "Toplevel209" 1
    radiobutton $site_8_0.rad28 \
        -command {$widget(Checkbutton209_23) configure -state normal} -padx 1 \
        -text {g2 (dB)} -value 2 -variable StkG2v2 
    vTcl:DefineAlias "$site_8_0.rad28" "Radiobutton209_15" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.rad48 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.rad28 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd81 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd81" "Frame444" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd81
    radiobutton $site_8_0.rad48 \
        -command {$widget(Checkbutton209_24) configure -state normal} -padx 1 \
        -text g3 -value 1 -variable StkG3v2 
    vTcl:DefineAlias "$site_8_0.rad48" "Radiobutton209_16" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkG3v2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_24" vTcl:WidgetProc "Toplevel209" 1
    radiobutton $site_8_0.rad28 \
        -command {$widget(Checkbutton209_24) configure -state normal} -padx 1 \
        -text {g3 (dB)} -value 2 -variable StkG3v2 
    vTcl:DefineAlias "$site_8_0.rad28" "Radiobutton209_17" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.rad48 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.rad28 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd80 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd81 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $site_5_0.cpd82 \
        -ipad 2 -text {Stokes Angles} 
    vTcl:DefineAlias "$site_5_0.cpd82" "TitleFrame7" vTcl:WidgetProc "Toplevel209" 1
    bind $site_5_0.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd82 getframe]
    frame $site_7_0.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame445" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd76
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkPhiv2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_26" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd84 \
        \
        -command {global BMPStkPhiv2 StkPhiv2
if {$StkPhiv2 == 1} {
    $widget(Checkbutton209_26) configure -state normal
    } else {
    $widget(Checkbutton209_26) configure -state disable
    set BMPStkPhiv2 0
    }} \
        -padx 1 -text {Orientation Angle} -variable StkPhiv2 
    vTcl:DefineAlias "$site_8_0.cpd84" "Checkbutton209_25" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor ne -expand 0 -fill none -side right 
    pack $site_8_0.cpd84 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd79" "Frame446" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd79
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkTauv2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_28" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd85 \
        \
        -command {global BMPStkTauv2 StkTauv2
if {$StkTauv2 == 1} {
    $widget(Checkbutton209_28) configure -state normal
    } else {
    $widget(Checkbutton209_28) configure -state disable
    set BMPStkTauv2 0
    }} \
        -padx 1 -text {Ellipticity Angle} -variable StkTauv2 
    vTcl:DefineAlias "$site_8_0.cpd85" "Checkbutton209_27" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd85 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $site_5_0.cpd83 \
        -ipad 2 -text {Wave Descriptors} 
    vTcl:DefineAlias "$site_5_0.cpd83" "TitleFrame10" vTcl:WidgetProc "Toplevel209" 1
    bind $site_5_0.cpd83 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd83 getframe]
    frame $site_7_0.cpd76 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame447" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd76
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkEigv2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_30" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd71 \
        \
        -command {global BMPStkEigv2 StkEigv2
if {$StkEigv2 == 1} {
    $widget(Checkbutton209_30) configure -state normal
    } else {
    $widget(Checkbutton209_30) configure -state disable
    set BMPStkEigv2 0
    }} \
        -padx 1 -text {Eigenvalues ( l1, l2 )} -variable StkEigv2 
    vTcl:DefineAlias "$site_8_0.cpd71" "Checkbutton209_29" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd71 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd81 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd81" "Frame450" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd81
    checkbutton $site_8_0.che51 \
        \
        -command {global BMPStkProbv2 StkProbv2
if {$StkProbv2 == 1} {
    $widget(Checkbutton209_38) configure -state normal
    } else {
    $widget(Checkbutton209_38) configure -state disable
    set BMPStkProbv1 0
    }} \
        -padx 1 -text {Probabilities ( p1, p2 )} -variable StkProbv2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_37" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd72 \
        -padx 1 -text BMP -variable BMPStkProbv2 
    vTcl:DefineAlias "$site_8_0.cpd72" "Checkbutton209_38" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd72 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    frame $site_7_0.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd79" "Frame448" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd79
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkHv2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_32" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd72 \
        \
        -command {global BMPStkHv2 StkHv2
if {$StkHv2 == 1} {
    $widget(Checkbutton209_32) configure -state normal
    } else {
    $widget(Checkbutton209_32) configure -state disable
    set BMPStkHv2 0
    }} \
        -padx 1 -text {Entropy (H)} -variable StkHv2 
    vTcl:DefineAlias "$site_8_0.cpd72" "Checkbutton209_31" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd72 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd80 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd80" "Frame449" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd80
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkAv2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_34" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkAv2 StkAv2
if {$StkAv2 == 1} {
    $widget(Checkbutton209_34) configure -state normal
    } else {
    $widget(Checkbutton209_34) configure -state disable
    set BMPStkAv2 0
    }} \
        -padx 1 -text {Anisotropy (A <-> DoP)} -variable StkAv2 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_33" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd73 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd73" "Frame452" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd73
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkCv2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_36" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkCv2 StkCv2
if {$StkCv2 == 1} {
    $widget(Checkbutton209_36) configure -state normal
    } else {
    $widget(Checkbutton209_36) configure -state disable
    set BMPStkCv2 0
    }} \
        -padx 1 -text {Contrast ( g1 / g0)} -variable StkCv2 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_35" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd78 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd78" "Frame457" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd78
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkDoLP2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_52" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkDoLP2 StkDoLP2
if {$StkDoLP2 == 1} {
    $widget(Checkbutton209_52) configure -state normal
    } else {
    $widget(Checkbutton209_52) configure -state disable
    set BMPStkDoLP2 0
    }} \
        -padx 1 -text {Deg of Lin Polar (DoLP)} -variable StkDoLP2 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_51" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd85 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd85" "Frame458" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd85
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkDoCP2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_54" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkDoCP2 StkDoCP2
if {$StkDoCP2 == 1} {
    $widget(Checkbutton209_54) configure -state normal
    } else {
    $widget(Checkbutton209_54) configure -state disable
    set BMPStkDoCP2 0
    }} \
        -padx 1 -text {Deg of Cir Polar (DoCP)} -variable StkDoCP2 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_53" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd83 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd83" "Frame459" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd83
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkLPR2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_56" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkLPR2 StkLPR2
if {$StkLPR2 == 1} {
    $widget(Checkbutton209_56) configure -state normal
    } else {
    $widget(Checkbutton209_56) configure -state disable
    set BMPStkLPR2 0
    }} \
        -padx 1 -text {Lin Polar Ratio (LPR)} -variable StkLPR2 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_55" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.cpd84 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd84" "Frame460" vTcl:WidgetProc "Toplevel209" 1
    set site_8_0 $site_7_0.cpd84
    checkbutton $site_8_0.che51 \
        -padx 1 -text BMP -variable BMPStkCPR2 
    vTcl:DefineAlias "$site_8_0.che51" "Checkbutton209_58" vTcl:WidgetProc "Toplevel209" 1
    checkbutton $site_8_0.cpd73 \
        \
        -command {global BMPStkCPR2 StkCPR2
if {$StkCPR2 == 1} {
    $widget(Checkbutton209_58) configure -state normal
    } else {
    $widget(Checkbutton209_58) configure -state disable
    set BMPStkCPR2 0
    }} \
        -padx 1 -text {Cir Polar Ratio (CPR)} -variable StkCPR2 
    vTcl:DefineAlias "$site_8_0.cpd73" "Checkbutton209_57" vTcl:WidgetProc "Toplevel209" 1
    pack $site_8_0.che51 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side right 
    pack $site_8_0.cpd73 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd81 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd79 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd80 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd73 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd78 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd85 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd83 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_7_0.cpd84 \
        -in $site_7_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd82 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.cpd83 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    pack $site_3_0.tit72 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd74 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side left 
    frame $top.fra77 \
        -borderwidth 2 -height 75 -width 225 
    vTcl:DefineAlias "$top.fra77" "Frame2" vTcl:WidgetProc "Toplevel209" 1
    set site_3_0 $top.fra77
    frame $site_3_0.fra79 \
        -borderwidth 2 -height 75 -width 225 
    vTcl:DefineAlias "$site_3_0.fra79" "Frame3" vTcl:WidgetProc "Toplevel209" 1
    set site_4_0 $site_3_0.fra79
    label $site_4_0.lab80 \
        -text {Window Size Row} -width 15 
    vTcl:DefineAlias "$site_4_0.lab80" "Label1" vTcl:WidgetProc "Toplevel209" 1
    entry $site_4_0.ent81 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NwinStkL -width 5 
    vTcl:DefineAlias "$site_4_0.ent81" "Entry1" vTcl:WidgetProc "Toplevel209" 1
    pack $site_4_0.lab80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd69 \
        -borderwidth 2 -height 75 -width 225 
    vTcl:DefineAlias "$site_3_0.cpd69" "Frame6" vTcl:WidgetProc "Toplevel209" 1
    set site_4_0 $site_3_0.cpd69
    label $site_4_0.lab80 \
        -text {Window Size Col} -width 15 
    vTcl:DefineAlias "$site_4_0.lab80" "Label3" vTcl:WidgetProc "Toplevel209" 1
    entry $site_4_0.ent81 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable NwinStkC -width 5 
    vTcl:DefineAlias "$site_4_0.ent81" "Entry3" vTcl:WidgetProc "Toplevel209" 1
    pack $site_4_0.lab80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    button $site_3_0.cpd71 \
        -background #ffff00 \
        -command {global StkG0v1 StkG1v1 StkG2v1 StkG3v1 StkPhiv1 StkTauv1 StkEigv1 StkProbv1 StkHv1 StkAv1 StkCv1 StkDoLP1 StkDoCP1 StkCPR1 StkLPR1
global BMPStkG0v1 BMPStkG1v1 BMPStkG2v1 BMPStkG3v1 BMPStkPhiv1 BMPStkTauv1 BMPStkEigv1 BMPStkProbv1 BMPStkHv1 BMPStkAv1 BMPStkCv1 BMPStkDoLP1 BMPStkDoCP1 BMPStkCPR1 BMPStkLPR1
global StkG0v2 StkG1v2 StkG2v2 StkG3v2 StkPhiv2 StkTauv2 StkEigv2 StkProbv2 StkHv2 StkAv2 StkCv2 StkDoLP2 StkDoCP2 StkCPR2 StkLPR2
global BMPStkG0v2 BMPStkG1v2 BMPStkG2v2 BMPStkG3v2 BMPStkPhiv2 BMPStkTauv2 BMPStkEigv2 BMPStkProbv2 BMPStkHv2 BMPStkAv2 BMPStkCv2 BMPStkDoLP2 BMPStkDoCP2 BMPStkCPR2 BMPStkLPR2
global StkFonction PolarType

set NwinStkL "?"
set NwinStkC "?"
if {$StkFonction == "S2"} {
    set StkG0v1 1; set StkG1v1 1; set StkG2v1 1; set StkG3v1 1
    set StkPhiv1 1; set StkTauv1 1
    set StkEigv1 1; set StkHv1 1
    set StkAv1 1; set StkCv1 1; set StkProbv1 1
    set StkDoLP1 1; set StkDoCP1 1
    set StkCPR1 1; set StkLPR1 1
    set BMPStkG0v1 1; set BMPStkG1v1 1; set BMPStkG2v1 1; set BMPStkG3v1 1
    set BMPStkPhiv1 1; set BMPStkTauv1 1
    set BMPStkEigv1 1; set BMPStkHv1 1
    set BMPStkAv1 1; set BMPStkCv1 1
    set BMPStkProbv1 1; set BMPStkDoLP1 1
    set BMPStkDoCP1 1; set BMPStkCPR1 1
    set BMPStkLPR1 1
    $widget(Checkbutton209_1) configure -state normal
    $widget(Checkbutton209_2) configure -state normal
    $widget(Checkbutton209_3) configure -state normal
    $widget(Checkbutton209_4) configure -state normal
    $widget(Checkbutton209_6) configure -state normal
    $widget(Checkbutton209_8) configure -state normal
    $widget(Checkbutton209_10) configure -state normal
    $widget(Checkbutton209_12) configure -state normal
    $widget(Checkbutton209_14) configure -state normal
    $widget(Checkbutton209_16) configure -state normal
    $widget(Checkbutton209_18) configure -state normal
    $widget(Checkbutton209_42) configure -state normal
    $widget(Checkbutton209_44) configure -state normal
    $widget(Checkbutton209_46) configure -state normal
    $widget(Checkbutton209_48) configure -state normal

    set StkG0v2 1; set StkG1v2 1; set StkG2v2 1; set StkG3v2 1
    set StkPhiv2 1; set StkTauv2 1
    set StkEigv2 1; set StkHv2 1
    set StkAv2 1; set StkCv2 1
    set StkDoLP2 1; set StkDoCP2 1
    set StkCPR2 1; set StkLPR2 1
    set StkProbv2 1
    set BMPStkG0v2 1; set BMPStkG1v2 1; set BMPStkG2v2 1; set BMPStkG3v2 1
    set BMPStkPhiv2 1; set BMPStkTauv2 1
    set BMPStkEigv2 1; set BMPStkHv2 1
    set BMPStkAv2 1; set BMPStkCv2 1
    set BMPStkProbv2 1; set BMPStkDoLP2 1
    set BMPStkDoCP2 1; set BMPStkCPR2 1
    set BMPStkLPR2 1
    $widget(Checkbutton209_21) configure -state normal
    $widget(Checkbutton209_22) configure -state normal
    $widget(Checkbutton209_23) configure -state normal
    $widget(Checkbutton209_24) configure -state normal
    $widget(Checkbutton209_26) configure -state normal
    $widget(Checkbutton209_28) configure -state normal
    $widget(Checkbutton209_30) configure -state normal
    $widget(Checkbutton209_32) configure -state normal
    $widget(Checkbutton209_34) configure -state normal
    $widget(Checkbutton209_36) configure -state normal
    $widget(Checkbutton209_38) configure -state normal
    $widget(Checkbutton209_52) configure -state normal
    $widget(Checkbutton209_54) configure -state normal
    $widget(Checkbutton209_56) configure -state normal
    $widget(Checkbutton209_58) configure -state normal
    } else {
    if {$PolarType == "pp1"} {
        set StkG0v1 1; set StkG1v1 1; set StkG2v1 1; set StkG3v1 1
        set StkPhiv1 1; set StkTauv1 1
        set StkEigv1 1; set StkHv1 1
        set StkAv1 1; set StkCv1 1; set StkProbv1 1
        set StkDoLP1 1; set StkDoCP1 1
        set StkCPR1 1; set StkLPR1 1
        set BMPStkG0v1 1; set BMPStkG1v1 1; set BMPStkG2v1 1; set BMPStkG3v1 1
        set BMPStkPhiv1 1; set BMPStkTauv1 1
        set BMPStkEigv1 1; set BMPStkHv1 1
        set BMPStkAv1 1; set BMPStkCv1 1
        set BMPStkProbv1 1; set BMPStkDoLP1 1
        set BMPStkDoCP1 1; set BMPStkCPR1 1
        set BMPStkLPR1 1
        $widget(Checkbutton209_1) configure -state normal
        $widget(Checkbutton209_2) configure -state normal
        $widget(Checkbutton209_3) configure -state normal
        $widget(Checkbutton209_4) configure -state normal
        $widget(Checkbutton209_6) configure -state normal
        $widget(Checkbutton209_8) configure -state normal
        $widget(Checkbutton209_10) configure -state normal
        $widget(Checkbutton209_12) configure -state normal
        $widget(Checkbutton209_14) configure -state normal
        $widget(Checkbutton209_16) configure -state normal
        $widget(Checkbutton209_18) configure -state normal
        $widget(Checkbutton209_42) configure -state normal
        $widget(Checkbutton209_44) configure -state normal
        $widget(Checkbutton209_46) configure -state normal
        $widget(Checkbutton209_48) configure -state normal
        }
    if {$PolarType == "pp2"} {
        set StkG0v2 1; set StkG1v2 1; set StkG2v2 1; set StkG3v2 1
        set StkPhiv2 1; set StkTauv2 1
        set StkEigv2 1; set StkHv2 1
        set StkAv2 1; set StkCv2 1
        set StkDoLP2 1; set StkDoCP2 1
        set StkCPR2 1; set StkLPR2 1
        set StkProbv2 1
        set BMPStkG0v2 1; set BMPStkG1v2 1; set BMPStkG2v2 1; set BMPStkG3v2 1
        set BMPStkPhiv2 1; set BMPStkTauv2 1
        set BMPStkEigv2 1; set BMPStkHv2 1
        set BMPStkAv2 1; set BMPStkCv2 1
        set BMPStkProbv2 1; set BMPStkDoLP2 1
        set BMPStkDoCP2 1; set BMPStkCPR2 1
        set BMPStkLPR2 1
        $widget(Checkbutton209_21) configure -state normal
        $widget(Checkbutton209_22) configure -state normal
        $widget(Checkbutton209_23) configure -state normal
        $widget(Checkbutton209_24) configure -state normal
        $widget(Checkbutton209_26) configure -state normal
        $widget(Checkbutton209_28) configure -state normal
        $widget(Checkbutton209_30) configure -state normal
        $widget(Checkbutton209_32) configure -state normal
        $widget(Checkbutton209_34) configure -state normal
        $widget(Checkbutton209_36) configure -state normal
        $widget(Checkbutton209_38) configure -state normal
        $widget(Checkbutton209_52) configure -state normal
        $widget(Checkbutton209_54) configure -state normal
        $widget(Checkbutton209_56) configure -state normal
        $widget(Checkbutton209_58) configure -state normal
        }
    }} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd71" "Button587" vTcl:WidgetProc "Toplevel209" 1
    bindtags $site_3_0.cpd71 "$site_3_0.cpd71 Button $top all _vTclBalloon"
    bind $site_3_0.cpd71 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.cpd82 \
        -background #ffff00 \
        -command {global StkG0v1 StkG1v1 StkG2v1 StkG3v1 StkPhiv1 StkTauv1 StkEigv1 StkProbv1 StkHv1 StkAv1 StkCv1 StkDoLP1 StkDoCP1 StkCPR1 StkLPR1
global BMPStkG0v1 BMPStkG1v1 BMPStkG2v1 BMPStkG3v1 BMPStkPhiv1 BMPStkTauv1 BMPStkEigv1 BMPStkProbv1 BMPStkHv1 BMPStkAv1 BMPStkCv1 BMPStkDoLP1 BMPStkDoCP1 BMPStkCPR1 BMPStkLPR1
global StkG0v2 StkG1v2 StkG2v2 StkG3v2 StkPhiv2 StkTauv2 StkEigv2 StkProbv2 StkHv2 StkAv2 StkCv2 StkDoLP2 StkDoCP2 StkCPR2 StkLPR2
global BMPStkG0v2 BMPStkG1v2 BMPStkG2v2 BMPStkG3v2 BMPStkPhiv2 BMPStkTauv2 BMPStkEigv2 BMPStkProbv2 BMPStkHv2 BMPStkAv2 BMPStkCv2 BMPStkDoLP2 BMPStkDoCP2 BMPStkCPR2 BMPStkLPR2
global NwinStkL NwinStkC

set NwinStkL "?"
set NwinStkC "?"
set StkG0v1 0
set StkG1v1 0
set StkG2v1 0
set StkG3v1 0
set StkPhiv1 0
set StkTauv1 0
set StkEigv1 0
set StkHv1 0
set StkAv1 0
set StkCv1 0
set StkProbv1 0
set StkDoLP1 0
set StkDoCP1 0
set StkCPR1 0
set StkLPR1 0
set BMPStkG0v1 0
set BMPStkG1v1 0
set BMPStkG2v1 0
set BMPStkG3v1 0
set BMPStkPhiv1 0
set BMPStkTauv1 0
set BMPStkEigv1 0
set BMPStkHv1 0
set BMPStkAv1 0
set BMPStkCv1 0
set BMPStkProbv1 0
set BMPStkDoLP1 0
set BMPStkDoCP1 0
set BMPStkCPR1 0
set BMPStkLPR1 0
$widget(Checkbutton209_1) configure -state disable
$widget(Checkbutton209_2) configure -state disable
$widget(Checkbutton209_3) configure -state disable
$widget(Checkbutton209_4) configure -state disable
$widget(Checkbutton209_6) configure -state disable
$widget(Checkbutton209_8) configure -state disable
$widget(Checkbutton209_10) configure -state disable
$widget(Checkbutton209_12) configure -state disable
$widget(Checkbutton209_14) configure -state disable
$widget(Checkbutton209_16) configure -state disable
$widget(Checkbutton209_18) configure -state disable
$widget(Checkbutton209_42) configure -state disable
$widget(Checkbutton209_44) configure -state disable
$widget(Checkbutton209_46) configure -state disable
$widget(Checkbutton209_48) configure -state disable
set StkG0v2 0
set StkG1v2 0
set StkG2v2 0
set StkG3v2 0
set StkPhiv2 0
set StkTauv2 0
set StkEigv2 0
set StkHv2 0
set StkAv2 0
set StkCv2 0
set StkDoLP2 0
set StkDoCP2 0
set StkCPR2 0
set StkLPR2 0
set StkProbv2 0
set BMPStkG0v2 0
set BMPStkG1v2 0
set BMPStkG2v2 0
set BMPStkG3v2 0
set BMPStkPhiv2 0
set BMPStkTauv2 0
set BMPStkEigv2 0
set BMPStkHv2 0
set BMPStkAv2 0
set BMPStkCv2 0
set BMPStkProbv2 0
set BMPStkDoLP2 0
set BMPStkDoCP2 0
set BMPStkCPR2 0
set BMPStkLPR2 0
$widget(Checkbutton209_21) configure -state disable
$widget(Checkbutton209_22) configure -state disable
$widget(Checkbutton209_23) configure -state disable
$widget(Checkbutton209_24) configure -state disable
$widget(Checkbutton209_26) configure -state disable
$widget(Checkbutton209_28) configure -state disable
$widget(Checkbutton209_30) configure -state disable
$widget(Checkbutton209_32) configure -state disable
$widget(Checkbutton209_34) configure -state disable
$widget(Checkbutton209_36) configure -state disable
$widget(Checkbutton209_38) configure -state disable
$widget(Checkbutton209_52) configure -state disable
$widget(Checkbutton209_54) configure -state disable
$widget(Checkbutton209_56) configure -state disable
$widget(Checkbutton209_58) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd82" "Button586" vTcl:WidgetProc "Toplevel209" 1
    bindtags $site_3_0.cpd82 "$site_3_0.cpd82 Button $top all _vTclBalloon"
    bind $site_3_0.cpd82 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.fra79 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 50 -side left 
    pack $site_3_0.cpd82 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra94 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra94" "Frame20" vTcl:WidgetProc "Toplevel209" 1
    set site_3_0 $top.fra94
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global StkDirInput StkDirOutput StkOutputDir StkOutputSubDir StkFonction StkFunction
global Fonction Fonction2 VarFunction VarWarning WarningMessage WarningMessage2 VarError ErrorMessage ProgressLine 
global BMPDirInput OpenDirFile PSPMemory TMPMemoryAllocError
global StkG0v1 StkG1v1 StkG2v1 StkG3v1 StkPhiv1 StkTauv1 StkEigv1 StkProbv1 StkHv1 StkAv1 StkCv1 StkDoLP1 StkDoCP1 StkCPR1 StkLPR1
global StkG0v2 StkG1v2 StkG2v2 StkG3v2 StkPhiv2 StkTauv2 StkEigv2 StkProbv2 StkHv2 StkAv2 StkCv2 StkDoLP2 StkDoCP2 StkCPR2 StkLPR2
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax NwinStkL NwinStkC

if {$OpenDirFile == 0} {

set config1 "false"
if {$StkG0v1 != "0"} { set config1 "true" }
if {$StkG1v1 != "0"} { set config1 "true" }
if {$StkG2v1 != "0"} { set config1 "true" }
if {$StkG3v1 != "0"} { set config1 "true" }
if {$StkPhiv1 != "0"} { set config1 "true" }
if {$StkTauv1 != "0"} { set config1 "true" }
if {$StkEigv1 != "0"} { set config1 "true" }
if {$StkProbv1 != "0"} { set config1 "true" }
if {$StkHv1 != "0"} { set config1 "true" }
if {$StkAv1 != "0"} { set config1 "true" }
if {$StkCv1 != "0"} { set config1 "true" }
if {$StkDoLP1 != "0"} { set config1 "true" }
if {$StkDoCP1 != "0"} { set config1 "true" }
if {$StkCPR1 != "0"} { set config1 "true" }
if {$StkLPR1 != "0"} { set config1 "true" }
set config2 "false"
if {$StkG0v2 != "0"} { set config2 "true" }
if {$StkG1v2 != "0"} { set config2 "true" }
if {$StkG2v2 != "0"} { set config2 "true" }
if {$StkG3v2 != "0"} { set config2 "true" }
if {$StkPhiv2 != "0"} { set config2 "true" }
if {$StkTauv2 != "0"} { set config2 "true" }
if {$StkEigv2 != "0"} { set config2 "true" }
if {$StkProbv2 != "0"} { set config2 "true" }
if {$StkHv2 != "0"} { set config2 "true" }
if {$StkAv2 != "0"} { set config2 "true" }
if {$StkCv2 != "0"} { set config2 "true" }
if {$StkDoLP2 != "0"} { set config2 "true" }
if {$StkDoCP2 != "0"} { set config2 "true" }
if {$StkCPR2 != "0"} { set config2 "true" }
if {$StkLPR2 != "0"} { set config2 "true" }
set config "false"
if {"$config1"=="true"} { set config "true" }
if {"$config2"=="true"} { set config "true" }

set VarWarning "ok"

if {"$config"=="true"} {

    set StkDirOutput $StkOutputDir
    if {$StkOutputSubDir != ""} {append StkDirOutput "/$StkOutputSubDir"}

    #####################################################################
    #Create Directory
    set StkDirOutput [PSPCreateDirectoryMask $StkDirOutput $StkOutputDir $StkDirInput]
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
        set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $NwinStkL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
        set TestVarName(5) "Window Size Col"; set TestVarType(5) "int"; set TestVarValue(5) $NwinStkC; set TestVarMin(5) "1"; set TestVarMax(5) "1000"
        TestVar 6
        if {$TestVarError == "ok"} {

            set BMPDirInput $StkDirOutput
        
            set Fonction "Creation of all the Binary Data Files"
            set Fonction2 "of the Stokes Parameters"
            if {"$config1"=="true"} {
                set MaskCmd ""
                set MaskFile "$StkDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/data_process_sngl/StokesParameters.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$StkDirInput\x22 -od \x22$StkDirOutput\x22 -iodf $StkFonction -nwr $NwinStkL -nwc $NwinStkC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cha 1 -fl1 $StkG0v1 -fl2 $StkG1v1 -fl3 $StkG2v1 -fl4 $StkG3v1 -fl5 $StkPhiv1 -fl6 $StkTauv1 -fl7 $StkEigv1 -fl8 $StkProbv1 -fl9 $StkHv1 -fl10 $StkAv1 -fl11 $StkCv1 -fl12 $StkDoLP1 -fl13 $StkDoCP1 -fl14 $StkLPR1 -fl15 $StkCPR1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/data_process_sngl/StokesParameters.exe -id \x22$StkDirInput\x22 -od \x22$StkDirOutput\x22 -iodf $StkFonction -nwr $NwinStkL -nwc $NwinStkC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cha 1 -fl1 $StkG0v1 -fl2 $StkG1v1 -fl3 $StkG2v1 -fl4 $StkG3v1 -fl5 $StkPhiv1 -fl6 $StkTauv1 -fl7 $StkEigv1 -fl8 $StkProbv1 -fl9 $StkHv1 -fl10 $StkAv1 -fl11 $StkCv1 -fl12 $StkDoLP1 -fl13 $StkDoCP1 -fl14 $StkLPR1 -fl15 $StkCPR1 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                if {"$StkG0v1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_g0.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_g0.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG0v1"=="2"} {
                    if [file exists "$StkDirOutput/Stokes1_g0dB.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_g0dB.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG1v1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_g1.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_g1.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG1v1"=="2"} {
                    if [file exists "$StkDirOutput/Stokes1_g1dB.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_g1dB.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG2v1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_g2.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_g2.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG2v1"=="2"} {
                    if [file exists "$StkDirOutput/Stokes1_g2dB.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_g2dB.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG3v1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_g3.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_g3.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG3v1"=="2"} {
                    if [file exists "$StkDirOutput/Stokes1_g3dB.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_g3dB.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkPhiv1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_phi.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_phi.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkTauv1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_tau.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_tau.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkEigv1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_l1.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_l1.bin" $FinalNlig $FinalNcol 4}
                    if [file exists "$StkDirOutput/Stokes1_l2.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_l2.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkProbv1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_p1.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_p1.bin" $FinalNlig $FinalNcol 4}
                    if [file exists "$StkDirOutput/Stokes1_p2.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_p2.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkHv1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_H.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_H.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkAv1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_A.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_A.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkCv1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_contrast.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_contrast.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkDoLP1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_DoLP.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_DoLP.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkDoCP1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_DoCP.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_DoCP.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkCPR1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_CPR.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_CPR.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkLPR1"=="1"} {
                    if [file exists "$StkDirOutput/Stokes1_LPR.bin"] {EnviWriteConfig "$StkDirOutput/Stokes1_LPR.bin" $FinalNlig $FinalNcol 4}
                    }
                }                    
            if {"$config2"=="true"} {
                set MaskCmd ""
                set MaskFile "$StkDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                TextEditorRunTrace "Process The Function Soft/data_process_sngl/StokesParameters.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$StkDirInput\x22 -od \x22$StkDirOutput\x22 -iodf $StkFonction -nwr $NwinStkL -nwc $NwinStkC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cha 2 -fl1 $StkG0v2 -fl2 $StkG1v2 -fl3 $StkG2v2 -fl4 $StkG3v2 -fl5 $StkPhiv2 -fl6 $StkTauv2 -fl7 $StkEigv2 -fl8 $StkProbv2 -fl9 $StkHv2 -fl10 $StkAv2 -fl11 $StkCv2 -fl12 $StkDoLP2 -fl13 $StkDoCP2 -fl14 $StkLPR2 -fl15 $StkCPR2 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/data_process_sngl/StokesParameters.exe -id \x22$StkDirInput\x22 -od \x22$StkDirOutput\x22 -iodf $StkFonction -nwr $NwinStkL -nwc $NwinStkC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -cha 2 -fl1 $StkG0v2 -fl2 $StkG1v2 -fl3 $StkG2v2 -fl4 $StkG3v2 -fl5 $StkPhiv2 -fl6 $StkTauv2 -fl7 $StkEigv2 -fl8 $StkProbv2 -fl9 $StkHv2 -fl10 $StkAv2 -fl11 $StkCv2 -fl12 $StkDoLP2 -fl13 $StkDoCP2 -fl14 $StkLPR2 -fl15 $StkCPR2 -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                if {"$StkG0v2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_g0.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_g0.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG0v2"=="2"} {
                    if [file exists "$StkDirOutput/Stokes2_g0dB.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_g0dB.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG1v2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_g1.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_g1.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG1v2"=="2"} {
                    if [file exists "$StkDirOutput/Stokes2_g1dB.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_g1dB.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG2v2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_g2.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_g2.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG2v2"=="2"} {
                    if [file exists "$StkDirOutput/Stokes2_g2dB.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_g2dB.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG3v2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_g3.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_g3.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkG3v2"=="2"} {
                    if [file exists "$StkDirOutput/Stokes2_g3dB.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_g3dB.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkPhiv2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_phi.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_Phi.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkTauv2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_tau.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_Tau.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkEigv2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_l1.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_l1.bin" $FinalNlig $FinalNcol 4}
                    if [file exists "$StkDirOutput/Stokes2_l2.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_l2.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkProbv2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_p1.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_p1.bin" $FinalNlig $FinalNcol 4}
                    if [file exists "$StkDirOutput/Stokes2_p2.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_p2.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkHv2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_H.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_H.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkAv2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_A.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_A.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkCv2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_contrast.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_contrast.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkDoLP2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_DoLP.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_DoLP.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkDoCP2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_DoCP.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_DoCP.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkCPR2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_CPR.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_CPR.bin" $FinalNlig $FinalNcol 4}
                    }
                if {"$StkLPR2"=="1"} {
                    if [file exists "$StkDirOutput/Stokes2_LPR.bin"] {EnviWriteConfig "$StkDirOutput/Stokes2_LPR.bin" $FinalNlig $FinalNcol 4}
                    }
                }
            #Update the Nlig/Ncol of the new image after processing
            set NligInit 1
            set NcolInit 1
            set NligEnd $FinalNlig
            set NcolEnd $FinalNcol
            
        #####################################################################       

        set Fonction "Creation of the BMP File"

        set OffsetLig [expr $NligInit - 1]
        set OffsetCol [expr $NcolInit - 1]
        set FinalNlig [expr $NligEnd - $NligInit + 1]
        set FinalNcol [expr $NcolEnd - $NcolInit + 1]

        if {"$BMPStkG0v1"=="1"} {
            if {"$StkG0v1"=="1"} {
                set BMPFileInput "$StkDirOutput/Stokes1_g0.bin"
                set BMPFileOutput "$StkDirOutput/Stokes1_g0.bmp"
                }
            if {"$StkG0v1"=="2"} {
                set BMPFileInput "$StkDirOutput/Stokes1_g0dB.bin"
                set BMPFileOutput "$StkDirOutput/Stokes1_g0dB.bmp"
                }
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkG1v1"=="1"} {
            if {"$StkG1v1"=="1"} {
                set BMPFileInput "$StkDirOutput/Stokes1_g1.bin"
                set BMPFileOutput "$StkDirOutput/Stokes1_g1.bmp"
                }
            if {"$StkG1v1"=="2"} {
                set BMPFileInput "$StkDirOutput/Stokes1_g1dB.bin"
                set BMPFileOutput "$StkDirOutput/Stokes1_g1dB.bmp"
                }
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkG2v1"=="1"} {
            if {"$StkG2v1"=="1"} {
                set BMPFileInput "$StkDirOutput/Stokes1_g2.bin"
                set BMPFileOutput "$StkDirOutput/Stokes1_g2.bmp"
                }
            if {"$StkG2v1"=="2"} {
                set BMPFileInput "$StkDirOutput/Stokes1_g2dB.bin"
                set BMPFileOutput "$StkDirOutput/Stokes1_g2dB.bmp"
                }
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkG3v1"=="1"} {
            if {"$StkG3v1"=="1"} {
                set BMPFileInput "$StkDirOutput/Stokes1_g3.bin"
                set BMPFileOutput "$StkDirOutput/Stokes1_g3.bmp"
                }
            if {"$StkG3v1"=="2"} {
                set BMPFileInput "$StkDirOutput/Stokes1_g3dB.bin"
                set BMPFileOutput "$StkDirOutput/Stokes1_g3dB.bmp"
                }
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkPhiv1"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes1_phi.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_phi.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -90 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkTauv1"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes1_tau.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_tau.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -45 45
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkEigv1"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes1_l1.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_l1.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set BMPFileInput "$StkDirOutput/Stokes1_l2.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_l2.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkProbv1"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes1_p1.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_p1.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set BMPFileInput "$StkDirOutput/Stokes1_p2.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_p2.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkHv1"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes1_H.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_H.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkAv1"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes1_A.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_A.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkCv1"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes1_contrast.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_contrast.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -1 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkDoLP1"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes1_DoLP.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_DoLP.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkDoCP1"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes1_DoCP.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_DoCP.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -1 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkCPR1"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes1_CPR.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_CPR.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkLPR1"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes1_LPR.bin"
            set BMPFileOutput "$StkDirOutput/Stokes1_LPR.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }


        if {"$BMPStkG0v2"=="1"} {
            if {"$StkG0v2"=="1"} {
                set BMPFileInput "$StkDirOutput/Stokes2_g0.bin"
                set BMPFileOutput "$StkDirOutput/Stokes2_g0.bmp"
                }
            if {"$StkG0v2"=="2"} {
                set BMPFileInput "$StkDirOutput/Stokes2_g0dB.bin"
                set BMPFileOutput "$StkDirOutput/Stokes2_g0dB.bmp"
                }
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkG1v2"=="1"} {
            if {"$StkG1v2"=="1"} {
                set BMPFileInput "$StkDirOutput/Stokes2_g1.bin"
                set BMPFileOutput "$StkDirOutput/Stokes2_g1.bmp"
                }
            if {"$StkG1v2"=="2"} {
                set BMPFileInput "$StkDirOutput/Stokes2_g1dB.bin"
                set BMPFileOutput "$StkDirOutput/Stokes2_g1dB.bmp"
                }
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkG2v2"=="1"} {
            if {"$StkG2v2"=="1"} {
                set BMPFileInput "$StkDirOutput/Stokes2_g2.bin"
                set BMPFileOutput "$StkDirOutput/Stokes2_g2.bmp"
                }
            if {"$StkG2v2"=="2"} {
                set BMPFileInput "$StkDirOutput/Stokes2_g2dB.bin"
                set BMPFileOutput "$StkDirOutput/Stokes2_g2dB.bmp"
                }
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkG3v2"=="1"} {
            if {"$StkG3v2"=="1"} {
                set BMPFileInput "$StkDirOutput/Stokes2_g3.bin"
                set BMPFileOutput "$StkDirOutput/Stokes2_g3.bmp"
                }
            if {"$StkG3v2"=="2"} {
                set BMPFileInput "$StkDirOutput/Stokes2_g3dB.bin"
                set BMPFileOutput "$StkDirOutput/Stokes2_g3dB.bmp"
                }
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkPhiv2"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes2_phi.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_phi.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -90 90
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkTauv2"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes2_tau.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_tau.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -45 45
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkEigv2"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes2_l1.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_l1.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set BMPFileInput "$StkDirOutput/Stokes2_l2.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_l2.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkProbv2"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes2_p1.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_p1.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            set BMPFileInput "$StkDirOutput/Stokes2_p2.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_p2.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkHv2"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes2_H.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_H.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkAv2"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes2_A.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_A.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkCv2"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes2_contrast.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_contrast.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -1 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkDoLP2"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes2_DoLP.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_DoLP.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkDoCP2"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes2_DoCP.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_DoCP.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 -1 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkCPR2"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes2_CPR.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_CPR.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }
        if {"$BMPStkLPR2"=="1"} {
            set BMPFileInput "$StkDirOutput/Stokes2_LPR.bin"
            set BMPFileOutput "$StkDirOutput/Stokes2_LPR.bmp"
            if [file exists $BMPFileInput] {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
                } else {
                set VarError ""
                set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        } 
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel209); TextEditorRunTrace "Close Window Stokes Parameters" "b"}
    }
}
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel209" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/StokesParameters.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel209" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel209); TextEditorRunTrace "Close Window Stokes Parameters" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel209" 1
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
    pack $top.cpd77 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra88 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra77 \
        -in $top -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $top.fra94 \
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
Window show .top209

main $argc $argv
