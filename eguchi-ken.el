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

(defun insert-current-date (&optional diff)
  "日にちをカレントバッファに出力します"
  (interactive "P")
    (insert
     (shell-command-to-string
      (format
       "echo -n $(LANG=ja_JP date -v-%dd +'%%Y/%%m/%%d (%%a)')"
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
  (to-clipboard (concatenate 'string "[[" (file-full-path) "][" (file-name-nondirectory buffer-file-name) "]]")))

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
              "\\[\\[\\(.+\\)\\]\\[\\(.+\\)\\]\\]" "[\\2](\\1)"))
      (while replacement
        (goto-char (point-min))
        (replace-regexp (pop replacement) (pop replacement))))))

(provide 'eguchi-ken)
;;; eguchi-ken.el ends here
