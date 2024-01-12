#!/usr/bin/env bash

# Calibre Breeze Icon Theme Build Script
# Requires calibre, breeze-icons, optipng and librsvg

# From: https://github.com/fleger/calibre-breeze-icon-theme

# With further adjustments by Peter Hoeg.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -eEuo pipefail

CALIBRE_RESOURCES_PATH="$1"
DARK_ICONS="$2"
LIGHT_ICONS="$3"
OUTPUT_DIR="$4"

ICON_EXT=.svg

CALIBRE_FMT=png
CALIBRE_EXT=.${CALIBRE_FMT}
CALIBRE_ICON_DPI=96
CALIBRE_ICON_SIZE=128

THEMED_ICON_REGEXP=".+-for-(dark|light)-theme"

# breeze icon mappins but might work with other FDo complient icon themes
declare -A mappings=(
  ['add_book']=actions/22/journal-new
  ['apple-touch-icon']=devices/22/input-touchscreen
  ['arrow-down']=actions/22/arrow-down
  ['arrow-up']=actions/22/arrow-up
  ['auto-reload']=actions/22/view-refresh
  ['auto-scroll']=actions/22/arrow-down-double
  ['auto_author_sort']=actions/22/sort-name
  ['back']=actions/22/go-previous
  ['beautify']=actions/22/flower-shape
  ['blank']=applets/256/empty
  ['book']=actions/22/address-book-new
  ['bookmarks']=actions/22/bookmarks
  ['books_in_series']=actions/22/view-file-columns
  ['bullhorn']=actions/22/new-command-alarm
  ['catalog']=actions/22/view-catalog
  ['chapters']=actions/22/format-list-ordered
  ['character-set']=actions/22/format-text-symbol
  ['clear_left']=actions/22/edit-clear
  ['close']=actions/22/view-close
  ['code']=actions/22/dialog-xml-editor
  ['column']=actions/22/object-columns
  ['compress-image']=actions/22/archive-insert
  ['config']=actions/22/configure
  ['connect_share']=status/22/cloudstatus
  ['connect_share_on']=status/22/state-ok
  ['convert']=actions/22/gtk-convert
  ['copy-to-library']=actions/22/address-book-new
  ['debug']=actions/22/debug-run
  ['default_cover']=apps/48/calibre-viewer
  ['devices/bambook']=devices/22/smartphone
  ['devices/boox']=devices/22/smartphone
  ['devices/folder']=places/22/folder-download
  ['devices/ipad']=devices/22/tablet
  ['devices/itunes']=devices/22/computer
  ['devices/kindle']=devices/22/smartphone
  ['devices/nook']=devices/22/smartphone
  ['devices/tablet']=devices/22/tablet
  ['dialog_error']=status/64/dialog-error
  ['dialog_information']=status/64/dialog-information
  ['dialog_question']=status/64/dialog-question
  ['dialog_warning']=status/64/dialog-warning
  ['dictionary']=actions/16/accessories-dictionary-symbolic # no 22 version
  ['diff']=actions/22/kr_comparedirs
  ['document-encrypt']=actions/22/document-encrypt
  ['document-import']=actions/22/document-import
  ['document-new']=actions/22/document-new
  ['document-split']=actions/22/split
  ['document_open']=actions/22/document-open
  ['donate']=actions/22/view-currency-list
  ['dot_green']=actions/22/flag-green
  ['dot_red']=actions/22/flag-red
  ['download-metadata']=actions/22/edit-download
  ['drm-locked']=actions/22/object-locked
  ['drm-unlocked']=actions/22/object-unlocked
  ['edit-clear']=actions/22/edit-clear
  ['edit-copy']=actions/22/edit-copy
  ['edit-cut']=actions/22/edit-cut
  ['edit-paste']=actions/22/edit-paste
  ['edit-redo']=actions/22/edit-redo
  ['edit-select-all']=actions/22/edit-select-all
  ['edit-undo']=actions/22/edit-undo
  ['edit_book']=apps/48/calibre-ebook-edit
  ['edit_input']=actions/22/edit-entry
  ['eject']=actions/22/media-eject
  ['embed-fonts']=actions/22/insert-text
  ['exec']=actions/22/run-build
  ['external-link']=actions/22/gnumeric-link-external
  ['filter']=actions/22/view-filter
  ['folder_saved_search']=places/symbolic/folder-saved-search-symbolic
  ['font']=actions/16/font-face # no 22 version
  ['font_size_larger']=actions/22/format-font-size-more
  ['font_size_smaller']=actions/22/format-font-size-less
  ['format-fill-color']=actions/22/format-fill-color
  ['format-indent-less']=actions/22/format-indent-less
  ['format-indent-more']=actions/22/format-indent-more
  ['format-justify-center']=actions/22/format-justify-center
  ['format-justify-fill']=actions/22/format-justify-fill
  ['format-justify-left']=actions/22/format-justify-left
  ['format-justify-right']=actions/22/format-justify-right
  ['format-list-ordered']=actions/22/format-list-ordered
  ['format-list-unordered']=actions/22/format-list-unordered
  ['format-text-bold']=actions/22/format-text-bold
  ['format-text-color']=actions/22/format-text-color
  ['format-text-heading']=actions/22/format-text-capitalize
  ['format-text-hr']=actions/22/menu_new_sep
  ['format-text-italic']=actions/22/format-text-italic
  ['format-text-strikethrough']=actions/22/format-text-strikethrough
  ['format-text-subscript']=actions/22/format-text-subscript
  ['format-text-superscript']=actions/22/format-text-superscript
  ['format-text-underline']=actions/22/format-text-underline
  ['forward']=actions/22/go-next
  ['fts']="" # we don't have a good icon for full text search
  ['gear']=actions/22/run-build
  ['gmail_logo']=actions/22/im-google
  ['grid']=actions/22/view-grid
  ['h-ellipsis']="" # see v-ellipsis
  ['help']=actions/22/help-contents
  ['heuristics']=actions/22/story-editor
  ['highlight_only_off']=status/22/camera-off
  ['highlight_only_on']=status/22/camera-on
  ['hotmail']=actions/22/im-msn
  ['html-fix']=actions/22/viewhtml
  ['icon_choose']=actions/22/view-list-icons
  ['identifiers']=actions/22/view-barcode
  ['insert-link']=actions/22/insert-link
  ['jobs']=actions/22/view-task
  ['keyboard-prefs']=actions/22/configure-shortcuts
  ['languages']=actions/22/set-language
  ['layout']=actions/22/tool_pagelayout
  ['library']=""
  ['list_remove']=actions/22/list-remove
  ['lookfeel']=actions/22/games-config-theme
  ['lt']=""
  ['mail']=actions/22/mail-sent
  ['marked']=actions/22/pin
  ['merge']=actions/22/merge
  ['merge_books']=actions/22/merge
  ['metadata']=actions/22/tag
  ['mimetypes/azw2']=mimetypes/64/application-x-fictionbook+xml
  ['mimetypes/azw3']=mimetypes/64/application-x-fictionbook+xml
  ['mimetypes/bmp']=mimetypes/64/image-bmp
  ['mimetypes/cbr']=mimetypes/64/application-x-rar
  ['mimetypes/cbz']=mimetypes/64/application-zip
  ['mimetypes/computer']=devices/64/computer
  ['mimetypes/dir']=mimetypes/64/inode-directory
  ['mimetypes/djvu']=mimetypes/64/image-vnd.djvu
  ['mimetypes/docx']=mimetypes/64/application-wps-office.docx
  ['mimetypes/epub']=mimetypes/64/application-epub+zip
  ['mimetypes/fb2']=mimetypes/64/application-x-zip-compressed-fb2
  ['mimetypes/gif']=mimetypes/64/image-gif
  ['mimetypes/html']=mimetypes/64/text-html
  ['mimetypes/jpeg']=mimetypes/64/image-jpeg
  ['mimetypes/lit']=mimetypes/64/application-x-fictionbook+xml # Sony BroadBand eBook (or BBeB)
  ['mimetypes/lrf']=mimetypes/64/application-x-fictionbook+xml # Sony BroadBand eBook (or BBeB)
  ['mimetypes/lrx']=mimetypes/64/application-x-fictionbook+xml # Sony BroadBand eBook (or BBeB)
  ['mimetypes/mobi']=mimetypes/64/application-x-fictionbook+xml
  ['mimetypes/odt']=mimetypes/64/application-vnd.oasis.opendocument.text
  ['mimetypes/opml']=mimetypes/64/text-x-opml
  ['mimetypes/pdf']=mimetypes/64/application-pdf
  ['mimetypes/png']=mimetypes/64/image-png
  ['mimetypes/rar']=mimetypes/64/application-x-rar
  ['mimetypes/rtf']=mimetypes/64/text-rtf
  ['mimetypes/snb']=mimetypes/64/application-x-fictionbook+xml # Shanda Bambook eBook
  ['mimetypes/svg']=mimetypes/64/image-svg+xml
  ['mimetypes/tpz']=mimetypes/64/application-x-fictionbook+xml # Amazon Kindle Topaz eBook
  ['mimetypes/txt']=mimetypes/64/text-plain
  ['mimetypes/unknown']=mimetypes/64/unknown
  ['mimetypes/xps']=mimetypes/64/application-msword
  ['mimetypes/zero']=mimetypes/64/application-x-zerosize
  ['mimetypes/zip']=mimetypes/64/application-zip
  ['minus']=actions/symbolic/list-remove-symbolic
  ['minusminus']=emblems/22/vcs-removed
  ['modified']=actions/22/modified
  ['network-server']=actions/22/network-connect
  ['news']=actions/22/news-subscribe
  ['next']=actions/22/media-skip-forward
  ['notes']=actions/22/note
  ['ok']=actions/22/dialog-ok
  ['page']=actions/22/view-fullscreen
  ['plugboard']=actions/22/application-menu
  ['plugins']=actions/22/plugins
  ['plugins/mobileread']=apps/48/plasma-mobile-phone
  ['plugins/plugin_deprecated']=""
  ['plugins/plugin_disabled_invalid']=""
  ['plugins/plugin_disabled_ok']=""
  ['plugins/plugin_disabled_valid']=""
  ['plugins/plugin_new']=""
  ['plugins/plugin_new_invalid']=""
  ['plugins/plugin_new_valid']=""
  ['plugins/plugin_updater']=status/22/update-high
  ['plugins/plugin_updater_updates']=status/22/update-none
  ['plugins/plugin_upgrade_invalid']=""
  ['plugins/plugin_upgrade_ok']=actions/22/dialog-ok
  ['plugins/plugin_upgrade_valid']=""
  ['plus']=actions/symbolic/list-add-symbolic
  ['plusplus']=emblems/22/vcs-added
  ['previous']=actions/22/media-skip-backward
  ['print']=actions/22/document-print
  ['publisher']=actions/22/view-media-publisher
  ['quickview']=actions/22/quickview
  ['random']=actions/22/roll
  ['rating']=emblems/22/rating
  ['reader']=apps/48/calibre-viewer
  ['reference']=actions/22/tool_references
  ['remove_books']=actions/22/edit-delete
  ['reports']=actions/22/view-statistics
  ['resize']=actions/22/transform-scale
  ['restart']=actions/22/start-over
  ['rotate-right']=actions/22/object-rotate-right
  ['save']=actions/22/document-save
  ['scheduler']=actions/22/view-time-schedule
  ['scroll']=actions/22/insert-page-break
  ['sd']=devices/64/media-flash-sd-mmc
  ['search']=actions/16/search # no 22 version
  ['series']=actions/22/view-file-columns
  ['smarten-punctuation']=actions/22/format-text-blockquote
  ['snippets']=actions/22/code-context
  ['sort']=actions/22/view-sort-ascending
  ['spell-check']=actions/22/tools-check-spelling
  ['split']=actions/22/split
  ['store']=actions/22/cloud-download
  ['swap']=actions/22/document-swap
  ['sync']=actions/22/upload-media
  ['sync-right']=actions/22/mail-forwarded
  ['tags']=actions/22/tag
  ['tb_folder']=places/22/folder-add
  ['template_funcs']=actions/22/template
  ['toc']=actions/22/gtk-index
  ['trash']=actions/22/trash-empty
  ['trim']=actions/22/transform-crop
  ['tweak']=actions/22/tool-tweak
  ['tweaks']=actions/22/view-media-equalizer
  ['unpack-book']=actions/22/archive-extract
  ['user_profile']=actions/22/user
  ['v-ellipsis']="" # see h-ellipsis
  ['view']=actions/22/preview
  ['view-image']=actions/22/view-preview
  ['view-refresh']=actions/22/view-refresh
  ['viewer']=apps/48/calibre-viewer
  ['width']=actions/22/edit-line-width
  ['window-close']=actions/22/window-close
  ['wizard']=actions/22/tools-wizard
)

