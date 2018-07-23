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
    set base .top57
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd84 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd84
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
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd83 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd81 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd81
    namespace eval ::widgets::$site_6_0.cpd93 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
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
    namespace eval ::widgets::$base.fra61 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra61
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra62 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra62
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra63 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra63
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra64 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra64
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra65 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra65
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra67 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra67
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra68 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra68
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra69 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra69
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad50 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra70 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra70
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra72 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra72
    namespace eval ::widgets::$site_3_0.lab47 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_3_0.rad48 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.rad49 {
        array set save {-command 1 -padx 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che51 {
        array set save {-padx 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra75
    namespace eval ::widgets::$site_3_0.cpd76 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd77 {
        array set save {-_tooltip 1 -background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
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
            vTclWindow.top57
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

proc vTclWindow.top57 {base} {
    if {$base == ""} {
        set base .top57
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
    wm minsize $top 113 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Covariance Elements C4"
    vTcl:DefineAlias "$top" "Toplevel57" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd84 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd84" "Frame4" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.cpd84
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel57" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable CovDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel57" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel57" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button39" vTcl:WidgetProc "Toplevel57" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel57" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -state normal \
        -textvariable CovOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel57" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel57" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd84 \
        -text / 
    vTcl:DefineAlias "$site_6_0.cpd84" "Label235" vTcl:WidgetProc "Toplevel57" 1
    entry $site_6_0.cpd83 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable CovOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd83" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel57" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd83 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd81 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd81" "Frame17" vTcl:WidgetProc "Toplevel57" 1
    set site_6_0 $site_5_0.cpd81
    button $site_6_0.cpd93 \
        \
        -command {global DirName DataDir CovOutputDir

set CovDirOutputTmp $CovOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set CovOutputDir $DirName
    } else {
    set CovOutputDir $CovDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.cpd93" "Button104" vTcl:WidgetProc "Toplevel57" 1
    bindtags $site_6_0.cpd93 "$site_6_0.cpd93 Button $top all _vTclBalloon"
    bind $site_6_0.cpd93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd93 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra59 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame237" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra59
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label229" vTcl:WidgetProc "Toplevel57" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry169" vTcl:WidgetProc "Toplevel57" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label230" vTcl:WidgetProc "Toplevel57" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry170" vTcl:WidgetProc "Toplevel57" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label231" vTcl:WidgetProc "Toplevel57" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry171" vTcl:WidgetProc "Toplevel57" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label232" vTcl:WidgetProc "Toplevel57" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry172" vTcl:WidgetProc "Toplevel57" 1
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
    frame $top.fra61 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra61" "Frame24" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra61
    label $site_3_0.lab47 \
        -text C11 
    vTcl:DefineAlias "$site_3_0.lab47" "Label26" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton57_1) configure -state normal} -padx 1 \
        -text Modulus -value mod -variable C4toC11 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton4" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton57_1) configure -state normal} \
        -text 10log(Modulus) -value db -variable C4toC11 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton5" vTcl:WidgetProc "Toplevel57" 1
    checkbutton $site_3_0.che51 \
        -text BMP -variable BMPC4toC11 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton57_1" vTcl:WidgetProc "Toplevel57" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra62 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra62" "Frame25" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra62
    label $site_3_0.lab47 \
        -text C12 
    vTcl:DefineAlias "$site_3_0.lab47" "Label27" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton57_2) configure -state normal} -padx 1 \
        -text Modulus -value mod -variable C4toC12 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton7" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton57_2) configure -state normal} \
        -text 10log(Modulus) -value db -variable C4toC12 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton8" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton57_2) configure -state normal} \
        -text Phase -value pha -variable C4toC12 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton9" vTcl:WidgetProc "Toplevel57" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPC4toC12 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton57_2" vTcl:WidgetProc "Toplevel57" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra63 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra63" "Frame27" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra63
    label $site_3_0.lab47 \
        -text C13 
    vTcl:DefineAlias "$site_3_0.lab47" "Label29" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton57_3) configure -state normal} -padx 1 \
        -text Modulus -value mod -variable C4toC13 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton74" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton57_3) configure -state normal} \
        -text 10log(Modulus) -value db -variable C4toC13 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton75" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton57_3) configure -state normal} \
        -text Phase -value pha -variable C4toC13 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton76" vTcl:WidgetProc "Toplevel57" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPC4toC13 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton57_3" vTcl:WidgetProc "Toplevel57" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra64 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra64" "Frame201" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra64
    label $site_3_0.lab47 \
        -text C14 
    vTcl:DefineAlias "$site_3_0.lab47" "Label206" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton57_4) configure -state normal} \
        -text Modulus -value mod -variable C4toC14 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton65" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton57_4) configure -state normal} \
        -text 10log(Modulus) -value db -variable C4toC14 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton66" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton57_4) configure -state normal} -padx 1 \
        -text Phase -value pha -variable C4toC14 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton67" vTcl:WidgetProc "Toplevel57" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPC4toC14 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton57_4" vTcl:WidgetProc "Toplevel57" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra65 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra65" "Frame28" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra65
    label $site_3_0.lab47 \
        -text C22 
    vTcl:DefineAlias "$site_3_0.lab47" "Label30" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton57_5) configure -state normal} -padx 1 \
        -text Modulus -value mod -variable C4toC22 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton77" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton57_5) configure -state normal} \
        -text 10log(Modulus) -value db -variable C4toC22 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton78" vTcl:WidgetProc "Toplevel57" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPC4toC22 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton57_5" vTcl:WidgetProc "Toplevel57" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra66 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame29" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra66
    label $site_3_0.lab47 \
        -text C23 
    vTcl:DefineAlias "$site_3_0.lab47" "Label31" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton57_6) configure -state normal} \
        -text Modulus -value mod -variable C4toC23 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton79" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton57_6) configure -state normal} \
        -text 10log(Modulus) -value db -variable C4toC23 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton80" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton57_6) configure -state normal} -padx 1 \
        -text Phase -value pha -variable C4toC23 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton81" vTcl:WidgetProc "Toplevel57" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPC4toC23 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton57_6" vTcl:WidgetProc "Toplevel57" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra67 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra67" "Frame198" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra67
    label $site_3_0.lab47 \
        -text C24 
    vTcl:DefineAlias "$site_3_0.lab47" "Label233" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton57_7) configure -state normal} -padx 1 \
        -text Modulus -value mod -variable C4toC24 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton56" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton57_7) configure -state normal} \
        -text 10log(Modulus) -value db -variable C4toC24 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton57" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton57_7) configure -state normal} \
        -text Phase -value pha -variable C4toC24 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton58" vTcl:WidgetProc "Toplevel57" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPC4toC24 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton57_7" vTcl:WidgetProc "Toplevel57" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra68 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra68" "Frame30" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra68
    label $site_3_0.lab47 \
        -text C33 
    vTcl:DefineAlias "$site_3_0.lab47" "Label32" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton57_8) configure -state normal} \
        -text Modulus -value mod -variable C4toC33 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton82" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton57_8) configure -state normal} -padx 1 \
        -text 10log(Modulus) -value db -variable C4toC33 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton83" vTcl:WidgetProc "Toplevel57" 1
    checkbutton $site_3_0.che51 \
        -text BMP -variable BMPC4toC33 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton57_8" vTcl:WidgetProc "Toplevel57" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra69 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra69" "Frame199" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra69
    label $site_3_0.lab47 \
        -text C34 
    vTcl:DefineAlias "$site_3_0.lab47" "Label234" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton57_9) configure -state normal} -padx 1 \
        -text Modulus -value mod -variable C4toC34 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton59" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton57_9) configure -state normal} \
        -text 10log(Modulus) -value db -variable C4toC34 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton60" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad50 \
        -command {$widget(Checkbutton57_9) configure -state normal} \
        -text Phase -value pha -variable C4toC34 
    vTcl:DefineAlias "$site_3_0.rad50" "Radiobutton61" vTcl:WidgetProc "Toplevel57" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPC4toC34 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton57_9" vTcl:WidgetProc "Toplevel57" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad50 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra70 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra70" "Frame202" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra70
    label $site_3_0.lab47 \
        -text C44 
    vTcl:DefineAlias "$site_3_0.lab47" "Label207" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton57_10) configure -state normal} \
        -text Modulus -value mod -variable C4toC44 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton68" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton57_10) configure -state normal} -padx 1 \
        -text 10log(Modulus) -value db -variable C4toC44 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton69" vTcl:WidgetProc "Toplevel57" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPC4toC44 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton57_10" vTcl:WidgetProc "Toplevel57" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra72 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra72" "Frame32" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra72
    label $site_3_0.lab47 \
        -text Span 
    vTcl:DefineAlias "$site_3_0.lab47" "Label33" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad48 \
        -command {$widget(Checkbutton57_11) configure -state normal} -padx 1 \
        -text Linear -value lin -variable C4toSpan 
    vTcl:DefineAlias "$site_3_0.rad48" "Radiobutton84" vTcl:WidgetProc "Toplevel57" 1
    radiobutton $site_3_0.rad49 \
        -command {$widget(Checkbutton57_11) configure -state normal} -padx 1 \
        -text {DeciBel = 10log(Span)} -value db -variable C4toSpan 
    vTcl:DefineAlias "$site_3_0.rad49" "Radiobutton85" vTcl:WidgetProc "Toplevel57" 1
    checkbutton $site_3_0.che51 \
        -padx 1 -text BMP -variable BMPC4toSpan 
    vTcl:DefineAlias "$site_3_0.che51" "Checkbutton57_11" vTcl:WidgetProc "Toplevel57" 1
    pack $site_3_0.lab47 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 10 -side left 
    pack $site_3_0.rad48 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_3_0.rad49 \
        -in $site_3_0 -anchor center -expand 0 -fill none -padx 25 -side left 
    pack $site_3_0.che51 \
        -in $site_3_0 -anchor center -expand 0 -fill none -side right 
    frame $top.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra75" "Frame1" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra75
    button $site_3_0.cpd76 \
        -background #ffff00 \
        -command {set C4toC11 "db"
set C4toC12 "db"
set C4toC13 "db"
set C4toC14 "db"
set C4toC22 "db"
set C4toC23 "db"
set C4toC24 "db"
set C4toC33 "db"
set C4toC34 "db"
set C4toC44 "db"
set C4toSpan "db"
set BMPC4toC11 "1"
set BMPC4toC12 "1"
set BMPC4toC13 "1"
set BMPC4toC14 "1"
set BMPC4toC22 "1"
set BMPC4toC23 "1"
set BMPC4toC24 "1"
set BMPC4toC33 "1"
set BMPC4toC34 "1"
set BMPC4toC44 "1"
set BMPC4toSpan "1"
$widget(Checkbutton57_1) configure -state normal
$widget(Checkbutton57_2) configure -state normal
$widget(Checkbutton57_3) configure -state normal
$widget(Checkbutton57_4) configure -state normal
$widget(Checkbutton57_5) configure -state normal
$widget(Checkbutton57_6) configure -state normal
$widget(Checkbutton57_7) configure -state normal
$widget(Checkbutton57_8) configure -state normal
$widget(Checkbutton57_9) configure -state normal
$widget(Checkbutton57_10) configure -state normal
$widget(Checkbutton57_11) configure -state normal} \
        -padx 4 -pady 2 -text {Select All} 
    vTcl:DefineAlias "$site_3_0.cpd76" "Button103" vTcl:WidgetProc "Toplevel57" 1
    bindtags $site_3_0.cpd76 "$site_3_0.cpd76 Button $top all _vTclBalloon"
    bind $site_3_0.cpd76 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select All Parameters}
    }
    button $site_3_0.cpd77 \
        -background #ffff00 \
        -command {set C4toC11 ""
set C4toC12 ""
set C4toC13 ""
set C4toC14 ""
set C4toC22 ""
set C4toC23 ""
set C4toC24 ""
set C4toC33 ""
set C4toC34 ""
set C4toC44 ""
set C4toSpan ""
set BMPC4toC11 ""
set BMPC4toC12 ""
set BMPC4toC13 ""
set BMPC4toC14 ""
set BMPC4toC22 ""
set BMPC4toC23 ""
set BMPC4toC24 ""
set BMPC4toC33 ""
set BMPC4toC34 ""
set BMPC4toC44 ""
set BMPC4toSpan ""
$widget(Checkbutton57_1) configure -state disable
$widget(Checkbutton57_2) configure -state disable
$widget(Checkbutton57_3) configure -state disable
$widget(Checkbutton57_4) configure -state disable
$widget(Checkbutton57_5) configure -state disable
$widget(Checkbutton57_6) configure -state disable
$widget(Checkbutton57_7) configure -state disable
$widget(Checkbutton57_8) configure -state disable
$widget(Checkbutton57_9) configure -state disable
$widget(Checkbutton57_10) configure -state disable
$widget(Checkbutton57_11) configure -state disable} \
        -padx 4 -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd77" "Button105" vTcl:WidgetProc "Toplevel57" 1
    bindtags $site_3_0.cpd77 "$site_3_0.cpd77 Button $top all _vTclBalloon"
    bind $site_3_0.cpd77 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Reset}
    }
    pack $site_3_0.cpd76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd77 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra74 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame238" vTcl:WidgetProc "Toplevel57" 1
    set site_3_0 $top.fra74
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global CovDirInput CovDirOutput CovOutputDir CovOutputSubDir
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global BMPDirInput OpenDirFile PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set CovDirOutput $CovOutputDir
if {$CovOutputSubDir != ""} {append CovDirOutput "/$CovOutputSubDir"}
    
    #####################################################################
    #Create Directory
    set CovDirOutput [PSPCreateDirectoryMask $CovDirOutput $CovOutputDir $CovDirInput]
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
    TestVar 4
    if {$TestVarError == "ok"} {

    if {"$C4toC11"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CovDirOutput/C11_$C4toC11.bin"
        set MaskCmd ""
        set MaskFile "$CovDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 11 -fmt $C4toC11 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 11 -fmt $C4toC11 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CovDirOutput/C11_$C4toC11.bin" $FinalNlig $FinalNcol 4
        if {"$BMPC4toC11"=="1"} {
            if {"$C4toC11"=="mod"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C11_mod.bin"
                set BMPFileOutput "$CovDirOutput/C11_mod.bmp"
                }
            if {"$C4toC11"=="db"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C11_db.bin"
                set BMPFileOutput "$CovDirOutput/C11_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
            }
        }

    if {"$C4toC12"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CovDirOutput/C12_$C4toC12.bin"
        set MaskCmd ""
        set MaskFile "$CovDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 12 -fmt $C4toC12 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 12 -fmt $C4toC12 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CovDirOutput/C12_$C4toC12.bin" $FinalNlig $FinalNcol 4
        if {"$BMPC4toC12"=="1"} {
            if {"$C4toC12"=="mod"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C12_mod.bin"
                set BMPFileOutput "$CovDirOutput/C12_mod.bmp"
                }
            if {"$C4toC12"=="db"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C12_db.bin"
                set BMPFileOutput "$CovDirOutput/C12_db.bmp"
                }
            if {"$C4toC12"=="pha"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C12_pha.bin"
                set BMPFileOutput "$CovDirOutput/C12_pha.bmp"
                }
            if {"$C4toC12"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }
        
    if {"$C4toC13"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CovDirOutput/C13_$C4toC13.bin"
        set MaskCmd ""
        set MaskFile "$CovDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 13 -fmt $C4toC13 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 13 -fmt $C4toC13 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CovDirOutput/C13_$C4toC13.bin" $FinalNlig $FinalNcol 4
        if {"$BMPC4toC13"=="1"} {
            if {"$C4toC13"=="mod"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C13_mod.bin"
                set BMPFileOutput "$CovDirOutput/C13_mod.bmp"
                }
            if {"$C4toC13"=="db"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C13_db.bin"
                set BMPFileOutput "$CovDirOutput/C13_db.bmp"
                }
            if {"$C4toC13"=="pha"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C13_pha.bin"
                set BMPFileOutput "$CovDirOutput/C13_pha.bmp"
                }
            if {"$C4toC13"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }

    if {"$C4toC14"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CovDirOutput/C14_$C4toC14.bin"
        set MaskCmd ""
        set MaskFile "$CovDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 14 -fmt $C4toC14 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 14 -fmt $C4toC14 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CovDirOutput/C14_$C4toC14.bin" $FinalNlig $FinalNcol 4
        if {"$BMPC4toC14"=="1"} {
            if {"$C4toC14"=="mod"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C14_mod.bin"
                set BMPFileOutput "$CovDirOutput/C14_mod.bmp"
                }
            if {"$C4toC14"=="db"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C14_db.bin"
                set BMPFileOutput "$CovDirOutput/C14_db.bmp"
                }
            if {"$C4toC14"=="pha"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C14_pha.bin"
                set BMPFileOutput "$CovDirOutput/C14_pha.bmp"
                }
            if {"$C4toC14"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }
        
    if {"$C4toC22"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CovDirOutput/C22_$C4toC22.bin"
        set MaskCmd ""
        set MaskFile "$CovDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 22 -fmt $C4toC22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 22 -fmt $C4toC22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CovDirOutput/C22_$C4toC22.bin" $FinalNlig $FinalNcol 4
        if {"$BMPC4toC22"=="1"} {
            if {"$C4toC22"=="mod"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C22_mod.bin"
                set BMPFileOutput "$CovDirOutput/C22_mod.bmp"
                }
            if {"$C4toC22"=="db"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C22_db.bin"
                set BMPFileOutput "$CovDirOutput/C22_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0  $FinalNlig  $FinalNcol 1 0 0
            }
        }

    if {"$C4toC23"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CovDirOutput/C23_$C4toC23.bin"
        set MaskCmd ""
        set MaskFile "$CovDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 23 -fmt $C4toC23 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 23 -fmt $C4toC23 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CovDirOutput/C23_$C4toC23.bin" $FinalNlig $FinalNcol 4
        if {"$BMPC4toC23"=="1"} {
            if {"$C4toC23"=="mod"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C23_mod.bin"
                set BMPFileOutput "$CovDirOutput/C23_mod.bmp"
                }
            if {"$C4toC23"=="db"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C23_db.bin"
                set BMPFileOutput "$CovDirOutput/C23_db.bmp"
                }
            if {"$C4toC23"=="pha"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C23_pha.bin"
                set BMPFileOutput "$CovDirOutput/C23_pha.bmp"
                }
            if {"$C4toC23"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }

    if {"$C4toC24"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CovDirOutput/C24_$C4toC24.bin"
        set MaskCmd ""
        set MaskFile "$CovDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 24 -fmt $C4toC24 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 24 -fmt $C4toC24 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CovDirOutput/C24_$C4toC24.bin" $FinalNlig $FinalNcol 4
        if {"$BMPC4toC24"=="1"} {
            if {"$C4toC24"=="mod"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C24_mod.bin"
                set BMPFileOutput "$CovDirOutput/C24_mod.bmp"
                }
            if {"$C4toC24"=="db"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C24_db.bin"
                set BMPFileOutput "$CovDirOutput/C24_db.bmp"
                }
            if {"$C4toC24"=="pha"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C24_pha.bin"
                set BMPFileOutput "$CovDirOutput/C24_pha.bmp"
                }
            if {"$C4toC24"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }
        
    if {"$C4toC33"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CovDirOutput/C33_$C4toC33.bin"
        set MaskCmd ""
        set MaskFile "$CovDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 33 -fmt $C4toC33 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 33 -fmt $C4toC33 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CovDirOutput/C33_$C4toC33.bin" $FinalNlig $FinalNcol 4
        if {"$BMPC4toC33"=="1"} {
            if {"$C4toC33"=="mod"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C33_mod.bin"
                set BMPFileOutput "$CovDirOutput/C33_mod.bmp"
                }
            if {"$C4toC33"=="db"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C33_db.bin"
                set BMPFileOutput "$CovDirOutput/C33_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
            }
        }

    if {"$C4toC34"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CovDirOutput/C34_$C4toC34.bin"
        set MaskCmd ""
        set MaskFile "$CovDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 34 -fmt $C4toC34 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 34 -fmt $C4toC34 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CovDirOutput/C34_$C4toC34.bin" $FinalNlig $FinalNcol 4
        if {"$BMPC4toC34"=="1"} {
            if {"$C4toC34"=="mod"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C34_mod.bin"
                set BMPFileOutput "$CovDirOutput/C34_mod.bmp"
                }
            if {"$C4toC34"=="db"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C34_db.bin"
                set BMPFileOutput "$CovDirOutput/C34_db.bmp"
                }
            if {"$C4toC34"=="pha"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C34_pha.bin"
                set BMPFileOutput "$CovDirOutput/C34_pha.bmp"
                }
            if {"$C4toC34"=="pha"} {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real hsv  $FinalNcol  0  0 $FinalNlig  $FinalNcol 0 -180 180
                } else {
                PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
                }
            }
        }

    if {"$C4toC44"!=""} {
        set Fonction "Creation of the Binary Data File :"
        set Fonction2 "$CovDirOutput/C44_$C4toC44.bin"
        set MaskCmd ""
        set MaskFile "$CovDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_elements.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 44 -fmt $C4toC44 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_elements.exe -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -elt 44 -fmt $C4toC44 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        EnviWriteConfig "$CovDirOutput/C44_$C4toC44.bin" $FinalNlig $FinalNcol 4
        if {"$BMPC4toC44"=="1"} {
            if {"$C4toC44"=="mod"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C44_mod.bin"
                set BMPFileOutput "$CovDirOutput/C44_mod.bmp"
                }
            if {"$C4toC44"=="db"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/C44_db.bin"
                set BMPFileOutput "$CovDirOutput/C44_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
            }
        }

    if {"$C4toSpan"!=""} {
        set Fonction "Creation of the Binary Data File :"
        if {"$C4toSpan"=="lin"} {
            set Fonction2 "$CovDirOutput/span.bin"
            }
        if {"$C4toSpan"=="db"} {
            set Fonction2 "$CovDirOutput/span_db.bin"
            }
        set MaskCmd ""
        set MaskFile "$CovDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        TextEditorRunTrace "Process The Function Soft/data_process_sngl/process_span.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -fmt $C4toSpan -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/data_process_sngl/process_span.exe -id \x22$CovDirInput\x22 -od \x22$CovDirOutput\x22 -iodf C4 -fmt $C4toSpan -nwr 1 -nwc 1 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -mem $PSPMemory -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if {"$C4toSpan"=="lin"} {EnviWriteConfig "$CovDirOutput/span.bin" $FinalNlig $FinalNcol 4}
        if {"$C4toSpan"=="db"} {EnviWriteConfig "$CovDirOutput/span_db.bin" $FinalNlig $FinalNcol 4}
        if {"$BMPC4toSpan"=="1"} {
            if {"$C4toSpan"=="lin"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/span.bin"
                set BMPFileOutput "$CovDirOutput/span.bmp"
                }
            if {"$C4toSpan"=="db"} {
                set BMPDirInput $CovDirOutput
                set BMPFileInput "$CovDirOutput/span_db.bin"
                set BMPFileOutput "$CovDirOutput/span_db.bmp"
                }
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real gray  $FinalNcol  0  0 $FinalNlig  $FinalNcol 1 0 0
            }
        }
    }
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel57); TextEditorRunTrace "Close Window Covariance Elements C4" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button100" vTcl:WidgetProc "Toplevel57" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CovarianceElementsC4.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button101" vTcl:WidgetProc "Toplevel57" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel57); TextEditorRunTrace "Close Window Covariance Elements C4" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button102" vTcl:WidgetProc "Toplevel57" 1
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
    pack $top.cpd84 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra59 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra61 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra62 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra63 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra64 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra65 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra67 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra68 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra69 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra70 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra72 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra75 \
        -in $top -anchor center -expand 1 -fill x -side top 
    pack $top.fra74 \
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
Window show .top57

main $argc $argv
