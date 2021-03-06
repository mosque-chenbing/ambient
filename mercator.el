(defun extractquery (material)
  (strdup material
          (add 6 (find material (concat 'query 'BRACKETL)))
          (strlen material)))

(defun extractcontent (material)
  (strdup material
          0
          (find material 'BRACKETR)))

(defun extractsnki (material begin end)
  (if  (or (eq begin nil)
           (eq end nil))
      nil
    (strdup material
            begin
            end)))

(defun wrapconcat(a b c)
  (if (eq c nil)
      nil
    (print (concat a b c))))

(defun process(material)
  (wrapconcat
   (extractcontent
    (extractquery material))
   'SPACE
   (extractsnki
    material
    (find material (quote &ki=))
    (find material (quote &vr_time)))))

(defun  reactor()
  (if (eofstdin)
      nil
    (progn
      (process (strip (stdin)))
      (reactor))))

(reactor)
