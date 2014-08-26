;; -*- lexical-binding: t -*-
;;; lighthouse.el --- LighthouseLogic Management Interface

;; Copyright (C) 2014 Jaime Fournier <jaimef@linbsd.org>

;; Author: Jaime Fournier <jaimef@linbsd.org>
;; Keywords: Lighthouse Management Interface
;; Version: 0.1

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
;; Some of this is cribbed from:
;; hackernews.el --- Hacker News Client for Emacs
;; Copyright (C) 2012  Lincoln de Sousa <lincoln@comum.org>

;; time, and many revisions before I would expect it to be useful to anyone.
;;

;; Define lighthouse-token to your token issued by lighthouse.
;; Define lighthouse-domain to your domain.lighthouseapp.com value (e.g. test.lighthouseapp.com would need lighthouse-domain to equal "test")

;; Requires the nice "web" package by Nic, request, and json.


;;; Code:

(require 'web)
(require 'json)

(defun lighthouse-list-tickets2 (uri extra)
  (let ((url (format "https://%s.lighthouseapp.com/projects/%s/tickets/new.json" lighthouse-domain lighthouse-app-id))
	(data `(("X-LighthouseToken" . ,lighthouse-token))))
    (web-http-get
     (lambda (httpc header my-data)
       (with-output-to-temp-buffer "*wtf*"
	 (switch-to-buffer-other-window "*wtf*")
	 (setq *NEWTICKET* my-data)
	 (with-output-to-temp-buffer "*newticket*" (pp *NEWTICKET*))
	 ;;(mapcar #'lighthouse-print-url (cdr (assoc 'tickets (json-read-from-string my-data))))))
	 ))
     :url url
     :extra-headers data
     )))


(defun lighthouse-create-new-ticket-push ()
  (interactive)
  (shell-command (format "cd ~/.emacs.d && ~/.emacs.d/create_ticket") "*NEWTICKET*"))

;; (defun my-web-post-done (result)
;;    (message "***** %S" result))

;; (defun please-work ()
;;   (interactive)
;;   (let (
;;         (heads `(
;;                  ("X-LighthouseToken" . ,lighthouse-token)
;;                  ("Content-type" . "application/json")
;;                  ))
;;         )
;;     (web-http-post
;;      (lambda (con header data)
;;        (my-web-post-done data))
;;      :url "http://test.lighthouseapp.com/projects/appid/tickets.json"
;;      :data `(("json" . "{\"ticket\":{\"assigned_user_id\":null,\"attachments_count\":0,\"closed\":false,\"created_at\":null,\"creator_id\":null,\"importance\":0,\"milestone_due_on\":null,\"milestone_id\":null,\"milestone_order\":0,\"number\":null,\"permalink\":null,\"project_id\":appid,\"raw_data\":null,\"spam\":false,\"state\":null,\"tag\":null,\"title\":\"Test XXX2\",\"updated_at\":null,\"user_id\":null,\"version\":null,\"watchers_ids\":[],\"url\":\"http://test.lighthouseapp.com/projects/appid/tickets/\",\"priority\":0,\"original_body\":null,\"latest_body\":null,\"original_body_html\":null,\"state_color\":null}}"))
;;      :extra-headers heads
;;      :mime-type "application/json"
;;      )))

(defun lighthouse-list-tickets (uri extra)
  (let (
	(url (format "%s/%s?%s" lighthouse-base-url uri extra))
	(data `(("X-LighthouseToken" . ,lighthouse-token))))
    (setq browse-url-generic-program "open")
    ;;(message "XXX:%s" url)
    (web-http-get
     (lambda (httpc header my-data)
       (with-output-to-temp-buffer "*lighthouse*"
	 (switch-to-buffer-other-window "*lighthouse*")
	 (mapcar #'lighthouse-print-url (cdr (assoc 'tickets (json-read-from-string my-data))))))
     :url url
     :extra-headers data
     )))

(defun msg-get-pending-operations-tickets ()
  (interactive)
  (message-lighthouse-list-tickets "tickets.json" "limit=100&q=milestone%3A*operations+sort%3Apriority+state%3Apending-review+&filter"))

(defun message-lighthouse-list-tickets (uri extra)
  (interactive)
  (let ((url (format "%s/%s?%s" lighthouse-base-url uri extra))
	(data `(("X-LighthouseToken" . ,lighthouse-token))))
    ;;(message "XXX:%s" url)
    (setq browse-url-generic-program "open")
    (web-http-get
     (lambda (httpc header my-data)
       (with-temp-buffer
	 ;;         (switch-to-buffer-other-window "*lighthouse*")

	 (mapcar #'my-message (cdr (assoc 'tickets (json-read-from-string my-data))))))
     :url url
     :extra-headers data
     )))

(defun my-message (element)
  (let* ( (ticket (assoc 'ticket element))
	  (url (format "%s" (cdr (assoc 'url ticket))))
	  (title (format " %s" (cdr (assoc 'title ticket))))
	  (state (format " %s" (cdr (assoc 'state ticket))))
	  (importance_name (format " %s" (cdr (assoc 'importance_name ticket))))
	  (milestone_title (format " %s" (cdr (assoc 'milestone_title ticket)))))
    (message "Pending approval%s" title)
    ))


(defun get-new-ticket ()
  (interactive)
  (setq *TICKETS* nil)
  (let (
	(data `(("X-LighthouseToken" . ,lighthouse-token)))
	)
    (web-http-get
     (lambda (httpc header my-data)
       ;; (with-output-to-temp-buffer "*my-tickets*" (pp my-data))
       (setq *TICKETS* (json-read-from-string my-data))
       ;; (with-output-to-temp-buffer "*tickets*" (pp *TICKETS*))))
       ))
    :url (format "%s" "https://test.lighthouseapp.com/projects/appid/tickets/new.json")
    :extra-headers data
    ))

(defun lighthouse-print-url (element)
  (let* ( (ticket (assoc 'ticket element))
	  (url (format "%s" (cdr (assoc 'url ticket))))
	  (title (format " %s" (cdr (assoc 'title ticket))))
	  (state (format " %s" (cdr (assoc 'state ticket))))
	  (importance_name (format " %s" (cdr (assoc 'importance_name ticket))))
	  (milestone_title (format " %s" (cdr (assoc 'milestone_title ticket)))))
    (lighthouse-create-link-in-buffer title url)
    (if (string= milestone_title " rc")
	(insert (propertize milestone_title 'face '(:foreground "red")))
      (insert (propertize milestone_title 'face '(:foreground "blue"))))
    (if (string= state " active")
	(insert (propertize state 'face '(:foreground "red")))
      (insert (propertize state 'face '(:foreground "green"))))
    ;;    (insert (propertize state 'face '(:foreground "orange")))
    ;;(message "XXX:%s:%s %s:%s " importance_name (type-of importance_name) "High" (type-of "High"))
    (insert (propertize (format " %s " (cdr (assoc 'number ticket))) 'face '(:foreground "yellow")))
    (if (string= importance_name " High")
	(insert (propertize importance_name 'face '(:foreground "red")))
      (insert (propertize importance_name 'face '(:foreground "purple"))))
    ;; (insert (propertize (format " state_color:%s" (cdr (assoc 'state_color ticket))) 'face '(:forground "blue")))
    ;;    (insert (propertize (format "original_body_html:%s" (cdr (assoc 'original_body_html ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format "latest_body:%s" (cdr (assoc 'latest_body ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format "original_body:%s" (cdr (assoc 'original_body ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " priority:%s" (cdr (assoc 'priority ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " watchers_ids:%s" (cdr (assoc 'watchers_ids ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " version:%s" (cdr (assoc 'version ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " user_id:%s" (cdr (assoc 'user_id ticket))) 'face '(:forground "blue")))
    (insert (propertize (format " updated_at:%s" (cdr (assoc 'updated_at ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " tag:%s" (cdr (assoc 'tag ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " state:%s" (cdr (assoc 'state ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " raw_data:%s" (cdr (assoc 'raw_data ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " project_id:%s" (cdr (assoc 'project_id ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " permalink:%s" (cdr (assoc 'permalink ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " number:%s" (cdr (assoc 'number ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " milestone_order:%s" (cdr (assoc 'milestone_order ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " milestone_id:%s" (cdr (assoc 'milestone_id ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " milestone_due_on:%s" (cdr (assoc 'milestone_due_on ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " importance:%s" (cdr (assoc 'importance ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " creator_id:%s" (cdr (assoc 'creator_id ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " created_at:%s" (cdr (assoc 'created_at ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " closed:%s" (cdr (assoc 'closed ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " attachments_count:%s" (cdr (assoc 'attachments_count ticket))) 'face '(:forground "blue")))
    ;; (insert (propertize (format " assigned_user_id:%s" (cdr (assoc 'assigned_user_id ticket))) 'face '(:forground "blue")))
    (princ "\n")))

(defun lighthouse-create-link-in-buffer (title url)
  "Insert clickable string inside a buffer"
  (lexical-let ((title title)
		(url url)
		(map (make-sparse-keymap)))
    (setq browse-url-generic-program "open")
    (define-key map (kbd "<RET>")
      #'(lambda (e) (interactive "p") (browse-url url)))
    (define-key map (kbd "<down-mouse-1>")
      #'(lambda (e) (interactive "p") (browse-url url)))
    (define-key map (kbd "w")
      #'(lambda (e) (interactive "p") (get-user-tickets "wayne" )))
    (define-key map (kbd "W")
      #'(lambda (e) (interactive "p") (get-user-tickets-closed "wayne" )))
    (define-key map (kbd "j")
      #'(lambda (e) (interactive "p") (get-user-tickets "jimmy" )))
    (define-key map (kbd "J")
      #'(lambda (e) (interactive "p") (get-user-tickets-closed "jimmy" )))
    (define-key map (kbd "m")
      #'(lambda (e) (interactive "p") (get-user-tickets "me" )))
    (define-key map (kbd "M")
      #'(lambda (e) (interactive "p") (get-user-tickets-closed "me" )))
    (define-key map (kbd "t")
      #'(lambda (e) (interactive "p") (get-user-tickets "tung" )))
    (insert
     (propertize
      title
      'face '(:foreground "green")
      'keymap map
      'mouse-face 'highlight))))

(defun search-tickets (q)
  (interactive "sQuery: ")
  (let ((our-buffer (format "*lighthouse-%s" q)))
    (lighthouse-list-tickets "tickets.json" (format "q=%s" q))))

(defun get-my-tickets ()
  (interactive)
  (lighthouse-list-tickets "tickets.json" "limit=100&q=responsible:me%20sort:priority%20state:new%20state:inactive%20state:active"))

(defun get-user-tickets (user)
  (interactive)
  (lighthouse-list-tickets "tickets.json" (concat "limit=100&q=responsible:" (format "%s" user) "%20sort:priority%20state:new%20state:inactive%20state:active")))

(defun get-user-tickets-closed (user)
  (interactive)
  ;;(https://test.lighthouseapp.com/projects/appid-br/tickets/bins?filter=&q=responsible%3Ame+sort%3Aupdated-+state%3Aresolved+state%3Adeployed
  (lighthouse-list-tickets "tickets.json" (concat "limit=100&q=responsible:" (format "%s" user) "+sort%3Aupdated-+state%3Aresolved+state%3Adeployed")))


(defun get-tickets-by-group (group)
  (interactive "sGroup:")
  (lighthouse-list-tickets "tickets.json" (format "limit=100&q=milestone%%3A*%s+sort%%3Apriority+state%%3Apending-review+&filter" group)))

(defun get-pending-operations-tickets ()
  (interactive)
  (lighthouse-list-tickets "tickets.json" "limit=100&q=milestone%3A*operations+sort%3Apriority+state%3Apending-review+&filter"))
;;https://test.lighthouseapp.com/projects/appid-br/tickets?q=milestone%3A*operations+sort%3Apriority+state%3Apending-review+&filter=

(defun get-new-ticket ()
  (interactive)
  (lighthouse-list-tickets2 "projects/appid/tickets/new.json" ""))

(global-set-key [f7] 'get-pending-operations-tickets)
(global-set-key [f8] 'lighthouse-create-new-ticket)
(global-set-key [f9] 'get-my-tickets)
(global-set-key [f10] 'search-tickets)
;;(run-with-timer 1 60 'msg-get-pending-operations-tickets)
;;(defun msg-get-pending-operations-tickets () ())


(defun lighthouse-print-new-ticket (ticket)
  (let ((state_color (cdr (assoc 'state_color ticket)))
  	 (original_body_html (cdr (assoc 'original_body_html ticket)))
  	 (latest_body (cdr (assoc 'latest_body ticket)))
  	 (original_body (cdr (assoc 'original_body ticket)))
  	 (importance_name (cdr (assoc 'importance_name ticket)))
  	 (priority (cdr (assoc 'priority ticket)))
  	 (url (cdr (assoc 'url ticket)))
  	 (assigned_user_name (cdr (assoc 'assigned_user_name ticket)))
  	 (creator_name (cdr (assoc 'creator_name ticket)))
  	 (user_name (cdr (assoc 'user_name ticket)))
  	 (watchers_ids (cdr (assoc 'watchers_ids ticket)))
  	 (version (cdr (assoc 'version ticket)))
  	 (user_id (cdr (assoc 'user_id ticket)))
  	 (updated_at (cdr (assoc 'updated_at ticket)))
  	 (title (cdr (assoc 'title ticket)))
  	 (tag (cdr (assoc 'tag ticket)))
  	 (state (cdr (assoc 'state ticket)))
  	 (spam (cdr (assoc 'spam ticket)))
  	 (raw_data (cdr (assoc 'raw_data ticket)))
  	 (project_id (cdr (assoc 'project_id ticket)))
  	 (permalink (cdr (assoc 'permalink ticket)))
  	 (number (cdr (assoc 'number ticket)))
  	 (milestone_order (cdr (assoc 'milestone_order ticket)))
  	 (milestone_id (cdr (assoc 'milestone_id ticket)))
  	 (milestone_due_on (cdr (assoc 'milestone_due_on ticket)))
  	 (importance (cdr (assoc 'importance ticket)))
  	 (creator_id (cdr (assoc 'creator_id ticket)))
  	 (created_at (cdr (assoc 'created_at ticket)))
  	 (closed (cdr (assoc 'closed ticket)))
  	 (attachments_count (cdr (assoc 'attachments_count ticket)))
  	 (assigned_user_id (cdr (assoc 'assigned_user_id ticket))))
    (insert (propertize (format " user_id:%s" user_id) 'face '(:foreground "darkgreen")))
    (insert (propertize (format " state_color:%s" state_color) 'face '(:foreground "lightblue")))
    (insert (propertize (format " original_body_html:%s" original_body_html) 'face '(:foreground "green")))
    (insert (propertize (format " latest_body:%s" latest_body) 'face '(:foreground "yellow")))
    (insert (propertize (format " original_body:%s" original_body) 'face '(:foreground "blue")))
    (insert (propertize (format " importance_name:%s" importance_name) 'face '(:foreground "orange")))
    (insert (propertize (format " priority:%s" priority) 'face '(:foreground "blue")))
    (insert (propertize (format " url:%s" url) 'face '(:foreground "blue")))
    (insert (propertize (format " assigned_user_name:%s" assigned_user_name) 'face '(:foreground "blue")))
    (insert (propertize (format " creator_name:%s" creator_name) 'face '(:foreground "blue")))
    (insert (propertize (format " user_name:%s" user_name) 'face '(:foreground "blue")))
    (insert (propertize (format " watchers_ids:%s" watchers_ids) 'face '(:foreground "blue")))
    (insert (propertize (format " version:%s" version) 'face '(:foreground "blue")))
    (insert (propertize (format " user_id:%s" user_id) 'face '(:foreground "blue")))
    (insert (propertize (format " updated_at:%s" updated_at) 'face '(:foreground "blue")))
    (insert (propertize (format " title:%s" title) 'face '(:foreground "blue")))
    (insert (propertize (format " tag:%s" tag) 'face '(:foreground "blue")))
    (insert (propertize (format " state:%s" state) 'face '(:foreground "blue")))
    (insert (propertize (format " spam:%s" spam) 'face '(:foreground "blue")))
    (insert (propertize (format " raw_data:%s" raw_data) 'face '(:foreground "blue")))
    (insert (propertize (format " project_id:%s" project_id) 'face '(:foreground "blue")))
    (insert (propertize (format " permalink:%s" permalink) 'face '(:foreground "blue")))
    (insert (propertize (format " number:%s" number) 'face '(:foreground "blue")))
    (insert (propertize (format " milestone_order:%s" milestone_order) 'face '(:foreground "blue")))
    (insert (propertize (format " milestone_id:%s" milestone_id) 'face '(:foreground "blue")))
    (insert (propertize (format " milestone_due_on:%s" milestone_due_on) 'face '(:foreground "blue")))
    (insert (propertize (format " importance:%s" importance) 'face '(:foreground "blue")))
    (insert (propertize (format " creator_id:%s" creator_id) 'face '(:foreground "blue")))
    (insert (propertize (format " created_at:%s" created_at) 'face '(:foreground "blue")))
    (insert (propertize (format " closed:%s" closed) 'face '(:foreground "blue")))
    (insert (propertize (format " attachments_count:%s" attachments_count) 'face '(:foreground "blue")))
    (insert (propertize (format " assigned_user_id:%s" assigned_user_id) 'face '(:foreground "blue")))))


(defun lighthouse-create-new-ticket (title body)
  (interactive "sTitle:\nsBody:\n")
  (let ((headers `(("X-LighthouseToken" . ,lighthouse-token)
		   ("Content-Type" . "application/json")))
	(url *lighthouse-new-ticket-url*)
	(to-send (json-encode
		  `((ticket
		     (assigned_user_id . ,*lighthouse-default-user-id*)
		     (attachments_count . 0)
		     (closed . :json-false)
		     (created_at)
		     (creator_id)
		     (importance . 1)
		     (milestone_due_on)
		     (milestone_id)
		     (milestone_order . 0)
		     (number)
		     (permalink)
		     (project_id . 6296)
		     (raw_data)
		     (spam . :json-false)
		     (state . "new")
		     (tag)
		     (title . ,title)
		     (updated_at)
		     (user_id)
		     (version)
		     (watchers_ids . [])
		     (url . ,*lighthouse-default-url*)
		     (priority . 0)
		     (original_body)
		     (latest_body)
		     (original_body_html)
		     (state_color)
		     (body . ,body))))))
    (web-http-post
     (lambda (httpc header my-data)
       (with-output-to-temp-buffer "*lighthouse-new-ticket*"
	 (switch-to-buffer-other-window "*lighthouse-new-ticket*")
	 (message "MD: type:%s %s" (type-of my-data) my-data)
	 (mapcar #'lighthouse-print-new-ticket  (json-read-from-string my-data))))
     :data to-send
     :extra-headers headers
     :mime-type "application/json"
     :url url
     :logging t)))