_convert() {
  source="$1"
  target="$OUTPUT_DIR/$2${CALIBRE_EXT}"

  rsvg-convert \
    -d $CALIBRE_ICON_DPI \
    -p $CALIBRE_ICON_DPI \
    -w $CALIBRE_ICON_SIZE \
    -h $CALIBRE_ICON_SIZE \
    -f $CALIBRE_FMT \
    -o "$target" \
    "$source"
  optipng "$target" 2> /dev/null
}

shopt -s globstar
total=0
replaced=0

# check that files we have requested mappings for are still in use by calibre
for k in "${!mappings[@]}"; do
  file="${CALIBRE_RESOURCES_PATH}/images/${k}${CALIBRE_EXT}"
  f1="${CALIBRE_RESOURCES_PATH}/images/${k}-for-dark-theme${CALIBRE_EXT}"
  f2="${CALIBRE_RESOURCES_PATH}/images/${k}-for-light-theme${CALIBRE_EXT}"
  found=0

  if [[ $file =~ $THEMED_ICON_REGEXP ]]; then
    echo "Warning: You should not map the color scheme specific file: ${k}"
    continue
  elif [ -e "$file" ] || [ -e "$f1" ] || [ -e "$f2" ]; then
    found=1
  fi

  if [ $found -eq 0 ]; then
    echo "Warning: Unused mapping found: ${k} ($file)"
  fi
