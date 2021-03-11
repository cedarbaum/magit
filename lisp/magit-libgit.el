;;; magit-libgit.el --- Libgit functionality       -*- lexical-binding: t -*-

;; Copyright (C) 2010-2021  The Magit Project Contributors
;;
;; You should have received a copy of the AUTHORS.md file which
;; lists all contributors.  If not, see http://magit.vc/authors.

;; Author: Jonas Bernoulli <jonas@bernoul.li>
;; Maintainer: Jonas Bernoulli <jonas@bernoul.li>

;; Package-Requires: ((emacs "26.1") (magit "0") (libgit "0"))
;; Keywords: git tools vc
;; Homepage: https://github.com/magit/magit

;; Magit is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; Magit is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
;; License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with Magit.  If not, see http://www.gnu.org/licenses.

;;; Commentary:

;; This package teaches Magit to use functions provided by the
;; `libegit2' module to perform certain tasks.  That module used the
;; Libgit2 implementation of the Git core methods and is implemented
;; in the `libgit' package.

;; The hope is that using a C module instead of calling out to `git'
;; all the time increases performance; especially on Windows where
;; starting a process is unreasonably slow.

;; This package is still experimental and not many functions have been
;; reimplemented to use `libgit' yet.

;;; Code:

(require 'cl-lib)
(require 'dash)
(require 'eieio)
(require 'seq)
(require 'subr-x)

(require 'magit-git)

(require 'libgit)

;;; Utilities

(defun magit-libgit-repo (&optional directory)
  "Return an object for the repository in DIRECTORY.
If optional DIRECTORY is nil, then use `default-directory'."
  (when-let ((default-directory
               (let ((magit-inhibit-libgit t))
                 (magit-gitdir directory))))
    (magit--with-refresh-cache
        (cons default-directory 'magit-libgit-repo)
      (libgit-repository-open default-directory))))

;;; Methods

(cl-defmethod magit-bare-repo-p
  (&context ((magit-gitimpl) (eql libgit)) &optional noerror)
  (and (magit--assert-default-directory noerror)
       (if-let ((repo (magit-libgit-repo)))
           (libgit-repository-bare-p repo)
         (unless noerror
           (signal 'magit-outside-git-repo default-directory)))))

(cl-defmethod magit-get-current-branch
  (&context ((magit-gitimpl) (eql libgit)))
  (when-let ((repo (magit-libgit-repo))
             (ref (libgit-reference-dwim repo "HEAD")))
    (when (libgit-reference-branch-p ref)
      (libgit-reference-shorthand ref))))

(cl-defmethod magit-revparse-single
  (rev &context ((magit-gitimpl) (eql libgit)) &optional symbolic-full-name)
  (when-let ((repo (magit-libgit-repo))
             (ref (libgit-revparse-single repo rev)))
    (if symbolic-full-name
        (libgit-commit-id ref)
      (libgit-commit-id ref))))

;; (magit-revparse-single "HEAD" t)
;; (magit-revparse-single "HEAD")

;; (magit-git-string "rev-parse" "HEAD")
;; (magit-git-string "rev-parse" "libgit2")

;; (magit-gitimpl)


;; (magit-get-current-branch)
;; (magit-git-string "rev-parse" "--symbolic-full-name" (magit-get-current-branch))
;; (magit-git-string-p "rev-parse" "--verify" rev)
;; (magit-git-string "rev-parse" "HEAD")


;;       (let* ((repo (libgit-repository-open path)))
;;         (should (string= c3 (libgit-commit-id (libgit-revparse-single repo "HEAD"))))
;;         (should (string= c2 (libgit-commit-id (libgit-revparse-single repo "HEAD~"))))
;;         (should (string= c2 (libgit-commit-id (libgit-revparse-single repo "HEAD^"))))
;;         (should (string= (libgit-commit-tree-id (libgit-commit-lookup repo c1))
;;                          (libgit-tree-id (libgit-revparse-single repo "HEAD~2^{tree}"))))
;;         (let ((res (libgit-revparse-ext repo "HEAD")))
;;           (should (string= c3 (libgit-commit-id (car res))))
;;           (should (libgit-reference-p (cdr res)))
;;           (should (string= "refs/heads/master" (libgit-reference-name (cdr res)))))
;;         (let ((res (libgit-revparse-ext repo c1)))
;;           (should (string= c1 (libgit-commit-id (car res))))
;;           (should-not (cdr res)))
;;         (let ((res (libgit-revparse repo (format "%s..HEAD" c1))))
;;           (should-not (car res))
;;           (should (string= c1 (libgit-commit-id (cadr res))))
;;           (should (string= c3 (libgit-commit-id (caddr res)))))
;;         (let ((res (libgit-revparse repo (format "%s...%s" c1 c2))))
;;           (should (car res))
;;           (should (string= c1 (libgit-commit-id (cadr res))))
;;           (should (string= c2 (libgit-commit-id (caddr res)))))))))

;;; _
(provide 'magit-libgit)
;;; magit-libgit.el ends here
