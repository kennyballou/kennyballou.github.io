---
title: "GPG Key Transition"
description: ""
tags:
  - GPG
  - GNUPG
  - Smartcards
  - yubikeys
date: "2017-08-23"
slug: "gpg-key-transition"
---

Today I'm announcing my [GPG][6] transition from my old, and now
expired, [GPG][6] key: [DAEE96513758BF6337F71E491066BA71A5F56C58][0]
and [8FCAF4F0CBB0BB9C590C8ED11CFA8A9CD949D956][1] to a new master
key [932F3E8E1C0F4A9895D7B8B8B0CAA28A02958308][2].  The old key will
remain vaild for a little while longer, but I prefer all future
correspondence to be addressed to my new key.

This transition document is signed by both keys to validate the
transition.

If you have signed my old key, I would appreciate new signatures on my
new key as well, provided that your signing policy permits that
without re-authenticating me.

## Key Verification ##

Specifically, the old keys were:

    pub   rsa4096 2014-06-12 [expired: 2017-06-27]
    DAEE 9651 3758 BF63 37F7 1E49 1066 BA71 A5F5 6C58

and,

    pub   rsa4096 2015-01-30 [expires: 2018-01-30]
    8FCA F4F0 CBB0 BB9C 590C 8ED1 1CFA 8A9C D949 D956

The new key is:

    pub   rsa4096 2017-06-27 [expires: 2022-06-26]
    932F 3E8E 1C0F 4A98 95D7 B8B8 B0CA A28A 0295 8308

To fetch my new key from a key server, use the following:

    gpg --keyserver pool.sks-keyservers.net --recv-key 0xB0CAA28A02958308

Or, if you prefer, you may also download the new key
from [this blog][this]:

    curl -fsL https://kennyballou.com/kballou.asc -O

The new key can be verified with the old key:

    gpg --check-sigs 0xB0CAA28A02958308

If you do not have the old key, or would like to double check, the
fingerprint can be verified against the one above:

    gpg --fingerprint 0xB0CAA28A02958308

If you have both keys, this document can be verified to be signed by
both keys:

    gpg --verify gpg-transition.markdown.asc

If you are satisfied that you have the correct key and the UID's
match, and if it's compatible with your key signing policy, I would
greatly appreciate it if you would sign my key:

    gpg --sign-key 0xB0CAA28A02958308

Finally, if you could upload these signatures, I would appreciate it.
You can either upload the signatures to a public key server directly:

    gpg --keyserver pool.sks-keyservers.net \
        --send-key 0xB0CAA28A02958308

Or you can send me an email with the new signatures:

    gpg --armor --export 0xB0CAA28A02958308

## New GPG Setup ##

The new key/transition is brought about by a number of months of
thinking about the [GPG][6] and a set of small problems I've been facing
with [GPG][6].  Mainly, sharing keys between the number of different
computers I use through the day makes me sad and worrisome.
Similarly, there isn't a good backup/recovery solution to the previous
setup, something the transition aims to fix.  Finally, multiple keys
per identity was more bothersome than I had originally anticipated.

My knowledge of [GPG][6] was young and it was time to level up my
knowledge.  To that end, I will, briefly, describe how my current
setup works.

### Key Generation and Storage ###

This new setup follows the basic "master-key with sub-keys" approach.
I have an encrypted USB drive (several, actually), that contains the
master key and the sub keys.  The master key is used for signing and
self-certification, but has no other purpose.  The sub keys are
created for the other purposes, e.g., encryption, signing, and
authentication.  I will not go over the specifics of generating the
keys or creating this setup, there
are [many][0] [guides][1] [already][2] for that purpose.

To solve the multiple device problem, I purchased a [Yubikey Neo][3]
to contain the sub keys.  I'm currently, as of this writing, only
using the [smartcard][5] functionality of the Yubikey, thus, I cannot
speak to its other uses.  However, something to note, the current
Yubikey (series 4) cannot hold keys bigger than 3072 bits, thus, all
of my sub keys are 2048 bits.  This turns out to be an acceptable
trade off, as 2048 keys are really, really similar in strength to 4096
keys.  I don't have enough cryptographic knowledge to sink into the
Elliptic-Curve based key algorithms, but they seem to show great
strengths against the larger RSA algorithm without as many weaknesses.

### Multiple Identities ###

[GPG][6] keys can have multiple UID's associated with them,
eliminating the need for a mapping of keys to email addresses, (unless
of course, a key not associated with your identity is desired).
However, I took a bit of a pragmatic approach here: I did not want
"work" keys tightly integrated with my own identity.  It will be
likely I will still generate a separate key for work related
activities.  This way, deleting passwords and other secrets is as
simple as deleting the key, I do not actually have to worry about the
possibility of still being able to decrypt the passwords and encrypted
data.

The one drawback to this approach of having a separate key pair for
personal and work related activities is that it either necessitates
_another_ [Yubikey][3], or I'm back to where I was with the previous
setup and the multi-device headaches that are associated with it.
However, I feel this is acceptable, because _usually_ I only have one
"work" device, but multiple personal devices.

### Backups ###

I've created numerous copies of the encrypted USB drive, and they will
be scattered to a number of locations, to make sure that I can still
access at least _a_ copy of the keys, it might not be the most up to
date key, but it will get me started in getting back online.

Furthermore, because flash memory isn't perfect, I've also created a
number of printouts using [paperkey][4] such that I can recover the
key even if _all_ of the USB keys fail.

### Future Work ###

One aspect of the system I would like to improve at some point is that
instead of creating exact duplicates of the flash drives or
the [paperkey][4] printouts, I would like to be able to create \\(n\\)
by \\(m\\) chunks of the key data.  That is, create a backup of
\\(n\\) pieces that only require \\(m\\) copies to be recoverable.

[this]: https://kennyballou.com/kballou.pub.asc

[0]: https://www.chameth.com/2016/08/11/offline-gnupg-master-yubikey-subkeys/

[1]: https://www.void.gr/kargig/blog/2013/12/02/creating-a-new-gpg-key-with-subkeys/

[2]: https://gist.github.com/abeluck/3383449

[3]: https://www.yubico.com/products/yubikey-hardware/yubikey-neo/

[4]: http://www.jabberwocky.com/software/paperkey/

[5]: https://en.wikipedia.org/wiki/Smart_card

[6]: https://gnupg.org/

[7]: http://blogs.fsfe.org/drdanz/?p=782
