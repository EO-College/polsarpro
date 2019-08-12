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
        {{[file join . GUI Images ColorMap_Gray.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}
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
    set base .top434
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
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd81 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd82 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd82 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd71
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra66 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra66
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd69
    namespace eval ::widgets::$site_4_0.lab72 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.but74 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_3_0.cpd67 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.che84 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra71
    namespace eval ::widgets::$site_6_0.lab72 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.but74 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$base.cpd78 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd78 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra71
    namespace eval ::widgets::$site_5_0.lab72 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but74 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd76
    namespace eval ::widgets::$site_5_0.lab72 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but74 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd77
    namespace eval ::widgets::$site_5_0.lab72 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.but74 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-command 1 -image 1 -pady 1}
    }
    namespace eval ::widgets::$base.tit81 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit81 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd82
    namespace eval ::widgets::$site_5_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra39
    namespace eval ::widgets::$site_6_0.lab33 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra40
    namespace eval ::widgets::$site_6_0.ent34 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.ent36 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd78
    namespace eval ::widgets::$site_5_0.fra39 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra39
    namespace eval ::widgets::$site_6_0.lab34 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab35 {
        array set save {-padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra40 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra40
    namespace eval ::widgets::$site_6_0.ent36 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.ent37 {
        array set save {-background 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.tit84 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit84 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.tit67 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.tit67 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.com68 {
        array set save {-entrybg 1 -modifycmd 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.lab66 {
        array set save {-image 1 -relief 1}
    }
    namespace eval ::widgets::$site_5_0.cpd69 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd69 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.com68 {
        array set save {-entrybg 1 -modifycmd 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.lab67 {
        array set save {-image 1 -relief 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-text 1}
    }
    set site_7_0 [$site_5_0.cpd70 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.com68 {
        array set save {-entrybg 1 -modifycmd 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd68 {
        array set save {-image 1 -relief 1}
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
            vTclWindow.top434
            WishartScattModelBasedUpdate
            WishartScattModelBasedColorMapFile
            WishartScattModelBasedUpdateBMP
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
## Procedure:  WishartScattModelBasedUpdate

proc ::WishartScattModelBasedUpdate {} {
global WishartScattModelBasedDirInput WishartScattModelBasedColorMapList
global WishartScattModelBasedColorMapSBString WishartScattModelBasedColorMapSBFile
global WishartScattModelBasedColorMapDBString WishartScattModelBasedColorMapDBFile
global WishartScattModelBasedColorMapRVString WishartScattModelBasedColorMapRVFile
global COLORMAPDir VarError ErrorMessage

set WishartScattModelBasedColorMapList(0) ""
for {set i 1} {$i < 100} {incr i } { set WishartScattModelBasedColorMapList($i) "" }

set NumColorMapList 1
set WishartScattModelBasedColorMapList(1) ""

if [file exists "$COLORMAPDir/ColorMap_AUTUMN.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Autumn"
    }
if [file exists "$COLORMAPDir/ColorMap_BLUE.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Blue"
    }
if [file exists "$COLORMAPDir/ColorMap_BLUELIGHT.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Blue Light"
    }
if [file exists "$COLORMAPDir/ColorMap_BONE.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Bone"
    }
if [file exists "$COLORMAPDir/ColorMap_BROWN.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Brown"
    }
if [file exists "$COLORMAPDir/ColorMap_COOL.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Cool"
    }
if [file exists "$COLORMAPDir/ColorMap_GREEN.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Green"
    }
if [file exists "$COLORMAPDir/ColorMap_GREENLIGHT.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Green Light"
    }
if [file exists "$COLORMAPDir/ColorMap_MAGENTA.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Magenta"
    }
if [file exists "$COLORMAPDir/ColorMap_OCEAN.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Ocean"
    }
if [file exists "$COLORMAPDir/ColorMap_ORANGE.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Orange"
    }
if [file exists "$COLORMAPDir/ColorMap_PURPLE.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Purple"
    }
if [file exists "$COLORMAPDir/ColorMap_RED.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Red"
    }
if [file exists "$COLORMAPDir/ColorMap_SPRING.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Spring"
    }
if [file exists "$COLORMAPDir/ColorMap_SUMMER.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Summer"
    }
if [file exists "$COLORMAPDir/ColorMap_WINTER.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Winter"
    }
if [file exists "$COLORMAPDir/ColorMap_YELLOW.pal"] {
    incr NumColorMapList
    set WishartScattModelBasedColorMapList($NumColorMapList) "Yellow"
    }


set config "true" 
if {$NumColorMapList == 1} {              
    set VarError ""
    set ErrorMessage "THERE IS A PROBLEM WITH THE COLORMAPS" 
    Window show .top44; TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }

if {$config == "true"} {              
    set WishartScattModelBasedColorMapSBString ""
    for {set i 1} {$i <= $NumColorMapList} {incr i } { lappend WishartScattModelBasedColorMapSBString $WishartScattModelBasedColorMapList($i) }
    .top434.tit84.f.cpd69.tit67.f.com68 configure -values $WishartScattModelBasedColorMapSBString
    set WishartScattModelBasedColorMapSB $WishartScattModelBasedColorMapList(1)

    set WishartScattModelBasedColorMapDBBString ""
    for {set i 1} {$i <= $NumColorMapList} {incr i } { lappend WishartScattModelBasedColorMapDBString $WishartScattModelBasedColorMapList($i) }
    .top434.tit84.f.cpd69.cpd69.f.com68 configure -values $WishartScattModelBasedColorMapDBString
    set WishartScattModelBasedColorMapDB $WishartScattModelBasedColorMapList(1)

    set WishartScattModelBasedColorMapRVString ""
    for {set i 1} {$i <= $NumColorMapList} {incr i } { lappend WishartScattModelBasedColorMapRVString $WishartScattModelBasedColorMapList($i) }
    .top434.tit84.f.cpd69.cpd70.f.com68 configure -values $WishartScattModelBasedColorMapRVString
    set WishartScattModelBasedColorMapRV $WishartScattModelBasedColorMapList(1)
  
    set WishartScattModelBasedColorMapSBFile ""; set WishartScattModelBasedColorMapDBFile ""; set WishartScattModelBasedColorMapRVFile ""
    }
}
#############################################################################
## Procedure:  WishartScattModelBasedColorMapFile

proc ::WishartScattModelBasedColorMapFile {} {
global WishartScattModelBasedColorMapSB WishartScattModelBasedColorMapSBFile
global WishartScattModelBasedColorMapDB WishartScattModelBasedColorMapDBFile
global WishartScattModelBasedColorMapRV WishartScattModelBasedColorMapRVFile
global VarError ErrorMessage COLORMAPDir

set WishartScattModelBasedColorMapSBFile ""
if {$WishartScattModelBasedColorMapSB == "Autumn"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_AUTUMN.pal" }
if {$WishartScattModelBasedColorMapSB == "Blue"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_BLUE.pal" }
if {$WishartScattModelBasedColorMapSB == "Blue Light"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_BLUELIGHT.pal" }
if {$WishartScattModelBasedColorMapSB == "Bone"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_BONE.pal" }
if {$WishartScattModelBasedColorMapSB == "Brown"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_BROWN.pal" }
if {$WishartScattModelBasedColorMapSB == "Cool"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_COOL.pal" }
if {$WishartScattModelBasedColorMapSB == "Green"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_GREEN.pal" }
if {$WishartScattModelBasedColorMapSB == "Green Light"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_GREENLIGHT.pal" }
if {$WishartScattModelBasedColorMapSB == "Magenta"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_MAGENTA.pal" }
if {$WishartScattModelBasedColorMapSB == "Ocean"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_OCEAN.pal" }
if {$WishartScattModelBasedColorMapSB == "Orange"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_ORANGE.pal" }
if {$WishartScattModelBasedColorMapSB == "Purple"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_PURPLE.pal" }
if {$WishartScattModelBasedColorMapSB == "Red"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_RED.pal" }
if {$WishartScattModelBasedColorMapSB == "Spring"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_SPRING.pal" }
if {$WishartScattModelBasedColorMapSB == "Summer"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_SUMMER.pal" }
if {$WishartScattModelBasedColorMapSB == "Winter"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_WINTER.pal" }
if {$WishartScattModelBasedColorMapSB == "Yellow"} { set WishartScattModelBasedColorMapSBFile "$COLORMAPDir/ColorMap_YELLOW.pal" }

set WishartScattModelBasedColorMapDBFile ""
if {$WishartScattModelBasedColorMapDB == "Autumn"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_AUTUMN.pal" }
if {$WishartScattModelBasedColorMapDB == "Blue"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_BLUE.pal" }
if {$WishartScattModelBasedColorMapDB == "Blue Light"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_BLUELIGHT.pal" }
if {$WishartScattModelBasedColorMapDB == "Bone"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_BONE.pal" }
if {$WishartScattModelBasedColorMapDB == "Brown"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_BROWN.pal" }
if {$WishartScattModelBasedColorMapDB == "Cool"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_COOL.pal" }
if {$WishartScattModelBasedColorMapDB == "Green"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_GREEN.pal" }
if {$WishartScattModelBasedColorMapDB == "Green Light"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_GREENLIGHT.pal" }
if {$WishartScattModelBasedColorMapDB == "Magenta"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_MAGENTA.pal" }
if {$WishartScattModelBasedColorMapDB == "Ocean"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_OCEAN.pal" }
if {$WishartScattModelBasedColorMapDB == "Orange"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_ORANGE.pal" }
if {$WishartScattModelBasedColorMapDB == "Purple"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_PURPLE.pal" }
if {$WishartScattModelBasedColorMapDB == "Red"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_RED.pal" }
if {$WishartScattModelBasedColorMapDB == "Spring"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_SPRING.pal" }
if {$WishartScattModelBasedColorMapDB == "Summer"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_SUMMER.pal" }
if {$WishartScattModelBasedColorMapDB == "Winter"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_WINTER.pal" }
if {$WishartScattModelBasedColorMapDB == "Yellow"} { set WishartScattModelBasedColorMapDBFile "$COLORMAPDir/ColorMap_YELLOW.pal" }

set WishartScattModelBasedColorMapRVFile ""
if {$WishartScattModelBasedColorMapRV == "Autumn"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_AUTUMN.pal" }
if {$WishartScattModelBasedColorMapRV == "Blue"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_BLUE.pal" }
if {$WishartScattModelBasedColorMapRV == "Blue Light"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_BLUELIGHT.pal" }
if {$WishartScattModelBasedColorMapRV == "Bone"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_BONE.pal" }
if {$WishartScattModelBasedColorMapRV == "Brown"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_BROWN.pal" }
if {$WishartScattModelBasedColorMapRV == "Cool"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_COOL.pal" }
if {$WishartScattModelBasedColorMapRV == "Green"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_GREEN.pal" }
if {$WishartScattModelBasedColorMapRV == "Green Light"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_GREENLIGHT.pal" }
if {$WishartScattModelBasedColorMapRV == "Magenta"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_MAGENTA.pal" }
if {$WishartScattModelBasedColorMapRV == "Ocean"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_OCEAN.pal" }
if {$WishartScattModelBasedColorMapRV == "Orange"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_ORANGE.pal" }
if {$WishartScattModelBasedColorMapRV == "Purple"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_PURPLE.pal" }
if {$WishartScattModelBasedColorMapRV == "Red"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_RED.pal" }
if {$WishartScattModelBasedColorMapRV == "Spring"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_SPRING.pal" }
if {$WishartScattModelBasedColorMapRV == "Summer"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_SUMMER.pal" }
if {$WishartScattModelBasedColorMapRV == "Winter"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_WINTER.pal" }
if {$WishartScattModelBasedColorMapRV == "Yellow"} { set WishartScattModelBasedColorMapRVFile "$COLORMAPDir/ColorMap_YELLOW.pal" }
}
#############################################################################
## Procedure:  WishartScattModelBasedUpdateBMP

proc ::WishartScattModelBasedUpdateBMP {} {
global WishartScattModelBasedColorMapSB WishartScattModelBasedColorMapDB WishartScattModelBasedColorMapRV

package require Img

image create photo WishartScattModelBasedColorMapSBBMP
WishartScattModelBasedColorMapSBBMP blank
.top434.tit84.f.cpd69.tit67.f.lab66 configure -anchor nw -image WishartScattModelBasedColorMapSBBMP
image delete WishartScattModelBasedColorMapSBBMP
image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_Gray.gif"
if {$WishartScattModelBasedColorMapSB == "Autumn"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_AUTUMN.gif" }
if {$WishartScattModelBasedColorMapSB == "Blue"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_BLUE.gif" }
if {$WishartScattModelBasedColorMapSB == "Blue Light"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_BLUELIGHT.gif" }
if {$WishartScattModelBasedColorMapSB == "Bone"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_BONE.gif" }
if {$WishartScattModelBasedColorMapSB == "Brown"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_BROWN.gif" }
if {$WishartScattModelBasedColorMapSB == "Cool"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_COOL.gif" }
if {$WishartScattModelBasedColorMapSB == "Green"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_GREEN.gif" }
if {$WishartScattModelBasedColorMapSB == "Green Light"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_GREENLIGHT.gif" }
if {$WishartScattModelBasedColorMapSB == "Magenta"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_MAGENTA.gif" }
if {$WishartScattModelBasedColorMapSB == "Ocean"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_OCEAN.gif" }
if {$WishartScattModelBasedColorMapSB == "Orange"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_ORANGE.gif" }
if {$WishartScattModelBasedColorMapSB == "Purple"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_PURPLE.gif" }
if {$WishartScattModelBasedColorMapSB == "Red"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_RED.gif" }
if {$WishartScattModelBasedColorMapSB == "Spring"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_SPRING.gif" }
if {$WishartScattModelBasedColorMapSB == "Summer"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_SUMMER.gif" }
if {$WishartScattModelBasedColorMapSB == "Winter"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_WINTER.gif" }
if {$WishartScattModelBasedColorMapSB == "Yellow"} { image create photo WishartScattModelBasedColorMapSBBMP -file "GUI/Images/ColorMap_YELLOW.gif" }
.top434.tit84.f.cpd69.tit67.f.lab66 configure -anchor nw -image WishartScattModelBasedColorMapSBBMP

image create photo WishartScattModelBasedColorMapDBBMP
WishartScattModelBasedColorMapDBBMP blank
.top434.tit84.f.cpd69.cpd69.f.lab67 configure -anchor nw -image WishartScattModelBasedColorMapDBBMP
image delete WishartScattModelBasedColorMapDBBMP
image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_Gray.gif"
if {$WishartScattModelBasedColorMapDB == "Autumn"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_AUTUMN.gif" }
if {$WishartScattModelBasedColorMapDB == "Blue"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_BLUE.gif" }
if {$WishartScattModelBasedColorMapDB == "Blue Light"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_BLUELIGHT.gif" }
if {$WishartScattModelBasedColorMapDB == "Bone"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_BONE.gif" }
if {$WishartScattModelBasedColorMapDB == "Brown"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_BROWN.gif" }
if {$WishartScattModelBasedColorMapDB == "Cool"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_COOL.gif" }
if {$WishartScattModelBasedColorMapDB == "Green"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_GREEN.gif" }
if {$WishartScattModelBasedColorMapDB == "Green Light"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_GREENLIGHT.gif" }
if {$WishartScattModelBasedColorMapDB == "Magenta"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_MAGENTA.gif" }
if {$WishartScattModelBasedColorMapDB == "Ocean"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_OCEAN.gif" }
if {$WishartScattModelBasedColorMapDB == "Orange"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_ORANGE.gif" }
if {$WishartScattModelBasedColorMapDB == "Purple"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_PURPLE.gif" }
if {$WishartScattModelBasedColorMapDB == "Red"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_RED.gif" }
if {$WishartScattModelBasedColorMapDB == "Spring"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_SPRING.gif" }
if {$WishartScattModelBasedColorMapDB == "Summer"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_SUMMER.gif" }
if {$WishartScattModelBasedColorMapDB == "Winter"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_WINTER.gif" }
if {$WishartScattModelBasedColorMapDB == "Yellow"} { image create photo WishartScattModelBasedColorMapDBBMP -file "GUI/Images/ColorMap_YELLOW.gif" }
.top434.tit84.f.cpd69.cpd69.f.lab67 configure -anchor nw -image WishartScattModelBasedColorMapDBBMP

image create photo WishartScattModelBasedColorMapRVBMP
WishartScattModelBasedColorMapRVBMP blank
.top434.tit84.f.cpd69.cpd70.f.cpd68 configure -anchor nw -image WishartScattModelBasedColorMapRVBMP
image delete WishartScattModelBasedColorMapRVBMP
image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_Gray.gif"
if {$WishartScattModelBasedColorMapRV == "Autumn"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_AUTUMN.gif" }
if {$WishartScattModelBasedColorMapRV == "Blue"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_BLUE.gif" }
if {$WishartScattModelBasedColorMapRV == "Blue Light"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_BLUELIGHT.gif" }
if {$WishartScattModelBasedColorMapRV == "Bone"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_BONE.gif" }
if {$WishartScattModelBasedColorMapRV == "Brown"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_BROWN.gif" }
if {$WishartScattModelBasedColorMapRV == "Cool"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_COOL.gif" }
if {$WishartScattModelBasedColorMapRV == "Green"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_GREEN.gif" }
if {$WishartScattModelBasedColorMapRV == "Green Light"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_GREENLIGHT.gif" }
if {$WishartScattModelBasedColorMapRV == "Magenta"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_MAGENTA.gif" }
if {$WishartScattModelBasedColorMapRV == "Ocean"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_OCEAN.gif" }
if {$WishartScattModelBasedColorMapRV == "Orange"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_ORANGE.gif" }
if {$WishartScattModelBasedColorMapRV == "Purple"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_PURPLE.gif" }
if {$WishartScattModelBasedColorMapRV == "Red"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_RED.gif" }
if {$WishartScattModelBasedColorMapRV == "Spring"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_SPRING.gif" }
if {$WishartScattModelBasedColorMapRV == "Summer"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_SUMMER.gif" }
if {$WishartScattModelBasedColorMapRV == "Winter"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_WINTER.gif" }
if {$WishartScattModelBasedColorMapRV == "Yellow"} { image create photo WishartScattModelBasedColorMapRVBMP -file "GUI/Images/ColorMap_YELLOW.gif" }
.top434.tit84.f.cpd69.cpd70.f.cpd68 configure -anchor nw -image WishartScattModelBasedColorMapRVBMP
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

proc vTclWindow.top434 {base} {
    if {$base == ""} {
        set base .top434
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
    wm geometry $top 500x540+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: Wishart - Scattering Model Based Classification"
    vTcl:DefineAlias "$top" "Toplevel434" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd79 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd79" "Frame4" vTcl:WidgetProc "Toplevel434" 1
    set site_3_0 $top.cpd79
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel434" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable WishartScattModelBasedDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel434" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame15" vTcl:WidgetProc "Toplevel434" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -padx 1 -pady 0 -relief flat -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button42" vTcl:WidgetProc "Toplevel434" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel434" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable WishartScattModelBasedOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel434" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame16" vTcl:WidgetProc "Toplevel434" 1
    set site_6_0 $site_5_0.cpd91
    label $site_6_0.cpd73 \
        -padx 1 -text / 
    vTcl:DefineAlias "$site_6_0.cpd73" "Label14" vTcl:WidgetProc "Toplevel434" 1
    entry $site_6_0.cpd74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable WishartScattModelBasedOutputSubDir \
        -width 3 
    vTcl:DefineAlias "$site_6_0.cpd74" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel434" 1
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd71" "Frame17" vTcl:WidgetProc "Toplevel434" 1
    set site_6_0 $site_5_0.cpd71
    button $site_6_0.cpd80 \
        \
        -command {global DirName DataDir WishartScattModelBasedOutputDir

set WishartScattModelBasedDirOutputTmp $WishartScattModelBasedOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set WishartScattModelBasedOutputDir $DirName
    } else {
    set WishartScattModelBasedOutputDir $WishartScattModelBasedDirOutputTmp
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
    vTcl:DefineAlias "$top.fra28" "Frame9" vTcl:WidgetProc "Toplevel434" 1
    set site_3_0 $top.fra28
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel434" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel434" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel434" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel434" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel434" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel434" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel434" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel434" 1
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
    TitleFrame $top.cpd80 \
        -ipad 0 -text {Single Bounce Scattering File} 
    vTcl:DefineAlias "$top.cpd80" "TitleFrame11" vTcl:WidgetProc "Toplevel434" 1
    bind $top.cpd80 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd80 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable WishartScattModelBasedSBFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh10" vTcl:WidgetProc "Toplevel434" 1
    frame $site_4_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame19" vTcl:WidgetProc "Toplevel434" 1
    set site_5_0 $site_4_0.cpd71
    button $site_5_0.cpd80 \
        \
        -command {global WishartScattModelBasedDirInput WishartScattModelBasedSBFile

set WishartScattModelBasedSBFile ""
set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $WishartScattModelBasedDirInput $types "INPUT SB FILE"
    
if {$FileName != ""} {
    set WishartScattModelBasedSBFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    bindtags $site_5_0.cpd80 "$site_5_0.cpd80 Button $top all _vTclBalloon"
    bind $site_5_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.cpd81 \
        -ipad 0 -text {Double Bounce Scattering File} 
    vTcl:DefineAlias "$top.cpd81" "TitleFrame12" vTcl:WidgetProc "Toplevel434" 1
    bind $top.cpd81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd81 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable WishartScattModelBasedDBFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh11" vTcl:WidgetProc "Toplevel434" 1
    frame $site_4_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame21" vTcl:WidgetProc "Toplevel434" 1
    set site_5_0 $site_4_0.cpd71
    button $site_5_0.cpd80 \
        \
        -command {global WishartScattModelBasedDirInput WishartScattModelBasedDBFile

set WishartScattModelBasedDBFile ""
set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $WishartScattModelBasedDirInput $types "INPUT DB FILE"
    
if {$FileName != ""} {
    set WishartScattModelBasedDBFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    bindtags $site_5_0.cpd80 "$site_5_0.cpd80 Button $top all _vTclBalloon"
    bind $site_5_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.cpd82 \
        -ipad 0 -text {Random / Volume Scattering File} 
    vTcl:DefineAlias "$top.cpd82" "TitleFrame13" vTcl:WidgetProc "Toplevel434" 1
    bind $top.cpd82 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd82 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable WishartScattModelBasedRVFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "EntryTopXXCh12" vTcl:WidgetProc "Toplevel434" 1
    frame $site_4_0.cpd71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd71" "Frame22" vTcl:WidgetProc "Toplevel434" 1
    set site_5_0 $site_4_0.cpd71
    button $site_5_0.cpd80 \
        \
        -command {global WishartScattModelBasedDirInput WishartScattModelBasedRVFile

set WishartScattModelBasedRVFile ""
set types {
{{BIN Files}        {.bin}        }
}
set FileName ""
OpenFile $WishartScattModelBasedDirInput $types "INPUT RV FILE"
    
if {$FileName != ""} {
    set WishartScattModelBasedRVFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    bindtags $site_5_0.cpd80 "$site_5_0.cpd80 Button $top all _vTclBalloon"
    bind $site_5_0.cpd80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra66 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra66" "Frame11" vTcl:WidgetProc "Toplevel434" 1
    set site_3_0 $top.fra66
    frame $site_3_0.cpd69 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd69" "Frame13" vTcl:WidgetProc "Toplevel434" 1
    set site_4_0 $site_3_0.cpd69
    label $site_4_0.lab72 \
        -text {Initial Number of Clusters} 
    vTcl:DefineAlias "$site_4_0.lab72" "Label2" vTcl:WidgetProc "Toplevel434" 1
    entry $site_4_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable WishartScattModelBasedClusterInit \
        -width 5 
    vTcl:DefineAlias "$site_4_0.ent73" "Entry2" vTcl:WidgetProc "Toplevel434" 1
    button $site_4_0.but74 \
        \
        -command {global WishartScattModelBasedClusterInit 

set Tmp [expr $WishartScattModelBasedClusterInit - 10]
if {$Tmp == 10} { set Tmp 50 }
set WishartScattModelBasedClusterInit $Tmp} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_4_0.but74" "Button3" vTcl:WidgetProc "Toplevel434" 1
    button $site_4_0.cpd75 \
        \
        -command {global WishartScattModelBasedClusterInit 

set Tmp [expr $WishartScattModelBasedClusterInit + 10]
if {$Tmp == 60} { set Tmp 20 }
set WishartScattModelBasedClusterInit $Tmp} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_4_0.cpd75" "Button4" vTcl:WidgetProc "Toplevel434" 1
    pack $site_4_0.lab72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.ent73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_4_0.but74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $site_3_0.cpd67 \
        -text {Mixed Scattering Type} 
    vTcl:DefineAlias "$site_3_0.cpd67" "TitleFrame14" vTcl:WidgetProc "Toplevel434" 1
    bind $site_3_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd67 getframe]
    checkbutton $site_5_0.che84 \
        \
        -command {global WishartScattModelBasedMixedFlag WishartScattModelBasedMixedThreshold

if {$WishartScattModelBasedMixedFlag == 1} {
    set WishartScattModelBasedMixedThreshold 0.5            
    $widget(Label434_1) configure -state normal; $widget(Entry434_1) configure -state disable
    $widget(Entry434_1) configure -disabledbackground #FFFFFF
    $widget(Button434_1) configure -state normal; $widget(Button434_2) configure -state normal
    }

if {$WishartScattModelBasedMixedFlag == 0} {
    set WishartScattModelBasedMixedThreshold ""            
    $widget(Label434_1) configure -state disable; $widget(Entry434_1) configure -state disable
    $widget(Entry434_1) configure -disabledbackground $PSPBackgroundColor
    $widget(Button434_1) configure -state disable; $widget(Button434_2) configure -state disable
    }} \
        -variable WishartScattModelBasedMixedFlag 
    vTcl:DefineAlias "$site_5_0.che84" "Checkbutton2" vTcl:WidgetProc "Toplevel434" 1
    frame $site_5_0.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra71" "Frame12" vTcl:WidgetProc "Toplevel434" 1
    set site_6_0 $site_5_0.fra71
    label $site_6_0.lab72 \
        -text Threshold 
    vTcl:DefineAlias "$site_6_0.lab72" "Label434_1" vTcl:WidgetProc "Toplevel434" 1
    entry $site_6_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable WishartScattModelBasedMixedThreshold \
        -width 5 
    vTcl:DefineAlias "$site_6_0.ent73" "Entry434_1" vTcl:WidgetProc "Toplevel434" 1
    button $site_6_0.but74 \
        \
        -command {global WishartScattModelBasedMixedThreshold

set Tmp [expr $WishartScattModelBasedMixedThreshold - 0.1]
if {$Tmp == "0.1"} { set Tmp "0.8" }
set WishartScattModelBasedMixedThreshold $Tmp} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_6_0.but74" "Button434_1" vTcl:WidgetProc "Toplevel434" 1
    button $site_6_0.cpd75 \
        \
        -command {global WishartScattModelBasedMixedThreshold

set Tmp [expr $WishartScattModelBasedMixedThreshold + 0.1]
if {$Tmp == "0.9"} { set Tmp "0.2" }
set WishartScattModelBasedMixedThreshold $Tmp} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_6_0.cpd75" "Button434_2" vTcl:WidgetProc "Toplevel434" 1
    pack $site_6_0.lab72 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent73 \
        -in $site_6_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_6_0.but74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.che84 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 5 -ipady 5 \
        -side left 
    pack $site_3_0.cpd67 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd78 \
        -text {Final Number of Clusters % Scattering Type (Minimum Value)} 
    vTcl:DefineAlias "$top.cpd78" "TitleFrame4" vTcl:WidgetProc "Toplevel434" 1
    bind $top.cpd78 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd78 getframe]
    frame $site_4_0.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra71" "Frame5" vTcl:WidgetProc "Toplevel434" 1
    set site_5_0 $site_4_0.fra71
    label $site_5_0.lab72 \
        -text {Single Bounce} 
    vTcl:DefineAlias "$site_5_0.lab72" "Label7" vTcl:WidgetProc "Toplevel434" 1
    entry $site_5_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable WishartScattModelBasedSBClusterFin \
        -width 5 
    vTcl:DefineAlias "$site_5_0.ent73" "Entry4" vTcl:WidgetProc "Toplevel434" 1
    button $site_5_0.but74 \
        \
        -command {global WishartScattModelBasedSBClusterFin

set Tmp [expr $WishartScattModelBasedSBClusterFin - 1]
if {$Tmp == 2} { set Tmp 10 }
set WishartScattModelBasedSBClusterFin $Tmp} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.but74" "Button7" vTcl:WidgetProc "Toplevel434" 1
    button $site_5_0.cpd75 \
        \
        -command {global WishartScattModelBasedSBClusterFin

set Tmp [expr $WishartScattModelBasedSBClusterFin + 1]
if {$Tmp == 11} { set Tmp 3 }
set WishartScattModelBasedSBClusterFin $Tmp} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_5_0.cpd75" "Button8" vTcl:WidgetProc "Toplevel434" 1
    pack $site_5_0.lab72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.but74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd76" "Frame6" vTcl:WidgetProc "Toplevel434" 1
    set site_5_0 $site_4_0.cpd76
    label $site_5_0.lab72 \
        -text {Double Bounce} 
    vTcl:DefineAlias "$site_5_0.lab72" "Label8" vTcl:WidgetProc "Toplevel434" 1
    entry $site_5_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable WishartScattModelBasedDBClusterFin \
        -width 5 
    vTcl:DefineAlias "$site_5_0.ent73" "Entry5" vTcl:WidgetProc "Toplevel434" 1
    button $site_5_0.but74 \
        \
        -command {global WishartScattModelBasedDBClusterFin

set Tmp [expr $WishartScattModelBasedDBClusterFin - 1]
if {$Tmp == 2} { set Tmp 10 }
set WishartScattModelBasedDBClusterFin $Tmp} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.but74" "Button9" vTcl:WidgetProc "Toplevel434" 1
    button $site_5_0.cpd75 \
        \
        -command {global WishartScattModelBasedDBClusterFin

set Tmp [expr $WishartScattModelBasedDBClusterFin + 1]
if {$Tmp == 11} { set Tmp 3 }
set WishartScattModelBasedDBClusterFin $Tmp} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_5_0.cpd75" "Button10" vTcl:WidgetProc "Toplevel434" 1
    pack $site_5_0.lab72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.but74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd77" "Frame7" vTcl:WidgetProc "Toplevel434" 1
    set site_5_0 $site_4_0.cpd77
    label $site_5_0.lab72 \
        -text {Random / Volume} 
    vTcl:DefineAlias "$site_5_0.lab72" "Label9" vTcl:WidgetProc "Toplevel434" 1
    entry $site_5_0.ent73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable WishartScattModelBasedRVClusterFin \
        -width 5 
    vTcl:DefineAlias "$site_5_0.ent73" "Entry10" vTcl:WidgetProc "Toplevel434" 1
    button $site_5_0.but74 \
        \
        -command {global WishartScattModelBasedRVClusterFin

set Tmp [expr $WishartScattModelBasedRVClusterFin - 1]
if {$Tmp == 2} { set Tmp 10 }
set WishartScattModelBasedRVClusterFin $Tmp} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 
    vTcl:DefineAlias "$site_5_0.but74" "Button11" vTcl:WidgetProc "Toplevel434" 1
    button $site_5_0.cpd75 \
        \
        -command {global WishartScattModelBasedRVClusterFin

set Tmp [expr $WishartScattModelBasedRVClusterFin + 1]
if {$Tmp == 11} { set Tmp 3 }
set WishartScattModelBasedRVClusterFin $Tmp} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 
    vTcl:DefineAlias "$site_5_0.cpd75" "Button12" vTcl:WidgetProc "Toplevel434" 1
    pack $site_5_0.lab72 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent73 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_5_0.but74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.fra71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit81 \
        -ipad 0 -text {Classification Parameters} 
    vTcl:DefineAlias "$top.tit81" "TitleFrame1" vTcl:WidgetProc "Toplevel434" 1
    bind $top.tit81 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit81 getframe]
    frame $site_4_0.cpd82 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd82" "Frame53" vTcl:WidgetProc "Toplevel434" 1
    set site_5_0 $site_4_0.cpd82
    frame $site_5_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_5_0.fra39" "Frame50" vTcl:WidgetProc "Toplevel434" 1
    set site_6_0 $site_5_0.fra39
    label $site_6_0.lab33 \
        -padx 1 -text {% of Pixels Switching Class} 
    vTcl:DefineAlias "$site_6_0.lab33" "Label36" vTcl:WidgetProc "Toplevel434" 1
    label $site_6_0.lab34 \
        -padx 1 -text {Maximum Number of Iterations} 
    vTcl:DefineAlias "$site_6_0.lab34" "Label37" vTcl:WidgetProc "Toplevel434" 1
    pack $site_6_0.lab33 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.lab34 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    frame $site_5_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_5_0.fra40" "Frame51" vTcl:WidgetProc "Toplevel434" 1
    set site_6_0 $site_5_0.fra40
    entry $site_6_0.ent34 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable WishartScattModelBasedPourcentage \
        -width 5 
    vTcl:DefineAlias "$site_6_0.ent34" "Entry24" vTcl:WidgetProc "Toplevel434" 1
    entry $site_6_0.ent36 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable WishartScattModelBasedIteration \
        -width 5 
    vTcl:DefineAlias "$site_6_0.ent36" "Entry23" vTcl:WidgetProc "Toplevel434" 1
    pack $site_6_0.ent34 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.ent36 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.fra39 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.fra40 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    checkbutton $site_4_0.cpd83 \
        -text BMP -variable BMPWishartScattModelBased 
    vTcl:DefineAlias "$site_4_0.cpd83" "Checkbutton59" vTcl:WidgetProc "Toplevel434" 1
    frame $site_4_0.cpd78 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd78" "Frame54" vTcl:WidgetProc "Toplevel434" 1
    set site_5_0 $site_4_0.cpd78
    frame $site_5_0.fra39 \
        -borderwidth 2 -height 6 -width 143 
    vTcl:DefineAlias "$site_5_0.fra39" "Frame52" vTcl:WidgetProc "Toplevel434" 1
    set site_6_0 $site_5_0.fra39
    label $site_6_0.lab34 \
        -padx 1 -text {Window Size Row} 
    vTcl:DefineAlias "$site_6_0.lab34" "Label40" vTcl:WidgetProc "Toplevel434" 1
    label $site_6_0.lab35 \
        -padx 1 -text {Window Size Col} 
    vTcl:DefineAlias "$site_6_0.lab35" "Label41" vTcl:WidgetProc "Toplevel434" 1
    pack $site_6_0.lab34 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_6_0.lab35 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    frame $site_5_0.fra40 \
        -borderwidth 2 -height 6 -width 125 
    vTcl:DefineAlias "$site_5_0.fra40" "Frame55" vTcl:WidgetProc "Toplevel434" 1
    set site_6_0 $site_5_0.fra40
    entry $site_6_0.ent36 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable WishartScattModelBasedNwinL -width 5 
    vTcl:DefineAlias "$site_6_0.ent36" "Entry27" vTcl:WidgetProc "Toplevel434" 1
    entry $site_6_0.ent37 \
        -background white -disabledforeground #ff0000 -foreground #ff0000 \
        -justify center -textvariable WishartScattModelBasedNwinC -width 5 
    vTcl:DefineAlias "$site_6_0.ent37" "Entry28" vTcl:WidgetProc "Toplevel434" 1
    pack $site_6_0.ent36 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_6_0.ent37 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.fra39 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.fra40 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill y -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side right 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.tit84 \
        -ipad 0 -text {Color Maps % Scattering Type} 
    vTcl:DefineAlias "$top.tit84" "TitleFrame2" vTcl:WidgetProc "Toplevel434" 1
    bind $top.tit84 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit84 getframe]
    frame $site_4_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd69" "Frame8" vTcl:WidgetProc "Toplevel434" 1
    set site_5_0 $site_4_0.cpd69
    TitleFrame $site_5_0.tit67 \
        -text {Single Bounce} 
    vTcl:DefineAlias "$site_5_0.tit67" "TitleFrame6" vTcl:WidgetProc "Toplevel434" 1
    bind $site_5_0.tit67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.tit67 getframe]
    ComboBox $site_7_0.com68 \
        -entrybg white -modifycmd WishartScattModelBasedUpdateBMP \
        -takefocus 1 -textvariable WishartScattModelBasedColorMapSB -width 10 
    vTcl:DefineAlias "$site_7_0.com68" "ComboBox4" vTcl:WidgetProc "Toplevel434" 1
    bindtags $site_7_0.com68 "$site_7_0.com68 BwComboBox $top all"
    label $site_7_0.lab66 \
        \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Gray.gif]] \
        -relief ridge 
    vTcl:DefineAlias "$site_7_0.lab66" "Label4" vTcl:WidgetProc "Toplevel434" 1
    pack $site_7_0.com68 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.lab66 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_5_0.cpd69 \
        -text {Double Bounce} 
    vTcl:DefineAlias "$site_5_0.cpd69" "TitleFrame7" vTcl:WidgetProc "Toplevel434" 1
    bind $site_5_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd69 getframe]
    ComboBox $site_7_0.com68 \
        -entrybg white -modifycmd WishartScattModelBasedUpdateBMP \
        -takefocus 1 -textvariable WishartScattModelBasedColorMapDB -width 10 
    vTcl:DefineAlias "$site_7_0.com68" "ComboBox5" vTcl:WidgetProc "Toplevel434" 1
    bindtags $site_7_0.com68 "$site_7_0.com68 BwComboBox $top all"
    label $site_7_0.lab67 \
        \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Gray.gif]] \
        -relief ridge 
    vTcl:DefineAlias "$site_7_0.lab67" "Label5" vTcl:WidgetProc "Toplevel434" 1
    pack $site_7_0.com68 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.lab67 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_5_0.cpd70 \
        -text {Random / Volume} 
    vTcl:DefineAlias "$site_5_0.cpd70" "TitleFrame10" vTcl:WidgetProc "Toplevel434" 1
    bind $site_5_0.cpd70 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd70 getframe]
    ComboBox $site_7_0.com68 \
        -entrybg white -modifycmd WishartScattModelBasedUpdateBMP \
        -takefocus 1 -textvariable WishartScattModelBasedColorMapRV -width 10 
    vTcl:DefineAlias "$site_7_0.com68" "ComboBox6" vTcl:WidgetProc "Toplevel434" 1
    bindtags $site_7_0.com68 "$site_7_0.com68 BwComboBox $top all"
    label $site_7_0.cpd68 \
        \
        -image [vTcl:image:get_image [file join . GUI Images ColorMap_Gray.gif]] \
        -relief ridge 
    vTcl:DefineAlias "$site_7_0.cpd68" "Label6" vTcl:WidgetProc "Toplevel434" 1
    pack $site_7_0.com68 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd68 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.tit67 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd69 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra42 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra42" "Frame20" vTcl:WidgetProc "Toplevel434" 1
    set site_3_0 $top.fra42
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global WishartScattModelBasedDirInput WishartScattModelBasedDirOutput WishartScattModelBasedOutputDir WishartScattModelBasedOutputSubDir
global WishartScattModelBasedNwinL WishartScattModelBasedNwinC WishartScattModelBasedClassifFonction
global WishartScattModelBasedMixedFlag WishartScattModelBasedMixedThreshold
global WishartScattModelBasedPourcentage WishartScattModelBasedIteration BMPWishartScattModelBased
global WishartScattModelBasedSBFile WishartScattModelBasedColorMapSBFile
global WishartScattModelBasedDBFile WishartScattModelBasedColorMapDBFile
global WishartScattModelBasedRVFile WishartScattModelBasedColorMapRVFile
global WishartScattModelBasedClusterInit WishartScattModelBasedSBClusterFin WishartScattModelBasedDBClusterFin WishartScattModelBasedRVClusterFin
global Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2 OpenDirFile TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$OpenDirFile == 0} {

set WishartScattModelBasedDirOutput $WishartScattModelBasedOutputDir
if {$WishartScattModelBasedOutputSubDir != ""} {append WishartScattModelBasedDirOutput "/$WishartScattModelBasedOutputSubDir"}

    #####################################################################
    #Create Directory
    set WishartScattModelBasedDirOutput [PSPCreateDirectoryMask $WishartScattModelBasedDirOutput $WishartScattModelBasedOutputDir $WishartScattModelBasedDirInput]
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
    set TestVarName(4) "Window Size Row"; set TestVarType(4) "int"; set TestVarValue(4) $WishartScattModelBasedNwinL; set TestVarMin(4) "1"; set TestVarMax(4) "1000"
    set TestVarName(5) "Pourcentage"; set TestVarType(5) "float"; set TestVarValue(5) $WishartScattModelBasedPourcentage; set TestVarMin(5) "0"; set TestVarMax(5) "100"
    set TestVarName(6) "Iteration"; set TestVarType(6) "int"; set TestVarValue(6) $WishartScattModelBasedIteration; set TestVarMin(6) "1"; set TestVarMax(6) "100"
    set TestVarName(7) "Window Size Col"; set TestVarType(7) "int"; set TestVarValue(7) $WishartScattModelBasedNwinC; set TestVarMin(7) "1"; set TestVarMax(7) "1000"
    TestVar 8
    if {$TestVarError == "ok"} {

    WishartScattModelBasedColorMapFile

    set config "true"
    if {$WishartScattModelBasedSBFile == ""} {
        set config "false"
        set VarError ""
        set ErrorMessage "THE Single Bounce Scattering File DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if {$WishartScattModelBasedDBFile == ""} {
        set config "false"
        set VarError ""
        set ErrorMessage "THE Double Bounce Scattering File DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if {$WishartScattModelBasedRVFile == ""} {
        set config "false"
        set VarError ""
        set ErrorMessage "THE Random / Volume Scattering File DOES NOT EXIST"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if {$WishartScattModelBasedColorMapSBFile == ""} {
        set config "false"
        set VarError ""
        set ErrorMessage "SELECT THE Single Bounce Scattering Type COLOR MAP"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if {$WishartScattModelBasedColorMapDBFile == ""} {
        set config "false"
        set VarError ""
        set ErrorMessage "SELECT THE Double Bounce Scattering Type COLOR MAP"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if {$WishartScattModelBasedColorMapRVFile == ""} {
        set config "false"
        set VarError ""
        set ErrorMessage "SELECT THE Random / Volume Scattering Type COLOR MAP"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        } 
    if {"$config"=="true"} {

        set Fonction "Creation of all the Binary Data and BMP Files"
        set Fonction2 "of the Wishart Scattering Model Based Classification"
        set MaskCmd ""
        set MaskFile "$WishartScattModelBasedDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update

    
        if {$WishartScattModelBasedMixedFlag == 0} {
            set WishartScattModelBasedMixedThres "-1"
            } else {
            set WishartScattModelBasedMixedThres $WishartScattModelBasedMixedThreshold
            }


        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/lee_scattering_model_based_classification.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$WishartScattModelBasedDirInput\x22 -od \x22$WishartScattModelBasedDirOutput\x22 -isf \x22$WishartScattModelBasedSBFile\x22 -idf \x22$WishartScattModelBasedDBFile\x22 -irf \x22$WishartScattModelBasedRVFile\x22 -iodf $WishartScattModelBasedClassifFonction -nwr $WishartScattModelBasedNwinL -nwc $WishartScattModelBasedNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -pct $WishartScattModelBasedPourcentage -nit $WishartScattModelBasedIteration -bmp $BMPWishartScattModelBased -ncl $WishartScattModelBasedClusterInit -mct $WishartScattModelBasedMixedThres -fscn $WishartScattModelBasedSBClusterFin -fdcn $WishartScattModelBasedDBClusterFin -fvcn $WishartScattModelBasedRVClusterFin -cms \x22$WishartScattModelBasedColorMapSBFile\x22 -cmd \x22$WishartScattModelBasedColorMapDBFile\x22 -cmr \x22$WishartScattModelBasedColorMapRVFile\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/lee_scattering_model_based_classification.exe -id \x22$WishartScattModelBasedDirInput\x22 -od \x22$WishartScattModelBasedDirOutput\x22 -isf \x22$WishartScattModelBasedSBFile\x22 -idf \x22$WishartScattModelBasedDBFile\x22 -irf \x22$WishartScattModelBasedRVFile\x22 -iodf $WishartScattModelBasedClassifFonction -nwr $WishartScattModelBasedNwinL -nwc $WishartScattModelBasedNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -pct $WishartScattModelBasedPourcentage -nit $WishartScattModelBasedIteration -bmp $BMPWishartScattModelBased -ncl $WishartScattModelBasedClusterInit -mct $WishartScattModelBasedMixedThres -fscn $WishartScattModelBasedSBClusterFin -fdcn $WishartScattModelBasedDBClusterFin -fvcn $WishartScattModelBasedRVClusterFin -cms \x22$WishartScattModelBasedColorMapSBFile\x22 -cmd \x22$WishartScattModelBasedColorMapDBFile\x22 -cmr \x22$WishartScattModelBasedColorMapRVFile\x22  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        set ClassificationFile "$WishartScattModelBasedDirOutput/scattering_model_based_classification_"
        append ClassificationFile $WishartScattModelBasedNwinL; append ClassificationFile "x"; append ClassificationFile $WishartScattModelBasedNwinC
        set ClassificationInputFile "$ClassificationFile.bin"
        set ClassificationColorMapFile "$WishartScattModelBasedDirOutput/scattering_model_based_colormap.pal"
        set ClassificationColorNumber [expr $WishartScattModelBasedSBClusterFin + $WishartScattModelBasedDBClusterFin + $WishartScattModelBasedRVClusterFin]
        if [file exists $ClassificationInputFile] {EnviWriteConfigClassif $ClassificationInputFile $FinalNlig $FinalNcol 4 $ClassificationColorMapFile $ClassificationColorNumber}
        }
    }      
    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel434); TextEditorRunTrace "Close Window Wishart - Scattering Model Based Classification" "b"}
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel434" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/WishartScattModelBasedClassification.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel434" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile
if {$OpenDirFile == 0} {
Window hide $widget(Toplevel434); TextEditorRunTrace "Close Window Wishart - Scattering Model Based Classification" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel434" 1
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
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd80 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.cpd81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd82 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra66 \
        -in $top -anchor center -expand 0 -fill both -side top 
    pack $top.cpd78 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.tit81 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit84 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
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
Window show .top434

main $argc $argv
