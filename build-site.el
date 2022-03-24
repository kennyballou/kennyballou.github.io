(require 'package)
(setq package-user-dir (expand-file-name ".packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(package-install 'htmlize)

(require 'ox-publish)
(require 'ox-html)
(require 'ox-rss)

(setq user-full-name "kb")
(setq user-mail-address "kb@devnulllabs.io")
(setq org-export-babel-evaluate nil)

(defun read-template (filename)
  "Read template contents from FILENAME."
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-string)))

(setq head-extra-template (read-template "templates/html_header.html"))
(setq header-template (read-template "templates/html_sub_header.html"))
(setq header-nav (read-template "templates/nav.html"))
(setq footer-template (read-template "templates/html_footer.html"))

(setq org-publish-project-alist
      (list
       (list "kennyballou.com"
             :components '("blog"
                           "blog-rss"
                           "pages"
                           "talks"
                           "static"))
       (list "blog"
             :recursive t
             :base-directory "./blog"
             :publishing-directory "./build/blog/"
             :htmlized-source t
             :with-author t
             :with-creator nil
             :with-date t
             :headline-level 4
             :section-numbers nil
             :with-toc t
             :with-drawers nil
             :with-sub-superscript t
             :html-link-up "https://kennyballou.com/blog"
             :html-link-home "https://kennyballou.com/"
             :html-head-include-default-style t
             :html-head-include-scripts t
             :html-divs '((preamble "header" "")
                          (content "div" "main")
                          (postamble "footer" ""))
             :html-head-extra head-extra-template
             :html-preamble header-nav
             :html-postamble footer-template
             :publishing-function #'org-html-publish-to-html)
       (list "blog-rss"
             :recursive t
             :base-directory "./blog"
             :publishing-directory "./build/"
             :exclude "*.org"
             :include (list "index.org")
             :publishing-function #'org-rss-publish-to-rss
             :html-link-home "https://kennyballou.com"
             :html-link-use-abs-url t
             :table-of-contents nil)
       (list "pages"
             :recursive t
             :base-directory "./pages"
             :publishing-directory "./build/"
             :htmlized-source t
             :with-author t
             :with-creator t
             :with-date t
             :headline-level 4
             :section-numbers nil
             :with-toc nil
             :with-drawers nil
             :with-sub-superscript t
             :html-link-up "https://kennyballou.com/"
             :html-link-home "https://kennyballou.com/"
             :html-head-include-default-style t
             :html-head-include-scripts t
             :html-divs '((preamble "header" "")
                          (content "div" "main")
                          (postamble "footer" ""))
             :html-head head-extra-template
             :html-preamble header-nav
             :html-postamble footer-template
             :publishing-function #'org-html-publish-to-html)
       (list "talks"
             :recursive t
             :base-directory "./talks"
             :publishing-directory "./build/talks"
             :htmlized-source t
             :with-author t
             :with-creator nil
             :with-date t
             :headline-level 4
             :section-numbers nil
             :with-toc nil
             :with-drawers nil
             :with-sub-superscript t
             :html-link-up "https://kennyballou.com/talks"
             :html-link-home "https://kennyballou.com/"
             :html-divs '((preamble "header" "")
                          (content "div" "main")
                          (postamble "footer" ""))
             :html-head-extra head-extra-template
             :html-preamble header-nav
             :html-postamble footer-template
             :publishing-function #'org-html-publish-to-html)
       (list "static"
             :recursive t
             :base-directory "./static"
             :base-extension ".*"
             :publishing-directory "./build/"
             :publishing-function #'org-publish-attachment)))

(org-publish-all t)

(message "Build Complete!")
