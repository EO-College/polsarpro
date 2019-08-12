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

        {{[file join . GUI Images Transparent_Button.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images OpenDir.gif]} {user image} user {}}
        {{[file join . GUI Images OpenFile.gif]} {user image} user {}}
        {{[file join . GUI Images down.gif]} {user image} user {}}
        {{[file join . GUI Images up.gif]} {user image} user {}}
        {{[file join . GUI Images SaveFile.gif]} {user image} user {}}
        {{[file join . GUI Images GIMPshortcut.gif]} {user image} user {}}

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
    set base .top253
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.tit71 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit71 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -state 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.but75 {
        array set save {-image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$base.tit76 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit76 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd72
    namespace eval ::widgets::$site_5_0.lab73 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd84
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra74
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
    namespace eval ::widgets::$base.cpd74 {
        array set save {-text 1}
    }
    set site_4_0 [$base.cpd74 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd84
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-_tooltip 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.tit92 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.tit92 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.rad71 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.fra71 {
        array set save {-borderwidth 1 -height 1 -width 1}
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
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd76 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd76 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.cpd71 {
        array set save {-text 1}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.che71 {
        array set save {-command 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra73
    namespace eval ::widgets::$site_5_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd71 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd67 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.fra68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra68
    namespace eval ::widgets::$site_7_0.cpd70 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.but69 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd72 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.fra68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra68
    namespace eval ::widgets::$site_7_0.cpd70 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.but69 {
        array set save {-command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd67 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd67
    namespace eval ::widgets::$site_5_0.but67 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra73
    namespace eval ::widgets::$site_6_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd70 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.but66 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd68
    namespace eval ::widgets::$site_6_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_6_0.cpd66 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd66 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd68 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd68
    namespace eval ::widgets::$site_5_0.cpd69 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.fra73
    namespace eval ::widgets::$site_6_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd68 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd68
    namespace eval ::widgets::$site_6_0.lab74 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_6_0.ent75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra67 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra67
    namespace eval ::widgets::$site_3_0.cpd68 {
        array set save {-text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.cpd69 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd70 {
        array set save {-background 1 -command 1 -image 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra83 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra83
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -cursor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but23 {
        array set save {-_tooltip 1 -background 1 -command 1 -image 1 -pady 1 -text 1 -width 1}
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
            vTclWindow.top253
            SurfacePlotHisto1D
            SurfacePlotHisto1DThumb
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
## Procedure:  SurfacePlotHisto1D

proc ::SurfacePlotHisto1D {} {
global GnuplotPipeFid GnuplotPipeHisto GnuOutputFile
global GnuHistoFile1 GnuHistoFile2 GnuHistoMax1 GnuHistoMax2
global TMPGnuPlotTk1 TMPGnuPlotTk2 TMPGnuPlot1Tk TMPGnuPlot2Tk

set xwindow [winfo x .top253]; set ywindow [winfo y .top253]

DeleteFile $TMPGnuPlotTk1
DeleteFile $TMPGnuPlotTk2
DeleteFile $TMPGnuPlot1Tk
DeleteFile $TMPGnuPlot2Tk

set GnuOutputFormat ""
set GnuHistoStyle "lines"
    
if {$GnuplotPipeHisto == ""} {
    GnuPlotInit 0 0 1 1
    set GnuplotPipeHisto $GnuplotPipeFid
    }
    
#SurfacePlotHisto1DThumb 1

set GnuOutputFile $TMPGnuPlotTk1
set GnuOutputFormat "gif"
GnuPlotTerm $GnuplotPipeHisto $GnuOutputFormat

set GnuHistoTitle "HISTOGRAM HVHV / VVVV"
puts $GnuplotPipeHisto "set autoscale"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set xlabel 'Value (dB)'"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set ylabel 'Nb of Samples (Max = $GnuHistoMax1)'"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set title '$GnuHistoTitle' textcolor lt 3"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "plot '$GnuHistoFile1' using 1:2 title ' ' with $GnuHistoStyle"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "unset output"; flush $GnuplotPipeHisto 

set ErrorCatch [catch {puts $GnuplotPipeHisto "quit"}]
if { $ErrorCatch == "0" } {
    puts $GnuplotPipeHisto "quit"; flush $GnuplotPipeHisto
    }
catch "close $GnuplotPipeHisto"
set GnuplotPipeHisto ""

WaitUntilCreated $TMPGnuPlotTk1
Gimp $TMPGnuPlotTk1
#ViewGnuPlotTKThumb 1 .top253 "Histogram HVHV / VVVV"

if {$GnuplotPipeHisto == ""} {
    GnuPlotInit 0 0 1 1
    set GnuplotPipeHisto $GnuplotPipeFid
    }
    
#SurfacePlotHisto1DThumb 2

set GnuOutputFile $TMPGnuPlotTk2
set GnuOutputFormat "gif"
GnuPlotTerm $GnuplotPipeHisto $GnuOutputFormat

set GnuHistoTitle "HISTOGRAM HHHH / VVVV"
puts $GnuplotPipeHisto "set autoscale"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set xlabel 'Value (dB)'"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set ylabel 'Nb of Samples (Max = $GnuHistoMax2)'"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "set title '$GnuHistoTitle' textcolor lt 3"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "plot '$GnuHistoFile2' using 1:2 title ' ' with $GnuHistoStyle"; flush $GnuplotPipeHisto
puts $GnuplotPipeHisto "unset output"; flush $GnuplotPipeHisto 

set ErrorCatch [catch {puts $GnuplotPipeHisto "quit"}]
if { $ErrorCatch == "0" } {
    puts $GnuplotPipeHisto "quit"; flush $GnuplotPipeHisto
    }
catch "close $GnuplotPipeHisto"
set GnuplotPipeHisto ""

WaitUntilCreated $TMPGnuPlotTk2
Gimp $TMPGnuPlotTk2
#ViewGnuPlotTKThumb 2 .top401 "Histogram HHHH / VVVV"
}
#############################################################################
## Procedure:  SurfacePlotHisto1DThumb

proc ::SurfacePlotHisto1DThumb {ThumbNum} {
global GnuplotPipeFid GnuplotPipeHisto GnuOutputFile
global GnuHistoFile1 GnuHistoFile2 GnuHistoMax1 GnuHistoMax2
global TMPGnuPlotTk1 TMPGnuPlotTk2 TMPGnuPlot1Tk TMPGnuPlot2Tk

set xwindow [winfo x .top253]; set ywindow [winfo y .top253]

if { $ThumbNum == "1" } {
    DeleteFile $TMPGnuPlot1Tk
    set GnuOutputFile $TMPGnuPlot1Tk
    set GnuOutputFormat "png"
    GnuPlotTerm $GnuplotPipeHisto $GnuOutputFormat

    set GnuHistoTitle "HISTOGRAM HVHV / VVVV"
    puts $GnuplotPipeHisto "set autoscale"; flush $GnuplotPipeHisto
    puts $GnuplotPipeHisto "set xlabel 'Value (dB)'"; flush $GnuplotPipeHisto
    puts $GnuplotPipeHisto "set ylabel 'Nb of Samples (Max = $GnuHistoMax1)'"; flush $GnuplotPipeHisto
    puts $GnuplotPipeHisto "set title '$GnuHistoTitle' textcolor lt 3"; flush $GnuplotPipeHisto
    puts $GnuplotPipeHisto "plot '$GnuHistoFile1' using 1:2 title ' ' with $GnuHistoStyle"; flush $GnuplotPipeHisto
    puts $GnuplotPipeHisto "unset output"; flush $GnuplotPipeHisto 

    WaitUntilCreated $TMPGnuPlot1Tk
    }
    
if { $ThumbNum == "2" } {
    DeleteFile $TMPGnuPlot2Tk
    set GnuOutputFile $TMPGnuPlot2Tk
    set GnuOutputFormat "png"
    GnuPlotTerm $GnuplotPipeHisto $GnuOutputFormat

    set GnuHistoTitle "HISTOGRAM HHHH / VVVV"
    puts $GnuplotPipeHisto "set autoscale"; flush $GnuplotPipeHisto
    puts $GnuplotPipeHisto "set xlabel 'Value (dB)'"; flush $GnuplotPipeHisto
    puts $GnuplotPipeHisto "set ylabel 'Nb of Samples (Max = $GnuHistoMax2)'"; flush $GnuplotPipeHisto
    puts $GnuplotPipeHisto "set title '$GnuHistoTitle' textcolor lt 3"; flush $GnuplotPipeHisto
    puts $GnuplotPipeHisto "plot '$GnuHistoFile2' using 1:2 title ' ' with $GnuHistoStyle"; flush $GnuplotPipeHisto
    puts $GnuplotPipeHisto "unset output"; flush $GnuplotPipeHisto 

    WaitUntilCreated $TMPGnuPlot2Tk
    }
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

proc vTclWindow.top253 {base} {
    if {$base == ""} {
        set base .top253
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
    wm geometry $top 500x510+10+110; update
    wm maxsize $top 1284 1009
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Process : Surface Parameter Data Inversion"
    vTcl:DefineAlias "$top" "Toplevel253" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    TitleFrame $top.tit71 \
        -text {Input Directory} 
    vTcl:DefineAlias "$top.tit71" "TitleFrame1" vTcl:WidgetProc "Toplevel253" 1
    bind $top.tit71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit71 getframe]
    entry $site_4_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -state disabled \
        -textvariable SurfaceDirInput 
    vTcl:DefineAlias "$site_4_0.cpd72" "Entry253_149" vTcl:WidgetProc "Toplevel253" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame1" vTcl:WidgetProc "Toplevel253" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.but75 \
        \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_5_0.but75" "Button1" vTcl:WidgetProc "Toplevel253" 1
    pack $site_5_0.but75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit76 \
        -text {Output Directory} 
    vTcl:DefineAlias "$top.tit76" "TitleFrame2" vTcl:WidgetProc "Toplevel253" 1
    bind $top.tit76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit76 getframe]
    entry $site_4_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 \
        -textvariable SurfaceOutputDir 
    vTcl:DefineAlias "$site_4_0.cpd82" "Entry253_73" vTcl:WidgetProc "Toplevel253" 1
    frame $site_4_0.cpd72 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd72" "Frame13" vTcl:WidgetProc "Toplevel253" 1
    set site_5_0 $site_4_0.cpd72
    label $site_5_0.lab73 \
        -text / 
    vTcl:DefineAlias "$site_5_0.lab73" "Label1" vTcl:WidgetProc "Toplevel253" 1
    entry $site_5_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SurfaceOutputSubDir -width 3 
    vTcl:DefineAlias "$site_5_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel253" 1
    pack $site_5_0.lab73 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame2" vTcl:WidgetProc "Toplevel253" 1
    set site_5_0 $site_4_0.cpd84
    button $site_5_0.cpd85 \
        \
        -command {global DirName DataDir SurfaceOutputDir
global VarWarning WarningMessage WarningMessage2

set SurfaceDirOutputTmp $SurfaceOutputDir
set DirName ""
OpenDir $DataDir "DATA OUTPUT DIRECTORY"
if {$DirName != ""} {
    set VarWarning ""
    set WarningMessage "THE MAIN DIRECTORY IS"
    set WarningMessage2 "CHANGED TO $DirName"
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {
        set SurfaceOutputDir $DirName
        } else {
        set SurfaceOutputDir $SurfaceDirOutputTmp
        }
    } else {
    set SurfaceOutputDir $SurfaceDirOutputTmp
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd85" "Button253_92" vTcl:WidgetProc "Toplevel253" 1
    bindtags $site_5_0.cpd85 "$site_5_0.cpd85 Button $top all _vTclBalloon"
    bind $site_5_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $top.fra74 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame9" vTcl:WidgetProc "Toplevel253" 1
    set site_3_0 $top.fra74
    label $site_3_0.lab57 \
        -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label253_01" vTcl:WidgetProc "Toplevel253" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry253_01" vTcl:WidgetProc "Toplevel253" 1
    label $site_3_0.lab59 \
        -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label253_02" vTcl:WidgetProc "Toplevel253" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry253_02" vTcl:WidgetProc "Toplevel253" 1
    label $site_3_0.lab61 \
        -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label253_03" vTcl:WidgetProc "Toplevel253" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry253_03" vTcl:WidgetProc "Toplevel253" 1
    label $site_3_0.lab63 \
        -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label253_04" vTcl:WidgetProc "Toplevel253" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry253_04" vTcl:WidgetProc "Toplevel253" 1
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
    TitleFrame $top.cpd74 \
        -text {Local Incidence Angle File} 
    vTcl:DefineAlias "$top.cpd74" "TitleFrame3" vTcl:WidgetProc "Toplevel253" 1
    bind $top.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd74 getframe]
    entry $site_4_0.cpd82 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -textvariable LIAFile 
    vTcl:DefineAlias "$site_4_0.cpd82" "Entry253" vTcl:WidgetProc "Toplevel253" 1
    frame $site_4_0.cpd84 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.cpd84" "Frame3" vTcl:WidgetProc "Toplevel253" 1
    set site_5_0 $site_4_0.cpd84
    button $site_5_0.cpd85 \
        \
        -command {global FileName SurfaceDirInput LIAFile
global WarningMessage WarningMessage2 VarAdvice

set WarningMessage "THE 2D LOCAL INCIDENCE ANGLE FILE MUST HAVE THE"
set WarningMessage2 "SAME DATA SIZE AND MUST NOT CONTAIN ANY HEADER"
set VarAdvice ""
Window show $widget(Toplevel242); TextEditorRunTrace "Open Window Advice" "b"
tkwait variable VarAdvice

set types {
{{BIN Files}        {.bin}        }
{{DAT Files}        {.dat}        }
}
set FileName ""
OpenFile "$SurfaceDirInput" $types "LOCAL INCIDENCE ANGLE FILE"
if {$FileName != ""} {
    set LIAFile $FileName
    }} \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd85" "Button253" vTcl:WidgetProc "Toplevel253" 1
    bindtags $site_5_0.cpd85 "$site_5_0.cpd85 Button $top all _vTclBalloon"
    bind $site_5_0.cpd85 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    TitleFrame $top.tit92 \
        -ipad 2 -text {Surface Parameter Data Inversion Procedures} 
    vTcl:DefineAlias "$top.tit92" "TitleFrame5" vTcl:WidgetProc "Toplevel253" 1
    bind $top.tit92 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit92 getframe]
    radiobutton $site_4_0.cpd73 \
        \
        -command {global SurfaceModel SurfaceFreq SurfaceCoeffCalib SurfaceCalibFlag
global SurfaceNwinL SurfaceNwinC SurfaceDieli SurfaceBeta
global SurfaceThreshold1 SurfaceThreshold2 SurfaceThreshold3 SurfaceThreshold4
global GnuplotPipeFid GnuplotPipeHisto DisplayXBraggHAlpha

if {$GnuplotPipeHisto != ""} {
    catch "close $GnuplotPipeHisto"
    set GnuplotPipeHisto ""
    }
set GnuplotPipeFid ""
Window hide .top401; Window hide .top402; Window hide .top419

if {$SurfaceModel == "dubois"} {
    set SurfaceFreq "?"
    $widget(TitleFrame253_1) configure -text "Central Freq. (GHz)"
    $widget(Entry253_1) configure -state normal
    $widget(Entry253_1) configure -disabledbackground #FFFFFF
    set SurfaceCoeffCalib ""
    $widget(TitleFrame253_2) configure -text "Calibration"
    set SurfaceCalibFlag 0
    $widget(Checkbutton253_1) configure -state normal

    $widget(TitleFrame253_3) configure -text ""
    $widget(TitleFrame253_4) configure -text ""
    $widget(TitleFrame253_5) configure -text ""
    set SurfaceNwinL ""; set SurfaceNwinC ""
    $widget(Label253_1a) configure -state disable
    $widget(Label253_1b) configure -state disable
    $widget(Entry253_3a) configure -state disable
    $widget(Entry253_3a) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry253_3b) configure -state disable
    $widget(Entry253_3b) configure -disabledbackground $PSPBackgroundColor
    set SurfaceDieli ""
    $widget(Entry253_4) configure -state disable
    $widget(Entry253_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button253_1) configure -state disable
    $widget(Button253_2) configure -state disable
    set SurfaceBeta ""
    $widget(Entry253_5) configure -state disable
    $widget(Entry253_5) configure -disabledbackground $PSPBackgroundColor
    $widget(Button253_3) configure -state disable
    $widget(Button253_4) configure -state disable
    
    set SurfaceThreshold1 "-11"
    set SurfaceThreshold2 "0"
    set SurfaceThreshold3 ""
    set SurfaceThreshold4 ""
    $widget(Label253_2) configure -state normal
    $widget(Entry253_6) configure -state normal
    $widget(Entry253_6) configure -disabledbackground #FFFFFF
    $widget(Label253_5) configure -state normal
    $widget(Label253_3) configure -state normal
    $widget(Entry253_7) configure -state normal
    $widget(Entry253_7) configure -disabledbackground #FFFFFF
    $widget(Label253_6) configure -state normal
    $widget(Button253_5) configure -state normal
    $widget(Button253_6) configure -state disable
    $widget(Button253_8) configure -state disable
    $widget(Label253_4) configure -state disable
    $widget(Label253_7) configure -state disable
    $widget(Entry253_8) configure -state disable
    $widget(Entry253_8) configure -disabledbackground $PSPBackgroundColor
    $widget(Label253_8) configure -state disable
    $widget(Entry253_9) configure -state disable
    $widget(Entry253_9) configure -disabledbackground $PSPBackgroundColor
    $widget(Checkbutton253_2) configure -state disable
    set DisplayXBraggHAlpha 0
    $widget(Button253_7) configure -state disable
    $widget(Button253_9) configure -state disable
    }} \
        -text Dubois -value dubois -variable SurfaceModel 
    vTcl:DefineAlias "$site_4_0.cpd73" "Radiobutton5" vTcl:WidgetProc "Toplevel253" 1
    radiobutton $site_4_0.rad71 \
        \
        -command {global SurfaceModel SurfaceFreq SurfaceCoeffCalib SurfaceCalibFlag
global SurfaceNwinL SurfaceNwinC SurfaceDieli SurfaceBeta
global SurfaceThreshold1 SurfaceThreshold2 SurfaceThreshold3 SurfaceThreshold4
global GnuplotPipeFid GnuplotPipeHisto DisplayXBraggHAlpha

if {$GnuplotPipeHisto != ""} {
    catch "close $GnuplotPipeHisto"
    set GnuplotPipeHisto ""
    }
set GnuplotPipeFid ""
Window hide .top401; Window hide .top402; Window hide .top419

if {$SurfaceModel == "oh"} {
    set SurfaceFreq ""
    $widget(TitleFrame253_1) configure -text ""
    $widget(Entry253_1) configure -state disable
    $widget(Entry253_1) configure -disabledbackground $PSPBackgroundColor
    set SurfaceCoeffCalib ""
    $widget(TitleFrame253_2) configure -text ""
    $widget(Entry253_2) configure -state disable
    $widget(Entry253_2) configure -disabledbackground $PSPBackgroundColor
    set SurfaceCalibFlag 0
    $widget(Checkbutton253_1) configure -state disable

    $widget(TitleFrame253_3) configure -text ""
    $widget(TitleFrame253_4) configure -text ""
    $widget(TitleFrame253_5) configure -text ""
    set SurfaceNwinL ""; set SurfaceNwinC ""
    $widget(Label253_1a) configure -state disable
    $widget(Label253_1b) configure -state disable
    $widget(Entry253_3a) configure -state disable
    $widget(Entry253_3a) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry253_3b) configure -state disable
    $widget(Entry253_3b) configure -disabledbackground $PSPBackgroundColor
    set SurfaceDieli ""
    $widget(Entry253_4) configure -state disable
    $widget(Entry253_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button253_1) configure -state disable
    $widget(Button253_2) configure -state disable
    set SurfaceBeta ""
    $widget(Entry253_5) configure -state disable
    $widget(Entry253_5) configure -disabledbackground $PSPBackgroundColor
    $widget(Button253_3) configure -state disable
    $widget(Button253_4) configure -state disable

    set SurfaceThreshold1 "-11"
    set SurfaceThreshold2 "0"
    set SurfaceThreshold3 ""
    set SurfaceThreshold4 ""
    $widget(Label253_2) configure -state normal
    $widget(Entry253_6) configure -state normal
    $widget(Entry253_6) configure -disabledbackground #FFFFFF
    $widget(Label253_5) configure -state normal
    $widget(Label253_3) configure -state normal
    $widget(Entry253_7) configure -state normal
    $widget(Entry253_7) configure -disabledbackground #FFFFFF
    $widget(Label253_6) configure -state normal
    $widget(Button253_5) configure -state normal
    $widget(Button253_6) configure -state disable
    $widget(Button253_8) configure -state disable
    $widget(Label253_4) configure -state disable
    $widget(Label253_7) configure -state disable
    $widget(Entry253_8) configure -state disable
    $widget(Entry253_8) configure -disabledbackground $PSPBackgroundColor
    $widget(Label253_8) configure -state disable
    $widget(Entry253_9) configure -state disable
    $widget(Entry253_9) configure -disabledbackground $PSPBackgroundColor
    $widget(Checkbutton253_2) configure -state disable
    set DisplayXBraggHAlpha 0
    $widget(Button253_7) configure -state disable
    $widget(Button253_9) configure -state disable
    }} \
        -text Oh -value oh -variable SurfaceModel 
    vTcl:DefineAlias "$site_4_0.rad71" "Radiobutton3" vTcl:WidgetProc "Toplevel253" 1
    radiobutton $site_4_0.cpd72 \
        \
        -command {global SurfaceModel SurfaceFreq SurfaceCoeffCalib SurfaceCalibFlag
global SurfaceNwinL SurfaceNwinC SurfaceDieli SurfaceBeta
global SurfaceThreshold1 SurfaceThreshold2 SurfaceThreshold3 SurfaceThreshold4
global GnuplotPipeFid GnuplotPipeHisto DisplayXBraggHAlpha

if {$GnuplotPipeHisto != ""} {
    catch "close $GnuplotPipeHisto"
    set GnuplotPipeHisto ""
    }
set GnuplotPipeFid ""
Window hide .top401; Window hide .top402; Window hide .top419

if {$SurfaceModel == "oh2004"} {
    set SurfaceFreq "?"
    $widget(TitleFrame253_1) configure -text "Central Frequency (GHz)"
    $widget(Entry253_1) configure -state normal
    $widget(Entry253_1) configure -disabledbackground #FFFFFF
    set SurfaceCoeffCalib ""
    $widget(TitleFrame253_2) configure -text ""
    $widget(Entry253_2) configure -state disable
    $widget(Entry253_2) configure -disabledbackground $PSPBackgroundColor
    set SurfaceCalibFlag 0
    $widget(Checkbutton253_1) configure -state disable

    $widget(TitleFrame253_3) configure -text ""
    $widget(TitleFrame253_4) configure -text ""
    $widget(TitleFrame253_5) configure -text ""
    set SurfaceNwinL ""; set SurfaceNwinC ""
    $widget(Label253_1a) configure -state disable
    $widget(Label253_1b) configure -state disable
    $widget(Entry253_3a) configure -state disable
    $widget(Entry253_3a) configure -disabledbackground $PSPBackgroundColor
    $widget(Entry253_3b) configure -state disable
    $widget(Entry253_3b) configure -disabledbackground $PSPBackgroundColor
    set SurfaceDieli ""
    $widget(Entry253_4) configure -state disable
    $widget(Entry253_4) configure -disabledbackground $PSPBackgroundColor
    $widget(Button253_1) configure -state disable
    $widget(Button253_2) configure -state disable
    set SurfaceBeta ""
    $widget(Entry253_5) configure -state disable
    $widget(Entry253_5) configure -disabledbackground $PSPBackgroundColor
    $widget(Button253_3) configure -state disable
    $widget(Button253_4) configure -state disable

    set SurfaceThreshold3 "0.01"
    set SurfaceThreshold4 "0.055"
    set SurfaceThreshold1 ""
    set SurfaceThreshold2 ""
    $widget(Label253_2) configure -state disable
    $widget(Entry253_6) configure -state disable
    $widget(Entry253_6) configure -disabledbackground $PSPBackgroundColor
    $widget(Label253_5) configure -state disable
    $widget(Label253_3) configure -state disable
    $widget(Entry253_7) configure -state disable
    $widget(Entry253_7) configure -disabledbackground $PSPBackgroundColor
    $widget(Label253_6) configure -state disable
    $widget(Button253_5) configure -state disable
    $widget(Button253_6) configure -state disable
    $widget(Button253_8) configure -state disable
    $widget(Label253_4) configure -state normal
    $widget(Label253_7) configure -state normal
    $widget(Entry253_8) configure -state normal
    $widget(Entry253_8) configure -disabledbackground #FFFFFF
    $widget(Label253_8) configure -state normal
    $widget(Entry253_9) configure -state normal
    $widget(Entry253_9) configure -disabledbackground #FFFFFF
    $widget(Checkbutton253_2) configure -state disable
    set DisplayXBraggHAlpha 0
    $widget(Button253_7) configure -state disable
    $widget(Button253_9) configure -state disable
    }} \
        -text {Oh 2004} -value oh2004 -variable SurfaceModel 
    vTcl:DefineAlias "$site_4_0.cpd72" "Radiobutton4" vTcl:WidgetProc "Toplevel253" 1
    radiobutton $site_4_0.cpd75 \
        \
        -command {global SurfaceModel SurfaceFreq SurfaceCoeffCalib SurfaceCalibFlag
global SurfaceNwinL SurfaceNwinC SurfaceDieli SurfaceBeta
global SurfaceThreshold1 SurfaceThreshold2 SurfaceThreshold3 SurfaceThreshold4
global GnuplotPipeFid GnuplotPipeHisto DisplayXBraggHAlpha

if {$GnuplotPipeHisto != ""} {
    catch "close $GnuplotPipeHisto"
    set GnuplotPipeHisto ""
    }
set GnuplotPipeFid ""
Window hide .top401; Window hide .top402; Window hide .top419
    
if {$SurfaceModel == "xbragg"} {
    set SurfaceFreq ""
    $widget(TitleFrame253_1) configure -text ""
    $widget(Entry253_1) configure -state disable
    $widget(Entry253_1) configure -disabledbackground $PSPBackgroundColor
    set SurfaceCoeffCalib ""
    $widget(TitleFrame253_2) configure -text ""
    $widget(Entry253_2) configure -state disable
    $widget(Entry253_2) configure -disabledbackground $PSPBackgroundColor
    set SurfaceCalibFlag 0
    $widget(Checkbutton253_1) configure -state disable

    $widget(TitleFrame253_3) configure -text "X-Bragg Parameters"
    $widget(TitleFrame253_4) configure -text "Dielectric Constant Step"
    $widget(TitleFrame253_5) configure -text "Beta Angle Step"
    set SurfaceNwinL "?"; set SurfaceNwinC "?"
    $widget(Label253_1a) configure -state normal
    $widget(Entry253_3a) configure -state normal
    $widget(Label253_1b) configure -state normal
    $widget(Entry253_3b) configure -state normal
    set SurfaceDieli "3"
    $widget(Entry253_4) configure -state disable
    $widget(Entry253_4) configure -disabledbackground #FFFFFF
    $widget(Button253_1) configure -state normal
    $widget(Button253_2) configure -state normal
    set SurfaceBeta "5"
    $widget(Entry253_5) configure -state disable
    $widget(Entry253_5) configure -disabledbackground #FFFFFF
    $widget(Button253_3) configure -state normal
    $widget(Button253_4) configure -state normal

    set SurfaceThreshold1 ""
    set SurfaceThreshold2 ""
    set SurfaceThreshold3 ""
    set SurfaceThreshold4 ""
    $widget(Label253_2) configure -state disable
    $widget(Entry253_6) configure -state disable
    $widget(Entry253_6) configure -disabledbackground $PSPBackgroundColor
    $widget(Label253_5) configure -state disable
    $widget(Label253_3) configure -state disable
    $widget(Entry253_7) configure -state disable
    $widget(Entry253_7) configure -disabledbackground $PSPBackgroundColor
    $widget(Label253_6) configure -state disable
    $widget(Button253_5) configure -state disable
    $widget(Button253_6) configure -state disable
    $widget(Button253_8) configure -state disable
    $widget(Label253_4) configure -state disable
    $widget(Label253_7) configure -state disable
    $widget(Entry253_8) configure -state disable
    $widget(Entry253_8) configure -disabledbackground $PSPBackgroundColor
    $widget(Label253_8) configure -state disable
    $widget(Entry253_9) configure -state disable
    $widget(Entry253_9) configure -disabledbackground $PSPBackgroundColor
    $widget(Checkbutton253_2) configure -state normal
    set DisplayXBraggHAlpha 1
    $widget(Button253_7) configure -state disable
    $widget(Button253_9) configure -state disable
     }} \
        -text {X-Bragg 2008} -value xbragg -variable SurfaceModel 
    vTcl:DefineAlias "$site_4_0.cpd75" "Radiobutton7" vTcl:WidgetProc "Toplevel253" 1
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.rad71 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    frame $top.fra71 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra71" "Frame4" vTcl:WidgetProc "Toplevel253" 1
    set site_3_0 $top.fra71
    TitleFrame $site_3_0.tit72 \
        -text {Local Incidence Angle Unit} 
    vTcl:DefineAlias "$site_3_0.tit72" "TitleFrame4" vTcl:WidgetProc "Toplevel253" 1
    bind $site_3_0.tit72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.tit72 getframe]
    radiobutton $site_5_0.cpd74 \
        -text Degree -value 0 -variable LIAangle 
    vTcl:DefineAlias "$site_5_0.cpd74" "Radiobutton1" vTcl:WidgetProc "Toplevel253" 1
    radiobutton $site_5_0.cpd75 \
        -text Radian -value 1 -variable LIAangle 
    vTcl:DefineAlias "$site_5_0.cpd75" "Radiobutton2" vTcl:WidgetProc "Toplevel253" 1
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    TitleFrame $site_3_0.cpd76 \
        -text {Central Frequency (GHz)} 
    vTcl:DefineAlias "$site_3_0.cpd76" "TitleFrame253_1" vTcl:WidgetProc "Toplevel253" 1
    bind $site_3_0.cpd76 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd76 getframe]
    entry $site_5_0.cpd73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SurfaceFreq -width 10 
    vTcl:DefineAlias "$site_5_0.cpd73" "Entry253_1" vTcl:WidgetProc "Toplevel253" 1
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    TitleFrame $site_3_0.cpd71 \
        -text Calibration 
    vTcl:DefineAlias "$site_3_0.cpd71" "TitleFrame253_2" vTcl:WidgetProc "Toplevel253" 1
    bind $site_3_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd71 getframe]
    checkbutton $site_5_0.che71 \
        \
        -command {global SurfaceCoeffCalib SurfaceCalibFlag

if {$SurfaceCalibFlag == 1} {
    set SurfaceCoeffCalib "?"
    $widget(TitleFrame253_2) configure -text "Calibration Coefficient"
    $widget(Entry253_2) configure -state normal
    $widget(Entry253_2) configure -disabledbackground #FFFFFF
    } else {
    set SurfaceCoeffCalib ""
    $widget(TitleFrame253_2) configure -text "Calibration"
    $widget(Entry253_2) configure -state disable
    $widget(Entry253_2) configure -disabledbackground $PSPBackgroundColor
    }} \
        -variable SurfaceCalibFlag 
    vTcl:DefineAlias "$site_5_0.che71" "Checkbutton253_1" vTcl:WidgetProc "Toplevel253" 1
    entry $site_5_0.cpd73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SurfaceCoeffCalib -width 10 
    vTcl:DefineAlias "$site_5_0.cpd73" "Entry253_2" vTcl:WidgetProc "Toplevel253" 1
    pack $site_5_0.che71 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.cpd73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side right 
    pack $site_3_0.tit72 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd76 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 30 -ipady 2 \
        -side left 
    pack $site_3_0.cpd71 \
        -in $site_3_0 -anchor center -expand 1 -fill none -ipadx 20 -ipady 2 \
        -side left 
    TitleFrame $top.cpd66 \
        -ipad 2 -text {X-Bragg Parameters} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame253_3" vTcl:WidgetProc "Toplevel253" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    frame $site_4_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra73" "Frame7" vTcl:WidgetProc "Toplevel253" 1
    set site_5_0 $site_4_0.fra73
    label $site_5_0.lab74 \
        -text {Window Size : Row} 
    vTcl:DefineAlias "$site_5_0.lab74" "Label253_1a" vTcl:WidgetProc "Toplevel253" 1
    entry $site_5_0.ent75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SurfaceNwinL -width 5 
    vTcl:DefineAlias "$site_5_0.ent75" "Entry253_3a" vTcl:WidgetProc "Toplevel253" 1
    label $site_5_0.cpd71 \
        -text Col 
    vTcl:DefineAlias "$site_5_0.cpd71" "Label253_1b" vTcl:WidgetProc "Toplevel253" 1
    entry $site_5_0.cpd72 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SurfaceNwinC -width 5 
    vTcl:DefineAlias "$site_5_0.cpd72" "Entry253_3b" vTcl:WidgetProc "Toplevel253" 1
    pack $site_5_0.lab74 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    pack $site_5_0.ent75 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_5_0.cpd71 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_5_0.cpd72 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd67 \
        -ipad 2 -text {Dielectric Constant Step} 
    vTcl:DefineAlias "$site_4_0.cpd67" "TitleFrame253_4" vTcl:WidgetProc "Toplevel253" 1
    bind $site_4_0.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd67 getframe]
    entry $site_6_0.cpd73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SurfaceDieli -width 5 
    vTcl:DefineAlias "$site_6_0.cpd73" "Entry253_4" vTcl:WidgetProc "Toplevel253" 1
    frame $site_6_0.fra68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra68" "Frame5" vTcl:WidgetProc "Toplevel253" 1
    set site_7_0 $site_6_0.fra68
    button $site_7_0.cpd70 \
        \
        -command {global SurfaceDieli

set SurfaceDieli [expr $SurfaceDieli + 1]
if {$SurfaceDieli == 6} { set SurfaceDieli 1 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.cpd70" "Button253_1" vTcl:WidgetProc "Toplevel253" 1
    button $site_7_0.but69 \
        \
        -command {global SurfaceDieli

set SurfaceDieli [expr $SurfaceDieli - 1]
if {$SurfaceDieli == 0} { set SurfaceDieli 5 }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.but69" "Button253_2" vTcl:WidgetProc "Toplevel253" 1
    pack $site_7_0.cpd70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.but69 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.fra68 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $site_4_0.cpd72 \
        -ipad 2 -text {Beta Angle Step} 
    vTcl:DefineAlias "$site_4_0.cpd72" "TitleFrame253_5" vTcl:WidgetProc "Toplevel253" 1
    bind $site_4_0.cpd72 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd72 getframe]
    entry $site_6_0.cpd73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -justify center \
        -state disabled -textvariable SurfaceBeta -width 5 
    vTcl:DefineAlias "$site_6_0.cpd73" "Entry253_5" vTcl:WidgetProc "Toplevel253" 1
    frame $site_6_0.fra68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra68" "Frame6" vTcl:WidgetProc "Toplevel253" 1
    set site_7_0 $site_6_0.fra68
    button $site_7_0.cpd70 \
        \
        -command {global SurfaceBeta

set SurfaceBeta [expr $SurfaceBeta + 1]
if {$SurfaceBeta == 11} { set SurfaceBeta 1 }} \
        -image [vTcl:image:get_image [file join . GUI Images up.gif]] -pady 0 \
        -text button 
    vTcl:DefineAlias "$site_7_0.cpd70" "Button253_3" vTcl:WidgetProc "Toplevel253" 1
    button $site_7_0.but69 \
        \
        -command {global SurfaceBeta

set SurfaceBeta [expr $SurfaceBeta - 1]
if {$SurfaceBeta == 0} { set SurfaceBeta 10 }} \
        -image [vTcl:image:get_image [file join . GUI Images down.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_7_0.but69" "Button253_4" vTcl:WidgetProc "Toplevel253" 1
    pack $site_7_0.cpd70 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.but69 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd73 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.fra68 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra73 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 1 -fill none -ipadx 40 \
        -side left 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 1 -fill none -ipadx 20 \
        -side left 
    TitleFrame $top.cpd67 \
        -ipad 2 -text Thresholds 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame253" vTcl:WidgetProc "Toplevel253" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    frame $site_4_0.cpd67
    set site_5_0 $site_4_0.cpd67
    button $site_5_0.but67 \
        -background #ffffff \
        -command {global TMPGnuPlotTk1 TMPGnuPlotTk2 

Gimp $TMPGnuPlotTk1
Gimp $TMPGnuPlotTk2} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but67" "Button253_8" vTcl:WidgetProc "Toplevel253" 1
    frame $site_5_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra73" "Frame11" vTcl:WidgetProc "Toplevel253" 1
    set site_6_0 $site_5_0.fra73
    label $site_6_0.lab74 \
        -text {HVHV / VVVV  <  } 
    vTcl:DefineAlias "$site_6_0.lab74" "Label253_2" vTcl:WidgetProc "Toplevel253" 1
    entry $site_6_0.ent75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SurfaceThreshold1 -width 5 
    vTcl:DefineAlias "$site_6_0.ent75" "Entry253_6" vTcl:WidgetProc "Toplevel253" 1
    label $site_6_0.cpd70 \
        -text (dB) 
    vTcl:DefineAlias "$site_6_0.cpd70" "Label253_5" vTcl:WidgetProc "Toplevel253" 1
    pack $site_6_0.lab74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_6_0.cpd70 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    button $site_5_0.but66 \
        -background #ffff00 \
        -command {global ErrorMessage VarError VarSaveGnuPlotFile
global SaveDisplayDirOutput SurfaceDirOutput
global GnuplotPipeFid
global SaveDisplayOutputFile1 SaveDisplayOutputFile2

#BMP_PROCESS
global Load_SaveDisplay2 PSPTopLevel

if {$Load_SaveDisplay2 == 0} {
    source "GUI/bmp_process/SaveDisplay2.tcl"
    set Load_SaveDisplay2 1
    WmTransient $widget(Toplevel457) $PSPTopLevel
    }

set SaveDisplayDirOutput $SurfaceDirOutput
set SaveDisplayOutputFile1 "Histogram_HVHV_VVVV"
set SaveDisplayOutputFile2 "Histogram_HHHH_VVVV"

set VarSaveGnuPlotFile ""
WidgetShowFromWidget $widget(Toplevel253) $widget(Toplevel457); TextEditorRunTrace "Open Window Save Display 2" "b"
tkwait variable VarSaveGnuPlotFile
} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_5_0.but66" "Button253_6" vTcl:WidgetProc "Toplevel253" 1
    frame $site_5_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd68" "Frame12" vTcl:WidgetProc "Toplevel253" 1
    set site_6_0 $site_5_0.cpd68
    label $site_6_0.lab74 \
        -text {HHHH / VVVV  <  } 
    vTcl:DefineAlias "$site_6_0.lab74" "Label253_3" vTcl:WidgetProc "Toplevel253" 1
    entry $site_6_0.ent75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SurfaceThreshold2 -width 5 
    vTcl:DefineAlias "$site_6_0.ent75" "Entry253_7" vTcl:WidgetProc "Toplevel253" 1
    label $site_6_0.cpd66 \
        -text (dB) 
    vTcl:DefineAlias "$site_6_0.cpd66" "Label253_6" vTcl:WidgetProc "Toplevel253" 1
    pack $site_6_0.lab74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_6_0.cpd66 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    button $site_5_0.cpd66 \
        -background #ffff00 \
        -command {global OpenDirFile 
global TMPStatisticsBin1 TMPStatResultsTxt1 TMPStatHistoTxt1
global TMPStatisticsBin2 TMPStatResultsTxt2 TMPStatHistoTxt2
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global GnuHistoFile1 GnuHistoFile2 GnuHistoMax1 GnuHistoMax2
global SurfaceDirInput SurfaceOutputSubDir
global VarError ErrorMessage 

if {$OpenDirFile == 0} {

DeleteFile $TMPStatisticsBin1
DeleteFile $TMPStatResultsTxt1
DeleteFile $TMPStatHistoTxt1
DeleteFile $TMPStatisticsBin2
DeleteFile $TMPStatResultsTxt2
DeleteFile $TMPStatHistoTxt2

set OffsetLig [expr $NligInit - 1]
set OffsetCol [expr $NcolInit - 1]
set FinalNlig [expr $NligEnd - $NligInit + 1]
set FinalNcol [expr $NcolEnd - $NcolInit + 1]

set Fonction ""
set Fonction2 ""
set MaskCmd ""
set MaskFile "$SurfaceDirInput/mask_valid_pixels.bin"
if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
set ProgressLine "0"
WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
update
if {$SurfaceOutputSubDir == ""} {set SurfaceF "S2"}
if {$SurfaceOutputSubDir == "T3"} {set SurfaceF "T3"}
if {$SurfaceOutputSubDir == "T4"} {set SurfaceF "T4"}
if {$SurfaceOutputSubDir == "C3"} {set SurfaceF "C3"}
if {$SurfaceOutputSubDir == "C4"} {set SurfaceF "C4"}
TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/surface_inversion_histo.exe" "k"
TextEditorRunTrace "Arguments: -id \x22$SurfaceDirInput\x22 -iodf $SurfaceF -hvvv \x22$TMPStatisticsBin1\x22 -hhvv \x22$TMPStatisticsBin2\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
set f [ open "| Soft/bin/data_process_sngl/surface_inversion_histo.exe -id \x22$SurfaceDirInput\x22 -iodf $SurfaceF -hvvv \x22$TMPStatisticsBin1\x22 -hhvv \x22$TMPStatisticsBin2\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
PsPprogressBar $f
TextEditorRunTrace "Check RunTime Errors" "r"
CheckRunTimeError
WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

set config "true"
if [file exists $TMPStatisticsBin1] {
    Window hide .top401
    DeleteFile $TMPStatHistoTxt1
    TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/statistics_histogram.exe" "k"
    TextEditorRunTrace "Arguments: \x22$TMPStatisticsBin1\x22 \x22$TMPStatHistoTxt1\x22 \x22$TMPStatResultsTxt1\x22 float real 200 1 -9999 +9999" "k"
    set f [ open "| Soft/bin/data_process_sngl/statistics_histogram.exe \x22$TMPStatisticsBin1\x22 \x22$TMPStatHistoTxt1\x22 \x22$TMPStatResultsTxt1\x22 float real 200 1 -9999 +9999" r]
    catch "close $f"
    }            
if [file exists $TMPStatHistoTxt1] {
    set GnuHistoFile1 "$TMPStatHistoTxt1"
    set f [open $TMPStatResultsTxt1 r]
    gets $f GnuHistoMax1
    close $f
    } else {
    set VarError ""
    set ErrorMessage "PROBLEM DURING HISTOGRAM GENERATION" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }

if [file exists $TMPStatisticsBin2] {
    Window hide .top402
    DeleteFile $TMPStatHistoTxt2
    TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/statistics_histogram.exe" "k"
    TextEditorRunTrace "Arguments: \x22$TMPStatisticsBin2\x22 \x22$TMPStatHistoTxt2\x22 \x22$TMPStatResultsTxt2\x22 float real 200 1 -9999 +9999" "k"
    set f [ open "| Soft/bin/data_process_sngl/statistics_histogram.exe \x22$TMPStatisticsBin2\x22 \x22$TMPStatHistoTxt2\x22 \x22$TMPStatResultsTxt2\x22 float real 200 1 -9999 +9999" r]
    catch "close $f"
    }            
if [file exists $TMPStatHistoTxt2] {
    set GnuHistoFile2 "$TMPStatHistoTxt2"
    set f [open $TMPStatResultsTxt2 r]
    gets $f GnuHistoMax2
    close $f
    } else {
    set VarError ""
    set ErrorMessage "PROBLEM DURING HISTOGRAM GENERATION" 
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    set config "false"
    }
if {$config == "true"} { SurfacePlotHisto1D; $widget(Button253_6) configure -state normal;  $widget(Button253_8) configure -state normal }
}} \
        -padx 4 -pady 2 -text Histo 
    vTcl:DefineAlias "$site_5_0.cpd66" "Button253_5" vTcl:WidgetProc "Toplevel253" 1
    pack $site_5_0.but67 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_5_0.fra73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.but66 \
        -in $site_5_0 -anchor center -expand 0 -fill none -padx 5 -side right 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd66 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    frame $site_4_0.cpd68
    set site_5_0 $site_4_0.cpd68
    label $site_5_0.cpd69 \
        -text {HHHH / VVVV  <  p_max} 
    vTcl:DefineAlias "$site_5_0.cpd69" "Label253_4" vTcl:WidgetProc "Toplevel253" 1
    frame $site_5_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.fra73" "Frame14" vTcl:WidgetProc "Toplevel253" 1
    set site_6_0 $site_5_0.fra73
    label $site_6_0.lab74 \
        -text {soil moisture ( mv ) = } 
    vTcl:DefineAlias "$site_6_0.lab74" "Label253_7" vTcl:WidgetProc "Toplevel253" 1
    entry $site_6_0.ent75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SurfaceThreshold3 -width 5 
    vTcl:DefineAlias "$site_6_0.ent75" "Entry253_8" vTcl:WidgetProc "Toplevel253" 1
    pack $site_6_0.lab74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    frame $site_5_0.cpd68 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_5_0.cpd68" "Frame15" vTcl:WidgetProc "Toplevel253" 1
    set site_6_0 $site_5_0.cpd68
    label $site_6_0.lab74 \
        -text {surface roughness ( s ) = } 
    vTcl:DefineAlias "$site_6_0.lab74" "Label253_8" vTcl:WidgetProc "Toplevel253" 1
    entry $site_6_0.ent75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -justify center \
        -textvariable SurfaceThreshold4 -width 5 
    vTcl:DefineAlias "$site_6_0.ent75" "Entry253_9" vTcl:WidgetProc "Toplevel253" 1
    pack $site_6_0.lab74 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.ent75 \
        -in $site_6_0 -anchor center -expand 1 -fill none -padx 2 -side left 
    pack $site_5_0.cpd69 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra73 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.cpd68 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.cpd67 \
        -in $site_4_0 -anchor center -expand 0 -fill x -side top 
    pack $site_4_0.cpd68 \
        -in $site_4_0 -anchor center -expand 0 -fill x -pady 2 -side top 
    frame $top.fra67 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra67" "Frame8" vTcl:WidgetProc "Toplevel253" 1
    set site_3_0 $top.fra67
    checkbutton $site_3_0.cpd68 \
        -text {Display X-Bragg - H / Alpha plane} \
        -variable DisplayXBraggHAlpha 
    vTcl:DefineAlias "$site_3_0.cpd68" "Checkbutton253_2" vTcl:WidgetProc "Toplevel253" 1
    button $site_3_0.cpd69 \
        -background #ffff00 \
        -command {global ErrorMessage VarError VarSaveGnuPlotFile
global SaveDisplayDirOutput SurfaceDirOutput
global GnuplotPipeFid
global SaveDisplayOutputFile1 SaveDisplayOutputFileNum

#BMP_PROCESS
global Load_SaveDisplay1num PSPTopLevel

if {$Load_SaveDisplay1num == 0} {
    source "GUI/bmp_process/SaveDisplay1num.tcl"
    set Load_SaveDisplay1num 1
    WmTransient $widget(Toplevel460) $PSPTopLevel
    }

set SaveDisplayDirOutput $SurfaceDirOutput
set SaveDisplayOutputFile1 "H_alpha_plane"
set SaveDisplayOutputFileNum 3

set VarSaveGnuPlotFile ""
WidgetShowFromWidget $widget(Toplevel253) $widget(Toplevel460); TextEditorRunTrace "Open Window Save Display 1" "b"
tkwait variable VarSaveGnuPlotFile} \
        -image [vTcl:image:get_image [file join . GUI Images SaveFile.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.cpd69" "Button253_7" vTcl:WidgetProc "Toplevel253" 1
    button $site_3_0.cpd70 \
        -background #ffffff \
        -command {global TMPGnuPlotTk3 

Gimp $TMPGnuPlotTk3} \
        -image [vTcl:image:get_image [file join . GUI Images GIMPshortcut.gif]] \
        -pady 0 -text button 
    vTcl:DefineAlias "$site_3_0.cpd70" "Button253_9" vTcl:WidgetProc "Toplevel253" 1
    pack $site_3_0.cpd68 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd69 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_3_0.cpd70 \
        -in $site_3_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    frame $top.fra83 \
        -relief groove -height 35 -width 125 
    vTcl:DefineAlias "$top.fra83" "Frame20" vTcl:WidgetProc "Toplevel253" 1
    set site_3_0 $top.fra83
    button $site_3_0.but93 \
        -background #ffff00 \
        -command {global DataDir DirName SurfaceDirInput SurfaceDirOutput SurfaceOutputDir SurfaceOutputSubDir 
global Fonction2 ProgressLine VarFunction VarWarning VarAdvice WarningMessage WarningMessage2
global ConfigFile FinalNlig FinalNcol PolarCase PolarType
global SurfaceModel LIAFile LIAangle SurfaceFreq SurfaceCoeffCalib SurfaceCalibFlag
global SurfaceThreshold1 SurfaceThreshold2 SurfaceThreshold3 SurfaceThreshold4 
global SurfaceNwinL SurfaceNwinC SurfaceDieli SurfaceBeta TMPMemoryAllocError
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax
global DisplayXBraggHAlpha

if {$OpenDirFile == 0} {

set SCoeffCalib "1.0"

set config "true"
if {$SurfaceModel == "dubois"} {
    if {$SurfaceFreq == ""} {set config "false1"}
    if {$SurfaceFreq == "0"} {set config "false1"}
    if {$SurfaceFreq == "?"} {set config "false1"}
    if {$SurfaceCalibFlag == 1} {
        if {$SurfaceCoeffCalib == ""} {set config "false2"}
        if {$SurfaceCoeffCalib == "0"} {set config "false2"}
        if {$SurfaceCoeffCalib == "?"} {set config "false2"}
        }
    }
if {$SurfaceModel == "oh2004"} {
    if {$SurfaceFreq == ""} {set config "false1"}
    if {$SurfaceFreq == "0"} {set config "false1"}
    if {$SurfaceFreq == "?"} {set config "false1"}
    }
if {$SurfaceModel == "xbragg"} {
    if {$SurfaceNwinL == ""} {set config "false3"}
    if {$SurfaceNwinL == "0"} {set config "false3"}
    if {$SurfaceNwinL == "?"} {set config "false3"}
    if {$SurfaceNwinC == ""} {set config "false3"}
    if {$SurfaceNwinC == "0"} {set config "false3"}
    if {$SurfaceNwinC == "?"} {set config "false3"}
    }
if {$config != "true"} {
    if {$config == "false1"} {
        set VarError ""
        set ErrorMessage "ENTER THE CENTRAL FREQUENCY VALUE" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    if {$config == "false2"} {
        set VarError ""
        set ErrorMessage "ENTER THE CALIBRATION COEFFICIENT VALUE" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    if {$config == "false3"} {
        set VarError ""
        set ErrorMessage "ENTER THE WINDOW SIZE" 
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        }
    } else {

set SurfaceDirOutput $SurfaceOutputDir
if {$SurfaceOutputSubDir != ""} {append SurfaceDirOutput "/$SurfaceOutputSubDir"}

    #####################################################################
    #Create Directory
    set SurfaceDirOutput [PSPCreateDirectoryMask $SurfaceDirOutput $SurfaceDirOutput $SurfaceDirInput]
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
    set TestVarName(4) "Local Incidence Angle File"; set TestVarType(4) "file"; set TestVarValue(4) $LIAFile; set TestVarMin(4) ""; set TestVarMax(4) ""
    if {$SurfaceModel == "oh2004"} {
        set TestVarName(5) "Threshold 1"; set TestVarType(5) "float"; set TestVarValue(5) $SurfaceThreshold3; set TestVarMin(5) "-9999"; set TestVarMax(5) "9999"
        set TestVarName(6) "Threshold 2"; set TestVarType(6) "float"; set TestVarValue(6) $SurfaceThreshold4; set TestVarMin(6) "-9999"; set TestVarMax(6) "9999"
        } else {
        if {$SurfaceModel == "xbragg"} {
            set SurfaceThresh1 0; set SurfaceThresh2 0
            } else {
            set SurfaceThresh1 $SurfaceThreshold1; set SurfaceThresh2 $SurfaceThreshold2
            }
        set TestVarName(5) "Threshold 1"; set TestVarType(5) "float"; set TestVarValue(5) $SurfaceThresh1; set TestVarMin(5) "-9999"; set TestVarMax(5) "9999"
        set TestVarName(6) "Threshold 2"; set TestVarType(6) "float"; set TestVarValue(6) $SurfaceThresh2; set TestVarMin(6) "-9999"; set TestVarMax(6) "9999"
        }
    if {$SurfaceModel == "dubois"} {
        set TestVarName(7) "Central Frequency"; set TestVarType(7) "float"; set TestVarValue(7) $SurfaceFreq; set TestVarMin(7) "0"; set TestVarMax(7) ""
        if {$SurfaceCalibFlag == 1} {
            set TestVarName(8) "Calibration Coefficient"; set TestVarType(8) "float"; set TestVarValue(8) $SurfaceCoeffCalib; set TestVarMin(8) "0."; set TestVarMax(8) ""
            TestVar 9
            } else {
            TestVar 8
            }
        }
    if {$SurfaceModel == "oh"} { TestVar 7 }
    if {$SurfaceModel == "oh2004"} {
        set TestVarName(7) "Central Frequency"; set TestVarType(7) "float"; set TestVarValue(7) $SurfaceFreq; set TestVarMin(7) "0"; set TestVarMax(7) ""
        TestVar 8
        }
    if {$SurfaceModel == "xbragg"} {
        set TestVarName(7) "Window Size Row"; set TestVarType(7) "int"; set TestVarValue(7) $SurfaceNwinL; set TestVarMin(7) "1"; set TestVarMax(7) "1000"
        set TestVarName(8) "Window Size Col"; set TestVarType(8) "int"; set TestVarValue(8) $SurfaceNwinC; set TestVarMin(8) "1"; set TestVarMax(8) "1000"
        TestVar 9
        }

    if {$TestVarError == "ok"} {

    set SurfaceFonction ""
    if {$SurfaceModel == "oh"} {
        set Fonction "OH - MODEL INVERSION"
        set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$SurfaceDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$SurfaceOutputSubDir == ""} {set SurfaceF "S2"}
        if {$SurfaceOutputSubDir == "T3"} {set SurfaceF "T3"}
        if {$SurfaceOutputSubDir == "T4"} {set SurfaceF "T4"}
        if {$SurfaceOutputSubDir == "C3"} {set SurfaceF "C3"}
        if {$SurfaceOutputSubDir == "C4"} {set SurfaceF "C4"}
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/surface_inversion_oh.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SurfaceDirInput\x22 -od \x22$SurfaceDirOutput\x22 -iodf $SurfaceF -ang \x22$LIAFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -un $LIAangle -th1 $SurfaceThreshold1 -th2 $SurfaceThreshold2  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/surface_inversion_oh.exe -id \x22$SurfaceDirInput\x22 -od \x22$SurfaceDirOutput\x22 -iodf $SurfaceF -ang \x22$LIAFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -un $LIAangle -th1 $SurfaceThreshold1 -th2 $SurfaceThreshold2  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if [file exists "$SurfaceDirOutput/oh_er.bin"] {EnviWriteConfig "$SurfaceDirOutput/oh_er.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/oh_mv.bin"] {EnviWriteConfig "$SurfaceDirOutput/oh_mv.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/oh_ks.bin"] {EnviWriteConfig "$SurfaceDirOutput/oh_ks.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/oh_mask_in.bin"] {EnviWriteConfig "$SurfaceDirOutput/oh_mask_in.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/oh_mask_out.bin"] {EnviWriteConfig "$SurfaceDirOutput/oh_mask_out.bin" $FinalNlig $FinalNcol 4}

        set MaskFileBMP $MaskFile
        if [file exists "$SurfaceDirOutput/oh_mask_valid_in_out.bin"] {
            EnviWriteConfig "$SurfaceDirOutput/oh_mask_valid_in_out.bin" $FinalNlig $FinalNcol 4
            set MaskFileBMP "$SurfaceDirOutput/oh_mask_valid_in_out.bin"
            }

        set Fonction "Creation of the BMP File"
        if [file exists "$SurfaceDirOutput/oh_er.bin"] {
            set BMPFileInput "$SurfaceDirOutput/oh_er.bin"
            set BMPFileOutput "$SurfaceDirOutput/oh_er.bmp"
            PSPcreate_bmp_file_mask $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0 $MaskFileBMP
            } else {
            set VarError ""
            set ErrorMessage "THE FILE oh_er.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/oh_mv.bin"] {
            set BMPFileInput "$SurfaceDirOutput/oh_mv.bin"
            set BMPFileOutput "$SurfaceDirOutput/oh_mv.bmp"
            PSPcreate_bmp_file_mask $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0 $MaskFileBMP
            } else {
            set VarError ""
            set ErrorMessage "THE FILE oh_mv.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/oh_ks.bin"] {
            set BMPFileInput "$SurfaceDirOutput/oh_ks.bin"
            set BMPFileOutput "$SurfaceDirOutput/oh_ks.bmp"
            PSPcreate_bmp_file_mask $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0 $MaskFileBMP
            } else {
            set VarError ""
            set ErrorMessage "THE FILE oh_ks.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/oh_mask_in.bin"] {
            set BMPFileInput "$SurfaceDirOutput/oh_mask_in.bin"
            set BMPFileOutput "$SurfaceDirOutput/oh_mask_in.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            } else {
            set VarError ""
            set ErrorMessage "THE FILE oh_mask_in.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/oh_mask_out.bin"] {
            set BMPFileInput "$SurfaceDirOutput/oh_mask_out.bin"
            set BMPFileOutput "$SurfaceDirOutput/oh_mask_out.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            } else {
            set VarError ""
            set ErrorMessage "THE FILE oh_mask_out.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        }

    set SurfaceFonction ""
    if {$SurfaceModel == "oh2004"} {
        set Fonction "OH 2004 - MODEL INVERSION"
        set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$SurfaceDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$SurfaceOutputSubDir == ""} {set SurfaceF "S2"}
        if {$SurfaceOutputSubDir == "T3"} {set SurfaceF "T3"}
        if {$SurfaceOutputSubDir == "T4"} {set SurfaceF "T4"}
        if {$SurfaceOutputSubDir == "C3"} {set SurfaceF "C3"}
        if {$SurfaceOutputSubDir == "C4"} {set SurfaceF "C4"}
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/surface_inversion_oh2004.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SurfaceDirInput\x22 -od \x22$SurfaceDirOutput\x22 -iodf $SurfaceF -ang \x22$LIAFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -un $LIAangle -fr $SurfaceFreq -th1 $SurfaceThreshold3 -th2 $SurfaceThreshold4  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/surface_inversion_oh2004.exe -id \x22$SurfaceDirInput\x22 -od \x22$SurfaceDirOutput\x22 -iodf $SurfaceF -ang \x22$LIAFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -un $LIAangle -fr $SurfaceFreq -th1 $SurfaceThreshold3 -th2 $SurfaceThreshold4  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if [file exists "$SurfaceDirOutput/oh2004_mv.bin"] {EnviWriteConfig "$SurfaceDirOutput/oh2004_mv.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/oh2004_s.bin"] {EnviWriteConfig "$SurfaceDirOutput/oh2004_s.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/oh2004_mask_in.bin"] {EnviWriteConfig "$SurfaceDirOutput/oh2004_mask_in.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/oh2004_mask_out.bin"] {EnviWriteConfig "$SurfaceDirOutput/oh2004_mask_out.bin" $FinalNlig $FinalNcol 4}

        set MaskFileBMP $MaskFile
        if [file exists "$SurfaceDirOutput/oh2004_mask_valid_in_out.bin"] {
            EnviWriteConfig "$SurfaceDirOutput/oh2004_mask_valid_in_out.bin" $FinalNlig $FinalNcol 4
            set MaskFileBMP "$SurfaceDirOutput/oh2004_mask_valid_in_out.bin"
            }

        set Fonction "Creation of the BMP File"
        if [file exists "$SurfaceDirOutput/oh2004_mv.bin"] {
            set BMPFileInput "$SurfaceDirOutput/oh2004_mv.bin"
            set BMPFileOutput "$SurfaceDirOutput/oh2004_mv.bmp"
            PSPcreate_bmp_file_mask $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0 $MaskFileBMP
            } else {
            set VarError ""
            set ErrorMessage "THE FILE oh2004_mv.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/oh2004_s.bin"] {
            set BMPFileInput "$SurfaceDirOutput/oh2004_s.bin"
            set BMPFileOutput "$SurfaceDirOutput/oh2004_s.bmp"
            PSPcreate_bmp_file_mask $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0 $MaskFileBMP
            } else {
            set VarError ""
            set ErrorMessage "THE FILE oh2004_s.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/oh2004_mask_in.bin"] {
            set BMPFileInput "$SurfaceDirOutput/oh2004_mask_in.bin"
            set BMPFileOutput "$SurfaceDirOutput/oh2004_mask_in.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            } else {
            set VarError ""
            set ErrorMessage "THE FILE oh2004_mask_in.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/oh2004_mask_out.bin"] {
            set BMPFileInput "$SurfaceDirOutput/oh2004_mask_out.bin"
            set BMPFileOutput "$SurfaceDirOutput/oh2004_mask_out.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            } else {
            set VarError ""
            set ErrorMessage "THE FILE oh2004_mask_out.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        }

    set SurfaceFonction ""
    if {$SurfaceModel == "xbragg"} {
        set Fonction "X-BRAGG - MODEL INVERSION"
        set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$SurfaceDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}

        #####################################################
        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$SurfaceOutputSubDir == ""} {set SurfaceF "S2T3"}
        if {$SurfaceOutputSubDir == "T3"} {set SurfaceF "T3"}
        if {$SurfaceOutputSubDir == "T4"} {set SurfaceF "T4"}
        if {$SurfaceOutputSubDir == "C3"} {set SurfaceF "C3T3"}
        if {$SurfaceOutputSubDir == "C4"} {set SurfaceF "C4T4"}
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SurfaceDirInput\x22 -od \x22$SurfaceDirOutput\x22 -iodf $SurfaceF -nwr $SurfaceNwinL -nwc $SurfaceNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 1 -fl4 1 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/h_a_alpha_decomposition.exe -id \x22$SurfaceDirInput\x22 -od \x22$SurfaceDirOutput\x22 -iodf $SurfaceF -nwr $SurfaceNwinL -nwc $SurfaceNwinC -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fl1 0 -fl2 0 -fl3 1 -fl4 1 -fl5 0 -fl6 0 -fl7 0 -fl8 0 -fl9 0  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"

        if [file exists "$SurfaceDirOutput/alpha.bin"] {EnviWriteConfig "$SurfaceDirOutput/alpha.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/entropy.bin"] {EnviWriteConfig "$SurfaceDirOutput/entropy.bin" $FinalNlig $FinalNcol 4}

        set conf "true"
        if [file exists "$SurfaceDirOutput/entropy.bin"] {
            } else {
            set conf "false"
            set VarError ""
            set ErrorMessage "THE FILE entropy DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/alpha.bin"] {
            } else {
            set conf "false"
            set VarError ""
            set ErrorMessage "THE FILE alpha DOES NOT EXIST" 
            Window show .top44; TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            } 
        if {"$conf"=="true"} {
            if {$DisplayXBraggHAlpha == 1} {
                PsPScatterPlot "$SurfaceDirOutput/entropy.bin" "$SurfaceDirInput/mask_valid_pixels.bin" float real 0 0 1 "$SurfaceDirOutput/alpha.bin" "$SurfaceDirInput/mask_valid_pixels.bin" float real 0 0 90 $OffsetLig $OffsetCol $FinalNlig $FinalNcol HAlpha "Entropy" "Alpha (deg)" "H - Alpha Plane" 3 .top253
                $widget(Button253_7) configure -state normal
                $widget(Button253_9) configure -state normal
                }
            } 

        #####################################################

        set ProgressLine "0"
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$SurfaceOutputSubDir == ""} {set SurfaceF "S2"}
        if {$SurfaceOutputSubDir == "T3"} {set SurfaceF "T3"}
        if {$SurfaceOutputSubDir == "T4"} {set SurfaceF "T4"}
        if {$SurfaceOutputSubDir == "C3"} {set SurfaceF "C3"}
        if {$SurfaceOutputSubDir == "C4"} {set SurfaceF "C4"}
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/surface_inversion_xbragg.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SurfaceDirInput\x22 -od \x22$SurfaceDirOutput\x22 -iodf $SurfaceF -ang \x22$LIAFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -un $LIAangle -nwr $SurfaceNwinL -nwc $SurfaceNwinC -dif $SurfaceDieli -bef $SurfaceBeta  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/surface_inversion_xbragg.exe -id \x22$SurfaceDirInput\x22 -od \x22$SurfaceDirOutput\x22 -iodf $SurfaceF -ang \x22$LIAFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -un $LIAangle -nwr $SurfaceNwinL -nwc $SurfaceNwinC -dif $SurfaceDieli -bef $SurfaceBeta  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if [file exists "$SurfaceDirOutput/xbragg_dc.bin"] {EnviWriteConfig "$SurfaceDirOutput/xbragg_dc.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/xbragg_mv.bin"] {EnviWriteConfig "$SurfaceDirOutput/xbragg_mv.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/xbragg_mask_out.bin"] {EnviWriteConfig "$SurfaceDirOutput/xbragg_mask_out.bin" $FinalNlig $FinalNcol 4}

        set MaskFileBMP $MaskFile
        if [file exists "$SurfaceDirOutput/xbragg_mask_valid_in_out.bin"] {
            EnviWriteConfig "$SurfaceDirOutput/xbragg_mask_valid_in_out.bin" $FinalNlig $FinalNcol 4
            set MaskFileBMP "$SurfaceDirOutput/xbragg_mask_valid_in_out.bin"
            }

        set Fonction "Creation of the BMP File"
        if [file exists "$SurfaceDirOutput/xbragg_mv.bin"] {
            set BMPFileInput "$SurfaceDirOutput/xbragg_mv.bin"
            set BMPFileOutput "$SurfaceDirOutput/xbragg_mv.bmp"
            PSPcreate_bmp_file_mask $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0 $MaskFileBMP
            } else {
            set VarError ""
            set ErrorMessage "THE FILE xbragg_mv.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/xbragg_dc.bin"] {
            set BMPFileInput "$SurfaceDirOutput/xbragg_dc.bin"
            set BMPFileOutput "$SurfaceDirOutput/xbragg_dc.bmp"
            PSPcreate_bmp_file_mask $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0 $MaskFileBMP
            } else {
            set VarError ""
            set ErrorMessage "THE FILE xbragg_dc.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/xbragg_mask_out.bin"] {
            set BMPFileInput "$SurfaceDirOutput/xbragg_mask_out.bin"
            set BMPFileOutput "$SurfaceDirOutput/xbragg_mask_out.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            } else {
            set VarError ""
            set ErrorMessage "THE FILE xbragg_mask_out.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        }

    set SurfaceFonction ""
    if {$SurfaceModel == "dubois"} {
        set Fonction "DUBOIS - MODEL INVERSION"
        set Fonction2 ""
        set MaskCmd ""
        set MaskFile "$SurfaceDirInput/mask_valid_pixels.bin"
        if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
        set ProgressLine "0"
        if {$SurfaceCalibFlag == 1} {
            set SCoeffCalib $SurfaceCoeffCalib
            } else {
            set SCoeffCalib "1.0"
            }
        WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
        update
        if {$SurfaceOutputSubDir == ""} {set SurfaceF "S2"}
        if {$SurfaceOutputSubDir == "T3"} {set SurfaceF "T3"}
        if {$SurfaceOutputSubDir == "T4"} {set SurfaceF "T4"}
        if {$SurfaceOutputSubDir == "C3"} {set SurfaceF "C3"}
        if {$SurfaceOutputSubDir == "C4"} {set SurfaceF "C4"}
        TextEditorRunTrace "Process The Function Soft/bin/data_process_sngl/surface_inversion_dubois.exe" "k"
        TextEditorRunTrace "Arguments: -id \x22$SurfaceDirInput\x22 -od \x22$SurfaceDirOutput\x22 -iodf $SurfaceF -ang \x22$LIAFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fr $SurfaceFreq -un $LIAangle -caf $SurfaceCalibFlag -cac $SCoeffCalib -th1 $SurfaceThreshold1 -th2 $SurfaceThreshold2  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
        set f [ open "| Soft/bin/data_process_sngl/surface_inversion_dubois.exe -id \x22$SurfaceDirInput\x22 -od \x22$SurfaceDirOutput\x22 -iodf $SurfaceF -ang \x22$LIAFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -fr $SurfaceFreq -un $LIAangle -caf $SurfaceCalibFlag -cac $SCoeffCalib -th1 $SurfaceThreshold1 -th2 $SurfaceThreshold2  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
        PsPprogressBar $f
        TextEditorRunTrace "Check RunTime Errors" "r"
        CheckRunTimeError
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        if [file exists "$SurfaceDirOutput/dubois_er.bin"] {EnviWriteConfig "$SurfaceDirOutput/dubois_er.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/dubois_mv.bin"] {EnviWriteConfig "$SurfaceDirOutput/dubois_mv.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/dubois_ks.bin"] {EnviWriteConfig "$SurfaceDirOutput/dubois_ks.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/dubois_mask_in.bin"] {EnviWriteConfig "$SurfaceDirOutput/dubois_mask_in.bin" $FinalNlig $FinalNcol 4}
        if [file exists "$SurfaceDirOutput/dubois_mask_out.bin"] {EnviWriteConfig "$SurfaceDirOutput/dubois_mask_out.bin" $FinalNlig $FinalNcol 4}
        set Fonction "Creation of the BMP File"

        set MaskFileBMP $MaskFile
        if [file exists "$SurfaceDirOutput/dubois_mask_valid_in_out.bin"] {
            EnviWriteConfig "$SurfaceDirOutput/dubois_mask_valid_in_out.bin" $FinalNlig $FinalNcol 4
            set MaskFileBMP "$SurfaceDirOutput/dubois_mask_valid_in_out.bin"
            }
        set MaskFileBMP "$SurfaceDirOutput/dubois_mask_in.bin"

        if [file exists "$SurfaceDirOutput/dubois_er.bin"] {
            set BMPFileInput "$SurfaceDirOutput/dubois_er.bin"
            set BMPFileOutput "$SurfaceDirOutput/dubois_er.bmp"
            PSPcreate_bmp_file_mask $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0 $MaskFileBMP
            } else {
            set VarError ""
            set ErrorMessage "THE FILE dubois_er.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/dubois_mv.bin"] {
            set BMPFileInput "$SurfaceDirOutput/dubois_mv.bin"
            set BMPFileOutput "$SurfaceDirOutput/dubois_mv.bmp"
            PSPcreate_bmp_file_mask $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0 $MaskFileBMP
            } else {
            set VarError ""
            set ErrorMessage "THE FILE dubois_mv.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/dubois_ks.bin"] {
            set BMPFileInput "$SurfaceDirOutput/dubois_ks.bin"
            set BMPFileOutput "$SurfaceDirOutput/dubois_ks.bmp"
            PSPcreate_bmp_file_mask $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0 $MaskFileBMP
            } else {
            set VarError ""
            set ErrorMessage "THE FILE dubois_ks.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/dubois_mask_in.bin"] {
            set BMPFileInput "$SurfaceDirOutput/dubois_mask_in.bin"
            set BMPFileOutput "$SurfaceDirOutput/dubois_mask_in.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            } else {
            set VarError ""
            set ErrorMessage "THE FILE dubois_mask_in.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        if [file exists "$SurfaceDirOutput/dubois_mask_out.bin"] {
            set BMPFileInput "$SurfaceDirOutput/dubois_mask_out.bin"
            set BMPFileOutput "$SurfaceDirOutput/dubois_mask_out.bmp"
            PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
            } else {
            set VarError ""
            set ErrorMessage "THE FILE dubois_mask_out.bin DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
        }       
    }
    } else {
    if {"$VarWarning"=="no"} { Window hide .top401; Window hide .top402; Window hide .top419; Window hide $widget(Toplevel253); TextEditorRunTrace "Close Window Surface Parameter Data Inversion" "b"}
    }
}
}} \
        -cursor {} -padx 4 -pady 2 -text Run 
    vTcl:DefineAlias "$site_3_0.but93" "Button13" vTcl:WidgetProc "Toplevel253" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but23 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/SurfaceInversion.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -pady 0 -text ? -width 20 
    vTcl:DefineAlias "$site_3_0.but23" "Button15" vTcl:WidgetProc "Toplevel253" 1
    bindtags $site_3_0.but23 "$site_3_0.but23 Button $top all _vTclBalloon"
    bind $site_3_0.but23 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Help File}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile GnuplotPipeFid GnuplotPipeHisto Load_SaveDisplay1num Load_SaveDisplay2

if {$OpenDirFile == 0} {
if {$Load_SaveDisplay1num == 1} {Window hide $widget(Toplevel460); TextEditorRunTrace "Close Window Save Display 1" "b"}
if {$Load_SaveDisplay2 == 1} {Window hide $widget(Toplevel457); TextEditorRunTrace "Close Window Save Display 2" "b"}
if {$GnuplotPipeHisto != ""} {
    catch "close $GnuplotPipeHisto"
    set GnuplotPipeHisto ""
    }
set GnuplotPipeFid ""
Window hide .top401; Window hide .top402; Window hide .top419
Window hide $widget(Toplevel253); TextEditorRunTrace "Close Window Surface Parameter Data Inversion" "b"
}} \
        -padx 4 -pady 2 -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel253" 1
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
    pack $top.tit71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit76 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $top.cpd74 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit92 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra71 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra67 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra83 \
        -in $top -anchor center -expand 1 -fill x -pady 5 -side top 

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
Window show .top253

main $argc $argv