done

for i in "${CALIBRE_RESOURCES_PATH}/images/"**/*"${CALIBRE_EXT}"; do
  if [[ $i =~ $THEMED_ICON_REGEXP ]]; then
    # bash doesn't do proper regexps, so we cannot do /-for-(dark|light)-theme/
    i="${i/-for-dark-theme/}"
    i="${i/-for-light-theme/}"
  fi
  # we are miscounting if we have more than one of the following for a given icon: icon,
  # icon-for-dark-theme, icon-for-light-theme
  # oh well...
  total=$((total + 1))
  i="${i#"${CALIBRE_RESOURCES_PATH}/images/"}"
  i="${i%"${CALIBRE_EXT}"}"
  c="${mappings["$i"]-}"
  if [[ -n $c ]]; then
    f1="${DARK_ICONS}/${c}${ICON_EXT}"
    f2="${LIGHT_ICONS}/${c}${ICON_EXT}"
    if [ ! -e "$f1" ] || [ ! -e "$f2" ]; then
      echo "Error: Missing overriden icon: $c"
      exit 1
    fi
  else
    f1="${DARK_ICONS}/${i}${ICON_EXT}"
    f2="${LIGHT_ICONS}/${i}${ICON_EXT}"
  fi
  if [ -f "$f1" ] && [ -f "$f2" ]; then
    install -dm755 "$OUTPUT_DIR/$(dirname "$i")"
    _convert "$f1" "$i-for-dark-theme"
    _convert "$f2" "$i-for-light-theme"
    replaced=$((replaced + 1))
  else
    echo "Unmapped icon: $i"
  fi
done

echo "Replaced icons: $replaced/$total"
