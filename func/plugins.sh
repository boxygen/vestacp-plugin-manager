#!/usr/bin/env bash

add_menu() {
    local display_name="$1"
    local page_link="$2"
    local local="${3:-all}" # all|admin|user
    local position="${4:-append}" # prepend|append

    if [[ ! "$display_name" || ! "$page_link" ]]; then
        echo "Invalid arguments"
        echo "Ex: add-menu.sh <menu_name> <page_link> [<local>] [<position>]"
        exit
    fi

    if [[ "$local" == "all" ]]; then
        # Add for all users
        add_menu "$display_name" "$page_link" "admin" "$position"
        add_menu "$display_name" "$page_link" "user" "$position"
    elif [[ "$local" == "admin" || "$local" == "user" ]]; then
        if grep -q "\"$page_link\"" "/usr/local/vesta/web/templates/$local/panel.html"; then
            echo 'Plugin link already exist.'
        else
            export menu_item="<div class=\"l-menu__item <?php if(\$TAB == \"$display_name\" ) echo \"l-menu__item--active\" ?>\"><a href=\"$page_link\"><?=__(\"$display_name\")?></a></div>"

            if [[ "$position" == "prepend" ]]; then
                sed -i "/<div class=\"l-menu clearfix.*\">/a $menu_item" "/usr/local/vesta/web/templates/$local/panel.html"
            else
                sed -Ezi "s|(.*)(</div>.*<\!\-\- /.l-menu \-\->.*)|\1$menu_item\n\2|" "/usr/local/vesta/web/templates/$local/panel.html"
            fi
        fi
    fi
}

remove_menu() {
    local page_link="$1"
    local local="${2:-all}" # all|admin|user

    if [[ "$local" == "all" ]]; then
        # Add for all users
        remove_menu "$page_link" "admin"
        remove_menu "$page_link" "user"
    elif [[ "$local" == "admin" || "$local" == "user" ]]; then
        local page_link="$(echo "$page_link" | sed -E "s|/|\\\\/|")"
        sed -Ei "/<div class=\"l-menu__item.*href=\"$page_link\".*/d" "/usr/local/vesta/web/templates/$local/panel.html"
    fi
}