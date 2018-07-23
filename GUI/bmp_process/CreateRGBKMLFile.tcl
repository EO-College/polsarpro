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
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}

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
    set base .top398
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd113 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd113
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
    namespace eval ::widgets::$site_6_0.cpd116 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.cpd117 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra41 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra41
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
    namespace eval ::widgets::$base.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra67
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd68
    namespace eval ::widgets::$site_4_0.fra38 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra38
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd68
    namespace eval ::widgets::$site_6_0.rad67 {
        array set save {-anchor 1 -command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd69
    namespace eval ::widgets::$site_6_0.rad68 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd67
    namespace eval ::widgets::$site_6_0.rad68 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra398 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra398
    namespace eval ::widgets::$site_5_0.fra42 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra42
    namespace eval ::widgets::$site_6_0.lab47 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab48 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab49 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra43 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra43
    namespace eval ::widgets::$site_6_0.lab52 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab53 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab54 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd70
    namespace eval ::widgets::$site_6_0.lab47 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab48 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.lab49 {
        array set save {-foreground 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra69 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra69
    namespace eval ::widgets::$site_4_0.fra70 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra70
    namespace eval ::widgets::$site_5_0.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra75
    namespace eval ::widgets::$site_6_0.but77 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.but76 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd80 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd79
    namespace eval ::widgets::$site_5_0.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra75
    namespace eval ::widgets::$site_6_0.but77 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.but76 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.ent74 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd81 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$base.cpd114 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd114
    namespace eval ::widgets::$site_3_0.cpd97 {
        array set save {-foreground 1 -ipad 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-foreground 1 -ipad 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.cpd120 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd118 {
        array set save {-foreground 1 -ipad 1 -text 1}
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
    namespace eval ::widgets::$site_6_0.cpd121 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
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
    namespace eval ::widgets::$site_5_0.cpd119 {
        array set save {-_tooltip 1 -command 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd115 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.cpd115
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
            vTclWindow.top398
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

proc vTclWindow.top398 {base} {
    if {$base == ""} {
        set base .top398
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
    wm geometry $top 500x489+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Create RGB - KML File"
    vTcl:DefineAlias "$top" "Toplevel398" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd113 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd113" "Frame1" vTcl:WidgetProc "Toplevel398" 1
    set site_3_0 $top.cpd113
    TitleFrame $site_3_0.cpd97 \
        -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame4" vTcl:WidgetProc "Toplevel398" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RGBDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh2" vTcl:WidgetProc "Toplevel398" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame16" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd116 \
        \
        -command {global DirName DataDir BMPDirInput RGBFunction RGBDirInput RGBDirOutput ConfigFile VarError ErrorMessage

set RGBFormat "combine"
set RGBFunction "S"
set RGBDirInput ""
set VarError ""

set RGBDirInputTmp $BMPDirInput
set DirName ""
OpenDir $DataDir "DATA INPUT DIRECTORY"
if {$DirName != ""} {
    set RGBDirInput $DirName
    } else {
    set RGBDirInput $RGBDirInputTmp
    } 
set RGBDirOutput $RGBDirInput

set RGBFunction ""

set ConfigFile "$RGBDirInput/config.txt"
set ErrorMessage ""
LoadConfig
if {"$ErrorMessage" != ""} {
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set RGBDirInput ""
    set RGBDirOutput ""
    if {$VarError == "cancel"} {Window hide $widget(Toplevel398); TextEditorRunTrace "Close Window Create RGB File" "b"}
    } else {
    if { "$PolarType" == "full"} {
        if [file exists "$RGBDirInput/s11.bin"] {set RGBFunction "S"}
        if [file exists "$RGBDirInput/T11.bin"] {set RGBFunction "T3"}
        #if [file exists "$RGBDirInput/T44.bin"] {set RGBFunction "T4"}
        if [file exists "$RGBDirInput/C11.bin"] {set RGBFunction "C3"}
        if [file exists "$RGBDirInput/C44.bin"] {set RGBFunction "C4"}
        } else {
        set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set ErrorMessage ""
        }
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd116" "Button36" vTcl:WidgetProc "Toplevel398" 1
    bindtags $site_6_0.cpd116 "$site_6_0.cpd116 Button $top all _vTclBalloon"
    bind $site_6_0.cpd116 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd116 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame5" vTcl:WidgetProc "Toplevel398" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RGBDirOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh6" vTcl:WidgetProc "Toplevel398" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame17" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd117 \
        \
        -command {global DirName DataDir RGBDirOutput RGBFormat RGBFileOutput

set RGBDirOutputTmp $RGBDirOutput
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != "" } {
    set RGBDirOutput $DirName
    } else {
    set RGBDirOutput $RGBDirOutputTmp
    }
if {$RGBFormat == "pauli"} {set RGBFileOutput "$RGBDirOutput/PauliRGB.bmp" }
if {$RGBFormat == "sinclair"} {set RGBFileOutput "$RGBDirOutput/SinclairRGB.bmp" }
if {$RGBFormat == "combine"} {set RGBFileOutput "$RGBDirOutput/CombineRGB.bmp" }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -padx 1 -pady 0 -text button 
    bindtags $site_6_0.cpd117 "$site_6_0.cpd117 Button $top all _vTclBalloon"
    bind $site_6_0.cpd117 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_6_0.cpd117 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd91 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra41 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra41" "Frame9" vTcl:WidgetProc "Toplevel398" 1
    set site_3_0 $top.fra41
    label $site_3_0.lab57 \
        -padx 1 -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel398" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel398" 1
    label $site_3_0.lab59 \
        -padx 1 -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel398" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel398" 1
    label $site_3_0.lab61 \
        -padx 1 -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel398" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel398" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel398" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel398" 1
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
    frame $top.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra67" "Frame4" vTcl:WidgetProc "Toplevel398" 1
    set site_3_0 $top.fra67
    frame $site_3_0.cpd68 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd68" "Frame71" vTcl:WidgetProc "Toplevel398" 1
    set site_4_0 $site_3_0.cpd68
    frame $site_4_0.fra38 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra38" "Frame90" vTcl:WidgetProc "Toplevel398" 1
    set site_5_0 $site_4_0.fra38
    frame $site_5_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd68" "Frame91" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.cpd68
    radiobutton $site_6_0.rad67 \
        -anchor center \
        -command {global RGBDirOutput RGBDirInput RGBFileOutput RGBFormat PolarType RGBFunction

set config "no"
if {$RGBFunction == "I2"} {set config "yes"}
if {$RGBFunction == "I4"} {set config "yes"}
if {$config == "yes"} {
    set RGBFormat "sinclair"
    set RGBFileOutput "$RGBDirOutput/SinclairRGB.bmp"
    set FileInputBlue "I11"
    if {$RGBFunction == "I2"} {set FileInputGreen "I12+I21"}
    if {$RGBFunction == "I4"} {set FileInputGreen "I12"}
    set FileInputRed "I22"
    } else {
    if {$PolarType == "full"} {
        set RGBFormat "pauli"
        set RGBFileOutput "$RGBDirOutput/PauliRGB.kml"
        set FileInputBlue "|S11+S22|"
        set FileInputGreen "|S12+S21|"
        set FileInputRed "|S11-S22|"
        } else {
        set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set RGBFormat "combine"
        set RGBDirInput ""
        set RGBDirOutput ""
        set RGBFileOutput ""
        set FileInputBlue ""
        set FileInputGreen ""
        set FileInputRed ""
        }
    }} \
        -text {Pauli Composition} -value pauli -variable RGBFormat 
    vTcl:DefineAlias "$site_6_0.rad67" "Radiobutton398_1" vTcl:WidgetProc "Toplevel398" 1
    pack $site_6_0.rad67 \
        -in $site_6_0 -anchor w -expand 0 -fill none -side left 
    frame $site_5_0.cpd69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd69" "Frame92" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.cpd69
    radiobutton $site_6_0.rad68 \
        \
        -command {global RGBDirOutput RGBDirInput RGBFileOutput RGBFormat PolarType RGBFunction

set config "no"
if {$RGBFunction == "I2"} {set config "yes"}
if {$RGBFunction == "I4"} {set config "yes"}
if {$config == "yes"} {
    set RGBFormat "sinclair"
    set RGBFileOutput "$RGBDirOutput/SinclairRGB.bmp"
    set FileInputBlue "I11"
    if {$RGBFunction == "I2"} {set FileInputGreen "I12+I21"}
    if {$RGBFunction == "I4"} {set FileInputGreen "I12"}
    set FileInputRed "I22"
    } else {
    if {$PolarType == "full"} {
        set RGBFormat "sinclair"
        set RGBFileOutput "$RGBDirOutput/SinclairRGB.kml"
        set FileInputBlue "|S11|"
        set FileInputGreen "|S12|"
        set FileInputRed "|S22|"
        } else {
        set ErrorMessage "INPUT DATA MUST BE FULL POLAR"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set RGBFormat "combine"
        set RGBDirInput ""
        set RGBDirOutput ""
        set RGBFileOutput ""
        set FileInputBlue ""
        set FileInputGreen ""
        set FileInputRed ""
        }
    }} \
        -text {Sinclair Composition} -value sinclair -variable RGBFormat 
    vTcl:DefineAlias "$site_6_0.rad68" "Radiobutton398_2" vTcl:WidgetProc "Toplevel398" 1
    pack $site_6_0.rad68 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd67" "Frame93" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.cpd67
    radiobutton $site_6_0.rad68 \
        \
        -command {global FileInputBlue FileInputGreen FileInputRed TMPFileNull
global RGBDirOutput RGBDirInput RGBFileOutput RGBFormat PolarType RGBFunction

set RGBFormat "combine"
set FileInputBlue $TMPFileNull
set FileInputGreen $TMPFileNull
set FileInputRed $TMPFileNull
set RGBFileOutput "$RGBDirOutput/CombineRGB.kml"} \
        -text Combine -value combine -variable RGBFormat 
    vTcl:DefineAlias "$site_6_0.rad68" "Radiobutton38" vTcl:WidgetProc "Toplevel398" 1
    pack $site_6_0.rad68 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd69 \
        -in $site_5_0 -anchor center -expand 0 -fill x -side top 
    pack $site_5_0.cpd67 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side top 
    frame $site_4_0.fra398 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra398" "Frame94" vTcl:WidgetProc "Toplevel398" 1
    set site_5_0 $site_4_0.fra398
    frame $site_5_0.fra42 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra42" "Frame72" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.fra42
    label $site_6_0.lab47 \
        -foreground #0000ff -padx 1 -text |S11+S22| 
    vTcl:DefineAlias "$site_6_0.lab47" "Label398_1" vTcl:WidgetProc "Toplevel398" 1
    label $site_6_0.lab48 \
        -foreground #008000 -padx 1 -text |S12+S21| 
    vTcl:DefineAlias "$site_6_0.lab48" "Label398_2" vTcl:WidgetProc "Toplevel398" 1
    label $site_6_0.lab49 \
        -foreground #ff0000 -padx 1 -text |S11-S22| 
    vTcl:DefineAlias "$site_6_0.lab49" "Label398_3" vTcl:WidgetProc "Toplevel398" 1
    pack $site_6_0.lab47 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab48 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab49 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.fra43 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra43" "Frame73" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.fra43
    label $site_6_0.lab52 \
        -foreground #0000ff -padx 1 -text |S11| 
    vTcl:DefineAlias "$site_6_0.lab52" "Label398_4" vTcl:WidgetProc "Toplevel398" 1
    label $site_6_0.lab53 \
        -foreground #008000 -padx 1 -text |(S12+S21)/2| 
    vTcl:DefineAlias "$site_6_0.lab53" "Label398_5" vTcl:WidgetProc "Toplevel398" 1
    label $site_6_0.lab54 \
        -foreground #ff0000 -padx 1 -text |S22| 
    vTcl:DefineAlias "$site_6_0.lab54" "Label398_6" vTcl:WidgetProc "Toplevel398" 1
    pack $site_6_0.lab52 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab53 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab54 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd70" "Frame74" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.cpd70
    label $site_6_0.lab47 \
        -foreground #0000ff -padx 1 -text {Blue File} 
    vTcl:DefineAlias "$site_6_0.lab47" "Label405" vTcl:WidgetProc "Toplevel398" 1
    label $site_6_0.lab48 \
        -foreground #008000 -padx 1 -text {Green File} 
    vTcl:DefineAlias "$site_6_0.lab48" "Label42" vTcl:WidgetProc "Toplevel398" 1
    label $site_6_0.lab49 \
        -foreground #ff0000 -padx 1 -text {Red File} 
    vTcl:DefineAlias "$site_6_0.lab49" "Label43" vTcl:WidgetProc "Toplevel398" 1
    pack $site_6_0.lab47 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab48 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.lab49 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.fra42 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_5_0.fra43 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd70 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.fra38 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra398 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $site_3_0.fra69 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra69" "Frame5" vTcl:WidgetProc "Toplevel398" 1
    set site_4_0 $site_3_0.fra69
    frame $site_4_0.fra70 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra70" "Frame6" vTcl:WidgetProc "Toplevel398" 1
    set site_5_0 $site_4_0.fra70
    frame $site_5_0.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra75" "Frame8" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.fra75
    button $site_6_0.but77 \
        \
        -command {global ReducFactor

set ReducFactor [expr $ReducFactor * 2]
if  {$ReducFactor == 16}  { set ReducFactor 1 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_6_0.but77" "Button2" vTcl:WidgetProc "Toplevel398" 1
    button $site_6_0.but76 \
        \
        -command {global ReducFactor

set ReducFactor [expr $ReducFactor / 2]
if  {$ReducFactor < 1}  { set ReducFactor 8 }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but76" "Button1" vTcl:WidgetProc "Toplevel398" 1
    pack $site_6_0.but77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.but76 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    entry $site_5_0.ent74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable ReducFactor -width 5 
    vTcl:DefineAlias "$site_5_0.ent74" "Entry1" vTcl:WidgetProc "Toplevel398" 1
    label $site_5_0.cpd80 \
        -text {Reduction Factor} 
    vTcl:DefineAlias "$site_5_0.cpd80" "Label2" vTcl:WidgetProc "Toplevel398" 1
    pack $site_5_0.fra75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    pack $site_5_0.ent74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    pack $site_5_0.cpd80 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 2 -side right 
    frame $site_4_0.cpd79 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd79" "Frame13" vTcl:WidgetProc "Toplevel398" 1
    set site_5_0 $site_4_0.cpd79
    frame $site_5_0.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra75" "Frame15" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.fra75
    button $site_6_0.but77 \
        \
        -command {global Transparency

set Transparency [expr $Transparency + 10]
if  {$Transparency == 110}  { set Transparency 0 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_6_0.but77" "Button5" vTcl:WidgetProc "Toplevel398" 1
    button $site_6_0.but76 \
        \
        -command {global Transparency

set Transparency [expr $Transparency - 10]
if  {$Transparency == -10}  { set Transparency 100 }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_6_0.but76" "Button6" vTcl:WidgetProc "Toplevel398" 1
    pack $site_6_0.but77 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.but76 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    entry $site_5_0.ent74 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable Transparency -width 5 
    vTcl:DefineAlias "$site_5_0.ent74" "Entry3" vTcl:WidgetProc "Toplevel398" 1
    label $site_5_0.cpd81 \
        -text Transparency 
    vTcl:DefineAlias "$site_5_0.cpd81" "Label5" vTcl:WidgetProc "Toplevel398" 1
    pack $site_5_0.fra75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    pack $site_5_0.ent74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 3 -side right 
    pack $site_5_0.cpd81 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 2 -side right 
    pack $site_4_0.fra70 \
        -in $site_4_0 -anchor center -expand 1 -fill x -pady 3 -side top 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 1 -fill x -pady 3 -side top 
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.fra69 \
        -in $site_3_0 -anchor center -expand 1 -fill x -side left 
    frame $top.cpd114 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd114" "Frame2" vTcl:WidgetProc "Toplevel398" 1
    set site_3_0 $top.cpd114
    TitleFrame $site_3_0.cpd97 \
        -foreground #0000ff -ipad 0 -text {BLUE Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame6" vTcl:WidgetProc "Toplevel398" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputBlue 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh3" vTcl:WidgetProc "Toplevel398" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame18" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd119 \
        \
        -command {global FileName RGBDirInput RGBDirOutput RGBFileOutput FileInputBlue RGBFormat VarError ErrorMessage TMPFileNull

set RGBFormat "combine"
if {"$RGBDirInput"!=""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $RGBDirInput $types "BLUE INPUT FILE"
    if {$FileName != ""} {
        set FileInputBlue $FileName
        set RGBFileOutput "$RGBDirOutput/CombineRGB.bmp"
        } else {
        set FileInputBlue $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd119" "Button37" vTcl:WidgetProc "Toplevel398" 1
    bindtags $site_6_0.cpd119 "$site_6_0.cpd119 Button $top all _vTclBalloon"
    bind $site_6_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_6_0.cpd119 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -foreground #009900 -ipad 0 -text {GREEN Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame7" vTcl:WidgetProc "Toplevel398" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputGreen 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh7" vTcl:WidgetProc "Toplevel398" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame19" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd120 \
        \
        -command {global FileName RGBDirInput  RGBDirOutput RGBFileOutput FileInputGreen RGBFormat VarError ErrorMessage TMPFileNull

set RGBFormat "combine"

if {"$RGBDirInput"!=""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $RGBDirInput $types "GREEN INPUT FILE"
    if {$FileName != ""} {
        set FileInputGreen $FileName
        set RGBFileOutput "$RGBDirOutput/CombineRGB.bmp"
        } else {
        set FileInputGreen $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text button 
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
    TitleFrame $site_3_0.cpd118 \
        -foreground #ff0000 -ipad 0 -text {RED Input Data File} 
    vTcl:DefineAlias "$site_3_0.cpd118" "TitleFrame10" vTcl:WidgetProc "Toplevel398" 1
    bind $site_3_0.cpd118 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd118 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable FileInputRed 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh9" vTcl:WidgetProc "Toplevel398" 1
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame27" vTcl:WidgetProc "Toplevel398" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd121 \
        \
        -command {global FileName RGBDirInput RGBDirOutput RGBFileOutput FileInputRed RGBFormat VarError ErrorMessage TMPFileNull

set RGBFormat "combine"

if {"$RGBDirInput"!=""} {
    set types {
    {{BIN Files}        {.bin}        }
    }
    set FileName ""
    OpenFile $RGBDirInput $types "RED INPUT FILE"
    if {$FileName != ""} {
        set FileInputRed $FileName
        set RGBFileOutput "$RGBDirOutput/CombineRGB.bmp"
        } else {
        set FileInputRed $TMPFileNull
        }
    } else {
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd121" "Button398" vTcl:WidgetProc "Toplevel398" 1
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
    pack $site_3_0.cpd97 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd118 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    TitleFrame $top.cpd66 \
        -foreground #000000 -ipad 0 -text {Input GEARTH_POLY File} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame398_1" vTcl:WidgetProc "Toplevel398" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    entry $site_4_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable RGBGearthPolyFile 
    vTcl:DefineAlias "$site_4_0.cpd85" "Entry398_1" vTcl:WidgetProc "Toplevel398" 1
    frame $site_4_0.cpd92 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd92" "Frame21" vTcl:WidgetProc "Toplevel398" 1
    set site_5_0 $site_4_0.cpd92
    button $site_5_0.cpd119 \
        \
        -command {global FileName RGBDirInput RGBGearthPolyFile

set types {
{{KML Files}        {.kml}        }
}
set FileName ""
OpenFile $RGBDirInput $types "INPUT GEARTH POLY FILE" 
if {$FileName != ""} {
    set RGBGearthPolyFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -padx 1 -pady 0 -text {    } 
    vTcl:DefineAlias "$site_5_0.cpd119" "Button398_1" vTcl:WidgetProc "Toplevel398" 1
    bindtags $site_5_0.cpd119 "$site_5_0.cpd119 Button $top all _vTclBalloon"
    bind $site_5_0.cpd119 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd119 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $top.cpd115 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.cpd115" "Frame3" vTcl:WidgetProc "Toplevel398" 1
    set site_3_0 $top.cpd115
    TitleFrame $site_3_0.cpd98 \
        -ipad 0 -text {Output KML File} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel398" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable RGBFileOutput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel398" 1
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_3_0.cpd98 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra59 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel398" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global TMPFileNull RGBDirInput FileInputBlue FileInputGreen FileInputRed RGBFunction RGBDirOutput RGBFileOutput RGBFormat BMPDirInput
global VarError ErrorMessage Fonction Fonction2 ProgressLine OpenDirFile RGBCCCE PSPMemory TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax NcolFullSize NligFullSize
global MapReadyKmlReader TMPFileKmlBlueBin TMPFileKmlBlueHdr TMPFileKmlGreenBin TMPFileKmlGreenHdr TMPFileKmlRedBin TMPFileKmlRedHdr
global ReducFactor Transparency
global wshMapReady PlatForm TMPDirectory MapInfoGeocoding RGBGearthPolyFile

if {$OpenDirFile == 0} {

if {"$RGBDirInput"!=""} {

    #####################################################################
    #Create Directory
    set RGBDirOutput [PSPCreateDirectoryMask $RGBDirOutput $RGBDirOutput $RGBDirInput]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
    
        set config "true"
        if {"$RGBFormat"=="combine"} {
            if {"$FileInputBlue"==""} {set config "false"}
            if {"$FileInputRed"==""} {set config "false"}
            if {"$FileInputGreen"==""} {set config "false"}
            if {"$config"=="false"} {
                set VarError ""
                set ErrorMessage "INVALID INPUT FILES" 
                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                tkwait variable VarError
                }
            }

        if {"$config"=="true"} {
            set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
            set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
            set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
            set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
            if {$MapInfoGeocoding != "UTM"} {
                set TestVarName(4) "GEARTH POLY File"; set TestVarType(4) "file"; set TestVarValue(4) $RGBGearthPolyFile; set TestVarMin(4) ""; set TestVarMax(4) ""
                TestVar 5
                } else {
                TestVar 4
                }
            if {$TestVarError == "ok"} {
                set OffsetLig [expr $NligInit - 1]
                set OffsetCol [expr $NcolInit - 1]
                set FinalNlig [expr $NligEnd - $NligInit + 1]
                set FinalNcol [expr $NcolEnd - $NcolInit + 1]

                DeleteFile $TMPFileKmlBlueHdr
                DeleteFile $TMPFileKmlGreenHdr
                DeleteFile $TMPFileKmlRedHdr
    
                set Fonction "Creation of the RGB BMP File :"
                set Fonction2 "$RGBFileOutput"    
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                if {"$RGBFormat"=="combine"} {
                    set config "false"
                    if {"$FileInputBlue"=="$TMPFileNull"} {set config "true"}
                    if {"$FileInputRed"=="$TMPFileNull"} {set config "true"}
                    if {"$FileInputGreen"=="$TMPFileNull"} {set config "true"}
                    if {"$config"=="true"} {
                        TextEditorRunTrace "Process The Function Soft/bmp_process/create_null_file.exe" "k"
                        TextEditorRunTrace "Arguments: -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" "k"
                        set f [ open "| Soft/bmp_process/create_null_file.exe -of \x22$TMPFileNull\x22 -fnr $FinalNlig -fnc $FinalNcol" r]
                        }
                    PsPprogressBar $f
                    TextEditorRunTrace "Check RunTime Errors" "r"
                    CheckRunTimeError

                    CopyFile $FileInputBlue $TMPFileKmlBlueBin
                    CopyFile $FileInputGreen $TMPFileKmlGreenBin
                    CopyFile $FileInputRed $TMPFileKmlRedBin

                    if {"$FileInputBlue"!="$TMPFileNull"} { set KmlFileHdr "$FileInputBlue.hdr" }
                    if {"$FileInputGreen"!="$TMPFileNull"} { set KmlFileHdr "$FileInputGreen.hdr" }
                    if {"$FileInputRed"!="$TMPFileNull"} { set KmlFileHdr "$FileInputRed.hdr" }

                    set BMPDirInput $RGBDirOutput
                    }

                if {"$RGBFormat"!="combine"} {

                    if {"$RGBFunction"=="S2"} {
                        set config "true"
                        set fichier "$RGBDirInput/s11.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE s11.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/s12.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE s12.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/s21.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE s21.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/s22.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE s22.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        if {"$config"=="true"} {
                            set KmlFileHdr "$RGBDirInput/s11.bin.hdr"
                            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_kml_file.exe" "k"
                            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -ofb \x22$TMPFileKmlBlueBin\x22 -ofg \x22$TMPFileKmlGreenBin\x22 -ofr \x22$TMPFileKmlRedBin\x22 -ift S2 -oft $RGBFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
                            set f [ open "| Soft/bmp_process/create_rgb_kml_file.exe -id \x22$RGBDirInput\x22 -ofb \x22$TMPFileKmlBlueBin\x22 -ofg \x22$TMPFileKmlGreenBin\x22 -ofr \x22$TMPFileKmlRedBin\x22 -ift S2 -oft $RGBFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
                            PsPprogressBar $f
                            TextEditorRunTrace "Check RunTime Errors" "r"
                            CheckRunTimeError
                            set BMPDirInput $RGBDirOutput
                            }                    
                        }                 

                    if {"$RGBFunction"=="T3"} {
                        set config "true"
                        set fichier "$RGBDirInput/T11.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE T11.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/T22.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE T22.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/T33.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE T33.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        if {"$RGBFormat"=="sinclair"} {
                            set fichier "$RGBDirInput/T12_real.bin"
                            if [file exists $fichier] {
                                } else {
                                set config "false"
                                set VarError ""
                                set ErrorMessage "THE FILE T12_real.bin MUST BE CREATED FIRST"
                                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                                tkwait variable VarError
                                }
                            }
                        if {"$config"=="true"} {
                            set KmlFileHdr "$RGBDirInput/T11.bin.hdr"
                            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_kml_file.exe" "k"
                            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -ofb \x22$TMPFileKmlBlueBin\x22 -ofg \x22$TMPFileKmlGreenBin\x22 -ofr \x22$TMPFileKmlRedBin\x22 -ift T3 -oft $RGBFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
                            set f [ open "| Soft/bmp_process/create_rgb_kml_file.exe -id \x22$RGBDirInput\x22 -ofb \x22$TMPFileKmlBlueBin\x22 -ofg \x22$TMPFileKmlGreenBin\x22 -ofr \x22$TMPFileKmlRedBin\x22 -ift T3 -oft $RGBFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
                            PsPprogressBar $f
                            TextEditorRunTrace "Check RunTime Errors" "r"
                            CheckRunTimeError
                            set BMPDirInput $RGBDirOutput
                            }                    
                        }                 

                    if {"$RGBFunction"=="T4"} {
                        set config "true"
                        set fichier "$RGBDirInput/T11.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE T11.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/T22.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE T22.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/T33.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE T33.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        if {"$RGBFormat"=="sinclair"} {
                            set fichier "$RGBDirInput/T12_real.bin"
                            if [file exists $fichier] {
                                } else {
                                set config "false"
                                set VarError ""
                                set ErrorMessage "THE FILE T12_real.bin MUST BE CREATED FIRST"
                                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                                tkwait variable VarError
                                }
                            }
                        if {"$config"=="true"} {
                            set KmlFileHdr "$RGBDirInput/T11.bin.hdr"
                            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_kml_file.exe" "k"
                            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -ofb \x22$TMPFileKmlBlueBin\x22 -ofg \x22$TMPFileKmlGreenBin\x22 -ofr \x22$TMPFileKmlRedBin\x22 -ift T3 -oft $RGBFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
                            set f [ open "| Soft/bmp_process/create_rgb_kml_file.exe -id \x22$RGBDirInput\x22 -ofb \x22$TMPFileKmlBlueBin\x22 -ofg \x22$TMPFileKmlGreenBin\x22 -ofr \x22$TMPFileKmlRedBin\x22 -ift T3 -oft $RGBFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
                            PsPprogressBar $f
                            TextEditorRunTrace "Check RunTime Errors" "r"
                            CheckRunTimeError
                            set BMPDirInput $RGBDirOutput
                            }                    
                        }                 

                    if {"$RGBFunction"=="C3"} {
                        set config "true"
                        set fichier "$RGBDirInput/C11.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE C11.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/C22.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE C22.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/C33.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE C33.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        if {"$RGBFormat"=="pauli"} {
                            set fichier "$RGBDirInput/C13_real.bin"
                            if [file exists $fichier] {
                                } else {
                                set config "false"
                                set VarError ""
                                set ErrorMessage "THE FILE C13_real.bin MUST BE CREATED FIRST"
                                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                                tkwait variable VarError
                                }
                            }
                        if {"$config"=="true"} {
                            set KmlFileHdr "$RGBDirInput/C11.bin.hdr"
                            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_kml_file.exe" "k"
                            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -ofb \x22$TMPFileKmlBlueBin\x22 -ofg \x22$TMPFileKmlGreenBin\x22 -ofr \x22$TMPFileKmlRedBin\x22 -ift C3 -oft $RGBFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
                            set f [ open "| Soft/bmp_process/create_rgb_kml_file.exe -id \x22$RGBDirInput\x22 -ofb \x22$TMPFileKmlBlueBin\x22 -ofg \x22$TMPFileKmlGreenBin\x22 -ofr \x22$TMPFileKmlRedBin\x22 -ift C3 -oft $RGBFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
                            PsPprogressBar $f
                            TextEditorRunTrace "Check RunTime Errors" "r"
                            CheckRunTimeError
                            set BMPDirInput $RGBDirOutput
                            }                                 
                        }    

                    if {"$RGBFunction"=="C4"} {
                        set config "true"
                        set fichier "$RGBDirInput/C11.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE C11.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/C22.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE C22.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/C33.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE C33.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/C44.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE C44.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        set fichier "$RGBDirInput/C23_real.bin"
                        if [file exists $fichier] {
                            } else {
                            set config "false"
                            set VarError ""
                            set ErrorMessage "THE FILE C23_real.bin MUST BE CREATED FIRST"
                            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                            tkwait variable VarError
                            }
                        if {"$RGBFormat"=="pauli"} {
                            set fichier "$RGBDirInput/C14_real.bin"
                            if [file exists $fichier] {
                                } else {
                                set config "false"
                                set VarError ""
                                set ErrorMessage "THE FILE C14_real.bin MUST BE CREATED FIRST"
                                Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                                tkwait variable VarError
                                }
                            }
                        if {"$config"=="true"} {
                            set KmlFileHdr "$RGBDirInput/C11.bin.hdr"
                            TextEditorRunTrace "Process The Function Soft/bmp_process/create_rgb_kml_file.exe" "k"
                            TextEditorRunTrace "Arguments: -id \x22$RGBDirInput\x22 -ofb \x22$TMPFileKmlBlueBin\x22 -ofg \x22$TMPFileKmlGreenBin\x22 -ofr \x22$TMPFileKmlRedBin\x22 -ift C4 -oft $RGBFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" "k"
                            set f [ open "| Soft/bmp_process/create_rgb_kml_file.exe -id \x22$RGBDirInput\x22 -ofb \x22$TMPFileKmlBlueBin\x22 -ofg \x22$TMPFileKmlGreenBin\x22 -ofr \x22$TMPFileKmlRedBin\x22 -ift C4 -oft $RGBFormat -nc $NcolFullSize -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol" r]
                            PsPprogressBar $f
                            TextEditorRunTrace "Check RunTime Errors" "r"
                            CheckRunTimeError
                            set BMPDirInput $RGBDirOutput
                            }                    
                        }                 
                    }                                  

                set RGBFormat ""
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

                WidgetShowTop399; TextEditorRunTrace "Open Window Processing" "b"

                DeleteFile $TMPFileKmlBlueHdr
                DeleteFile $TMPFileKmlGreenHdr
                DeleteFile $TMPFileKmlRedHdr

                if [file exists $KmlFileHdr] {
                    if {$MapInfoGeocoding == "UTM"} {
                        CopyFile $KmlFileHdr $TMPFileKmlBlueHdr
                        CopyFile $KmlFileHdr $TMPFileKmlGreenHdr
                        CopyFile $KmlFileHdr $TMPFileKmlRedHdr
                        } else {
                        set HDRFileInput $KmlFileHdr
                        set ProgressLine "0"
                        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                        update
                        TextEditorRunTrace "Process The Function Soft/tools/LatLong_to_UTM.exe" "k"
                        TextEditorRunTrace "Arguments: -if \x22$HDRFileInput\x22 -of \x22$TMPFileKmlBlueHdr\x22 -igp \x22$RGBGearthPolyFile\x22 -fnr $FinalNlig -fnc $FinalNcol" "k"
                        set f [ open "| Soft/tools/LatLong_to_UTM.exe -if \x22$HDRFileInput\x22 -of \x22$TMPFileKmlBlueHdr\x22 -igp \x22$RGBGearthPolyFile\x22 -fnr $FinalNlig -fnc $FinalNcol" r]
                        PsPprogressBar $f
                        TextEditorRunTrace "Check RunTime Errors" "r"
                        CheckRunTimeError
                        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                        WaitUntilCreated $TMPFileKmlBlueHdr
                        CopyFile $TMPFileKmlBlueHdr $TMPFileKmlGreenHdr
                        CopyFile $TMPFileKmlBlueHdr $TMPFileKmlRedHdr
                        }
                    }

                #set MapReadyKmlOutput [file rootname $RGBFileOutput]
                set MapReadyKmlOutput "$TMPDirectory/"
                append MapReadyKmlOutput [file rootname [file tail $RGBFileOutput]]

                set MapReadyKmlCommand " -reduction_factor $ReducFactor"
                if {$Transparency != 0} {append MapReadyKmlCommand " -transparency $Transparency"}
                append MapReadyKmlCommand " -polsarpro decomposition -rgb Freeman_Dbl,Freeman_Vol,Freeman_Odd"
                append MapReadyKmlCommand " \x22$TMPFileKmlRedBin\x22 \x22$MapReadyKmlOutput\x22"
                TextEditorRunTrace "Process The Function $MapReadyKmlReader" "k"
                TextEditorRunTrace "Arguments: $MapReadyKmlCommand" "k"

                if {$PlatForm == "windows"} {
        	        package require tcom
            	  set wshMapReady [::tcom::ref createobject "WScript.Shell"]
                    set taskIdMapReady [$wshMapReady Run "\x22$MapReadyKmlReader\x22 $MapReadyKmlCommand"]
                    }
                if {$PlatForm == "unix"} {set taskIdMapReady [ open "| \x22$MapReadyKmlReader\x22 $MapReadyKmlCommand" r]}

                #set f [ open "| \x22$MapReadyKmlReader\x22 $MapReadyKmlCommand" r]
                #TextEditorRunTrace "Check RunTime Errors" "r"
                #CheckRunTimeError

                #WaitUntilCreated $RGBFileOutput
                set TMPFileOutput [file rootname $RGBFileOutput]
                WaitUntilCreated "$MapReadyKmlOutput.kml"
                CopyFile "$MapReadyKmlOutput.kml" "$TMPFileOutput.kml"
                WaitUntilCreated "$MapReadyKmlOutput.png"
                CopyFile "$MapReadyKmlOutput.png" "$TMPFileOutput.png"

                Window hide $widget(Toplevel398); TextEditorRunTrace "Close Window Create RGB - KML File" "b"
                WidgetHideTop399; TextEditorRunTrace "Close Window Processing" "b"
                }
            }
        } else {
        if {"$VarWarning"=="no"} {Window hide $widget(Toplevel398); TextEditorRunTrace "Close Window Create RGB - KML File" "b"}
        }
    } else {
    set RGBFormat ""
    set VarError ""
    set ErrorMessage "ENTER A VALID DIRECTORY"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    }
}} \
        -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel398" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/CreateRGBKMLFile.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel398" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global DisplayMainMenu OpenDirFile

if {$OpenDirFile == 0} {
Window hide $widget(Toplevel398); TextEditorRunTrace "Close Window Create RGB File" "b"
if {$DisplayMainMenu == 1} {
    set DisplayMainMenu 0
    WidgetShow $widget(Toplevel2)
    }
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel398" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit  the Function}
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
    pack $top.cpd113 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra41 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd114 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd115 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
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
Window show .top398

main $argc $argv
