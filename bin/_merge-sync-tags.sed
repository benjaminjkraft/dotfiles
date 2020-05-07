# call with sed -Esi -f
#
# when we see a conflict marker:
/^<{7}/ {
    : conflict
    # while we haven't yet seen an end-conflict marker,
    # append next line to pattern space
    />{7}/! {
        N
        b conflict
    }

    # now the pattern space has the entire conflict region.  Save it to the
    # hold buffer, for later use.
    h

    : resolve
    # while there's non-whitespace in the local or remote section:
    /<{7}[^\n]*[ \t\r\n]*(|\|{7}.*)={7}[^\n]*[ \t\r\n]*>{7}/! {
        # consider the first line of the local section.  if not a sync-tag,
        # or does not match the first line of the remote section, give up.
        # (regexp has unused groups to precisely match the one below)
        /(<{7}[^\n]*)\n(#|\/\/) (sync-start:[^ ]*) ([0-9]*) ([^\n]*)\n(.*)(={7}[^\n]*\n)(\2 \3 [0-9]* \5)\n/! {
            x
            b
        }

        # otherwise, move the local version above the conflict marker,
        # and delete any copies of it.
        s/(<{7}[^\n]*)\n(#|\/\/) (sync-start:[^ ]*) ([0-9]*) ([^\n]*)\n(.*)(={7}[^\n]*\n)(\2 \3 [0-9]* \5)\n/\2 \3 \4 \5\n\1\n\6\7/

        b resolve
    }

    # remove the now-handled conflict section.
    # (newline handling is awkward because the trailing newline
    # isn't in the pattern space)
    s/\n<{7}[^\n]*\n([ \t\r\n]*)[|=]{7}.*>{7}[^\n]*/\1/
}
