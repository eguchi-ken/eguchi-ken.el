;;; eguchi-ken.el --- eggc utility functions -*- lexical-binding: t; -*-

;; Copyright (C) 2020 eggc

;; Author: eggc <no.eggchicken@gmail.com>
;; Keywords: lisp
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(setenv "SPEC_OPTS" "--format documentation --fail-fast")
(setenv "RSPEC_RETRY_RETRY_COUNT" "1")

(menu-bar-mode -1)
(show-paren-mode 1)
(column-number-mode t)
(global-hl-line-mode)
(global-auto-revert-mode 1)
(electric-pair-mode 1)
(setq show-paren-delay 0)
(setq show-paren-style 'expression)
(set-face-attribute 'show-paren-match nil :inherit 'highlight :underline 'unspecified)
(setq-default indent-tabs-mode nil)
(setq x-select-enable-clipboard t)
(setq x-select-enable-primary t)
(setq save-interprogram-paste-before-kill t)
(setq require-final-newline t)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq backup-directory-alist `((".*". ,temporary-file-directory)))
(setq kill-ring-max 300)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

; 長い行（とくに整形されてないjson等の表示）の処理が非常に重いためそれを軽減する
; https://emacs.stackexchange.com/questions/598/how-do-i-prevent-extremely-long-lines-making-emacs-slow/601
(setq-default bidi-display-reordering nil)

; 日本語入力時のちらつきを防止する 26.3 では画面が崩れ表示できなくなるので現状 NG (我慢するしかない)
;; http://hylom.net/emacs-25.1-ime-flicker-problem
(if (version<= emacs-version "26.1") (setq redisplay-dont-pause nil))

(fset 'yes-or-no-p 'y-or-n-p) ; yes or no の質問を y, n で答えられるようにする

(package-initialize)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(menu-bar-mode t)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(defun insert-current-time ()
  "現在時間をカレントバッファに出力します"
  (interactive)
    (insert
     (replace-regexp-in-string "\n$" "" (shell-command-to-string "date '+%H:%M:%S'"))))

(defun insert-current-date (&optional diff)
  "現在年月日をカレントバッファに出力します"
  (interactive "P")
    (insert
     (shell-command-to-string
      (format
       "echo -n $(LC_ALL=ja_JP date -v-%dd +'%%Y/%%m/%%d (%%a)')"
       (or diff 0)))))

(defun file-full-path ()
  "今開いているファイルの絶対パス::行数を返します"
  (if (equal major-mode 'dired-mode)
      default-directory
    (concat (buffer-file-name) "::" (number-to-string (line-number-at-pos)))))

(defun to-clipboard (x)
  "与えられた文字列をクリップボードにコピーします"
  (when x
    (with-temp-buffer
      (insert x)
      (clipboard-kill-region (point-min) (point-max)))
    (message x)))

(defun file-full-path-to-clipboard ()
  "今開いているファイルの org link をクリップボードにコピーします"
  (interactive)
  (to-clipboard (file-full-path)))

(defun file-full-path-org-link-to-clipboard ()
  "今開いているファイルの org link をクリップボードにコピーします"
  (interactive)
  (to-clipboard (concat "[[" (file-full-path) "][" (file-name-nondirectory buffer-file-name) "]]")))

(defun file-full-path-to-clipboard-for-rspec ()
  "今開いているファイルの rspec コマンドをクリップボードにコピーします"
  (interactive)
  (to-clipboard (concat "bin/rspec " (buffer-file-name))))

(defun open-current-buffer-file ()
  "今開いているファイルを open します"
  (interactive)
  (shell-command (concat "open " (buffer-file-name))))

(defun replace-org-to-markdown ()
  "org をある程度 markdown に変換します"
  (interactive)
  (save-excursion
    (let (replacement)
      (setq replacement
            '("^* "                                "# "
              "^** "                               "## "
              "^*** "                              "### "
              "^**** "                             "#### "
              "^***** "                            "##### "
              "#\\+BEGIN_SRC"                      "```"
              "#\\+END_SRC"                        "```"
              "#\\+begin_src"                      "```"
              "#\\+end_src"                        "```"
              "\\[\\[\\(.+\\)\\]\\[\\(.+\\)\\]\\]" "[\\2](\\1)"))
      (while replacement
        (goto-char (point-min))
        (replace-regexp (pop replacement) (pop replacement))))))

(provide 'eguchi-ken)
;;; eguchi-ken.el ends here
