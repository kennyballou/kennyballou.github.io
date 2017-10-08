---
title: "Conky Mail Notifications using Maildirs"
description: "How to configure `conky` to use local `maildirs`"
tags:
    - conky
    - maildir
    - notifications
date: "2017-10-08"
slug: "conky-maildirs-config"
---

Configuring [`conky`][0] to display a count and symbol of new mail turned out
to be more tricky than I had originally anticipated.  This small post quickly
explores the issues and my own misunderstandings that led to a
working [`conky`][0] configuration and a better understanding
of [`maildir`][4].

> When the documentation fails you, use the source.

I've been trying to configure [`conky`][0] to show an icon if there is new mail
in my local [`maildir`][4].  However, I'm seemingly unable to achieve the
desired result.

Here is a trimmed down version of my [`conky`][0] configuration for reference:

> This is using [`conky`][0]'s new 1.10 syntax.

    conky.config = {
        out_to_x = false,
        own_window = false,
        out_to_console = true,
        background = false,
    };

    conky.text = [[
        ${mails ${HOME}/.mail/} 
    ]];


However, when attempting to run this through [`conky`][0], I receive the
following error:

    conky: cannot open directory

I also tried adding the `mail_spool` configuration setting to the
`conky.config` table and removing the folder from the `${mails}` variable.
Furthermore, I tried both of the above using the `${new_mails}` variable as
well, similarly to no avail.

> I actually receive a different error suggesting that `mail_spool` is no
> longer a valid configuration setting.  [Searching the code base][3], I feel
> this is accurate.

Another variation of the above I have tried is to try quoting the directory
path, which failed with a different error suggesting [`conky`][0] is attempting
to literally open the quoted folder.

It wasn't until I read the source of [`conky`][2] that I was able to figure out
what the _actual_ issue was.

What was not obvious to me from the documentation was that `$mails` and friends
request a literal [`maildir`][4] as its parameter.  This means, it's required
to specify a folder with the triplet of folders: `cur`, `new`, and `tmp` under
it.  Without which, [`conky`][0] returns the error "cannot open directory"
because [`conky`][0] is trying to open the directory
`{provided-mail-directory}/cur` instead of the provided directory.

Therefore, to solve my issue, I had changed the path given to `$mails` to the
following:

    ${mails ${HOME}/{email-account}/INBOX}

Where `{email-account}` is the email account I want updates for.

This has been a frustrating experience, and the documentation
around [`conky`][0] is unfortunately out of date.  But this is partially my own
fault, my understanding of [`maildir`][4] was incorrect and certainly led me
astray.

I'm debating whether to submit a pull request for expanding the documentation
around [`maildir`][4] usage in the `$*mails` variables but it's likely my own
misunderstanding of [`maildir`][4] that led me to so much issue.

Next, onto [`conky`][0]'s use of `if_match` and `$battery_short` to display
different battery symbols based on "charging", "discharging" and "full" states.

[0]: https://github.com/brndnmtthws/conky

[1]: https://stackoverflow.com/

[2]: https://github.com/brndnmtthws/conky/blob/master/src/mail.cc#L255

[3]: https://github.com/brndnmtthws/conky/search?utf8=%E2%9C%93&q=mail_spool&type=

[4]: https://en.wikipedia.org/wiki/Maildir
