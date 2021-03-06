(seq  concern_schema  (list 'gender 'age 'app_interest 'long_term 'life_stage
                             'status 'trade 'constellation 'educational_level 'job 'consumption 'device_info 'app_list))


(seq  product_schema  (list 'udwid 'otherid 'source))
(seq  profile_schema  (cons 'udwid (cons 'otherid concern_schema)))
(seq  map_schema  (cons 'udwid (cons 'logtype (cons 'source  concern_schema))))

(seq  redis (dcreate))
(seq  redisx (dcreate))
(seq  queue 'queue)


(defun  map (stream f)
  (iter (stream f)
    (progn
      (yield (list (funcall f  (next stream)) 
                   (isstop stream)))
      (self stream f))))

(defun  switch_content(first now schema signal)
  (if  (eq  schema nil)
      first
    (if (and (eq  (car schema) 'source)
             (eq signal 0))
        (switch_content first now (cdr schema) signal)
      (progn
        (dset first queue (car schema) (dget now queue (car schema)))
        (ddel now queue (car schema))
        (switch_content first now (cdr schema) signal)))))

(defun countsameid (first now)
  (if  (eq   (dget first queue 'logtype) (quote id_source))
      (switch_content first now map_schema 0)
    (dset  first queue 'source  (dget now  queue 'source))))


(defun prod_attr_value(prod name lst)
  (if (eq  lst nil)
      nil
    (enterconcat
     (list 
      (tabconcat (list (spaceconcat (list  prod  name  (car lst))) 0))
      (prod_attr_value prod name (cdr lst))))))

(defun target_value(first source name)
  (prod_attr_value
   source
   name
   (spacesplit  (dget first queue name))))


(defun process_next (first source schema value)
  (if (eq value nil)
      (target_attr first  source (cdr schema))
    (enterconcat 
     (list
      value
      (target_attr first  source (cdr schema))))))
 
(defun target_attr(first source schema)
  (if  (eq  schema nil)
      nil
    (process_next
     first source (cdr schema)
     (target_value first source  (car schema)))))

(defun prod_attr(first lst)
  (if  (eq  lst nil)
      nil
    (enterconcat 
     (list
      (tabconcat (list (spaceconcat (list  (car lst)  'all  0)) 0))
      (target_attr first (car lst) concern_schema)
      (prod_attr first (cdr lst))))))

(defun coverage(first)
  (enterconcat 
   (list
    (tabconcat (list (spaceconcat (list  'all  'all  0)) 0))
    (target_attr first 'all concern_schema)
    (prod_attr first (spacesplit  (dget first queue 'source))))))

(defun countotherid (first now label)
  (progn
    (if (eq   (dget first queue 'source) nil)
        nil
      (yield (list (coverage first) label)))
    (switch_content first now map_schema 1)))

(defun count (first now label)
  (if  (eq    (dget first queue 'udwid)
              (dget now queue 'udwid))
      (countsameid first now )
    (countotherid first now label)))


(defun format_schema (schema content  obj)
  (if (eq content  nil)
      obj
    (format_schema 
     (cdr schema)
     (cdr content)
     (dset  obj queue  (car schema)  (car content)))))

(defun choice_schema (content  obj)
  (if (eq (size content) 38)
      (format_schema product_schema content obj)
    (format_schema profile_schema content obj)))
 
(defun  reduce (stream first)
  (iter (stream first)
    (self stream
          (count
           first
           (format_schema  map_schema (tabsplit (strip (next stream))) redisx)
           (isstop stream)))))

(defun  reactor()
  (iter  ()
    (progn
      (yield (list  (stdin)
                    (eofstdin)))
      (self  ))))

(defun switch (content first)
  (progn
    (print content)))

(defun serial (schema first)
  (if (eq schema  nil)
      nil
    (cons
     (dget first queue  (car schema))
     (serial (cdr schema)
             first))))

(defun wrapprint (schema first)
  (switch  (tabconcat (serial schema first))
           first))

(defun  printb (stream schema)
  (if  (isstop stream)
      nil
    (progn
      (wrapprint  schema (next stream))
      (printb  stream schema))))


(defun  prints (stream )
  (if  (isstop stream)
      nil
    (progn
      (print  (next stream))
      (prints  stream))))

(defun  construct (lst)
  (if  (eq  lst nil)
      nil
    (cons (car (colsplit  (car lst)))
          (construct   (cdr lst)))))

(defun wrapconstruct (lst)
  (if  (eq  lst  nil)
      nil
    (if  (big   (size lst)  150)
        nil
      (construct lst))))

(defun new_object(lst)
  (if  (eq lst  nil)
      nil
    (spaceconcat  (wrapconstruct  (spacesplit lst)))))

(defun  get_all_ids(name obj)
  (new_object (strip   (dget  obj queue  name))))

(defun transform (schema first)
  (if (eq schema  nil)
      first
    (transform (cdr schema)
               (dset
                first
                queue
                (car schema)
                (get_all_ids (car schema) first)))))

(defun wrapdata (content  obj)
  (if (eq (size content) 38)
      (dset obj  queue 'logtype 'id_source)
    (transform 
     concern_schema
     (dset obj queue 'logtype  'profile))))
 
(defun  processoutput (content dic)
  (wrapdata content (choice_schema content dic)))

(comment
 (printb (map  (reactor) 
               (lambda (lst)  (processoutput  (tabsplit  (strip lst))
                                              redis)))
         map_schema)
 )


(prints
 (reduce (reactor)
         (format_schema  map_schema  map_schema  redis)))


