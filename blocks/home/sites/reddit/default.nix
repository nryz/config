{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    tuir
    feh
  ];

  xdg.configFile."tuir/tuir.cfg".text = ''
    [tuir]
    ascii = False
    monochrome = False
    clipboard_cmd = xclip
    flash = True

    ;log = /tmp/tuir.log

    ; Default subreddit that will be opened when the program launches.
    subreddit = front

    persistent = False
    autologin = False
    clear_auth = True

    history_size = 200
    enable_media = True

    max_comment_cols = 120
    ;max_pager_cols = 70

    hide_username = False

    ; Set the look and feel. Default allows posts to be spread across 4 lines,
    ; while compact reduces it to 2 lines. Compact reduces the vertical space
    ; the cost of horizontal space - the title won't be wrapped to the next
    ; line.
    ; look_and_feel = default
    ; look_and_feel = compact

    ; The subreddit_format option defines the format of submissions in a
    ; SubredditPage. Some caveats:
    ;
    ; If specified, this option will override whatever was set in
    ; look_and_feel.
    ;
    ; Lines after the first line must be intented for Python's config parser to
    ; understand the option having multiple lines
    ;
    ; Attributes are assigned only to the text written from a format specifier.
    ; Certain characters ("<>/{}[]()|_-~") are assigned the separator attribute,
    ; but no extraneous text added by the user will have an attribute.
    ;
    ; This feature is experimental and bound to have bugs. If you find one, please
    ; file a bug report at https://gitlab.com/ajak/tuir/issues
    ;
    ; List of valid format specifiers and what they evaluate to:
    ; %i index
    ; %t title
    ; %s score
    ; %v vote status
    ; %c comment count
    ; %r relative creation time
    ; %R absolute creation time
    ; %e relative edit time
    ; %E absolute edit time
    ; %a author
    ; %S subreddit
    ; %u short url - 'self.reddit' or 'gfycat.com' for example
    ; %U full url
    ; %A saved
    ; %h hidden
    ; %T stickied
    ; %g gold
    ; %n nsfw
    ; %f post flair
    ; %F all flair - saved, hidden, stickied, gold, nsfw, post flair,
    ;                separated by spaces
    ;
    ; For example, the compact look_and_feel is a format of:
    ; subreddit_format = %t
    ;  <%i|%s%v|%cC> %r%e %a %S %F
    ;

    ; Color theme, use "tuir --list-themes" to view a list of valid options.
    ; This can be an absolute filepath, or the name of a theme file that has
    ; been installed into either the custom of default theme paths.
    theme = molokai

    force_new_browser_window = False

    oauth_client_id = zjyhNI7tK8ivzQ
    oauth_client_secret = praw_gapfill
    oauth_redirect_uri = http://127.0.0.1:65000/
    oauth_redirect_port = 65000
    oauth_scope = edit,history,identity,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote

    ; This is a separate token for the imgur api. It's used to extract images
    ; from imgur links and albums so they can be opened with mailcap.
    ; See https://imgur.com/account/settings/apps to generate your own key.
    imgur_client_id = b33d69ac8931734


    [bindings]
    ; Base page
    EXIT = q 
    FORCE_EXIT = Q
    HELP = ?
    SORT_1 = 1
    SORT_2 = 2
    SORT_3 = 3
    SORT_4 = 4
    SORT_5 = 5
    SORT_6 = 6
    SORT_7 = 7
    MOVE_UP = k, <KEY_UP>
    MOVE_DOWN = j, <KEY_DOWN>
    PREVIOUS_THEME = <KEY_F2>
    NEXT_THEME = <KEY_F3>
    PAGE_UP = m, <KEY_PPAGE>, <NAK>
    PAGE_DOWN = n, <KEY_NPAGE>, <EOT>
    PAGE_TOP = gg
    PAGE_BOTTOM = G
    UPVOTE = a
    DOWNVOTE = z
    LOGIN = u
    DELETE = d
    EDIT = e
    INBOX = i
    REFRESH = r, <KEY_F5>
    PROMPT = /
    SAVE = w
    COPY_PERMALINK = y
    COPY_URL = Y
    PRIVATE_MESSAGE = C
    SUBSCRIPTIONS = s
    MULTIREDDITS = S

    ; Submission page
    SUBMISSION_TOGGLE_COMMENT = 0x20
    SUBMISSION_OPEN_IN_BROWSER = o, <LF>, <KEY_ENTER>
    SUBMISSION_POST = c
    SUBMISSION_EXIT = h, <KEY_LEFT>
    SUBMISSION_OPEN_IN_PAGER = l, <KEY_RIGHT>
    SUBMISSION_OPEN_IN_URLVIEWER = b
    SUBMISSION_GOTO_PARENT = K
    SUBMISSION_GOTO_SIBLING = J

    ; Subreddit page
    SUBREDDIT_SEARCH = f
    SUBREDDIT_POST = c
    SUBREDDIT_OPEN = l, <KEY_RIGHT>
    SUBREDDIT_OPEN_IN_BROWSER = o, <LF>, <KEY_ENTER>
    SUBREDDIT_FRONTPAGE = p
    SUBREDDIT_HIDE = 0x20

    ; Subscription page
    SUBSCRIPTION_SELECT = l, <LF>, <KEY_ENTER>, <KEY_RIGHT>
    SUBSCRIPTION_EXIT = h, s, S, <ESC>, <KEY_LEFT>

    ; Inbox page
    INBOX_VIEW_CONTEXT = l, <KEY_RIGHT>
    INBOX_OPEN_SUBMISSION = o, <LF>, <KEY_ENTER>
    INBOX_REPLY = c
    INBOX_MARK_READ = w
    INBOX_EXIT = h, <ESC>, <KEY_LEFT>
  '';

  home.file.".mailcap".text = ''
    image/x-imgur-album; feh -g 640x480  -. %s; test=test -n "$DISPLAY"
    image/gif; mpv '%s' --autofit=640x480 --loop=inf; test=test -n "$DISPLAY"
    image/*; feh -g 640x480 -. '%s'; test=test -n "$DISPLAY"
    video/x-youtube; mpv --ytdl-format=bestvideo+bestaudio/best '%s' --autofit=640x480; test=test -n "$DISPLAY"
    video/*; mpv '%s' --autofit=640x480 --loop=inf; test=test -n "$DISPLAY"
  '';
}
